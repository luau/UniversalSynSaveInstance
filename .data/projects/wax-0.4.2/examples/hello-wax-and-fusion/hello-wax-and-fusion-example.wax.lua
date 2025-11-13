local a local b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,t,u,v,E,F,G={function()local b,c,d=a(1)local e return(function(...)local f
=game:GetService'Players'local g=f.LocalPlayer local h,i=g:FindFirstChildWhichIsA'PlayerGui',d(c.Fusion)local j,k,l,m=i.
New,i.Children,i.Value,i.Computed local n=l(0)task.spawn(function()for o=1,50 do n:set(n:get()+1)task.wait(1)end end)j
'ScreenGui'{Name='WaxWithFusion',Parent=h,DisplayOrder=100,ResetOnSpawn=false,[k]={j'TextLabel'{Name='Hello',
AutomaticSize=Enum.AutomaticSize.XY,AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(44,56,63),Position=
UDim2.fromScale(0.5,0.5),Font=Enum.Font.GothamMedium,Text=m(function()return
'Hello, Wax & Fusion!\nTesting.. Testing... '..n:get()end),TextColor3=Color3.fromRGB(218,223,228),TextSize=16,
TextWrapped=true,[k]={j'UIPadding'{PaddingTop=UDim.new(0,16),PaddingBottom=UDim.new(0,16),PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16)},j'UICorner'{CornerRadius=UDim.new(0,4)},j'UIStroke'{ApplyStrokeMode=Enum.ApplyStrokeMode.
Border,Color=Color3.fromRGB(45,51,58)}}}}}end)()end,function()local b,c,d=a(2)local e return(function(...)local f,g=d(c.
PubTypes),d(c.Utility.restrictRead)return g('Fusion',{version={major=0,minor=2,isRelease=true},New=d(c.Instances.New),
Hydrate=d(c.Instances.Hydrate),Ref=d(c.Instances.Ref),Out=d(c.Instances.Out),Cleanup=d(c.Instances.Cleanup),Children=d(c
.Instances.Children),OnEvent=d(c.Instances.OnEvent),OnChange=d(c.Instances.OnChange),Value=d(c.State.Value),Computed=d(c
.State.Computed),ForPairs=d(c.State.ForPairs),ForKeys=d(c.State.ForKeys),ForValues=d(c.State.ForValues),Observer=d(c.
State.Observer),Tween=d(c.Animation.Tween),Spring=d(c.Animation.Spring),cleanup=d(c.Utility.cleanup),doNothing=d(c.
Utility.doNothing)})end)()end,[4]=function()local b,c,d=a(4)local e return(function(...)local f=c.Parent.Parent local g,
h,i,j,k,l,m,n,o,p,q,r=d(f.PubTypes),d(f.Types),d(f.Logging.logError),d(f.Logging.logErrorNonFatal),d(f.Animation.
unpackType),d(f.Animation.SpringScheduler),d(f.Dependencies.useDependency),d(f.Dependencies.initDependency),d(f.
Dependencies.updateAll),d(f.Utility.xtypeof),d(f.State.unwrap),{}local s,t={__index=r},{__mode='k'}function r.get(u,v)if
v~=false then m(u)end return u._currentValue end function r.setPosition(u,v)local w=typeof(v)if w~=u._currentType then
i('springTypeMismatch',nil,w,u._currentType)end u._springPositions=k(v,w)u._currentValue=v l.add(u)o(u)end function r.
setVelocity(u,v)local w=typeof(v)if w~=u._currentType then i('springTypeMismatch',nil,w,u._currentType)end u.
_springVelocities=k(v,w)l.add(u)end function r.addVelocity(u,v)local w=typeof(v)if w~=u._currentType then i(
'springTypeMismatch',nil,w,u._currentType)end local x=k(v,w)for y,z in ipairs(x)do u._springVelocities[y]+=z end l.add(u
)end function r.update(u)local v=u._goalState:get(false)if v==u._goalValue then local w=q(u._damping)if typeof(w)~=
'number'then j('mistypedSpringDamping',nil,typeof(w))elseif w<0 then j('invalidSpringDamping',nil,w)else u.
_currentDamping=w end local x=q(u._speed)if typeof(x)~='number'then j('mistypedSpringSpeed',nil,typeof(x))elseif x<0
then j('invalidSpringSpeed',nil,x)else u._currentSpeed=x end return false else u._goalValue=v local w,x=u._currentType,
typeof(v)u._currentType=x local y=k(v,x)local z=#y u._springGoals=y if x~=w then u._currentValue=u._goalValue local A,B=
table.create(z,0),table.create(z,0)for C,D in ipairs(y)do A[C]=D end u._springPositions=A u._springVelocities=B l.
remove(u)return true elseif z==0 then u._currentValue=u._goalValue return true else l.add(u)return false end end end
local function u(v,w,x)if w==nil then w=10 end if x==nil then x=1 end local y={[v]=true}if p(w)=='State'then y[w]=true
end if p(x)=='State'then y[x]=true end local z=setmetatable({type='State',kind='Spring',dependencySet=y,dependentSet=
setmetatable({},t),_speed=w,_damping=x,_goalState=v,_goalValue=nil,_currentType=nil,_currentValue=nil,_currentSpeed=q(w)
,_currentDamping=q(x),_springPositions=nil,_springGoals=nil,_springVelocities=nil},s)n(z)v.dependentSet[z]=true z:
update()return z end return u end)()end,[5]=function()local b,c,d=a(5)local e return(function(...)local f,g=game:
GetService'RunService',c.Parent.Parent local h,i,j,k=d(g.Types),d(g.Animation.packType),d(g.Animation.springCoefficients
),d(g.Dependencies.updateAll)local l,m,n,o={},0.0001,{},os.clock()function l.add(p)p._lastSchedule=o p.
_startDisplacements={}p._startVelocities={}for q,r in ipairs(p._springGoals)do p._startDisplacements[q]=p.
_springPositions[q]-r p._startVelocities[q]=p._springVelocities[q]end n[p]=true end function l.remove(p)n[p]=nil end
local function p()local q={}o=os.clock()for r in pairs(n)do local s,t,u,v=j(o-r._lastSchedule,r._currentDamping,r.
_currentSpeed)local w,x,y,z,A=r._springPositions,r._springVelocities,r._startDisplacements,r._startVelocities,false for
B,C in ipairs(r._springGoals)do local D,E=y[B],z[B]local F,G=D*s+E*t,D*u+E*v if math.abs(F)>m or math.abs(G)>m then A=
true end w[B]=F+C x[B]=G end if not A then q[r]=true end end for s in pairs(n)do s._currentValue=i(s._springPositions,s.
_currentType)k(s)end for t in pairs(q)do n[t]=nil end end f:BindToRenderStep('__FusionSpringScheduler',Enum.
RenderPriority.First.Value,p)return l end)()end,[6]=function()local b,c,d=a(6)local e return(function(...)local f=c.
Parent.Parent local g,h,i,j,k,l,m,n,o=d(f.PubTypes),d(f.Types),d(f.Animation.TweenScheduler),d(f.Dependencies.
useDependency),d(f.Dependencies.initDependency),d(f.Logging.logError),d(f.Logging.logErrorNonFatal),d(f.Utility.xtypeof)
,{}local p,q={__index=o},{__mode='k'}function o.get(t,u)if u~=false then j(t)end return t._currentValue end function o.
update(t)local u=t._goalState:get(false)if u==t._nextValue and not t._currentlyAnimating then return false end local v=t
._tweenInfo if t._tweenInfoIsState then v=v:get()end if typeof(v)~='TweenInfo'then m('mistypedTweenInfo',nil,typeof(v))
return false end t._prevValue=t._currentValue t._nextValue=u t._currentTweenStartTime=os.clock()t._currentTweenInfo=v
local w=v.DelayTime+v.Time if v.Reverses then w+=v.Time end w*=v.RepeatCount+1 t._currentTweenDuration=w i.add(t)return
false end local function t(u,v)local w=u:get(false)if v==nil then v=TweenInfo.new()end local x,y={[u]=true},n(v)==
'State'if y then x[v]=true end local z=v if y then z=z:get()end if typeof(z)~='TweenInfo'then l('mistypedTweenInfo',nil,
typeof(z))end local A=setmetatable({type='State',kind='Tween',dependencySet=x,dependentSet=setmetatable({},q),_goalState
=u,_tweenInfo=v,_tweenInfoIsState=y,_prevValue=w,_nextValue=w,_currentValue=w,_currentTweenInfo=v,_currentTweenDuration=
0,_currentTweenStartTime=0,_currentlyAnimating=false},p)k(A)u.dependentSet[A]=true return A end return t end)()end,[7]=
function()local b,c,d=a(7)local e return(function(...)local f,g=game:GetService'RunService',c.Parent.Parent local h,i,j,
k,l=d(g.Types),d(g.Animation.lerpType),d(g.Animation.getTweenRatio),d(g.Dependencies.updateAll),{}local m,n={__mode='k'}
,{}setmetatable(n,m)function l.add(o)n[o]=true end function l.remove(o)n[o]=nil end local function o()local p=os.clock()
for q in pairs(n)do local t=p-q._currentTweenStartTime if t>q._currentTweenDuration then if q._currentTweenInfo.Reverses
then q._currentValue=q._prevValue else q._currentValue=q._nextValue end q._currentlyAnimating=false k(q)l.remove(q)else
local u=j(q._currentTweenInfo,t)local v=i(q._prevValue,q._nextValue,u)q._currentValue=v q._currentlyAnimating=true k(q)
end end end f:BindToRenderStep('__FusionTweenScheduler',Enum.RenderPriority.First.Value,o)return l end)()end,[8]=
function()local b,c,d=a(8)local e return(function(...)local f=game:GetService'TweenService'local function g(h,i)local j,
k,l,m,n,o=h.DelayTime,h.Time,h.Reverses,1+h.RepeatCount,h.EasingStyle,h.EasingDirection local p=j+k if l then p+=k end
if i>=p*m then return 1 end local q=i%p if q<=j then return 0 end local t=(q-j)/k if t>1 then t=2-t end local u=f:
GetValue(t,n,o)return u end return g end)()end,[9]=function()local b,c,d=a(9)local e return(function(...)local f=c.
Parent.Parent local g,h=d(f.PubTypes),d(f.Colour.Oklab)local function i(j,k,l)local m=typeof(j)if typeof(k)==m then if m
=='number'then local n,o=k,j return(n-o)*l+o elseif m=='CFrame'then local n,o=k,j return o:Lerp(n,l)elseif m=='Color3'
then local n,o=k,j local p,q=h.to(o),h.to(n)return h.from(p:Lerp(q,l),false)elseif m=='ColorSequenceKeypoint'then local
n,o=k,j local p,q=h.to(o.Value),h.to(n.Value)return ColorSequenceKeypoint.new((n.Time-o.Time)*l+o.Time,h.from(p:Lerp(q,l
),false))elseif m=='DateTime'then local n,o=k,j return DateTime.fromUnixTimestampMillis((n.UnixTimestampMillis-o.
UnixTimestampMillis)*l+o.UnixTimestampMillis)elseif m=='NumberRange'then local n,o=k,j return NumberRange.new((n.Min-o.
Min)*l+o.Min,(n.Max-o.Max)*l+o.Max)elseif m=='NumberSequenceKeypoint'then local n,o=k,j return NumberSequenceKeypoint.
new((n.Time-o.Time)*l+o.Time,(n.Value-o.Value)*l+o.Value,(n.Envelope-o.Envelope)*l+o.Envelope)elseif m==
'PhysicalProperties'then local n,o=k,j return PhysicalProperties.new((n.Density-o.Density)*l+o.Density,(n.Friction-o.
Friction)*l+o.Friction,(n.Elasticity-o.Elasticity)*l+o.Elasticity,(n.FrictionWeight-o.FrictionWeight)*l+o.FrictionWeight
,(n.ElasticityWeight-o.ElasticityWeight)*l+o.ElasticityWeight)elseif m=='Ray'then local n,o=k,j return Ray.new(o.Origin:
Lerp(n.Origin,l),o.Direction:Lerp(n.Direction,l))elseif m=='Rect'then local n,o=k,j return Rect.new(o.Min:Lerp(n.Min,l),
o.Max:Lerp(n.Max,l))elseif m=='Region3'then local n,o=k,j local p,q=o.CFrame.Position:Lerp(n.CFrame.Position,l),o.Size:
Lerp(n.Size,l)/2 return Region3.new(p-q,p+q)elseif m=='Region3int16'then local n,o=k,j return Region3int16.new(
Vector3int16.new((n.Min.X-o.Min.X)*l+o.Min.X,(n.Min.Y-o.Min.Y)*l+o.Min.Y,(n.Min.Z-o.Min.Z)*l+o.Min.Z),Vector3int16.new((
n.Max.X-o.Max.X)*l+o.Max.X,(n.Max.Y-o.Max.Y)*l+o.Max.Y,(n.Max.Z-o.Max.Z)*l+o.Max.Z))elseif m=='UDim'then local n,o=k,j
return UDim.new((n.Scale-o.Scale)*l+o.Scale,(n.Offset-o.Offset)*l+o.Offset)elseif m=='UDim2'then local n,o=k,j return o:
Lerp(n,l)elseif m=='Vector2'then local n,o=k,j return o:Lerp(n,l)elseif m=='Vector2int16'then local n,o=k,j return
Vector2int16.new((n.X-o.X)*l+o.X,(n.Y-o.Y)*l+o.Y)elseif m=='Vector3'then local n,o=k,j return o:Lerp(n,l)elseif m==
'Vector3int16'then local n,o=k,j return Vector3int16.new((n.X-o.X)*l+o.X,(n.Y-o.Y)*l+o.Y,(n.Z-o.Z)*l+o.Z)end end if l<
0.5 then return j else return k end end return i end)()end,[10]=function()local b,c,d=a(10)local e return(function(...)
local f=c.Parent.Parent local g,h=d(f.PubTypes),d(f.Colour.Oklab)local function i(j,k)if k=='number'then return j[1]
elseif k=='CFrame'then return CFrame.new(j[1],j[2],j[3])*CFrame.fromAxisAngle(Vector3.new(j[4],j[5],j[6]).Unit,j[7])
elseif k=='Color3'then return h.from(Vector3.new(j[1],j[2],j[3]),false)elseif k=='ColorSequenceKeypoint'then return
ColorSequenceKeypoint.new(j[4],h.from(Vector3.new(j[1],j[2],j[3]),false))elseif k=='DateTime'then return DateTime.
fromUnixTimestampMillis(j[1])elseif k=='NumberRange'then return NumberRange.new(j[1],j[2])elseif k==
'NumberSequenceKeypoint'then return NumberSequenceKeypoint.new(j[2],j[1],j[3])elseif k=='PhysicalProperties'then return
PhysicalProperties.new(j[1],j[2],j[3],j[4],j[5])elseif k=='Ray'then return Ray.new(Vector3.new(j[1],j[2],j[3]),Vector3.
new(j[4],j[5],j[6]))elseif k=='Rect'then return Rect.new(j[1],j[2],j[3],j[4])elseif k=='Region3'then local l,m=Vector3.
new(j[1],j[2],j[3]),Vector3.new(j[4]/2,j[5]/2,j[6]/2)return Region3.new(l-m,l+m)elseif k=='Region3int16'then return
Region3int16.new(Vector3int16.new(j[1],j[2],j[3]),Vector3int16.new(j[4],j[5],j[6]))elseif k=='UDim'then return UDim.new(
j[1],j[2])elseif k=='UDim2'then return UDim2.new(j[1],j[2],j[3],j[4])elseif k=='Vector2'then return Vector2.new(j[1],j[2
])elseif k=='Vector2int16'then return Vector2int16.new(j[1],j[2])elseif k=='Vector3'then return Vector3.new(j[1],j[2],j[
3])elseif k=='Vector3int16'then return Vector3int16.new(j[1],j[2],j[3])else return nil end end return i end)()end,[11]=
function()local b,c,d=a(11)local e return(function(...)local function f(g,h,i)if g==0 or i==0 then return 1,0,0,1 end
local j,k,l,m if h>1 then local n,o=g*i,math.sqrt(h^2-1)local p,q=-0.5/o,-o-h local t,u=1/q,math.exp(n*q)local v=math.
exp(n*t)j=(v*q-u*t)*p k=(u-v)*p/i l=(v-u)*p*i m=(u*q-v*t)*p elseif h==1 then local n=g*i local o=math.exp(-n)j=o*(1+n)k=
o*g l=o*(-n*i)m=o*(1-n)else local n,o=g*i,math.sqrt(1-h^2)local p,q,t=1/o,o*n,math.exp(-n*h)local u,v=t*math.sin(q),t*
math.cos(q)local w=u*p local x=w*h j=x+v k=w l=-(x*h+u*o)m=v-x end return j,k,l,m end return f end)()end,[12]=function()
local b,c,d=a(12)local e return(function(...)local f=c.Parent.Parent local g,h=d(f.PubTypes),d(f.Colour.Oklab)
local function i(j,k)if k=='number'then local l=j return{l}elseif k=='CFrame'then local l,m=j:ToAxisAngle()return{j.X,j.
Y,j.Z,l.X,l.Y,l.Z,m}elseif k=='Color3'then local l=h.to(j)return{l.X,l.Y,l.Z}elseif k=='ColorSequenceKeypoint'then local
l=h.to(j.Value)return{l.X,l.Y,l.Z,j.Time}elseif k=='DateTime'then return{j.UnixTimestampMillis}elseif k=='NumberRange'
then return{j.Min,j.Max}elseif k=='NumberSequenceKeypoint'then return{j.Value,j.Time,j.Envelope}elseif k==
'PhysicalProperties'then return{j.Density,j.Friction,j.Elasticity,j.FrictionWeight,j.ElasticityWeight}elseif k=='Ray'
then return{j.Origin.X,j.Origin.Y,j.Origin.Z,j.Direction.X,j.Direction.Y,j.Direction.Z}elseif k=='Rect'then return{j.Min
.X,j.Min.Y,j.Max.X,j.Max.Y}elseif k=='Region3'then return{j.CFrame.X,j.CFrame.Y,j.CFrame.Z,j.Size.X,j.Size.Y,j.Size.Z}
elseif k=='Region3int16'then return{j.Min.X,j.Min.Y,j.Min.Z,j.Max.X,j.Max.Y,j.Max.Z}elseif k=='UDim'then return{j.Scale,
j.Offset}elseif k=='UDim2'then return{j.X.Scale,j.X.Offset,j.Y.Scale,j.Y.Offset}elseif k=='Vector2'then return{j.X,j.Y}
elseif k=='Vector2int16'then return{j.X,j.Y}elseif k=='Vector3'then return{j.X,j.Y,j.Z}elseif k=='Vector3int16'then
return{j.X,j.Y,j.Z}else return{}end end return i end)()end,[14]=function()local b,c,d=a(14)local e return(function(...)
local f={}function f.to(g)local h,i,j=g.R*0.4122214708+g.G*0.5363325363+g.B*0.0514459929,g.R*0.2119034982+g.G*
0.6806995451+g.B*0.1073969566,g.R*0.0883024619+g.G*0.2817188376+g.B*0.6299787005 local k,l,m=h^(0.3333333333333333),i^(
0.3333333333333333),j^(0.3333333333333333)return Vector3.new(k*0.2104542553+l*0.793617785-m*0.0040720468,k*1.9779984951-
l*2.428592205+m*0.4505937099,k*0.0259040371+l*0.7827717662-m*0.808675766)end function f.from(g,h)local i,j,k=g.X+g.Y*
0.3963377774+g.Z*0.2158037573,g.X-g.Y*0.1055613458-g.Z*0.0638541728,g.X-g.Y*0.0894841775-g.Z*1.291485548 local l,m,n=i^3
,j^3,k^3 local o,p,q=l*4.0767416621-m*3.3077115913+n*0.2309699292,l*-1.2684380046+m*2.6097574011-n*0.3413193965,l*-
4.196086299999999E-3-m*0.7034186147+n*1.707614701 if not h then o=math.clamp(o,0,1)p=math.clamp(p,0,1)q=math.clamp(q,0,1
)end return Color3.new(o,p,q)end return f end)()end,[16]=function()local b,c,d=a(16)local e return(function(...)local f=
c.Parent.Parent local g,h,i=d(f.PubTypes),d(f.Logging.parseError),d(f.Dependencies.sharedState)local j,k=i.
initialisedStack,0 local function l(m,n,...)local o=i.dependencySet i.dependencySet=m i.initialisedStackSize+=1 local p,
q=(i.initialisedStackSize)if p>k then q={}j[p]=q k=p else q=j[p]table.clear(q)end local t=table.pack(xpcall(n,h,...))i.
dependencySet=o i.initialisedStackSize-=1 return table.unpack(t,1,t.n)end return l end)()end,[17]=function()local b,c,d=
a(17)local e return(function(...)local f=c.Parent.Parent local g,h=d(f.PubTypes),d(f.Dependencies.sharedState)local i=h.
initialisedStack local function j(k)local l=h.initialisedStackSize for m,n in ipairs(i)do if m>l then return end n[k]=
true end end return j end)()end,[18]=function()local b,c,d=a(18)local e return(function(...)local f=c.Parent.Parent
local g=d(f.PubTypes)local h,i,j={},0 return{dependencySet=j,initialisedStack=h,initialisedStackSize=i}end)()end,[19]=
function()local b,c,d=a(19)local e return(function(...)local f=c.Parent.Parent local g=d(f.PubTypes)local function h(i)
local j,k,l,m,n={},{},{},0,1 for o in i.dependentSet do m+=1 l[m]=o k[o]=true end while n<=m do local p=l[n]local q=j[p]
j[p]=if q==nil then 1 else q+1 if(p).dependentSet~=nil then for t in(p).dependentSet do m+=1 l[m]=t end end n+=1 end n=1
while n<=m do local p=l[n]local q=j[p]-1 j[p]=q if q==0 and k[p]and p:update()and(p).dependentSet~=nil then for t in(p).
dependentSet do k[t]=true end end n+=1 end end return h end)()end,[20]=function()local b,c,d=a(20)local e return(
function(...)local f=c.Parent.Parent local g,h=d(f.PubTypes),d(f.Dependencies.sharedState)local i=h.initialisedStack
local function j(k)local l=h.dependencySet if l~=nil then local m=h.initialisedStackSize if m>0 then local n=i[m]if n[k]
~=nil then return end end l[k]=true end end return j end)()end,[22]=function()local b,c,d=a(22)local e return(function(
...)local f=c.Parent.Parent local g,h,i,j=d(f.PubTypes),d(f.Logging.logWarn),d(f.State.Observer),d(f.Utility.xtypeof)
local k,l=false,{}l.type='SpecialKey'l.kind='Children'l.stage='descendants'function l.apply(m,n,o,p)local q,t,u,v,w,x={}
,{},{},{},false local function y()if not w then return end w=false t,q=q,t v,u=u,v table.clear(q)table.clear(u)
local function z(A,B)local C=j(A)if C=='Instance'then q[A]=true if t[A]==nil then A.Parent=o else t[A]=nil end if k and
B~=nil then A.Name=B end elseif C=='State'then local D=A:get(false)if D~=nil then z(D,B)end local E=v[A]if E==nil then E
=i(A):onChange(x)else v[A]=nil end u[A]=E elseif C=='table'then for D,E in pairs(A)do local F,G=(typeof(D))if F==
'string'then G=D elseif F=='number'and B~=nil then G=B..'_'..D end z(E,G)end else h('unrecognisedChildType',C)end end if
n~=nil then z(n)end for A in pairs(t)do A.Parent=nil end for B,C in pairs(v)do C()end end x=function()if not w then w=
true task.defer(y)end end table.insert(p,function()n=nil w=true y()end)w=true y()end return l end)()end,[23]=function()
local b,c,d=a(23)local e return(function(...)local f=c.Parent.Parent local g,h=d(f.PubTypes),{}h.type='SpecialKey'h.kind
='Cleanup'h.stage='observer'function h.apply(i,j,k,l)table.insert(l,j)end return h end)()end,[24]=function()local b,c,d=
a(24)local e return(function(...)local f=c.Parent.Parent local g,h=d(f.PubTypes),d(f.Instances.applyInstanceProps)
local function i(j)return function(k)h(k,j)return j end end return i end)()end,[25]=function()local b,c,d=a(25)local e
return(function(...)local f=c.Parent.Parent local g,h,i,j=d(f.PubTypes),d(f.Instances.defaultProps),d(f.Instances.
applyInstanceProps),d(f.Logging.logError)local function k(l)return function(m)local n,o=pcall(Instance.new,l)if not n
then j('cannotCreateClass',nil,l)end local p=h[l]if p~=nil then for q,t in pairs(p)do o[q]=t end end i(m,o)return o end
end return k end)()end,[26]=function()local b,c,d=a(26)local e return(function(...)local f=c.Parent.Parent local g,h=d(f
.PubTypes),d(f.Logging.logError)local function i(j)local k={}k.type='SpecialKey'k.kind='OnChange'k.stage='observer'
function k.apply(l,m,n,o)local p,q=pcall(n.GetPropertyChangedSignal,n,j)if not p then h('cannotConnectChange',nil,n.
ClassName,j)elseif typeof(m)~='function'then h('invalidChangeHandler',nil,j)else table.insert(o,q:Connect(function()m((n
)[j])end))end end return k end return i end)()end,[27]=function()local b,c,d=a(27)local e return(function(...)local f=c.
Parent.Parent local g,h=d(f.PubTypes),d(f.Logging.logError)local function i(j,k)return(j)[k]end local function j(k)local
l={}l.type='SpecialKey'l.kind='OnEvent'l.stage='observer'function l.apply(m,n,o,p)local q,t=pcall(i,o,k)if not q or
typeof(t)~='RBXScriptSignal'then h('cannotConnectEvent',nil,o.ClassName,k)elseif typeof(n)~='function'then h(
'invalidEventHandler',nil,k)else table.insert(p,t:Connect(n))end end return l end return j end)()end,[28]=function()
local b,c,d=a(28)local e return(function(...)local f=c.Parent.Parent local g,h,i=d(f.PubTypes),d(f.Logging.logError),d(f
.Utility.xtypeof)local function j(k)local l={}l.type='SpecialKey'l.kind='Out'l.stage='observer'function l.apply(m,n,o,p)
local q,t=pcall(o.GetPropertyChangedSignal,o,k)if not q then h('invalidOutProperty',nil,o.ClassName,k)elseif i(n)~=
'State'or n.kind~='Value'then h'invalidOutType'else n:set((o)[k])table.insert(p,t:Connect(function()n:set((o)[k])end))
table.insert(p,function()n:set(nil)end)end end return l end return j end)()end,[29]=function()local b,c,d=a(29)local e
return(function(...)local f=c.Parent.Parent local g,h,i,j=d(f.PubTypes),d(f.Logging.logError),d(f.Utility.xtypeof),{}j.
type='SpecialKey'j.kind='Ref'j.stage='observer'function j.apply(k,l,m,n)if i(l)~='State'or l.kind~='Value'then h
'invalidRefType'else l:set(m)table.insert(n,function()l:set(nil)end)end end return j end)()end,[30]=function()local b,c,
d=a(30)local e return(function(...)local f=c.Parent.Parent local g,h,i,j,k=d(f.PubTypes),d(f.Utility.cleanup),d(f.
Utility.xtypeof),d(f.Logging.logError),d(f.State.Observer)local function l(m,n,o)(m)[n]=o end local function m(n,o)(n)[o
]=(n)[o]end local function n(o,p,q)if not pcall(l,o,p,q)then if not pcall(m,o,p)then if o==nil then j(
'setPropertyNilRef',nil,p,tostring(q))else j('cannotAssignProperty',nil,o.ClassName,p)end else local t,u=typeof(q),
typeof((o)[p])j('invalidPropertyType',nil,o.ClassName,p,u,t)end end end local function o(p,q,t,u)if i(t)=='State'then
local v=false local function w()if not v then v=true task.defer(function()v=false n(p,q,t:get(false))end)end end n(p,q,t
:get(false))table.insert(u,k(t):onChange(w))else n(p,q,t)end end local function p(q,t)local u,v={self={},descendants={},
ancestor={},observer={}},{}for w,x in pairs(q)do local y=i(w)if y=='string'then if w~='Parent'then o(t,w,x,v)end elseif
y=='SpecialKey'then local z=(w).stage local A=u[z]if A==nil then j('unrecognisedPropertyStage',nil,z)else A[w]=x end
else j('unrecognisedPropertyKey',nil,i(w))end end for y,z in pairs(u.self)do y:apply(z,t,v)end for A,B in pairs(u.
descendants)do A:apply(B,t,v)end if q.Parent~=nil then o(t,'Parent',q.Parent,v)end for C,D in pairs(u.ancestor)do C:
apply(D,t,v)end for E,F in pairs(u.observer)do E:apply(F,t,v)end t.Destroying:Connect(function()h(v)end)end return p end
)()end,[31]=function()local b,c,d=a(31)local e return(function(...)return{ScreenGui={ResetOnSpawn=false,ZIndexBehavior=
Enum.ZIndexBehavior.Sibling},BillboardGui={ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},SurfaceGui={
ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud,
PixelsPerStud=50},Frame={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0},
ScrollingFrame={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0,ScrollBarImageColor3
=Color3.new(0,0,0)},TextLabel={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0,Font=
Enum.Font.SourceSans,Text='',TextColor3=Color3.new(0,0,0),TextSize=14},TextButton={BackgroundColor3=Color3.new(1,1,1),
BorderColor3=Color3.new(0,0,0),BorderSizePixel=0,AutoButtonColor=false,Font=Enum.Font.SourceSans,Text='',TextColor3=
Color3.new(0,0,0),TextSize=14},TextBox={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),
BorderSizePixel=0,ClearTextOnFocus=false,Font=Enum.Font.SourceSans,Text='',TextColor3=Color3.new(0,0,0),TextSize=14},
ImageLabel={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0},ImageButton={
BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0,AutoButtonColor=false},ViewportFrame
={BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0},VideoFrame={BackgroundColor3=
Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),BorderSizePixel=0},CanvasGroup={BackgroundColor3=Color3.new(1,1,1),
BorderColor3=Color3.new(0,0,0),BorderSizePixel=0}}end)()end,[33]=function()local b,c,d=a(33)local e return(function(...)
local f=c.Parent.Parent local g,h=d(f.Types),d(f.Logging.messages)local function i(j,k,...)local l if h[j]~=nil then l=h
[j]else j='unknownMessage'l=h[j]end local m if k==nil then m=string.format('[Fusion] '..l..'\n(ID: '..j..')',...)else l=
l:gsub('ERROR_MESSAGE',k.message)m=string.format('[Fusion] '..l..'\n(ID: '..j..')\n---- Stack trace ----\n'..k.trace,...
)end error(m:gsub('\n','\n    '),0)end return i end)()end,[34]=function()local b,c,d=a(34)local e return(function(...)
local f=c.Parent.Parent local g,h=d(f.Types),d(f.Logging.messages)local function i(j,k,...)local l if h[j]~=nil then l=h
[j]else j='unknownMessage'l=h[j]end local m if k==nil then m=string.format('[Fusion] '..l..'\n(ID: '..j..')',...)else l=
l:gsub('ERROR_MESSAGE',k.message)m=string.format('[Fusion] '..l..'\n(ID: '..j..')\n---- Stack trace ----\n'..k.trace,...
)end task.spawn(function(...)error(m:gsub('\n','\n    '),0)end,...)end return i end)()end,[35]=function()local b,c,d=a(
35)local e return(function(...)local f=c.Parent.Parent local g=d(f.Logging.messages)local function h(i,...)local j if g[
i]~=nil then j=g[i]else i='unknownMessage'j=g[i]end warn(string.format('[Fusion] '..j..'\n(ID: '..i..')',...))end return
h end)()end,[36]=function()local b,c,d=a(36)local e return(function(...)return{cannotAssignProperty=
"The class type '%s' has no assignable property '%s'.",cannotConnectChange=
"The %s class doesn't have a property called '%s'.",cannotConnectEvent="The %s class doesn't have an event called '%s'."
,cannotCreateClass="Can't create a new instance of class '%s'.",computedCallbackError=
'Computed callback error: ERROR_MESSAGE',destructorNeededValue=
[[To save instances into Values, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]]
,destructorNeededComputed=
[[To return instances from Computeds, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]]
,multiReturnComputed=
[[Returning multiple values from Computeds is discouraged, as behaviour will change soon - see discussion #189 on GitHub.]]
,destructorNeededForKeys=
[[To return instances from ForKeys, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]]
,destructorNeededForValues=
[[To return instances from ForValues, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]]
,destructorNeededForPairs=
[[To return instances from ForPairs, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]]
,duplicatePropertyKey='',forKeysProcessorError='ForKeys callback error: ERROR_MESSAGE',forKeysKeyCollision=
[[ForKeys should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previously input key: '%s'; New input key: '%s']]
,forKeysDestructorError='ForKeys destructor error: ERROR_MESSAGE',forPairsDestructorError=
'ForPairs destructor error: ERROR_MESSAGE',forPairsKeyCollision=
[[ForPairs should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previous input pair: '[%s] = %s'; New input pair: '[%s] = %s']]
,forPairsProcessorError='ForPairs callback error: ERROR_MESSAGE',forValuesProcessorError=
'ForValues callback error: ERROR_MESSAGE',forValuesDestructorError='ForValues destructor error: ERROR_MESSAGE',
invalidChangeHandler=[[The change handler for the '%s' property must be a function.]],invalidEventHandler=
"The handler for the '%s' event must be a function.",invalidPropertyType=
"'%s.%s' expected a '%s' type, but got a '%s' type.",invalidRefType='Instance refs must be Value objects.',
invalidOutType='[Out] properties must be given Value objects.',invalidOutProperty=
"The %s class doesn't have a property called '%s'.",invalidSpringDamping=
[[The damping ratio for a spring must be >= 0. (damping was %.2f)]],invalidSpringSpeed=
'The speed of a spring must be >= 0. (speed was %.2f)',mistypedSpringDamping=
'The damping ratio for a spring must be a number. (got a %s)',mistypedSpringSpeed=
'The speed of a spring must be a number. (got a %s)',mistypedTweenInfo=
'The tween info of a tween must be a TweenInfo. (got a %s)',springTypeMismatch=
"The type '%s' doesn't match the spring's type '%s'.",strictReadError="'%s' is not a valid member of '%s'.",
unknownMessage='Unknown error: ERROR_MESSAGE',unrecognisedChildType=
"'%s' type children aren't accepted by `[Children]`.",unrecognisedPropertyKey=
"'%s' keys aren't accepted in property tables.",unrecognisedPropertyStage=
[['%s' isn't a valid stage for a special key to be applied at.]]}end)()end,[37]=function()local b,c,d=a(37)local e
return(function(...)local f=c.Parent.Parent local g=d(f.Types)local function h(i)return{type='Error',raw=i,message=i:
gsub('^.+:%d+:%s*',''),trace=debug.traceback(nil,2)}end return h end)()end,[38]=function()local b,c,d=a(38)local e
return(function(...)return nil end)()end,[40]=function()local b,c,d=a(40)local e return(function(...)local f=c.Parent.
Parent local g,h,i,j,k,l,m,n,o=d(f.Types),d(f.Dependencies.captureDependencies),d(f.Dependencies.initDependency),d(f.
Dependencies.useDependency),d(f.Logging.logErrorNonFatal),d(f.Logging.logWarn),d(f.Utility.isSimilar),d(f.Utility.
needsDestruction),{}local p,q={__index=o},{__mode='k'}function o.get(t,u)if u~=false then j(t)end return t._value end
function o.update(t)for u in pairs(t.dependencySet)do u.dependentSet[t]=nil end t._oldDependencySet,t.dependencySet=t.
dependencySet,t._oldDependencySet table.clear(t.dependencySet)local v,E,F=h(t.dependencySet,t._processor)if v then if t.
_destructor==nil and n(E)then l'destructorNeededComputed'end if F~=nil then l'multiReturnComputed'end local G=t._value
local H=m(G,E)if t._destructor~=nil then t._destructor(G)end t._value=E for I in pairs(t.dependencySet)do I.dependentSet
[t]=true end return not H else k('computedCallbackError',E)t._oldDependencySet,t.dependencySet=t.dependencySet,t.
_oldDependencySet for G in pairs(t.dependencySet)do G.dependentSet[t]=true end return false end end local function t(u,v
)local E=setmetatable({type='State',kind='Computed',dependencySet={},dependentSet=setmetatable({},q),_oldDependencySet={
},_processor=u,_destructor=v,_value=nil},p)i(E)E:update()return E end return t end)()end,[41]=function()local b,c,d=a(41
)local e return(function(...)local f=c.Parent.Parent local g,h,i,j,k,l,m,n,o,p,q,t=d(f.PubTypes),d(f.Types),d(f.
Dependencies.captureDependencies),d(f.Dependencies.initDependency),d(f.Dependencies.useDependency),d(f.Logging.
parseError),d(f.Logging.logErrorNonFatal),d(f.Logging.logError),d(f.Logging.logWarn),d(f.Utility.cleanup),d(f.Utility.
needsDestruction),{}local u,v={__index=t},{__mode='k'}function t.get(E,F)if F~=false then k(E)end return E._outputTable
end function t.update(E)local F=E._inputIsState local G,H,I,J,K,L,M=if F then E._inputTable:get(false)else E._inputTable
,E._oldInputTable,E._outputTable,E._keyOIMap,E._keyIOMap,E._meta,false for N in pairs(E.dependencySet)do N.dependentSet[
E]=nil end E._oldDependencySet,E.dependencySet=E.dependencySet,E._oldDependencySet table.clear(E.dependencySet)if F then
E._inputTable.dependentSet[E]=true E.dependencySet[E._inputTable]=true end for O,P in pairs(G)do local Q=E._keyData[O]if
Q==nil then Q={dependencySet=setmetatable({},v),oldDependencySet=setmetatable({},v),dependencyValues=setmetatable({},v)}
E._keyData[O]=Q end local R=H[O]==nil if R==false then for S,T in pairs(Q.dependencyValues)do if T~=S:get(false)then R=
true break end end end if R then Q.oldDependencySet,Q.dependencySet=Q.dependencySet,Q.oldDependencySet table.clear(Q.
dependencySet)local S,T,U=i(Q.dependencySet,E._processor,O)if S then if E._destructor==nil and(q(T)or q(U))then o
'destructorNeededForKeys'end local V,W=J[T],K[O]if V~=O and G[V]~=nil then n('forKeysKeyCollision',nil,tostring(T),
tostring(V),tostring(T))end if W~=T and J[W]==O then local X=L[W]local Y,Z=xpcall(E._destructor or p,l,W,X)if not Y then
m('forKeysDestructorError',Z)end J[W]=nil I[W]=nil L[W]=nil end H[O]=P L[T]=U J[T]=O K[O]=T I[T]=P M=true else Q.
oldDependencySet,Q.dependencySet=Q.dependencySet,Q.oldDependencySet m('forKeysProcessorError',T)end end for S in pairs(Q
.dependencySet)do Q.dependencyValues[S]=S:get(false)E.dependencySet[S]=true S.dependentSet[E]=true end end for Q,R in
pairs(J)do if G[R]==nil then local S=L[Q]local T,U=xpcall(E._destructor or p,l,Q,S)if not T then m(
'forKeysDestructorError',U)end H[R]=nil L[Q]=nil J[Q]=nil K[R]=nil I[Q]=nil E._keyData[R]=nil M=true end end return M
end local function E(F,G,H)local I=F.type=='State'and typeof(F.get)=='function'local J=setmetatable({type='State',kind=
'ForKeys',dependencySet={},dependentSet=setmetatable({},v),_oldDependencySet={},_processor=G,_destructor=H,_inputIsState
=I,_inputTable=F,_oldInputTable={},_outputTable={},_keyOIMap={},_keyIOMap={},_keyData={},_meta={}},u)j(J)J:update()
return J end return E end)()end,[42]=function()local b,c,d=a(42)local e return(function(...)local f=c.Parent.Parent
local g,h,i,j,k,l,m,n,o,p,q,t=d(f.PubTypes),d(f.Types),d(f.Dependencies.captureDependencies),d(f.Dependencies.
initDependency),d(f.Dependencies.useDependency),d(f.Logging.parseError),d(f.Logging.logErrorNonFatal),d(f.Logging.
logError),d(f.Logging.logWarn),d(f.Utility.cleanup),d(f.Utility.needsDestruction),{}local u,v={__index=t},{__mode='k'}
function t.get(E,F)if F~=false then k(E)end return E._outputTable end function t.update(E)local F=E._inputIsState local
G,H,I,J,K=if F then E._inputTable:get(false)else E._inputTable,E._oldInputTable,E._keyIOMap,E._meta,false for L in
pairs(E.dependencySet)do L.dependentSet[E]=nil end E._oldDependencySet,E.dependencySet=E.dependencySet,E.
_oldDependencySet table.clear(E.dependencySet)if F then E._inputTable.dependentSet[E]=true E.dependencySet[E._inputTable
]=true end E._oldOutputTable,E._outputTable=E._outputTable,E._oldOutputTable local M,N=E._oldOutputTable,E._outputTable
table.clear(N)for O,P in pairs(G)do local Q=E._keyData[O]if Q==nil then Q={dependencySet=setmetatable({},v),
oldDependencySet=setmetatable({},v),dependencyValues=setmetatable({},v)}E._keyData[O]=Q end local R=H[O]~=P if R==false
then for S,T in pairs(Q.dependencyValues)do if T~=S:get(false)then R=true break end end end if R then Q.oldDependencySet
,Q.dependencySet=Q.dependencySet,Q.oldDependencySet table.clear(Q.dependencySet)local S,T,U,V=i(Q.dependencySet,E.
_processor,O,P)if S then if E._destructor==nil and(q(T)or q(U)or q(V))then o'destructorNeededForPairs'end if N[T]~=nil
then local W,X for Y,Z in pairs(I)do if Z==T then X=G[Y]if X~=nil then W=Y break end end end if W~=nil then n(
'forPairsKeyCollision',nil,tostring(T),tostring(W),tostring(X),tostring(O),tostring(P))end end local W=M[T]if W~=U then
local X=J[T]if W~=nil then local Y,Z=xpcall(E._destructor or p,l,T,W,X)if not Y then m('forPairsDestructorError',Z)end
end M[T]=nil end H[O]=P I[O]=T J[T]=V N[T]=U K=true else Q.oldDependencySet,Q.dependencySet=Q.dependencySet,Q.
oldDependencySet m('forPairsProcessorError',T)end else local S=I[O]if N[S]~=nil then local T,U for V,W in pairs(I)do if
S==W then U=G[V]if U~=nil then T=V break end end end if T~=nil then n('forPairsKeyCollision',nil,tostring(S),tostring(T)
,tostring(U),tostring(O),tostring(P))end end N[S]=M[S]end for S in pairs(Q.dependencySet)do Q.dependencyValues[S]=S:get(
false)E.dependencySet[S]=true S.dependentSet[E]=true end end for Q,R in pairs(M)do if N[Q]~=R then local S=J[Q]if R~=nil
then local T,U=xpcall(E._destructor or p,l,Q,R,S)if not T then m('forPairsDestructorError',U)end end if N[Q]==nil then J
[Q]=nil E._keyData[Q]=nil end K=true end end for S in pairs(H)do if G[S]==nil then H[S]=nil I[S]=nil end end return K
end local function E(F,G,H)local I=F.type=='State'and typeof(F.get)=='function'local J=setmetatable({type='State',kind=
'ForPairs',dependencySet={},dependentSet=setmetatable({},v),_oldDependencySet={},_processor=G,_destructor=H,
_inputIsState=I,_inputTable=F,_oldInputTable={},_outputTable={},_oldOutputTable={},_keyIOMap={},_keyData={},_meta={}},u)
j(J)J:update()return J end return E end)()end,[43]=function()local b,c,d=a(43)local e return(function(...)local f=c.
Parent.Parent local g,h,i,j,k,l,m,n,o,p,q=d(f.PubTypes),d(f.Types),d(f.Dependencies.captureDependencies),d(f.
Dependencies.initDependency),d(f.Dependencies.useDependency),d(f.Logging.parseError),d(f.Logging.logErrorNonFatal),d(f.
Logging.logWarn),d(f.Utility.cleanup),d(f.Utility.needsDestruction),{}local t,u={__index=q},{__mode='k'}function q.get(v
,E)if E~=false then k(v)end return v._outputTable end function q.update(v)local E=v._inputIsState local F,G,H=if E then
v._inputTable:get(false)else v._inputTable,{},false v._oldValueCache,v._valueCache=v._valueCache,v._oldValueCache local
I,J=v._valueCache,v._oldValueCache table.clear(I)for K in pairs(v.dependencySet)do K.dependentSet[v]=nil end v.
_oldDependencySet,v.dependencySet=v.dependencySet,v._oldDependencySet table.clear(v.dependencySet)if E then v.
_inputTable.dependentSet[v]=true v.dependencySet[v._inputTable]=true end for L,M in pairs(F)do local N=J[M]local O,P,Q,R
=(N==nil)if type(N)=='table'and#N>0 then local S=table.remove(N,#N)P=S.value Q=S.valueData R=S.meta if#N<=0 then J[M]=
nil end elseif N~=nil then J[M]=nil O=true end if Q==nil then Q={dependencySet=setmetatable({},u),oldDependencySet=
setmetatable({},u),dependencyValues=setmetatable({},u)}end if O==false then for S,T in pairs(Q.dependencyValues)do if T
~=S:get(false)then O=true break end end end if O then Q.oldDependencySet,Q.dependencySet=Q.dependencySet,Q.
oldDependencySet table.clear(Q.dependencySet)local S,T,U=i(Q.dependencySet,v._processor,M)if S then if v._destructor==
nil and(p(T)or p(U))then n'destructorNeededForValues'end if P~=nil then local V,W=xpcall(v._destructor or o,l,P,R)if not
V then m('forValuesDestructorError',W)end end P=T R=U H=true else Q.oldDependencySet,Q.dependencySet=Q.dependencySet,Q.
oldDependencySet m('forValuesProcessorError',T)end end local S=I[M]if S==nil then S={}I[M]=S end table.insert(S,{value=P
,valueData=Q,meta=R})G[L]=P for T in pairs(Q.dependencySet)do Q.dependencyValues[T]=T:get(false)v.dependencySet[T]=true
T.dependentSet[v]=true end end for N,O in pairs(J)do for P,Q in ipairs(O)do local R,S=Q.value,Q.meta local T,U=xpcall(v.
_destructor or o,l,R,S)if not T then m('forValuesDestructorError',U)end H=true end table.clear(O)end v._outputTable=G
return H end local function v(E,F,G)local H=E.type=='State'and typeof(E.get)=='function'local I=setmetatable({type=
'State',kind='ForValues',dependencySet={},dependentSet=setmetatable({},u),_oldDependencySet={},_processor=F,_destructor=
G,_inputIsState=H,_inputTable=E,_outputTable={},_valueCache={},_oldValueCache={}},t)j(I)I:update()return I end return v
end)()end,[44]=function()local b,c,d=a(44)local e return(function(...)local f=c.Parent.Parent local g,h,i=d(f.PubTypes),
d(f.Types),d(f.Dependencies.initDependency)local j={}local k,l={__index=j},{}function j.update(m)for n,o in pairs(m.
_changeListeners)do task.spawn(o)end return false end function j.onChange(m,n)local o={}m._numChangeListeners+=1 m.
_changeListeners[o]=n l[m]=true local p=false return function()if p then return end p=true m._changeListeners[o]=nil m.
_numChangeListeners-=1 if m._numChangeListeners==0 then l[m]=nil end end end local function m(n)local o=setmetatable({
type='State',kind='Observer',dependencySet={[n]=true},dependentSet={},_changeListeners={},_numChangeListeners=0},k)i(o)n
.dependentSet[o]=true return o end return m end)()end,[45]=function()local b,c,d=a(45)local e return(function(...)local
f=c.Parent.Parent local g,h,i,j,k,l=d(f.Types),d(f.Dependencies.useDependency),d(f.Dependencies.initDependency),d(f.
Dependencies.updateAll),d(f.Utility.isSimilar),{}local m,n={__index=l},{__mode='k'}function l.get(o,p)if p~=false then
h(o)end return o._value end function l.set(o,p,q)local t=o._value if q or not k(t,p)then o._value=p j(o)end end
local function o(p)local q=setmetatable({type='State',kind='Value',dependentSet=setmetatable({},n),_value=p},m)i(q)
return q end return o end)()end,[46]=function()local b,c,d=a(46)local e return(function(...)local f=c.Parent.Parent
local g,h=d(f.PubTypes),d(f.Utility.xtypeof)local function i(j,k)return if h(j)=='State'then(j):get(k)else(j)end return
i end)()end,[47]=function()local b,c,d=a(47)local e return(function(...)local f=c.Parent local g=d(f.PubTypes)return nil
end)()end,[49]=function()local b,c,d=a(49)local e return(function(...)local f=c.Parent.Parent local g=d(f.Types)return{
type='Symbol',name='None'}end)()end,[50]=function()local b,c,d=a(50)local e return(function(...)local function f(g)local
h=typeof(g)if h=='Instance'then g:Destroy()elseif h=='RBXScriptConnection'then g:Disconnect()elseif h=='function'then g(
)elseif h=='table'then if typeof(g.destroy)=='function'then g:destroy()elseif typeof(g.Destroy)=='function'then g:
Destroy()elseif g[1]~=nil then for i,j in ipairs(g)do f(j)end end end end local function g(...)for h=1,select('#',...)do
f(select(h,...))end end return g end)()end,[51]=function()local b,c,d=a(51)local e return(function(...)local function f(
...)end return f end)()end,[52]=function()local b,c,d=a(52)local e return(function(...)local function f(g,h)if typeof(g)
=='table'then return false else return g==h end end return f end)()end,[53]=function()local b,c,d=a(53)local e return(
function(...)local function f(g)return typeof(g)=='Instance'end return f end)()end,[54]=function()local b,c,d=a(54)local
e return(function(...)local f=c.Parent.Parent local g=d(f.Logging.logError)local function h(i,j)local k=getmetatable(j)
if k==nil then k={}setmetatable(j,k)end function k.__index(l,m)g('strictReadError',nil,tostring(m),i)end return j end
return h end)()end,[55]=function()local b,c,d=a(55)local e return(function(...)local function f(g)local h=typeof(g)if h
=='table'and typeof(g.type)=='string'then return g.type else return h end end return f end)()end},{{1,4,{
'hello-wax-and-fusion-example'},{{2,2,{'Fusion'},{{47,2,{'Types'}},{13,1,{'Colour'},{{14,2,{'Oklab'}}}},{3,1,{
'Animation'},{{11,2,{'springCoefficients'}},{7,2,{'TweenScheduler'}},{9,2,{'lerpType'}},{6,2,{'Tween'}},{10,2,{
'packType'}},{8,2,{'getTweenRatio'}},{5,2,{'SpringScheduler'}},{12,2,{'unpackType'}},{4,2,{'Spring'}}}},{48,1,{'Utility'
},{{54,2,{'restrictRead'}},{52,2,{'isSimilar'}},{50,2,{'cleanup'}},{51,2,{'doNothing'}},{55,2,{'xtypeof'}},{53,2,{
'needsDestruction'}},{49,2,{'None'}}}},{21,1,{'Instances'},{{24,2,{'Hydrate'}},{22,2,{'Children'}},{28,2,{'Out'}},{23,2,
{'Cleanup'}},{31,2,{'defaultProps'}},{30,2,{'applyInstanceProps'}},{29,2,{'Ref'}},{26,2,{'OnChange'}},{27,2,{'OnEvent'}}
,{25,2,{'New'}}}},{32,1,{'Logging'},{{36,2,{'messages'}},{35,2,{'logWarn'}},{37,2,{'parseError'}},{33,2,{'logError'}},{
34,2,{'logErrorNonFatal'}}}},{38,2,{'PubTypes'}},{39,1,{'State'},{{40,2,{'Computed'}},{46,2,{'unwrap'}},{42,2,{
'ForPairs'}},{43,2,{'ForValues'}},{41,2,{'ForKeys'}},{44,2,{'Observer'}},{45,2,{'Value'}}}},{15,1,{'Dependencies'},{{17,
2,{'initDependency'}},{16,2,{'captureDependencies'}},{20,2,{'useDependency'}},{18,2,{'sharedState'}},{19,2,{'updateAll'}
}}}}}}}},'0.3.5','WaxRuntime',string,task,setmetatable,error,newproxy,getmetatable,next,table,unpack,coroutine,script,
type,require,pcall,tostring,tonumber,_VERSION local H,I,J,K,L,M,N=m.insert,m.remove,m.freeze or function(H)return H end,
o.wrap,f.sub,f.match,f.gmatch if F and L(F,1,4)=='Lune'then local O,P=u(t,'@lune/task')if O and P then g=P end end local
O=g and g.defer local P,Q,R,S,T,U,V,W,X=O or function(P,...)K(P)(...)end,{[1]='Folder',[2]='ModuleScript',[3]='Script',[
4]='LocalScript',[5]='StringValue'},{},{},{},{},{},{},{}local aa,ab={GetFullName={{},function(Y)local Z,_=Y.Name,Y.
Parent while _ do Z=_.Name..'.'..Z _=_.Parent end return Z end},GetChildren={{},function(Y)local Z={}for _ in l,X[Y]do
H(Z,_)end return Z end},GetDescendants={{},function(Y)local Z={}for _ in l,X[Y]do H(Z,_)for aa,ab in l,_:GetDescendants(
)do H(Z,ab)end end return Z end},FindFirstChild={{'string','boolean?'},function(aa,ab,Y)local Z=X[aa]for _ in l,Z do if
_.Name==ab then return _ end end if Y then for ac in l,Z do return ac:FindFirstChild(ab,Y)end end end},FindFirstAncestor
={{'string'},function(aa,ab)local ac=aa.Parent while ac do if ac.Name==ab then return ac end ac=ac.Parent end end},
WaitForChild={{'string','number?'},function(aa,ab)return aa:FindFirstChild(ab)end}},{}for ac,Y in l,aa do local Z,_,ad=Y
[1],Y[2],{}for ae,af in l,Z do local ag,ah=M(af,'^([^%?]+)(%??)')ad[ae]={ag,ah}end ab[ac]=function(ag,...)if not X[ag]
then i("Expected ':' not '.' calling member function "..ac,2)end local ah={...}for ai,aj in l,ad do local ak=ah[ai]local
al,am,an=q(ak),aj[1],aj[2]if ak==nil and not an then i('Argument '..ak..' missing or nil',3)end if am~='any'and al~=am
and not(al=='nil'and an)then i('Argument '..ai..' expects type "'..am..'", got "'..al..'"',2)end end return _(ag,...)end
end local function ad(ae,af,ag)local ah,ai=(h({},{__mode='k'}))local function aj(ak)i(ak..
' is not a valid (virtual) member of '..ae..' "'..af..'"',3)end local function ak(al)i(
'Unable to assign (virtual) property '..al..'. Property is read only',3)end local al=j(true)local am=k(al)am.__metatable
=false am.__index=function(an,Z)if Z=='ClassName'then return ae elseif Z=='Name'then return af elseif Z=='Parent'then
return ag elseif ae=='StringValue'and Z=='Value'then return ai else local _=ab[Z]if _ then return _ end end for _ in l,
ah do if _.Name==Z then return _ end end aj(Z)end am.__newindex=function(an,Z,_)if Z=='ClassName'then ak(Z)elseif Z==
'Name'then af=_ elseif Z=='Parent'then if _==al then return end if ag~=nil then X[ag][al]=nil end ag=_ if _~=nil then X[
_][al]=true end elseif ae=='StringValue'and Z=='Value'then ai=_ else aj(Z)end end am.__tostring=function()return af end
X[al]=ah if ag~=nil then X[ag][al]=true end return al end local function ae(af,ag)local ah,ai,aj,ak=af[1],af[2],af[3],af
[4]local al=Q[ai]local am=aj and I(aj,1)or al local an=ad(al,am,ag)R[ah]=an if aj then for Z,_ in l,aj do an[Z]=_ end
end if ak then for Z,_ in l,ak do ae(_,an)end end return an end local af=ad('Folder','['..e..']')for ag,ah in l,c do ae(
ah,af)end for ai,aj in l,b do local ak=R[ai]S[ak]=aj T[ak]=ai local al=ak.ClassName if al=='LocalScript'or al=='Script'
then H(V,ak)end end local function ak(al)local am,an=al.ClassName,U[al]if an and am=='ModuleScript'then return n(an)end
local Z=S[al]local function _(ao)ao=v(ao)local ap,aq,ar=al:GetFullName(),M(ao,'[^:]+:(%d+): (.+)')if not aq or not G
then return ap..':*: '..(ar or ao)end aq=E(aq)local as=T[al]local at=G[as]local au=aq-at+1 if au<0 then au='?'end return
ap..':'..au..': '..ar end if am=='LocalScript'or am=='Script'then local ao,ap=u(Z)if not ao then i(_(ap),0)end else
local ao={u(Z)}local ap=I(ao,1)if not ap then local aq=I(ao,1)i(_(aq),0)end U[al]=ao return n(ao)end end function a(al)
local am=R[al]local function an(ao,...)local ap={u(ao,...)}local aq=I(ap,1)if not aq then i(ap[1],3)end return n(ap)end
local ao=J(h({},{__index=W,__newindex=function(ao,ap,aq)W[ap]=aq end,__len=function()return#W end,__iter=function()
return l,W end}))local ap,aq=J{version=d,envname=e,shared=ao,script=p,require=t},am local function ar(as,...)local at,au
,Z=q(as),'Attempted to call require with a non-ModuleScript','Attempted to call require with self'if at=='userdata'and X
[as]then if as.ClassName~='ModuleScript'then i(au,2)elseif as==am then i(Z,2)end return ak(as)elseif at=='string'and L(
as,1,1)~='@'then if#as==0 then i('Attempted to call require with empty string',2)end local _=am if L(as,1,1)=='/'then _=
af elseif L(as,1,2)=='./'then as=L(as,3)end local av for aw in N(as,'([^/]*)/?')do local ax=aw if aw=='..'then ax=
'Parent'end if ax~=''then local ay=_:FindFirstChild(ax)if not ay then local az=_.Parent if az then ay=az:FindFirstChild(
ax)end end if ay then _=ay elseif aw~=av and aw~='init'and aw~='init.server'and aw~='init.client'then i(
'Virtual script path "'..as..'" not found',2)end end av=aw end if _.ClassName~='ModuleScript'then i(au,2)elseif _==am
then i(Z,2)end return ak(_)end return an(t,as,...)end return ap,aq,ar end for al,am in l,V do P(ak,am)end do local an,ao
=(af:GetChildren())if#an==1 and an[1].ClassName=='ModuleScript'then ao=an[1]else for ap,aq in l,an do if aq.ClassName==
'ModuleScript'and aq.Name=='MainModule'then ao=aq break end end end if ao then return ak(ao)end end