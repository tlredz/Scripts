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
local o=n:WaitForChild"CommF_"
local p=n:WaitForChild"CommE"

local q=workspace:WaitForChild"ChestModels"
local r=workspace:WaitForChild"_WorldOrigin"
local s=workspace:WaitForChild"Characters"
local t=workspace:WaitForChild"SeaBeasts"
local u=workspace:WaitForChild"Enemies"
local v=workspace:WaitForChild"Boats"
local w=workspace:WaitForChild"Map"

local x=r:WaitForChild"EnemySpawns"
local y=r:WaitForChild"Locations"

local z=l.RenderStepped
local A=l.Heartbeat
local B=l.Stepped
local C=m.LocalPlayer

local D=C:WaitForChild"Data"
local E=D:WaitForChild"Level"
local F=D:WaitForChild"Fragments"
local G=D:WaitForChild"Beli"

local H=i:WaitForChild"Modules"
local I=H:WaitForChild"Net"

local J={"NULL"}

local K=string.upper(if identifyexecutor then identifyexecutor()else"NULL")
local L=table.find(J,K)~=nil

local M=(not L and hookmetamethod)or(function(...)return...end)
local N=(not L and hookfunction)or(function(...)return...end)

local O=sethiddenproperty
local P=setsimulationradius

local Q=setupvalue or(debug and debug.setupvalue)
local R=getupvalue or(debug and debug.getupvalue)

local S=i:FindFirstChild"PrivateServerOwnerId"
local T=if S then S.Value~=0 else true

local U=0
local V local W=function(

W)
if(tick()-U)>0 then
U=tick()+5

if P then
pcall(P,W)
end

if O then
pcall(O,C,"SimulationRadius",W)
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

ag=M(game,"__index",function(ai,aj)
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

ah=M(game,"__namecall",function(ai,...)
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
MaxLevel=2750
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
table.insert(c,h:GetInstanceAddedSignal"BasicMob":Connect(aO))
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
local aF=d.SendHitsToServer
local aG=d.PlayHitAnimation
local aH=d.SetHitsCooldown
local aI=d.IsAttackWeapon
local aJ=d.NewDebounce
local aK=d.GetMaxHits
local aL=d.CheckStun

local aM=d.UpdateShootAndValidator
local aN=d.CanGetGunValidator

local aO=aB:RemoteEvent"ShootGunEvent"

local aP=0.4
local aQ=0
local aR=4
local aS=0
local aT=0
local aU=0

d.SetRigisterAttackEvent(aB:RemoteEvent"RegisterAttack")
d.SetRigisterHitEvent(aB:RemoteEvent"RegisterHit")local aV=function(

aV)
return if aV==s then au.attackPlayers else au.attackMobs end local aW=function(


aW, aX, aY)
local aZ=aK()
local a_={}
local a0={}




for a1,a2 in aY do
local a3=a2.Parent
local a4=a3.Parent

if not aV(a4)then continue end
if a4.Parent~=workspace or not X(a3)then continue end
if a4==s and(a3==C.Character or not ag(a3))then continue end

if not a0[a3]then
table.insert(a_,{a3,a2})
a0[a3]=true
end

if#a_>=aZ then
break
end
end

if#a_>0 then
aG(aW)
aH(aX)
aF(a_)
end end local aX=function()



if aS>=aR or(tick()-aQ)>=aP then
aS=0
end

aQ=tick()
aS+=1
return aS end local aY=function(


aY)
local aZ=aY.Parent
local a_=aZ.Parent.Parent

if a_~=workspace then
a_=a_.Parent
aZ=aZ.Parent
end

if a_==workspace and X(aZ)and aV(aZ.Parent)then
return true
end

return false end local aZ=function(


aZ)
while aZ.Parent.Parent~=workspace do
aZ=aZ.Parent
end
return aZ end local a_=function(


a_, a0, a1)
if not a0.Enabled then return end
if not aN then return end

local a2=C.Character
local a3,a4=math.huge
local a5=at.PlayerManager:GetRootPartPosition()

for a6,a7 in a_ do
if a7:IsDescendantOf(a2)then continue end
if not aY(a7)then continue end

local a8=(a5-a7.Position).Magnitude

if a8<a3 then
a8,a4=a8,a7
end

if a8<50 then
break
end
end

if a4 then
local a6=aZ(a4)
local a7=az[a0.Name]or"Normal"

if a7=="Overheat"then
aT=tick()+9e9

while X(a2)and X(a6)and a0.Parent==a2 do
aM(a0)
aO:FireServer(a4.Position,{a4})
task.wait()

if al(a4)>a1 then
break
end
end

aT=0
elseif a7=="Normal"then
aM(a0)

for a8=1,(ax[a0.Name]or 1)do
aO:FireServer(a4.Position,{a4})
end
else
au:ShootInTarget(a4.Position)
end
end end local a0=function(


a0, a1)
local a2=C.Character

for a3,a4 in a0 do
if a4:IsDescendantOf(a2)then continue end
if not aY(a4)then continue end

local a5=at.PlayerManager:GetRootPartPosition()
local a6=(a4.Position-a5).Unit

aC(a1,a6,aX())
return nil
end end


function au.AddAttackDebounce(a1)
aT=tick()+a1
end

function au:ShootInTarget(a1)
if(tick()-aU)<0 then return end
if not aN then return end

local a2=X(C.Character)and C.Character:FindFirstChildOfClass"Tool"
if not a2 or a2.ToolTip~="Gun"then return end

local a3=a2:FindFirstChild"Cooldown"
if not a3 then return end

local a4=az[a2.Name]

if a4=="Position"or a4=="TAP"and a2:FindFirstChild"RemoteEvent"then
aU=tick()+a3.Value
aM(a2)

if a4=="TAP"then
a2.RemoteEvent:FireServer("TAP",a1)
else
aO:FireServer(a1)
end
end
end

an(B,function()
local a1=C.Character
if not X(a1)then return end
if(tick()-aT)<=0 then return end

local a2=a1.Humanoid
local a3=a2.RootPart

if not a3 then return end

local a4=a1:FindFirstChildOfClass"Tool"

if not a4 or not aI(a4)then
return nil
end

if aD(a4)and aL(a4)then
local a5=a4.ToolTip
local a6=aJ(a4)
local a7=(ay[a4.Name]or av[a5])*2

local a8=aE(a4,a3.CFrame,a7)
if#a8==0 then return end

if a5=="Blox Fruit"and not aA[a4.Name]then
local a9=a4:FindFirstChild"LeftClickRemote"

if a9 then
a0(a8,a9)
end
elseif a5=="Gun"then
if e.AutoShoot or e.UseDragonstormSea then
a_(a8,a4,a7)
end
elseif e.AutoAttack then
aW(a4,a6,a8)
end
end
end)

return au
end)()

return at
end)()

