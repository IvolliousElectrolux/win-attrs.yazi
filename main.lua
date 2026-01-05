local state = ya.sync(function(st, args)
	if args.action == "set" then
		st.cache = st.cache or {}
		st.cache[args.url] = args.attrs
	elseif args.action == "get" then
		return st.cache and st.cache[args.url]
	end
end)

return {
	fetch = function(self, job)
		local urls = {}
		for _, file in ipairs(job.files) do
			table.insert(urls, tostring(file.url))
		end

		if #urls == 0 then
			return true
		end

		-- Windows attrib command
		-- We use a batch approach to avoid spawning too many processes
		-- But for simplicity in parsing, we'll do them in a loop here.
		-- Yazi fetchers run in their own thread, so this is non-blocking for UI.
		for _, url in ipairs(urls) do
			local child, err = Command("attrib"):arg(url):stdout(Command.PIPED):spawn()
			if child then
				local output = child:wait_with_output()
				if output and output.status.success then
					local out = output.stdout
					-- attrib output example: "A  SHR     C:\path\to\file"
					-- The attributes part is before the path (first 11 chars)
					local attr_part = out:sub(1, 11)
					local r = attr_part:find("R") and "R" or "."
					local h = attr_part:find("H") and "H" or "."
					local s = attr_part:find("S") and "S" or "."
					local a = attr_part:find("A") and "A" or "."
					
					state({ action = "set", url = url, attrs = { r, h, s, a } })
				end
			end
		end
		return true
	end,

	get = function(url)
		return state({ action = "get", url = tostring(url) })
	end,
}

