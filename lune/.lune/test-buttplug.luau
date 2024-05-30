local Buttplug = require("modules/buttplug")
local task = require("@lune/task")

local Client = Buttplug.new("testing", "ws://127.0.0.1:12345")
Client.callbacks.OnDeviceAdded += function(device) print("it worked", device) end
Client.callbacks.OnDeviceRemoved += function(device) print(device) end
Client.callbacks.OnSensorRead += function(data) print(data) end

Client:StartScanning()

task.spawn(function()
    while true do
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
            task.wait(0.5)
            device:SendScalarCmd({
                {
                    Index = 0,
                    Scalar = 0.0,
                    ActuatorType = "Vibrate",
                },
                {
                    Index = 1,
                    Scalar = 0.0,
                    ActuatorType = "Vibrate",
                },
            })
        end

        task.wait(0.5)
    end
end)