local at=0
local au={}

function as.DisableCanTouch()
at=tick()
end

function as.RemoveBasePartsCollision(av)
local ax=av:GetDescendants()

for ay=1,#ax do
local az=ax[ay]
if az:IsA"BasePart"and az.CanCollide then
az.CanCollide=false
end
end
end

local av=as.Services.Inventory.MasteryRequirements

function as.UseSkills(ax,ay)
if al(ax)>=60 then return end

local az=C.Character and C.Character:FindFirstChildOfClass"Tool"

if az then
local aA=az:GetAttribute"Level"or 0
local aB=av[az.Name]

if aB==nil and az:FindFirstChild"Data"then
local aC,aD=pcall(require,az.Data)

if aC and type(aD)=="table"then
av[az.Name]=aD.Lvl or false
else
av[az.Name]=false
end
end

for aC,aD in ay do
if not aD then continue end
if aB and(not aB[aC]or aA<aB[aC])then continue end

local aE=au[aC]

if aD and(tick()-(aE or 0))>=0 then
g:SendKeyEvent(true,aC,false,game)
g:SendKeyEvent(false,aC,false,game)
au[aC]=tick()+ad.SKILL_COOLDOWN
end
end
end
end

as.TweenBodyVelocity=(function()
local ax=ac.ClearNoclipObjects
local ay=ac.AddNoclipObject
local az=ac.UnprotectObject
local aA=ac.ProtectObject
local aB=ac.OriginalIndex

local aC=as.Services.GoodSignal.Signals.BvChanged

local aD=Instance.new"BodyVelocity"
aD.Velocity=Vector3.zero
aD.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
aD.P=1000

local aE=f.tween_bodyvelocity

if aE then
az(aE)
aE.Parent=nil
aE:Destroy()
end

aA(aD)
f.tween_bodyvelocity=aD

local aF,aG=game.IsA,game.FindFirstChild
local aH=false

local aI,aJ,aK={},{},{}do
ac.SetCanCollideObjects(aJ)
ac.SetCanTouchObjects(aK)local aL=function(

aL)
if aL~=aD and aF(aL,"BasePart")and(aL.CanCollide or aL.CanTouch)then
table.insert(aI,aL)
ay(aL)

if aB(aL,"CanCollide")then aJ[aL]=true end
if aB(aL,"CanTouch")then aK[aL]=true end
end end local aM=function(


aM)
local aN=table.find(aI,aM)

if aN then
table.remove(aI,aN)
end end local aN=function(


aN)
if not aN then return end
table.clear(aI)

for aO,aP in aN:GetDescendants()do aL(aP)end
aN.DescendantAdded:Connect(aL)
aN.DescendantRemoving:Connect(aM)

aN:WaitForChild("Humanoid",9e9).Died:Wait()
table.clear(aI)
ax()end


an(C.CharacterAdded,aN)
task.spawn(aN,C.Character)
end local aL=function(

aL)
if not aH and f.OnFarm then
aH=true
end

if f.OnFarm and not C:HasTag"Teleporting"then
C:AddTag"Teleporting"
aH=true
elseif aH and not f.OnFarm and C:HasTag"Teleporting"then
C:RemoveTag"Teleporting"
aH=false
end

if f.OnFarm then
for aM=1,#aI do
local aN=aI[aM]
local aO=if(tick()-at)<=1 then false else true

if aK[aN]and aN.CanTouch~=aO then
aN.CanTouch=aO
end
if aJ[aN]and aN.CanCollide then
aN.CanCollide=false
end
end
elseif aL.PrimaryPart and(not aL.PrimaryPart.CanCollide or not aL.PrimaryPart.CanTouch)then
for aM=1,#aI do
local aN=aI[aM]

if aJ[aN]then
aN.CanCollide=true
end
if aK[aN]then
aN.CanTouch=true
end
end
end end local aM=function(


aM)
local aN=aG(aM,"UpperTorso")
local aO=aG(aM,"Humanoid")
local aP=f.tween_bodyvelocity

local aQ=if f.OnFarm and aN and aO and aO.Health>0 then aN else nil

if aB(aP,"Parent")~=aQ then
aP.Parent=aQ
aC:Fire(aQ)
end

local aR=aB(aP,"Velocity")

if aR~=Vector3.zero and(not aO or not aO.SeatPart or not f.OnFarm)then
aP.Velocity=Vector3.zero
end end


an(B,function()
local aN=C.Character
if X(aN)then
aM(aN)
aL(aN)
end
end)

return aD
end)()

