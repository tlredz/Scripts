local importer = ...
assert(type(importer) == "table", "package importer not found")
assert(type(importer.Import) == "function", "Import not found")

local RobloxServices = importer:Import("RobloxServices")
local Connections = importer:Import("Connections")
local Obfuscated = importer:Import("Obfuscated")
local Settings = importer:Import("Settings")

local _ENV = (getgenv or getrenv or getfenv)()

local VirtualInputManager: VirtualInputManager = RobloxServices.VirtualInputManager
local CollectionService: CollectionService = RobloxServices.CollectionService
local ReplicatedStorage: ReplicatedStorage = RobloxServices.ReplicatedStorage
local TeleportService: TeleportService = RobloxServices.TeleportService
local TweenService: TweenService = RobloxServices.TweenService
local RunService: RunService = RobloxServices.RunService
local Players: Players = RobloxServices.Players

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF: RemoteFunction = Remotes:WaitForChild("CommF_")
local CommE: RemoteEvent = Remotes:WaitForChild("CommE")

local ChestModels: Folder = workspace:WaitForChild("ChestModels")
local WorldOrigin: Folder = workspace:WaitForChild("_WorldOrigin")
local Characters: Folder = workspace:WaitForChild("Characters")
local SeaBeasts: Folder = workspace:WaitForChild("SeaBeasts")
local Enemies: Folder = workspace:WaitForChild("Enemies")
local Boats: Folder = workspace:WaitForChild("Boats")
local Map: Model = workspace:WaitForChild("Map")

local EnemySpawns: Folder = WorldOrigin:WaitForChild("EnemySpawns")
local Locations: Folder = WorldOrigin:WaitForChild("Locations")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped
local Player = Players.LocalPlayer

local Data: Folder = Player:WaitForChild("Data")
local Level: IntValue = Data:WaitForChild("Level")
local Fragments: IntValue = Data:WaitForChild("Fragments")
local Money: IntValue = Data:WaitForChild("Beli")

local Modules: Folder? = ReplicatedStorage:WaitForChild("Modules")
local Net: ModuleScript = Modules:WaitForChild("Net")

local BLACKLISTED_EXECUTORS: { string } = {"NULL"}

local EXECUTOR_NAME: string = string.upper(if identifyexecutor then identifyexecutor() else "NULL")
local IS_BLACKLISTED_EXECUTOR: boolean = table.find(BLACKLISTED_EXECUTORS, EXECUTOR_NAME) ~= nil

local hookmetamethod = (not IS_BLACKLISTED_EXECUTOR and hookmetamethod) or (function(...) return ... end)
local hookfunction = (not IS_BLACKLISTED_EXECUTOR and hookfunction) or (function(...) return ... end)

local sethiddenproperty: (Instance, string, any?) -> (nil) = sethiddenproperty
local setsimulationradius: (Radius: number) -> (nil) = setsimulationradius

local setupvalue: (any, number, any?) -> (nil) = setupvalue or (debug and debug.setupvalue)
local getupvalue: (any, number) -> any = getupvalue or (debug and debug.getupvalue)

local ServerOwnerId: IntValue? = ReplicatedStorage:FindFirstChild("PrivateServerOwnerId")
local IsPrivateServer: boolean = if ServerOwnerId then ServerOwnerId.Value ~= 0 else true

local SET_SIMULATION_RADIUS_DEBOUNCE = 0
local CURRENT_RAID_ISLAND = nil

local function SetSimulationRadius(radius)
	if (tick() - SET_SIMULATION_RADIUS_DEBOUNCE) > 0 then
		SET_SIMULATION_RADIUS_DEBOUNCE = tick() + 5
		
		if setsimulationradius then
			pcall(setsimulationradius, radius)
		end
		
		if sethiddenproperty then
			pcall(sethiddenproperty, Player, "SimulationRadius", radius)
		end
	end
end

local function CreateDictionary(array: { string? }, value: any?): { [string]: any? }
	local Dictionary = {}
	
	for _, string in ipairs(array) do
		Dictionary[string] = if type(value) == "table" then {} else value
	end
	
	return Dictionary
end

local function NewHookManager()
	local HookManager = {}

	local hookedProperties = {}
	local protectedObjects = {}
	local noclipObjects = {}

	local SafeObject = Obfuscated.SafeObject
	local cloneObject = SafeObject.Clone
	local originalCloneProperties = CreateDictionary(Obfuscated.OriginalProperties, true)
	
	local function isString(index)
		return type(index) == "string"
	end
	
	local NOCLIP_PROPERTY = "CanCollide"
	
	local originalIndex
	local originalNamecall
	
	originalIndex = hookmetamethod(game, "__index", function(object, index)
		local clone = protectedObjects[object]
		if clone and isString(index) and not originalCloneProperties[index] then
			object = clone
		elseif index == NOCLIP_PROPERTY then
			local isNoclip = noclipObjects[object]
			if isNoclip then
				return isNoclip
			end
		end
		
		local hooked = hookedProperties[object]
		if hooked and hooked[index] ~= nil then
			return hooked[index]
		end
		
		return originalIndex(object, index)
	end)

	originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		if protectedObjects[self] then
			return originalNamecall(SafeObject, ...)
		end
		return originalNamecall(self, ...)
	end)

	function HookManager.ProtectObject(object: Instance)
		assert(object, `ProtectObject -> Instance expeted, got {typeof(object)}`)
		
		object.Name = SafeObject.Name
		protectedObjects[object] = cloneObject(SafeObject)
	end

	function HookManager.UnprotectObject(object: Instance)
		if HookManager.IsProtected(object) then return end
		assert(object, `UnprotectObject -> Instance expeted, got {typeof(object)}`)
		
		local safeObject = protectedObjects[object]
		if safeObject then
			protectedObjects[object] = nil
			safeObject:Destroy()
		end
	end

	function HookManager.IsProtected(object: Instance): boolean
		return protectedObjects[object] ~= nil
	end

	function HookManager.HookProperty(object: Instance, property: string, value: any?)
		if not hookedProperties[object] then
			hookedProperties[object] = {}
		end
		hookedProperties[object][property] = value
	end

	function HookManager.UnhookProperty(object: Instance, property: string)
		local hooked = hookedProperties[object]
		if hooked then
			hooked[property] = nil
			
			if next(hooked) == nil then
				hookedProperties[object] = nil
			end
		end
	end

	function HookManager.SetNoclipObjects(list)
		noclipObjects = list
	end
	
	function HookManager.Clear()
		table.clear(protectedObjects)
		table.clear(hookedProperties)
		HookManager.ClearNoclipObjects()
	end
	
	HookManager.OriginalIndex = originalIndex
	HookManager.OriginalNamecall = originalNamecall
	
	return HookManager
end

local HookManager = (function()
	local manager = _ENV.rz_hook_manager or NewHookManager()
	_ENV.rz_hook_manager = manager
	return manager
end)()

local HIDDEN_SETTINGS: { [string]: any } = {
	SKILL_COOLDOWN = 0.5,
	CLEAR_AFTER = 50,
	
	SILENT_AIM_ENABLED = true,
	WALKSPEED_BYPASS_ENABLED = true,
}

local CACHE_EQUIPPED_WEAPON = nil

local function GetEnemyName(text: string): string
	return text:gsub(if text:find("Lv. ") then " %pLv. %d+%p" else " %pBoss%p", "")
end

local function CheckPlayerAlly(__Player: Player): boolean
	if __Player.Parent == Characters then
		__Player = Players:GetPlayerFromCharacter(__Player)
	end
	
	if tostring(__Player.Team) == "Marines" and __Player.Team == Player.Team then
		return false
	elseif __Player:HasTag(`Ally{Player.Name}`) or Player:HasTag(`Ally{__Player.Name}`) then
		return false
	end
	
	return true
end

local function CreateNewClear()
	local COUNT_NEWINDEX = 0
	
	return {
		__newindex = function(self, index, value)
			if COUNT_NEWINDEX >= HIDDEN_SETTINGS.CLEAR_AFTER then
				for key, cache in self do
					if typeof(cache) == "Instance" and not cache:IsDescendantOf(game) then
						rawset(self, key, nil)
					end
				end
				COUNT_NEWINDEX = 0
			end
			
			COUNT_NEWINDEX += 1
			return rawset(self, index, value)
		end
	}
end

local function CreateDefaultDictionary(Value: any?): table
	return setmetatable({}, { __index = function() return Value end })
end

local HumanoidsCache do
	local Metatable = CreateNewClear()
	Metatable.__index = function(self, Character)
		local Humanoid = Character:FindFirstChild(if Character.Parent == SeaBeasts then "Health" else "Humanoid")
		
		if Humanoid then
			self[Character] = Humanoid
			return Humanoid
		end
	end
	
	HumanoidsCache = setmetatable({}, Metatable)
end

local function GetHuamnoidHealth(Humanoid: Humanoid): number
	return Humanoid[if Humanoid.ClassName == "Humanoid" then "Health" else "Value"]
end

local function DistanceFromCharacter(Value: CFrame | BasePart | Vector3): number
	if typeof(Value) ~= "Vector3" then
		Value = Value.Position
	end
	return Player:DistanceFromCharacter(Value)
end

local function IsAlive(Character: Model, _Humanoid: Humanoid): boolean
	if _Humanoid then
		return GetHuamnoidHealth(_Humanoid) > 0
	elseif Character then
		local Humanoid = HumanoidsCache[Character]
		
		if Humanoid and Humanoid.Parent == Character then
			return GetHuamnoidHealth(Humanoid) > 0
		else
			return Character.Parent == Boats
		end
	end
	
	return false
end

local function NewErrorMessage(Message)
	-- local CoreGui = gethui and gethui() or game:GetService("CoreGui")
	
	return error(Message, 2)
end

local function ConvertVersionToNumber(Version: string): number
	local CurrentVersion;
	
	for Number in string.gmatch(string.sub(Version, 2, -1), "[^%.]+") do
		if not CurrentVersion then
			CurrentVersion = `{ Number }.`
		else
			CurrentVersion ..= Number
		end
	end
	
	return tonumber(CurrentVersion) or 0
end

local function NewConnection(Event: RBX, Action, Mode): (nil)
	table.insert(Connections, Event[Mode or "Connect"](Event, Action))
end

local function NewCollection(Tag: string): { Instance }
	local Objects = CollectionService:GetTagged(Tag)
	
	NewConnection(CollectionService:GetInstanceAddedSignal(Tag), function(Object)
		table.insert(Objects, Object)
	end)
	
	return Objects
end

