local Settings = ...

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local rs_Monsters = ReplicatedStorage:WaitForChild("MonsterSpawn")
local Modules = ReplicatedStorage:WaitForChild("ModuleScript")
local OtherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Monsters = workspace:WaitForChild("Monster")

local MQuestSettings = require(Modules:WaitForChild("Quest_Settings"))
local MSetting = require(Modules:WaitForChild("Setting"))

local Characters = workspace:WaitForChild("Character")
local NPCs = workspace:WaitForChild("NPCs")
local Raids = workspace:WaitForChild("Raids")
local Location = workspace:WaitForChild("Location")

local EnemyLocation = Location:WaitForChild("Enemy_Location")
local QuestLocation = Location:WaitForChild("QuestLocaion")

local Gamepass = Player:WaitForChild("PlayerSpecial")
local Cooldown = Player:WaitForChild("Cooldown")
local Items = Player:WaitForChild("Items")
local Ability = Player:WaitForChild("Ability")
local PlayerData = Player:WaitForChild("PlayerData")
local PlayerLevel = PlayerData:WaitForChild("Level")

local sethiddenproperty = sethiddenproperty or (function()end)
local _env = getgenv and getgenv() or {}

local _insert = table.insert
local _spawn = task.spawn
local _wait = task.wait
local _huge = math.huge

local Skill_DB = {}

