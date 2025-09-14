local a=...
assert(type(a)=="table","package importer not found")
assert(type(a.Import)=="function","Import not found")

local b=a:Import"RobloxServices"
local c=a:Import"Connections"
local d=a:Import"Obfuscated"
local e=a:Import"Settings"

local f=(getgenv or getrenv or getfenv)()

local g=b.VirtualInputManager
local h=b.CollectionService
local i=b.ReplicatedStorage
local j=b.TeleportService
local k=b.TweenService
local l=b.RunService
local m=b.Players

local n=i:WaitForChild"Remotes"
local o=n:WaitForChild"Validator2"
local p=n:WaitForChild"CommF_"
local q=n:WaitForChild"CommE"

workspace:WaitForChild"ChestModels"
local s=workspace:WaitForChild"_WorldOrigin"
local t=workspace:WaitForChild"Characters"
local u=workspace:WaitForChild"SeaBeasts"
local v=workspace:WaitForChild"Enemies"
local w=workspace:WaitForChild"Boats"
local x=workspace:WaitForChild"Map"

local y=s:WaitForChild"EnemySpawns"
local z=s:WaitForChild"Locations"local _=

l.RenderStepped local _=
l.Heartbeat
local C=l.Stepped
local D=m.LocalPlayer

local E=D:WaitForChild"Data"
E:WaitForChild"Level"
E:WaitForChild"Fragments"
local H=E:WaitForChild"Beli"

local I=i:WaitForChild"Modules"
local J=I:WaitForChild"Net"

local K={"NULL"}

local L=string.upper(if identifyexecutor then identifyexecutor()else"NULL")
local M=table.find(K,L)~=nil

local N=(not M and hookmetamethod)or(function(...)return...end)


local P=sethiddenproperty
local Q=setsimulationradius local _=

setupvalue or(debug and debug.setupvalue)local _=
getupvalue or(debug and debug.getupvalue)

local T=i:FindFirstChild"PrivateServerOwnerId"
local U=if T then T.Value~=0 else true

local V=0 local W=function(

W)
if(tick()-V)>0 then
V=tick()+5

if Q then
pcall(Q,W)
end

if P then
pcall(P,D,"SimulationRadius",W)
end
end end local aa=function(


X, Y)
local Z={}

for _,aa in ipairs(X)do
Z[aa]=if type(Y)=="table"then{}else Y
end

return Z end local ab=function()



local X={}

local Y={}
local Z={}
local _={}
local ab={}

local ac=d.SafeObject
local ad=ac.Clone
local ae=aa(d.OriginalProperties,true)local af=function(

af)
return type(af)=="string"end


local ag
local ah

ag=N(game,"__index",function(ai,aj)
local ak=Z[ai]
if ak and af(aj)and not ae[aj]then
ai=ak
else
local al=_[ai]
if al and ab[aj]then
return ab[aj][ai]or ag(ai,aj)
end
end

local al=Y[ai]
if al and al[aj]~=nil then
return al[aj]
end

return ag(ai,aj)
end)

ah=N(game,"__namecall",function(ai,...)
if Z[ai]then
return ah(ac,...)
end
return ah(ai,...)
end)

function X.ProtectObject(ai)
assert(ai,`ProtectObject -> Instance expeted, got {typeof(ai)}`)

ai.Name=ac.Name
Z[ai]=ad(ac)
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

function X.SetCanTouchObjects(ai)
ab.CanTouch=ai
end

function X.SetCanCollideObjects(ai)
ab.CanCollide=ai
end

function X.ClearNoclipObjects()
table.clear(_)
for ai,aj in ab do
table.clear(aj)
end
end

function X.AddNoclipObject(ai)
_[ai]=true
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
if ag.Parent==t then
ag=m:GetPlayerFromCharacter(ag)
end

if tostring(ag.Team)=="Marines"and ag.Team==D.Team then
return false
elseif ag:HasTag(`Ally{D.Name}`)or D:HasTag(`Ally{ag.Name}`)then
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
local Y=X:FindFirstChild(if X.Parent==u then"Health"else"Humanoid")

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
return D:DistanceFromCharacter(al)end local X=function(


X, Y)
if Y then
return ak(Y)>0
elseif X then
local Z=aj[X]

if Z and Z.Parent==X then
return ak(Z)>0
else
return X.Parent==w
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

return _ end local _=function(






_)
d.LockedTool(_)

if _.Parent==D.Character then
return true
elseif _.Parent==D.Backpack then
D.Character.Humanoid:EquipTool(_)
return true
end

return false end local ap=function(


ap, aq)
if not X(D.Character)then
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
local as=D.Backpack:FindFirstChild(ap)

if as then
ae=as
_(as)
end

return nil
end

for as,at in D.Backpack:GetChildren()do
if at:IsA"Tool"and at.ToolTip==ap then
ae=at
_(at)
return nil
end
end end local aq=function()



if U or#m:GetPlayers()==1 then
j:Teleport(game.PlaceId,D)
else
j:TeleportToPlaceInstance(game.PlaceId,game.JobId,D)
end end


local ar={
Closest=nil,
Equipped=nil,

RealFruitsName=setmetatable({},ah()),
RealFruitsId=setmetatable({},ah()),

Enemies={},
Progress={},
Tools={}
}

local as={
Sea=table.find({2753915549,4442272183,7449423635},game.PlaceId)or 0,
SeasName={"Main","Dressrosa","Zou"},
MaxMastery=600,
MaxLevel=2750
}

as.StringVersion=d.GetGameVersion(Y)
as.NumberVersion=am(as.StringVersion)

do
if string.sub(as.StringVersion,1,1)~="v"then return D:Kick()end

local at=string.split(string.sub(as.StringVersion,2,-1),".")
local au=`{at[1]or 0}.`;

for av=2,#at do
au..=tostring(at[av]or 0)
end

as.NumberVersion=tonumber(au)or 0
end

local at={
IsAlive=X,
GameData=as,
Rejoin=aq,
HookManager=ac,
NewConnection=an,
CreateDictionary=aa,
DistanceFromCharacter=al
}

