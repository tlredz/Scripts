local _ENV = (getgenv or getrenv or getfenv)()
local BETA_VERSION = BETA_VERSION or _ENV.BETA_VERSION

local Scripts = {
	{
		GameId = 994732206,
		UrlPath = if BETA_VERSION then "BLOX-FRUITS-BETA.lua" else "BloxFruits.luau"
	},
	{
		PlacesIds = {10260193230},
		UrlPath = "MemeSea.luau"
	}
}

local fetcher, urls = {}, {}

do
	local last_exec = _ENV.rz_execute_debounce
	
	if last_exec and (tick() - last_exec) <= 5 then
		return nil
	end
	
	_ENV.rz_execute_debounce = tick()
end

urls.Owner = "https://raw.githubusercontent.com/tlredz/";
urls.Repository = urls.Owner .. "Scripts/refs/heads/main/";
urls.Translator = urls.Repository .. "Translator/";
urls.Utils = urls.Repository .. "Utils/";

do
	local executor = syn or fluxus
	local queueteleport = queue_on_teleport or (executor and executor.queue_on_teleport)
	
	if not _ENV.rz_added_teleport_queue and type(queueteleport) == "function" then
		local ScriptSettings = {...}
		local SettingsCode = ""
		
		_ENV.rz_added_teleport_queue = true
		
		local Success, EncodedSettings = pcall(function()
			return game:GetService("HttpService"):JSONEncode(ScriptSettings)
		end)
		
		if Success and EncodedSettings then
			SettingsCode = "unpack(game:GetService('HttpService'):JSONDecode('" .. EncodedSettings .. "'))"
		end
		
		local SourceCode = ("loadstring(game:HttpGet('%smain.luau'))(%s)"):format(urls.Repository, SettingsCode)
		
		if BETA_VERSION then
			SourceCode = "getgenv().BETA_VERSION=true;" .. SourceCode
		end
		
		pcall(queueteleport, SourceCode)
	end
end

do
	if _ENV.rz_error_message then
		_ENV.rz_error_message:Destroy()
	end
	
	local identifyexecutor = identifyexecutor or (function() return "Unknown" end)
	
	local function CreateMessageError(Text)
		_ENV.loadedFarm = nil
		_ENV.OnFarm = false
		
		local Message = Instance.new("Message", workspace)
		Message.Text = string.gsub(Text, urls.Owner, "")
		_ENV.rz_error_message = Message
		
		error(Text, 2)
	end
	
	local function formatUrl(Url)
		for key, path in urls do
			if Url:find("{" .. key .. "}") then
				return Url:gsub("{" .. key .. "}", path)
			end
		end
		
		return Url
	end
	
	function fetcher.get(Url)
		local success, response = pcall(function()
			return game:HttpGet(formatUrl(Url))
		end)
		
		if success then
			return response
		else
			CreateMessageError(`[1] [{ identifyexecutor() }] failed to get http/url/raw: { Url }\n>>{ response }<<`)
		end
	end
	
	function fetcher.load(Url: string, concat: string?)
		local raw = fetcher.get(Url) .. (if concat then concat else "")
		local runFunction, errorText = loadstring(raw)
		
		if type(runFunction) ~= "function" then
			CreateMessageError(`[2] [{ identifyexecutor() }] sintax error: { Url }\n>>{ errorText }<<`)
		else
			return runFunction
		end
	end
end

local function IsPlace(Script)
	if Script.PlacesIds and table.find(Script.PlacesIds, game.PlaceId) then
		return true
	elseif Script.GameId and Script.GameId == game.GameId then
		return true
	end
	return false
end

for _, Script in Scripts do
	if IsPlace(Script) then
		return fetcher.load("{Repository}Games/" .. Script.UrlPath)(fetcher, ...)
	end
end