local function GetRandomHitboxLimb(Character: Model): BasePart?
	return Character:FindFirstChild(HitboxLimbs[math.random(#HitboxLimbs)])
end

local function CharacterEquipTool(Tool: Tool): boolean
	Obfuscated.LockedTool(Tool)
	
	if Tool.Parent == Player.Character then
		return true
	elseif Tool.Parent == Player.Backpack then
		Player.Character.Humanoid:EquipTool(Tool)
		return true
	end
	
	return false
end

local function EquipTool(ToolName: string, ByType: boolean?): (nil)
	if not IsAlive(Player.Character) then
		return nil
	end
	
	ByType = ByType or not ToolName
	ToolName = ToolName or Settings.FarmTool
	
	local Equipped = CACHE_EQUIPPED_WEAPON
	
	if Equipped and Equipped.Parent and Equipped[if ByType then "ToolTip" else "Name"] == ToolName then
		if CharacterEquipTool(Equipped) then
			return nil
		end
	end
	
	if ToolName and not ByType then
		local OnInventory = Player.Backpack:FindFirstChild(ToolName)
		
		if OnInventory then
			CACHE_EQUIPPED_WEAPON = OnInventory
			CharacterEquipTool(OnInventory)
		end
		
		return nil
	end
	
	for _, Tool in Player.Backpack:GetChildren() do
		if Tool:IsA("Tool") and Tool.ToolTip == ToolName then
			CACHE_EQUIPPED_WEAPON = Tool
			CharacterEquipTool(Tool)
			return nil
		end
	end
end

local Cached = {
	Closest = nil,
	Equipped = nil,
	
	RealFruitsName = setmetatable({}, CreateNewClear()),
	RealFruitsId = setmetatable({}, CreateNewClear()),
	
	Enemies = {}, -- setmetatable({}, CreateNewClear()),
	Progress = {},
	Tools = {}
}

local GameData = {
	Sea = table.find({2753915549, 4442272183, 7449423635}, game.PlaceId) or 0,
	SeasName = { "Main", "Dressrosa", "Zou" },
	MaxMastery = 600,
	MaxLevel = 2800
}

if GameData.Sea == 0 then
	GameData.Sea = table.find({2753915549, 79091703265657, 7449423635}, game.PlaceId) or 0,
end

GameData.StringVersion = Obfuscated.GetGameVersion(NewErrorMessage)
GameData.NumberVersion = ConvertVersionToNumber(GameData.StringVersion)

do
	if string.sub(GameData.StringVersion, 1, 1) ~= "v" then return Player:Kick() end
	
	local SplitVersion = string.split(string.sub(GameData.StringVersion, 2, -1), ".")
	local CurrentVersion = `{ SplitVersion[1] or 0 }.`;
	
	for i = 2, #SplitVersion do
		CurrentVersion ..= tostring(SplitVersion[i] or 0)
	end
	
	GameData.NumberVersion =	tonumber(CurrentVersion) or 0
end

local Module = {
	CreateDictionary = CreateDictionary,
	NewConnection = NewConnection,
	HookManager = HookManager,
	GameData = GameData,
	IsAlive = IsAlive,
}

function Module.RejoinServer(): (nil)
	if IsPrivateServer or #Players:GetPlayers() == 1 then
		TeleportService:Teleport(game.PlaceId, Player)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end
end

function Module.ServerHop(MaxPlayers: number?, Region: string?): (nil)
	Module.RejoinBlocked = true -- bloqueia o Auto Rejoin
	
	MaxPlayers = math.min(MaxPlayers or 8, 11)
	Region = Region or "Singapore"
	
	local ServerBrowser = ReplicatedStorage.__ServerBrowser; -- o evento que gerência tudo relacionado a "servidores"
	local InvokeServer = ServerBrowser.InvokeServer; -- armazena a função de "InvokeServer" para otimizar
	local MyJobId = game.JobId; -- armazena o JobId do server atual, também para otimizar o loop
	local CurrentPage = 1; -- a "página" atual de servidores ServerBrowser:InvokeServer(1. 2. 3...)
	local task_delay = task.delay -- armazena a função de "task.delay"
	
	local function nextPage()
		local Success, Servers = pcall(InvokeServer, ServerBrowser, CurrentPage) -- retorna a lista de servidores da página atual
		CurrentPage += 1
		
		if Success ~= true then return end
		if type(Servers) ~= "table" then return end
		
		local lowServerCount, lowServerId = MaxPlayers;
		
		for id, data in Servers do
			if id ~= MyJobId and data.Count <= lowServerCount then
				lowServerCount, lowServerId = data.Count, id;
			end
		end
		
		if lowServerId then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, lowServerId, Player)
		end
	end
	
	for index = 1, 100 do
		task_delay(index / 50, nextPage)
	end
end

function Module.GetRaidIsland()
	if CURRENT_RAID_ISLAND and CURRENT_RAID_ISLAND.Parent == Locations then
		return CURRENT_RAID_ISLAND
	end
	
	for index = 5, 1, -1 do
		local IslandName = `Island {index}`
		
		for _, Island in Locations:GetChildren() do
			if Island.Name == IslandName and DistanceFromCharacter(Island.Position) < 3500 then
				CURRENT_RAID_ISLAND = Island
				return Island
			end
		end
	end
end

do
	local Shop = {}
	
	local function NewShopSection(...)
		table.insert(Shop, {...})
	end
	
	NewShopSection("Frags", {
		{"Race Reroll", {"BlackbeardReward", "Reroll", "2"}};
		{"Reset Stats", {"BlackbeardReward", "Refund", "2"}};
	});
	
	NewShopSection("Fighting Style", {
		{"Buy Black Leg", {"BuyBlackLeg"}};
		{"Buy Electro", {"BuyElectro"}};
		{"Buy Fishman Karate", {"BuyFishmanKarate"}};
		{"Buy Dragon Claw", {"BlackbeardReward", "DragonClaw", "2"}};
		{"Buy Superhuman", {"BuySuperhuman"}};
		{"Buy Death Step", {"BuyDeathStep"}};
		{"Buy Sharkman Karate", {"BuySharkmanKarate"}};
		{"Buy Electric Claw", {"BuyElectricClaw"}};
		{"Buy Dragon Talon", {"BuyDragonTalon"}};
		{"Buy GodHuman", {"BuyGodhuman"}};
		{"Buy Sanguine Art", {"BuySanguineArt"}};
	});
	
	NewShopSection("Ability Teacher", {
		{"Buy Geppo", {"BuyHaki", "Geppo"}};
		{"Buy Buso", {"BuyHaki", "Buso"}};
		{"Buy Soru", {"BuyHaki", "Soru"}};
		{"Buy Ken", {"KenTalk", "Buy"}};
	});
	
	NewShopSection("Sword", {
		{"Buy Katana", {"BuyItem", "Katana"}};
		{"Buy Cutlass", {"BuyItem", "Cutlass"}};
		{"Buy Dual Katana", {"BuyItem", "Dual Katana"}};
		{"Buy Iron Mace", {"BuyItem", "Iron Mace"}};
		{"Buy Triple Katana", {"BuyItem", "Triple Katana"}};
		{"Buy Pipe", {"BuyItem", "Pipe"}};
		{"Buy Dual-Headed Blade", {"BuyItem", "Dual-Headed Blade"}};
		{"Buy Soul Cane", {"BuyItem", "Soul Cane"}};
		{"Buy Bisento", {"BuyItem", "Bisento"}};
	});
	
	NewShopSection("Gun", {
		{"Buy Musket", {"BuyItem", "Musket"}};
		{"Buy Slingshot", {"BuyItem", "Slingshot"}};
		{"Buy Flintlock", {"BuyItem", "Flintlock"}};
		{"Buy Refined Slingshot", {"BuyItem", "Refined Slingshot"}};
		{"Buy Dual Flintlock", {"BuyItem", "Dual Flintlock"}};
		{"Buy Cannon", {"BuyItem", "Cannon"}};
		{"Buy Kabucha", {"BlackbeardReward", "Slingshot", "2"}};
	});
	
	NewShopSection("Accessories", {
		{"Buy Black Cape", {"BuyItem", "Black Cape"}};
		{"Buy Swordsman Hat", {"BuyItem", "Swordsman Hat"}};
		{"Buy Tomoe Ring", {"BuyItem", "Tomoe Ring"}};
	});
	
	NewShopSection("Race", {
		{"Ghoul Race", {"Ectoplasm", "Change", 4}};
		{"Cyborg Race", {"CyborgTrainer", "Buy"}};
	});
	
	Module.Shop = Shop;
end

function Module:IsBlacklistedExecutor(): boolean
	return IS_BLACKLISTED_EXECUTOR
end

do
	local SPAWNED_FRUITS_NAME = "Fruit "
	local WAIT_TIMEOUT = 10
	local DEFAULT_FRUIT_DISPLAY = "Fruit [ ???-??? ]"
	local DEFAULT_FRUIT_ID = "0"
	
	local FruitsId = {}
	
	local function RegisterFruit(id, realName)
		FruitsId[string.format("rbxassetid://%s", tostring(id))] = string.format("Fruit [ %s-%s ]", realName, realName)
	end
	
	do
		RegisterFruit(15124425041, "Rocket")
		RegisterFruit(15123685330, "Spin")
		RegisterFruit(15123613404, "Blade")
		RegisterFruit(15123689268, "Spring")
		RegisterFruit(15123595806, "Bomb")
		RegisterFruit(15123677932, "Smoke")
		RegisterFruit(15124220207, "Spike")
		RegisterFruit(121545956771325, "Flame")
		RegisterFruit(15123673019, "Sand")
		RegisterFruit(15123618591, "Dark")
		RegisterFruit(77885466312115, "Eagle")
		RegisterFruit(15112600534, "Diamond")
		RegisterFruit(15123640714, "Light")
		RegisterFruit(15123668008, "Rubber")
		RegisterFruit(15123662036, "Ghost")
		RegisterFruit(15123645682, "Magma")
		RegisterFruit(15123606541, "Quake")
		RegisterFruit(15123643097, "Love")
		RegisterFruit(15123681598, "Spider")
		RegisterFruit(116828771482820, "Creation")
		RegisterFruit(15123679712, "Sound")
		RegisterFruit(15123654553, "Phoenix")
		RegisterFruit(15123656798, "Portal")
		RegisterFruit(15123670514, "Rumble")
		RegisterFruit(15123652069, "Pain")
		RegisterFruit(15123587371, "Blizzard")
		RegisterFruit(15123633312, "Gravity")
		RegisterFruit(15123648309, "Mammoth")
		RegisterFruit(15694681122, "T-Rex")
		RegisterFruit(15123624401, "Dough")
		RegisterFruit(15123675904, "Shadow")
		RegisterFruit(10773719142, "Venom")
		RegisterFruit(15123616275, "Control")
		RegisterFruit(118054805452821, "Gas")
		RegisterFruit(11911905519, "Spirit")
		RegisterFruit(15123638064, "Leopard")
		RegisterFruit(115276580506154, "Yeti")
		RegisterFruit(15487764876, "Kitsune")
		RegisterFruit(95749033139458, "Dragon East")
	end
	
	local RealFruitsName = setmetatable({}, CreateNewClear())
	local RealFruitsId = setmetatable({}, CreateNewClear())
	
	local InstanceTypes = {
		Animation = "Animation",
		Fruit = "MeshPart",
		Idle = "MeshPart"
	}
	
	local function GetIdProperty(instance)
		return instance:IsA("MeshPart") and "MeshId" or "AnimationId"
	end
	
	local function SetFruitIdAndName(fruit, id, name)
		RealFruitsName[fruit] = id
		RealFruitsId[fruit] = name
	end

	local function ProcessModelChild(child)
		local expectedClass = InstanceTypes[child.Name]
		
		if expectedClass and child:IsA(expectedClass) then
			local assetId = child[GetIdProperty(child)]
			return FruitsId[assetId], assetId
		end
	end
	
	local function ProcessFruitChildren(fruit, model)
		for _, child in fruit:GetChildren() do
			local realFruitName, realFruitId = ProcessModelChild(child)
			if realFruitName then
				SetFruitIdAndName(fruit, realFruitName, realFruitId)
				return realFruitName, realFruitId
			end
		end
		
		local realFruitName = nil
		local realFruitId = nil
		local countdown = WAIT_TIMEOUT
		
		local connection = model.ChildAdded:Connect(function(child)
			if not realFruitName then
				realFruitName, realFruitId = ProcessModelChild(child)
			end
		end)
		
		while not realFruitName and countdown > 0 do
			countdown -= task.wait()
		end
		
		connection:Disconnect()
		
		if realFruitName then
			SetFruitIdAndName(fruit, realFruitName, realFruitId)
			return realFruitName
		end
	end
	
	function Module.GetRealFruitName(fruit, returnsId)
		if fruit.Name ~= SPAWNED_FRUITS_NAME then
			return fruit.Name
		end
		
		if RealFruitsName[fruit] then
			return returnsId and RealFruitsId[fruit] or RealFruitsName[fruit]
		end
		
		RealFruitsName[fruit] = DEFAULT_FRUIT_DISPLAY
		RealFruitsId[fruit] = DEFAULT_FRUIT_ID
		
		local model = fruit:WaitForChild("Fruit", math.huge)
		ProcessFruitChildren(fruit, model)
		
		return (returnsId and RealFruitsId[fruit] or RealFruitsName[fruit]) or DEFAULT_FRUIT_ID
	end
end

Module.CollectionService = (function()
	local CollectionObjects = {}
	
	local Chests = NewCollection("_ChestTagged")
	local Berries = NewCollection("BerryBush")
	
	local GetChestDebounce, CachedChest = 0;
	local GetBerryDebounce, CachedBerry = 0;
	
	CollectionObjects.Chests = Chests
	CollectionObjects.Berries = Berries
	
	local function CanCollectChest(Chest)
		return Chest and not Chest:GetAttribute("IsDisabled")
	end
	
	local function HasBerries(Bush)
		return Bush and next(Bush:GetAttributes()) ~= nil
	end
	
	local function GetClosestChest(SelectedIsland)
		if CanCollectChest(CachedChest) and (not SelectedIsland or CachedChest:IsDescendantOf(SelectedIsland)) then
			return CachedChest
		elseif (tick() - GetChestDebounce) < 1 then
			return nil
		end
		
		local Distance, Closest = math.huge
		
		for index = 1, #Chests do
			local Chest = Chests[index]
			if CanCollectChest(Chest) and (not SelectedIsland or CachedChest:IsDescendantOf(SelectedIsland)) then
				local Magnitude = Player:DistanceFromCharacter(Chest:GetPivot().Position)
				
				if Magnitude < Distance then
					Distance, Closest = Magnitude, Chest
				end
			end
		end
		
		GetChestDebounce = tick()
		CachedChest = Closest
		
		return Closest
	end
	
	local function GetClosestBerry()
		if HasBerries(CachedBerry) and CachedBerry:IsDescendantOf(Map) then
			return CachedBerry
		elseif (tick() - GetBerryDebounce) < 1 then
			return nil
		end
		
		local Distance, Closest = math.huge
		
		for index = 1, #Berries do
			local Bush = Berries[index]
			
			if HasBerries(Bush) and Bush.Parent then
				local Magnitude = DistanceFromCharacter(Bush.Parent:GetPivot().Position)
				
				if Magnitude < Distance then
					Distance, Closest = Magnitude, Bush
				end
			end
		end
		
		GetBerryDebounce = tick()
		CachedBerry = Closest
		
		return Closest
	end
	
	Module.GetClosestChest = GetClosestChest;
	Module.GetClosestBerry = GetClosestBerry;
	Module.HasBerries = HasBerries;
	
	return CollectionObjects
end)()

Module.Services = (function()
	local Services = {}
	
	Services.Network = (function()
		local Network = {}
		
		local InvokeServer = CommF.InvokeServer;
		
		local RF_TAG = "RF/%s";
		local RE_TAG = "RE/%s";
		
		local Progress = {};
		
		local function GetNetworkRemote(Tag, Class, RemoteName)
			local Remote = Net:WaitForChild(Tag:format(RemoteName))
			
			if not Remote then
				return error(`Cannot found {RemoteName}: { Class } in Network`, 2)
			end
			
			return Remote
		end
		
		function Network.InvokeCommF(...)
			return InvokeServer(CommF, ...)
		end
		
		function Network.TravelTo(Sea: number?): (nil)
			return Network.InvokeCommF(`Travel{ GameData.SeasName[Sea] }`)
		end
		
		function Network.GetProgress(...)
			local Tag = ...
			
			if Progress[Tag] and Progress[Tag].Debounce < 0 then
				return unpack(Progress[Tag].Args)
			end
			
			Progress[Tag] = {
				Debounce = tick() + 2.5,
				Args = table.pack(Network.InvokeCommF(...))
			}
			
			return unpack(Progress[Tag].Args)
		end
		
		function Network:RemoteFunction(RemoteName)
			return GetNetworkRemote(RF_TAG, "RemoteFunction", RemoteName)
		end
		
		function Network:RemoteEvent(RemoteName)
			return GetNetworkRemote(RE_TAG, "RemoteEvent", RemoteName)
		end
		
		return Network
	end)()
	
	Services.GoodSignal = (function()
		local Signal = {}
		local Connection = {}
		
		Connection.__index = Connection
		Signal.__index = Signal
		
		do
			function Connection:Disconnect(): (nil)
				if not self.Connected then
					return nil
				end
				
				local find = table.find(self.Signal, self)
				
				if find then
					table.remove(self.Signal, find)
				end
				
				self.Function = nil
				self.Connected = false
			end
			
			function Connection:Fire(...): (nil)
				if not self.Function then
					return nil
				end
				
				task.spawn(self.Function, ...)
			end
			
			function Connection.new(): Connection
				return setmetatable({
					Connected = true
				}, Connection)
			end
			
			setmetatable(Connection, {
				__index = function(self, index)
					error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(index)), 2)
				end,
				__newindex = function(tb, key, value)
					error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
				end
			})
		end
		
		function Signal:Connect(Function): Connection
			assert(type(Function) == "function", "function expected, got " .. type(Function))
			
			local NewConnection = Connection.new()
			NewConnection.Function = Function
			NewConnection.Signal = self
			
			table.insert(self.Connections, NewConnection)
			return NewConnection
		end
		
		function Signal:Once(Function): (nil)
			local Connection;
			Connection = self:Connect(function(...)
				Function(...)
				Connection:Disconnect()
			end)
			return Connection
		end
		
		function Signal:Wait(): any?
			local WaitingCoroutine = coroutine.running()
			local Connection;Connection = self:Connect(function(...)
				Connection:Disconnect()
				task.spawn(WaitingCoroutine, ...)
			end)
			return coroutine.yield()
		end
		
		function Signal:Fire(...): (nil)
			for _, Connection in ipairs(self.Connections) do
				if Connection.Connected then
					Connection:Fire(...)
				end
			end
		end
		
		function Signal.new(): Signal
			return setmetatable({
				Connections = {}
			}, Signal)
		end
		
		Signal.Signals = {
			BvChanged = Signal.new(),
			Notify = Signal.new(),
			Error = Signal.new(),
		}
		
		setmetatable(Signal, {
			__index = function(self, index)
				error(`Attempt to get Signal::{ tostring(index) } (not a valid member)`, 2)
			end,
			__newindex = function(self, index, value)
				error(`Attempt to set Signal::{ tostring(index) } (not a valid member)`, 2)
			end
		})
		
		return Signal
	end)()
	
	Services.PlayerManager = (function()
		local Manager = {}
		
		local RootPartPosition = Vector3.zero
		
		local function GetRootPart()
			local Character = Player.Character
			return IsAlive(Character) and Character.Humanoid.RootPart
		end
		
		function Manager:GetRootPartPosition()
			local RootPart = GetRootPart()
			
			if RootPart then
				RootPartPosition = RootPart.Position
			end
			
			return RootPartPosition
		end
		
		NewConnection(Player.CharacterAdded, function(...) PlayerCharacter = ... end)
		NewConnection(Player.CharacterRemoving, function() PlayerCharacter = nil end)
		
		return Manager
	end)()
	
	Services.Hooking = (function()
		local Hooking = {}
		
		local WhitelistSkills = CreateDictionary({ "Z", "X", "C", "V", "F" }, true)
		
		local Enabled = _ENV.rz_EnabledOptions;
		local ClosestEnemie = nil;
		
		local DisableUpdateClosest = 0;
		local UpdateClosestsDebounce = 0;
		
		local function get_aim_target(Tag: string): any?
			if (tick() - DisableUpdateClosest) <= 2 or _ENV[Tag] then
				return ClosestEnemie
			end
		end
		
		local function UpdateClosests()
			local time = tick()
			
			if (time - DisableUpdateClosest) <= 2 or (time - UpdateClosestsDebounce) <= 0 then
				return nil
			else
				UpdateClosestsDebounce = time + (if Settings.SmoothMode then 0.5 else 0.25)
			end
			
			local MyCharacter = Player.Character
			local Equipped = IsAlive(MyCharacter) and MyCharacter:FindFirstChildOfClass("Tool")
			
			if Equipped and Equipped.ToolTip and MyCharacter.Humanoid.RootPart then
				local ClosestDistance = if Equipped.ToolTip == "Gun" then 250 else 900
				
				local MyPosition = MyCharacter.Humanoid.RootPart.Position
				local _Characters = Characters:GetChildren()
				local _Enemies = Enemies:GetChildren()
				
				ClosestEnemie = nil
				
				for index = 1, #_Characters do
					local Character = _Characters[index]
					if Character == MyCharacter or not CheckPlayerAlly(Character) then continue end
					local RootPart = IsAlive(Character) and Character.Humanoid.RootPart
					
					if RootPart then
						local Magnitude = (RootPart.Position - MyPosition).Magnitude
						
						if Magnitude <= ClosestDistance then
							ClosestEnemie, ClosestDistance = RootPart, Magnitude
						end
					end
				end
				
				for index = 1, (if Settings.NoAimMobs then 0 else #_Enemies) do
					local Mob = _Enemies[index]
					local RootPart = IsAlive(Mob) and Mob.Humanoid.RootPart
					
					if RootPart then
						local Magnitude = (RootPart.Position - MyPosition).Magnitude
						
						if Magnitude <= ClosestDistance then
							ClosestEnemie, ClosestDistance = RootPart, Magnitude
						end
					end
				end
			end
		end
		
		local function hook_newindex()
			if _ENV.rz_enabled_bypass or not HIDDEN_SETTINGS.WALKSPEED_BYPASS_ENABLED then return end
			_ENV.rz_enabled_bypass = true
			
			local HookProperty = HookManager.HookProperty
			
			local old_newindex;
			old_newindex = hookmetamethod(Player, "__newindex", function(self, index, value)
				if index == "WalkSpeed" and self.Name == "Humanoid" then
					HookProperty(self, index, value)
					return old_newindex(self, "WalkSpeed", _ENV.WalkSpeedBypass or value)
				else
					return old_newindex(self, index, value)
				end
			end)
		end
		
		local function hook_namecall()
			if not HIDDEN_SETTINGS.SILENT_AIM_ENABLED then return end
			if _ENV.rz_original_namecall then return end
			
			Stepped:Connect(UpdateClosests)
			
			local Events = {
				["RE/ShootGunEvent"] = function(...)
					local Position, Enemies = ...
					
					if typeof(Position) == "Vector3" and type(Enemies) == "table" and #Enemies ~= 0 then
						local Target = get_aim_target("AimBot_Gun")
						
						if Target then
							return Target.Position, { Target }
						end
					end
					
					return ...
				end,
				["RemoteEvent"] = function(...)
					local param1, param2 = ...
					
					if typeof(param1) == "Vector3" and not param2 then
						local Target = get_aim_target("AimBot_Skills")
						
						if Target then
							return Target.Position
						end
					elseif param1 == "TAP" and typeof(param2) == "Vector3" then
						local Target = get_aim_target("AimBot_Tap")
						
						if Target then
							return "TAP", Target.Position
						end
					end
					
					return ...
				end
			}
			
			local OriginalIndex = HookManager.OriginalIndex
			local string_lower = string.lower
			
			local old_namecall;
			old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
				local Event = Events[OriginalIndex(self, "Name")]
				
				if Event and string_lower(getnamecallmethod()) == "fireserver" then
					return old_namecall(self, Event(...))
				else
					return old_namecall(self, ...)
				end
			end)
			
			_ENV.rz_original_namecall = old_namecall
		end
		
		Module.HookGame = function()
			task.delay(1, hook_newindex)
			task.delay(1, hook_namecall)
		end
		
		function Hooking:SetAimTarget(RootPart: BasePart): (nil)
			ClosestEnemie, DisableUpdateClosest = RootPart, tick()
		end
		
		return Hooking
	end)()
	
	Services.Inventory = (function()
		local Inventory = {
			Unlocked = CreateDefaultDictionary(false),
			Mastery = CreateDefaultDictionary(0),
			Count = CreateDefaultDictionary(0),
			MasteryRequirements = {},
			
			Loaded = false,
			Items = {}
		}
		
		local NotificationSignal = Services.GoodSignal.Signals.Notify
		
		local function ItemUpdated(self, NewItemData)
			if type(NewItemData) ~= "table" then return end
			
			local ItemName = NewItemData.Name
			self.Items[ItemName] = NewItemData
			
			if not self.Unlocked[ItemName] then self.Unlocked[ItemName] = true end
			if NewItemData.Count then self.Count[ItemName] = NewItemData.Count end
			if NewItemData.Mastery then self.Mastery[ItemName] = NewItemData.Mastery end
			if NewItemData.MasteryRequirements then self.MasteryRequirements[ItemName] = NewItemData.MasteryRequirements end
		end
		
		local function ItemRemoved(self, ItemName)
			if type(ItemName) == "string" then
				self.MasteryRequirements[ItemName] = nil
				self.Unlocked[ItemName] = nil
				self.Mastery[ItemName] = nil
				self.Count[ItemName] = nil
				self.Items[ItemName] = nil
			end
		end
		
		local Methods = {
			["ItemChanged"] = function(...) ItemUpdated(Inventory, ...) end;
			["ItemAdded"] = function(...) ItemUpdated(Inventory, ...) end;
			["ItemRemoved"] = function(...) ItemRemoved(Inventory, ...) end;
			["Notify"] = function(...) NotificationSignal:Fire(...) end;
		}
		
		local function OnClientEvent(Method, ...)
			if Method and Methods[Method] then
				Methods[Method](...)
			end
		end
		
		local function GetInventory()
			return Services.Network.InvokeCommF("getInventory")
		end
		
		task.defer(function()
			NewConnection(CommE.OnClientEvent, OnClientEvent)
			local InventoryItems = GetInventory();
			
			while type(InventoryItems) ~= "table" and task.wait(1) do
				InventoryItems = GetInventory()
			end
			
			for index = 1, #InventoryItems do
				ItemUpdated(Inventory, InventoryItems[index])
			end
			
			Inventory.Loaded = true
		end)
		
		return Inventory
	end)()
	
	Services.Enemies = (function()
		local EnemiesModule = CreateDictionary({
			"__CakePrince", "__PirateRaid", "__TyrantSkies", "__Bones", "__Elite", "__Others", "__Ectoplasm"
		}, {})
		
		local TagsMobs = {
			["Deandre"] = "Elite", ["Diablo"] = "Elite", ["Urban"] = "Elite",
			
			["Reborn Skeleton"] = "Bones", ["Living Zombie"] = "Bones",
			["Demonic Soul"] = "Bones", ["Posessed Mummy"] = "Bones",
			
			["Head Baker"] = "CakePrince", ["Baking Staff"] = "CakePrince",
			["Cake Guard"] = "CakePrince", ["Cookie Crafter"] = "CakePrince",
			
			["Sun-kissed Warrior"] = "TyrantSkies", ["Skull Slayer"] = "TyrantSkies",
			["Isle Champion"] = "TyrantSkies", ["Serpent Hunter"] = "TyrantSkies",
			
			["Ship Deckhand"] = "Ectoplasm", ["Ship Engineer"] = "Ectoplasm",
			["Ship Officer"] = "Ectoplasm", ["Ship Steward"] = "Ectoplasm",
		}
		
		local SpawnLocations = Module.SpawnLocations
		local CachedEnemies = Cached.Enemies
		
		local UnprotectObject = HookManager.UnprotectObject
		local ProtectObject = HookManager.ProtectObject
		local OriginalIndex = HookManager.OriginalIndex
		
		local BringAttachment = Obfuscated.GetBringAttachment()
		
		local BringMobsCFrames = {}
		local BringMobsLookup = {}
		
		local SpawnLocations = {}
		local EnemyLocations = {}
		
		EnemiesModule.SpawnLocations = SpawnLocations
		EnemiesModule.EnemyLocations = EnemyLocations
		
		EnemiesModule.PirateRaid = 0
		
		do
			local BLACKLISTED_BOSSES = CreateDictionary({"Ice Admiral", "rip_indra"}, true)
			local Bosses = {}
			
			local function NewBoss(bossName, spawn, quest, level)
				Bosses[bossName] = {
					BossSpawn = CFrame.new(unpack(spawn)),
					LevelReq = level,
					Quest = quest
				}
			end
			
			function EnemiesModule.IsABoss(enemyName)
				return Bosses[enemyName] ~= nil
			end
			
			function EnemiesModule.EnemyIsBoss(Enemy)
				return (Enemy:GetAttribute("IsBoss") or Enemy:GetAttribute("RaidBoss")) and not BLACKLISTED_BOSSES[Enemy.Name]
			end
			
			function EnemiesModule:GetBosses()
				return Bosses
			end
			
			-- Quest Bosses
			NewBoss("The Gorilla King", {-1128, 6, -451}, {"JungleQuest", CFrame.new(-1598, 37, 153)}, 20)
			NewBoss("Chef", {-1131, 14, 4080}, {"BuggyQuest1", CFrame.new(-1140, 4, 3829)}, 55)
			NewBoss("Yeti", {1185, 106, -1518}, {"SnowQuest", CFrame.new(1385, 87, -1298)}, 105)
			NewBoss("Vice Admiral", {-4807, 21, 4360}, {"MarineQuest2", CFrame.new(-5035, 29, 4326), 2}, 130)
			NewBoss("Warden", {5230, 4, 749}, {"ImpelQuest", CFrame.new(5191, 4, 692), 1}, 220)
			NewBoss("Chief Warden", {5230, 4, 749}, {"ImpelQuest", CFrame.new(5191, 4, 692), 2}, 230)
			NewBoss("Swan", {5230, 4, 749}, {"ImpelQuest", CFrame.new(5191, 4, 692)}, 240)
			NewBoss("Magma Admiral", {-5694, 18, 8735}, {"MagmaQuest", CFrame.new(-5319, 12, 8515)}, 350)
			NewBoss("Fishman Lord", {61350, 31, 1095}, {"FishmanQuest", CFrame.new(61122, 18, 1567)}, 425)
			NewBoss("Wysper", {-7927, 5551, -637}, {"SkyExp1Quest", CFrame.new(-7861, 5545, -381)}, 500)
			NewBoss("Thunder God", {-7751, 5607, -2315}, {"SkyExp2Quest", CFrame.new(-7903, 5636, -1412)}, 575)
			NewBoss("Cyborg", {6138, 10, 3939}, {"FountainQuest", CFrame.new(5258, 39, 4052)}, 675)
			
			-- Quest Bosses
			NewBoss("Diamond", {-1569, 199, -31}, {"Area1Quest", CFrame.new(-427, 73, 1835)}, 750)
			NewBoss("Jeremy", {2316, 449, 787}, {"Area2Quest", CFrame.new(635, 73, 919)}, 850)
			NewBoss("Orbitus", {-2086, 73, -4208}, {"MarineQuest3", CFrame.new(-2441, 73, -3219)}, 925)
			NewBoss("Smoke Admiral", {-5078, 24, -5352}, {"IceSideQuest", CFrame.new(-6061, 16, -4904)}, 1150)
			NewBoss("Awakened Ice Admiral", {6473, 297, -6944}, {"FrostQuest", CFrame.new(5668, 28, -6484)}, 1400)
			NewBoss("Tide Keeper", {-3711, 77, -11469}, {"ForgottenQuest", CFrame.new(-3056, 240, -10145)}, 1475)
			
			-- Quest Bosses
			NewBoss("Stone", {-1049, 40, 6791}, {"PiratePortQuest", CFrame.new(-449, 109, 5950)}, 1550)
			NewBoss("Hydra Leader", {5836, 1019, -83}, {"VenomCrewQuest", CFrame.new(5214, 1004, 761)}, 1675)
			NewBoss("Kilo Admiral", {2904, 509, -7349}, {"MarineTreeIsland", CFrame.new(2485, 74, -6788)}, 1750)
			NewBoss("Captain Elephant", {-13393, 319, -8423}, {"DeepForestIsland", CFrame.new(-13233, 332, -7626)}, 1875)
			NewBoss("Beautiful Pirate", {5370, 22, -89}, {"DeepForestIsland2", CFrame.new(-12682, 391, -9901)}, 1950)
			NewBoss("Cake Queen", {-710, 382, -11150}, {"IceCreamIslandQuest", CFrame.new(-818, 66, -10964)}, 2175)
			
			table.freeze(Bosses)
		end
		
		do
			local IslandsStartWord = "Island "
			
			local function NewIslandAdded(Island)
				if string.sub(Island.Name, 1, #IslandsStartWord) == IslandsStartWord then
					CURRENT_RAID_ISLAND = nil
				end
			end
			
			local function NewSpawn(Part)
				local EnemyName = GetEnemyName(Part.Name)
				EnemyLocations[EnemyName] = EnemyLocations[EnemyName] or {}
				
				local EnemySpawn = Part.CFrame + Vector3.one * 25
				SpawnLocations[EnemyName] = Part
				
				if not table.find(EnemyLocations[EnemyName], EnemySpawn) then
					table.insert(EnemyLocations[EnemyName], EnemySpawn)
				end
			end
			
			for _, Spawn in EnemySpawns:GetChildren() do NewSpawn(Spawn) end
			NewConnection(EnemySpawns.ChildAdded, NewSpawn)
			NewConnection(Locations.ChildAdded, NewIslandAdded)
		end
		
		local function CanBringMob(Enemy)
			return not BringMobsLookup[Enemy]
		end
		
		local function StartBringMob(AlignPosition, Enemy, EnemyName, Humanoid, RootPart)
			while Enemy.Parent == Enemies and IsAlive(_, Humanoid) and RootPart.Parent == Enemy do
				local TargetPosition = BringMobsCFrames[EnemyName].Position
				
				if (TargetPosition - RootPart.Position).Magnitude <= Settings.BringDistance then
					if AlignPosition.Position ~= TargetPosition then
						AlignPosition.Position = TargetPosition
					end
				else
					break
				end
				
				task.wait(0.25)
			end
		end
		
		local function BringMob(Enemy)
			if BringMobsLookup[Enemy] then return end
			BringMobsLookup[Enemy] = true
			
			local EnemyName = Enemy.Name
			local Humanoid = Enemy.Humanoid
			local RootPart = Humanoid.RootPart
			
			local CloneAttachment = BringAttachment:Clone()
			local AlignPosition = CloneAttachment.AlignPosition
			
			CloneAttachment.Parent = RootPart
			StartBringMob(AlignPosition, Enemy, EnemyName, Humanoid, RootPart)
			
			BringMobsLookup[Enemy] = nil
			
			if CloneAttachment then
				CloneAttachment:Destroy()
			end
		end
		
		function EnemiesModule.GetEnemy(EnemyName: string): Model?
			if type(EnemyName) == "table" then
				return EnemiesModule:GetClosest(EnemyName)
			else
				return EnemiesModule:GetEnemyByTag(EnemyName)
			end
		end
		
		function EnemiesModule.IsSpawned(EnemyName: string): boolean
			local Cache = SpawnLocations[EnemyName]
			
			if Cache and Cache.Parent == EnemySpawns then
				return Cache:GetAttribute("Active")
			else
				return EnemiesModule:GetEnemyByTag(EnemyName) ~= nil
			end
		end
		
		function EnemiesModule:GetMobsName(Tag: string): { string }
			local Mobs = {}
			for EnemyName: string, EnemyTag: string in TagsMobs do
				if EnemyTag == Tag then
					table.insert(Mobs, EnemyName)
				end
			end
			return Mobs
		end
		
		function EnemiesModule.BringMobs(ToEnemy: Instance, ToCFrame: CFrame?, Distance: number?): (nil)
			local RootPart = IsAlive(ToEnemy) and ToEnemy.Humanoid.RootPart
			if not RootPart then return end
			
			local ToEnemyName = ToEnemy.Name
			SetSimulationRadius(9e9)
			
			if not Settings.BringMobs then
				if not BringMobsCFrames[ToEnemyName] then
					BringMobsCFrames[ToEnemyName] = RootPart.CFrame
				end
				
				RootPart.CFrame = BringMobsCFrames[ToEnemyName]
				return nil
			end
			
			local MyRootPosition = Services.PlayerManager:GetRootPartPosition()
			
			local Target = ToCFrame or RootPart.CFrame
			local MaxDistance = Distance or Settings.BringDistance
			
			if not BringMobsCFrames[ToEnemyName] or (Target.Position - BringMobsCFrames[ToEnemyName].Position).Magnitude > 25 then
				BringMobsCFrames[ToEnemyName] = Target
			end
			
			for _, Enemy in EnemiesModule:GetTagged(ToEnemyName) do
				if not Enemy:FindFirstChild("CharacterReady") then continue end
				if Enemy.Parent ~= Enemies or Enemy.Name ~= ToEnemyName then continue end
				
				local EnemyRootPart = IsAlive(Enemy) and Enemy.Humanoid.RootPart
				if not EnemyRootPart then continue end
				
				if (MyRootPosition - EnemyRootPart.Position).Magnitude < MaxDistance then
					task.spawn(BringMob, Enemy)
				end
			end
		end
		
		function EnemiesModule:GetTagged(TagName: string): { Model }
			return self[`__{ TagName }`] or self.__Others[TagName]
		end
		
		function EnemiesModule:GetEnemyByTag(TagName: string): Model?
			local CachedEnemy = CachedEnemies[TagName]
			
			if CachedEnemy and CachedEnemy.Parent ~= nil and IsAlive(CachedEnemy) then
				return CachedEnemy
			end
			
			local Enemies = self:GetTagged(TagName)
			if not Enemies then return end
			
			for index = 1, #Enemies do
				if IsAlive(Enemies[index]) then
					return Enemies[index]
				end
			end
		end
		
		function EnemiesModule:GetClosest(Enemies: { string }): Model?
			local SpecialTag = table.concat(Enemies, "_")
			local CachedEnemy = CachedEnemies[SpecialTag]
			
			if CachedEnemy and CachedEnemy.Parent ~= nil and IsAlive(CachedEnemy) then
				return CachedEnemy
			end
			
			local Distance, Nearest = math.huge
			
			for index = 1, #Enemies do
				local Enemy = self:GetClosestByTag(Enemies[index])
				local EnemyRootPart = IsAlive(Enemy) and Enemy.Humanoid.RootPart
				local Magnitude = EnemyRootPart and Player:DistanceFromCharacter(EnemyRootPart.Position)
				
				if EnemyRootPart and Magnitude <= Distance then
					Distance, Nearest = Magnitude, Enemy
				end
			end
			
			if Nearest then
				CachedEnemies[SpecialTag] = Nearest
				return Nearest
			end
		end
		
		function EnemiesModule:GetClosestByTag(TagName: string): Model?
			local CachedEnemy = CachedEnemies[TagName]
			
			if CachedEnemy and CachedEnemy.Parent ~= nil and IsAlive(CachedEnemy) then
				return CachedEnemy
			end
			
			local Enemies = self:GetTagged(TagName)
			
			if Enemies and #Enemies > 0 then
				local RootPosition = Services.PlayerManager:GetRootPartPosition()
				local Distance, Nearest = math.huge
				
				for index = 1, #Enemies do
					local Enemy = Enemies[index]
					local EnemyRootPart = IsAlive(Enemy) and Enemy.Humanoid.RootPart
					if not EnemyRootPart then continue end
					
					local Magnitude = (RootPosition - EnemyRootPart.Position).Magnitude
					
					if Magnitude <= 50 then
						CachedEnemies[TagName] = Enemy
						return Enemy
					elseif Magnitude <= Distance then
						Distance, Nearest = Magnitude, Enemy
					end
				end
				
				if Nearest then
					CachedEnemies[TagName] = Nearest
					return Nearest
				end
			end
		end
		
		do
			local SeaCastlePosition = Vector3.new(-5556, 314, -2988)
			local OthersEnemies = EnemiesModule.__Others
			local CurrentSea = GameData.Sea
			
			local function NewEnemy(self, Enemy)
				if table.find(self, Enemy) then return end
				
				local Humanoid = Enemy:WaitForChild("Humanoid")
				
				if Humanoid and Humanoid.Health > 0 then
					table.insert(self, Enemy)
					Humanoid.Died:Once(function()
						table.remove(self, table.find(self, Enemy))
					end)
				end
			end
			
			local function IsFromSeaCastle(Enemy)
				if Enemy.Name == "rip_indra True Form" or Enemy.Name == "Blank Buddy" then return end
				
				local Humanoid = Enemy:WaitForChild("Humanoid", 60 * 10)
				if not Humanoid or Humanoid.Health <= 0 then return end
				
				local RootPart = Enemy:WaitForChild("HumanoidRootPart")
				
				if RootPart and (RootPart.Position - SeaCastlePosition).Magnitude <= 750 then
					task.spawn(NewEnemy, EnemiesModule.__PirateRaid, Enemy)
					EnemiesModule.PirateRaid = tick()
				end
			end
			
			local function NewEnemyAdded(Enemy)
				local EnemyName = Enemy.Name
				local TagName = `__{ EnemyName }`
				
				OthersEnemies[EnemyName] = OthersEnemies[EnemyName] or {}
				task.spawn(NewEnemy, OthersEnemies[EnemyName], Enemy)
				
				if CurrentSea == 3 then
					task.spawn(IsFromSeaCastle, Enemy)
				end
				
				if EnemiesModule[TagName] then
					task.spawn(NewEnemy, EnemiesModule[TagName], Enemy)
				elseif TagsMobs[EnemyName] then
					task.spawn(NewEnemy, EnemiesModule[`__{ TagsMobs[EnemyName] }`], Enemy)
				end
			end
			
			for _, Enemy in CollectionService:GetTagged("BasicMob") do NewEnemyAdded(Enemy) end
			NewConnection(CollectionService:GetInstanceAddedSignal("BasicMob"), NewEnemyAdded)
		end
		
		return EnemiesModule
	end)()
	
	Services.ToolService = (function()
		local ToolService = {}
		
		local InvokeCommF = Services.Network.InvokeCommF
		local ToolsCache = Cached.Tools
		local BUSO_PRICE = 25000
		
		local function FindFirstType(Tip: string): Tool?
			local Equipped = Player.Character:FindFirstChildOfClass("Tool")
			
			if Equipped and Equipped.ToolTip == Tip then
				return Equipped
			end
			
			for _, Tool in Player.Backpack:GetChildren() do
				if Tool:IsA("Tool") and Tool.ToolTip == Tip then
					return Tool
				end
			end
		end
		
		local function BuyBuso()
			if Money.Value < BUSO_PRICE then return end
			
			InvokeCommF("BuyHaki", "Buso")
		end
		
		local function IsJobTool(Tool, JobId)
			return Tool.ToolTip == "JobTool" and Tool:GetAttribute("JobId") == JobId
		end
		
		local function GetTool(Name: string, ByType: boolean?): Tool?
			local Character = Player.Character
			if not IsAlive(Character) then return end
			
			local CacheTag = if ByType then `toolTip_{Name}` else Name
			local Cache = ToolsCache[CacheTag]
			
			if Cache and (Cache.Parent == Character or Cache.Parent == Player.Backpack) then
				return Cache
			end
			
			local HasTool = if ByType then FindFirstType(Name) else (Character:FindFirstChild(Name) or Player.Backpack:FindFirstChild(Name))
			
			if HasTool then
				ToolsCache[CacheTag] = HasTool
				return HasTool
			end
		end
		
		function ToolService.GetToolMastery(Name: string, ...): number
			local HasTool = GetTool(Name, ...)
			return HasTool and HasTool:GetAttribute("Level") or 0
		end
		
		function ToolService.EquipJobTool(JobId)
			local Character = Player.Character
			if not IsAlive(Character) then return end
			
			local Equipped = Character:FindFirstChildOfClass("Tool")
			
			if Equipped and IsJobTool(Equipped, JobId) then
				return Equipped
			end
			
			for _, Tool in Player.Backpack:GetChildren() do
				if Tool:IsA("Tool") and IsJobTool(Tool, JobId) then
					CharacterEquipTool(Tool)
					return Tool
				end
			end
		end
		
		function ToolService.VerifyTool(Name: string, ...): boolean
			return GetTool(Name, ...) ~= nil
		end
		
		function ToolService.EnableBuso()
			local Character = Player.Character
			if IsAlive(Character) and not Character:FindFirstChild("HasBuso") then
				return if Character:HasTag("Buso") then InvokeCommF("Buso") else BuyBuso()
			end
		end
		
		ToolService.EquipTool = EquipTool
		
		return ToolService
	end)()
	
	Services.FastAttack = (function()
		local FastAttack = {
			attackPlayers = true,
			attackMobs = true,
		}
		
		local ATTACK_RANGE = {
			["Blox Fruit"] = 35,
			["Melee"] = 40,
			["Sword"] = 40,
			["Gun"] = 200,
		}
		
		local SHOOTS_PER_TARGET = {
			["Dual Flintlock"] = 2
		}
		
		local RANGES_BY_NAME = {
			["Dragonstorm"] = 300
		}
		
		local SHOOTS_TYPES = {
			["Skull Guitar"] = "TAP",
			["Bazooka"] = "Position",
			["Cannon"] = "Position",
			["Dragonstorm"] = "Overheat"
		}
		
		local NORMAL_HITS_FRUITS = CreateDictionary({"Light-Light", "Ice-Ice"}, true)
		
		local Network = Services.Network
		
		local SendLeftClickRemote = Obfuscated.SendLeftClickRemote
		local CheckAttackDebounce = Obfuscated.CheckAttackDebounce
		local GetPartBoundsInBox = Obfuscated.GetPartBoundsInBox
		local PlayHitAnimation = Obfuscated.PlayHitAnimation
		local SetHitsCooldown = Obfuscated.SetHitsCooldown
		local IsAttackWeapon = Obfuscated.IsAttackWeapon
		local NewDebounce = Obfuscated.NewDebounce
		local GetMaxHits = Obfuscated.GetMaxHits
		local CheckStun = Obfuscated.CheckStun
		
		local CanSendHitsToServer = Obfuscated.CanSendHitsToServer
		local SendHitsToServer = Obfuscated.SendHitsToServer
		
		local UpdateShootAndValidator = Obfuscated.UpdateShootAndValidator
		local CanGetGunValidator = Obfuscated.CanGetGunValidator
		
		local RE_ShootGunEvent = Network:RemoteEvent("ShootGunEvent")
		
		local LAST_BLOXFRUIT_ATTACK = 0
		local MIN_COMBO_COOLDOWN = 0.4
		local MAX_BLOXFRUIT_COMBO = 4
		local BLOX_FRUIT_COMBO = 0
		
		local BELOW_ATTACK_ENABLED_DEBOUNCE = 0
		local BELOW_ATTACK_PERCENT = 0
		local ATTACK_DEBOUNCE = 0
		local SHOOT_DEBOUNCE = 0
		
		Obfuscated.SetRigisterAttackEvent(Network:RemoteEvent("RegisterAttack"))
		Obfuscated.SetRigisterHitEvent(Network:RemoteEvent("RegisterHit"))
		
		local function attackIsEnabled(Folder)
			return if Folder == Characters then FastAttack.attackPlayers else FastAttack.attackMobs
		end
		
		local function DamageParts(Equipped, Cooldown, Parts)
			local MaxHits = GetMaxHits()
			local BladeHits = {}
			local AddedHits = {}
			
			for _, Part in Parts do
				local Enemy = Part.Parent
				local Folder = Enemy.Parent
				
				if Folder.Parent ~= workspace or not IsAlive(Enemy) then continue end
				if Folder == Characters and (Enemy == Player.Character or not CheckPlayerAlly(Enemy)) then continue end
				if not attackIsEnabled(Folder) then continue end
				
				if (tick() - BELOW_ATTACK_ENABLED_DEBOUNCE) <= 0 then
					if (Enemy.Humanoid.Health / Enemy.Humanoid.MaxHealth) <= BELOW_ATTACK_PERCENT then
						continue
					end
				end
				
				if not AddedHits[Enemy] then
					table.insert(BladeHits, {Enemy, Part})
					AddedHits[Enemy] = true
				end
				
				if #BladeHits >= MaxHits then
					break
				end
			end
			
			if #BladeHits > 0 then
				PlayHitAnimation(Equipped)
				SetHitsCooldown(Cooldown)
				SendHitsToServer(BladeHits)
			end
		end
		
		local function GetBloxFruitCombo()
			if BLOX_FRUIT_COMBO >= MAX_BLOXFRUIT_COMBO or (tick() - LAST_BLOXFRUIT_ATTACK) >= MIN_COMBO_COOLDOWN then
				BLOX_FRUIT_COMBO = 0
			end
			
			LAST_BLOXFRUIT_ATTACK = tick()
			BLOX_FRUIT_COMBO += 1
			return BLOX_FRUIT_COMBO
		end
		
		local function IsEnemyAttackableFromPart(targetPart: BasePart): boolean
			local targetCharacter = targetPart.Parent
			local targetContainer = targetCharacter.Parent.Parent
			
			if targetContainer ~= workspace then
				targetContainer = targetContainer.Parent
				targetCharacter = targetCharacter.Parent
			end
			
			if targetContainer == workspace and IsAlive(targetCharacter) and attackIsEnabled(targetCharacter.Parent) then
				return true
			end
			
			return false
		end
		
		local function GetCharacterFromPart(part): Model
			while part.Parent.Parent ~= workspace do
				part = part.Parent
			end
			return part
		end
		
		local function UseGunShoot(hitParts: { BasePart }, Equipped: Tool, Range: number): (nil)
			if not Equipped.Enabled then return end
			if not CanGetGunValidator then return end
			
			local Character = Player.Character
			local Distance, Closest = math.huge
			local MyPosition = Services.PlayerManager:GetRootPartPosition()
			
			for _, hitPart in hitParts do
				if hitPart:IsDescendantOf(Character) then continue end
				if not IsEnemyAttackableFromPart(hitPart) then continue end
				
				local Magnitude = (MyPosition - hitPart.Position).Magnitude
				
				if Magnitude < Distance then
					Magnitude, Closest = Magnitude, hitPart
				end
				
				if Magnitude < 50 then
					break
				end
			end
			
			if Closest then
				local enemyCharacter = GetCharacterFromPart(Closest)
				local ShootType = SHOOTS_TYPES[Equipped.Name] or "Normal"
				
				if ShootType == "Overheat" then
					ATTACK_DEBOUNCE = tick() + 9e9
					
					while IsAlive(Character) and IsAlive(enemyCharacter) and Equipped.Parent == Character do
						UpdateShootAndValidator(Equipped)
						RE_ShootGunEvent:FireServer(Closest.Position, { Closest })
						task.wait()
						
						if DistanceFromCharacter(Closest) > Range then
							break
						end
					end
					
					ATTACK_DEBOUNCE = 0
				elseif ShootType == "Normal" then
					UpdateShootAndValidator(Equipped)
					
					for index = 1, (SHOOTS_PER_TARGET[Equipped.Name] or 1) do
						RE_ShootGunEvent:FireServer(Closest.Position, { Closest })
					end
				else
					FastAttack:ShootInTarget(Closest.Position)
				end
			end
		end
		
		local function UseFruitM1(hitParts: { BasePart }, LeftClickRemote: RemoteEvent): (nil)
			local Character = Player.Character
			
			for _, hitPart in hitParts do
				if hitPart:IsDescendantOf(Character) then continue end
				if not IsEnemyAttackableFromPart(hitPart) then continue end
				
				local rootPosition = Services.PlayerManager:GetRootPartPosition()
				local direction = (hitPart.Position - rootPosition).Unit
				
				SendLeftClickRemote(LeftClickRemote, direction, GetBloxFruitCombo())
				return nil
			end
		end
		
		function FastAttack.AddAttackDebounce(Value: number): (nil)
			ATTACK_DEBOUNCE = tick() + Value
		end
		
		function FastAttack.DontAttackBelowPercent(Percent)
			BELOW_ATTACK_ENABLED_DEBOUNCE = tick() + 1
			BELOW_ATTACK_PERCENT = Percent
		end
		
		function FastAttack:ShootInTarget(TargetPosition: Vector3): (nil)
			if (tick() - SHOOT_DEBOUNCE) < 0 then return end
			if not CanGetGunValidator then return end
			
			local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
			if not Equipped or Equipped.ToolTip ~= "Gun" then return end
			
			local Cooldown = Equipped:FindFirstChild("Cooldown")
			if not Cooldown then return end
			
			local ShootType = SHOOTS_TYPES[Equipped.Name]
			
			if ShootType == "Position" or ShootType == "TAP" and Equipped:FindFirstChild("RemoteEvent") then
				SHOOT_DEBOUNCE = tick() + Cooldown.Value
				UpdateShootAndValidator(Equipped)
				
				if ShootType == "TAP" then
					Equipped.RemoteEvent:FireServer("TAP", TargetPosition)
				else
					RE_ShootGunEvent:FireServer(TargetPosition)
				end
			end
		end
		
		NewConnection(Stepped, function()
			local Character = Player.Character
			if not IsAlive(Character) then return end
			if (tick() - ATTACK_DEBOUNCE) <= 0 then return end
			
			local Humanoid = Character.Humanoid
			local RootPart = Humanoid.RootPart
			
			if not RootPart then return end
			
			local Equipped = Character:FindFirstChildOfClass("Tool")
			
			if not Equipped or not IsAttackWeapon(Equipped) then
				return nil
			end
			
			if CheckAttackDebounce(Equipped) and CheckStun(Equipped) then
				local ToolTip = Equipped.ToolTip
				local Cooldown = NewDebounce(Equipped)
				local Range = (RANGES_BY_NAME[Equipped.Name] or ATTACK_RANGE[ToolTip]) * 2
				
				local Parts = GetPartBoundsInBox(Equipped, RootPart.CFrame, Range)
				if #Parts == 0 then return end
				
				if ToolTip == "Blox Fruit" and not NORMAL_HITS_FRUITS[Equipped.Name] then
					local LeftClickRemote = Equipped:FindFirstChild("LeftClickRemote")
					
					if LeftClickRemote then
						UseFruitM1(Parts, LeftClickRemote)
					end
				elseif ToolTip == "Gun" then
					if Settings.AutoShoot or Settings.UseDragonstormSea then
						UseGunShoot(Parts, Equipped, Range)
					end
				elseif Settings.AutoAttack then
					DamageParts(Equipped, Cooldown, Parts)
				end
			end
		end)
		
		return FastAttack
	end)()
	
	return Services
end)()

local SkillsDebounce = {}

function Module.RemoveBasePartsCollision(Object)
	local Descendants = Object:GetDescendants()
	
	for index = 1, #Descendants do
		local value = Descendants[index]
		if value:IsA("BasePart") and value.CanCollide then
			value.CanCollide = false
		end
	end
end

local MasteryRequirements = Module.Services.Inventory.MasteryRequirements

function Module.UseSkills(Target: any?, Skills: table?): (nil)
	if DistanceFromCharacter(Target) >= 60 then return end
	
	local Equipped = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
	
	if Equipped then
		local Level = Equipped:GetAttribute("Level") or 0
		local Mastery = MasteryRequirements[Equipped.Name]
		
		if Mastery == nil and Equipped:FindFirstChild("Data") then
			local Success, Requirements = pcall(require, Equipped.Data)
			
			if Success and type(Requirements) == "table" then
				MasteryRequirements[Equipped.Name] = Requirements.Lvl or false
			else
				MasteryRequirements[Equipped.Name] = false
			end
		end
		
		for Skill, Enabled in Skills do
			if not Enabled then continue end
			if Mastery and (not Mastery[Skill] or Level < Mastery[Skill]) then continue end
			
			local Debounce = SkillsDebounce[Skill]
			
			if Enabled and (tick() - (Debounce or 0)) >= 0 then
				VirtualInputManager:SendKeyEvent(true, Skill, false, game)
				VirtualInputManager:SendKeyEvent(false, Skill, false, game)
				SkillsDebounce[Skill] = tick() + HIDDEN_SETTINGS.SKILL_COOLDOWN
			end
		end
	end
end

Module.TweenBodyVelocity = (function()
	local ClearNoclipObjects = HookManager.ClearNoclipObjects
	local AddNoclipObject = HookManager.AddNoclipObject
	local UnprotectObject = HookManager.UnprotectObject
	local ProtectObject = HookManager.ProtectObject
	local OriginalIndex = HookManager.OriginalIndex
	
	local BodyVeloChangedSignal = Module.Services.GoodSignal.Signals.BvChanged
	
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Velocity = Vector3.zero
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.P = 1000
	
	local old_bodyVelocity = _ENV.tween_bodyvelocity
	
	if old_bodyVelocity then
		UnprotectObject(old_bodyVelocity)
		old_bodyVelocity.Parent = nil
		old_bodyVelocity:Destroy()
	end
	
	ProtectObject(BodyVelocity)
	_ENV.tween_bodyvelocity = BodyVelocity
	
	local IsA, FindFirstChild = game.IsA, game.FindFirstChild
	
	local IS_CUSTOM_TAG = false
	local TELEPORTING_TAG = "Teleporting"
	
	local BaseParts = {} do
		local noclipObjects = {}
		HookManager.SetNoclipObjects(noclipObjects)
		
		local function AddObjectToBaseParts(Object)
			if Object ~= BodyVelocity and IsA(Object, "BasePart") and Object.CanCollide then
				table.insert(BaseParts, Object)
				noclipObjects[Object] = true
			end
		end
		
		local function RemoveObjectsFromBaseParts(BasePart)
			local index = table.find(BaseParts, BasePart)
			noclipObjects[BasePart] = nil
			
			if index then
				table.remove(BaseParts, index)
			end
		end
		
		local function NewCharacter(Character)
			if not Character then return end
			table.clear(BaseParts)
			
			for _, Object in Character:GetDescendants() do AddObjectToBaseParts(Object) end
			Character.DescendantAdded:Connect(AddObjectToBaseParts)
			Character.DescendantRemoving:Connect(RemoveObjectsFromBaseParts)
			
			Character:WaitForChild("Humanoid", 9e9).Died:Wait()
			table.clear(BaseParts)
			noclipObjects = {}
			SetNoclipObjects(noclipObjects)
		end
		
		NewConnection(Player.CharacterAdded, NewCharacter)
		task.spawn(NewCharacter, Player.Character)
	end
	
	local function NoClipOnStepped(Character)
		if not IS_CUSTOM_TAG and _ENV.OnFarm then
			IS_CUSTOM_TAG = true
		end
		
		if _ENV.OnFarm and not Player:HasTag(TELEPORTING_TAG) then
			Player:AddTag(TELEPORTING_TAG)
			IS_CUSTOM_TAG = true
		elseif IS_CUSTOM_TAG and not _ENV.OnFarm and Player:HasTag(TELEPORTING_TAG) then
			Player:RemoveTag(TELEPORTING_TAG)
			IS_CUSTOM_TAG = false
		end
		
		if _ENV.OnFarm then
			for index = 1, #BaseParts do
				BaseParts[index].CanCollide = false
			end
		else
			local RootPart = Character.Humanoid.RootPart
			
			if RootPart and (not RootPart.CanCollide or not RootPart.CanTouch) then
				for index = 1, #BaseParts do
					BaseParts[index].CanCollide = true
				end
			end
		end
	end
	
	local function UpdateVelocityOnStepped(Character)
		local BasePart = FindFirstChild(Character, "UpperTorso")
		local Humanoid = FindFirstChild(Character, "Humanoid")
		local BodyVelocity = _ENV.tween_bodyvelocity
		
		local NewParent = if _ENV.OnFarm and BasePart and Humanoid and Humanoid.Health > 0 then BasePart else nil
		
		if OriginalIndex(BodyVelocity, "Parent") ~= NewParent then
			BodyVelocity.Parent = NewParent
			BodyVeloChangedSignal:Fire(NewParent)
		end
		
		local Velocity = OriginalIndex(BodyVelocity, "Velocity")
		
		if Velocity ~= Vector3.zero and (not Humanoid or not Humanoid.SeatPart or not _ENV.OnFarm) then
			BodyVelocity.Velocity = Vector3.zero
		end
	end
	
	NewConnection(Stepped, function()
		local Character = Player.Character
		if IsAlive(Character) then
			NoClipOnStepped(Character)
			UpdateVelocityOnStepped(Character)
		end
	end)
	
	return BodyVelocity
end)()

Module.RunModules = (function()
	local Modules = {}
	
	local function NewModule(Name, Module)
		Modules[Name] = Module
	end
	
	NewModule("InitializeQuests", function(QuestsModule, Data)
		local getQuestTasks = Data.GetQuestTasks
		local QuestsLookup = Data.QuestsLookup
		local Quests = Data.Quests
		
		local questsLevelsBySea = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[GameData.Sea]
		local blacklistedQuests = CreateDictionary({"BartiloQuest", "MarineQuest", "CitizenQuest"}, true)
		
		for questName, task in QuestsModule do
			if blacklistedQuests[questName] then continue end
			
			for index, mission in task do
				local levelRequired = mission.LevelReq
				
				if levelRequired >= questsLevelsBySea[1] and levelRequired < questsLevelsBySea[2] then
					local targets, enemyLocations = getQuestTasks(mission)
					local primaryTarget = targets[1]
					
					local QuestData = {
						QuestName = questName,
						QuestIndex = index,
						Quest = {
							EnemyLocations = enemyLocations,
							LevelReq = levelRequired,
							Targets = targets
						}
					}
					
					QuestsLookup[primaryTarget] = QuestData
					table.insert(Quests, QuestData)
				end
			end
		end
		
		table.sort(Quests, function(quest1, quest2)
			return quest1.Quest.LevelReq < quest2.Quest.LevelReq
		end)
	end)
	
	NewModule("FarmQueue", function(Options)
		local function GetQueue()
			for _, Option in Options do
				Settings.RunningOption = Option.Name
				local Method = Option.Function()
				if not Method then continue end
				
				if type(Method) == "string" then
					Settings.RunningMethod = Method
				end
				
				return true
			end
			
			Settings.RunningOption, Settings.RunningMethod = nil, nil
		end
		
		while task.wait(Settings.SmoothMode and 0.25 or 0) do
			if _ENV.teleporting then
				_ENV.OnFarm = true
			elseif Settings.IgnoreErrors then
				local success, response = pcall(GetQueue)
				
				if not success then
					warn(`redz Hub Error in {Settings.RunningOption} -> {response}`)
				end
				
				_ENV.OnFarm = (not success and _ENV.OnFarm) or response
			else
				_ENV.OnFarm = if GetQueue() then true else false
			end
		end
	end)
	
	NewModule("Translator", function(Window, Translation)
		local OldMakeTab = Window.MakeTab
		local IsHooked = false
		
		local RealFunctions = {}
		local Hooks = {}
		
		local START_WARN_TITLE = "⚠️ "
		
		local function NewTranslation(Option)
			local OptionTitle = Option.Title
			local Warning = false
			
			if OptionTitle:sub(1, #START_WARN_TITLE) == START_WARN_TITLE then
				OptionTitle = OptionTitle:sub(#START_WARN_TITLE + 1, -1)
				Warning = true
			end
			
			local Translated = Translation[OptionTitle]
			
			if Translated then
				if type(Translated) == "string" then
					Option:SetTitle((Warning and START_WARN_TITLE or "") .. Translated)
					return Option
				end
				
				if Translated[1] ~= nil then
					Option:SetTitle((Warning and START_WARN_TITLE or "") .. Translated[1])
				end
				
				if Translated[2] ~= nil then
					Option:SetDesc(Translated[2])
				end
			end
			
			return Option
		end
		
		function Hooks:AddSection(Name)
			return NewTranslation(RealFunctions["AddSection"](self, Name))
		end
		
		function Hooks:AddParagraph(Name, Desc)
			return NewTranslation(RealFunctions["AddParagraph"](self, Name, Desc))
		end
		
		function Hooks:AddToggle(Configs)
			return NewTranslation(RealFunctions["AddToggle"](self, Configs))
		end
		
		function Hooks:AddDropdown(Configs)
			return NewTranslation(RealFunctions["AddDropdown"](self, Configs))
		end
		
		function Hooks:AddSlider(Configs)
			return NewTranslation(RealFunctions["AddSlider"](self, Configs))
		end
		
		function Hooks:AddButton(Configs)
			return NewTranslation(RealFunctions["AddButton"](self, Configs))
		end
		
		function Hooks:AddTextBox(Configs)
			return NewTranslation(RealFunctions["AddTextBox"](self, Configs))
		end
		
		Window.MakeTab = function(self, Configs)
			local Title = Configs[1] or Configs.Name or Configs.Title
			
			if Translation[Title] then
				Configs[1] = Translation[Title]
			end
			
			local Tab = OldMakeTab(self, Configs)
			
			for CreatorName, Function in Hooks do
				RealFunctions[CreatorName] = Tab[CreatorName]
				Tab[CreatorName] = Function
			end
			
			return Tab
		end
	end)
	
	NewModule("OptionsPlugin", function(EnabledOptions, Options)
		local Builder = {}
		
		function Builder.Toggle(Tab, Settings, Flag)
			local Option = Tab:AddToggle({
				Name = Settings[1],
				Default = if type(Settings[2]) ~= "string" then Settings[2] else nil,
				Description = Settings[if type(Settings[2]) == "string" then 2 else 3],
				Callback = function(Value) EnabledOptions[Flag] = Value end,
				Flag = Flag
			})
			
			Options[Flag] = Option
			return Option
		end
		
		return Builder
	end)
	
	NewModule("TweenManager", function()
		local module = {}
		module.__index = module
		
		local tweens = {}
		local EasingStyle = Enum.EasingStyle.Linear
		
		function module.new(obj, time, prop, value)
			local self = setmetatable({}, module)
			
			self.tween = TweenService:Create(obj, TweenInfo.new(time, EasingStyle), { [prop] = value })
			self.tween:Play()
			self.value = value
			self.object = obj
			
			if tweens[obj] then
				tweens[obj]:destroy()
			end
			
			tweens[obj] = self
			return self
		end
		
		function module:destroy()
			self.tween:Pause()
			self.tween:Destroy()
			
			tweens[self.object] = nil
			setmetatable(self, nil)
		end
		
		function module:stopTween(obj)
			if obj and tweens[obj] then
				tweens[obj]:destroy()
			end
		end
		
		return module
	end)
	
	return Modules
end)()

task.defer(function()
	local OwnersId = { 3095250, 17884881 }
	local OwnersFriends = CreateDictionary({ 6079649301, 4985647299 }, true)
	
	local LocalPlayer = Player
	
	local StaffsItems = {
		["Triple Dark Blade"] = true
	}
	
	local BlacklistedAttributes = {"GANKS", "GANKSVolley", "AAIM"}
	
	local MaxLevel = GameData.MaxLevel
	local CurrentSea = GameData.Sea
	local MaxBounty = 3e7 + 250000
	
	local VerificationSteps = {
		(function(Player)
			if table.find(OwnersId, Player.UserId) then
				return true
			elseif OwnersFriends[Player.UserId] then
				return true
			end
		end),
		(function(Player, Data)
			if Data.Level.Value > MaxLevel then
				return true
			elseif Data.Beli.Value >= 3e8 and Data.Level.Value <= 700 then
				return true
			end
		end),
		(function(Player, Data)
			if CurrentSea > 1 and Data.Level.Value < 700 then
				return true
			elseif CurrentSea > 2 and Data.Level.Value < 1500 then
				return true
			end
		end),
		(function(Player)
			for index = 1, #BlacklistedAttributes do
				if Player:GetAttribute(BlacklistedAttributes[index]) then
					return true
				end
			end
		end),
		(function(Player)
			local BountyHonor = Player:WaitForChild("leaderstats"):WaitForChild("Bounty/Honor")
			
			if BountyHonor.Value > MaxBounty or BountyHonor.Value < 0 then
				return true
			end
		end)
	}
	
	local function PossibleStaff(Player)
		Module.RejoinBlocked = true
		return LocalPlayer:Kick(`{ Player.DisplayName }/@{ Player.Name } maybe it's a blox fruits admin`)
	end
	
	local NewPlayerAdded = Obfuscated.NewPlayerAdded
	Obfuscated.SetPossibleStaffKick(PossibleStaff)
	
	local function StaffCheck(Player)
		if Player == LocalPlayer then return end
		
		local Data = Player:WaitForChild("Data", 30)
		
		if Data then
			Data:WaitForChild("Level", 10)
			Data:WaitForChild("Beli", 10)
			task.spawn(NewPlayerAdded, Player)
			
			for index = 1, #VerificationSteps do
				local success, isStaff = pcall(VerificationSteps[index], Player, Data)
				if not success then
					warn(`redz Hub -> failed to check if @{Player.Name} is a Staff: {isStaff}`)
				elseif isStaff then
					return PossibleStaff(Player)
				end
			end
		end
	end
	
	task.spawn(function()
		table.insert(Connections, Players.PlayerAdded:Connect(StaffCheck))
		for _, Player in ipairs(Players:GetPlayers()) do task.defer(StaffCheck, Player) end
	end)
	
	for _, OwnerId in OwnersId do
		local FriendsPages = Players:GetFriendsAsync(OwnerId)
		if not FriendsPages then task.wait(5) continue end
		
		while not FriendsPages.IsFinished do
			local FriendsList = FriendsPages:GetCurrentPage()
			
			for index = 1, #FriendsList do
				local Friend = FriendsList[index]
				local Player = Players:GetPlayerByUserId(Friend.Id)
				
				if Player then
					task.defer(PossibleStaff, Player)
				else
					OwnersFriends[Friend.Id] = true
				end
			end
			
			FriendsPages:AdvanceToNextPageAsync()
		end
	end
end)

return Modulereturn ag(ai,aj)
end)

ah=M(game,"__namecall",function(ai,...)
if Z[ai]then
return ah(ab,...)
end
return ah(ai,...)
end)

function X.ProtectObject(ai)
assert(ai,`ProtectObject -> Instance expeted, got {typeof(ai)}`)

ai.Name=ab.Name
Z[ai]=ac(ab)
end

function X.UnprotectObject(ai)
if X.IsProtected(ai)then return end
assert(ai,`UnprotectObject -> Instance expeted, got {typeof(ai)}`)

local aj=Z[ai]
if aj then
Z[ai]=nil
aj:Destroy()
end
end

function X.IsProtected(ai)
return Z[ai]~=nil
end

function X.HookProperty(ai,aj,ak)
if not Y[ai]then
Y[ai]={}
end
Y[ai][aj]=ak
end

function X.UnhookProperty(ai,aj)
local ak=Y[ai]
if ak then
ak[aj]=nil

if next(ak)==nil then
Y[ai]=nil
end
end
end

function X.SetNoclipObjects(ai)
_=ai
end

function X.Clear()
table.clear(Z)
table.clear(Y)
X.ClearNoclipObjects()
end

X.OriginalIndex=ag
X.OriginalNamecall=ah

return X end


local ac=(function()
local ac=f.rz_hook_manager or ab()
f.rz_hook_manager=ac
return ac
end)()

local ad={
SKILL_COOLDOWN=0.5,
CLEAR_AFTER=50,

SILENT_AIM_ENABLED=true,
WALKSPEED_BYPASS_ENABLED=true,
}

local ae local af=function(

af)
return af:gsub(if af:find"Lv. "then" %pLv. %d+%p"else" %pBoss%p","")end local ag=function(


ag)
if ag.Parent==s then
ag=m:GetPlayerFromCharacter(ag)
end

if tostring(ag.Team)=="Marines"and ag.Team==C.Team then
return false
elseif ag:HasTag(`Ally{C.Name}`)or C:HasTag(`Ally{ag.Name}`)then
return false
end

return true end local ah=function()



local ah=0

return{
__newindex=function(ai,aj,ak)
if ah>=ad.CLEAR_AFTER then
for al,X in ai do
if typeof(X)=="Instance"and not X:IsDescendantOf(game)then
rawset(ai,al,nil)
end
end
ah=0
end

ah+=1
return rawset(ai,aj,ak)
end
}end local ai=function(


ai)
return setmetatable({},{__index=function()return ai end})end


local aj do
local ak=ah()
ak.__index=function(al,X)
local Y=X:FindFirstChild(if X.Parent==t then"Health"else"Humanoid")

if Y then
al[X]=Y
return Y
end
end

aj=setmetatable({},ak)
end local ak=function(

ak)
return ak[if ak.ClassName=="Humanoid"then"Health"else"Value"]end local al=function(


al)
if typeof(al)~="Vector3"then
al=al.Position
end
return C:DistanceFromCharacter(al)end local X=function(


X, Y)
if Y then
return ak(Y)>0
elseif X then
local Z=aj[X]

if Z and Z.Parent==X then
return ak(Z)>0
else
return X.Parent==v
end
end

return false end local Y=function(


Y)


return error(Y,2)end local am=function(


Z)
local _;

for am in string.gmatch(string.sub(Z,2,-1),"[^%.]+")do
if not _ then
_=`{am}.`
else
_..=am
end
end

return tonumber(_)or 0 end local an=function(


Z, _, an)
table.insert(c,Z[an or"Connect"](Z,_))end local ao=function(


Z)
local _=h:GetTagged(Z)

an(h:GetInstanceAddedSignal(Z),function(ao)
table.insert(_,ao)
end)

return _ end local Z=function(


Z)
return Z:FindFirstChild(HitboxLimbs[math.random(#HitboxLimbs)])end local _=function(


_)
d.LockedTool(_)

if _.Parent==C.Character then
return true
elseif _.Parent==C.Backpack then
C.Character.Humanoid:EquipTool(_)
return true
end

return false end local ap=function(


ap, aq)
if not X(C.Character)then
return nil
end

aq=aq or not ap
ap=ap or e.FarmTool

local ar=ae

if ar and ar.Parent and ar[if aq then"ToolTip"else"Name"]==ap then
if _(ar)then
return nil
end
end

if ap and not aq then
local as=C.Backpack:FindFirstChild(ap)

if as then
ae=as
_(as)
end

return nil
end

for as,at in C.Backpack:GetChildren()do
if at:IsA"Tool"and at.ToolTip==ap then
ae=at
_(at)
return nil
end
end end


local aq={
Closest=nil,
Equipped=nil,

RealFruitsName=setmetatable({},ah()),
RealFruitsId=setmetatable({},ah()),

Enemies={},
Progress={},
Tools={}
}

local ar={
Sea=table.find({2753915549,4442272183,7449423635},game.PlaceId)or 0,
SeasName={"Main","Dressrosa","Zou"},
MaxMastery=600,
MaxLevel=2800
}

ar.StringVersion=d.GetGameVersion(Y)
ar.NumberVersion=am(ar.StringVersion)

do
if string.sub(ar.StringVersion,1,1)~="v"then return C:Kick()end

local as=string.split(string.sub(ar.StringVersion,2,-1),".")
local at=`{as[1]or 0}.`;

for au=2,#as do
at..=tostring(as[au]or 0)
end

ar.NumberVersion=tonumber(at)or 0
end

local as={
CreateDictionary=aa,
NewConnection=an,
HookManager=ac,
GameData=ar,
IsAlive=X,
}

function as.RejoinServer()
if T or#m:GetPlayers()==1 then
j:Teleport(game.PlaceId,C)
else
j:TeleportToPlaceInstance(game.PlaceId,game.JobId,C)
end
end

function as.ServerHop(at,au)
as.RejoinBlocked=true

at=math.min(at or 8,11)
au=au or"Singapore"

local av=i.__ServerBrowser;
local aw=av.InvokeServer;
local ax=game.JobId;
local ay=1;
local az=task.delay local aA=function()


local aA,aB=pcall(aw,av,ay)
ay+=1

if aA~=true then return end
if type(aB)~="table"then return end

local aC,aD=at;

for aE,aF in aB do
if aE~=ax and aF.Count<=aC then
aC,aD=aF.Count,aE;
end
end

if aD then
j:TeleportToPlaceInstance(game.PlaceId,aD,C)
end end


for aB=1,100 do
az(aB/50,aA)
end
end

function as.GetRaidIsland()
if V and V.Parent==y then
return V
end

for at=5,1,-1 do
local au=`Island {at}`

for av,aw in y:GetChildren()do
if aw.Name==au and al(aw.Position)<3500 then
V=aw
return aw
end
end
end
end

do
local at={}local au=function(...)


table.insert(at,{...})end


au("Frags",{
{"Race Reroll",{"BlackbeardReward","Reroll","2"}};
{"Reset Stats",{"BlackbeardReward","Refund","2"}};
});

au("Fighting Style",{
{"Buy Black Leg",{"BuyBlackLeg"}};
{"Buy Electro",{"BuyElectro"}};
{"Buy Fishman Karate",{"BuyFishmanKarate"}};
{"Buy Dragon Claw",{"BlackbeardReward","DragonClaw","2"}};
{"Buy Superhuman",{"BuySuperhuman"}};
{"Buy Death Step",{"BuyDeathStep"}};
{"Buy Sharkman Karate",{"BuySharkmanKarate"}};
{"Buy Electric Claw",{"BuyElectricClaw"}};
{"Buy Dragon Talon",{"BuyDragonTalon"}};
{"Buy GodHuman",{"BuyGodhuman"}};
{"Buy Sanguine Art",{"BuySanguineArt"}};
});

au("Ability Teacher",{
{"Buy Geppo",{"BuyHaki","Geppo"}};
{"Buy Buso",{"BuyHaki","Buso"}};
{"Buy Soru",{"BuyHaki","Soru"}};
{"Buy Ken",{"KenTalk","Buy"}};
});

au("Sword",{
{"Buy Katana",{"BuyItem","Katana"}};
{"Buy Cutlass",{"BuyItem","Cutlass"}};
{"Buy Dual Katana",{"BuyItem","Dual Katana"}};
{"Buy Iron Mace",{"BuyItem","Iron Mace"}};
{"Buy Triple Katana",{"BuyItem","Triple Katana"}};
{"Buy Pipe",{"BuyItem","Pipe"}};
{"Buy Dual-Headed Blade",{"BuyItem","Dual-Headed Blade"}};
{"Buy Soul Cane",{"BuyItem","Soul Cane"}};
{"Buy Bisento",{"BuyItem","Bisento"}};
});

au("Gun",{
{"Buy Musket",{"BuyItem","Musket"}};
{"Buy Slingshot",{"BuyItem","Slingshot"}};
{"Buy Flintlock",{"BuyItem","Flintlock"}};
{"Buy Refined Slingshot",{"BuyItem","Refined Slingshot"}};
{"Buy Dual Flintlock",{"BuyItem","Dual Flintlock"}};
{"Buy Cannon",{"BuyItem","Cannon"}};
{"Buy Kabucha",{"BlackbeardReward","Slingshot","2"}};
});

au("Accessories",{
{"Buy Black Cape",{"BuyItem","Black Cape"}};
{"Buy Swordsman Hat",{"BuyItem","Swordsman Hat"}};
{"Buy Tomoe Ring",{"BuyItem","Tomoe Ring"}};
});

au("Race",{
{"Ghoul Race",{"Ectoplasm","Change",4}};
{"Cyborg Race",{"CyborgTrainer","Buy"}};
});

as.Shop=at;
end

function as:IsBlacklistedExecutor()
return L
end

do
local at="Fruit "
local au=10
local av="Fruit [ ???-??? ]"
local aw="0"

local ax={}local ay=function(

ay, az)
ax[string.format("rbxassetid://%s",tostring(ay))]=string.format("Fruit [ %s-%s ]",az,az)end


do
ay(15124425041,"Rocket")
ay(15123685330,"Spin")
ay(15123613404,"Blade")
ay(15123689268,"Spring")
ay(15123595806,"Bomb")
ay(15123677932,"Smoke")
ay(15124220207,"Spike")
ay(121545956771325,"Flame")
ay(15123673019,"Sand")
ay(15123618591,"Dark")
ay(77885466312115,"Eagle")
ay(15112600534,"Diamond")
ay(15123640714,"Light")
ay(15123668008,"Rubber")
ay(15123662036,"Ghost")
ay(15123645682,"Magma")
ay(15123606541,"Quake")
ay(15123643097,"Love")
ay(15123681598,"Spider")
ay(116828771482820,"Creation")
ay(15123679712,"Sound")
ay(15123654553,"Phoenix")
ay(15123656798,"Portal")
ay(15123670514,"Rumble")
ay(15123652069,"Pain")
ay(15123587371,"Blizzard")
ay(15123633312,"Gravity")
ay(15123648309,"Mammoth")
ay(15694681122,"T-Rex")
ay(15123624401,"Dough")
ay(15123675904,"Shadow")
ay(10773719142,"Venom")
ay(15123616275,"Control")
ay(118054805452821,"Gas")
ay(11911905519,"Spirit")
ay(15123638064,"Leopard")
ay(115276580506154,"Yeti")
ay(15487764876,"Kitsune")
ay(95749033139458,"Dragon East")
end

local az=setmetatable({},ah())
local aA=setmetatable({},ah())

local aB={
Animation="Animation",
Fruit="MeshPart",
Idle="MeshPart"
}local aC=function(

aC)
return aC:IsA"MeshPart"and"MeshId"or"AnimationId"end local aD=function(


aD, aE, aF)
az[aD]=aE
aA[aD]=aF end local aE=function(


aE)
local aF=aB[aE.Name]

if aF and aE:IsA(aF)then
local aG=aE[aC(aE)]
return ax[aG],aG
end end local aF=function(


aF, aG)
for aH,aI in aF:GetChildren()do
local aJ,aK=aE(aI)
if aJ then
aD(aF,aJ,aK)
return aJ,aK
end
end

local aH
local aI
local aJ=au

local aK=aG.ChildAdded:Connect(function(aK)
if not aH then
aH,aI=aE(aK)
end
end)

while not aH and aJ>0 do
aJ-=task.wait()
end

aK:Disconnect()

if aH then
aD(aF,aH,aI)
return aH
end end


function as.GetRealFruitName(aG,aH)
if aG.Name~=at then
return aG.Name
end

if az[aG]then
return aH and aA[aG]or az[aG]
end

az[aG]=av
aA[aG]=aw

local aI=aG:WaitForChild("Fruit",math.huge)
aF(aG,aI)

return(aH and aA[aG]or az[aG])or aw
end
end

as.CollectionService=(function()
local at={}

local au=ao"_ChestTagged"
local av=ao"BerryBush"

local aw,ax=0;
local ay,az=0;

at.Chests=au
at.Berries=av local aA=function(

aA)
return aA and not aA:GetAttribute"IsDisabled"end local aB=function(


aB)
return aB and next(aB:GetAttributes())~=nil end local aC=function(


aC)
if aA(ax)and(not aC or ax:IsDescendantOf(aC))then
return ax
elseif(tick()-aw)<1 then
return nil
end

local aD,aE=math.huge

for aF=1,#au do
local aG=au[aF]
if aA(aG)and(not aC or ax:IsDescendantOf(aC))then
local aH=C:DistanceFromCharacter(aG:GetPivot().Position)

if aH<aD then
aD,aE=aH,aG
end
end
end

aw=tick()
ax=aE

return aE end local aD=function()



if aB(az)and az:IsDescendantOf(w)then
return az
elseif(tick()-ay)<1 then
return nil
end

local aD,aE=math.huge

for aF=1,#av do
local aG=av[aF]

if aB(aG)and aG.Parent then
local aH=al(aG.Parent:GetPivot().Position)

if aH<aD then
aD,aE=aH,aG
end
end
end

ay=tick()
az=aE

return aE end


as.GetClosestChest=aC;
as.GetClosestBerry=aD;
as.HasBerries=aB;

return at
end)()

as.Services=(function()
local at={}

at.Network=(function()
local au={}

local av=o.InvokeServer;

local aw="RF/%s";
local ax="RE/%s";

local ay={};local az=function(

az, aA, aB)
local aC=I:WaitForChild(az:format(aB))

if not aC then
return error(`Cannot found {aB}: {aA} in Network`,2)
end

return aC end


function au.InvokeCommF(...)
return av(o,...)
end

function au.TravelTo(aA)
return au.InvokeCommF(`Travel{ar.SeasName[aA]}`)
end

function au.GetProgress(...)
local aA=...

if ay[aA]and ay[aA].Debounce<0 then
return unpack(ay[aA].Args)
end

ay[aA]={
Debounce=tick()+2.5,
Args=table.pack(au.InvokeCommF(...))
}

return unpack(ay[aA].Args)
end

function au:RemoteFunction(aA)
return az(aw,"RemoteFunction",aA)
end

function au:RemoteEvent(aA)
return az(ax,"RemoteEvent",aA)
end

return au
end)()

at.GoodSignal=(function()
local au={}
local av={}

av.__index=av
au.__index=au

do
function av:Disconnect()
if not self.Connected then
return nil
end

local aw=table.find(self.Signal,self)

if aw then
table.remove(self.Signal,aw)
end

self.Function=nil
self.Connected=false
end

function av:Fire(...)
if not self.Function then
return nil
end

task.spawn(self.Function,...)
end

function av.new()
return setmetatable({
Connected=true
},av)
end

setmetatable(av,{
__index=function(aw,ax)
error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(ax)),2)
end,
__newindex=function(aw,ax,ay)
error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(ax)),2)
end
})
end

function au:Connect(aw)
assert(type(aw)=="function","function expected, got "..type(aw))

local ax=av.new()
ax.Function=aw
ax.Signal=self

table.insert(self.Connections,ax)
return ax
end

function au:Once(aw)
local ax;
ax=self:Connect(function(...)
aw(...)
ax:Disconnect()
end)
return ax
end

function au:Wait()
local aw=coroutine.running()
local ax;ax=self:Connect(function(...)
ax:Disconnect()
task.spawn(aw,...)
end)
return coroutine.yield()
end

function au:Fire(...)
for aw,ax in ipairs(self.Connections)do
if ax.Connected then
ax:Fire(...)
end
end
end

function au.new()
return setmetatable({
Connections={}
},au)
end

au.Signals={
BvChanged=au.new(),
Notify=au.new(),
Error=au.new(),
}

setmetatable(au,{
__index=function(aw,ax)
error(`Attempt to get Signal::{tostring(ax)} (not a valid member)`,2)
end,
__newindex=function(aw,ax,ay)
error(`Attempt to set Signal::{tostring(ax)} (not a valid member)`,2)
end
})

return au
end)()

at.PlayerManager=(function()
local au={}

local av=Vector3.zero local aw=function()


local aw=C.Character
return X(aw)and aw.Humanoid.RootPart end


function au:GetRootPartPosition()
local ax=aw()

if ax then
av=ax.Position
end

return av
end

an(C.CharacterAdded,function(...)PlayerCharacter=...end)
an(C.CharacterRemoving,function()PlayerCharacter=nil end)

return au
end)()

at.Hooking=(function()
local au={}

local av=aa({"Z","X","C","V","F"},true)

local aw=f.rz_EnabledOptions;
local ax;

local ay=0;
local az=0;local aA=function(

aA)
if(tick()-ay)<=2 or f[aA]then
return ax
end end local aB=function()



local aB=tick()

if(aB-ay)<=2 or(aB-az)<=0 then
return nil
else
az=aB+(if e.SmoothMode then 0.5 else 0.25)
end

local aC=C.Character
local aD=X(aC)and aC:FindFirstChildOfClass"Tool"

if aD and aD.ToolTip and aC.Humanoid.RootPart then
local aE=if aD.ToolTip=="Gun"then 250 else 900

local aF=aC.Humanoid.RootPart.Position
local aG=s:GetChildren()
local aH=u:GetChildren()

ax=nil

for aI=1,#aG do
local aJ=aG[aI]
if aJ==aC or not ag(aJ)then continue end
local aK=X(aJ)and aJ.Humanoid.RootPart

if aK then
local aL=(aK.Position-aF).Magnitude

if aL<=aE then
ax,aE=aK,aL
end
end
end

for aI=1,(if e.NoAimMobs then 0 else#aH)do
local aJ=aH[aI]
local aK=X(aJ)and aJ.Humanoid.RootPart

if aK then
local aL=(aK.Position-aF).Magnitude

if aL<=aE then
ax,aE=aK,aL
end
end
end
end end local aC=function()



if f.rz_enabled_bypass or not ad.WALKSPEED_BYPASS_ENABLED then return end
f.rz_enabled_bypass=true

local aC=ac.HookProperty

local aD;
aD=M(C,"__newindex",function(aE,aF,aG)
if aF=="WalkSpeed"and aE.Name=="Humanoid"then
aC(aE,aF,aG)
return aD(aE,"WalkSpeed",f.WalkSpeedBypass or aG)
else
return aD(aE,aF,aG)
end
end)end local aD=function()



if not ad.SILENT_AIM_ENABLED then return end
if f.rz_original_namecall then return end

B:Connect(aB)

local aD={
["RE/ShootGunEvent"]=function(...)
local aD,aE=...

if typeof(aD)=="Vector3"and type(aE)=="table"and#aE~=0 then
local aF=aA"AimBot_Gun"

if aF then
return aF.Position,{aF}
end
end

return...
end,
["RemoteEvent"]=function(...)
local aD,aE=...

if typeof(aD)=="Vector3"and not aE then
local aF=aA"AimBot_Skills"

if aF then
return aF.Position
end
elseif aD=="TAP"and typeof(aE)=="Vector3"then
local aF=aA"AimBot_Tap"

if aF then
return"TAP",aF.Position
end
end

return...
end
}

local aE=ac.OriginalIndex
local aF=string.lower

local aG;
aG=M(game,"__namecall",function(aH,...)
local aI=aD[aE(aH,"Name")]

if aI and aF(getnamecallmethod())=="fireserver"then
return aG(aH,aI(...))
else
return aG(aH,...)
end
end)

f.rz_original_namecall=aG end


as.HookGame=function()
task.delay(1,aC)
task.delay(1,aD)
end

function au:SetAimTarget(aE)
ax,ay=aE,tick()
end

return au
end)()

at.Inventory=(function()
local au={
Unlocked=ai(false),
Mastery=ai(0),
Count=ai(0),
MasteryRequirements={},

Loaded=false,
Items={}
}

local av=at.GoodSignal.Signals.Notify local aw=function(

aw, ax)
if type(ax)~="table"then return end

local ay=ax.Name
aw.Items[ay]=ax

if not aw.Unlocked[ay]then aw.Unlocked[ay]=true end
if ax.Count then aw.Count[ay]=ax.Count end
if ax.Mastery then aw.Mastery[ay]=ax.Mastery end
if ax.MasteryRequirements then aw.MasteryRequirements[ay]=ax.MasteryRequirements end end local ax=function(


ax, ay)
if type(ay)=="string"then
ax.MasteryRequirements[ay]=nil
ax.Unlocked[ay]=nil
ax.Mastery[ay]=nil
ax.Count[ay]=nil
ax.Items[ay]=nil
end end


local ay={
["ItemChanged"]=function(...)aw(au,...)end;
["ItemAdded"]=function(...)aw(au,...)end;
["ItemRemoved"]=function(...)ax(au,...)end;
["Notify"]=function(...)av:Fire(...)end;
}local az=function(

az, ...)
if az and ay[az]then
ay[az](...)
end end local aA=function()



return at.Network.InvokeCommF"getInventory"end


task.defer(function()
an(p.OnClientEvent,az)
local aB=aA();

while type(aB)~="table"and task.wait(1)do
aB=aA()
end

for aC=1,#aB do
aw(au,aB[aC])
end

au.Loaded=true
end)

return au
end)()

at.Enemies=(function()
local au=aa({
"__CakePrince","__PirateRaid","__TyrantSkies","__Bones","__Elite","__Others","__Ectoplasm"
},{})

local av={
["Deandre"]="Elite",["Diablo"]="Elite",["Urban"]="Elite",

["Reborn Skeleton"]="Bones",["Living Zombie"]="Bones",
["Demonic Soul"]="Bones",["Posessed Mummy"]="Bones",

["Head Baker"]="CakePrince",["Baking Staff"]="CakePrince",
["Cake Guard"]="CakePrince",["Cookie Crafter"]="CakePrince",

["Sun-kissed Warrior"]="TyrantSkies",["Skull Slayer"]="TyrantSkies",
["Isle Champion"]="TyrantSkies",["Serpent Hunter"]="TyrantSkies",

["Ship Deckhand"]="Ectoplasm",["Ship Engineer"]="Ectoplasm",
["Ship Officer"]="Ectoplasm",["Ship Steward"]="Ectoplasm",
}

local aw=as.SpawnLocations
local ax=aq.Enemies

local ay=ac.UnprotectObject
local az=ac.ProtectObject
local aA=ac.OriginalIndex

local aB=d.GetBringAttachment()

local aC={}
local aD={}

local aE={}
local aF={}

au.SpawnLocations=aE
au.EnemyLocations=aF

au.PirateRaid=0

do
local aG=aa({"Ice Admiral","rip_indra"},true)
local aH={}local aI=function(

aI, aJ, aK, aL)
aH[aI]={
BossSpawn=CFrame.new(unpack(aJ)),
LevelReq=aL,
Quest=aK
}end


function au.IsABoss(aJ)
return aH[aJ]~=nil
end

function au.EnemyIsBoss(aJ)
return(aJ:GetAttribute"IsBoss"or aJ:GetAttribute"RaidBoss")and not aG[aJ.Name]
end

function au:GetBosses()
return aH
end


aI("The Gorilla King",{-1128,6,-451},{"JungleQuest",CFrame.new(-1598,37,153)},20)
aI("Chef",{-1131,14,4080},{"BuggyQuest1",CFrame.new(-1140,4,3829)},55)
aI("Yeti",{1185,106,-1518},{"SnowQuest",CFrame.new(1385,87,-1298)},105)
aI("Vice Admiral",{-4807,21,4360},{"MarineQuest2",CFrame.new(-5035,29,4326),2},130)
aI("Warden",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692),1},220)
aI("Chief Warden",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692),2},230)
aI("Swan",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692)},240)
aI("Magma Admiral",{-5694,18,8735},{"MagmaQuest",CFrame.new(-5319,12,8515)},350)
aI("Fishman Lord",{61350,31,1095},{"FishmanQuest",CFrame.new(61122,18,1567)},425)
aI("Wysper",{-7927,5551,-637},{"SkyExp1Quest",CFrame.new(-7861,5545,-381)},500)
aI("Thunder God",{-7751,5607,-2315},{"SkyExp2Quest",CFrame.new(-7903,5636,-1412)},575)
aI("Cyborg",{6138,10,3939},{"FountainQuest",CFrame.new(5258,39,4052)},675)