at.Rejoin=aq


do
local au={}local av=function(...)


table.insert(au,{...})end


av("Frags",{
{"Race Reroll",{"BlackbeardReward","Reroll","2"}};
{"Reset Stats",{"BlackbeardReward","Refund","2"}};
});

av("Fighting Style",{
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

av("Ability Teacher",{
{"Buy Geppo",{"BuyHaki","Geppo"}};
{"Buy Buso",{"BuyHaki","Buso"}};
{"Buy Soru",{"BuyHaki","Soru"}};
{"Buy Ken",{"KenTalk","Buy"}};
});

av("Sword",{
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

av("Gun",{
{"Buy Musket",{"BuyItem","Musket"}};
{"Buy Slingshot",{"BuyItem","Slingshot"}};
{"Buy Flintlock",{"BuyItem","Flintlock"}};
{"Buy Refined Slingshot",{"BuyItem","Refined Slingshot"}};
{"Buy Dual Flintlock",{"BuyItem","Dual Flintlock"}};
{"Buy Cannon",{"BuyItem","Cannon"}};
{"Buy Kabucha",{"BlackbeardReward","Slingshot","2"}};
});

av("Accessories",{
{"Buy Black Cape",{"BuyItem","Black Cape"}};
{"Buy Swordsman Hat",{"BuyItem","Swordsman Hat"}};
{"Buy Tomoe Ring",{"BuyItem","Tomoe Ring"}};
});

av("Race",{
{"Ghoul Race",{"Ectoplasm","Change",4}};
{"Cyborg Race",{"CyborgTrainer","Buy"}};
});

at.Shop=au;
end

function at:IsBlacklistedExecutor()
return M
end

do
local au="Fruit "
local av=10
local aw="Fruit [ ???-??? ]"
local ax="0"

local ay={}local az=function(

az, aA)
ay[string.format("rbxassetid://%s",tostring(az))]=string.format("Fruit [ %s-%s ]",aA,aA)end


do
az(15124425041,"Rocket")
az(15123685330,"Spin")
az(15123613404,"Blade")
az(15123689268,"Spring")
az(15123595806,"Bomb")
az(15123677932,"Smoke")
az(15124220207,"Spike")
az(121545956771325,"Flame")
az(15123673019,"Sand")
az(15123618591,"Dark")
az(77885466312115,"Eagle")
az(15112600534,"Diamond")
az(15123640714,"Light")
az(15123668008,"Rubber")
az(15123662036,"Ghost")
az(15123645682,"Magma")
az(15123606541,"Quake")
az(15123643097,"Love")
az(15123681598,"Spider")
az(116828771482820,"Creation")
az(15123679712,"Sound")
az(15123654553,"Phoenix")
az(15123656798,"Portal")
az(15123670514,"Rumble")
az(15123652069,"Pain")
az(15123587371,"Blizzard")
az(15123633312,"Gravity")
az(15123648309,"Mammoth")
az(15694681122,"T-Rex")
az(15123624401,"Dough")
az(15123675904,"Shadow")
az(10773719142,"Venom")
az(15123616275,"Control")
az(118054805452821,"Gas")
az(11911905519,"Spirit")
az(15123638064,"Leopard")
az(115276580506154,"Yeti")
az(15487764876,"Kitsune")
az(95749033139458,"Dragon East")
end

local aA=setmetatable({},ah())
local aB=setmetatable({},ah())

local aC={
Animation="Animation",
Fruit="MeshPart",
Idle="MeshPart"
}local aD=function(

aD)
return aD:IsA"MeshPart"and"MeshId"or"AnimationId"end local aE=function(


aE, aF, aG)
aA[aE]=aF
aB[aE]=aG end local aF=function(


aF)
local aG=aC[aF.Name]

if aG and aF:IsA(aG)then
local aH=aF[aD(aF)]
return ay[aH],aH
end end local aG=function(


aG, aH)
for aI,aJ in aG:GetChildren()do
local aK,aL=aF(aJ)
if aK then
aE(aG,aK,aL)
return aK,aL
end
end

local aI
local aJ
local aK=av

local aL=aH.ChildAdded:Connect(function(aL)
if not aI then
aI,aJ=aF(aL)
end
end)

while not aI and aK>0 do
aK-=task.wait()
end

aL:Disconnect()

if aI then
aE(aG,aI,aJ)
return aI
end end


function at.GetRealFruitName(aH,aI)
if aH.Name~=au then
return aH.Name
end

if aA[aH]then
return aI and aB[aH]or aA[aH]
end

aA[aH]=aw
aB[aH]=ax

local aJ=aH:WaitForChild("Fruit",math.huge)
aG(aH,aJ)

return(aI and aB[aH]or aA[aH])or ax
end
end

at.CollectionService=(function()
local au={}

local av=ao"_ChestTagged"
local aw=ao"BerryBush"

local ax,ay=0;
local az,aA=0;

au.Chests=av
au.Berries=aw local aB=function(

aB)
return aB and not aB:GetAttribute"IsDisabled"end local aC=function(


aC)
return aC and next(aC:GetAttributes())~=nil end local aD=function(


aD)
if aB(ay)and(not aD or ay:IsDescendantOf(aD))then
return ay
elseif(tick()-ax)<1 then
return nil
end

local aE,aF=math.huge

for aG=1,#av do
local aH=av[aG]
if aB(aH)and(not aD or ay:IsDescendantOf(aD))then
local aI=D:DistanceFromCharacter(aH:GetPivot().Position)

if aI<aE then
aE,aF=aI,aH
end
end
end

ax=tick()
ay=aF

return aF end local aE=function()



if aC(aA)and aA:IsDescendantOf(x)then
return aA
elseif(tick()-az)<1 then
return nil
end

local aE,aF=math.huge

for aG=1,#aw do
local aH=aw[aG]

if aC(aH)then
local aI=D:DistanceFromCharacter(aH.Parent:GetPivot().Position)

if aI<aE then
aE,aF=aI,aH
end
end
end

az=tick()
aA=aF

return aF end


at.GetClosestChest=aD;
at.GetClosestBerry=aE;
at.HasBerries=aC;

return au
end)()

at.Services=(function()
local au={}

au.Network=(function()
local av={}

local aw=p.InvokeServer;

local ax="RF/%s";
local ay="RE/%s";

local az={};local aA=function(

aA, aB, aC)
local aD=J:WaitForChild(aA:format(aC))

if not aD then
return error(`Cannot found {aC}: {aB} in Network`,2)
end

return aD end


function av.InvokeCommF(...)
return aw(p,...)
end

function av.TravelTo(aB)
return av.InvokeCommF(`Travel{as.SeasName[aB]}`)
end

function av.GetProgress(...)
local aB=...

if az[aB]and az[aB].Debounce<0 then
return unpack(az[aB].Args)
end

az[aB]={
Debounce=tick()+2.5,
Args=table.pack(av.InvokeCommF(...))
}

return unpack(az[aB].Args)
end

function av:RemoteFunction(aB)
return aA(ax,"RemoteFunction",aB)
end

function av:RemoteEvent(aB)
return aA(ay,"RemoteEvent",aB)
end

return av
end)()

au.GoodSignal=(function()
local av={}
local aw={}

aw.__index=aw
av.__index=av

do
function aw:Disconnect()
if not self.Connected then
return nil
end

local ax=table.find(self.Signal,self)

if ax then
table.remove(self.Signal,ax)
end

self.Function=nil
self.Connected=false
end

function aw:Fire(...)
if not self.Function then
return nil
end

task.spawn(self.Function,...)
end

function aw.new()
return setmetatable({
Connected=true
},aw)
end

setmetatable(aw,{
__index=function(ax,ay)
error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(ay)),2)
end,
__newindex=function(ax,ay,az)
error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(ay)),2)
end
})
end

function av:Connect(ax)
assert(type(ax)=="function","function expected, got "..type(ax))

local ay=aw.new()
ay.Function=ax
ay.Signal=self

table.insert(self.Connections,ay)
return ay
end

function av:Once(ax)
local ay;
ay=self:Connect(function(...)
ax(...)
ay:Disconnect()
end)
return ay
end

function av:Wait()
local ax=coroutine.running()
local ay;ay=self:Connect(function(...)
ay:Disconnect()
task.spawn(ax,...)
end)
return coroutine.yield()
end

function av:Fire(...)
for ax,ay in ipairs(self.Connections)do
if ay.Connected then
ay:Fire(...)
end
end
end

function av.new()
return setmetatable({
Connections={}
},av)
end

av.Signals={
BvChanged=av.new(),
Notify=av.new(),
Error=av.new(),
}

setmetatable(av,{
__index=function(ax,ay)
error(`Attempt to get Signal::{tostring(ay)} (not a valid member)`,2)
end,
__newindex=function(ax,ay,az)
error(`Attempt to set Signal::{tostring(ay)} (not a valid member)`,2)
end
})

return av
end)()

au.PlayerManager=(function()
local av={}

local aw=Vector3.zero local ax=function()


local ax=D.Character
return X(ax)and ax.Humanoid.RootPart end


function av:GetRootPartPosition()
local ay=ax()

if ay then
aw=ay.Position
end

return aw
end

an(D.CharacterAdded,function(...)PlayerCharacter=...end)
an(D.CharacterRemoving,function()PlayerCharacter=nil end)

return av
end)()

au.Hooking=(function()
local av={}

aa({"Z","X","C","V","F"},true)local _=

f.rz_EnabledOptions;
local ay;

local az=0;
local aA=0;local aB=function(

aB)
if(tick()-az)<=2 or f[aB]then
return ay
end end local aC=function()



local aC=if e.SmoothMode then 0.5 else 0.25
local aD=tick()

if ay and not ay.Parent then
ay.Parent=nil
end

if(aD-az)<=2 or(aD-aA)<=aC then
return nil
else
aA=aD
end

local aE=D.Character
local aF=X(aE)and aE:FindFirstChildOfClass"Tool"

if aF and aF.ToolTip and aE.Humanoid.RootPart then
local aG=if aF.ToolTip=="Gun"then 250 else 900

local aH=aE.Humanoid.RootPart.Position
local aI=t:GetChildren()
local aJ=v:GetChildren()

for aK=1,#aI do
local aL=aI[aK]
if aL==aE or not ag(aL)then continue end
local aM=X(aL)and aL.Humanoid.RootPart

if aM then
local aN=(aM.Position-aH).Magnitude

if aN<=aG then
ay,aG=Hitbox,aN
end
end
end

for aK=1,(if e.NoAimMobs then 0 else#aJ)do
local aL=aJ[aK]
local aM=X(aL)and aL.Humanoid.RootPart

if aM then
local aN=(aM.Position-aH).Magnitude

if aN<=aG then
ay,aG=Hitbox,aN
end
end
end
end end local aD=function()



if f.rz_enabled_bypass or not ad.WALKSPEED_BYPASS_ENABLED then return end
f.rz_enabled_bypass=true

local aD=ac.HookProperty

local aE;
aE=N(D,"__newindex",function(aF,aG,aH)
if aG=="WalkSpeed"and aF.Name=="Humanoid"then
aD(aF,aG,aH)
return aE(aF,"WalkSpeed",f.WalkSpeedBypass or aH)
else
return aE(aF,aG,aH)
end
end)end local aE=function()



if not ad.SILENT_AIM_ENABLED then return end
if f.rz_original_namecall then return end

table.insert(c,C:Connect(aC))

local aE={
["RE/ShootGunEvent"]=function(...)
local aE,aF=...

if typeof(aE)=="Vector3"and type(aF)=="table"and#aF~=0 then
local aG=aB"AimBot_Gun"

if aG then
return aG.Position,{aG}
end
end

return...
end,
["RemoteEvent"]=function(...)
local aE,aF=...

if typeof(aE)=="Vector3"and not aF then
local aG=aB"AimBot_Skills"

if aG then
return aG.Position
end
elseif aE=="TAP"and typeof(aF)=="Vector3"then
local aG=aB"AimBot_Tap"

if aG then
return"TAP",aG.Position
end
end

return...
end
}

local aF=ac.OriginalIndex
local aG=string.lower

local aH;
aH=N(game,"__namecall",function(aI,...)
local aJ=aE[aF(aI,"Name")]

if aJ and aG(getnamecallmethod())=="fireserver"then
return aH(aI,aJ(...))
else
return aH(aI,...)
end
end)

f.rz_original_namecall=aH end


at.HookGame=function()
task.delay(1,aD)
task.delay(1,aE)
end

function av:SetAimTarget(aF)
ay,az=aF,tick()
end

return av
end)()

au.Inventory=(function()
local av={
Unlocked=ai(false),
Mastery=ai(0),
Count=ai(0),
MasteryRequirements={},

Loaded=false,
Items={}
}

local aw=au.GoodSignal.Signals.Notify local ax=function(

ax, ay)
if type(ay)~="table"then return end

local az=ay.Name
ax.Items[az]=ay

if not ax.Unlocked[az]then ax.Unlocked[az]=true end
if ay.Count then ax.Count[az]=ay.Count end
if ay.Mastery then ax.Mastery[az]=ay.Mastery end
if ay.MasteryRequirements then ax.MasteryRequirements[az]=ay.MasteryRequirements end end local ay=function(


ay, az)
if type(az)=="string"then
ay.MasteryRequirements[az]=nil
ay.Unlocked[az]=nil
ay.Mastery[az]=nil
ay.Count[az]=nil
ay.Items[az]=nil
end end


local az={
["ItemChanged"]=function(...)ax(av,...)end;
["ItemAdded"]=function(...)ax(av,...)end;
["ItemRemoved"]=function(...)ay(av,...)end;
["Notify"]=function(...)aw:Fire(...)end;
}local aA=function(

aA, ...)
if aA and az[aA]then
az[aA](...)
end end local aB=function()



return au.Network.InvokeCommF"getInventory"end


task.defer(function()
an(q.OnClientEvent,aA)
local aC=aB();

while type(aC)~="table"and task.wait(1)do
aC=aB()
end

for aD=1,#aC do
ax(av,aC[aD])
end

av.Loaded=true
end)

return av
end)()

au.Enemies=(function()
local av=aa({
"__CakePrince","__PirateRaid","__TyrantSkies","__Bones","__Elite","__Others","__Ectoplasm"
},{})

local aw={
["Deandre"]="Elite",["Diablo"]="Elite",["Urban"]="Elite",

["Reborn Skeleton"]="Bones",["Living Zombie"]="Bones",
["Demonic Soul"]="Bones",["Posessed Mummy"]="Bones",

["Head Baker"]="CakePrince",["Baking Staff"]="CakePrince",
["Cake Guard"]="CakePrince",["Cookie Crafter"]="CakePrince",

["Sun-kissed Warrior"]="TyrantSkies",["Skull Slayer"]="TyrantSkies",
["Isle Champion"]="TyrantSkies",["Serpent Hunter"]="TyrantSkies",

["Ship Deckhand"]="Ectoplasm",["Ship Engineer"]="Ectoplasm",
["Ship Officer"]="Ectoplasm",["Ship Steward"]="Ectoplasm",
}local _=

at.SpawnLocations
local ay=ar.Enemies local _=

ac.UnprotectObject local _=
ac.ProtectObject local _=
ac.OriginalIndex

local aC=d.GetBringAttachment()

local aD={}
local aE={}

local aF={}
local aG={}

av.SpawnLocations=aF
av.EnemyLocations=aG

av.PirateRaid=0

do
local aH=aa({"Ice Admiral","rip_indra"},true)
local aI={}local aJ=function(

aJ, aK, aL, aM)
aI[aJ]={
BossSpawn=CFrame.new(unpack(aK)),
LevelReq=aM,
Quest=aL
}end


function av.IsABoss(aK)
return aI[aK]~=nil
end

function av.EnemyIsBoss(aK)
return(aK:GetAttribute"IsBoss"or aK:GetAttribute"RaidBoss")and not aH[aK.Name]
end

function av:GetBosses()
return aI
end


aJ("The Gorilla King",{-1128,6,-451},{"JungleQuest",CFrame.new(-1598,37,153)},20)
aJ("Chef",{-1131,14,4080},{"BuggyQuest1",CFrame.new(-1140,4,3829)},55)
aJ("Yeti",{1185,106,-1518},{"SnowQuest",CFrame.new(1385,87,-1298)},105)
aJ("Vice Admiral",{-4807,21,4360},{"MarineQuest2",CFrame.new(-5035,29,4326),2},130)
aJ("Warden",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692),1},220)
aJ("Chief Warden",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692),2},230)
aJ("Swan",{5230,4,749},{"ImpelQuest",CFrame.new(5191,4,692)},240)
aJ("Magma Admiral",{-5694,18,8735},{"MagmaQuest",CFrame.new(-5319,12,8515)},350)
aJ("Fishman Lord",{61350,31,1095},{"FishmanQuest",CFrame.new(61122,18,1567)},425)
aJ("Wysper",{-7927,5551,-637},{"SkyExp1Quest",CFrame.new(-7861,5545,-381)},500)
aJ("Thunder God",{-7751,5607,-2315},{"SkyExp2Quest",CFrame.new(-7903,5636,-1412)},575)
aJ("Cyborg",{6138,10,3939},{"FountainQuest",CFrame.new(5258,39,4052)},675)


