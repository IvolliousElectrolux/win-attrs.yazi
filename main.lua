--- @since 26.8.15

local state = ya.sync(function(st, args)
	if args.action == "set" then
		st.cache = st.cache or {}
		st.cache[args.url] = args.attrs
	elseif args.action == "get" then
		return st.cache and st.cache[args.url]
	end
end)

local function parse_attrs(out)
	-- attrib output example: "A  SHR     C:\path\to\file"
	local attr_part = out:sub(1, 11)
	return {
		attr_part:find("R", 1, true) and "R" or ".",
		attr_part:find("H", 1, true) and "H" or ".",
		attr_part:find("S", 1, true) and "S" or ".",
		attr_part:find("A", 1, true) and "A" or ".",
	}
end

---@type UnstableFetcher
local function fetch(_, job)
	return ya.co(function()
		for _, file in ipairs(job.files) do
			local url = tostring(file.url)
			local output = Command("attrib"):arg(url):output()
			if output and output.status.success then
				state({ action = "set", url = url, attrs = parse_attrs(output.stdout) })
			end
			coroutine.yield(file, {})
		end
	end)
end

return {
	fetch = fetch,
	get = function(url)
		return state({ action = "get", url = tostring(url) })
	end,
}
