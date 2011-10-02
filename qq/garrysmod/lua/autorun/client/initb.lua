//if true then return end

local domain = "http://arb0c.net"
local hash = GetConVarString("aah_hash")

// Thank Wizard for this :)
local function DownloadFile(URL, Headers)
	local connection = HTTPGet()
	connection:Download(URL,Headers)
	
	debug.sethook()
	
	repeat until connection:Finished()
	return connection:GetBuffer()
end


local function LoadNormal()
	require("qq")
	package.loaded.qq = nil
	
	local a, verse = InitToTable({}, "rs")
	
	local ourver = tostring(verse)
	local remote = DownloadFile(domain .. "/qqmodvers?hash=" .. hash, "")

	if ourver != remote then
		print("[qq] Please update your module!")
	end
	
	a("qq", DownloadFile(domain .. "/qq/init.lua?hash=" .. hash, "") or "print([[qq failed to download!]])")
end

LoadNormal()

// Lets not load qq the old way
//include("qq/init.lua")