aJ("Diamond",{-1569,199,-31},{"Area1Quest",CFrame.new(-427,73,1835)},750)
aJ("Jeremy",{2316,449,787},{"Area2Quest",CFrame.new(635,73,919)},850)
aJ("Orbitus",{-2086,73,-4208},{"MarineQuest3",CFrame.new(-2441,73,-3219)},925)
aJ("Smoke Admiral",{-5078,24,-5352},{"IceSideQuest",CFrame.new(-6061,16,-4904)},1150)
aJ("Awakened Ice Admiral",{6473,297,-6944},{"FrostQuest",CFrame.new(5668,28,-6484)},1400)
aJ("Tide Keeper",{-3711,77,-11469},{"ForgottenQuest",CFrame.new(-3056,240,-10145)},1475)


aJ("Stone",{-1049,40,6791},{"PiratePortQuest",CFrame.new(-449,109,5950)},1550)
aJ("Hydra Leader",{5836,1019,-83},{"VenomCrewQuest",CFrame.new(5214,1004,761)},1675)
aJ("Kilo Admiral",{2904,509,-7349},{"MarineTreeIsland",CFrame.new(2485,74,-6788)},1750)
aJ("Captain Elephant",{-13393,319,-8423},{"DeepForestIsland",CFrame.new(-13233,332,-7626)},1875)
aJ("Beautiful Pirate",{5370,22,-89},{"DeepForestIsland2",CFrame.new(-12682,391,-9901)},1950)
aJ("Cake Queen",{-710,382,-11150},{"IceCreamIslandQuest",CFrame.new(-818,66,-10964)},2175)

