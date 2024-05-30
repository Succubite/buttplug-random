local function create_callback_table()
	return setmetatable({ callbacks = {} }, {
		__add = function(self, callback)
			self.callbacks[#self.callbacks + 1] = callback
			return self
		end,
		__iter = function(self)
			return next, self.callbacks
		end,
		__index = function(self, key)
			return self.callbacks[key]
		end,
		__call = function(self, ...)
			for _, callback in self do
				callback(...)
			end
		end,
	})
end

return {
    create = create_callback_table,
}