aI("Diamond",{-1569,199,-31},{"Area1Quest",CFrame.new(-427,73,1835)},750)
aI("Jeremy",{2316,449,787},{"Area2Quest",CFrame.new(635,73,919)},850)
aI("Orbitus",{-2086,73,-4208},{"MarineQuest3",CFrame.new(-2441,73,-3219)},925)
aI("Smoke Admiral",{-5078,24,-5352},{"IceSideQuest",CFrame.new(-6061,16,-4904)},1150)
aI("Awakened Ice Admiral",{6473,297,-6944},{"FrostQuest",CFrame.new(5668,28,-6484)},1400)
aI("Tide Keeper",{-3711,77,-11469},{"ForgottenQuest",CFrame.new(-3056,240,-10145)},1475)


aI("Stone",{-1049,40,6791},{"PiratePortQuest",CFrame.new(-449,109,5950)},1550)
aI("Hydra Leader",{5836,1019,-83},{"VenomCrewQuest",CFrame.new(5214,1004,761)},1675)
aI("Kilo Admiral",{2904,509,-7349},{"MarineTreeIsland",CFrame.new(2485,74,-6788)},1750)
aI("Captain Elephant",{-13393,319,-8423},{"DeepForestIsland",CFrame.new(-13233,332,-7626)},1875)
aI("Beautiful Pirate",{5370,22,-89},{"DeepForestIsland2",CFrame.new(-12682,391,-9901)},1950)
aI("Cake Queen",{-710,382,-11150},{"IceCreamIslandQuest",CFrame.new(-818,66,-10964)},2175)