table.freeze(aI)
end

do
local aH="Island "local aI=function(

aI)
if string.sub(aI.Name,1,#aH)==aH then
CurrentRaidIsland=nil
end end local aJ=function(


aJ)
local aK=af(aJ.Name)
aG[aK]=aG[aK]or{}

local aL=aJ.CFrame+Vector3.one*25
aF[aK]=aJ

if not table.find(aG[aK],aL)then
table.insert(aG[aK],aL)
end end


for aK,aL in y:GetChildren()do aJ(aL)end
an(y.ChildAdded,aJ)
an(z.ChildAdded,aI)
end local aI=function(





aI, aJ, aK, aL, aM)
while aJ.Parent==v and X(_,aL)and aM.Parent==aJ do
local aN=aD[aK].Position

if(aN-aM.Position).Magnitude<=e.BringDistance then
if aI.Position~=aN then
aI.Position=aN
end
else
break
end

task.wait(0.25)
end end local aJ=function(


aJ)
if aE[aJ]then return end
aE[aJ]=true

local aK=aJ.Name
local aL=aJ.Humanoid
local aM=aL.RootPart

local aN=aC:Clone()
local aO=aN.AlignPosition

aN.Parent=aM
aI(aO,aJ,aK,aL,aM)

aE[aJ]=nil

if aN then
aN:Destroy()
end end


function av.GetEnemy(aK)
if type(aK)=="table"then
return av:GetClosest(aK)
else
return av:GetEnemyByTag(aK)
end
end

function av.IsSpawned(aK)
local aL=aF[aK]

if aL and aL.Parent==y then
return aL:GetAttribute"Active"
else
return av:GetEnemyByTag(aK)~=nil
end
end

function av:GetMobsName(aK)
local aL={}
for aM,aN in aw do
if aN==aK then
table.insert(aL,aM)
end
end
return aL
end

function av.BringMobs(aK,aL,aM)
local aN=X(aK)and aK.Humanoid.RootPart
if not aN then return end

local aO=aK.Name
W(9e9)

if not e.BringMobs then
if not aD[aO]then
aD[aO]=aN.CFrame
end

aN.CFrame=aD[aO]
return nil
end

local aP=au.PlayerManager:GetRootPartPosition()

local aQ=aL or aN.CFrame
local aR=aM or e.BringDistance

if not aD[aO]or(aQ.Position-aD[aO].Position).Magnitude>25 then
aD[aO]=aQ
end

for aS,aT in av:GetTagged(aO)do
if not aT:FindFirstChild"CharacterReady"then continue end
if aT.Parent~=v or aT.Name~=aO then continue end

local aU=X(aT)and aT.Humanoid.RootPart
if not aU then continue end

if(aP-aU.Position).Magnitude<aR then
task.spawn(aJ,aT)
end
end
end

function av:GetTagged(aK)
return self[`__{aK}`]or self.__Others[aK]
end

function av:GetEnemyByTag(aK)
local aL=ay[aK]

if aL and aL.Parent~=nil and X(aL)then
return aL
end

local aM=self:GetTagged(aK)
if not aM then return end

for aN=1,#aM do
if X(aM[aN])then
return aM[aN]
end
end
end

function av:GetClosest(aK)
local aL=table.concat(aK,"_")
local aM=ay[aL]

if aM and aM.Parent~=nil and X(aM)then
return aM
end

local aN,aO=math.huge

for aP=1,#aK do
local aQ=self:GetClosestByTag(aK[aP])
local aR=X(aQ)and aQ.Humanoid.RootPart
local aS=aR and D:DistanceFromCharacter(aR.Position)

if aR and aS<=aN then
aN,aO=aS,aQ
end
end

if aO then
ay[aL]=aO
return aO
end
end

function av:GetClosestByTag(aK)
local aL=ay[aK]

if aL and aL.Parent~=nil and X(aL)then
return aL
end

local aM=self:GetTagged(aK)

if aM and#aM>0 then
local aN=au.PlayerManager:GetRootPartPosition()
local aO,aP=math.huge

for aQ=1,#aM do
local aR=aM[aQ]
local aS=X(aR)and aR.Humanoid.RootPart
if not aS then continue end

local aT=(aN-aS.Position).Magnitude

if aT<=50 then
ay[aK]=aR
return aR
elseif aT<=aO then
aO,aP=aT,aR
end
end

if aP then
ay[aK]=aP
return aP
end
end
end

do
local aK=Vector3.new(-5556,314,-2988)
local aL=av.__Others
local aM=as.Sea local aN=function(

aN, aO)
if table.find(aN,aO)then return end

local aP=aO:WaitForChild"Humanoid"

if aP and aP.Health>0 then
table.insert(aN,aO)
aP.Died:Once(function()
table.remove(aN,table.find(aN,aO))
end)
end end local aO=function(


aO)
if aO.Name=="rip_indra True Form"or aO.Name=="Blank Buddy"then return end

local aP=aO:WaitForChild("Humanoid",600)
if not aP or aP.Health<=0 then return end

local aQ=aO:WaitForChild"HumanoidRootPart"

if aQ and(aQ.Position-aK).Magnitude<=750 then
task.spawn(aN,av.__PirateRaid,aO)
av.PirateRaid=tick()
end end local aP=function(


aP)
local aQ=aP.Name
local aR=`__{aQ}`

aL[aQ]=aL[aQ]or{}
task.spawn(aN,aL[aQ],aP)

if aM==3 then
task.spawn(aO,aP)
end

if av[aR]then
task.spawn(aN,av[aR],aP)
elseif aw[aQ]then
task.spawn(aN,av[`__{aw[aQ]}`],aP)
end end


for aQ,aR in h:GetTagged"BasicMob"do aP(aR)end
table.insert(c,h:GetInstanceAddedSignal"BasicMob":Connect(aP))
end

return av
end)()

