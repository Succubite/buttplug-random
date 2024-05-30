local Device = require("../device")

return function(self, contents)
    for _, device in contents.Devices do
        self.devices[#self.devices + 1] = Device.create(self, device)
    end
end