table.freeze(aH)
end

do
local aG="Island "local aH=function(

aH)
if string.sub(aH.Name,1,#aG)==aG then
V=nil
end end local aI=function(


aI)
local aJ=af(aI.Name)
aF[aJ]=aF[aJ]or{}

local aK=aI.CFrame+Vector3.one*25
aE[aJ]=aI

if not table.find(aF[aJ],aK)then
table.insert(aF[aJ],aK)
end end


for aJ,aK in x:GetChildren()do aI(aK)end
an(x.ChildAdded,aI)
an(y.ChildAdded,aH)
end local aG=function(

aG)
return not aD[aG]end local aH=function(


aH, aI, aJ, aK, aL)
while aI.Parent==u and X(_,aK)and aL.Parent==aI do
local aM=aC[aJ].Position

if(aM-aL.Position).Magnitude<=e.BringDistance then
if aH.Position~=aM then
aH.Position=aM
end
else
break
end

task.wait(0.25)
end end local aI=function(


aI)
if aD[aI]then return end
aD[aI]=true

local aJ=aI.Name
local aK=aI.Humanoid
local aL=aK.RootPart

local aM=aB:Clone()
local aN=aM.AlignPosition

aM.Parent=aL
aH(aN,aI,aJ,aK,aL)

aD[aI]=nil

if aM then
aM:Destroy()
end end


function au.GetEnemy(aJ)
if type(aJ)=="table"then
return au:GetClosest(aJ)
else
return au:GetEnemyByTag(aJ)
end
end

function au.IsSpawned(aJ)
local aK=aE[aJ]

if aK and aK.Parent==x then
return aK:GetAttribute"Active"
else
return au:GetEnemyByTag(aJ)~=nil
end
end

function au:GetMobsName(aJ)
local aK={}
for aL,aM in av do
if aM==aJ then
table.insert(aK,aL)
end
end
return aK
end

function au.BringMobs(aJ,aK,aL)
local aM=X(aJ)and aJ.Humanoid.RootPart
if not aM then return end

local aN=aJ.Name
W(9e9)

if not e.BringMobs then
if not aC[aN]then
aC[aN]=aM.CFrame
end

aM.CFrame=aC[aN]
return nil
end

local aO=at.PlayerManager:GetRootPartPosition()

local aP=aK or aM.CFrame
local aQ=aL or e.BringDistance

if not aC[aN]or(aP.Position-aC[aN].Position).Magnitude>25 then
aC[aN]=aP
end

for aR,aS in au:GetTagged(aN)do
if not aS:FindFirstChild"CharacterReady"then continue end
if aS.Parent~=u or aS.Name~=aN then continue end

local aT=X(aS)and aS.Humanoid.RootPart
if not aT then continue end

if(aO-aT.Position).Magnitude<aQ then
task.spawn(aI,aS)
end
end
end

function au:GetTagged(aJ)
return self[`__{aJ}`]or self.__Others[aJ]
end

function au:GetEnemyByTag(aJ)
local aK=ax[aJ]

if aK and aK.Parent~=nil and X(aK)then
return aK
end

local aL=self:GetTagged(aJ)
if not aL then return end

for aM=1,#aL do
if X(aL[aM])then
return aL[aM]
end
end
end

function au:GetClosest(aJ)
local aK=table.concat(aJ,"_")
local aL=ax[aK]

if aL and aL.Parent~=nil and X(aL)then
return aL
end

local aM,aN=math.huge

for aO=1,#aJ do
local aP=self:GetClosestByTag(aJ[aO])
local aQ=X(aP)and aP.Humanoid.RootPart
local aR=aQ and C:DistanceFromCharacter(aQ.Position)

if aQ and aR<=aM then
aM,aN=aR,aP
end
end

if aN then
ax[aK]=aN
return aN
end
end

function au:GetClosestByTag(aJ)
local aK=ax[aJ]

if aK and aK.Parent~=nil and X(aK)then
return aK
end

local aL=self:GetTagged(aJ)

if aL and#aL>0 then
local aM=at.PlayerManager:GetRootPartPosition()
local aN,aO=math.huge

for aP=1,#aL do
local aQ=aL[aP]
local aR=X(aQ)and aQ.Humanoid.RootPart
if not aR then continue end

local aS=(aM-aR.Position).Magnitude

if aS<=50 then
ax[aJ]=aQ
return aQ
elseif aS<=aN then
aN,aO=aS,aQ
end
end

if aO then
ax[aJ]=aO
return aO
end
end
end

do
local aJ=Vector3.new(-5556,314,-2988)
local aK=au.__Others
local aL=ar.Sea local aM=function(

aM, aN)
if table.find(aM,aN)then return end

local aO=aN:WaitForChild"Humanoid"

if aO and aO.Health>0 then
table.insert(aM,aN)
aO.Died:Once(function()
table.remove(aM,table.find(aM,aN))
end)
end end local aN=function(


aN)
if aN.Name=="rip_indra True Form"or aN.Name=="Blank Buddy"then return end

local aO=aN:WaitForChild("Humanoid",600)
if not aO or aO.Health<=0 then return end

local aP=aN:WaitForChild"HumanoidRootPart"

if aP and(aP.Position-aJ).Magnitude<=750 then
task.spawn(aM,au.__PirateRaid,aN)
au.PirateRaid=tick()
end end local aO=function(


aO)
local aP=aO.Name
local aQ=`__{aP}`

aK[aP]=aK[aP]or{}
task.spawn(aM,aK[aP],aO)

if aL==3 then
task.spawn(aN,aO)
end

if au[aQ]then
task.spawn(aM,au[aQ],aO)
elseif av[aP]then
task.spawn(aM,au[`__{av[aP]}`],aO)
end end


for aP,aQ in h:GetTagged"BasicMob"do aO(aQ)end
an(h:GetInstanceAddedSignal"BasicMob",aO)
end

return au
end)()