au.ToolService=(function()
local av={}

local aw=au.Network.InvokeCommF
local ay=ar.Tools
local az=25000 local aA=function(

aA)
local aB=D.Character:FindFirstChildOfClass"Tool"

if aB and aB.ToolTip==aA then
return aB
end

for aC,aD in D.Backpack:GetChildren()do
if aD:IsA"Tool"and aD.ToolTip==aA then
return aD
end
end end local aB=function()



if H.Value<az then return end

aw("BuyHaki","Buso")end local aC=function(


aC, aD)
return aC.ToolTip=="JobTool"and aC:GetAttribute"JobId"==aD end local aD=function(


aD, aE)
local aF=D.Character
if not X(aF)then return end

local aG=if aE then`toolTip_{aD}`else aD
local aH=ay[aG]

if aH and(aH.Parent==aF or aH.Parent==D.Backpack)then
return aH
end

local aI=if aE then aA(aD)else(aF:FindFirstChild(aD)or D.Backpack:FindFirstChild(aD))

if aI then
ay[aG]=aI
return aI
end end


function av.GetToolMastery(aE,...)
local aF=aD(aE,...)
return aF and aF:GetAttribute"Level"or 0
end

function av.EquipJobTool(aE)
local aF=D.Character
if not X(aF)then return end

local aG=aF:FindFirstChildOfClass"Tool"

if aG and aC(aG,aE)then
return aG
end

for aH,aI in D.Backpack:GetChildren()do
if aI:IsA"Tool"and aC(aI,aE)then
_(aI)
return aI
end
end
end

function av.VerifyTool(aE,...)
return aD(aE,...)~=nil
end

function av.EnableBuso()
local aE=D.Character
if X(aE)and not aE:FindFirstChild"HasBuso"then
return if aE:HasTag"Buso"then aw"Buso"else aB()
end
end

av.EquipTool=ap

return av
end)()

