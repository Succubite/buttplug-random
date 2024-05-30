local Device = require("../device")

return function(self, contents)
    self.callbacks.OnDeviceAdded(contents)

    self.devices[#self.devices + 1] = Device.create(self, contents)
end