at.ToolService=(function()
local au={}

local av=at.Network.InvokeCommF
local ax=aq.Tools
local ay=25000 local az=function(

az)
local aA=C.Character:FindFirstChildOfClass"Tool"

if aA and aA.ToolTip==az then
return aA
end

for aB,aC in C.Backpack:GetChildren()do
if aC:IsA"Tool"and aC.ToolTip==az then
return aC
end
end end local aA=function()



if G.Value<ay then return end

av("BuyHaki","Buso")end local aB=function(


aB, aC)
return aB.ToolTip=="JobTool"and aB:GetAttribute"JobId"==aC end local aC=function(


aC, aD)
local aE=C.Character
if not X(aE)then return end

local aF=if aD then`toolTip_{aC}`else aC
local aG=ax[aF]

if aG and(aG.Parent==aE or aG.Parent==C.Backpack)then
return aG
end

local aH=if aD then az(aC)else(aE:FindFirstChild(aC)or C.Backpack:FindFirstChild(aC))

if aH then
ax[aF]=aH
return aH
end end


function au.GetToolMastery(aD,...)
local aE=aC(aD,...)
return aE and aE:GetAttribute"Level"or 0
end

function au.EquipJobTool(aD)
local aE=C.Character
if not X(aE)then return end

local aF=aE:FindFirstChildOfClass"Tool"

if aF and aB(aF,aD)then
return aF
end

for aG,aH in C.Backpack:GetChildren()do
if aH:IsA"Tool"and aB(aH,aD)then
_(aH)
return aH
end
end
end

function au.VerifyTool(aD,...)
return aC(aD,...)~=nil
end

function au.EnableBuso()
local aD=C.Character
if X(aD)and not aD:FindFirstChild"HasBuso"then
return if aD:HasTag"Buso"then av"Buso"else aA()
end
end

au.EquipTool=ap

return au
end)()