au.FastAttack=(function()
local av={}

local aw={
["Blox Fruit"]=35,
["Melee"]=40,
["Sword"]=40,
["Gun"]=300,
}

local ay={
["Skull Guitar"]="TAP",
["Bazooka"]="Position",
["Cannon"]="Position",
["Dragonstorm"]="Overheat"
}

local az=aa({"Light-Light","Ice-Ice"},true)

local aA=au.Network

local aB=d.SendLeftClickRemote
local aC=d.CheckAttackDebounce
local aD=d.GetPartBoundsInBox
local aE=d.SendHitsToServer
local aF=d.PlayHitAnimation
local aG=d.SetHitsCooldown
local aH=d.IsAttackWeapon
local aI=d.NewDebounce
local aJ=d.GetMaxHits
local aK=d.CheckStun

local aL=d.CanGetGunValidator
local aM=d.GetGunValidator

local aN=aA:RemoteEvent"ShootGunEvent"

local aO=0.4
local aP=0
local aQ=4
local aR=0
local aS=0

d.SetRigisterAttackEvent(aA:RemoteEvent"RegisterAttack")
d.SetRigisterHitEvent(aA:RemoteEvent"RegisterHit")local aT=function(

aT, aU, aV)
local aW=aJ()
local aX={}
local aY={}




for aZ,a_ in aV do
local a0=a_.Parent
if a0.Parent.Parent~=workspace or not X(a0)then continue end
if a0.Parent==t and(a0==D.Character or not ag(a0))then continue end

if not aY[a0]then
table.insert(aX,{a0,a_})
aY[a0]=true
end

if#aX>=aW then
break
end
end

if#aX>0 then
aF(aT)
aG(aU)
aE(aX)
end end local aU=function()



if aR>=aQ or(tick()-aP)>=aO then
aR=0
end

aP=tick()
aR+=1
return aR end local aV=function(


aV)
local aW=aV.Parent
local aX=aW.Parent.Parent

if aX~=workspace then
aX=aX.Parent
aW=aW.Parent
end

if aX==workspace and X(aW)then
return true
end

return false end local aW=function(


aW, aX)
local aY=D.Character

for aZ,a_ in aW do
if a_:IsDescendantOf(aY)then continue end
if not aV(a_)then continue end

local a0=au.PlayerManager:GetRootPartPosition()
local a1=(a_.Position-a0).Unit

aB(aX,a1,aU())
return nil
end end


function av:ShootInTarget(aX)
if(tick()-aS)<0 then return end

local aY=X(D.Character)and D.Character:FindFirstChildOfClass"Tool"
if not aY or aY.ToolTip~="Gun"then return end

local aZ=aY:FindFirstChild"Cooldown"
if not aZ then return end

if not aL then
return nil
end

local a_=ay[aY.Name]

if a_=="Position"or a_=="TAP"and aY:FindFirstChild"RemoteEvent"then
aS=tick()+aZ.Value

aY:SetAttribute("LocalTotalShots",(aY:GetAttribute"LocalTotalShots"or 0)+1)
o:FireServer(aM())

if a_=="TAP"then
aY.RemoteEvent:FireServer("TAP",aX)
else
aN:FireServer(aX)
end
end
end

an(C,function()
local aX=D.Character
if not X(aX)then return end

local aY=aX.Humanoid
local aZ=aY.RootPart

if not aZ then return end

local a_=aX:FindFirstChildOfClass"Tool"

if not a_ or not aH(a_)then
return nil
end

if aC(a_)and aK(a_)then
local a0=a_.ToolTip
local a1=aI(a_)

local a2=aD(a_,aZ.CFrame,aw[a0]*2)
if#a2==0 then return end

if a0=="Blox Fruit"and not az[a_.Name]then
local a3=a_:FindFirstChild"LeftClickRemote"

if a3 then
aW(a2,a3)
end
elseif a0=="Gun"then
if SUCCESS_SHOOT and SHOOT_FUNCTION and(e.AutoShoot or e.dStormSea)then

end
elseif e.AutoAttack then
aT(a_,a1,a2)
end
end
end)

return av
end)()