local Module = {} do
  Module.__index = Module
  
  Module.MaxLevel = MSetting.Setting.MaxLevel
  Module.PassesPrice = MSetting.Setting.Gamepasses_Cost
  Module.BL_Spawns = MSetting.Setting.IgnoreSpawnPoints
  Module.PassesId = {}
  
  Module.WeaponList = {"Fight", "Power", "Weapon"}
  Module.Shop = {
    {"Weapons", {
      {"Katana", "$5.000 Money", {"Weapon_Seller", "Doge"}},
      {"Hanger", "$25.000 Money", {"Weapon_Seller", "Hanger"}},
      {"Flame Katana", "1x Cheems Cola and $50.000", {"Weapon_Seller", "Cheems"}},
      {"Banana", "1x Cat Food and $350.000", {"Weapon_Seller", "Smiling Cat"}},
      {"Bonk", "5x Money Bags and $1.000.000", {"Weapon_Seller", "Meme Man"}},
      {"Pumpkin", "1x Nugget Man and $3.500.000", {"Weapon_Seller", "Gravestone"}},
      {"Popcat", "10.000 Pops Clicker", {"Weapon_Seller", "Ohio Popcat"}}
    }},
    {"Ability", {
      {"Flash Step", "$100.000 Money", {"Ability_Teacher", "Giga Chad"}},
      {"Instinct", "$2.500.000 Money", {"Ability_Teacher", "Nugget Man"}},
      {"Aura", "1x Meme Cube and $10.000.000", {"Ability_Teacher", "Aura Master"}}
    }},
    {"Fighting Style", {
      {"Combat", "$0 Money", {"FightingStyle_Teacher", "Maxwell"}},
      {"Baller", "10x Balls and $10.000.000", {"FightingStyle_Teacher", "Baller"}}
    }}
  }
  Module.ItemsPrice = {
    ["Quest Scroll"] = { Money = 1000000 },
    ["Aura"] = { Material = {"Meme Cube", 1}, Money = 10000000 },
    ["Instinct"] = { Money = 2500000 },
    ["FlashStep"] = { Money = 100000 },
    ["Katana"] = { Money = 5000 },
    ["Hanger"] = { Money = 25000 },
    ["Flame Katana"] = { Material = {"Cheems Cola", 1}, Money = 50000 },
    ["Banana"] = { Material = {"Cat Food", 1}, Money = 350000 },
    ["Bonk"] = { Material = {"Money Bag", 5}, Money = 1000000 },
    ["Pumpkin"] = { Material = {"Nugget Man", 1}, Money = 3500000 },
    ["Baller"] = { Material = {"Ball", 10}, Money = 10000000 },
    ["Popcat"] = { Pop = 10000 }
  }
  
  function Module:IsAlive(Char)
    local Hum = Char and Char:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
  end
  
  function Module:GetEnemy(EnName)
    if EnName then
      local Enemy = Monsters:FindFirstChild(EnName) or rs_Monsters:FindFirstChild(EnName)
      if self:IsAlive(Enemy) then
        return Enemy
      end
    end
    for _,Enemy in ipairs(Monsters:GetChildren()) do
      if (not EnName or Enemy.Name == EnName) and self:IsAlive(Enemy) then
        return Enemy
      end
    end
    return false
  end
  
  function Module:GoTo(CFrame, Move)
    local Char = Player.Character
    return self:IsAlive(Char) and (Move and Char:MoveTo(CFrame.p) or Char:SetPrimaryPartCFrame(CFrame))
  end
  
  function Module:PlayerClick()
    local Character = Player.Character
    
    if Character then
      if Settings.AutoHaki and not Character:GetAttribute("Using_Aura") and self:AbilityUnlocked("Aura") then
        OtherEvent.MainEvents.Ability:InvokeServer("Aura")
      end
      
      local Equipped = Character:FindFirstChildOfClass("Tool")
      
      if Equipped then
        Equipped.Enabled = true
        Equipped:Activate()
      end
    end
  end
  
  function Module:EquipWeapon()
    local Char, Tool = Player.Character, Settings.ToolFarm
    if Tool and self:IsAlive(Char) then
      local charTool = Char:FindFirstChildOfClass("Tool")
      if not charTool or not charTool.ToolTip:find(Tool) then
        for _,v in ipairs(Player.Backpack:GetChildren()) do
          if v:IsA("Tool") and v.ToolTip:find(Tool) then
            _env.EquippedTool = v
            return Char.Humanoid:EquipTool(v)
          end
        end
      end
    end
  end
  
  function Module:BringMobsTo(EnName, CFrame, BAll)
    for _,Enemy in ipairs(Monsters:GetChildren()) do
      if (BAll or Enemy.Name == EnName) and self:IsAlive(Enemy) then
        local PP, Hum = Enemy.PrimaryPart, Enemy.Humanoid
        if PP and (PP.Position - CFrame.p).Magnitude < 500 then
          Hum.WalkSpeed = 0
          Hum:ChangeState(14)
          PP.CFrame = CFrame
          PP.CanCollide = false
          PP.Size = Vector3.new(40, 40, 40)
        end
      end
    end
    return pcall(sethiddenproperty, Player, "SimulationRadius", _huge)
  end
  
  function Module:GetRaidEnemy()
    for _,Enemy in ipairs(Monsters:GetChildren()) do
      if Enemy:GetAttribute("Raid_Enemy") and self:IsAlive(Enemy) then
        return Enemy
      end
    end
  end
  
  function Module:GetRaidMap()
    for _,Map in ipairs(Raids:GetChildren()) do
      if Map.Joiners:FindFirstChild(Player.Name) then
        return Map
      end
    end
  end
  
  function Module:KillEnemy(EnName, ...)
    local Enemy = type(EnName) == "string" and self:GetEnemy(EnName) or EnName
    local PP = Enemy.PrimaryPart
    
    if PP then
      self:GoTo(PP.CFrame * Settings.FarmCFrame)self:EquipWeapon()self:UseSkills()
      if not Enemy:FindFirstChild("Reverse_Mark") then self:PlayerClick() end
      if Settings.BringMobs then self:BringMobsTo(EnName, PP.CFrame, ...) end
      return true
    end
  end
  
  function Module:AbilityUnlocked(Ablt)
    return Ability:FindFirstChild(Ablt) and Ability[Ablt].Value
  end
  
  function Module:CanUseSkill(key)
    for _,v in ipairs(Cooldown:GetChildren()) do
      if v.Name:find("_" .. key) then
        return false
      end
    end
    return true
  end
  
  function Module:UseSkills()
    if _env.AutoSkill then
      for key, Value in pairs(Settings.SkillsSelected) do
        if Value and not Skill_DB[key] and self:CanUseSkill(key) then
          VIM:SendKeyEvent(true, key, false, game)
          VIM:SendKeyEvent(false, key, false, game)
          _spawn(function() Skill_DB[key] = true; _wait(0.5); Skill_DB[key] = false; end)
        end
      end
    end
  end
  
  function Module:UnlockedGamepass(GaName)
    return Gamepass[GaName].Value
  end
  
  function Module:GetNearestList(Distance)
    local List = {}
    for _,plr in ipairs(Players:GetPlayers()) do
      local Char = plr.Character
      if plr ~= Player and self:IsAlive(Char) then
        local PP = Char.PrimaryPart
        if PP and Player:DistanceFromCharacter(PP.Position) <= Distance then
          _insert(List, Char)
        end
      end
    end
    return List
  end
  
  _spawn(function()
    for _,Pass in ipairs(require(Modules.Gamepass_Assets)) do
      Module.PassesId[Pass.Asset_Name] = Pass.GamepassId
    end
  end)
  
  _spawn(function()
    if _env.Loaded_HUN then return end
    _env.Loaded_HUN = true
    
    local Label = Player.PlayerGui.MainGui.PlayerName
    
    local function Update()
      local Level = PlayerLevel.Value
      local IsMax = Level >= Module.MaxLevel
      Label.Text = ("%s • Lv. %i%s"):format("Anonymous", Level, IsMax and " (Max)" or "")
    end
    
    Label:GetPropertyChangedSignal("Text"):Connect(Update)Update()
  end)
  
  _spawn(function()
    if _env.Loaded_AimBot then return end
    _env.Loaded_AimBot = true
    
    local old;
    old = hookmetamethod(game, "__namecall", function(self, ...)
      local Method = getnamecallmethod():lower()
      if Method == "fireserver" then
        local Remote = self.Name
        if Remote == "Server_Skills" and Module.AimBot then
          return Module:AimBot(old, self, ...)
        end
      end
      return old(self, ...)
    end)
  end)
  
  _spawn(function()
    if _env.Loaded_NPrf then return end
    _env.Loaded_NPrf = true
    
    RunService.Stepped:Connect(function()
      local Distance, Nearest = 1000, false;
      if _env.AimBotPlayers then
        for _,Char in ipairs(Characters:GetChildren()) do
          local PP = Char.PrimaryPart
          if Char ~= Player.Character and PP and Player:DistanceFromCharacter(PP.Position) < Distance then
            Distance, Nearest = Player:DistanceFromCharacter(PP.Position), PP
          end
        end
      end
      _env.NearestPlayer = Nearest
    end)
  end)
  
  _spawn(function()
    if _env.Loaded_NoStun then return end
    _env.Loaded_NoStun = true
    
    local UpdateStun = function(Char)
      Char:WaitForChild("Stun"):GetPropertyChangedSignal("Value"):Connect(function()
        if _env.NoStun then
          Char.Stun.Value = 0
        end
      end)
    end
    
    Player.CharacterAdded:Connect(UpdateStun)
    UpdateStun(Player.Character)
  end)
  
  Module.Items = (function()
    local Items = {}
    Items.Inventory = Player:WaitForChild("Items")
    Items.Folders = {}
    Items.Acessories = {"Nah, I'd Win.", "Sus Pals", "Noob Friend", "Pumpkin Head", "Moai Face", "Egg Doge", "Floppa Hat"}
    Items.Swords = {"Purple Katana", "Yellow Blade", "Popcat", "Pumpkin", "Floppa", "Portal", "Katana"}
    
    function Items:GetMaterial(MaName)
      return self.Folders.ItemStorage[MaName].Value
    end
    
    function Items:VerifySword(SwName)
      return self.Folders.Weapon[SwName].Value > 0
    end
    
    function Items:VerifyAccessory(AcName)
      return self.Folders.Accessory[AcName].Value > 0
    end
    
    function Items:VerifyFightStyle(FsName)
      return self.Folders.FightingStyle[FsName].Value == true
    end
    
    function Items:GetUnlocked()
      local Unlocked = {}
      for _,v in (self.Folders.Weapon:GetChildren()) do
        Unlocked[v.Name] = v.Value > 0 or false
      end
      for _,v in (self.Folders.Accessory:GetChildren()) do
        Unlocked[v.Name] = v.Value > 0 or false
      end
      return Unlocked
    end
    
    function Items:CanRerollAura()
      for _,Color in ipairs(self.Folders.AuraColor:GetChildren()) do
        if not Color.Value then
          return true
        end
      end
      return false
    end
    
    function Items:EquipSword()
      local Swords = self.Folders.Weapon
      for _,Sword in ipairs(self.Swords) do
        if Swords[Sword].Value > 0 then
          if PlayerData.SwordEquip.Value ~= Sword then
            OtherEvent.ItemEvents.UpdateInventory:InvokeServer("Weapon", { SelectedItem = Sword })
          end
          return
        end
      end
    end
    
    function Items:EquipAcessory()
      local Accessories = self.Folders.Accessory
      for _,Acessory in ipairs(self.Acessories) do
        if Accessories[Acessory].Value > 0 then
          if PlayerData.AccessoryEquip.Value ~= Acessory then
            OtherEvent.ItemEvents.UpdateInventory:InvokeServer("Accessory", { SelectedItem = Acessory })
          end
          return
        end
      end
    end
    
    for _,Folder in ipairs(Items.Inventory:GetChildren()) do
      Items.Folders[Folder.Name] = Folder
    end
    
    return Items
  end)()
  Module.Quests = (function()
    local Quests = {}
    Quests.QuestsList = {}
    Quests.QuestsNPCs = {}
    Quests.EnemyList = {}
    
    function Quests:UpdateQuestsList()
      table.clear(self.QuestsList)
      for Npc, Quest in pairs(MQuestSettings) do
        if QuestLocation:FindFirstChild(Npc) then
          _insert(self.QuestsList, {
            EnemyPos = EnemyLocation[Quest.Target].CFrame,
            QuestPos = QuestLocation[Npc].CFrame,
            SpecialQuest = Quest.Special_Quest,
            RaidBoss = Quest.Raid_Boss,
            Level = Quest.LevelNeed,
            Enemy = Quest.Target,
            NpcName = Npc
          })
        end
      end
      table.sort(self.QuestsList, function(a,b)return(a.Level>b.Level)end)
      for _,v in ipairs(self.QuestsList) do
        _insert(self.EnemyList, v.Enemy)
        self.QuestsNPCs[v.Enemy] = v.NpcName
      end
    end
    
    return Quests
  end)()
end

return Module