at.FastAttack=(function()
local au={
attackPlayers=true,
attackMobs=true,
}

local av={
["Blox Fruit"]=35,
["Melee"]=40,
["Sword"]=40,
["Gun"]=200,
}

local ax={
["Dual Flintlock"]=2
}

local ay={
["Dragonstorm"]=300
}

local az={
["Skull Guitar"]="TAP",
["Bazooka"]="Position",
["Cannon"]="Position",
["Dragonstorm"]="Overheat"
}

local aA=aa({"Light-Light","Ice-Ice"},true)

local aB=at.Network

local aC=d.SendLeftClickRemote
local aD=d.CheckAttackDebounce
local aE=d.GetPartBoundsInBox
local aF=d.PlayHitAnimation
local aG=d.SetHitsCooldown
local aH=d.IsAttackWeapon
local aI=d.NewDebounce
local aJ=d.GetMaxHits
local aK=d.CheckStun

local aL=d.CanSendHitsToServer
local aM=d.SendHitsToServer

local aN=d.UpdateShootAndValidator
local aO=d.CanGetGunValidator

local aP=aB:RemoteEvent"ShootGunEvent"

local aQ=0
local aR=0.4
local aS=4
local aT=0

local aU=0
local aV=0
local aW=0
local aX=0

d.SetRigisterAttackEvent(aB:RemoteEvent"RegisterAttack")
d.SetRigisterHitEvent(aB:RemoteEvent"RegisterHit")local aY=function(

aY)
return if aY==s then au.attackPlayers else au.attackMobs end local aZ=function(


aZ, a_, a0)
local a1=aJ()
local a2={}
local a3={}

for a4,a5 in a0 do
local a6=a5.Parent
local a7=a6.Parent

if a7.Parent~=workspace or not X(a6)then continue end
if a7==s and(a6==C.Character or not ag(a6))then continue end
if not aY(a7)then continue end

if(tick()-aU)<=0 then
if(a6.Humanoid.Health/a6.Humanoid.MaxHealth)<=aV then
continue
end
end

if not a3[a6]then
table.insert(a2,{a6,a5})
a3[a6]=true
end

if#a2>=a1 then
break
end
end

if#a2>0 then
aF(aZ)
aG(a_)
aM(a2)
end end local a_=function()



if aT>=aS or(tick()-aQ)>=aR then
aT=0
end

aQ=tick()
aT+=1
return aT end local a0=function(


a0)
local a1=a0.Parent
local a2=a1.Parent.Parent

if a2~=workspace then
a2=a2.Parent
a1=a1.Parent
end

if a2==workspace and X(a1)and aY(a1.Parent)then
return true
end

return false end local a1=function(


a1)
while a1.Parent.Parent~=workspace do
a1=a1.Parent
end
return a1 end local a2=function(


a2, a3, a4)
if not a3.Enabled then return end
if not aO then return end

local a5=C.Character
local a6,a7=math.huge
local a8=at.PlayerManager:GetRootPartPosition()

for a9,ba in a2 do
if ba:IsDescendantOf(a5)then continue end
if not a0(ba)then continue end

local bb=(a8-ba.Position).Magnitude

if bb<a6 then
bb,a7=bb,ba
end

if bb<50 then
break
end
end

if a7 then
local a9=a1(a7)
local ba=az[a3.Name]or"Normal"

if ba=="Overheat"then
aW=tick()+9e9

while X(a5)and X(a9)and a3.Parent==a5 do
aN(a3)
aP:FireServer(a7.Position,{a7})
task.wait()

if al(a7)>a4 then
break
end
end

aW=0
elseif ba=="Normal"then
aN(a3)

for bb=1,(ax[a3.Name]or 1)do
aP:FireServer(a7.Position,{a7})
end
else
au:ShootInTarget(a7.Position)
end
end end local a3=function(


a3, a4)
local a5=C.Character

for a6,a7 in a3 do
if a7:IsDescendantOf(a5)then continue end
if not a0(a7)then continue end

local a8=at.PlayerManager:GetRootPartPosition()
local a9=(a7.Position-a8).Unit

aC(a4,a9,a_())
return nil
end end


function au.AddAttackDebounce(a4)
aW=tick()+a4
end

function au.DontAttackBelowPercent(a4)
aU=tick()+1
aV=a4
end

function au:ShootInTarget(a4)
if(tick()-aX)<0 then return end
if not aO then return end

local a5=X(C.Character)and C.Character:FindFirstChildOfClass"Tool"
if not a5 or a5.ToolTip~="Gun"then return end

local a6=a5:FindFirstChild"Cooldown"
if not a6 then return end

local a7=az[a5.Name]

if a7=="Position"or a7=="TAP"and a5:FindFirstChild"RemoteEvent"then
aX=tick()+a6.Value
aN(a5)

if a7=="TAP"then
a5.RemoteEvent:FireServer("TAP",a4)
else
aP:FireServer(a4)
end
end
end

an(B,function()
local a4=C.Character
if not X(a4)then return end
if(tick()-aW)<=0 then return end

local a5=a4.Humanoid
local a6=a5.RootPart

if not a6 then return end

local a7=a4:FindFirstChildOfClass"Tool"

if not a7 or not aH(a7)then
return nil
end

if aD(a7)and aK(a7)then
local a8=a7.ToolTip
local a9=aI(a7)
local ba=(ay[a7.Name]or av[a8])*2

local bb=aE(a7,a6.CFrame,ba)
if#bb==0 then return end

if a8=="Blox Fruit"and not aA[a7.Name]then
local bc=a7:FindFirstChild"LeftClickRemote"

if bc then
a3(bb,bc)
end
elseif a8=="Gun"then
if e.AutoShoot or e.UseDragonstormSea then
a2(bb,a7,ba)
end
elseif e.AutoAttack then
aZ(a7,a9,bb)
end
end
end)

return au
end)()

