return function(var)
	return function(matches)
		if matches[var] then
			return matches[var]()
		else
			return matches["_"]()
		end
	end
end
