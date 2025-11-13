local a local aa,ab,ac,ad,ae,af,ag,ah,ar,as,au,ax,az,aA,aB,aC,aD,aE,aF,aG,aH,aI={function()local b,c,d=a(1)local e
return(function(...)local f,g,h=game:GetService'Players',d(c.ReactLuau.React),d(c.ReactLuau.ReactRoblox)local i,j=g.
createElement,f.LocalPlayer local k,l,m=j.PlayerGui,i('ScreenGui',{},{i('TextLabel',{Text=
'Hello, Wax & Roact17! (react-roblox)',TextSize=32,Font=Enum.Font.Gotham,Size=UDim2.fromScale(1,1)})}),h.createRoot(
Instance.new'Folder')m:render(h.createPortal(l,k))end)()end,[3]=function()local b,c,d=a(3)local e return(function(...)
local f=d(c.Parent._Index['jsdotlua_luau-polyfill@1.2.3']['luau-polyfill'])return f end)()end,[4]=function()local b,c,d=
a(4)local e return(function(...)return d(c.Parent._Index['evaera_promise@4.0.0'].promise)end)()end,[5]=function()local b
,c,d=a(5)local e return(function(...)local f=c.Parent local g=d(f.LuauPolyfill)local h=d(c.React)local i=d(c.ReactLazy)
local j=d(f.Shared)return h end)()end,[6]=function()local b,c,d=a(6)local e return(function(...)local f=c.Parent.Parent
local g=d(f.LuauPolyfill)return g.Object.None end)()end,[7]=function()local b,c,d=a(7)local e return(function(...)local
f=c.Parent local g=f.Parent local h=d(g.LuauPolyfill)local i,j,k,l,m,n,o,p,q,r,s,t=d(f.ReactMutableSource),d(g.Shared).
ReactSharedInternals,d(f.ReactBaseClasses),d(f.ReactChildren),d(f.ReactElementValidator),d(f.ReactElement),d(f.
ReactCreateRef),d(f.ReactForwardRef),d(f.ReactHooks),d(f.ReactMemo),d(f.ReactContext),d(f.ReactLazy)local u,v,w=d(f[
'ReactBinding.roblox']),d(f['None.roblox']),d(g.Shared)local x,y,z=w.ReactSymbols,_G.__DEV__ or _G.
__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__,d(g.Shared)local A,B=if y then m.createElementWithValidation else n.
createElement,if y then m.cloneElementWithValidation else n.cloneElement return{Children=l,createMutableSource=i,
createRef=o.createRef,Component=k.Component,PureComponent=k.PureComponent,createContext=s.createContext,forwardRef=p.
forwardRef,lazy=t.lazy,memo=r.memo,useCallback=q.useCallback,useContext=q.useContext,useEffect=q.useEffect,
useImperativeHandle=q.useImperativeHandle,useDebugValue=q.useDebugValue,useLayoutEffect=q.useLayoutEffect,useMemo=q.
useMemo,useMutableSource=q.useMutableSource,useReducer=q.useReducer,useRef=q.useRef,useBinding=q.useBinding,useState=q.
useState,Fragment=x.REACT_FRAGMENT_TYPE,Profiler=x.REACT_PROFILER_TYPE,StrictMode=x.REACT_STRICT_MODE_TYPE,
unstable_DebugTracingMode=x.REACT_DEBUG_TRACING_MODE_TYPE,Suspense=x.REACT_SUSPENSE_TYPE,createElement=A,cloneElement=B,
isValidElement=n.isValidElement,__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=j,unstable_LegacyHidden=x.
REACT_LEGACY_HIDDEN_TYPE,createBinding=u.create,joinBindings=u.join,None=v,__subscribeToBinding=u.subscribe,Event=d(g.
Shared).Event,Change=d(g.Shared).Change,Tag=d(g.Shared).Tag,unstable_parseReactError=d(g.Shared).parseReactError}end)()
end,[8]=function()local b,c,d=a(8)local e return(function(...)local f,g,h=_G.__DEV__,_G.__COMPAT_WARNINGS__,c.Parent.
Parent local i=d(h.LuauPolyfill)local j=i.Object local k,l=d(h.Shared).console,d(h.Shared)local m,n=d(c.Parent.
ReactNoopUpdateQueue),{}if f then j.freeze(n)end local o,p=d(h.Shared).UninitializedState,{isReactComponent=true}
local function q(r)local s=string.match(r,'%.%u[%.%w]-$')if s then return string.gsub(s,'^%.','')end return r end
local function r(s,t,u)k.warn(
[[%s already defined '%s', but it also defining the deprecated Roact method '%s'. %s should only implement one of these methods, preferably using the non-deprecated name.]]
,s,u,t,s)end local function s(t,u,v)if f and g then local w,x=debug.info(3,'sln')k.warn(
[[%s is using method '%s', which is no longer supported and should be updated to '%s'
File: %s:%s]],t,u,v,q(w),tostring(
x))end end local t={didMount='componentDidMount',shouldUpdate='shouldComponentUpdate',willUpdate=
'UNSAFE_componentWillUpdate',didUpdate='componentDidUpdate',willUnmount='componentWillUnmount'}local function u(v,w,x)if
t[w]~=nil then if v[t[w]]~=nil then r(v.__componentName,w,t[w])elseif w=='willUpdate'and v.componentWillUpdate then r(v.
__componentName,w,'UNSAFE_componentWillUpdate')else s(v.__componentName,w,t[w])end w=t[w]end rawset(v,w,x)end local v={
__newindex=u,__index=p,__tostring=function(v)return v.__componentName end}local w,x,y=(setmetatable({__componentName=
'Component'},v)),if not _G.__TESTEZ_RUNNING_TEST__ then 900 else 0,1 local z=table.create(x)for A=1,x do table.insert(z,
{props=nil,context=nil,state=o,__refs=n,__updater=m})end local function A(B,C,D)if f and(D)~=nil then k.warn(
[[Received a `callback` argument to `setState` during initialization of "%s". The callback behavior is not supported when using `setState` in `init`.

Consider defining similar behavior in a `compontentDidMount` method instead.]]
,B.__componentName)end local E=C and type(C)if C==nil or(E~='table'and E~='function')then error
[[setState(...): takes an object of state variables to update or a function which returns an object of state variables.]]
end local F,G=(B.state)if E=='function'then G=C(F,B.props)else G=C end B.state=j.assign({},F,G)end function w.extend(B,C
)if C==nil then if g then k.warn
[[Component:extend() accepting no arguments is deprecated, and will not be supported in a future version of Roact. Please provide an explicit name.]]
end C=''elseif type(C)~='string'then error'Component class name must be a string'end local D={__componentName=C,setState
=B.setState,forceUpdate=B.forceUpdate,init=nil}D.__index=D function D.__ctor(E,F,G)local H if y<=x then H=z[y]H.props=E
H.context=F z[y]=nil y+=1 else H={props=E,context=F,state=o,__refs=n,__updater=G or m}end H=setmetatable(H,D)if D.init
and type(D.init)=='function'then H.setState=A D.init(H,E,F)H.setState=nil end return(H)end setmetatable(D,getmetatable(B
))return(D)end function w.setState(B,C,D)if C~=nil and type(C)~='table'and type(C)~='function'then error
[[setState(...): takes an object of state variables to update or a function which returns an object of state variables.]]
end B.__updater.enqueueSetState(B,C,D,'setState')end function w.forceUpdate(B,C)B.__updater.enqueueForceUpdate(B,C,
'forceUpdate')end if f then local B,C={isMounted={'isMounted',
[[Instead, make sure to clean up subscriptions and pending requests in componentWillUnmount to prevent memory leaks.]]},
replaceState={'replaceState',
[[Refactor your code to use setState instead (see https://github.com/facebook/react/issues/3236).]]}},function(B,C)(w)[B
]=function()k.warn('%s(...) is deprecated in plain JavaScript React classes. %s',C[1],C[2])return nil end end for D,E in
B do if B[D]~=nil then C(D,B[D])end end end local B=w:extend'PureComponent';(B).extend=w.extend local C={
isReactComponent=true,isPureReactComponent=true}setmetatable(B,{__newindex=u,__index=C,__tostring=function(D)return D.
__componentName end})return{Component=w,PureComponent=B}end)()end,[9]=function()local b,c,d=a(9)local e return(function(
...)local f=c.Parent.Parent local g,h,i=d(f.LuauPolyfill),d(f.Shared).ReactSymbols,d(f.Shared)local j,k=g.Symbol,d(c.
Parent['createSignal.roblox'])local l=j'BindingImpl'local m,n={},{}function n.getValue(o)return m.getValue(o)end
function n.map(o,p)return m.map(o,p)end local o={__index=n,__tostring=function(o)return string.format('RoactBinding(%s)'
,tostring(o:getValue()))end}function m.update(p,q)return(p[l]).update(q)end function m.subscribe(p,q)return(p[l]).
subscribe(q)end function m.getValue(p)return(p[l]):getValue()end function m.create(p)local q,r=k()local s={value=p,
subscribe=q}function s.update(t)s.value=t r(t)end function s.getValue()return s.value end local t if _G.__DEV__ then t=
debug.traceback('Binding created at:',3)end return(setmetatable({['$$typeof']=h.REACT_BINDING_TYPE,[l]=s,_source=t},o)),
s.update end function m.map(p,q)if _G.__DEV__ then assert(typeof(p)=='table'and p['$$typeof']==h.REACT_BINDING_TYPE,
'Expected `self` to be a binding')assert(typeof(q)=='function','Expected arg #1 to be a function')end local r={}function
r.subscribe(s)return m.subscribe(p,function(t)s(q(t))end)end function r.update(s)error(
[[Bindings created by Binding:map(fn) cannot be updated directly]],2)end function r.getValue()return q(p:getValue())end
local s if _G.__DEV__ then s=debug.traceback('Mapped binding created at:',3)end return(setmetatable({['$$typeof']=h.
REACT_BINDING_TYPE,[l]=r,_source=s},o))end function m.join(p)if _G.__DEV__ then assert(typeof(p)=='table',
'Expected arg #1 to be of type table')for q,r in p do if typeof(r)~='table'or(r)['$$typeof']~=h.REACT_BINDING_TYPE then
local s=([[Expected arg #1 to contain only bindings, but key %q had a non-binding value]]):format(tostring(q))error(s,2)
end end end local q={}local function r()local s={}for t,u in pairs(p)do s[t]=u:getValue()end return s end function q.
subscribe(s)local t={}for u,v in p do t[u]=m.subscribe(v,function(w)s(r())end)end return function()if t==nil then return
end for w,x in t do x()end t=nil end end function q.update(s)error(
[[Bindings created by joinBindings(...) cannot be updated directly]],2)end function q.getValue()return r()end local s if
_G.__DEV__ then s=debug.traceback('Joined binding created at:',2)end return(setmetatable({['$$typeof']=h.
REACT_BINDING_TYPE,[l]=q,_source=s},o))end return m end)()end,[10]=function()local b,c,d=a(10)local e return(function(
...)local f=c.Parent.Parent local g=d(f.Shared)local h,i=d(f.Shared).invariant,d(f.Shared).ReactSymbols local j,k,l,m=i.
getIteratorFn,i.REACT_ELEMENT_TYPE,i.REACT_PORTAL_TYPE,d(f.LuauPolyfill)local n=m.Array local o=d(c.Parent.ReactElement)
local p,q,r,s=o.isValidElement,o.cloneAndReplaceKey,'.',':'local function t(u)local v=string.gsub(u,'=','=0')v=string.
gsub(v,':','=2')return'$'..v end local function u(v)return v end local function v(w,x)if typeof(w)=='table'and w~=nil
and w.key~=nil then return t(tostring(w.key))end return tostring(x)end local function w(x,y,z,A,B)local C=typeof(x)if C
=='nil'or C=='boolean'or C=='userdata'then x=nil end local D=false if x==nil then D=true else if C=='string'or C==
'number'then D=true elseif C=='table'then local E=(x)['$$typeof']if E==k or E==l then D=true end end end if D then local
E=x local F,G=B(E),if A==''then r..v(E,1)else A if n.isArray(F)then local H=''if G~=nil then H=u(G)..'/'end w(F,y,H,'',
function(I)return I end)elseif F~=nil then if p(F)then local H=(F).key F=q(F,z..(if H and(not E or(E).key~=H)then u(
tostring(H))..'/'else'')..G)end table.insert(y,F)end return 1 end local E,F,G,H=0,if A==''then r else A..s if n.isArray(
x)then for I=1,#(x)do G=(x)[I]H=F..v(G,I)E+=w(G,y,z,H,B)end else local I=j(x)if typeof(I)=='function'then local J=x
local K,L,M=I(J),1 M=K.next()while not M.done do G=M.value H=F..v(G,L)L+=1 E+=w(G,y,z,H,B)M=K.next()end end end return E
end local function x(y,z,A)if y==nil then return nil end local B,C={},1 w(y,B,'','',function(D)local E=z(D,C)C+=1 return
E end)return B end local function y(z)local A=0 x(z,function()A+=1 return end)return A end local function z(A,B,C)x(A,
function(...)B(...)return end,C)end local function A(B)return x(B,function(C)return C end)or{}end local function B(C)h(
p(C),[[React.Children.only expected to receive a single React element child.]])return C end return{forEach=z,map=x,count
=y,only=B,toArray=A}end)()end,[11]=function()local b,c,d=a(11)local e return(function(...)local f=c.Parent.Parent local
g=d(f.Shared)local h,i=g.console,d(f.Shared).ReactSymbols local j,k=i.REACT_PROVIDER_TYPE,i.REACT_CONTEXT_TYPE local l={
}l.createContext=function(m,n)local o={['$$typeof']=k,_calculateChangedBits=n,_currentValue=m,_currentValue2=m,
_threadCount=0,Provider=(nil),Consumer=(nil),displayName=nil,_currentRenderer=nil,_currentRenderer2=nil}o.Provider={[
'$$typeof']=j,_context=o}local p=false if _G.__DEV__ then local q={['$$typeof']=k,_context=o,_calculateChangedBits=o.
_calculateChangedBits}setmetatable(q,{__index=function(r,s)if s=='_currentValue'then return o._currentValue elseif s==
'_currentValue2'then return o._currentValue2 elseif s=='_threadCount'then return o._threadCount elseif s=='displayName'
then return o.displayName end return nil end,__newindex=function(r,s,t)if s=='_currentValue'then o._currentValue=t
elseif s=='_currentValue2'then o._currentValue2=t elseif s=='_threadCount'then o._threadCount=t elseif s=='displayName'
then if not p then h.warn('Setting `displayName` on Context.Consumer has no effect. '..
[[You should set it directly on the context with Context.displayName = ]]..t..'.')p=true end end end})o.Consumer=(q)else
o.Consumer=o end if _G.__DEV__ then o._currentRenderer=nil o._currentRenderer2=nil end return o end return l end)()end,[
12]=function()local b,c,d=a(12)local e return(function(...)local f=c.Parent.Parent local g=d(f.Shared)local h,i=d(c.
Parent['ReactBinding.roblox']),{}i.createRef=function()local j,k=h.create(nil)local l={}if _G.__DEV__ then j._source=
debug.traceback('Ref created at:',1)end setmetatable(l,{__index=function(m,n)if n=='current'then return j:getValue()else
return(j)[n]end end,__newindex=function(m,n,o)if n=='current'then h.update(j,o)end(j)[n]=o end,__tostring=function(m)
return string.format('Ref(%s)',tostring(j:getValue()))end})return(l)end return i end)()end,[13]=function()local b,c,d=a(
13)local e return(function(...)local f,g=_G.__DEV__,c.Parent.Parent local h=d(g.LuauPolyfill)local i=h.Error local j,k=
d(g.Shared).console,d(g.Shared)local l=d(c.Parent.ReactLazy)local m,n,o,p,q,r,s=d(g.Shared).getComponentName,d(g.Shared)
.ReactSymbols.REACT_ELEMENT_TYPE,d(g.Shared).ReactSharedInternals.ReactCurrentOwner,{key=true,ref=true,__self=true,
__source=true}if f then s={}end local t={}local function u(v)if f then if v.ref~=nil and type(v.ref)=='table'then if(v.
ref).isReactWarning then return false end end end return v.ref~=nil end local function v(w)if f then if w.key~=nil and
type(w.key)=='table'then if(w.key).isReactWarning then return false end end end return w.key~=nil end local w={
isReactWarning=true}local function x(y,z)local A=function()if f then if not q then q=true j.error(
[[%s: `key` is not a prop. Trying to access it will result in `nil` being returned. If you need to access the same value within the child component, you should pass it as a different prop. (https://reactjs.org/link/special-props)]]
,z)end end end y.key=nil setmetatable(y,{__index=function(B,C)if C=='key'then A()return w end return nil end})end
local function y(z,A)local B=function()if f then if not r then r=true j.error(
[[%s: `ref` is not a prop. Trying to access it will result in `nil` being returned. If you need to access the same value within the child component, you should pass it as a different prop. (https://reactjs.org/link/special-props)]]
,A)end end end z.ref=nil setmetatable(z,{__index=function(C,D)if D=='ref'then B()return w end return nil end})end
local function z(A)if f then if type(A.ref)=='string'and o.current then local B=m(o.current.type)if not s[B]then error(
string.format(
[[Component "%s" contains the string ref "%s". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref]]
,B or'Unknown',A.ref))end end end end local function A(B,C,D,E,F,G,H)local I={type=B,key=C,ref=D,props=H,_owner=G}I[
'$$typeof']=n if f then local J={validated=false}I._store=setmetatable({},{__index=J,__newindex=function(K,L,M)if L==
'validated'then J.validated=M else rawset(K,L,M)end end})setmetatable(I,{__index={_self=E,_source=F}})end return I end t
.jsx=function(B,C,D)error'JSX is currently unsupported'end t.jsxDEV=function(B,C,D,E,F)error
'JSX is currently unsupported'return nil end local function B(C,D,...)local E,F,G,H,I=if D~=nil then table.clone(D)else{
}if D~=nil then if u(D)then G=((D)).ref if f then z((D))end end if v(D)then local J=(D).key if type(J)=='number'then F=J
else F=tostring(J)end end I=if((D)).__source==nil then nil else((D)).__source if E.key~=nil then E.key=nil end if E.ref
~=nil then E.ref=nil end if E.__self~=nil then E.__self=nil end if E.__source~=nil then E.__source=nil end end local J=
select('#',...)if J==1 then E.children=select(1,...)elseif J>1 then local K=table.create(J)for L=1,J do local M=select(L
,...)table.insert(K,M)end if f then table.freeze(K)end E.children=K end if type(C)=='table'and(C).defaultProps then
local K=(C).defaultProps for L,M in(K)do if E[L]==nil then E[L]=((K))[L]end end end if f then if F or G then local K if
type(C)=='function'then K=debug.info(C,'n')or'<function>'elseif type(C)=='table'then K=((C).displayName or(C).name)or
'Unknown'else K=C end if F then x(E,K)end if G then y(E,K)end end if I==nil then I={fileName=debug.info(3,'s'),
lineNumber=debug.info(3,'l')}end end return A(C,F,G,H,I,o.current,E)end t.createElement=B t.cloneAndReplaceKey=function(
C,D)local E=A(C.type,D,C.ref,C._self,C._source,C._owner,C.props)return E end t.cloneElement=function(C,D,...)if C==nil
then error(i.new([[React.cloneElement(...): The argument must be a React element, but you passed ]]..tostring(C)))end
local E=C.props local F,G,H,I,J=if E~=nil then table.clone(E)else{},C.key,C.ref,C._source,C._owner if D~=nil then local
K=D.ref if K~=nil then H=K J=o.current else u(D)end local L=D.key if L~=nil then if type(L)=='number'then G=L else G=L
or'nil'end else v((D))end end local K=C.type local L=if type(K)=='table'then K.defaultProps else nil if D~=nil then for
M,N in D do if(D)[M]~=nil and not p[M]then if(D)[M]==nil and L~=nil then(F)[M]=(L)[M]else(F)[M]=(D)[M]end end end end
local M=select('#',...)if M==1 then F.children=select(1,...)elseif M>1 then(F).children={...}end return A(C.type,G,H,nil
,I,J,(F))end t.isValidElement=function(C)return type(C)=='table'and C['$$typeof']==n end return t end)()end,[14]=
function()local b,c,d=a(14)local e return(function(...)local f=c.Parent.Parent local g=d(f.LuauPolyfill)local h=g.Array
local i,j=g.Boolean,g.Object local k,l=d(f.Shared).console,g.util.inspect local m=d(f.Shared)local n,o,p=d(f.Shared).
isValidElementType,d(f.Shared).getComponentName,d(f.Shared).ReactSymbols local q,r,s,t,u,v,w,x,y=p.getIteratorFn,p.
REACT_FORWARD_REF_TYPE,p.REACT_MEMO_TYPE,p.REACT_FRAGMENT_TYPE,p.REACT_ELEMENT_TYPE,d(f.Shared).ReactFeatureFlags.
warnAboutSpreadingKeyToJSX,d(f.Shared).checkPropTypes,d(f.Shared).ReactSharedInternals.ReactCurrentOwner,d(c.Parent.
ReactElement)local z,A,B,C,D,E,F=y.isValidElement,y.createElement,y.cloneElement,y.jsxDEV,d(f.Shared).
ReactSharedInternals.ReactDebugCurrentFrame.setExtraStackFrame,d(f.Shared).ReactComponentStackFrame.
describeUnknownElementTypeFrameInDEV,{}local function G(H)if _G.__DEV__ then if H then local I,J=(H._owner)if I then J=I
.type end local K=E(H.type,H._source,J);(D)(K)else(D)(nil)end end end local H if _G.__DEV__ then H=false end
local function I(J,K)return J[K]~=nil end local function J()if x.current then local K=o(x.current.type)if K then return
'\n\nCheck the render method of `'..K..'`.'end end return''end local function K(L)if L~=nil then local M,N=string.gsub(L
.fileName,'^.*[\\/]',''),L.lineNumber return'\n\nCheck your code at '..M..':'..N..'.'end return''end local function L(M)
if M~=nil then return K(M.__source)end return''end local M={}local function N(O)local P=J()if not i.toJSBoolean(P)then
local Q=if typeof(O)=='string'then O else if typeof(O)=='table'then O.displayName or O.name else nil if not Q and
typeof(O)=='function'then local R=debug.info(O,'n')Q=if R~=''then R else nil end if Q then P=string.format(
'\n\nCheck the top-level render call using <%s>.',Q)end end return P end local function O(P,Q,R)if P._store==nil or P.
_store.validated then return end(P._store).validated=true if(P.key~=nil)~=(R~=nil)then return end local S=N(Q)if M[S]
then return end M[S]=true local T=''if P and P._owner and P._owner~=x.current then T=string.format(
' It was passed a child from %s.',tostring(o(P._owner.type)))end if _G.__DEV__ then G(P)if P.key~=nil and R~=nil then k.
error(
[[Child element received a "key" prop ("%s") in addition to a key in the "children" table of its parent ("%s"). Please provide only one key definition. When both are present, the "key" prop will take precedence.%s%s See https://reactjs.org/link/warning-keys for more information.]]
,tostring(P.key),tostring(R),S,T)else k.error(
[[Each child in a list should have a unique "key" prop.%s%s See https://reactjs.org/link/warning-keys for more information.]]
,S,T)end G(nil)end end local function P(Q,R)if typeof(Q)~='table'then return end if h.isArray(Q)then for S=1,#Q do local
T=Q[S]if z(T)then O(T,R)end end elseif z(Q)then if Q._store then Q._store.validated=true end elseif Q then local S=q(Q)
if typeof(S)=='function'then if S~=Q.entries then local T=S(Q)local U=T.next()while not U.done do if z(U.value)then O(U.
value,R,U.key)end U=T.next()end end end end end local function Q(R)if _G.__DEV__ or _G.
__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then local S=R.type if S==nil or typeof(S)=='string'then return end
local T,U if typeof(S)=='function'then return elseif typeof(S)=='table'then T=S.propTypes U=S.validateProps else return
end if T or U then local V=o(S)w(T,U,R.props,'prop',V,R)elseif(S).PropTypes~=nil and not H then H=true local V=o(S)k.
error([[Component %s declared `PropTypes` instead of `propTypes`. Did you misspell the property assignment?]],V or
'Unknown')end if(S).getDefaultProps~=nil then k.error
[[getDefaultProps is only used on classic React.createClass definitions. Use a static property named `defaultProps` instead.]]
end end end local function R(S)if _G.__DEV__ then local T=j.keys(S.props)for U=1,#T do local V=T[U]if V~='children'and V
~='key'then G(S)k.error(
[[Invalid prop `%s` supplied to `React.Fragment`. React.Fragment can only have `key` and `children` props.]],V)G(nil)
break end end if S.ref~=nil then G(S)k.error'Invalid attribute `ref` supplied to `React.Fragment`.'G(nil)end end end
local function S(T,U,V,W,X,Y)local Z=n(T)if not Z then local _=''if T==nil or(typeof(T)=='table'and#j.keys(T)==0)then _
..=(
[[ You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.]]
)end local aa=K(X)if aa then _..=aa else _..=J()end local ab if T==nil then ab='nil'elseif h.isArray(T)then ab='array'
elseif typeof(T)=='table'and T['$$typeof']==u then ab=string.format('<%s />',o(T.type)or'Unknown')_..=
[[ Did you accidentally export a JSX literal or Element instead of a component?]]else ab=typeof(T)_..='\n'..l(T)end if
_G.__DEV__ then k.error(
[[React.jsx: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s]]
,ab,_)end end local aa=C(T,U,V,X,Y)if aa==nil then return aa end if Z then local ab=U.children if ab~=nil then if W then
if h.isArray(ab)then for _=1,#ab do P(ab[_],T)end j.freeze(ab)else if _G.__DEV__ then k.error
[[React.jsx: Static children should always be an array. You are likely explicitly calling React.jsxs or React.jsxDEV. Use the Babel transform instead.]]
end end else P(ab,T)end end end if _G.__DEV__ then if v then if I(U,'key')then k.error(
[[React.jsx: Spreading a key to JSX is a deprecated pattern. Explicitly pass a key after spreading props in your JSX call. E.g. <%s {...props} key={key} />]]
,o(T)or'ComponentName')end end end if T==t then R((aa))else Q((aa))end return aa end F.jsxWithValidation=S F.
jsxWithValidationStatic=function(aa,ab,T)return S(aa,ab,T,true)end F.jsxWithValidationDynamic=function(aa,ab,T)return S(
aa,ab,T,false)end local function aa(ab,T,...)local U=n(ab)if not U then local V=''if ab==nil or(typeof(ab)=='table'and#j
.keys(ab)==0)then V..=(
[[ You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.]]
)end local W=L(T)if W then V..=W else V..=J()end local X if ab==nil then X='nil'elseif h.isArray(ab)then X='array'elseif
ab~=nil and typeof(ab)=='table'and ab['$$typeof']==u then X=string.format('<%s />',o((ab).type)or'Unknown')V..=
[[ Did you accidentally export a JSX literal or Element instead of a component?]]else X=typeof(ab)if ab~=nil then V..=
'\n'..l(ab)end end if _G.__DEV__ then k.error(
[[React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s]]
,X,V)end end local V=A(ab,T,...)if V==nil then return V end if U then for W=1,select('#',...)do P(select(W,...),ab)end
end if ab==t then R(V)else Q(V)end return V end F.createElementWithValidation=aa F.cloneElementWithValidation=function(
ab,T,...)local U,V={ab,T,...},B(ab,T,...)for W=3,#U do P(U[W],V.type)end Q(V)return V end return F end)()end,[15]=
function()local aa,ab,b=a(15)local c return(function(...)local d=ab.Parent.Parent local e,f,g=b(d.Shared).console,b(d.
Shared).ReactSymbols,b(d.Shared)local h,i,j=f.REACT_FORWARD_REF_TYPE,f.REACT_MEMO_TYPE,{}j.forwardRef=function(k)if _G.
__DEV__ then if typeof(k)=='table'and(k)['$$typeof']==i then e.error
[[forwardRef requires a render function but received a `memo` component. Instead of forwardRef(memo(...)), use memo(forwardRef(...)).]]
elseif typeof(k)~='function'then e.error('forwardRef requires a render function but was given %s.',typeof(k))else local
l,m=debug.info(k,'a')if l~=0 and l~=2 then e.error(
[[forwardRef render functions accept exactly two parameters: props and ref. %s]],(function()if l==1 then return
'Did you forget to use the ref parameter?'end return'Any additional parameter will be undefined.'end)())end end end
local l={['$$typeof']=h,render=k}if _G.__DEV__ then local m setmetatable(l,{__index=function(n,o)if o=='displayName'then
return m end return rawget(n,o)end,__newindex=function(n,o,p)if o=='displayName'then m=p else rawset(n,o,p)end end})end
return(l)end return j end)()end,[16]=function()local aa,ab,b=a(16)local c return(function(...)local d=ab.Parent.Parent
local e=b(d.LuauPolyfill)local f=e.Array local g,h=b(d.Shared).console,b(d.Shared)local i=b(d.Shared)local j=b(d.Shared)
.ReactSharedInternals.ReactCurrentDispatcher local function k()local l=j.current if _G.__DEV__ then if l==nil then g.
error
[[Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]]
end end return l end local l={}local function m(n,o,...)local p=k()if _G.__DEV__ then if o~=nil then g.error(
[[useContext() second argument is reserved for future use in React. Passing it is not supported. You passed: %s.%s]],o,(
typeof(o)=='number'and f.isArray{...})and
[[


Did you call Array.map(useContext)? Calling Hooks inside a loop is not supported. Learn more at https://reactjs.org/link/rules-of-hooks]]
or'')end if(n)._context~=nil then local q=(n)._context if q.Consumer==n then g.error
[[Calling useContext(Context.Consumer) is not supported, may cause bugs, and will be removed in a future major release. Did you mean to call useContext(Context) instead?]]
elseif q.Provider==n then g.error
[[Calling useContext(Context.Provider) is not supported. Did you mean to call useContext(Context) instead?]]end end end
return p.useContext(n,o)end l.useContext=m local function n(o,...)local p=k()return p.useState(o,...)end l.useState=n
local function o(p,q,r)local s=k()return s.useReducer(p,q,r)end l.useReducer=o local function p(q)local r=k()return r.
useRef(q)end l.useRef=p local function q(r)local s=k()return s.useBinding(r)end l.useBinding=q local function r(s,t)
local u=k()return u.useEffect(s,t)end l.useEffect=r local function s(t,u)local v=k()return v.useLayoutEffect(t,u)end l.
useLayoutEffect=s local function t(u,v)local w=k()return w.useCallback(u,v)end l.useCallback=t local function u(v,w)
local x=k()return x.useMemo(v,w)end l.useMemo=u local function v(w,x,y)local z=k()return z.useImperativeHandle(w,x,y)end
l.useImperativeHandle=v local function w(x,y)if _G.__DEV__ then local z=k()return z.useDebugValue(x,y)end return nil end
l.useDebugValue=w l.emptyObject={}l.useOpaqueIdentifier=function()local x=k()return x.useOpaqueIdentifier()end l.
useMutableSource=function(x,y,z)local A=k()return A.useMutableSource(x,y,z)end return l end)()end,[17]=function()local
aa,ab,b=a(17)local c return(function(...)local d=ab.Parent.Parent local e=b(d.Shared)local f,g=e.console,b(d.
LuauPolyfill)local h,i=g.util.inspect,b(d.Shared)local j=b(d.Shared).ReactSymbols local k,l,m,n,o=j.REACT_LAZY_TYPE,-1,0
,1,2 function lazyInitializer(p)if p._status==l then local q=p._result local r,s=q(),p s._status=m s._result=r r:
andThen(function(t)if p._status==m then local u=t.default if _G.__DEV__ then if u==nil then f.error(
[[lazy: Expected the result of a dynamic import() call. Instead received: `%s`

Your code should look like: 
  local MyComponent = lazy(function() return reqquire(script.Parent.MyComponent) end)]]
,h(t))end end local v=p v._status=n v._result=u end end,function(t)if p._status==m then local u=p u._status=o u._result=
t end end)end if p._status==n then return p._result else error(p._result)end end local p={}p.lazy=function(q)local r={
_status=-1,_result=q}local s={['$$typeof']=k,_payload=r,_init=lazyInitializer}if _G.__DEV__ then local t,u setmetatable(
s,{__index=function(v,w)if w=='defaultProps'then return t end if w=='propTypes'then return u end return end,__newindex=
function(v,w,x)if w=='defaultProps'then f.error
[[React.lazy(...): It is not supported to assign `defaultProps` to a lazy component import. Either specify them where the component is defined, or create a wrapping component around it.]]
t=x setmetatable(v,{__index=function()end,__newindex=function()end})end if w=='propTypes'then f.error
[[React.lazy(...): It is not supported to assign `propTypes` to a lazy component import. Either specify them where the component is defined, or create a wrapping component around it.]]
u=x setmetatable(v,{__index=function()end,__newindex=function()end})end end})end return s end return p end)()end,[18]=
function()local aa,ab,b=a(18)local c return(function(...)local d=ab.Parent.Parent local e=b(d.Shared)local f,g=e.console
,b(d.LuauPolyfill)local h,i,j=g.Array,g.Object,g.util.inspect local k=e.ReactSymbols local l,m,n,o,p=k.REACT_MEMO_TYPE,k
.REACT_ELEMENT_TYPE,e.isValidElementType,e.getComponentName,{}p.memo=function(q,r)if _G.__DEV__ then local s=n(q)if not
s then local t=''if q==nil or(typeof(q)=='table'and#i.keys(q)==0)then t=t..(
[[ You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.]]
)end local u if q==nil then u='nil'elseif h.isArray(q)then u='array'elseif q~=nil and typeof(q)=='table'and(q)[
'$$typeof']==m then u=string.format('<%s />',o((q).type)or'UNKNOWN')t=
[[ Did you accidentally export a JSX literal or Element instead of a component?]]else u=typeof(q)if q~=nil then t='\n'..
j(q)end end f.error([[memo: The first argument must be a component. Instead received: `%s`.%s]],u,t)end end local s={[
'$$typeof']=l,type=q,compare=r or nil}if _G.__DEV__ then local t setmetatable(s,{__index=function(u,v)if v==
'displayName'then return t end return rawget(u,v)end,__newindex=function(u,v,w)if v=='displayName'then t=w if typeof(q)
=='table'and(q).displayName==nil then(q).displayName=t end else rawset(u,v,w)end end})end return s end return p end)()
end,[19]=function()local aa,ab,b=a(19)local c return(function(...)local d=ab.Parent.Parent local e=b(d.Shared)
local function f(g,h)local i={_getVersion=h,_source=g,_workInProgressVersionPrimary=nil,_workInProgressVersionSecondary=
nil}if _G.__DEV__ then i._currentPrimaryRenderer=nil i._currentSecondaryRenderer=nil end return i end return f end)()end
,[20]=function()local aa,ab,b=a(20)local c return(function(...)local d=ab.Parent.Parent local e,f=b(d.Shared).console,{}
local function g(h,i)if _G.__DEV__ then local j=h.__componentName or'ReactClass'local k=j..'.'..i if f[k]then return end
e.error(
[[Can't call %s on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the %s component's `init` method.]]
,i,j)f[k]=true end end local h={isMounted=function(h)return false end,enqueueForceUpdate=function(h,i,j)g(h,
'forceUpdate')end,enqueueReplaceState=function(h,i,j,k)g(h,'replaceState')end,enqueueSetState=function(h,i,j,k)g(h,
'setState')end}return h end)()end,[21]=function()local aa,ab,b=a(21)local c return(function(...)local function d()local
e,f,g={},{},false local function h(i)assert(typeof(i)=='function','Can only subscribe to signals with a function.')local
j={callback=i,disconnected=false}if g and not e[i]then f[i]=j end e[i]=j local function k()assert(not j.disconnected,
'Listeners can only be disconnected once.')j.disconnected=true e[i]=nil f[i]=nil end return k end local function i(...)g
=true for j,k in e do if not k.disconnected and not f[j]then j(...)end end g=false table.clear(f)end return h,i end
return d end)()end,[22]=function()local aa,ab,b=a(22)local c return(function(...)local d=b(ab.ReactDebugTools)return d
end)()end,[23]=function()local aa,ab,b=a(23)local c return(function(...)local d=ab.Parent.Parent local e=b(d.
LuauPolyfill)local f,g,h,i=e.Array,e.Error,e.Map,e.Object local j,k,l=e.String,{},b(d.Shared)local m=b(d.ReactReconciler
)local n=b(d.Shared)local o=b(d.ReactReconciler){}local p=o.ReactTypeOfMode.NoMode local q,r={parse=function(q)if q.
stack==nil then return{}end local r=f.filter(string.split(q.stack,'\n'),function(r)return string.find(r,'^LoadedCode')~=
nil end)return f.map(r,function(s)local t=string.match(s,'function (%w+)$')return{source=s,functionName=t}end)end},b(d.
Shared)local s,t=r.ReactSharedInternals,r.ReactSymbols local u,v=t.REACT_OPAQUE_ID_TYPE,o.ReactWorkTags local w,x,y,z,A=
v.FunctionComponent,v.SimpleMemoComponent,v.ContextProvider,v.ForwardRef,v.Block local B={}local C,D local E
local function F()if C==nil then local G,H=(h.new())do local I,J=pcall(function()E.useContext{_currentValue=nil}E.
useState(nil)E.useReducer(function(I,J)return I end,nil)E.useRef(nil)E.useLayoutEffect(function()end)E.useEffect(
function()end)E.useImperativeHandle(nil,function()return nil end)E.useDebugValue(nil)E.useCallback(function()end)E.
useMemo(function()return nil end)end)do H=B B={}end if not I then error(J)end end for I=1,#H do local J=H[I]G:set(J.
primitive,q.parse(J.stackError))end C=G end return C end local G local function H()local I=G if I~=nil then G=I.next end
return I end local function I(J,K)return J._currentValue end local function J(K,L)table.insert(B,{primitive='Context',
stackError=g.new(),value=K._currentValue})return K._currentValue end local function K(L)local M=H()local N=if M~=nil
then M.memoizedState else if typeof(L)=='function'then L()else L table.insert(B,{primitive='State',stackError=g.new(),
value=N})return N,function(O)end end local function L(M,N,O)local P,Q=(H())if P~=nil then Q=P.memoizedState else Q=if O
~=nil then O(N)else(N)end table.insert(B,{primitive='Reducer',stackError=g.new(),value=Q})return Q,function(R)end end
local function M(N)local O=H()local P=if O~=nil then O.memoizedState else{current=N}table.insert(B,{primitive='Ref',
stackError=g.new(),value=P.current})return P end local function N(O)local P=H()local Q=if P~=nil then P.memoizedState
else({getValue=function(Q)return O end})table.insert(B,{primitive='Binding',stackError=g.new(),value=Q:getValue()})
return Q,function(R)end end local function O(P,Q)H()table.insert(B,{primitive='LayoutEffect',stackError=g.new(),value=P}
)end local function P(Q,R)H()table.insert(B,{primitive='Effect',stackError=g.new(),value=Q})end local function Q(R,S,T)
H()local U if R~=nil and typeof(R)=='table'then U=R.current end table.insert(B,{primitive='ImperativeHandle',stackError=
g.new(),value=U})end local function R(S,T)table.insert(B,{primitive='DebugValue',stackError=g.new(),value=if typeof(T)==
'function'then T(S)else S})end local function S(T,U)local V=H()table.insert(B,{primitive='Callback',stackError=g.new(),
value=if V~=nil then V.memoizedState[1]else T})return T end local function T(U,V)local W=H()local X=if W~=nil then W.
memoizedState[1]else{U()}table.insert(B,{primitive='Memo',stackError=g.new(),value=X})return table.unpack(X)end
local function U(V,W,X)H()H()H()H()local Y=W(V._source)table.insert(B,{primitive='MutableSource',stackError=g.new(),
value=Y})return Y end local function V()local W=H()if D and D.mode==p then H()end local X=if W==nil then nil else W.
memoizedState if X and(X)['$$typeof']==u then X=nil end table.insert(B,{primitive='OpaqueIdentifier',stackError=g.new(),
value=X})return X end E={readContext=I,useCallback=S,useContext=J,useEffect=P,useImperativeHandle=Q,useDebugValue=R,
useLayoutEffect=O,useMemo=T,useReducer=L,useRef=M,useBinding=N,useState=K,useMutableSource=U,useOpaqueIdentifier=V}local
W=1 local function X(Y,Z,_)local ac=Z[_].source for ad=1,#Y do if Y[ad].source==ac then local ae,af,ag=_+1,ad+1,false
while ae<=#Z and af<=#Y do if Y[af].source~=Z[ae].source then ag=true break end ae+=1 af+=1 end if not ag then return ad
end end end return-1 end local function ac(ad,ae)local af=X(ae,ad,W)if af~=-1 then return af end for ag=1,math.min(#ad,5
)do af=X(ae,ad,ag)if af~=-1 then W=ag return af end end return-1 end local function ad(ae,af)if not ae or ae==''then
return false end local ag='use'..tostring(af)if string.len(ae)<string.len(ag)then return false end return j.lastIndexOf(
ae,ag)==(string.len(ae)-string.len(ag)+1)end local function ae(af,ag)local Y=F()local Z=Y:get(ag.primitive)if Z==nil
then return-1 end for _=1,math.min(#Z,#af)do if(Z)[_].source~=af[_].source then if _<#af and ad(af[_].functionName,ag.
primitive)then _+=1 end if _<#af and ad(af[_].functionName,ag.primitive)then _+=1 end return _ end end return-1 end
local function af(ag,Y)local Z=q.parse(Y.stackError)local _,ah=ac(ag,Z),ae(Z,Y)if _==-1 or ah==-1 or _-ah<2 then return
nil end return f.slice(Z,ah,_-1)end local function ag(ah)if not ah then return''end local Y=j.lastIndexOf(ah,'.')if Y==-
1 then Y=1 end if j.substr(ah,Y,3)=='use'then Y+=3 end return j.substr(ah,Y)end local ah local function Y(Z,_)local ai,
aj={}local ak,al,am=ai,1,{}for an=1,#_ do local ao=_[an]local ap=af(Z,ao)if ap~=nil then local aq=0 if aj~=nil then
while aq<#ap and aq<#aj do local ar,as=ap[#ap-aq].source,aj[#aj-aq].source if ar~=as then break end aq+=1 end for ar=#aj
-1,aq+1,-1 do ak=table.remove(am)end end for ar=#ap-aq,2,-1 do local as={}table.insert(ak,{id=nil,isStateEditable=false,
name=ag(ap[ar-1].functionName),value=nil,subHooks=as})table.insert(am,ak)ak=as end aj=ap end local function aq()local ar
=al al+=1 return ar end local ar=ao.primitive local as,at=if ar=='Context'or ar=='DebugValue'then nil else aq(),ar==
'Reducer'or ar=='State'table.insert(ak,{id=as,isStateEditable=at,name=ar,value=ao.value,subHooks={}})end ah(ai,nil)
return ai end function ah(ai,aj)local ak={}do local al=1 while al<=#ai do local am=ai[al]if am.name=='DebugValue'and#am.
subHooks==0 then f.splice(ai,al,1)al-=1 table.insert(ak,am)else ah(am.subHooks,am)end al+=1 end end if aj~=nil then if#
ak==1 then aj.value=ak[1].value elseif#ak>1 then aj.value=f.map(ak,function(al)local am=al.value return am end)end end
end local function ai(aj,ak,al)if al==nil then al=s.ReactCurrentDispatcher end local am,an=((al).current);(al).current=E
local ao do local ap,aq=pcall(function()ao=g.new()aj(ak)end)do an=B B={}(al).current=am end if not ap then error(aq)end
end local ap=q.parse(ao)return Y(ap,an)end k.inspectHooks=ai local function aj(ak,al)local am=al while am do if am.tag==
y then local an=am.type local ao=an._context if not ak:has(ao)then ak:set(ao,ao._currentValue)ao._currentValue=am.
memoizedProps.value end end am=am.return_ end end local function ak(al)for am,an in al do local ao,ap=an[1],an[2]ao.
_currentValue=ap end end local function al(am,an,ao,ap)local aq,ar=(ap.current)ap.current=E local as do local at,Z=
pcall(function()as=g.new()am(an,ao)end)do ar=B B={}ap.current=aq end if not at then error(Z)end end local at=q.parse(as)
return Y(at,ar)end local function am(an,ao)if typeof(an)=='table'and an.defaultProps then local ap,aq=i.assign({},ao),an
.defaultProps for ar in aq do if(ap)[ar]==nil then(ap)[ar]=aq[ar]end end return ap end return ao end local function an(
ao,ap)if ap==nil then ap=s.ReactCurrentDispatcher end D=ao if ao.tag~=w and ao.tag~=x and ao.tag~=z and ao.tag~=A then
error(g.new[[Unknown Fiber. Needs to be a function component to inspect hooks.]])end F()local aq,ar=ao.type,ao.
memoizedProps if aq~=ao.elementType then ar=am(aq,ar)end G=ao.memoizedState local as=h.new()do local at,Z=pcall(function
()aj(as,ao)if ao.tag==z then return al(aq.render,ar,ao.ref,ap)end return ai(aq,ar,ap)end)do G=nil ak(as)end if not at
then error(Z)end return Z end end k.inspectHooksOfFiber=an return k end)()end,[24]=function()local aa,ab,ac=a(24)local
ad return(function(...)local ae,af={},ac(ab.Parent.ReactDebugHooks)local ag,ah=af.inspectHooks,af.inspectHooksOfFiber ae
.inspectHooks=ag ae.inspectHooksOfFiber=ah return ae end)()end,[26]=function()local aa,ab,ac=a(26)local ad return(
function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Error,ac(ae.Dev.JestGlobals)
local ai,aj,ak,al,am,an=ah.afterEach,ah.beforeEach,ah.describe,ah.expect,ah.it,ah.jest ak(
'React hooks DevTools integration',function()local ao,ap,aq,ar,as,at,b,c aj(function()_G.__REACT_DEVTOOLS_GLOBAL_HOOK__=
{inject=function(d)at=d.overrideHookState b=d.scheduleUpdate c=d.setSuspenseHandler end,supportsFiber=true,
onCommitFiberRoot=function()end,onCommitFiberUnmount=function()end}an.resetModules()aq=ac(ae.Dev.ReactTestRenderer)ao=
ac(ae.Dev.React)ap=ac(ae.ReactDebugTools)ar=ac(ae.Dev.Scheduler)as=aq.act end)ai(function()_G.
__REACT_DEVTOOLS_GLOBAL_HOOK__=nil end)am('should support editing useState hooks',function()local d local function e()
local f,g=ao.useState(0)d=g return ao.createElement('Frame',nil,ao.createElement('TextLabel',{Text='count:'}),ao.
createElement('TextLabel',{Text=tostring(f)}))end local f=aq.create(ao.createElement(e,nil))al(f:toJSON()).toEqual{type=
'Frame',props={},children={{type='TextLabel',props={Text='count:'}},{type='TextLabel',props={Text='0'}}}}local g=f.root:
findByType(e):_currentFiber()local h=ap.inspectHooksOfFiber(g)local i=h[1]al(i.isStateEditable).toBe(true)if _G.__DEV__
then at(g,i.id,{},10)al(f:toJSON()).toEqual{type='Frame',props={},children={{type='TextLabel',props={Text='count:'}},{
type='TextLabel',props={Text='10'}}}}as(function()return d(function(j)return j+1 end)end)al(f:toJSON()).toEqual{type=
'Frame',props={},children={{type='TextLabel',props={Text='count:'}},{type='TextLabel',props={Text='11'}}}}end end)am(
'should support editable useReducer hooks',function()local d={foo='abc',bar=123}local function e(f,g)local h=g.type if h
=='swap'then return{foo=f.bar,bar=f.foo}else error(ag.new())end end local f local function g()local h,i=ao.useReducer(e,
d)f=i return ao.createElement('Frame',{},ao.createElement('TextLabel',{Text='foo:'}),ao.createElement('TextLabel',{Text=
tostring(h.foo)}),ao.createElement('TextLabel',{Text=', bar:'}),ao.createElement('TextLabel',{Text=tostring(h.bar)}))end
local h=aq.create(ao.createElement(g,nil))al(h:toJSON()).toEqual{type='Frame',props={},children={{type='TextLabel',props
={Text='foo:'}},{type='TextLabel',props={Text='abc'}},{type='TextLabel',props={Text=', bar:'}},{type='TextLabel',props={
Text='123'}}}}local i=h.root:findByType(g):_currentFiber()local j=ap.inspectHooksOfFiber(i)local k=j[1]al(k.
isStateEditable).toBe(true)if _G.__DEV__ then at(i,k.id,{'foo'},'def')al(h:toJSON()).toEqual{type='Frame',props={},
children={{type='TextLabel',props={Text='foo:'}},{type='TextLabel',props={Text='def'}},{type='TextLabel',props={Text=
', bar:'}},{type='TextLabel',props={Text='123'}}}}as(function()return f{type='swap'}end)al(h:toJSON()).toEqual{type=
'Frame',props={},children={{type='TextLabel',props={Text='foo:'}},{type='TextLabel',props={Text='123'}},{type=
'TextLabel',props={Text=', bar:'}},{type='TextLabel',props={Text='def'}}}}end end)am(
[[should handle interleaved stateful hooks (e.g. useState) and non-stateful hooks (e.g. useContext)]],function()local d,
e=(ao.createContext(1))local function f()local g=ao.useContext(d)local h,i=ao.useState{count=g}ao.useDebugValue(h.count)
e=i return h.count end local function g()local h=f()return ao.createElement('Frame',nil,ao.createElement('TextLabel',{
Text='count:'}),ao.createElement('TextLabel',{Text=tostring(h)}))end local h=aq.create(ao.createElement(g,nil))al(h:
toJSON()).toEqual{type='Frame',props={},children={{type='TextLabel',props={Text='count:'}},{type='TextLabel',props={Text
='1'}}}}local i=h.root:findByType(g):_currentFiber()local j=ap.inspectHooksOfFiber(i)local k=j[1].subHooks[2]al(k.
isStateEditable).toBe(true)if _G.__DEV__ then at(i,k.id,{'count'},10)al(h:toJSON()).toEqual{type='Frame',props={},
children={{type='TextLabel',props={Text='count:'}},{type='TextLabel',props={Text='10'}}}}as(function()return e(function(
l)return{count=l.count+1}end)end)al(h:toJSON()).toEqual{type='Frame',props={},children={{type='TextLabel',props={Text=
'count:'}},{type='TextLabel',props={Text='11'}}}}end end)am('should support overriding suspense in legacy mode',function
()if _G.__DEV__ then c(function()return true end)end local function d()return ao.createElement('TextLabel',{Text='Done'}
)end local e=aq.create(ao.createElement('Frame',nil,ao.createElement(ao.Suspense,{fallback=ao.createElement('TextLabel',
{Text='Loading'})},ao.createElement(d,nil))))local f=e.root:_currentFiber().child if _G.__DEV__ then al(e:toJSON().
children).toEqual{{type='TextLabel',props={Text='Loading'}}}b(f)al(e:toJSON().children).toEqual{{type='TextLabel',props=
{Text='Loading'}}}c(function()return false end)b(f)al(e:toJSON().children).toEqual{{type='TextLabel',props={Text='Done'}
}}b(f)al(e:toJSON().children).toEqual{{type='TextLabel',props={Text='Done'}}}c(function()return true end)b(f)al(e:
toJSON().children).toEqual{{type='TextLabel',props={Text='Loading'}}}c(function()return false end)b(f)al(e:toJSON().
children).toEqual{{type='TextLabel',props={Text='Done'}}}c(function(g)return g==f or g==f.alternate end)b(f)al(e:toJSON(
).children).toEqual{{type='TextLabel',props={Text='Loading'}}}c(function(g)return g~=f and g~=f.alternate end)b(f)al(e:
toJSON().children).toEqual{{type='TextLabel',props={Text='Done'}}}else al(e:toJSON().children).toEqual{{type='TextLabel'
,props={Text='Done'}}}end end)am('should support overriding suspense in concurrent mode',function()an.useFakeTimers()if
_G.__DEV__ then c(function()return true end)end local function d()return ao.createElement('TextLabel',{Text='Done'})end
local e=aq.create(ao.createElement('div',nil,ao.createElement(ao.Suspense,{fallback=ao.createElement('TextLabel',{Text=
'Loading'})},ao.createElement(d,nil))),{unstable_isConcurrent=true})al(ar).toFlushAndYield{}an.advanceTimersByTime(1000)
local f=e.root:_currentFiber().child if _G.__DEV__ then al(e:toJSON().children).toEqual{{type='TextLabel',props={Text=
'Loading'}}}b(f)al(e:toJSON().children).toEqual{{type='TextLabel',props={Text='Loading'}}}c(function()return false end)
b(f)ar.unstable_flushAll()al(e:toJSON().children).toEqual{{type='TextLabel',props={Text='Done'}}}b(f)al(e:toJSON().
children).toEqual{{type='TextLabel',props={Text='Done'}}}c(function()return true end)b(f)al(e:toJSON().children).toEqual
{{type='TextLabel',props={Text='Loading'}}}c(function()return false end)b(f)al(e:toJSON().children).toEqual{{type=
'TextLabel',props={Text='Done'}}}c(function(g)return g==f or g==f.alternate end)b(f)al(e:toJSON().children).toEqual{{
type='TextLabel',props={Text='Loading'}}}c(function(g)return g~=f and g~=f.alternate end)b(f)al(e:toJSON().children).
toEqual{{type='TextLabel',props={Text='Done'}}}else al(e:toJSON().children).toEqual{{type='TextLabel',props={Text='Done'
}}}end an.useRealTimers()end)end)end)()end,[27]=function()local aa,ab,ac=a(27)local ad return(function(...)local ae=ab.
Parent.Parent.Parent local af=ac(ae.Dev.JestGlobals)local ag,ah,ai,aj,ak,al,am=af.beforeEach,af.describe,af.expect,af.it
,(af.jest)ah('ReactHooksInspection',function()ag(function()ak.resetModules()al=ac(ae.Dev.React)am=ac(ae.ReactDebugTools)
end)aj('should inspect a simple useState hook',function()local function an(ao)local ap=al.useState'hello world'return al
.createElement('div',nil,ap)end local ao=am.inspectHooks(an,{})ai(ao).toEqual{{isStateEditable=true,id=1,name='State',
value='hello world',subHooks={}}}end)aj('should inspect a simple custom hook',function()local function an(ao)local ap=al
.useState(ao)[1]al.useDebugValue'custom hook label'return ap end local function ao(ap)local aq=an'hello world'return al.
createElement('div',nil,aq)end local ap=am.inspectHooks(ao,{})ai(ap).toEqual{{isStateEditable=false,id=nil,name='Custom'
,value=if _G.__DEV__ then'custom hook label'else nil,subHooks={{isStateEditable=true,id=1,name='State',value=
'hello world',subHooks={}}}}}end)aj('should inspect a tree of multiple hooks',function()local function an()end
local function ao(ap)local aq=al.useState(ap)al.useEffect(an)return aq end local function ap(aq)local ar,as=ao'hello',ao
'world'return al.createElement('div',nil,ar,' ',as)end local aq=am.inspectHooks(ap,{})ai(aq).toEqual{{isStateEditable=
false,id=nil,name='Custom',value=nil,subHooks={{isStateEditable=true,id=1,name='State',subHooks={},value='hello'},{
isStateEditable=false,id=2,name='Effect',subHooks={},value=an}}},{isStateEditable=false,id=nil,name='Custom',value=nil,
subHooks={{isStateEditable=true,id=3,name='State',value='world',subHooks={}},{isStateEditable=false,id=4,name='Effect',
value=an,subHooks={}}}}}end)aj('should inspect a tree of multiple levels of hooks',function()local function an()end
local function ao(ap)local aq=al.useReducer(function(aq,ar)return aq end,ap)al.useEffect(an)return aq end local function
ap(aq)local ar=ao(aq)al.useLayoutEffect(an)return ar end local function aq(ar)al.useLayoutEffect(an)local as=ao(ar)
return as end local function ar(as)local at,b=ap'hello',aq'world'return al.createElement('div',nil,at,' ',b)end local as
=am.inspectHooks(ar,{})ai(as).toEqual{{isStateEditable=false,id=nil,name='Bar',value=nil,subHooks={{isStateEditable=
false,id=nil,name='Custom',value=nil,subHooks={{isStateEditable=true,id=1,name='Reducer',value='hello',subHooks={}},{
isStateEditable=false,id=2,name='Effect',value=an,subHooks={}}}},{isStateEditable=false,id=3,name='LayoutEffect',value=
an,subHooks={}}}},{isStateEditable=false,id=nil,name='Baz',value=nil,subHooks={{isStateEditable=false,id=4,name=
'LayoutEffect',value=an,subHooks={}},{isStateEditable=false,id=nil,name='Custom',subHooks={{isStateEditable=true,id=5,
name='Reducer',subHooks={},value='world'},{isStateEditable=false,id=6,name='Effect',subHooks={},value=an}},value=nil}}}}
end)aj('should inspect the default value using the useContext hook',function()local an=al.createContext'default'
local function ao(ap)local aq=al.useContext(an)return al.createElement('div',nil,aq)end local ap=am.inspectHooks(ao,{})
ai(ap).toEqual{{isStateEditable=false,id=nil,name='Context',value='default',subHooks={}}}end)aj(
'should support an injected dispatcher',function()local function an(ao)local ap=al.useState'hello world'return al.
createElement('div',nil,ap)end local ao={}local ap,aq,ar=ao,0,{}local as,at=setmetatable({__getters={current=function(as
)print'getting current'aq+=1 return ap end},__setters={current=function(as,at)print('setting current',at)table.insert(ar
,at)ap=at end}},{__index=function(as,at)if typeof(as.__getters[at])=='function'then return as.__getters[at](as)else
return nil end end,__newindex=function(as,at,b)if typeof(as.__setters[at])=='function'then return as.__setters[at](as,b)
else return nil end end}),false ai(function()ai(function()am.inspectHooks(an,{},as)end).toThrow
"attempt to index nil with 'useState'"at=true end).toErrorDev(
[[Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]]
,{withoutStack=true})ai(at).toBe(true)ai(aq).toBe(1)ai(ar).toHaveLength(2)ai(ar[1]).never.toBe(ao)ai(ar[2]).toBe(ao)end)
ah('useDebugValue',function()aj('should be ignored when called outside of a custom hook',function()local function an(ao)
al.useDebugValue'this is invalid'return nil end local ao=am.inspectHooks(an,{})ai(ao).toHaveLength(0)end)aj(
'should support an optional formatter function param',function()local function an()al.useDebugValue({bar=123},function(
ao)return('bar:%s'):format(tostring(ao.bar))end)al.useState(0)end local function ao(ap)an()return nil end local ap=am.
inspectHooks(ao,{})ai(ap).toEqual{{isStateEditable=false,id=nil,name='Custom',value=if _G.__DEV__ then'bar:123'else nil,
subHooks={{isStateEditable=true,id=1,name='State',subHooks={},value=0}}}}end)end)end)end)()end,[28]=function()local aa,
ab,ac=a(28)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af,ag,ah=ac(ae.LuauPolyfill),ac(ae.Dev.
Promise),ac(ae.Dev.JestGlobals)local ai,aj,ak,al,am,an,ao,ap,aq,ar,as=ah.beforeEach,ah.describe,ah.expect,ah.it,ah.jest,
(af.String)aj('ReactHooksInspectionIntegration',function()ai(function()am.resetModules()ap=ac(ae.Dev.ReactTestRenderer)
aq=ac(ae.Dev.Scheduler)ao=ac(ae.Dev.React)as=ap.unstable_concurrentAct ar=ac(ae.ReactDebugTools)end)al(
'should inspect the current state of useState hooks',function()local at=ao.useState local function b(c)local d,e=at
'hello'local f,g=at'world'return ao.createElement('Frame',{onMouseDown=e,onMouseUp=g},d,' ',f)end local c=ap.create(ao.
createElement(b,{prop='prop'}))local d=c.root:findByType(b):_currentFiber()local e=ar.inspectHooksOfFiber(d)ak(e).
toEqual{{isStateEditable=true,id=1,name='State',value='hello',subHooks={}},{isStateEditable=true,id=2,name='State',value
='world',subHooks={}}}local f,g do local h=c.root:findByType'Frame'.props f,g=h.onMouseDown,h.onMouseUp end as(function(
)return f'Hi'end)d=c.root:findByType(b):_currentFiber()e=ar.inspectHooksOfFiber(d)ak(e).toEqual{{isStateEditable=true,id
=1,name='State',value='Hi',subHooks={}},{isStateEditable=true,id=2,name='State',value='world',subHooks={}}}as(function()
return g'world!'end)d=c.root:findByType(b):_currentFiber()e=ar.inspectHooksOfFiber(d)ak(e).toEqual{{isStateEditable=true
,id=1,name='State',value='Hi',subHooks={}},{isStateEditable=true,id=2,name='State',value='world!',subHooks={}}}end)al(
'should inspect the current state of all stateful hooks',function()local at=ao.createRef()local function b()end
local function c(d)local e,f=ao.useState'a'local g,h=ao.useReducer(function(g,h)return h.value end,'b')local i=ao.useRef
'c'ao.useLayoutEffect(b)ao.useEffect(b)ao.useImperativeHandle(at,function()return function()end end,{})ao.useMemo(
function()return e..g end,{e})local function j()as(function()f'A'end)as(function()h{value='B'}end)i.current='C'end local
k=ao.useCallback(j,{})return ao.createElement('Frame',{onClick=k},e,' ',g)end local d as(function()d=ap.create(ao.
createElement(c,{prop='prop'}))end)local e,f=d.root:findByType(c):_currentFiber(),d.root:findByType'Frame'.props.onClick
local g=ar.inspectHooksOfFiber(e)ak(g).toEqual{{isStateEditable=true,id=1,name='State',value='a',subHooks={}},{
isStateEditable=true,id=2,name='Reducer',value='b',subHooks={}},{isStateEditable=false,id=3,name='Ref',value='c',
subHooks={}},{isStateEditable=false,id=4,name='LayoutEffect',value=b,subHooks={}},{isStateEditable=false,id=5,name=
'Effect',value=b,subHooks={}},{isStateEditable=false,id=6,name='ImperativeHandle',value=at.current,subHooks={}},{
isStateEditable=false,id=7,name='Memo',value={'ab'},subHooks={}},{isStateEditable=false,id=8,name='Callback',value=f,
subHooks={}}}f()e=d.root:findByType(c):_currentFiber()g=ar.inspectHooksOfFiber(e)ak(g).toEqual{{isStateEditable=true,id=
1,name='State',value='A',subHooks={}},{isStateEditable=true,id=2,name='Reducer',value='B',subHooks={}},{isStateEditable=
false,id=3,name='Ref',value='C',subHooks={}},{isStateEditable=false,id=4,name='LayoutEffect',value=b,subHooks={}},{
isStateEditable=false,id=5,name='Effect',value=b,subHooks={}},{isStateEditable=false,id=6,name='ImperativeHandle',value=
at.current,subHooks={}},{isStateEditable=false,id=7,name='Memo',value={'Ab'},subHooks={}},{isStateEditable=false,id=8,
name='Callback',value=f,subHooks={}}}end)al([[should inspect the value of the current provider in useContext]],function(
)local at=ao.createContext'default'local function b(c)local d=ao.useContext(at)return ao.createElement('Frame',nil,d)end
local c=ap.create(ao.createElement(at.Provider,{value='contextual'},ao.createElement(b,{prop='prop'})))local d=c.root:
findByType(b):_currentFiber()local e=ar.inspectHooksOfFiber(d)ak(e).toEqual{{isStateEditable=false,id=nil,name='Context'
,value='contextual',subHooks={}}}end)al('should inspect forwardRef',function()local function at()end local b,c=ao.
forwardRef(function(b,c)ao.useImperativeHandle(c,function()return at end)return ao.createElement('Frame',nil)end),ao.
createRef()local d=ap.create(ao.createElement(b,{ref=c}))local e=d.root:findByType(b):_currentFiber()local f=ar.
inspectHooksOfFiber(e)ak(f).toEqual{{isStateEditable=false,id=1,name='ImperativeHandle',value=at,subHooks={}}}end)al(
'should inspect memo',function()local function at(b)local c=ao.useState'hello'return ao.createElement('Frame',nil,c)end
local b=ao.memo(at)local c=ap.create(ao.createElement(b,nil))local d=c.root:findByType(at):_currentFiber()local e=ar.
inspectHooksOfFiber(d)ak(e).toEqual{{isStateEditable=true,id=1,name='State',value='hello',subHooks={}}}end)al(
'should inspect custom hooks',function()local function at()local b=ao.useState'hello'return b end local function b(c)
local d=at()return ao.createElement('Frame',nil,d)end local c=ap.create(ao.createElement(b,nil))local d=c.root:
findByType(b):_currentFiber()local e=ar.inspectHooksOfFiber(d)ak(e).toEqual{{isStateEditable=false,id=nil,name='Custom',
value=nil,subHooks={{isStateEditable=true,id=1,name='State',value='hello',subHooks={}}}}}end)al.skip(
'should support composite useTransition hook',function()local function at(b)local c=ao.useMemo(function()return'hello'
end,{})return ao.createElement('Frame',nil,c)end local b=ap.create(ao.createElement(at,nil))local c=b.root:findByType(at
):_currentFiber()local d=ar.inspectHooksOfFiber(c)ak(d).toEqual{{id=1,isStateEditable=false,name='Transition',value=nil,
subHooks={}},{id=2,isStateEditable=false,name='Memo',value='hello',subHooks={}}}end)al.skip(
'should support composite useDeferredValue hook',function()local function at(b)local c=ao.useState(function()return
'hello'end,{})return ao.createElement('Frame',nil,c)end local b=ap.create(ao.createElement(at,nil))local c=b.root:
findByType(at):_currentFiber()local d=ar.inspectHooksOfFiber(c)ak(d).toEqual{{id=1,isStateEditable=false,name=
'DeferredValue',value='abc',subHooks={}},{id=2,isStateEditable=true,name='State',value='hello',subHooks={}}}end)al.skip(
'should support composite useOpaqueIdentifier hook',function()local function at(b)local c,d=(ao.useState(function()
return'hello'end,{}))return ao.createElement('Frame',{id=d},c)end local b=ap.create(ao.createElement(at,nil))local c=b.
root:findByType(at):_currentFiber()local d=ar.inspectHooksOfFiber(c)ak(#d).toEqual(2)ak(d[1].id).toEqual(0)ak(d[1].
isStateEditable).toEqual(false)ak(d[1].name).toEqual'OpaqueIdentifier'ak(an.startsWith(d[1].value..'','c_')).toBe(true)
ak(d[2]).toEqual{id=2,isStateEditable=true,name='State',value='hello',subHooks={}}end)al.skip(
[[should support composite useOpaqueIdentifier hook in concurrent mode]],function()local function at(b)local c,d=(ao).
unstable_useOpaqueIdentifier(),ao.useState(function()return'hello'end,{})return ao.createElement('Frame',{id=c},d)end
local b=ap.create(ao.createElement(at,nil),{unstable_isConcurrent=true})ak(aq).toFlushWithoutYielding()local c=b.root:
findByType(at):_currentFiber()local d=ar.inspectHooksOfFiber(c)ak(#d).toEqual(2)ak(d[1].id).toEqual(0)ak(d[1].
isStateEditable).toEqual(false)ak(d[1].name).toEqual'OpaqueIdentifier'ak(an.startsWith(d[1].value..'','c_')).toBe(true)
ak(d[2]).toEqual{id=2,isStateEditable=true,name='State',value='hello',subHooks={}}end)aj('useDebugValue',function()al(
'should support inspectable values for multiple custom hooks',function()local function at(b)local c=ao.useState(b)ao.
useDebugValue(('custom label %s'):format(tostring(b)))return c end local function b(c)local d=ao.useState(c)return d end
local function c()at'a'ao.useState'b'b'c'at'd'return nil end local d=ap.create(ao.createElement(c,nil))local e=d.root:
findByType(c):_currentFiber()local f=ar.inspectHooksOfFiber(e)ak(f).toEqual{{isStateEditable=false,id=nil,name=
'LabeledValue',value=(if _G.__DEV__ then'custom label a'else nil),subHooks={{isStateEditable=true,id=1,name='State',
value='a',subHooks={}}}},{isStateEditable=true,id=2,name='State',value='b',subHooks={}},{isStateEditable=false,id=nil,
name='Anonymous',value=nil,subHooks={{isStateEditable=true,id=3,name='State',value='c',subHooks={}}}},{isStateEditable=
false,id=nil,name='LabeledValue',value=if _G.__DEV__ then'custom label d'else nil,subHooks={{isStateEditable=true,id=4,
name='State',value='d',subHooks={}}}}}end)al('should support inspectable values for nested custom hooks',function()
local function at()ao.useDebugValue'inner'ao.useState(0)end local function b()ao.useDebugValue'outer'at()end
local function c()b()return nil end local d=ap.create(ao.createElement(c,nil))local e=d.root:findByType(c):
_currentFiber()local f=ar.inspectHooksOfFiber(e)ak(f).toEqual{{isStateEditable=false,id=nil,name='Outer',value=if _G.
__DEV__ then'outer'else nil,subHooks={{isStateEditable=false,id=nil,name='Inner',value=if _G.__DEV__ then'inner'else nil
,subHooks={{isStateEditable=true,id=1,name='State',value=0,subHooks={}}}}}}}end)al(
'should support multiple inspectable values per custom hooks',function()local function at()ao.useDebugValue'one'ao.
useDebugValue'two'ao.useDebugValue'three'ao.useState(0)end local function b(c)ao.useDebugValue(('single %s'):format(
tostring(c)))ao.useState(0)end local function c()b'one'at()b'two'return nil end local d=ap.create(ao.createElement(c,nil
))local e=d.root:findByType(c):_currentFiber()local f=ar.inspectHooksOfFiber(e)ak(f).toEqual{{isStateEditable=false,id=
nil,name='SingleLabelCustom',value=(if _G.__DEV__ then'single one'else nil),subHooks={{isStateEditable=true,id=1,name=
'State',value=0,subHooks={}}}},{isStateEditable=false,id=nil,name='MultiLabelCustom',value=if _G.__DEV__ then{'one',
'two','three'}else nil,subHooks={{isStateEditable=true,id=2,name='State',value=0,subHooks={}}}},{isStateEditable=false,
id=nil,name='SingleLabelCustom',value=if _G.__DEV__ then'single two'else nil,subHooks={{isStateEditable=true,id=3,name=
'State',value=0,subHooks={}}}}}end)al('should ignore useDebugValue() made outside of a custom hook',function()
local function at()ao.useDebugValue'this is invalid'return nil end local b=ap.create(ao.createElement(at,nil))local c=b.
root:findByType(at):_currentFiber()local d=ar.inspectHooksOfFiber(c)ak(d).toHaveLength(0)end)al(
'should support an optional formatter function param',function()local function at()ao.useDebugValue({bar=123},function(b
)return('bar:%s'):format(tostring(b.bar))end)ao.useState(0)end local function b()at()return nil end local c=ap.create(ao
.createElement(b,nil))local d=c.root:findByType(b):_currentFiber()local e=ar.inspectHooksOfFiber(d)ak(e).toEqual{{
isStateEditable=false,id=nil,name='Custom',value=if _G.__DEV__ then'bar:123'else nil,subHooks={{isStateEditable=true,id=
1,name='State',subHooks={},value=0}}}}end)end)al.skip('should support defaultProps and lazy',function()return ag.
resolve():andThen(function()end)end)al('should support an injected dispatcher',function()local function at(b)local c=ao.
useState'hello world'return ao.createElement('Frame',nil,c)end local b={}local c,d,e=b,0,{}local f,g=setmetatable({
__getters={current=function(f)d+=1 return c end},__setters={current=function(f,g)table.insert(e,g)c=g end}},{__index=
function(f,g)if typeof(f.__getters[g])=='function'then return f.__getters[g](f)else return nil end end,__newindex=
function(f,g,h)if typeof(f.__setters[g])=='function'then return f.__setters[g](f,h)else return nil end end}),ap.create(
ao.createElement(at,nil))local h=g.root:_currentFiber()ak(function()ar.inspectHooksOfFiber(h,f)end).toThrow
[[Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]]
ak(d).toBe(1)ak(e).toHaveLength(2)ak(e[1]).never.toBe(b)ak(e[2]).toBe(b)end)al(
'should properly advance the current hook for useContext',function()local at,b=(ao.createContext(1))local function c(d)
local e=ao.useContext(at)local f,g=ao.useState{count=e}b=function()return g(function(h)local i=h.count return{count=i+1}
end)end return ao.createElement('Frame',nil,'count: ',f.count)end local d=ap.create(ao.createElement(c,nil))ak(d:toJSON(
)).toEqual{type='Frame',props={},children={'count: ','1'}}as(b)ak(d:toJSON()).toEqual{type='Frame',props={},children={
'count: ','2'}}local e=d.root:_currentFiber()local f=ar.inspectHooksOfFiber(e)ak(f).toEqual{{isStateEditable=false,id=
nil,name='Context',value=1,subHooks={}},{isStateEditable=true,id=1,name='State',value={count=2},subHooks={}}}end)end)end
)()end,[29]=function()local aa,ab,ac=a(29)local ad return(function(...)return{backend=ac(ab.backend),bridge=ac(ab.bridge
),devtools=ac(ab.devtools),hydration=ac(ab.hydration),hook=ac(ab.hook),utils=ac(ab.utils)}end)()end,[30]=function()local
aa,ab,ac=a(30)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Array,
ac(ab.agent)local ai=ac(ab.types)local function aj(ak,al,am)if ak==nil then return function()end end local an,ao={ak.
sub('renderer-attached',function(an)local ao,ap=an.id,an.rendererInterface al:setRendererInterface(ao,ap)ap.
flushInitialOperations()end),ak.sub('unsupported-renderer-version',function(an)al:onUnsupportedRenderer(an)end),ak.sub(
'operations',function(...)al:onHookOperations(...)end),ak.sub('traceUpdates',function(...)al:onTraceUpdates(...)end)},
function(an,ao)local ap,aq=ac(ab.renderer).attach,ak.rendererInterfaces:get(an)if aq==nil then if type(ao.
findFiberByHostInstance)=='function'then aq=ap(ak,an,ao,am)elseif ao.ComponentTree then end if aq~=nil then ak.
rendererInterfaces:set(an,aq)end end if aq~=nil then ak.emit('renderer-attached',{id=an,renderer=ao,rendererInterface=aq
})else ak.emit('unsupported-renderer-version',an)end end ak.renderers:forEach(function(ap,aq)ao(aq,ap)end)table.insert(
an,ak.sub('renderer',function(ap)local aq,ar=ap.id,ap.renderer ao(aq,ar)end))ak.emit('react-devtools',al)ak.
reactDevtoolsAgent=al local function ap()ag.forEach(an,function(aq)aq()end)ak.rendererInterfaces:forEach(function(aq)aq.
cleanup()end)ak.reactDevtoolsAgent=nil end al:addListener('shutdown',ap)table.insert(an,function()al:removeListener(
'shutdown',ap)end)return function()for aq,ar in an do ar()end end end return{initBackend=aj,agent=ac(ab.agent),
NativeStyleEditor={types=ac(ab.NativeStyleEditor.types)}}end)()end,[32]=function()local aa,ab,ac=a(32)local ad return(
function(...)return{}end)()end,[33]=function()local aa,ab,ac=a(33)local ad return(function(...)local ae={}ae.
CONCURRENT_MODE_NUMBER=0xeacf ae.CONCURRENT_MODE_SYMBOL_STRING='Symbol(react.concurrent_mode)'ae.CONTEXT_NUMBER=0xeace
ae.CONTEXT_SYMBOL_STRING='Symbol(react.context)'ae.DEPRECATED_ASYNC_MODE_SYMBOL_STRING='Symbol(react.async_mode)'ae.
ELEMENT_NUMBER=0xeac7 ae.ELEMENT_SYMBOL_STRING='Symbol(react.element)'ae.DEBUG_TRACING_MODE_NUMBER=0xeae1 ae.
DEBUG_TRACING_MODE_SYMBOL_STRING='Symbol(react.debug_trace_mode)'ae.FORWARD_REF_NUMBER=0xead0 ae.
FORWARD_REF_SYMBOL_STRING='Symbol(react.forward_ref)'ae.FRAGMENT_NUMBER=0xeacb ae.FRAGMENT_SYMBOL_STRING=
'Symbol(react.fragment)'ae.LAZY_NUMBER=0xead4 ae.LAZY_SYMBOL_STRING='Symbol(react.lazy)'ae.MEMO_NUMBER=0xead3 ae.
MEMO_SYMBOL_STRING='Symbol(react.memo)'ae.OPAQUE_ID_NUMBER=0xeae0 ae.OPAQUE_ID_SYMBOL_STRING='Symbol(react.opaque.id)'ae
.PORTAL_NUMBER=0xeaca ae.PORTAL_SYMBOL_STRING='Symbol(react.portal)'ae.PROFILER_NUMBER=0xead2 ae.PROFILER_SYMBOL_STRING=
'Symbol(react.profiler)'ae.PROVIDER_NUMBER=0xeacd ae.PROVIDER_SYMBOL_STRING='Symbol(react.provider)'ae.SCOPE_NUMBER=
0xead7 ae.SCOPE_SYMBOL_STRING='Symbol(react.scope)'ae.STRICT_MODE_NUMBER=0xeacc ae.STRICT_MODE_SYMBOL_STRING=
'Symbol(react.strict_mode)'ae.SUSPENSE_NUMBER=0xead1 ae.SUSPENSE_SYMBOL_STRING='Symbol(react.suspense)'ae.
SUSPENSE_LIST_NUMBER=0xead8 ae.SUSPENSE_LIST_SYMBOL_STRING='Symbol(react.suspense_list)'return ae end)()end,[34]=
function()local aa,ab,ac=a(34)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)
local ag,ah,ai=af.console,game:GetService'HttpService',_G local aj=ac(ab.Parent.Parent.events)local ak,al=function(ak,al
)return ak end,ac(ab.Parent.Parent.constants)local am,an,ao,ap,aq=al.SESSION_STORAGE_LAST_SELECTION_KEY,al.
SESSION_STORAGE_RELOAD_AND_PROFILE_KEY,al.SESSION_STORAGE_RECORD_CHANGE_DESCRIPTIONS_KEY,al.__DEBUG__,ac(ab.Parent.
Parent.storage)local ar,as,at,b,c,d,e,f,g=aq.sessionStorageGetItem,aq.sessionStorageRemoveItem,aq.sessionStorageSetItem,
function(ar,as)end,function(ar)end,function(ar)end,function(ar)end,function()end,ac(ab.Parent.Parent.bridge)local h=ac(
ab.Parent.types)local i=ac(ab.Parent.Parent.types)local j=function(j,...)if ap then print(j,...)end end local k=
setmetatable({},{__index=aj})local l={__index=k}function k.new(m)local n=setmetatable(aj.new(),l)n._bridge=m n.
_isProfiling=false n._recordChangeDescriptions=false n._rendererInterfaces={}n._persistedSelection=nil n.
_persistedSelectionMatch=nil n._traceUpdatesEnabled=false if ar(an)=='true'then n._recordChangeDescriptions=ar(ao)==
'true'n._isProfiling=true as(ao)as(an)end local o=ar(am)if o~=nil then n._persistedSelection=ah.JSONDecode(o)end
local function p(q)return function(...)q(n,...)end end m:addListener('copyElementPath',p(n.copyElementPath))m:
addListener('deletePath',p(n.deletePath))m:addListener('getProfilingData',p(n.getProfilingData))m:addListener(
'getProfilingStatus',p(n.getProfilingStatus))m:addListener('getOwnersList',p(n.getOwnersList))m:addListener(
'inspectElement',p(n.inspectElement))m:addListener('logElementToConsole',p(n.logElementToConsole))m:addListener(
'overrideSuspense',p(n.overrideSuspense))m:addListener('overrideValueAtPath',p(n.overrideValueAtPath))m:addListener(
'reloadAndProfile',p(n.reloadAndProfile))m:addListener('renamePath',p(n.renamePath))m:addListener(
'setTraceUpdatesEnabled',p(n.setTraceUpdatesEnabled))m:addListener('startProfiling',p(n.startProfiling))m:addListener(
'stopProfiling',p(n.stopProfiling))m:addListener('storeAsGlobal',p(n.storeAsGlobal))m:addListener(
'syncSelectionFromNativeElementsPanel',p(n.syncSelectionFromNativeElementsPanel))m:addListener('shutdown',p(n.shutdown))
m:addListener('updateConsolePatchSettings',p(n.updateConsolePatchSettings))m:addListener('updateComponentFilters',p(n.
updateComponentFilters))m:addListener('viewAttributeSource',p(n.viewAttributeSource))m:addListener('viewElementSource',
p(n.viewElementSource))m:addListener('overrideContext',p(n.overrideContext))m:addListener('overrideHookState',p(n.
overrideHookState))m:addListener('overrideProps',p(n.overrideProps))m:addListener('overrideState',p(n.overrideState))if
n._isProfiling then m:send('profilingStatus',true)end local q=true m:send('isBackendStorageAPISupported',q)b(m,n)c(n)
return n end function k.getRendererInterfaces(m)return m._rendererInterfaces end function k.copyElementPath(m,n)local o,
p,q=n.id,n.path,n.rendererID local r=m._rendererInterfaces[q]if r==nil then ag.warn(string.format(
'Invalid renderer id "%d" for element "%d"',q,o))else(r).copyElementPath(o,p)end end function k.deletePath(m,n)local o,p
,q,r,s=n.hookID,n.id,n.path,n.rendererID,n.type local t=m._rendererInterfaces[r]if t==nil then ag.warn(string.format(
'Invalid renderer id "%d" for element "%d"',r,p))else(t).deletePath(s,p,o,q)end end function k.getInstanceAndStyle(m,n)
local o,p=n.id,n.rendererID local q=m._rendererInterfaces[p]if q==nil then ag.warn(string.format(
'Invalid renderer id "%d"',p))return nil end return(q).getInstanceAndStyle(o)end function k.getIDForNode(m,n)for o,p in
m._rendererInterfaces do local q,r=pcall(p.getFiberIDForNative,n,true)if q and r~=nil then return r end end return nil
end function k.getProfilingData(m,n)local o=n.rendererID local p=m._rendererInterfaces[o]if p==nil then ag.warn(string.
format('Invalid renderer id "%d"',o))end m._bridge:send('profilingData',(p).getProfilingData())end function k.
getProfilingStatus(m)m._bridge:send('profilingStatus',m._isProfiling)end function k.getOwnersList(m,n)local o,p=n.id,n.
rendererID local q=m._rendererInterfaces[p]if q==nil then ag.warn(string.format(
'Invalid renderer id "%d" for element "%d"',p,o))else local r=(q).getOwnersList(o)m._bridge:send('ownersList',{id=o,
owners=r})end end function k.inspectElement(m,n)local o,p,q=n.id,n.path,n.rendererID local r=m._rendererInterfaces[q]if
r==nil then ag.warn(string.format('Invalid renderer id "%d" for element "%d"',q,o))else m._bridge:send(
'inspectedElement',(r).inspectElement(o,p))if(m._persistedSelectionMatch)==nil or(m._persistedSelectionMatch).id~=o then
m._persistedSelection=nil m._persistedSelectionMatch=nil(r).setTrackedPath(nil)m:_throttledPersistSelection(q,o)end end
end function k.logElementToConsole(m,n)local o,p=n.id,n.rendererID local q=m._rendererInterfaces[p]if q==nil then ag.
warn(string.format('Invalid renderer id "%d" for element "%d"',p,o))else(q).logElementToConsole(o)end end function k.
overrideSuspense(m,n)local o,p,q=n.id,n.rendererID,n.forceFallback local r=m._rendererInterfaces[p]if r==nil then ag.
warn(string.format('Invalid renderer id "%d" for element "%d"',p,o))else(r).overrideSuspense(o,q)end end function k.
overrideValueAtPath(m,n)local o,p,q,r,s,t=n.hookID,n.id,n.path,n.rendererID,n.type,n.value local u=m._rendererInterfaces
[r]if u==nil then ag.warn(string.format('Invalid renderer id "%d" for element "%d"',r,p))else(u).overrideValueAtPath(s,p
,o,q,t)end end function k.overrideContext(m,n)local o,p,q,r,s=n.id,n.path,n.rendererID,n.wasForwarded,n.value if not r
then m:overrideValueAtPath{id=o,path=p,rendererID=q,type='context',value=s}end end function k.overrideHookState(m,n)
local o,p,q,r,s,t=n.id,n.hookID,n.path,n.rendererID,n.wasForwarded,n.value if not s then m:overrideValueAtPath{id=o,path
=q,rendererID=r,type='hooks',value=t}end end function k.overrideProps(m,n)local o,p,q,r,s=n.id,n.path,n.rendererID,n.
wasForwarded,n.value if not r then m:overrideValueAtPath{id=o,path=p,rendererID=q,type='props',value=s}end end function
k.overrideState(m,n)local o,p,q,r,s=n.id,n.path,n.rendererID,n.wasForwarded,n.value if not r then m:overrideValueAtPath{
id=o,path=p,rendererID=q,type='state',value=s}end end function k.reloadAndProfile(m,n)at(an,'true')at(ao,(function()if n
then return'true'end return'false'end)())m._bridge:send'reloadAppForProfiling'end function k.renamePath(m,n)local o,p,q,
r,s,t=n.hookID,n.id,n.newPath,n.oldPath,n.rendererID,n.type local u=m._rendererInterfaces[s]if u==nil then ag.warn(
string.format('Invalid renderer id "%d" for element "%d"',s,p))else(u).renamePath(t,p,o,r,q)end end function k.
selectNode(m,n)local o=m:getIDForNode(n)if o~=nil then m._bridge:send('selectFiber',o)end end function k.
setRendererInterface(m,n,o)m._rendererInterfaces[n]=o if m._isProfiling then o.startProfiling(m.
_recordChangeDescriptions)end o.setTraceUpdatesEnabled(m._traceUpdatesEnabled)local p=m._persistedSelection if p~=nil
and(p).rendererID==n then o.setTrackedPath((p).path)end end function k.setTraceUpdatesEnabled(m,n)m._traceUpdatesEnabled
=n d(n)for o,p in m._rendererInterfaces do p.setTraceUpdatesEnabled(n)end end function k.
syncSelectionFromNativeElementsPanel(m)local n=ai.__REACT_DEVTOOLS_GLOBAL_HOOK__['$0']if n==nil then return end m:
selectNode(n)end function k.shutdown(m)m:emit'shutdown'end function k.startProfiling(m,n)m._recordChangeDescriptions=n m
._isProfiling=true for o,p in m._rendererInterfaces do p.startProfiling(n)end m._bridge:send('profilingStatus',m.
_isProfiling)end function k.stopProfiling(m)m._isProfiling=false m._recordChangeDescriptions=false for n,o in m.
_rendererInterfaces do o.stopProfiling()end m._bridge:send('profilingStatus',m._isProfiling)end function k.storeAsGlobal
(m,n)local o,p,q,r=n.count,n.id,n.path,n.rendererID local s=m._rendererInterfaces[r]if s==nil then ag.warn(string.
format('Invalid renderer id "%d" for element "%d"',r,p))else(s).storeAsGlobal(p,q,o)end end function k.
updateConsolePatchSettings(m,n)local o,p=n.appendComponentStack,n.breakOnConsoleErrors if o or p then e{
appendComponentStack=o,breakOnConsoleErrors=p}else f()end end function k.updateComponentFilters(m,n)for o,p in m.
_rendererInterfaces do p.updateComponentFilters(n)end end function k.viewAttributeSource(m,n)local o,p,q=n.id,n.path,n.
rendererID local r=m._rendererInterfaces[q]if r==nil then ag.warn(string.format(
'Invalid renderer id "%d" for element "%d"',q,o))else(r).prepareViewAttributeSource(o,p)end end function k.
viewElementSource(m,n)local o,p=n.id,n.rendererID local q=m._rendererInterfaces[p]if q==nil then ag.warn(string.format(
'Invalid renderer id "%d" for element "%d"',p,o))else(q).prepareViewElementSource(o)end end function k.onTraceUpdates(m,
n)m:emit('traceUpdates',n)end function k.onHookOperations(m,n)if ai.__DEBUG__ then j('onHookOperations',n)end m._bridge:
send('operations',n)if m._persistedSelection~=nil then local o=n[1]if(m._persistedSelection).rendererID==o then local p=
m._rendererInterfaces[o]if p==nil then ag.warn(string.format('Invalid renderer id "%d"',o))else local q,r=m.
_persistedSelectionMatch,(p).getBestMatchForTrackedPath()m._persistedSelectionMatch=r local s,t=if q~=nil then q.id else
nil,if r~=nil then r.id else nil if s~=t then if t~=nil then m._bridge:send('selectFiber',t)end end if r~=nil and(r).
isFullMatch then m._persistedSelection=nil m._persistedSelectionMatch=nil(p).setTrackedPath(nil)end end end end end
function k.onUnsupportedRenderer(m,n)m._bridge:send('unsupportedRendererVersion',n)end k._throttledPersistSelection=ak(
function(m,n,o)local p=m._rendererInterfaces[n]local q=(function()if p~=nil then return(p).getPathForElement(o)end
return nil end)()if q~=nil then at(am,ah:JSONEncode{rendererID=n,path=q})else as(am)end end,1000)return k end)()end,[35]
=function()local aa,ab,ac=a(35)local ad return(function(...)local ae=ac(ab.Parent.types)local af={}function af.patch(ag)
end function af.unpatch()end function af.error(...)error(...)end function af.warn(...)warn(...)end function af.log(...)
print(...)end function af.registerRenderer(ag)end return af end)()end,[36]=function()local aa,ab,ac=a(36)local ad return
(function(...)local ae=ab.Parent.Parent.Parent local af,ag=ac(ae.LuauPolyfill),ac(ae.Shared)local ah,ai,aj,ak,al,am,an,
ao=ag.console,af.Map,af.Set,af.Array,af.Boolean,af.Object,af.Number,af.String local ap,aq,ar,as=_G,{},ac(ae.Shared).
invariant,ac(ab.Parent.Parent.types)local at,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p=as.ComponentFilterDisplayName,as.
ComponentFilterElementType,as.ComponentFilterHOC,as.ComponentFilterLocation,as.ElementTypeClass,as.ElementTypeContext,as
.ElementTypeFunction,as.ElementTypeForwardRef,as.ElementTypeHostComponent,as.ElementTypeMemo,as.
ElementTypeOtherOrUnknown,as.ElementTypeProfiler,as.ElementTypeRoot,as.ElementTypeSuspense,as.ElementTypeSuspenseList,
ac(ab.Parent.Parent.utils)local q,r,s,t,u,v,w,x=p.deletePathInObject,p.getDisplayName,p.getDefaultComponentFilters,p.
getInObject,p.getUID,p.renamePathInObject,p.setInObject,ac(ab.Parent.Parent.storage)local y,z=x.sessionStorageGetItem,
ac(ab.Parent.utils)local A,B,C,D,E,F=z.cleanForBridge,z.copyToClipboard,z.copyWithDelete,z.copyWithRename,z.copyWithSet,
ac(ab.Parent.Parent.constants)local G,H,I,J,K,L,M,N=F.__DEBUG__,F.SESSION_STORAGE_RELOAD_AND_PROFILE_KEY,F.
SESSION_STORAGE_RECORD_CHANGE_DESCRIPTIONS_KEY,F.TREE_OPERATION_ADD,F.TREE_OPERATION_REMOVE,F.
TREE_OPERATION_REORDER_CHILDREN,F.TREE_OPERATION_UPDATE_TREE_BASE_DURATION,ac(ae.ReactDebugTools)local O,P=N.
inspectHooksOfFiber,ac(ab.Parent.console)local Q,R,S=P.patch,P.registerRenderer,ac(ab.Parent.ReactSymbols)local T,U,V,W,
X,Y,Z,_,au,av,aw,ax,ay,az,aA,aB,aC,aD,aE=S.CONCURRENT_MODE_NUMBER,S.CONCURRENT_MODE_SYMBOL_STRING,S.
DEPRECATED_ASYNC_MODE_SYMBOL_STRING,S.PROVIDER_NUMBER,S.PROVIDER_SYMBOL_STRING,S.CONTEXT_NUMBER,S.CONTEXT_SYMBOL_STRING,
S.STRICT_MODE_NUMBER,S.STRICT_MODE_SYMBOL_STRING,S.PROFILER_NUMBER,S.PROFILER_SYMBOL_STRING,S.SCOPE_NUMBER,S.
SCOPE_SYMBOL_STRING,S.FORWARD_REF_NUMBER,S.FORWARD_REF_SYMBOL_STRING,S.MEMO_NUMBER,S.MEMO_SYMBOL_STRING,ag.objectIs,ac(
ae.ReactReconciler){}local aF,aG=aE.getNearestMountedFiber,ac(ae.ReactReconciler)local aH=ac(ab.Parent.types)local aI=
ac(ab.Parent.Parent.devtools.views.Profiler.types)local aJ=ac(ab.Parent.Parent.types)local function aK(aL)if aL.flags~=
nil then return aL.flags else return(aL).effectTag end end local aL=function()return os.clock()end aq.
getInternalReactConstants=function(aM)local aN,aO,aP={NoFlags=0,PerformedWork=1,Placement=2},{ImmediatePriority=99,
UserBlockingPriority=98,NormalPriority=97,LowPriority=96,IdlePriority=95,NoPriority=90},{Block=22,ClassComponent=1,
ContextConsumer=9,ContextProvider=10,CoroutineComponent=-1,CoroutineHandlerPhase=-1,DehydratedSuspenseComponent=18,
ForwardRef=11,Fragment=7,FunctionComponent=0,HostComponent=5,HostPortal=4,HostRoot=3,HostText=6,IncompleteClassComponent
=17,IndeterminateComponent=2,LazyComponent=16,MemoComponent=14,Mode=8,OffscreenComponent=23,Profiler=12,
SimpleMemoComponent=15,SuspenseComponent=13,SuspenseListComponent=19,YieldComponent=-1}local function aQ(aR)local aS=if
typeof(aR)=='table'then aR['$$typeof']else aR return if typeof(aS)=='table'then tostring(aS)else aS end local aR,aS,aT,
aU,aV,aW,aX,aY,aZ,a_,a0,a1,a2,a3=aP.ClassComponent,aP.IncompleteClassComponent,aP.FunctionComponent,aP.
IndeterminateComponent,aP.ForwardRef,aP.HostRoot,aP.HostComponent,aP.HostPortal,aP.HostText,aP.Fragment,aP.MemoComponent
,aP.SimpleMemoComponent,aP.SuspenseComponent,aP.SuspenseListComponent local function a4(a5)local a6=aQ(a5)if a6==aB or
a6==aC then return a4(a5.type)elseif a6==az or a6==aA then return a5.render else return a5 end end local function a5(a6)
local a7,a8=a6.type,a6.tag local a9=a7 if typeof(a7)=='table'and a7~=nil then a9=a4(a7)end local ba if a8==aR or a8==aS
then return r(a9)elseif a8==aT or a8==aU then return r(a9)elseif a8==aV then return(a7 and a7.displayName)or r(a9,
'Anonymous')elseif a8==aW then return nil elseif a8==aX then return a7 elseif a8==aY or a8==aZ or a8==a_ then return nil
elseif a8==a0 or a8==a1 then return r(a9,'Anonymous')elseif a8==a2 then return'Suspense'elseif a8==a3 then return
'SuspenseList'else local bb=aQ(a7)if bb==T or bb==U or bb==V then return nil elseif bb==W or bb==X then ba=a6.type.
_context or a6.type.context return string.format('%s.Provider',ba.displayName or'Context')elseif bb==Y or bb==Z then ba=
a6.type._context or a6.type return string.format('%s.Consumer',ba.displayName or'Context')elseif bb==_ or bb==au then
return nil elseif bb==av or bb==aw then return string.format('Profiler(%s)',a6.memoizedProps.id)elseif bb==ax or bb==ay
then return'Scope'else return nil end end end return{getDisplayNameForFiber=a5,getTypeSymbol=aQ,ReactPriorityLevels=aO,
ReactTypeOfWork=aP,ReactTypeOfSideEffect=aN}end aq.attach=function(aM,aN,aO,aP)local aQ,aR,aS,aT,aU,aV=ai.new(),ai.new()
,aj.new(),ai.new(),ai.new(),-1 local function aW(aX)if not aQ:has(aX)then local aY=u()aQ:set(aX,aY)aR:set(aY,aX)end
return(aQ:get(aX))end local aX=aq.getInternalReactConstants(aO.version)local aY,aZ,a_,a0,a1=aX.getDisplayNameForFiber,aX
.getTypeSymbol,aX.ReactPriorityLevels,aX.ReactTypeOfWork,aX.ReactTypeOfSideEffect local a2,a3,a4,a5,a6,a7,a8,a9,ba,bb,bc
,bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw=a1.PerformedWork,a0.FunctionComponent,a0.ClassComponent,a0.
ContextConsumer,a0.DehydratedSuspenseComponent,a0.Fragment,a0.ForwardRef,a0.HostRoot,a0.HostPortal,a0.HostComponent,a0.
HostText,a0.IncompleteClassComponent,a0.IndeterminateComponent,a0.MemoComponent,a0.OffscreenComponent,a0.
SimpleMemoComponent,a0.SuspenseComponent,a0.SuspenseListComponent,a_.ImmediatePriority,a_.UserBlockingPriority,a_.
NormalPriority,a_.LowPriority,a_.IdlePriority,function(...)return aO.overrideHookState(...)end,function(...)return aO.
overrideHookStateDeletePath(...)end,function(...)return aO.overrideHookStateRenamePath(...)end,function(...)return aO.
overrideProps(...)end,function(...)return aO.overridePropsDeletePath(...)end,function(...)return aO.
overridePropsRenamePath(...)end,function(...)return aO.setSuspenseHandler(...)end,function(...)return aO.scheduleUpdate(
...)end local bx=typeof(bv)=='function'and typeof(bw)=='function'if _G.__DEV__ then R(aO)local by,bz=ap.
__REACT_DEVTOOLS_APPEND_COMPONENT_STACK__~=false,ap.__REACT_DEVTOOLS_BREAK_ON_CONSOLE_ERRORS__==true if by or bz then Q{
appendComponentStack=by,breakOnConsoleErrors=bz}end end local by,bz,bA,bB,bC,bD,bE,bF,bG,bH,bI,bJ,bK,bL,bM,bN,bO,bP,bQ,
bR,bS,bT,bU,bV,bW,bX,bY,bZ,b_,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,ca,cb,cc,cd,ce,cf,cg,ch=function(by,bz,bA)if G then local bB
,bC,bD,bE=aY(bz)or'nil',aW(bz),if bA~=nil then aY(bA)else'nil',if bA then aW(bA)else''ah.log(string.format(
'[renderer] %s %s (%d) %s',by,bB,bC,if bA then string.format('%s (%s)',tostring(bD),tostring(bE))else''))end end,aj.new(
),aj.new(),aj.new(),ai.new(),ai.new(),false,0,false,false,{},aj.new(),false,aj.new(),-1,false local function ci(cj)bB:
clear()bz:clear()bA:clear()for ck,cl in cj do if not cl.isEnabled then continue end if cl.type==at then bz:add((cl).
value)elseif cl.type==b then bB:add((cl).value)elseif cl.type==d then if(cl).isValid and(cl).value~=''then bA:add((cl).
value)end elseif cl.type==c then bz:add'%('else ah.warn(string.format('Invalid component filter type "%d"',cl.type))end
end end if ap.__REACT_DEVTOOLS_COMPONENT_FILTERS__~=nil then ci(ap.__REACT_DEVTOOLS_COMPONENT_FILTERS__)else ci(s())end
local function cj(ck)if bE then error'Cannot modify filter preferences while profiling'end aM.getFiberRoots(aN):forEach(
function(cl)aV=aW(b0(cl.current))b1(cl.current)b2(cl.current,false)aV=-1 end)ci(ck)bD:clear()aM.getFiberRoots(aN):
forEach(function(cl)aV=aW(b0(cl.current))b3(aV,cl.current)bY(cl.current,nil,false,false)b5(cl)aV=-1 end)end
local function ck(cl)local cm,cn,co=cl._debugSource,cl.tag,cl.type if cn==a6 then return true elseif cn==ba or cn==bc or
cn==a7 or cn==bg then return true elseif cn==a9 then return false else local cp=aZ(co)if cp==T or cp==U or cp==V or cp==
_ or cp==au then return true end end local cp=b6(cl)if bB:has(cp)then return true end if bz.size>0 then local cq=aY(cl)
if cq~=nil then for cr,cs in bz do if string.match(cq,cs)then return true end end end end if cm~=nil and bA.size>0 then
local cq=cm.fileName for cr,cs in bA do if string.match(cq,cs)then return true end end end return false end b6=function(
cl)local cm,cn=cl.type,cl.tag if cn==a4 or cn==bd then return e elseif cn==a3 or cn==be then return g elseif cn==a8 then
return h elseif cn==a9 then return m elseif cn==bb then return i elseif cn==ba or cn==bc or cn==a7 then return k elseif
cn==bf or cn==bh then return j elseif cn==bi then return n elseif cn==bj then return o else local co=aZ(cm)if co==T or
co==U or co==V then return f elseif co==W or co==X then return f elseif co==Y or co==Z then return f elseif co==_ or co
==au then return k elseif co==av or co==aw then return l else return k end end end b0=function(cl)if aS:has(cl)then
return cl end local cm=cl.alternate if cm~=nil and aS:has(cm)then return cm end aS:add(cl)return cl end local function
cl(cm,cn)local co=b6(cn)if co==e or co==g or co==j or co==h or co==i then if cm==nil then return{context=nil,
didHooksChange=false,isFirstMount=true,props=nil,state=nil}else return{context=b7(cn),didHooksChange=b8((cm).
memoizedState,cn.memoizedState),isFirstMount=false,props=bX((cm).memoizedProps,cn.memoizedProps),state=bX((cm).
memoizedState,cn.memoizedState)}end else return nil end end local function cm(cn)if b6(cn)==e then if bQ~=nil then local
co,cp=aW(b0(cn)),b9(cn)if cp~=nil then bQ:set(co,cp)end end end end local cn={}b9=function(co)if b6(co)==e then local cp
,cq,cr=co.stateNode,cn,cn if cp~=nil then if cp.constructor and cp.constructor.contextType~=nil then cr=cp.context else
cq=cp.context if cq and#am.keys(cq)==0 then cq=cn end end end return{cq,cr}end return nil end local function co(cp)cm(cp
)local cq=cp.child while cq~=nil do co(cq)cq=(cq).sibling end end b7=function(cp)if b6(cp)==e then if bQ~=nil then local
cq=aW(b0(cp))local cr,cs=if bQ:has(cq)then bQ:get(cq)else nil,b9(cp)if cr==nil or cs==nil then return nil end local ct,
cu,cv,cw=cr[1],cr[2],(cs)[1],(cs)[2]if cv~=cn then return bX(ct,cv)elseif cw~=cn then return cu~=cw end end end return
nil end local function cp(cq)local cr=0 for cs,ct in cq do cr=if cs>cr then cs else cr end return cr end local function
cq(cr,cs)if cs==nil then return false end local ct=cs local cu,cv=cp(ct),cp(cr)if cu~=cv then return false end for cw=1,
cu do if not aD(cr[cw],ct[cw])then return false end end return true end local function cr(cs)return cs~=nil and typeof(
cs)=='table'and cs.tag~=nil and cs.create~=nil and cs.destroy~=nil and cs.deps~=nil and(cs.deps==nil or ak.isArray(cs.
deps))and cs.next end local function cs(ct,cu)local cv,cw=ct.memoizedState,cu.memoizedState if cr(cv)and cr(cw)then
return cv~=cw and not cq(cw.deps,cv.deps)end return cw~=cv end b8=function(ct,cu)if ct==nil or cu==nil then return false
end if cu.baseState and cu.memoizedState and cu.next and cu.queue then while cu~=nil do if cs(ct,cu)then return true
else cu=cu.next ct=ct.next end end end return false end bX=function(ct,cu)if ct==nil or cu==nil then return nil end if
cu.baseState~=nil and cu.memoizedState~=nil and cu.next~=nil and cu.queue~=nil then return nil end local cv,cw=aj.new(ak
.concat(am.keys(ct),am.keys(cu))),{}for cx,cy in cv do if ct[cy]~=cu[cy]then table.insert(cw,cy)end end return cw end
local function ct(cu,cv)local cw=cv.tag if cw==a4 or cw==a3 or cw==a5 or cw==bf or cw==bh then return bit32.band(aK(cv),
a2)==a2 else return cu.memoizedProps~=cv.memoizedProps or cu.memoizedState~=cv.memoizedState or cu.ref~=cv.ref end end
local cu,cv,cw,cx,cy,cz,cA={},{},{},{},ai.new(),0 local function cB(cC)if aP.__DEV__ then if not an.isInteger(cC)then ah
.error('pushOperation() was called but the value is not an integer.',cC)end end table.insert(cu,cC)end b5=function(cC)if
#cu==0 and#cv==0 and#cw==0 and cA==nil then if not bE then return end end local cD,cE,cF=#cv+#cw+(if cA==nil then 0 else
1),{},1 local function cG()local cH=cF cF+=1 return cH end cE[cG()]=aN cE[cG()]=aV cE[cG()]=cz local cH=#cE cy:forEach(
function(cI,cJ)cE[cH+cI]=cJ cG()end)if cD>0 then cE[cG()]=K cE[cG()]=cD for cI=#cv,1,-1 do cE[cG()]=cv[cI]end for cI=1,#
cw do cE[cF+cI-1]=cw[cI]end cF=cF+#cw if cA~=nil then cE[cF]=cA cF=cF+1 end end for cI=1,#cu do cE[cF+cI-1]=cu[cI]end cF
=cF+#cu if cx~=nil then table.insert(cx,cE)else aM.emit('operations',cE)end cu={}cv={}cw={}cA=nil cy:clear()cz=0 end
local function cC(cD)if cD==nil or cD==''then return 0 end local cE=cy:get(cD)if cE~=nil then return cE end local cF=cy.
size+1 cy:set(cD,cF)cz+=1 return cF end local function cD(cE,cF)if aP.__DEBUG__ then by('recordMount()',cE,cF)end local
cG,cH,cI,cJ=cE.tag==a9,aW(b0(cE)),cE._debugOwner~=nil,cE.treeBaseDuration~=nil if cG then cB(J)cB(cH)cB(m)cB(if cJ then
1 else 0)cB(if cI then 1 else 0)if bE then if bP~=nil then(bP):set(cH,ca(cE))end end else local cK,cL,cM,cN=cE.key,aY(cE
),b6(cE),cE._debugOwner local cO,cP,cQ,cR=if cN~=nil then aW(b0(cN))else 0,if al.toJSBoolean(cF)then aW(b0(cF))else 0,
cC(cL),if cK==nil then nil else tostring(cK)local cS=cC(cR)cB(J)cB(cH)cB(cM)cB(cP)cB(cO)cB(cQ)cB(cS)end if cJ then aU:
set(cH,aV)cb(cE)end end b2=function(cE,cF)if aP.__DEBUG__ then by('recordUnmount()',cE)end if bW~=nil then if cE==bW or
cE==(bW).alternate then b_(nil)end end local cG,cH=cE.tag==a9,b0(cE)if not aQ:has(cH)then aS:delete(cH)return end local
cI=aW(cH)if cG then cA=cI elseif not ck(cE)then if cF then table.insert(cw,cI)else table.insert(cv,cI)end end aQ:delete(
cH)aR:delete(cI)aS:delete(cH)local cJ=cE.treeBaseDuration~=nil if cJ then aU:delete(cI)aT:delete(cI)end end bY=function(
cE,cF,cG,cH)if G then by('mountFiberRecursively()',cE,cF)end local cI,cJ=cc(cE),not ck(cE)if cJ then cD(cE,cF)end if bK
then if cH then local cK=b6(cE)if cK==i then bL:add(cE.stateNode)cH=false end end end local cK=cE.tag==a0.
SuspenseComponent if cK then local cL=cE.memoizedState~=nil if cL then local cM=cE.child local cN=if cM then cM.sibling
else nil local cO=if cN then cN.child else nil if cO~=nil then bY(cO,if cJ then cE else cF,true,cH)end else local cM,cN=
(bg==-1)if cM then cN=cE.child elseif cE.child~=nil then cN=(cE.child).child end if cN~=nil then bY(cN,if cJ then cE
else cF,true,cH)end end else if cE.child~=nil then bY(cE.child,if cJ then cE else cF,true,cH)end end cd(cI)if cG and cE.
sibling~=nil then bY(cE.sibling,cF,true,cH)end end b1=function(cE)if aP.__DEBUG__ then by(
'unmountFiberChildrenRecursively()',cE)end local cF,cG=cE.tag==a0.SuspenseComponent and cE.memoizedState~=nil,cE.child
if cF then local cH=cE.child local cI=if cH then cH.sibling else nil cG=if cI then cI.child else nil end while cG~=nil
do if(cG).return_~=nil then b1(cG)b2(cG,true)end cG=(cG).sibling end end cb=function(cE)local cF,cG,cH=aW(b0(cE)),cE.
actualDuration,cE.treeBaseDuration aT:set(cF,cH or 0)if bE then local cI=cE.alternate if cI==nil or cH~=(cI).
treeBaseDuration then local cJ=math.floor((cH or 0)*1000)cB(M)cB(cF)cB(cJ)end if cI==nil or ct(cI,cE)then if cG~=nil
then local cJ,cK=cG,cE.child while cK~=nil do cJ=cJ-((cK).actualDuration or 0)cK=(cK).sibling end local cL=bO table.
insert(cL.durations,cF)table.insert(cL.durations,cG)table.insert(cL.durations,cJ)cL.maxActualDuration=math.max(cL.
maxActualDuration,cG)if bG then local cM=cl(cI,cE)if cM~=nil then if cL.changeDescriptions~=nil then(cL.
changeDescriptions):set(cF,cM)end end cm(cE)end end end end end local function cE(cF,cG)local cH,cI={},cG while cI~=nil
do ce(cI,cH)cI=(cI).sibling end local cJ=#cH if cJ<2 then return end cB(L)cB(aW(b0(cF)))cB(cJ)for cK=1,#cH do cB(cH[cK])
end end ce=function(cF,cG)if not ck(cF)then table.insert(cG,aW(b0(cF)))else local cH=cF.child while cH~=nil do ce(cH,cG)
cH=(cH).sibling end end end local function cF(cG,cH,cI,cJ)if aP.__DEBUG__ then by('updateFiberRecursively()',cG,cI)end
if bK then local cK=b6(cG)if cJ then if cK==i then bL:add(cG.stateNode)cJ=false end else if cK==g or cK==e or cK==f then
cJ=ct(cH,cG)end end end if bU~=nil and(bU).id==aW(b0(cG))and ct(cH,cG)then bH=true end local cK,cL,cM=not ck(cG),cG.tag
==bi,false local cN,cO=cL and cH.memoizedState~=nil,cL and cG.memoizedState~=nil if cN and cO then local cP=cG.child
local cQ,cR=if cP then cP.sibling else nil,cH.child local cS=if cR then cR.sibling else nil if cQ~=nil and cS~=nil and
cF(cQ,cS,cG,cJ)then cM=true end elseif cN and not cO then local cP=cG.child if cP~=nil then bY(cP,cG,true,cJ)end cM=true
elseif not cN and cO then b1(cH)local cP=cG.child local cQ=if cP then cP.sibling else nil if cQ~=nil then bY(cQ,cG,true,
cJ)cM=true end else if cG.child~=cH.child then local cP,cQ=cG.child,cH.child while cP do if(cP).alternate then local cR=
(cP).alternate if cF(cP,cR,if cK then cG else cI,cJ)then cM=true end if cR~=cQ then cM=true end else bY(cP,if cK then cG
else cI,false,cJ)cM=true end cP=cP.sibling if not cM and cQ~=nil then cQ=(cQ).sibling end end if cQ~=nil then cM=true
end else if bK then if cJ then local cP=bZ(aW(b0(cG)))for cQ,cR in cP do bL:add(cR.stateNode)end end end end end if cK
then local cP=cG.treeBaseDuration~=nil if cP then cb(cG)end end if cM then if cK then local cP=cG.child if cO then local
cQ=cG.child cP=if cQ then cQ.sibling else nil end if cP~=nil then cE(cG,cP)end return false else return true end else
return false end end local function cG()end local function cH()local cI=cx cx=nil if cI~=nil and#(cI)>0 then for cJ,cK
in cI do aM.emit('operations',cK)end else if bV~=nil then bN=true end aM.getFiberRoots(aN):forEach(function(cJ)aV=aW(b0(
cJ.current))b3(aV,cJ.current)if bE and cJ.memoizedInteractions~=nil then local cK=ak.from(cJ.memoizedInteractions)bO={
changeDescriptions=if bG then ai.new()else nil,durations={},commitTime=aL()-bF,interactions=ak.map(ak.from(cJ.
memoizedInteractions),function(cL)local cM=am.assign({},cL,{timestamp=cL.timestamp-bF})return cM end),maxActualDuration=
0,priorityLevel=nil}end bY(cJ.current,nil,false,false)b5(cJ)aV=-1 end)end end local function cI(cJ)b2(cJ,false)end local
cJ=function(cJ)if cJ==nil then return'Unknown'end if cJ==bk then return'Immediate'elseif cJ==bl then return
'User-Blocking'elseif cJ==bm then return'Normal'elseif cJ==bn then return'Low'elseif cJ==bo then return'Idle'else return
'Unknown'end end local function cK(cL,cM)local cN=cL.current local cO=cN.alternate aV=aW(b0(cN))if bV~=nil then bN=true
end if bK then bL:clear()end local cP=cL.memoizedInteractions~=nil if bE and cP then local cQ=ak.from(cL.
memoizedInteractions)bO={changeDescriptions=if bG then ai.new()else nil,durations={},commitTime=aL()-bF,interactions=ak.
map(ak.from(cL.memoizedInteractions),function(cR)local cS=am.assign({},cR,{timestamp=cR.timestamp-bF})return cS end),
maxActualDuration=0,priorityLevel=if cM==nil then nil else cJ(cM)}end if cO then local cQ,cR=(cO).memoizedState~=nil and
(cO).memoizedState.element~=nil,cN.memoizedState~=nil and cN.memoizedState.element~=nil if not cQ and cR then b3(aV,cN)
bY(cN,nil,false,false)elseif cQ and cR then cF(cN,cO,nil,false)elseif cQ and not cR then b4(aV)b2(cN,false)end else b3(
aV,cN)bY(cN,nil,false,false)end if bE and cP then local cQ=((bT)):get(aV)if cQ~=nil then table.insert(cQ,(bO))else((bT))
:set(aV,{(bO)})end end b5(cL)if bK then aM.emit('traceUpdates',bL)end aV=-1 end bZ=function(cL)local cM,cN={},cf(cL)if
not cN then return cM end local cO=cN while true do if cO.tag==bb or cO.tag==bc then table.insert(cM,cO)elseif cO.child
then(cO.child).return_=cO cO=cO.child end if cO==cN then return cM end while not cO.sibling do if not cO.return_ or cO.
return_==cN then return cM end cO=cO.return_ end(cO.sibling).return_=cO.return_ cO=cO.sibling end return cM end
local function cL(cM)local cN,cO=pcall(function()local cN=cf(cM)if cN==nil then return nil end local cO=(cN).tag==bi and
(cN).memoizedState~=nil if cO then local cP=(cN).child and((cN).child).sibling if cP~=nil then cN=cP end end local cP=
bZ(cM)return ak.map(cP,function(cQ)return cQ.stateNode end)end)if not cN then return nil end return cO end
local function cM(cN)local cO=aR:get(cN)return if cO~=nil then aY(cO)else nil end local function cN(cO,cP)cP=cP or false
local cQ=aO.findFiberByHostInstance(cO)if cQ~=nil then if cP then while cQ~=nil and ck(cQ)do cQ=(cQ).return_ end end
return aW(b0(cQ))end return nil end local function cO(cP)ar(aF(cP)==cP,'Unable to find node on an unmounted component.')
end cf=function(cP)local cQ=aR:get(cP)if cQ==nil then ah.warn(string.format('Could not find Fiber with id "%s"',
tostring(cP)))return nil end local cR=(cQ).alternate if not cR then local cS=aF(cQ)ar(cS~=nil,
'Unable to find node on an unmounted component.')if cS~=(cQ)then return nil end return cQ end local cS,cT=cQ,cR while
true do local cU=cS.return_ if cU==nil then break end local cV=(cU).alternate if cV==nil then local cW=(cU).return_ if
cW~=nil then cS=cW cT=cW continue end break end if(cU).child==(cV).child then local cW=(cU).child while cW do if cW==cS
then cO(cU)return cQ end if cW==cT then cO(cU)return cR end cW=cW.sibling end ar(false,
'Unable to find node on an unmounted component.')end if cS.return_~=cT.return_ then cS=cU cT=cV else local cW,cX=false,(
cU).child while cX do if cX==cS then cW=true cS=cU cT=cV break end if cX==cT then cW=true cT=cU cS=cV break end cX=cX.
sibling end if not cW then cX=(cV).child while cX do if cX==cS then cW=true cS=cV cT=cU break end if cX==cT then cW=true
cT=cV cS=cU break end cX=cX.sibling end ar(cW,
[[Child was not found in either parent set. This indicates a bug in React related to the return pointer. Please file an issue.]]
)end end ar(cS.alternate==cT,
[[Return fibers should always be each others' alternates. This error is likely caused by a bug in React. Please file an issue.]]
)end ar(cS.tag==a9,'Unable to find node on an unmounted component.')if cS.stateNode.current==cS then return cQ end
return cR end local function cP(cQ,cR)local cS=cg(cQ)if cS then ap['$attribute']=t(bU,cR)end end local function cQ(cR)
local cS=aR:get(cR)if cS==nil then ah.warn(string.format('Could not find Fiber with id "%s"',tostring(cR)))return end
local cT,cU,cV=(cS).elementType,(cS).tag,(cS).type if cU==a4 or cU==a3 or cU==bd or cU==be then aP['$type']=cV elseif cU
==a8 then aP['$type']=cV.render elseif cU==bf or cU==bh then aP['$type']=cT~=nil and cT.type~=nil and cT.type or cV else
aP['$type']=nil end end local function cR(cS)local cT=cf(cS)if cT==nil then return nil end local cU,cV=(cT)._debugOwner,
{{displayName=aY(cT)or'Anonymous',id=cS,type=b6(cT)}}if cU then local cW=cU while cW~=nil do ak.unshift(cV,{displayName=
aY(cW)or'Anonymous',id=aW(b0(cW)),type=b6(cW)})cW=(cW)._debugOwner or nil end end return cV end local function cS(cT)
local cU,cV,cW=(cf(cT))if cU~=nil then cV=(cU).stateNode if(cU).memoizedProps~=nil then cW=(cU).memoizedProps.style end
end return{instance=cV,style=cW}end local function cT(cU)local cV=cf(cU)if cV==nil then return nil end local cW,cX,cY,cZ
,c_,c0,c1,c2,c3,c4=(cV)._debugOwner,(cV)._debugSource,(cV).stateNode,(cV).key,(cV).memoizedProps,(cV).memoizedState,(cV)
.dependencies,(cV).tag,(cV).type,b6(cV)local c5,c6,c7,c8=(c2==a3 or c2==bh or c2==a8)and(not not c0 or not not c1),aZ(c3
),false if c2==a4 or c2==a3 or c2==bd or c2==be or c2==bf or c2==a8 or c2==bh then c7=true if cY and cY.context~=nil
then local c9=c4==e and not(c3.contextTypes or c3.contextType)if not c9 then c8=cY.context end end elseif c6==Y or c6==Z
then local c9=c3._context or c3 c8=c9._currentValue or nil local da=(cV).return_ while da~=nil do local db=(da).type
local dc=aZ(db)if dc==W or dc==X then local dd=db._context or db.context if dd==c9 then c8=(da).memoizedProps.value
break end end da=(da).return_ end end local c9=false if c8~=nil then c9=not not c3.contextTypes c8={value=c8}end local
da if cW then da={}local db=cW while db~=nil do table.insert(da,{displayName=aY(db)or'Anonymous',id=aW(b0(db)),type=b6(
db)})db=(db)._debugOwner or nil end end local db,dc=(c2==bi and c0~=nil)if c5 then local dd={}for de,df in ah do pcall(
function()dd[de]=ah[de]ah[de]=function()end end)end pcall(function()dc=O(cV,aO.currentDispatcherRef)end)for dg,dh in ah
do pcall(function()ah[dg]=dd[dg]end)end end local dd,dg=cV while dd.return_~=nil do dd=dd.return_ end local dh=dd.
stateNode if dh~=nil and dh._debugRootType~=nil then dg=dh._debugRootType end return{id=cU,canEditHooks=typeof(bp)==
'function',canEditFunctionProps=typeof(bs)=='function',canEditHooksAndDeletePaths=typeof(bq)=='function',
canEditHooksAndRenamePaths=typeof(br)=='function',canEditFunctionPropsDeletePaths=typeof(bt)=='function',
canEditFunctionPropsRenamePaths=typeof(bu)=='function',canToggleSuspense=bx and(not db or bJ[cU]),canViewSource=c7,
hasLegacyContext=c9,key=cZ,displayName=aY(cV),type_=c4,context=c8,hooks=dc,props=c_,state=if c5 then nil else c0,owners=
da,source=cX or nil,rootType=dg,rendererPackageName=aO.rendererPackageName,rendererVersion=aO.version}end cg=function(cU
)return bU~=nil and(bU).id==cU and not bH end local function cU(cV)local cW=bI for cX,cY in cV do if not al.toJSBoolean(
cW[cY])then cW[cY]={}end cW=cW[cY]end end local function cV(cW,cX)return function(cY)if cX=='hooks'then if#cY==1 then
return true end if cY[#cY]=='subHooks'or cY[#cY-1]=='subHooks'then return true end end local cZ=if cW==nil then bI else
bI[cW]if not al.toJSBoolean(cZ)then return false end for c_=1,#cY do cZ=cZ[cY[c_]]if not al.toJSBoolean(cZ)then return
false end end return true end end local function cW(cX)local cY,cZ,c_=cX.hooks,cX.id,cX.props local c0=aR:get(cZ)if c0==
nil then ah.warn(string.format('Could not find Fiber with id "%s"',tostring(cZ)))return end local c1,c2,c3,c4=(c0).
elementType,(c0).stateNode,(c0).tag,(c0).type if c3==a4 or c3==bd or c3==be then aP['$r']=c2 elseif c3==a3 then aP['$r']
={hooks=cY,props=c_,type=c4}elseif c3==a8 then aP['$r']={props=c_,type=c4.render}elseif c3==bf or c3==bh then aP['$r']={
props=c_,type=c1~=nil and c1.type~=nil and c1.type or c4}else aP['$r']=nil end end local function cX(cY,cZ,c_)local c0=
cg(cY)if c0 then local c1,c2=t(bU,cZ),string.format('$reactTemp%s',tostring(c_))ap[c2]=c1 ah.log(c2)ah.log(c1)end end
local function cY(cZ,c_)local c0=cg(cZ)if c0 then B(t(bU,c_))end end local function cZ(c_,c0)local c1=cg(c_)if c1 then
if c0~=nil then cU(c0)local c2 if(c0)[1]=='hooks'then c2='hooks'end return{id=c_,type='hydrated-path',path=c0,value=A(t(
bU,c0),cV(nil,c2),c0)}else return{id=c_,type='no-change'}end else bH=false if bU==nil or(bU).id~=c_ then bI={}end bU=cT(
c_)if bU==nil then return{id=c_,type='not-found'}end if c0~=nil then cU(c0)end cW(bU)local c2=am.assign({},bU)c2.context
=A(c2.context,cV('context',nil))c2.hooks=A(c2.hooks,cV('hooks','hooks'))c2.props=A(c2.props,cV('props',nil))c2.state=A(
c2.state,cV('state',nil))return{id=c_,type='full-data',value=c2}end end local function c_(c0)local c1=if cg(c0)then bU
else cT(c0)if c1==nil then ah.warn(string.format('Could not find Fiber with id "%s"',tostring(c0)))return end if(c1).
props~=nil then ah.log('Props:',(c1).props)end if(c1).state~=nil then ah.log('State:',(c1).state)end if(c1).hooks~=nil
then ah.log('Hooks:',(c1).hooks)end local c2=cL(c0)if c2~=nil then ah.log('Nodes:',c2)end if(c1).source~=nil then ah.
log('Location:',(c1).source)end end local function c0(c1,c2,c3,c4)local c5=cf(c2)if c5~=nil then local c6=(c5).stateNode
if c1=='context'then c4=ak.slice(c4,1)if(c5).tag==a4 then if#c4==0 then else q(c6.context,c4)end c6:forceUpdate()elseif(
c5).tag==a3 then end elseif c1=='hooks'then if type(bq)=='function'then bq(c5,c3,c4)end elseif c1=='props'then if c6==
nil then if type(bt)=='function'then bt(c5,c4)end else(c5).pendingProps=C(c6.props,c4)c6:forceUpdate()end elseif c1==
'state'then q(c6.state,c4)c6:forceUpdate()end end end local function c1(c2,c3,c4,c5,c6)local c7=cf(c3)if c7~=nil then
local c8=(c7).stateNode if c2=='context'then c5=ak.slice(c5,1)c6=ak.slice(c6,1)if(c7).tag==a4 then if#c5==0 then else v(
c8.context,c5,c6)end c8:forceUpdate()elseif(c7).tag==a3 then end elseif c2=='hooks'then if type(br)=='function'then br(
c7,c4,c5,c6)end elseif c2=='props'then if c8==nil then if type(bu)=='function'then bu(c7,c5,c6)end else(c7).pendingProps
=D(c8.props,c5,c6)c8:forceUpdate()end elseif c2=='state'then v(c8.state,c5,c6)c8:forceUpdate()end end end local function
c2(c3,c4,c5,c6,c7)local c8=cf(c4)if c8~=nil then local c9=(c8).stateNode if c3=='context'then c6=ak.slice(c6,1)if(c8).
tag==a4 then if#c6==0 then c9.context=c7 else w(c9.context,c6,c7)end c9:forceUpdate()elseif(c8).tag==a3 then end elseif
c3=='hooks'then if type(bp)=='function'then bp(c8,c5,c6,c7)end elseif c3=='props'then if c9==nil then if type(bs)==
'function'then bs(c8,c6,c7)end else(c8).pendingProps=E(c9.props,c6,c7)c9:forceUpdate()end elseif c3=='state'then w(c9.
state,c6,c7)c9:forceUpdate()end end end local function c3()local c4={}if bT==nil then error
[[getProfilingData() called before any profiling data was recorded]]end(bT):forEach(function(c5,c6)local c7,c8,c9,da,db=
{},{},ai.new(),ai.new(),bP~=nil and(bP):get(c6)or'Unknown'if bR~=nil then bR:forEach(function(dc,dd)if bS~=nil and(bS):
get(dd)==c6 then table.insert(c8,{dd,dc})end end)end for dc,dd in c5 do local dg,dh,di,dj,dk,dl,dm=dd.changeDescriptions
,dd.durations,dd.interactions,dd.maxActualDuration,dd.priorityLevel,dd.commitTime,{}for dn,dp in di do if not c9:has(dp.
id)then c9:set(dp.id,dp)end table.insert(dm,dp.id)local dq=da:get(dp.id)if dq~=nil then table.insert(dq,dc)else da:set(
dp.id,{dc})end end local dq,dr={},{}for ds=1,#dh,3 do local dt=dh[ds]table.insert(dq,{dt,dh[ds+1]})table.insert(dr,{dt,
dh[ds+2]})end table.insert(c7,{changeDescriptions=if dg~=nil then ak.from(dg:entries())else nil,duration=dj,
fiberActualDurations=dq,fiberSelfDurations=dr,interactionIDs=dm,priorityLevel=dk,timestamp=dl})end local dg,dh=ak.from(
da:entries()),ak.from(c9:entries())table.insert(c4,{commitData=c7,displayName=db,initialTreeBaseDurations=c8,
interactionCommits=ak.from(da:entries()),interactions=ak.from(c9:entries()),rootID=c6})end)return{dataForRoots=c4,
rendererID=aN}end local function c4(c5)if bE then return end bG=c5 bP=ai.new()bR=ai.new(aT)bS=ai.new(aU)bQ=ai.new()aM.
getFiberRoots(aN):forEach(function(c6)local c7=aW(b0(c6.current));((bP)):set(c7,ca(c6.current))if c5 then co(c6.current)
end end)bE=true bF=aL()bT=ai.new()end local function c5()bE=false bG=false end if y(H)=='true'then c4(y(I)=='true')end
local function c6()return false end local function c7(c8)local c9=aW(b0(c8))return bJ:has(c9)end local function c8(c9,da
)if typeof(bv)~='function'or typeof(bw)~='function'then error
[[Expected overrideSuspense() to not get called for earlier React versions.]]end if da then bJ:add(c9)if bJ.size==1 then
bv(c7)end else bJ:delete(c9)if bJ.size==0 then bv(c6)end end local db=aR:get(c9)if db~=nil then bw(db)end end b_=
function(c9)if c9==nil then bW=nil bM=-1 bN=false end bV=c9 end cc=function(c9)if bV==nil or not bN then return false
end local da=c9.return_ local db=if da~=nil then da.alternate else nil if bW==da or bW==db and db~=nil then local dc,dd=
ch(c9),(bV)[bM+1]if dd==nil then error'Expected to see a frame at the next depth.'end if dc.index==(dd).index and dc.key
==(dd).key and dc.displayName==(dd).displayName then bW=c9 bM=bM+1 if bM==#(bV)-1 then bN=false else bN=true end return
false end end bN=false return true end cd=function(c9)bN=c9 end b3=function(c9,da)local db=ca(da)local dc=bD:get(db)or 0
bD:set(db,dc+1)local dd=string.format('%s:%d',db,dc)bC:set(c9,dd)end b4=function(c9)local da=bC:get(c9)if da==nil then
error'Expected root pseudo key to be known.'end local db=string.sub(da,1,ao.lastIndexOf(da,':')-1)local dc=bD:get(db)if
dc==nil then error'Expected counter to be known.'end if dc>1 then bD:set(db,dc-1)else bD:delete(db)end bC:delete(c9)end
ca=function(c9)local da,db,dc=(c9.child)for dd=0,2 do if da==nil then break end local dg=aY(da)if dg~=nil then if
typeof((da).type)=='function'then db=dg elseif dc==nil then dc=dg end end if db~=nil then break end da=(da).child end
return db or dc or'Anonymous'end ch=function(c9)local da,db,dc=c9.key,aY(c9),c9.index if c9.tag==a9 then local dd=aW(b0(
c9))local dg=bC:get(dd)if dg==nil then error'Expected mounted root to have known pseudo key.'end db=dg elseif c9.tag==bb
then db=c9.type end return{displayName=db,key=da,index=dc}end local function c9(da)local db=aR:get(da)if db==nil then
return nil end local dc={}while db~=nil do table.insert(dc,ch(db))db=(db).return_ end ak.reverse(dc)return dc end
local function da()if bV==nil then return nil end if bW==nil then return nil end local db=bW while db~=nil and ck(db)do
db=(db).return_ end if db==nil then return nil end return{id=aW(b0(db)),isFullMatch=bM==#(bV)}end local function db(dc)
bK=dc end return{cleanup=cG,copyElementPath=cY,deletePath=c0,findNativeNodesForFiberID=cL,flushInitialOperations=cH,
getBestMatchForTrackedPath=da,getDisplayNameForFiberID=cM,getFiberIDForNative=cN,getInstanceAndStyle=cS,getOwnersList=cR
,getPathForElement=c9,getProfilingData=c3,handleCommitFiberRoot=cK,handleCommitFiberUnmount=cI,inspectElement=cZ,
logElementToConsole=c_,prepareViewAttributeSource=cP,prepareViewElementSource=cQ,overrideSuspense=c8,overrideValueAtPath
=c2,renamePath=c1,renderer=aO,setTraceUpdatesEnabled=db,setTrackedPath=b_,startProfiling=c4,stopProfiling=c5,
storeAsGlobal=cX,updateComponentFilters=cj,getDisplayNameForRoot=ca}end return aq end)()end,[37]=function()local aa,ab,
ac=a(37)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah={},ac(ae.
Shared)local ai=ac(ae.ReactReconciler)local aj=ac(ab.Parent.Parent.types)local ak=ac(ab.Parent.Parent.devtools.views.
Profiler.types)ag.InspectElementFullDataType='full-data'ag.InspectElementNoChangeType='no-change'ag.
InspectElementNotFoundType='not-found'ag.InspectElementHydratedPathType='hydrated-path'return ag end)()end,[38]=function
()local aa,ab,ac=a(38)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag
,ah=af.Set,af.Array local ai=ac(ab.Parent.Parent.hydration)local aj,ak=ai.dehydrate,ac(ab.Parent.Parent.devtools.views.
Components.types)local al,am=game:GetService'HttpService',{}am.cleanForBridge=function(an,ao,ap)ap=ap or{}if an~=nil
then local aq,ar={},{}local as=aj(an,aq,ar,ap,ao)return{data=as,cleaned=aq,unserializable=ar}else return nil end end am.
copyToClipboard=function(an)end am.copyWithDelete=function(an,ao,ap)ap=ap or 1 local aq,ar=ao[ap],table.clone(an)if ap==
#ao then if ah.isArray(ar)then ah.splice(ar,aq,1)else ar[aq]=nil end else ar[aq]=am.copyWithDelete(an[aq],ao,ap+1)end
return ar end am.copyWithRename=function(an,ao,ap,aq)aq=aq or 1 local ar,as=ao[aq],table.clone(an)if aq==#ao then local
at=ap[aq]as[at]=as[ar]if ah.isArray(as)then ah.splice(as,ar,1)else as[ar]=nil end else as[ar]=am.copyWithRename(an[ar],
ao,ap,aq+1)end return as end am.copyWithSet=function(an,ao,ap,aq)aq=aq or 1 if aq>#ao then return ap end local ar,as=ao[
aq],table.clone(an)as[ar]=am.copyWithSet(an[ar],ao,ap,aq+1)return as end am.serializeToString=function(an)local ao=ag.
new()return al.JSONEncode(an,function(ap,aq)if typeof(aq)=='table'and aq~=nil then if ao:has(aq)then return end ao:add(
aq)end return aq end)end return am end)()end,[39]=function()local aa,ab,ac=a(39)local ad return(function(...)local ae=ab
.Parent.Parent local af,ag=ac(ae.LuauPolyfill),ac(ae.Shared).console local ah=ac(ab.Parent.events)local ai=ac(ab.Parent.
types)local aj=ac(ab.Parent.backend.types)local ak=100 local al=setmetatable({},{__index=ah})local am={__index=al}
function al.new(an)local ao=setmetatable(ah.new(),am)ao._isShutdown=false ao._messageQueue={}ao._timeoutID=nil ao.
_wallUnlisten=nil ao._wall=an ao._wallUnlisten=an.listen(function(ap)ao:emit(ap.event,ap.payload)end)or nil ao:
addListener('overrideValueAtPath',ao.overrideValueAtPath)ao.wall=an return ao end function al.send(an,ao,...)local ap={
...}if an._isShutdown then ag.warn(string.format([[Cannot send message "%s" through a Bridge that has been shutdown.]],
ao))return end table.insert(an._messageQueue,ao)table.insert(an._messageQueue,ap)if not an._timeoutID then an._timeoutID
=af.setTimeout(function()an:_flush()end,0)end end function al.shutdown(an)if an._isShutdown then ag.warn
'Bridge was already shutdown.'return end an:send'shutdown'an._isShutdown=true an.addListener=function()end an.emit=
function()end an:removeAllListeners()local ao=an._wallUnlisten if ao then ao()end repeat an:_flush()until#an.
_messageQueue==0 if an._timeoutID~=nil then af.clearTimeout(an._timeoutID)an._timeoutID=nil end end function al._flush(
an)if an._timeoutID~=nil then af.clearTimeout(an._timeoutID)an._timeoutID=nil end if#an._messageQueue>0 then local ao=1
while ao<#an._messageQueue do an._wall.send(an._messageQueue[ao],table.unpack(an._messageQueue[ao+1]))ao+=2 end table.
clear(an._messageQueue)an._timeoutID=af.setTimeout(function()an:_flush()end,ak)end end function al.overrideValueAtPath(
an,ao)local ap,aq,ar,as,at=ao.id,ao.path,ao.rendererID,ao.type,ao.value if as=='context'then an:send('overrideContext',{
id=ap,path=aq,rendererID=ar,wasForwarded=true,value=at})elseif as=='hooks'then an:send('overrideHookState',{id=ap,path=
aq,rendererID=ar,wasForwarded=true,value=at})elseif as=='props'then an:send('overrideProps',{id=ap,path=aq,rendererID=ar
,wasForwarded=true,value=at})elseif as=='state'then an:send('overrideState',{id=ap,path=aq,rendererID=ar,wasForwarded=
true,value=at})end end return al end)()end,[40]=function()local aa,ab,ac=a(40)local ad return(function(...)local ae={}ae
.__DEBUG__=_G.__DEBUG__ ae.TREE_OPERATION_ADD=1 ae.TREE_OPERATION_REMOVE=2 ae.TREE_OPERATION_REORDER_CHILDREN=3 ae.
TREE_OPERATION_UPDATE_TREE_BASE_DURATION=4 ae.LOCAL_STORAGE_FILTER_PREFERENCES_KEY='React::DevTools::componentFilters'ae
.SESSION_STORAGE_LAST_SELECTION_KEY='React::DevTools::lastSelection'ae.SESSION_STORAGE_RECORD_CHANGE_DESCRIPTIONS_KEY=
'React::DevTools::recordChangeDescriptions'ae.SESSION_STORAGE_RELOAD_AND_PROFILE_KEY='React::DevTools::reloadAndProfile'
ae.LOCAL_STORAGE_SHOULD_BREAK_ON_CONSOLE_ERRORS='React::DevTools::breakOnConsoleErrors'ae.
LOCAL_STORAGE_SHOULD_PATCH_CONSOLE_KEY='React::DevTools::appendComponentStack'ae.LOCAL_STORAGE_TRACE_UPDATES_ENABLED_KEY
='React::DevTools::traceUpdatesEnabled'ae.PROFILER_EXPORT_VERSION=4 ae.CHANGE_LOG_URL=
[[https://github.com/facebook/react/blob/master/packages/react-devtools/CHANGELOG.md]]ae.UNSUPPORTED_VERSION_URL=
[[https://reactjs.org/blog/2019/08/15/new-react-devtools.html#how-do-i-get-the-old-version-back]]local af,ag af=15 ag=10
ae.COMFORTABLE_LINE_HEIGHT=af ae.COMPACT_LINE_HEIGHT=ag return ae end)()end,[41]=function()local aa,ab,ac=a(41)local ad
return(function(...)return{utils=ac(ab.utils),store=ac(ab.store),cache=ac(ab.cache),devtools={Components={views={types=
ac(ab.views.Components.types)}}}}end)()end,[42]=function()local aa,ab,ac=a(42)local ad return(function(...)local ae=ab.
Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai,aj=af.Array,af.Map,af.Set,af.console local ak=ac(ab.
Parent.Parent.events)local al,am=ac(ab.Parent.views.Profiler.utils).prepareProfilingDataFrontendFromBackendAndStore,ac(
ab.Parent.types)local an=ac(ab.Parent.Parent.bridge)local ao=ac(ab.Parent.Parent.backend.types)local ap=ac(ab.Parent.
views.Profiler.types)local aq,ar=ac(ab.Parent.ProfilingCache),(setmetatable({},{__index=ak}))ar.__index=ar function ar.
new(as,at,au)local av=setmetatable(ak.new(),ar)av._dataBackends={}av._dataFrontend=nil av._initialRendererIDs=ai.new()av
._initialSnapshotsByRootID=ah.new()av._inProgressOperationsByRootID=ah.new()av._isProfiling=au av.
_rendererIDsThatReportedProfilingData=ai.new()av._rendererQueue=ai.new()av._bridge=as av._store=at function av.
_takeProfilingSnapshotRecursive(aw,ax,ay)local az=aw._store:getElementByID(ax)if az~=nil then local aA={id=ax,children=
ag.slice(az.children,0),displayName=az.displayName,hocDisplayNames=az.hocDisplayNames,key=az.key,type=az.type}ay:set(ax,
aA)ag.forEach(az.children,function(aB)return aw:_takeProfilingSnapshotRecursive(aB,ay)end)end end function av.
onBridgeOperations(aw,ax)local ay,az=ax[1],ax[2]if aw._isProfiling then local aA=aw._inProgressOperationsByRootID:get(az
)if aA==nil then aA={ax}aw._inProgressOperationsByRootID:set(az,aA)else table.insert(aA,ax)end if not aw.
_initialRendererIDs:has(ay)then aw._initialRendererIDs:add(ay)end if not aw._initialSnapshotsByRootID:has(az)then aw.
_initialSnapshotsByRootID:set(az,ah.new())end aw._rendererIDsThatReportedProfilingData:add(ay)end end function av.
onBridgeProfilingData(aw,ax)if aw._isProfiling then return end local ay=ax.rendererID if not aw._rendererQueue:has(ay)
then error(string.format('Unexpected profiling data update from renderer "%s"',tostring(ay)))end table.insert(aw.
_dataBackends,ax)aw._rendererQueue:delete(ay)if aw._rendererQueue.size==0 then aw._dataFrontend=al(aw._dataBackends,aw.
_inProgressOperationsByRootID,aw._initialSnapshotsByRootID)ag.splice(aw._dataBackends,0)aw:emit'isProcessingData'end end
function av.onBridgeShutdown(aw)aw._bridge:removeListener('operations',aw.onBridgeOperations)aw._bridge:removeListener(
'profilingData',aw.onBridgeProfilingData)aw._bridge:removeListener('profilingStatus',aw.onProfilingStatus)aw._bridge:
removeListener('shutdown',aw.onBridgeShutdown)end function av.onProfilingStatus(aw,ax)if ax then ag.splice(aw.
_dataBackends,0)aw._dataFrontend=nil aw._initialRendererIDs:clear()aw._initialSnapshotsByRootID:clear()aw.
_inProgressOperationsByRootID:clear()aw._rendererIDsThatReportedProfilingData:clear()aw._rendererQueue:clear()for ay,az
in aw._store:getRootIDToRendererID()do if not aw._initialRendererIDs:has(az)then aw._initialRendererIDs:add(az)end end
for aA,aB in aw._store:getRoots()do local aC=ah.new()aw._initialSnapshotsByRootID:set(aB,aC)aw:
_takeProfilingSnapshotRecursive(aB,aC)end end if aw._isProfiling~=ax then aw._isProfiling=ax aw._cache:invalidate()aw:
emit'isProfiling'if not ax then ag.splice(aw._dataBackends,0)aw._rendererQueue:clear()for az,aA in aw.
_rendererIDsThatReportedProfilingData do if not aw._rendererQueue:has(aA)then aw._rendererQueue:add(aA)aw._bridge:send(
'getProfilingData',{rendererID=aA})end end aw:emit'isProcessingData'end end end as:addListener('operations',function(...
)return av:onBridgeOperations(...)end)as:addListener('profilingData',function(...)return av:onBridgeProfilingData(...)
end)as:addListener('profilingStatus',function(...)return av:onProfilingStatus(...)end)as:addListener('shutdown',function
(...)return av:onBridgeShutdown(...)end)as:send'getProfilingStatus'av._cache=aq.new(av)return av end function ar.
getCommitData(as,at,au)if as._dataFrontend~=nil then local av=as._dataFrontend.dataForRoots:get(at)if av~=nil then local
aw=av.commitData[au]if aw~=nil then return aw end end end error(string.format(
'Could not find commit data for root "%s" and commit %s',tostring(at),tostring(au)))end function ar.getDataForRoot(as,at
)if as._dataFrontend~=nil then local au=as._dataFrontend.dataForRoots:get(at)if au~=nil then return au end end error(
string.format('Could not find commit data for root "%s"',tostring(at)))end function ar.didRecordCommits(as)return as.
_dataFrontend~=nil and as._dataFrontend.dataForRoots.size>0 end function ar.isProcessingData(as)return as._rendererQueue
.size>0 or#as._dataBackends>0 end function ar.isProfiling(as)return as._isProfiling end function ar.profilingCache(as)
return as._cache end function ar.profilingData(as,at)if at==nil then return as._dataFrontend end if as._isProfiling then
aj.warn[[Profiling data cannot be updated while profiling is in progress.]]return end ag.splice(as._dataBackends,0)as.
_dataFrontend=at as._initialRendererIDs:clear()as._initialSnapshotsByRootID:clear()as._inProgressOperationsByRootID:
clear()as._cache:invalidate()as:emit'profilingData'return end function ar.clear(as)ag.splice(as._dataBackends,0)as.
_dataFrontend=nil as._initialRendererIDs:clear()as._initialSnapshotsByRootID:clear()as._inProgressOperationsByRootID:
clear()as._rendererQueue:clear()as._cache:invalidate()as:emit'profilingData'end function ar.startProfiling(as)as._bridge
:send('startProfiling',as._store:getRecordChangeDescriptions())end function ar.stopProfiling(as)as._bridge:send
'stopProfiling'end return ar end)()end,[43]=function()local aa,ab,ac=a(43)local ad return(function(...)local ae=ab.
Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Array,af.Map local ai=ab.Parent.views.Profiler local aj=
ac(ai.CommitTreeBuilder)local ak,al,am=aj.getCommitTree,aj.invalidateCommitTrees,ac(ai.FlamegraphChartBuilder)local an,
ao,ap=am.getChartData,am.invalidateChartData,ac(ai.InteractionsChartBuilder)local aq,ar,as=ap.getChartData,ap.
invalidateChartData,ac(ai.RankedChartBuilder)local at,au,av=as.getChartData,as.invalidateChartData,ac(ai.types)local aw=
ac(ab.Parent.types)local ax={}(ax).__index=ax function ax.new(az)local aA=(setmetatable({},ax))aA._fiberCommits=ah.new()
aA._profilerStore=az function aA.getCommitTree(aB,aC)local aD,aE=aC.commitIndex,aC.rootID return ak{commitIndex=aD,
profilerStore=aB._profilerStore,rootID=aE}end function aA.getFiberCommits(aB,aC)local aD,aE=aC.fiberID,aC.rootID local
aF=aB._fiberCommits:get(aD)if aF~=nil then return aF end local aG,aH={},aB._profilerStore:getDataForRoot(aE)ag.forEach(
aH.commitData,function(aI,aJ)if aI.fiberActualDurations:has(aD)then table.insert(aG,aJ)end end)aB._fiberCommits:set(aD,
aG)return aG end function aA.getFlamegraphChartData(aB,aC)local aD,aE,aF=aC.commitIndex,aC.commitTree,aC.rootID return
an{commitIndex=aD,commitTree=aE,profilerStore=aB._profilerStore,rootID=aF}end function aA.getInteractionsChartData(aB,aC
)local aD=aC.rootID return aq{profilerStore=aB._profilerStore,rootID=aD}end function aA.getRankedChartData(aB,aC)local
aD,aE,aF=aC.commitIndex,aC.commitTree,aC.rootID return at{commitIndex=aD,commitTree=aE,profilerStore=aB._profilerStore,
rootID=aF}end return aA end function ax.invalidate(az)az._fiberCommits:clear()al()ao()ar()au()end return ax end)()end,[
44]=function()local aa,ab,ac=a(44)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag,ah=af.Error,af.Map local ai=af.WeakMap local aj=ac(ae.Shared)local ak=ac(ae.React)local al=ak.
createContext local am,an,ao,ap=0,1,2,ak.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
local function aq(ar,as)local at=ap.current if at==nil then error(ag.new
[[react-cache: read and preload may only be called from within a component's render. They are not supported in event handlers or lifecycle methods.]]
)end assert(at~=nil,'assert needed until Luau understands if nil then error()')return at.readContext(ar,as)end local ar=
al(nil)local as,at=ah.new(),ah.new()local function au(av)local aw=as:get(av)if aw==nil then aw=ai.new()as:set(av,aw)end
return aw end local function av(aw,ax,az,aA)local aB=au(aw)local aC=aB:get(aA)if aC==nil then local aD,aE=(ax(az))aD:
andThen(function(aF)if aE.status==am then local aG=aE aG.status=an aG.value=aF end end,function(aF)if aE.status==am then
local aG=aE aG.status=ao aG.value=aF end end)aE={status=am,value=aD}aB:set(aA,aE)return aE else return aC end end local
aw={}aw.createResource=function(ax,az,aA)local aB,aC=(aA or{})aC={clear=function()as[aC]=nil end,invalidate=function(aD)
local aE=au(aC)aE[aD]=nil end,read=function(aD)aq(ar)local aE=az(aD)local aF=av(aC,ax,aD,aE)if aF.status==am then error(
aF.value)elseif aF.status==an then return aF.value elseif aF.status==ao then error(aF.value)else return nil end end,
preload=function(aD)aq(ar)local aE=az(aD)av(aC,ax,aD,aE)end,write=function(aD,aE)local aF,aG=au(aC),{status=an,value=aE}
aF:set(aD,aG)end}at:set(aC,aB)return aC end aw.invalidateResources=function()as:clear()end return aw end)()end,[45]=
function()local aa,ab,ac=a(45)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)
local ag,ah,ai,aj,ak,al=af.util.inspect,af.Array,af.Error,af.Map,af.Object,af.Set local am,an=ac(ae.Shared).console,ac(
ab.Parent.Parent.events)local ao=ac(ab.Parent.Parent.constants)local ap,aq,ar,as,at=ao.TREE_OPERATION_ADD,ao.
TREE_OPERATION_REMOVE,ao.TREE_OPERATION_REORDER_CHILDREN,ao.TREE_OPERATION_UPDATE_TREE_BASE_DURATION,ac(ab.Parent.Parent
.types)local au,av=at.ElementTypeRoot,ac(ab.Parent.Parent.utils)local aw,ax,az,aA,aB=av.getSavedComponentFilters,av.
saveComponentFilters,av.separateDisplayNameAndHOCs,av.shallowDiffers,ac(ab.Parent.Parent.storage)local aC,aD,aE,aF=aB.
localStorageGetItem,aB.localStorageSetItem,ao.__DEBUG__,ac(ab.Parent.ProfilerStore)local aG=ac(ab.Parent.Parent.devtools
.views.Components.types)local aH=ac(ab.Parent.Parent.types)local aI=ac(ab.Parent.Parent.bridge)local aJ=ac(ab.Parent.
types)local aK,aL,aM=function(aK,...)if aE then print('Store',aK,...)end end,'React::DevTools::collapseNodesByDefault',
'React::DevTools::recordChangeDescriptions'local aN=(setmetatable({},{__index=an}))local aO={__index=aN}function aN.new(
aP,aQ)local aR=setmetatable(an.new(),aO)aQ=aQ or{}aR._bridge=aP aR._collapseNodesByDefault=true aR._componentFilters={}
aR._hasOwnerMetadata=false aR._idToElement=aj.new()aR._isNativeStyleEditorSupported=false aR.
_isBackendStorageAPISupported=false aR._nativeStyleEditorValidAttributes=nil aR._ownersMap=aj.new()aR.
_recordChangeDescriptions=false aR._revision=0 aR._roots={}aR._rootIDToCapabilities=aj.new()aR._rootIDToRendererID=aj.
new()aR._supportsNativeInspection=true aR._supportsProfiling=false aR._supportsReloadAndProfile=false aR.
_supportsTraceUpdates=false aR._unsupportedRendererVersionDetected=false aR._weightAcrossRoots=0 if aE then aK(
'constructor','subscribing to Bridge')end aR._collapseNodesByDefault=aC(aL)=='true'aR._recordChangeDescriptions=aC(aM)==
'true'aR._componentFilters=aw()local aS=false if aQ~=nil then aS=(aQ).isProfiling==true local aT,aU,aV,aW=(aQ).
supportsNativeInspection,(aQ).supportsProfiling,(aQ).supportsReloadAndProfile,(aQ).supportsTraceUpdates aR.
_supportsNativeInspection=aT~=false if aU then aR._supportsProfiling=true end if aV then aR._supportsReloadAndProfile=
true end if aW then aR._supportsTraceUpdates=true end end aR._profilerStore=aF.new(aP,aR,aS)aR._onBridgeOperations=aR.
onBridgeOperations aR.onBridgeOperations=function(...)aR:_onBridgeOperations(...)end aR.
_onBridgeOverrideComponentFilters=aR.onBridgeOverrideComponentFilters aR.onBridgeOverrideComponentFilters=function(...)
aR:_onBridgeOverrideComponentFilters(...)end aR._onBridgeShutdown=aR.onBridgeShutdown aR.onBridgeShutdown=function(...)
aR:_onBridgeShutdown(...)end aR._onBridgeStorageSupported=aR.onBridgeStorageSupported aR.onBridgeStorageSupported=
function(...)aR:_onBridgeStorageSupported(...)end aR._onBridgeNativeStyleEditorSupported=aR.
onBridgeNativeStyleEditorSupported aR.onBridgeNativeStyleEditorSupported=function(...)aR:
_onBridgeNativeStyleEditorSupported(...)end aR._onBridgeUnsupportedRendererVersion=aR.onBridgeUnsupportedRendererVersion
aR.onBridgeUnsupportedRendererVersion=function(...)aR:_onBridgeUnsupportedRendererVersion(...)end aP:addListener(
'operations',aR.onBridgeOperations)aP:addListener('overrideComponentFilters',aR.onBridgeOverrideComponentFilters)aP:
addListener('shutdown',aR.onBridgeShutdown)aP:addListener('isBackendStorageAPISupported',aR.onBridgeStorageSupported)aP:
addListener('isNativeStyleEditorSupported',aR.onBridgeNativeStyleEditorSupported)aP:addListener(
'unsupportedRendererVersion',aR.onBridgeUnsupportedRendererVersion)return aR end function aN.assertExpectedRootMapSizes(
aP)if#aP._roots==0 then aP:assertMapSizeMatchesRootCount(aP._idToElement,'_idToElement')aP:
assertMapSizeMatchesRootCount(aP._ownersMap,'_ownersMap')end aP:assertMapSizeMatchesRootCount(aP._rootIDToCapabilities,
'_rootIDToCapabilities')aP:assertMapSizeMatchesRootCount(aP._rootIDToRendererID,'_rootIDToRendererID')end function aN.
assertMapSizeMatchesRootCount(aP,aQ,aR)local aS=#aP._roots if aQ.size~=aS then error(ai.new(string.format(
[[Expected %s to contain %s items, but it contains %s items

%s]],aR,tostring(aS),tostring(aQ.size),ag(aQ,{depth=20}))))
end end function aN.getCollapseNodesByDefault(aP)return aP._collapseNodesByDefault end function aN.
setCollapseNodesByDefault(aP,aQ)aP._collapseNodesByDefault=aQ aD(aL,if aQ then'true'else'false')aP:emit
'collapseNodesByDefault'end function aN.getComponentFilters(aP)return aP._componentFilters end function aN.
setComponentFilters(aP,aQ)if aP._profilerStore:isProfiling()then error'Cannot modify filter preferences while profiling'
end local aR,aS=ah.filter(aP._componentFilters,function(aR)return aR.isEnabled end),ah.filter(aQ,function(aR)return aR.
isEnabled end)local aT=#aR~=#aS if not aT then for aU=1,#aS do local aV,aW=aR[aU],aS[aU]if aA(aV,aW)then aT=true break
end end end aP._componentFilters=aQ ax(aQ)if aT then aP._bridge:send('updateComponentFilters',aQ)end aP:emit
'componentFilters'end function aN.getHasOwnerMetadata(aP)return aP._hasOwnerMetadata end function aN.
getNativeStyleEditorValidAttributes(aP)return aP._nativeStyleEditorValidAttributes end function aN.getNumElements(aP)
return aP._weightAcrossRoots end function aN.getProfilerStore(aP)return aP._profilerStore end function aN.
getRecordChangeDescriptions(aP)return aP._recordChangeDescriptions end function aN.setRecordChangeDescriptions(aP,aQ)aP.
_recordChangeDescriptions=aQ aD(aM,if aQ then'true'else'false')aP:emit'recordChangeDescriptions'end function aN.
getRevision(aP)return aP._revision end function aN.getRootIDToRendererID(aP)return aP._rootIDToRendererID end function
aN.getRoots(aP)return aP._roots end function aN.getSupportsNativeInspection(aP)return aP._supportsNativeInspection end
function aN.getSupportsNativeStyleEditor(aP)return aP._isNativeStyleEditorSupported end function aN.getSupportsProfiling
(aP)return aP._supportsProfiling end function aN.getSupportsReloadAndProfile(aP)return aP._supportsReloadAndProfile and
aP._isBackendStorageAPISupported end function aN.getSupportsTraceUpdates(aP)return aP._supportsTraceUpdates end function
aN.getUnsupportedRendererVersionDetected(aP)return aP._unsupportedRendererVersionDetected end function aN.
containsElement(aP,aQ)return aP._idToElement:get(aQ)~=nil end function aN.getElementAtIndex(aP,aQ)if aQ<0 or aQ>=aP:
getNumElements()then am.warn(string.format('Invalid index %d specified; store contains %d items.',aQ,aP:getNumElements()
))return nil end local aR,aS,aT=0 for aU=1,#aP._roots do aS=aP._roots[aU]aT=(aP._idToElement:get(aS))if#aT.children==0
then continue elseif aR+aT.weight>aQ then break else aR+=aT.weight end end local aU,aV=(aT),aR-1 while aQ~=aV do local
aW=#aU.children for aX=1,aW do local aY=aU.children[aX]local aZ=(aP._idToElement:get(aY))local a_=if aZ.isCollapsed then
1 else aZ.weight if aQ<=aV+a_ then aV+=1 aU=aZ break else aV+=a_ end end end return aU or nil end function aN.
getElementIDAtIndex(aP,aQ)local aR=aP:getElementAtIndex(aQ)return(function()if aR==nil then return nil end return(aR).id
end)()end function aN.getElementByID(aP,aQ)local aR=aP._idToElement:get(aQ)if aR==nil then am.warn(string.format(
'No element found with id "%s"',tostring(aQ)))return nil end return aR end function aN.getIndexOfElementID(aP,aQ)local
aR=aP:getElementByID(aQ)if aR==nil or(aR).parentID==0 then return nil end local aS,aT,aU=aQ,(aR).parentID,0 while true
do local aV=(aP._idToElement:get(aT))local aW=aV.children for aX=1,#aW do local aY=aW[aX]if aY==aS then break end local
aZ=(aP._idToElement:get(aY))aU+=if aZ.isCollapsed then 1 else aZ.weight end if aV.parentID==0 then break end aU+=1 aS=aV
.id aT=aV.parentID end for aV=1,#aP._roots do local aW=aP._roots[aV]if aW==aT then break end local aX=(aP._idToElement:
get(aW))aU+=aX.weight end return aU end function aN.getOwnersListForElement(aP,aQ)local aR,aS={},aP._idToElement:get(aQ)
if aS~=nil then table.insert(aR,ak.assign({},aS,{depth=0}))local aT=aP._ownersMap:get(aQ)if aT~=nil then local aU,aV=aj.
new{{aQ,0}},ah.sort(ah.from(aT),function(aU,aV)return(aP:getIndexOfElementID(aU)or 0)-(aP:getIndexOfElementID(aV)or 0)
end)for aW,aX in aV do local aY=aP._idToElement:get(aX)if aY~=nil then local aZ,a_=aY.parentID,0 while aZ>0 do if aZ==aQ
or aT:has(aZ)then a_=aU:get(aZ)+1 aU:set(aX,a_)break end local a0=aP._idToElement:get(aZ)if a0==nil then break end aZ=(
a0).parentID end if a_==0 then error'Invalid owners list'end table.insert(aR,ak.assign({},aY,{depth=a_}))end end end end
return aR end function aN.getRendererIDForElement(aP,aQ)local aR=aP._idToElement:get(aQ)while aR~=nil do if aR.parentID
==0 then local aS=aP._rootIDToRendererID:get(aR.id)if aS==nil then return nil end return aS else aR=aP._idToElement:get(
aR.parentID)end end return nil end function aN.getRootIDForElement(aP,aQ)local aR=aP._idToElement:get(aQ)while aR~=nil
do if aR.parentID==0 then return aR.id else aR=aP._idToElement:get(aR.parentID)end end return nil end function aN.
isInsideCollapsedSubTree(aP,aQ)local aR=aP._idToElement:get(aQ)while aR~=nil do if(aR).parentID==0 then return false
else aR=aP._idToElement:get(aR.parentID)if aR~=nil and(aR).isCollapsed then return true end end end return false end
function aN.toggleIsCollapsed(aP,aQ,aR)local aS,aT=false,aP:getElementByID(aQ)if aT~=nil then if aR then if(aT).type==au
then error'Root nodes cannot be collapsed'end if not(aT).isCollapsed then aS=true(aT).isCollapsed=true local aU,aV=1-(aT
).weight,(aP._idToElement:get(aT.parentID))while aV~=nil do aV.weight+=aU aV=aP._idToElement:get(aV.parentID)end end
else local aU=aT while aU~=nil do local aV=if(aU).isCollapsed then 1 else aU.weight if(aU).isCollapsed then aS=true(aU).
isCollapsed=false local aW=if(aU).isCollapsed then 1 else(aU).weight local aX,aY=aW-aV,(aP._idToElement:get(aU.parentID)
)while aY~=nil do aY.weight+=aX if(aY).isCollapsed then break end aY=aP._idToElement:get(aY.parentID)end end aU=if(aU).
parentID~=0 then aP:getElementByID((aU).parentID)else nil end end if aS then local aU=0 for aV,aW in aP._roots do local
aX=aP:getElementByID(aW)local aY=(aX).weight aU=aU+aY end aP._weightAcrossRoots=aU aP:emit('mutated',{{},{}})end end end
function aN._adjustParentTreeWeight(aP,aQ,aR)local aS=false while aQ~=nil do(aQ).weight+=aR if(aQ).isCollapsed then aS=
true break end aQ=(aP._idToElement:get(aQ.parentID))end if not aS then aP._weightAcrossRoots+=aR end end function aN.
onBridgeNativeStyleEditorSupported(aP,aQ)local aR,aS=aQ.isSupported,aQ.validAttributes aP._isNativeStyleEditorSupported=
aR aP._nativeStyleEditorValidAttributes=aS or nil aP:emit'supportsNativeStyleEditor'end function aN.onBridgeOperations(
aP,aQ)if aE then am.groupCollapsed'onBridgeOperations'aK('onBridgeOperations',table.concat(aQ,','))end local aR,aS,aT,aU
,aV,aW=false,aQ[1],{},{},3,{''}local function aX()local aY=aV aV+=1 return aY end local aY=aQ[aX()]local aZ=aV+aY while
aV<aZ do local a_=aQ[aX()]table.insert(aW,a_)end while aV<=#aQ do local a_=aQ[aV]if a_==ap then local a0,a1=aQ[aV+1],aQ[
aV+2]aV+=3 if aP._idToElement:has(a0)then error(ai.new((
[[Cannot add node %s because a node with that id is already in the Store.]]):format(tostring(a0))))end local a2,a3=0,(
nil)if a1==au then if aE then aK('Add',string.format('new root node %s',tostring(a0)))end local a4=aQ[aV]>0 aV+=1 local
a5=aQ[aV]>0 aV+=1 aP._roots=ah.concat(aP._roots,a0)aP._rootIDToRendererID:set(a0,aS)aP._rootIDToCapabilities:set(a0,{
hasOwnerMetadata=a5,supportsProfiling=a4})aP._idToElement:set(a0,{children={},depth=-1,displayName=nil,hocDisplayNames=
nil,id=a0,isCollapsed=false,key=nil,ownerID=0,parentID=0,type=a1,weight=0})aR=true else a3=(aQ[aV])aV+=1 a2=(aQ[aV])aV+=
1 local a4=aQ[aV]local a5=aW[a4+1]aV+=1 local a6=aQ[aV]local a7=aW[a6+1]aV+=1 if aE then aK('Add',string.format(
'node %s (%s) as child of %s',tostring(a0),a5 or'null',tostring(a3)))end if not aP._idToElement:has(a3)then error(ai.
new(([[Cannot add child %s to parent %s because parent node was not found in the Store.]]):format(tostring(a0),tostring(
a3))))end local a8=(aP._idToElement:get(a3))table.insert(a8.children,a0)local a9,b=az(a5,a1)local ba={children={},depth=
a8.depth+1,displayName=a9,hocDisplayNames=b,id=a0,isCollapsed=aP._collapseNodesByDefault,key=a7,ownerID=a2,parentID=a8.
id,type=a1,weight=1}aP._idToElement:set(a0,ba)table.insert(aT,a0)aP:_adjustParentTreeWeight(a8,1)if a2>0 then local bb=
aP._ownersMap:get(a2)if bb==nil then bb=al.new()aP._ownersMap:set(a2,bb)end(bb):add(a0)end end elseif a_==aq then local
a0=aQ[aV+1]aV+=2 for a1=1,a0 do local a2=(aQ[aV])if not aP._idToElement:has(a2)then error(ai.new((
[[Cannot remove node %s because no matching node was found in the Store.]]):format(tostring(a2))))end aV+=1 local a3=(aP
._idToElement:get(a2))local a4,a5,a6,a7=a3.children,a3.ownerID,a3.parentID,a3.weight if#a4>0 then error(ai.new(string.
format('Node %s was removed before its children.',tostring(a2))))end aP._idToElement:delete(a2)local a8 if a6==0 then if
aE then aK('Remove',string.format('node %s root',tostring(a2)))end aP._roots=ah.filter(aP._roots,function(a9)return a9~=
a2 end)aP._rootIDToRendererID:delete(a2)aP._rootIDToCapabilities:delete(a2)aR=true else if aE then aK('Remove',string.
format('node %s from parent %s',tostring(a2),tostring(a6)))end a8=(aP._idToElement:get(a6))if a8==nil then error((
[[Cannot remove node %s from parent %s because no matching node was found in the Store.]]):format(tostring(a2),tostring(
a6)))end local a9=ah.indexOf((a8).children,a2)ah.splice((a8).children,a9,1)end aP:_adjustParentTreeWeight(a8,-a7)aU[a2]=
a6 aP._ownersMap:delete(a2)if a5>0 then local a9=aP._ownersMap:get(a5)if a9~=nil then(a9):delete(a2)end end end elseif
a_==ar then local a0,a1=(aQ[aV+1]),(aQ[aV+2])aV+=3 if not aP._idToElement:has(a0)then error(ai.new((
[[Cannot reorder children for node %s because no matching node was found in the Store.]]):format(tostring(a0))))end
local a2=(aP._idToElement:get(a0))local a3=a2.children if#a3~=a1 then error
[[Children cannot be added or removed during a reorder operation.]]end for a4=1,a1 do local a5=aQ[aV+a4-1]a3[a4]=a5 if
_G.__DEV__ then local a6=aP._idToElement:get(a5)if a6==nil or(a6).parentID~=a0 then am.error
[[Children cannot be added or removed during a reorder operation.]]end end end aV=aV+a1 if _G.__DEBUG__ then aK(
'Re-order',string.format('Node %s children %s',tostring(a0),ah.join(a3,',')))end elseif a_==as then aV+=3 else error(
'Unsupported Bridge operation '..tostring(a_))end end aP._revision+=1 if aR then local a_=aP._supportsProfiling aP.
_hasOwnerMetadata=false aP._supportsProfiling=false for a0,a1 in aP._rootIDToCapabilities do local a2,a3=a1.
hasOwnerMetadata,a1.supportsProfiling if a2 then aP._hasOwnerMetadata=true end if a3 then aP._supportsProfiling=true end
end aP:emit'roots'if aP._supportsProfiling~=a_ then aP:emit'supportsProfiling'end end if aE then local a_=ac(ab.Parent.
utils)local a0=a_.printStore am.log(a0(aP,true))am.groupEnd()end aP:emit('mutated',{aT,aU})end function aN.
onBridgeOverrideComponentFilters(aP,aQ)aP._componentFilters=aQ ax(aQ)end function aN.onBridgeShutdown(aP)if aE then aK(
'onBridgeShutdown','unsubscribing from Bridge')end aP._bridge:removeListener('operations',aP.onBridgeOperations)aP.
_bridge:removeListener('shutdown',aP.onBridgeShutdown)aP._bridge:removeListener('isBackendStorageAPISupported',aP.
onBridgeStorageSupported)end function aN.onBridgeStorageSupported(aP,aQ)aP._isBackendStorageAPISupported=aQ aP:emit
'supportsReloadAndProfile'end function aN.onBridgeUnsupportedRendererVersion(aP)aP._unsupportedRendererVersionDetected=
true aP:emit'unsupportedRendererVersionDetected'end return aN end)()end,[46]=function()local aa,ab,ac=a(46)local ad
return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ab.Parent.Parent.devtools.
views.Components.types)local ah=ac(ab.Parent.Parent.types)local ai=ac(ab.Parent.Parent.events)local aj=ac(ab.Parent.
Parent.bridge)local ak=ac(ab.Parent.Parent.backend.types)local al=ac(ab.Parent.views.Profiler.types)return true end)()
end,[47]=function()local aa,ab,ac=a(47)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag=af.Array local ah,ai,aj=game:GetService'HttpService',{},ac(ab.Parent.views.Components.types)local
ak=ac(ab.Parent.types)ai.printElement=function(al,am)am=am or false local an=' 'if#al.children>0 then an=if al.
isCollapsed then'\u{25b8}'else'\u{25be}'end local ao=''if al.key~=nil and al.key~=''then ao=string.format(' key="%s"',
tostring(al.key))end local ap if al.hocDisplayNames~=nil then ap=table.clone(al.hocDisplayNames)end local aq,ar=if ap==
nil then''else string.format(' [%s]',table.concat(ap,'][')),''if am then ar=string.format(' (%s)',if al.isCollapsed then
'1'else tostring(al.weight))end return string.format('%s%s <%s%s>%s%s',('  '):rep(al.depth+1),an,al.displayName or'null'
,ao,aq,ar)end ai.printOwnersList=function(al,am)am=am or false return table.concat(ag.map(al,function(an)return ai.
printElement(an,am)end),'\n')end ai.printStore=function(al,am)am=am or false local an,ao={},0 ag.forEach(al:getRoots(),
function(ap)local aq=((al:getElementByID(ap))).weight table.insert(an,'[root]'..(if am then string.format(' (%d)',aq)
else''))for ar=ao,ao+aq-1 do local as=al:getElementAtIndex(ar)if as==nil then error(string.format(
'Could not find element at index %d',ar))end table.insert(an,ai.printElement(as,am))end ao+=aq end)if ao~=al:
getNumElements()then error(([[Inconsistent Store state. Individual root weights (%s) do not match total weight (%s)]]):
format(tostring(ao),tostring(al:getNumElements())))end al:assertExpectedRootMapSizes()return table.concat(an,'\n')end ai
.sanitizeForParse=function(al)if typeof(al)=='string'then if#al>=2 and string.sub(al,1,1)=="'"and string.sub(al,#al)==
"'"then return'"'..string.sub(al,1,#al-2)..'"'end end return al end ai.smartParse=function(al)if al=='Infinity'then
return math.huge elseif al=='NaN'then return 0 elseif al=='undefined'then return nil else return ah:JSONDecode(ai.
sanitizeForParse(al))end end ai.smartStringify=function(al)if typeof(al)=='number'then elseif al==nil then return
'undefined'end return ah:JSONEncode(al)end return ai end)()end,[50]=function()local aa,ab,ac=a(50)local ad return(
function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ae.Shared)local ah=
ac(ab.Parent.Parent.Parent.Parent.hydration)local ai=ac(ab.Parent.Parent.Parent.Parent.types)return{}end)()end,[52]=
function()local aa,ab,ac=a(52)local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(ae
.LuauPolyfill)local ag,ah,ai=af.Array,af.Map,af.console local aj,ak={},ac(ab.Parent.Parent.Parent.Parent.constants)local
al,am,an,ao,ap,aq=ak.__DEBUG__,ak.TREE_OPERATION_ADD,ak.TREE_OPERATION_REMOVE,ak.TREE_OPERATION_REORDER_CHILDREN,ak.
TREE_OPERATION_UPDATE_TREE_BASE_DURATION,ac(ab.Parent.Parent.Parent.types)local ar,as=ac(ab.Parent.Parent.Parent.Parent.
types).ElementTypeRoot,ac(ab.Parent.Parent.Parent.Parent.types)local at=ac(ab.Parent.types)local function au(av,...)if
al then print('[CommitTreeBuilder]',av,...)end end local function av(aw)if al then local ax,az=aw.nodes,aw.rootID ai.
group'__printTree()'local aA={az,0}while#aA>0 do local aB,aC=table.remove(aA,1),table.remove(aA,1)local aD=ax:get(aB)if
aD==nil then error(string.format('Could not find node with id "%s" in commit tree',tostring(aB)))end ai.log(string.
format('%s%s:%s %s (%s)',string.rep('\u{2022}',aC),tostring((aD).id),tostring((aD).displayName or''),if(aD).key then
string.format('key:"%s"',tostring((aD).key))else'',tostring((aD).treeBaseDuration)))ag.forEach((aD).children,function(aE
)ag.concat(aA,{aE,aC+1})end)end ai.groupEnd()end end local function aw(ax,az)local aA=ah.new(ax.nodes)local function aB(
aC)local aD=table.clone((aA:get(aC)))aA:set(aC,aD)return aD end local aC=3 local function aD()local aE=aC aC+=1 return
aE end local aE,aF,aG=(nil),{''},az[aD()]local aH=aC+aG while aC<aH do local aI=az[aD()]table.insert(aF,aI)end while aC
<=#az do local aI=az[aD()]if aI==am then aE=az[aD()]local aJ=(az[aD()])if aA:has(aE)then error(
'Commit tree already contains fiber '..tostring(aE)..'. This is a bug in React DevTools.')end if aJ==ar then aC+=2 if al
then au('Add',('new root fiber %s'):format(tostring(aE)))end local aK={children={},displayName=nil,hocDisplayNames=nil,
id=aE,key=nil,parentID=0,treeBaseDuration=0,type=aJ}aA:set(aE,aK)else local aK=az[aD()]aC+=1 local aL=az[aD()]local aM,
aN=aF[aL+1],az[aD()]local aO=aF[aN+1]if al then au('Add',('fiber %s (%s) as child of %s'):format(tostring(aE),tostring(
aM or'null'),tostring(aK)))end local aP=aB(aK)aP.children=ag.concat(aP.children,aE)local aQ={children={},displayName=aM,
hocDisplayNames=nil,id=aE,key=aO,parentID=aK,treeBaseDuration=0,type=aJ}aA:set(aE,aQ)end elseif aI==an then local aJ=az[
aD()]for aK=1,aJ do aE=az[aD()]if not aA:has(aE)then error('Commit tree does not contain fiber '..tostring(aE)..
'. This is a bug in React DevTools.')end local aL=aB(aE)local aM=aL.parentID aA:delete(aE)if not aA:has(aM)then else
local aN=aB(aM)if al then au('Remove',('fiber %s from parent %s'):format(tostring(aE),tostring(aM)))end aN.children=ag.
filter(aN.children,function(aO)return aO~=aE end)end end elseif aI==ao then aE=az[aD()]local aJ=az[aD()]local aK=(ag.
slice(az,aC,aC+aJ))aC+=aJ if al then au('Re-order',('fiber %s children %s'):format(tostring(aE),tostring(ag.join(aK,',')
)))end local aL=aB(aE)aL.children=ag.from(aK)elseif aI==ap then aE=az[aD()]local aJ=aB(aE)aJ.treeBaseDuration=az[aD()]/
1000 if al then au('Update',('fiber %s treeBaseDuration to %s'):format(tostring(aE),tostring(aJ.treeBaseDuration)))end
else error(string.format('Unsupported Bridge operation %s at operation index %d',tostring(aI),aC))end end return{nodes=
aA,rootID=ax.rootID}end local function ax(az,aA,aB,aC)local aD=aC.snapshots:get(az)if aD~=nil then aB:set(az,{id=az,
children=aD.children,displayName=aD.displayName,hocDisplayNames=aD.hocDisplayNames,key=aD.key,parentID=aA,
treeBaseDuration=(aC.initialTreeBaseDurations:get(az)),type=aD.type})for aE,aF in aD.children do ax(aF,az,aB,aC)end end
end local az=ah.new()local function aA(aB)local aC,aD,aE=aB.commitIndex,aB.profilerStore,aB.rootID if not az:has(aE)then
az:set(aE,{})end local aF=(az:get(aE))if aC<=#aF then return aF[aC]end local aG=aD:profilingData()if aG==nil then error
'No profiling data available'end local aH=(aG).dataForRoots:get(aE)if aH==nil then error(string.format(
'Could not find profiling data for root "%s"',tostring(aE)))end local aI=(aH).operations if aC==1 then local aJ=ah.new()
ax(aE,0,aJ,aH)if aI~=nil and aC<=#aI then local aK=aw({nodes=aJ,rootID=aE},aI[aC])if al then av(aK)end table.insert(aF,
aK)return aK end else local aJ=aA{commitIndex=aC-1,profilerStore=aD,rootID=aE}if aI~=nil and aC<=#aI then local aK=aw(aJ
,aI[aC])if al then av(aK)end table.insert(aF,aK)return aK end end error(string.format(
[[getCommitTree(): Unable to reconstruct tree for root "%s" and commit %s]],tostring(aE),tostring(aC)))end aj.
getCommitTree=aA local function aB()return az:clear()end aj.invalidateCommitTrees=aB return aj end)()end,[53]=function()
local aa,ab,ac=a(53)local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag,ah,ai=af.Boolean,af.Map,af.Set local aj,ak={},ac(ab.Parent.Parent.Parent.types)local al,am=ac(ab.
Parent.utils).formatDuration,ac(ab.Parent.types)local an=ah.new()local function ao(ap)local aq,ar,as,at=ap.commitIndex,
ap.commitTree,ap.profilerStore,ap.rootID local au=as:getCommitData(at,aq)local av,aw,ax,az=au.fiberActualDurations,au.
fiberSelfDurations,ar.nodes,('%s-%s'):format(tostring(at),tostring(aq))if an:has(az)then return(an:get(az))end local aA,
aB,aC,aD,aE=ah.new(),ai.new(),{},0,0 local function aF(aG,aH,aI)aA:set(aG,aI)local aJ=ax:get(aG)if aJ==nil then error(
string.format('Could not find node with id "%s" in commit tree',tostring(aG)))end local aK,aL,aM,aN,aO,aP,aQ,aR=(aJ).
children,(aJ).displayName,(aJ).hocDisplayNames,(aJ).key,(aJ).treeBaseDuration,av:get(aG)or 0,aw:get(aG)or 0,av:has(aG)
local aS,aT,aU=aL or'Anonymous',if ag.toJSBoolean(aN)then(' key="%s"'):format(tostring(aN))else'',''if aM~=nil and#aM>0
then aU=string.format(' (%s)',tostring(aM[1]))end local aV=string.format('%s%s%s%s',tostring(aS),tostring(aU),tostring(
aT),if aR then string.format(' (%sms of %sms)',tostring(al(aQ)),tostring(al(aP)))else'')aD=math.max(aD,aI)aE=math.max(aE
,aQ)local aW={actualDuration=aP,didRender=aR,id=aG,label=aV,name=aS,offset=aH-aO,selfDuration=aQ,treeBaseDuration=aO}if
aI>#aC then table.insert(aC,{aW})else table.insert(aC[aI-1],aW)end do local aX=#aK while aX>=1 do local aY=aK[aX]local
aZ=aF(aY,aH,aI)aH-=aZ.treeBaseDuration aX-=1 end end return aW end local aG=0 if ax.size>0 then local aH=ax:get(at)if aH
==nil then error(string.format('Could not find root node with id "%s" in commit tree',tostring(at)))end do local aI=#(aH
).children while aI>=1 do local aJ=(aH).children[aI]local aK=ax:get(aJ)if aK==nil then error(string.format(
'Could not find node with id "%s" in commit tree',tostring(aJ)))end aG+=(aK).treeBaseDuration aF(aJ,aG,2)aI-=1 end end
for aI,aJ in av do local aK=ax:get(aI)if aK~=nil then local aL=aK.parentID while aL~=0 do if aB:has(aL)then break else
aB:add(aL)end aK=ax:get(aL)aL=if aK~=nil then aK.parentID else 0 end end end end local aH={baseDuration=aG,depth=aD,
idToDepthMap=aA,maxSelfDuration=aE,renderPathNodes=aB,rows=aC}an:set(az,aH)return aH end aj.getChartData=ao
local function ap()return an:clear()end aj.invalidateChartData=ap return aj end)()end,[54]=function()local aa,ab,ac=a(54
)local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.
Array,af.Map local ai,aj={},ac(ab.Parent.Parent.Parent.types)local ak=ac(ab.Parent.types)local al=ah.new()local function
am(an)local ao,ap=an.profilerStore,an.rootID if al:has(ap)then return(al:get(ap))end local aq=ao:getDataForRoot(ap)if aq
==nil then error(string.format('Could not find profiling data for root "%s"',tostring(ap)))end local ar,as=aq.commitData
,aq.interactions local at,au=if#ar>0 then ar[#ar].timestamp else 0,0 ag.forEach(ar,function(av)au=math.max(au,av.
duration)end)local av={interactions=ag.from(as:values()),lastInteractionTime=at,maxCommitDuration=au}al:set(ap,av)return
av end ai.getChartData=am local function an()return al:clear()end ai.invalidateChartData=an return ai end)()end,[55]=
function()local aa,ab,ac=a(55)local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(ae
.LuauPolyfill)local ag,ah,ai=af.Array,af.Boolean,af.Map local aj,ak={},ac(ab.Parent.Parent.Parent.types)local al=ac(ab.
Parent.Parent.Parent.Parent.types)local am,an,ao,ap=al.ElementTypeForwardRef,al.ElementTypeMemo,ac(ab.Parent.utils).
formatDuration,ac(ab.Parent.types)local aq=ai.new()local function ar(as)local at,au,av,aw=as.commitIndex,as.commitTree,
as.profilerStore,as.rootID local ax=av:getCommitData(aw,at)local az,aA,aB,aC=ax.fiberActualDurations,ax.
fiberSelfDurations,au.nodes,('%s-%s'):format(tostring(aw),tostring(at))if aq:has(aC)then return(aq:get(aC))end local aD,
aE=0,{}for aF,aG in az do local aH=aB:get(aF)if aH==nil then error(string.format(
'Could not find node with id "%s" in commit tree',tostring(aF)))end local aI,aJ,aK,aL=(aH).displayName,(aH).key,(aH).
parentID,(aH).type if aK==0 then continue end local aM=aA:get(aF)or 0 aD=math.max(aD,aM)local aN,aO,aP=aI or'Anonymous',
if ah.toJSBoolean(aJ)then(' key="%s"'):format(tostring(aJ))else'',''if aL==am then aP=' (ForwardRef)'elseif aL==an then
aP=' (Memo)'end local aQ=('%s%s%s (%sms)'):format(tostring(aN),tostring(aP),tostring(aO),tostring(ao(aM)))table.insert(
aE,{id=aF,label=aQ,name=aN,value=aM})end local aH={maxValue=aD,nodes=ag.sort(aE,function(aH,aI)return aI.value-aH.value
end)}aq:set(aC,aH)return aH end aj.getChartData=ar local function as()return aq:clear()end aj.invalidateChartData=as
return aj end)()end,[56]=function()local aa,ab,ac=a(56)local ad return(function(...)local ae=ab.Parent.Parent.Parent.
Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah={},ac(ab.Parent.Parent.Parent.Parent.types)return ag end)()end,[57
]=function()local aa,ab,ac=a(57)local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent.Parent local af=ac(
ae.LuauPolyfill)local ag,ah,ai,aj,ak=af.Array,af.Boolean,af.Error,af.Map,af.Number local al,am,an={},ac(ab.Parent.Parent
.Parent.Parent.constants).PROFILER_EXPORT_VERSION,ac(ab.Parent.Parent.Parent.Parent.backend.types)local ao=ac(ab.Parent.
types)local ap={'var(--color-commit-gradient-0)','var(--color-commit-gradient-1)','var(--color-commit-gradient-2)',
'var(--color-commit-gradient-3)','var(--color-commit-gradient-4)','var(--color-commit-gradient-5)',
'var(--color-commit-gradient-6)','var(--color-commit-gradient-7)','var(--color-commit-gradient-8)',
'var(--color-commit-gradient-9)'}local function aq(ar,as,at)local au=aj.new()for av,aw in ar do for ax,az in aw.
dataForRoots do local aA,aB,aC,aD,aE,aF=az.commitData,az.displayName,az.initialTreeBaseDurations,az.interactionCommits,
az.interactions,az.rootID local aG=as:get(aF)if aG==nil then error(ai.new(string.format(
'Could not find profiling operations for root %s',tostring(aF))))end local aH=at:get(aF)if aH==nil then error(ai.new(
string.format('Could not find profiling snapshots for root %s',tostring(aF))))end local aI=ag.map(aA,function(aI,aJ)
return{changeDescriptions=if aI.changeDescriptions~=nil then aj.new(aI.changeDescriptions)else nil,duration=aI.duration,
fiberActualDurations=aj.new(aI.fiberActualDurations),fiberSelfDurations=aj.new(aI.fiberSelfDurations),interactionIDs=aI.
interactionIDs,priorityLevel=aI.priorityLevel,timestamp=aI.timestamp}end)au:set(aF,{commitData=aI,displayName=aB,
initialTreeBaseDurations=aj.new(aC),interactionCommits=aj.new(aD),interactions=aj.new(aE),operations=aG,rootID=aF,
snapshots=aH})end end return{dataForRoots=au,imported=false}end al.prepareProfilingDataFrontendFromBackendAndStore=aq
local function ar(as)local at=as.version if at~=am then error(string.format('Unsupported profiler export version "%s"',
tostring(at)))end local au=aj.new()ag.forEach(as.dataForRoots,function(av)local aw,ax,az,aA,aB,aC,aD,aE=av.commitData,av
.displayName,av.initialTreeBaseDurations,av.interactionCommits,av.interactions,av.operations,av.rootID,av.snapshots au:
set(aD,{commitData=ag.map(aw,function(aF)local aG,aH,aI,aJ,aK,aL,aM=aF.changeDescriptions,aF.duration,aF.
fiberActualDurations,aF.fiberSelfDurations,aF.interactionIDs,aF.priorityLevel,aF.timestamp return{changeDescriptions=if
aG~=nil then aj.new(aG)else nil,duration=aH,fiberActualDurations=aj.new(aI),fiberSelfDurations=aj.new(aJ),interactionIDs
=aK,priorityLevel=aL,timestamp=aM}end),displayName=ax,initialTreeBaseDurations=aj.new(az),interactionCommits=aj.new(aA),
interactions=aj.new(aB),operations=aC,rootID=aD,snapshots=aj.new(aE)})end)return{dataForRoots=au,imported=true}end al.
prepareProfilingDataFrontendFromExport=ar local function as(at)local au={}at.dataForRoots:forEach(function(av)local aw,
ax,az,aA,aB,aC,aD,aE=av.commitData,av.displayName,av.initialTreeBaseDurations,av.interactionCommits,av.interactions,av.
operations,av.rootID,av.snapshots table.insert(au,{commitData=ag.map(aw,function(aF)local aG,aH,aI,aJ,aK,aL,aM=aF.
changeDescriptions,aF.duration,aF.fiberActualDurations,aF.fiberSelfDurations,aF.interactionIDs,aF.priorityLevel,aF.
timestamp return{changeDescriptions=if aG~=nil then ag.from(aG:entries())else nil,duration=aH,fiberActualDurations=ag.
from(aI:entries()),fiberSelfDurations=ag.from(aJ:entries()),interactionIDs=aK,priorityLevel=aL,timestamp=aM}end),
displayName=ax,initialTreeBaseDurations=ag.from(az:entries()),interactionCommits=ag.from(aA:entries()),interactions=ag.
from(aB:entries()),operations=aC,rootID=aD,snapshots=ag.from(aE:entries())})end)return{version=am,dataForRoots=au}end al
.prepareProfilingDataExport=as local function at(au)local av,aw=(#ap)if ak.isNaN(au)then aw=0 elseif not ak.isFinite(au)
then aw=av else aw=math.max(0,math.min(av,au))*av end return ap[math.round(aw)]end al.getGradientColor=at local function
au(av)local aw=math.round(av*10)/10 return if ah.toJSBoolean(aw)then aw else'<0.1'end al.formatDuration=au
local function av(aw)return math.round(aw*100)end al.formatPercentage=av local function aw(ax)return math.round(math.
round(ax)/100)/10 end al.formatTime=aw local function ax(az,aA,aB,aC)return function(aD,aE)return if aA-az==0 then aE
else(aD-az)/(aA-az)*(aC-aB)end end al.scale=ax return al end)()end,[58]=function()local aa,ab,ac=a(58)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Array,af.Map local ai=({})local aj={
__index=ai}function ai.new()local ak={}ak.listenersMap=ah.new()return(setmetatable(ak,aj))end function ai.addListener(ak
,al,am)local an=ak.listenersMap:get(al)if an==nil then ak.listenersMap:set(al,{am})else local ao=ag.indexOf(an,am)if ao<
1 then table.insert(an,am)end end end function ai.emit(ak,al,...)local am=ak.listenersMap:get(al)if am~=nil then if#am==
1 then local an=am[1]an(...)else local an,ao,ap=false,(table.clone(am))for aq,ar in ao do local as,at=pcall(function(...
)ar(...)return nil end,...)if not as then an=true ap=at end end if an then error(tostring(ap))end end end end function
ai.removeAllListeners(ak)ak.listenersMap:clear()end function ai.removeListener(ak,al,am)local an=ak.listenersMap:get(al)
if an~=nil then local ao=ag.indexOf(an,am)if ao>=1 then ag.splice(an,ao,1)end end end return ai end)()end,[59]=function(
)local aa,ab,ac=a(59)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai=
af.Array,af.Map,af.Set local aj,ak={},ac(ab.Parent.backend.console)local al,am,an=ak.patch,ak.registerRenderer,ac(ab.
Parent.backend.types)local ao=_G aj.installHook=function(ap)if ap.__REACT_DEVTOOLS_GLOBAL_HOOK__ then return nil end
local aq,ar,as,at,au,av=false,{},ah.new(),{},(ah.new())local function aw(ax)return'production'end local function ax(az)
end local az=1 local function aA()az+=1 return az end local function aB(aC)local aD=aA()au:set(aD,aC)local aE=if aq then
'deadcode'else aw(aC)if _G.__DEV__ then pcall(function()local aF,aG=ao.__REACT_DEVTOOLS_APPEND_COMPONENT_STACK__~=false,
ao.__REACT_DEVTOOLS_BREAK_ON_CONSOLE_ERRORS__==true if aF or aG then am(aC)al{appendComponentStack=aF,
breakOnConsoleErrors=aG}end end)end local aF=ap.__REACT_DEVTOOLS_ATTACH__ if type(aF)=='function'then local aG=aF(av,aD,
aC,ap)av.rendererInterfaces:set(aD,aG)end av.emit('renderer',{id=aD,renderer=aC,reactBuildType=aE})return aD end
local function aC(aD,aE)av.on(aD,aE)return function()return av.off(aD,aE)end end local function aD(aE,aF)if not at[aE]
then at[aE]={}end table.insert(at[aE],aF)end local function aE(aF,aG)if not at[aF]then return end local aH=ag.indexOf(at
[aF],aG)if aH~=-1 then ag.splice(at[aF],aH,1)end if#at[aF]==0 then at[aF]=nil end end local function aF(aG,aH)if at[aG]
then for aI,aJ in at[aG]do aJ(aH)end end end local function aG(aH)local aI=ar if not aI[aH]then aI[aH]=ai.new()end
return aI[aH]end local function aH(aI,aJ)local aK=as:get(aI)if aK~=nil then aK.handleCommitFiberUnmount(aJ)end end
local function aI(aJ,aK,aL)local aM,aN=av.getFiberRoots(aJ),aK.current local aO,aP=aM[aK]~=nil,aN.memoizedState==nil or
aN.memoizedState.element==nil if not aO and not aP then aM[aK]=true elseif aO and aP then aM[aK]=nil end local aQ=as:
get(aJ)if aQ~=nil then aQ.handleCommitFiberRoot(aK,aL)end end av={rendererInterfaces=as,listeners=at,renderers=au,emit=
aF,getFiberRoots=aG,inject=aB,on=aD,off=aE,sub=aC,supportsFiber=true,checkDCE=ax,onCommitFiberUnmount=aH,
onCommitFiberRoot=aI}ap.__REACT_DEVTOOLS_GLOBAL_HOOK__=av return av end return aj end)()end,[60]=function()local aa,ab,
ac=a(60)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=af.Symbol
local function ah(ai)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('!!! '..ai..
' was called, but is stubbed! ')end local ai={}ai.meta={inspectable=ag'inspectable',inspected=ag'inspected',name=ag
'name',preview_long=ag'preview_long',preview_short=ag'preview_short',readonly=ag'readonly',size=ag'size',type=ag'type',
unserializable=ag'unserializable'}local aj=2 ai.createDehydrated=function(ak,al,am,an,ao)ah'createDehydrated'error
'unimplemented createDehydrated'end ai.dehydrate=function(ak,al,am,an,ao,ap)if ap==nil then ap=0 end return ak end ai.
fillInPath=function(ak,al,am,an)ah'fillInPath'end ai.hydrate=function(ak,al,am)return ak end return ai end)()end,[61]=
function()local aa,ab,ac=a(61)local ad return(function(...)local ae={}if _G.__LOCALSTORAGE__==nil then _G.
__LOCALSTORAGE__={}end if _G.__SESSIONSTORAGE__==nil then _G.__SESSIONSTORAGE__={}end local af,ag=_G.__LOCALSTORAGE__,_G
.__SESSIONSTORAGE__ ae.localStorageGetItem=function(ah)return af[ah]end ae.localStorageRemoveItem=function(ah)af[ah]=nil
end ae.localStorageSetItem=function(ah,ai)af[ah]=ai end ae.sessionStorageGetItem=function(ah)return ag[ah]end ae.
sessionStorageRemoveItem=function(ah)ag[ah]=nil end ae.sessionStorageSetItem=function(ah,ai)ag[ah]=ai end return ae end
)()end,[62]=function()local aa,ab,ac=a(62)local ad return(function(...)local ae={}ae.ElementTypeClass=1 ae.
ElementTypeContext=2 ae.ElementTypeFunction=5 ae.ElementTypeForwardRef=6 ae.ElementTypeHostComponent=7 ae.
ElementTypeMemo=8 ae.ElementTypeOtherOrUnknown=9 ae.ElementTypeProfiler=10 ae.ElementTypeRoot=11 ae.ElementTypeSuspense=
12 ae.ElementTypeSuspenseList=13 ae.ComponentFilterElementType=1 ae.ComponentFilterDisplayName=2 ae.
ComponentFilterLocation=3 ae.ComponentFilterHOC=4 return ae end)()end,[63]=function()local aa,ab,ac=a(63)local ad return
(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai,aj=af.Array,af.WeakMap,af.Number,af.
Object local ak,al,am=game:GetService'HttpService',{},ac(ae.Shared)local an,ao=am.getComponentName,ac(ae.ReactIs)local
ap,aq,ar,as,at,au,av,aw,ax,az,aA,aB,aC=ao.isElement,ao.typeOf,ao.ContextConsumer,ao.ContextProvider,ao.ForwardRef,ao.
Fragment,ao.Lazy,ao.Memo,ao.Portal,ao.Profiler,ao.StrictMode,ao.Suspense,ac(ae.Shared).ReactSymbols local aD,aE=aC.
REACT_SUSPENSE_LIST_TYPE,ac(ab.Parent.constants)local aF,aG,aH,aI,aJ=aE.TREE_OPERATION_ADD,aE.TREE_OPERATION_REMOVE,aE.
TREE_OPERATION_REORDER_CHILDREN,aE.TREE_OPERATION_UPDATE_TREE_BASE_DURATION,ac(ab.Parent.types)local aK,aL,aM,aN,aO,aP,
aQ,aR,aS,aT,aU=aJ.ElementTypeRoot,aE.LOCAL_STORAGE_FILTER_PREFERENCES_KEY,aE.
LOCAL_STORAGE_SHOULD_BREAK_ON_CONSOLE_ERRORS,aE.LOCAL_STORAGE_SHOULD_PATCH_CONSOLE_KEY,aJ.ComponentFilterElementType,aJ.
ElementTypeHostComponent,aJ.ElementTypeClass,aJ.ElementTypeForwardRef,aJ.ElementTypeFunction,aJ.ElementTypeMemo,ac(ab.
Parent.storage)local aV,aW,aX=aU.localStorageGetItem,aU.localStorageSetItem,ac(ab.Parent.hydration)local aY=aX.meta
local aZ=ah.new()al.alphaSortKeys=function(a_,a0)return tostring(a_)>tostring(a0)end al.getAllEnumerableKeys=function(a_
)return aj.keys(a_)end al.getDisplayName=function(a_,a0)a0=a0 or'Anonymous'local a1=aZ:get(a_)if a1~=nil then return a1
end local a2=a0 if typeof(a_)=='table'and typeof(a_.__componentName)=='string'then a2=a_.__componentName elseif typeof(
a_)=='table'and typeof(a_.name)=='string'and a_.name~=''then a2=a_.name elseif typeof(a_)=='function'then a2=an(a_)or a2
end aZ:set(a_,a2)return a2 end local a_=0 al.getUID=function()a_+=1 return a_ end al.printOperationsArray=function(a0)
local a1,a2=a0[1],a0[2]local a3,a4={string.format('operations for renderer:%s and root:%s',tostring(a1),tostring(a2))},3
local function a5()local a6=a4 a4+=1 return a6 end local a6,a7={''},a0[a5()]local a8=a4+a7 while a4<a8 do local a9=a0[
a5()]table.insert(a6,a9)end while a4<#a0 do local a9=a0[a4]if a9==aF then local b,ba=a0[a4+1],a0[a4+2]a4+=3 if ba==aK
then table.insert(a3,string.format('Add new root node %d',b))a4+=1 a4+=1 else local bb=a0[a4]a4+=1 a4+=1 local bc=a0[a4]
local bd=a6[bc+1]a4+=1 a4+=1 table.insert(a3,string.format('Add node %d (%s) as child of %d',b,bd or'null',bb))end
elseif a9==aG then local b=a0[a4+1]a4+=2 for ba=1,b do local bb=a0[a4]a4+=1 table.insert(a3,string.format(
'Remove node %d',bb))end elseif a9==aH then local b,ba=a0[a4+1],a0[a4+2]a4+=3 local bb=ag.slice(a0,a4,a4+ba)a4+=ba table
.insert(a3,string.format('Re-order node %d children %s',b,ag.join(bb,',')))elseif a9==aI then a4+=3 else error(string.
format('Unsupported Bridge operation %d',a9))end end print(table.concat(a3,'\n  '))end al.getDefaultComponentFilters=
function()return{{type=aO,value=aP,isEnabled=true}}end al.getSavedComponentFilters=function()local a0,a1=pcall(function(
)local a0=aV(aL)if a0~=nil then return ak:JSONDecode(a0)end return nil end)if not a0 then return al.
getDefaultComponentFilters()end return a1 end al.saveComponentFilters=function(a0)aW(aL,ak:JSONEncode(a0))end al.
getAppendComponentStack=function()local a0,a1=pcall(function()local a0=aV(aN)if a0~=nil then return ak:JSONDecode(a0)end
return nil end)if not a0 then return true end return a1 end al.setAppendComponentStack=function(a0)aW(aN,ak:JSONEncode(
a0))end al.getBreakOnConsoleErrors=function()local a0,a1=pcall(function()local a0=aV(aM)if a0~=nil then return ak:
JSONDecode(a0)end return nil end)if a0 then return a1 end return false end al.setBreakOnConsoleErrors=function(a0)aW(aM,
ak:JSONEncode(a0))end al.separateDisplayNameAndHOCs=function(a0,a1)if a0==nil then return nil,nil end local a2 if a1==aQ
or a1==aR or a1==aS or a1==aT then if string.find(a0,'(',1,true)then local a3={}for a4 in string.gmatch(a0,'[^()]+')do
table.insert(a3,a4)end local a5=#a3 local a6=a3[a5]a3[a5]=nil a0=a6 a2=a3 end end if a1==aT then if a2==nil then a2={
'Memo'}else ag.unshift(a2,'Memo')end elseif a1==aR then if a2==nil then a2={'ForwardRef'}else ag.unshift(a2,'ForwardRef'
)end end return a0,a2 end al.shallowDiffers=function(a0,a1)for a2,a3 in a0 do if a1[a2]~=a3 then return true end end
return false end al.getInObject=function(a0,a1)return ag.reduce(a1,function(a2,a3)if a2 then if a2[a3]~=nil then return
a2[a3]end end return nil end,a0)end al.deletePathInObject=function(a0,a1)local a2=#a1 local a3=a1[a2]if a0~=nil then
local a4=al.getInObject(a0,ag.slice(a1,0,a2))if a4 then if ag.isArray(a4)then ag.splice(a4,a3,1)else a4[a3]=nil end end
end end al.renamePathInObject=function(a0,a1,a2)local a3=#a1 if a0~=nil then local a4=al.getInObject(a0,ag.slice(a1,1,a3
))if a4 then local a5,a6=a1[a3],a2[a3]a4[a6]=a4[a5]if ag.isArray(a4)then ag.splice(a4,a5,1)else a4[a5]=nil end end end
end al.setInObject=function(a0,a1,a2)local a3=#a1 local a4=a1[a3]if a0~=nil then local a5=al.getInObject(a0,ag.slice(a1,
1,a3))if a5 then a5[a4]=a2 end end end al.getDataType=function(a0)if a0==nil then return'null'end if ap(a0)then return
'react_element'end local a1=typeof(a0)if a1=='bigint'then return'bigint'elseif a1=='boolean'then return'boolean'elseif
a1=='function'then return'function'elseif a1=='number'then if ai.isNaN(a0)then return'nan'elseif not ai.isFinite(a0)then
return'infinity'else return'number'end elseif a1=='object'then if ag.isArray(a0)then return'array'else return'object'end
elseif a1=='string'then return'string'elseif a1=='nil'then return'nil'else return'unknown'end end al.
getDisplayNameForReactElement=function(a0)local a1=aq(a0)if a1==ar then return'ContextConsumer'elseif a1==as then return
'ContextProvider'elseif a1==at then return'ForwardRef'elseif a1==au then return'Fragment'elseif a1==av then return'Lazy'
elseif a1==aw then return'Memo'elseif a1==ax then return'Portal'elseif a1==az then return'Profiler'elseif a1==aA then
return'StrictMode'elseif a1==aB then return'Suspense'elseif a1==aD then return'SuspenseList'else local a2=if a0 then a0.
type else nil if typeof(a2)=='string'then return a2 elseif typeof(a2)=='function'then return al.getDisplayName(a2,
'Anonymous')elseif a2~=nil then return'NotImplementedInDevtools'else return'Element'end end end local a0=50
local function a1(a2,a3)a3=a3 or a0 if string.len(a2)>(a3)then return string.sub(a2,1,(a3)+1)..'\u{2026}'else return a2
end end function al.formatDataForPreview(a2,a3)if a2[aY.type]~=nil then return(function()if a3 then return a2[aY.
preview_long]end return a2[aY.preview_short]end)()end local a4=al.getDataType(a2)if a4=='html_element'then return string
.format('<%s />',a1(string.lower(a2.tagName)))elseif a4=='function'then return a1(string.format('\u{192} %s() {}',(
function()if typeof(a2.name)=='function'then return''end return a2.name end)()))elseif a4=='string'then return string.
format('"%s"',tostring(a2))elseif a4=='react_element'then return string.format('<%s />',a1(al.
getDisplayNameForReactElement(a2)or'Unknown'))elseif a4=='array'then local a5=a2 if a3 then local a6=''for a7=1,#a5 do
if a7>1 then a6..=', 'end a6=a6..al.formatDataForPreview(a5[a7],false)if string.len(a6)>a0 then break end end return
string.format('[%s]',a1(a6))else local a6=(function()if a5[#aY]~=nil then return a5[#aY]end return#a5 end)()return
string.format('Array(%s)',a6)end elseif a4=='object'then if a3 then local a5=al.getAllEnumerableKeys(a2)table.sort(a5,al
.alphaSortKeys)local a6=''for a7=1,#a5 do local a8=a5[a7]if a7>1 then a6=a6..', 'end a6=a6..string.format('%s: %s',
tostring(a8),al.formatDataForPreview(a2[a8],false))if string.len(a6)>a0 then break end end return string.format('{%s}',
a1(a6))else return'{\u{2026}}'end elseif a4=='boolean'or a4=='number'or a4=='infinity'or a4=='nan'or a4=='null'or a4==
'undefined'then return tostring(a2)else local a5,a6=pcall(a1,''..tostring(a2))return if a5 then a6 else'unserializable'
end end return al end)()end,[64]=function()local aa,ab,ac=a(64)local ad return(function(...)local ae=ab.Parent local af,
ag,ah=ac(ae.Shared).console,{},ac(ae.Shared).ReactSymbols local ai,aj,ak,al,am,an,ao,ap,aq,ar,as,at,au,av=ah.
REACT_CONTEXT_TYPE,ah.REACT_ELEMENT_TYPE,ah.REACT_FORWARD_REF_TYPE,ah.REACT_FRAGMENT_TYPE,ah.REACT_LAZY_TYPE,ah.
REACT_MEMO_TYPE,ah.REACT_PORTAL_TYPE,ah.REACT_PROFILER_TYPE,ah.REACT_PROVIDER_TYPE,ah.REACT_STRICT_MODE_TYPE,ah.
REACT_SUSPENSE_TYPE,ah.REACT_SUSPENSE_LIST_TYPE,ac(ae.Shared).isValidElementType,ah.REACT_BINDING_TYPE local function aw
(ax)if typeof(ax)=='table'and ax~=nil then local az=ax['$$typeof']if az==aj then local aA=ax.type if aA==al or aA==ap or
aA==ar or aA==as or aA==at then return aA else local aB=aA and typeof(aA)=='table'and aA['$$typeof']if aB==ai or aB==ak
or aB==am or aB==an or aB==aq then return aB else return az end end elseif az==ao or az==av then return az end end
return nil end ag.typeOf=aw local ax=ai ag.ContextConsumer=ax local az=aq ag.ContextProvider=az local aA=aj ag.Element=
aA local aB=ak ag.ForwardRef=aB local aC=al ag.Fragment=aC local aD=am ag.Lazy=aD local aE=an ag.Memo=aE local aF=ao ag.
Portal=aF local aG=ap ag.Profiler=aG local aH=ar ag.StrictMode=aH local aI=as ag.Suspense=aI ag.Binding=ah.
REACT_BINDING_TYPE ag.isValidElementType=au local aJ,aK=false,false local function aL(aM)if _G.__DEV__ then if not aJ
then aJ=true af.warn[[The ReactIs.isAsyncMode() alias has been deprecated, and will be removed in React 18+.]]end end
return false end ag.isAsyncMode=aL local function aM(aN)if _G.__DEV__ then if not aK then aK=true af.warn
[[The ReactIs.isConcurrentMode() alias has been deprecated, and will be removed in React 18+.]]end end return false end
ag.isConcurrentMode=aM local function aN(aO)return aw(aO)==ai end ag.isContextConsumer=aN local function aO(aP)return
aw(aP)==aq end ag.isContextProvider=aO local function aP(aQ)return typeof(aQ)=='table'and aQ~=nil and aQ['$$typeof']==aj
end ag.isElement=aP local function aQ(aR)return aw(aR)==ak end ag.isForwardRef=aQ local function aR(aS)return aw(aS)==al
end ag.isFragment=aR local function aS(aT)return aw(aT)==am end ag.isLazy=aS local function aT(aU)return aw(aU)==an end
ag.isMemo=aT local function aU(aV)return aw(aV)==ao end ag.isPortal=aU local function aV(aW)return aw(aW)==ap end ag.
isProfiler=aV local function aW(aX)return aw(aX)==ar end ag.isStrictMode=aW local function aX(aY)return aw(aY)==as end
ag.isSuspense=aX ag.isBinding=function(aY)return aw(aY)==av end return ag end)()end,[65]=function()local aa,ab,ac=a(65)
local ad return(function(...)local ae,af=ac(ab.ReactInternalTypes),ac(ab.ReactRootTags)local function ag(ah)local ai=ac(
ab.ReactFiberHostConfig)for aj,ak in ah do ai[aj]=ak end return ac(ab.ReactFiberReconciler)end return ag end)()end,[66]=
function()local aa,ab,ac=a(66)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.Shared)local ag,ah,
ai,aj=af.console,{},(ac(ab.Parent.ReactFiberLane))local ak,al,am,an,ao=ac(ae.Shared).ReactFeatureFlags.
enableDebugTracing,ag,{},0 function decimalToBinaryString(ap)local aq=''repeat local ar=ap/2 local as,at=math.modf(ar)ap
=as aq=math.ceil(at)..aq until ap==0 local ar=31-string.len(aq)return string.rep('0',ar)..aq end local function ap(aq)
return'0b'..decimalToBinaryString(aq)end local function aq(...)for ar,as in{...}do table.insert(am,as)end if ao==nil
then ao=al.log al.log=aj end end local function ar()table.remove(am,1)while an>#am do al.groupEnd()an-=1 end if#am==0
then al.log=ao ao=nil end end function aj(...)if an<#am then for as=an+1,#am do local at=am[as]al.group(at)end an=#am
end if typeof(ao)=='function'then(ao)(...)else al.log(...)end end local as=''local function at(au)if _G.__DEV__ then if
ak then aq(string.format('* commit (%s)',ap(au)),as,'','')end end end ah.logCommitStarted=at local function au()if _G.
__DEV__ then if ak then ar()end end end ah.logCommitStopped=au local function av(aw,ax)if _G.__DEV__ then if ak then aj(
string.format('* %s suspended',aw))ax:andThen(function()aj(string.format('* %s resolved',aw))end,function()aj(string.
format('* %s rejected',aw))end)end end end ah.logComponentSuspended=av local function aw(ax)if _G.__DEV__ then if ak
then aq(string.format('* layout effects (%s)',ap(ax)))end end end ah.logLayoutEffectsStarted=aw local function ax()if _G
.__DEV__ then if ak then ar()end end end ah.logLayoutEffectsStopped=ax local function az(aA)if _G.__DEV__ then if ak
then aq(string.format('* passive effects (%s)',ap(aA)))end end end ah.logPassiveEffectsStarted=az local function aA()if
_G.__DEV__ then if ak then ar()end end end ah.logPassiveEffectsStopped=aA local function aB(aC)if _G.__DEV__ then if ak
then aq(string.format('* render (%s)',ap(aC)))end end end ah.logRenderStarted=aB local function aC()if _G.__DEV__ then
if ak then ar()end end end ah.logRenderStopped=aC local function aD(aE,aF)if _G.__DEV__ then if ak then aj(string.
format('* %s forced update (%s)',aE,ap(aF)))end end end ah.logForceUpdateScheduled=aD local function aE(aF,aG,aH)if _G.
__DEV__ then if ak then aj(string.format('* %s updated state (%s)',aF,ap(aG)))end end end ah.logStateUpdateScheduled=aE
return ah end)()end,[67]=function()local aa,ab,ac=a(67)local ad return(function(...)return{MAX_SIGNED_31_BIT_INT=
1073741823}end)()end,[68]=function()local aa,ab,ac=a(68)local ad return(function(...)local ae=ac(ab.Parent.
ReactInternalTypes)local af=ac(ab.Parent.ReactFiberComponentStack).getStackByFiberInDevAndProd local ag={}ag.
createCapturedValue=function(ah,ai)return{value=ah,source=ai,stack=af(ai)}end return ag end)()end,[69]=function()local
aa,ab,ac=a(69)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent.Parent local ag=ac(af.LuauPolyfill)local ah,
ai=ag.Array,ag.Error local aj,ak,al=ac(af.Shared).console,ac(af.Shared).describeError,ac(af.Shared)local am=ac(af.React)
local an=ac(ab.Parent.ReactInternalTypes)local ao=ac(ab.Parent.ReactFiberLane)local ap,aq=ac(af.Shared).getComponentName
,ac(ab.Parent.ReactFiberFlags)local ar,as,at=aq.Placement,aq.Deletion,ac(af.Shared).ReactSymbols local au,av,aw,ax,az,aA
,aB=at.getIteratorFn,at.REACT_ELEMENT_TYPE,at.REACT_FRAGMENT_TYPE,at.REACT_PORTAL_TYPE,at.REACT_LAZY_TYPE,at.
REACT_BLOCK_TYPE,ac(ab.Parent.ReactWorkTags)local aC,aD,aE,aF,aG,aH,aI,aJ,aK,aL=aB.FunctionComponent,aB.ClassComponent,
aB.HostText,aB.HostPortal,aB.ForwardRef,aB.Fragment,aB.SimpleMemoComponent,aB.Block,ac(af.Shared).invariant,ac(af.Shared
).ReactFeatureFlags local aM,aN,aO=aL.enableLazyElements,aL.enableBlocksAPI,ac(ab.Parent['ReactFiber.new'])local aP,aQ,
aR,aS,aT,aU,aV,aW,aX,aY,aZ=aO.createWorkInProgress,aO.resetWorkInProgress,aO.createFiberFromElement,aO.
createFiberFromFragment,aO.createFiberFromText,aO.createFiberFromPortal,{},function(aP,aQ)end if ae then aX=false aY={}
aZ={}aW=function(a_,a0)if a_==nil or type(a_)~='table'then return end if not a_._store or a_._store.validated or a_.key
~=nil then return end aK(a_._store~=nil and type(a_._store)=='table',
[[React Component in warnForMissingKey should have a _store. This error is likely caused by a bug in React. Please file an issue.]]
)a_._store.validated=true local a1=ap(a0.type)or'Component'if aY[a1]then return end aY[a1]=true aj.error
[[Each child in a list should have a unique "key" prop. See https://reactjs.org/link/warning-keys for more information.]]
end end local a_=ah.isArray function coerceRef(a0,a1,a2)local a3=a2.ref if a3~=nil and type(a3)=='string'then if not a2.
_owner or not a2._self or a2._owner.stateNode==a2._self then local a4 if ae then a4=ap(a0.type)or'Component'else a4=
'<enable __DEV__ mode for component names>'end error(ai.new(string.format(
[[Component "%s" contains the string ref "%s". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref]]
,a4,tostring(a3))))end if not a2._owner then error
[[Expected ref to be a function or an object returned by React.createRef(), or nil.]]end end return a3 end
local function a0(a1)if ae then local a2=ap(a1.type)or'Component'if aZ[a2]then return end aZ[a2]=true aj.error
[[Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.]]
end end function resolveLazyType(a1)local a2,a3=a1._payload,a1._init local a4,a5=xpcall(a3,ak,a2)if not a4 then return
a1 end return a5 end local function a1(a2)local function a3(a4,a5)if not a2 then return end local a6=a4.deletions if a6
==nil then a4.deletions={a5}a4.flags=bit32.bor(a4.flags,as)else table.insert(a6,a5)end end local function a4(a5,a6)if
not a2 then return nil end local a7=a6 while a7~=nil do a3(a5,a7)a7=a7.sibling end return nil end local function a5(a6,
a7)local a8,a9={},a7 while a9~=nil do if a9.key~=nil then a8[a9.key]=a9 else a8[a9.index]=a9 end a9=a9.sibling end
return a8 end local function a6(a7,a8)local a9=aP(a7,a8)a9.index=1 a9.sibling=nil return a9 end local function a7(a8,a9,
b)a8.index=b if not a2 then return a9 end local ba=a8.alternate if ba~=nil then local bb=ba.index if bb<a9 then a8.flags
=bit32.bor(a8.flags,ar)return a9 else return bb end else a8.flags=bit32.bor(a8.flags,ar)return a9 end end local function
a8(a9)if a2 and a9.alternate==nil then a9.flags=bit32.bor(a9.flags,ar)end return a9 end local function a9(b,ba,bb,bc)if
ba==nil or(ba).tag~=aE then local bd=aT(bb,b.mode,bc)bd.return_=b return bd else local bd=a6(ba,bb)bd.return_=b return
bd end end local function b(ba,bb,bc,bd)if bb~=nil then if(bb).elementType==bc.type then local be=a6(bb,bc.props)be.ref=
coerceRef(ba,bb,bc)be.return_=ba if ae then be._debugSource=bc._source be._debugOwner=bc._owner end return be elseif aN
and(bb).tag==aJ then local be=bc.type if type(be)=='table'and be['$$typeof']==az then be=resolveLazyType(be)end if be[
'$$typeof']==aA and be._render==(bb).type._render then local bf=a6(bb,bc.props)bf.return_=ba bf.type=be if ae then bf.
_debugSource=bc._source bf._debugOwner=bc._owner end return bf end end end local be=aR(bc,ba.mode,bd)be.ref=coerceRef(ba
,bb,bc)be.return_=ba return be end local function ba(bb,bc,bd,be)if bc==nil or(bc).tag~=aF or(bc).stateNode.
containerInfo~=bd.containerInfo or(bc).stateNode.implementation~=bd.implementation then local bf=aU(bd,bb.mode,be)bf.
return_=bb return bf else local bf=a6(bc,bd.children or{})bf.return_=bb return bf end end local function bb(bc,bd,be,bf,
bg)if bd==nil or(bd).tag~=aH then local bh=aS(be,bc.mode,bf,bg)bh.return_=bc return bh else local bh=a6(bd,be)bh.return_
=bc return bh end end local function bc(bd,be)if be.key==nil then local bf=type(bd)if bf=='string'or bf=='number'then be
.key=bd elseif bf=='table'then be.key=tostring(bd)end end end local function bd(be,bf,bg,bh)if bf==nil then return nil
end local bi=type(bf)if bi=='table'then bc(bh,bf)local bj=bf['$$typeof']if bj==av then local bk=aR(bf,be.mode,bg)bk.ref=
coerceRef(be,nil,bf)bk.return_=be return bk elseif bj==ax then local bk=aU(bf,be.mode,bg)bk.return_=be return bk elseif
bj==az then if aM then local bk,bl=bf._payload,bf._init return bd(be,bl(bk),bg)end end local bk=aS(bf,be.mode,bg,nil)bk.
return_=be return bk end if bi=='string'or bi=='number'then local bj=aT(tostring(bf),be.mode,bg)bj.return_=be return bj
end if ae then if bi=='function'then a0(be)end end return nil end local function be(bf,bg,bh,bi,bj)if bh==nil then
return nil end local bk,bl=if bg~=nil then bg.key else nil,type(bh)if bl=='table'then bc(bj,bh)local bm=bh['$$typeof']if
bm==av then if bh.key==bk then if bh.type==aw then return bb(bf,bg,bh.props.children,bi,bk)end return b(bf,bg,bh,bi)else
return nil end elseif bm==ax then if bh.key==bk then return ba(bf,bg,bh,bi)else return nil end elseif bm==az then if aM
then local bn,bo=bh._payload,bh._init return be(bf,bg,bo(bn),bi)end end if bk~=nil then return nil end return bb(bf,bg,
bh,bi)end if bl=='string'or bl=='number'then if bk~=nil then return nil end return a9(bf,bg,tostring(bh),bi)end if ae
then if bl=='function'then a0(bf)end end return nil end local function bf(bg,bh,bi,bj,bk,bl)if bj==nil then return nil
end local bm=type(bj)if bm=='table'then bc(bl,bj)local bn,bo=(bj['$$typeof'])if bn==av then if bj.key==nil then bo=bi
else bo=bj.key end local bp=bg[bo]if bj.type==aw then return bb(bh,bp,bj.props.children,bk,bj.key)end return b(bh,bp,bj,
bk)elseif bn==ax then if bj.key==nil then bo=bi else bo=bj.key end local bp=bg[bo]return ba(bh,bp,bj,bk)elseif bn==az
then if aM then local bp,bq=bj._payload,bj._init return bf(bg,bh,bi,bq(bp),bk)end end local bp=bg[bi]return bb(bh,bp,bj,
bk)end if bm=='string'or bm=='number'then local bn=bg[bi]or nil return a9(bh,bn,tostring(bj),bk)end if ae then if bm==
'function'then a0(bh)end end return nil end local function bg(bh,bi,bj)if ae then if bh==nil or type(bh)~='table'then
return bi end local bk=bh['$$typeof']if bk==av or bk==ax then aW(bh,bj)local bl=bh.key if type(bl)~='string'then elseif
bi==nil then bi={}(bi)[bl]=true elseif not(bi)[bl]then(bi)[bl]=true else aj.error(
'Encountered two children with the same key, `%s`. Keys should be unique so that components maintain their identity across updates. Non-unique keys may cause children to be duplicated and/or omitted \u{2014} the behavior is unsupported and could change in a future version.'
,bl)end elseif bk==az then if aM then local bl,bm=bh._payload,bh._init bg(bm(bl),bi,bj)end end end return bi end
local function bh(bi,bj,bk,bl)if ae then local bm for bn,bo in bk do bm=bg(bo,bm,bi)end end local bm,bn,bo,bp,bq,br,bs=
bj,1,1,(#bk)while bm~=nil and bo<=bp do if bm.index>bo then bs=bm bm=nil else bs=bm.sibling end local bt,bu=(bk[bo])if
bt~=nil and type(bt)=='table'and bt['$$typeof']~=nil then bu=be(bi,bm,bt,bl,bo)else bu=be(bi,bm,bt,bl)end if bu==nil
then if bm==nil then bm=bs end break end if a2 then if bm and(bu).alternate==nil then a3(bi,bm)end end bn=a7(bu,bn,bo)if
br==nil then bq=bu else(br).sibling=bu end br=bu bm=bs bo+=1 end if bo>bp then a4(bi,bm)return bq end if bm==nil then
while bo<=bp do local bt,bu=(bk[bo])if bt~=nil and type(bt)=='table'and bt['$$typeof']~=nil then bu=bd(bi,bt,bl,bo)else
bu=bd(bi,bt,bl)end if bu==nil then bo+=1 continue end bn=a7(bu,bn,bo)if br==nil then bq=bu else(br).sibling=bu end br=bu
bo+=1 end return bq end local bt=a5(bi,bm)while bo<=bp do local bu=bf(bt,bi,bo,bk[bo],bl,bo)if bu~=nil then if a2 then
if bu.alternate~=nil then bt[if bu.key==nil then bo else bu.key]=nil end end bn=a7(bu,bn,bo)if br==nil then bq=bu else(
br).sibling=bu end br=bu end bo+=1 end if a2 then for bu,bv in bt do a3(bi,bv)end end return bq end local function bi(bj
,bk,bl,bm,bn)if ae then if bl.entries==bn then if not aX then aj.error
[[Using Maps as children is not supported. Use an array of keyed ReactElements instead.]]end aX=true end local bo=bn(bl)
if bo then local bp,bq=(bo.next())while not bp.done do bp=bo.next()local br=bp.value bq=bg(br,bq,bj)end end end local bo
,bp,bq,br,bs,bt,bu=bn(bl),bk,1,1 local bv=bo.next()while bp~=nil and not bv.done do if bp.index>br then bu=bp bp=nil
else bu=bp.sibling end local bw=be(bj,bp,bv.value,bm,bv.key)if bw==nil then if bp==nil then bp=bu end break end if a2
then if bp and(bw).alternate==nil then a3(bj,bp)end end bq=a7(bw,bq,br)if bt==nil then bs=bw else bt.sibling=bw end bt=
bw bp=bu br+=1 bv=bo.next()end if bv.done then a4(bj,bp)return bs end if bp==nil then while not bv.done do local bw=bd(
bj,bv.value,bm,bv.key)if bw==nil then br+=1 bv=bo.next()continue end bq=a7(bw,bq,br)if bt==nil then bs=bw else bt.
sibling=bw end bt=bw br+=1 bv=bo.next()end return bs end local bw while not bv.done do if not bw then bw=a5(bj,bp)end
local bx=bf(bw,bj,br,bv.value,bm,bv.key)if bx~=nil then if a2 then if bx.alternate~=nil then if bx.key==nil then bw[br]=
nil else bw[bx.key]=nil end end end bq=a7(bx,bq,br)if bt==nil then bs=bx else bt.sibling=bx end bt=bx end br+=1 bv=bo.
next()end if a2 then for bx,by in bw do a3(bj,by)end end return bs end local function bj(bk,bl,bm,bn)if bl~=nil and(bl).
tag==aE then a4(bk,(bl).sibling)local bo=a6(bl,bm)bo.return_=bk return bo end a4(bk,bl)local bo=aT(bm,bk.mode,bn)bo.
return_=bk return bo end local function bk(bl,bm,bn,bo)local bp,bq=bn.key,bm while bq~=nil do if bq.key==bp then if bq.
tag==aH then if bn.type==aw then a4(bl,bq.sibling)local br=a6(bq,bn.props.children)br.return_=bl if ae then br.
_debugSource=bn._source br._debugOwner=bn._owner end return br end else if bq.elementType==bn.type then a4(bl,bq.sibling
)local br=a6(bq,bn.props)br.ref=coerceRef(bl,bq,bn)br.return_=bl if ae then br._debugSource=bn._source br._debugOwner=bn
._owner end return br end end a4(bl,bq)break else a3(bl,bq)end bq=bq.sibling end if bn.type==aw then local br=aS(bn.
props.children,bl.mode,bo,bn.key)br.return_=bl return br else local br=aR(bn,bl.mode,bo)br.ref=coerceRef(bl,bm,bn)br.
return_=bl return br end end local function bl(bm,bn,bo,bp)local bq,br=bo.key,bn while br~=nil do if br.key==bq then if
br.tag==aF and br.stateNode.containerInfo==bo.containerInfo and br.stateNode.implementation==bo.implementation then a4(
bm,br.sibling)local bs=a6(br,bo.children or{})bs.return_=bm return bs else a4(bm,br)break end else a3(bm,br)end br=br.
sibling end local bs=aU(bo,bm.mode,bp)bs.return_=bm return bs end local function bm(bn,bo,bp,bq)local br=type(bp)local
bs=bp~=nil and br=='table'and bp.type==aw and bp.key==nil if bs then bp=bp.props.children br=type(bp)end local bt=a_(bp)
local bu=bp~=nil and br=='table'and not bt if bu then local bv=bp['$$typeof']if bv==av then return a8(bk(bn,bo,bp,bq))
elseif bv==ax then return a8(bl(bn,bo,bp,bq))elseif bv==az then if aM then local bw,bx=bp._payload,bp._init return bm(bn
,bo,bx(bw),bq)end end elseif bt then return bh(bn,bo,bp,bq)elseif br=='string'or br=='number'then return a8(bj(bn,bo,
tostring(bp),bq))end local bv=au(bp)if bv then return bi(bn,bo,bp,bq,bv)end if ae then if br=='function'then a0(bn)end
end if bp==nil and not bs then local bw=false if bw and(bn.tag==aD or bn.tag==aC or bn.tag==aG or bn.tag==aI)then aK(
false,
[[%s(...): Nothing was returned from render. This usually means a return statement is missing. Or, to render nothing, return nil.]]
,ap(bn.type)or'Component')end end return a4(bn,bo)end return bm end aV.reconcileChildFibers=a1(true)aV.mountChildFibers=
a1(false)aV.cloneChildFibers=function(a2,a3)if a3.child==nil then return end local a4=a3.child local a5=aP(a4,a4.
pendingProps)a3.child=a5 a5.return_=a3 while a4.sibling~=nil do a4=a4.sibling a5.sibling=aP(a4,a4.pendingProps)a5=a5.
sibling a5.return_=a3 end a5.sibling=nil end aV.resetChildFibers=function(a2,a3)local a4=a2.child while a4~=nil do aQ(a4
,a3)a4=a4.sibling end end return aV end)()end,[70]=function()local aa,ab,ac=a(70)local ad return(function(...)local ae,
af,ag=_G.__DEV__,ab.Parent.Parent,ac(ab.Parent.ReactInternalTypes)local ah,ai=ac(af.Shared).ReactSharedInternals,ac(ab.
Parent.ReactFiberComponentStack)local aj,ak,al=ai.getStackByFiberInDevAndProd,ac(af.Shared).getComponentName,ah.
ReactDebugCurrentFrame local am={current=nil,isRendering=false}am.getCurrentFiberOwnerNameInDevOrNull=function()if ae
then if am.current==nil then return nil end local an=(am.current)._debugOwner if an then return ak(an.type)end end
return nil end local function an()if ae then if am.current==nil then return''end return aj(am.current)end return''end am
.resetCurrentFiber=function()if ae then(al).getCurrentStack=nil am.current=nil am.isRendering=false end end am.
setCurrentFiber=function(ao)if ae then(al).getCurrentStack=an am.current=ao am.isRendering=false end end am.
setIsRendering=function(ao)if ae then am.isRendering=ao end end am.getIsRendering=function()if ae then return am.
isRendering end return false end return am end)()end,[71]=function()local aa,ab,ac=a(71)local ad return(function(...)
local ae,af=_G.__DEV__,ab.Parent.Parent local ag=ac(af.LuauPolyfill)local ah,ai,aj,ak,al=ag.Object,ag.Array,ag.util.
inspect,ac(af.Shared).console,ac(af.Shared)local am=ac(ab.Parent.ReactInternalTypes)local an=ac(ab.Parent.ReactRootTags)
local ao=ac(ab.Parent.ReactWorkTags)local ap=ac(ab.Parent.ReactTypeOfMode)local aq=ac(ab.Parent.ReactFiberLane)local ar=
ac(ab.Parent.ReactFiberHostConfig)local as=ac(ab.Parent.ReactFiberOffscreenComponent)local at,au=ac(af.Shared).invariant
,ac(af.Shared).ReactFeatureFlags local av,aw=au.enableProfilerTimer,ac(ab.Parent.ReactFiberFlags)local ax,az,aA,aB,aC,aD
,aE,aF,aG,aH,aI,aJ,aK,aL,aM,aN,aO,aP,aQ,aR,aS,aT,aU,aV,aW,aX,aY,aZ,a_,a0=aw.NoFlags,aw.Placement,aw.StaticMask,an.
ConcurrentRoot,an.BlockingRoot,ao.IndeterminateComponent,ao.ClassComponent,ao.HostRoot,ao.HostComponent,ao.HostText,ao.
HostPortal,ao.ForwardRef,ao.Fragment,ao.Mode,ao.ContextProvider,ao.ContextConsumer,ao.Profiler,ao.SuspenseComponent,ao.
SuspenseListComponent,ao.DehydratedFragment,ao.FunctionComponent,ao.MemoComponent,ao.SimpleMemoComponent,ao.
LazyComponent,ao.FundamentalComponent,ao.ScopeComponent,ao.OffscreenComponent,ao.LegacyHiddenComponent,ac(af.Shared).
getComponentName,ac(ab.Parent['ReactFiberDevToolsHook.new'])local a1,a2=a0.isDevToolsPresent,ac(ab.Parent[
'ReactFiberHotReloading.new'])local a3,a4,a5,a6,a7,a8,a9,b,ba,bb,bc=a2.resolveClassForHotReloading,a2.
resolveFunctionForHotReloading,a2.resolveForwardRefForHotReloading,aq.NoLanes,ap.NoMode,ap.ConcurrentMode,ap.
DebugTracingMode,ap.ProfileMode,ap.StrictMode,ap.BlockingMode,ac(af.Shared).ReactSymbols local bd,be,bf,bg,bh,bi,bj,bk,
bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz=bc.REACT_FORWARD_REF_TYPE,bc.REACT_FRAGMENT_TYPE,bc.REACT_ELEMENT_TYPE,bc.
REACT_DEBUG_TRACING_MODE_TYPE,bc.REACT_STRICT_MODE_TYPE,bc.REACT_PROFILER_TYPE,bc.REACT_PROVIDER_TYPE,bc.
REACT_CONTEXT_TYPE,bc.REACT_SUSPENSE_TYPE,bc.REACT_SUSPENSE_LIST_TYPE,bc.REACT_MEMO_TYPE,bc.REACT_LAZY_TYPE,bc.
REACT_OFFSCREEN_TYPE,bc.REACT_LEGACY_HIDDEN_TYPE,1 local function bA(bB,bC,bD,bE,bF,bG,bH,bI)local bJ={tag=bB,key=bD,
elementType=bF,type=bG,stateNode=bH,index=1,pendingProps=bC,mode=bE,flags=ax,subtreeFlags=ax,lanes=if bI then bI else a6
,childLanes=a6}if av then bJ.actualDuration=0 bJ.actualStartTime=-1 bJ.selfBaseDuration=0 bJ.treeBaseDuration=0 end if
ae then bJ._debugID=br br+=1 bJ._debugSource=nil bJ._debugOwner=nil bJ._debugNeedsRemount=false bJ._debugHookTypes=nil
end return bJ end function _shouldConstruct(bB)return type(bB)~='function'and not not bB.isReactComponent end
local function bB(bC)return type(bC)=='function'end local function bC(bD)local bE=typeof(bD)if bE=='function'then return
aS end if bE=='table'then if bD.isReactComponent then return aE end local bF=bD['$$typeof']if bF==bd then return aJ end
if bF==bn then return aT end end return aD end local function bD(bE,bF)local bG=bE.alternate if bG==nil then bG=bA(bE.
tag,bF,bE.key,bE.mode,bE.elementType,bE.type,bE.stateNode)if ae then bG._debugID=bE._debugID bG._debugSource=bE.
_debugSource bG._debugOwner=bE._debugOwner bG._debugHookTypes=bE._debugHookTypes end bG.alternate=bE bE.alternate=bG
else bG.pendingProps=bF bG.type=bE.type bG.flags=ax bG.subtreeFlags=ax bG.deletions=nil if av then bG.actualDuration=0
bG.actualStartTime=-1 end end bG.flags=bit32.band(bE.flags,aA)bG.childLanes=bE.childLanes bG.lanes=bE.lanes bG.child=bE.
child bG.memoizedProps=bE.memoizedProps bG.memoizedState=bE.memoizedState bG.updateQueue=bE.updateQueue local bH=bE.
dependencies if bH==nil then bG.dependencies=nil else bG.dependencies={lanes=bH.lanes,firstContext=bH.firstContext}end
bG.sibling=bE.sibling bG.index=bE.index bG.ref=bE.ref if av then bG.selfBaseDuration=bE.selfBaseDuration bG.
treeBaseDuration=bE.treeBaseDuration end if ae then bG._debugNeedsRemount=bE._debugNeedsRemount if bG.tag==aD or bG.tag
==aS or bG.tag==aU then bG.type=a4(bE.type)elseif bG.tag==aE then bG.type=a3(bE.type)elseif bG.tag==aJ then bG.type=a5(
bE.type)end end return bG end local function bE(bF,bG)bF.flags=bit32.band(bF.flags,bit32.bor(aA,az))local bH=bF.
alternate if bH==nil then bF.childLanes=a6 bF.lanes=bG bF.child=nil bF.subtreeFlags=ax bF.memoizedProps=nil bF.
memoizedState=nil bF.updateQueue=nil bF.dependencies=nil bF.stateNode=nil if av then bF.selfBaseDuration=0 bF.
treeBaseDuration=0 end else bF.childLanes=bH.childLanes bF.lanes=bH.lanes bF.child=bH.child bF.subtreeFlags=bH.
subtreeFlags bF.deletions=nil bF.memoizedProps=bH.memoizedProps bF.memoizedState=bH.memoizedState bF.updateQueue=bH.
updateQueue bF.type=bH.type local bI=bH.dependencies if bI==nil then bF.dependencies=nil else bF.dependencies={lanes=bI.
lanes,firstContext=bI.firstContext}end if av then bF.selfBaseDuration=bH.selfBaseDuration bF.treeBaseDuration=bH.
treeBaseDuration end end return bF end local function bF(bG)local bH if bG==aB then bH=bit32.bor(a8,bb,ba)elseif bG==aC
then bH=bit32.bor(bb,ba)else bH=a7 end if av and a1()then bH=bit32.bor(bH,b)end return bA(aF,nil,nil,bH)end
local function bG(bH,bI,bJ,bK,bL,bM)local bN,bO,bP=aD,bH,type(bH)if bP=='function'then if ae then bO=a4(bO)end elseif bP
=='table'and not not bH.isReactComponent then bN=aE if ae then bO=a3(bO)end elseif bP=='string'then bN=aG else if bH==be
then return bu(bJ.children,bL,bM,bI)elseif bH==bg then bN=aL bL=bit32.bor(bL,a9)elseif bH==bh then bN=aL bL=bit32.bor(bL
,ba)elseif bH==bi then return bt(bJ,bL,bM,bI)elseif bH==bl then return bw(bJ,bL,bM,bI)elseif bH==bp then return bx(bJ,bL
,bM,bI)elseif bH==bq then return by(bJ,bL,bM,bI)else local bQ,bR=false if bP=='table'then bR=bH['$$typeof']if bR==bj
then bN=aM bQ=true elseif bR==bk then bN=aN bQ=true elseif bR==bd then bN=aJ if ae then bO=a5(bO)end bQ=true elseif bR==
bn then bN=aT bQ=true elseif bR==bo then bN=aV bO=nil bQ=true end end if not bQ then local bS=''if ae then if bH==nil or
(bP=='table'and#ah.keys(bH)==0)then bS..=
[[ You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.]]
elseif bH~=nil and bP=='table'then bS..='\n'..aj(bH)end local bT if bK then bT=a_(bK.type)end if bT~=nil and bT~=''then
bS..='\n\nCheck the render method of `'..bT..'`.'elseif bK then bS..='\n'..aj(bK)end end local bT if bH==nil then bT=
'nil'elseif ai.isArray(bH)then bT='array'elseif bP=='table'and bR==bf then bT=string.format('<%s />',a_(bH.type)or
'Unknown')bS=[[ Did you accidentally export a JSX literal or Element instead of a component?]]else bT=bP end at(false,
[[Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: %s.%s]]
,bT,bS)end end end local bQ=bA(bN,bJ,bI,bL,bH,bO,nil,bM)if ae then bQ._debugOwner=bK end return bQ end local function bH
(bI,bJ,bK)local bL if ae then bL=bI._owner end local bM,bN,bO=bI.type,bI.key,bI.props local bP=bG(bM,bN,bO,bL,bJ,bK)if
ae then bP._debugSource=bI._source bP._debugOwner=bI._owner end return bP end function bu(bI,bJ,bK,bL)local bM=bA(aK,bI,
bL,bJ,nil,nil,nil,bK)return bM end function bv(bI,bJ,bK,bL,bM)local bN=bA(aW,bJ,bM,bK,bI,bI,nil,bL)return bN end
function bs(bI,bJ,bK,bL,bM)local bN=bA(aX,bJ,bM,bK,bI,bI,nil,bL)return bN end function bt(bI,bJ,bK,bL)if ae then if
typeof(bI.id)~='string'then ak.error'Profiler must specify an "id" as a prop'end end local bM=bA(aO,bI,bL,bit32.bor(bJ,b
),bi,bi,if av then{effectDuration=0,passiveEffectDuration=0}else nil,bK)return bM end function bw(bI,bJ,bK,bL)local bM=
bA(aP,bI,bL,bJ,bl,bl,nil,bK)return bM end function bz(bI,bJ,bK,bL)local bM=bA(aQ,bI,bL,bJ,bm,if ae then bm else nil,nil,
bK)return bM end function bx(bI,bJ,bK,bL)local bM=bA(aY,bI,bL,bJ,bp,if ae then bp else nil,nil,bK)return bM end function
by(bI,bJ,bK,bL)local bM=bA(aZ,bI,bL,bJ,bq,if ae then bq else nil,nil,bK)return bM end local function bI(bJ,bK,bL)local
bM=bA(aH,bJ,nil,bK,nil,nil,nil,bL)return bM end local function bJ()local bK=bA(aG,nil,nil,a7,'DELETED','DELETED')return
bK end local function bK(bL)local bM=bA(aR,nil,nil,a7,nil,nil,bL)return bM end local function bL(bM,bN,bO)local bP=if bM
.children~=nil then bM.children else{}local bQ=bA(aI,bP,bM.key,bN,nil,nil,{containerInfo=bM.containerInfo,
pendingChildren=nil,implementation=bM.implementation},bO)return bQ end local function bM(bN,bO)if bN==nil then bN=bA(aD,
nil,nil,a7)end bN.tag=bO.tag bN.key=bO.key bN.elementType=bO.elementType bN.type=bO.type bN.stateNode=bO.stateNode bN.
return_=bO.return_ bN.child=bO.child bN.sibling=bO.sibling bN.index=bO.index bN.ref=bO.ref bN.pendingProps=bO.
pendingProps bN.memoizedProps=bO.memoizedProps bN.updateQueue=bO.updateQueue bN.memoizedState=bO.memoizedState bN.
dependencies=bO.dependencies bN.mode=bO.mode bN.flags=bO.flags bN.subtreeFlags=bO.subtreeFlags bN.deletions=bO.deletions
bN.lanes=bO.lanes bN.childLanes=bO.childLanes bN.alternate=bO.alternate if av then bN.actualDuration=bO.actualDuration
bN.actualStartTime=bO.actualStartTime bN.selfBaseDuration=bO.selfBaseDuration bN.treeBaseDuration=bO.treeBaseDuration
end bN._debugID=bO._debugID bN._debugSource=bO._debugSource bN._debugOwner=bO._debugOwner bN._debugNeedsRemount=bO.
_debugNeedsRemount bN._debugHookTypes=bO._debugHookTypes return bN end return{isSimpleFunctionComponent=bB,
resolveLazyComponentTag=bC,createWorkInProgress=bD,resetWorkInProgress=bE,createHostRootFiber=bF,
createFiberFromTypeAndProps=bG,createFiberFromElement=bH,createFiberFromFragment=bu,createFiberFromFundamental=bv,
createFiberFromSuspense=bw,createFiberFromSuspenseList=bz,createFiberFromOffscreen=bx,createFiberFromLegacyHidden=by,
createFiberFromText=bI,createFiberFromHostInstanceForDeletion=bJ,createFiberFromDehydratedFragment=bK,
createFiberFromPortal=bL,assignFiberPropertiesInDEV=bM}end)()end,[72]=function()local aa,ab,ac=a(72)local ad return(
function(...)local function ae(af)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('UNIMPLEMENTED ERROR: '..tostring(af))error(
'FIXME (roblox): '..af..' is unimplemented',2)end local af,ag,ah,ai=_G.__DEV__,_G.
__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__,_G.__COMPAT_WARNINGS__,ab.Parent.Parent local aj=ac(ai.Shared)local ak,
al=aj.console,ac(ai.LuauPolyfill)local am,an,ao,ap=al.Array,al.Object,al.util.inspect,ac(ai.Shared)local aq=ac(ai.React)
local ar=ac(ab.Parent.ReactInternalTypes)local as=ac(ab.Parent.ReactFiberLane)local at=ac(ab.Parent[
'ReactFiberSuspenseComponent.new'])local au=ac(ab.Parent['ReactFiberSuspenseContext.new'])local av=ac(ab.Parent.
ReactFiberOffscreenComponent)local aw,ax=ac(ai.Shared).checkPropTypes,ac(ab.Parent.ReactWorkTags)local az,aA,aB,aC,aD,aE
,aF,aG,aH,aI,aJ,aK,aL,aM,aN,aO,aP,aQ,aR,aS,aT=ax.FunctionComponent,ax.ClassComponent,ax.HostRoot,ax.HostComponent,ax.
HostText,ax.HostPortal,ax.ForwardRef,ax.Fragment,ax.Mode,ax.ContextProvider,ax.ContextConsumer,ax.Profiler,ax.
SuspenseComponent,ax.SuspenseListComponent,ax.MemoComponent,ax.SimpleMemoComponent,ax.LazyComponent,ax.
IncompleteClassComponent,ax.OffscreenComponent,ax.LegacyHiddenComponent,ac(ab.Parent.ReactFiberFlags)local aU,aV,aW,aX,
aY,aZ,a_,a0,a1,a2,a3,a4=aT.NoFlags,aT.StaticMask,aT.PerformedWork,aT.Placement,aT.Hydrating,aT.ContentReset,aT.
DidCapture,aT.Ref,aT.Deletion,aT.ForceUpdateForLegacySuspense,ac(ai.Shared).ReactSharedInternals,ac(ai.Shared).
ReactFeatureFlags local a5,a6,a7,a8,a9,b,ba,bb,bc,bd,be,bf=a4.debugRenderPhaseSideEffectsForStrictMode,a4.
disableLegacyContext,a4.disableModulePatternComponents,a4.enableProfilerTimer,a4.enableSchedulerTracing,a4.
enableSuspenseServerRenderer,a4.warnAboutDefaultPropsOnFunctionComponents,ac(ai.Shared).invariant,ac(ai.Shared).
describeError,ac(ai.Shared).shallowEqual,ac(ai.Shared).getComponentName,ac(ai.Shared).ReactSymbols local bg,bh,bi,bj=bf.
REACT_LAZY_TYPE,bf.getIteratorFn,ac(ab.Parent['ReactStrictModeWarnings.new']),ac(ab.Parent.ReactCurrentFiber)local bk,bl
,bm=bj.getCurrentFiberOwnerNameInDevOrNull,bj.setIsRendering,ac(ab.Parent['ReactFiberHotReloading.new'])local bn,bo,bp,
bq=bm.resolveFunctionForHotReloading,bm.resolveForwardRefForHotReloading,bm.resolveClassForHotReloading,ac(ab.Parent[
'ReactChildFiber.new'])local br,bs,bt,bu=bq.mountChildFibers,bq.reconcileChildFibers,bq.cloneChildFibers,ac(ab.Parent[
'ReactUpdateQueue.new'])local bv,bw,bx,by=bu.processUpdateQueue,bu.cloneUpdateQueue,bu.initializeUpdateQueue,ac(ab.
Parent.ReactTypeOfMode)local bz,bA,bB,bC,bD,bE=by.ConcurrentMode,by.NoMode,by.ProfileMode,by.StrictMode,by.BlockingMode,
ac(ab.Parent.ReactFiberHostConfig)local bF,bG,bH,bI,bJ=bE.shouldSetTextContent,bE.isSuspenseInstancePending,bE.
isSuspenseInstanceFallback,bE.registerSuspenseInstanceRetry,bE.supportsHydration local bK=ac(ab.Parent[
'ReactFiberHostContext.new'])local bL,bM,bN,bO,bP,bQ,bR,bS,bT,bU=bK.pushHostContext,bK.pushHostContainer,au.
suspenseStackCursor,au.hasSuspenseContext,au.ForceSuspenseFallback,au.addSubtreeSuspenseContext,au.
InvisibleParentSuspenseContext,au.pushSuspenseContext,au.setDefaultShallowSuspenseContext,ac(ab.Parent[
'ReactFiberNewContext.new'])local bV,bW,bX,bY,bZ,b_=bU.propagateContextChange,bU.readContext,bU.calculateChangedBits,bU.
prepareToReadContext,bU.pushProvider,{renderWithHooksRef=nil,bailoutHooksRef=nil,shouldSuspendRef=nil}local function b0(
b1)if not b_.shouldSuspendRef then b_.shouldSuspendRef=ac(ab.Parent.ReactFiberReconciler).shouldSuspend end return b_.
shouldSuspendRef(b1)end local function b1()local b2=ac(ab.Parent['ReactFiberHooks.new'])b_.renderWithHooksRef=b2.
renderWithHooks b_.bailoutHooksRef=b2.bailoutHooks end local function b2(...)if not b_.renderWithHooksRef then b1()end
return b_.renderWithHooksRef(...)end local function b3(...)if not b_.bailoutHooksRef then b1()end return b_.
bailoutHooksRef(...)end local b4,b5=ac(ab.Parent['ReactProfilerTimer.new']).stopProfilerTimerIfRunning,ac(ab.Parent[
'ReactFiberContext.new'])local b6,b7,b8,b9,c,ca,cb,cc=b5.getMaskedContext,b5.getUnmaskedContext,b5.hasContextChanged,b5.
pushContextProvider,b5.isContextProvider,b5.pushTopLevelContextObject,b5.invalidateContextProvider,ac(ab.Parent[
'ReactFiberHydrationContext.new'])local cd,ce,cf,cg,ch,ci=cc.resetHydrationState,cc.enterHydrationState,cc.
reenterHydrationStateFromDehydratedSuspenseInstance,cc.tryToClaimNextHydratableInstance,cc.warnIfHydrating,ac(ab.Parent[
'ReactFiberClassComponent.new'])local cj,ck,cl,cm,cn,co,cp,cq=ci.adoptClassInstance,ci.applyDerivedStateFromProps,ci.
constructClassInstance,ci.mountClassInstance,ci.resumeMountClassInstance,ci.updateClassInstance,ac(ab.Parent[
'ReactFiberLazyComponent.new']).resolveDefaultProps,ac(ab.Parent['ReactFiber.new'])local cr,cs,ct,cu,cv,cw,cx=cq.
resolveLazyComponentTag,cq.createFiberFromFragment,cq.createFiberFromOffscreen,cq.createFiberFromTypeAndProps,cq.
isSimpleFunctionComponent,cq.createWorkInProgress,ac(ab.Parent['ReactFiberWorkLoop.new'])local cy,cz,cA,cB,cC,cD,cE,cF,
cG,cH,cI,cJ,cK=cx.pushRenderLanes,cx.markSpawnedWork,cx.retryDehydratedSuspenseBoundary,cx.scheduleUpdateOnFiber,cx.
renderDidSuspendDelayIfPossible,cx.getWorkInProgressRoot,cx.getExecutionContext,cx.RetryAfterError,cx.NoContext,ac(ab.
Parent['ReactMutableSource.new']).setWorkInProgressVersion,ac(ab.Parent.ReactFiberWorkInProgress).markSkippedUpdateLanes
,(ac(ai.Shared).ConsolePatchingDev)local cL,cM,cN,cO,cP,cQ,cR,cS,cT=cJ.disableLogs,cJ.reenableLogs,a3.ReactCurrentOwner,
{},false,{didWarnAboutBadClass={},didWarnAboutModulePatternComponent={},didWarnAboutContextTypeOnFunctionComponent={},
didWarnAboutGetDerivedStateOnFunctionComponent={},didWarnAboutFunctionRefs={},
didWarnAboutDefaultPropsOnFunctionComponent={}}if af then cQ.didWarnAboutBadClass={}cQ.
didWarnAboutModulePatternComponent={}cQ.didWarnAboutContextTypeOnFunctionComponent={}cQ.
didWarnAboutGetDerivedStateOnFunctionComponent={}cQ.didWarnAboutFunctionRefs={}cO.didWarnAboutReassigningProps=false cQ.
didWarnAboutDefaultPropsOnFunctionComponent={}end local function cU(cV,cW,cX,cY)if cV==nil then cW.child=br(cW,nil,cX,cY
)else cW.child=bs(cW,(cV).child,cX,cY)end end local function cV(cW,cX,cY,cZ)cX.child=bs(cX,cW.child,nil,cZ)cX.child=bs(
cX,nil,cY,cZ)end local function cW(cX,cY,cZ,c_,c0)if af or ag then if cY.type~=cY.elementType then local c1,c2=cZ.
propTypes,cZ.validateProps if c1 or c2 then aw(c1,c2,c_,'prop',be(cZ))end end end local c1,c2,c3=cZ.render,(cY.ref)bY(cY
,c0,cO.markWorkInProgressReceivedUpdate)if af then cN.current=cY bl(true)c3=b2(cX,cY,c1,c_,c2,c0)if a5 and bit32.band(cY
.mode,bC)~=0 then cL()local c4,c5=xpcall(b2,bc,cX,cY,c1,c_,c2,c0)if c4 then c3=c5 end cM()if not c4 then error(c5)end
end bl(false)else c3=b2(cX,cY,c1,c_,c2,c0)end if cX~=nil and not cP then b3(cX,cY,c0)return cR(cX,cY,c0)end cY.flags=
bit32.bor(cY.flags,aW)cU(cX,cY,c3,c0)return cY.child end local function cX(cY,cZ,c_,c0,c1,c2)if cY==nil then local c3=c_
.type if cv(c3)and c_.compare==nil and c_.defaultProps==nil then local c4=c3 if af then c4=bn(c3)end cZ.tag=aO cZ.type=
c4 if af then validateFunctionComponentInDev(cZ,c3)end return cT(cY,cZ,c4,c0,c1,c2)end if af or ag then local c4,c5 if
type(c3)=='table'then c4=c3.propTypes c5=c3.validateProps end if c4 or c5 then aw(c4,c5,c0,'prop',be(c3))end end local
c4=cu(c_.type,nil,c0,cZ,cZ.mode,c2)c4.ref=cZ.ref c4.return_=cZ cZ.child=c4 return c4 end local c3=cY if af or ag then
local c4,c5,c6=(c_.type)if type(c4)=='table'then c5=c4.propTypes c6=c4.validateProps end if c5 or c6 then aw(c5,c6,c0,
'prop',be(c4))end end local c4=(c3.child)if not as.includesSomeLane(c1,c2)then local c5,c6=c4.memoizedProps,c_.compare
if c6==nil then c6=bd end if c6(c5,c0)and c3.ref==cZ.ref then return cR(c3,cZ,c2)end end cZ.flags=bit32.bor(cZ.flags,aW)
local c5=cw(c4,c0)c5.ref=cZ.ref c5.return_=cZ cZ.child=c5 return c5 end function cT(cY,cZ,c_,c0,c1,c2)if af or ag then
if cZ.type~=cZ.elementType then local c3=cZ.elementType if c3['$$typeof']==bg then local c4=c3 local c5,c6=c4._payload,
c4._init local c7,c8=xpcall(c6,bc,c5)if c7 then c3=c8 else c3=nil end local c9,d if c3~=nil and type(c3)=='table'then c9
=(c3).propTypes d=(c3).validateProps end if c9 or d then aw(c9,d,c0,'prop',be(c3))end end end end if cY~=nil then local
c3=cY local c4,c5=c3.memoizedProps,true if af then c5=cZ.type==c3.type end if bd(c4,c0)and c3.ref==cZ.ref and c5 then cP
=false if not as.includesSomeLane(c2,c1)then cZ.lanes=c3.lanes return cR(c3,cZ,c2)elseif bit32.band(c3.flags,a2)~=aU
then cP=true end end end return cS(cY,cZ,c_,c0,c2)end local function cY(cZ,c_,c0)local c1=c_.pendingProps local c2,c3=(
c1.children)if cZ~=nil then c3=(cZ).memoizedState end if c1.mode=='hidden'or c1.mode=='unstable-defer-without-hiding'
then if bit32.band(c_.mode,bz)==bA then local c4={baseLanes=as.NoLanes}c_.memoizedState=c4 cy(c_,c0)elseif not as.
includesSomeLane(c0,as.OffscreenLane)then local c4 if c3~=nil then local c5=(c3).baseLanes c4=as.mergeLanes(c5,c0)else
c4=c0 end if a9 then cz(as.OffscreenLane)end c_.childLanes=as.laneToLanes(as.OffscreenLane)c_.lanes=c_.childLanes local
c5={baseLanes=c4}c_.memoizedState=c5 cy(c_,c4)return nil else local c4={baseLanes=as.NoLanes}c_.memoizedState=c4 local
c5=c0 if c3~=nil then c5=(c3).baseLanes end cy(c_,c5)end else local c4 if c3~=nil then c4=as.mergeLanes((c3).baseLanes,
c0)c_.memoizedState=nil else c4=c0 end cy(c_,c4)end cU(cZ,c_,c2,c0)return c_.child end local cZ=cY function
updateFragment(c_,c0,c1)local c2=c0.pendingProps cU(c_,c0,c2,c1)return c0.child end function updateMode(c_,c0,c1)local
c2=c0.pendingProps.children cU(c_,c0,c2,c1)return c0.child end function updateProfiler(c_,c0,c1)if a8 then local c2=c0.
stateNode c2.effectDuration=0 c2.passiveEffectDuration=0 end local c2=c0.pendingProps local c3=c2.children cU(c_,c0,c3,
c1)return c0.child end local function c_(c0,c1)local c2=c1.ref if(c0==nil and c2~=nil)or(c0~=nil and(c0).ref~=c2)then c1
.flags=bit32.bor(c1.flags,a0)end end function cS(c0,c1,c2,c3,c4)if af or ag then if type(c2)~='function'and(c1.type~=c1.
elementType)then local c5,c6 if type(c2)=='table'then c5=(c2).propTypes c6=(c2).validateProps end if c5 or c6 then aw(c5
,c6,c3,'prop',be(c2))end end end local c5 if not a6 then local c6=b7(c1,c2,true)c5=b6(c1,c6)end local c6 bY(c1,c4,cO.
markWorkInProgressReceivedUpdate)if af then cN.current=c1 bl(true)c6=b2(c0,c1,c2,c3,c5,c4)if a5 and bit32.band(c1.mode,
bC)~=0 then cL()local c7,c8=xpcall(b2,bc,c0,c1,c2,c3,c5,c4)cM()if c7 then c6=c8 else error(c8)end end bl(false)else c6=
b2(c0,c1,c2,c3,c5,c4)end if c0~=nil and not cP then b3(c0,c1,c4)return cR(c0,c1,c4)end c1.flags=bit32.bor(c1.flags,aW)
cU(c0,c1,c6,c4)return c1.child end local function c0(c1,c2,c3,c4,c5)if af or ag then if c2.type~=c2.elementType then
local c6,c7=c3.propTypes,c3.validateProps if c6 or c7 then aw(c6,c7,c4,'prop',be(c3))end end end local c6 if c(c3)then
c6=true b9(c2)else c6=false end bY(c2,c5,cO.markWorkInProgressReceivedUpdate)local c7,c8=(c2.stateNode)if c7==nil then
if c1~=nil then c1.alternate=nil c2.alternate=nil c2.flags=bit32.bor(c2.flags,aX)end cl(c2,c3,c4)cm(c2,c3,c4,c5)c8=true
elseif c1==nil then c8=cn(c2,c3,c4,c5)else c8=co(c1,c2,c3,c4,c5)end local c9=finishClassComponent(c1,c2,c3,c8,c6,c5)if
af then local d=c2.stateNode if c8 and d.props~=c4 then if not cO.didWarnAboutReassigningProps then ak.error(
[[It looks like %s is reassigning its own `this.props` while rendering. This is not supported and can lead to confusing bugs.]]
,be(c2.type)or'a component')end cO.didWarnAboutReassigningProps=true end end return c9 end function finishClassComponent
(c1,c2,c3,c4,c5,c6)c_(c1,c2)local c7=bit32.band(c2.flags,a_)~=aU if not c4 and not c7 then if c5 then cb(c2,c3,false)end
return cR(c1,c2,c6)end local c8=c2.stateNode cN.current=c2 local c9 if c7 and(c3.getDerivedStateFromError==nil or type(
c3.getDerivedStateFromError)~='function')then c9=nil if a8 then b4(c2)end else if af then bl(true)c9=c8:render()if a5
and bit32.band(c2.mode,bC)~=0 then cL()local d,da=xpcall(c8.render,bc,c8)cM()if not d then error(da)end end bl(false)
else c9=c8:render()end end c2.flags=bit32.bor(c2.flags,aW)if c1~=nil and c7 then cV(c1,c2,c9,c6)else cU(c1,c2,c9,c6)end
c2.memoizedState=c8.state if c5 then cb(c2,c3,true)end return c2.child end local function c1(c2)local c3=c2.stateNode if
c3.pendingContext then ca(c2,c3.pendingContext,c3.pendingContext~=c3.context)elseif c3.context then ca(c2,c3.context,
false)end bM(c2,c3.containerInfo)end local function c2(c3,c4,c5)c1(c4)local c6=c4.updateQueue bb(c3~=nil and c6~=nil,
[[If the root does not have an updateQueue, we should have already bailed out. This error is likely caused by a bug in React. Please file an issue.]]
)local c7,c8,c9=c4.pendingProps,(c4.memoizedState)if c8~=nil then c9=c8.element end bw(c3,c4)bv(c4,c7,nil,c5)local d=c4.
memoizedState local da=d.element if da==c9 then cd()return cR(c3,c4,c5)end local db=c4.stateNode if db.hydrate and ce(c4
)then if bJ then local dc=db.mutableSourceEagerHydrationData if dc~=nil then for dd=1,#dc,2 do local dg,dh=dc[dd],dc[dd+
1]cH(dg,dh)end end end local dc=br(c4,nil,da,c5)c4.child=dc local dd=dc while dd do dd.flags=bit32.bor(bit32.band(dd.
flags,bit32.bnot(aX)),aY)dd=dd.sibling end else cU(c3,c4,da,c5)cd()end return c4.child end local function c3(c4,c5,c6)
bL(c5)if c4==nil then cg(c5)end local c7,c8,c9=c5.type,(c5.pendingProps)if c4~=nil then c9=c4.memoizedProps end local d,
da=c8.children,bF(c7,c8)if da then d=nil elseif c9~=nil and bF(c7,c9)then c5.flags=bit32.bor(c5.flags,aZ)end c5.flags=
bit32.bor(c5.flags,aW)c_(c4,c5)cU(c4,c5,d,c6)return c5.child end local function c4(c5,c6)if c5==nil then cg(c6)end
return nil end local function c5(c6,c7,c8,c9,d)if c6~=nil then c6.alternate=nil c7.alternate=nil c7.flags=bit32.bor(c7.
flags,aX)end local da,db=c7.pendingProps,c8 local dc,dd=db._payload,db._init local dg=dd(dc)c7.type=dg c7.tag=cr(dg)
local dh,di,dj=c7.tag,(cp(dg,da))if dh==az then if af then validateFunctionComponentInDev(c7,dg)dg=bn(dg)c7.type=dg end
dj=cS(nil,c7,dg,di,d)return dj elseif dh==aA then if af then dg=bp(dg)c7.type=dg end dj=c0(nil,c7,dg,di,d)return dj
elseif dh==aF then if af then dg=bo(dg)c7.type=dg end dj=cW(nil,c7,dg,di,d)return dj elseif dh==aN then if af or ag then
if c7.type~=c7.elementType then local dk,dl=dg.propTypes,dg.validateProps if dk or dl then aw(dk,dl,di,'prop',be(dg))end
end end dj=cX(nil,c7,dg,cp(dg.type,di),c9,d)return dj end local dk=''if af then if dg~=nil and type(dg)=='table'and dg[
'$$typeof']==bg then dk=' Did you wrap a component in React.lazy() more than once?'elseif type(dg)=='table'and dg[
'$$typeof']==nil then dk='\n'..ao(dg)end end bb(false,
[[Element type is invalid. Received a promise that resolves to: %s. Lazy element type must resolve to a class or function.%s]]
,tostring(dg),dk)return nil end function mountIncompleteClassComponent(c6,c7,c8,c9,d)if c6~=nil then c6.alternate=nil c7
.alternate=nil c7.flags=bit32.bor(c7.flags,aX)end c7.tag=aA local da if c(c8)then da=true b9(c7)else da=false end bY(c7,
d,cO.markWorkInProgressReceivedUpdate)cl(c7,c8,c9)cm(c7,c8,c9,d)return finishClassComponent(nil,c7,c8,true,da,d)end
local function c6(c7,c8,c9,d)if c7~=nil then c7.alternate=nil c8.alternate=nil c8.flags=bit32.bor(c8.flags,aX)end local
da,db=(c8.pendingProps)if not a6 then local dc=b7(c8,c9,false)db=b6(c8,dc)end bY(c8,d,cO.
markWorkInProgressReceivedUpdate)local dc if af then if type(c9)=='table'and type(c9.render)=='function'then local dd=
be(c9)or'Unknown'if not cQ.didWarnAboutBadClass[dd]then ak.error(
[[The <%s /> component appears to have a render method, but doesn't extend React.Component. This is likely to cause errors. Change %s to extend React.Component instead.]]
,dd,dd)cQ.didWarnAboutBadClass[dd]=true end end if bit32.band(c8.mode,bC)~=0 then bi.recordLegacyContextWarning(c8)end
bl(true)cN.current=c8 dc=b2(nil,c8,c9,da,db,d)bl(false)else dc=b2(nil,c8,c9,da,db,d)end c8.flags=bit32.bor(c8.flags,aW)
local dd=type(dc)if af then if dc~=nil and dd=='table'and type(dc.render)=='function'and dc['$$typeof']==nil then local
dg=be(c9)or'Unknown'if not cQ.didWarnAboutModulePatternComponent[dg]then ak.error(
[[The <%s /> component appears to be a function component that returns a class instance. Change %s to a class that extends React.Component instead. ]]
,dg,dg)cQ.didWarnAboutModulePatternComponent[dg]=true end end end if not a7 and dc~=nil and dd=='table'and type(dc.
render)=='function'and dc['$$typeof']==nil then if af then local dg=be(c9)or'Unknown'if not cQ.
didWarnAboutModulePatternComponent[dg]then ak.error(
[[The <%s /> component appears to be a function component that returns a class instance. ]]..
'Change %s to a class that extends React.Component instead. '..dg,dg)cQ.didWarnAboutModulePatternComponent[dg]=true end
end c8.tag=aA c8.memoizedState=nil c8.updateQueue=nil local dg=false if c(c9)then dg=true b9(c8)else dg=false end c8.
memoizedState=dc.state bx(c8)local dh if type(c9)~='function'then dh=(c9).getDerivedStateFromProps end if dh~=nil and
type(dh)=='function'then ck(c8,c9,dh,da)end cj(c8,dc)cm(c8,c9,da,d)return finishClassComponent(nil,c8,c9,true,dg,d)else
c8.tag=az if af then if a6 and c9.contextTypes then ak.error(
[[%s uses the legacy contextTypes API which is no longer supported. Use React.createContext() with React.useContext() instead.]]
,be(c9)or'Unknown')end if a5 and bit32.band(c8.mode,bC)~=0 then cL()local dg,dh=xpcall(b2,bc,nil,c8,c9,da,db,d)cM()if dg
then dc=dh else error(dh)end end end cU(nil,c8,dc,d)if af then validateFunctionComponentInDev(c8,c9)end return c8.child
end end function validateFunctionComponentInDev(c7,c8)if af then if c7.ref~=nil then local c9,d='',bk()if d then c9..=
'\n\nCheck the render method of `'..d..'`.'end local da,db=d or c7._debugID or'',c7._debugSource if db then da=db.
fileName..':'..db.lineNumber end if not cQ.didWarnAboutFunctionRefs[da]then cQ.didWarnAboutFunctionRefs[da]=true ak.
error(
[[Function components cannot be given refs. Attempts to access this ref will fail. Did you mean to use React.forwardRef()?%s]]
,c9)end end if ba and type(c8)~='function'and c8.defaultProps~=nil then local c9=be(c8)or'Unknown'if not cQ.
didWarnAboutDefaultPropsOnFunctionComponent[c9]then ak.error(
[[%s: Support for defaultProps will be removed from function components in a future major release.]],c9)cQ.
didWarnAboutDefaultPropsOnFunctionComponent[c9]=true end end if type(c8)~='function'and c8.getDerivedStateFromProps~=nil
and type(c8.getDerivedStateFromProps)=='function'then local c9=be(c8)or'Unknown'if not cQ.
didWarnAboutGetDerivedStateOnFunctionComponent[c9]then ak.error(
[[%s: Function components do not support getDerivedStateFromProps.]],c9)cQ.
didWarnAboutGetDerivedStateOnFunctionComponent[c9]=true end end if type(c8)~='function'and c8.contextType~=nil and type(
c8.contextType)=='table'then local c9=be(c8)or'Unknown'if not cQ.didWarnAboutContextTypeOnFunctionComponent[c9]then ak.
error('%s: Function components do not support contextType.',c9)cQ.didWarnAboutContextTypeOnFunctionComponent[c9]=true
end end end end local c7={dehydrated=nil,retryLane=as.NoLane}local function c8(c9)return{baseLanes=c9}end local function
c9(d,da)return{baseLanes=as.mergeLanes(d.baseLanes,da)}end local function d(da,db,dc,dd)if db~=nil then local dg=(db).
memoizedState if dg==nil then return false end end return bO(da,bP)end local function da(db,dc)return as.removeLanes(db.
childLanes,dc)end local db,dc,dd,dg,dh local function di(dj,dk,dl)local dm=dk.pendingProps if af then if b0(dk)then dk.
flags=bit32.bor(dk.flags,a_)end end local dn,dp,dq=bN.current,false,bit32.band(dk.flags,a_)~=aU if dq or d(dn,dj,dk,dl)
then dp=true dk.flags=bit32.band(dk.flags,bit32.bnot(a_))else if dj==nil or dj.memoizedState~=nil then if dm.fallback~=
nil and dm.unstable_avoidThisFallback~=true then dn=bQ(dn,bR)end end end dn=bT(dn)bS(dk,dn)if dj==nil then if dm.
fallback~=nil then cg(dk)if b then local dr=dk.memoizedState if dr~=nil then local ds=(dr).dehydrated if ds~=nil then
return dc(dk,ds,dl)end end end end local dr,ds=dm.children,dm.fallback if dp then local dt,e=
mountSuspenseFallbackChildren(dk,dr,ds,dl),dk.child e.memoizedState=c8(dl)dk.memoizedState=c7 return dt elseif dm.
unstable_expectedLoadTime~=nil and type(dm.unstable_expectedLoadTime)=='number'then local dt,e=
mountSuspenseFallbackChildren(dk,dr,ds,dl),dk.child e.memoizedState=c8(dl)dk.memoizedState=c7 dk.lanes=as.SomeRetryLane
if a9 then cz(as.SomeRetryLane)end return dt else return dd(dk,dr,dl)end else local dr=dj.memoizedState if dr~=nil then
if b then local ds=(dr).dehydrated if ds~=nil then if not dq then return dh(dj,dk,ds,dr,dl)elseif dk.memoizedState~=nil
then dk.child=dj.child dk.flags=bit32.bor(dk.flags,a_)return nil else local dt,e=dm.children,dm.fallback local f,g=
mountSuspenseFallbackAfterRetryWithoutHydrating(dj,dk,dt,e,dl),dk.child g.memoizedState=c8(dl)dk.memoizedState=c7 return
f end end end if dp then local ds,dt=dm.fallback,dm.children local e,f,g=dg(dj,dk,dt,ds,dl),dk.child,(dj.child).
memoizedState if g==nil then f.memoizedState=c8(dl)else f.memoizedState=c9(g,dl)end f.childLanes=da(dj,dl)dk.
memoizedState=c7 return e else local ds=dm.children local dt=db(dj,dk,ds,dl)dk.memoizedState=nil return dt end else if
dp then local ds,dt=dm.fallback,dm.children local e,f,g=dg(dj,dk,dt,ds,dl),dk.child,(dj.child).memoizedState if g==nil
then f.memoizedState=c8(dl)else f.memoizedState=c9(g,dl)end f.childLanes=da(dj,dl)dk.memoizedState=c7 return e else
local ds=dm.children local dt=db(dj,dk,ds,dl)dk.memoizedState=nil return dt end end end end function dd(dj,dk,dl)local
dm,dn=dj.mode,{mode='visible',children=dk}local dp=ct(dn,dm,dl,nil)dp.return_=dj dj.child=dp return dp end function
mountSuspenseFallbackChildren(dj,dk,dl,dm)local dn,dp,dq,dr,ds=dj.mode,dj.child,{mode='hidden',children=dk}if bit32.
band(dn,bD)==bA and dp~=nil then dr=dp dr.childLanes=as.NoLanes dr.pendingProps=dq if a8 and bit32.band(dj.mode,bB)~=0
then dr.actualDuration=0 dr.actualStartTime=-1 dr.selfBaseDuration=0 dr.treeBaseDuration=0 end ds=cs(dl,dn,dm,nil)else
dr=ct(dq,dn,as.NoLanes,nil)ds=cs(dl,dn,dm,nil)end dr.return_=dj ds.return_=dj dr.sibling=ds dj.child=dr return ds end
local function dj(dk,dl)return cw(dk,dl)end function db(dk,dl,dm,dn)local dp=dk.child local dq,dr=dp.sibling,dj(dp,{mode
='visible',children=dm})if bit32.band(dl.mode,bD)==bA then dr.lanes=dn end dr.return_=dl dr.sibling=nil if dq~=nil then
local ds=dl.deletions if ds==nil then dl.deletions={dq}dl.flags=bit32.bor(dl.flags,a1)else table.insert(ds,dq)end end dl
.child=dr return dr end function dg(dk,dl,dm,dn,dp)local dq,dr=dl.mode,dk.child local ds,dt,e=dr.sibling,{mode='hidden',
children=dm}if bit32.band(dq,bD)==bA and dl.child~=dr then local f=dl.child e=f e.childLanes=as.NoLanes e.pendingProps=
dt if a8 and bit32.band(dl.mode,bB)~=0 then e.actualDuration=0 e.actualStartTime=-1 e.selfBaseDuration=dr.
selfBaseDuration e.treeBaseDuration=dr.treeBaseDuration end dl.deletions=nil else e=dj(dr,dt)e.subtreeFlags=bit32.band(
dr.subtreeFlags,aV)end local f if ds~=nil then f=cw(ds,dn)else f=cs(dn,dq,dp,nil)f.flags=bit32.bor(f.flags,aX)end f.
return_=dl e.return_=dl e.sibling=f dl.child=e return f end local function dk(dl,dm,dn)bs(dm,dl.child,nil,dn)local dp=dm
.pendingProps local dq=dp.children local dr=dd(dm,dq,dn)dr.flags=bit32.bor(dr.flags,aX)dm.memoizedState=nil return dr
end function mountSuspenseFallbackAfterRetryWithoutHydrating(dl,dm,dn,dp,dq)local dr=dm.mode local ds,dt=ct(dn,dr,as.
NoLanes,nil),cs(dp,dr,dq,nil)dt.flags=bit32.bor(dt.flags,aX)ds.return_=dm dt.return_=dm ds.sibling=dt dm.child=ds if
bit32.band(dm.mode,bD)~=bA then bs(dm,dl.child,nil,dq)end return dt end function dc(dl,dm,dn)if bit32.band(dl.mode,bD)==
bA then if af then ak.error
[[Cannot hydrate Suspense in legacy mode. Switch fromReactDOM.hydrate(element, container) to ReactDOM.createBlockingRoot(container, { hydrate: true }).render(element) or remove the Suspense componentsthe server rendered components.]]
end dl.lanes=as.laneToLanes(as.SyncLane)elseif bH(dm)then if a9 then cz(as.DefaultHydrationLane)end dl.lanes=as.
laneToLanes(as.DefaultHydrationLane)else dl.lanes=as.laneToLanes(as.OffscreenLane)if a9 then cz(as.OffscreenLane)end end
return nil end function dh(dl,dm,dn,dp,dq)ch()if bit32.band(cE(),cF)~=cG then return dk(dl,dm,dq)end if bit32.band(dm.
mode,bD)==bA then return dk(dl,dm,dq)end if bH(dn)then return dk(dl,dm,dq)end local dr=as.includesSomeLane(dq,dl.
childLanes)if cP or dr then local ds=cD()if ds~=nil then local dt=as.getBumpedLaneForHydration(ds,dq)if dt~=as.NoLane
and dt~=dp.retryLane then dp.retryLane=dt local e=as.NoTimestamp cB(dl,dt,e)end end cC()return dk(dl,dm,dq)elseif bG(dn)
then dm.flags=bit32.bor(dm.flags,a_)dm.child=dl.child local ds=function()return cA(dl)end if a9 then if cK==nil then cK=
ac(ai.Scheduler).tracing.unstable_wrap end ds=cK(ds)end bI(dn,ds)return nil else cf(dm,dn)local ds=dm.pendingProps local
dt=ds.children local e=dd(dm,dt,dq)e.flags=bit32.bor(e.flags,aY)return e end end function updatePortalComponent(dl,dm,dn
)bM(dm,dm.stateNode.containerInfo)local dp=dm.pendingProps if dl==nil then dm.child=bs(dm,nil,dp,dn)else cU(dl,dm,dp,dn)
end return dm.child end local dl=false local function dm(dn,dp,dq)local dr=dp.type local ds,dt,e=dr._context,dp.
pendingProps,dp.memoizedProps local f=dt.value if af or ag then if am.indexOf(an.keys(dt),'value')<1 then if not dl then
dl=true ak.error[[The `value` prop is required for the `<Context.Provider>`. Did you misspell it or forget to pass it?]]
end end local g,h=dp.type.propTypes,dp.type.validateProps if g or h then aw(g,h,dt,'prop','Context.Provider')end end bZ(
dp,f)if e~=nil then local g=e.value local h=bX(ds,f,g)if h==0 then if e.children==dt.children and not b8()then return
cR(dn,dp,dq)end else bV(dp,ds,h,dq)end end local g=dt.children cU(dn,dp,g,dq)return dp.child end local dn={
usingContextAsConsumer=false,usingLegacyConsumer=false}function updateContextConsumer(dp,dq,dr)local ds=dq.type if af
then if(ds)._context==nil then if ds~=ds.Consumer then if not dn.usingContextAsConsumer then dn.usingContextAsConsumer=
true ak.error
[[Rendering <Context> directly is not supported and will be removed in a future major release. Did you mean to render <Context.Consumer> instead?]]
end end else ds=(ds)._context end end local dt,e=(dq.pendingProps)if dt.render then if af and ah then if not dn.
usingLegacyConsumer then dn.usingLegacyConsumer=true ak.warn
[[Your Context.Consumer component is using legacy Roact syntax, which won't be supported in future versions of Roact. 
Please provide no props and supply the 'render' function as a child (the 3rd argument of createElement). For example: 
       createElement(ContextConsumer, {render = function(...) end})
becomes:
       createElement(ContextConsumer, nil, function(...) end)
For more info, reference the React documentation here: 
https://reactjs.org/docs/context.html#contextconsumer]]
end end e=dt.render else e=dt.children end if af then if type(e)~='function'then ak.error
[[A context consumer was rendered with multiple children, or a child that isn't a function. A context consumer expects a single child that is a function. If you did pass a function, make sure there is no trailing or leading whitespace around it.]]
end end bY(dq,dr,cO.markWorkInProgressReceivedUpdate)local f,g=(bW(ds,dt.unstable_observedBits))if af then cN.current=dq
bl(true)g=e(f)bl(false)else g=e(f)end dq.flags=bit32.bor(dq.flags,aW)cU(dp,dq,g,dr)return dq.child end cO.
markWorkInProgressReceivedUpdate=function()cP=true end function cR(dp,dq,dr)if dp then dq.dependencies=dp.dependencies
end if a8 then b4(dq)end cI(dq.lanes)if not as.includesSomeLane(dr,dq.childLanes)then return nil else bt(dp,dq)return dq
.child end end function remountFiber(dp,dq,dr)if af then local ds=dq.return_ if ds==nil then error
'Cannot swap the root fiber.'end assert(ds~=nil,'returnFiber was nil in remountFiber')dp.alternate=nil dq.alternate=nil
dr.index=dq.index dr.sibling=dq.sibling dr.return_=dq.return_ dr.ref=dq.ref if dq==ds.child then ds.child=dr else local
dt=ds.child if dt==nil then error'Expected parent to have a child.'end assert(dt~=nil,
'prevSibling was nil in remountFiber')while dt.sibling~=dq do dt=dt.sibling if dt==nil then error
'Expected to find the previous sibling.'end end dt.sibling=dr end local dt=ds.deletions if dt==nil then ds.deletions={dp
}ds.flags=bit32.bor(ds.flags,a1)else table.insert(dt,dp)end dr.flags=bit32.bor(dr.flags,aX)return dr else error
[[Did not expect this call in production. This is a bug in React. Please file an issue.]]end end local function dp(dq,dr
,ds)local dt=dr.lanes if af then if dr._debugNeedsRemount and dq~=nil then return remountFiber(dq,dr,cu(dr.type,dr.key,
dr.pendingProps,dr._debugOwner or nil,dr.mode,dr.lanes))end end if dq~=nil then local e,f=dq.memoizedProps,dr.
pendingProps if e~=f or b8()or if af then dr.type~=dq.type else false then cP=true elseif not as.includesSomeLane(ds,dt)
then cP=false if dr.tag==aB then c1(dr)cd()elseif dr.tag==aC then bL(dr)elseif dr.tag==aA then local g=dr.type if c(g)
then b9(dr)end elseif dr.tag==aE then bM(dr,dr.stateNode.containerInfo)elseif dr.tag==aI then local g=dr.memoizedProps.
value bZ(dr,g)elseif dr.tag==aK then if a8 then local g=dr.stateNode g.effectDuration=0 g.passiveEffectDuration=0 end
elseif dr.tag==aL then local g=dr.memoizedState if g~=nil then if b then if(g).dehydrated~=nil then bS(dr,bT(bN.current)
)dr.flags=bit32.bor(dr.flags,a_)return nil end end local h=dr.child local i=h.childLanes if as.includesSomeLane(ds,i)
then return di(dq,dr,ds)else bS(dr,bT(bN.current))local j=cR(dq,dr,ds)if j~=nil then return j.sibling else return nil
end end else bS(dr,bT(bN.current))end elseif dr.tag==aM then ae'beginWork: SuspenseListComponent'elseif dr.tag==aR or dr
.tag==aS then dr.lanes=as.NoLanes return cY(dq,dr,ds)end return cR(dq,dr,ds)else if bit32.band(dq.flags,a2)~=aU then cP=
true else cP=false end end else cP=false end dr.lanes=as.NoLanes if dr.tag==ax.IndeterminateComponent then return c6(dq,
dr,dr.type,ds)elseif dr.tag==aP then local e=dr.elementType return c5(dq,dr,e,dt,ds)elseif dr.tag==az then local e,f,g=
dr.type,(dr.pendingProps)if dr.elementType==e then g=f else g=cp(e,f)end return cS(dq,dr,e,g,ds)elseif dr.tag==aA then
local e,f=dr.type,dr.pendingProps local g=dr.elementType==e and f or cp(e,f)return c0(dq,dr,e,g,ds)elseif dr.tag==aB
then return c2(dq,dr,ds)elseif dr.tag==aC then return c3(dq,dr,ds)elseif dr.tag==aD then return c4(dq,dr)elseif dr.tag==
aL then return di(dq,dr,ds)elseif dr.tag==aE then return updatePortalComponent(dq,dr,ds)elseif dr.tag==aF then local e,f
=dr.type,dr.pendingProps local g=f if dr.elementType~=e then g=cp(e,f)end return cW(dq,dr,e,g,ds)elseif dr.tag==aG then
return updateFragment(dq,dr,ds)elseif dr.tag==aH then return updateMode(dq,dr,ds)elseif dr.tag==aK then return
updateProfiler(dq,dr,ds)elseif dr.tag==aI then return dm(dq,dr,ds)elseif dr.tag==aJ then return updateContextConsumer(dq
,dr,ds)elseif dr.tag==aN then local e,f=dr.type,dr.pendingProps local g=cp(e,f)if af or ag then if dr.type~=dr.
elementType then local h,i if type(e)=='table'then h=e.propTypes i=e.validateProps end if h or i then aw(h,i,g,'prop',
be(e))end end end g=cp(e.type,g)return cX(dq,dr,e,g,dt,ds)elseif dr.tag==aO then return cT(dq,dr,dr.type,dr.pendingProps
,dt,ds)elseif dr.tag==aQ then local e,f=dr.type,dr.pendingProps local g=dr.elementType==e and f or cp(e,f)return
mountIncompleteClassComponent(dq,dr,e,g,ds)elseif dr.tag==aR then return cY(dq,dr,ds)elseif dr.tag==aS then return cZ(dq
,dr,ds)end bb(false,
[[Unknown unit of work tag (%s). This error is likely caused by a bug in React. Please file an issue.]],tostring(dr.tag)
)return nil end cO.beginWork=dp return cO end)()end,[73]=function()local aa,ab,ac=a(73)local ad return(function(...)
local ae,af=_G.__DEV__,ab.Parent.Parent local ag=ac(af.LuauPolyfill)local ah,ai,aj=ag.Object,ac(af.Shared).console,ac(ab
.Parent.ReactInternalTypes)local ak=ac(ab.Parent.ReactFiberLane)local al=ac(ab.Parent['ReactUpdateQueue.new'])local am=
ac(af.Shared)local an,ao=ac(af.React),ac(ab.Parent.ReactFiberFlags)local ap,aq,ar,as=ao.Update,ao.Snapshot,ao.
MountLayoutDev,ac(af.Shared).ReactFeatureFlags local at,au,av,aw,ax,az,aA,aB,aC=as.
debugRenderPhaseSideEffectsForStrictMode,as.disableLegacyContext,as.enableDebugTracing,as.enableSchedulingProfiler,as.
warnAboutDeprecatedLifecycles,as.enableDoubleInvokingEffects,ac(ab.Parent['ReactStrictModeWarnings.new']),ac(ab.Parent.
ReactFiberTreeReflection).isMounted,ac(af.Shared).ReactInstanceMap local aD,aE,aF,aG,aH,aI,aJ=aC.get,aC.set,ac(af.Shared
).shallowEqual,ac(af.Shared).getComponentName,ac(af.Shared).UninitializedState,ac(af.Shared).describeError,ac(af.Shared)
.ReactSymbols local aK,aL,aM,aN=aJ.REACT_CONTEXT_TYPE,aJ.REACT_PROVIDER_TYPE,ac(ab.Parent['ReactFiberLazyComponent.new']
).resolveDefaultProps,ac(ab.Parent.ReactTypeOfMode)local aO,aP,aQ,aR,aS,aT,aU,aV,aW,aX,aY,aZ,a_=aN.DebugTracingMode,aN.
StrictMode,al.enqueueUpdate,al.processUpdateQueue,al.checkHasForceUpdateAfterProcessing,al.
resetHasForceUpdateBeforeProcessing,al.createUpdate,al.ReplaceState,al.ForceUpdate,al.initializeUpdateQueue,al.
cloneUpdateQueue,ak.NoLanes,ac(ab.Parent['ReactFiberContext.new'])local a0,a1,a2,a3,a4,a5=a_.cacheContext,a_.
getMaskedContext,a_.getUnmaskedContext,a_.hasContextChanged,a_.emptyContextObject,ac(ab.Parent[
'ReactFiberNewContext.new'])local a6,a7=a5.readContext,ac(ab.Parent.DebugTracing)local a8,a9,b=a7.
logForceUpdateScheduled,a7.logStateUpdateScheduled,ac(af.Shared).ConsolePatchingDev local ba,bb,bc=b.disableLogs,b.
reenableLogs,ac(ab.Parent.SchedulingProfiler)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq=bc.markForceUpdateScheduled
,bc.markStateUpdateScheduled,{},(an.Component:extend''.__refs)if ae then bh={}bi={}bj={}bk={}bo={}bl={}bp={}bq={}local
br={}function bn(bs,bt)if bs==nil or type(bs)=='function'then return end local bu=bt..'_'..tostring(bs)if not br[bu]then
br[bu]=true ai.error([[%s(...): Expected the last optional `callback` argument to be a function. Instead received: %s.]]
,bt,tostring(bs))end end function bm(bs,bt)end end local function br(bs,bt,bu,bv)local bw=bs.memoizedState if ae then if
at and bit32.band(bs.mode,aP)~=0 then ba()local bx,by=xpcall(bu,aI,bv,bw)bb()if not bx then error(by)end end end local
bx=bu(bv,bw)if ae then bm(bt,bx)end local by=if bx==nil then bw else ah.assign({},bw,bx)bs.memoizedState=by if bs.lanes
==aZ then local bz=bs.updateQueue bz.baseState=by end end local bs local function bt()local bu=ac(ab.Parent[
'ReactFiberWorkLoop.new'])local bv,bw,bx=bu.requestEventTime,bu.requestUpdateLane,bu.scheduleUpdateOnFiber bs={isMounted
=aB,enqueueSetState=function(by,bz,bA)local bB,bC=aD(by),bv()local bD=bw(bB)local bE=aU(bC,bD,bz,bA)if bA~=nil then if
ae then bn(bA,'setState')end end aQ(bB,bE)bx(bB,bD,bC)if ae then if av then if bit32.band(bB.mode,aO)~=0 then local bF=
aG(bB.type)or'Unknown'a9(bF,bD,bz)end end end if aw then be(bB,bD)end end,enqueueReplaceState=function(by,bz,bA)local bB
,bC=aD(by),bv()local bD=bw(bB)local bE=aU(bC,bD,bz,bA)bE.tag=aV if bA~=nil then if ae then bn(bA,'replaceState')end end
aQ(bB,bE)bx(bB,bD,bC)if ae then if av then if bit32.band(bB.mode,aO)~=0 then local bF=aG(bB.type)or'Unknown'a9(bF,bD,bz)
end end end if aw then be(bB,bD)end end,enqueueForceUpdate=function(by,bz)local bA,bB=aD(by),bv()local bC=bw(bA)local bD
=aU(bB,bC,nil,bz)bD.tag=aW if bz~=nil then if ae then bn(bz,'forceUpdate')end end aQ(bA,bD)bx(bA,bC,bB)if ae then if av
then if bit32.band(bA.mode,aO)~=0 then local bE=aG(bA.type)or'Unknown'a8(bE,bC)end end end if aw then bd(bA,bC)end end}
end local function bu()if bs==nil then bt()end return bs end function checkShouldComponentUpdate(bv,bw,bx,by,bz,bA,bB)
local bC=bv.stateNode if bC.shouldComponentUpdate~=nil and type(bC.shouldComponentUpdate)=='function'then if ae then if
at and bit32.band(bv.mode,aP)~=0 then ba()local bD,bE=xpcall(bC.shouldComponentUpdate,aI,bC,by,bA,bB)bb()if not bD then
error(bE)end end end local bD=bC:shouldComponentUpdate(by,bA,bB)if ae then if bD==nil then ai.error(
[[%s.shouldComponentUpdate(): Returned nil instead of a boolean value. Make sure to return true or false.]],aG(bw)or
'Component')end end return bD end if type(bw)=='table'and bw.isPureReactComponent then return(not aF(bx,by)or not aF(bz,
bA))end return true end local function bv(bw,bx,by)local bz=bw.stateNode if ae then local bA,bB=aG(bx)or'Component',bz.
render if not bB then if type(bx.render)=='function'then ai.error(
[[%s(...): No `render` method found on the returned component instance: did you accidentally return an object from the constructor?]]
,bA)else ai.error(
[[%s(...): No `render` method found on the returned component instance: you may have forgotten to define `render`.]],bA)
end end if bz.getInitialState and not bz.getInitialState.isReactClassApproved and not bz.state then ai.error(
[[getInitialState was defined on %s, a plain JavaScript class. This is only supported for classes created using React.createClass. Did you mean to define a state property instead?]]
,bA)end if bz.getDefaultProps and not bz.getDefaultProps.isReactClassApproved then ai.error(
[[getDefaultProps was defined on %s, a plain JavaScript class. This is only supported for classes created using React.createClass. Use a static property to define defaultProps instead.]]
,bA)end if bz.propTypes and not bx.propTypes then ai.error(
[[propTypes was defined as an instance property on %s. Use a static property to define propTypes instead.]],bA)end if bz
.contextType and not bx.contextType then ai.error(
[[contextType was defined as an instance property on %s. Use a static property to define contextType instead.]],bA)end
if au then if bx.childContextTypes then ai.error(
[[%s uses the legacy childContextTypes API which is no longer supported. Use React.createContext() instead.]],bA)end if
bx.contextTypes then ai.error(
[[%s uses the legacy contextTypes API which is no longer supported. Use React.createContext() with static contextType instead.]]
,bA)end else if bz.contextTypes and not bx.contextTypes then ai.error(
[[contextTypes was defined as an instance property on %s. Use a static property to define contextTypes instead.]],bA)end
if type(bx)=='table'and bx.contextType and bx.contextTypes and not bp[bx]then bp[bx]=true ai.error(
[[%s declares both contextTypes and contextType static properties. The legacy contextTypes property will be ignored.]],
bA)end end if type(bz.componentShouldUpdate)=='function'then ai.error(
[[%s has a method called componentShouldUpdate(). Did you mean shouldComponentUpdate()? The name is phrased as a question because the function is expected to return a value.]]
,bA)end if type(bx)=='table'and bx.isPureReactComponent and bz.shouldComponentUpdate~=nil then ai.error(
[[%s has a method called shouldComponentUpdate(). shouldComponentUpdate should not be used when extending React.PureComponent. Please extend React.Component if shouldComponentUpdate is used.]]
,aG(bx)or'A pure component')end if type(bz.componentDidUnmount)=='function'then ai.error(
[[%s has a method called componentDidUnmount(). But there is no such lifecycle method. Did you mean componentWillUnmount()?]]
,bA)end if type(bz.componentDidReceiveProps)=='function'then ai.error(
[[%s has a method called componentDidReceiveProps(). But there is no such lifecycle method. If you meant to update the state in response to changing props, use componentWillReceiveProps(). If you meant to fetch data or run side-effects or mutations after React has updated the UI, use componentDidUpdate().]]
,bA)end if type(bz.componentWillRecieveProps)=='function'then ai.error(
[[%s has a method called componentWillRecieveProps(). Did you mean componentWillReceiveProps()?]],bA)end if type(bz.
UNSAFE_componentWillRecieveProps)=='function'then ai.error(
[[%s has a method called UNSAFE_componentWillRecieveProps(). Did you mean UNSAFE_componentWillReceiveProps()?]],bA)end
local bC=bz.props~=by if bz.props~=nil and bC then ai.error(
[[%s(...): When calling super() in `%s`, make sure to pass up the same props that your component's constructor was passed.]]
,bA,bA)end if rawget(bz,'defaultProps')then ai.error(
[[Setting defaultProps as an instance property on %s is not supported and will be ignored. Instead, define defaultProps as a static property on %s.]]
,bA,bA)end if type(bz.getSnapshotBeforeUpdate)=='function'and type(bz.componentDidUpdate)~='function'and not bj[bx]then
bj[bx]=true ai.error(
[[%s: getSnapshotBeforeUpdate() should be used with componentDidUpdate(). This component defines getSnapshotBeforeUpdate() only.]]
,aG(bx))end local bD=bz.state if bD~=nil and type(bD)~='table'then ai.error('%s.state: must be set to an object or nil',
bA)end if type(bx)=='table'and type(bz.getChildContext)=='function'and type(bx.childContextTypes)~='table'then ai.error(
[[%s.getChildContext(): childContextTypes must be defined in order to use getChildContext().]],bA)end end end
local function bw(bx,by)by.__updater=bu()bx.stateNode=by aE(by,bx)if ae then by._reactInternalInstance=bf end end
local function bx(by,bz,bA)local bB,bC,bD,bE=false,a4,a4,bz.contextType if ae then if bz.contextType~=nil then local bF=
bE==nil or(bE['$$typeof']==aK and bE._context==nil)if not bF and not bq[bz]then bq[bz]=true local bG=''if bE==nil then
bG=
[[ However, it is set to nil. This can be caused by a typo or by mixing up named and default imports. This can also happen due to a circular dependency, so try moving the createContext() call to a separate file.]]
elseif type(bE)~='table'then bG=' However, it is set to a '..type(bE)..'.'elseif bE['$$typeof']==aL then bG=
' Did you accidentally pass the Context.Provider instead?'elseif bE._context~=nil then bG=
' Did you accidentally pass the Context.Consumer instead?'else bG..=' However, it is set to an object with keys {'for bH
,bI in bE do bG..=bH..', 'end bG..='}.'end ai.error(
[[%s defines an invalid contextType. contextType should point to the Context object returned by React.createContext().%s]]
,aG(bz)or'Component',bG)end end end if bE~=nil and type(bE)=='table'then bD=a6(bE)elseif not au then bC=a2(by,bz,true)
local bF=bz.contextTypes bB=bF~=nil bD=bB and a1(by,bC)or a4 end if ae then if at and bit32.band(by.mode,aP)~=0 then ba(
)local bF,bG=xpcall(bz.__ctor,aI,bA,bD)bb()if not bF then error(bG)end end end local bF=bz.__ctor(bA,bD)by.memoizedState
=bF.state local bG=by.memoizedState bw(by,bF)if ae then if type(bz.getDerivedStateFromProps)=='function'and bG==aH then
local bH=aG(bz)or'Component'if not bi[bH]then bi[bH]=true ai.error(
[[`%s` uses `getDerivedStateFromProps` but its initial state has not been initialized. This is not recommended. Instead, define the initial state by passing an object to `self:setState` in the `init` method of `%s`. This ensures that `getDerivedStateFromProps` arguments have a consistent shape.]]
,bH,bH)end end if type(bz.getDerivedStateFromProps)=='function'or type(bF.getSnapshotBeforeUpdate)=='function'then local
bH,bI,bJ if type(bF.componentWillMount)=='function'then bH='componentWillMount'elseif type(bF.UNSAFE_componentWillMount)
=='function'then bH='UNSAFE_componentWillMount'end if type(bF.componentWillReceiveProps)=='function'then bI=
'componentWillReceiveProps'elseif type(bF.UNSAFE_componentWillReceiveProps)=='function'then bI=
'UNSAFE_componentWillReceiveProps'end if type(bF.componentWillUpdate)=='function'then bJ='componentWillUpdate'elseif
type(bF.UNSAFE_componentWillUpdate)=='function'then bJ='UNSAFE_componentWillUpdate'end if bH~=nil or bI~=nil or bJ~=nil
then local bK,bL=(aG(bz)or'Component')if type(bz.getDerivedStateFromProps)=='function'then bL=
'getDerivedStateFromProps()'else bL='getSnapshotBeforeUpdate()'end local bM if bH~=nil then bM=('\n  '..tostring(bH))
else bM=''end local bN if bI~=nil then bN=('\n  '..tostring(bI))else bN=''end local bO if bJ~=nil then bO='\n  '..
tostring(bJ)else bO=''end if not bk[bK]then bk[bK]=true ai.error(
[[Unsafe legacy lifecycles will not be called for components using new component APIs.

%s uses %s but also contains the following legacy lifecycles:%s%s%s

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]]
,bK,bL,bM,bN,bO)end end end end if bB then a0(by,bC,bD)end return bF end local function by(bz,bA)local bB=bA.state if bA
.componentWillMount~=nil and type(bA.componentWillMount)=='function'then bA:componentWillMount()end if bA.
UNSAFE_componentWillMount~=nil and type(bA.UNSAFE_componentWillMount)=='function'then bA:UNSAFE_componentWillMount()end
if bB~=bA.state then if ae then ai.error(
[[%s.componentWillMount(): Assigning directly to this.state is deprecated (except inside a component's constructor). Use setState instead.]]
,aG(bz.type)or'Component')end bu().enqueueReplaceState(bA,bA.state)end end function callComponentWillReceiveProps(bz,bA,
bB,bC)local bD=bA.state if bA.componentWillReceiveProps~=nil and type(bA.componentWillReceiveProps)=='function'then bA:
componentWillReceiveProps(bB,bC)end if bA.UNSAFE_componentWillReceiveProps~=nil and type(bA.
UNSAFE_componentWillReceiveProps)=='function'then bA:UNSAFE_componentWillReceiveProps(bB,bC)end if bA.state~=bD then if
ae then local bE=aG(bz.type)or'Component'if not bh[bE]then bh[bE]=true ai.error(
[[%s.componentWillReceiveProps(): Assigning directly to this.state is deprecated (except inside a component's constructor). Use setState instead.]]
,bE)end end bu().enqueueReplaceState(bA,bA.state)end end local function bz(bA,bB,bC,bD)if ae then bv(bA,bB,bC)end local
bE=bA.stateNode bE.props=bC bE.state=bA.memoizedState bE.__refs=bg aX(bA)local bF if type(bB)=='table'then bF=bB.
contextType end if bF~=nil and type(bF)=='table'then bE.context=a6(bF)elseif au then bE.context=a4 else local bG=a2(bA,
bB,true)bE.context=a1(bA,bG)end if ae then if bE.state==bC then local bG=aG(bB)or'Component'if not bo[bG]then bo[bG]=
true ai.error(
[[%s: It is not recommended to assign props directly to state because updates to props won't be reflected in state. In most cases, it is better to use props directly.]]
,bG)end end if bit32.band(bA.mode,aP)~=0 then aA.recordLegacyContextWarning(bA,bE)end if ax then aA.
recordUnsafeLifecycleWarnings(bA,bE)end end aR(bA,bC,bE,bD)bE.state=bA.memoizedState local bG,bH=(type(bB))if type(bB)==
'table'then bH=bB.getDerivedStateFromProps end if bH~=nil and type(bH)=='function'then br(bA,bB,bH,bC)bE.state=bA.
memoizedState end if bG=='table'and type(bB.getDerivedStateFromProps)~='function'and type(bE.getSnapshotBeforeUpdate)~=
'function'and(type(bE.UNSAFE_componentWillMount)=='function'or type(bE.componentWillMount)=='function')then by(bA,bE)aR(
bA,bC,bE,bD)bE.state=bA.memoizedState end if type(bE.componentDidMount)=='function'then if ae and az then bA.flags=bit32
.bor(bA.flags,bit32.bor(ar,ap))else bA.flags=bit32.bor(bA.flags,ap)end end end function resumeMountClassInstance(bA,bB,
bC,bD)local bE,bF=bA.stateNode,bA.memoizedProps bE.props=bF local bG,bH,bI=bE.context,bB.contextType,a4 if bH~=nil and
type(bH)=='table'then bI=a6(bH)elseif not au then local bJ=a2(bA,bB,true)bI=a1(bA,bJ)end local bJ=bB.
getDerivedStateFromProps local bK=type(bJ)=='function'or type(bE.getSnapshotBeforeUpdate)=='function'if not bK and(type(
bE.UNSAFE_componentWillReceiveProps)=='function'or type(bE.componentWillReceiveProps)=='function')then if bF~=bC or bG~=
bI then callComponentWillReceiveProps(bA,bE,bC,bI)end end aT()local bL=bA.memoizedState bE.state=bL local bM=bL aR(bA,bC
,bE,bD)bM=bA.memoizedState if bF==bC and bL==bM and not a3()and not aS()then if type(bE.componentDidMount)=='function'
then if ae and az then bA.flags=bit32.bor(bA.flags,ar,ap)else bA.flags=bit32.bor(bA.flags,ap)end end return false end if
bJ~=nil and type(bJ)=='function'then br(bA,bB,bJ,bC)bM=bA.memoizedState end local bN=aS()or checkShouldComponentUpdate(
bA,bB,bF,bC,bL,bM,bI)if bN then if not bK and(type(bE.UNSAFE_componentWillMount)=='function'or type(bE.
componentWillMount)=='function')then if type(bE.componentWillMount)=='function'then bE:componentWillMount()end if type(
bE.UNSAFE_componentWillMount)=='function'then bE:UNSAFE_componentWillMount()end end if type(bE.componentDidMount)==
'function'then if ae and az then bA.flags=bit32.bor(bA.flags,ar,ap)else bA.flags=bit32.bor(bA.flags,ap)end end else if
type(bE.componentDidMount)=='function'then if ae and az then bA.flags=bit32.bor(bA.flags,ar,ap)else bA.flags=bit32.bor(
bA.flags,ap)end end bA.memoizedProps=bC bA.memoizedState=bM end bE.props=bC bE.state=bM bE.context=bI return bN end
local function bA(bB,bC,bD,bE,bF)local bG=bC.stateNode aY(bB,bC)local bH=bC.memoizedProps local bI=if bC.type==bC.
elementType then bH else aM(bC.type,bH)bG.props=bI local bJ,bK,bL,bM=bC.pendingProps,(bG.context)if type(bD)=='table'
then bL=bD.contextType bM=bD.getDerivedStateFromProps end local bN=a4 if type(bL)=='table'then bN=a6(bL)elseif not au
then local bO=a2(bC,bD,true)bN=a1(bC,bO)end local bO=(bM~=nil and type(bM)=='function')or(bG.getSnapshotBeforeUpdate~=
nil and type(bG.getSnapshotBeforeUpdate)=='function')if not bO and((bG.UNSAFE_componentWillReceiveProps~=nil and type(bG
.UNSAFE_componentWillReceiveProps)=='function')or(bG.componentWillReceiveProps~=nil and type(bG.
componentWillReceiveProps)=='function'))then if bH~=bJ or bK~=bN then callComponentWillReceiveProps(bC,bG,bE,bN)end end
aT()local bP=bC.memoizedState bG.state=bP local bQ=bG.state aR(bC,bE,bG,bF)bQ=bC.memoizedState if bH==bJ and bP==bQ and
not a3()and not aS()then if bG.componentDidUpdate~=nil and type(bG.componentDidUpdate)=='function'then if bH~=bB.
memoizedProps or bP~=bB.memoizedState then bC.flags=bit32.bor(bC.flags,ap)end end if bG.getSnapshotBeforeUpdate~=nil and
type(bG.getSnapshotBeforeUpdate)=='function'then if bH~=bB.memoizedProps or bP~=bB.memoizedState then bC.flags=bit32.
bor(bC.flags,aq)end end return false end if bM~=nil and type(bM)=='function'then br(bC,bD,bM,bE)bQ=bC.memoizedState end
local bR=aS()or checkShouldComponentUpdate(bC,bD,bI,bE,bP,bQ,bN)if bR then if not bO and((bG.UNSAFE_componentWillUpdate
~=nil and type(bG.UNSAFE_componentWillUpdate)=='function')or(bG.componentWillUpdate~=nil and type(bG.componentWillUpdate
)=='function'))then if bG.componentWillUpdate~=nil and type(bG.componentWillUpdate)=='function'then bG:
componentWillUpdate(bE,bQ,bN)end if bG.UNSAFE_componentWillUpdate~=nil and type(bG.UNSAFE_componentWillUpdate)==
'function'then bG:UNSAFE_componentWillUpdate(bE,bQ,bN)end end if bG.componentDidUpdate~=nil and type(bG.
componentDidUpdate)=='function'then bC.flags=bit32.bor(bC.flags,ap)end if bG.getSnapshotBeforeUpdate~=nil and type(bG.
getSnapshotBeforeUpdate)=='function'then bC.flags=bit32.bor(bC.flags,aq)end else if bG.componentDidUpdate~=nil and type(
bG.componentDidUpdate)=='function'then if bH~=bB.memoizedProps or bP~=bB.memoizedState then bC.flags=bit32.bor(bC.flags,
ap)end end if bG.getSnapshotBeforeUpdate~=nil and type(bG.getSnapshotBeforeUpdate)=='function'then if bH~=bB.
memoizedProps or bP~=bB.memoizedState then bC.flags=bit32.bor(bC.flags,aq)end end bC.memoizedProps=bE bC.memoizedState=
bQ end bG.props=bE bG.state=bQ bG.context=bN return bR end return{adoptClassInstance=bw,constructClassInstance=bx,
mountClassInstance=bz,resumeMountClassInstance=resumeMountClassInstance,updateClassInstance=bA,
applyDerivedStateFromProps=br,emptyRefsObject=bg}end)()end,[74]=function()local aa,ab,ac=a(74)local ad return(function(
...)local function ae(af)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('UNIMPLEMENTED ERROR: '..tostring(af))error(
'FIXME (roblox): '..af..' is unimplemented',2)end local af,ag,ah,ai=_G.__DEV__,_G.__YOLO__,0,20 local function aj(ak)if
typeof(ak)=='function'then return true end if typeof(ak)=='table'then local al=getmetatable(ak)if al and rawget(al,
'__call')then return true end if ak._isMockFunction then return true end end return false end local ak=ab.Parent.Parent
local al,am=ac(ak.Shared).console,ac(ak.LuauPolyfill)local an,ao=am.Error,am.Set local ap=ac(ab.Parent.
ReactFiberHostConfig)local aq=ac(ab.Parent.ReactInternalTypes)local ar=ac(ab.Parent['ReactFiberSuspenseComponent.new'])
local as=ac(ab.Parent['ReactUpdateQueue.new'])local at=ac(ak.Shared)local au=ac(ab.Parent.ReactFiberOffscreenComponent)
local av=ac(ab.Parent.ReactHookEffectTags)local aw,ax=ac(ak.Scheduler).tracing.unstable_wrap,ac(ak.Shared).
ReactFeatureFlags local az,aA,aB,aC,aD,aE=ax.enableSchedulerTracing,ax.enableProfilerTimer,ax.enableProfilerCommitHooks,
ax.enableSuspenseCallback,ax.enableDoubleInvokingEffects,ac(ab.Parent.ReactWorkTags)local aF,aG,aH,aI,aJ,aK,aL,aM,aN,aO,
aP,aQ,aR,aS,aT,aU,aV,aW,aX,aY=aE.FunctionComponent,aE.ForwardRef,aE.ClassComponent,aE.HostRoot,aE.HostComponent,aE.
HostText,aE.HostPortal,aE.Profiler,aE.SuspenseComponent,aE.DehydratedFragment,aE.IncompleteClassComponent,aE.
MemoComponent,aE.SimpleMemoComponent,aE.SuspenseListComponent,aE.FundamentalComponent,aE.ScopeComponent,aE.Block,aE.
OffscreenComponent,aE.LegacyHiddenComponent,ac(ak.Shared).ReactErrorUtils local aZ,a_,a0,a1=aY.invokeGuardedCallback,aY.
hasCaughtError,aY.clearCaughtError,ac(ab.Parent.ReactFiberFlags)local a2,a3,a4,a5,a6,a7,a8,a9,b,ba,bb,bc,bd=a1.NoFlags,
a1.ContentReset,a1.Placement,a1.Snapshot,a1.Update,a1.Callback,a1.LayoutMask,a1.PassiveMask,a1.Ref,ac(ak.Shared).
getComponentName,ac(ak.Shared).invariant,ac(ak.Shared).describeError,ac(ab.Parent.ReactCurrentFiber)local be,bf,bg,bh,bi
,bj=bd.current,bd.resetCurrentFiber,bd.setCurrentFiber,ac(ab.Parent['ReactFiberDevToolsHook.new']).onCommitUnmount,ac(ab
.Parent['ReactFiberLazyComponent.new']).resolveDefaultProps,ac(ab.Parent['ReactProfilerTimer.new'])local bk,bl,bm,bn,bo,
bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,bA,bB,bC,bD,bE,bF,bG,bH,bI,bJ,bK,bL=bj.startLayoutEffectTimer,bj.
recordPassiveEffectDuration,bj.recordLayoutEffectDuration,bj.startPassiveEffectTimer,bj.getCommitTime,ac(ab.Parent.
ReactTypeOfMode).ProfileMode,as.commitUpdateQueue,ap.getPublicInstance,ap.supportsMutation,ap.supportsPersistence,ap.
supportsHydration,ap.commitMount,ap.commitUpdate,ap.resetTextContent,ap.commitTextUpdate,ap.appendChild,ap.
appendChildToContainer,ap.insertBefore,ap.insertInContainerBefore,ap.removeChild,ap.removeChildFromContainer,ap.
hideInstance,ap.hideTextInstance,ap.unhideInstance,ap.unhideTextInstance,ap.commitHydratedSuspenseInstance,(ap.
clearContainer)local function bM(bN,bO)if not bL then bL=ac(ab.Parent['ReactFiberWorkLoop.new'])end bL.
resolveRetryWakeable(bN,bO)end local function bN()if not bL then bL=ac(ab.Parent['ReactFiberWorkLoop.new'])end bL.
markCommitTimeOfFallback()end local function bO()al.warn(
[[ReactFiberCommitWork: schedulePassiveEffectCallback causes a dependency cycle
]]..debug.traceback())end local function
bP(bQ,bR,bS)al.warn[[ReactFiberCommitWork: captureCommitPhaseError causes a dependency cycle]]error(bS)end local bQ,bR,
bS,bT,bU=av.NoFlags,av.HasEffect,av.Layout,(av.Passive)local bV=function()if not bU then bU=ac(ab.Parent[
'ReactFiberBeginWork.new']).didWarnAboutReassigningProps end return bU end local bW,bX,bY,bZ,b_,b0,b1,b2,b3,b4,b5
local function b6(b7,b8)b8.props=b7.memoizedProps b8.state=b7.memoizedState if aA and aB and bit32.band(b7.mode,bp)~=0
then local b9,c=xpcall(function()bk()b8:componentWillUnmount()end,bc)bm(b7)if not b9 then error(c)end else b8:
componentWillUnmount()end end function safelyCallComponentWillUnmount(b7,b8,b9)local c,ca=xpcall(b6,bc,b7,b8)if not c
then bP(b7,b9,ca)end end local function b7(b8,b9)local c=b8.ref if c~=nil then if typeof(c)=='function'then local ca,cb=
xpcall(c,bc)if not ca then bP(b8,b9,cb)end else c.current=nil end end end local function b8(b9,c,ca)local cb,cc=xpcall(
ca,bc)if not cb then bP(b9,c,cc)end end local function b9(c,ca)if ca.tag==aF or ca.tag==aG or ca.tag==aR or ca.tag==aV
then return elseif ca.tag==aH then if bit32.band(ca.flags,a5)~=0 then if c~=nil then local cb,cc,cd=(c).memoizedProps,(c
).memoizedState,ca.stateNode if af then if ca.type==ca.elementType and not bV then if cd.props~=ca.memoizedProps then al
.error(
[[Expected %s props to match memoized props before getSnapshotBeforeUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.]]
,ba(ca.type)or'instance')end if cd.state~=ca.memoizedState then al.error(
[[Expected %s state to match memoized state before getSnapshotBeforeUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.]]
,ba(ca.type)or'instance')end end end local ce=cd:getSnapshotBeforeUpdate(ca.elementType==ca.type and cb or bi(ca.type,cb
),cc)if af then end cd.__reactInternalSnapshotBeforeUpdate=ce end end return elseif ca.tag==aI then if bs then if bit32.
band(ca.flags,a5)~=0 then local cb=ca.stateNode bK(cb.containerInfo)end end return elseif ca.tag==aJ or ca.tag==aK or ca
.tag==aL or ca.tag==aP then return end bb(false,
[[This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue.]]
)end local function c(ca,cb,cc)local cd,ce=(cb.updateQueue)if cd~=nil then ce=(cd).lastEffect end if ce~=nil then local
cf=ce.next local cg=cf repeat if bit32.band(cg.tag,ca)==ca then local ch=cg.destroy cg.destroy=nil if ch~=nil then b8(cb
,cc,ch)end end cg=cg.next until cg==cf end end local function ca(cb,cc)local cd=cc.updateQueue local ce=if cd~=nil then
cd.lastEffect else nil if ce~=nil then local cf=ce.next local cg=cf repeat if bit32.band(cg.tag,cb)==cb then local ch=cg
.create cg.destroy=ch()if af then local ci=cg.destroy if ci~=nil and typeof(ci)~='function'then local cj if ci==nil then
cj=[[ You returned nil. If your effect does not require clean up, return nil (or nothing).]]elseif typeof(ci.andThen)==
'function'then cj=
[=[


It looks like you wrote useEffect(Promise.new(function() --[[...]] end) or returned a Promise. Instead, write the async function inside your effect and call it immediately:

useEffect(function()
  function fetchData()
    -- You can await here
    local response = MyAPI.getData(someId):await()
    -- ...
  end
  fetchData()
end, {someId}) -- Or {} if effect doesn't need props or state

Learn more about data fetching with Hooks: https://reactjs.org/link/hooks-data-fetching]=]
else cj=' You returned: '..ci end al.error(
[[An effect function must not return anything besides a function, which is used for clean-up.%s]],cj)end end end cg=cg.
next until cg==cf end end function commitProfilerPassiveEffect(cb,cc)if aA and aB then if cc.tag==aM then local cd,ce,cf
,cg=cc.stateNode.passiveEffectDuration,cc.memoizedProps.id,cc.memoizedProps.onPostCommit,bo()if typeof(cf)=='function'
then if az then cf(ce,if cc.alternate==nil then'mount'else'update',cd,cg,cb.memoizedInteractions)else cf(ce,if cc.
alternate==nil then'mount'else'update',cd,cg)end end end end end local function cb(cc,cd,ce,cf)if ce~=nil then bP=ce end
if cf~=nil then bO=cf end local cg,ch=cc.flags,cc.tag if ch==aM then local ci if aA and aB then ci=b5 b5=cc end local cj
=cc.child while cj~=nil do local ck=bit32.band(cc.subtreeFlags,a8)if ck~=a2 then if af then local cl=be bg(cj)aZ(nil,cb,
nil,cj,cd,bP,bO)if a_()then local cm=a0()bP(cj,cc,cm)end if cl~=nil then bg(cl)else bf()end else local cl,cm=xpcall(cb,
bc,cj,cd,bP,bO)if not cl then bP(cj,cc,cm)end end end cj=cj.sibling end local ck=bit32.band(cg,bit32.bor(a6,a7))if ck~=
a2 then if aA then if af then local cl=be bg(cc)aZ(nil,commitLayoutEffectsForProfiler,nil,cc,cd)if a_()then local cm=a0(
)bP(cc,cc.return_,cm)end if cl~=nil then bg(cl)else bf()end else local cl,cm=xpcall(commitLayoutEffectsForProfiler,bc,cc
,cd)if not cl then bP(cc,cc.return_,cm)end end end end if aA and aB then if ci~=nil then ci.stateNode.effectDuration+=cc
.stateNode.effectDuration end b5=ci end else local ci=cc.child while ci~=nil do local cj=bit32.band(cc.subtreeFlags,a8)
if cj~=a2 then if af then local ck=bd.current bg(ci)if ah<ai then ah+=1 aZ(nil,cb,nil,ci,cd,bP,bO)ah-=1 if a_()then
local cl=a0()bP(ci,cc,cl)end else cb(ci,cd,bP,bO)end if ck~=nil then bg(ck)else bf()end else local ck,cl if not ag and
ah<ai then ah+=1 ck,cl=xpcall(cb,bc,ci,cd,bP,bO)ah-=1 else ck=true cb(ci,cd,bP,bO)end if not ck then bP(ci,cc,cl)end end
end ci=ci.sibling end local cj=bit32.band(cg,bit32.bor(a6,a7))if cj~=a2 then if ch==aF or ch==aG or ch==aR or ch==aV
then if aA and aB and bit32.band(cc.mode,bp)~=0 then local ck,cl=xpcall(function()bk()ca(bit32.bor(bS,bR),cc)end,bc)bm(
cc)if not ck then error(cl)end else ca(bit32.bor(bS,bR),cc)end if bit32.band(cc.subtreeFlags,a9)~=a2 then bO()end elseif
ch==aH then b1(cc)elseif ch==aI then b_(cc)elseif ch==aJ then b0(cc)elseif ch==aN then commitSuspenseHydrationCallbacks(
cd,cc)elseif ch==aT or ch==aL or ch==aK or ch==aP or ch==aX or ch==aW or ch==aU or ch==aS then else bb(false,
[[This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue.]]
)end end if bit32.band(cg,b)~=0 then commitAttachRef(cc)end end end function commitLayoutEffectsForProfiler(cc,cd)if aA
then local ce,cf,cg,ch,ci,cj,ck,cl=cc.flags,cc.alternate,cc.memoizedProps.onCommit,cc.memoizedProps.onRender,cc.
stateNode.effectDuration,bo(),a6,a7 if bit32.band(ce,ck)~=a2 and aj(ch)then if az then ch(cc.memoizedProps.id,if cf==nil
then'mount'else'update',cc.actualDuration,cc.treeBaseDuration,cc.actualStartTime,cj,cd.memoizedInteractions)else ch(cc.
memoizedProps.id,if cf==nil then'mount'else'update',cc.actualDuration,cc.treeBaseDuration,cc.actualStartTime,cj)end end
if aB then if bit32.band(ce,cl)~=a2 and aj(cg)then if az then cg(cc.memoizedProps.id,if cf==nil then'mount'else'update',
ci,cj,cd.memoizedInteractions)else cg(cc.memoizedProps.id,if cf==nil then'mount'else'update',ci,cj)end end end end end
function b1(cc)local cd,ce=cc.stateNode,cc.alternate if bit32.band(cc.flags,a6)~=0 then if ce==nil then if af then if cc
.type==cc.elementType and not bV then if cd.props~=cc.memoizedProps then al.error(
[[Expected %s props to match memoized props before componentDidMount. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.]]
,ba(cc.type)or'instance')end if cd.state~=cc.memoizedState then al.error(
[[Expected %s state to match memoized state before componentDidMount. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.]]
,ba(cc.type)or'instance')end end end if aA and aB and bit32.band(cc.mode,bp)~=0 then local cf,cg=xpcall(function()bk()cd
:componentDidMount()end,bc)bm(cc)if not cf then error(cg)end else cd:componentDidMount()end else local cf,cg=cc.
elementType==cc.type and ce.memoizedProps or bi(cc.type,ce.memoizedProps),ce.memoizedState if af then if cc.type==cc.
elementType and not bV then if cd.props~=cc.memoizedProps then al.error(
[[Expected %s props to match memoized props before componentDidUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.]]
,ba(cc.type)or'instance')end if cd.state~=cc.memoizedState then al.error(
[[Expected %s state to match memoized state before componentDidUpdate. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.]]
,ba(cc.type)or'instance')end end end if aA and aB and bit32.band(cc.mode,bp)~=0 then local ch,ci=xpcall(function()bk()cd
:componentDidUpdate(cf,cg,cd.__reactInternalSnapshotBeforeUpdate)end,bc)bm(cc)if not ch then error(ci)end else cd:
componentDidUpdate(cf,cg,cd.__reactInternalSnapshotBeforeUpdate)end end end local cf=cc.updateQueue if cf~=nil then if
af then if cc.type==cc.elementType and not bV then if cd.props~=cc.memoizedProps then al.error(
[[Expected %s props to match memoized props before processing the update queue. This might either be because of a bug in React, or because a component reassigns its own `this.props`. Please file an issue.]]
,ba(cc.type)or'instance')end if cd.state~=cc.memoizedState then al.error(
[[Expected %s state to match memoized state before processing the update queue. This might either be because of a bug in React, or because a component reassigns its own `this.state`. Please file an issue.]]
,ba(cc.type)or'instance')end end end bq(cc,cf,cd)end end function b_(cc)local cd=cc.updateQueue if cd~=nil then local ce
if cc.child~=nil then local cf=cc.child if cf.tag==aJ then ce=br(cf.stateNode)elseif cf.tag==aH then ce=cf.stateNode end
end bq(cc,cd,ce)end end function b0(cc)local cd,ce=cc.stateNode,cc.alternate if ce==nil and bit32.band(cc.flags,a6)~=0
then local cf,cg=cc.type,cc.memoizedProps bv(cd,cf,cg,cc)end end local function cc(cd,ce)if bs then local cf=cd while
true do if cf.tag==aJ then local cg=cf.stateNode if ce then bF(cg)else bH(cf.stateNode,cf.memoizedProps)end elseif cf.
tag==aK then local cg=cf.stateNode if ce then bG(cg)else bI(cg,cf.memoizedProps)end elseif(cf.tag==aW or cf.tag==aX)and(
cf.memoizedState)~=nil and cf~=cd then elseif cf.child~=nil then(cf.child).return_=cf cf=cf.child continue end if cf==cd
then return end while cf.sibling==nil do if cf.return_==nil or cf.return_==cd then return end cf=cf.return_ end(cf.
sibling).return_=cf.return_ cf=cf.sibling end end end function commitAttachRef(cd)local ce=cd.ref if ce~=nil then local
cf,cg=(cd.stateNode)if cd.tag==aJ then cg=br(cf)else cg=cf end if typeof(ce)=='function'then ce(cg)else if af then if
typeof(ce)~='table'then al.error(
[[Unexpected ref object provided for %s. Use either a ref-setter function or React.createRef().]],ba(cd.type)or
'instance')return end end ce.current=cg end end end function commitDetachRef(cd)local ce=cd.ref if ce~=nil then if
typeof(ce)=='function'then ce(nil)else ce.current=nil end end end function b4(cd,ce,cf,cg)bh(ce)if ce.tag==aF or ce.tag
==aG or ce.tag==aQ or ce.tag==aR or ce.tag==aV then local ch=ce.updateQueue if ch~=nil then local ci=(ch).lastEffect if
ci~=nil then local cj=ci.next local ck=cj repeat if ck.destroy~=nil then if bit32.band(ck.tag,bS)~=bQ then if aA and aB
and bit32.band(ce.mode,bp)~=0 then bk()b8(ce,cf,ck.destroy)bm(ce)else b8(ce,cf,ck.destroy)end end end ck=ck.next until
ck==cj end end return elseif ce.tag==aH then b7(ce,cf)local ch=ce.stateNode if typeof(ch.componentWillUnmount)==
'function'then safelyCallComponentWillUnmount(ce,ch,cf)end return elseif ce.tag==aJ then b7(ce,cf)return elseif ce.tag==
aL then if bs then b2(cd,ce,cf,cg)elseif bt then ae'emptyPortalContainer'end return end end function b3(cd,ce,cf,cg)
local ch=ce while true do b4(cd,ch,cf,cg)if ch.child~=nil and(not bs or ch.tag~=aL)then(ch.child).return_=ch ch=ch.child
continue end if ch==ce then return end while ch.sibling==nil do if ch.return_==nil or ch.return_==ce then return end ch=
ch.return_ end(ch.sibling).return_=ch.return_ ch=ch.sibling end end local function cd(ce)local cf=ce.alternate if cf~=
nil then cf.return_=nil ce.alternate=nil end ce.return_=nil end local function ce(cf)local cg=cf.return_ while cg~=nil
do if bW(cg)then return cg end cg=cg.return_ end error(an.new
[[Expected to find a host parent. This error is likely caused by a bug in React. Please file an issue.]])end function bW
(cf)return cf.tag==aJ or cf.tag==aI or cf.tag==aL end function bX(cf)local cg=cf while true do local ch=false while cg.
sibling==nil do if cg.return_==nil or bW(cg.return_)then return nil end cg=cg.return_ end(cg.sibling).return_=cg.return_
cg=cg.sibling while cg.tag~=aJ and cg.tag~=aK and cg.tag~=aO do if bit32.band(cg.flags,a4)~=0 then ch=true break end if
cg.child==nil or cg.tag==aL then ch=true break else(cg.child).return_=cg cg=cg.child end end if ch then continue end if
bit32.band(cg.flags,a4)==0 then return cg.stateNode end end end local function cf(cg)if not bs then return end local ch,
ci,cj=(ce(cg))local ck=ch.stateNode if ch.tag==aJ then ci=ck cj=false elseif ch.tag==aI then ci=ck.containerInfo cj=true
elseif ch.tag==aL then ci=ck.containerInfo cj=true else bb(false,
[[Invalid host parent fiber. This error is likely caused by a bug in React. Please file an issue.]])end if bit32.band(ch
.flags,a3)~=0 then bx(ci)ch.flags=bit32.band(ch.flags,bit32.bnot(a3))end local cl=bX(cg)if cj then bZ(cg,cl,ci)else bY(
cg,cl,ci)end end function bZ(cg,ch,ci)local cj=cg.tag local ck=cj==aJ or cj==aK if ck then local cl=cg.stateNode if ch
then bC(ci,cl,ch)else bA(ci,cl)end elseif cj==aL then else local cl=cg.child if cl~=nil then bZ(cl,ch,ci)local cm=cl.
sibling while cm~=nil do bZ(cm,ch,ci)cm=cm.sibling end end end end function bY(cg,ch,ci)local cj=cg.tag local ck=cj==aJ
or cj==aK if ck then local cl=cg.stateNode if ch then bB(ci,cl,ch)else bz(ci,cl)end elseif cj==aL then else local cl=cg.
child if cl~=nil then bY(cl,ch,ci)local cm=cl.sibling while cm~=nil do bY(cm,ch,ci)cm=cm.sibling end end end end
function b2(cg,ch,ci,cj)local ck,cl,cm,cn=ch,false while true do if not cl then local co=ck.return_ while true do if co
==nil then error(an.new
[[Expected to find a host parent. This error is likely caused by a bug in React. Please file an issue.]])end local cp=co
.stateNode if co.tag==aJ then cm=cp cn=false break elseif co.tag==aI then cm=cp.containerInfo cn=true break elseif co.
tag==aL then cm=cp.containerInfo cn=true break end co=co.return_ end cl=true end if ck.tag==aJ or ck.tag==aK then b3(cg,
ck,ci,cj)if cn then bE(cm,ck.stateNode)else bD(cm,ck.stateNode)end elseif ck.tag==aL then if ck.child~=nil then cm=ck.
stateNode.containerInfo cn=true ck.child.return_=ck ck=ck.child continue end else b4(cg,ck,ci,cj)if ck.child~=nil then
ck.child.return_=ck ck=ck.child continue end end if ck==ch then return end while ck.sibling==nil do if ck.return_==nil
or ck.return_==ch then return end ck=ck.return_ if ck.tag==aL then cl=false end end(ck.sibling).return_=ck.return_ ck=ck
.sibling end end local function cg(ch,ci,cj,ck)b2(ch,ci,cj,ck)local cl=ci.alternate cd(ci)if cl~=nil then cd(cl)end end
local function ch(ci,cj)if cj.tag==aF or cj.tag==aG or cj.tag==aQ or cj.tag==aR or cj.tag==aV then if aA and aB and
bit32.band(cj.mode,bp)~=0 then local ck,cl=xpcall(function()bk()c(bit32.bor(bS,bR),cj,cj.return_)end,bc)bm(cj)if not ck
then error(cl)end else c(bit32.bor(bS,bR),cj,cj.return_)end return elseif cj.tag==aH then return elseif cj.tag==aJ then
local ck=cj.stateNode if ck~=nil then local cl,cm=(cj.memoizedProps)if ci then cm=ci.memoizedProps else cm=cl end local
cn,co=cj.type,cj.updateQueue cj.updateQueue=nil if co~=nil then bw(ck,co,cn,cm,cl,cj)end end return elseif cj.tag==aK
then bb(cj.stateNode~=nil,
[[This should have a text node initialized. This error is likely caused by a bug in React. Please file an issue.]])local
ck,cl,cm=cj.stateNode,(cj.memoizedProps)if ci~=nil then cm=(ci).memoizedProps cm=cl end by(ck,cm,cl)return elseif cj.tag
==aI then if bu then local ck=cj.stateNode if ck.hydrate then ck.hydrate=false ae
'commitWork: HostRoot: commitHydratedContainer'end end return elseif cj.tag==aM then return elseif cj.tag==aN then
commitSuspenseComponent(cj)attachSuspenseRetryListeners(cj)return elseif cj.tag==aS then ae
'commitWork: SuspenseListComponent'elseif cj.tag==aP then return elseif cj.tag==aW or cj.tag==aX then local ck=cj.
memoizedState local cl=ck~=nil cc(cj,cl)return end bb(false,
[[This unit of work tag should not have side-effects. This error is likely caused by a bug in React. Please file an issue.]]
)end function commitSuspenseComponent(ci)local cj=ci.memoizedState if cj~=nil then bN()if bs then local ck=ci.child cc(
ck,true)end end if aC and cj~=nil then local ck=ci.memoizedProps.suspenseCallback if typeof(ck)=='function'then local cl
=ci.updateQueue if cl~=nil then ck(table.clone(cl))end elseif af then if ck~=nil then al.error(
'Unexpected type for suspenseCallback: %s',tostring(ck))end end end end function commitSuspenseHydrationCallbacks(ci,cj)
if not bu then return end local ck=cj.memoizedState if ck==nil then local cl=cj.alternate if cl~=nil then local cm=cl.
memoizedState if cm~=nil then local cn=cm.dehydrated if cn~=nil then bJ(cn)if aC then local co=ci.hydrationCallbacks if
co~=nil then local cp=co.onHydrated if cp then cp(cn)end end end end end end end end function
attachSuspenseRetryListeners(ci)local cj=ci.updateQueue if cj~=nil then ci.updateQueue=nil local ck=ci.stateNode if ck==
nil then ci.stateNode=ao.new()ck=ci.stateNode end for cl,cm in cj do local cn=function()return bM(ci,cl)end if not ck:
has(cl)then if az then if cl.__reactDoNotTraceInteractions~=true then cn=aw(cn)end end ck:add(cl)cl:andThen(function()
return cn()end,function()return cn()end)end end end end function isSuspenseBoundaryBeingHidden(ci,cj)if ci~=nil then
local ck=(ci).memoizedState if ck==nil or(ck).dehydrated~=nil then local cl=cj.memoizedState return cl~=nil and(cl).
dehydrated==nil end end return false end function commitResetTextContent(ci)if not bs then return end bx(ci.stateNode)
end local function ci(cj)if cj.tag==aF or cj.tag==aG or cj.tag==aR or cj.tag==aV then if aA and aB and bit32.band(cj.
mode,bp)~=0 then bn()c(bit32.bor(bT,bR),cj,cj.return_)bl(cj)else c(bit32.bor(bT,bR),cj,cj.return_)end end end
local function cj(ck,cl)if ck.tag==aF or ck.tag==aG or ck.tag==aR or ck.tag==aV then if aA and aB and bit32.band(ck.mode
,bp)~=0 then bn()c(bT,ck,cl)bl(ck)else c(bT,ck,cl)end end end local function ck(cl,cm)if cm.tag==aF or cm.tag==aG or cm.
tag==aR or cm.tag==aV then if aA and aB and bit32.band(cm.mode,bp)~=0 then bn()local cn,co=xpcall(ca,bc,bit32.bor(bT,bR)
,cm)bl(cm)if not cn then error(co)end else ca(bit32.bor(bT,bR),cm)end elseif cm.tag==aM then
commitProfilerPassiveEffect(cl,cm)end end function invokeLayoutEffectMountInDEV(cl)if af and aD then if cl.tag==aF or cl
.tag==aG or cl.tag==aR or cl.tag==aV then aZ(nil,ca,nil,bit32.bor(bS,bR),cl)if a_()then local cm=a0()bP(cl,cl.return_,cm
)end return end elseif cl.tag==aH then local cm=cl.stateNode aZ(nil,cm.componentDidMount,cm)if a_()then local cn=a0()bP(
cl,cl.return_,cn)end return end end function invokePassiveEffectMountInDEV(cl)if af and aD then if cl.tag==aF or cl.tag
==aG or cl.tag==aR or cl.tag==aV then aZ(nil,ca,nil,bit32.bor(bT,bR),cl)if a_()then local cm=a0()bP(cl,cl.return_,cm)end
return end end end function invokeLayoutEffectUnmountInDEV(cl)if af and aD then if cl.tag==aF or cl.tag==aG or cl.tag==
aR or cl.tag==aV then aZ(nil,c,nil,bit32.bor(bS,bR),cl,cl.return_)if a_()then local cm=a0()bP(cl,cl.return_,cm)end
return end elseif cl.tag==aH then local cm=cl.stateNode if typeof(cm.componentWillUnmount)=='function'then
safelyCallComponentWillUnmount(cl,cm,cl.return_)end return end end function invokePassiveEffectUnmountInDEV(cl)if af and
aD then if cl.tag==aF or cl.tag==aG or cl.tag==aR or cl.tag==aV then aZ(nil,c,nil,bit32.bor(bT,bR),cl,cl.return_)if a_()
then local cm=a0()bP(cl,cl.return_,cm)end return end end end return{safelyCallDestroy=b8,commitBeforeMutationLifeCycles=
b9,commitResetTextContent=commitResetTextContent,commitPlacement=cf,commitDeletion=cg,commitWork=ch,commitAttachRef=
commitAttachRef,commitDetachRef=commitDetachRef,commitPassiveUnmount=ci,commitPassiveUnmountInsideDeletedTree=cj,
commitPassiveMount=ck,invokeLayoutEffectMountInDEV=invokeLayoutEffectMountInDEV,invokeLayoutEffectUnmountInDEV=
invokeLayoutEffectUnmountInDEV,invokePassiveEffectMountInDEV=invokePassiveEffectMountInDEV,
invokePassiveEffectUnmountInDEV=invokePassiveEffectUnmountInDEV,isSuspenseBoundaryBeingHidden=
isSuspenseBoundaryBeingHidden,recursivelyCommitLayoutEffects=cb}end)()end,[75]=function()local aa,ab,ac=a(75)local ad
return(function(...)local function ae(af)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('UNIMPLEMENTED ERROR: '..tostring(af))error(
'FIXME (roblox): '..af..' is unimplemented',2)end local af,ag=ab.Parent.Parent,ac(ab.Parent.ReactInternalTypes)local ah=
ac(ab.Parent.ReactFiberLane)local ai,aj=ah.OffscreenLane,ac(ab.Parent.ReactFiberHostConfig)local ak=ac(ab.Parent.
ReactFiberOffscreenComponent)local al=ac(ab.Parent['ReactMutableSource.new'])local am,an=al.resetWorkInProgressVersions,
ac(ab.Parent.ReactWorkTags)local ao,ap,aq,ar,as,at,au,av,aw,ax,az,aA,aB,aC,aD,aE,aF,aG,aH,aI,aJ,aK,aL,aM,aN=an.
IndeterminateComponent,an.FunctionComponent,an.ClassComponent,an.HostRoot,an.HostComponent,an.HostText,an.HostPortal,an.
ContextProvider,an.ContextConsumer,an.ForwardRef,an.Fragment,an.Mode,an.Profiler,an.SuspenseComponent,an.
SuspenseListComponent,an.MemoComponent,an.SimpleMemoComponent,an.LazyComponent,an.IncompleteClassComponent,an.
FundamentalComponent,an.ScopeComponent,an.Block,an.OffscreenComponent,an.LegacyHiddenComponent,ac(ab.Parent[
'ReactFiberSuspenseComponent.new'])local aO=ac(ab.Parent.ReactTypeOfMode)local aP,aQ,aR,aS,aT=aO.NoMode,aO.
ConcurrentMode,aO.BlockingMode,aO.ProfileMode,ac(ab.Parent.ReactFiberFlags)local aU,aV,aW,aX,aY,aZ,a_,a0,a1,a2,a3,a4,a5,
a6,a7,a8,a9,b,ba,bb,bc,bd,be,bf,bg=aT.Ref,aT.Update,aT.Callback,aT.Passive,aT.Deletion,aT.NoFlags,aT.DidCapture,aT.
Snapshot,aT.MutationMask,aT.LayoutMask,aT.PassiveMask,aT.StaticMask,aT.PerformedWork,ac(af.Shared).invariant,aj.
createInstance,aj.createTextInstance,aj.appendInitialChild,aj.finalizeInitialChildren,aj.prepareUpdate,aj.
supportsMutation,aj.supportsPersistence,aj.createContainerChildSet,aj.finalizeContainerChildren,aj.preparePortalMount,
ac(ab.Parent['ReactFiberHostContext.new'])local bh,bi,bj,bk,bl=bg.getRootHostContainer,bg.popHostContext,bg.
getHostContext,bg.popHostContainer,ac(ab.Parent['ReactFiberSuspenseContext.new'])local bm,bn,bo,bp=bl.popSuspenseContext
,bl.suspenseStackCursor,bl.InvisibleParentSuspenseContext,bl.hasSuspenseContext local bq=ac(ab.Parent[
'ReactFiberContext.new'])local br,bs,bt,bu,bv=bq.isContextProvider,bq.popContext,bq.popTopLevelContextObject,ac(ab.
Parent['ReactFiberNewContext.new']).popProvider,ac(ab.Parent['ReactFiberHydrationContext.new'])local bw,bx,by,bz,bA,bB=
bv.prepareToHydrateHostSuspenseInstance,bv.popHydrationState,bv.resetHydrationState,bv.prepareToHydrateHostInstance,bv.
prepareToHydrateHostTextInstance,ac(af.Shared).ReactFeatureFlags local bC,bD,bE,bF,bG,bH=bB.enableSchedulerTracing,bB.
enableSuspenseCallback,bB.enableSuspenseServerRenderer,bB.enableFundamentalAPI,bB.enableProfilerTimer,ac(ab.Parent[
'ReactFiberWorkLoop.new'])local bI,bJ,bK,bL,bM,bN,bO,bP=bH.popRenderLanes,bH.markSpawnedWork,bH.renderDidSuspend,bH.
renderDidSuspendDelayIfPossible,ah.NoLanes,ah.includesSomeLane,ah.mergeLanes,ac(ab.Parent['ReactProfilerTimer.new'])
local bQ=bP.transferActualDuration local function bR(bS)bS.flags=bit32.bor(bS.flags,aV)end local function bS(bT)bT.flags
=bit32.bor(bT.flags,aU)end local function bT(bU,bV)local bW=bU~=nil and bU.child==bV.child if bW then return true end
local bX=bV.child while bX~=nil do if bit32.band(bX.flags,a1)~=aZ then return false end if bit32.band(bX.subtreeFlags,a1
)~=aZ then return false end bX=bX.sibling end return true end local bU,bV,bW,bX if bb then bU=function(bY,bZ,b_,b0)local
b1=bZ.child while b1~=nil do if b1.tag==as or b1.tag==at then a9(bY,b1.stateNode)elseif bF and b1.tag==aI then a9(bY,b1.
stateNode.instance)elseif b1.tag==au then elseif b1.child~=nil then b1.child.return_=b1 b1=b1.child continue end if b1==
bZ then return end while b1.sibling==nil do if b1.return_==nil or b1.return_==bZ then return end b1=b1.return_ end(b1.
sibling).return_=b1.return_ b1=b1.sibling end end bV=function(bY,bZ)end function bW(bY,bZ,b_,b0,b1)local b2=bY.
memoizedProps if b2==b0 then return end local b3,b4=bZ.stateNode,bj()local b5=ba(b3,b_,b2,b0,b1,b4)bZ.updateQueue=b5 if
b5 then bR(bZ)end end function bX(bY,bZ,b_,b0)if b_~=b0 then bR(bZ)end end elseif bc then bU=function(bY,bZ,b_,b0)ae
'appendAllChildren'end local function bY(bZ,b_,b0,b1)ae'appendAllChildrenToContainer'end function bV(bZ,b_)local b0,b1=
b_.stateNode,bT(bZ,b_)if b1 then else local b2=b0.containerInfo local b3=bd(b2)bY(b3,b_,false,false)b0.pendingChildren=
b3 bR(b_)be(b2,b3)end end else bV=function(bY,bZ)end end local function bY(bZ)local b_,b0,b1=bZ.alternate~=nil and(bZ.
alternate).child==bZ.child,bM,aZ if not b_ then if bG and bit32.band(bZ.mode,aS)~=aP then local b2,b3,b4=bZ.
actualDuration,bZ.selfBaseDuration,bZ.child while b4~=nil do b0=bO(b0,bO(b4.lanes,b4.childLanes))b1=bit32.bor(b1,b4.
subtreeFlags)b1=bit32.bor(b1,b4.flags)b2+=b4.actualDuration b3+=b4.treeBaseDuration b4=b4.sibling end bZ.actualDuration=
b2 bZ.treeBaseDuration=b3 else local b2=bZ.child while b2~=nil do b0=bit32.bor(b0,bit32.bor(b2.lanes,b2.childLanes))b1=
bit32.bor(b1,b2.subtreeFlags)b1=bit32.bor(b1,b2.flags)b2.return_=bZ b2=b2.sibling end end bZ.subtreeFlags=bit32.bor(bZ.
subtreeFlags,b1)else if bG and bit32.band(bZ.mode,aS)~=aP then local b2,b3=bZ.selfBaseDuration,bZ.child while b3~=nil do
b0=bO(b0,bO(b3.lanes,b3.childLanes))b1=bit32.bor(b1,bit32.band(b3.subtreeFlags,a4))b1=bit32.bor(b1,bit32.band(b3.flags,
a4))b2+=b3.treeBaseDuration b3=b3.sibling end bZ.treeBaseDuration=b2 else local b2=bZ.child while b2~=nil do b0=bit32.
bor(b0,bit32.bor(b2.lanes,b2.childLanes))b1=bit32.bor(b1,bit32.band(b2.subtreeFlags,a4))b1=bit32.bor(b1,bit32.band(b2.
flags,a4))b2.return_=bZ b2=b2.sibling end end bZ.subtreeFlags=bit32.bor(bZ.subtreeFlags,b1)end bZ.childLanes=b0 return
b_ end local function bZ(b_,b0,b1)local b2=b0.pendingProps if b0.tag==ao or b0.tag==aG or b0.tag==aF or b0.tag==ap or b0
.tag==ax or b0.tag==az or b0.tag==aA or b0.tag==aw or b0.tag==aE then bY(b0)return nil elseif b0.tag==aq then local b3=
b0.type if br(b3)then bs(b0)end bY(b0)return nil elseif b0.tag==ar then bk(b0)bt(b0)am()local b3=b0.stateNode if b3.
pendingContext then b3.context=b3.pendingContext b3.pendingContext=nil end if b_==nil or b_.child==nil then local b4=bx(
b0)if b4 then bR(b0)elseif not b3.hydrate then b0.flags=bit32.bor(b0.flags,a0)end end bV(b_,b0)bY(b0)return nil elseif
b0.tag==as then bi(b0)local b3,b4=bh(),b0.type if b_~=nil and b0.stateNode~=nil then bW(b_,b0,b4,b2,b3)if b_.ref~=b0.ref
then bS(b0)end else if not b2 then a6(b0.stateNode~=nil,
[[We must have new props for new mounts. This error is likely caused by a bug in React. Please file an issue.]])bY(b0)
return nil end local b5,b6=bj(),bx(b0)if b6 then if bz(b0,b3,b5)then bR(b0)end else local b7=a7(b4,b2,b3,b5,b0)bU(b7,b0,
false,false)b0.stateNode=b7 if b(b7,b4,b2,b3,b5)then bR(b0)end end if b0.ref~=nil then bS(b0)end end bY(b0)return nil
elseif b0.tag==at then local b3=b2 if b_ and b0.stateNode~=nil then local b4=b_.memoizedProps bX(b_,b0,b4,b3)else if
typeof(b3)~='string'then a6(b0.stateNode~=nil,
[[We must have new props for new mounts. This error is likely caused by a bug in React. Please file an issue.]])end
local b4,b5,b6=bh(),bj(),bx(b0)if b6 then if bA(b0)then bR(b0)end else b0.stateNode=a8(b3,b4,b5,b0)end end bY(b0)return
nil elseif b0.tag==aB then local b3=bY(b0)if not b3 then local b4,b5,b6,b7,b8=aV,aW,aX,b0.subtreeFlags,b0.flags local b9
=b8 if bit32.band(b8,a5)~=aZ or bit32.band(b7,a5)~=aZ then b9=bit32.bor(b9,b4)end if bit32.band(b8,bit32.bor(a2,aY))~=aZ
or bit32.band(b7,bit32.bor(a2,aY))~=aZ then b9=bit32.bor(b9,b5)end if bit32.band(b8,a3)~=aZ or bit32.band(b7,a3)~=aZ
then b9=bit32.bor(b9,b6)end b0.flags=b9 end return nil elseif b0.tag==aC then bm(b0)local b3=b0.memoizedState if bE then
if b3~=nil and(b3).dehydrated~=nil then if b_==nil then local b4=bx(b0)a6(b4,
[[A dehydrated suspense component was completed without a hydrated node. This is probably a bug in React.]])bw(b0)if bC
then bJ(ai)end bY(b0)if bG then if bit32.band(b0.mode,aS)~=aP then local b5=b3~=nil if b5 then local b6=b0.child if b6~=
nil then b0.treeBaseDuration=(b6.treeBaseDuration)end end end end return nil else by()if bit32.band(b0.flags,a_)==aZ
then b0.memoizedState=nil end b0.flags=bit32.bor(b0.flags,aV)bY(b0)if bG then if bit32.band(b0.mode,aS)~=aP then local
b4=b3~=nil if b4 then local b5=b0.child if b5~=nil then b0.treeBaseDuration-=b5.treeBaseDuration end end end end return
nil end end end if bit32.band(b0.flags,a_)~=aZ then b0.lanes=b1 if bG and bit32.band(b0.mode,aS)~=aP then bQ(b0)end
return b0 end local b4,b5=b3~=nil,false if b_==nil then if b0.memoizedProps.fallback~=nil then bx(b0)end else local b6=
b_.memoizedState b5=b6~=nil end if b4 and not b5 then if bit32.band(b0.mode,aR)~=aP then local b6=b_==nil and b0.
memoizedProps.unstable_avoidThisFallback~=true if b6 or bp(bn.current,bo)then bK()else bL()end end end if bc then if b4
then b0.flags=bit32.bor(b0.flags,aV)end end if bb then if b4 or b5 then b0.flags=bit32.bor(b0.flags,aV)end end if bD and
b0.updateQueue~=nil and b0.memoizedProps.suspenseCallback~=nil then b0.flags=bit32.bor(b0.flags,aV)end bY(b0)if bG then
if bit32.band(b0.mode,aS)~=aP then if b4 then local b6=b0.child if b6~=nil then b0.treeBaseDuration-=b6.treeBaseDuration
end end end end return nil elseif b0.tag==au then bk(b0)bV(b_,b0)if b_==nil then bf(b0.stateNode.containerInfo)end bY(b0
)return nil elseif b0.tag==av then bu(b0)bY(b0)return nil elseif b0.tag==aH then local b3=b0.type if br(b3)then bs(b0)
end bY(b0)return nil elseif b0.tag==aD then ae'SuspenseListComponent'elseif b0.tag==aI then ae'FundamentalComponent'
elseif b0.tag==aJ then ae'ScopeComponent'elseif b0.tag==aK then ae'Block'elseif b0.tag==aL or b0.tag==aM then bI(b0)
local b3=b0.memoizedState local b4=b3~=nil if b_~=nil then local b5=b_.memoizedState local b6=b5~=nil if b6~=b4 and b2.
mode~='unstable-defer-without-hiding'then b0.flags=bit32.bor(b0.flags,aV)end end if not b4 or bN(bH.subtreeRenderLanes,
ai)or bit32.band(b0.mode,aQ)==aP then bY(b0)end return nil end a6(false,
[[Unknown unit of work tag (%s). This error is likely caused by a bug in React. Please file an issue.]],tostring(b0.tag)
)return nil end return{completeWork=bZ}end)()end,[76]=function()local aa,ab,ac=a(76)local ad return(function(...)local
ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ab.Parent.ReactInternalTypes)local ah=ac(ab.Parent.
ReactWorkTags)local ai,aj,ak,al,am,an,ao,ap,aq,ar=ah.HostComponent,ah.LazyComponent,ah.SuspenseComponent,ah.
SuspenseListComponent,ah.FunctionComponent,ah.IndeterminateComponent,ah.ForwardRef,ah.SimpleMemoComponent,ah.
ClassComponent,ac(ae.Shared).ReactComponentStackFrame local as,at,au=ar.describeBuiltInComponentFrame,ar.
describeFunctionComponentFrame,ar.describeClassComponentFrame local function av(aw)local ax if _G.__DEV__ then local az=
aw._debugOwner if az then ax=az.type end end local az if _G.__DEV__ then az=aw._debugSource end if aw.tag==ai then
return as(aw.type,az,ax)elseif aw.tag==aj then return as('Lazy',az,ax)elseif aw.tag==ak then return as('Suspense',az,ax)
elseif aw.tag==al then return as('SuspenseList',az,ax)elseif aw.tag==am or aw.tag==an or aw.tag==ap then return at(aw.
type,az,ax)elseif aw.tag==ao then return at(aw.type.render,az,ax)elseif aw.tag==aq then return au(aw.type,az,ax)else
return''end end return{getStackByFiberInDevAndProd=function(aw)local ax,az=pcall(function()local ax,az='',aw repeat ax
..=av(az)az=(az).return_ until az==nil return ax end)if not ax then local aA='\nError generating stack: 'if typeof(az)==
'table'and(az).message and(az).stack then return aA..(az).message..'\n'..tostring((az).stack)end return aA..tostring(az)
end return az end}end)()end,[77]=function()local aa,ab,ac=a(77)local ad return(function(...)local ae,af,ag=_G.__DEV__,_G
.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__,ab.Parent.Parent local ah=ac(ag.LuauPolyfill)local ai,aj,ak,al=ah.
Object,ah.Error,ac(ag.Shared).console,ac(ab.Parent.ReactInternalTypes)local am=ac(ab.Parent['ReactFiberStack.new'])local
an,ao,ap=ac(ab.Parent.ReactFiberTreeReflection).isFiberMounted,ac(ag.Shared).ReactFeatureFlags.disableLegacyContext,ac(
ab.Parent.ReactWorkTags)local aq,ar,as,at,au,av,aw,ax=ap.ClassComponent,ap.HostRoot,ac(ag.Shared).getComponentName,ac(ag
.Shared).checkPropTypes,am.createCursor,am.push,(am.pop)if ae then ax={}end local az={}if ae then ai.freeze(az)end local
aA,aB,aC,aD=au(az),au(false),az local function aE(aF,aG,aH)if aH and aD(aG)then return aC end return aA.current end
local function aF(aG,aH,aI)local aJ=aG.stateNode aJ.__reactInternalMemoizedUnmaskedChildContext=aH aJ.
__reactInternalMemoizedMaskedChildContext=aI end local function aG(aH,aI)local aJ=aH.type if type(aJ)=='function'then
return aI end local aK=aJ.contextTypes if not aK then return az end local aL=aH.stateNode if aL and aL.
__reactInternalMemoizedUnmaskedChildContext==aI then return aL.__reactInternalMemoizedMaskedChildContext end local aM={}
for aN,aO in aK do aM[aN]=aI[aN]end if ae or af then local aP=as(aJ)or'Unknown'at(aK,nil,aM,'context',aP)end if aL then
aF(aH,aI,aM)end return aM end local function aH()if ao then return false else return aB.current end end function aD(aI)
if type(aI)=='function'then return false end local aJ=aI.childContextTypes return aJ~=nil end local function aI(aJ)aw(aB
,aJ)aw(aA,aJ)end local function aJ(aK)aw(aB,aK)aw(aA,aK)end local function aK(aL,aM,aN)if aA.current~=az then error(aj.
new[[Unexpected context found on stack. This error is likely caused by a bug in React. Please file an issue.]])end av(aA
,aM,aL)av(aB,aN,aL)end local function aL(aM,aN,aO)local aP,aQ=aM.stateNode,aN.childContextTypes if aP.getChildContext==
nil or type(aP.getChildContext)~='function'then if ae then local aR=as(aN)or'Unknown'if not ax[aR]then ax[aR]=true ak.
error(
[[%s.childContextTypes is specified but there is no getChildContext() method on the instance. You can either define getChildContext() on %s or remove childContextTypes from it.]]
,aR,aR)end end return aO end local aR=aP:getChildContext()for aS,aT in aR do if aQ[aS]==nil then local aU=as(aN)or
'Unknown'error(aj.new(string.format([[%s.getChildContext(): key "%s" is not defined in childContextTypes.]],aU,aS)))end
end if ae or af then local aU=as(aN)or'Unknown'at(aQ,nil,aR,'child context',aU)end return ai.assign({},aO,aR)end
local function aM(aN)local aO=aN.stateNode local aP=(aO and aO.__reactInternalMemoizedMergedChildContext)or az aC=aA.
current av(aA,aP,aN)av(aB,aB.current,aN)return true end local function aN(aO,aP,aQ)local aR=aO.stateNode if not aR then
error(aj.new
[[Expected to have an instance by this point. This error is likely caused by a bug in React. Please file an issue.]])end
if aQ then local aS=aL(aO,aP,aC)aR.__reactInternalMemoizedMergedChildContext=aS aw(aB,aO)aw(aA,aO)av(aA,aS,aO)av(aB,aQ,
aO)else aw(aB,aO)av(aB,aQ,aO)end end local function aO(aP)if aP.tag~=aq or not an(aP)then error(aj.new
[[Expected subtree parent to be a mounted class component. This error is likely caused by a bug in React. Please file an issue.]]
)end local aQ=aP repeat if aQ.tag==ar then return aQ.stateNode.context elseif aQ.tag==aq then local aR=aQ.type if aR.
childContextTypes~=nil then return aQ.stateNode.__reactInternalMemoizedMergedChildContext end end aQ=aQ.return_ until aQ
==nil error(aj.new
[[Found unexpected detached subtree parent. This error is likely caused by a bug in React. Please file an issue.]])end
return{emptyContextObject=az,getUnmaskedContext=aE,cacheContext=aF,getMaskedContext=aG,hasContextChanged=aH,popContext=
aI,popTopLevelContextObject=aJ,pushTopLevelContextObject=aK,processChildContext=aL,isContextProvider=aD,
pushContextProvider=aM,invalidateContextProvider=aN,findCurrentUnmaskedContext=aO}end)()end,[78]=function()local aa,ab,
ac=a(78)local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.Shared).console,ac(ae.LuauPolyfill)
local ah={}local function ai(aj)if typeof(aj)=='function'then return true end if typeof(aj)=='table'then local ak=
getmetatable(aj)if ak and rawget(ak,'__call')then return true end if aj._isMockFunction then return true end end return
false end local aj,ak=ac(ae.Shared).ReactFeatureFlags.enableProfilerTimer,ac(ab.Parent.ReactInternalTypes)local al=ac(ae
.Shared)local am,an,ao,ap=ac(ab.Parent.ReactFiberFlags).DidCapture,false ah.isDevToolsPresent=function()return _G.
__REACT_DEVTOOLS_GLOBAL_HOOK__~=nil end ah.injectInternals=function(aq)if _G.__REACT_DEVTOOLS_GLOBAL_HOOK__==nil then
return false end local ar=_G.__REACT_DEVTOOLS_GLOBAL_HOOK__ if ar.isDisabled then return true end if not ar.
supportsFiber then if _G.__DEV__ then af.error
[[The installed version of React DevTools is too old and will not work with the current version of React. Please update React DevTools. https://reactjs.org/link/react-devtools]]
end return true end local as,at=pcall(function()ao=ar.inject(aq)ap=ar end)if not as then if _G.__DEV__ then af.error(
'React instrumentation encountered an error: %s.',at)end end return true end ah.onScheduleRoot=function(aq,ar)if _G.
__DEV__ then if ap and ai(ap.onScheduleFiberRoot)then local as,at=pcall(ap.onScheduleFiberRoot,ao,aq,ar)if not as then
if _G.__DEV__ and not an then an=true af.error('React instrumentation encountered an error: %s',at)end end end end end
ah.onCommitRoot=function(aq,ar)if ap and ai(ap.onCommitFiberRoot)then local as,at=pcall(function()local as=bit32.band(aq
.current.flags,am)==am if aj then ap.onCommitFiberRoot(ao,aq,ar,as)else ap.onCommitFiberRoot(ao,aq,nil,as)end end)if not
as then if _G.__DEV__ then if not an then an=true af.error('React instrumentation encountered an error: %s',at)end end
end end end ah.onCommitUnmount=function(aq)if ap and ai(ap.onCommitFiberUnmount)then local ar,as=pcall(ap.
onCommitFiberUnmount,ao,aq)if not ar then if _G.__DEV__ then if not an then an=true af.error(
'React instrumentation encountered an error: %s',as)end end end end end return ah end)()end,[79]=function()local aa,ab,
ac=a(79)local ad return(function(...)local ae={}ae.showErrorDialog=function(af,ag)return true end return ae end)()end,[
80]=function()local aa,ab,ac=a(80)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)
local ag,ah,ai=af.util.inspect,af.setTimeout,ac(ae.Shared)local aj,ak,al=ai.console,ai.errorToString,ac(ab.Parent.
ReactInternalTypes)local am=ac(ab.Parent.ReactCapturedValue)local an,ao,ap,aq=ac(ab.Parent.ReactFiberErrorDialog).
showErrorDialog,ac(ab.Parent.ReactWorkTags).ClassComponent,ac(ae.Shared).getComponentName,{}aq.logCapturedError=function
(ar,as)local at,au=pcall(function()local at=an(ar,as)if at==false then return nil end local au=as.value if _G.__DEV__
then local av,aw=as.source,as.stack local ax=aw or''if au~=nil and au._suppressLogging then if ar.tag==ao then return
end aj.error(au)end local az if av~=nil then az=ap(av.type)else az=nil end local aA if az then aA=
'The above error occurred in the <'..tostring(az)..'> component:'else aA=
'The above error occurred in one of your React components:'end local aB,aC=(ap(ar.type))if aB then aC=
[[React will try to recreate this component tree from scratch ]]..'using the error boundary you provided, '..aB..'.'else
aC=
[[Consider adding an error boundary to your tree to customize error handling behavior.
Visit https://reactjs.org/link/error-boundaries to learn more about error boundaries.]]
end local aD=aA..'\n'..ax..'\n\n'..aC aj.error(aD)else aj.error(ag(au))end return nil end)if not at then warn(
'failed to error with error: '..ag(au))ah(function()error(ak(au))end)end end return aq end)()end,[81]=function()local aa
,ab,ac=a(81)local ad return(function(...)local ae={}ae.NoFlags=0b0 ae.PerformedWork=0b1 ae.Placement=0b10 ae.Update=
0b100 ae.PlacementAndUpdate=0b110 ae.Deletion=0b1000 ae.ContentReset=0b10000 ae.Callback=0b100000 ae.DidCapture=
0b1000000 ae.Ref=0b10000000 ae.Snapshot=0b100000000 ae.Passive=0b1000000000 ae.PassiveUnmountPendingDev=0b10000000000000
ae.Hydrating=0b10000000000 ae.HydratingAndUpdate=0b10000000100 ae.LifecycleEffectMask=0b1110100100 ae.HostEffectMask=
0b11111111111 ae.Incomplete=0b100000000000 ae.ShouldCapture=0b1000000000000 ae.ForceUpdateForLegacySuspense=
0b100000000000000 ae.PassiveStatic=0b1000000000000000 ae.BeforeMutationMask=0b1100001010 ae.MutationMask=0b10010011110
ae.LayoutMask=0b10100100 ae.PassiveMask=0b1000001000 ae.StaticMask=0b1000000000000000 ae.MountLayoutDev=
0b10000000000000000 ae.MountPassiveDev=0b100000000000000000 return ae end)()end,[82]=function()local aa,ab,ac=a(82)local
ad return(function(...)local function ae(af)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('UNIMPLEMENTED ERROR: '..af)error('FIXME (roblox): '..af..
' is unimplemented')end local af,ag=_G.__DEV__,ab.Parent.Parent local ah=ac(ag.LuauPolyfill)local ai,aj,ak,al,am,an,ao=
ah.Array,ah.Error,ah.Object,ac(ag.React).createRef,ac(ag.React).createBinding,ac(ag.Shared).console,ac(ag.Shared)local
ap=ac(ab.Parent.ReactInternalTypes)local aq=ac(ab.Parent.ReactFiberLane)local ar=ac(ab.Parent.ReactHookEffectTags)local
as,at=ac(ag.Shared).ReactSharedInternals,ac(ag.Shared).ReactFeatureFlags local au,av,aw,ax,az,aA,aB,aC,aD,aE,aF,aG,aH=at
.enableDebugTracing,at.enableSchedulingProfiler,at.enableNewReconciler,at.enableDoubleInvokingEffects,ac(ab.Parent.
ReactTypeOfMode).DebugTracingMode,aq.NoLane,aq.NoLanes,aq.isSubsetOfLanes,aq.mergeLanes,aq.removeLanes,aq.
markRootEntangled,aq.markRootMutableRead,ac(ab.Parent['ReactFiberNewContext.new'])local aI,aJ=aH.readContext,ac(ab.
Parent.ReactFiberFlags)local aK,aL,aM,aN,aO,aP,aQ,aR,aS=aJ.Update,aJ.Passive,aJ.PassiveStatic,aJ.MountLayoutDev,aJ.
MountPassiveDev,ar.HasEffect,ar.Layout,ar.Passive,ac(ab.Parent['ReactFiberWorkLoop.new'])local aT,aU,aV,aW,aX,aY,aZ,a_,
a0,a1=aS.warnIfNotCurrentlyActingUpdatesInDEV,aS.scheduleUpdateOnFiber,aS.warnIfNotScopedWithMatchingAct,aS.
requestEventTime,aS.requestUpdateLane,aS.markSkippedUpdateLanes,aS.getWorkInProgressRoot,aS.
warnIfNotCurrentlyActingEffectsInDEV,ac(ag.Shared).invariant,ac(ag.Shared).getComponentName local function a2(a3,a4)
return a3==a4 and(a3~=0 or 1/a3==1/a4)or a3~=a3 and a4~=a4 end local a3,a4,a5=ac(ab.Parent['ReactFiberBeginWork.new']).
markWorkInProgressReceivedUpdate,ac(ab.Parent['ReactFiberHydrationContext.new']).getIsHydrating,ac(ab.Parent.
ReactFiberHostConfig)local a6,a7=a5.makeClientId,ac(ab.Parent['ReactMutableSource.new'])local a8,a9,b,ba,bb,bc,bd=a7.
warnAboutMultipleRenderersDEV,a7.getWorkInProgressVersion,a7.setWorkInProgressVersion,a7.markSourceAsDirty,ac(ab.Parent.
DebugTracing).logStateUpdateScheduled,ac(ab.Parent.SchedulingProfiler).markStateUpdateScheduled,as.
ReactCurrentDispatcher local be,bf if af then bf={}be={}end local bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,
by={},aB,false,false,25,0,false local function bz(bA)local bB=0 for bC,bD in bA do bB=if bC>bB then bC else bB end
return bB end local function bA(bB)if type(bB)~='table'then return false end for bC,bD in bB do if type(bC)~='number'
then return false end end return true end local function bB()if af then local bC=(bq)if br==nil then br=({bC})else table
.insert(br,bC)end end end function updateHookTypesDev()if af then local bC=(bq)if br~=nil then bl+=1 if br[bl]~=bC then
warnOnHookMismatchInDev(bC)end end end end local function bC(bD)if af then if bD~=nil and not bA(bD)then an.error(
[[%s received a final argument that is not an array (instead, received `%s`). When specified, the final argument must be an array.]]
,bq,type(bD))end end end function warnOnHookMismatchInDev(bD)if af then local bE=a1(bn.type)or'Component'if not be[bE]
then be[bE]=true if br~=nil then local bF,bG='',30 for bH=1,bl do local bI,bJ=((br)[bH])if bH==bl then bJ=bD else bJ=bI
end local bK=tostring(bH)..'. '..(bI or'undefined')while string.len(bK)<bG do bK..=' 'end bK..=bJ..'\n'bF..=bK end an.
error(
[[React has detected a change in the order of Hooks called by %s. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
%s   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
]]
,bE,bF)end end end end local function bD()error(aj.new
[[Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]]
)end local function bE(bF,bG)if af then if bm then return false end end if bG==nil then if af then an.error(
[[%s received a final argument during this render, but not during the previous render. Even though the final argument is optional, its type cannot change between renders.]]
,bq)end return false end local bH,bI=bz(bF),bz(bG)if bH~=bI then return false end local bJ=math.min(bI,bH)for bK=1,bJ do
if a2(bF[bK],bG[bK])then continue end return false end return true end bg.bailoutHooks=function(bF,bG,bH)bG.updateQueue=
bF.updateQueue if af and ax then bG.flags=bit32.band(bG.flags,bit32.bnot(bit32.bor(aO,aL,aN,aK)))else bG.flags=bit32.
band(bG.flags,bit32.bnot(bit32.bor(aL,aK)))end bF.lanes=aE(bF.lanes,bH)end local bF=false bg.resetHooksAfterThrow=
function()bd.current=bg.ContextOnlyDispatcher if bi then local bG=bn.memoizedState while bG~=nil do local bH=bG.queue if
bH~=nil then bH.pending=nil end bG=bG.next end bi=false end bh=aB bn=nil bo=nil bp=nil if af then br=nil bl=0 bq=nil bF=
false end bj=false end local function bG()local bH={memoizedState=nil,baseState=nil,baseQueue=nil,queue=nil,next=nil}if
bp==nil then bn.memoizedState=bH bp=bH else bp.next=bH bp=bH end return bp end local function bH()local bI if bo==nil
then local bJ=bn.alternate if bJ~=nil then bI=bJ.memoizedState else bI=nil end else bI=bo.next end local bJ if bp==nil
then bJ=bn.memoizedState else bJ=bp.next end if bJ~=nil then bp=bJ bJ=bp.next bo=bI else if bI==nil then error(aj.new
'Rendered more hooks than during the previous render.')end bo=bI local bK={memoizedState=bo.memoizedState,baseState=bo.
baseState,baseQueue=bo.baseQueue,queue=bo.queue,next=nil}if bp==nil then bp=bK bn.memoizedState=bK else bp.next=bK bp=bK
end end return bp end function basicStateReducer(bI,bJ)if type(bJ)=='function'then return bJ(bI)else return bJ end end
function mountReducer(bI,bJ,bK)local bL,bM=(bG())if bK~=nil then bM=bK(bJ)else bM=(bJ)end bL.baseState=bM bL.
memoizedState=bL.baseState local bN={pending=nil,dispatch=nil,lastRenderedReducer=bI,lastRenderedState=bM}bL.queue=bN
local bO=bn local bP=function(bP,...)dispatchAction(bO,bN,bP,...)end bN.dispatch=bP return bL.memoizedState,bP end
function updateReducer(bI,bJ,bK)local bL=bH()local bM=bL.queue assert(bM~=nil,
[[Should have a queue. This is likely a bug in React. Please file an issue.]])bM.lastRenderedReducer=bI local bN=bo
local bO,bP=bN.baseQueue,bM.pending if bP~=nil then if bO~=nil then local bQ,bR=bO.next,bP.next bO.next=bR bP.next=bQ
end bO=bP bN.baseQueue=bO bM.pending=nil end if bO~=nil then local bQ,bR,bS,bT,bU=bO.next,(bN.baseState)local bV=bQ
repeat local bW=bV.lane if bit32.band(bh,bW)~=bW then local bX={lane=bW,action=bV.action,eagerReducer=bV.eagerReducer,
eagerState=bV.eagerState,next=nil}if bU==nil then bU=bX bT=bU bS=bR else bU.next=bX bU=bU.next end bn.lanes=aD(bn.lanes,
bW)aY(bW)else if bU~=nil then local bX={lane=aA,action=bV.action,eagerReducer=bV.eagerReducer,eagerState=bV.eagerState,
next=nil}bU.next=bX bU=bU.next end if bV.eagerReducer==bI then bR=bV.eagerState else local bX=bV.action bR=bI(bR,bX)end
end bV=bV.next until bV==nil or bV==bQ if bU==nil then bS=bR else bU.next=bT end if not a2(bR,bL.memoizedState)then a3()
end bL.memoizedState=bR bL.baseState=bS bL.baseQueue=bU bM.lastRenderedState=bR end local bQ=bM.dispatch return bL.
memoizedState,bQ end function rerenderReducer(bI,bJ,bK)local bL=bH()local bM=bL.queue assert(bM~=nil,
[[Should have a queue. This is likely a bug in React. Please file an issue.]])bM.lastRenderedReducer=bI local bN,bO,bP=
bM.dispatch,bM.pending,bL.memoizedState if bO~=nil then bM.pending=nil local bQ=bO.next local bR=bQ repeat local bS=bR.
action bP=bI(bP,bS)bR=bR.next until bR==bQ if not a2(bP,bL.memoizedState)then a3()end bL.memoizedState=bP if bL.
baseQueue==nil then bL.baseState=bP end bM.lastRenderedState=bP end return bP,bN end function
readFromUnsubcribedMutableSource(bI,bJ,bK)if af then a8(bJ)end local bL=bJ._getVersion local bM,bN,bO=bL(bJ._source),
false,a9(bJ)if bO~=nil then bN=bO==bM else bN=aC(bh,bI.mutableReadLanes)if bN then b(bJ,bM)end end if bN then local bP=
bK(bJ._source)if af then if type(bP)=='function'then an.error
[[Mutable source should not return a function as the snapshot value. Functions may close over mutable values and cause tearing.]]
end end return bP else ba(bJ)error(aj.new
[[Cannot read from mutable source during the current render without tearing. This is a bug in React. Please file an issue.]]
)end end function useMutableSource(bI,bJ,bK,bL)local bM=aZ()a0(bM~=nil,
[[Expected a work-in-progress root. This is a bug in React. Please file an issue.]])local bN=bJ._getVersion local bO,bP=
bN(bJ._source),bd.current assert(bP~=nil,'dispatcher was nil, this is a bug in React')local bQ,bR=bP.useState(function()
return readFromUnsubcribedMutableSource(bM,bJ,bK)end)local bS,bT,bU=bQ,bp,bI.memoizedState if bU.refs==nil then error(
tostring(debug.traceback()))end local bV=bU.refs local bW,bX,bY,bZ=bV.getSnapshot,bU.source,bU.subscribe,bn bI.
memoizedState={refs=bV,source=bJ,subscribe=bL}bP.useEffect(function()bV.getSnapshot=bK bV.setSnapshot=bR local b_=bN(bJ.
_source)if not a2(bO,b_)then local b0=bK(bJ._source)if af then if type(b0)=='function'then an.error
[[Mutable source should not return a function as the snapshot value. Functions may close over mutable values and cause tearing.]]
end end if not a2(bS,b0)then bR(b0)local b1=aX(bZ)aG(bM,b1)end aF(bM,bM.mutableReadLanes)end end,{bK,bJ,bL})bP.
useEffect(function()local b_=function()local b_,b0=bV.getSnapshot,bV.setSnapshot local b1,b2=pcall(function()b0(b_(bJ.
_source))local b1=aX(bZ)aG(bM,b1)end)if not b1 then b0(function()error(b2)end)end end local b0=bL(bJ._source,b_)if af
then if type(b0)~='function'then an.error[[Mutable source subscribe function must return an unsubscribe function.]]end
end return b0 end,{bJ,bL})if not a2(bW,bK)or not a2(bX,bJ)or not a2(bY,bL)then local b_,b0={pending=nil,dispatch=nil,
lastRenderedReducer=basicStateReducer,lastRenderedState=bS},bn bR=function(...)dispatchAction(b0,b_,...)end b_.dispatch=
bR bT.queue=b_ bT.baseQueue=nil bS=readFromUnsubcribedMutableSource(bM,bJ,bK)bT.baseState=bS bT.memoizedState=bT.
baseState end return bS end function mountMutableSource(bI,bJ,bK)local bL=bG()bL.memoizedState={refs={getSnapshot=bJ,
setSnapshot=nil},source=bI,subscribe=bK}return useMutableSource(bL,bI,bJ,bK)end function updateMutableSource(bI,bJ,bK)
local bL=bH()return useMutableSource(bL,bI,bJ,bK)end function mountState(bI)local bJ=bG()if type(bI)=='function'then
local bK=bI bI=bK()end bJ.baseState=bI bJ.memoizedState=bJ.baseState local bK={pending=nil,dispatch=nil,
lastRenderedReducer=nil,lastRenderedState=bI}bK.lastRenderedReducer=basicStateReducer bJ.queue=bK local bL=bn local bM=
function(bM,...)dispatchAction(bL,bK,bM,...)end bK.dispatch=bM return bJ.memoizedState,bM end function updateState(bI)
return updateReducer(basicStateReducer,bI)end function rerenderState(bI)return rerenderReducer(basicStateReducer,bI)end
local function bI(bJ,bK,bL,bM)local bN,bO={tag=bJ,create=bK,destroy=bL,deps=bM,next=nil},bn.updateQueue if bO==nil then
bO={lastEffect=nil}bn.updateQueue=bO bN.next=bN bO.lastEffect=bN else local bP=bO.lastEffect if bP==nil then bO.
lastEffect=bN bN.next=bN else local bQ=bP.next bP.next=bN bN.next=bQ bO.lastEffect=bN end end return bN end function
mountBinding(bJ)local bK,bL,bM=bG(),am(bJ)bK.memoizedState={bL,bM}return bL,bM end function updateBinding(bJ)local bK=
bH()return unpack(bK.memoizedState)end function mountRef(bJ)local bK,bL=bG(),al()bL.current=bJ bK.memoizedState=bL
return bL end function updateRef(bJ)local bK=bH()return bK.memoizedState end local function bJ(bK,bL,bM,bN)local bO,bP=
bG(),bN bn.flags=bit32.bor(bn.flags,bK)bO.memoizedState=bI(bit32.bor(aP,bL),bM,nil,bP)end function updateEffectImpl(bK,
bL,bM,bN)local bO,bP,bQ=bH(),bN if bo~=nil then local bR=bo.memoizedState bQ=bR.destroy if bP~=nil then local bS=bR.deps
if bE(bP,bS)then bO.memoizedState=bI(bL,bM,bQ,bP)return end end end bn.flags=bit32.bor(bn.flags,bK)bO.memoizedState=bI(
bit32.bor(aP,bL),bM,bQ,bP)end local function bK(bL,bM)if af then if type(_G.jest)~='nil'or _G.__TESTEZ_RUNNING_TEST__
then a_(bn)end end if af and ax then bJ(bit32.bor(aO,aL,aM),aR,bL,bM)else bJ(bit32.bor(aL,aM),aR,bL,bM)end end
local function bL(bM,bN)if af then if type(_G.jest)~='nil'or _G.__TESTEZ_RUNNING_TEST__ then a_(bn)end end
updateEffectImpl(aL,aR,bM,bN)end local function bM(bN,bO)if af and ax then bJ(bit32.bor(aN,aK),aQ,bN,bO)else bJ(aK,aQ,bN
,bO)end end local function bN(bO,bP)updateEffectImpl(aK,aQ,bO,bP)end function imperativeHandleEffect(bO,bP)if bP~=nil
and type(bP)=='function'then local bQ,bR=bP,bO()bQ(bR)return function()return bQ(nil)end elseif bP~=nil then local bQ=bP
if af then local bR=getmetatable(bQ)~=nil and#ak.keys(bQ)==0 if not bR then an.error(
[[Expected useImperativeHandle() first argument to either be a ref callback or React.createRef() object. Instead received: %s.]]
,'an object with keys {'..ai.join(ak.keys(bQ),', ')..'}')end end local bR=bO()bQ.current=bR return function()bQ.current=
nil end else return nil end end function mountImperativeHandle(bO,bP,bQ)if af then if type(bP)~='function'then an.error(
[[Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: %s.]],if bP~=
nil then type(bP)else'nil')end end local bR=if bQ~=nil then ai.concat(bQ,{bO})else nil if af and ax then return bJ(bit32
.bor(aN,aK),aQ,function()return imperativeHandleEffect(bP,bO)end,bR)else return bJ(aK,aQ,function()return
imperativeHandleEffect(bP,bO)end,bR)end end function updateImperativeHandle(bO,bP,bQ)if af then if type(bP)~='function'
then local bR='nil'if bP then bR=type(bP)end an.error(
[[Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: %s.]],bR)end
end local bR if bQ~=nil then bR=table.clone(bQ)table.insert(bR,bO)end return updateEffectImpl(aK,aQ,function()return
imperativeHandleEffect(bP,bO)end,bR)end function mountDebugValue(bO,bP)end local bO=mountDebugValue function
mountCallback(bP,bQ)local bR,bS=bG(),bQ bR.memoizedState={bP,bS}return bP end function updateCallback(bP,bQ)local bR,bS=
bH(),bQ local bT=bR.memoizedState if bT~=nil then if bS~=nil then local bU=bT[2]if bE(bS,bU)then return bT[1]end end end
bR.memoizedState={bP,bS}return bP end function mountMemo(bP,bQ)local bR,bS,bT=bG(),bQ,{bP()}bR.memoizedState={bT,bS}
return unpack(bT)end function updateMemo(bP,bQ)local bR,bS=bH(),bQ local bT=bR.memoizedState if bT~=nil then if bS~=nil
then local bU=bT[2]if bE(bS,bU)then return unpack(bT[1])end end end local bU={bP()}bR.memoizedState={bU,bS}return
unpack(bU)end local bP=false bg.getIsUpdatingOpaqueValueInRenderPhaseInDEV=function()if af then return bP end return nil
end function mountOpaqueIdentifier()local bQ if af then an.warn'!!! unimplemented: warnOnOpaqueIdentifierAccessInDEV'
else bQ=a6 end if a4()then ae'ReactFiberHooks: getIsHydrating() true'return nil else local bR=bQ()mountState(bR)return
bR end end function updateOpaqueIdentifier()local bQ,bR=updateState(nil)return bQ end function rerenderOpaqueIdentifier(
)local bQ,bR=rerenderState(nil)return bQ end function dispatchAction(bQ,bR,bS,...)if af then local bT,bU=(select('#',...
))if bT==1 then bU=select(1,...)end if type(bU)=='function'then an.error
[[State updates from the useState() and useReducer() Hooks don't support the second callback argument. To execute a side effect after rendering, declare it in the component body with useEffect().]]
end end local bT,bU=aW(),aX(bQ)local bV,bW={lane=bU,action=bS,eagerReducer=nil,eagerState=nil,next=nil},bR.pending if bW
==nil then bV.next=bV else bV.next=bW.next bW.next=bV end bR.pending=bV local bX=bQ.alternate if bQ==bn or(bX~=nil and
bX==bn)then bi=true bj=true else if bQ.lanes==aB and(bX==nil or bX.lanes==aB)then local bY=bR.lastRenderedReducer if bY
~=nil then local bZ if af then bZ=bd.current bd.current=bx end local b_=bR.lastRenderedState local b0,b1=pcall(bY,b_,bS)
if b0 then bV.eagerReducer=bY bV.eagerState=b1 end if af then bd.current=bZ end if a2(b1,b_)then return end if not b0
then end end end if af then if type(_G.jest)~='nil'or _G.__TESTEZ_RUNNING_TEST__ then aV(bQ)aT(bQ)end end aU(bQ,bU,bT)
end if af then if au then if bit32.band(bQ.mode,az)~=0 then local bY=a1(bQ.type)or'Unknown'bb(bY,bU,bS)end end end if av
then bc(bQ,bU)end return end local bQ={readContext=aI,useCallback=bD,useContext=bD,useEffect=bD,useImperativeHandle=bD,
useLayoutEffect=bD,useMemo=bD,useReducer=bD,useRef=bD,useBinding=bD,useState=bD,useDebugValue=bD,useMutableSource=bD,
useOpaqueIdentifier=bD,unstable_isNewReconciler=aw}bg.ContextOnlyDispatcher=bQ local bR,bS,bT={readContext=aI,
useCallback=mountCallback,useContext=aI,useEffect=bK,useImperativeHandle=mountImperativeHandle,useLayoutEffect=bM,
useMemo=mountMemo,useReducer=mountReducer,useRef=mountRef,useBinding=mountBinding,useState=mountState,useDebugValue=
mountDebugValue,useMutableSource=mountMutableSource,useOpaqueIdentifier=mountOpaqueIdentifier,unstable_isNewReconciler=
aw},{readContext=aI,useCallback=updateCallback,useContext=aI,useEffect=bL,useImperativeHandle=updateImperativeHandle,
useLayoutEffect=bN,useMemo=updateMemo,useReducer=updateReducer,useRef=updateRef,useBinding=updateBinding,useState=
updateState,useDebugValue=bO,useMutableSource=updateMutableSource,useOpaqueIdentifier=updateOpaqueIdentifier,
unstable_isNewReconciler=aw},{readContext=aI,useCallback=updateCallback,useContext=aI,useEffect=bL,useImperativeHandle=
updateImperativeHandle,useLayoutEffect=bN,useMemo=updateMemo,useReducer=rerenderReducer,useRef=updateRef,useBinding=
updateBinding,useState=rerenderState,useDebugValue=bO,useMutableSource=updateMutableSource,useOpaqueIdentifier=
rerenderOpaqueIdentifier,unstable_isNewReconciler=aw}if af then local bU,bV=function()an.error
[[Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().]]
end,function()an.error
[[Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. You can only call Hooks at the top level of your React function. For more information, see https://reactjs.org/link/rules-of-hooks]]
end bs={readContext=function(bW,bX)return aI(bW,bX)end,useCallback=function(bW,bX)bq='useCallback'bB()bC(bX)return
mountCallback(bW,bX)end,useContext=function(bW,bX)bq='useContext'bB()return aI(bW,bX)end,useEffect=function(bW,bX)bq=
'useEffect'bB()bC(bX)return bK(bW,bX)end,useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'bB()bC(bY)return
mountImperativeHandle(bW,bX,bY)end,useLayoutEffect=function(bW,bX)bq='useLayoutEffect'bB()bC(bX)return bM(bW,bX)end,
useMemo=function(bW,bX)bq='useMemo'bB()bC(bX)local bY=bd.current bd.current=bw local bZ={pcall(mountMemo,bW,bX)}bd.
current=bY if not bZ[1]then error(bZ[2])end return unpack(bZ,2)end,useReducer=function(bW,bX,bY)bq='useReducer'bB()local
bZ=bd.current bd.current=bw local b_,b0,b1=pcall(mountReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return
b0,b1 end,useRef=function(bW)bq='useRef'bB()return mountRef(bW)end,useBinding=function(bW)bq='useBinding'bB()return
mountBinding(bW)end,useState=function(bW)bq='useState'bB()local bX=bd.current bd.current=bw local bY,bZ,b_=pcall(
mountState,bW)bd.current=bX if not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)bq='useDebugValue'
bB()return mountDebugValue(bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'bB()return
mountMutableSource(bW,bX,bY)end,useOpaqueIdentifier=function()bq='useOpaqueIdentifier'bB()return mountOpaqueIdentifier()
end,unstable_isNewReconciler=aw}bt={readContext=function(bW,bX)return aI(bW,bX)end,useCallback=function(bW,bX)bq=
'useCallback'updateHookTypesDev()bC(bX)return mountCallback(bW,bX)end,useContext=function(bW,bX)bq='useContext'
updateHookTypesDev()return aI(bW,bX)end,useEffect=function(bW,bX)bq='useEffect'updateHookTypesDev()return bK(bW,bX)end,
useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'updateHookTypesDev()return mountImperativeHandle(bW,bX,bY)
end,useLayoutEffect=function(bW,bX)bq='useLayoutEffect'updateHookTypesDev()return bM(bW,bX)end,useMemo=function(bW,bX)bq
='useMemo'updateHookTypesDev()local bY=bd.current bd.current=bw local bZ={pcall(mountMemo,bW,bX)}bd.current=bY if not bZ
[1]then error(bZ[2])end return unpack(bZ,2)end,useReducer=function(bW,bX,bY)bq='useReducer'updateHookTypesDev()local bZ=
bd.current bd.current=bw local b_,b0,b1=pcall(mountReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return b0,
b1 end,useRef=function(bW)bq='useRef'updateHookTypesDev()return mountRef(bW)end,useBinding=function(bW)bq='useBinding'
updateHookTypesDev()return mountBinding(bW)end,useState=function(bW)bq='useState'updateHookTypesDev()local bX=bd.current
bd.current=bw local bY,bZ,b_=pcall(mountState,bW)bd.current=bX if not bY then error(bZ)end return bZ,b_ end,
useDebugValue=function(bW,bX)bq='useDebugValue'updateHookTypesDev()return mountDebugValue(bW,bX)end,useMutableSource=
function(bW,bX,bY)bq='useMutableSource'updateHookTypesDev()return mountMutableSource(bW,bX,bY)end,useOpaqueIdentifier=
function()bq='useOpaqueIdentifier'updateHookTypesDev()return mountOpaqueIdentifier()end,unstable_isNewReconciler=aw}bu={
readContext=function(bW,bX)return aI(bW,bX)end,useCallback=function(bW,bX)bq='useCallback'updateHookTypesDev()return
updateCallback(bW,bX)end,useContext=function(bW,bX)bq='useContext'updateHookTypesDev()return aI(bW,bX)end,useEffect=
function(bW,bX)bq='useEffect'updateHookTypesDev()return bL(bW,bX)end,useImperativeHandle=function(bW,bX,bY)bq=
'useImperativeHandle'updateHookTypesDev()return updateImperativeHandle(bW,bX,bY)end,useLayoutEffect=function(bW,bX)bq=
'useLayoutEffect'updateHookTypesDev()return bN(bW,bX)end,useMemo=function(bW,bX)bq='useMemo'updateHookTypesDev()local bY
=bd.current bd.current=bx local bZ={pcall(updateMemo,bW,bX)}bd.current=bY if not bZ[1]then error(bZ[2])end return
unpack(bZ,2)end,useReducer=function(bW,bX,bY)bq='useReducer'updateHookTypesDev()local bZ=bd.current bd.current=bx local
b_,b0,b1=pcall(updateReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return b0,b1 end,useRef=function(bW)bq=
'useRef'updateHookTypesDev()return updateRef(bW)end,useBinding=function(bW)bq='useBinding'updateHookTypesDev()return
updateBinding(bW)end,useState=function(bW)bq='useState'updateHookTypesDev()local bX=bd.current bd.current=bx local bY,bZ
,b_=pcall(updateState,bW)bd.current=bX if not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)bq=
'useDebugValue'updateHookTypesDev()return bO(bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'
updateHookTypesDev()return updateMutableSource(bW,bX,bY)end,useOpaqueIdentifier=function()bq='useOpaqueIdentifier'
updateHookTypesDev()return updateOpaqueIdentifier()end,unstable_isNewReconciler=aw}bv={readContext=function(bW,bX)return
aI(bW,bX)end,useCallback=function(bW,bX)bq='useCallback'updateHookTypesDev()return mountCallback(bW,bX)end,useContext=
function(bW,bX)bq='useContext'updateHookTypesDev()return aI(bW,bX)end,useEffect=function(bW,bX)bq='useEffect'
updateHookTypesDev()return bL(bW,bX)end,useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'
updateHookTypesDev()return updateImperativeHandle(bW,bX,bY)end,useLayoutEffect=function(bW,bX)bq='useLayoutEffect'
updateHookTypesDev()return bN(bW,bX)end,useMemo=function(bW,bX)bq='useMemo'updateHookTypesDev()local bY=bd.current bd.
current=by local bZ={pcall(updateMemo,bW,bX)}bd.current=bY if not bZ[1]then error(bZ[2])end return unpack(bZ,2)end,
useReducer=function(bW,bX,bY)bq='useReducer'updateHookTypesDev()local bZ=bd.current bd.current=by local b_,b0,b1=pcall(
rerenderReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return b0,b1 end,useRef=function(bW)bq='useRef'
updateHookTypesDev()return updateRef(bW)end,useBinding=function(bW)bq='useBinding'updateHookTypesDev()return
updateBinding(bW)end,useState=function(bW)bq='useState'updateHookTypesDev()local bX=bd.current bd.current=by local bY,bZ
,b_=pcall(rerenderState,bW)bd.current=bX if not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)bq=
'useDebugValue'updateHookTypesDev()return bO(bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'
updateHookTypesDev()return updateMutableSource(bW,bX,bY)end,useOpaqueIdentifier=function()bq='useOpaqueIdentifier'
updateHookTypesDev()return rerenderOpaqueIdentifier()end,unstable_isNewReconciler=aw}bw={readContext=function(bW,bX)bU()
return aI(bW,bX)end,useCallback=function(bW,bX)bq='useCallback'bV()bB()return mountCallback(bW,bX)end,useContext=
function(bW,bX)bq='useContext'bV()bB()return aI(bW,bX)end,useEffect=function(bW,bX)bq='useEffect'bV()bB()return bK(bW,bX
)end,useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'bV()bB()return mountImperativeHandle(bW,bX,bY)end,
useLayoutEffect=function(bW,bX)bq='useLayoutEffect'bV()bB()return bM(bW,bX)end,useMemo=function(bW,bX)bq='useMemo'bV()
bB()local bY=bd.current bd.current=bw local bZ={pcall(mountMemo,bW,bX)}bd.current=bY if not bZ[1]then error(bZ[2])end
return unpack(bZ,2)end,useReducer=function(bW,bX,bY)bq='useReducer'bV()bB()local bZ=bd.current bd.current=bw local b_,b0
,b1=pcall(mountReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return b0,b1 end,useRef=function(bW)bq=
'useRef'bV()bB()return mountRef(bW)end,useBinding=function(bW)bq='useBinding'bV()bB()return mountBinding(bW)end,useState
=function(bW)bq='useState'bV()bB()local bX=bd.current bd.current=bw local bY,bZ,b_=pcall(mountState,bW)bd.current=bX if
not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)bq='useDebugValue'bV()bB()return mountDebugValue(
bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'bV()bB()return mountMutableSource(bW,bX,bY)end,
useOpaqueIdentifier=function()bq='useOpaqueIdentifier'bV()bB()return mountOpaqueIdentifier()end,unstable_isNewReconciler
=aw}bx={readContext=function(bW,bX)bU()return aI(bW,bX)end,useCallback=function(bW,bX)bq='useCallback'bV()
updateHookTypesDev()return mountCallback(bW,bX)end,useContext=function(bW,bX)bq='useContext'bV()updateHookTypesDev()
return aI(bW,bX)end,useEffect=function(bW,bX)bq='useEffect'bV()updateHookTypesDev()return bL(bW,bX)end,
useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'bV()updateHookTypesDev()return updateImperativeHandle(bW,
bX,bY)end,useLayoutEffect=function(bW,bX)bq='useLayoutEffect'bV()updateHookTypesDev()return bN(bW,bX)end,useMemo=
function(bW,bX)bq='useMemo'bV()updateHookTypesDev()local bY=bd.current bd.current=bx local bZ={pcall(updateMemo,bW,bX)}
bd.current=bY if not bZ[1]then error(bZ[2])end return unpack(bZ,2)end,useReducer=function(bW,bX,bY)bq='useReducer'bV()
updateHookTypesDev()local bZ=bd.current bd.current=bx local b_,b0,b1=pcall(updateReducer,bW,bX,bY)bd.current=bZ if not
b_ then error(b0)end return b0,b1 end,useRef=function(bW)bq='useRef'bV()updateHookTypesDev()return updateRef(bW)end,
useBinding=function(bW)bq='useBinding'bV()updateHookTypesDev()return updateBinding(bW)end,useState=function(bW)bq=
'useState'bV()updateHookTypesDev()local bX=bd.current bd.current=bx local bY,bZ,b_=pcall(updateState,bW)bd.current=bX if
not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)bq='useDebugValue'bV()updateHookTypesDev()return
bO(bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'bV()updateHookTypesDev()return updateMutableSource(
bW,bX,bY)end,useOpaqueIdentifier=function()bq='useOpaqueIdentifier'bV()updateHookTypesDev()return
updateOpaqueIdentifier()end,unstable_isNewReconciler=aw}by={readContext=function(bW,bX)bU()return aI(bW,bX)end,
useCallback=function(bW,bX)bq='useCallback'bV()updateHookTypesDev()return updateCallback(bW,bX)end,useContext=function(
bW,bX)bq='useContext'bV()updateHookTypesDev()return aI(bW,bX)end,useEffect=function(bW,bX)bq='useEffect'bV()
updateHookTypesDev()return bL(bW,bX)end,useImperativeHandle=function(bW,bX,bY)bq='useImperativeHandle'bV()
updateHookTypesDev()return updateImperativeHandle(bW,bX,bY)end,useLayoutEffect=function(bW,bX)bq='useLayoutEffect'bV()
updateHookTypesDev()return bN(bW,bX)end,useMemo=function(bW,bX)bq='useMemo'bV()updateHookTypesDev()local bY=bd.current
bd.current=bx local bZ={pcall(updateMemo,bW,bX)}bd.current=bY if not bZ[1]then error(bZ[2])end return unpack(bZ,2)end,
useReducer=function(bW,bX,bY)bq='useReducer'bV()updateHookTypesDev()local bZ=bd.current bd.current=bx local b_,b0,b1=
pcall(rerenderReducer,bW,bX,bY)bd.current=bZ if not b_ then error(b0)end return b0,b1 end,useRef=function(bW)bq='useRef'
bV()updateHookTypesDev()return updateRef(bW)end,useBinding=function(bW)bq='useBinding'bV()updateHookTypesDev()return
updateBinding(bW)end,useState=function(bW)bq='useState'bV()updateHookTypesDev()local bX=bd.current bd.current=bx local
bY,bZ,b_=pcall(rerenderState,bW)bd.current=bX if not bY then error(bZ)end return bZ,b_ end,useDebugValue=function(bW,bX)
bq='useDebugValue'bV()updateHookTypesDev()return bO(bW,bX)end,useMutableSource=function(bW,bX,bY)bq='useMutableSource'
bV()updateHookTypesDev()return updateMutableSource(bW,bX,bY)end,useOpaqueIdentifier=function()bq='useOpaqueIdentifier'
bV()updateHookTypesDev()return rerenderOpaqueIdentifier()end,unstable_isNewReconciler=aw}end local function bU(bV,bW,bX,
bY,bZ,b_)bh=b_ bn=bW if af then br=if bV~=nil then(bV._debugHookTypes)else nil bl=0 end bW.memoizedState=nil bW.
updateQueue=nil bW.lanes=aB if af then if bV~=nil and bV.memoizedState~=nil then bd.current=bu elseif br~=nil then bd.
current=bt else bd.current=bs end else bd.current=(bV==nil or bV.memoizedState==nil)and bR or bS end local b0=bX(bY,bZ)
if bj then local b1=0 repeat bj=false if b1>=bk then error(aj.new
[[Too many re-renders. React limits the number of renders to prevent an infinite loop.]])end b1+=1 bo=nil bp=nil bW.
updateQueue=nil if af then bl=0 end bd.current=af and bv or bT b0=bX(bY,bZ)until not bj end bd.current=bQ if af then bW.
_debugHookTypes=br end local b1=bo~=nil and bo.next~=nil bh=aB bn=nil bo=nil bp=nil if af then bq=nil br=nil bl=0 end bi
=false if b1 then error(aj.new
[[Rendered fewer hooks than expected. This may be caused by an accidental early return statement.]])end return b0 end bg
.renderWithHooks=bU return bg end)()end,[83]=function()local aa,ab,ac=a(83)local ad return(function(...)local ae={}
return ae end)()end,[84]=function()local aa,ab,ac=a(84)local ad return(function(...)local ae=ac(ab.Parent.
ReactInternalTypes)local af=ac(ab.Parent['ReactFiberStack.new'])local ag=ac(ab.Parent.ReactFiberHostConfig)local ah,ai,
aj,ak,al=ag.getChildHostContext,ag.getRootHostContext,af.createCursor,af.push,af.pop local am={}local an,ao,ap=aj(am),
aj(am),aj(am)function requiredContext(aq)return aq end function getRootHostContainer()return ap.current end function
pushHostContainer(aq,ar)ak(ap,ar,aq)ak(ao,aq,aq)ak(an,am,aq)local as=ai(ar)al(an,aq)ak(an,as,aq)end function
popHostContainer(aq)al(an,aq)al(ao,aq)al(ap,aq)end function getHostContext()return an.current end function
pushHostContext(aq)local ar,as=requiredContext(ap.current),requiredContext(an.current)local at=ah(as,aq.type,ar)if as==
at then return end ak(ao,aq,aq)ak(an,at,aq)end function popHostContext(aq)if ao.current~=aq then return end al(an,aq)al(
ao,aq)end return{getHostContext=getHostContext,getRootHostContainer=getRootHostContainer,popHostContainer=
popHostContainer,popHostContext=popHostContext,pushHostContainer=pushHostContainer,pushHostContext=pushHostContext}end)(
)end,[85]=function()local aa,ab,ac=a(85)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.Shared)
local ag=ac(ab.Parent.ReactInternalTypes)local ah=ac(ae.Shared).ReactSymbols local ai=ah.REACT_FORWARD_REF_TYPE local aj
,ak,al={}local function am(an)if _G.__DEV__ then if ak==nil then return an end local ao=ak(an)if ao==nil then return an
end return ao.current else return an end end aj.resolveFunctionForHotReloading=am local function an(ao)return am(ao)end
aj.resolveClassForHotReloading=an local function ao(ap)if _G.__DEV__ then if ak==nil then return ap end local aq=ak(ap)
if aq==nil then if ap~=nil and typeof(ap.render)=='function'then local ar=am(ap.render)if ap.render~=ar then local as={[
'$$typeof']=ai,render=ar,displayName=nil}if ap.displayName~=nil then as.displayName=ap.displayName end return as end end
return ap end return aq.current else return ap end end aj.resolveForwardRefForHotReloading=ao aj.
isCompatibleFamilyForHotReloading=function(ap,aq)warn[[isCompatibleFamilyForHotReloading is stubbed (returns false)]]
return false end aj.markFailedErrorBoundaryForHotReloading=function(ap)if _G.__DEV__ then if ak==nil then return end if
al==nil then al={}end table.insert(al,ap)end end return aj end)()end,[86]=function()local aa,ab,ac=a(86)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.Shared).console local function ag(ah)print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print(
'UNIMPLEMENTED ERROR: '..ah)error('FIXME (roblox): '..ah..' is unimplemented',2)end local ah=ac(ab.Parent.
ReactInternalTypes)local ai=ac(ab.Parent.ReactFiberHostConfig)local aj=ac(ab.Parent['ReactFiberSuspenseComponent.new'])
local ak=ac(ab.Parent.ReactWorkTags)local al,am,an,ao,ap=ak.HostComponent,ak.HostText,ak.HostRoot,ak.SuspenseComponent,
ac(ab.Parent.ReactFiberFlags)local aq,ar,as,at=ap.Placement,ap.Hydrating,ac(ae.Shared).invariant,ac(ab.Parent[
'ReactFiber.new'])local au,av,aw,ax,az,aA,aB,aC,aD,aE,aF,aG,aH,aI,aJ,aK,aL,aM,aN=at.createFiberFromDehydratedFragment,ai
.supportsHydration,ai.getNextHydratableSibling,ai.getFirstHydratableChild,ai.canHydrateInstance,ai.
canHydrateTextInstance,ai.canHydrateSuspenseInstance,ai.hydrateInstance,ai.hydrateTextInstance,ai.
hydrateSuspenseInstance,ai.getNextHydratableInstanceAfterSuspenseInstance,ai.didNotMatchHydratedContainerTextInstance,ai
.didNotMatchHydratedTextInstance,ai.shouldSetTextContent,ac(ae.Shared).ReactFeatureFlags.enableSuspenseServerRenderer,
ac(ab.Parent.ReactFiberLane).OffscreenLane,false function warnIfHydrating()if _G.__DEV__ then if aL then af.error
[[We should not be hydrating here. This is a bug in React. Please file a bug.]]end end end function enterHydrationState(
aO)if not av then return false end local aP=aO.stateNode.containerInfo aN=ax(aP)aM=aO aL=true return true end function
reenterHydrationStateFromDehydratedSuspenseInstance(aO,aP)if not av then return false end aN=aw(aP)popToNextHostParent(
aO)aL=true return true end function deleteHydratableInstance(aO,aP)ag'deleteHydratableInstance'end function
insertNonHydratedInstance(aO,aP)ag'insertNonHydratedInstance'aP.flags=bit32.bor(bit32.band(aP.flags,bit32.bnot(ar)),aq)
if _G.__DEV__ then end end function tryHydrate(aO,aP)if aO.tag==al then local aQ,aR=aO.type,aO.pendingProps local aS=az(
aP,aQ,aR)if aS~=nil then aO.stateNode=aS return true end return false elseif aO.tag==am then local aQ=aO.pendingProps
local aR=aA(aP,aQ)if aR~=nil then aO.stateNode=aR return true end return false elseif aO.tag==ao then if aJ then local
aQ=aB(aP)if aQ~=nil then local aR={dehydrated=aQ,retryLane=aK}aO.memoizedState=aR local aS=au(aQ)aS.return_=aO aO.child=
aS return true end end return false else return false end end function tryToClaimNextHydratableInstance(aO)if not aL
then return end local aP=aN if not aP then insertNonHydratedInstance(aM,aO)aL=false aM=aO return end local aQ=aP if not
tryHydrate(aO,aP)then aP=aw(aQ)if not aP or not tryHydrate(aO,aP)then insertNonHydratedInstance(aM,aO)aL=false aM=aO
return end deleteHydratableInstance(aM,aQ)end aM=aO aN=ax(aP)end function prepareToHydrateHostInstance(aO,aP,aQ)if not
av then as(false,
[[Expected prepareToHydrateHostInstance() to never be called. This error is likely caused by a bug in React. Please file an issue.]]
)end local aR=aO.stateNode local aS=aC(aR,aO.type,aO.memoizedProps,aP,aQ,aO)aO.updateQueue=aS if aS~=nil then return
true end return false end function prepareToHydrateHostTextInstance(aO)if not av then as(false,
[[Expected prepareToHydrateHostTextInstance() to never be called. This error is likely caused by a bug in React. Please file an issue.]]
)end local aP,aQ=aO.stateNode,aO.memoizedProps local aR=aD(aP,aQ,aO)if _G.__DEV__ then if aR then local aS=aM if aS~=nil
then if aS.tag==an then local aT=aS.stateNode.containerInfo aG(aT,aP,aQ)elseif aS.tag==al then local aT,aU,aV=aS.type,aS
.memoizedProps,aS.stateNode aH(aT,aU,aV,aP,aQ)end end end end return aR end function
prepareToHydrateHostSuspenseInstance(aO)if not av then as(false,
[[Expected prepareToHydrateHostSuspenseInstance() to never be called. This error is likely caused by a bug in React. Please file an issue.]]
)end local aP,aQ=(aO.memoizedState)if aP~=nil then aQ=aP.dehydrated else aQ=nil end as(aQ,
[[Expected to have a hydrated suspense instance. This error is likely caused by a bug in React. Please file an issue.]])
aE(aQ,aO)end function skipPastDehydratedSuspenseInstance(aO)if not av then as(false,
[[Expected skipPastDehydratedSuspenseInstance() to never be called. This error is likely caused by a bug in React. Please file an issue.]]
)end local aP,aQ=(aO.memoizedState)if aP~=nil then aQ=aP.dehydrated else aQ=nil end as(aQ,
[[Expected to have a hydrated suspense instance. This error is likely caused by a bug in React. Please file an issue.]])
return aF(aQ)end function popToNextHostParent(aO)local aP=aO.return_ while aP~=nil and aP.tag~=al and aP.tag~=an and aP.
tag~=ao do aP=aP.return_ end aM=aP end function popHydrationState(aO)if not av then return false end if aO~=aM then
return false end if not aL then popToNextHostParent(aO)aL=true return false end local aP=aO.type if aO.tag~=al or(aP~=
'head'and aP~='body'and not aI(aP,aO.memoizedProps))then local aQ=aN while aQ do deleteHydratableInstance(aO,aQ)aQ=aw(aQ
)end end popToNextHostParent(aO)if aO.tag==ao then aN=skipPastDehydratedSuspenseInstance(aO)else if aM then aN=aw(aO.
stateNode)else aN=nil end end return true end function resetHydrationState()if not av then return end aM=nil aN=nil aL=
false end function getIsHydrating()return aL end return{warnIfHydrating=warnIfHydrating,enterHydrationState=
enterHydrationState,getIsHydrating=getIsHydrating,reenterHydrationStateFromDehydratedSuspenseInstance=
reenterHydrationStateFromDehydratedSuspenseInstance,resetHydrationState=resetHydrationState,
tryToClaimNextHydratableInstance=tryToClaimNextHydratableInstance,prepareToHydrateHostInstance=
prepareToHydrateHostInstance,prepareToHydrateHostTextInstance=prepareToHydrateHostTextInstance,
prepareToHydrateHostSuspenseInstance=prepareToHydrateHostSuspenseInstance,popHydrationState=popHydrationState}end)()end,
[87]=function()local aa,ab,ac=a(87)local ad return(function(...)local ae,af=ab.Parent.Parent,ac(ab.Parent.
ReactInternalTypes)local ag,ah=ac(ae.Shared).console,ac(ab.Parent['ReactFiberSchedulerPriorities.roblox'])local ai,aj,ak
,al,am,an,ao,ap,aq=ac(ae.Shared).invariant,ah.ImmediatePriority,ah.UserBlockingPriority,ah.NormalPriority,ah.LowPriority
,ah.IdlePriority,ah.NoPriority,{},15 ap.SyncLanePriority=aq local ar=14 ap.SyncBatchedLanePriority=ar local as,at=13,12
ap.InputDiscreteLanePriority=at local au,av=11,10 ap.InputContinuousLanePriority=av local aw,ax=9,8 ap.
DefaultLanePriority=ax local az,aA=7,6 ap.TransitionPriority=aA local aB,aC,aD,aE,aF,aG=5,4,3,2,1,0 ap.NoLanePriority=aG
local aH=0b0 ap.NoLanes=aH local aI=0b0 ap.NoLane=aI local aJ=0b1 ap.SyncLane=aJ local aK=0b10 ap.SyncBatchedLane=aK
local aL=0b100 ap.InputDiscreteHydrationLane=aL local aM,aN,aO,aP=0b11000,0b100000,0b11000000,0b100000000 ap.
DefaultHydrationLane=aP local aQ=0b111000000000 ap.DefaultLanes=aQ local aR,aS,aT=0b1000000000000,
0b1111111110000000000000,0b11110000000000000000000000 ap.RetryLanes=aT local aU=0b10000000000000000000000000 ap.
SomeRetryLane=aU local aV=0b100000000000000000000000000 ap.SelectiveHydrationLane=aV local aW,aX=
0b111111111111111111111111111,0b1000000000000000000000000000 ap.IdleHydrationLane=aX local aY,aZ=
0b110000000000000000000000000000,0b1000000000000000000000000000000 ap.OffscreenLane=aZ local a_=-1 ap.NoTimestamp=a_
local a0=ap.NoLanePriority ap.getCurrentUpdateLanePriority=function()return a0 end ap.setCurrentUpdateLanePriority=
function(a1)a0=a1 end local a1=ap.DefaultLanePriority local function a2(a3)if bit32.band(aJ,a3)~=aH then a1=aq return aJ
end if bit32.band(aK,a3)~=aH then a1=ar return aK end if bit32.band(aL,a3)~=aH then a1=as return aL end local a4=bit32.
band(aM,a3)if a4~=aH then a1=at return a4 end if bit32.band(a3,aN)~=aH then a1=au return aN end local a5=bit32.band(aO,
a3)if a5~=aH then a1=av return a5 end if bit32.band(a3,aP)~=aH then a1=aw return aP end local a6=bit32.band(aQ,a3)if a6
~=aH then a1=ax return a6 end if bit32.band(a3,aR)~=aH then a1=az return aR end local a7=bit32.band(aS,a3)if a7~=aH then
a1=aA return a7 end local a8=bit32.band(aT,a3)if a8~=aH then a1=aB return a8 end if bit32.band(a3,aV)~=0 then a1=aC
return aV end if bit32.band(a3,aX)~=aH then a1=aD return aX end local a9=bit32.band(aY,a3)if a9~=aH then a1=aE return a9
end if bit32.band(aZ,a3)~=aH then a1=aF return aZ end if _G.__DEV__ then ag.error
'Should have found matching lanes. This is a bug in React.'end a1=ax return a3 end local function a3(a4)if a4==aj then
return aq elseif a4==ak then return av elseif a4==al or a4==am then return ax elseif a4==an then return aE else return
aG end end ap.schedulerPriorityToLanePriority=a3 local function a4(a5)if a5==aq or a5==ar then return aj elseif a5==as
or a5==at or a5==au or a5==av then return ak elseif a5==aw or a5==ax or a5==az or a5==aA or a5==aC or a5==aB then return
al elseif a5==aD or a5==aE or a5==aF then return an elseif a5==aG then return ao else ai(false,
'Invalid update priority: %s. This is a bug in React.',a5)error'unreachable'end end ap.lanePriorityToSchedulerPriority=
a4 local a5,a6,a7 local function a8(a9,b)local ba=a9.pendingLanes if ba==aH then a1=aG return aH end local bb,bc,bd,be,
bf=aH,aG,a9.expiredLanes,a9.suspendedLanes,a9.pingedLanes if bd~=aH then bb=bd a1=aq bc=aq else local bg=bit32.band(ba,
aW)if bg~=aH then local bh=bit32.band(bg,bit32.bnot(be))if bh~=aH then bb=a2(bh)bc=a1 else local bi=bit32.band(bg,bf)if
bi~=aH then bb=a2(bi)bc=a1 end end else local bh=bit32.band(ba,bit32.bnot(be))if bh~=aH then bb=a2(bh)bc=a1 else if bf~=
aH then bb=a2(bf)bc=a1 end end end end if bb==aH then return aH end bb=bit32.band(ba,bit32.lshift(a6(bb),1)-1)if b~=aH
and b~=bb and bit32.band(b,be)==aH then a2(b)local bg=a1 if bc<=bg then return b else a1=bc end end local bg=a9.
entangledLanes if bg~=aH then local bh,bi=a9.entanglements,bit32.band(bb,bg)while bi>0 do local bj=a5(bi)local bk=bit32.
lshift(1,bj)bb=bit32.bor(bb,bh[bj])bi=bit32.band(bi,bit32.bnot(bk))end end return bb end ap.getNextLanes=a8
local function a9(b,ba)local bb,bc=b.eventTimes,a_ while ba>0 do local bd=a5(ba)local be,bf=bit32.lshift(1,bd),bb[bd]if
bf>bc then bc=bf end ba=bit32.band(ba,bit32.bnot(be))end return bc end ap.getMostRecentEventTime=a9 local function b(ba,
bb)a2(ba)local bc=a1 if bc>=av then return bb+250 elseif bc>=aA then return bb+5000 else return a_ end end ap.
computeExpirationTime=b local function ba(bb,bc)local bd,be,bf,bg=bb.pendingLanes,bb.suspendedLanes,bb.pingedLanes,bb.
expirationTimes local bh=bd while bh>0 do local bi=a5(bh)local bj,bk=bit32.lshift(1,bi),bg[bi]if bk==a_ then if bit32.
band(bj,be)==aH or bit32.band(bj,bf)~=aH then bg[bi]=b(bj,bc)end elseif bk<=bc then bb.expiredLanes=bit32.bor(bb.
expiredLanes,bj)end bh=bit32.band(bh,bit32.bnot(bj))end end ap.markStarvedLanesAsExpired=ba local function bb(bc)return
a2(bc.pendingLanes)end ap.getHighestPriorityPendingLanes=bb local function bc(bd)local be=bit32.band(bd.pendingLanes,
bit32.bnot(aZ))if be~=aH then return be end if bit32.band(be,aZ)~=0 then return aZ end return aH end ap.
getLanesToRetrySynchronouslyOnError=bc local function bd()return a1 end ap.returnNextLanesPriority=bd local function be(
bf)return bit32.band(bf,aW)~=aH end ap.includesNonIdleWork=be local function bf(bg)return bit32.band(bg,aT)==bg end ap.
includesOnlyRetries=bf local function bg(bh)return bit32.band(bh,aS)==bh end ap.includesOnlyTransitions=bg local bh
local function bi(bj,bk)if bj==aG then elseif bj==aq then return aJ elseif bj==ar then return aK elseif bj==at then
local bl=bh(bit32.band(aM,bit32.bnot(bk)))if bl==aI then return bi(av,bk)end return bl elseif bj==av then local bl=bh(
bit32.band(aO,bit32.bnot(bk)))if bl==aI then return bi(ax,bk)end return bl elseif bj==ax then local bl=bh(bit32.band(aQ,
bit32.bnot(bk)))if bl==aI then bl=bh(bit32.band(aS,bit32.bnot(bk)))if bl==aI then bl=bh(aQ)end end return bl elseif bj==
aA or bj==aB then elseif bj==aE then local bl=bh(bit32.band(aY,bit32.bnot(bk)))if bl==aI then bl=bh(aY)end return bl end
ai(false,'Invalid update priority: %s. This is a bug in React.',bj)error'unreachable'end ap.findUpdateLane=bi
local function bj(bk,bl)local bm=bh(bit32.band(aS,bit32.bnot(bl)))if bm==aI then bm=bh(bit32.band(aS,bit32.bnot(bk)))if
bm==aI then bm=bh(aS)end end return bm end ap.findTransitionLane=bj local function bk(bl)local bm=bh(bit32.band(aT,bit32
.bnot(bl)))if bm==aI then bm=bh(aT)end return bm end ap.findRetryLane=bk local function bl(bm)return bit32.band(bm,-bm)
end function a6(bm)local bn=31-bit32.countlz(bm)if bn<0 then return aH else return bit32.lshift(1,bn)end end function a7
(bm)return bit32.lshift(a6(bm),1)-1 end function bh(bm)return bl(bm)end ap.pickArbitraryLane=bh function a5(bm)return 31
-bit32.countlz(bm)end local function bm(bn,bo)return bit32.band(bn,bo)~=aH end ap.includesSomeLane=bm local function bn(
bo,bp)return bit32.band(bo,bp)==bp end ap.isSubsetOfLanes=bn local function bo(bp,bq)return bit32.bor(bp,bq)end ap.
mergeLanes=bo local function bp(bq,br)return bit32.band(bq,bit32.bnot(br))end ap.removeLanes=bp local function bq(br)
return br end ap.laneToLanes=bq local function br(bs,bt)if bs~=aI and bt~=aI then if bs<bt then return bs end return bt
else if bs~=aI then return bs end return bt end end ap.higherPriorityLane=br local function bs(bt,bu)if bt~=aG and bt>bu
then return bt else return bu end end ap.higherLanePriority=bs local function bt(bu)local bv={[0]=bu,[1]=bu,[2]=bu,[3]=
bu,[4]=bu,[5]=bu,[6]=bu,[7]=bu,[8]=bu,[9]=bu,[10]=bu,[11]=bu,[12]=bu,[13]=bu,[14]=bu,[15]=bu,[16]=bu,[17]=bu,[18]=bu,[19
]=bu,[20]=bu,[21]=bu,[22]=bu,[23]=bu,[24]=bu,[25]=bu,[26]=bu,[27]=bu,[28]=bu,[29]=bu,[30]=bu,[31]=bu}return bv end ap.
createLaneMap=bt local function bu(bv,bw,bx)bv.pendingLanes=bit32.bor(bv.pendingLanes,bw)local by=bw-1 bv.suspendedLanes
=bit32.band(bv.suspendedLanes,by)bv.pingedLanes=bit32.band(bv.pingedLanes,by)local bz,bA=bv.eventTimes,31-bit32.countlz(
bw)bz[bA]=bx end ap.markRootUpdated=bu local function bv(bw,bx)bw.suspendedLanes=bit32.bor(bw.suspendedLanes,bx)bw.
pingedLanes=bit32.band(bw.pingedLanes,bit32.bnot(bx))local by,bz=bw.expirationTimes,bx while bz>0 do local bA=a5(bz)
local bB=bit32.lshift(1,bA)by[bA]=a_ bz=bit32.band(bz,bit32.bnot(bB))end end ap.markRootSuspended=bv local function bw(
bx,by,bz)bx.pingedLanes=bit32.bor(bx.pingedLanes,bit32.band(bx.suspendedLanes,by))end ap.markRootPinged=bw
local function bx(by,bz)by.expiredLanes=bit32.bor(by.expiredLanes,bit32.band(bz,by.pendingLanes))end ap.markRootExpired=
bx local function by(bz)bz.expiredLanes=bit32.bor(bz.expiredLanes,bit32.band(aM,bz.pendingLanes))end ap.
markDiscreteUpdatesExpired=by local function bz(bA)return bit32.band(bA,aM)~=aH end ap.hasDiscreteLanes=bz
local function bA(bB,bC)bB.mutableReadLanes=bit32.bor(bB.mutableReadLanes,bit32.band(bC,bB.pendingLanes))end ap.
markRootMutableRead=bA local function bB(bC,bD)local bE=bit32.band(bC.pendingLanes,bit32.bnot(bD))bC.pendingLanes=bD bC.
suspendedLanes=0 bC.pingedLanes=0 bC.expiredLanes=bit32.band(bC.expiredLanes,bD)bC.mutableReadLanes=bit32.band(bC.
mutableReadLanes,bD)bC.entangledLanes=bit32.band(bC.entangledLanes,bD)local bF,bG,bH,bI=bC.entanglements,bC.eventTimes,
bC.expirationTimes,bE while bI>0 do local bJ=a5(bI)local bK=bit32.lshift(1,bJ)bF[bJ]=aH bG[bJ]=a_ bH[bJ]=a_ bI=bit32.
band(bI,bit32.bnot(bK))end end ap.markRootFinished=bB local function bC(bD,bE)bD.entangledLanes=bit32.bor(bD.
entangledLanes,bE)local bF,bG=bD.entanglements,bE while bG>0 do local bH=a5(bG)local bI=bit32.lshift(1,bH)bF[bH]=bit32.
bor(bF[bH],bE)bG=bit32.band(bG,bit32.bnot(bI))end end ap.markRootEntangled=bC local function bD(bE,bF)a2(bF)local bG,bH=
a1 if bG==aq or bG==ar then bH=aI elseif bG==as or bG==at then bH=aL elseif bG==au or bG==av then bH=aN elseif bG==aw or
bG==ax then bH=aP elseif bG==az or bG==aA then bH=aR elseif bG==aB then bH=aR elseif bG==aC then bH=aV elseif bG==aD or
bG==aE then bH=aX elseif bG==aF or bG==aG then bH=aI else ai(false,'Invalid lane: %s. This is a bug in React.',tostring(
bH))end if bit32.band(bH,bit32.bor(bE.suspendedLanes,bF))~=aI then return aI end return bH end ap.
getBumpedLaneForHydration=bD return ap end)()end,[88]=function()local aa,ab,ac=a(88)local ad return(function(...)
local function ae(af,ag)if af and typeof(af)=='table'and af.defaultProps then local ah,ai=table.clone(ag),af.
defaultProps for aj,ak in ai do if ah[aj]==nil then ah[aj]=ai[aj]end end return ah end return ag end return{
resolveDefaultProps=ae}end)()end,[89]=function()local aa,ab,ac=a(89)local ad return(function(...)local ae=ab.Parent.
Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai,aj=af.Number,af.Error,ac(ae.Shared).console,ac(ae.Shared)local ak=ac(
ab.Parent.ReactInternalTypes)local al=ac(ab.Parent['ReactFiberStack.new'])local am=ac(ab.Parent.ReactFiberLane)local an=
ac(ab.Parent['ReactUpdateQueue.new'])local ao=ac(ab.Parent.ReactFiberHostConfig)local ap,aq,ar,as,at,au=ao.
isPrimaryRenderer,al.createCursor,al.push,al.pop,ac(ab.Parent.MaxInts).MAX_SIGNED_31_BIT_INT,ac(ab.Parent.ReactWorkTags)
local av,aw,ax,az,aA,aB,aC,aD,aE,aF,aG,aH,aI,aJ=au.ContextProvider,au.ClassComponent,am.NoLanes,am.NoTimestamp,am.
isSubsetOfLanes,am.includesSomeLane,am.mergeLanes,am.pickArbitraryLane,ac(ae.Shared).objectIs,an.createUpdate,an.
ForceUpdate,{},(aq(nil))if _G.__DEV__ then aJ={}end local aK,aL,aM,aN=false aH.resetContextDependencies=function()aL=nil
aM=nil aN=nil if _G.__DEV__ then aK=false end end aH.enterDisallowedContextReadInDEV=function()if _G.__DEV__ then aK=
true end end aH.exitDisallowedContextReadInDEV=function()if _G.__DEV__ then aK=false end end aH.pushProvider=function(aO
,aP)local aQ=aO.type._context if ap then ar(aI,aQ._currentValue,aO)aQ._currentValue=aP if _G.__DEV__ then if aQ.
_currentRenderer~=nil and aQ._currentRenderer~=aJ then ai.error
[[Detected multiple renderers concurrently rendering the same context provider. This is currently unsupported.]]end aQ.
_currentRenderer=aJ end else ar(aI,aQ._currentValue2,aO)aQ._currentValue2=aP if _G.__DEV__ then if aQ._currentRenderer2
~=nil and aQ._currentRenderer2~=aJ then ai.error
[[Detected multiple renderers concurrently rendering the same context provider. This is currently unsupported.]]end aQ.
_currentRenderer2=aJ end end end aH.popProvider=function(aO)local aP=aI.current as(aI,aO)local aQ=aO.type._context if ap
then aQ._currentValue=aP else aQ._currentValue2=aP end end aH.calculateChangedBits=function(aO,aP,aQ)if aE(aQ,aP)then
return 0 else local aR=at if typeof(aO._calculateChangedBits)=='function'then aR=aO._calculateChangedBits(aQ,aP)end
return math.floor(aR)end end aH.scheduleWorkOnParentPath=function(aO,aP)local aQ=aO while aQ~=nil do local aR=aQ.
alternate if not aA(aQ.childLanes,aP)then aQ.childLanes=aC(aQ.childLanes,aP)if aR~=nil then aR.childLanes=aC(aR.
childLanes,aP)end elseif aR~=nil and not aA(aR.childLanes,aP)then aR.childLanes=aC(aR.childLanes,aP)else break end aQ=aQ
.return_ end end aH.propagateContextChange=function(aO,aP,aQ,aR)local aS=aO.child if aS~=nil then aS.return_=aO end
while aS~=nil do local aT,aU=(aS.dependencies)if aT~=nil then aU=aS.child local aV=aT.firstContext while aV~=nil do if
aV.context==aP and bit32.band(aV.observedBits,aQ)~=0 then if aS.tag==aw then local aW=aF(az,aD(aR))aW.tag=aG local aX=aS
.updateQueue if aX==nil then else local aY=(aX).shared local aZ=aY.pending if aZ==nil then aW.next=aW else aW.next=aZ.
next aZ.next=aW end aY.pending=aW end end aS.lanes=bit32.bor(aS.lanes,aR)local aW=aS.alternate if aW~=nil then aW.lanes=
bit32.bor(aW.lanes,aR)end aH.scheduleWorkOnParentPath(aS.return_,aR)aT.lanes=bit32.bor(aT.lanes,aR)break end aV=aV.next
end elseif aS.tag==av then if aS.type==aO.type then aU=nil else aU=aS.child end else aU=aS.child end if aU~=nil then aU.
return_=aS else aU=aS while aU~=nil do if aU==aO then aU=nil break end local aV=aU.sibling if aV~=nil then aV.return_=aU
.return_ aU=aV break end aU=aU.return_ end end aS=aU end end aH.prepareToReadContext=function(aO,aP,aQ)aL=aO aM=nil aN=
nil local aR=aO.dependencies if aR~=nil then local aS=aR.firstContext if aS~=nil then if aB(aR.lanes,aP)then aQ()end aR.
firstContext=nil end end end aH.readContext=function(aO,aP)if _G.__DEV__ then if aK then ai.error
[[Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().]]
end end if aN==aO then elseif aP==false or aP==0 then else local aQ if typeof(aP)~='number'or aP==ag.MAX_SAFE_INTEGER
then aN=aO aQ=ag.MAX_SAFE_INTEGER else aQ=aP end local aR={context=aO,observedBits=aQ,next=nil}if aM==nil then if aL==
nil then error(ah.new
[[Context can only be read while React is rendering. In classes, you can read it in the render method or getDerivedStateFromProps. In function components, you can read it directly in the function body, but not inside Hooks like useReducer() or useMemo().]]
)end aM=aR;(aL).dependencies={lanes=ax,firstContext=aR,responders=nil}else(aM).next=aR aM=aR end end return if ap then
aO._currentValue else aO._currentValue2 end return aH end)()end,[90]=function()local aa,ab,ac=a(90)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.Shared)local ag=ac(ab.Parent.ReactFiberLane)return{}end)()end,[91]
=function()local aa,ab,ac=a(91)local ad return(function(...)return ac(ab.Parent['ReactFiberReconciler.new'])end)()end,[
92]=function()local aa,ab,ac=a(92)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent.Parent local ag=ac(af.
Shared)local ah=ac(af.LuauPolyfill)local ai,aj=ah.Array,ah.Object local ak=ac(af.Shared).console local al=ac(ab.Parent.
ReactInternalTypes)local am=ac(ab.Parent.ReactRootTags)local an,ao=ac(ab.Parent.ReactFiberFlags),ac(ab.Parent.
ReactFiberHostConfig)local ap=ac(ab.Parent.ReactWorkTags)local aq,ar=ap.FundamentalComponent,ac(af.Shared)local as=ac(ab
.Parent.ReactFiberLane)local at=ac(ab.Parent['ReactFiberSuspenseComponent.new'])local au=ac(ab.Parent.
ReactFiberTreeReflection)local av,aw,ax,az,aA,aB,aC,aD,aE,aF,aG,aH,aI,aJ=au.findCurrentHostFiber,au.
findCurrentHostFiberWithNoPortals,ac(af.Shared).ReactInstanceMap.get,ap.HostComponent,ap.ClassComponent,ap.HostRoot,ap.
SuspenseComponent,ac(af.Shared).getComponentName,ac(af.Shared).invariant,ac(af.Shared).describeError,ac(af.Shared).
ReactFeatureFlags.enableSchedulingProfiler,ac(af.Shared).ReactSharedInternals,ac(ab.Parent.ReactFiberHostConfig).
getPublicInstance,ac(ab.Parent['ReactFiberContext.new'])local aK,aL,aM,aN,aO=aJ.findCurrentUnmaskedContext,aJ.
processChildContext,aJ.emptyContextObject,aJ.isContextProvider,ac(ab.Parent['ReactFiberRoot.new'])local aP,aQ=aO.
createFiberRoot,ac(ab.Parent['ReactFiberDevToolsHook.new'])local aR,aS,aT=aQ.injectInternals,aQ.onScheduleRoot,ac(ab.
Parent['ReactFiberWorkLoop.new'])local aU,aV,aW,aX,aY,aZ,a_,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b=aT.requestEventTime,aT.
requestUpdateLane,aT.scheduleUpdateOnFiber,aT.flushRoot,aT.batchedEventUpdates,aT.batchedUpdates,aT.unbatchedUpdates,aT.
flushSync,aT.flushControlled,aT.deferredUpdates,aT.discreteUpdates,aT.flushDiscreteUpdates,aT.flushPassiveEffects,aT.
warnIfNotScopedWithMatchingAct,aT.warnIfUnmockedScheduler,aT.IsThisRendererActing,aT.act,ac(ab.Parent[
'ReactUpdateQueue.new'])local ba,bb,bc=b.createUpdate,b.enqueueUpdate,ac(ab.Parent.ReactCurrentFiber)local bd,be,bf,bg=
bc.isRendering,bc.resetCurrentFiber,bc.setCurrentFiber,ac(ab.Parent.ReactTypeOfMode)local bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,
br=bg.StrictMode,as.SyncLane,as.InputDiscreteHydrationLane,as.SelectiveHydrationLane,as.NoTimestamp,as.
getHighestPriorityPendingLanes,as.higherPriorityLane,as.getCurrentUpdateLanePriority,as.setCurrentUpdateLanePriority,ac(
ab.Parent.SchedulingProfiler).markRenderScheduled,{}br.ReactRootTags=am br.ReactWorkTags=ap br.ReactTypeOfMode=bg br.
ReactFiberFlags=an br.getNearestMountedFiber=au.getNearestMountedFiber br.findCurrentFiberUsingSlowPath=au.
findCurrentFiberUsingSlowPath br.createPortal=ac(ab.Parent.ReactPortal).createPortal local bs,bt if ae then bs=false bt=
{}end local function bu(bv)if not bv then return aM end local bw=ax(bv)local bx=aK(bw)if bw.tag==aA then local by=bw.
type if aN(by)then return aL(bw,by,bx)end end return bx end local function bv(bw)local bx=ax(bw)if bx==nil then if
typeof(bw.render)=='function'then aE(false,'Unable to find node on an unmounted component.')else aE(false,
'Argument appears to not be a ReactComponent. Keys: %s',table.concat(aj.keys(bw)))end end local by=av(bx)if by==nil then
return nil end return by.stateNode end local function bw(bx,by)if ae then local bz=ax(bx)if bz==nil then if typeof(bx.
render)=='function'then aE(false,'Unable to find node on an unmounted component.')else aE(false,
'Argument appears to not be a ReactComponent. Keys: %s',table.concat(aj.keys(bx)))end end local bA=av(bz)if bA==nil then
return nil end if bit32.band(bA.mode,bh)~=0 then local bB=aD(bz.type)or'Component'if not bt[bB]then bt[bB]=true local bC
,bD,bE=bc.current,xpcall(function()bf(bA)if bit32.band(bz.mode,bh)~=0 then ak.error(
[[%s is deprecated in StrictMode. %s was passed an instance of %s which is inside StrictMode. Instead, add a ref directly to the element you want to reference. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-find-node]]
,by,by,bB)else ak.error(
[[%s is deprecated in StrictMode. %s was passed an instance of %s which renders StrictMode children. Instead, add a ref directly to the element you want to reference. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-find-node]]
,by,by,bB)end end,aF)if bC then bf(bC)else be()end if not bD then error(bE)end end end return bA.stateNode end return
bv(bx)end br.createContainer=function(bx,by,bz,bA)return aP(bx,by,bz,bA)end br.updateContainer=function(bx,by,bz,bA)if
ae then aS(by,bx)end local bB,bC=by.current,aU()if ae then if _G.__TESTEZ_RUNNING_TEST__ then a7(bB)a6(bB)end end local
bD=aV(bB)if aG then bq(bD)end local bE=bu(bz)if by.context==nil then by.context=bE else by.pendingContext=bE end if ae
then if bd and bc.current~=nil and not bs then bs=true ak.error(
[[Render methods should be a pure function of props and state; triggering nested component updates from render is not allowed. If necessary, trigger nested updates in componentDidUpdate.

Check the render method of %s.]]
,aD((bc.current).type)or'Unknown')end end local bF=ba(bC,bD)if bx==nil then bx=aj.None end bF.payload={element=bx}if bA
~=nil then if ae then if typeof(bA)~='function'then ak.error(
[[render(...): Expected the last optional `callback` argument to be a function. Instead received: %s.]],tostring(bA))end
end bF.callback=bA end bb(bB,bF)aW(bB,bD,bC)return bD end br.batchedEventUpdates=aY br.batchedUpdates=aZ br.
unbatchedUpdates=a_ br.deferredUpdates=a2 br.discreteUpdates=a3 br.flushDiscreteUpdates=a4 br.flushControlled=a1 br.
flushSync=a0 br.flushPassiveEffects=a5 br.IsThisRendererActing=a8 br.act=a9 br.getPublicRootInstance=function(bx)local
by=bx.current if not by.child then return nil end if by.child.tag==az then return aI(by.child.stateNode)else return by.
child.stateNode end end local bx br.attemptSynchronousHydration=function(by)if by.tag==aB then local bz=by.stateNode if
bz.hydrate then local bA=bm(bz)aX(bz,bA)end elseif by.tag==aC then local bz=aU()a0(function()return aW(by,bi,bz)end)
local bA=bj bx(by,bA)end end local function by(bz,bA)local bB=bz.memoizedState if bB then if bB~=nil and bB.dehydrated~=
nil then bB.retryLane=bn(bB.retryLane,bA)end end end bx=function(bz,bA)by(bz,bA)local bB=bz.alternate if bB then by(bB,
bA)end end br.attemptUserBlockingHydration=function(bz)if bz.tag~=aC then return end local bA,bB=aU(),bj aW(bz,bB,bA)bx(
bz,bB)end br.attemptContinuousHydration=function(bz)if bz.tag~=aC then return end local bA,bB=aU(),bk aW(bz,bB,bA)bx(bz,
bB)end br.attemptHydrationAtCurrentPriority=function(bz)if bz.tag~=aC then return end local bA,bB=aU(),aV(bz)aW(bz,bB,bA
)bx(bz,bB)end br.runWithPriority=function(bz,bA)local bB=bo()bp(bz)local bC,bD=xpcall(bA,aF)bp(bB)if not bC then error(
bD)end return bD end br.getCurrentUpdateLanePriority=bo br.findHostInstance=bv br.findHostInstanceWithWarning=bw br.
findHostInstanceWithNoPortals=function(bz)local bA=aw(bz)if bA==nil then return nil end if bA.tag==aq then return bA.
stateNode.instance end return bA.stateNode end local function bz(bA)return false end br.shouldSuspend=function(bA)return
bz(bA)end local bA,bB,bC,bD,bE,bF,bG,bH if ae then local function bI(bJ,bK,bL)local bM,bN=(bK[bL])if ai.isArray(bJ)then
bN=ai.slice(bJ)else bN=table.clone(bJ)end if bL+1==#bK then if ai.isArray(bN)then local bO=bM ai.splice(bN,bO,1)else bN[
bM]=nil end return bN end bN[bM]=bI(bJ[bM],bK,bL+1)return bN end local function bJ(bK,bL)return bI(bK,bL,0)end
local function bK(bL,bM,bN,bO)local bP,bQ=(bM[bO])if ai.isArray(bL)then bQ=ai.slice(bL)else bQ=table.clone(bL)end if bO+
1==#bM then local bR=bN[bO]bQ[bR]=bQ[bP]if ai.isArray(bQ)then ai.splice(bQ,bP,1)else bQ[bP]=nil end else bQ[bP]=bK(bL[bP
],bM,bN,bO+1)end return bQ end local function bL(bM,bN,bO)if#bN~=#bO then ak.warn
'copyWithRename() expects paths of the same length'return nil else for bP=1,#bO do if bN[bP]~=bO[bP]then ak.warn
[[copyWithRename() expects paths to be the same except for the deepest key]]return nil end end end return bK(bM,bN,bO,0)
end local function bM(bN,bO,bP,bQ)if bP>=(#bO+1)then return bQ end local bR,bS=(bO[bP])if ai.isArray(bN)then bS=ai.
slice(bN)else bS=table.clone(bN)end bS[bR]=bM(bN[bR],bO,bP+2,bQ)return bS end local function bN(bO,bP,bQ)return bM(bO,bP
,1,bQ)end local function bO(bP,bQ)local bR=bP.memoizedState while bR~=nil and bQ>1 do bR=bR.next bQ-=1 end return bR end
bA=function(bP,bQ,bR,bS)local bT=bO(bP,bQ)if bT~=nil then local bU=bN(bT.memoizedState,bR,bS)bT.memoizedState=bU bT.
baseState=bU bP.memoizedProps=table.clone(bP.memoizedProps)aW(bP,bi,bl)end end bB=function(bP,bQ,bR)local bS=bO(bP,bQ)if
bS~=nil then local bT=bJ(bS.memoizedState,bR)bS.memoizedState=bT bS.baseState=bT bP.memoizedProps=table.clone(bP.
memoizedProps)aW(bP,bi,bl)end end bC=function(bP,bQ,bR,bS)local bT=bO(bP,bQ)if bT~=nil then local bU=bL(bT.memoizedState
,bR,bS)bT.memoizedState=bU bT.baseState=bU bP.memoizedProps=table.clone(bP.memoizedProps)aW(bP,bi,bl)end end bD=function
(bP,bQ,bR)bP.pendingProps=bN(bP.memoizedProps,bQ,bR)local bS=bP.alternate if bS then bS.pendingProps=bP.pendingProps end
aW(bP,bi,bl)end bE=function(bP,bQ)bP.pendingProps=bJ(bP.memoizedProps,bQ)local bR=bP.alternate if bR then bR.
pendingProps=bP.pendingProps end aW(bP,bi,bl)end bF=function(bP,bQ,bR)bP.pendingProps=bL(bP.memoizedProps,bQ,bR)local bS
=bP.alternate if bS then bS.pendingProps=bP.pendingProps end aW(bP,bi,bl)end bG=function(bP)aW(bP,bi,bl)end bH=function(
bP)bz=bP end end function findHostInstanceByFiber(bI)local bJ=av(bI)if bJ==nil then return nil end return bJ.stateNode
end function emptyFindFiberByHostInstance(bI)return nil end function getCurrentFiberForDevTools()return bc.current end
br.injectIntoDevTools=function(bI)local bJ,bK,bL=bI.findFiberByHostInstance,(aH.ReactCurrentDispatcher)if ae then bL=
getCurrentFiberForDevTools end return aR{bundleType=bI.bundleType,version=bI.version,rendererPackageName=bI.
rendererPackageName,rendererConfig=bI.rendererConfig,overrideHookState=bA,overrideHookStateDeletePath=bB,
overrideHookStateRenamePath=bC,overrideProps=bD,overridePropsDeletePath=bE,overridePropsRenamePath=bF,setSuspenseHandler
=bH,scheduleUpdate=bG,currentDispatcherRef=bK,findHostInstanceByFiber=findHostInstanceByFiber,findFiberByHostInstance=bJ
or emptyFindFiberByHostInstance,getCurrentFiber=bL}end return br end)()end,[93]=function()local aa,ab,ac=a(93)local ad
return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai=af.Set,af.Map,ac(ab.Parent.
ReactInternalTypes)local aj=ac(ab.Parent.ReactRootTags)local ak=ac(ab.Parent.ReactFiberHostConfig)local al,am,an=ak.
noTimeout,ak.supportsHydration,ac(ab.Parent['ReactFiber.new'])local ao,ap=an.createHostRootFiber,ac(ab.Parent.
ReactFiberLane)local aq,ar,as,at,au=ap.NoLanes,ap.NoLanePriority,ap.NoTimestamp,ap.createLaneMap,ac(ae.Shared).
ReactFeatureFlags local av,aw,ax=au.enableSchedulerTracing,au.enableSuspenseCallback,ac(ae.Scheduler).tracing local az,
aA=ax.unstable_getThreadID,ac(ab.Parent['ReactUpdateQueue.new'])local aB,aC,aD,aE,aF=aA.initializeUpdateQueue,aj.
LegacyRoot,aj.BlockingRoot,aj.ConcurrentRoot,{}local function aG(aH,aI,aJ)local aK={tag=aI,containerInfo=aH,
pendingChildren=nil,current=(nil),pingCache=nil,finishedWork=nil,timeoutHandle=al,context=nil,pendingContext=nil,hydrate
=aJ,callbackNode=nil,callbackPriority=ar,eventTimes=at(aq),expirationTimes=at(as),pendingLanes=aq,suspendedLanes=aq,
pingedLanes=aq,expiredLanes=aq,mutableReadLanes=aq,finishedLanes=aq,entangledLanes=aq,entanglements=at(aq)}if am then aK
.mutableSourceEagerHydrationData=nil end if av then aK.interactionThreadID=az()aK.memoizedInteractions=ag.new()aK.
pendingInteractionMap=ah.new()end if aw then aK.hydrationCallbacks=nil end if _G.__DEV__ then if aI==aD then aK.
_debugRootType='createBlockingRoot()'elseif aI==aE then aK._debugRootType='createRoot()'elseif aI==aC then aK.
_debugRootType='createLegacyRoot()'end end return aK end aF.createFiberRoot=function(aH,aI,aJ,aK)local aL=aG(aH,aI,aJ)if
aw then aL.hydrationCallbacks=aK end local aM=ao(aI)aL.current=aM aM.stateNode=aL aB(aM)return aL end return aF end)()
end,[94]=function()local aa,ab,ac=a(94)local ad return(function(...)local ae={ImmediatePriority=99,UserBlockingPriority=
98,NormalPriority=97,LowPriority=96,IdlePriority=95,NoPriority=90}return ae end)()end,[95]=function()local aa,ab,ac=a(95
)local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.Shared).console,ac(ab.Parent.
ReactInternalTypes)local ah={}local ai,aj={}if _G.__DEV__ then aj={}end local ak=0 local function al(am)return{current=
am}end local function am()return ak==0 end local function an(ao,ap)if ak<1 then if _G.__DEV__ then af.error
'Unexpected pop.'end return end if _G.__DEV__ then if ap~=aj[ak]then af.error'Unexpected Fiber popped.'end end local aq=
ai[ak]if aq==ah then ao.current=nil else ao.current=aq end ai[ak]=nil if _G.__DEV__ then aj[ak]=nil end ak-=1 end
local function ao(ap,aq,ar)ak+=1 local as=ap.current if as==nil then ai[ak]=ah else ai[ak]=as end if _G.__DEV__ then aj[
ak]=ar end ap.current=aq end local function ap()if _G.__DEV__ then if ak~=0 then af.error
'Expected an empty stack. Something was not reset properly.'end end end local function aq()if _G.__DEV__ then ak=0 table
.clear(ai)table.clear(aj)end end return{createCursor=al,isEmpty=am,pop=an,push=ao,checkThatStackIsEmpty=ap,
resetStackAfterFatalErrorInDev=aq}end)()end,[96]=function()local aa,ab,ac=a(96)local ad return(function(...)local ae=ab.
Parent.Parent local af=ac(ae.Shared)local ag=ac(ab.Parent.ReactInternalTypes)local ah=ac(ab.Parent.ReactFiberHostConfig)
local ai=ac(ab.Parent.ReactFiberLane)local aj=ac(ab.Parent.ReactWorkTags)local ak,al,am=aj.SuspenseComponent,aj.
SuspenseListComponent,ac(ab.Parent.ReactFiberFlags)local an,ao,ap,aq=am.NoFlags,am.DidCapture,ah.
isSuspenseInstancePending,ah.isSuspenseInstanceFallback local ar={}ar.shouldCaptureSuspense=function(as,at)local au=as.
memoizedState if au then if au.dehydrated~=nil then return true end return false end local av=as.memoizedProps if av.
fallback==nil then return false end if av.unstable_avoidThisFallback~=true then return true end if at then return false
end return true end ar.findFirstSuspended=function(as)local at=as while at~=nil do if at.tag==ak then local au=at.
memoizedState if au then local av=au.dehydrated if av==nil or ap(av)or aq(av)then return at end end elseif at.tag==al
and at.memoizedProps.revealOrder~=nil then local au=bit32.band(at.flags,ao)~=an if au then return at end elseif at.child
~=nil then at.child.return_=at at=at.child continue end if at==as then return nil end while at.sibling==nil do if at.
return_==nil or at.return_==as then return nil end at=at.return_ end(at.sibling).return_=at.return_ at=at.sibling end
return nil end return ar end)()end,[97]=function()local aa,ab,ac=a(97)local ad return(function(...)local ae=ac(ab.Parent
.ReactInternalTypes)local af=ac(ab.Parent['ReactFiberStack.new'])local ag,ah,ai=af.createCursor,af.push,af.pop local aj,
ak,al,am={},0b0,0b1,0b1 aj.InvisibleParentSuspenseContext=am local an=0b10 aj.ForceSuspenseFallback=an local ao=ag(ak)aj
.suspenseStackCursor=ao function aj.hasSuspenseContext(ap,aq)return bit32.band(ap,aq)~=0 end function aj.
setDefaultShallowSuspenseContext(ap)return bit32.band(ap,al)end function aj.setShallowSuspenseContext(ap,aq)return bit32
.bor(bit32.band(ap,al),aq)end function aj.addSubtreeSuspenseContext(ap,aq)return bit32.bor(ap,aq)end function aj.
pushSuspenseContext(ap,aq)ah(ao,aq,ap)end function aj.popSuspenseContext(ap)ai(ao,ap)end return aj end)()end,[98]=
function()local aa,ab,ac=a(98)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local
ag,ah=af.Object,ac(ae.Shared).console local ai=ac(ab.Parent.ReactInternalTypes)local aj=ac(ab.Parent.ReactFiberLane)
local ak=ac(ab.Parent.ReactCapturedValue)local al=ac(ab.Parent['ReactUpdateQueue.new'])local am=ac(ae.Shared)local an=
ac(ab.Parent['ReactFiberSuspenseContext.new'])local ao,ap=ac(ae.Shared).getComponentName,ac(ab.Parent.ReactWorkTags)
local aq,ar,as,at,au=ap.ClassComponent,ap.HostRoot,ap.SuspenseComponent,ap.IncompleteClassComponent,ac(ab.Parent.
ReactFiberFlags)local av,aw,ax,az,aA,aB,aC,aD=au.DidCapture,au.Incomplete,au.NoFlags,au.ShouldCapture,au.
LifecycleEffectMask,au.ForceUpdateForLegacySuspense,ac(ab.Parent['ReactFiberSuspenseComponent.new']).
shouldCaptureSuspense,ac(ab.Parent.ReactTypeOfMode)local aE,aF,aG,aH=aD.NoMode,aD.BlockingMode,aD.DebugTracingMode,ac(ae
.Shared).ReactFeatureFlags local aI,aJ,aK,aL,aM,aN,aO,aP,aQ,aR,aS,aT,aU,aV,aW,aX=aH.enableDebugTracing,aH.
enableSchedulingProfiler,ac(ab.Parent.ReactCapturedValue).createCapturedValue,al.enqueueCapturedUpdate,al.createUpdate,
al.CaptureUpdate,al.ForceUpdate,al.enqueueUpdate,ac(ab.Parent['ReactFiberHotReloading.new']).
markFailedErrorBoundaryForHotReloading,an.hasSuspenseContext,an.InvisibleParentSuspenseContext,(an.suspenseStackCursor)
local aY,aZ,a_,a0,a1,a2,a3,a4,a5,a6,a7=function(...)if not aV then aU=ac(ab.Parent['ReactFiberWorkLoop.new'])aV=aU.
markLegacyErrorBoundaryAsFailed end return aV(...)end,function(...)if aU==nil then aU=ac(ab.Parent[
'ReactFiberWorkLoop.new'])end aX=aU.pingSuspendedRoot return aX(...)end,function(...)if aU==nil then aU=ac(ab.Parent[
'ReactFiberWorkLoop.new'])end aW=aU.isAlreadyFailedLegacyErrorBoundary return aW(...)end,ac(ab.Parent.
ReactFiberErrorLogger).logCapturedError,ac(ab.Parent.DebugTracing).logComponentSuspended,ac(ab.Parent.SchedulingProfiler
).markComponentSuspended,aj.SyncLane,aj.NoTimestamp,aj.includesSomeLane,aj.mergeLanes,aj.pickArbitraryLane function
createRootErrorUpdate(a8,a9,b,ba)local bb=aM(a4,b)bb.tag=aN bb.payload={element=ag.None}local bc=a9.value bb.callback=
function()if ba~=nil then ba(bc)end a0(a8,a9)end return bb end function createClassErrorUpdate(a8,a9,b)local ba=aM(a4,b)
ba.tag=aN local bb=(a8.type).getDerivedStateFromError if typeof(bb)=='function'then local bc=a9.value ba.payload=
function()a0(a8,a9)return bb(bc)end end local bc=a8.stateNode if bc~=nil and typeof(bc.componentDidCatch)=='function'
then ba.callback=function()if _G.__DEV__ then aQ(a8)end if typeof(bb)~='function'then aY(bc)a0(a8,a9)end local bd,be=a9.
value,a9.stack bc:componentDidCatch(bd,{componentStack=be or''})if _G.__DEV__ then if typeof(bb)~='function'then if not
a5(a8.lanes,a3)then ah.error(
[[%s: Error boundaries should implement getDerivedStateFromError(). In that method, return a state update to display an error message or fallback UI.]]
,ao(a8.type)or'Unknown')end end end end elseif _G.__DEV__ then ba.callback=function()aQ(a8)end end return ba end
local function a8(a9,b,ba)local bb,bc=(a9.pingCache)if bb==nil then bc={}a9.pingCache={[b]=bc}bb=a9.pingCache else bc=(
bb)[b]if bc==nil then bc={}(bb)[b]=bc end end if not bc[ba]then bc[ba]=true local bd=function()return aZ(a9,b,ba)end b:
andThen(bd,bd)end end function throwException(a9,b,ba,bb,bc,bd,be)ba.flags=bit32.bor(ba.flags,aw)if bb~=nil and typeof(
bb)=='table'and typeof(bb.andThen)=='function'then local bf=bb if _G.__DEV__ then if aI then if bit32.band(ba.mode,aG)~=
0 then local bg=ao(ba.type)or'Unknown'a1(bg,bf)end end end if aJ then a2(ba,bf)end if bit32.band(ba.mode,aF)==aE then
local bg=ba.alternate if bg then ba.updateQueue=bg.updateQueue ba.memoizedState=bg.memoizedState ba.lanes=bg.lanes else
ba.updateQueue=nil ba.memoizedState=nil end end local bg,bh=aR(aT.current,aS),b repeat if bh.tag==as and aC(bh,bg)then
local bi=bh.updateQueue if bi==nil then local bj={[bf]=true}bh.updateQueue=bj else bi[bf]=true end if bit32.band(bh.mode
,aF)==aE then bh.flags=bit32.bor(bh.flags,av)ba.flags=bit32.bor(ba.flags,aB)ba.flags=bit32.band(ba.flags,bit32.bnot(
bit32.bor(aA,aw)))if ba.tag==aq then local bj=ba.alternate if bj==nil then ba.tag=at else local bk=aM(a4,a3)bk.tag=aO
aP(ba,bk)end end ba.lanes=a6(ba.lanes,a3)return end a8(a9,bf,bc)bh.flags=bit32.bor(bh.flags,az)bh.lanes=bc return end bh
=bh.return_ until bh==nil bb=(ao(ba.type)or'A React component')..
[[ suspended while rendering, but no fallback UI was specified.

Add a <Suspense fallback=...> component higher in the tree to provide a loading indicator or placeholder to display.]]
end be()bb=aK(bb,ba)local bf=b repeat if bf.tag==ar then local bg=bb bf.flags=bit32.bor(bf.flags,az)local bh=a7(bc)bf.
lanes=a6(bf.lanes,bh)local bi=createRootErrorUpdate(bf,bg,bh,bd)aL(bf,bi)return elseif bf.tag==aq then local bg,bh,bi=bb
,bf.type,bf.stateNode if bit32.band(bf.flags,av)==ax and(typeof(bh.getDerivedStateFromError)=='function'or(bi~=nil and
typeof(bi.componentDidCatch)=='function'and not a_(bi)))then bf.flags=bit32.bor(bf.flags,az)local bj=a7(bc)bf.lanes=a6(
bf.lanes,bj)local bk=createClassErrorUpdate(bf,bg,bj)aL(bf,bk)return end end bf=bf.return_ until bf==nil end return{
throwException=throwException,createRootErrorUpdate=createRootErrorUpdate,createClassErrorUpdate=createClassErrorUpdate}
end)()end,[99]=function()local aa,ab,ac=a(99)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.
Shared).ReactSharedInternals local ag=af.ReactCurrentBatchConfig return{NoTransition=0,requestCurrentTransition=function
()return ag.transition end}end)()end,[100]=function()local aa,ab,ac=a(100)local ad return(function(...)local ae=ab.
Parent.Parent local af,ag=ac(ae.Shared).console,ac(ab.Parent.ReactInternalTypes)local ah=ac(ab.Parent.
ReactFiberHostConfig)local ai=ac(ab.Parent['ReactFiberSuspenseComponent.new'])local aj,ak,al,am,an=ac(ae.Shared).
invariant,ac(ae.Shared).ReactInstanceMap.get,ac(ae.Shared).ReactSharedInternals,ac(ae.Shared).getComponentName,ac(ab.
Parent.ReactWorkTags)local ao,ap,aq,ar,as,at,au,av=an.ClassComponent,an.HostComponent,an.HostRoot,an.HostPortal,an.
HostText,an.FundamentalComponent,an.SuspenseComponent,ac(ab.Parent.ReactFiberFlags)local aw,ax,az,aA,aB,aC=av.NoFlags,av
.Placement,av.Hydrating,ac(ae.Shared).ReactFeatureFlags.enableFundamentalAPI,al.ReactCurrentOwner,{}local function aD(aE
)local aF,aG=aE,aE if not aE.alternate then local aH=aF repeat aF=aH if bit32.band(aF.flags,bit32.bor(ax,az))~=aw then
aG=aF.return_ end aH=aF.return_ until not aH else while aF.return_ do aF=aF.return_ end end if aF.tag==aq then return aG
end return nil end aC.getNearestMountedFiber=aD aC.getSuspenseInstanceFromFiber=function(aE)if aE.tag==au then local aF=
aE.memoizedState if aF==nil then local aG=aE.alternate if aG~=nil then aF=aG.memoizedState end end if aF then return aF.
dehydrated end end return nil end aC.getContainerFromFiber=function(aE)return if aE.tag==aq then aE.stateNode.
containerInfo else nil end aC.isFiberMounted=function(aE)return aD(aE)==aE end aC.isMounted=function(aE)if _G.__DEV__
then local aF=aB.current if aF~=nil and aF.tag==ao then local aG=aF local aH=aG.stateNode if not aH.
_warnedAboutRefsInRender then af.error(
[[%s is accessing isMounted inside its render() function. render() should be a pure function of props and state. It should never access something that requires stale data from the previous render, such as refs. Move this logic to componentDidMount and componentDidUpdate instead.]]
,am(aG.type)or'A component')end aH._warnedAboutRefsInRender=true end end local aF=ak(aE)if not aF then return false else
local aG=aF return aD(aG)==aF end end local function aE(aF)aj(aD(aF)==aF,
'Unable to find node on an unmounted component.')end local function aF(aG)local aH=aG.alternate if not aH then local aI=
aD(aG)aj(aI~=nil,'Unable to find node on an unmounted component.')if aI~=aG then return nil end return aG end local aI,
aJ=aG,aH while true do local aK=aI.return_ if aK==nil then break end local aL=aK.alternate if aL==nil then local aM=aK.
return_ if aM~=nil then aI=aM aJ=aM continue end break end if aK.child==aL.child then local aM=aK.child while aM do if
aM==aI then aE(aK)return aG end if aM==aJ then aE(aK)return aH end aM=aM.sibling end aj(false,
'Unable to find node on an unmounted component.')end if aI.return_~=aJ.return_ then aI=aK aJ=aL else local aM,aN=false,
aK.child while aN do if aN==aI then aM=true aI=aK aJ=aL break end if aN==aJ then aM=true aJ=aK aI=aL break end aN=aN.
sibling end if not aM then aN=aL.child while aN do if aN==aI then aM=true aI=aL aJ=aK break end if aN==aJ then aM=true
aJ=aL aI=aK break end aN=aN.sibling end aj(aM,
[[Child was not found in either parent set. This indicates a bug in React related to the return pointer. Please file an issue.]]
)end end aj(aI.alternate==aJ,
[[Return fibers should always be each others' alternates. This error is likely caused by a bug in React. Please file an issue.]]
)end aj(aI.tag==aq,'Unable to find node on an unmounted component.')if aI.stateNode.current==aI then return aG end
return aH end aC.findCurrentFiberUsingSlowPath=aF aC.findCurrentHostFiber=function(aG)local aH=aF(aG)if not aH then
return nil end local aI=aH while true do local aJ=aI.child if aI.tag==ap or aI.tag==as then return aI elseif aJ then aJ.
return_=aI aI=aJ continue end if aI==aH then return nil end local aK,aL=aI.return_,aI.sibling while not aL do if not aK
or aK==aH then return nil end aI=aK end(aL).return_=aK aI=aL end return nil end aC.findCurrentHostFiberWithNoPortals=
function(aG)local aH=aF(aG)if not aH then return nil end local aI=aH while true do local aJ=aI.child if aI.tag==ap or aI
.tag==as or(aA and aI.tag==at)then return aI elseif aJ and aI.tag~=ar then aJ.return_=aI aI=aJ continue end if aI==aH
then return nil end local aK,aL=aI.return_,aI.sibling while not aL do if not aK or aK==aH then return nil end aI=aK end(
aL).return_=aK aI=aL end return nil end aC.isFiberSuspenseAndTimedOut=function(aG)local aH=aG.memoizedState return aG.
tag==au and aH~=nil and aH.dehydrated==nil end aC.doesFiberContain=function(aG,aH)local aI,aJ=aH,aG.alternate while aI~=
nil do if aI==aG or aI==aJ then return true end aI=aI.return_ end return false end return aC end)()end,[101]=function()
local aa,ab,ac=a(101)local ad return(function(...)local ae,af=ab.Parent.Parent,ac(ab.Parent.ReactInternalTypes)local ag=
ac(ab.Parent.ReactFiberLane)local ah=ac(ab.Parent['ReactFiberSuspenseComponent.new'])local ai,aj,ak,al,am=ac(ab.Parent[
'ReactMutableSource.new']).resetWorkInProgressVersions,ac(ab.Parent.ReactWorkTags),ac(ab.Parent.ReactFiberFlags),ac(ab.
Parent.ReactTypeOfMode),ac(ae.Shared).ReactFeatureFlags local an,ao,ap=am.enableSuspenseServerRenderer,am.
enableProfilerTimer,ac(ab.Parent['ReactFiberHostContext.new'])local aq,ar,as,at,au=ap.popHostContainer,ap.popHostContext
,ac(ab.Parent['ReactFiberSuspenseContext.new']).popSuspenseContext,ac(ab.Parent['ReactFiberHydrationContext.new']).
resetHydrationState,ac(ab.Parent['ReactFiberContext.new'])local av,aw,ax,az,aA=au.isContextProvider,au.popContext,au.
popTopLevelContextObject,(ac(ab.Parent['ReactFiberNewContext.new']).popProvider)local aB,aC,aD=function(...)if not aA
then aA=ac(ab.Parent['ReactFiberWorkLoop.new']).popRenderLanes end return aA(...)end,ac(ab.Parent[
'ReactProfilerTimer.new']).transferActualDuration,ac(ae.Shared).invariant local function aE(aF,aG)if aF.tag==aj.
ClassComponent then local aH=aF.type if av(aH)then aw(aF)end local aI=aF.flags if bit32.band(aI,ak.ShouldCapture)~=0
then aF.flags=bit32.bor(bit32.band(aI,bit32.bnot(ak.ShouldCapture)),ak.DidCapture)if ao and bit32.band(aF.mode,al.
ProfileMode)~=al.NoMode then aC(aF)end return aF end return nil elseif aF.tag==aj.HostRoot then aq(aF)ax(aF)ai()local aH
=aF.flags aD(bit32.band(aH,ak.DidCapture)==ak.NoFlags,
[[The root failed to unmount after an error. This is likely a bug in React. Please file an issue.]])aF.flags=bit32.bor(
bit32.band(aH,bit32.bnot(ak.ShouldCapture)),ak.DidCapture)return aF elseif aF.tag==aj.HostComponent then ar(aF)return
nil elseif aF.tag==aj.SuspenseComponent then as(aF)if an then local aH=aF.memoizedState if aH~=nil and aH.dehydrated~=
nil then aD(aF.alternate~=nil,
[[Threw in newly mounted dehydrated component. This is likely a bug in React. Please file an issue.]])at()end end local
aH=aF.flags if bit32.band(aH,ak.ShouldCapture)~=0 then aF.flags=bit32.bor(bit32.band(aH,bit32.bnot(ak.ShouldCapture)),ak
.DidCapture)if ao and(bit32.band(aF.mode,al.ProfileMode)~=al.NoMode)then aC(aF)end return aF end return nil elseif aF.
tag==aj.SuspenseListComponent then as(aF)return nil elseif aF.tag==aj.HostPortal then aq(aF)return nil elseif aF.tag==aj
.ContextProvider then az(aF)return nil elseif aF.tag==aj.OffscreenComponent or aF.tag==aj.LegacyHiddenComponent then aB(
aF)return nil else return nil end end function unwindInterruptedWork(aF)if aF.tag==aj.ClassComponent then local aG if
typeof(aF.type)=='table'then aG=aF.type.childContextTypes end if aG~=nil then aw(aF)end elseif aF.tag==aj.HostRoot then
aq(aF)ax(aF)ai()elseif aF.tag==aj.HostComponent then ar(aF)elseif aF.tag==aj.HostPortal then aq(aF)elseif aF.tag==aj.
SuspenseComponent then as(aF)elseif aF.tag==aj.SuspenseListComponent then as(aF)elseif aF.tag==aj.ContextProvider then
az(aF)elseif aF.tag==aj.OffscreenComponent or aF.tag==aj.LegacyHiddenComponent then aB(aF)return else return end end
return{unwindWork=aE,unwindInterruptedWork=unwindInterruptedWork}end)()end,[102]=function()local aa,ab,ac=a(102)local ad
return(function(...)local ae=ac(ab.Parent.ReactFiberLane)local af,ag=ae.NoLanes,ae.mergeLanes local ah={}ah.
workInProgressRootSkippedLanes=function(ai)if ai==nil then return af end af=ai return af end ah.markSkippedUpdateLanes=
function(ai)af=ag(ai,af)end return ah end)()end,[103]=function()local aa,ab,ac=a(103)local ad return(function(...)local
ae,af,ag=_G.__DEV__,_G.__YOLO__,ab.Parent.Parent local ah,ai=ac(ag.Shared).console,ac(ag.LuauPolyfill)local aj=ai.Set
local ak,al={},ac(ag.Shared)local am=ac(ab.Parent.ReactInternalTypes)local an=ac(ab.Parent.ReactFiberLane)local ao=ac(ag
.Scheduler)local ap=ac(ab.Parent['ReactFiberSuspenseComponent.new'])local aq=ac(ab.Parent['ReactFiberStack.new'])local
ar=ac(ag.Shared).ReactFeatureFlags local as,at,au,av,aw=ar.enableDebugTracing,ar.enableSchedulingProfiler,ar.
skipUnmountedBoundaries,ar.enableDoubleInvokingEffects,ac(ag.Shared)local ax,az,aA,aB=ac(ag.Shared).describeError,aw.
ReactSharedInternals,aw.invariant,ac(ab.Parent['SchedulerWithReactIntegration.new'])local aC,aD,aE,aF,aG,aH,aI,aJ,aK,aL,
aM,aN,aO,aP,aQ,aR=aB.scheduleCallback,aB.cancelCallback,aB.getCurrentPriorityLevel,aB.runWithPriority,aB.shouldYield,aB.
requestPaint,aB.now,aB.NoPriority,aB.ImmediatePriority,aB.UserBlockingPriority,aB.NormalPriority,aB.
flushSyncCallbackQueue,aB.scheduleSyncCallback,ac(ab.Parent.DebugTracing),ac(ab.Parent.SchedulingProfiler),ac(ag.
Scheduler).tracing local aS,aT,aU,aV,aW,aX,aY,aZ=aR.__interactionsRef,aR.__subscriberRef,ac(ab.Parent.
ReactFiberHostConfig),ac(ab.Parent['ReactFiber.new']),ac(ab.Parent.ReactTypeOfMode),ac(ab.Parent.ReactWorkTags),ac(ab.
Parent.ReactRootTags).LegacyRoot,ac(ab.Parent.ReactFiberFlags)local a_,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b,ba,bb,bc,bd,be,bf
,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt=an.SyncLane,an.SyncBatchedLane,an.NoTimestamp,an.findUpdateLane,an.
findTransitionLane,an.findRetryLane,an.includesSomeLane,an.isSubsetOfLanes,an.mergeLanes,an.removeLanes,an.
pickArbitraryLane,an.hasDiscreteLanes,an.includesNonIdleWork,an.includesOnlyRetries,an.includesOnlyTransitions,an.
getNextLanes,an.returnNextLanesPriority,an.setCurrentUpdateLanePriority,an.getCurrentUpdateLanePriority,an.
markStarvedLanesAsExpired,an.getLanesToRetrySynchronouslyOnError,an.getMostRecentEventTime,an.markRootUpdated,an.
markRootSuspended,an.markRootPinged,an.markRootExpired,an.markDiscreteUpdatesExpired,an.markRootFinished,an.
schedulerPriorityToLanePriority,an.lanePriorityToSchedulerPriority,ac(ab.Parent.ReactFiberTransition),ac(ab.Parent[
'ReactFiberUnwindWork.new'])local bu,bv,bw=bt.unwindWork,bt.unwindInterruptedWork,ac(ab.Parent['ReactFiberThrow.new'])
local bx,by,bz,bA=bw.throwException,bw.createRootErrorUpdate,bw.createClassErrorUpdate,ac(ab.Parent[
'ReactFiberCommitWork.new'])local bB,bC,bD,bE,bF,bG,bH,bI,bJ,bK,bL,bM,bN,bO,bP,bQ,bR,bS=bA.
commitBeforeMutationLifeCycles,bA.commitPlacement,bA.commitWork,bA.commitDeletion,bA.commitPassiveUnmount,bA.
commitPassiveUnmountInsideDeletedTree,bA.commitPassiveMount,bA.commitDetachRef,bA.invokeLayoutEffectMountInDEV,bA.
invokePassiveEffectMountInDEV,bA.invokeLayoutEffectUnmountInDEV,bA.invokePassiveEffectUnmountInDEV,bA.
recursivelyCommitLayoutEffects,ac(ag.Promise),ac(ab.Parent['ReactUpdateQueue.new']).enqueueUpdate,ac(ab.Parent[
'ReactFiberNewContext.new']).resetContextDependencies,{resetHooksAfterThrowRef=(nil),ContextOnlyDispatcherRef=(nil),
getIsUpdatingOpaqueValueInRenderPhaseInDEVRef=(nil),originalBeginWorkRef=(nil),completeWorkRef=(nil)}local bT,bU,bV=
function(bT,bU,bV)if not bR.originalBeginWorkRef then bR.originalBeginWorkRef=ac(ab.Parent['ReactFiberBeginWork.new']).
beginWork end return bR.originalBeginWorkRef(bT,bU,bV)end,function(bT,bU,bV)if not bR.completeWorkRef then bR.
completeWorkRef=ac(ab.Parent['ReactFiberCompleteWork.new']).completeWork end return(bR.completeWorkRef)(bT,bU,bV)end
local function bW()bV=ac(ab.Parent['ReactFiberHooks.new'])bR.resetHooksAfterThrowRef=bV.resetHooksAfterThrow bR.
ContextOnlyDispatcherRef=bV.ContextOnlyDispatcher bR.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef=bV.
getIsUpdatingOpaqueValueInRenderPhaseInDEV end local bX,bY,bZ,b_,b0,b1,b2,b3,b4,b5,b6=function()if not bR.
resetHooksAfterThrowRef then bW()end return bR.resetHooksAfterThrowRef()end,function()if not bR.ContextOnlyDispatcherRef
then bW()end return bR.ContextOnlyDispatcherRef end,function()if not bR.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef
then bW()end return bR.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef()end,ac(ab.Parent.ReactCapturedValue).
createCapturedValue,aq.push,aq.pop,aq.createCursor,ac(ab.Parent['ReactProfilerTimer.new']),ac(ag.Shared).
getComponentName,ac(ab.Parent['ReactStrictModeWarnings.new']),ac(ab.Parent.ReactCurrentFiber)local b7,b8,b9,c=b6.current
,b6.resetCurrentFiber,b6.setCurrentFiber,ac(ag.Shared).ReactErrorUtils local ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm=c.
invokeGuardedCallback,c.hasCaughtError,c.clearCaughtError,ac(ab.Parent['ReactFiberDevToolsHook.new']).onCommitRoot,ac(ab
.Parent.ReactTestSelectors).onCommitRoot,ac(ag.Shared).enqueueTask,ac(ab.Parent.ReactFiberTreeReflection).
doesFiberContain,az.ReactCurrentDispatcher,az.ReactCurrentOwner,az.IsSomeRendererActing,{}local cn,co,cp,cq,cr,cs,ct,cu=
0b0,0b1,0b10,0b100,0b1000,0b10000,0b100000,0b1000000 ak.NoContext=cn ak.RetryAfterError=cu local cv,cw,cx,cy,cz={
Incomplete=0,FatalErrored=1,Errored=2,Suspended=3,SuspendedWithDelay=4,Completed=5},cn,(an.NoLanes)ak.subtreeRenderLanes
=an.NoLanes local cA,cB,cC,cD,cE=b2(an.NoLanes),cv.Incomplete,an.NoLanes,(ac(ab.Parent.ReactFiberWorkInProgress))local
cF,cG,cH,cI,cJ,cK,cL,cM,cN=cD.workInProgressRootSkippedLanes,an.NoLanes,an.NoLanes,0,500,math.huge,500 local function cO
()cK=aI()+cL end ak.getRenderTargetTime=function()return cK end local cP,cQ,cR,cS,cT,cU,cV,cW,cX,cY,cZ,c_,c0,c1,c2,c3,c4
,c5,c6=false,false,aJ,an.NoLanes,50,0,50,0,a1,an.NoLanes,an.NoLanes,false ak.getWorkInProgressRoot=function()return cy
end ak.requestEventTime=function()if bit32.band(cw,bit32.bor(cs,ct))~=cn then return aI()end if cX~=a1 then return cX
end cX=aI()return cX end ak.requestUpdateLane=function(c7)local c8=c7.mode if bit32.band(c8,aW.BlockingMode)==aW.NoMode
then return a_ elseif bit32.band(c8,aW.ConcurrentMode)==aW.NoMode then return if aE()==aK then a_ else a0 elseif not ar.
deferRenderPhaseUpdateToNextBatch and bit32.band(cw,cs)~=cn and cx~=an.NoLanes then return a9(cx)end if cY==an.NoLanes
then cY=cC end local c9=bs.requestCurrentTransition()~=bs.NoTransition if c9 then if cZ~=an.NoLanes then if cM~=nil then
cZ=cM.pendingLanes else cZ=an.NoLanes end end return a3(cY,cZ)end local d,da=(aE())if bit32.band(cw,cq)~=cn and d==aL
then da=a2(an.InputDiscreteLanePriority,cY)else local db=bq(d)if ar.decoupleUpdatePriorityFromScheduler then local dc=
bg()if db~=dc and dc~=an.NoLanePriority then if ae then ah.error(
[[Expected current scheduler lane priority %s to match current update lane priority %s]],tostring(db),tostring(dc))end
end end da=a2(db,cY)end return da end function requestRetryLane(c7)local c8=c7.mode if bit32.band(c8,aW.BlockingMode)==
aW.NoMode then return a_ elseif bit32.band(c8,aW.ConcurrentMode)==aW.NoMode then return if aE()==aK then a_ else a0 end
if cY==an.NoLanes then cY=cC end return a4(cY)end ak.scheduleUpdateOnFiber=function(c7,c8,c9)ck.checkForNestedUpdates()
local d=ck.markUpdateLaneFromFiberToRoot(c7,c8)if d==nil then return nil end bk(d,c8,c9)if d==cy then ck.
warnAboutRenderPhaseUpdatesInDEV(c7)if ar.deferRenderPhaseUpdateToNextBatch or bit32.band(cw,cs)==cn then cG=a7(cG,c8)
end if cB==cv.SuspendedWithDelay then ck.markRootSuspended(d,cx)end end local da=aE()if c8==a_ then if bit32.band(cw,cr)
~=cn and bit32.band(cw,bit32.bor(cs,ct))==cn then ck.schedulePendingInteractions(d,c8)ck.performSyncWorkOnRoot(d)else
bS(d,c9)ck.schedulePendingInteractions(d,c8)if cw==cn then cO()aN()end end else if bit32.band(cw,cq)~=cn and(da==aL or
da==aK)then if c3==nil then c3=aj.new{d}else c3:add(d)end end bS(d,c9)ck.schedulePendingInteractions(d,c8)end cM=d
return d end ck.markUpdateLaneFromFiberToRoot=function(c7,c8)c7.lanes=a7(c7.lanes,c8)local c9=c7.alternate if c9~=nil
then c9.lanes=a7(c9.lanes,c8)end if ae then if c9==nil and bit32.band(c7.flags,bit32.bor(aZ.Placement,aZ.Hydrating))~=aZ
.NoFlags then ck.warnAboutUpdateOnNotYetMountedFiberInDEV(c7)end end local d,da=c7,c7.return_ while da~=nil do da.
childLanes=a7(da.childLanes,c8)c9=da.alternate if c9~=nil then c9.childLanes=a7(c9.childLanes,c8)else if ae then if
bit32.band(da.flags,bit32.bor(aZ.Placement,aZ.Hydrating))~=aZ.NoFlags then ck.warnAboutUpdateOnNotYetMountedFiberInDEV(
c7)end end end d=da da=da.return_ end if d.tag==aX.HostRoot then local db=d.stateNode return db else return nil end end
bS=function(c7,c8)local c9=c7.callbackNode bh(c7,c8)local d if c7==cy then d=cx else d=an.NoLanes end local da,db=bd(c7,
d),be()if da==an.NoLanes then if c9~=nil then aD(c9)c7.callbackNode=nil c7.callbackPriority=an.NoLanePriority end return
end if c9~=nil then local dc=c7.callbackPriority if dc==db then return end aD(c9)end local dc if db==an.SyncLanePriority
then dc=aO(function()return ck.performSyncWorkOnRoot(c7)end)elseif db==an.SyncBatchedLanePriority then dc=aC(aK,function
()return ck.performSyncWorkOnRoot(c7)end)else local dd=br(db)dc=aC(dd,function()return ck.performConcurrentWorkOnRoot(c7
)end)end c7.callbackPriority=db c7.callbackNode=dc end ck.performConcurrentWorkOnRoot=function(c7)cX=a1 cY=an.NoLanes cZ
=an.NoLanes aA(bit32.band(cw,bit32.bor(cs,ct))==cn,'Should not already be working.')local c8,c9=c7.callbackNode,ak.
flushPassiveEffects()if c9 then if c7.callbackNode~=c8 then return nil end end local d=bd(c7,if c7==cy then cx else an.
NoLanes)if d==an.NoLanes then return nil end local da=ck.renderRootConcurrent(c7,d)if a5(cC,cG)then ck.
prepareFreshStack(c7,an.NoLanes)elseif da~=cv.Incomplete then if da==cv.Errored then cw=bit32.bor(cw,cu)if c7.hydrate
then c7.hydrate=false aU.clearContainer(c7.containerInfo)end d=bi(c7)if d~=an.NoLanes then da=ck.renderRootSync(c7,d)end
end if da==cv.FatalErrored then local db=cE ck.prepareFreshStack(c7,an.NoLanes)ck.markRootSuspended(c7,d)bS(c7,aI())
error(db)end local db=c7.current.alternate c7.finishedWork=db c7.finishedLanes=d ck.finishConcurrentRender(c7,da,d)end
bS(c7,aI())if c7.callbackNode==c8 then return function()return ck.performConcurrentWorkOnRoot(c7)end end return nil end
local c7,c8=0,false function shouldForceFlushFallbacksInDEV()return ae and c7>0 end ck.finishConcurrentRender=function(
c9,d,da)if d==cv.Incomplete or d==cv.FatalErrored then aA(false,'Root did not complete. This is a bug in React.')elseif
d==cv.Errored then ck.commitRoot(c9)elseif d==cv.Suspended then ck.markRootSuspended(c9,da)if bb(da)and not
shouldForceFlushFallbacksInDEV()then local db=cI+cJ-aI()if db>10 then local dc=bd(c9,an.NoLanes)if dc~=an.NoLanes then
return end local dd=c9.suspendedLanes if not a6(dd,da)then local dg=ak.requestEventTime()bm(c9,dd,dg)return end c9.
timeoutHandle=aU.scheduleTimeout(function()return ck.commitRoot(c9)end,db)return end end ck.commitRoot(c9)elseif d==cv.
SuspendedWithDelay then ck.markRootSuspended(c9,da)if bc(da)then return end if not shouldForceFlushFallbacksInDEV()then
local db=bj(c9,da)local dc=db local dd=aI()-dc local dg=jnd(dd)-dd if dg>10 then c9.timeoutHandle=aU.scheduleTimeout(
function()return ck.commitRoot(c9)end,dg)return end end ck.commitRoot(c9)elseif d==cv.Completed then ck.commitRoot(c9)
else aA(false,'Unknown root exit status.')end end ck.markRootSuspended=function(c9,d)d=a8(d,cH)d=a8(d,cG)bl(c9,d)end ck.
performSyncWorkOnRoot=function(c9)aA(bit32.band(cw,bit32.bor(cs,ct))==cn,'Should not already be working.')ak.
flushPassiveEffects()local d,da if c9==cy and a5(c9.expiredLanes,cx)then d=cx da=ck.renderRootSync(c9,d)if a5(cC,cG)then
d=bd(c9,d)da=ck.renderRootSync(c9,d)end else d=bd(c9,an.NoLanes)da=ck.renderRootSync(c9,d)end if c9.tag~=aY and da==cv.
Errored then cw=bit32.bor(cw,cu)if c9.hydrate then c9.hydrate=false aU.clearContainer(c9.containerInfo)end d=bi(c9)if d
~=an.NoLanes then da=ck.renderRootSync(c9,d)end end if da==cv.FatalErrored then local db=cE ck.prepareFreshStack(c9,an.
NoLanes)ck.markRootSuspended(c9,d)bS(c9,aI())error(db)end local db=c9.current.alternate c9.finishedWork=db c9.
finishedLanes=d ck.commitRoot(c9)bS(c9,aI())return nil end ak.flushRoot=function(c9,d)bn(c9,d)bS(c9,aI())if bit32.band(
cw,bit32.bor(cs,ct))==cn then cO()aN()end end ak.getExecutionContext=function()return cw end ak.flushDiscreteUpdates=
function()if bit32.band(cw,bit32.bor(co,cs,ct))~=cn then if ae then if bit32.band(cw,cs)~=cn then ah.error
[[unstable_flushDiscreteUpdates: Cannot flush updates when React is already rendering.]]end end return end ck.
flushPendingDiscreteUpdates()ak.flushPassiveEffects()end ak.deferredUpdates=function(c9)if ar.
decoupleUpdatePriorityFromScheduler then local d,da,db=(bg())if not af then bf(an.DefaultLanePriority)da,db=xpcall(aF,ax
,aM,c9)else da=true bf(an.DefaultLanePriority)db=aF(aM,c9)end bf(d)if da then return db else error(db)end else return
aF(aM,c9)end end ck.flushPendingDiscreteUpdates=function()if c3~=nil then local c9=c3 c3=nil c9:forEach(function(d)bo(d)
bS(d,aI())end)end aN()end ak.batchedUpdates=function(c9,d)local da=cw cw=bit32.bor(cw,co)local db,dc if not af then db,
dc=xpcall(c9,ax,d)else db=true dc=c9(d)end cw=da if cw==cn then cO()aN()end if db then return dc else error(dc)end end
ak.batchedEventUpdates=function(c9,d)local da=cw cw=bit32.bor(cw,cp)local db,dc if not af then db,dc=xpcall(c9,ax,d)else
db=true dc=c9(d)end cw=da if cw==cn then cO()aN()end if db then return dc else error(dc)end end ak.discreteUpdates=
function(c9,d,da,db,dc)local dd=cw cw=bit32.bor(cw,cq)if ar.decoupleUpdatePriorityFromScheduler then local dg=bg()bf(an.
InputDiscreteLanePriority)local dh,di=xpcall(aF,ax,aL,function()return c9(d,da,db,dc)end)bf(dg)cw=dd if cw==cn then cO()
aN()end if dh then return di else error(di)end else local dg,dh=xpcall(aF,ax,aL,function()return c9(d,da,db,dc)end)cw=dd
if cw==cn then cO()aN()end if dg then return dh else error(dh)end end end ak.unbatchedUpdates=function(c9,d)local da=cw
cw=bit32.band(cw,bit32.bnot(co))cw=bit32.bor(cw,cr)local db,dc if not af then db,dc=xpcall(c9,ax,d)else db=true dc=c9(d)
end cw=da if cw==cn then cO()aN()end if db then return dc else error(dc)end end ak.flushSync=function(c9,d)local da=cw
if(bit32.band(da,bit32.bor(cs,ct)))~=cn then if ae then ah.error
[[flushSync was called from inside a lifecycle method. React cannot flush when React is already rendering. Consider moving this call to a scheduler task or micro task.]]
end return c9(d)end cw=bit32.bor(cw,co)if ar.decoupleUpdatePriorityFromScheduler then local db=bg()bf(an.
SyncLanePriority)local dc,dd if not af then if c9 then dc,dd=xpcall(aF,ax,aK,function()return c9(d)end)else dc=true dd=
nil end else dc=true bf(an.SyncLanePriority)if c9 then dd=aF(aK,function()return c9(d)end)else dd=nil end end bf(db)cw=
da aN()if not dc then error(dd)end return dd else local db,dc if not af then if c9 then db,dc=xpcall(aF,ax,aK,function()
return c9(d)end)else db=true dc=nil end else db=true if c9 then dc=aF(aK,function()return c9(d)end)else dc=nil end end
cw=da aN()if not db then error(dc)end return dc end end ak.flushControlled=function(c9)local d=cw cw=bit32.bor(cw,co)if
ar.decoupleUpdatePriorityFromScheduler then local da=bg()bf(an.SyncLanePriority)local db,dc=xpcall(aF,ax,aK,c9)bf(da)cw=
d if cw==cn then cO()aN()end if not db then error(dc)end else local da,db=xpcall(aF,ax,aK,c9)cw=d if cw==cn then cO()aN(
)end if not da then error(db)end end end ak.pushRenderLanes=function(c9,d)b0(cA,ak.subtreeRenderLanes,c9)ak.
subtreeRenderLanes=a7(ak.subtreeRenderLanes,d)cC=a7(cC,d)end ak.popRenderLanes=function(c9)ak.subtreeRenderLanes=cA.
current b1(cA,c9)end ck.prepareFreshStack=function(c9,d)c9.finishedWork=nil c9.finishedLanes=an.NoLanes local da=c9.
timeoutHandle if da~=aU.noTimeout then c9.timeoutHandle=aU.noTimeout aU.cancelTimeout(da)end if cz~=nil then local db=cz
.return_ while db~=nil do bv(db)db=db.return_ end end cy=c9 cz=aV.createWorkInProgress(c9.current,nil)cx=d ak.
subtreeRenderLanes=d cC=d cB=cv.Incomplete cE=nil cF(an.NoLanes)cG=an.NoLanes cH=an.NoLanes if ar.enableSchedulerTracing
then c5=nil end if ae then b5.discardPendingWarnings()end end ck.handleError=function(c9,d)while true do local da=cz
local db,dc=pcall(function()bQ()bX()b8()ci.current=nil if da==nil or da.return_==nil then cB=cv.FatalErrored cE=d cz=nil
return end if ar.enableProfilerTimer and bit32.band((da).mode,aW.ProfileMode)~=0 then b3.
stopProfilerTimerIfRunningAndRecordDelta(da,true)end bx(c9,(da).return_,da,d,cx,ak.onUncaughtError,ak.renderDidError)ck.
completeUnitOfWork(da)end)if not db then d=dc if cz==da and da~=nil then da=da.return_ cz=da else da=cz end continue end
return end end ck.pushDispatcher=function()local c9=ch.current ch.current=bY()if c9==nil then return bY()else return c9
end end ck.popDispatcher=function(c9)ch.current=c9 end ck.pushInteractions=function(c9)if ar.enableSchedulerTracing then
local d=aS.current aS.current=c9.memoizedInteractions return d end return nil end ck.popInteractions=function(c9)if ar.
enableSchedulerTracing then aS.current=c9 end end ak.markCommitTimeOfFallback=function()cI=aI()end ak.
markSkippedUpdateLanes=function(c9)cD.markSkippedUpdateLanes(c9)end ak.renderDidSuspend=function()if cB==cv.Incomplete
then cB=cv.Suspended end end ak.renderDidSuspendDelayIfPossible=function()if cB==cv.Incomplete or cB==cv.Suspended then
cB=cv.SuspendedWithDelay end if cy~=nil and(ba(cF())or ba(cG))then ck.markRootSuspended(cy,cx)end end ak.renderDidError=
function()if cB~=cv.Completed then cB=cv.Errored end end ak.renderHasNotSuspendedYet=function()return cB==cv.Incomplete
end ck.renderRootSync=function(c9,d)local da=cw cw=bit32.bor(cw,cs)local db=ck.pushDispatcher()if cy~=c9 or cx~=d then
ck.prepareFreshStack(c9,d)ck.startWorkOnPendingInteractions(c9,d)end local dc=ck.pushInteractions(c9)if ae then if as
then aP.logRenderStarted(d)end end if at then aQ.markRenderStarted(d)end while true do local dd,dg if not af then dd,dg=
xpcall(ck.workLoopSync,ax)else dd=true ck.workLoopSync()end if not dd then ck.handleError(c9,dg)else break end end bQ()
if ar.enableSchedulerTracing then ck.popInteractions(dc)end cw=da ck.popDispatcher(db)if cz~=nil then aA(false,
[[Cannot commit an incomplete root. This error is likely caused by a bug in React. Please file an issue.]])end if ae
then if as then aP.logRenderStopped()end end if at then aQ.markRenderStopped()end cy=nil cx=an.NoLanes return cB end ck.
workLoopSync=function()while cz~=nil do ck.performUnitOfWork(cz)end end ck.renderRootConcurrent=function(c9,d)local da=
cw cw=bit32.bor(cw,cs)local db=ck.pushDispatcher()if cy~=c9 or cx~=d then cO()ck.prepareFreshStack(c9,d)ck.
startWorkOnPendingInteractions(c9,d)end local dc=ck.pushInteractions(c9)if ae then if as then aP.logRenderStarted(d)end
end if at then aQ.markRenderStarted(d)end while true do local dd,dg if not af then dd,dg=xpcall(ck.workLoopConcurrent,ax
)if dd then dg='break'end else dd=true dg='break'ck.workLoopConcurrent()end if dg=='break'then break end if not dd then
ck.handleError(c9,dg)end end bQ()if ar.enableSchedulerTracing then ck.popInteractions(dc)end ck.popDispatcher(db)cw=da
if ae then if as then aP.logRenderStopped()end end if cz~=nil then if at then aQ.markRenderYielded()end return cv.
Incomplete else if at then aQ.markRenderStopped()end cy=nil cx=an.NoLanes return cB end end ck.workLoopConcurrent=
function()while cz~=nil and not aG()do ck.performUnitOfWork(cz)end end ck.performUnitOfWork=function(c9)local d=c9.
alternate b9(c9)local da if ar.enableProfilerTimer and bit32.band(c9.mode,aW.ProfileMode)~=aW.NoMode then b3.
startProfilerTimer(c9)da=ck.beginWork(d,c9,ak.subtreeRenderLanes)b3.stopProfilerTimerIfRunningAndRecordDelta(c9,true)
else da=ck.beginWork(d,c9,ak.subtreeRenderLanes)end b8()c9.memoizedProps=c9.pendingProps if da==nil then ck.
completeUnitOfWork(c9)else cz=da end ci.current=nil end ck.completeUnitOfWork=function(c9)local d=c9 repeat local da,db=
d.alternate,d.return_ if bit32.band(d.flags,aZ.Incomplete)==aZ.NoFlags then b9(d)local dc if not ar.enableProfilerTimer
or bit32.band(d.mode,aW.ProfileMode)==aW.NoMode then dc=bU(da,d,ak.subtreeRenderLanes)else b3.startProfilerTimer(d)dc=
bU(da,d,ak.subtreeRenderLanes)b3.stopProfilerTimerIfRunningAndRecordDelta(d,false)end b8()if dc~=nil then cz=dc return
end else local dc=bu(d,ak.subtreeRenderLanes)if dc~=nil then dc.flags=bit32.band(dc.flags,aZ.HostEffectMask)cz=dc return
end if ar.enableProfilerTimer and bit32.band(d.mode,aW.ProfileMode)~=aW.NoMode then b3.
stopProfilerTimerIfRunningAndRecordDelta(d,false)local dd,dg=d.actualDuration or 0,d.child while dg~=nil do dd+=dg.
actualDuration or 0 dg=dg.sibling end d.actualDuration=dd end if db~=nil then db.flags=bit32.bor(db.flags,aZ.Incomplete)
db.subtreeFlags=aZ.NoFlags db.deletions=nil end end local dc=d.sibling if dc~=nil then cz=dc return end d=db cz=d until
d==nil if cB==cv.Incomplete then cB=cv.Completed end end ck.commitRoot=function(c9)local d=aE()aF(aK,function()return ck
.commitRootImpl(c9,d)end)return nil end ck.commitRootImpl=function(c9,d)repeat ak.flushPassiveEffects()until c2==nil
flushRenderPhaseStrictModeWarningsInDEV()aA(bit32.band(cw,bit32.bor(cs,ct))==cn,'Should not already be working.')local
da,db=c9.finishedWork,c9.finishedLanes if ae then if as then aP.logCommitStarted(db)end end if at then aQ.
markCommitStarted(db)end if da==nil then if ae then if as then aP.logCommitStopped()end end if at then aQ.
markCommitStopped()end return nil end c9.finishedWork=nil c9.finishedLanes=an.NoLanes aA(da~=c9.current,
[[Cannot commit the same tree as before. This error is likely caused by a bug in React. Please file an issue.]])c9.
callbackNode=nil local dc=a7(da.lanes,da.childLanes)bp(c9,dc)if c3~=nil then if not b(dc)and c3:has(c9)then c3:delete(c9
)end end if c9==cy then cy=nil cz=nil cx=an.NoLanes end local dd,dg=bit32.band(da.subtreeFlags,bit32.bor(aZ.
BeforeMutationMask,aZ.MutationMask,aZ.LayoutMask,aZ.PassiveMask))~=aZ.NoFlags,bit32.band(da.flags,bit32.bor(aZ.
BeforeMutationMask,aZ.MutationMask,aZ.LayoutMask,aZ.PassiveMask))~=aZ.NoFlags if dd or dg then local dh if ar.
decoupleUpdatePriorityFromScheduler then dh=bg()bf(an.SyncLanePriority)end local di=cw cw=bit32.bor(cw,ct)local dj=ck.
pushInteractions(c9)ci.current=nil c6=aU.prepareForCommit(c9.containerInfo)c_=false ck.commitBeforeMutationEffects(da)c6
=nil if ar.enableProfilerTimer then b3.recordCommitTime()end ck.commitMutationEffects(da,c9,d)if c_ then aU.
afterActiveInstanceBlur()end aU.resetAfterCommit(c9.containerInfo)c9.current=da if ae then if as then aP.
logLayoutEffectsStarted(db)end end if at then aQ.markLayoutEffectsStarted(db)end if ae then b9(da)ca(nil,bN,nil,da,c9,ak
.captureCommitPhaseError,ak.schedulePassiveEffectCallback)if cb()then local dk=cc()cl(da,da,dk)end b8()else local dk,dl
if not af then dk,dl=xpcall(bN,ax,da,c9,ak.captureCommitPhaseError,ak.schedulePassiveEffectCallback)else dk=true bN(da,
c9,ak.captureCommitPhaseError,ak.schedulePassiveEffectCallback)end if not dk then cl(da,da,dl)end end if ae then if as
then aP.logLayoutEffectsStopped()end end if at then aQ.markLayoutEffectsStopped()end if bit32.band(da.subtreeFlags,aZ.
PassiveMask)~=aZ.NoFlags or bit32.band(da.flags,aZ.PassiveMask)~=aZ.NoFlags then if not cQ then cQ=true aC(aM,function()
ak.flushPassiveEffects()return nil end)end end aH()if ar.enableSchedulerTracing then ck.popInteractions(dj)end cw=di if
ar.decoupleUpdatePriorityFromScheduler and dh~=nil then bf(dh)end else c9.current=da if ar.enableProfilerTimer then b3.
recordCommitTime()end end local dh=cQ if cQ then cQ=false c2=c9 cS=db cR=d end dc=c9.pendingLanes if dc~=an.NoLanes then
if ar.enableSchedulerTracing then if c5~=nil then local di=c5 c5=nil for dj=1,#di do scheduleInteractions(c9,di[dj],c9.
memoizedInteractions)end end ck.schedulePendingInteractions(c9,dc)end else c1=nil end if ae and av then if not dh then
commitDoubleInvokeEffectsInDEV(c9.current,false)end end if ar.enableSchedulerTracing then if not dh then ck.
finishPendingInteractions(c9,db)end end if dc==a_ then if c9==c4 then cU+=1 else cU=0 c4=c9 end else cU=0 end cd(da.
stateNode,d)if ae then ce()end bS(c9,aI())if cP then cP=false local di=c0 c0=nil error(di)end if bit32.band(cw,cr)~=cn
then if ae then if as then aP.logCommitStopped()end end if at then aQ.markCommitStopped()end return nil end aN()if ae
then if as then aP.logCommitStopped()end end if at then aQ.markCommitStopped()end return nil end ck.
commitBeforeMutationEffects=function(c9)local d=c9 while d~=nil do if d.deletions~=nil then ck.
commitBeforeMutationEffectsDeletions(d.deletions)end if d.child~=nil then local da=bit32.band(d.subtreeFlags,aZ.
BeforeMutationMask)if da~=aZ.NoFlags then ck.commitBeforeMutationEffects(d.child)end end if ae then b9(d)ca(nil,ck.
commitBeforeMutationEffectsImpl,nil,d)if cb()then local da=cc()ak.captureCommitPhaseError(d,d.return_,da)end b8()else
local da,db if not af then da,db=xpcall(ck.commitBeforeMutationEffectsImpl,ax,d)else da=true ck.
commitBeforeMutationEffectsImpl(d)end if not da then ak.captureCommitPhaseError(d,d.return_,db)end end d=d.sibling end
end ck.commitBeforeMutationEffectsImpl=function(c9)local d,da=c9.alternate,c9.flags if not c_ and c6~=nil then if c9.tag
==aX.SuspenseComponent and bA.isSuspenseBoundaryBeingHidden(d,c9)and cg(c9,c6)then c_=true aU.beforeActiveInstanceBlur()
end end if bit32.band(da,aZ.Snapshot)~=aZ.NoFlags then b9(c9)bB(d,c9)b8()end if bit32.band(da,aZ.Passive)~=aZ.NoFlags
then if not cQ then cQ=true aC(aM,function()ak.flushPassiveEffects()return nil end)end end end ck.
commitBeforeMutationEffectsDeletions=function(c9)for d=1,#c9 do local da=c9[d]if cg(da,(c6))then c_=true aU.
beforeActiveInstanceBlur()end end end ck.commitMutationEffects=function(c9,d,da)local db=c9 while db~=nil do local dc=db
.deletions if dc~=nil then for dd,dg in dc do local dh,di=xpcall(bE,ax,d,dg,db,da)if not dh then ak.
captureCommitPhaseError(dg,db,di)end end end if db.child~=nil then local dd=bit32.band(db.subtreeFlags,aZ.MutationMask)
if dd~=aZ.NoFlags then ck.commitMutationEffects(db.child,d,da)end end if ae then b9(db)ca(nil,ck.
commitMutationEffectsImpl,nil,db,d,da)if cb()then local dd=cc()ak.captureCommitPhaseError(db,db.return_,dd)end b8()else
local dd,dg if not af then dd,dg=xpcall(ck.commitMutationEffectsImpl,ax,db,d,da)else dd=true ck.
commitMutationEffectsImpl(db,d,da)end if not dd then ak.captureCommitPhaseError(db,db.return_,dg)end end db=db.sibling
end end ck.commitMutationEffectsImpl=function(c9,d,da)local db=c9.flags if bit32.band(db,aZ.Ref)~=0 then local dc=c9.
alternate if dc~=nil then bI(dc)end end local dc=bit32.band(db,bit32.bor(aZ.Placement,aZ.Update,aZ.Hydrating))if dc==aZ.
Placement then bC(c9)c9.flags=bit32.band(c9.flags,bit32.bnot(aZ.Placement))elseif dc==aZ.PlacementAndUpdate then bC(c9)
c9.flags=bit32.band(c9.flags,bit32.bnot(aZ.Placement))local dd=c9.alternate bD(dd,c9)elseif dc==aZ.Update then local dd=
c9.alternate bD(dd,c9)end end ck.commitMutationEffectsDeletions=function(c9,d,da,db)for dc,dd in c9 do local dg,dh=
xpcall(bE,ax,da,dd,d,db)if not dg then ak.captureCommitPhaseError(dd,d,dh)end end end ak.schedulePassiveEffectCallback=
function()if not cQ then cQ=true aC(aM,function()ak.flushPassiveEffects()return nil end)end end local c9 ak.
flushPassiveEffects=function()if cR~=aJ then local d=if cR>aM then aM else cR cR=aJ if ar.
decoupleUpdatePriorityFromScheduler then local da=bg()bf(bq(d))local db,dc if not af then db,dc=xpcall(aF,ax,d,c9)else
db=true bf(bq(d))dc=aF(d,c9)end bf(da)if not db then error(dc)end return dc else return aF(d,c9)end end return false end
cm=function(d,da)local db=da while db~=nil do local dc if ar.enableProfilerTimer and ar.enableProfilerCommitHooks then
if db.tag==aX.Profiler then dc=cN cN=db end end local dd=bit32.band(db.subtreeFlags,aZ.PassiveMask)if db.child~=nil and
dd~=aZ.NoFlags then cm(d,db.child)end if bit32.band(db.flags,aZ.Passive)~=aZ.NoFlags then if ae then b9(db)ca(nil,bH,nil
,d,db)if cb()then local dg=cc()ak.captureCommitPhaseError(db,db.return_,dg)end b8()else local dg,dh if not af then dg,dh
=xpcall(bH,ax,d,db)else dg=true bH(d,db)end if not dg then ak.captureCommitPhaseError(db,db.return_,dh)end end end if ar
.enableProfilerTimer and ar.enableProfilerCommitHooks then if db.tag==aX.Profiler then if dc~=nil then dc.stateNode.
passiveEffectDuration+=db.stateNode.passiveEffectDuration end cN=dc end end db=db.sibling end end local function d(da)
local db=da while db~=nil do local dc=db.deletions if dc~=nil then for dd=1,#dc do local dg=dc[dd]ck.
flushPassiveUnmountEffectsInsideOfDeletedTree(dg,db)ck.detachFiberAfterEffects(dg)end end local dd=db.child if dd~=nil
then local dg=bit32.band(db.subtreeFlags,aZ.PassiveMask)if dg~=aZ.NoFlags then d(dd)end end local dg=bit32.band(db.flags
,aZ.Passive)if dg~=aZ.NoFlags then b9(db)bF(db)b8()end db=db.sibling end end ck.
flushPassiveUnmountEffectsInsideOfDeletedTree=function(da,db)if bit32.band(da.subtreeFlags,aZ.PassiveStatic)~=aZ.NoFlags
then local dc=da.child while dc~=nil do ck.flushPassiveUnmountEffectsInsideOfDeletedTree(dc,db)dc=dc.sibling end end if
bit32.band(da.flags,aZ.PassiveStatic)~=aZ.NoFlags then b9(da)bG(da,db)b8()end end c9=function()if c2==nil then return
false end local da,db=c2,cS c2=nil cS=an.NoLanes aA(bit32.band(cw,bit32.bor(cs,ct))==cn,
'Cannot flush passive effects while already rendering.')if ae then if as then aP.logPassiveEffectsStarted(db)end end if
at then aQ.markPassiveEffectsStarted(db)end local dc=cw cw=bit32.bor(cw,ct)local dd=ck.pushInteractions(da)d(da.current)
cm(da,da.current)if ae then if as then aP.logPassiveEffectsStopped()end end if at then aQ.markPassiveEffectsStopped()end
if ae and av then commitDoubleInvokeEffectsInDEV(da.current,true)end if ar.enableSchedulerTracing then ck.
popInteractions(dd)ck.finishPendingInteractions(da,db)end cw=dc aN()if c2==nil then cW=0 else cW=cW+1 end return true
end ak.isAlreadyFailedLegacyErrorBoundary=function(da)return c1~=nil and c1:has(da)end ak.
markLegacyErrorBoundaryAsFailed=function(da)if c1==nil then c1=aj.new{da}else c1:add(da)end end local function da(db)if
not cP then cP=true c0=db end end ak.onUncaughtError=da cl=function(db,dc,dd)local dg=b_(dd,dc)local dh=by(db,dg,a_,ak.
onUncaughtError)bP(db,dh)local di,dj=ak.requestEventTime(),ck.markUpdateLaneFromFiberToRoot(db,a_)if dj~=nil then bk(dj,
a_,di)bS(dj,di)ck.schedulePendingInteractions(dj,a_)end end ak.captureCommitPhaseError=function(db,dc,dd)if db.tag==aX.
HostRoot then cl(db,db,dd)return end local dg if au then dg=dc else dg=db.return_ end while dg~=nil do if dg.tag==aX.
HostRoot then cl(dg,db,dd)return else if dg.tag==aX.ClassComponent then local dh,di=dg.type,dg.stateNode if typeof(dh.
getDerivedStateFromError)=='function'or(typeof(di.componentDidCatch)=='function'and not ak.
isAlreadyFailedLegacyErrorBoundary(di))then local dj=b_(dd,db)local dk=bz(dg,dj,a_)bP(dg,dk)local dl,dm=ak.
requestEventTime(),ck.markUpdateLaneFromFiberToRoot(dg,a_)if dm~=nil then bk(dm,a_,dl)bS(dm,dl)ck.
schedulePendingInteractions(dm,a_)end return end end dg=dg.return_ end end end ak.pingSuspendedRoot=function(db,dc,dd)
local dg=db.pingCache if dg~=nil then dg[dc]=nil end local dh=ak.requestEventTime()bm(db,dd,dh)if cy==db and a6(cx,dd)
then if cB==cv.SuspendedWithDelay or cB==cv.Suspended and bb(cx)and aI()-cI<cJ then ck.prepareFreshStack(db,an.NoLanes)
else cH=a7(cH,dd)end end bS(db,dh)ck.schedulePendingInteractions(db,dd)end function retryTimedOutBoundary(db,dc)if dc==
an.NoLane then dc=requestRetryLane(db)end local dd,dg=ak.requestEventTime(),ck.markUpdateLaneFromFiberToRoot(db,dc)if dg
~=nil then bk(dg,dc,dd)bS(dg,dd)ck.schedulePendingInteractions(dg,dc)end end ak.resolveRetryWakeable=function(db,dc)
local dd,dg=(an.NoLane)dg=db.stateNode if dg~=nil then dg:delete(dc)end retryTimedOutBoundary(db,dd)end function jnd(db)
if db<120 then return 120 elseif db<480 then return 480 elseif db<1080 then return 1080 elseif db<1920 then return 1920
elseif db<3000 then return 3000 elseif db<4320 then return 4320 else return math.ceil(db/1960)*1960 end end ck.
checkForNestedUpdates=function()if cU>cT then cU=0 c4=nil aA(false,
[[Maximum update depth exceeded. This can happen when a component repeatedly calls setState inside componentWillUpdate or componentDidUpdate. React limits the number of nested updates to prevent infinite loops.]]
)end if ae then if cW>cV then cW=0 ah.error
[[Maximum update depth exceeded. This can happen when a component calls setState inside useEffect, but useEffect either doesn't have a dependency array, or one of the dependencies changes on every render.]]
end end end function flushRenderPhaseStrictModeWarningsInDEV()if ae then b5.flushLegacyContextWarning()if ar.
warnAboutDeprecatedLifecycles then b5.flushPendingUnsafeLifecycleWarnings()end end end function
commitDoubleInvokeEffectsInDEV(db,dc)if ae and av then b9(db)invokeEffectsInDev(db,aZ.MountLayoutDev,bL)if dc then
invokeEffectsInDev(db,aZ.MountPassiveDev,bM)end invokeEffectsInDev(db,aZ.MountLayoutDev,bJ)if dc then
invokeEffectsInDev(db,aZ.MountPassiveDev,bK)end b8()end end function invokeEffectsInDev(db,dc,dd)if ae and av then local
dg=db while dg~=nil do if dg.child~=nil then local dh=bit32.band(dg.subtreeFlags,dc)if dh~=aZ.NoFlags then
invokeEffectsInDev(dg.child,dc,dd)end end if bit32.band(dg.flags,dc)~=aZ.NoFlags then dd(dg)end dg=dg.sibling end end
end local db ck.warnAboutUpdateOnNotYetMountedFiberInDEV=function(dc)if ae then if bit32.band(cw,cs)~=cn then return end
if bit32.band(dc.mode,bit32.bor(aW.BlockingMode,aW.ConcurrentMode))==0 then return end local dd=dc.tag if dd~=aX.
IndeterminateComponent and dd~=aX.HostRoot and dd~=aX.ClassComponent and dd~=aX.FunctionComponent and dd~=aX.ForwardRef
and dd~=aX.MemoComponent and dd~=aX.SimpleMemoComponent and dd~=aX.Block then return end local dg=b4(dc.type)or
'ReactComponent'if db~=nil then if db[dg]then return end db[dg]=true else db={[dg]=true}end local dh,di,dj=b6.current,
pcall(function()b9(dc)ah.error
[[Can't perform a React state update on a component that hasn't mounted yet. This indicates that you have a side-effect in your render function that asynchronously later calls tries to update the component. Move this work to useEffect instead.]]
end)if dh then b9(dc)else b8()end if not di then error(dj)end end end if ae and ar.
replayFailedUnitOfWorkWithInvokeGuardedCallback then local dc ck.beginWork=function(dd,dg,dh)local di,dj,dk=aV.
assignFiberPropertiesInDEV(dc,dg),xpcall(bT,ax,dd,dg,dh)if not dj then local dl=dk if dl~=nil and typeof(dl)=='table'and
typeof(dl.andThen)=='function'then error(dl)end bQ()bX()bv(dg)aV.assignFiberPropertiesInDEV(dg,di)if ar.
enableProfilerTimer and bit32.band(dg.mode,aW.ProfileMode)~=0 then b3.startProfilerTimer(dg)end ca(nil,bT,nil,dd,dg,dh)
if cb()then local dm=cc()error(dm)else error(dl)end end return dk end else ck.beginWork=bT end local dc,dd=false if ae
then dd={}end ck.warnAboutRenderPhaseUpdatesInDEV=function(dg)if ae then if b6.isRendering and bit32.band(cw,cs)~=cn and
not bZ()then if dg.tag==aX.FunctionComponent or dg.tag==aX.ForwardRef or dg.tag==aX.SimpleMemoComponent then local dh=(
function()if cz~=nil then return b4((cz).type)end return'Unknown'end)()local di=dh if dd[di]==nil then dd[di]=true local
dj=b4(dg.type)or'Unknown'ah.error(
[[Cannot update a component (`%s`) while rendering a different component (`%s`). To locate the bad setState() call inside `%s`, follow the stack trace as described in https://reactjs.org/link/setstate-in-render]]
,dj,dh,dh)end elseif dg.tag==aX.ClassComponent then if not dc then ah.error
[[Cannot update during an existing state transition (such as within `render`). Render methods should be a pure function of props and state.]]
dc=true end end end end end ak.IsThisRendererActing={current=false}ak.warnIfNotScopedWithMatchingAct=function(dg)if ae
then if aU.warnsIfNotActing==true and cj.current==true and ak.IsThisRendererActing.current~=true then local dh,di,dj=b6.
current,pcall(function()b9(dg)ah.error
[[It looks like you're using the wrong act() around your test interactions.
Be sure to use the matching version of act() corresponding to your renderer:

-- for react-roblox:
local React = require(Packages.React)
-- ...
React.TestUtils.act(function() ... end)

-- for react-test-renderer:
local TestRenderer = require(Packages.ReactTestRenderer)
-- ...
TestRenderer.act(function() ... end)]]
end)if dh then b9(dg)else b8()end if not di then error(dj)end end end end ak.warnIfNotCurrentlyActingEffectsInDEV=
function(dg)if ae then if aU.warnsIfNotActing==true and bit32.band(dg.mode,aW.StrictMode)~=aW.NoMode and cj.current==
false and ak.IsThisRendererActing.current==false then ah.error(
[=[An update to %s ran an effect, but was not wrapped in act(...).

When testing, code that causes React state updates should be wrapped into act(...):

act(function()
  --[[ fire events that update state ]]
end)
--[[ assert on the output ]]

This ensures that you're testing the behavior the user would see in the real client. Learn more at https://reactjs.org/link/wrap-tests-with-act]=]
,b4(dg.type))end end end ak.warnIfNotCurrentlyActingUpdatesInDEV=function(dg)if ae then if aU.warnsIfNotActing==true and
cw==cn and cj.current==false and ak.IsThisRendererActing.current==false then local dh,di,dj=b7,pcall(function()b9(dg)ah.
error(
[=[An update to %s inside a test was not wrapped in act(...).

When testing, code that causes React state updates should be wrapped into act(...):

act(function()
  --[[ fire events that update state ]]
end)
--[[ assert on the output ]]

This ensures that you're testing the behavior the user would see in the client application. Learn more at https://reactjs.org/link/wrap-tests-with-act]=]
,b4(dg.type))end)if dh then b9(dg)else b8()end if di then return dj end end end return end local dg=false ak.
warnIfUnmockedScheduler=function(dh)if ae then if dg==false and ao.unstable_flushAllWithoutAsserting==nil then if bit32.
band(dh.mode,aW.BlockingMode)~=0 or bit32.band(dh.mode,aW.ConcurrentMode)~=0 then dg=true ah.error
[[In Concurrent or Sync modes, the 'scheduler' module needs to be mocked to guarantee consistent behaviour across tests and client application. For example, with Jest: 
jest.mock('scheduler', function() return require(Packages.Scheduler).unstable_mock end)

For more info, visit https://reactjs.org/link/mock-scheduler]]
elseif ar.warnAboutUnmockedScheduler==true then dg=true ah.error
[[Starting from React v18, the 'scheduler' module will need to be mocked to guarantee consistent behaviour across tests and client applications. For example, with Jest: 
jest.mock('scheduler', function() return require(Packages.Scheduler).unstable_mock end)

For more info, visit https://reactjs.org/link/mock-scheduler]]
end end end end function computeThreadID(dh,di)return di*1000+dh.interactionThreadID end ak.markSpawnedWork=function(dh)
if not ar.enableSchedulerTracing then return end if c5==nil then c5={dh}else table.insert(c5,dh)end end function
scheduleInteractions(dh,di,dj)if not ar.enableSchedulerTracing then return end if dj.size>0 then local dk=dh.
pendingInteractionMap local dl=dk:get(di)if dl~=nil then dj:forEach(function(dm)if not dl:has(dm)then dm.__count+=1 end
dl:add(dm)end)else dk:set(di,aj.new(dj))for dm,dn in dj do dn.__count+=1 end end local dm=aT.current if dm~=nil then
local dn=computeThreadID(dh,di)dm.onWorkScheduled(dj,dn)end end end ck.schedulePendingInteractions=function(dh,di)if not
ar.enableSchedulerTracing then return end scheduleInteractions(dh,di,aS.current)end ck.startWorkOnPendingInteractions=
function(dh,di)if not ar.enableSchedulerTracing then return end local dj=aj.new()dh.pendingInteractionMap:forEach(
function(dk,dl)if a5(di,dl)then dk:forEach(function(dm)dj:add(dm)end)end end)dh.memoizedInteractions=dj if dj.size>0
then local dk=aT.current if dk~=nil then local dl=computeThreadID(dh,di)local dm,dn=xpcall(dk.onWorkStarted,ax,dj,dl)if
not dm then aC(aK,function()error(dn)end)end end end end ck.finishPendingInteractions=function(dh,di)if not ar.
enableSchedulerTracing then return end local dj,dk,dl,dm=dh.pendingLanes,true if dl~=nil and dh.memoizedInteractions.
size>0 then local dn=computeThreadID(dh,di)dl=aT.current dk,dm=xpcall(dl.onWorkStopped,ax,dh.memoizedInteractions,dn)end
local dn=dh.pendingInteractionMap dn:forEach(function(dp,dq)if not a5(dj,dq)then dn:delete(dq)dp:forEach(function(dr)dr.
__count-=1 if dl~=nil and dr.__count==0 then local ds,dt=xpcall(dl.onInteractionScheduledWorkCompleted,ax,dr)if not ds
then aC(aK,function()error(dt)end)end end end)end end)if not dk then aC(aK,function()error(dm)end)end end local dh,di,dj
=false,false,ao.unstable_flushAllWithoutAsserting local dk=typeof(dj)=='function'local function dl()if dj~=nil then
local dm=dh dh=true local dn,dp=xpcall(dj,ax)dh=dm if not dn then error(dp)else return dp end else local dm=dh dh=true
local dn,dp=xpcall(function()local dn=false while ak.flushPassiveEffects()do dn=true end return dn end,ax)dh=dm if not
dn then error(dp)else return dp end end end local function dm(dn)local dp,dq=xpcall(dl,ax)if dp then dp,dq=xpcall(cf,ax,
function()if dl()then dm(dn)else dn()end end)end if not dp then dn(dq)end end ak.act=function(dn)if not(ae or _G.
__ROACT_17_MOCK_SCHEDULER__)then if c8==false then c8=true ah.error
[[act(...) is not supported in production builds of React, and might not behave as expected.]]end end local dp=c7 c7+=1
local dq,dr,ds=cj.current,ak.IsThisRendererActing.current,di cj.current=true ak.IsThisRendererActing.current=true di=
true local function dt()c7-=1 cj.current=dq ak.IsThisRendererActing.current=dr di=ds if ae then if c7>dp then ah.error
[[You seem to have overlapping act() calls, this is not supported. Be sure to await previous act() calls before making a new one. ]]
end end end local e,f=xpcall(ak.batchedUpdates,ax,dn)if not e then dt()error(f)end if f~=nil and typeof(f)=='table'and
typeof(f.andThen)=='function'then local g=false if ae then if typeof(bO)~=nil then bO.resolve():andThen(function()end):
andThen(function()if g==false then ah.error
[=[You called act(Promise.new(function() --[[ ... ]] end)) without :await() or :expect(). This could lead to unexpected testing behaviour, interleaving multiple act calls and mixing their scopes. You should - act(function() Promise.new(function() --[[ ... ]] end):await() end);]=]
end end)end end return{andThen=function(h,i,j)g=true return f:andThen(function()if c7>1 or(dk==true and dq==true)then
dt()i()return end dm(function(k)dt()if k then j(k)else i()end end)end,function(k)dt()j(k)end)end}else if ae then if f~=
nil then ah.error([[The callback passed to act(...) function must return nil, or a Promise. You returned %s]],tostring(f
))end end local g,h=xpcall(function()if c7==1 and(dk==false or dq==false)then dl()end dt()end,ax)if not g then dt()
error(h)end return{andThen=function(i,j,k)if ae then ah.error
[[Do not await the result of calling act(...) with sync logic, it is not a Promise.]]end j()end}end end ck.
detachFiberAfterEffects=function(dn)dn.child=nil dn.deletions=nil dn.dependencies=nil dn.memoizedProps=nil dn.
memoizedState=nil dn.pendingProps=nil dn.sibling=nil dn.stateNode=nil dn.updateQueue=nil if ae then dn._debugOwner=nil
end end return ak end)()end,[104]=function()local aa,ab,ac=a(104)local ad return(function(...)return{NoFlags=0b0,
HasEffect=0b1,Layout=0b10,Passive=0b100}end)()end,[105]=function()local aa,ab,ac=a(105)local ad return(function(...)
local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ae.Shared)local ah=ac(ab.Parent.ReactWorkTags)local ai
=ac(ab.Parent.ReactTypeOfMode)local aj=ac(ab.Parent.ReactFiberFlags)local ak=ac(ab.Parent.ReactRootTags)local al=ac(ae.
Shared)local am=ac(ae.Scheduler)return{}end)()end,[106]=function()local aa,ab,ac=a(106)local ad return(function(...)
local ae=ab.Parent.Parent local af=ac(ae.Shared).console local ag,ah={},ac(ae.Shared)local ai=ac(ab.Parent.
ReactInternalTypes)local aj,ak,al=ac(ab.Parent.ReactFiberHostConfig).isPrimaryRenderer,{}if _G.__DEV__ then al={}end ag.
markSourceAsDirty=function(am)table.insert(ak,am)end ag.resetWorkInProgressVersions=function()for am,an in ak do if aj
then an._workInProgressVersionPrimary=nil else an._workInProgressVersionSecondary=nil end end table.clear(ak)end ag.
getWorkInProgressVersion=function(am)if aj then return am._workInProgressVersionPrimary else return am.
_workInProgressVersionSecondary end end ag.setWorkInProgressVersion=function(am,an)if aj then am.
_workInProgressVersionPrimary=an else am._workInProgressVersionSecondary=an end table.insert(ak,am)end ag.
warnAboutMultipleRenderersDEV=function(am)if _G.__DEV__ then if aj then if am._currentPrimaryRenderer==nil then am.
_currentPrimaryRenderer=al elseif am._currentPrimaryRenderer~=al then af.error
[[Detected multiple renderers concurrently rendering the same mutable source. This is currently unsupported.]]end else
if am._currentSecondaryRenderer==nil then am._currentSecondaryRenderer=al elseif am._currentSecondaryRenderer~=al then
af.error[[Detected multiple renderers concurrently rendering the same mutable source. This is currently unsupported.]]
end end end end ag.registerMutableSourceForHydration=function(am,an)local ao=an._getVersion local ap=ao(an._source)if am
.mutableSourceEagerHydrationData==nil then am.mutableSourceEagerHydrationData={an,ap}end end return ag end)()end,[107]=
function()local aa,ab,ac=a(107)local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.Shared).
ReactSymbols.REACT_PORTAL_TYPE,ac(ae.Shared)local function ah(ai,aj,ak,al)if al~=nil then al=tostring(al)end return{[
'$$typeof']=af,key=al,children=ai,containerInfo=aj,implementation=ak}end return{createPortal=ah}end)()end,[108]=function
()local aa,ab,ac=a(108)local ad return(function(...)local ae,af=ab.Parent.Parent,ac(ab.Parent.ReactInternalTypes)local
ag=ac(ae.Shared).ReactFeatureFlags local ah,ai,aj=ag.enableProfilerTimer,ag.enableProfilerCommitHooks,ac(ab.Parent.
ReactWorkTags)local ak,al=aj.Profiler,ac(ae.Scheduler)local am=al.unstable_now local an,ao,ap,aq=0,-1,-1,-1 function
getCommitTime()return an end function recordCommitTime()if not ah then return end an=am()end function startProfilerTimer
(ar)if not ah then return end ap=am()if ar.actualStartTime~=nil and(ar.actualStartTime)<0 then ar.actualStartTime=am()
end end function stopProfilerTimerIfRunning(ar)if not ah then return end ap=-1 end function
stopProfilerTimerIfRunningAndRecordDelta(ar,as)if not ah then return end if ap>=0 then local at=am()-ap ar.
actualDuration+=at if as then ar.selfBaseDuration=at end ap=-1 end end function recordLayoutEffectDuration(ar)if not ah
or not ai then return end if ao>=0 then local as=am()-ao ao=-1 local at=ar.return_ while at~=nil do if at.tag==ak then
local au=at.stateNode au.effectDuration+=as break end at=at.return_ end end end function recordPassiveEffectDuration(ar)
if not ah or not ai then return end if aq>=0 then local as=am()-aq aq=-1 local at=ar.return_ while at~=nil do if at.tag
==ak then local au=at.stateNode if au~=nil then au.passiveEffectDuration+=as end break end at=at.return_ end end end
function startLayoutEffectTimer()if not ah or not ai then return end ao=am()end function startPassiveEffectTimer()if not
ah or not ai then return end aq=am()end function transferActualDuration(ar)local as=ar.child while as do ar.
actualDuration+=as.actualDuration as=as.sibling end end return{getCommitTime=getCommitTime,recordCommitTime=
recordCommitTime,recordLayoutEffectDuration=recordLayoutEffectDuration,recordPassiveEffectDuration=
recordPassiveEffectDuration,startLayoutEffectTimer=startLayoutEffectTimer,startPassiveEffectTimer=
startPassiveEffectTimer,startProfilerTimer=startProfilerTimer,stopProfilerTimerIfRunning=stopProfilerTimerIfRunning,
stopProfilerTimerIfRunningAndRecordDelta=stopProfilerTimerIfRunningAndRecordDelta,transferActualDuration=
transferActualDuration}end)()end,[109]=function()local aa,ab,ac=a(109)local ad return(function(...)return{LegacyRoot=0,
BlockingRoot=1,ConcurrentRoot=2}end)()end,[110]=function()local aa,ab,ac=a(110)local ad return(function(...)local ae=ab.
Parent.Parent local af,ag=ac(ae.Shared).console,ac(ab.Parent.ReactInternalTypes)local ah=ac(ab.Parent.ReactCurrentFiber)
local ai,aj,ak,al=ah.resetCurrentFiber,ah.setCurrentFiber,ac(ae.Shared).getComponentName,ac(ab.Parent.ReactTypeOfMode).
StrictMode local am={recordUnsafeLifecycleWarnings=function(am,an)end,flushPendingUnsafeLifecycleWarnings=function()end,
recordLegacyContextWarning=function(am,an)end,flushLegacyContextWarning=function()end,discardPendingWarnings=function()
end}if _G.__DEV__ then local an,ao,ap,aq,ar,as,at,au,av=function(an)local ao,ap=an while ao~=nil do if bit32.band(ao.
mode,al)~=0 then ap=ao end ao=ao.return_ end return ap end,function(an)local ao={}for ap,aq in an do table.insert(ao,ap)
end table.sort(ao)return table.concat(ao,', ')end,{},{},{},{},{},{},{}am.recordUnsafeLifecycleWarnings=function(aw,ax)if
av[aw.type]then return end if typeof(ax.componentWillMount)=='function'then table.insert(ap,aw)end if bit32.band(aw.mode
,al)~=0 and typeof(ax.UNSAFE_componentWillMount)=='function'then table.insert(aq,aw)end if typeof(ax.
componentWillReceiveProps)=='function'then table.insert(ar,aw)end if bit32.band(aw.mode,al)~=0 and typeof(ax.
UNSAFE_componentWillReceiveProps)=='function'then table.insert(as,aw)end if typeof(ax.componentWillUpdate)=='function'
then table.insert(at,aw)end if bit32.band(aw.mode,al)~=0 and typeof(ax.UNSAFE_componentWillUpdate)=='function'then table
.insert(au,aw)end end am.flushPendingUnsafeLifecycleWarnings=function()local aw={}if#ap>0 then for ax,az in ap do aw[ak(
az.type)or'Component']=true av[az.type]=true end table.clear(ap)end local ax={}if#aq>0 then for az,aA in aq do ax[ak(aA.
type)or'Component']=true av[aA.type]=true end table.clear(aq)end local az={}if#ar>0 then for aA,aB in ar do az[ak(aB.
type)or'Component']=true av[aB.type]=true end table.clear(ar)end local aA={}if#as>0 then for aB,aC in as do aA[ak(aC.
type)or'Component']=true av[aC.type]=true end table.clear(as)end local aB={}if#at>0 then for aC,aD in at do aB[ak(aD.
type)or'Component']=true av[aD.type]=true end table.clear(at)end local aC={}if#au>0 then for aD,aE in au do aC[ak(aE.
type)or'Component']=true av[aE.type]=true end table.clear(au)end if next(ax)~=nil then local aD=ao(ax)af.error(
[[Using UNSAFE_componentWillMount in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.

Please update the following components: %s]]
,aD)end if next(aA)~=nil then local aD=ao(aA)af.error(
[[Using UNSAFE_componentWillReceiveProps in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state

Please update the following components: %s]]
,aD)end if next(aC)~=nil then local aD=ao(aC)af.error(
[[Using UNSAFE_componentWillUpdate in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.

Please update the following components: %s]]
,aD)end if next(aw)~=nil then local aD=ao(aw)af.warn(
[[componentWillMount has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.
* Rename componentWillMount to UNSAFE_componentWillMount to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]]
,aD)end if next(az)~=nil then local aD=ao(az)af.warn(
[[componentWillReceiveProps has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state
* Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]]
,aD)end if next(aB)~=nil then local aD=ao(aB)af.warn(
[[componentWillUpdate has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* Rename componentWillUpdate to UNSAFE_componentWillUpdate to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: %s]]
,aD)end end local aw,ax={},{}am.recordLegacyContextWarning=function(az,aA)local aB=an(az)if aB==nil then af.error
[[Expected to find a StrictMode component in a strict mode tree. This error is likely caused by a bug in React. Please file an issue.]]
return end if ax[az.type]then return end local aC=aw[aB]if typeof(az.type)~='function'and(az.type.contextTypes~=nil or
az.type.childContextTypes~=nil or(aA~=nil and typeof(aA.getChildContext)=='function'))then if aC==nil then aC={}aw[aB]=
aC end table.insert(aC,az)end end am.flushLegacyContextWarning=function()for az,aA in aw do if#aA==0 then return end
local aB,aC=aA[1],{}for aD,aE in aA do aC[ak(aE.type)or'Component']=true ax[aE.type]=true end local aF=ao(aC)local aG,aH
=pcall(function()aj(aB)af.error(
[[Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: %s

Learn more about this warning here: https://reactjs.org/link/legacy-context]]
,aF)end)ai()if not aG then error(aH)end end end am.discardPendingWarnings=function()table.clear(ap)table.clear(aq)table.
clear(ar)table.clear(as)table.clear(at)table.clear(au)table.clear(aw)end end return am end)()end,[111]=function()local
aa,ab,ac=a(111)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ab.Parent.
ReactFiberHostConfig)local ah,ai=ag.supportsTestSelectors,{}local aj={}ai.onCommitRoot=function()if ah then for ak,al in
aj do al()end end end return ai end)()end,[112]=function()local aa,ab,ac=a(112)local ad return(function(...)return{
NoMode=0b0,StrictMode=0b1,BlockingMode=0b10,ConcurrentMode=0b100,ProfileMode=0b1000,DebugTracingMode=0b10000}end)()end,[
113]=function()local aa,ab,ac=a(113)local ad return(function(...)local ae,af,ag=_G.__DEV__,_G.__YOLO__,ab.Parent.Parent
local ah=ac(ag.LuauPolyfill)local ai,aj,ak=ah.Object,ac(ag.Shared).console,ac(ab.Parent.ReactInternalTypes)local al=ac(
ab.Parent.ReactFiberLane)local am,an,ao,ap,aq=al.NoLane,al.NoLanes,al.isSubsetOfLanes,(al.mergeLanes)local function ar()
if not aq then aq=ac(ab.Parent['ReactFiberNewContext.new'])end aq.enterDisallowedContextReadInDEV()end local function as
()if not aq then aq=ac(ab.Parent['ReactFiberNewContext.new'])end aq.exitDisallowedContextReadInDEV()end local at=ac(ab.
Parent.ReactFiberFlags)local au,av,aw,ax=at.Callback,at.ShouldCapture,at.DidCapture,ac(ag.Shared).ReactFeatureFlags
local az,aA=ax.debugRenderPhaseSideEffectsForStrictMode,ac(ab.Parent.ReactTypeOfMode)local aB,aC,aD,aE=aA.StrictMode,ac(
ab.Parent.ReactFiberWorkInProgress).markSkippedUpdateLanes,ac(ag.Shared).describeError,ac(ag.Shared).ConsolePatchingDev
local aF,aG=aE.disableLogs,aE.reenableLogs local aH,aI={},0 aH.UpdateState=aI local aJ=1 aH.ReplaceState=aJ local aK=2
aH.ForceUpdate=aK local aL=3 aH.CaptureUpdate=aL local aM,aN,aO=false if ae then aN=false aO=nil aH.
resetCurrentlyProcessingQueue=function()aO=nil end end local aP=210 local aQ,aR=table.create(aP),aP for aS=1,aP do aQ[aS
]={eventTime=-1,lane=-1,tag=-1,payload=nil,callback=nil,next=nil}end local function aS(aT)local aU={baseState=aT.
memoizedState,firstBaseUpdate=nil,lastBaseUpdate=nil,shared={pending=nil},effects=nil}aT.updateQueue=aU end aH.
initializeUpdateQueue=aS local function aT(aU,aV)local aW,aX=aV.updateQueue,aU.updateQueue if aW==aX then local aY=table
.clone(aX)aV.updateQueue=aY end end aH.cloneUpdateQueue=aT local function aU(aV,aW,aX,aY)if aR>0 then local aZ=aQ[aR]aQ[
aR]=nil aR-=1 aZ.eventTime=aV aZ.lane=aW aZ.tag=aI aZ.payload=aX aZ.callback=aY return aZ end local aZ={eventTime=aV,
lane=aW,tag=aI,payload=aX,callback=aY,next=nil}return aZ end aH.createUpdate=aU local function aV(aW,aX)local aY=aW.
updateQueue if aY==nil then return end local aZ=(aY).shared local a_=aZ.pending if a_==nil then aX.next=aX else aX.next=
a_.next a_.next=aX end aZ.pending=aX if ae then if aO==aZ and not aN then aj.error
[[An update (setState, replaceState, or forceUpdate) was scheduled from inside an update function. Update functions should be pure, with zero side-effects. Consider using componentDidUpdate or a callback.]]
aN=true end end end aH.enqueueUpdate=aV local function aW(aX,aY)local aZ,a_=aX.updateQueue,aX.alternate if a_~=nil then
local a0=a_.updateQueue if aZ==a0 then local a1,a2,a3=(aZ.firstBaseUpdate)if a1~=nil then local a4=a1 repeat local a5={
eventTime=a4.eventTime,lane=a4.lane,tag=a4.tag,payload=a4.payload,callback=a4.callback,next=nil}if a3==nil then a3=a5 a2
=a5 else a3.next=a5 a3=a5 end a4=a4.next until a4==nil if a3==nil then a3=aY a2=aY else a3.next=aY a3=aY end else a3=aY
a2=aY end aZ={baseState=a0.baseState,firstBaseUpdate=a2,lastBaseUpdate=a3,shared=a0.shared,effects=a0.effects}aX.
updateQueue=aZ return end end local a0=aZ.lastBaseUpdate if a0==nil then aZ.firstBaseUpdate=aY else a0.next=aY end aZ.
lastBaseUpdate=aY end aH.enqueueCapturedUpdate=aW local function aX(aY,aZ,a_,a0,a1,a2)local a3=a_.tag if a3==aJ then
local a4=a_.payload if type(a4)=='function'then if ae then ar()end local a5=a4(a0,a1)if ae then if az and bit32.band(aY.
mode,aB)~=0 then aF()local a6,a7 if not af then a6,a7=xpcall(a4,aD,a0,a1)else a6=true a4(a0,a1)end aG()if not a6 then
error(a7)end end as()end return a5 end return a4 elseif a3==aL or a3==aI then if a3==aL then aY.flags=bit32.bor(bit32.
band(aY.flags,bit32.bnot(av)),aw)end local a4,a5=(a_.payload)if type(a4)=='function'then if ae then ar()end a5=a4(a0,a1)
if ae then if az and bit32.band(aY.mode,aB)~=0 then aF()local a6,a7 if not af then a6,a7=xpcall(a4,aD,a0,a1)else a6=true
a4(a0,a1)end aG()if not a6 then error(a7)end end as()end else a5=a4 end if a5==nil then return a0 end return ai.assign({
},a0,a5)elseif a3==aK then aM=true return a0 end return a0 end aH.getStateFromUpdate=aX local function aY(aZ,a_,a0,a1)
local a2=aZ.updateQueue aM=false if ae then aO=a2.shared end local a3,a4,a5=a2.firstBaseUpdate,a2.lastBaseUpdate,a2.
shared.pending if a5~=nil then a2.shared.pending=nil local a6=a5 local a7=a6.next a6.next=nil if a4==nil then a3=a7 else
a4.next=a7 end a4=a6 local a8=aZ.alternate if a8~=nil then local a9=a8.updateQueue local b=a9.lastBaseUpdate if b~=a4
then if b==nil then a9.firstBaseUpdate=a7 else b.next=a7 end a9.lastBaseUpdate=a6 end end end if a3~=nil then local a6,
a7,a8,a9,b,ba=a2.baseState,an,a3 while true do local bb,bc=a8.lane,a8.eventTime if not ao(a1,bb)then local bd={eventTime
=bc,lane=bb,tag=a8.tag,payload=a8.payload,callback=a8.callback,next=nil}if ba==nil then b=bd ba=bd a9=a6 else ba.next=bd
ba=bd end a7=ap(a7,bb)else if ba~=nil then local bd={eventTime=bc,lane=am,tag=a8.tag,payload=a8.payload,callback=a8.
callback,next=nil}ba.next=bd ba=bd end a6=aX(aZ,a2,a8,a6,a_,a0)local bd=a8.callback if bd~=nil and a8.lane~=am then aZ.
flags=bit32.bor(aZ.flags,au)local be=a2.effects if be==nil then a2.effects={a8}else table.insert(be,a8)end end end a8=a8
.next if a8==nil then a5=a2.shared.pending if a5==nil then break else local bd=a5 local be=(bd.next)bd.next=nil a8=be a2
.lastBaseUpdate=bd a2.shared.pending=nil end end end if ba==nil then a9=a6 end a2.baseState=(a9)a2.firstBaseUpdate=b a2.
lastBaseUpdate=ba aC(a7)aZ.lanes=a7 aZ.memoizedState=a6 end if ae then aO=nil end end aH.processUpdateQueue=aY
local function aZ(a_,a0)if type(a_)~='function'then error(string.format(
[[Invalid argument passed as callback. Expected a function. Instead received: %s]],tostring(a_)))end a_(a0)end aH.
resetHasForceUpdateBeforeProcessing=function()aM=false end aH.checkHasForceUpdateAfterProcessing=function()return aM end
local function a_(a0,a1,a2)local a3=a1.effects a1.effects=nil if a3~=nil then for a4,a5 in a3 do local a6=a5.callback if
a6~=nil then aZ(a6,a2)end table.clear(a5)table.insert(aQ,a5)aR+=1 end end end aH.commitUpdateQueue=a_ return aH end)()
end,[114]=function()local aa,ab,ac=a(114)local ad return(function(...)return{FunctionComponent=0,ClassComponent=1,
IndeterminateComponent=2,HostRoot=3,HostPortal=4,HostComponent=5,HostText=6,Fragment=7,Mode=8,ContextConsumer=9,
ContextProvider=10,ForwardRef=11,Profiler=12,SuspenseComponent=13,MemoComponent=14,SimpleMemoComponent=15,LazyComponent=
16,IncompleteClassComponent=17,DehydratedFragment=18,SuspenseListComponent=19,FundamentalComponent=20,ScopeComponent=21,
Block=22,OffscreenComponent=23,LegacyHiddenComponent=24}end)()end,[115]=function()local aa,ab,ac=a(115)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Array,ac(ab.Parent.ReactInternalTypes)
local ai,aj=ac(ae.Scheduler),ac(ae.Shared).ReactFeatureFlags local ak,al,am,an=aj.decoupleUpdatePriorityFromScheduler,
ac(ae.Shared).invariant,ac(ae.Shared).describeError,ac(ab.Parent.ReactFiberLane)local ao,ap,aq,ar,as,at,au,av,aw,ax,az,
aA,aB,aC,aD,aE=an.SyncLanePriority,an.getCurrentUpdateLanePriority,an.setCurrentUpdateLanePriority,ai.
unstable_runWithPriority,ai.unstable_scheduleCallback,ai.unstable_cancelCallback,ai.unstable_shouldYield,ai.
unstable_requestPaint,ai.unstable_now,ai.unstable_getCurrentPriorityLevel,ai.unstable_ImmediatePriority,ai.
unstable_UserBlockingPriority,ai.unstable_NormalPriority,ai.unstable_LowPriority,ai.unstable_IdlePriority,ac(ab.Parent[
'ReactFiberSchedulerPriorities.roblox'])local aF,aG,aH,aI,aJ,aK=aE.ImmediatePriority,aE.UserBlockingPriority,aE.
NormalPriority,aE.LowPriority,aE.IdlePriority,aE.NoPriority local aL local aM,aN,aO={},au if av~=nil then aO=av else aO=
function()end end local aP,aQ,aR,aS=false,(aw())local function aT()return aw()-aQ end local function aU()local aV=ax()if
aV==az then return aF elseif aV==aA then return aG elseif aV==aB then return aH elseif aV==aC then return aI elseif aV==
aD then return aJ else al(false,'Unknown priority level.')return aK end end function reactPriorityToSchedulerPriority(aV
)if aV==aF then return az elseif aV==aG then return aA elseif aV==aH then return aB elseif aV==aI then return aC elseif
aV==aJ then return aD else al(false,'Unknown priority level.')return nil end end local function aV(aW,aX)local aY=
reactPriorityToSchedulerPriority(aW)return ar(aY,aX)end local function aW(aX,aY,aZ)local a_=
reactPriorityToSchedulerPriority(aX)return as(a_,aY,aZ)end local function aX(aY)if aR==nil then aR={aY}aS=as(az,aL)else
local aZ=aR table.insert(aZ,aY)end return aM end local function aY(aZ)if aZ~=aM then at(aZ)end end local function aZ()if
aS~=nil then local a_=aS aS=nil at(a_)end return aL()end aL=function()if not aP and aR~=nil then aP=true local a_=1 if
ak then local a0,a1,a2=ap(),true if not _G.__YOLO__ then local a3,a4=true,aR aq(ao)a1,a2=xpcall(aV,am,aF,function()for
a5,a6 in a4 do a_=a5 repeat a6=a6(a3)until a6==nil end end)aR=nil else a1=true local a3,a4=true,aR aq(ao)aV(aF,function(
)for a5,a6 in a4 do a_=a5 repeat a6=a6(a3)until a6==nil a_+=1 end end)aR=nil end aq(a0)aP=false if not a1 then if aR~=
nil then aR=ag.slice(aR,a_+1)end as(az,aZ)error(a2)end else local a0,a1 if not _G.__YOLO__ then local a2,a3=true,aR a0,
a1=xpcall(aV,am,aF,function()for a4,a5 in a3 do a_=a4 repeat a5=a5(a2)until a5==nil end end)aR=nil else a0=true local a2
,a3=true,aR aV(aF,function()for a4,a5 in a3 do a_=a4 repeat a5=a5(a2)until a5==nil end end)aR=nil end aP=false if not a0
then if aR~=nil then aR=ag.slice(aR,a_+1)end as(az,aZ)error(a1)end end return true else return false end end return{
ImmediatePriority=aF,UserBlockingPriority=aG,NormalPriority=aH,LowPriority=aI,IdlePriority=aJ,NoPriority=aK,
getCurrentPriorityLevel=aU,flushSyncCallbackQueue=aZ,runWithPriority=aV,scheduleCallback=aW,scheduleSyncCallback=aX,
cancelCallback=aY,now=aT,requestPaint=aO,shouldYield=aN}end)()end,[116]=function()local aa,ab,ac=a(116)local ad return(
function(...)local ae,af={},ab.Parent.Parent local ag=ac(af.LuauPolyfill)local ah=ag.WeakMap local ai=ac(ab.Parent.
ReactFiberLane)local aj=ac(ab.Parent.ReactInternalTypes)local ak=ac(af.Shared)local al=ac(af.Shared).ReactFeatureFlags
local am,an,ao,ap,aq=al.enableSchedulingProfiler,ac(af.Shared).ReactVersion,ac(af.Shared).getComponentName,_G.
performance~=nil,_G.performance or{mark=function(am)debug.profilebegin(am)debug.profileend()end}function formatLanes(ar)
return tostring(ar)end if am then if ap then aq.mark('--react-init-'..tostring(an))end end ae.markCommitStarted=function
(ar)if am then if ap then aq.mark('--commit-start-'..formatLanes(ar))end end end ae.markCommitStopped=function()if am
then if ap then aq.mark'--commit-stop'end end end local ar,as=ah.new(),0 function getWakeableID(at)if not ar:has(at)then
ar:set(at,as)as+=1 end return ar:get(at)end ae.markComponentSuspended=function(at,au)if am then if ap then local av,aw=
getWakeableID(au),ao(at.type)or'Unknown'aq.mark('--suspense-suspend-'..tostring(av)..'-'..aw)au:andThen(function()aq.
mark('--suspense-resolved-'..tostring(av)..'-'..aw)end,function()aq.mark('--suspense-rejected-'..tostring(av)..'-'..aw)
end)end end end ae.markLayoutEffectsStarted=function(at)if am then if ap then aq.mark('--layout-effects-start-'..
formatLanes(at))end end end ae.markLayoutEffectsStopped=function()if am then if ap then aq.mark'--layout-effects-stop'
end end end ae.markPassiveEffectsStarted=function(at)if am then if ap then aq.mark('--passive-effects-start-'..
formatLanes(at))end end end ae.markPassiveEffectsStopped=function()if am then if ap then aq.mark'--passive-effects-stop'
end end end ae.markRenderStarted=function(at)if am then if ap then aq.mark('--render-start-'..formatLanes(at))end end
end ae.markRenderYielded=function()if am then if ap then aq.mark'--render-yield'end end end ae.markRenderStopped=
function()if am then if ap then aq.mark'--render-stop'end end end ae.markRenderScheduled=function(at)if am then if ap
then aq.mark('--schedule-render-'..formatLanes(at))end end end ae.markForceUpdateScheduled=function(at,au)if am then if
ap then local av=ao(at.type)or'Unknown'aq.mark('--schedule-forced-update-'..formatLanes(au)..'-'..av)end end end ae.
markStateUpdateScheduled=function(at,au)if am then if ap then local av=ao(at.type)or'Unknown'aq.mark(
'--schedule-state-update-'..formatLanes(au)..'-'..av)end end end return ae end)()end,[118]=function()local aa,ab,ac=a(
118)local ad return(function(...)local ae=ab.Parent.Parent.Parent return ac(ae.Dev.ReactTestRenderer)end)()end,[119]=
function()local aa,ab,ac=a(119)local ad return(function(...)local ae=ac(ab.client['ReactRobloxHostTypes.roblox'])return
ac(ab.client.ReactRoblox)end)()end,[120]=function()local aa,ab,ac=a(120)local ad return(function(...)local ae=ab.Parent.
Parent local af,ag=ac(ae.ReactReconciler),ac(ab.Parent.client.ReactRobloxHostConfig)return af(ag)end)()end,[122]=
function()local aa,ab,ac=a(122)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.Shared)local
ag=ac(ab.Parent['ReactRobloxHostTypes.roblox'])local ah ah=ac(ab.Parent.ReactRobloxRoot)local ai,aj,ak,al,am=ah.
createRoot,ah.createBlockingRoot,ah.createLegacyRoot,ah.isValidContainer,ac(ab.Parent.Parent['ReactReconciler.roblox'])
local an,ao,ap,aq,ar,as,at,au=am.batchedUpdates,am.injectIntoDevTools,am.flushPassiveEffects,am.IsThisRendererActing,am.
createPortal,ac(ae.Shared).ReactVersion,ac(ae.Shared).invariant,ac(ae.Shared).ReactFeatureFlags local av,aw=au.
enableNewReconciler,ac(ab.Parent.ReactRobloxComponentTree)local ax,az,aA,aB,aC,aD,aE=aw.getInstanceFromNode,aw.
getNodeFromInstance,aw.getFiberCurrentPropsFromNode,aw.getClosestInstanceFromNode,ac(ae.Shared).Event,ac(ae.Shared).
Change,ac(ae.Shared).Tag local function aF(aG,aH,aI)at(al(aH),'Target container is not a Roblox Instance.')return ar(aG,
aH,nil,aI)end local aG={Events={getInstanceFromNode=ax,getNodeFromInstance=az,getFiberCurrentPropsFromNode=aA,
flushPassiveEffects=ap,IsThisRendererActing=aq}}local aH={createPortal=aF,unstable_batchedUpdates=an,
__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=aG,version=as,createRoot=ai,createBlockingRoot=aj,createLegacyRoot=ak
,Event=aC,Change=aD,Tag=aE,unstable_isNewReconciler=av,act=function(aH)error
[[ReactRoblox.act is only available in testing environments, not production. Enable the `__ROACT_17_MOCK_SCHEDULER__` global in your test configuration in order to use `act`.]]
end}if _G.__ROACT_17_MOCK_SCHEDULER__ then aH.act=am.act end local aI=ao{findFiberByHostInstance=aB,bundleType=if _G.
__DEV__ then 1 else 0,version=as,rendererPackageName='ReactRoblox'}if _G.__DEV__ then end return aH end)()end,[123]=
function()local aa,ab,ac=a(123)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.LuauPolyfill
)local ag,ah,ai=af.Object,ac(ab.Parent.roblox.RobloxComponentProps),ac(ab.Parent['ReactRobloxHostTypes.roblox'])local aj
={}aj.setInitialProperties=ah.setInitialProperties local function ak(al,am,an,ao,ap)local aq,ar,as=an,ao for at,au in aq
do if ar[at]~=nil then continue end as=as or table.create(2)table.insert(as,at)table.insert(as,ag.None)end for av,aw in
ar do local ax=if aq~=nil then aq[av]else nil if aw==ax then continue end as=as or table.create(2)table.insert(as,av)
table.insert(as,aw)end return as end aj.diffProperties=ak aj.updateProperties=ah.updateProperties aj.
cleanupHostComponent=ah.cleanupHostComponent return aj end)()end,[124]=function()local aa,ab,ac=a(124)local ad return(
function(...)local ae,af=ab.Parent.Parent.Parent,ac(ab.Parent['ReactRobloxHostTypes.roblox'])local ag=ac(ae.
ReactReconciler)local ah=ac(ae.Shared)local ai,aj,ak,al,am,an,ao,ap,aq,ar,as,au=ah.invariant,{},{},{},{},(string.sub(
tostring(math.random()),3))local av,aw='__reactFiber$'..an,'__reactContainer$'..an aj.precacheFiberNode=function(ax,az)
al[az]=ax end aj.uncacheFiberNode=function(ax)al[ax]=nil am[ax]=nil end aj.markContainerAsRoot=function(ax,az)ak[az]=ax
end aj.unmarkContainerAsRoot=function(ax)ak[ax]=nil end aj.isContainerMarkedAsRoot=function(ax)return not not ak[ax]end
aj.getClosestInstanceFromNode=function(ax)local az=al[ax]if az then return az end local aA=ax.Parent while aA do az=al[
aA]if az then local aB=az.alternate if az.child~=nil or(aB~=nil and aB.child~=nil)then if au==nil then au=(ac(ab.Parent.
ReactRobloxHostConfig)).getParentSuspenseInstance end local aC=au(ax)while aC~=nil do local aD=al[aC]if aD then return
aD end aC=au(aC)end end return az end ax=aA aA=ax.Parent end return nil end aj.getInstanceFromNode=function(ax)if ao==
nil then local az=ac(ab.Parent.Parent['ReactReconciler.roblox'])ao=az.ReactWorkTags ap=ao.HostComponent aq=ao.
HostComponent ar=ao.HostComponent as=ao.HostComponent end local az=(ax)[av]or(ax)[aw]if az then if az.tag==ap or az.tag
==aq or az.tag==as or az.tag==ar then return az else return nil end end return nil end aj.getNodeFromInstance=function(
ax)if ax.tag==ap or ax.tag==aq then return ax.stateNode end ai(false,'getNodeFromInstance: Invalid argument.')error
'getNodeFromInstance: Invalid argument.'end aj.getFiberCurrentPropsFromNode=function(ax)return am[ax]end aj.
updateFiberProps=function(ax,az)am[ax]=az end return aj end)()end,[125]=function()local aa,ab,ac=a(125)local ad return(
function(...)local function ae(af)print'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'print('UNIMPLEMENTED ERROR: '..tostring(af))error(
'FIXME (roblox): '..af..' is unimplemented',2)end local af,ag=game:GetService'CollectionService',ab.Parent.Parent.Parent
local ah=ac(ag.LuauPolyfill)local ai,aj,ak,al,am,an=ah.util.inspect,ac(ag.Shared).console,ah.Object,ah.setTimeout,ah.
clearTimeout,ac(ab.Parent['ReactRobloxHostTypes.roblox'])local ao=ac(ab.Parent.ReactRobloxComponentTree)local ap,aq,ar,
as=ao.precacheFiberNode,ao.uncacheFiberNode,ao.updateFiberProps,ac(ab.Parent.ReactRobloxComponent)local au,av,aw,ax,az=
as.setInitialProperties,as.diffProperties,as.updateProperties,as.cleanupHostComponent,ac(ag.Shared).ReactFeatureFlags
local aA=az.enableCreateEventHandleAPI local function aB(aC)if typeof(aC)~='Instance'then return end aq(aC)for aD,aE in
aC:GetDescendants()do aq(aE)end end local aC={}ak.assign(aC,ac(ag.Shared).ReactFiberHostConfig.WithNoPersistence)aC.
getRootHostContext=function(aD)return aD.ClassName end aC.getChildHostContext=function(aD,aE,aF)return aD end aC.
getPublicInstance=function(aD)return aD end aC.prepareForCommit=function(aD)local aE if aA then ae
'enableCreateEventHandleAPI'end return aE end aC.beforeActiveInstanceBlur=function()if aA then ae
'enableCreateEventHandleAPI'end end aC.afterActiveInstanceBlur=function()if aA then ae'enableCreateEventHandleAPI'end
end aC.resetAfterCommit=function(aD)end aC.createInstance=function(aD,aE,aF,aG,aH)local aI=Instance.new(aD)if aH.key
then aI.Name=aH.key else local aJ=aH.return_ while aJ do if aJ.key then aI.Name=aJ.key break end aJ=aJ.return_ end end
ap(aH,aI)ar(aI,aE)return aI end aC.appendInitialChild=function(aD,aE)aE.Parent=aD end aC.finalizeInitialChildren=
function(aD,aE,aF,aG,aH)au(aD,aE,aF,aG)return false end local function aD(aE,aF,aG,aH,aI,aJ)return av(aE,aF,aG,aH,aI)end
aC.prepareUpdate=aD aC.shouldSetTextContent=function(aE,aF)return false end aC.createTextInstance=function(aE,aF,aG,aH)
ae'createTextInstance'return nil end aC.isPrimaryRenderer=true aC.warnsIfNotActing=true aC.scheduleTimeout=al aC.
cancelTimeout=am aC.noTimeout=-1 aC.supportsMutation=true aC.commitMount=function(aE,aF,aG,aH)ae'commitMount'end aC.
commitUpdate=function(aE,aF,aG,aH,aI,aJ)ar(aE,aI)aw(aE,aF,aH)end local function aE(aF)if typeof(aF)~='Instance'then aj.
warn('Could not check tags on non-instance %s.',ai(aF))return end if not aF:IsDescendantOf(game)then if#af:GetTags(aF)>0
then aj.warn(
[[Tags applied to orphaned %s "%s" cannot be accessed via CollectionService:GetTagged. If you're relying on tag behavior in a unit test, consider mounting your test root into the DataModel.]]
,aF.ClassName,aF.Name)end end end aC.appendChild=function(aF,aG)aG.Parent=aF if _G.__DEV__ then aE(aG)end end aC.
appendChildToContainer=function(aF,aG)local aH=aF aC.appendChild(aH,aG)end aC.insertBefore=function(aF,aG,aH)aG.Parent=
aF if _G.__DEV__ then aE(aG)end end aC.insertInContainerBefore=function(aF,aG,aH)local aI=aF aC.insertBefore(aI,aG,aH)
end aC.removeChild=function(aF,aG)aB(aG)ax(aG)aG.Parent=nil aG:Destroy()end aC.removeChildFromContainer=function(aF,aG)
aC.removeChild(aF,aG)end aC.clearSuspenseBoundary=function(aF,aG)ae'clearSuspenseBoundary'end aC.
clearSuspenseBoundaryFromContainer=function(aF,aG)ae'clearSuspenseBoundaryFromContainer'end aC.hideInstance=function(aF)
ae'hideInstance'end aC.hideTextInstance=function(aF)ae'hideTextInstance'end aC.unhideInstance=function(aF,aG)ae
'unhideInstance'end aC.unhideTextInstance=function(aF,aG)ae'unhideTextInstance'end aC.clearContainer=function(aF)local
aG=aF for aH,aI in aG:GetChildren()do aC.removeChild(aG,aI)end end aC.preparePortalMount=function(aF)end return aC end)(
)end,[126]=function()local aa,ab,ac=a(126)local ad return(function(...)local ae=ab.Parent.Parent.Parent local af=ac(ae.
ReactReconciler)local ag=ac(ae.Shared)return{}end)()end,[127]=function()local aa,ab,ac=a(127)local ad return(function(
...)local ae,af=ab.Parent.Parent.Parent,ac(ab.Parent['ReactRobloxHostTypes.roblox'])local ag=ac(ae.ReactReconciler)local
ah=ac(ae.Shared)local ai=ac(ae.ReactReconciler)local aj=ac(ab.Parent.ReactRobloxComponentTree)local ak,al,am=aj.
markContainerAsRoot,aj.unmarkContainerAsRoot,ac(ab.Parent.Parent['ReactReconciler.roblox'])local an,ao,ap,aq,ar,as,au,av
,aw=am.createContainer,am.updateContainer,ac(ae.Shared).invariant,ac(ae.Shared).ReactFeatureFlags.
enableEagerRootListeners,am.ReactRootTags.BlockingRoot,am.ReactRootTags.ConcurrentRoot,am.ReactRootTags.LegacyRoot,{}av.
__index=av function av.new(ax,az)local aA=(setmetatable({},av))aA._internalRoot=aw(ax,as,az)return aA end local function
ax(az,aA,aB)local aC=(setmetatable({},av))aC._internalRoot=aw(az,aA,aB)return aC end function av.render(az,aA)local aB=
az._internalRoot ao(aA,aB,nil)end function av.unmount(az)local aA=az._internalRoot local aB=aA.containerInfo ao(nil,aA,
nil,function()al(aB)end)end aw=function(az,aA,aB)local aC,aD,aE=aB~=nil and aB.hydrate==true,if aB~=nil then aB.
hydrationOptions else nil,(aB~=nil and aB.hydrationOptions~=nil and aB.hydrationOptions.mutableSources)or nil local aF=
an(az,aA,aC,aD)ak(aF.current,az)if aq then end if aE then end return aF end local az={}local function aA(aB)return
typeof(aB)=='Instance'end az.isValidContainer=aA az.createRoot=function(aB,aC)ap(aA(aB),
'createRoot(...): Target container is not a Roblox Instance.')warnIfReactDOMContainerInDEV(aB)return av.new(aB,aC)end az
.createBlockingRoot=function(aB,aC)ap(aA(aB),'createRoot(...): Target container is not a Roblox Instance.')
warnIfReactDOMContainerInDEV(aB)return ax(aB,ar,aC)end az.createLegacyRoot=function(aB,aC)return ax(aB,au,aC)end
function warnIfReactDOMContainerInDEV(aB)if _G.__DEV__ then end end return az end)()end,[129]=function()local aa,ab,ac=
a(129)local ad return(function(...)local ae,af,ag=_G.__DEV__,game:GetService'CollectionService',ab.Parent.Parent.Parent.
Parent local ah=ac(ag.LuauPolyfill)local ai,aj,ak,al,am,an,ao,ap=ah.Object,ah.Set,ah.String,ah.util.inspect,ac(ag.Shared
).console,ac(ag.React),ac(ag.Shared).ReactSymbols,ac(ab.Parent.SingleEventManager)local aq,ar,as=ac(ag.Shared).Type,ac(
ab.Parent.getDefaultInstanceProperty),ac(ab.Parent.Parent['ReactRobloxHostTypes.roblox'])local au=ac(ag.React).Tag local
av,aw,ax,az,aA={},{},[[Error applying initial props to Roblox Instance '%s' (%s):
  %s
]],
"Error updating props on Roblox Instance '%s' (%s):\n  %s\n",
[[Error updating binding or ref assigned to key %s of '%s' (%s).

Updated value:
  %s

Error:
  %s

%s
]]local function
aB(...)return...end local function aC(aD,aE,aF)if aF==nil then local aG=aD.ClassName local aH,aI=ar(aG,aE)aF=aI end aD[
aE]=aF end local function aD(aE,aF)local aG=aw[aE]if aG~=nil then local aH=aG[aF]aH()aG[aF]=nil end end local function
aE(aF,aG,aH)local function aI(aJ)local aK,aL=xpcall(aC,aB,aF,aG,aJ)if not aK then local aM=aH._source or
'<enable DEV mode for stack>'local aN=string.format(aA,aG,aF.Name,aF.ClassName,tostring(aJ),aL,aM)am.error(aN)error(aN,0
)end end if aw[aF]==nil then aw[aF]={}end aw[aF][aG]=an.__subscribeToBinding(aH,aI)aI(aH:getValue())end local function
aF(aG,aH,aI)if ae then if aI~=nil and typeof(aI)~='string'then am.error(
[[Type provided for ReactRoblox.Tag is invalid - tags should be specified as a single string, with individual tags delimited by spaces. Instead received:
%s]]
,al(aI))return end end local aJ,aK=aj.new(ak.split(aH or'',' ')),aj.new(ak.split(aI or'',' '))for aL,aM in aJ do if not
aK:has(aM)then af:RemoveTag(aG,aM)end end for aN,aO in aK do if not aJ:has(aO)then af:AddTag(aG,aO)end end end
local function aG(aH)for aI,aJ in af:GetTags(aH)do af:RemoveTag(aH,aJ)end end local function aH(aI,aJ,aK,aN)local aO=aq.
of(aJ)if aO==aq.HostEvent or aO==aq.HostChangeEvent then local aP=av[aI]if aP==nil then aP=(ap.new(aI))av[aI]=aP end
local aQ=aJ.name if aO==aq.HostChangeEvent then aP:connectPropertyChange(aQ,aK)else aP:connectEvent(aQ,aK)end return end
local aP,aQ=typeof(aK)=='table'and aK['$$typeof']==ao.REACT_BINDING_TYPE,aN~=nil and typeof(aN)=='table'and aN[
'$$typeof']==ao.REACT_BINDING_TYPE if aQ then aD(aI,aJ)end if aP then aE(aI,aJ,aK)elseif aJ==au then aF(aI,aN,aK)else
aC(aI,aJ,aK)end end local function aI(aJ,aK)for aN,aO in aK do if aN=='ref'or aN=='children'then continue end aH(aJ,aN,
aO)end end local function aJ(aK,aN,aO,aP)local aQ,aR=xpcall(aI,aB,aK,aO)if not aQ then local aS=string.format(ax,aK.Name
,aK.ClassName,aR)am.error(aS)error(aS,0)end if av[aK]~=nil then av[aK]:resume()end end local function aK(aN,aO,aP)local
aQ=#aO for aR=1,aQ,2 do local aS,aT=aO[aR],aO[aR+1]if aT==ai.None then aT=nil end if aS~='ref'and aS~='children'then aH(
aN,aS,aT,aP[aS])end end end local function aN(aO,aP,aQ)if av[aO]~=nil then av[aO]:suspend()end local aR,aS=xpcall(aK,aB,
aO,aP,aQ)if not aR then local aT=string.format(az,aO.Name,aO.ClassName,aS)am.error(aT)error(aT,0)end if av[aO]~=nil then
av[aO]:resume()end end local function aO(aP)if av[aP]~=nil then av[aP]=nil end if aw[aP]~=nil then aw[aP]=nil end if
typeof(aP)~='Instance'then return end aG(aP)for aQ,aR in aP:GetDescendants()do if av[aR]~=nil then av[aR]=nil end if aw[
aR]~=nil then aw[aR]=nil end aG(aP)end end return{setInitialProperties=aJ,updateProperties=aN,cleanupHostComponent=aO,
_instanceToEventManager=av,_instanceToBindings=aw}end)()end,[130]=function()local aa,ab,ac=a(130)local ad return(
function(...)local ae=ab.Parent.Parent.Parent.Parent local af=ac(ae.Shared).console local ag,ah='Change.',{Disabled=
'Disabled',Suspended='Suspended',Enabled='Enabled'}local ai={}ai.__index=ai function ai.new(aj)local ak=setmetatable({
_suspendedEventQueue={},_connections={},_listeners={},_status=ah.Disabled,_isResuming=false,_instance=aj},ai)return(ak)
end function ai.connectEvent(aj,ak,al)aj:_connect(ak,aj._instance[ak],al)end function ai.connectPropertyChange(aj,ak,al)
local am,an=pcall(aj._instance.GetPropertyChangedSignal,aj._instance,ak)if not am then error(string.format(
'Cannot get changed signal on property %q: %s',tostring(ak),an),0)end aj:_connect(ag..ak,an,al)end function ai._connect(
aj,ak,al,am)if am==nil then if aj._connections[ak]~=nil then aj._connections[ak]:Disconnect()aj._connections[ak]=nil end
aj._listeners[ak]=nil else if aj._connections[ak]==nil then aj._connections[ak]=al:Connect(function(...)if aj._status==
ah.Enabled then aj._listeners[ak](aj._instance,...)elseif aj._status==ah.Suspended then local an=select('#',...)table.
insert(aj._suspendedEventQueue,{ak,an,...})end end)end aj._listeners[ak]=am end end function ai.suspend(aj)aj._status=ah
.Suspended end function ai.resume(aj)if aj._isResuming then return end aj._isResuming=true for ak,al in aj.
_suspendedEventQueue do local am,an=aj._listeners[al[1]],al[2]if am~=nil then local ao=coroutine.create(am)local ap,aq=
coroutine.resume(ao,aj._instance,unpack(al,3,2+an))if not ap then af.warn('%s',aq)end end end aj._isResuming=false aj.
_status=ah.Enabled table.clear(aj._suspendedEventQueue)end return ai end)()end,[131]=function()local aa,ab,ac=a(131)
local ad return(function(...)local ae=ab.Parent.Parent.Parent.Parent local af=ac(ae.Shared).Symbol local ag,ah=af.named
'Nil',{}local function ai(aj,ak)return aj[ak]end local function aj(ak,al)local am=ah[ak]if am then local an=am[al]if an
==ag then return true,nil end if an~=nil then return true,an end else am={}ah[ak]=am end local an=Instance.new(ak)local
ao,ap=pcall(ai,an,al)an:Destroy()if ao then if ap==nil then am[al]=ag else am[al]=ap end end return ao,ap end return aj
end)()end,[132]=function()local aa,ab,ac=a(132)local ad return(function(...)local ae=ab.Parent local af,ag,ah,ai=ac(ae.
React),ac(ae.ReactRoblox),ac(ae.Shared),ac(ab.RoactTree)return{Component=af.Component,PureComponent=af.PureComponent,
createElement=af.createElement,createRef=af.createRef,forwardRef=af.forwardRef,createContext=af.createContext,None=af.
None,mount=ai.mount,update=ai.update,unmount=ai.unmount,createFragment=ac(ab.createFragment),oneChild=ac(ab.oneChild),
setGlobalConfig=ac(ab.setGlobalConfig),Portal=ac(ab.Portal),Ref='ref',Children='children',Event=ah.Event,Change=ah.
Change,createBinding=af.createBinding,joinBindings=af.joinBindings,act=ag.act}end)()end,[133]=function()local aa,ab,ac=
a(133)local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.ReactRoblox),ac(ab.Parent.warnOnce)
local function ah(ai)if _G.__DEV__ and _G.__COMPAT_WARNINGS__ then ag('Roact.Portal',
'Please use the createPortal API on ReactRoblox instead')end return af.createPortal(ai.children,ai.target)end return ah
end)()end,[134]=function()local aa,ab,ac=a(134)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag,ah=af.util.inspect,ac(ae.ReactRoblox)local ai=ac(ab.Parent.warnOnce)local function aj(ak,al,am)if
_G.__DEV__ and _G.__COMPAT_WARNINGS__ then ai('mount','Please use the createRoot API in ReactRoblox')end if al~=nil and
typeof(al)~='Instance'then error(string.format(
[[Cannot mount element (`%s`) into a parent that is not a Roblox Instance (got type `%s`) 
%s]],(function()if ak then
return tostring(ak.type)end return'<unknown>'end)(),typeof(al),(function()if al~=nil then return ag(al)end return''end)(
)))end local an if _G.__ROACT_17_COMPAT_LEGACY_ROOT__ then an=ah.createLegacyRoot(Instance.new'Folder')else an=ah.
createRoot(Instance.new'Folder')end if al==nil then al=Instance.new'Folder'al.Name='Target'end if am==nil then if _G.
__ROACT_17_COMPAT_LEGACY_ROOT__ then am='ReactLegacyRoot'else am='ReactRoot'end end if _G.__ROACT_17_INLINE_ACT__ then
ah.act(function()an:render(ah.createPortal({[am]=ak},al))end)else an:render(ah.createPortal({[am]=ak},al))end return{
root=an,parent=al,key=am}end local function ak(al,am)if _G.__DEV__ and _G.__COMPAT_WARNINGS__ then ai('update',
'Please use the createRoot API in ReactRoblox')end local an,ao=al.key,al.parent if _G.__ROACT_17_INLINE_ACT__ then ah.
act(function()al.root:render(ah.createPortal({[an]=am},ao))end)else al.root:render(ah.createPortal({[an]=am},ao))end
return al end local function al(am)if _G.__DEV__ and _G.__COMPAT_WARNINGS__ then ai('unmount',
'Please use the createRoot API in ReactRoblox')end if _G.__ROACT_17_INLINE_ACT__ then ah.act(function()am.root:unmount()
end)else am.root:unmount()end end return{mount=aj,update=ak,unmount=al}end)()end,[135]=function()local aa,ab,ac=a(135)
local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.React),ac(ab.Parent.warnOnce)return function(ah
)if _G.__DEV__ and _G.__COMPAT_WARNINGS__ then ag('createFragment',
'Please instead use:\n\tReact.createElement(React.Fragment, ...)')end return af.createElement(af.Fragment,nil,ah)end end
)()end,[136]=function()local aa,ab,ac=a(136)local ad return(function(...)local ae=ab.Parent.Parent local af,ag=ac(ae.
React),ac(ab.Parent.warnOnce)local function ah(ai)if _G.__DEV__ and _G.__COMPAT_WARNINGS__ then ag('oneChild',
[[You likely don't need this at all! If you were assigning children via `React.oneChild(someChildren)`, you can simply use `someChildren` directly.]]
)end if not ai then return nil end local aj,ak=next(ai)if not ak then return nil end local al=next(ai,aj)if al then
error('Expected at most one child, had more than one child.',2)end return af.Children.only(ak)end return ah end)()end,[
137]=function()local aa,ab,ac=a(137)local ad return(function(...)local ae=ac(ab.Parent.warnOnce)return function(af)if _G
.__DEV__ and _G.__COMPAT_WARNINGS__ then ae('setGlobalConfig',
[[Roact 17 uses a `_G.__DEV__` flag to enable development behavior. If you're seeing this warning, you already have it enabled. Please remove any redundant uses of `setGlobalConfig`.]]
)end end end)()end,[138]=function()local aa,ab,ac=a(138)local ad return(function(...)local ae=ab.Parent.Parent local af,
ag=ac(ae.Shared).console,{}local function ah(ai,aj)if not ag[ai]then af.warn(
[[The legacy Roact API '%s' is deprecated, and will be removed in a future release.

%s]],ai,aj)end ag[ai]=true end
return ah end)()end,[139]=function()local aa,ab,ac=a(139)local ad return(function(...)local ae=ac(ab.Scheduler)
local function af(ag)return function()error(ag..' is only available in tests, not in production')end end local ag,ah,ai=
ae(nil),ac(ab.Tracing),ac(ab.TracingSubscriptions)if _G.__ROACT_17_MOCK_SCHEDULER__ then return ac(ab.unstable_mock)end
local aj={unstable_ImmediatePriority=ag.unstable_ImmediatePriority,unstable_UserBlockingPriority=ag.
unstable_UserBlockingPriority,unstable_NormalPriority=ag.unstable_NormalPriority,unstable_IdlePriority=ag.
unstable_IdlePriority,unstable_LowPriority=ag.unstable_LowPriority,unstable_runWithPriority=ag.unstable_runWithPriority,
unstable_next=ag.unstable_next,unstable_scheduleCallback=ag.unstable_scheduleCallback,unstable_cancelCallback=ag.
unstable_cancelCallback,unstable_wrapCallback=ag.unstable_wrapCallback,unstable_getCurrentPriorityLevel=ag.
unstable_getCurrentPriorityLevel,unstable_shouldYield=ag.unstable_shouldYield,unstable_requestPaint=ag.
unstable_requestPaint,unstable_continueExecution=ag.unstable_continueExecution,unstable_pauseExecution=ag.
unstable_pauseExecution,unstable_getFirstCallbackNode=ag.unstable_getFirstCallbackNode,unstable_now=ag.unstable_now,
unstable_forceFrameRate=ag.unstable_forceFrameRate,unstable_flushAllWithoutAsserting=af
'unstable_flushAllWithoutAsserting',unstable_flushAll=af'unstable_flushAll',unstable_flushNumberOfYields=af
'unstable_flushNumberOfYields',unstable_clearYields=af'unstable_clearYields',unstable_flushUntilNextPaint=af
'unstable_clearYields',unstable_advanceTime=af'unstable_advanceTime',unstable_flushExpired=af'unstable_flushExpired',
unstable_yieldValue=af'unstable_yieldValue',tracing={unstable_wrap=af'unstable_wrap',__interactionsRef={},
__subscriberRef={}}}for ak,al in ah do aj.tracing[ak]=al end for am,an in ai do aj.tracing[am]=an end return aj end)()
end,[140]=function()local aa,ab,ac=a(140)local ad return(function(...)return function(ae)local af=ab.Parent.Parent local
ag,ah=ac(af.Shared).describeError,ac(ab.Parent.SchedulerFeatureFlags)local ai,aj,am=ah.enableSchedulerDebugging,ah.
enableProfiling,ae or ac(ab.Parent.SchedulerHostConfig)local an,ao,ap,aq,ar,as,au=am.requestHostCallback,am.
requestHostTimeout,am.cancelHostTimeout,am.shouldYieldToHost,am.getCurrentTime,am.forceFrameRate,am.requestPaint local
av,aw,ax local az,aA,aB=function(az,aA)local aB=#az+1 az[aB]=aA aw(az,aA,aB)end,function(az)return az[1]end,function(az)
local aA=az[1]if aA~=nil then local aB=az[#az]az[#az]=nil if aB~=aA then az[1]=aB ax(az,aB,1)end return aA else return
nil end end aw=function(aC,aD,aE)while true do local aF=math.floor(aE/2)local aG=aC[aF]if aG~=nil and av(aG,aD)>0 then
aC[aF]=aD aC[aE]=aG aE=aF else return end end end ax=function(aC,aD,aE)local aF=#aC while aE<aF do local aG=aE*2 local
aH,aI=aC[aG],aG+1 local aJ=aC[aI]if aH~=nil and av(aH,aD)<0 then if aJ~=nil and av(aJ,aH)<0 then aC[aE]=aJ aC[aI]=aD aE=
aI else aC[aE]=aH aC[aG]=aD aE=aG end elseif aJ~=nil and av(aJ,aD)<0 then aC[aE]=aJ aC[aI]=aD aE=aI else return end end
end av=function(aC,aD)local aE=aC.sortIndex-aD.sortIndex if aE==0 then return aC.id-aD.id end return aE end local aC=ac(
ab.Parent.SchedulerPriorities)local aD,aE,aF,aG,aH,aI=aC.ImmediatePriority,aC.UserBlockingPriority,aC.NormalPriority,aC.
LowPriority,aC.IdlePriority,ac(ab.Parent.SchedulerProfiling)local aJ,aK,aN,aO,aP,aQ,aR,aS,aT,aU,aV,aW,aX,aY,aZ=aI.
markTaskRun,aI.markTaskYield,aI.markTaskCompleted,aI.markTaskCanceled,aI.markTaskErrored,aI.markSchedulerSuspended,aI.
markSchedulerUnsuspended,aI.markTaskStart,aI.stopLoggingProfilingEvents,aI.startLoggingProfilingEvents,1073741823,-1,250
,5000,10000 local a_,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,b,ba=aV,{},{},1,false,aF,false,false,false local function bb(bc)local
bd=aA(a1)while bd~=nil do if bd.callback==nil then aB(a1)elseif bd.startTime<=bc then aB(a1)bd.sortIndex=bd.
expirationTime az(a0,bd)if aj then aS(bd,bc)bd.isQueued=true end else return end bd=aA(a1)end end a9=function(bc)a7=
false bb(bc)if not a6 then if aA(a0)~=nil then a6=true an(b)else local bd=aA(a1)if bd~=nil then ao(a9,bd.startTime-bc)
end end end end b=function(bc,bd)if aj then aR(bd)end a6=false if a7 then a7=false ap()end a5=true local be,bf,bg=a4 if
not _G.__YOLO__ then if aj then bf,bg=xpcall(ba,ag,bc,bd)if not bf then if a8~=nil then local bh=ar()aP(a8,bh)a8.
isQueued=false end end else bf=true bg=ba(bc,bd)end else bf=true bg=ba(bc,bd)end a8=nil a4=be a5=false if aj then local
bh=ar()aQ(bh)end if not bf then error(bg)end return bg end ba=function(bc,bd)local be=bd bb(be)a8=aA(a0)while a8~=nil
and not(ai and a3)do if a8.expirationTime>be and(not bc or aq())then break end local bf=a8.callback if typeof(bf)==
'function'then a8.callback=nil a4=a8.priorityLevel local bg=a8.expirationTime<=be aJ(a8,be)local bh=bf(bg)be=ar()if
typeof(bh)=='function'then a8.callback=bh aK(a8,be)else if aj then aN(a8,be)a8.isQueued=false end if a8==aA(a0)then aB(
a0)end end bb(be)else aB(a0)end a8=aA(a0)end if a8~=nil then return true else local bf=aA(a1)if bf~=nil then ao(a9,bf.
startTime-be)end return false end end local function bc(bd,be)if bd==aD or bd==aE or bd==aF or bd==aG or bd==aH then
else bd=aF end local bf=a4 a4=bd local bg,bh if not _G.__YOLO__ then bg,bh=xpcall(be,ag)else bg=true bh=be()end a4=bf if
not bg then error(bh)end return bh end local function bd(be)local bf if a4==aD or a4==aE or a4==aF then bf=aF else bf=a4
end local bg=a4 a4=bf local bh,bi if not _G.__YOLO__ then bh,bi=xpcall(be,ag)else bh=true bi=be()end a4=bg if not bh
then error(bi)end return bi end local function be(bf)local bg=a4 return function(...)local bh=a4 a4=bg local bi,bj if
not _G.__YOLO__ then bi,bj=xpcall(bf,ag,...)else bi=true bj=bf(...)end a4=bh if not bi then error(bj)end return bj end
end local function bf(bg,bh,bi)local bj,bk=(ar())if typeof(bi)=='table'then local bl=bi.delay if typeof(bl)=='number'and
bl>0 then bk=bj+bl else bk=bj end else bk=bj end local bl if bg==aD then bl=aW elseif bg==aE then bl=aX elseif bg==aH
then bl=a_ elseif bg==aG then bl=aZ else bl=aY end local bm=bk+bl local bn={id=a2,callback=bh,priorityLevel=bg,startTime
=bk,expirationTime=bm,sortIndex=-1}a2+=1 if aj then bn.isQueued=false end if bk>bj then bn.sortIndex=bk az(a1,bn)if#a0==
0 and bn==aA(a1)then if a7 then ap()else a7=true end ao(a9,bk-bj)end else bn.sortIndex=bm az(a0,bn)if aj then aS(bn,bj)
bn.isQueued=true end if not a6 and not a5 then a6=true an(b)end end return bn end local function bg()a3=true end
local function bh()a3=false if not a6 and not a5 then a6=true an(b)end end local function bi()return aA(a0)end
local function bj(bk)if aj then if bk.isQueued then local bl=ar()aO(bk,bl)bk.isQueued=false end end bk.callback=nil end
local function bk()return a4 end local bl=au return{unstable_ImmediatePriority=aD,unstable_UserBlockingPriority=aE,
unstable_NormalPriority=aF,unstable_IdlePriority=aH,unstable_LowPriority=aG,unstable_runWithPriority=bc,unstable_next=bd
,unstable_scheduleCallback=bf,unstable_cancelCallback=bj,unstable_wrapCallback=be,unstable_getCurrentPriorityLevel=bk,
unstable_shouldYield=aq,unstable_requestPaint=bl,unstable_continueExecution=bh,unstable_pauseExecution=bg,
unstable_getFirstCallbackNode=bi,unstable_now=ar,unstable_forceFrameRate=as,unstable_Profiling=(function()if aj then
return{startLoggingProfilingEvents=aU,stopLoggingProfilingEvents=aT}end return nil end)()}end end)()end,[141]=function()
local aa,ab,ac=a(141)local ad return(function(...)return{enableSchedulerDebugging=false,enableIsInputPending=false,
enableProfiling=_G.__PROFILE__}end)()end,[142]=function()local aa,ab,ac=a(142)local ad return(function(...)return ac(ab.
Parent.forks['SchedulerHostConfig.default'])end)()end,[143]=function()local aa,ab,ac=a(143)local ad return(function(...)
local ae,af,ag,ah={}ae.push=function(ai,aj)local am=#ai+1 ai[am]=aj ag(ai,aj,am)end ae.peek=function(ai)return ai[1]end
ae.pop=function(ai)local aj=ai[1]if aj~=nil then local am=ai[#ai]ai[#ai]=nil if am~=aj then ai[1]=am ah(ai,am,1)end
return aj else return nil end end ag=function(ai,aj,am)while true do local an=math.floor(am/2)local ao=ai[an]if ao~=nil
and af(ao,aj)>0 then ai[an]=aj ai[am]=ao am=an else return end end end ah=function(ai,aj,am)local an=#ai while am<an do
local ao=am*2 local ap,aq=ai[ao],ao+1 local ar=ai[aq]if ap~=nil and af(ap,aj)<0 then if ar~=nil and af(ar,ap)<0 then ai[
am]=ar ai[aq]=aj am=aq else ai[am]=ap ai[ao]=aj am=ao end elseif ar~=nil and af(ar,aj)<0 then ai[am]=ar ai[aq]=aj am=aq
else return end end end af=function(ai,aj)local am=ai.sortIndex-aj.sortIndex if am==0 then return ai.id-aj.id end return
am end return ae end)()end,[144]=function()local aa,ab,ac=a(144)local ad return(function(...)return{NoPriority=0,
ImmediatePriority=1,UserBlockingPriority=2,NormalPriority=3,LowPriority=4,IdlePriority=5}end)()end,[145]=function()local
aa,ab,ac=a(145)local ad return(function(...)local ae=ab.Parent.Parent local af,ag,ah=ac(ae.Shared).console,{},ac(ab.
Parent.SchedulerPriorities)local ai=ac(ab.Parent.SchedulerFeatureFlags)local aj,am,an,ao,ap,aq,ar,as,au,av,aw,ax,az,aA,
aB,aC,aD=ai.enableProfiling,0,0,131072,524288,0,1,1,2,3,4,5,6,7,8 local function aE(aF)if aD~=nil then ar+=#aF if ar+1>
aq then aq*=2 if aq>ap then af.error
[[Scheduler Profiling: Event log exceeded maximum size. Don't forget to call `stopLoggingProfilingEvents()`.]]ag.
stopLoggingProfilingEvents()return end local aG={}table.insert(aG,aD)aC=aG aD=aG end table.insert(aD,aF)end end ag.
startLoggingProfilingEvents=function()aq=ao aC={}aD=aC ar=1 end ag.stopLoggingProfilingEvents=function()local aF=aC aq=0
aC=nil aD=nil ar=1 return aF end ag.markTaskStart=function(aF,aG)if aj then if aD~=nil then aE{as,aG*1000,aF.id,aF.
priorityLevel}end end end ag.markTaskCompleted=function(aF,aG)if aj then if aD~=nil then aE{au,aG*1000,aF.id}end end end
ag.markTaskCanceled=function(aF,aG)if aj then if aD~=nil then aE{aw,aG*1000,aF.id}end end end ag.markTaskErrored=
function(aF,aG)if aj then if aD~=nil then aE{av,aG*1000,aF.id}end end end ag.markTaskRun=function(aF,aG)if aj then am+=1
if aD~=nil then aE{ax,aG*1000,aF.id,am}end end end ag.markTaskYield=function(aF,aG)if aj then if aD~=nil then aE{az,aG*
1000,aF.id,am}end end end ag.markSchedulerSuspended=function(aF)if aj then an+=1 if aD~=nil then aE{aA,aF*1000,an}end
end end ag.markSchedulerUnsuspended=function(aF)if aj then if aD~=nil then aE{aB,aF*1000,an}end end end return ag end)()
end,[146]=function()local aa,ab,ac=a(146)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag,ah,ai=af.Set,{},ac(ae.Shared).ReactFeatureFlags local aj=ai.enableSchedulerTracing local am,an,ao,
ap,aq=0,0,0 if aj then ap={current=ag.new()}aq={current=nil}end ah.__interactionsRef=ap ah.__subscriberRef=aq ah.
unstable_clear=function(ar)if not aj then return ar()end local as=ap.current ap.current=ag.new()local au,av=pcall(ar)ap.
current=as if not au then error(av)end return av end ah.unstable_getCurrent=function()if not aj then return nil else
return ap.current end end ah.unstable_getThreadID=function()ao+=1 return ao end ah.unstable_trace=function(ar,as,au,av)
local aw=if av~=nil then av else am if not aj then return au()end local ax={__count=1,id=an,name=ar,timestamp=as}an+=1
local az=ap.current local aA=ag.new(az)aA:add(ax)ap.current=aA local aB,aC=(aq.current)local aD,aE=pcall(function()if aB
~=nil then aB.onInteractionTraced(ax)end end)local aF,aG=pcall(function()if aB~=nil then aB.onWorkStarted(aA,aw)end end)
local aH,aI=pcall(function()aC=au()end)ap.current=az local aJ,aK=pcall(function()if aB~=nil then aB.onWorkStopped(aA,aw)
end end)ax.__count-=1 if aB~=nil and ax.__count==0 then aB.onInteractionScheduledWorkCompleted(ax)end if not aJ then
error(aK)end if not aH then error(aI)end if not aF then error(aG)end if not aD then error(aE)end return aC end ah.
unstable_wrap=function(ar,as)if as==nil then as=am end if not aj then return ar end local au,av=ap.current,aq.current if
av~=nil then av.onWorkScheduled(au,as)end for aw,ax in au do ax.__count+=1 end local az=false local function aA(aB,...)
local aC=ap.current ap.current=au av=aq.current local aD,aE=pcall(function(...)local aD,aE,aF=nil,pcall(function()if av
~=nil then av.onWorkStarted(au,as)end end)local aG,aH=pcall(function(...)aD=ar(...)end,...)ap.current=aC if av~=nil then
av.onWorkStopped(au,as)end if not aG then error(aH)end if not aE then error(aF)end return aD end,...)if not az then az=
true for aF,aG in au do aG.__count-=1 if av~=nil and aG.__count==0 then av.onInteractionScheduledWorkCompleted(aG)end
end end if not aD then error(aE)end return aE end local aB,aC=function()av=aq.current local aB,aC=pcall(function()if av
~=nil then av.onWorkCanceled(au,as)end end)for aD,aE in au do aE.__count-=1 if av~=nil and aE.__count==0 then av.
onInteractionScheduledWorkCompleted(aE)end end if not aB then error(aC)end end,{}setmetatable(aC,{__call=aA})aC.cancel=
aB return aC end return ah end)()end,[147]=function()local aa,ab,ac=a(147)local ad return(function(...)local ae,af={},ab
.Parent.Parent local ag,ah=ac(af.LuauPolyfill).Object,ac(ab.Parent.Tracing)local ai=ac(af.Shared).ReactFeatureFlags
local aj,am,an=ai.enableSchedulerTracing,ah.__subscriberRef,{}if aj then an={}end ae.unstable_subscribe=function(ao)if
aj then an[ao]=true if#ag.keys(an)==1 then am.current={onInteractionScheduledWorkCompleted=
onInteractionScheduledWorkCompleted,onInteractionTraced=onInteractionTraced,onWorkCanceled=onWorkCanceled,
onWorkScheduled=onWorkScheduled,onWorkStarted=onWorkStarted,onWorkStopped=onWorkStopped}end end end ae.
unstable_unsubscribe=function(ao)if aj then an[ao]=nil if#ag.keys(an)==0 then am.current=nil end end end function
onInteractionTraced(ao)local ap,aq=false for ar,as in an do local au,av=pcall(ar.onInteractionTraced,ao)if not au then
local aw=av if not ap then ap=true aq=aw end end end if ap then error(aq)end end function
onInteractionScheduledWorkCompleted(ao)local ap,aq=false for ar,as in an do local au,av=pcall(ar.
onInteractionScheduledWorkCompleted,ao)if not au then local aw=av if not ap then ap=true aq=aw end end end if ap then
error(aq)end end function onWorkScheduled(ao,ap)local aq,ar=false for as,au in an do local av,aw=pcall(as.
onWorkScheduled,ao,ap)if not av then local ax=aw if not aq then aq=true ar=ax end end end if aq then error(ar)end end
function onWorkStarted(ao,ap)local aq,ar=false for as,au in an do local av,aw=pcall(as.onWorkStarted,ao,ap)if not av
then local ax=aw if not aq then aq=true ar=ax end end end if aq then error(ar)end end function onWorkStopped(ao,ap)local
aq,ar=false for as,au in an do local av,aw=pcall(as.onWorkStopped,ao,ap)if not av then local ax=aw if not aq then aq=
true ar=ax end end end if aq then error(ar)end end function onWorkCanceled(ao,ap)local aq,ar=false for as,au in an do
local av,aw=pcall(as.onWorkCanceled,ao,ap)if not av then local ax=aw if not aq then aq=true ar=ax end end end if aq then
error(ar)end end return ae end)()end,[149]=function()local aa,ab,ac=a(149)local ad return(function(...)local ae=ab.
Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah=af.Object,ac(ae.Shared)local ai,aj,am,an,ao,ap,aq,ar,as,au,
av=ah.console,ah.errorToString,ah.describeError,function()return os.clock()*1000 end,af.setTimeout,af.clearTimeout,false
,ag.None,15,0 local function aw()return an()>=au end local function ax()end local function az(aA)if aA<0 or aA>125 then
ai.warn
[[forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported]]
return end if aA>0 then as=math.floor(1000/aA)else as=5 end end local function aA()if av~=nil then local aB=an()au=aB+as
local aC,aD,aE=true local function aF()local aG=(av)(aC,aB)if not aG then aq=false av=nil else task.delay(0,aA)end
return nil end if not _G.__YOLO__ then aD,aE=xpcall(aF,am)else aE=aF()aD=true end if not aD then task.delay(0,aA)error(
aj(aE))end else aq=false end end local function aB(aC)av=aC if not aq then aq=true task.delay(0,aA)end end
local function aC()av=nil end local function aD(aE,aF)ar=ao(function()aE(an())end,aF)end local function aE()ap(ar)ar=ag.
None end return{requestHostCallback=aB,cancelHostCallback=aC,requestHostTimeout=aD,cancelHostTimeout=aE,
shouldYieldToHost=aw,requestPaint=ax,getCurrentTime=an,forceFrameRate=az}end)()end,[150]=function()local aa,ab,ac=a(150)
local ad return(function(...)local ae,af,ag,ah,ai,aj,am,an,ao,ap,aq,ar={},0,-1,-1,false,false,false,false,(ab.Parent.
Parent.Parent)local as,au=ac(ao.Shared).console,ac(ao.Shared).ConsolePatchingDev local av=au.disabledLog ae.
requestHostCallback=function(aw)ap=aw end ae.cancelHostCallback=function()ap=nil end ae.requestHostTimeout=function(aw,
ax)aq=aw ag=af+ax end ae.cancelHostTimeout=function()aq=nil ag=-1 end ae.shouldYieldToHost=function()local aw=ar if(ah~=
-1 and aw~=nil and#aw>=ah)or(an and am)then ai=true return true end return false end ae.getCurrentTime=function()return
af end ae.forceFrameRate=function()end ae.reset=function()if aj then error'Cannot reset while already flushing work.'end
af=0 ap=nil aq=nil ag=-1 ar=nil ah=-1 ai=false aj=false am=false end ae.unstable_flushNumberOfYields=function(aw)if aj
then error'Already flushing work.'end if ap~=nil then local ax=ap ah=aw aj=true local az,aA=pcall(function()local az=
true repeat az=ax(true,af)until not az or ai if not az then ap=nil end end)ah=-1 ai=false aj=false if not az then error(
aA)end end end ae.unstable_flushUntilNextPaint=function()if aj then error'Already flushing work.'end if ap~=nil then
local aw=ap an=true am=false aj=true local ax,az=pcall(function()local ax=true repeat ax=aw(true,af)until not ax or ai
if not ax then ap=nil end end)an=false ai=false aj=false if not ax then error(az)end end end ae.unstable_flushExpired=
function()if aj then error'Already flushing work.'end if ap~=nil then aj=true local aw,ax=pcall(function()local aw=ap
local ax=aw(false,af)if not ax then ap=nil end end)aj=false if not aw then error(ax)end end end ae.
unstable_flushAllWithoutAsserting=function()if aj then error'Already flushing work.'end if ap~=nil then local aw=ap aj=
true local ax,az=pcall(function()local ax=true repeat ax=aw(true,af)until not ax if not ax then ap=nil end end)aj=false
if not ax then error(az)end return true else return false end end ae.unstable_clearYields=function()if ar==nil then
return{}end local aw=ar ar=nil return aw end ae.unstable_flushAll=function()if ar~=nil then error
[[Log is not empty. Assert on the log of yielded values before flushing additional work.]]end ae.
unstable_flushAllWithoutAsserting()if ar~=nil then error
[[While flushing work, something yielded a value. Use an assertion helper to assert on the log of yielded values, e.g. expect(Scheduler).toFlushAndYield([...])]]
end end ae.unstable_yieldValue=function(aw)if as.log==av then return end if ar==nil then ar={aw}else local ax=ar table.
insert(ax,aw)end end ae.unstable_advanceTime=function(aw)if as.log==av then return end af+=aw if aq~=nil and ag<=af then
local ax=aq ax(af)ag=-1 aq=nil end end ae.requestPaint=function()am=true end return ae end)()end,[151]=function()local
aa,ab,ac=a(151)local ad return(function(...)local ae,af=ac(ab.Parent.Tracing),ac(ab.Parent.TracingSubscriptions)local ag
,ah=ac(ab.Parent.Scheduler),ac(ab.Parent.forks['SchedulerHostConfig.mock'])local ai,aj=ag(ah),{}aj.tracing={}for am,an
in ai do aj[am]=an end for ao,ap in ae do aj.tracing[ao]=ap end for aq,ar in af do aj.tracing[aq]=ar end aj.
unstable_flushAllWithoutAsserting=ah.unstable_flushAllWithoutAsserting aj.unstable_flushNumberOfYields=ah.
unstable_flushNumberOfYields aj.unstable_flushExpired=ah.unstable_flushExpired aj.unstable_clearYields=ah.
unstable_clearYields aj.unstable_flushUntilNextPaint=ah.unstable_flushUntilNextPaint aj.unstable_flushAll=ah.
unstable_flushAll aj.unstable_yieldValue=ah.unstable_yieldValue aj.unstable_advanceTime=ah.unstable_advanceTime aj.
unstable_Profiling=ai.unstable_Profiling return aj end)()end,[152]=function()local aa,ab,ac=a(152)local ad return(
function(...)local ae=ab.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai,aj,aq,ar=ac(ab.ReactTypes),ac(ab[
'flowtypes.roblox']),ac(ab.ReactElementType),ac(ab.ReactFiberHostConfig),ac(ab.ReactSharedInternals),ac(ab[
'ErrorHandling.roblox'])return{checkPropTypes=ac(ab.checkPropTypes),console=ac(ab.console),ConsolePatchingDev=ac(ab[
'ConsolePatchingDev.roblox']),consoleWithStackDev=ac(ab.consoleWithStackDev),enqueueTask=ac(ab['enqueueTask.roblox']),
ExecutionEnvironment=ac(ab.ExecutionEnvironment),formatProdErrorMessage=ac(ab.formatProdErrorMessage),getComponentName=
ac(ab.getComponentName),invariant=ac(ab.invariant),invokeGuardedCallbackImpl=ac(ab.invokeGuardedCallbackImpl),
isValidElementType=ac(ab.isValidElementType),objectIs=ac(ab.objectIs),ReactComponentStackFrame=ac(ab.
ReactComponentStackFrame),ReactElementType=ac(ab.ReactElementType),ReactErrorUtils=ac(ab.ReactErrorUtils),
ReactFeatureFlags=ac(ab.ReactFeatureFlags),ReactInstanceMap=ac(ab.ReactInstanceMap),ReactSharedInternals=aq,
ReactFiberHostConfig=aj,ReactSymbols=ac(ab.ReactSymbols),ReactVersion=ac(ab.ReactVersion),shallowEqual=ac(ab.
shallowEqual),UninitializedState=ac(ab['UninitializedState.roblox']),ReactTypes=ag,describeError=ar.describeError,
errorToString=ar.errorToString,parseReactError=ar.parseReactError,Symbol=ac(ab['Symbol.roblox']),Type=ac(ab[
'Type.roblox']),Change=ac(ab.PropMarkers.Change),Event=ac(ab.PropMarkers.Event),Tag=ac(ab.PropMarkers.Tag)}end)()end,[
153]=function()local aa,ab,ac=a(153)local ad return(function(...)local ae,af,ag,ah,ai,aj,aq,ar,as,au,av=ac(ab.Parent.
console),0,function()end,{}ah.disabledLog=ag ah.disableLogs=function()if _G.__DEV__ then if af==0 then ai=ae.log aj=ae.
info aq=ae.warn ar=ae.error as=ae.group au=ae.groupCollapsed av=ae.groupEnd ae.info=ag ae.log=ag ae.warn=ag ae.error=ag
ae.group=ag ae.groupCollapsed=ag ae.groupEnd=ag end af=af+1 end end ah.reenableLogs=function()if _G.__DEV__ then af=af-1
if af==0 then ae.log=ai ae.info=aj ae.warn=aq ae.error=ar ae.group=as ae.groupCollapsed=au ae.groupEnd=av end if af<0
then ae.error[[disabledDepth fell below zero. This is a bug in React. Please file an issue.]]end end end return ah end)(
)end,[154]=function()local aa,ab,ac=a(154)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag,ah,ai=af.Error,af.util.inspect,'\n------ Error caught by React ------\n'local function aj(aq)if
typeof(aq)=='string'then local ar,as=string.find(aq,':[%d]+: ')local au=if as then string.sub(aq,as+1)else aq local av=
af.Error.new(au)av.stack=debug.traceback(nil,2)return av end return aq end local function aq(ar)local as if typeof(ar)==
'table'then if(ar).message and(ar).stack then as=ai..(ar).message..ai..tostring((ar).stack)else as=ah(ar)end else as=ah(
ar)end return as end local function ar(as)local au=string.split(as,ai)if#au==3 then local av,aw,ax=table.unpack(au)local
az=ag.new(aw)az.stack=ax return az,av else local av=ag.new(as)av.stack=nil return av,''end end return{describeError=aj,
errorToString=aq,parseReactError=ar,__ERROR_DIVIDER=ai}end)()end,[155]=function()local aa,ab,ac=a(155)local ad return(
function(...)local ae={}ae.canUseDOM=function()return false end return ae end)()end,[157]=function()local aa,ab,ac=a(157
)local ad return(function(...)local ae,af,ag=ac(ab.Parent.Parent['Type.roblox']),{},{__tostring=function(ae)return
string.format('RoactHostChangeEvent(%s)',ae.name)end}setmetatable(af,{__index=function(ah,ai)local aj={[ae]=ae.
HostChangeEvent,name=ai}setmetatable(aj,ag)af[ai]=aj return aj end})return af end)()end,[158]=function()local aa,ab,ac=
a(158)local ad return(function(...)local ae,af,ag=ac(ab.Parent.Parent['Type.roblox']),{},{__tostring=function(ae)return
string.format('RoactHostEvent(%s)',ae.name)end}setmetatable(af,{__index=function(ah,ai)local aj={[ae]=ae.HostEvent,name=
ai}setmetatable(aj,ag)af[ai]=aj return aj end})return af end)()end,[159]=function()local aa,ab,ac=a(159)local ad return(
function(...)local ae=ac(ab.Parent.Parent['Symbol.roblox'])local af=ae.named'RobloxTag'return af end)()end,[160]=
function()local aa,ab,ac=a(160)local ad return(function(...)local ae=ac(ab.Parent.ReactElementType)local af=ac(ab.Parent
['flowtypes.roblox'])local ag=ac(ab.Parent.ReactSymbols)local ah,ai,aj,aq,ar,as,au=ag.REACT_SUSPENSE_TYPE,ag.
REACT_SUSPENSE_LIST_TYPE,ag.REACT_FORWARD_REF_TYPE,ag.REACT_MEMO_TYPE,ag.REACT_BLOCK_TYPE,ag.REACT_LAZY_TYPE,ac(ab.
Parent['ConsolePatchingDev.roblox'])local av,aw,ax=au.disableLogs,au.reenableLogs,ac(ab.Parent.ReactSharedInternals)
local az,aA,aB,aC=ax.ReactCurrentDispatcher,'    in 'local function aD(aE)if type(aE)=='function'then return debug.info(
aE,'n')elseif type(aE)=='table'then return tostring(aE)end return nil end local function aE(aF,aG,aH)local aI if _G.
__DEV__ and aH then aI=aD(aH)end return aB(aF,aG,aI)end local aF,aG=false if _G.__DEV__ then aG=setmetatable({},{__mode=
'k'})end local function aH(aI,aJ)if not aI or aF then return''end if _G.__DEV__ then local aK=aG[aI]if aK~=nil then
return aK end end local aK aF=true local aN if _G.__DEV__ then aN=az.current az.current=nil av()end local aO local aP,aQ
=xpcall(function()if aJ then else local aP,aQ=pcall(function()aO=debug.traceback()error{stack=aO}end)aK=aQ;(aI)()end end
,function(aP)return{message=aP,stack=aO}end)local aR if aQ and aK and type(aQ.stack)=='string'then local aS,aT=string.
split(aQ.stack,'\n'),string.split(aK.stack,'\n')local aU,aV=#aS-1,#aT-1 while aU>=2 and aV>=0 and aS[aU]~=aT[aV]do aV=aV
-1 end while aU>=3 and aV>=1 do aU=aU-1 aV=aV-1 if aS[aU]~=aT[aV]then if aU~=1 or aV~=1 then repeat aU=aU-1 aV=aV-1 if
aV<0 or aS[aU]~=aT[aV]then local aW='\n'..aA..aS[aU]if _G.__DEV__ then aG[aI]=aW end aR=aW end until not(aU>=3 and aV>=1
)end break end end end aF=false if _G.__DEV__ then az.current=aN aw()end if aR~=nil then return aR end local aS,aT=if
type(aI)=='function'then debug.info(aI,'n')else if type(aI)=='table'then tostring(aI)else'',''if aS~=nil and aS~=''then
aT=aE(aS)end if _G.__DEV__ then aG[aI]=aT end return aT end local aI='^(.*)[\\/]'function aB(aJ,aK,aN)local aO=''if _G.
__DEV__ and aK then local aP=aK.fileName local aQ=string.gsub(aP,aI,'')if string.match(aQ,'^init%.')then local aR=string
.match(aP,aI)if aR and#aR~=0 then local aS=string.gsub(aR,aI,'')aQ=aS..'/'..aQ end end aO=' (at '..aQ..':'..aK.
lineNumber..')'elseif aN then aO=' (created by '..aN..')'end return'\n    in '..(aJ or'Unknown')..aO end local function
aJ(aK,aN,aO)local aP,aQ=(tostring(aK))if _G.__DEV__ and aO then aQ=aD(aO)end return aB(aP,aN,aQ)end function aC(aK,aN,aO
)if not aK then return''end local aP,aQ=if type(aK)=='function'then debug.info(aK,'n')else tostring(aK)if _G.__DEV__ and
aO then aQ=aD(aO)end return aB(aP,aN,aQ)end local function aK(aN,aO,aP)if not _G.__DEV__ then return''end if aN==nil
then return''end if type(aN)=='table'and type(aN.__ctor)=='function'then return aJ(aN,aO,aP)end if type(aN)=='function'
then return aC(aN,aO,aP)end if type(aN)=='string'then return aE(aN,aO,aP)end if aN==ah then return aE('Suspense',aO,aP)
elseif aN==ai then return aE('SuspenseList',aO,aP)end if type(aN)=='table'then local aQ=aN['$$typeof']if aQ==aj then
return aC(aN.render,aO,aP)elseif aQ==aq then return aK(aN.type,aO,aP)elseif aQ==ar then return aC(aN._render,aO,aP)
elseif aQ==as then local aR=aN local aS,aT=aR._payload,aR._init local aU,aV=pcall(function()aK(aT(aS),aO,aP)end)if aU
then return aV end end end return''end return{describeComponentFrame=aB,describeBuiltInComponentFrame=aE,
describeNativeComponentFrame=aH,describeClassComponentFrame=aJ,describeFunctionComponentFrame=aC,
describeUnknownElementTypeFrameInDEV=aK}end)()end,[161]=function()local aa,ab,ac=a(161)local ad return(function(...)
local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ab.Parent['flowtypes.roblox'])return{}end)()end,[162]=
function()local aa,ab,ac=a(162)local ad return(function(...)local ae,af,ag,ah,ai,aj,aq=ac(ab.Parent.invariant),ac(ab.
Parent.invokeGuardedCallbackImpl),false,false local ar,as={onError=function(ar)ag=true aj=ar end},{}as.
invokeGuardedCallback=function(...)ag=false aj=nil af(ar,...)end as.invokeGuardedCallbackAndCatchFirstError=function(...
)as.invokeGuardedCallback(...)if ag then local au=ai()if not ah then ah=true aq=au end end end as.rethrowCaughtError=
function()if ah then local au=aq ah=false aq=nil error(au)end end as.hasCaughtError=function()return ag end ai=function(
)if ag then local au=aj ag=false aj=nil return au else ae(false,
[[clearCaughtError was called but no error was captured. This error is likely caused by a bug in React. Please file an issue.]]
)return nil end end as.clearCaughtError=ai return as end)()end,[163]=function()local aa,ab,ac=a(163)local ad return(
function(...)local ae={}ae.enableFilterEmptyStringAttributesDOM=true ae.enableDebugTracing=false ae.
enableSchedulingProfiler=_G.__PROFILE__ and _G.__EXPERIMENTAL__ ae.debugRenderPhaseSideEffectsForStrictMode=_G.__DEV__
ae.replayFailedUnitOfWorkWithInvokeGuardedCallback=_G.__DEV__ ae.warnAboutDeprecatedLifecycles=true ae.
enableProfilerTimer=_G.__PROFILE__ ae.enableProfilerCommitHooks=false ae.enableSchedulerTracing=_G.__PROFILE__ ae.
enableSuspenseServerRenderer=_G.__EXPERIMENTAL__ ae.enableSelectiveHydration=_G.__EXPERIMENTAL__ ae.enableBlocksAPI=_G.
__EXPERIMENTAL__ ae.enableLazyElements=_G.__EXPERIMENTAL__ ae.enableSchedulerDebugging=false ae.disableJavaScriptURLs=
false ae.enableFundamentalAPI=false ae.enableScopeAPI=false ae.enableCreateEventHandleAPI=false ae.
warnAboutUnmockedScheduler=false ae.enableSuspenseCallback=false ae.warnAboutDefaultPropsOnFunctionComponents=false ae.
disableSchedulerTimeoutBasedOnReactExpirationTime=false ae.enableTrustedTypesIntegration=false ae.
warnAboutSpreadingKeyToJSX=true ae.enableComponentStackLocations=true ae.enableNewReconciler=true ae.
skipUnmountedBoundaries=true ae.disableInputAttributeSyncing=true ae.warnAboutStringRefs=false ae.disableLegacyContext=
false ae.disableTextareaChildren=false ae.disableModulePatternComponents=false ae.warnUnstableRenderSubtreeIntoContainer
=false ae.enableLegacyFBSupport=true ae.deferRenderPhaseUpdateToNextBatch=false ae.decoupleUpdatePriorityFromScheduler=
true ae.enableDiscreteEventFlushingChange=false ae.enableEagerRootListeners=false ae.enableDoubleInvokingEffects=false
return ae end)()end,[164]=function()local aa,ab,ac=a(164)local ad return(function(...)return{WithNoHydration=ac(ab.
WithNoHydration),WithNoPersistence=ac(ab.WithNoPersistence),WithNoTestSelectors=ac(ab.WithNoTestSelectors)}end)()end,[
165]=function()local aa,ab,ac=a(165)local ad return(function(...)local ae=ac(ab.Parent.Parent.invariant)function shim(
...)ae(false,
[[The current renderer does not support hydration. This error is likely caused by a bug in React. Please file an issue.]]
)end return{supportsHydration=false,canHydrateInstance=shim,canHydrateTextInstance=shim,canHydrateSuspenseInstance=shim,
isSuspenseInstancePending=shim,isSuspenseInstanceFallback=shim,registerSuspenseInstanceRetry=shim,
getNextHydratableSibling=shim,getFirstHydratableChild=shim,hydrateInstance=shim,hydrateTextInstance=shim,
hydrateSuspenseInstance=shim,getNextHydratableInstanceAfterSuspenseInstance=shim,commitHydratedContainer=shim,
commitHydratedSuspenseInstance=shim,clearSuspenseBoundary=shim,clearSuspenseBoundaryFromContainer=shim,
didNotMatchHydratedContainerTextInstance=shim,didNotMatchHydratedTextInstance=shim,didNotHydrateContainerInstance=shim,
didNotHydrateInstance=shim,didNotFindHydratableContainerInstance=shim,didNotFindHydratableContainerTextInstance=shim,
didNotFindHydratableContainerSuspenseInstance=shim,didNotFindHydratableInstance=shim,didNotFindHydratableTextInstance=
shim,didNotFindHydratableSuspenseInstance=shim}end)()end,[166]=function()local aa,ab,ac=a(166)local ad return(function(
...)local ae=ac(ab.Parent.Parent.invariant)local function af(...)ae(false,
[[The current renderer does not support persistence. This error is likely caused by a bug in React. Please file an issue.]]
)end return{supportsPersistence=false,cloneInstance=af,cloneFundamentalInstance=af,createContainerChildSet=af,
appendChildToContainerChildSet=af,finalizeContainerChildren=af,replaceContainerChildren=af,cloneHiddenInstance=af,
cloneHiddenTextInstance=af}end)()end,[167]=function()local aa,ab,ac=a(167)local ad return(function(...)local ae=ac(ab.
Parent.Parent.invariant)local function af(...)ae(false,
[[The current renderer does not support test selectors. This error is likely caused by a bug in React. Please file an issue.]]
)end return{supportsTestSelectors=false,findFiberRoot=af,getBoundingRect=af,getTextContent=af,isHiddenSubtree=af,
matchAccessibilityRole=af,setFocusIfFocusable=af,setupIntersectionObserver=af}end)()end,[168]=function()local aa,ab,ac=
a(168)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag=ac(af.LuauPolyfill)local ah,ai,aj,aq=
ag.Error,ag.util.inspect,ac(ab.Parent.getComponentName),{}local function ar(as)return as.tag~=nil and as.subtreeFlags~=
nil and as.lanes~=nil and as.childLanes~=nil end aq.remove=function(as)as._reactInternals=nil end aq.get=function(as)
local au=as._reactInternals if not ar(au)then error(ah.new('invalid fiber in '..(aj(as)or'UNNAMED Component')..
' during get from ReactInstanceMap! '..ai(au)))elseif au.alternate~=nil and not ar(au.alternate)then error(ah.new(
'invalid alternate fiber ('..(aj(as)or'UNNAMED alternate')..') in '..(aj(as)or'UNNAMED Component')..
' during get from ReactInstanceMap! '..ai(au.alternate)))end return au end aq.has=function(as)return as._reactInternals
~=nil end aq.set=function(as,au)local av,aw=au while av~=nil do if not ar(av)then aw='invalid fiber in '..(aj(as)or
'UNNAMED Component')..' being set in ReactInstanceMap! '..ai(av)..'\n'if au~=av then aw..=' (from original fiber '..(aj(
as)or'UNNAMED Component')..')'end error(ah.new(aw))elseif(av).alternate~=nil and not ar((av).alternate)then aw=
'invalid alternate fiber ('..(aj(as)or'UNNAMED alternate')..') in '..(aj(as)or'UNNAMED Component')..
' being set in ReactInstanceMap! '..ai((av).alternate)..'\n'if au~=av then aw..=' (from original fiber '..(aj(as)or
'UNNAMED Component')..')'end error(ah.new(aw))end av=(av).return_ end(as)._reactInternals=au end return aq end)()end,[
169]=function()local aa,ab,ac=a(169)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill).
console local function ag(ah)return function()af.error(ah..' is only available in tests, not in production')end end
local ah=ac(ab.ReactCurrentDispatcher)local ai,aj,aq,ar=ac(ab.ReactCurrentBatchConfig),ac(ab.ReactCurrentOwner),ac(ab.
ReactDebugCurrentFrame),ac(ab.IsSomeRendererActing)local as={ReactCurrentDispatcher=ah,ReactCurrentBatchConfig=ai,
ReactCurrentOwner=aj,IsSomeRendererActing=ar,ReactDebugCurrentFrame=if _G.__DEV__ then aq else{setExtraStackFrame=
function(as)ag'setExtraStackFrame'end}}return as end)()end,[170]=function()local aa,ab,ac=a(170)local ad return(function
(...)local ae={current=false}return ae end)()end,[171]=function()local aa,ab,ac=a(171)local ad return(function(...)local
ae={transition=0}return ae end)()end,[172]=function()local aa,ab,ac=a(172)local ad return(function(...)local ae=ab.
Parent.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=ac(ab.Parent.Parent.ReactElementType)local ah=ac(ab.Parent.
Parent.ReactTypes)local ai={current=nil}return ai end)()end,[173]=function()local aa,ab,ac=a(173)local ad return(
function(...)local ae={current=nil}return ae end)()end,[174]=function()local aa,ab,ac=a(174)local ad return(function(...
)local ae,af={}function ae.setExtraStackFrame(ag)if _G.__DEV__ then af=ag end end if _G.__DEV__ then ae.getCurrentStack=
nil function ae.getStackAddendum()local ag=''if af then ag=ag..af end local ah=ae.getCurrentStack if ah then ag=ag..(ah(
)or'')end return ag end end return ae end)()end,[175]=function()local aa,ab,ac=a(175)local ad return(function(...)local
ae={}ae.REACT_ELEMENT_TYPE=0xeac7 ae.REACT_PORTAL_TYPE=0xeaca ae.REACT_FRAGMENT_TYPE=0xeacb ae.REACT_STRICT_MODE_TYPE=
0xeacc ae.REACT_PROFILER_TYPE=0xead2 ae.REACT_PROVIDER_TYPE=0xeacd ae.REACT_CONTEXT_TYPE=0xeace ae.
REACT_FORWARD_REF_TYPE=0xead0 ae.REACT_SUSPENSE_TYPE=0xead1 ae.REACT_SUSPENSE_LIST_TYPE=0xead8 ae.REACT_MEMO_TYPE=0xead3
ae.REACT_LAZY_TYPE=0xead4 ae.REACT_BLOCK_TYPE=0xead9 ae.REACT_SERVER_BLOCK_TYPE=0xeada ae.REACT_FUNDAMENTAL_TYPE=0xead5
ae.REACT_SCOPE_TYPE=0xead7 ae.REACT_OPAQUE_ID_TYPE=0xeae0 ae.REACT_DEBUG_TRACING_MODE_TYPE=0xeae1 ae.
REACT_OFFSCREEN_TYPE=0xeae2 ae.REACT_LEGACY_HIDDEN_TYPE=0xeae3 ae.REACT_BINDING_TYPE=0xeae4 ae.getIteratorFn=function(af
)if typeof(af)=='table'then if af['$$typeof']==ae.REACT_PORTAL_TYPE then return nil end return function()local ag,ah
return{next=function()ag,ah=next(af,ag)return{done=ah==nil,key=ag,value=ah}end}end end return nil end return ae end)()
end,[176]=function()local aa,ab,ac=a(176)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.
LuauPolyfill)local ag=ac(ab.Parent['flowtypes.roblox'])local ah={}ah.DiscreteEvent=0 ah.UserBlockingEvent=1 ah.
ContinuousEvent=2 return ah end)()end,[177]=function()local aa,ab,ac=a(177)local ad return(function(...)return'17.0.1'
end)()end,[178]=function()local aa,ab,ac=a(178)local ad return(function(...)local ae={}function ae.named(af)assert(type(
af)=='string','Symbols must be created using a string name!')local ag,ah=newproxy(true),string.format('Symbol(%s)',af)
getmetatable(ag).__tostring=function()return ah end return ag end return ae end)()end,[179]=function()local aa,ab,ac=a(
179)local ad return(function(...)local ae,af,ag=ac(ab.Parent['Symbol.roblox']),newproxy(true),{}local function ah(ai)ag[
ai]=ae.named('Roact'..ai)end ah'HostChangeEvent'ah'HostEvent'function ag.of(ai)if typeof(ai)~='table'then return nil end
return ai[af]end getmetatable(af).__index=ag getmetatable(af).__tostring=function()return'RoactType'end return af end)()
end,[180]=function()local aa,ab,ac=a(180)local ad return(function(...)local ae,af=ac(ab.Parent.console),{}setmetatable(
af,{__index=function(ag,ah)if _G.__DEV__ then ae.warn
[[Attempted to access uninitialized state. Use setState to initialize state]]end return nil end,__newindex=function(ag,
ah)if _G.__DEV__ then ae.error[[Attempted to directly mutate state. Use setState to assign new values to state.]]end
return nil end,__tostring=function(ag)return'<uninitialized component state>'end,__metatable='UninitializedState'})
return af end)()end,[181]=function()local aa,ab,ac=a(181)local ad return(function(...)local ae=ab.Parent.Parent local af
=ac(ae.LuauPolyfill)local ag=af.Error local ah,ai,aj=ac(ab.Parent.console),{},ac(ab.Parent.ReactComponentStackFrame)
local aq,ar,as=aj.describeUnknownElementTypeFrameInDEV,ac(ab.Parent.ReactSharedInternals),ac(ab.Parent[
'ErrorHandling.roblox']).describeError local au=ar.ReactDebugCurrentFrame local function av(aw)if _G.__DEV__ then if aw
then local ax=aw._owner local az=aq(aw.type,aw._source,if ax~=nil then ax.type else nil);(au.setExtraStackFrame)(az)else
(au.setExtraStackFrame)(nil)end end end local function aw(ax,az,aA,aB,aC,aD)if _G.__DEV__ or _G.
__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then if ax and az then ah.warn(
"You've defined both propTypes and validateProps on "..(aC or'a component'))end if az then if typeof(az)~='function'then
ah.error(([[validateProps must be a function, but it is a %s.
Check the definition of the component %q.]]):format(
typeof(az),aC or''))else local aE,aF=az(aA)if not aE then aF=aF or'<Validator function did not supply a message>'local
aG=string.format('validateProps failed on a %s type in %s: %s',aB,aC or'<UNKNOWN Component>',tostring(aF))error(aG)end
end end if ax then assert(typeof(ax)=='table','propTypes needs to be a table')for aE,aF in ax do local aG,aH=xpcall(
function()if typeof(ax[aE])~='function'then local aG=ag.new((aC or'React class')..': '..aB..' type `'..aE..
'` is invalid; '..[[it must be a function, usually from the `prop-types` package, but received `]]..typeof(ax[aE])..
[[`.This often happens because of typos such as `PropTypes.function` instead of `PropTypes.func`.]])aG.name=
'Invariant Violation'error(aG)end return(ax[aE])(aA,aE,aC,aB,nil,'SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED')end,as)
local aI=typeof(aH)=='table'if aH~=nil and not aI then av(aD)ah.error(string.format(
[[%s: type specification of %s `%s` is invalid; the type checker function must return `nil` or an `Error` but returned a %s. You may have forgotten to pass an argument to the type checker creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and shape all require an argument).]]
,aC or'React class',aB,aE,typeof(aH)))av(nil)end if aI and ai[(aH).message]==nil then ai[tostring((aH).message)]=true
av(aD)ah.warn(string.format('Failed %s type: %s',aB,tostring((aH).message)))av(nil)end end end end end return aw end)()
end,[182]=function()local aa,ab,ac=a(182)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag=ac(
af.LuauPolyfill)local ah,ai=ag.console,ac(ae.consoleWithStackDev)if _G.__DEV__ then local aj=setmetatable({warn=ai.warn,
error=ai.error},{__index=ah})return aj end return ah end)()end,[183]=function()local aa,ab,ac=a(183)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag,ah,ai,aj,aq=af.console,af.Array,ac(ab.Parent
.ReactSharedInternals),{}aj.warn=function(ar,...)if _G.__DEV__ then aq('warn',ar,{...})end end aj.error=function(ar,...)
if _G.__DEV__ then aq('error',ar,{...})end end function aq(ar,as,au)if _G.__DEV__ then local av=ai.
ReactDebugCurrentFrame local aw=av.getStackAddendum()if aw~=''then as..='%s'au=ah.slice(au,1)table.insert(au,aw)end
local ax=ah.map(au,tostring)table.insert(ax,1,'Warning: '..as)ag[ar](unpack(ax))end end return aj end)()end,[184]=
function()local aa,ab,ac=a(184)local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local
ag=af.setTimeout return function(ah)return ag(ah,0)end end)()end,[185]=function()local aa,ab,ac=a(185)local ad return(
function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)return{}end)()end,[186]=function()local aa,ab,ac=a(
186)local ad return(function(...)local ae=game:GetService'HttpService'local function af(ag,...)local ah,ai=
'https://reactjs.org/docs/error-decoder.html?invariant='..tostring(ag),select('#',...)for aj=1,ai,1 do ah=ah..'&args[]='
..ae:UrlEncode(select(aj,...))end return string.format(
[[Minified React error #%d; visit %s for the full message or use the non-minified dev environment for full errors and additional helpful warnings.]]
,ag,ah)end return af end)()end,[187]=function()local aa,ab,ac=a(187)local ad return(function(...)local ae=ac(ab.Parent.
console)local af=ac(ab.Parent.ReactSymbols)local ag,ah,ai,aj,aq,ar,as,au,av,aw,ax,az,aA=af.REACT_CONTEXT_TYPE,af.
REACT_FORWARD_REF_TYPE,af.REACT_FRAGMENT_TYPE,af.REACT_PORTAL_TYPE,af.REACT_MEMO_TYPE,af.REACT_PROFILER_TYPE,af.
REACT_PROVIDER_TYPE,af.REACT_STRICT_MODE_TYPE,af.REACT_SUSPENSE_TYPE,af.REACT_SUSPENSE_LIST_TYPE,af.REACT_LAZY_TYPE,af.
REACT_BLOCK_TYPE,ac(ab.Parent.ReactTypes)local aB=ac(ab.Parent['ErrorHandling.roblox']).describeError local function aC(
aD,aE,aF)local aG='<function>'if typeof(aE)=='table'then aG=aE.displayName or aE.name or''end return aD.displayName or(
aG~=''and string.format('%s(%s)',aF,aG)or aF)end local function aD(aE)return aE.displayName or'Context'end
local function aE(aF)if aF==nil then return nil end local aG=typeof(aF)if _G.__DEV__ then if aG=='table'and typeof(aF.
tag)=='number'then ae.warn
[[Received an unexpected object in getComponentName(). This is likely a bug in React. Please file an issue.]]end end if
aG=='function'then local aH=debug.info((aF),'n')if aH and string.len(aH)>0 then return aH else return nil end end if aG
=='string'then return(aF)end if aF==ai then return'Fragment'elseif aF==aj then return'Portal'elseif aF==ar then return
'Profiler'elseif aF==au then return'StrictMode'elseif aF==av then return'Suspense'elseif aF==aw then return
'SuspenseList'end if aG=='table'then local aH=aF['$$typeof']if aH==ag then local aI=aF return aD(aI)..'.Consumer'elseif
aH==as then local aI=aF return aD(aI._context)..'.Provider'elseif aH==ah then return aC(aF,aF.render,'ForwardRef')elseif
aH==aq then return aE(aF.type)elseif aH==az then return aE(aF._render)elseif aH==ax then local aI=aF local aJ,aK=aI.
_payload,aI._init local aN,aO=xpcall(aK,aB,aJ)if aN then return aE(aO)else return nil end else if aF.displayName then
return aF.displayName end if aF.name then return aF.name end local aI=getmetatable(aF)if aI and rawget(aI,'__tostring')
then return tostring(aF)end end end return nil end return aE end)()end,[188]=function()local aa,ab,ac=a(188)local ad
return(function(...)local ae=ab.Parent.Parent local af=ac(ae.LuauPolyfill)local ag=af.Error local function ah(ai,aj,...)
if not ai then error(ag(string.format(aj,...)))end end return ah end)()end,[189]=function()local aa,ab,ac=a(189)local ad
return(function(...)local ae=ac(ab.Parent['ErrorHandling.roblox']).describeError local function af(ag,ah,ai,aj,...)local
aq,ar if not _G.__YOLO__ then if aj==nil then aq,ar=xpcall(ai,ae,...)else aq,ar=xpcall(ai,ae,aj,...)end else aq=true if
aj==nil then ai(...)else ai(aj,...)end end if not aq then ag.onError(ar)end end local ag=af if _G.__DEV__ then end
return ag end)()end,[190]=function()local aa,ab,ac=a(190)local ad return(function(...)local ae=ac(ab.Parent.ReactSymbols
)local af,ag,ah,ai,aj,aq,ar,as,au,av,aw,ax,az,aA=ae.REACT_CONTEXT_TYPE,ae.REACT_FORWARD_REF_TYPE,ae.REACT_FRAGMENT_TYPE,
ae.REACT_PROFILER_TYPE,ae.REACT_PROVIDER_TYPE,ae.REACT_DEBUG_TRACING_MODE_TYPE,ae.REACT_STRICT_MODE_TYPE,ae.
REACT_SUSPENSE_TYPE,ae.REACT_MEMO_TYPE,ae.REACT_LAZY_TYPE,ae.REACT_FUNDAMENTAL_TYPE,ae.REACT_BLOCK_TYPE,ae.
REACT_SERVER_BLOCK_TYPE,ae.REACT_LEGACY_HIDDEN_TYPE return function(aB)local aC=typeof(aB)if aC=='string'or aC==
'function'then return true end if aB==ah or aB==ai or aB==aq or aB==ar or aB==as or aB==aA then return true end if aC==
'table'then if aB.isReactComponent then return true end if aB['$$typeof']==av or aB['$$typeof']==au or aB['$$typeof']==
aj or aB['$$typeof']==af or aB['$$typeof']==ag or aB['$$typeof']==aw or aB['$$typeof']==ax or aB[1]==az then return true
end end return false end end)()end,[191]=function()local aa,ab,ac=a(191)local ad return(function(...)local function ae(
af,ag)return af==ag and(af~=0 or 1/af==1/ag)or af~=af and ag~=ag end local af=ae return af end)()end,[192]=function()
local aa,ab,ac=a(192)local ad return(function(...)local ae=ac(ab.Parent.objectIs)local function af(ag,ah)if ae(ag,ah)
then return true end if typeof(ag)~='table'or ag==nil or typeof(ah)~='table'or ah==nil then return false end for ai,aj
in ag do if not ae(ah[ai],aj)then return false end end for aq,ar in ah do if not ae(ag[aq],ar)then return false end end
return true end return af end)()end,[195]=function()local aa,ab,ac=a(195)local ad return(function(...)local ae,af,ag,ah=
'Non-promise value passed into %s at index %s','Please pass a list of promises to %s',
'Please pass a handler function to %s!',{__mode='k'}local function aq(ar)if type(ar)=='function'then return true end if
type(ar)=='table'then local as=getmetatable(ar)if as and type(rawget(as,'__call'))=='function'then return true end end
return false end local function ar(as,au)local av={}for aw,ax in ipairs(au)do av[ax]=ax end return setmetatable(av,{
__index=function(az,aA)error(string.format('%s is not in %s!',aA,as),2)end,__newindex=function()error(string.format(
'Creating new members in %s is not allowed!',as),2)end})end local as do as={Kind=ar('Promise.Error.Kind',{
'ExecutionError','AlreadyCancelled','NotResolvedInTime','TimedOut'})}as.__index=as function as.new(au,av)au=au or{}
return setmetatable({error=tostring(au.error)or'[This error has no error text.]',trace=au.trace,context=au.context,kind=
au.kind,parent=av,createdTick=os.clock(),createdTrace=debug.traceback()},as)end function as.is(au)if type(au)=='table'
then local av=getmetatable(au)if type(av)=='table'then return rawget(au,'error')~=nil and type(rawget(av,'extend'))==
'function'end end return false end function as.isKind(au,av)assert(av~=nil,
'Argument #2 to Promise.Error.isKind must not be nil')return as.is(au)and au.kind==av end function as.extend(au,av)av=av
or{}av.kind=av.kind or au.kind return as.new(av,au)end function as.getErrorChain(au)local av={au}while av[#av].parent do
table.insert(av,av[#av].parent)end return av end function as.__tostring(au)local av={string.format(
'-- Promise.Error(%s) --',au.kind or'?')}for aw,ax in ipairs(au:getErrorChain())do table.insert(av,table.concat({ax.
trace or ax.error,ax.context},'\n'))end return table.concat(av,'\n')end end local function au(...)return select('#',...)
,{...}end local function av(aw,...)return aw,select('#',...),{...}end local function aw(ax)assert(ax~=nil,
'traceback is nil')return function(az)if type(az)=='table'then return az end return as.new{error=az,kind=as.Kind.
ExecutionError,trace=debug.traceback(tostring(az),2),context='Promise created at:\n\n'..ax}end end local function ax(az,
aA,...)return av(xpcall(aA,aw(az),...))end local function az(aA,aB,aC,aD)return function(...)local aE,aF,aG=ax(aA,aB,...
)if aE then aC(unpack(aG,1,aF))else aD(aG[1])end end end local function aA(aB)return next(aB)==nil end local aB={Error=
as,Status=ar('Promise.Status',{'Started','Resolved','Rejected','Cancelled'}),_getTime=os.clock,_timeEvent=game:
GetService'RunService'.Heartbeat,_unhandledRejectionCallbacks={}}aB.prototype={}aB.__index=aB.prototype function aB._new
(aC,aD,aE)if aE~=nil and not aB.is(aE)then error('Argument #2 to Promise.new must be a promise or nil',2)end local aF={
_thread=nil,_source=aC,_status=aB.Status.Started,_values=nil,_valuesLength=-1,_unhandledRejection=true,_queuedResolve={}
,_queuedReject={},_queuedFinally={},_cancellationHook=nil,_parent=aE,_consumers=setmetatable({},ah)}if aE and aE._status
==aB.Status.Started then aE._consumers[aF]=true end setmetatable(aF,aB)local function aG(...)aF:_resolve(...)end
local function aH(...)aF:_reject(...)end local function aI(aJ)if aJ then if aF._status==aB.Status.Cancelled then aJ()
else aF._cancellationHook=aJ end end return aF._status==aB.Status.Cancelled end aF._thread=coroutine.create(function()
local aJ,aK,aN=ax(aF._source,aD,aG,aH,aI)if not aJ then aH(aN[1])end end)task.spawn(aF._thread)return aF end function aB
.new(aC)return aB._new(debug.traceback(nil,2),aC)end function aB.__tostring(aC)return string.format('Promise(%s)',aC.
_status)end function aB.defer(aC)local aD,aE=(debug.traceback(nil,2))aE=aB._new(aD,function(aF,aG,aH)local aI aI=aB.
_timeEvent:Connect(function()aI:Disconnect()local aJ,aK,aN=ax(aD,aC,aF,aG,aH)if not aJ then aG(aN[1])end end)end)return
aE end aB.async=aB.defer function aB.resolve(...)local aC,aD=au(...)return aB._new(debug.traceback(nil,2),function(aE)
aE(unpack(aD,1,aC))end)end function aB.reject(...)local aC,aD=au(...)return aB._new(debug.traceback(nil,2),function(aE,
aF)aF(unpack(aD,1,aC))end)end function aB._try(aC,aD,...)local aE,aF=au(...)return aB._new(aC,function(aG)aG(aD(unpack(
aF,1,aE)))end)end function aB.try(aC,...)return aB._try(debug.traceback(nil,2),aC,...)end function aB._all(aC,aD,aE)if
type(aD)~='table'then error(string.format(af,'Promise.all'),3)end for aF,aG in pairs(aD)do if not aB.is(aG)then error(
string.format(ae,'Promise.all',tostring(aF)),3)end end if#aD==0 or aE==0 then return aB.resolve{}end return aB._new(aC,
function(aH,aI,aJ)local aK,aN,aO,aP,aQ={},{},0,0,false local function aR()for aS,aT in ipairs(aN)do aT:cancel()end end
local function aS(aT,...)if aQ then return end aO=aO+1 if aE==nil then aK[aT]=...else aK[aO]=...end if aO>=(aE or#aD)
then aQ=true aH(aK)aR()end end aJ(aR)for aT,aU in ipairs(aD)do aN[aT]=aU:andThen(function(...)aS(aT,...)end,function(...
)aP=aP+1 if aE==nil or#aD-aP<aE then aR()aQ=true aI(...)end end)end if aQ then aR()end end)end function aB.all(aC)return
aB._all(debug.traceback(nil,2),aC)end function aB.fold(aC,aD,aE)assert(type(aC)=='table',
'Bad argument #1 to Promise.fold: must be a table')assert(aq(aD),'Bad argument #2 to Promise.fold: must be a function')
local aF=aB.resolve(aE)return aB.each(aC,function(aG,aH)aF=aF:andThen(function(aI)return aD(aI,aG,aH)end)end):andThen(
function()return aF end)end function aB.some(aC,aD)assert(type(aD)=='number',
'Bad argument #2 to Promise.some: must be a number')return aB._all(debug.traceback(nil,2),aC,aD)end function aB.any(aC)
return aB._all(debug.traceback(nil,2),aC,1):andThen(function(aD)return aD[1]end)end function aB.allSettled(aC)if type(aC
)~='table'then error(string.format(af,'Promise.allSettled'),2)end for aD,aE in pairs(aC)do if not aB.is(aE)then error(
string.format(ae,'Promise.allSettled',tostring(aD)),2)end end if#aC==0 then return aB.resolve{}end return aB._new(debug.
traceback(nil,2),function(aF,aG,aH)local aI,aJ,aK={},{},0 local function aN(aO,...)aK=aK+1 aI[aO]=...if aK>=#aC then aF(
aI)end end aH(function()for aO,aP in ipairs(aJ)do aP:cancel()end end)for aO,aP in ipairs(aC)do aJ[aO]=aP:finally(
function(...)aN(aO,...)end)end end)end function aB.race(aC)assert(type(aC)=='table',string.format(af,'Promise.race'))for
aD,aE in pairs(aC)do assert(aB.is(aE),string.format(ae,'Promise.race',tostring(aD)))end return aB._new(debug.traceback(
nil,2),function(aF,aG,aH)local aI,aJ={},false local function aK()for aN,aO in ipairs(aI)do aO:cancel()end end
local function aN(aO)return function(...)aK()aJ=true return aO(...)end end if aH(aN(aG))then return end for aO,aP in
ipairs(aC)do aI[aO]=aP:andThen(aN(aF),aN(aG))end if aJ then aK()end end)end function aB.each(aC,aD)assert(type(aC)==
'table',string.format(af,'Promise.each'))assert(aq(aD),string.format(ag,'Promise.each'))return aB._new(debug.traceback(
nil,2),function(aE,aF,aG)local aH,aI,aJ={},{},false local function aK()for aN,aO in ipairs(aI)do aO:cancel()end end aG(
function()aJ=true aK()end)local aN={}for aO,aP in ipairs(aC)do if aB.is(aP)then if aP:getStatus()==aB.Status.Cancelled
then aK()return aF(as.new{error='Promise is cancelled',kind=as.Kind.AlreadyCancelled,context=string.format(
[[The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.

That Promise was created at:

%s]]
,aO,aP._source)})elseif aP:getStatus()==aB.Status.Rejected then aK()return aF(select(2,aP:await()))end local aQ=aP:
andThen(function(...)return...end)table.insert(aI,aQ)aN[aO]=aQ else aN[aO]=aP end end for aQ,aR in ipairs(aN)do if aB.
is(aR)then local aS aS,aR=aR:await()if not aS then aK()return aF(aR)end end if aJ then return end local aS=aB.resolve(
aD(aR,aQ))table.insert(aI,aS)local aT,aU=aS:await()if not aT then aK()return aF(aU)end aH[aQ]=aU end aE(aH)end)end
function aB.is(aC)if type(aC)~='table'then return false end local aD=getmetatable(aC)if aD==aB then return true elseif
aD==nil then return aq(aC.andThen)elseif type(aD)=='table'and type(rawget(aD,'__index'))=='table'and aq(rawget(rawget(aD
,'__index'),'andThen'))then return true end return false end function aB.promisify(aC)return function(...)return aB.
_try(debug.traceback(nil,2),aC,...)end end do local aC,aD function aB.delay(aE)assert(type(aE)=='number',
'Bad argument #1 to Promise.delay, must be a number.')if not(aE>=1.6666666666666665E-2)or aE==math.huge then aE=
1.6666666666666665E-2 end return aB._new(debug.traceback(nil,2),function(aF,aG,aH)local aI=aB._getTime()local aJ=aI+aE
local aK={resolve=aF,startTime=aI,endTime=aJ}if aD==nil then aC=aK aD=aB._timeEvent:Connect(function()local aN=aB.
_getTime()while aC~=nil and aC.endTime<aN do local aQ=aC aC=aQ.next if aC==nil then aD:Disconnect()aD=nil else aC.
previous=nil end aQ.resolve(aB._getTime()-aQ.startTime)end end)else if aC.endTime<aJ then local aN=aC local aQ=aN.next
while aQ~=nil and aQ.endTime<aJ do aN=aQ aQ=aN.next end aN.next=aK aK.previous=aN if aQ~=nil then aK.next=aQ aQ.previous
=aK end else aK.next=aC aC.previous=aK aC=aK end end aH(function()local aN=aK.next if aC==aK then if aN==nil then aD:
Disconnect()aD=nil else aN.previous=nil end aC=aN else local aQ=aK.previous aQ.next=aN if aN~=nil then aN.previous=aQ
end end end)end)end end function aB.prototype.timeout(aC,aD,aE)local aF=debug.traceback(nil,2)return aB.race{aB.delay(aD
):andThen(function()return aB.reject(aE==nil and as.new{kind=as.Kind.TimedOut,error='Timed out',context=string.format(
'Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s',aD,aF)}or aE)end),aC}end function aB.prototype.getStatus(
aC)return aC._status end function aB.prototype._andThen(aC,aD,aE,aF)aC._unhandledRejection=false if aC._status==aB.
Status.Cancelled then local aG=aB.new(function()end)aG:cancel()return aG end return aB._new(aD,function(aG,aH,aI)local
aJ=aG if aE then aJ=az(aD,aE,aG,aH)end local aK=aH if aF then aK=az(aD,aF,aG,aH)end if aC._status==aB.Status.Started
then table.insert(aC._queuedResolve,aJ)table.insert(aC._queuedReject,aK)aI(function()if aC._status==aB.Status.Started
then table.remove(aC._queuedResolve,table.find(aC._queuedResolve,aJ))table.remove(aC._queuedReject,table.find(aC.
_queuedReject,aK))end end)elseif aC._status==aB.Status.Resolved then aJ(unpack(aC._values,1,aC._valuesLength))elseif aC.
_status==aB.Status.Rejected then aK(unpack(aC._values,1,aC._valuesLength))end end,aC)end function aB.prototype.andThen(
aC,aD,aE)assert(aD==nil or aq(aD),string.format(ag,'Promise:andThen'))assert(aE==nil or aq(aE),string.format(ag,
'Promise:andThen'))return aC:_andThen(debug.traceback(nil,2),aD,aE)end function aB.prototype.catch(aC,aD)assert(aD==nil
or aq(aD),string.format(ag,'Promise:catch'))return aC:_andThen(debug.traceback(nil,2),nil,aD)end function aB.prototype.
tap(aC,aD)assert(aq(aD),string.format(ag,'Promise:tap'))return aC:_andThen(debug.traceback(nil,2),function(...)local aE=
aD(...)if aB.is(aE)then local aF,aG=au(...)return aE:andThen(function()return unpack(aG,1,aF)end)end return...end)end
function aB.prototype.andThenCall(aC,aD,...)assert(aq(aD),string.format(ag,'Promise:andThenCall'))local aE,aF=au(...)
return aC:_andThen(debug.traceback(nil,2),function()return aD(unpack(aF,1,aE))end)end function aB.prototype.
andThenReturn(aC,...)local aD,aE=au(...)return aC:_andThen(debug.traceback(nil,2),function()return unpack(aE,1,aD)end)
end function aB.prototype.cancel(aC)if aC._status~=aB.Status.Started then return end aC._status=aB.Status.Cancelled if
aC._cancellationHook then aC._cancellationHook()end coroutine.close(aC._thread)if aC._parent then aC._parent:
_consumerCancelled(aC)end for aD in pairs(aC._consumers)do aD:cancel()end aC:_finalize()end function aB.prototype.
_consumerCancelled(aC,aD)if aC._status~=aB.Status.Started then return end aC._consumers[aD]=nil if next(aC._consumers)==
nil then aC:cancel()end end function aB.prototype._finally(aC,aD,aE)aC._unhandledRejection=false local aF=aB._new(aD,
function(aF,aG,aH)local aI aH(function()aC:_consumerCancelled(aC)if aI then aI:cancel()end end)local aJ=aF if aE then aJ
=function(...)local aK=aE(...)if aB.is(aK)then aI=aK aK:finally(function(aN)if aN~=aB.Status.Rejected then aF(aC)end end
):catch(function(...)aG(...)end)else aF(aC)end end end if aC._status==aB.Status.Started then table.insert(aC.
_queuedFinally,aJ)else aJ(aC._status)end end)return aF end function aB.prototype.finally(aC,aD)assert(aD==nil or aq(aD),
string.format(ag,'Promise:finally'))return aC:_finally(debug.traceback(nil,2),aD)end function aB.prototype.finallyCall(
aC,aD,...)assert(aq(aD),string.format(ag,'Promise:finallyCall'))local aE,aF=au(...)return aC:_finally(debug.traceback(
nil,2),function()return aD(unpack(aF,1,aE))end)end function aB.prototype.finallyReturn(aC,...)local aD,aE=au(...)return
aC:_finally(debug.traceback(nil,2),function()return unpack(aE,1,aD)end)end function aB.prototype.awaitStatus(aC)aC.
_unhandledRejection=false if aC._status==aB.Status.Started then local aD=coroutine.running()aC:finally(function()task.
spawn(aD)end):catch(function()end)coroutine.yield()end if aC._status==aB.Status.Resolved then return aC._status,unpack(
aC._values,1,aC._valuesLength)elseif aC._status==aB.Status.Rejected then return aC._status,unpack(aC._values,1,aC.
_valuesLength)end return aC._status end local function aC(aD,...)return aD==aB.Status.Resolved,...end function aB.
prototype.await(aD)return aC(aD:awaitStatus())end local function aD(aE,...)if aE~=aB.Status.Resolved then error((...)==
nil and'Expected Promise rejected with no value.'or(...),3)end return...end function aB.prototype.expect(aE)return aD(aE
:awaitStatus())end aB.prototype.awaitValue=aB.prototype.expect function aB.prototype._unwrap(aE)if aE._status==aB.Status
.Started then error('Promise has not resolved or rejected.',2)end local aF=aE._status==aB.Status.Resolved return aF,
unpack(aE._values,1,aE._valuesLength)end function aB.prototype._resolve(aE,...)if aE._status~=aB.Status.Started then if
aB.is((...))then(...):_consumerCancelled(aE)end return end if aB.is((...))then if select('#',...)>1 then local aF=string
.format([[When returning a Promise from andThen, extra arguments are discarded! See:

%s]],aE._source)warn(aF)end local
aF=...local aG=aF:andThen(function(...)aE:_resolve(...)end,function(...)local aG=aF._values[1]if aF._error then aG=as.
new{error=aF._error,kind=as.Kind.ExecutionError,context=
[=[[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]]=]}end if
as.isKind(aG,as.Kind.ExecutionError)then return aE:_reject(aG:extend{error=
'This Promise was chained to a Promise that errored.',trace='',context=string.format(
[[The Promise at:

%s
...Rejected because it was chained to the following Promise, which encountered an error:
]],aE.
_source)})end aE:_reject(...)end)if aG._status==aB.Status.Cancelled then aE:cancel()elseif aG._status==aB.Status.Started
then aE._parent=aG aG._consumers[aE]=true end return end aE._status=aB.Status.Resolved aE._valuesLength,aE._values=au(
...)for aF,aG in ipairs(aE._queuedResolve)do coroutine.wrap(aG)(...)end aE:_finalize()end function aB.prototype._reject(
aE,...)if aE._status~=aB.Status.Started then return end aE._status=aB.Status.Rejected aE._valuesLength,aE._values=au(...
)if not aA(aE._queuedReject)then for aF,aG in ipairs(aE._queuedReject)do coroutine.wrap(aG)(...)end else local aF=
tostring((...))coroutine.wrap(function()aB._timeEvent:Wait()if not aE._unhandledRejection then return end local aG=
string.format('Unhandled Promise rejection:\n\n%s\n\n%s',aF,aE._source)for aH,aI in ipairs(aB.
_unhandledRejectionCallbacks)do task.spawn(aI,aE,unpack(aE._values,1,aE._valuesLength))end if aB.TEST then return end
warn(aG)end)()end aE:_finalize()end function aB.prototype._finalize(aE)for aF,aG in ipairs(aE._queuedFinally)do
coroutine.wrap(aG)(aE._status)end aE._queuedFinally=nil aE._queuedReject=nil aE._queuedResolve=nil if not aB.TEST then
aE._parent=nil aE._consumers=nil end task.defer(coroutine.close,aE._thread)end function aB.prototype.now(aE,aF)local aG=
debug.traceback(nil,2)if aE._status==aB.Status.Resolved then return aE:_andThen(aG,function(...)return...end)else return
aB.reject(aF==nil and as.new{kind=as.Kind.NotResolvedInTime,error='This Promise was not resolved in time for :now()',
context=':now() was called at:\n\n'..aG}or aF)end end function aB.retry(aE,aF,...)assert(aq(aE),
'Parameter #1 to Promise.retry must be a function')assert(type(aF)=='number',
'Parameter #2 to Promise.retry must be a number')local aG,aH={...},select('#',...)return aB.resolve(aE(...)):catch(
function(...)if aF>0 then return aB.retry(aE,aF-1,unpack(aG,1,aH))else return aB.reject(...)end end)end function aB.
retryWithDelay(aE,aF,aG,...)assert(aq(aE),'Parameter #1 to Promise.retry must be a function')assert(type(aF)=='number',
'Parameter #2 (times) to Promise.retry must be a number')assert(type(aG)=='number',
'Parameter #3 (seconds) to Promise.retry must be a number')local aH,aI={...},select('#',...)return aB.resolve(aE(...)):
catch(function(...)if aF>0 then aB.delay(aG):await()return aB.retryWithDelay(aE,aF-1,aG,unpack(aH,1,aI))else return aB.
reject(...)end end)end function aB.fromEvent(aE,aF)aF=aF or function()return true end return aB._new(debug.traceback(nil
,2),function(aG,aH,aI)local aJ,aK=false local function aN()aK:Disconnect()aK=nil end aK=aE:Connect(function(...)local aQ
=aF(...)if aQ==true then aG(...)if aK then aN()else aJ=true end elseif type(aQ)~='boolean'then error
'Promise.fromEvent predicate should always return a boolean'end end)if aJ and aK then return aN()end aI(aN)end)end
function aB.onUnhandledRejection(aE)table.insert(aB._unhandledRejectionCallbacks,aE)return function()local aF=table.
find(aB._unhandledRejectionCallbacks,aE)if aF then table.remove(aB._unhandledRejectionCallbacks,aF)end end end return aB
end)()end,[196]=function()local aa,ab,ac=a(196)local ad return(function(...)return function()local ae=ac(ab.Parent)ae.
TEST=true local af=Instance.new'BindableEvent'ae._timeEvent=af.Event local ag do local ah=0 ae._getTime=function()return
ah end function ag(aq)aq=aq or(1.6666666666666665E-2)ah=ah+aq af:Fire(aq)end end local function ah(...)local aq=select(
'#',...)return aq,{...}end describe('Promise.Status',function()it('should error if indexing nil value',function()expect(
function()local aq=ae.Status.wrong end).to.throw()end)end)describe('Unhandled rejection signal',function()it(
'should call unhandled rejection callbacks',function()local aq,ar=ae.new(function(aq,ar)ar(1,2)end),0 local function as(
au,av,aw)ar+=1 expect(au).to.equal(aq)expect(av).to.equal(1)expect(aw).to.equal(2)end local au=ae.onUnhandledRejection(
as)ag()expect(ar).to.equal(1)au()ae.new(function(av,aw)aw(3,4)end)ag()expect(ar).to.equal(1)end)end)describe(
'Promise.new',function()it('should instantiate with a callback',function()local aq=ae.new(function()end)expect(aq).to.be
.ok()end)it('should invoke the given callback with resolve and reject',function()local aq,ar,as=0 local au=ae.new(
function(au,av)aq=aq+1 ar=au as=av end)expect(au).to.be.ok()expect(aq).to.equal(1)expect(ar).to.be.a'function'expect(as)
.to.be.a'function'expect(au:getStatus()).to.equal(ae.Status.Started)end)it('should resolve promises on resolve()',
function()local aq=0 local ar=ae.new(function(ar)aq=aq+1 ar()end)expect(ar).to.be.ok()expect(aq).to.equal(1)expect(ar:
getStatus()).to.equal(ae.Status.Resolved)end)it('should reject promises on reject()',function()local aq=0 local ar=ae.
new(function(ar,as)aq=aq+1 as()end)expect(ar).to.be.ok()expect(aq).to.equal(1)expect(ar:getStatus()).to.equal(ae.Status.
Rejected)end)it('should reject on error in callback',function()local aq=0 local ar=ae.new(function()aq=aq+1 error'hahah'
end)expect(ar).to.be.ok()expect(aq).to.equal(1)expect(ar:getStatus()).to.equal(ae.Status.Rejected)expect(tostring(ar.
_values[1]):find'hahah').to.be.ok()expect(tostring(ar._values[1]):find'init.spec').to.be.ok()expect(tostring(ar._values[
1]):find'runExecutor').to.be.ok()end)it('should work with C functions',function()expect(function()ae.new(tick):andThen(
tick)end).to.never.throw()end)it('should have a nice tostring',function()expect(tostring(ae.resolve()):gmatch
'Promise(Resolved)').to.be.ok()end)it('should allow yielding',function()local aq=Instance.new'BindableEvent'local ar=ae.
new(function(ar)aq.Event:Wait()ar(5)end)expect(ar:getStatus()).to.equal(ae.Status.Started)aq:Fire()expect(ar:getStatus()
).to.equal(ae.Status.Resolved)expect(ar._values[1]).to.equal(5)end)it(
'should preserve stack traces of resolve-chained promises',function()local function aq(ar)error(ar)end local ar=ae.new(
function(ar)ar(ae.new(function()aq'sample text'end))end)expect(ar:getStatus()).to.equal(ae.Status.Rejected)local as=
tostring(ar._values[1])expect(as:find'sample text').to.be.ok()expect(as:find'nestedCall').to.be.ok()expect(as:find
'runExecutor').to.be.ok()expect(as:find'runPlanNode').to.be.ok()expect(as:find
[[...Rejected because it was chained to the following Promise, which encountered an error:]]).to.be.ok()end)it(
'should report errors from Promises with _error (< v2)',function()local aq=ae.reject()aq._error='Sample error'local ar=
ae.resolve():andThenReturn(aq)expect(ar:getStatus()).to.equal(ae.Status.Rejected)local as=tostring(ar._values[1])expect(
as:find'Sample error').to.be.ok()expect(as:find
[[...Rejected because it was chained to the following Promise, which encountered an error:]]).to.be.ok()expect(as:find
'%[No stack trace available').to.be.ok()end)it('should allow callable tables',function()local aq,ar=ae.new(setmetatable(
{},{__call=function(aq,ar)ar(1)end})),false aq:andThen(setmetatable({},{__call=function(as,au)expect(au).to.equal(1)ar=
true end}))expect(ar).to.equal(true)end)itSKIP('should close the thread after resolve',function()local aq=0 ae.new(
function(ar)aq+=1 ar()ae.delay(1):await()aq+=1 end)task.wait(1)expect(aq).to.equal(1)end)end)describe('Promise.defer',
function()it('should execute after the time event',function()local aq=0 local ar=ae.defer(function(ar,as,au,av)expect(
type(ar)).to.equal'function'expect(type(as)).to.equal'function'expect(type(au)).to.equal'function'expect(type(av)).to.
equal'nil'aq=aq+1 ar'foo'end)expect(aq).to.equal(0)expect(ar:getStatus()).to.equal(ae.Status.Started)ag()expect(aq).to.
equal(1)expect(ar:getStatus()).to.equal(ae.Status.Resolved)ag()expect(aq).to.equal(1)end)end)describe('Promise.delay',
function()it('should schedule promise resolution',function()local aq=ae.delay(1)expect(aq:getStatus()).to.equal(ae.
Status.Started)ag()expect(aq:getStatus()).to.equal(ae.Status.Started)ag(1)expect(aq:getStatus()).to.equal(ae.Status.
Resolved)end)it('should allow for delays to be cancelled',function()local aq=ae.delay(2)ae.delay(1):andThen(function()aq
:cancel()end)expect(aq:getStatus()).to.equal(ae.Status.Started)ag()expect(aq:getStatus()).to.equal(ae.Status.Started)ag(
1)expect(aq:getStatus()).to.equal(ae.Status.Cancelled)ag(1)end)end)describe('Promise.resolve',function()it(
'should immediately resolve with a value',function()local aq=ae.resolve(5,6)expect(aq).to.be.ok()expect(aq:getStatus()).
to.equal(ae.Status.Resolved)expect(aq._values[1]).to.equal(5)expect(aq._values[2]).to.equal(6)end)it(
'should chain onto passed promises',function()local aq=ae.resolve(ae.new(function(aq,ar)ar(7)end))expect(aq).to.be.ok()
expect(aq:getStatus()).to.equal(ae.Status.Rejected)expect(aq._values[1]).to.equal(7)end)end)describe('Promise.reject',
function()it('should immediately reject with a value',function()local aq=ae.reject(6,7)expect(aq).to.be.ok()expect(aq:
getStatus()).to.equal(ae.Status.Rejected)expect(aq._values[1]).to.equal(6)expect(aq._values[2]).to.equal(7)end)it(
'should pass a promise as-is as an error',function()local aq=ae.new(function(aq)aq(6)end)local ar=ae.reject(aq)expect(ar
).to.be.ok()expect(ar:getStatus()).to.equal(ae.Status.Rejected)expect(ar._values[1]).to.equal(aq)end)end)describe(
'Promise:andThen',function()it('should allow yielding',function()local aq=Instance.new'BindableEvent'local ar=ae.
resolve():andThen(function()aq.Event:Wait()return 5 end)expect(ar:getStatus()).to.equal(ae.Status.Started)aq:Fire()
expect(ar:getStatus()).to.equal(ae.Status.Resolved)expect(ar._values[1]).to.equal(5)end)it(
'should run andThens on a new thread',function()local aq,ar=(Instance.new'BindableEvent')local as=ae.new(function(as)ar=
as end)local au,av=as:andThen(function()aq.Event:Wait()return 5 end),as:andThen(function()return'foo'end)expect(as:
getStatus()).to.equal(ae.Status.Started)ar()expect(av:getStatus()).to.equal(ae.Status.Resolved)expect(av._values[1]).to.
equal'foo'expect(au:getStatus()).to.equal(ae.Status.Started)end)it('should chain onto resolved promises',function()local
aq,ar,as,au,av=0,0,(ae.resolve(5))local aw=as:andThen(function(...)av,au=ah(...)aq=aq+1 end,function()ar=ar+1 end)
expect(ar).to.equal(0)expect(aq).to.equal(1)expect(av).to.equal(1)expect(au[1]).to.equal(5)expect(as).to.be.ok()expect(
as:getStatus()).to.equal(ae.Status.Resolved)expect(as._values[1]).to.equal(5)expect(aw).to.be.ok()expect(aw).never.to.
equal(as)expect(aw:getStatus()).to.equal(ae.Status.Resolved)expect(#aw._values).to.equal(0)end)it(
'should chain onto rejected promises',function()local aq,ar,as,au,av=0,0,(ae.reject(5))local aw=as:andThen(function(...)
ar=ar+1 end,function(...)av,au=ah(...)aq=aq+1 end)expect(ar).to.equal(0)expect(aq).to.equal(1)expect(av).to.equal(1)
expect(au[1]).to.equal(5)expect(as).to.be.ok()expect(as:getStatus()).to.equal(ae.Status.Rejected)expect(as._values[1]).
to.equal(5)expect(aw).to.be.ok()expect(aw).never.to.equal(as)expect(aw:getStatus()).to.equal(ae.Status.Resolved)expect(#
aw._values).to.equal(0)end)it('should reject on error in callback',function()local aq=0 local ar=ae.resolve(1):andThen(
function()aq=aq+1 error'hahah'end)expect(ar).to.be.ok()expect(aq).to.equal(1)expect(ar:getStatus()).to.equal(ae.Status.
Rejected)expect(tostring(ar._values[1]):find'hahah').to.be.ok()expect(tostring(ar._values[1]):find'init.spec').to.be.ok(
)expect(tostring(ar._values[1]):find'runExecutor').to.be.ok()end)it('should chain onto asynchronously resolved promises'
,function()local aq,ar,as,au,av=0,0 local aw=ae.new(function(aw)av=aw end)local ax=aw:andThen(function(...)as={...}au=
select('#',...)aq=aq+1 end,function()ar=ar+1 end)expect(aq).to.equal(0)expect(ar).to.equal(0)av(6)expect(ar).to.equal(0)
expect(aq).to.equal(1)expect(au).to.equal(1)expect(as[1]).to.equal(6)expect(aw).to.be.ok()expect(aw:getStatus()).to.
equal(ae.Status.Resolved)expect(aw._values[1]).to.equal(6)expect(ax).to.be.ok()expect(ax).never.to.equal(aw)expect(ax:
getStatus()).to.equal(ae.Status.Resolved)expect(#ax._values).to.equal(0)end)it(
'should chain onto asynchronously rejected promises',function()local aq,ar,as,au,av=0,0 local aw=ae.new(function(aw,ax)
av=ax end)local ax=aw:andThen(function()ar=ar+1 end,function(...)as={...}au=select('#',...)aq=aq+1 end)expect(aq).to.
equal(0)expect(ar).to.equal(0)av(6)expect(ar).to.equal(0)expect(aq).to.equal(1)expect(au).to.equal(1)expect(as[1]).to.
equal(6)expect(aw).to.be.ok()expect(aw:getStatus()).to.equal(ae.Status.Rejected)expect(aw._values[1]).to.equal(6)expect(
ax).to.be.ok()expect(ax).never.to.equal(aw)expect(ax:getStatus()).to.equal(ae.Status.Resolved)expect(#ax._values).to.
equal(0)end)it('should propagate errors through multiple levels',function()local aq,ar,as ae.new(function(au,av)av(1,2,3
)end):andThen(function()end):catch(function(au,av,aw)aq,ar,as=au,av,aw end)expect(aq).to.equal(1)expect(ar).to.equal(2)
expect(as).to.equal(3)end)it([[should not call queued callbacks from a cancelled sub-promise]],function()local aq,ar=0
local as=ae.new(function(as)ar=as end)as:andThen(function()aq+=1 end)as:andThen(function()aq+=1 end):cancel()ar'foo'
expect(aq).to.equal(1)end)end)describe('Promise:cancel',function()it(
[[should mark promises as cancelled and not resolve or reject them]],function()local aq,ar=0,0 local as=ae.new(function(
)end):andThen(function()aq=aq+1 end):finally(function()ar=ar+1 end)as:cancel()as:cancel()expect(aq).to.equal(0)expect(ar
).to.equal(1)expect(as:getStatus()).to.equal(ae.Status.Cancelled)end)it('should call the cancellation hook once',
function()local aq=0 local ar=ae.new(function(ar,as,au)au(function()aq=aq+1 end)end)ar:cancel()ar:cancel()expect(aq).to.
equal(1)end)it('should propagate cancellations',function()local aq=ae.new(function()end)local ar,as=aq:andThen(),aq:
andThen()expect(aq:getStatus()).to.equal(ae.Status.Started)expect(ar:getStatus()).to.equal(ae.Status.Started)expect(as:
getStatus()).to.equal(ae.Status.Started)ar:cancel()expect(aq:getStatus()).to.equal(ae.Status.Started)expect(ar:
getStatus()).to.equal(ae.Status.Cancelled)expect(as:getStatus()).to.equal(ae.Status.Started)as:cancel()expect(aq:
getStatus()).to.equal(ae.Status.Cancelled)expect(ar:getStatus()).to.equal(ae.Status.Cancelled)expect(as:getStatus()).to.
equal(ae.Status.Cancelled)end)it('should affect downstream promises',function()local aq=ae.new(function()end)local ar=aq
:andThen()aq:cancel()expect(ar:getStatus()).to.equal(ae.Status.Cancelled)end)it('should track consumers',function()local
aq,ar=ae.new(function()end),ae.resolve()local as=ar:andThen(function()return aq end)local au=ae.new(function(au)au(as)
end)local av=au:andThen(function()end)expect(as._parent).to.never.equal(ar)expect(au._parent).to.never.equal(as)expect(
au._consumers[av]).to.be.ok()expect(av._parent).to.equal(au)end)it('should cancel resolved pending promises',function()
local aq=ae.new(function()end)local ar=ae.new(function(ar)ar(aq)end):finally(function()end)ar:cancel()expect(aq._status)
.to.equal(ae.Status.Cancelled)expect(ar._status).to.equal(ae.Status.Cancelled)end)it('should close the promise thread',
function()local aq=0 local ar=ae.new(function()aq+=1 ae.delay(1):await()aq+=1 end)ar:cancel()ag(2)expect(aq).to.equal(1)
end)end)describe('Promise:finally',function()it('should be called upon resolve, reject, or cancel',function()local aq=0
local function ar()aq=aq+1 end ae.new(function(as,au)as()end):finally(ar)ae.resolve():andThen(function()end):finally(ar)
:finally(ar)ae.reject():finally(ar)local as=ae.new(function()end):finally(ar)as:cancel()expect(aq).to.equal(5)end)it(
'should not forward return values',function()local aq ae.resolve(2):finally(function()return 1 end):andThen(function(ar)
aq=ar end)expect(aq).to.equal(2)end)it('should not consume rejections',function()local aq,ar=false,false ae.reject(5):
finally(function()return 42 end):andThen(function()ar=true end):catch(function(as)aq=true expect(as).to.equal(5)end)
expect(aq).to.equal(true)expect(ar).to.equal(false)end)it('should wait for returned promises',function()local aq local
ar=ae.reject'foo':finally(function()return ae.new(function(ar)aq=ar end)end)expect(ar:getStatus()).to.equal(ae.Status.
Started)aq()expect(ar:getStatus()).to.equal(ae.Status.Rejected)local as,au=ar:_unwrap()expect(au).to.equal'foo'end)it(
"should reject with a returned rejected promise's value",function()local aq local ar=ae.reject'foo':finally(function()
return ae.new(function(ar,as)aq=as end)end)expect(ar:getStatus()).to.equal(ae.Status.Started)aq'bar'expect(ar:getStatus(
)).to.equal(ae.Status.Rejected)local as,au=ar:_unwrap()expect(au).to.equal'bar'end)it(
'should reject when handler errors',function()local aq={}local ar=ae.reject'bar':finally(function()error(aq)end)local as
,au=ar:_unwrap()expect(as).to.equal(false)expect(au).to.equal(aq)end)it('should not prevent cancellation',function()
local aq,ar=ae.new(function()end),false aq:finally(function()ar=true end)local as=aq:andThen(function()end)as:cancel()
expect(aq:getStatus()).to.equal(ae.Status.Cancelled)expect(ar).to.equal(true)end)it(
'should propagate cancellation downwards',function()local aq,ar,as=false,false,ae.new(function()end)local au=as:finally(
function()aq=true end)as:cancel()expect(as:getStatus()).to.equal(ae.Status.Cancelled)expect(au:getStatus()).to.equal(ae.
Status.Cancelled)expect(aq).to.equal(true)expect(ar).to.equal(false)end)it('should propagate cancellation upwards',
function()local aq,ar,as=false,false,ae.new(function()end)local au=as:finally(function()aq=true end)au:cancel()expect(as
:getStatus()).to.equal(ae.Status.Cancelled)expect(au:getStatus()).to.equal(ae.Status.Cancelled)expect(aq).to.equal(true)
expect(ar).to.equal(false)end)it('should cancel returned promise if cancelled',function()local aq=ae.new(function()end)
local ar=ae.resolve():finally(function()return aq end)ar:cancel()expect(aq:getStatus()).to.equal(ae.Status.Cancelled)end
)end)describe('Promise.all',function()it('should error if given something other than a table',function()expect(function(
)ae.all(1)end).to.throw()end)it([[should resolve instantly with an empty table if given no promises]],function()local aq
=ae.all{}local ar,as=aq:_unwrap()expect(ar).to.equal(true)expect(aq:getStatus()).to.equal(ae.Status.Resolved)expect(as).
to.be.a'table'expect(next(as)).to.equal(nil)end)it('should error if given non-promise values',function()expect(function(
)ae.all{{},{},{}}end).to.throw()end)it([[should wait for all promises to be resolved and return their values]],function(
)local aq,ar,as={},ah(1,'A string',nil,false)local au={}for av=1,ar do au[av]=ae.new(function(aw)aq[av]={aw,as[av]}end)
end local av=ae.all(au)for aw,ax in ipairs(aq)do expect(av:getStatus()).to.equal(ae.Status.Started)ax[1](ax[2])end local
az,aA=ah(av:_unwrap())local aB,aC=unpack(aA,1,az)expect(az).to.equal(2)expect(aB).to.equal(true)expect(aC).to.be.a
'table'expect(#aC).to.equal(#au)for aD=1,ar do expect(aC[aD]).to.equal(as[aD])end end)it(
'should reject if any individual promise rejected',function()local aq,ar local as,au=ae.new(function(as,au)aq=au end),ae
.new(function(as)ar=as end)local av=ae.all{as,au}expect(av:getStatus()).to.equal(ae.Status.Started)aq('baz','qux')ar(
'foo','bar')local aw,ax=ah(av:_unwrap())local az,aA,aB=unpack(ax,1,aw)expect(aw).to.equal(3)expect(az).to.equal(false)
expect(aA).to.equal'baz'expect(aB).to.equal'qux'expect(au:getStatus()).to.equal(ae.Status.Cancelled)end)it(
'should not resolve if resolved after rejecting',function()local aq,ar local as,au=ae.new(function(as,au)aq=au end),ae.
new(function(as)ar=as end)local av=ae.all{as,au}expect(av:getStatus()).to.equal(ae.Status.Started)aq('baz','qux')ar(
'foo','bar')local aw,ax=ah(av:_unwrap())local az,aA,aB=unpack(ax,1,aw)expect(aw).to.equal(3)expect(az).to.equal(false)
expect(aA).to.equal'baz'expect(aB).to.equal'qux'end)it('should only reject once',function()local aq,ar local as,au=ae.
new(function(as,au)aq=au end),ae.new(function(as,au)ar=au end)local av=ae.all{as,au}expect(av:getStatus()).to.equal(ae.
Status.Started)aq('foo','bar')expect(av:getStatus()).to.equal(ae.Status.Rejected)ar('baz','qux')local aw,ax=ah(av:
_unwrap())local az,aA,aB=unpack(ax,1,aw)expect(aw).to.equal(3)expect(az).to.equal(false)expect(aA).to.equal'foo'expect(
aB).to.equal'bar'end)it('should error if a non-array table is passed in',function()local aq,ar=pcall(function()ae.all(ae
.new(function()end))end)expect(aq).to.be.ok()expect(ar:find'Non%-promise').to.be.ok()end)it(
'should cancel pending promises if one rejects',function()local aq=ae.new(function()end)expect(ae.all{ae.resolve(),ae.
reject(),aq}:getStatus()).to.equal(ae.Status.Rejected)expect(aq:getStatus()).to.equal(ae.Status.Cancelled)end)it(
'should cancel promises if it is cancelled',function()local aq=ae.new(function()end)aq:andThen(function()end)local ar={
ae.new(function()end),ae.new(function()end),aq}ae.all(ar):cancel()expect(ar[1]:getStatus()).to.equal(ae.Status.Cancelled
)expect(ar[2]:getStatus()).to.equal(ae.Status.Cancelled)expect(ar[3]:getStatus()).to.equal(ae.Status.Started)end)end)
describe('Promise.fold',function()it([[should return the initial value in a promise when the list is empty]],function()
local aq={}local ar=ae.fold({},function()error'should not be called'end,aq)expect(ae.is(ar)).to.equal(true)expect(ar:
getStatus()).to.equal(ae.Status.Resolved)expect(ar:expect()).to.equal(aq)end)it('should accept promises in the list',
function()local aq local ar=ae.fold({ae.new(function(ar)aq=ar end),2,3},function(ar,as)return ar+as end,0)aq(1)expect(ae
.is(ar)).to.equal(true)expect(ar:getStatus()).to.equal(ae.Status.Resolved)expect(ar:expect()).to.equal(6)end)it(
[[should always return a promise even if the list or reducer don't use them]],function()local aq=ae.fold({1,2,3},
function(aq,ar,as)if as==2 then return ae.delay(1):andThenReturn(aq+ar)else return aq+ar end end,0)expect(ae.is(aq)).to.
equal(true)expect(aq:getStatus()).to.equal(ae.Status.Started)ag(2)expect(aq:getStatus()).to.equal(ae.Status.Resolved)
expect(aq:expect()).to.equal(6)end)it('should return the first rejected promise',function()local aq='foo'local ar=ae.
fold({1,2,3},function(ar,as,au)if au==2 then return ae.reject(aq)else return ar+as end end,0)expect(ae.is(ar)).to.equal(
true)local as,au=ar:awaitStatus()expect(as).to.equal(ae.Status.Rejected)expect(au).to.equal(aq)end)it(
'should return the first canceled promise',function()local aq local ar=ae.fold({1,2,3},function(ar,as,au)if au==1 then
return ar+as elseif au==2 then aq=ae.delay(1):andThenReturn(ar+as)return aq else error
'this should not run if the promise is cancelled'end end,0)expect(ae.is(ar)).to.equal(true)expect(ar:getStatus()).to.
equal(ae.Status.Started)aq:cancel()expect(ar:getStatus()).to.equal(ae.Status.Cancelled)end)end)describe('Promise.race',
function()it('should resolve with the first settled value',function()local aq=ae.race{ae.resolve(1),ae.resolve(2)}:
andThen(function(aq)expect(aq).to.equal(1)end)expect(aq:getStatus()).to.equal(ae.Status.Resolved)end)it(
'should cancel other promises',function()local aq=ae.new(function()end)aq:andThen(function()end)local ar={aq,ae.new(
function()end),ae.new(function(ar)ar(2)end)}local as=ae.race(ar)expect(as:getStatus()).to.equal(ae.Status.Resolved)
expect(as._values[1]).to.equal(2)expect(ar[1]:getStatus()).to.equal(ae.Status.Started)expect(ar[2]:getStatus()).to.
equal(ae.Status.Cancelled)expect(ar[3]:getStatus()).to.equal(ae.Status.Resolved)local au=ae.new(function()end)expect(ae.
race{ae.reject(),ae.resolve(),au}:getStatus()).to.equal(ae.Status.Rejected)expect(au:getStatus()).to.equal(ae.Status.
Cancelled)end)it('should error if a non-array table is passed in',function()local ar,as=pcall(function()ae.race(ae.new(
function()end))end)expect(ar).to.be.ok()expect(as:find'Non%-promise').to.be.ok()end)it(
'should cancel promises if it is cancelled',function()local ar=ae.new(function()end)ar:andThen(function()end)local as={
ae.new(function()end),ae.new(function()end),ar}ae.race(as):cancel()expect(as[1]:getStatus()).to.equal(ae.Status.
Cancelled)expect(as[2]:getStatus()).to.equal(ae.Status.Cancelled)expect(as[3]:getStatus()).to.equal(ae.Status.Started)
end)end)describe('Promise.promisify',function()it('should wrap functions',function()local function ar(as)return as+1 end
local as=ae.promisify(ar)local au=as(1)local av,aw=au:_unwrap()expect(av).to.equal(true)expect(au:getStatus()).to.equal(
ae.Status.Resolved)expect(aw).to.equal(2)end)it('should catch errors after a yield',function()local ar=Instance.new
'BindableEvent'local as=ae.promisify(function()ar.Event:Wait()error'errortext'end)local au=as()expect(au:getStatus()).to
.equal(ae.Status.Started)ar:Fire()expect(au:getStatus()).to.equal(ae.Status.Rejected)expect(tostring(au._values[1]):find
'errortext').to.be.ok()end)end)describe('Promise.tap',function()it('should thread through values',function()local ar,as
ae.resolve(1):andThen(function(au)return au+1 end):tap(function(au)ar=au return au+1 end):andThen(function(au)as=au end)
expect(ar).to.equal(2)expect(as).to.equal(2)end)it('should chain onto promises',function()local ar,as local au=ae.
resolve(1):tap(function()return ae.new(function(au)ar=au end)end):andThen(function(au)as=au end)expect(au:getStatus()).
to.equal(ae.Status.Started)expect(as).to.never.be.ok()ar(1)expect(au:getStatus()).to.equal(ae.Status.Resolved)expect(as)
.to.equal(1)end)end)describe('Promise.try',function()it('should catch synchronous errors',function()local ar ae.try(
function()error'errortext'end):catch(function(as)ar=tostring(as)end)expect(ar:find'errortext').to.be.ok()end)it(
'should reject with error objects',function()local ar={}local as,au=ae.try(function()error(ar)end):_unwrap()expect(as).
to.equal(false)expect(au).to.equal(ar)end)it('should catch asynchronous errors',function()local ar=Instance.new
'BindableEvent'local as=ae.try(function()ar.Event:Wait()error'errortext'end)expect(as:getStatus()).to.equal(ae.Status.
Started)ar:Fire()expect(as:getStatus()).to.equal(ae.Status.Rejected)expect(tostring(as._values[1]):find'errortext').to.
be.ok()end)end)describe('Promise:andThenReturn',function()it('should return the given values',function()local ar,as ae.
resolve():andThenReturn(1,2):andThen(function(au,av)ar=au as=av end)expect(ar).to.equal(1)expect(as).to.equal(2)end)end)
describe('Promise:andThenCall',function()it('should call the given function with arguments',function()local ar,as ae.
resolve():andThenCall(function(au,av)ar=au as=av end,3,4)expect(ar).to.equal(3)expect(as).to.equal(4)end)end)describe(
'Promise.some',function()it('should resolve once the goal is reached',function()local ar=ae.some({ae.resolve(1),ae.
reject(),ae.resolve(2)},2)expect(ar:getStatus()).to.equal(ae.Status.Resolved)expect(ar._values[1][1]).to.equal(1)expect(
ar._values[1][2]).to.equal(2)end)it("should error if the goal can't be reached",function()expect(ae.some({ae.resolve(),
ae.reject()},2):getStatus()).to.equal(ae.Status.Rejected)local ar local as=ae.some({ae.resolve(),ae.new(function(as,au)
ar=au end)},2)expect(as:getStatus()).to.equal(ae.Status.Started)ar'foo'expect(as:getStatus()).to.equal(ae.Status.
Rejected)expect(as._values[1]).to.equal'foo'end)it('should cancel pending Promises once the goal is reached',function()
local ar,as=(ae.new(function()end))local au=ae.new(function(au)as=au end)local av=ae.some({ar,au,ae.resolve()},2)expect(
av:getStatus()).to.equal(ae.Status.Started)expect(ar:getStatus()).to.equal(ae.Status.Started)expect(au:getStatus()).to.
equal(ae.Status.Started)as()expect(av:getStatus()).to.equal(ae.Status.Resolved)expect(ar:getStatus()).to.equal(ae.Status
.Cancelled)expect(au:getStatus()).to.equal(ae.Status.Resolved)end)it('should error if passed a non-number',function()
expect(function()ae.some({},'non-number')end).to.throw()end)it('should return an empty array if amount is 0',function()
local ar=ae.some({ae.resolve(2)},0)expect(ar:getStatus()).to.equal(ae.Status.Resolved)expect(#ar._values[1]).to.equal(0)
end)it('should not return extra values',function()local ar=ae.some({ae.resolve(1),ae.resolve(2),ae.resolve(3),ae.
resolve(4)},2)expect(ar:getStatus()).to.equal(ae.Status.Resolved)expect(#ar._values[1]).to.equal(2)expect(ar._values[1][
1]).to.equal(1)expect(ar._values[1][2]).to.equal(2)end)it('should cancel promises if it is cancelled',function()local ar
=ae.new(function()end)ar:andThen(function()end)local as={ae.new(function()end),ae.new(function()end),ar}ae.some(as,3):
cancel()expect(as[1]:getStatus()).to.equal(ae.Status.Cancelled)expect(as[2]:getStatus()).to.equal(ae.Status.Cancelled)
expect(as[3]:getStatus()).to.equal(ae.Status.Started)end)describe('Promise.any',function()it(
'should return the value directly',function()local ar=ae.any{ae.reject(),ae.reject(),ae.resolve(1)}expect(ar:getStatus()
).to.equal(ae.Status.Resolved)expect(ar._values[1]).to.equal(1)end)it('should error if all are rejected',function()
expect(ae.any{ae.reject(),ae.reject(),ae.reject()}:getStatus()).to.equal(ae.Status.Rejected)end)end)end)describe(
'Promise.allSettled',function()it('should resolve with an array of PromiseStatuses',function()local ar local as=ae.
allSettled{ae.resolve(),ae.reject(),ae.resolve(),ae.new(function(as,au)ar=au end)}expect(as:getStatus()).to.equal(ae.
Status.Started)ar()expect(as:getStatus()).to.equal(ae.Status.Resolved)expect(as._values[1][1]).to.equal(ae.Status.
Resolved)expect(as._values[1][2]).to.equal(ae.Status.Rejected)expect(as._values[1][3]).to.equal(ae.Status.Resolved)
expect(as._values[1][4]).to.equal(ae.Status.Rejected)end)it('should cancel promises if it is cancelled',function()local
ar=ae.new(function()end)ar:andThen(function()end)local as={ae.new(function()end),ae.new(function()end),ar}ae.allSettled(
as):cancel()expect(as[1]:getStatus()).to.equal(ae.Status.Cancelled)expect(as[2]:getStatus()).to.equal(ae.Status.
Cancelled)expect(as[3]:getStatus()).to.equal(ae.Status.Started)end)end)describe('Promise:await',function()it(
'should return the correct values',function()local ar=ae.resolve(5,6,nil,7)local as,au,av,aw,ax=ar:await()expect(as).to.
equal(true)expect(au).to.equal(5)expect(av).to.equal(6)expect(aw).to.equal(nil)expect(ax).to.equal(7)end)it(
'should work if yielding is needed',function()local ar=false task.spawn(function()local as,au=ae.delay(1):await()expect(
type(au)).to.equal'number'ar=true end)ag(2)expect(ar).to.equal(true)end)end)describe('Promise:expect',function()it(
'should throw the correct values',function()local ar={}local as=ae.reject(ar)local au,av=pcall(function()as:expect()end)
expect(au).to.equal(false)expect(av).to.equal(ar)end)end)describe('Promise:now',function()it(
'should resolve if the Promise is resolved',function()local ar,as=ae.resolve'foo':now():_unwrap()expect(ar).to.equal(
true)expect(as).to.equal'foo'end)it('should reject if the Promise is not resolved',function()local ar,as=ae.new(function
()end):now():_unwrap()expect(ar).to.equal(false)expect(ae.Error.isKind(as,'NotResolvedInTime')).to.equal(true)end)it(
'should reject with a custom rejection value',function()local ar,as=ae.new(function()end):now'foo':_unwrap()expect(ar).
to.equal(false)expect(as).to.equal'foo'end)end)describe('Promise.each',function()it('should iterate',function()local ar,
as=ae.each({'foo','bar','baz','qux'},function(...)return{...}end):_unwrap()expect(ar).to.equal(true)expect(as[1][1]).to.
equal'foo'expect(as[1][2]).to.equal(1)expect(as[2][1]).to.equal'bar'expect(as[2][2]).to.equal(2)expect(as[3][1]).to.
equal'baz'expect(as[3][2]).to.equal(3)expect(as[4][1]).to.equal'qux'expect(as[4][2]).to.equal(4)end)it(
'should iterate serially',function()local ar,as={},{}local au=ae.each({'foo','bar','baz'},function(au,av)as[av]=(as[av]
or 0)+1 return ae.new(function(aw)table.insert(ar,function()aw(au:upper())end)end)end)expect(au:getStatus()).to.equal(ae
.Status.Started)expect(#ar).to.equal(1)expect(as[1]).to.equal(1)expect(as[2]).to.never.be.ok()table.remove(ar,1)()
expect(au:getStatus()).to.equal(ae.Status.Started)expect(#ar).to.equal(1)expect(as[1]).to.equal(1)expect(as[2]).to.
equal(1)expect(as[3]).to.never.be.ok()table.remove(ar,1)()expect(au:getStatus()).to.equal(ae.Status.Started)expect(as[1]
).to.equal(1)expect(as[2]).to.equal(1)expect(as[3]).to.equal(1)table.remove(ar,1)()expect(au:getStatus()).to.equal(ae.
Status.Resolved)expect(type(au._values[1])).to.equal'table'expect(type(au._values[2])).to.equal'nil'local av=au._values[
1]expect(av[1]).to.equal'FOO'expect(av[2]).to.equal'BAR'expect(av[3]).to.equal'BAZ'end)it(
[[should reject with the value if the predicate promise rejects]],function()local ar=ae.each({1,2,3},function()return ae
.reject'foobar'end)expect(ar:getStatus()).to.equal(ae.Status.Rejected)expect(ar._values[1]).to.equal'foobar'end)it(
[[should allow Promises to be in the list and wait when it gets to them]],function()local ar local as=ae.new(function(as
)ar=as end)local au=ae.each({as},function(au)return au*2 end)expect(au:getStatus()).to.equal(ae.Status.Started)ar(2)
expect(au:getStatus()).to.equal(ae.Status.Resolved)expect(au._values[1][1]).to.equal(4)end)it(
[[should reject with the value if a Promise from the list rejects]],function()local ar=false local as=ae.each({1,2,ae.
reject'foobar'},function(as)ar=true return'never'end)expect(as:getStatus()).to.equal(ae.Status.Rejected)expect(as.
_values[1]).to.equal'foobar'expect(ar).to.equal(false)end)it(
[[should reject immediately if there's a cancelled Promise in the list initially]],function()local ar=ae.new(function()
end)ar:cancel()local as=false local au=ae.each({1,2,ar},function()as=true end)expect(au:getStatus()).to.equal(ae.Status.
Rejected)expect(as).to.equal(false)expect(au._values[1].kind).to.equal(ae.Error.Kind.AlreadyCancelled)end)it(
'should stop iteration if Promise.each is cancelled',function()local ar={}local as=ae.each({'foo','bar','baz'},function(
as,au)ar[au]=(ar[au]or 0)+1 return ae.new(function()end)end)expect(as:getStatus()).to.equal(ae.Status.Started)expect(ar[
1]).to.equal(1)expect(ar[2]).to.never.be.ok()as:cancel()expect(as:getStatus()).to.equal(ae.Status.Cancelled)expect(ar[1]
).to.equal(1)expect(ar[2]).to.never.be.ok()end)it(
[[should cancel the Promise returned from the predicate if Promise.each is cancelled]],function()local ar local as=ae.
each({'foo','bar','baz'},function(as,au)ar=ae.new(function()end)return ar end)as:cancel()expect(ar:getStatus()).to.
equal(ae.Status.Cancelled)end)it([[should cancel Promises in the list if Promise.each is cancelled]],function()local ar=
ae.new(function()end)local as=ae.each({ar},function()end)as:cancel()expect(ar:getStatus()).to.equal(ae.Status.Cancelled)
end)end)describe('Promise.retry',function()it('should retry N times',function()local ar=0 local as=ae.retry(function(as)
expect(as).to.equal'foo'ar=ar+1 if ar==5 then return ae.resolve'ok'end return ae.reject'fail'end,5,'foo')expect(as:
getStatus()).to.equal(ae.Status.Resolved)expect(as._values[1]).to.equal'ok'end)it(
'should reject if threshold is exceeded',function()local ar=ae.retry(function()return ae.reject'fail'end,5)expect(ar:
getStatus()).to.equal(ae.Status.Rejected)expect(ar._values[1]).to.equal'fail'end)end)describe('Promise.retryWithDelay',
function()it('should retry after a delay',function()local ar=0 local as=ae.retryWithDelay(function(as)expect(as).to.
equal'foo'ar=ar+1 if ar==3 then return ae.resolve'ok'end return ae.reject'fail'end,3,10,'foo')expect(ar).to.equal(1)ag(
11)expect(ar).to.equal(2)ag(11)expect(ar).to.equal(3)expect(as:getStatus()).to.equal(ae.Status.Resolved)expect(as.
_values[1]).to.equal'ok'end)end)describe('Promise.fromEvent',function()it('should convert a Promise into an event',
function()local ar=Instance.new'BindableEvent'local as=ae.fromEvent(ar.Event)expect(as:getStatus()).to.equal(ae.Status.
Started)ar:Fire'foo'expect(as:getStatus()).to.equal(ae.Status.Resolved)expect(as._values[1]).to.equal'foo'end)it(
'should convert a Promise into an event with the predicate',function()local ar=Instance.new'BindableEvent'local as=ae.
fromEvent(ar.Event,function(as)return as=='foo'end)expect(as:getStatus()).to.equal(ae.Status.Started)ar:Fire'bar'expect(
as:getStatus()).to.equal(ae.Status.Started)ar:Fire'foo'expect(as:getStatus()).to.equal(ae.Status.Resolved)expect(as.
_values[1]).to.equal'foo'end)end)describe('Promise.is',function()it('should work with current version',function()local
ar=ae.resolve(1)expect(ae.is(ar)).to.equal(true)end)it('should work with any object with an andThen',function()local ar=
{andThen=function()return 1 end}expect(ae.is(ar)).to.equal(true)end)it('should work with older promises',function()local
ar={}ar.prototype={}ar.__index=ar.prototype function ar.prototype.andThen(as)end local as=setmetatable({},ar)expect(ae.
is(as)).to.equal(true)end)end)end end)()end,[198]=function()local aa,ab,ac=a(198)local ad return(function(...)return ac(
ab.Parent.Parent['jsdotlua_number@1.2.3'].number)end)()end,[199]=function()local aa,ab,ac=a(199)local ad return(function
(...)return{toJSBoolean=ac(ab.toJSBoolean)}end)()end,[200]=function()local aa,ab,ac=a(200)local ad return(function(...)
local ae=ab.Parent.Parent local af=ac(ae.Number)return function(ag)return not not ag and ag~=0 and ag~=''and not af.
isNaN(ag)end end)()end,[202]=function()local aa,ab,ac=a(202)local ad return(function(...)local ae=ac(ab.Parent.Parent[
'jsdotlua_es7-types@1.2.3']['es7-types'])return ae end)()end,[203]=function()local aa,ab,ac=a(203)local ad return(
function(...)return ac(ab.Parent.Parent['jsdotlua_instance-of@1.2.3']['instance-of'])end)()end,[204]=function()local aa,
ab,ac=a(204)local ad return(function(...)local ae,af,ag,ah,ar,as,au=ab.Parent,ac(ab.Array),ac(ab.Map),ac(ab.Object),ac(
ab.Set),ac(ab.WeakMap),ac(ab.inspect)local av=ac(ae.ES7Types)return{Array=af,Object=ah,Map=ag.Map,coerceToMap=ag.
coerceToMap,coerceToTable=ag.coerceToTable,Set=ar,WeakMap=as,inspect=au}end)()end,[205]=function()local aa,ab,ac=a(205)
local ad return(function(...)local ae=ab.Parent.Parent local af=ac(ae.ES7Types)return{concat=ac(ab.concat),every=ac(ab.
every),filter=ac(ab.filter),find=ac(ab.find),findIndex=ac(ab.findIndex),flat=ac(ab.flat),flatMap=ac(ab.flatMap),forEach=
ac(ab.forEach),from=ac(ab.from),includes=ac(ab.includes),indexOf=ac(ab.indexOf),isArray=ac(ab.isArray),join=ac(ab.join),
map=ac(ab.map),reduce=ac(ab.reduce),reverse=ac(ab.reverse),shift=ac(ab.shift),slice=ac(ab.slice),some=ac(ab.some),sort=
ac(ab.sort),splice=ac(ab.splice),unshift=ac(ab.unshift)}end)()end,[206]=function()local aa,ab,ac=a(206)local ad return(
function(...)local ae,af=_G.__DEV__,ab.Parent local ag,ah=af.Parent.Parent,ac(af.isArray)local ar=ac(ag.ES7Types)local
as=
[[Array.concat(...) only works with array-like tables but it received an object-like table.
You can avoid this error by wrapping the object-like table into an array. Example: `concat({1, 2}, {a = true})` should be `concat({1, 2}, { {a = true} }`]]
local function au(av,...)local aw,ax=0 if ah(av)then ax=table.clone(av)aw=#(av)else aw+=1 ax={}ax[aw]=av end for az=1,
select('#',...)do local aA=select(az,...)local aB=typeof(aA)if aA==nil then elseif aB=='table'then if ae then if not ah(
aA)then error(as)end end for aC=1,#aA do aw+=1 ax[aw]=aA[aC]end else aw+=1 ax[aw]=aA end end return(ax)end return au end
)()end,[207]=function()local aa,ab,ac=a(207)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag=af.
Parent.Parent local ah=ac(ag.ES7Types)return function(ar,as,au)if ae then if typeof(ar)~='table'then error(string.
format('Array.every called on %s',typeof(ar)))end if typeof(as)~='function'then error'callback is not a function'end end
local av,aw=#ar,1 while aw<=av do local ax,az=(ar[aw])if ax~=nil then if au~=nil then az=(as)(au,ax,aw,ar)else az=(as)(
ax,aw,ar)end if not az then return false end end aw+=1 end return true end end)()end,[208]=function()local aa,ab,ac=a(
208)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag=af.Parent.Parent local ah=ac(ag.ES7Types)
return function(ar,as,au)if ae then if typeof(ar)~='table'then error(string.format('Array.filter called on %s',typeof(ar
)))end if typeof(as)~='function'then error'callback is not a function'end end local av,aw,ax=#ar,{},1 if au==nil then
for az=1,av do local aA=ar[az]if aA~=nil then if(as)(aA,az,ar)then aw[ax]=aA ax+=1 end end end else for az=1,av do local
aA=ar[az]if aA~=nil then if(as)(au,aA,az,ar)then aw[ax]=aA ax+=1 end end end end return aw end end)()end,[209]=function(
)local aa,ab,ac=a(209)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)
return function(ah,ar)for as=1,#ah do local au=ah[as]if ar(au,as,ah)then return au end end return nil end end)()end,[210
]=function()local aa,ab,ac=a(210)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(
af.ES7Types)return function(ah,ar)for as=1,#ah do local au=ah[as]if ar(au,as,ah)then return as end end return-1 end end
)()end,[211]=function()local aa,ab,ac=a(211)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag,ah=af
.Parent.Parent,ac(af.isArray)local ar=ac(ag.ES7Types)local function as(au,av)if ae then if typeof(au)~='table'then
error(string.format('Array.flat called on %s',typeof(au)))end if av~=nil and typeof(av)~='number'then error
'depth is not a number or nil'end end local aw,ax=av or 1,{}for az,aA in au do if ah(aA)then local aB=(aA)local aC=if aw
>1 then as(aB,aw-1)else aB for aD,aE in aC do table.insert(ax,aE)end else table.insert(ax,aA)end end return ax end
return as end)()end,[212]=function()local aa,ab,ac=a(212)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent
local ag,ah,ar=af.Parent.Parent,ac(af.flat),ac(af.map)local as=ac(ag.ES7Types)local function au(av,aw,ax)if ae then if
typeof(av)~='table'then error(string.format('Array.flatMap called on %s',typeof(av)))end if typeof(aw)~='function'then
error'callback is not a function'end end return ah(ar(av,aw,ax))end return au end)()end,[213]=function()local aa,ab,ac=
a(213)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag=af.Parent.Parent local ah=ac(ag.ES7Types)
return function(ar,as,au)if ae then if typeof(ar)~='table'then error(string.format('Array.forEach called on %s',typeof(
ar)))end if typeof(as)~='function'then error'callback is not a function'end end local av,aw=#ar,1 while aw<=av do local
ax=ar[aw]if au~=nil then(as)(au,ax,aw,ar)else(as)(ax,aw,ar)end if#ar<av then av=#ar end aw+=1 end end end)()end,[214]=
function()local aa,ab,ac=a(214)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag,ah,ar,as=af.
Parent,ac(af.Set),ac(af.Map.Map),ac(ae.isArray)local au,av,aw,ax,az,aA=ac(ag.InstanceOf),ac(ag.ES7Types),ac(ab.
fromString),ac(ab.fromSet),ac(ab.fromMap),ac(ab.fromArray)return function(aB,aC,aD)if aB==nil then error
'cannot create array from a nil value'end local aE,aF=(typeof(aB))if aE=='table'and as(aB)then aF=aA(aB,aC,aD)elseif au(
aB,ah)then aF=ax(aB,aC,aD)elseif au(aB,ar)then aF=az(aB,aC,aD)elseif aE=='string'then aF=aw(aB,aC,aD)else aF={}end
return aF end end)()end,[215]=function()local aa,ab,ac=a(215)local ad return(function(...)local ae=ab.Parent.Parent
local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)local au={}if ar then local av=#(ah)au=table.
create(av)for aw=1,av do if as~=nil then(au)[aw]=(ar)(as,(ah)[aw],aw)else(au)[aw]=(ar)((ah)[aw],aw)end end else au=table
.clone(ah)end return au end end)()end,[216]=function()local aa,ab,ac=a(216)local ad return(function(...)local ae=ab.
Parent.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)local au={}if ar then au={}for
av,aw in ah do if as~=nil then(au)[av]=(ar)(as,aw,av)else(au)[av]=(ar)(aw,av)end end else au={}for av,aw in ah do(au)[av
]=aw end end return au end end)()end,[217]=function()local aa,ab,ac=a(217)local ad return(function(...)local ae=ab.
Parent.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)local au={}if ar then au={}for
av,aw in ah do if as~=nil then(au)[av]=(ar)(as,aw,av)else(au)[av]=(ar)(aw,av)end end else au=table.clone((ah)._array)end
return au end end)()end,[218]=function()local aa,ab,ac=a(218)local ad return(function(...)local ae=ab.Parent.Parent
local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)local au,av={},#ah au=table.create(av)if ar
then for aw=1,av do if as~=nil then(au)[aw]=(ar)(as,string.sub(ah,aw,aw),aw)else(au)[aw]=(ar)(string.sub(ah,aw,aw),aw)
end end else for aw=1,av do(au)[aw]=string.sub(ah,aw,aw)end end return au end end)()end,[219]=function()local aa,ab,ac=
a(219)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)local ah=ac(ab.
Parent.indexOf)return function(ar,as,au)return ah(ar,as,au)~=-1 end end)()end,[220]=function()local aa,ab,ac=a(220)local
ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)
local au,av=as or 1,#ah if au<1 then au=math.max(av-math.abs(au),1)end for aw=au,av do if ah[aw]==ar then return aw end
end return-1 end end)()end,[221]=function()local aa,ab,ac=a(221)local ad return(function(...)return function(ae)if
typeof(ae)~='table'then return false end if next(ae)==nil then return true end local af=#ae if af==0 then return false
end local ag,ah=0,0 for ar in pairs(ae)do if typeof(ar)~='number'then return false end if ar%1~=0 or ar<1 then return
false end ag+=1 ah+=ar end return ah==(ag*(ag+1)/2)end end)()end,[222]=function()local aa,ab,ac=a(222)local ad return(
function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)local ah=ac(ae.map)return function(ar,
as)if#ar==0 then return''end local au=ah(ar,function(au)return tostring(au)end)return table.concat(au,as or',')end end)(
)end,[223]=function()local aa,ab,ac=a(223)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag=af.
Parent.Parent local ah=ac(ag.ES7Types)return function(ar,as,au)if ae then if typeof(ar)~='table'then error(string.
format('Array.map called on %s',typeof(ar)))end if typeof(as)~='function'then error'callback is not a function'end end
local av,aw,ax=#ar,{},1 while ax<=av do local az=ar[ax]if az~=nil then local aA if au~=nil then aA=(as)(au,az,ax,ar)else
aA=(as)(az,ax,ar)end aw[ax]=aA end ax+=1 end return aw end end)()end,[224]=function()local aa,ab,ac=a(224)local ad
return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag=af.Parent.Parent local ah=ac(ag.ES7Types)return function(
ar,as,au)if ae then if typeof(ar)~='table'then error(string.format('Array.reduce called on %s',typeof(ar)))end if
typeof(as)~='function'then error'callback is not a function'end end local av,aw,ax=#ar,1 if au~=nil then ax=au else aw=2
if av==0 then error'reduce of empty array with no initial value'end ax=ar[1]end for az=aw,av do ax=as(ax,ar[az],az,ar)
end return ax end end)()end,[225]=function()local aa,ab,ac=a(225)local ad return(function(...)local ae=ab.Parent local
af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah)local ar,as=#ah,1 while as<ar do ah[as],ah[ar]=ah[ar],ah[
as]as=as+1 ar=ar-1 end return ah end end)()end,[226]=function()local aa,ab,ac=a(226)local ad return(function(...)local
ae,af=_G.__DEV__,ab.Parent local ag,ah=af.Parent.Parent,ac(af.isArray)local ar=ac(ag.ES7Types)return function(as)if ae
then if not ah(as)then error(string.format('Array.shift called on non-array %s',typeof(as)))end end if#as>0 then return
table.remove(as,1)else return nil end end end)()end,[227]=function()local aa,ab,ac=a(227)local ad return(function(...)
local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar,as)if typeof(ah)~='table'then
error(string.format('Array.slice called on %s',typeof(ah)))end local au,av,aw=#ah,(ar or 1)if as==nil or as>au+1 then aw
=au+1 else aw=as end if av>au+1 then return{}end local ax={}if av<1 then av=math.max(au-math.abs(av),1)end if aw<1 then
aw=math.max(au-math.abs(aw),1)end local az,aA=av,1 while az<aw do ax[aA]=ah[az]az=az+1 aA=aA+1 end return ax end end)()
end,[228]=function()local aa,ab,ac=a(228)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local
ag=ac(af.ES7Types)return function(ah,ar,as)if typeof(ah)~='table'then error(string.format('Array.some called on %s',
typeof(ah)))end if typeof(ar)~='function'then error'callback is not a function'end for au,av in ah do if as~=nil then if
av~=nil and(ar)(as,av,au,ah)then return true end else if av~=nil and(ar)(av,au,ah)then return true end end end return
false end end)()end,[229]=function()local aa,ab,ac=a(229)local ad return(function(...)local ae=ab.Parent local af=ae.
Parent local ag,ah=af.Parent,ac(af.Object.None)local ar=ac(ag.ES7Types)local as=function(as,au)return type(as)..
tostring(as)<type(au)..tostring(au)end return function(au,av)local aw=as if av~=nil and av~=ah then if typeof(av)~=
'function'then error[[invalid argument to Array.sort: compareFunction must be a function]]end aw=function(ax,az)local aA
=av(ax,az)if typeof(aA)~='number'then error(([[invalid result from compare function, expected number but got %s]]):
format(typeof(aA)))end return aA<0 end end table.sort(au,aw)return au end end)()end,[230]=function()local aa,ab,ac=a(230
)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah,ar
,as,...)if ar>#ah then local au=select('#',...)for av=1,au do local aw=select(av,...)table.insert(ah,aw)end return{}else
local au=#ah if ar<1 then ar=math.max(au-math.abs(ar),1)end local av,aw={},as or au if aw>0 then local ax=math.min(au,ar
+math.max(0,aw-1))for az=ar,ax do local aA=table.remove(ah,ar)table.insert(av,aA)end end local ax=select('#',...)for az=
ax,1,-1 do local aA=select(az,...)table.insert(ah,ar,aA)end return av end end end)()end,[231]=function()local aa,ab,ac=
a(231)local ad return(function(...)local ae,af=_G.__DEV__,ab.Parent local ag,ah=af.Parent.Parent,ac(af.isArray)local ar=
ac(ag.ES7Types)return function(as,...)if ae then if not ah(as)then error(string.format(
'Array.unshift called on non-array %s',typeof(as)))end end local au=select('#',...)if au>0 then for av=au,1,-1 do local
aw=select(av,...)table.insert(as,1,aw)end end return#as end end)()end,[232]=function()local aa,ab,ac=a(232)local ad
return(function(...)local ae=ab.Parent.Parent local af,ag,ah,ar=ac(ae.ES7Types),ac(ab.Map),ac(ab.coerceToMap),ac(ab.
coerceToTable)return{Map=ag,coerceToMap=ah,coerceToTable=ar}end)()end,[233]=function()local aa,ab,ac=a(233)local ad
return(function(...)local ae,af=_G.__DEV__,ab.Parent.Parent local ag,ah,ar,as=af.Parent,ac(af.Array.forEach),ac(af.Array
.map),ac(af.Array.isArray)local au,av=ac(ag.InstanceOf),ac(ag.ES7Types)local aw=({})function aw.new(ax)local az,aA if ax
==nil then az={}aA={}elseif as(ax)then if ae then if#(ax)>0 and typeof((ax)[1])~='table'then error('Value `'..typeof((ax
)[1])..[[` is not an entry object.
 Cannot create Map from {K, V} form, it must be { {K, V}... }]])end end az=table.
create(#(ax))aA={}for aB,aC in ax do local aD=aC[1]if ae then if aD==nil then error
"cannot create Map from a table that isn't an array."end end local aE=aC[2]if aA[aD]==nil then table.insert(az,aD)end aA
[aD]=aE end elseif au(ax,aw)then az=table.clone((ax)._array)aA=table.clone((ax)._map)else error((
'`%s` `%s` is not iterable, cannot make Map using it'):format(typeof(ax),tostring(ax)))end return(setmetatable({size=#az
,_map=aA,_array=az},aw))end function aw.set(ax,az,aA)if ax._map[az]==nil then ax.size=ax.size+1 table.insert(ax._array,
az)end ax._map[az]=aA return ax end function aw.get(ax,az)return ax._map[az]end function aw.clear(ax)local az=table ax.
size=0 az.clear(ax._map)az.clear(ax._array)end function aw.delete(ax,az)if ax._map[az]==nil then return false end ax.
size=ax.size-1 ax._map[az]=nil local aA=table.find(ax._array,az)if aA then table.remove(ax._array,aA)end return true end
function aw.forEach(ax,az,aA)if ae then if typeof(az)~='function'then error'callback is not a function'end end ah(ax.
_array,function(aB)local aC=ax._map[aB]if aA~=nil then(az)(aA,aC,aB,ax)else(az)(aC,aB,ax)end end)end function aw.has(ax,
az)return ax._map[az]~=nil end function aw.keys(ax)return ax._array end function aw.values(ax)return ar(ax._array,
function(az)return ax._map[az]end)end function aw.entries(ax)return ar(ax._array,function(az)return{az,ax._map[az]}end)
end function aw.ipairs(ax)if ae then warn(debug.traceback(
[[`for _,_ in myMap:ipairs() do` is deprecated and will be removed in a future release, please use `for _,_ in myMap do` instead
]]
,2))end return ipairs(ax:entries())end function aw.__iter(ax)return next,ax:entries()end function aw.__index(ax,az)local
aA=rawget(aw,az)if aA~=nil then return aA end if ae then assert(rawget(ax,'_map'),
[[Map has been corrupted, and is missing private state! Did you accidentally call table.clear() instead of map:clear()?]]
)end return aw.get(ax,az)end function aw.__newindex(ax,az,aA)ax:set(az,aA)end return aw end)()end,[234]=function()local
aa,ab,ac=a(234)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag,ah,ar=af.Parent,ac(ae.Map),
ac(af.Object)local as,au=ac(ag.InstanceOf),ac(ag.ES7Types)local function av(aw)return as(aw,ah)and aw or ah.new(ar.
entries(aw))end return av end)()end,[235]=function()local aa,ab,ac=a(235)local ad return(function(...)local ae=ab.Parent
local af=ae.Parent local ag,ah=af.Parent,ac(ae.Map)local ar,as,au=ac(ag.InstanceOf),ac(af.Array.reduce),ac(ag.ES7Types)
local function av(aw)if not ar(aw,ah)then return aw end return as(aw:entries(),function(ax,az)ax[az[1]]=az[2]return ax
end,{})end return av end)()end,[236]=function()local aa,ab,ac=a(236)local ad return(function(...)return{assign=ac(ab.
assign),entries=ac(ab.entries),freeze=ac(ab.freeze),is=ac(ab.is),isFrozen=ac(ab.isFrozen),keys=ac(ab.keys),
preventExtensions=ac(ab.preventExtensions),seal=ac(ab.seal),values=ac(ab.values),None=ac(ab.None)}end)()end,[237]=
function()local aa,ab,ac=a(237)local ad return(function(...)local ae=newproxy(true)local af=getmetatable(ae)af.
__tostring=function()return'Object.None'end return ae end)()end,[238]=function()local aa,ab,ac=a(238)local ad return(
function(...)local ae=ab.Parent local af,ag=ae.Parent.Parent,ac(ae.None)local ah=ac(af.ES7Types)return function(ar,as,au
,av,...)if as~=nil and typeof(as)=='table'then for aw,ax in pairs(as)do if ax==ag then(ar)[aw]=nil else(ar)[aw]=ax end
end end if au~=nil and typeof(au)=='table'then for aw,ax in pairs(au)do if ax==ag then(ar)[aw]=nil else(ar)[aw]=ax end
end end if av~=nil and typeof(av)=='table'then for aw,ax in pairs(av)do if ax==ag then(ar)[aw]=nil else(ar)[aw]=ax end
end end for aw=1,select('#',...)do local ax=select(aw,...)if ax~=nil and typeof(ax)=='table'then for az,aA in pairs(ax)
do if aA==ag then(ar)[az]=nil else(ar)[az]=aA end end end end return(ar)end end)()end,[239]=function()local aa,ab,ac=a(
239)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah
)assert(ah~=nil,'cannot get entries from a nil value')local ar,as=typeof(ah),{}if ar=='table'then for au,av in pairs(ah)
do table.insert(as,{au,av})end elseif ar=='string'then for au=1,string.len(ah)do as[au]={tostring(au),string.sub(ah,au,
au)}end end return as end end)()end,[240]=function()local aa,ab,ac=a(240)local ad return(function(...)local ae=ab.Parent
local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah)return(table.freeze(ah))end end)()end,[241]=
function()local aa,ab,ac=a(241)local ad return(function(...)return function(ae,af)if ae==af then return ae~=0 or 1/ae==1
/af else return ae~=ae and af~=af end end end)()end,[242]=function()local aa,ab,ac=a(242)local ad return(function(...)
local ae,af=_G.__DEV__,ab.Parent local ag=af.Parent.Parent local ah=ac(ag.ES7Types)return function(ar)if ae then print
[[Luau now has a direct table.isfrozen call that can save the overhead of this library function call]]end return table.
isfrozen(ar)end end)()end,[243]=function()local aa,ab,ac=a(243)local ad return(function(...)local ae=ab.Parent local af,
ag=ae.Parent,ae.Parent.Parent local ah,ar,as=ac(af.Set),ac(ag.ES7Types),ac(ag.InstanceOf)return function(au)if au==nil
then error'cannot extract keys from a nil value'end local av,aw=(typeof(au))if av=='table'then aw={}if as(au,ah)then
return aw end for ax in pairs(au)do table.insert(aw,ax)end elseif av=='string'then local ax=(au):len()aw=table.create(ax
)for az=1,ax do aw[az]=tostring(az)end end return aw end end)()end,[244]=function()local aa,ab,ac=a(244)local ad return(
function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)local function ah(ar)local as=
tostring(ar)return(setmetatable(ar,{__newindex=function(au,av,aw)local ax=('%q (%s) is not a valid member of %s'):
format(tostring(av),typeof(av),as)error(ax,2)end,__metatable=false}))end return ah end)()end,[245]=function()local aa,ab
,ac=a(245)local ad return(function(...)local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return
function(ah)return(table.freeze(ah))end end)()end,[246]=function()local aa,ab,ac=a(246)local ad return(function(...)
local ae=ab.Parent local af=ae.Parent.Parent local ag=ac(af.ES7Types)return function(ah)if ah==nil then error
'cannot extract values from a nil value'end local ar,as=(typeof(ah))if ar=='table'then as={}for au,av in pairs(ah)do
table.insert(as,av)end elseif ar=='string'then local au=(ah):len()as=table.create(au)for av=1,au do(as)[av]=(ah):sub(av,
av)end end return as end end)()end,[247]=function()local aa,ab,ac=a(247)local ad return(function(...)local ae,af=_G.
__DEV__,ab.Parent local ag,ah,ar,as,au=af.Parent,ac(af.inspect),ac(af.Array.isArray),ac(af.Array.forEach),ac(af.Array.
from.fromString)local av=ac(ag.ES7Types)local aw=({__iter=function(aw)return next,aw._array end,__tostring=function(aw)
local ax='Set 'if#aw._array>0 then ax..='('..tostring(#aw._array)..') 'end ax..=ah(aw._array)return ax end});(aw).
__index=aw function aw.new(ax)local az,aA={}if ax~=nil then local aB if typeof(ax)=='table'then if ar(ax)then aB=table.
clone(ax)else local aC=getmetatable(ax)if aC and rawget(aC,'__iter')then aB=ax elseif ae then error
'cannot create array from an object-like table'end end elseif typeof(ax)=='string'then aB=au(ax)else error((
'cannot create array from value of type `%s`'):format(typeof(ax)))end if aB then aA=table.create(#aB)for aC,aD in aB do
if not az[aD]then az[aD]=true table.insert(aA,aD)end end else aA={}end else aA={}end return(setmetatable({size=#aA,_map=
az,_array=aA},aw))end function aw.add(ax,az)if not ax._map[az]then ax.size=ax.size+1 ax._map[az]=true table.insert(ax.
_array,az)end return ax end function aw.clear(ax)ax.size=0 table.clear(ax._map)table.clear(ax._array)end function aw.
delete(ax,az)if not ax._map[az]then return false end ax.size=ax.size-1 ax._map[az]=nil local aA=table.find(ax._array,az)
if aA then table.remove(ax._array,aA)end return true end function aw.forEach(ax,az,aA)if typeof(az)~='function'then
error'callback is not a function'end as(ax._array,function(aB)if aA~=nil then(az)(aA,aB,aB,ax)else(az)(aB,aB,ax)end end)
end function aw.has(ax,az)return ax._map[az]~=nil end function aw.ipairs(ax)if ae then warn(debug.traceback(
[[`for _,_ in mySet:ipairs() do` is deprecated and will be removed in a future release, please use `for _,_ in mySet do` instead
]]
,2))end return ipairs(ax._array)end return aw end)()end,[248]=function()local aa,ab,ac=a(248)local ad return(function(
...)local ae=ab.Parent local af=ae.Parent local ag=ac(af.ES7Types)local ah={}(ah).__index=ah function ah.new()local ar=
setmetatable({},{__mode='k'})return setmetatable({_weakMap=ar},ah)end function ah.get(ar,as)return ar._weakMap[as]end
function ah.set(ar,as,au)ar._weakMap[as]=au return ar end function ah.has(ar,as)return ar._weakMap[as]~=nil end return
ah end)()end,[249]=function()local aa,ab,ac=a(249)local ad return(function(...)local ae,af=game:GetService'HttpService',
ab.Parent local ag,ah=af.Parent,ac(af.Array.isArray)local ar=ac(ag.ES7Types)local as,au,av,aw,ax,az,aA=10,2
local function aB(aC,aD)local aE=aD or{depth=au}local aF=aE.depth or au aE.depth=if aF>=0 then aF else au return av(aC,{
},aE)end local function aC(aD,aE)return type(aD)=='number'and aD<=aE and 1<=aD and math.floor(aD)==aD end local function
aD(aE)local aF=1 local aG=rawget(aE,aF)while aG~=nil do aF+=1 aG=rawget(aE,aF)end return aF-1 end local function aE(aF,
aG)local aH,aI=type(aF),type(aG)if aH==aI and(aH=='number'or aH=='string')then return aF<aG end return aH<aI end
local function aF(aG)return next,aG,nil end local function aG(aH)local aI,aJ,aK={},0,aD(aH)for aN,aQ in aF(aH)do if not
aC(aN,aK)then aJ=aJ+1 aI[aJ]=aN end end table.sort(aI,aE)return aI,aJ,aK end function av(aH,aI,aJ)local aK=typeof(aH)if
aK=='string'then return ae:JSONEncode(aH)elseif aK=='number'then if aH~=aH then return'NaN'elseif aH==math.huge then
return'Infinity'elseif aH==-math.huge then return'-Infinity'else return tostring(aH)end elseif aK=='function'then local
aN,aQ='[function',debug.info(aH,'n')if aQ~=nil and aQ~=''then aN..=' '..aQ end return aN..']'elseif aK=='table'then
return aw(aH,aI,aJ)else return tostring(aH)end end function aw(aH,aI,aJ)if table.find(aI,aH)~=nil then return
'[Circular]'end local aK={unpack(aI)}table.insert(aK,aH)if typeof(aH.toJSON)=='function'then local aN=aH:toJSON(aH)if aN
~=aH then if typeof(aN)=='string'then return aN else return av(aN,aK,aJ)end end elseif ah(aH)then return ax(aH,aK,aJ)end
return az(aH,aK,aJ)end function az(aH,aI,aJ)local aK,aN='',getmetatable(aH)if aN and rawget(aN,'__tostring')then return
tostring(aH)end local aQ,aR,aS=aG(aH)if aS==0 and aR==0 then aK..='{}'return aK end if#aI>aJ.depth then aK..='['..aA(aH)
..']'return aK end local aT={}for aU=1,aS do local aV=av(aH[aU],aI,aJ)table.insert(aT,aV)end for aU=1,aR do local aV=aQ[
aU]local aW=av(aH[aV],aI,aJ)table.insert(aT,aV..': '..aW)end aK..='{ '..table.concat(aT,', ')..' }'return aK end
function ax(aH,aI,aJ)local aK=#aH if aK==0 then return'[]'end if#aI>aJ.depth then return'[Array]'end local aN=math.min(
as,aK)local aQ,aR=aK-aN,{}for aS=1,aN do aR[aS]=(av(aH[aS],aI,aJ))end if aQ==1 then table.insert(aR,'... 1 more item')
elseif aQ>1 then table.insert(aR,('... %s more items'):format(tostring(aQ)))end return'['..table.concat(aR,', ')..']'end
function aA(aH)return'Object'end return aB end)()end,[251]=function()local aa,ab,ac=a(251)local ad return(function(...)
local ae=ac(ab.Parent.Parent['jsdotlua_collections@1.2.3'].collections)return ae end)()end,[252]=function()local aa,ab,
ac=a(252)local ad return(function(...)local ae=ac(ab.makeConsoleImpl)return ae()end)()end,[253]=function()local aa,ab,ac
=a(253)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag,ah=ac(af.Collections).inspect,'  '
return function()local ar,as={},0 local function au()return string.rep(ah,as)end function ar.log(av,...)local aw if
typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end print(au()..aw)end function ar.debug(av,...)local aw
if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end print(au()..aw)end function ar.info(av,...)local
aw if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end print(au()..aw)end function ar.warn(av,...)
local aw if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end warn(au()..aw)end function ar.error(av,
...)local aw if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end warn(au()..aw)end function ar.group(
av,...)local aw if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end print(au()..aw)as=as+1 end
function ar.groupCollapsed(av,...)local aw if typeof(av)=='string'then aw=string.format(av,...)else aw=ag(av)end print(
au()..aw)as=as+1 end function ar.groupEnd()if as>0 then as=as-1 end end return ar end end)()end,[255]=function()local aa
,ab,ac=a(255)local ad return(function(...)return{}end)()end,[257]=function()local aa,ab,ac=a(257)local ad return(
function(...)local ae=ac(ab.instanceof)return ae end)()end,[258]=function()local aa,ab,ac=a(258)local ad return(function
(...)local ae=_G.__DEV__ local function af(ag,ah)if ae then assert(typeof(ah)=='table',
'Received a non-table as the second argument for instanceof')end if typeof(ag)~='table'then return false end local ar,as
=pcall(function()return ah.new~=nil and ag.new==ah.new end)if ar and as then return true end local au={[ag]=true}while
ag and typeof(ag)=='table'do ag=getmetatable(ag)if typeof(ag)=='table'then ag=ag.__index if ag==ah then return true end
end if typeof(ag)=='table'then if au[ag]then return false end au[ag]=true end end return false end return af end)()end,[
260]=function()local aa,ab,ac=a(260)local ad return(function(...)return ac(ab.Parent.Parent['jsdotlua_boolean@1.2.3'].
boolean)end)()end,[261]=function()local aa,ab,ac=a(261)local ad return(function(...)local ae=ac(ab.Parent.Parent[
'jsdotlua_collections@1.2.3'].collections)return ae end)()end,[262]=function()local aa,ab,ac=a(262)local ad return(
function(...)return ac(ab.Parent.Parent['jsdotlua_console@1.2.3'].console)end)()end,[263]=function()local aa,ab,ac=a(263
)local ad return(function(...)local ae=ac(ab.Parent.Parent['jsdotlua_es7-types@1.2.3']['es7-types'])return ae end)()end,
[264]=function()local aa,ab,ac=a(264)local ad return(function(...)return ac(ab.Parent.Parent[
'jsdotlua_instance-of@1.2.3']['instance-of'])end)()end,[265]=function()local aa,ab,ac=a(265)local ad return(function(...
)return ac(ab.Parent.Parent['jsdotlua_math@1.2.3'].math)end)()end,[266]=function()local aa,ab,ac=a(266)local ad return(
function(...)return ac(ab.Parent.Parent['jsdotlua_number@1.2.3'].number)end)()end,[267]=function()local aa,ab,ac=a(267)
local ad return(function(...)return ac(ab.Parent.Parent['jsdotlua_string@1.2.3'].string)end)()end,[268]=function()local
aa,ab,ac=a(268)local ad return(function(...)local ae=ac(ab.Parent.Parent['jsdotlua_symbol@1.0.0'].symbol)return ae end)(
)end,[269]=function()local aa,ab,ac=a(269)local ad return(function(...)local ae=ac(ab.Parent.Parent[
'jsdotlua_timers@1.2.3'].timers)return ae end)()end,[270]=function()local aa,ab,ac=a(270)local ad return(function(...)
local ae=ab.Parent local af,ag,ah,ar,as,au,av,aw,ax,az,aA,aB,aC,aD=ac(ae.Boolean),ac(ae.Collections),ac(ae.Console),ac(
ae.Math),ac(ae.Number),ac(ae.String),ac(ae.Symbol),ac(ae.Timers),ac(ae.ES7Types),ac(ab.AssertionError),ac(ab.Error),ac(
ab.Promise),ac(ab.extends),ac(ae.InstanceOf)return{Array=ag.Array,AssertionError=az,Boolean=af,console=ah,Error=aA,
extends=aC,instanceof=aD,Math=ar,Number=as,Object=ag.Object,Map=ag.Map,coerceToMap=ag.coerceToMap,coerceToTable=ag.
coerceToTable,Set=ag.Set,WeakMap=ag.WeakMap,String=au,Symbol=av,setTimeout=aw.setTimeout,clearTimeout=aw.clearTimeout,
setInterval=aw.setInterval,clearInterval=aw.clearInterval,util={inspect=ag.inspect}}end)()end,[271]=function()local aa,
ab,ac=a(271)local ad return(function(...)local ae=ac(ab['AssertionError.global'])return ae.AssertionError end)()end,[272
]=function()local aa,ab,ac=a(272)local ad return(function(...)local ae=ab.Parent.Parent local af=ae.Parent local ag=ac(
af.Collections)local ah,ar,as,au,av,aw,ax,az=ag.Array,ag.Object,ac(af.Boolean),ac(af.String),ac(af.ES7Types),ag.inspect,
ac(ae.Error),ac(af.InstanceOf)local aA={stderr={isTTY=false,columns=0,hasColors=function(aA)return true end}}function
ErrorCaptureStackTrace(aB,...)ax.captureStackTrace(aB,...)end local function aB(aC)return aC end local aC,aD,aE,aF,aG,aH
='','','','',{deepStrictEqual='Expected values to be strictly deep-equal:',strictEqual=
'Expected values to be strictly equal:',strictEqualObject='Expected "actual" to be reference-equal to "expected":',
deepEqual='Expected values to be loosely deep-equal:',notDeepStrictEqual=
'Expected "actual" not to be strictly deep-equal to:',notStrictEqual='Expected "actual" to be strictly unequal to:',
notStrictEqualObject='Expected "actual" not to be reference-equal to "expected":',notDeepEqual=
'Expected "actual" not to be loosely deep-equal to:',notIdentical=
'Values have same structure but are not reference-equal:',notDeepEqualUnequal=
'Expected values not to be loosely deep-equal:'},12 local function aI(aJ)local aK,aN=ar.keys(aJ),{}for aQ,aR in aK do aN
[aR]=aJ[aR]end aN.message=aJ.message return aN end local function aJ(aK)return aw(aK,{compact=false,customInspect=false,
depth=1000,maxArrayLength=math.huge,showHidden=false,showProxy=false,sorted=true,getters=true})end local function aK(aN,
aQ,aR)local aS,aT,aU,aV,aW='','','',false,aJ(aN)local aX,aY,aZ,a_=au.split(aW,'\n'),au.split(aJ(aQ),'\n'),0,''if aR==
'strictEqual'and(typeof(aN)=='table'and aN~=nil and typeof(aQ)=='table'and aQ~=nil or typeof(aN)=='function'and typeof(
aQ)=='function')then aR='strictEqualObject'end if#aX==1 and#aY==1 and aX[1]~=aY[1]then local a0=false local a1,a2=if a0
then aB(aX[1])else aX[1],if as.toJSBoolean(a0)then aB(aY[1])else aY[1]local a3=string.len(a1)+string.len(a2)if a3<=aH
then if(typeof(aN)~='table'or aN==nil)and(typeof(aQ)~='table'or aQ==nil)and(aN~=0 or aQ~=0)then return('%s\n\n'):format(
aG[aR])..('%s !== %s\n'):format(aX[1],aY[1])end elseif aR~='strictEqualObject'then local a4=if aA.stderr.isTTY then aA.
stderr.columns else 80 if a3<a4 then while string.sub(a1,aZ+1,aZ+1)==string.sub(a2,aZ+1,aZ+1)do aZ+=1 end if aZ>2 then
a_=('\n  %s^'):format(string.rep(' ',aZ))aZ=0 end end end end local a0,a1=aX[#aX],aY[#aY]while a0==a1 do local a2=aZ aZ
+=1 if a2<3 then aU=('\n  %s%s'):format(a0,aU)else aS=a0 end table.remove(aX)table.remove(aY)if#aX==0 or#aY==0 then
break end a0=aX[#aX]a1=aY[#aY]end local a2=math.max(#aX,#aY)if a2==0 then local a3=au.split(aW,'\n')if#a3>50 then a3[47]
=('%s...%s'):format(aC,aF)while#a3>47 do table.remove(a3)end end return('%s\n\n'):format(aG.notIdentical)..('%s\n'):
format(ah.join(a3,'\n'))end if aZ>=5 then aU=('\n%s...%s%s'):format(aC,aF,aU)aV=true end if aS~=''then aU=('\n  %s%s'):
format(aS,aU)aS=''end local a3,a4,a5,a6,a7,a8,a9=0,0,aG[aR]..('\n%s+ actual%s %s- expected%s'):format(aD,aF,aE,aF),(
' %s...%s Lines skipped'):format(aC,aF),aX,('%s+%s'):format(aD,aF),#aY if#aX<a2 then a7=aY a8=('%s-%s'):format(aE,aF)a9=
#aX end for b=1,a2 do aZ=b if a9<b then if a4>2 then if a4>3 then if a4>4 then if a4==5 then aT..=('\n  %s'):format(a7[(
b-3)])a3+=1 else aT..=('\n%s...%s'):format(aC,aF)aV=true end end aT..=('\n  %s'):format(a7[(b-2)])a3+=1 end aT..=(
'\n  %s'):format(a7[(b-1)])a3+=1 end a4=0 if a7==aX then aT..=('\n%s %s'):format(a8,a7[b])else aS..=('\n%s %s'):format(
a8,a7[b])end a3+=1 else local ba,bb=aY[b],aX[b]local bc=bb~=ba and(not as.toJSBoolean(au.endsWith(bb,','))or au.slice(bb
,0,-1)~=ba)if bc and au.endsWith(ba,',')and au.slice(ba,0,-1)==bb then bc=false bb..=','end if bc then if a4>2 then if
a4>3 then if a4>4 then if a4==5 then aT..=('\n  %s'):format(aX[b-3])a3+=1 else aT..=('\n%s...%s'):format(aC,aF)aV=true
end end aT..=('\n  %s'):format(aX[b-2])a3+=1 end aT..=('\n  %s'):format(aX[b-1])a3+=1 end a4=0 aT..=('\n%s+%s %s'):
format(aD,aF,bb)aS..=('\n%s-%s %s'):format(aE,aF,ba)a3+=2 else aT..=aS aS=''a4+=1 if a4<=2 then aT..=('\n  %s'):format(
bb)a3+=1 end end end if a3>50 and b<a2-2 then return('%s%s\n%s\n%s...%s%s\n'):format(a5,a6,aT,aC,aF,aS)..('%s...%s'):
format(aC,aF)end end return('%s%s\n%s%s%s%s'):format(a5,if aV then a6 else'',aT,aS,aU,a_)end local aN=(setmetatable({},{
__index=ax}))aN.__index=aN aN.__tostring=function(aQ)return aQ:toString()end function aN.new(aQ)local aR,aS,aT,aU,aV,aW=
aQ.message,aQ.operator,aQ.stackStartFn,aQ.actual,(aQ.expected)if aR~=nil then aW=(setmetatable(ax.new(tostring(aR)),aN))
else if aA.stderr.isTTY then if aA.stderr:hasColors()then aC='\27[34m'aD='\27[32m'aF='\27[39m'aE='\27[31m'else aC=''aD=
''aF=''aE=''end end if typeof(aU)=='table'and aU~=nil and typeof(aV)=='table'and aV~=nil and ah.indexOf(ar.keys(aU),
'stack')~=-1 and az(aU,ax)and ah.indexOf(ar.keys(aV),'stack')~=-1 and az(aV,ax)then aU=aI(aU)aV=aI(aV)end if aS==
'deepStrictEqual'or aS=='strictEqual'then aW=(setmetatable(ax.new(aK(aU,aV,aS)),aN))elseif aS=='notDeepStrictEqual'or aS
=='notStrictEqual'then local aX,aY=aG[aS],au.split(aJ(aU),'\n')if aS=='notStrictEqual'and(typeof(aU)=='table'and aU~=nil
or typeof(aU)=='function')then aX=aG.notStrictEqualObject end if#aY>50 then aY[47]=('%s...%s'):format(aC,aF)while#aY>47
do table.remove(aY)end end if#aY==1 then aW=(setmetatable(ax.new(('%s%s%s'):format(aX,if string.len(aY[1])>5 then'\n\n'
else' ',aY[1])),aN))else aW=(setmetatable(ax.new(('%s\n\n%s\n'):format(aX,ah.join(aY,'\n'))),aN))end else local aX,aY,aZ
=aJ(aU),aJ(aV),aG[tostring(aS)]if aS=='notDeepEqual'and aX==aY then aX=('%s\n\n%s'):format(aZ,aX)if string.len(aX)>1024
then aX=('%s...'):format(au.slice(aX,0,1021))end aW=(setmetatable(ax.new(aX),aN))else if string.len(aX)>512 then aX=(
'%s...'):format(au.slice(aX,0,509))end if string.len(aY)>512 then aY=('%s...'):format(au.slice(aY,0,509))end if aS==
'deepEqual'then aX=([[%s

%s

should loosely deep-equal

]]):format(aZ,aX)else local a_=aG[('%sUnequal'):format(
tostring(aS))]if as.toJSBoolean(a_)then aX=([[%s

%s

should not loosely deep-equal

]]):format(a_,aX)else aY=(' %s %s')
:format(tostring(aS),aY)end end aW=(setmetatable(ax.new(('%s%s'):format(aX,aY)),aN))end end end aW.generatedMessage=not
as.toJSBoolean(aR)aW.name='AssertionError [ERR_ASSERTION]'aW.code='ERR_ASSERTION'aW.actual=aU aW.expected=aV aW.operator
=aS ErrorCaptureStackTrace(aW,aT or aN.new)aW.name='AssertionError'return(aW)end function aN.toString(aQ)return(
'%s [%s]: %s'):format(aQ.name,aQ.code,aQ.message)end aN.name='AssertionError'return{AssertionError=aN}end)()end,[273]=
function()local aa,ab,ac=a(273)local ad return(function(...)local ae=ac(ab['Error.global'])return ae end)()end,[274]=
function()local aa,ab,ac=a(274)local ad return(function(...)local ae=ab.Parent.Parent local af=ae.Parent local ag=ac(af.
ES7Types)local ah,ar={},'Error'ah.__index=ah ah.__tostring=function(as)return getmetatable(ah).__tostring(as)end
local function as(au)local av=(setmetatable({name=ar,message=au or''},ah))ah.__captureStackTrace(av,4)return av end
function ah.new(au)return as(au)end function ah.captureStackTrace(au,av)ah.__captureStackTrace(au,3,av)end function ah.
__captureStackTrace(au,av,aw)local ax=au if typeof(aw)=='function'then local az,aA,aB=debug.traceback(nil,av),debug.
info(aw,'n'),debug.info(aw,'s')local aC=string.gsub(aB,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')local aD=aC..':%d* function '
..aA local aE,aF=(string.find(az,aD))if aE~=nil then aE,aF=string.find(az,'\n',aE+1)end if aF~=nil then az=string.sub(az
,aF+1)end ax.__stack=az else ax.__stack=debug.traceback(nil,av)end ah.__recalculateStacktrace(ax)end function ah.
__recalculateStacktrace(au)local av=au local aw,ax=av.message,av.name or ar local az,aA=ax..(if aw~=nil and aw~=''then(
': '..aw)else''),if av.__stack then av.__stack else''av.stack=az..'\n'..aA end return setmetatable(ah,{__call=function(
au,...)return as(...)end,__tostring=function(au)if au.name~=nil then if au.message and au.message~=''then return string.
format('%s: %s',tostring(au.name),tostring(au.message))end return tostring(au.name)end return tostring(ar)end})end)()end
,[275]=function()local aa,ab,ac=a(275)local ad return(function(...)return{}end)()end,[276]=function()local aa,ab,ac=a(
276)local ad return(function(...)local ae,af=game:GetService'HttpService',ab.Parent local ag=af.Parent local ah=ac(ag.
String)local ar,as=ah.charCodeAt,ac(ab.Parent.Error)local function au(av)local aw=utf8.len(av)if aw==0 or aw==nil then
return''end local ax=ar(av,1)if aw==1 then if ax==0xd800 then error(as.new'URI malformed')end if ax==0xdfff then error(
as.new'URI malformed')end end if ax>=0xdc00 and ax<0xdfff then error(as.new'URI malformed')end local az=ae:UrlEncode(av)
local aA=az:gsub('%%2D','-'):gsub('%%5F','_'):gsub('%%2E','.'):gsub('%%21','!'):gsub('%%7E','~'):gsub('%%2A','*'):gsub(
'%%27',"'"):gsub('%%28','('):gsub('%%29',')')return aA end return au end)()end,[277]=function()local aa,ab,ac=a(277)
local ad return(function(...)return function(ae,af,ag)local ah={}ah.__index=ah ah.__tostring=function(ar)return
getmetatable(ae).__tostring(ar)end local ar={}ah.new=function(...)local as={}ag(as,...)return setmetatable(as,ah)end if
typeof(getmetatable(ae))=='table'and getmetatable(ae).__call then ar.__call=function(as,...)return ah.new(...)end end ar
.__index=ae ar.__tostring=function(as)if as==ah then return tostring(af)end return getmetatable(ae).__tostring(as)end
setmetatable(ah,ar)return ah end end)()end,[290]=function()local aa,ab,ac=a(290)local ad return(function(...)local ae=
ac(ab.Parent.Parent['jsdotlua_es7-types@1.2.3']['es7-types'])return ae end)()end,[298]=function()local aa,ab,ac=a(298)
local ad return(function(...)local function ae(af,ag,ah)local ar,as=(string.len(af))if ah then as=ah else as=ar end if
ah and ah<1 then as=1 end if ah and ah>ar then as=ar end if ag==''then return as end local au,av,aw=0 repeat av=aw aw,au
=string.find(af,ag,au+1,true)until aw==nil or aw>as if av==nil then return-1 end return av end return ae end)()end,[315]
=function()local aa,ab,ac=a(315)local ad return(function(...)local ae=newproxy(false)local af,ag,ah=1,2,3 return
function(ar)local function as(au,av,...)local aw,ax={...},{[ae]=af}if av==nil then av=0 end local az=av/1000 ar(az,
function()if ax[ae]==af then au(unpack(aw))ax[ae]=ag end end)return ax end local function au(av)if av==nil then return
end if av[ae]==af then av[ae]=ah end end return{setTimeout=as,clearTimeout=au}end end)()end,[284]=function()local aa,ab,
ac=a(284)local ad return(function(...)return function(ae)return typeof(ae)=='number'and ae==ae and ae~=math.huge and ae
~=-math.huge end end)()end,[288]=function()local aa,ab,ac=a(288)local ad return(function(...)return function(ae,af)local
ag=ae if typeof(ae)=='string'then local ah=0/0 ag=tonumber(ae)or ah end if typeof(ag)~='number'then return'nan'end if af
~=nil then if typeof(af)~='number'then error[[TypeError: fractionDigits must be a number between 0 and 100]]end if af<0
or af>100 then error'RangeError: fractionDigits must be between 0 and 100'end end local ah if af==nil then ah='%e'else
ah='%.'..tostring(af)..'e'end local ar=string.format(ah,ag):gsub('%+0','+'):gsub('%-0','-'):gsub('0*e','e')return ar end
end)()end,[314]=function()local aa,ab,ac=a(314)local ad return(function(...)local ae=newproxy(false)local af,ag=1,3
return function(ah)local function ar(as,au,...)local av,aw={...},{[ae]=af}if au==nil then au=0 end local ax,az=(au/1000)
az=function()ah(ax,function()if aw[ae]==af then as(unpack(av))az()end end)end az()return aw end local function as(au)if
au==nil then return end if au[ae]==af then au[ae]=ag end end return{setInterval=ar,clearInterval=as}end end)()end,[300]=
function()local aa,ab,ac=a(300)local ad return(function(...)local ae=ab.Parent local af,ag,ah=ac(ae.findOr),ac(ae.slice)
,ae.Parent local ar=ac(ah.ES7Types)local as=ac(ah.Number).MAX_SAFE_INTEGER local function au(av,aw,ax)if aw==nil then
return{av}end if ax==0 then return{}end local az,aA,aB=if ax==nil or ax<0 then as else ax,aw if typeof(aA)=='string'then
if aA==''then local aC={}for aD in av:gmatch'.'do table.insert(aC,aD)end return aC end aB={aA}else aB=aA end local aC,aD
,aE,aF,aG=1,{},nil,utf8.len(av)assert(aF~=nil,('string `%s` has an invalid byte at position %s'):format(av,tostring(aG))
)repeat local aH=af(av,aB,aC)if aH~=nil then table.insert(aD,ag(av,aC,aH.index))local aI=utf8.len(aH.match)aC=aH.index+
aI else table.insert(aD,ag(av,aC,nil))end if aH~=nil then aE=aH end until aH==nil or aC>aF or#aD>=az if aE~=nil then
local aH,aI=utf8.len(aE.match)assert(aH~=nil,('string `%s` has an invalid byte at position %s'):format(aE.match,
tostring(aI)))if aE.index+aH==aF+1 then table.insert(aD,'')end end return aD end return au end)()end,[305]=function()
local aa,ab,ac=a(305)local ad return(function(...)return function(ae)return(ae:gsub('^[%s]+',''))end end)()end,[293]=
function()local aa,ab,ac=a(293)local ad return(function(...)local ae=ab.Parent local af=ae.Parent local ag=ac(af.Number)
local ah=ag.NaN return function(ar,as)if type(as)~='number'then as=1 end local au=string.len(ar)if as<1 or as>au then
return ah end local av=utf8.offset(ar,as)if av==nil or av>au then return ah end local aw=utf8.codepoint(ar,av,av)if aw==
nil then return ah end return aw end end)()end,[291]=function()local aa,ab,ac=a(291)local ad return(function(...)return
ac(ab.Parent.Parent['jsdotlua_number@1.2.3'].number)end)()end,[310]=function()local aa,ab,ac=a(310)local ad return(
function(...)return{new=function(ae)local af,ag=newproxy(true),'Symbol()'if ae then ag=('Symbol(%s)'):format(ae)end
getmetatable(af).__tostring=function()return ag end return(af)end}end)()end,[299]=function()local aa,ab,ac=a(299)local
ad return(function(...)local function ae(af,ag,ah)local ar,as=utf8.len(af)assert(ar~=nil,(
'string `%s` has an invalid byte at position %s'):format(af,tostring(as)))local au=tonumber(ag)assert(typeof(au)==
'number','startIndexStr should be a number')if au+ar<0 then au=1 end if au>ar then return''end local av=ar+1 if ah~=nil
then local aw=0/0 av=tonumber(ah)or aw end assert(typeof(av)=='number','lastIndexStr should convert to number')if av>ar
then av=ar+1 end local aw,ax=assert(utf8.offset(af,au),'startIndexByte should be a number'),assert(utf8.offset(af,av),
'lastIndexByte should be a number')-1 return string.sub(af,aw,ax)end return ae end)()end,[301]=function()local aa,ab,ac=
a(301)local ad return(function(...)local function ae(af,ag,ah)if string.len(ag)==0 then return true end local ar if ah==
nil or ah<1 then ar=1 else ar=ah end if ar>string.len(af)then return false end return af:find(ag,ar,true)==ar end return
ae end)()end,[309]=function()local aa,ab,ac=a(309)local ad return(function(...)local ae,af=ac(ab.Parent.Symbol),{}return
{getOrInit=function(ag)if af[ag]==nil then af[ag]=ae.new(ag)end return af[ag]end,__clear=function()af={}end}end)()end,[
287]=function()local aa,ab,ac=a(287)local ad return(function(...)local ae,af=ac(ab.Parent.isInteger),ac(ab.Parent.
MAX_SAFE_INTEGER)return function(ag)return ae(ag)and math.abs(ag)<=af end end)()end,[282]=function()local aa,ab,ac=a(282
)local ad return(function(...)return 9007199254740991 end)()end,[295]=function()local aa,ab,ac=a(295)local ad return(
function(...)local ae='(['..('$%^()-[].?'):gsub('(.)','%%%1')..'])'local function af(ag,ah,ar)local as,au=utf8.offset(ag
,ar or 1),{}for av,aw in ah do aw=aw:gsub(ae,'%%%1')local ax,az=string.find(ag,aw,as)if ax then local aA=string.sub(ag,1
,ax-1)local aB,aC=utf8.len(aA)if aB==nil then error(('string `%s` has an invalid byte at position %s'):format(aA,
tostring(aC)))end local aD=aB+1 local aE={index=aD,match=string.sub(ag,ax,az)}table.insert(au,aE)end end if#au==0 then
return nil end local ax for az,aA in au do if ax==nil then ax=aA end if aA.index<ax.index then ax=aA end end return ax
end return af end)()end,[283]=function()local aa,ab,ac=a(283)local ad return(function(...)return-9007199254740991 end)()
end,[297]=function()local aa,ab,ac=a(297)local ad return(function(...)local ae='(['..('$%^()-[].?'):gsub('(.)','%%%1')..
'])'return function(af,ag,ah)local ar,as=#af,if ah~=nil then if ah<1 then 1 else ah else 1 if#ag==0 then return if as>ar
then ar else as end if as>ar then return-1 end ag=ag:gsub(ae,'%%%1')local au=#ag for ax=as,ar do if string.sub(af,ax,ax+
au-1)==ag then return ax end end return-1 end end)()end,[281]=function()local aa,ab,ac=a(281)local ad return(function(
...)return{isFinite=ac(ab.isFinite),isInteger=ac(ab.isInteger),isNaN=ac(ab.isNaN),isSafeInteger=ac(ab.isSafeInteger),
MAX_SAFE_INTEGER=ac(ab.MAX_SAFE_INTEGER),MIN_SAFE_INTEGER=ac(ab.MIN_SAFE_INTEGER),NaN=0/0,toExponential=ac(ab.
toExponential)}end)()end,[292]=function()local aa,ab,ac=a(292)local ad return(function(...)return{charCodeAt=ac(ab.
charCodeAt),endsWith=ac(ab.endsWith),findOr=ac(ab.findOr),includes=ac(ab.includes),indexOf=ac(ab.indexOf),lastIndexOf=
ac(ab.lastIndexOf),slice=ac(ab.slice),split=ac(ab.split),startsWith=ac(ab.startsWith),substr=ac(ab.substr),trim=ac(ab.
trim),trimEnd=ac(ab.trimEnd),trimStart=ac(ab.trimStart),trimRight=ac(ab.trimEnd),trimLeft=ac(ab.trimStart)}end)()end,[
286]=function()local aa,ab,ac=a(286)local ad return(function(...)return function(ae)return type(ae)=='number'and ae~=ae
end end)()end,[296]=function()local aa,ab,ac=a(296)local ad return(function(...)local ae='(['..('$%^()-[].?'):gsub('(.)'
,'%%%1')..'])'local function af(ag,ah,ar)local as,au=utf8.len(ag)assert(as~=nil,(
'string `%s` has an invalid byte at position %s'):format(ag,tostring(au)))if as==0 then return false end if#ah==0 then
return true end local ax=1 if ar~=nil then ax=tonumber(ar)or 1 if ax>as then return false end end if ax<1 then ax=1 end
local az,aA=utf8.offset(ag,ax),ah:gsub(ae,'%%%1')local aB,aC=string.find(ag,aA,az)return aB~=nil end return af end)()end
,[313]=function()local aa,ab,ac=a(313)local ad return(function(...)local ae=ab.Parent local af,ag,ah=ac(ae.Collections).
Object,ac(ab.makeTimerImpl),ac(ab.makeIntervalImpl)return af.assign({},ag(task.delay),ah(task.delay))end)()end,[302]=
function()local aa,ab,ac=a(302)local ad return(function(...)return function(ae,af,ag)if ag and ag<=0 then return''end
return string.sub(ae,af,ag and af+ag-1 or nil)end end)()end,[307]=function()local aa,ab,ac=a(307)local ad return(
function(...)local ae=ac(ab.Symbol)local af,ag=ac(ab['Registry.global']),setmetatable({},{__call=function(af,ag)return
ae.new(ag)end})ag.for_=af.getOrInit return ag end)()end,[304]=function()local aa,ab,ac=a(304)local ad return(function(
...)return function(ae)return(ae:gsub('[%s]+$',''))end end)()end,[294]=function()local aa,ab,ac=a(294)local ad return(
function(...)local function ae(af,ag,ah)local ar=ag:len()if ar==0 then return true end local as=af:len()local au=ah or
as if au>as then au=as end if au<1 then return false end local ax=au-ar+1 return af:find(ag,ax,true)==ax end return ae
end)()end,[312]=function()local aa,ab,ac=a(312)local ad return(function(...)local ae=ac(ab.Parent.Parent[
'jsdotlua_collections@1.2.3'].collections)return ae end)()end,[279]=function()local aa,ab,ac=a(279)local ad return(
function(...)return{clz32=bit32.countlz}end)()end,[308]=function()local aa,ab,ac=a(308)local ad return(function(...)
local ae,af=ac(ab.Parent.Symbol),{}return{getOrInit=function(ag)if af[ag]==nil then af[ag]=ae.new(ag)end return af[ag]
end,__clear=function()af={}end}end)()end,[285]=function()local aa,ab,ac=a(285)local ad return(function(...)return
function(ae)return type(ae)=='number'and ae~=math.huge and ae==math.floor(ae)end end)()end,[303]=function()local aa,ab,
ac=a(303)local ad return(function(...)local ae,af=ac(ab.Parent.trimStart),ac(ab.Parent.trimEnd)return function(ag)return
ae(af(ag))end end)()end},{{1,4,{'react-roblox-example'},{{2,1,{'ReactLuau'},{{132,2,{'RoactCompat'},{{135,2,{
'createFragment'}},{137,2,{'setGlobalConfig'}},{136,2,{'oneChild'}},{138,2,{'warnOnce'}},{134,2,{'RoactTree'}},{133,2,{
'Portal'}}}},{5,2,{'React'},{{16,2,{'ReactHooks'}},{14,2,{'ReactElementValidator'}},{20,2,{'ReactNoopUpdateQueue'}},{18,
2,{'ReactMemo'}},{11,2,{'ReactContext'}},{19,2,{'ReactMutableSource'}},{15,2,{'ReactForwardRef'}},{8,2,{
'ReactBaseClasses'}},{17,2,{'ReactLazy'}},{9,2,{'ReactBinding.roblox'}},{6,2,{'None.roblox'}},{21,2,{
'createSignal.roblox'}},{13,2,{'ReactElement'}},{10,2,{'ReactChildren'}},{7,2,{'React'}},{12,2,{'ReactCreateRef'}}}},{64
,2,{'ReactIs'}},{29,2,{'ReactDevtoolsShared'},{{40,2,{'constants'}},{59,2,{'hook'}},{61,2,{'storage'}},{39,2,{'bridge'}}
,{30,2,{'backend'},{{34,2,{'agent'}},{38,2,{'utils'}},{37,2,{'types'}},{35,2,{'console'}},{31,1,{'NativeStyleEditor'},{{
32,2,{'types'}}}},{33,2,{'ReactSymbols'}},{36,2,{'renderer'}}}},{60,2,{'hydration'}},{58,2,{'events'}},{63,2,{'utils'}},
{41,2,{'devtools'},{{46,2,{'types'}},{48,1,{'views'},{{49,1,{'Components'},{{50,2,{'types'}}}},{51,1,{'Profiler'},{{54,2
,{'InteractionsChartBuilder'}},{52,2,{'CommitTreeBuilder'}},{57,2,{'utils'}},{56,2,{'types'}},{55,2,{
'RankedChartBuilder'}},{53,2,{'FlamegraphChartBuilder'}}}}}},{47,2,{'utils'}},{43,2,{'ProfilingCache'}},{42,2,{
'ProfilerStore'}},{45,2,{'store'}},{44,2,{'cache'}}}},{62,2,{'types'}}}},{3,2,{'LuauPolyfill'}},{193,1,{'_Index'},{{256,
1,{'jsdotlua_instance-of@1.2.3'},{{257,2,{'instance-of'},{{258,2,{'instanceof'}}}}}},{254,1,{'jsdotlua_es7-types@1.2.3'}
,{{255,2,{'es7-types'}}}},{280,1,{'jsdotlua_number@1.2.3'},{{281,2,{'number'},{{288,2,{'toExponential'}},{283,2,{
'MIN_SAFE_INTEGER'}},{282,2,{'MAX_SAFE_INTEGER'}},{287,2,{'isSafeInteger'}},{286,2,{'isNaN'}},{284,2,{'isFinite'}},{285,
2,{'isInteger'}}}}}},{289,1,{'jsdotlua_string@1.2.3'},{{292,2,{'string'},{{298,2,{'lastIndexOf'}},{299,2,{'slice'}},{304
,2,{'trimEnd'}},{294,2,{'endsWith'}},{297,2,{'indexOf'}},{300,2,{'split'}},{295,2,{'findOr'}},{303,2,{'trim'}},{302,2,{
'substr'}},{301,2,{'startsWith'}},{296,2,{'includes'}},{305,2,{'trimStart'}},{293,2,{'charCodeAt'}}}},{290,2,{'ES7Types'
}},{291,2,{'Number'}}}},{194,1,{'evaera_promise@4.0.0'},{{195,2,{'promise'},{{196,2,{'init.spec'}}}}}},{311,1,{
'jsdotlua_timers@1.2.3'},{{312,2,{'Collections'}},{313,2,{'timers'},{{314,2,{'makeIntervalImpl'}},{315,2,{
'makeTimerImpl'}}}}}},{259,1,{'jsdotlua_luau-polyfill@1.2.3'},{{266,2,{'Number'}},{260,2,{'Boolean'}},{263,2,{'ES7Types'
}},{262,2,{'Console'}},{268,2,{'Symbol'}},{267,2,{'String'}},{261,2,{'Collections'}},{264,2,{'InstanceOf'}},{270,2,{
'luau-polyfill'},{{271,2,{'AssertionError'},{{272,2,{'AssertionError.global'}}}},{275,2,{'Promise'}},{273,2,{'Error'},{{
274,2,{'Error.global'}}}},{276,2,{'encodeURIComponent'}},{277,2,{'extends'}}}},{265,2,{'Math'}},{269,2,{'Timers'}}}},{
306,1,{'jsdotlua_symbol@1.0.0'},{{307,2,{'symbol'},{{309,2,{'Registry.global'}},{310,2,{'Symbol'}},{308,2,{
'GlobalRegistry'}}}}}},{250,1,{'jsdotlua_console@1.2.3'},{{251,2,{'Collections'}},{252,2,{'console'},{{253,2,{
'makeConsoleImpl'}}}}}},{278,1,{'jsdotlua_math@1.2.3'},{{279,2,{'math'}}}},{197,1,{'jsdotlua_boolean@1.2.3'},{{198,2,{
'Number'}},{199,2,{'boolean'},{{200,2,{'toJSBoolean'}}}}}},{201,1,{'jsdotlua_collections@1.2.3'},{{204,2,{'collections'}
,{{247,2,{'Set'}},{232,2,{'Map'},{{235,2,{'coerceToTable'}},{234,2,{'coerceToMap'}},{233,2,{'Map'}}}},{236,2,{'Object'},
{{242,2,{'isFrozen'}},{241,2,{'is'}},{245,2,{'seal'}},{239,2,{'entries'}},{240,2,{'freeze'}},{246,2,{'values'}},{238,2,{
'assign'}},{237,2,{'None'}},{243,2,{'keys'}},{244,2,{'preventExtensions'}}}},{249,2,{'inspect'}},{205,2,{'Array'},{{230,
2,{'splice'}},{219,2,{'includes'}},{207,2,{'every'}},{221,2,{'isArray'}},{211,2,{'flat'}},{222,2,{'join'}},{210,2,{
'findIndex'}},{231,2,{'unshift'}},{225,2,{'reverse'}},{228,2,{'some'}},{213,2,{'forEach'}},{227,2,{'slice'}},{220,2,{
'indexOf'}},{226,2,{'shift'}},{229,2,{'sort'}},{224,2,{'reduce'}},{223,2,{'map'}},{209,2,{'find'}},{214,2,{'from'},{{218
,2,{'fromString'}},{217,2,{'fromSet'}},{215,2,{'fromArray'}},{216,2,{'fromMap'}}}},{212,2,{'flatMap'}},{208,2,{'filter'}
},{206,2,{'concat'}}}},{248,2,{'WeakMap'}}}},{202,2,{'ES7Types'}},{203,2,{'InstanceOf'}}}}}},{22,2,{'ReactDebugTools'},{
{25,1,{'__tests__'},{{26,2,{'ReactDevToolsHooksIntegration.spec'}},{27,2,{'ReactHooksInspection.spec'}},{28,2,{
'ReactHooksInspectionIntegration.spec'}}}},{23,2,{'ReactDebugHooks'}},{24,2,{'ReactDebugTools'}}}},{65,2,{
'ReactReconciler'},{{92,2,{'ReactFiberReconciler.new'}},{69,2,{'ReactChildFiber.new'}},{81,2,{'ReactFiberFlags'}},{82,2,
{'ReactFiberHooks.new'}},{80,2,{'ReactFiberErrorLogger'}},{85,2,{'ReactFiberHotReloading.new'}},{112,2,{
'ReactTypeOfMode'}},{84,2,{'ReactFiberHostContext.new'}},{74,2,{'ReactFiberCommitWork.new'}},{100,2,{
'ReactFiberTreeReflection'}},{86,2,{'ReactFiberHydrationContext.new'}},{79,2,{'ReactFiberErrorDialog'}},{117,1,{'forks'}
,{{118,2,{'ReactFiberHostConfig.test'}}}},{106,2,{'ReactMutableSource.new'}},{99,2,{'ReactFiberTransition'}},{110,2,{
'ReactStrictModeWarnings.new'}},{113,2,{'ReactUpdateQueue.new'}},{71,2,{'ReactFiber.new'}},{111,2,{'ReactTestSelectors'}
},{87,2,{'ReactFiberLane'}},{97,2,{'ReactFiberSuspenseContext.new'}},{83,2,{'ReactFiberHostConfig'}},{75,2,{
'ReactFiberCompleteWork.new'}},{107,2,{'ReactPortal'}},{115,2,{'SchedulerWithReactIntegration.new'}},{114,2,{
'ReactWorkTags'}},{77,2,{'ReactFiberContext.new'}},{116,2,{'SchedulingProfiler'}},{95,2,{'ReactFiberStack.new'}},{93,2,{
'ReactFiberRoot.new'}},{66,2,{'DebugTracing'}},{94,2,{'ReactFiberSchedulerPriorities.roblox'}},{89,2,{
'ReactFiberNewContext.new'}},{104,2,{'ReactHookEffectTags'}},{105,2,{'ReactInternalTypes'}},{72,2,{
'ReactFiberBeginWork.new'}},{103,2,{'ReactFiberWorkLoop.new'}},{102,2,{'ReactFiberWorkInProgress'}},{78,2,{
'ReactFiberDevToolsHook.new'}},{90,2,{'ReactFiberOffscreenComponent'}},{91,2,{'ReactFiberReconciler'}},{98,2,{
'ReactFiberThrow.new'}},{96,2,{'ReactFiberSuspenseComponent.new'}},{88,2,{'ReactFiberLazyComponent.new'}},{76,2,{
'ReactFiberComponentStack'}},{67,2,{'MaxInts'}},{70,2,{'ReactCurrentFiber'}},{108,2,{'ReactProfilerTimer.new'}},{109,2,{
'ReactRootTags'}},{73,2,{'ReactFiberClassComponent.new'}},{68,2,{'ReactCapturedValue'}},{101,2,{
'ReactFiberUnwindWork.new'}}}},{152,2,{'Shared'},{{162,2,{'ReactErrorUtils'}},{156,1,{'PropMarkers'},{{157,2,{'Change'}}
,{158,2,{'Event'}},{159,2,{'Tag'}}}},{184,2,{'enqueueTask.roblox'}},{177,2,{'ReactVersion'}},{176,2,{'ReactTypes'}},{163
,2,{'ReactFeatureFlags'}},{155,2,{'ExecutionEnvironment'}},{182,2,{'console'}},{154,2,{'ErrorHandling.roblox'}},{160,2,{
'ReactComponentStackFrame'}},{181,2,{'checkPropTypes'}},{190,2,{'isValidElementType'}},{178,2,{'Symbol.roblox'}},{189,2,
{'invokeGuardedCallbackImpl'}},{192,2,{'shallowEqual'}},{186,2,{'formatProdErrorMessage'}},{187,2,{'getComponentName'}},
{168,2,{'ReactInstanceMap'}},{185,2,{'flowtypes.roblox'}},{183,2,{'consoleWithStackDev'}},{179,2,{'Type.roblox'}},{153,2
,{'ConsolePatchingDev.roblox'}},{191,2,{'objectIs'}},{180,2,{'UninitializedState.roblox'}},{169,2,{
'ReactSharedInternals'},{{173,2,{'ReactCurrentOwner'}},{171,2,{'ReactCurrentBatchConfig'}},{170,2,{
'IsSomeRendererActing'}},{174,2,{'ReactDebugCurrentFrame'}},{172,2,{'ReactCurrentDispatcher'}}}},{161,2,{
'ReactElementType'}},{175,2,{'ReactSymbols'}},{188,2,{'invariant'}},{164,2,{'ReactFiberHostConfig'},{{166,2,{
'WithNoPersistence'}},{165,2,{'WithNoHydration'}},{167,2,{'WithNoTestSelectors'}}}}}},{119,2,{'ReactRoblox'},{{121,1,{
'client'},{{125,2,{'ReactRobloxHostConfig'}},{123,2,{'ReactRobloxComponent'}},{122,2,{'ReactRoblox'}},{124,2,{
'ReactRobloxComponentTree'}},{126,2,{'ReactRobloxHostTypes.roblox'}},{127,2,{'ReactRobloxRoot'}},{128,1,{'roblox'},{{129
,2,{'RobloxComponentProps'}},{130,2,{'SingleEventManager'}},{131,2,{'getDefaultInstanceProperty'}}}}}},{120,2,{
'ReactReconciler.roblox'}}}},{139,2,{'Scheduler'},{{142,2,{'SchedulerHostConfig'}},{141,2,{'SchedulerFeatureFlags'}},{
147,2,{'TracingSubscriptions'}},{144,2,{'SchedulerPriorities'}},{151,2,{'unstable_mock'}},{145,2,{'SchedulerProfiling'}}
,{148,1,{'forks'},{{149,2,{'SchedulerHostConfig.default'}},{150,2,{'SchedulerHostConfig.mock'}}}},{140,2,{'Scheduler'}},
{146,2,{'Tracing'}},{143,2,{'SchedulerMinHeap'}}}},{4,2,{'Promise'}}}}}}},'0.3.5','WaxRuntime',string,task,setmetatable,
error,newproxy,getmetatable,next,table,unpack,coroutine,script,type,require,pcall,tostring,tonumber,_VERSION local aJ,aK
,aN,aQ,aR,aS,aT=ax.insert,ax.remove,ax.freeze or function(aJ)return aJ end,aA.wrap,ae.sub,ae.match,ae.gmatch if aH and
aR(aH,1,4)=='Lune'then local aU,aV=aE(aD,'@lune/task')if aU and aV then af=aV end end local aU=af and af.defer local aV,
aW,aX,aY,aZ,a_,a0,a1,a2=aU or function(aV,...)aQ(aV)(...)end,{[1]='Folder',[2]='ModuleScript',[3]='Script',[4]=
'LocalScript',[5]='StringValue'},{},{},{},{},{},{},{}local a3,a4={GetFullName={{},function(a3)local a4,a5=a3.Name,a3.
Parent while a5 do a4=a5.Name..'.'..a4 a5=a5.Parent end return a4 end},GetChildren={{},function(a3)local a4={}for a5 in
au,a2[a3]do aJ(a4,a5)end return a4 end},GetDescendants={{},function(a3)local a4={}for a5 in au,a2[a3]do aJ(a4,a5)for a6,
a7 in au,a5:GetDescendants()do aJ(a4,a7)end end return a4 end},FindFirstChild={{'string','boolean?'},function(a3,a4,a5)
local a6=a2[a3]for a7 in au,a6 do if a7.Name==a4 then return a7 end end if a5 then for a8 in au,a6 do return a8:
FindFirstChild(a4,a5)end end end},FindFirstAncestor={{'string'},function(a3,a4)local a5=a3.Parent while a5 do if a5.Name
==a4 then return a5 end a5=a5.Parent end end},WaitForChild={{'string','number?'},function(a3,a4)return a3:
FindFirstChild(a4)end}},{}for a5,a6 in au,a3 do local a7,a8,a9=a6[1],a6[2],{}for b,ba in au,a7 do local bb,bc=aS(ba,
'^([^%?]+)(%??)')a9[b]={bb,bc}end a4[a5]=function(bb,...)if not a2[bb]then ah(
"Expected ':' not '.' calling member function "..a5,2)end local bc={...}for bd,be in au,a9 do local bf=bc[bd]local bg,bh
,bi=aC(bf),be[1],be[2]if bf==nil and not bi then ah('Argument '..bf..' missing or nil',3)end if bh~='any'and bg~=bh and
not(bg=='nil'and bi)then ah('Argument '..bd..' expects type "'..bh..'", got "'..bg..'"',2)end end return a8(bb,...)end
end local function a7(a8,a9,b)local ba,bb=(ag({},{__mode='k'}))local function bc(bd)ah(bd..
' is not a valid (virtual) member of '..a8..' "'..a9..'"',3)end local function bd(be)ah(
'Unable to assign (virtual) property '..be..'. Property is read only',3)end local be=ar(true)local bf=as(be)bf.
__metatable=false bf.__index=function(bg,bh)if bh=='ClassName'then return a8 elseif bh=='Name'then return a9 elseif bh==
'Parent'then return b elseif a8=='StringValue'and bh=='Value'then return bb else local bi=a4[bh]if bi then return bi end
end for bi in au,ba do if bi.Name==bh then return bi end end bc(bh)end bf.__newindex=function(bg,bh,bi)if bh==
'ClassName'then bd(bh)elseif bh=='Name'then a9=bi elseif bh=='Parent'then if bi==be then return end if b~=nil then a2[b]
[be]=nil end b=bi if bi~=nil then a2[bi][be]=true end elseif a8=='StringValue'and bh=='Value'then bb=bi else bc(bh)end
end bf.__tostring=function()return a9 end a2[be]=ba if b~=nil then a2[b][be]=true end return be end local function a8(a9
,b)local ba,bb,bc,bd=a9[1],a9[2],a9[3],a9[4]local be=aW[bb]local bf=bc and aK(bc,1)or be local bg=a7(be,bf,b)aX[ba]=bg
if bc then for bh,bi in au,bc do bg[bh]=bi end end if bd then for bh,bi in au,bd do a8(bi,bg)end end return bg end local
a9=a7('Folder','['..ad..']')for b,ba in au,ab do a8(ba,a9)end for bb,bc in au,aa do local bd=aX[bb]aY[bd]=bc aZ[bd]=bb
local be=bd.ClassName if be=='LocalScript'or be=='Script'then aJ(a0,bd)end end local function bd(be)local bf,bg=be.
ClassName,a_[be]if bg and bf=='ModuleScript'then return az(bg)end local bh=aY[be]local function bi(bj)bj=aF(bj)local bk,
bl,bm=be:GetFullName(),aS(bj,'[^:]+:(%d+): (.+)')if not bl or not aI then return bk..':*: '..(bm or bj)end bl=aG(bl)
local bn=aZ[be]local bo=aI[bn]local bp=bl-bo+1 if bp<0 then bp='?'end return bk..':'..bp..': '..bm end if bf==
'LocalScript'or bf=='Script'then local bj,bk=aE(bh)if not bj then ah(bi(bk),0)end else local bj={aE(bh)}local bk=aK(bj,1
)if not bk then local bl=aK(bj,1)ah(bi(bl),0)end a_[be]=bj return az(bj)end end function a(be)local bf=aX[be]
local function bg(bh,...)local bi={aE(bh,...)}local bj=aK(bi,1)if not bj then ah(bi[1],3)end return az(bi)end local bh=
aN(ag({},{__index=a1,__newindex=function(bh,bi,bj)a1[bi]=bj end,__len=function()return#a1 end,__iter=function()return au
,a1 end}))local bi,bj=aN{version=ac,envname=ad,shared=bh,script=aB,require=aD},bf local function bk(bl,...)local bm,bn,
bo=aC(bl),'Attempted to call require with a non-ModuleScript','Attempted to call require with self'if bm=='userdata'and
a2[bl]then if bl.ClassName~='ModuleScript'then ah(bn,2)elseif bl==bf then ah(bo,2)end return bd(bl)elseif bm=='string'
and aR(bl,1,1)~='@'then if#bl==0 then ah('Attempted to call require with empty string',2)end local bp=bf if aR(bl,1,1)==
'/'then bp=a9 elseif aR(bl,1,2)=='./'then bl=aR(bl,3)end local bq for br in aT(bl,'([^/]*)/?')do local bs=br if br=='..'
then bs='Parent'end if bs~=''then local bt=bp:FindFirstChild(bs)if not bt then local bu=bp.Parent if bu then bt=bu:
FindFirstChild(bs)end end if bt then bp=bt elseif br~=bq and br~='init'and br~='init.server'and br~='init.client'then
ah('Virtual script path "'..bl..'" not found',2)end end bq=br end if bp.ClassName~='ModuleScript'then ah(bn,2)elseif bp
==bf then ah(bo,2)end return bd(bp)end return bg(aD,bl,...)end return bi,bj,bk end for be,bf in au,a0 do aV(bd,bf)end do
local bg,bh=(a9:GetChildren())if#bg==1 and bg[1].ClassName=='ModuleScript'then bh=bg[1]else for bi,bj in au,bg do if bj.
ClassName=='ModuleScript'and bj.Name=='MainModule'then bh=bj break end end end if bh then return bd(bh)end end