return at
end)()

local at={}

function as.RemoveBasePartsCollision(au)
local av=au:GetDescendants()

for ax=1,#av do
local ay=av[ax]
if ay:IsA"BasePart"and ay.CanCollide then
ay.CanCollide=false
end
end
end

local au=as.Services.Inventory.MasteryRequirements

function as.UseSkills(av,ax)
if al(av)>=60 then return end

local ay=C.Character and C.Character:FindFirstChildOfClass"Tool"

if ay then
local az=ay:GetAttribute"Level"or 0
local aA=au[ay.Name]

if aA==nil and ay:FindFirstChild"Data"then
local aB,aC=pcall(require,ay.Data)

if aB and type(aC)=="table"then
au[ay.Name]=aC.Lvl or false
else
au[ay.Name]=false
end
end

for aB,aC in ax do
if not aC then continue end
if aA and(not aA[aB]or az<aA[aB])then continue end

local aD=at[aB]

if aC and(tick()-(aD or 0))>=0 then
g:SendKeyEvent(true,aB,false,game)
g:SendKeyEvent(false,aB,false,game)
at[aB]=tick()+ad.SKILL_COOLDOWN
end
end
end
end

as.TweenBodyVelocity=(function()
local av=ac.ClearNoclipObjects
local ax=ac.AddNoclipObject
local ay=ac.UnprotectObject
local az=ac.ProtectObject
local aA=ac.OriginalIndex

local aB=as.Services.GoodSignal.Signals.BvChanged

local aC=Instance.new"BodyVelocity"
aC.Velocity=Vector3.zero
aC.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
aC.P=1000

local aD=f.tween_bodyvelocity

if aD then
ay(aD)
aD.Parent=nil
aD:Destroy()
end

az(aC)
f.tween_bodyvelocity=aC

local aE,aF=game.IsA,game.FindFirstChild

local aG=false
local aH="Teleporting"

local aI={}do
local aJ={}
ac.SetNoclipObjects(aJ)local aK=function(

aK)
if aK~=aC and aE(aK,"BasePart")and aK.CanCollide then
table.insert(aI,aK)
aJ[aK]=true
end end local aL=function(


aL)
local aM=table.find(aI,aL)
aJ[aL]=nil

if aM then
table.remove(aI,aM)
end end local aM=function(


aM)
if not aM then return end
table.clear(aI)

for aN,aO in aM:GetDescendants()do aK(aO)end
aM.DescendantAdded:Connect(aK)
aM.DescendantRemoving:Connect(aL)

aM:WaitForChild("Humanoid",9e9).Died:Wait()
table.clear(aI)
aJ={}
SetNoclipObjects(aJ)end


an(C.CharacterAdded,aM)
task.spawn(aM,C.Character)
end local aJ=function(

aJ)
if not aG and f.OnFarm then
aG=true
end

if f.OnFarm and not C:HasTag(aH)then
C:AddTag(aH)
aG=true
elseif aG and not f.OnFarm and C:HasTag(aH)then
C:RemoveTag(aH)
aG=false
end

if f.OnFarm then
for aK=1,#aI do
aI[aK].CanCollide=false
end
else
local aK=aJ.Humanoid.RootPart

if aK and(not aK.CanCollide or not aK.CanTouch)then
for aL=1,#aI do
aI[aL].CanCollide=true
end
end
end end local aK=function(


aK)
local aL=aF(aK,"UpperTorso")
local aM=aF(aK,"Humanoid")
local aN=f.tween_bodyvelocity

local aO=if f.OnFarm and aL and aM and aM.Health>0 then aL else nil

if aA(aN,"Parent")~=aO then
aN.Parent=aO
aB:Fire(aO)
end

local aP=aA(aN,"Velocity")

if aP~=Vector3.zero and(not aM or not aM.SeatPart or not f.OnFarm)then
aN.Velocity=Vector3.zero
end end


an(B,function()
local aL=C.Character
if X(aL)then
aJ(aL)
aK(aL)
end
end)

return aC
end)()

