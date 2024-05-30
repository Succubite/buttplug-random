local serde = require("@lune/serde")

--[=[
    @class Device
    @within Buttplug

    Represents a device on the Buttplug server.
]=]
local Device = {}

--[=[
    @within Device
    @function SendScalarCmd

    Sends a scalar command to the device. This can be anything from a vibration to a actuation.

    @param scalars The scalars to send
]=]
function Device:SendScalarCmd(scalars)
    local msg = serde.encode("json", {
        {
            ScalarCmd = {
                Id = 1,
                DeviceIndex = self.DeviceIndex,
                Scalars = scalars,
            }
        }
    })

    self.ws.send(msg)
end

--[=[
    @within Device
    @function ReadSensor

    Reads a sensor from the device.

    @param sensor_index The index of the sensor
    @param sensor_type The type of the sensor
]=]
function Device:ReadSensor(sensor_index, sensor_type)
    local msg = serde.encode("json", {
        {
            SensorReadCmd = {
                Id = 1,
                DeviceIndex = self.DeviceIndex,
                SensorIndex = sensor_index,
                SensorType = sensor_type,
            }
        }
    })

    self.ws.send(msg)
end

--[=[
    @within Device
    @function SubscribeSensor

    Subscribes to a sensor from the device.

    @param sensor_index The index of the sensor
    @param sensor_type The type of the sensor
]=]
function Device:SubscribeSensor(sensor_index, sensor_type)
    local msg = serde.encode("json", {
        {
            SensorSubscribeCmd = {
                Id = 1,
                DeviceIndex = self.DeviceIndex,
                SensorIndex = sensor_index,
                SensorType = sensor_type,
            }
        }
    })

    self.ws.send(msg)
end

--[=[
    @within Device
    @function UnsubscribeSensor

    Unsubscribes from a sensor from the device.

    @param sensor_index The index of the sensor
    @param sensor_type The type of the sensor
]=]
function Device:UnsubscribeSensor(sensor_index, sensor_type)
    local msg = serde.encode("json", {
        {
            SensorUnsubscribeCmd = {
                Id = 1,
                DeviceIndex = self.DeviceIndex,
                SensorIndex = sensor_index,
                SensorType = sensor_type,
            }
        }
    })

    self.ws.send(msg)
end

--[=[
    @within Device
    @function Stop

    Stops the device.
]=]
function Device:Stop()
    local msg = serde.encode("json", {
        {
            StopDevice = {
                Id = 1,
                DeviceIndex = self.DeviceIndex,
            }
        }
    })

    self.ws.send(msg)
end

--[=[
    @within Device
    @function create

    Creates a new device from the device data.

    @param buttplug The Buttplug instance
    @param device_data The device data
]=]
function Device.create(buttplug, device_data)
    local self = setmetatable({}, {
        __index = Device,
    })

    self.DeviceIndex = device_data.DeviceIndex
    self.DeviceName = device_data.DeviceName
    self.DeviceMessages = device_data.DeviceMessages
    self.ws = buttplug.ws

    return self
end

return Device