as.RunModules=(function()
local ax={}local ay=function(

ay, az)
ax[ay]=az end


ay("InitializeQuests",function(az,aA)
local aB=aA.GetQuestTasks
local aC=aA.QuestsLookup
local aD=aA.Quests

local aE=({{0,700},{700,1500},{1500,math.huge}})[ar.Sea]
local aF=aa({"BartiloQuest","MarineQuest","CitizenQuest"},true)

for aG,aH in az do
if aF[aG]then continue end

for aI,aJ in aH do
local aK=aJ.LevelReq

if aK>=aE[1]and aK<aE[2]then
local aL,aM=aB(aJ)
local aN=aL[1]

local aO={
QuestName=aG,
QuestIndex=aI,
Quest={
EnemyLocations=aM,
LevelReq=aK,
Targets=aL
}
}

aC[aN]=aO
table.insert(aD,aO)
end
end
end

table.sort(aD,function(aG,aH)
return aG.Quest.LevelReq<aH.Quest.LevelReq
end)
end)

ay("FarmQueue",function(az)local aA=function()

for aA,aB in az do
e.RunningOption=aB.Name
local aC=aB.Function()
if not aC then continue end

if type(aC)=="string"then
e.RunningMethod=aC
end

return true
end

e.RunningOption,e.RunningMethod=nil,nil end


while task.wait(e.SmoothMode and 0.25 or 0)do
if f.teleporting then
f.OnFarm=true
elseif e.IgnoreErrors then
local aB,aC=pcall(aA)

if not aB then
warn(`redz Hub Error in {e.RunningOption} -> {aC}`)
end

f.OnFarm=(not aB and f.OnFarm)or aC
else
f.OnFarm=if aA()then true else false
end
end
end)

ay("Translator",function(az,aA)
local aB=az.MakeTab
local aC=false

local aD={}
local aE={}

local aF="⚠️ "local aG=function(

aG)
local aH=aG.Title
local aI=false

if aH:sub(1,#aF)==aF then
aH=aH:sub(#aF+1,-1)
aI=true
end

local aJ=aA[aH]

if aJ then
if aJ[1]~=nil then
aG:SetTitle((aI and aF or"")..aJ[1])
end

if aJ[2]~=nil then
aG:SetDesc(aJ[2])
end
end

return aG end


function aE:AddSection(aH)
return aG(aD["AddSection"](self,aH))
end

function aE:AddParagraph(aH,aI)
return aG(aD["AddParagraph"](self,aH,aI))
end

function aE:AddToggle(aH)
return aG(aD["AddToggle"](self,aH))
end

function aE:AddDropdown(aH)
return aG(aD["AddDropdown"](self,aH))
end

function aE:AddSlider(aH)
return aG(aD["AddSlider"](self,aH))
end

function aE:AddButton(aH)
return aG(aD["AddButton"](self,aH))
end

function aE:AddTextBox(aH)
return aG(aD["AddTextBox"](self,aH))
end

az.MakeTab=function(aH,aI)
local aJ=aI[1]or aI.Name or aI.Title

if aA[aJ]then
aI[1]=aA[aJ]
end

local aK=aB(aH,aI)

for aL,aM in aE do
aD[aL]=aK[aL]
aK[aL]=aM
end

return aK
end
end)

ay("OptionsPlugin",function(az,aA)
local aB={}

function aB.Toggle(aC,aD,aE)
local aF=aC:AddToggle{
Name=aD[1],
Default=if type(aD[2])~="string"then aD[2]else nil,
Description=aD[if type(aD[2])=="string"then 2 else 3],
Callback=function(aF)az[aE]=aF end,
Flag=aE
}

aA[aE]=aF
return aF
end

return aB
end)

ay("TweenManager",function()
local az={}
az.__index=az

local aA={}
local aB=Enum.EasingStyle.Linear

function az.new(aC,aD,aE,aF)
local aG=setmetatable({},az)

aG.tween=k:Create(aC,TweenInfo.new(aD,aB),{[aE]=aF})
aG.tween:Play()
aG.value=aF
aG.object=aC

if aA[aC]then
aA[aC]:destroy()
end

aA[aC]=aG
return aG
end

function az:destroy()
self.tween:Pause()
self.tween:Destroy()

aA[self.object]=nil
setmetatable(self,nil)
end

function az:stopTween(aC)
if aC and aA[aC]then
aA[aC]:destroy()
end
end

return az
end)

return ax
end)()

task.defer(function()
local ax={3095250,17884881}
local ay=aa({6079649301,4985647299},true)

local az=C

local aA={
["Triple Dark Blade"]=true
}

local aB={"GANKS","GANKSVolley","AAIM"}

local aC=ar.MaxLevel
local aD=ar.Sea
local aE=3025E4

local aF={
(function(aF)
if table.find(ax,aF.UserId)then
return true
elseif ay[aF.UserId]then
return true
end
end),
(function(aF,aG)
if aG.Level.Value>aC then
return true
elseif aG.Beli.Value>=3e8 and aG.Level.Value<=700 then
return true
end
end),
(function(aF,aG)
if aD>1 and aG.Level.Value<700 then
return true
elseif aD>2 and aG.Level.Value<1500 then
return true
end
end),
(function(aF)
for aG=1,#aB do
if aF:GetAttribute(aB[aG])then
return true
end
end
end),
(function(aF)
local aG=aF:WaitForChild"leaderstats":WaitForChild"Bounty/Honor"

if aG.Value>aE or aG.Value<0 then
return true
end
end)
}local aG=function(

aG)
as.RejoinBlocked=true
return az:Kick(`{aG.DisplayName}/@{aG.Name} maybe it's a blox fruits admin`)end


local aH=d.NewPlayerAdded
d.SetPossibleStaffKick(aG)local aI=function(

aI)
if aI==az then return end

local aJ=aI:WaitForChild("Data",30)

if aJ then
aJ:WaitForChild("Level",10)
aJ:WaitForChild("Beli",10)
task.spawn(aH,aI)

for aK=1,#aF do
local aL,aM=pcall(aF[aK],aI,aJ)
if not aL then
warn(`redz Hub -> failed to check if @{aI.Name} is a Staff: {aM}`)
elseif aM then
return aG(aI)
end
end
end end


task.spawn(function()
table.insert(c,m.PlayerAdded:Connect(aI))
for aJ,aK in ipairs(m:GetPlayers())do task.defer(aI,aK)end
end)

for aJ,aK in ax do
local aL=m:GetFriendsAsync(aK)
if not aL then task.wait(5)continue end

while not aL.IsFinished do
local aM=aL:GetCurrentPage()

for aN=1,#aM do
local aO=aM[aN]
local aP=m:GetPlayerByUserId(aO.Id)

if aP then
task.defer(aG,aP)
else
ay[aO.Id]=true
end
end

aL:AdvanceToNextPageAsync()
end
end
end)

return as