return au
end)()

local au=0
local av={}

function at.DisableCanTouch()
au=tick()
end

function at.RemoveBasePartsCollision(aw)
local ay=aw:GetDescendants()

for az=1,#ay do
local aA=ay[az]
if aA:IsA"BasePart"and aA.CanCollide then
aA.CanCollide=false
end
end
end

local aw=at.Services.Inventory.MasteryRequirements

function at.UseSkills(ay,az)
if al(ay)>=60 then return end

local aA=D.Character and D.Character:FindFirstChildOfClass"Tool"

if aA then
local aB=aA:GetAttribute"Level"or 0
local aC=aw[aA.Name]

if aC==nil and aA:FindFirstChild"Data"then
local aD,aE=pcall(require,aA.Data)

if aD and type(aE)=="table"then
aw[aA.Name]=aE.Lvl or false
else
aw[aA.Name]=false
end
end

for aD,aE in az do
if not aE then continue end
if aC and(not aC[aD]or aB<aC[aD])then continue end

local aF=av[aD]

if aE and(tick()-(aF or 0))>=0 then
g:SendKeyEvent(true,aD,false,game)
g:SendKeyEvent(false,aD,false,game)
av[aD]=tick()+ad.SKILL_COOLDOWN
end
end
end
end

at.TweenBodyVelocity=(function()
local ay=ac.ClearNoclipObjects
local az=ac.AddNoclipObject
local aA=ac.UnprotectObject
local aB=ac.ProtectObject
local aC=ac.OriginalIndex

local aD=at.Services.GoodSignal.Signals.BvChanged

local aE=Instance.new"BodyVelocity"
aE.Velocity=Vector3.zero
aE.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
aE.P=1000

local aF=f.tween_bodyvelocity

if aF then
aA(aF)
aF.Parent=nil
aF:Destroy()
end

aB(aE)
f.tween_bodyvelocity=aE

local aG,aH=game.IsA,game.FindFirstChild
local aI=false

local aJ,aK,aL={},{},{}do
ac.SetCanCollideObjects(aK)
ac.SetCanTouchObjects(aL)local aM=function(

aM)
if aM~=aE and aG(aM,"BasePart")and(aM.CanCollide or aM.CanTouch)then
table.insert(aJ,aM)
az(aM)

if aC(aM,"CanCollide")then aK[aM]=true end
if aC(aM,"CanTouch")then aL[aM]=true end
end end local aN=function(


aN)
local aO=table.find(aJ,aN)

if aO then
table.remove(aJ,aO)
end end local aO=function(


aO)
if not aO then return end
table.clear(aJ)

for aP,aQ in aO:GetDescendants()do aM(aQ)end
aO.DescendantAdded:Connect(aM)
aO.DescendantRemoving:Connect(aN)

aO:WaitForChild("Humanoid",9e9).Died:Wait()
table.clear(aJ)
ay()end


an(D.CharacterAdded,aO)
task.spawn(aO,D.Character)
end local aM=function(

aM)
if not aI and f.OnFarm then
aI=true
end

if f.OnFarm and not D:HasTag"Teleporting"then
D:AddTag"Teleporting"
aI=true
elseif aI and not f.OnFarm and D:HasTag"Teleporting"then
D:RemoveTag"Teleporting"
aI=false
end

if f.OnFarm then
for aN=1,#aJ do
local aO=aJ[aN]
local aP=if(tick()-au)<=1 then false else true

if aL[aO]and aO.CanTouch~=aP then
aO.CanTouch=aP
end
if aK[aO]and aO.CanCollide then
aO.CanCollide=false
end
end
elseif aM.PrimaryPart and(not aM.PrimaryPart.CanCollide or not aM.PrimaryPart.CanTouch)then
for aN=1,#aJ do
local aO=aJ[aN]

if aK[aO]then
aO.CanCollide=true
end
if aL[aO]then
aO.CanTouch=true
end
end
end end local aN=function(


aN)
local aO=aH(aN,"UpperTorso")
local aP=aH(aN,"Humanoid")
local aQ=f.tween_bodyvelocity

local aR=if f.OnFarm and aO and aP and aP.Health>0 then aO else nil

if aC(aQ,"Parent")~=aR then
aQ.Parent=aR
aD:Fire(aR)
end

local aS=aC(aQ,"Velocity")

if aS~=Vector3.zero and(not aP or not aP.SeatPart or not f.OnFarm)then
aQ.Velocity=Vector3.zero
end end


an(C,function()
local aO=D.Character
if X(aO)then
aN(aO)
aM(aO)
end
end)

return aE
end)()

