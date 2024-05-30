return function(self, contents)
	self.callbacks.OnDeviceRemoved(contents)

	for i, device in self.devices do
		if device.DeviceIndex == contents.DeviceIndex then
			table.remove(self.devices, i)
		end
	end
end
