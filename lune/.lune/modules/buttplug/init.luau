local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local CallbackTable = require("utils/CallbackTable")
local match = require("utils/match")
local handlers = {
	DeviceAdded = require("handlers/DeviceAdded"),
	DeviceRemoved = require("handlers/DeviceRemoved"),
	DeviceList = require("handlers/DeviceList"),
	ScanningFinished = require("handlers/ScanningFinished"),
	SensorReading = require("handlers/SensorReading"),
}

--[=[
	@class Buttplug

	Represents a Buttplug client.

	### Example usage

	```lua
	local Buttplug = require("buttplug")

	local Client = Buttplug.new("testing", "ws://127.0.0.1:12345")
	Client.callbacks.OnDeviceAdded += function(device) print("it worked", device) end

	Client:StartScanning()
	for _, device in Client.devices do
		device:SendScalarCmd({
            {
                Index = 0,
                Scalar = 0.0,
                ActuatorType = "Vibrate",
            },
            {
                Index = 1,
                Scalar = 1.0,
                ActuatorType = "Vibrate",
            },
        })
	end
	```
]=]
local Buttplug = {}

--[=[
	@within Buttplug

	Requests server info from the Buttplug server.
]=]
function Buttplug:RequestServerInfo()
	local msg = serde.encode("json", {
		{
			RequestServerInfo = {
				Id = 1,
				ClientName = self.client_name,
				MessageVersion = 3,
			},
		},
	})

	self.ws.send(msg)
	local server_info = serde.decode("json", self.ws.next())
	return server_info[1] -- silly
end

--[=[
	@within Buttplug

	Requests device list from the Buttplug server.
]=]
function Buttplug:RequestDeviceList()
	local msg = serde.encode("json", {
		{
			RequestDeviceList = {
				Id = 1,
			},
		},
	})

	self.ws.send(msg)
end

--[=[
	@within Buttplug

	Stops scanning for devices.

	@see StartScanning
]=]
function Buttplug:StopScanning()
	local msg = serde.encode("json", {
		{
			StopScanning = {
				Id = 1,
			},
		},
	})

	self.ws.send(msg)
end

--[=[
	@within Buttplug

	Starts scanning for devices.

	@see StopScanning
]=]
function Buttplug:StartScanning()
	local msg = serde.encode("json", {
		{
			StartScanning = {
				Id = 1,
			},
		},
	})

	self.ws.send(msg)
end

--[=[
	@within Buttplug
	@function new

	Creates a new Buttplug client.

	@param client_name The name of the client
	@param websocket_addr The address of the websocket
]=]
function Buttplug.new(client_name, websocket_addr)
	local self = setmetatable({
		client_name = client_name,
	}, {
		__index = Buttplug,
	})
	self.ws = net.socket(websocket_addr)
	self.callbacks = {
		OnDeviceAdded = CallbackTable.create(),
		OnDeviceRemoved = CallbackTable.create(),
		OnScanningFinished = CallbackTable.create(),
		OnSensorRead = CallbackTable.create(),
	}

	self.server_info = self:RequestServerInfo()
	self.devices = {}

	self:RequestDeviceList()

	task.spawn(function()
		while true do
			local msg = self.ws.next() -- yields until next message
			local decoded = serde.decode("json", msg)[1]
			local msg_type = next(decoded)
			local contents = decoded[msg_type]

			match(msg_type)({
				["DeviceAdded"] = function()
					handlers.DeviceAdded(self, contents)
				end,
				["DeviceRemoved"] = function()
					handlers.DeviceRemoved(self, contents)
				end,
				["DeviceList"] = function()
					handlers.DeviceList(self, contents)
				end,
				["ScanningFinished"] = function()
					handlers.ScanningFinished(self, contents)
				end,
				["SensorReading"] = function()
					handlers.SensorReading(self, contents)
				end,
				["Ok"] = function() end, -- We dont really have to do anything, to be honest
				["Error"] = function() end, -- TODO: Implement this
				_ = function()
					print("Unhandled message type: ", msg_type, contents)
				end,
			})
		end
	end)

	task.spawn(function()
		local msg = serde.encode("json", {
			{
				Ping = {
					Id = 5,
				},
			},
		})

		while true do
			self.ws.send(msg)
			task.wait(1)
		end
	end)

	return self
end

return Buttplug