as.RunModules=(function()
local av={}local ax=function(

ax, ay)
av[ax]=ay end


ax("InitializeQuests",function(ay,az)
local aA=az.GetQuestTasks
local aB=az.QuestsLookup
local aC=az.Quests

local aD=({{0,700},{700,1500},{1500,math.huge}})[ar.Sea]
local aE=aa({"BartiloQuest","MarineQuest","CitizenQuest"},true)

for aF,aG in ay do
if aE[aF]then continue end

for aH,aI in aG do
local aJ=aI.LevelReq

if aJ>=aD[1]and aJ<aD[2]then
local aK,aL=aA(aI)
local aM=aK[1]

local aN={
QuestName=aF,
QuestIndex=aH,
Quest={
EnemyLocations=aL,
LevelReq=aJ,
Targets=aK
}
}

aB[aM]=aN
table.insert(aC,aN)
end
end
end

table.sort(aC,function(aF,aG)
return aF.Quest.LevelReq<aG.Quest.LevelReq
end)
end)

ax("FarmQueue",function(ay)local az=function()

for az,aA in ay do
e.RunningOption=aA.Name
local aB=aA.Function()
if not aB then continue end

if type(aB)=="string"then
e.RunningMethod=aB
end

return true
end

e.RunningOption,e.RunningMethod=nil,nil end


while task.wait(e.SmoothMode and 0.25 or 0)do
if f.teleporting then
f.OnFarm=true
elseif e.IgnoreErrors then
local aA,aB=pcall(az)

if not aA then
warn(`redz Hub Error in {e.RunningOption} -> {aB}`)
end

f.OnFarm=(not aA and f.OnFarm)or aB
else
f.OnFarm=if az()then true else false
end
end
end)

ax("Translator",function(ay,az)
local aA=ay.MakeTab
local aB=false

local aC={}
local aD={}

local aE="⚠️ "local aF=function(

aF)
local aG=aF.Title
local aH=false

if aG:sub(1,#aE)==aE then
aG=aG:sub(#aE+1,-1)
aH=true
end

local aI=az[aG]

if aI then
if type(aI)=="string"then
aF:SetTitle((aH and aE or"")..aI)
return aF
end

if aI[1]~=nil then
aF:SetTitle((aH and aE or"")..aI[1])
end

if aI[2]~=nil then
aF:SetDesc(aI[2])
end
end

return aF end


function aD:AddSection(aG)
return aF(aC["AddSection"](self,aG))
end

function aD:AddParagraph(aG,aH)
return aF(aC["AddParagraph"](self,aG,aH))
end

function aD:AddToggle(aG)
return aF(aC["AddToggle"](self,aG))
end

function aD:AddDropdown(aG)
return aF(aC["AddDropdown"](self,aG))
end

function aD:AddSlider(aG)
return aF(aC["AddSlider"](self,aG))
end

function aD:AddButton(aG)
return aF(aC["AddButton"](self,aG))
end

function aD:AddTextBox(aG)
return aF(aC["AddTextBox"](self,aG))
end

ay.MakeTab=function(aG,aH)
local aI=aH[1]or aH.Name or aH.Title

if az[aI]then
aH[1]=az[aI]
end

local aJ=aA(aG,aH)

for aK,aL in aD do
aC[aK]=aJ[aK]
aJ[aK]=aL
end

return aJ
end
end)

ax("OptionsPlugin",function(ay,az)
local aA={}

function aA.Toggle(aB,aC,aD)
local aE=aB:AddToggle{
Name=aC[1],
Default=if type(aC[2])~="string"then aC[2]else nil,
Description=aC[if type(aC[2])=="string"then 2 else 3],
Callback=function(aE)ay[aD]=aE end,
Flag=aD
}

az[aD]=aE
return aE
end

return aA
end)

ax("TweenManager",function()
local ay={}
ay.__index=ay

local az={}
local aA=Enum.EasingStyle.Linear

function ay.new(aB,aC,aD,aE)
local aF=setmetatable({},ay)

aF.tween=k:Create(aB,TweenInfo.new(aC,aA),{[aD]=aE})
aF.tween:Play()
aF.value=aE
aF.object=aB

if az[aB]then
az[aB]:destroy()
end

az[aB]=aF
return aF
end

function ay:destroy()
self.tween:Pause()
self.tween:Destroy()

az[self.object]=nil
setmetatable(self,nil)
end

function ay:stopTween(aB)
if aB and az[aB]then
az[aB]:destroy()
end
end

return ay
end)

return av
end)()

task.defer(function()
local av={3095250,17884881}
local ax=aa({6079649301,4985647299},true)

local ay=C

local az={
["Triple Dark Blade"]=true
}

local aA={"GANKS","GANKSVolley","AAIM"}

local aB=ar.MaxLevel
local aC=ar.Sea
local aD=3025E4

local aE={
(function(aE)
if table.find(av,aE.UserId)then
return true
elseif ax[aE.UserId]then
return true
end
end),
(function(aE,aF)
if aF.Level.Value>aB then
return true
elseif aF.Beli.Value>=3e8 and aF.Level.Value<=700 then
return true
end
end),
(function(aE,aF)
if aC>1 and aF.Level.Value<700 then
return true
elseif aC>2 and aF.Level.Value<1500 then
return true
end
end),
(function(aE)
for aF=1,#aA do
if aE:GetAttribute(aA[aF])then
return true
end
end
end),
(function(aE)
local aF=aE:WaitForChild"leaderstats":WaitForChild"Bounty/Honor"

if aF.Value>aD or aF.Value<0 then
return true
end
end)
}local aF=function(

aF)
as.RejoinBlocked=true
return ay:Kick(`{aF.DisplayName}/@{aF.Name} maybe it's a blox fruits admin`)end


local aG=d.NewPlayerAdded
d.SetPossibleStaffKick(aF)local aH=function(

aH)
if aH==ay then return end

local aI=aH:WaitForChild("Data",30)

if aI then
aI:WaitForChild("Level",10)
aI:WaitForChild("Beli",10)
task.spawn(aG,aH)

for aJ=1,#aE do
local aK,aL=pcall(aE[aJ],aH,aI)
if not aK then
warn(`redz Hub -> failed to check if @{aH.Name} is a Staff: {aL}`)
elseif aL then
return aF(aH)
end
end
end end


task.spawn(function()
table.insert(c,m.PlayerAdded:Connect(aH))
for aI,aJ in ipairs(m:GetPlayers())do task.defer(aH,aJ)end
end)

for aI,aJ in av do
local aK=m:GetFriendsAsync(aJ)
if not aK then task.wait(5)continue end

while not aK.IsFinished do
local aL=aK:GetCurrentPage()

for aM=1,#aL do
local aN=aL[aM]
local aO=m:GetPlayerByUserId(aN.Id)

if aO then
task.defer(aF,aO)
else
ax[aN.Id]=true
end
end

aK:AdvanceToNextPageAsync()
end
end
end)

return as