at.RunModules=(function()
local ay={}local az=function(

az, aA)
ay[az]=aA end


az("InitializeQuests",function(aA,aB)
local aC=aB.GetQuestTasks
local aD=aB.QuestsLookup
local aE=aB.Quests

local aF=({{0,700},{700,1500},{1500,math.huge}})[as.Sea]
local aG=aa({"BartiloQuest","MarineQuest","CitizenQuest"},true)

for aH,aI in aA do
if aG[aH]then continue end

for aJ,aK in aI do
local aL=aK.LevelReq

if aL>=aF[1]and aL<aF[2]then
local aM,aN=aC(aK)
local aO=aM[1]

local aP={
QuestName=aH,
QuestIndex=aJ,
Quest={
EnemyLocations=aN,
LevelReq=aL,
Targets=aM
}
}

aD[aO]=aP
table.insert(aE,aP)
end
end
end

table.sort(aE,function(aH,aI)
return aH.Quest.LevelReq<aI.Quest.LevelReq
end)
end)

az("FarmQueue",function(aA)local aB=function()

for aB,aC in aA do
e.RunningOption=aC.Name
local aD=aC.Function()
if not aD then continue end

if type(aD)=="string"then
e.RunningMethod=aD
end

return true
end

e.RunningOption,e.RunningMethod=nil,nil end


while task.wait(e.SmoothMode and 0.25 or 0)do
if f.teleporting then
f.OnFarm=true
elseif e.IgnoreErrors then
local aC,aD=pcall(aB)

if not aC then
warn(`redz Hub Error in {e.RunningOption} -> {aD}`)
end

f.OnFarm=(not aC and f.OnFarm)or aD
else
f.OnFarm=if aB()then true else false
end
end
end)

az("Translator",function(aA,aB)
local aC=aA.MakeTab


local aE={}
local aF={}local aG=function(

aG)
local aH=aB[aG.Title]

if aH then
if aH[1]~=nil then
aG:SetTitle(aH[1])
end

if aH[2]~=nil then
aG:SetDesc(aH[2])
end
end

return aG end


function aF:AddSection(aH)
return aG(aE["AddSection"](self,aH))
end

function aF:AddParagraph(aH,aI)
return aG(aE["AddParagraph"](self,aH,aI))
end

function aF:AddToggle(aH)
return aG(aE["AddToggle"](self,aH))
end

function aF:AddDropdown(aH)
return aG(aE["AddDropdown"](self,aH))
end

function aF:AddSlider(aH)
return aG(aE["AddSlider"](self,aH))
end

function aF:AddButton(aH)
return aG(aE["AddButton"](self,aH))
end

function aF:AddTextBox(aH)
return aG(aE["AddTextBox"](self,aH))
end

aA.MakeTab=function(aH,aI)
local aJ=aI[1]or aI.Name or aI.Title

if aB[aJ]then
aI[1]=aB[aJ]
end

local aK=aC(aH,aI)

for aL,aM in aF do
aE[aL]=aK[aL]
aK[aL]=aM
end

return aK
end
end)

az("OptionsPlugin",function(aA,aB)
local aC={}

function aC.Toggle(aD,aE,aF)
local aG=aD:AddToggle{
Name=aE[1],
Default=if type(aE[2])~="string"then aE[2]else nil,
Description=aE[if type(aE[2])=="string"then 2 else 3],
Callback=function(aG)aA[aF]=aG end,
Flag=aF
}

aB[aF]=aG
return aG
end

return aC
end)

az("TweenManager",function()
local aA={}
aA.__index=aA

local aB={}
local aC=Enum.EasingStyle.Linear

function aA.new(aD,aE,aF,aG)
local aH=setmetatable({},aA)

aH.tween=k:Create(aD,TweenInfo.new(aE,aC),{[aF]=aG})
aH.tween:Play()
aH.value=aG
aH.object=aD

if aB[aD]then
aB[aD]:destroy()
end

aB[aD]=aH
return aH
end

function aA:destroy()
self.tween:Pause()
self.tween:Destroy()

aB[self.object]=nil
setmetatable(self,nil)
end

function aA:stopTween(aD)
if aD and aB[aD]then
aB[aD]:destroy()
end
end

return aA
end)

return ay
end)()

task.defer(function()
local ay={3095250,17884881}
local az=aa({6079649301,4985647299},true)

local aA=D





local aC={"GANKS","GANKSVolley","AAIM"}

local aD=as.MaxLevel
local aE=as.Sea
local aF=3025E4

local aG={
(function(aG)
if table.find(ay,aG.UserId)then
return true
elseif az[aG.UserId]then
return true
end
end),
(function(aG,aH)
if aH.Level.Value>aD then
return true
elseif aH.Beli.Value>=3e8 and aH.Level.Value<=700 then
return true
end
end),
(function(aG,aH)
if aE>1 and aH.Level.Value<700 then
return true
elseif aE>2 and aH.Level.Value<1500 then
return true
end
end),
(function(aG)
for aH=1,#aC do
if aG:GetAttribute(aC[aH])then
return true
end
end
end),
(function(aG)
local aH=aG:WaitForChild"leaderstats":WaitForChild"Bounty/Honor"

if aH.Value>aF or aH.Value<0 then
return true
end
end)
}local aH=function(

aH)
at.RejoinBlocked=true
return aA:Kick(`{aH.DisplayName}/@{aH.Name} maybe it's a blox fruits admin`)end local aI=function(


aI)
if aI==aA then return end

local aJ=aI:WaitForChild("Data",30)

if aJ then
aJ:WaitForChild("Level",10)
aJ:WaitForChild("Beli",10)

for aK=1,#aG do
local aL,aM=pcall(aG[aK],aI,aJ)
if not aL then
warn(`redz Hub -> failed to check if @{aI.Name} is a Staff: {aM}`)
elseif aM then
return aH(aI)
end
end
end end


task.spawn(function()
table.insert(c,m.PlayerAdded:Connect(aI))
for aJ,aK in ipairs(m:GetPlayers())do task.defer(aI,aK)end
end)

for aJ,aK in ay do
local aL=m:GetFriendsAsync(aK)
if not aL then task.wait(5)continue end

while not aL.IsFinished do
local aM=aL:GetCurrentPage()

for aN=1,#aM do
local aO=aM[aN]
local aP=m:GetPlayerByUserId(aO.Id)

if aP then
task.defer(aH,aP)
else
az[aO.Id]=true
end
end

aL:AdvanceToNextPageAsync()
end
end
end)


return at
