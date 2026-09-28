--!nonstrict
-- ============================================================
-- LUA INTERFACE v5.4.3
-- Adiciona TweenManager central: cancelamento por (obj,key),
-- validação de TweenInfo, fallback direto se Create falhar,
-- Completed com validação de tween atual, cleanup no Destroy.
-- ============================================================
if _G.LuaInterface and _G.LuaInterface.Destroy then pcall(function()_G.LuaInterface:Destroy()end)end
_G.LuaInterface=(function()
local S={P=game:GetService("Players"),R=game:GetService("RunService"),U=game:GetService("UserInputService"),T=game:GetService("TweenService"),St=game:GetService("Stats"),M=game:GetService("MarketplaceService"),H=game:GetService("HttpService"),D=game:GetService("Debris"),TP=game:GetService("TeleportService"),G=game:GetService("GuiService"),CP=game:GetService("ContentProvider")}
S.LP=S.P.LocalPlayer
if not S.LP then return end
local pgOk,pg=S.LP:WaitForChild("PlayerGui",12)
S.PG=(pgOk and pg) or S.LP:FindFirstChildOfClass("PlayerGui")
if not S.PG then return end
local U2,U3,Uv,Un,V2,WH=UDim2.new,UDim2.fromOffset,UDim2.fromScale,UDim.new,Vector2.new,Color3.new(1,1,1)
local c3rgb,c3hsv,c3hex=Color3.fromRGB,Color3.fromHSV,Color3.fromHex
local cl,mi,ma,fl,ro=math.clamp,math.min,math.max,math.floor,math.round
local sn,cs,rd,dg,sq,at=math.sin,math.cos,math.rad,math.deg,math.sqrt,math.atan2
local sf,sl,sm,ss,sg=string.format,string.lower,string.match,string.sub,string.gmatch
local ty,ts,tn=typeof,tostring,tonumber
local trem,tins=table.remove,table.insert
local I=Instance.new

local CFG={Name="Lua",Version="v5.4.3",Bg=c3hex("#0B0B0F"),Sidebar=c3hex("#0A0A0D"),Card=c3hex("#15151C"),CardHover=c3hex("#1F1F28"),Field=c3hex("#121218"),Purple=c3hex("#B24CFF"),PurpleSoft=c3hex("#9B5BC8"),Red=c3rgb(255,90,110),Text=c3hex("#EEE8F4"),SubText=c3hex("#BEB8C4"),Stroke=c3hex("#2A2A35"),CardHoverBorder=c3hex("#4A2A5E"),IconBg=c3hex("#23232C"),BgButton=c3hex("#23232C"),BgTrack=c3hex("#1E1E26"),NavActive=c3hex("#1F1F28"),AvatarBg=c3hex("#23232C"),DangerBg=c3hex("#3C1420"),DangerText=c3hex("#FF8CA0"),PopupBg=c3hex("#15151C"),ModalOverlay=c3hex("#000000"),MinW=320,MinH=360,MLW=.80,MLH=.86,MPW=.90,MPH=.68,TWR=.84,THR=.82,PartCount=22,ToggleKey=Enum.KeyCode.RightShift,NotifyDur=4,MaxNotify=6,Debug=false,ErrorMode="Notify",NotifyDedupeWindow=1.2,ButtonCooldown=.18,BaseSize=nil,LogoId="104650551286971",CornerRadius=15,Fullscreen=false,TextSizeMin=11,TextSizeMax=28,MaxTweenDur=10}
local IMA={FPS="88339611171447",Ping="126112532632455",Home="107671250314081",Keybind="126112532632455",Lua="104650551286971"}

-- Tema normalizado: os campos públicos seguem a estrutura Accent/Background/Outline/Text/Placeholder/Button/Icon,
-- enquanto os aliases antigos continuam existindo para manter compatibilidade com a API v5.x.
local function MakeTheme(bg,sidebar,card,hover,field,accent,accentSoft,text,sub,stroke,icon,particle,dangerBg,dangerText,overlay)
    local Background=c3hex(bg)
    if overlay==nil then
        local r,g,b=Background.R,Background.G,Background.B
        local lum=.2126*r+.7152*g+.0722*b
        overlay=lum>.55 and "#111318" or "#000000"
    end
    local Panel=c3hex(card)
    local Button=c3hex(icon)
    local Accent=c3hex(accent)
    local Outline=c3hex(stroke)
    local Text=c3hex(text)
    local Placeholder=c3hex(sub)
    local Icon=c3hex(icon)
    return {
        E="●",
        -- Estrutura de tema compatível com o modelo WindUI/Obsidian-like
        Accent=Accent, Background=Background, Outline=Outline, Text=Text, Placeholder=Placeholder, Button=Button, Icon=Icon,
        -- Superfícies
        Bg=Background, Sidebar=c3hex(sidebar), Card=Panel, CardHover=c3hex(hover), Field=c3hex(field),
        -- Aliases LuaInterface legados
        Purple=Accent, PurpleSoft=c3hex(accentSoft), SubText=Placeholder, Stroke=Outline,
        CardHoverBorder=Accent, IconBg=Icon, BgButton=Button, BgTrack=c3hex(field), NavActive=c3hex(hover),
        PopupBg=Panel, DangerBg=c3hex(dangerBg), DangerText=c3hex(dangerText), AvatarBg=Icon, ModalOverlay=c3hex(overlay),
        PColor=c3hex(particle or accent), PTmin=.35, PTmax=.78
    }
end

local Themes={
    -- Dark: quase preto, superfícies cinza escuro, accent cinza-claro.
    ["Dark"]=MakeTheme("#101114","#0B0C0F","#181A1F","#22252B","#14161A","#B8BDC7","#D0D4DB","#F2F4F7","#A7ADB7","#30343B","#25292F","#C5CAD2","#3A1820","#FF9AAA"),
    -- Light: branco, superfícies muito claras, accent cinza/azul.
    ["Light"]=MakeTheme("#F7F8FA","#FFFFFF","#FFFFFF","#EEF1F5","#F1F3F6","#64748B","#7C8DA5","#171A21","#667085","#D9DEE7","#E8ECF2","#7C8798","#FCE9ED","#C73550","#111318"),
    -- Darker: preto/cinza mais profundo.
    ["Darker"]=MakeTheme("#08090B","#050608","#0D0F12","#15181D","#0A0C0F","#A0A6B0","#BDC2CA","#ECEEF2","#858C99","#20242B","#171A1F","#AAB0BA","#2A1017","#FF879C"),
    -- Amoled: preto absoluto com superfícies quase pretas.
    ["Amoled"]=MakeTheme("#000000","#000000","#050505","#0A0A0A","#030303","#FFFFFF","#DCDCDC","#FFFFFF","#A6A6A6","#1A1A1A","#0A0A0A","#E6E6E6","#260B12","#FF8AA0"),
    -- Rose
    ["Rose"]=MakeTheme("#110A0F","#0C070B","#1A0F16","#291620","#140B11","#E879A8","#FF9BC1","#FDECF4","#C9A9B7","#3A202C","#341A29","#F2A6C5","#40131F","#FF9FBA"),
    -- Indigo
    ["Indigo"]=MakeTheme("#0B0D17","#070911","#14182A","#202640","#0F1222","#7182FF","#94A0FF","#EEF0FF","#ADB5D4","#29304A","#202640","#A4AEFF","#351722","#FF98AB"),
    -- Blue
    ["Blue"]=MakeTheme("#081018","#050B12","#0E1B28","#16283A","#0A141F","#4EA7FF","#7BC1FF","#EAF5FF","#9EB6C9","#20384C","#16283A","#82C9FF","#351821","#FF98AB"),
    -- Green
    ["Green"]=MakeTheme("#08120D","#050C08","#0E1C14","#163023","#0A150F","#4ACF7F","#70E7A0","#EBFFF2","#A2C4AE","#21422E","#163023","#7BE39E","#38171E","#FF99AA"),
    -- Red
    ["Red"]=MakeTheme("#150A0B","#0D0607","#211012","#32171A","#190B0D","#F05A68","#FF7B88","#FFF0F1","#D0A5A9","#482126","#32171A","#FF858F","#50141D","#FFB0BA"),
    -- Purple
    ["Purple"]=MakeTheme("#100A18","#09050E","#1C1029","#2A1840","#140B1E","#B565F5","#D08CFF","#F7ECFF","#C3A9D3","#39234D","#2A1840","#D59CFF","#401426","#FF9FBA"),
    -- Mellowsi: suave, quente, pastel/lilás-rosado.
    ["Mellowsi"]=MakeTheme("#15121A","#0E0B12","#211B27","#302638","#18131E","#C58FBF","#D9AED5","#FFF3FB","#C8B4C8","#44364A","#302638","#D9B9D5","#4A1A2D","#FFAAC0"),
    -- Ocean
    ["Ocean"]=MakeTheme("#07131A","#040C11","#0C2029","#123442","#091A22","#38BDEB","#69D4F5","#E7FAFF","#9FC0C9","#1E4552","#123442","#75DDF7","#3A1820","#FF9AAA"),
    -- Amber
    ["Amber"]=MakeTheme("#130E08","#0B0804","#21150A","#34220E","#180F07","#F59E0B","#FFC45B","#FFF5E1","#D1B58B","#4D3517","#36220D","#FFD06A","#4A1919","#FFAAA0"),
    -- Emerald
    ["Emerald"]=MakeTheme("#07130F","#040C09","#0C2118","#12382A","#091A13","#22C58B","#55E1B5","#E7FFF6","#9CC8B7","#1E4B3B","#12382A","#6DE7C0","#3B171E","#FF9CAB"),
    -- Violet
    ["Violet"]=MakeTheme("#0E0917","#08050E","#1B1029","#29183E","#120B1C","#9A6BFF","#B695FF","#F5EEFF","#BDAAD4","#37234D","#29183E","#C19BFF","#3F1427","#FF9FBC")
}


-- v5.1.4: ActiveTweens adicionado ao ST (não é local novo do chunk)
local ST={CurrentMode="Desktop",CurrentPage=nil,MainVisible=true,Pages={},Buttons={},ButtonIcons={},toggleToken=0,Conns=setmetatable({}, {__mode="k"}),ConnCount=0,ButtonLowerNames={},TweenInfoCache={},TweenInfoCacheCount=0,ActiveNotif={},ActiveCount=0,Elements={},ElementOrder={},CustomSize=nil,Resizing=false,OpenPopup=nil,OpenDropdown=nil,ActiveDialog=nil,FirstLayout=true,ScrollScheduled=false,RespScheduled=false,UserMoved=false,LastDragTime=0,PageToken=0,CurrentTheme="Dark",PColor=c3hex("#DDDDDD"),PTmin=.35,PTmax=.78,Themed={},ThemeHooks={},Tasks={},ThemeToken=0,Dragging=false,LastTabChange=0,State="Ready",Destroyed=false,Errors={},ErrorSeq=0,Keybinds={},ListeningKeybind=nil,ForceCheckbox=false,Scale=1,Language="en-US",Locales={},Plugins={},Loading=nil,
PageScrolls={},
Tabboxes={},
Groupboxes={},
DependencyRefreshers={},
LastResizeMode="",
ActiveTweens=setmetatable({}, {__mode="k"}),
Window={Title="Lua",Footer="",Position=nil,Size=nil,Center=true,AutoShow=true,ToggleKeybind=nil,NotifySide="Right",ShowCustomCursor=true,AlwaysOnTop=false,Font=Enum.Font.GothamMedium,CornerRadius=15,Icon=nil,IconSize=30,BackgroundImage=nil,Resizable=true,ShowMobileButtons=true,MobileButtonsSide="Right",DisableSearch=false,SearchbarSize=nil,GlobalSearch=false,UnlockMouseWhileOpen=true,EnableSidebarResize=false,EnableCompacting=true,DisableCompactingSnap=false,SidebarCompacted=false,MinContainerWidth=256,MinSidebarWidth=128,SidebarCompactWidth=48,SidebarCollapseThreshold=.5,CompactWidthActivation=128,Snapping=false,SnapDistance=28,SnapMargin=8,SnapAvoidCoreGui=true,Animations={ToggleWindow=true,TabSwitch=true,Groupbox=true,Dropdown=true,KeyPicker=true},TabTransitionTime=.22,TabSwipeOffset=26,TabSwipeFrom="bottom",TabButtonsStyle={Gap=0,Padding=0,CornerRadius=0,Indicator=false,IndicatorWidth=2,IndicatorHeight=20},SidebarWidth=nil,LastExpandedSidebarWidth=nil,FullscreenSaved=nil},
}

local UI={}
local SetTab

-- ============================================================
-- v5.2.0: Reliability / Error / Lifecycle layer
-- ============================================================
local LuaNotify

local function RecordError(source,err,trace)
    ST.ErrorSeq=ST.ErrorSeq+1
    local e={Id=ST.ErrorSeq,Time=os.clock(),Source=ts(source or "Unknown"),Message=ts(err or "Unknown error"),Traceback=ts(trace or err or "Unknown error")}
    ST.Errors[#ST.Errors+1]=e
    while #ST.Errors>50 do trem(ST.Errors,1) end
    if CFG.Debug then warn("[LuaInterface]["..e.Source.."] "..e.Message.."\n"..e.Traceback) end
    return e
end

local function SafeCall(source,fn,...)
    if type(fn)~="function" then return true end
    if ST.Destroyed then return false,"LuaInterface destroyed" end
    local ok,a,b,c,d,e=xpcall(fn,debug.traceback,...)
    if ok then return true,a,b,c,d,e end
    local rec=RecordError(source,a,a)
    if CFG.ErrorMode=="Notify" and LuaNotify then
        pcall(function() LuaNotify({Type="Error",Title="LuaInterface",Content=ts(source)..": "..ts(a),Duration=5,DedupeKey="ERR:"..ts(source)}) end)
    elseif CFG.ErrorMode=="Warn" then
        warn("[LuaInterface] "..ts(source)..": "..ts(a))
    elseif CFG.ErrorMode=="Custom" and type(ST.ErrorHandler)=="function" then
        pcall(ST.ErrorHandler,rec)
    end
    return false,a,rec
end

local function ValidState()
    return not ST.Destroyed and ST.State~="Destroying" and UI.Gui~=nil and UI.Gui.Parent~=nil
end

local function Tk(c) if not c then return c end ST.Conns[c]=true return c end
local function TrackTask(t)
    if not t then return t end
    for i=#ST.Tasks,1,-1 do
        local old=ST.Tasks[i]
        if not old or coroutine.status(old)=="dead" then table.remove(ST.Tasks,i) end
    end
    ST.Tasks[#ST.Tasks+1]=t
    return t
end
local function RegT(o,p,k)
    if not o or not k then return end
    local l=ST.Themed[k]
    if not l then
        l=setmetatable({}, {__mode="k"})
        ST.Themed[k]=l
    end
    l[o]=p
end
local function Reg(o,p1,k1,p2,k2,p3,k3)
    RegT(o,p1,k1)
    if p2 then RegT(o,p2,k2) end
    if p3 then RegT(o,p3,k3) end
    return o
end
local function AfterT(fn) ST.ThemeHooks[#ST.ThemeHooks+1]=fn end
local function CleanHooks()
    local w=1
    for i=1,#ST.ThemeHooks do
        local fn=ST.ThemeHooks[i]
        if fn then ST.ThemeHooks[w]=fn w=w+1 end
    end
    for i=w,#ST.ThemeHooks do ST.ThemeHooks[i]=nil end
end

local function ClampTextSize(sz)
    if not sz then return 14 end
    return cl(fl(sz),CFG.TextSizeMin,CFG.TextSizeMax)
end

local function SaveScrolls()
    if not ST.CurrentPage or not UI.PageC then return end
    ST.PageScrolls[ST.CurrentPage]=UI.PageC.CanvasPosition.Y
end
local function RestoreScroll(Nm)
    if not UI.PageC then return end
    local y=ST.PageScrolls[Nm] or 0
    task.defer(function()
        if not UI.PageC or not UI.PageC.Parent then return end
        local ok,cY=pcall(function() return UI.PageC.AbsoluteCanvasSize.Y end)
        if ok and cY then
            local maxY=ma(0,cY-UI.PageC.AbsoluteSize.Y)
            UI.PageC.CanvasPosition=V2(0,cl(y,0,maxY))
        else
            UI.PageC.CanvasPosition=V2(0,y)
        end
    end)
end

local function CloseDropdowns()
    if ST.OpenDropdown then
        pcall(function() ST.OpenDropdown:Destroy() end)
        ST.OpenDropdown=nil
    end
    if ST.OpenPopup then
        pcall(function() ST.OpenPopup:Destroy() end)
        ST.OpenPopup=nil
    end
end

local function SyncState()
    if not UI or not UI.Main then return end
    if ST.CurrentPage and ST.Pages[ST.CurrentPage] then
        for PN,Pg in pairs(ST.Pages) do
            if Pg and Pg.Parent then
                Pg.Visible=(PN==ST.CurrentPage)
            end
        end
    end
    if ST.ActiveDialog and not ST.ActiveDialog._alive then
        ST.ActiveDialog=nil
    end
    if ST.OpenDropdown and not ST.OpenDropdown.Parent then
        ST.OpenDropdown=nil
    end
    if ST.OpenPopup and not ST.OpenPopup.Parent then
        ST.OpenPopup=nil
    end
    local w=1
    for i=1,#ST.ActiveNotif do
        local n=ST.ActiveNotif[i]
        if n and n._alive then
            ST.ActiveNotif[w]=n w=w+1
        end
    end
    for i=w,#ST.ActiveNotif do ST.ActiveNotif[i]=nil end
    ST.ActiveCount=w-1
end

local function ApplyTheme(name)
    local t=Themes[name]
    if not t then
        RecordError("Theme", "Tema inválido: "..ts(name), "Tema inválido")
        name="Dark"
        t=Themes[name]
    end
    if not t then return end
    ST.ThemeToken=ST.ThemeToken+1
    local token=ST.ThemeToken
    ST.CurrentTheme=name
    for k,v in pairs(t) do
        if k~="E" and k~="PColor" and k~="PTmin" and k~="PTmax" then CFG[k]=v end
    end
    -- Mantém os dois modelos de nomes sincronizados.
    CFG.Bg= t.Background or t.Bg
    CFG.Card= t.Card
    CFG.Stroke= t.Outline or t.Stroke
    CFG.Text= t.Text
    CFG.SubText= t.Placeholder or t.SubText
    CFG.Purple= t.Accent or t.Purple
    CFG.BgButton= t.Button or t.BgButton
    CFG.IconBg= t.Icon or t.IconBg
    ST.PColor=t.PColor or c3hex("#DDDDDD")
    ST.PTmin=t.PTmin or .35
    ST.PTmax=t.PTmax or .78
    for key,list in pairs(ST.Themed) do
        local clr=t[key]
        if clr then
            for obj,prop in pairs(list) do
                if obj and obj.Parent then
                    pcall(function() obj[prop]=clr end)
                end
            end
        end
    end
    for BN,tl in pairs(ST.ButtonIcons) do
        local active=(BN==ST.CurrentPage)
        local cc=active and CFG.Purple or CFG.SubText
        if tl then
            for i=1,#tl do
                local d=tl[i]
                if d and d.Parent then
                    local n=d.Name
                    if n=="IconLine" or n=="IconDot" then d.BackgroundColor3=cc
                    elseif n=="IconStroke" then d.Color=cc
                    elseif d:IsA("ImageLabel") then d.ImageColor3=cc end
                end
            end
        end
    end
    if ST.Framework and ST.Framework.IconInstances then
        for icon,rec in pairs(ST.Framework.IconInstances) do
            if icon and icon.Parent and rec then
                local cc=rec.ThemeKey and CFG[rec.ThemeKey]
                if typeof(cc)~="Color3" then cc=rec.Color or CFG.SubText end
                pcall(function()
                    if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then icon.ImageColor3=cc end
                    IC.T(icon,cc)
                end)
            end
        end
    end
    if UI and UI.Particles then
        local w=1
        for i=1,#UI.Particles do
            local p=UI.Particles[i]
            if p and p.Object and p.Object.Parent then
                p.Object.BackgroundColor3=ST.PColor
                UI.Particles[w]=p w=w+1
            end
        end
        for i=w,#UI.Particles do UI.Particles[i]=nil end
    end
    for i=1,#ST.ThemeHooks do
        if token==ST.ThemeToken then
            pcall(ST.ThemeHooks[i])
        end
    end
end

-- ============================================================
-- v5.1.4: TweenManager central
-- ============================================================
local FT={}
-- FT.T(obj, props, dur, style, dir, key)
-- key: string opcional. Se omitido, deriva das propriedades
--      (ordenadas alfabeticamente). Tweens com mesma key no
--      mesmo objeto cancelam-se mutuamente.
function FT.GetTweenInfo(d,s,dir)
    if ST.TweenInfoCacheCount and ST.TweenInfoCacheCount>=512 then
        ST.TweenInfoCache={}
        ST.TweenInfoCacheCount=0
    end
    local a=ST.TweenInfoCache[s]
    if not a then a={}; ST.TweenInfoCache[s]=a end
    local b=a[dir]
    if not b then b={}; a[dir]=b end
    local ti=b[d]
    if not ti then ti=TweenInfo.new(d,s,dir); b[d]=ti; ST.TweenInfoCacheCount=(ST.TweenInfoCacheCount or 0)+1 end
    return ti
end
function FT.T(o,p,d,s,dir,key)
    if not o or not o.Parent then return end
    if ty(p)~="table" then return end
    -- valida se p tem ao menos uma propriedade
    local hasProp=false
    for _ in pairs(p) do hasProp=true break end
    if not hasProp then return end
    -- valida TweenInfo
    local dur=tn(d)
    if not dur or dur<0 then dur=.22 end
    if dur>CFG.MaxTweenDur then dur=CFG.MaxTweenDur end
    if ty(s)~="EnumItem" then s=Enum.EasingStyle.Quint end
    if ty(dir)~="EnumItem" then dir=Enum.EasingDirection.Out end
    -- key padrão = propriedades ordenadas
    if not key then
        local parts={}
        for k in pairs(p) do parts[#parts+1]=k end
        table.sort(parts)
        key=table.concat(parts,",")
    end
    -- cancelar tween anterior da mesma key
    local bucket=ST.ActiveTweens[o]
    if not bucket then
        bucket={}
        ST.ActiveTweens[o]=bucket
        if o.Destroying then
            bucket._DestroyConn=o.Destroying:Connect(function() FT.ClearTweens(o) end)
        end
    end
    local old=bucket[key]
    if old then
        bucket[key]=nil
        pcall(function() old:Cancel() end)
        if ST.ActiveTweens[o]~=bucket then ST.ActiveTweens[o]=bucket end
        if not bucket._DestroyConn then
            pcall(function() bucket._DestroyConn=o.Destroying:Connect(function() FT.ClearTweens(o) end) end)
        end
    end
    -- criar tween com fallback direto; TweenInfo é cacheado
    local ok,tw=pcall(function()
        return S.T:Create(o,FT.GetTweenInfo(dur,s,dir),p)
    end)
    if not ok or not tw then
        pcall(function()
            for k,v in pairs(p) do o[k]=v end
        end)
        bucket[key]=nil
        if next(bucket)==nil then ST.ActiveTweens[o]=nil end
        return nil
    end
    bucket[key]=tw
    -- Completed com validação de tween atual
    tw.Completed:Connect(function()
        local b2=ST.ActiveTweens[o]
        if b2 and b2[key]==tw then
            b2[key]=nil
            local empty=true
            for k in pairs(b2) do if k~="_DestroyConn" then empty=false break end end
            if empty then
                if b2._DestroyConn then pcall(function() b2._DestroyConn:Disconnect() end) end
                ST.ActiveTweens[o]=nil
            end
        end
    end)
    tw:Play()
    return tw
end
function FT.ClearTweens(o)
    if not o then return end
    local bucket=ST.ActiveTweens[o]
    if not bucket then return end
    for k,tw in pairs(bucket) do
        if k~="_DestroyConn" then pcall(function() tw:Cancel() end) end
    end
    if bucket._DestroyConn then pcall(function() bucket._DestroyConn:Disconnect() end) end
    ST.ActiveTweens[o]=nil
end
function FT.C(o,r)
    if not o then return nil end
    local c=o:FindFirstChildOfClass("UICorner")
    if not c then c=I("UICorner") end
    c.CornerRadius=Un(0,r or 10)
    c.Parent=o
    return c
end
function FT.S(o,c,t) if not o then return nil end local s=o:FindFirstChildOfClass("UIStroke") if not s then s=I("UIStroke") end s.Color=c or CFG.Stroke s.Thickness=t or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=o return s end
function FT.L(p,tx,sz,cl)
    local o=I("TextLabel")
    o.BackgroundTransparency=1
    o.Text=tx or""
    o.TextSize=ClampTextSize(sz or 14)
    o.Font=Enum.Font.GothamMedium
    o.TextColor3=cl or CFG.Text
    o.TextXAlignment=Enum.TextXAlignment.Left
    o.TextYAlignment=Enum.TextYAlignment.Center
    o.TextWrapped=true
    o.Parent=p
    return o
end
local function ValidParent(p)
    if not p then return false end
    local ok=p:IsA("GuiObject")
    return ok
end
function FT.Card(parent,h)
    if not ValidParent(parent) then return nil,nil end
    local F=I("Frame")
    F.BackgroundColor3=CFG.Card
    F.BorderSizePixel=0
    F.Size=U2(1,0,0,h or 50)
    F.BackgroundTransparency=1
    F.Parent=parent
    FT.C(F,10)
    local st=FT.S(F,CFG.Stroke,1)
    st.Transparency=1
    Reg(F,"BackgroundColor3","Card")
    Reg(st,"Color","Stroke")
    task.delay(.05,function()
        if not F.Parent then return end
        FT.T(F,{BackgroundTransparency=0},.3,"__Card")
        FT.T(st,{Transparency=0},.3,"__Card")
    end)
    return F,st
end
function FT.H(F,st)
    if not F then return end
    Tk(F.MouseEnter:Connect(function()
        FT.T(F,{BackgroundColor3=CFG.CardHover},.18)
        if st then FT.T(st,{Color=CFG.Purple},.18) end
    end))
    Tk(F.MouseLeave:Connect(function()
        FT.T(F,{BackgroundColor3=CFG.Card},.18)
        if st then FT.T(st,{Color=CFG.Stroke},.18) end
    end))
end

local IC={}
local function IL(p,t,x1,y1,x2,y2)
    local dx,dy=x2-x1,y2-y1
    local l=sq(dx*dx+dy*dy)
    if l<.001 then return end
    local f=I("Frame")
    f.Name="IconLine"
    f.BackgroundColor3=WH
    f.BorderSizePixel=0
    f.AnchorPoint=V2(.5,.5)
    f.Position=U3(ro((x1+x2)*.5),ro((y1+y2)*.5))
    f.Size=U3(ma(1,ro(l)),ma(1,ro(t)))
    f.Rotation=dg(at(dy,dx))
    f.Parent=p
    return f
end
local function IR(p,t,x,y,w,h,r)
    local f=I("Frame")
    f.Name="IconRect"
    f.BackgroundTransparency=1
    f.BorderSizePixel=0
    f.Position=U3(ro(x),ro(y))
    f.Size=U3(ro(w),ro(h))
    f.Parent=p
    local c=I("UICorner") c.CornerRadius=Un(0,r or 0) c.Parent=f
    local s=I("UIStroke") s.Name="IconStroke" s.Color=WH s.Thickness=t s.Parent=f
    return f
end
local function ID(p,cx,cy,d)
    local f=I("Frame")
    f.Name="IconDot"
    f.BackgroundColor3=WH
    f.BorderSizePixel=0
    f.AnchorPoint=V2(.5,.5)
    f.Position=U3(ro(cx),ro(cy))
    local di=ma(1,ro(d))
    f.Size=U3(di,di)
    f.Parent=p
    local c=I("UICorner") c.CornerRadius=Un(1,0) c.Parent=f
    return f
end
local function ICo(p,sz) local c=I("Frame") c.Name="VectorIcon" c.BackgroundTransparency=1 c.Size=U3(sz,sz) c.Parent=p return c end

function IC.Home(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,2*s,10*s,12*s,2*s) IL(c,t,12*s,2*s,22*s,10*s)
    IL(c,t,4.5*s,9.5*s,4.5*s,21*s) IL(c,t,19.5*s,9.5*s,19.5*s,21*s)
    IL(c,t,4.5*s,21*s,19.5*s,21*s) IL(c,t,9*s,21*s,9*s,14*s)
    IL(c,t,15*s,21*s,15*s,14*s) IL(c,t,9*s,14*s,15*s,14*s)
    return c
end
function IC.Bell(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,12*s,2.5*s,12*s,5*s) IR(c,t,5*s,4.5*s,14*s,12.5*s,7*s)
    IL(c,t,3*s,17*s,21*s,17*s) ID(c,12*s,20*s,2.4*s)
    return c
end
function IC.Alert(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,12*s,3*s,2*s,19.5*s) IL(c,t,12*s,3*s,22*s,19.5*s)
    IL(c,t,2*s,19.5*s,22*s,19.5*s) IL(c,t,12*s,10*s,12*s,14*s)
    ID(c,12*s,17*s,t*1.6)
    return c
end
function IC.Activity(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.6,sz*.1)
    IL(c,t,2*s,12*s,6*s,12*s) IL(c,t,6*s,12*s,9*s,3*s)
    IL(c,t,9*s,3*s,15*s,21*s) IL(c,t,15*s,21*s,18*s,12*s)
    IL(c,t,18*s,12*s,22*s,12*s)
    return c
end
function IC.User(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    local h=I("Frame") h.Name="IconRect" h.BackgroundTransparency=1 h.AnchorPoint=V2(.5,.5)
    h.Position=U3(ro(12*s),ro(8*s)) h.Size=U3(ro(9*s),ro(9*s)) h.Parent=c
    local hc=I("UICorner") hc.CornerRadius=Un(1,0) hc.Parent=h
    local hs=I("UIStroke") hs.Name="IconStroke" hs.Color=WH hs.Thickness=t hs.Parent=h
    local b=I("Frame") b.Name="IconRect" b.BackgroundTransparency=1 b.AnchorPoint=V2(.5,1)
    b.Position=U3(ro(12*s),ro(21*s)) b.Size=U3(ro(16*s),ro(10*s)) b.Parent=c
    local bc=I("UICorner") bc.CornerRadius=Un(.5,0) bc.Parent=b
    local bs=I("UIStroke") bs.Name="IconStroke" bs.Color=WH bs.Thickness=t bs.Parent=b
    return c
end
function IC.Keyboard(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.2,sz*.07)
    IR(c,t,2*s,6*s,20*s,12*s,3.5*s)
    local d=1.1*s*2
    ID(c,6.5*s,10*s,d) ID(c,10*s,10*s,d) ID(c,13.5*s,10*s,d) ID(c,17*s,10*s,d)
    IL(c,t*.9,9*s,14.5*s,15*s,14.5*s)
    return c
end
function IC.Ping(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    ID(c,5*s,19*s,t*2.2)
    IL(c,t,3.2*s,13*s,10.5*s,20.2*s)
    IL(c,t,3.2*s,8*s,15.5*s,20.2*s)
    IL(c,t,3.2*s,3*s,20.5*s,20.2*s)
    return c
end
function IC.Server(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,2*s,3.5*s,20*s,17*s,3*s) IL(c,t,2*s,12*s,22*s,12*s)
    ID(c,6.5*s,7.75*s,t*1.6) IL(c,t,12*s,7.75*s,18*s,7.75*s)
    ID(c,6.5*s,16.25*s,t*1.6) IL(c,t,12*s,16.25*s,18*s,16.25*s)
    return c
end
function IC.Save(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,3*s,18*s,18*s,2.5*s)
    IR(c,t,7*s,3*s,10*s,5*s,1*s)
    IR(c,t,7*s,13*s,10*s,8*s,1*s)
    return c
end
function IC.Settings(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.2,sz*.07)
    local i=I("Frame") i.Name="IconRect" i.BackgroundTransparency=1 i.AnchorPoint=V2(.5,.5)
    i.Position=U3(ro(12*s),ro(12*s)) i.Size=U3(ro(5.5*s),ro(5.5*s)) i.Parent=c
    local ic=I("UICorner") ic.CornerRadius=Un(1,0) ic.Parent=i
    local ist=I("UIStroke") ist.Name="IconStroke" ist.Color=WH ist.Thickness=t ist.Parent=i
    local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.AnchorPoint=V2(.5,.5)
    o.Position=U3(ro(12*s),ro(12*s)) o.Size=U3(ro(13*s),ro(13*s)) o.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(1,0) oc.Parent=o
    local ost=I("UIStroke") ost.Name="IconStroke" ost.Color=WH ost.Thickness=t ost.Parent=o
    for k=0,7 do
        local a=rd(k*45) local ca,sa=cs(a),sn(a)
        IL(c,t,12*s+ca*8*s,12*s+sa*8*s,12*s+ca*11*s,12*s+sa*11*s)
    end
    return c
end
function IC.Info(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IR(c,t,2*s,2*s,20*s,20*s,10*s)
    IL(c,t,12*s,11*s,12*s,17*s) ID(c,12*s,8*s,t*1.6)
    return c
end
function IC.Trash(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IL(c,t,3*s,6*s,21*s,6*s) IL(c,t,8*s,6*s,8*s,21*s)
    IL(c,t,16*s,6*s,16*s,21*s) IL(c,t,8*s,21*s,16*s,21*s)
    IL(c,t,10*s,3*s,14*s,3*s)
    return c
end
function IC.ArrowR(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,4*s,12*s,19*s,12*s)
    IL(c,t,13*s,6*s,19*s,12*s)
    IL(c,t,13*s,18*s,19*s,12*s)
    return c
end
function IC.X(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,6*s,6*s,18*s,18*s)
    IL(c,t,6*s,18*s,18*s,6*s)
    return c
end
function IC.Moon(p,sz)
    local c=ICo(p,sz)
    local s,t=sz/24,ma(1.4,sz*.08)
    local outer=I("Frame") outer.Name="IconRect" outer.BackgroundColor3=WH outer.BorderSizePixel=0
    outer.AnchorPoint=V2(.5,.5) outer.Position=U3(ro(12*s),ro(12*s))
    outer.Size=U3(ro(18*s),ro(18*s)) outer.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(1,0) oc.Parent=outer
    local inner=I("Frame") inner.Name="MoonCutout" inner.BackgroundColor3=CFG.Sidebar inner.BorderSizePixel=0
    inner.AnchorPoint=V2(.5,.5) inner.Position=U3(ro(16*s),ro(9*s))
    inner.Size=U3(ro(16*s),ro(16*s)) inner.Parent=c
    local ic=I("UICorner") ic.CornerRadius=Un(1,0) ic.Parent=inner
    Reg(inner,"BackgroundColor3","Sidebar")
    return c
end
function IC.Dots(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.1)
    ID(c,7*s,12*s,t*1.5) ID(c,12*s,12*s,t*1.5) ID(c,17*s,12*s,t*1.5)
    return c
end


-- Built-in vector icon pack. These are rendered from Roblox UI primitives so the
-- library does not depend on one ImageLabel/asset per icon. The IconManager below
-- also accepts asset-backed icons for packs supplied by users.
function IC.Plus(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,12*s,4*s,12*s,20*s) IL(c,t,4*s,12*s,20*s,12*s) return c
end
function IC.Minus(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,4*s,12*s,20*s,12*s) return c
end
function IC.Check(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,4*s,12*s,10*s,18*s) IL(c,t,10*s,18*s,21*s,6*s) return c
end
function IC.Search(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.075)
    local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.Position=U3(ro(3*s),ro(3*s)) o.Size=U3(ro(13*s),ro(13*s)) o.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(1,0) oc.Parent=o
    local os=I("UIStroke") os.Name="IconStroke" os.Color=WH os.Thickness=t os.Parent=o
    IL(c,t,15*s,15*s,21*s,21*s) return c
end
function IC.Menu(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,4*s,6*s,20*s,6*s) IL(c,t,4*s,12*s,20*s,12*s) IL(c,t,4*s,18*s,20*s,18*s) return c
end
function IC.Eye(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.AnchorPoint=V2(.5,.5) o.Position=U3(ro(12*s),ro(12*s)) o.Size=U3(ro(18*s),ro(11*s)) o.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(.5,0) oc.Parent=o
    local os=I("UIStroke") os.Name="IconStroke" os.Color=WH os.Thickness=t os.Parent=o
    ID(c,12*s,12*s,4.5*s) return c
end
function IC.EyeOff(p,sz)
    local c=IC.Eye(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,4*s,4*s,20*s,20*s) return c
end
function IC.Shield(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    local f=I("Frame") f.Name="IconRect" f.BackgroundTransparency=1 f.AnchorPoint=V2(.5,.5) f.Position=U3(ro(12*s),ro(12*s)) f.Size=U3(ro(16*s),ro(19*s)) f.Parent=c
    local fc=I("UICorner") fc.CornerRadius=Un(.22,0) fc.Parent=f
    local fs=I("UIStroke") fs.Name="IconStroke" fs.Color=WH fs.Thickness=t fs.Parent=f
    IL(c,t,12*s,5*s,12*s,19*s) return c
end
function IC.Sword(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,5*s,19*s,19*s,5*s) IL(c,t,16*s,4*s,20*s,8*s) IL(c,t,4*s,16*s,8*s,20*s) IL(c,t,7*s,17*s,10*s,20*s) return c
end
function IC.Swords(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.07)
    IL(c,t,5*s,19*s,17*s,5*s) IL(c,t,14*s,4*s,20*s,10*s) IL(c,t,4*s,14*s,10*s,20*s)
    IL(c,t,7*s,5*s,19*s,17*s) IL(c,t,17*s,14*s,20*s,17*s) IL(c,t,5*s,4*s,8*s,7*s) return c
end
function IC.Target(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.07)
    for d in {18,11,4} do
        local f=I("Frame") f.Name="IconRect" f.BackgroundTransparency=1 f.AnchorPoint=V2(.5,.5) f.Position=U3(ro(12*s),ro(12*s)) f.Size=U3(ro(d*s),ro(d*s)) f.Parent=c
        local fc=I("UICorner") fc.CornerRadius=Un(1,0) fc.Parent=f
        local fs=I("UIStroke") fs.Name="IconStroke" fs.Color=WH fs.Thickness=t fs.Parent=f
    end
    return c
end
function IC.Crosshair(p,sz)
    local c=IC.Target(p,sz) local s,t=sz/24,ma(1.3,sz*.07)
    IL(c,t,12*s,2*s,12*s,7*s) IL(c,t,12*s,17*s,12*s,22*s) IL(c,t,2*s,12*s,7*s,12*s) IL(c,t,17*s,12*s,22*s,12*s) return c
end
function IC.Zap(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,13*s,2*s,5*s,13*s) IL(c,t,5*s,13*s,12*s,13*s) IL(c,t,12*s,13*s,10*s,22*s) IL(c,t,10*s,22*s,19*s,9*s) IL(c,t,19*s,9*s,13*s,9*s) return c
end
function IC.Play(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.07)
    local f=I("Frame") f.Name="IconRect" f.BackgroundTransparency=1 f.AnchorPoint=V2(.5,.5) f.Position=U3(ro(11*s),ro(12*s)) f.Size=U3(ro(16*s),ro(18*s)) f.Rotation=90 f.Parent=c
    local fc=I("UICorner") fc.CornerRadius=Un(.2,0) fc.Parent=f
    local fs=I("UIStroke") fs.Name="IconStroke" fs.Color=WH fs.Thickness=t fs.Parent=f return c
end
function IC.Pause(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,8*s,5*s,8*s,19*s) IL(c,t,16*s,5*s,16*s,19*s) return c
end
function IC.ChevronDown(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,5*s,9*s,12*s,16*s) IL(c,t,12*s,16*s,19*s,9*s) return c
end
function IC.ChevronUp(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,5*s,15*s,12*s,8*s) IL(c,t,12*s,8*s,19*s,15*s) return c
end
function IC.ChevronLeft(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,15*s,5*s,8*s,12*s) IL(c,t,8*s,12*s,15*s,19*s) return c
end
function IC.ChevronRight(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.4,sz*.08)
    IL(c,t,9*s,5*s,16*s,12*s) IL(c,t,16*s,12*s,9*s,19*s) return c
end
function IC.Refresh(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.Position=U3(ro(4*s),ro(4*s)) o.Size=U3(ro(16*s),ro(16*s)) o.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(1,0) oc.Parent=o
    local os=I("UIStroke") os.Name="IconStroke" os.Color=WH os.Thickness=t os.Parent=o
    IL(c,t,17*s,5*s,20*s,5*s) IL(c,t,20*s,5*s,20*s,8*s) return c
end
function IC.Download(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,12*s,3*s,12*s,16*s) IL(c,t,7*s,11*s,12*s,16*s) IL(c,t,17*s,11*s,12*s,16*s) IL(c,t,5*s,20*s,19*s,20*s) return c
end
function IC.Upload(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,12*s,21*s,12*s,8*s) IL(c,t,7*s,13*s,12*s,8*s) IL(c,t,17*s,13*s,12*s,8*s) IL(c,t,5*s,4*s,19*s,4*s) return c
end
function IC.Copy(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,7*s,7*s,13*s,14*s,2*s) IR(c,t,3*s,3*s,13*s,14*s,2*s) return c
end
function IC.Edit(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,5*s,19*s,18*s,6*s) IL(c,t,15*s,5*s,19*s,9*s) IL(c,t,4*s,20*s,9*s,19*s) return c
end
function IC.Folder(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,6*s,18*s,14*s,2*s) IL(c,t,4*s,6*s,9*s,6*s) return c
end
function IC.Lock(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,4*s,10*s,16*s,11*s,2*s) IR(c,t,8*s,4*s,8*s,9*s,4*s) return c
end
function IC.Unlock(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,4*s,10*s,16*s,11*s,2*s) IL(c,t,8*s,10*s,8*s,5*s) IL(c,t,8*s,5*s,14*s,5*s) return c
end
function IC.Star(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.25,sz*.07)
    IL(c,t,12*s,3*s,14.8*s,8.5*s) IL(c,t,14.8*s,8.5*s,21*s,9.2*s) IL(c,t,21*s,9.2*s,16.5*s,13.5*s) IL(c,t,16.5*s,13.5*s,17.8*s,20*s) IL(c,t,17.8*s,20*s,12*s,16.5*s) IL(c,t,12*s,16.5*s,6.2*s,20*s) IL(c,t,6.2*s,20*s,7.5*s,13.5*s) IL(c,t,7.5*s,13.5*s,3*s,9.2*s) IL(c,t,3*s,9.2*s,9.2*s,8.5*s) IL(c,t,9.2*s,8.5*s,12*s,3*s) return c
end
function IC.Heart(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.25,sz*.07)
    IL(c,t,12*s,20*s,4*s,10*s) IL(c,t,4*s,10*s,4*s,6*s) IL(c,t,4*s,6*s,8*s,4*s) IL(c,t,8*s,4*s,12*s,8*s) IL(c,t,12*s,8*s,16*s,4*s) IL(c,t,16*s,4*s,20*s,6*s) IL(c,t,20*s,6*s,20*s,10*s) IL(c,t,20*s,10*s,12*s,20*s) return c
end
function IC.Palette(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.AnchorPoint=V2(.5,.5) o.Position=U3(ro(12*s),ro(12*s)) o.Size=U3(ro(18*s),ro(16*s)) o.Parent=c
    local oc=I("UICorner") oc.CornerRadius=Un(.45,0) oc.Parent=o
    local os=I("UIStroke") os.Name="IconStroke" os.Color=WH os.Thickness=t os.Parent=o
    ID(c,7*s,9*s,2*s) ID(c,11*s,7*s,2*s) ID(c,16*s,8*s,2*s) ID(c,17*s,13*s,2*s) return c
end
function IC.Sliders(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IL(c,t,4*s,6*s,20*s,6*s) IL(c,t,4*s,12*s,20*s,12*s) IL(c,t,4*s,18*s,20*s,18*s)
    ID(c,9*s,6*s,3*s) ID(c,15*s,12*s,3*s) ID(c,11*s,18*s,3*s) return c
end
function IC.Filter(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,3*s,5*s,21*s,5*s) IL(c,t,6*s,11*s,18*s,11*s) IL(c,t,10*s,17*s,14*s,17*s) return c
end
function IC.List(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    for y=6,18,6 do ID(c,4*s,y*s,2*s) IL(c,t,8*s,y*s,20*s,y*s) end return c
end
function IC.Grid(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.07)
    for _,x in ipairs({3,13}) do for _,y in ipairs({3,13}) do IR(c,t,x*s,y*s,8*s,8*s,1.5*s) end end return c
end
function IC.Smartphone(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,6*s,2*s,12*s,20*s,2*s) ID(c,12*s,18.5*s,1.2*s) return c
end
function IC.Gamepad(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.25,sz*.07)
    IR(c,t,3*s,7*s,18*s,11*s,5*s) IL(c,t,7*s,12*s,11*s,12*s) IL(c,t,9*s,10*s,9*s,14*s) ID(c,17*s,10*s,1.5*s) ID(c,19*s,13*s,1.5*s) return c
end
function IC.Globe(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,3*s,18*s,18*s,9*s) IL(c,t,3*s,12*s,21*s,12*s) IL(c,t,12*s,3*s,12*s,21*s) return c
end
function IC.Clock(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,3*s,18*s,18*s,9*s) IL(c,t,12*s,7*s,12*s,12*s) IL(c,t,12*s,12*s,16*s,14*s) return c
end
function IC.Volume(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,9*s,5*s,6*s,1*s) IL(c,t,8*s,9*s,13*s,5*s) IL(c,t,8*s,15*s,13*s,19*s) IL(c,t,13*s,5*s,13*s,19*s) IL(c,t,16*s,8*s,20*s,16*s) return c
end
function IC.Mic(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,8*s,3*s,8*s,13*s,4*s) IL(c,t,4*s,12*s,4*s,15*s) IL(c,t,4*s,15*s,20*s,15*s) IL(c,t,12*s,15*s,12*s,20*s) return c
end
function IC.Trophy(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,7*s,3*s,10*s,12*s,2*s) IL(c,t,12*s,15*s,12*s,20*s) IL(c,t,8*s,20*s,16*s,20*s) IL(c,t,7*s,6*s,4*s,6*s) IL(c,t,4*s,6*s,4*s,12*s) IL(c,t,4*s,12*s,8*s,14*s) IL(c,t,17*s,6*s,20*s,6*s) IL(c,t,20*s,6*s,20*s,12*s) IL(c,t,20*s,12*s,16*s,14*s) return c
end
function IC.Users(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.25,sz*.07)
    ID(c,8*s,8*s,5*s) ID(c,17*s,9*s,4*s) IL(c,t,3*s,19*s,13*s,19*s) IL(c,t,13*s,19*s,13*s,15*s) IL(c,t,13*s,15*s,21*s,19*s) return c
end
function IC.Package(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,4*s,6*s,16*s,14*s,2*s) IL(c,t,4*s,6*s,12*s,11*s) IL(c,t,12*s,11*s,20*s,6*s) IL(c,t,12*s,11*s,12*s,20*s) return c
end
function IC.Database(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    for y in {6,12,18} do local o=I("Frame") o.Name="IconRect" o.BackgroundTransparency=1 o.AnchorPoint=V2(.5,.5) o.Position=U3(ro(12*s),ro(y*s)) o.Size=U3(ro(18*s),ro(6*s)) o.Parent=c local oc=I("UICorner") oc.CornerRadius=Un(.5,0) oc.Parent=o local os=I("UIStroke") os.Name="IconStroke" os.Color=WH os.Thickness=t os.Parent=o end return c
end
function IC.Code(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.35,sz*.075)
    IL(c,t,9*s,5*s,4*s,12*s) IL(c,t,4*s,12*s,9*s,19*s) IL(c,t,15*s,5*s,20*s,12*s) IL(c,t,20*s,12*s,15*s,19*s) IL(c,t,13*s,4*s,11*s,20*s) return c
end
function IC.Terminal(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,4*s,18*s,16*s,2*s) IL(c,t,7*s,9*s,10*s,12*s) IL(c,t,10*s,12*s,7*s,15*s) IL(c,t,13*s,16*s,18*s,16*s) return c
end
function IC.Help(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IR(c,t,3*s,3*s,18*s,18*s,9*s) IL(c,t,9*s,9*s,9*s,8*s) IL(c,t,9*s,8*s,12*s,6*s) IL(c,t,12*s,6*s,15*s,8*s) IL(c,t,15*s,8*s,15*s,10*s) IL(c,t,15*s,10*s,12*s,13*s) IL(c,t,12*s,13*s,12*s,15*s) ID(c,12*s,18*s,1.6*s) return c
end
function IC.Sparkles(p,sz)
    local c=ICo(p,sz) local s,t=sz/24,ma(1.3,sz*.075)
    IL(c,t,12*s,3*s,12*s,10*s) IL(c,t,9*s,6*s,15*s,6*s) IL(c,t,6*s,14*s,6*s,21*s) IL(c,t,3*s,17*s,9*s,17*s) IL(c,t,18*s,12*s,18*s,17*s) IL(c,t,16*s,14.5*s,20*s,14.5*s) return c
end

-- Inline SVG support for outline icon artwork. Roblox ImageLabels do not render raw
-- SVG markup, so this parser turns common SVG primitives and path commands into
-- native GuiObjects. Supported path commands: M/L/H/V/C/S/Q/T/A/Z (relative and
-- absolute), including elliptical arcs. This keeps icons
-- crisp, tintable, and independent of uploaded asset IDs.
function IC.SVG(parent,size,markup,options)
    if not parent or type(markup)~="string" or #markup==0 then return nil end
    options=options or {}
    size=tn(size) or 18
    local vbX,vbY,vbW,vbH=0,0,24,24
    local viewBox=sm(markup,"viewBox%s*=%s*['\"]([^'\"]+)")
    if viewBox then
        local values={}
        for token in string.gmatch(viewBox,"[%+%-]?[%d%.]+") do values[#values+1]=tn(token) end
        if #values>=4 and values[3] and values[4] and values[3]>0 and values[4]>0 then
            vbX,vbY,vbW,vbH=values[1],values[2],values[3],values[4]
        end
    end
    local scale=size/ma(vbW,vbH)
    local root=ICo(parent,size)
    root.Name=options.Name or "VectorIcon"
    local function coord(x,y)
        return (x-vbX)*scale,(y-vbY)*scale
    end
    local function line(x1,y1,x2,y2,width)
        local ax,ay=coord(x1,y1); local bx,by=coord(x2,y2)
        return IL(root,ma(1,width*scale),ax,ay,bx,by)
    end
    local function circle(cx,cy,r,width,fill)
        local x,y=coord(cx,cy); local d=ma(1,ro(r*2*scale))
        local f=I("Frame"); f.Name=fill and "IconDot" or "IconRect"; f.BorderSizePixel=0
        f.AnchorPoint=V2(.5,.5); f.Position=U3(ro(x),ro(y)); f.Size=U3(d,d); f.Parent=root
        local corner=I("UICorner"); corner.CornerRadius=Un(1,0); corner.Parent=f
        if not fill then local stroke=I("UIStroke"); stroke.Name="IconStroke"; stroke.Color=WH; stroke.Thickness=ma(1,width*scale); stroke.Parent=f end
        return f
    end
    local function attr(tag,key,default)
        local value=sm(tag,"%s"..key.."%s*=%s*['\"]([^'\"]*)['\"]")
        return value or default
    end
    local function numbers(text)
        local out={}
        for n in string.gmatch(text or "","[%+%-]?[%d%.]+[eE]?[%+%-]?%d*") do
            local v=tn(n); if v then out[#out+1]=v end
        end
        return out
    end
    local function path(d,width)
        local tokens={}; local i=1
        while i<=#d do
            local ch=string.sub(d,i,i)
            if string.match(ch,"%s") or ch=="," then i=i+1
            elseif string.match(ch,"[%a]") then tokens[#tokens+1]=ch; i=i+1
            else
                local tail=string.sub(d,i)
                local num=string.match(tail,"^[%+%-]?%d*%.?%d+")
                if not num then i=i+1
                else
                    local consumed=#num
                    local exp=string.sub(tail,consumed+1,consumed+1)
                    if exp=="e" or exp=="E" then
                        local expPart=string.match(string.sub(tail,consumed+1),"^[eE][%+%-]?%d+")
                        if expPart then num=num..expPart; consumed=consumed+#expPart end
                    end
                    tokens[#tokens+1]=tn(num); i=i+consumed
                end
            end
        end
        local idx=1; local cmd=nil; local x,y=0,0; local sx,sy=0,0; local lastC,lastQ=nil,nil
        local function hasnum() return type(tokens[idx])=="number" end
        local function take() local v=tokens[idx]; idx=idx+1; return v end
        local function absolute(px,py,relative) if relative then return x+px,y+py end return px,py end
        local function segment(nx,ny) line(x,y,nx,ny,width); x,y=nx,ny end
        local function arc(rx,ry,rotation,largeArc,sweepArc,ex,ey)
            rx,ry=math.abs(rx),math.abs(ry)
            if rx<.001 or ry<.001 or (math.abs(ex-x)<.001 and math.abs(ey-y)<.001) then segment(ex,ey); return end
            local phi=rd(rotation%360); local cp,sp=cs(phi),sn(phi)
            local dx=(x-ex)*.5; local dy=(y-ey)*.5
            local xp=cp*dx+sp*dy; local yp=-sp*dx+cp*dy
            local lambda=xp*xp/(rx*rx)+yp*yp/(ry*ry)
            if lambda>1 then local factor=sq(lambda); rx,ry=rx*factor,ry*factor end
            local numerator=ma(0,rx*rx*ry*ry-rx*rx*yp*yp-ry*ry*xp*xp)
            local denominator=rx*rx*yp*yp+ry*ry*xp*xp
            if denominator<.001 then segment(ex,ey); return end
            local sign=(largeArc==sweepArc) and -1 or 1
            local factor=sign*sq(numerator/denominator)
            local cxp=factor*(rx*yp/ry); local cyp=factor*(-ry*xp/rx)
            local cx=cp*cxp-sp*cyp+(x+ex)*.5
            local cy=sp*cxp+cp*cyp+(y+ey)*.5
            local ux=(xp-cxp)/rx; local uy=(yp-cyp)/ry
            local vx=(-xp-cxp)/rx; local vy=(-yp-cyp)/ry
            local startAngle=at(uy,ux)
            local delta=at(ux*vy-uy*vx,ux*vx+uy*vy)
            if not sweepArc and delta>0 then delta=delta-2*math.pi
            elseif sweepArc and delta<0 then delta=delta+2*math.pi end
            local steps=ma(4,math.ceil(math.abs(delta)*8))
            for step=1,steps do
                local a=startAngle+delta*step/steps
                local px=cx+rx*cs(a)*cp-ry*sn(a)*sp
                local py=cy+rx*cs(a)*sp+ry*sn(a)*cp
                if step==steps then px,py=ex,ey end
                segment(px,py)
            end
        end
        while idx<=#tokens do
            if type(tokens[idx])=="string" then
                cmd=take()
                if cmd=="Z" or cmd=="z" then segment(sx,sy); lastC,lastQ=nil,nil; cmd=nil end
            elseif not cmd then
                break
            end
            if cmd then
                local lower=string.lower(cmd); local rel=(cmd==lower)
                if lower=="m" or lower=="l" then
                    local first=true
                    while hasnum() do
                        if idx+1>#tokens or type(tokens[idx+1])~="number" then break end
                        local px,py=take(),take(); local nx,ny=absolute(px,py,rel)
                        if lower=="m" and first then x,y=nx,ny; sx,sy=nx,ny; first=false
                        else segment(nx,ny); first=false end
                        lastC,lastQ=nil,nil
                        if lower=="m" and not first then cmd=rel and "l" or "L"; rel=(cmd=="l") end
                    end
                elseif lower=="h" then
                    while hasnum() do local nx=take(); if rel then nx=x+nx end; segment(nx,y); lastC,lastQ=nil,nil end
                elseif lower=="v" then
                    while hasnum() do local ny=take(); if rel then ny=y+ny end; segment(x,ny); lastC,lastQ=nil,nil end
                elseif lower=="c" then
                    while hasnum() do
                        if idx+5>#tokens then break end
                        local a,b,c1,d1,e,f=take(),take(),take(),take(),take(),take()
                        local x0,y0=x,y; local cpx,cpy=absolute(a,b,rel); local c2x,c2y=absolute(c1,d1,rel); local ex,ey=absolute(e,f,rel)
                        for step=1,8 do local t=step/8; local u=1-t
                            local px=u*u*u*x0+3*u*u*t*cpx+3*u*t*t*c2x+t*t*t*ex
                            local py=u*u*u*y0+3*u*u*t*cpy+3*u*t*t*c2y+t*t*t*ey
                            segment(px,py)
                        end
                        lastC={c2x,c2y}; lastQ=nil
                    end
                elseif lower=="s" then
                    while hasnum() do
                        if idx+3>#tokens then break end
                        local a,b,c1,d1=take(),take(),take(),take(); local x0,y0=x,y
                        local cpx,cpy=x0,y0; if lastC then cpx=2*x0-lastC[1]; cpy=2*y0-lastC[2] end
                        local c2x,c2y=absolute(a,b,rel); local ex,ey=absolute(c1,d1,rel)
                        for step=1,8 do local t=step/8; local u=1-t
                            segment(u*u*u*x0+3*u*u*t*cpx+3*u*t*t*c2x+t*t*t*ex,u*u*u*y0+3*u*u*t*cpy+3*u*t*t*c2y+t*t*t*ey)
                        end
                        lastC={c2x,c2y}; lastQ=nil
                    end
                elseif lower=="q" or lower=="t" then
                    while hasnum() do
                        local x0,y0=x,y; local qx,qy,ex,ey
                        if lower=="q" then
                            if idx+3>#tokens then break end
                            local a,b,c1,d1=take(),take(),take(),take(); qx,qy=absolute(a,b,rel); ex,ey=absolute(c1,d1,rel)
                        else
                            if idx+1>#tokens then break end
                            local a,b=take(),take(); qx,qy=x0,y0; if lastQ then qx=2*x0-lastQ[1]; qy=2*y0-lastQ[2] end; ex,ey=absolute(a,b,rel)
                        end
                        for step=1,8 do local t=step/8; local u=1-t; segment(u*u*x0+2*u*t*qx+t*t*ex,u*u*y0+2*u*t*qy+t*t*ey) end
                        lastQ={qx,qy}; lastC=nil
                    end
                elseif lower=="a" then
                    while hasnum() do
                        if idx+6>#tokens then break end
                        local rx,ry,rotation,largeArc,sweepArc,ex,ey=take(),take(),take(),take(),take(),take(),take()
                        if rel then ex,ey=x+ex,y+ey end
                        arc(rx,ry,rotation,largeArc~=0,sweepArc~=0,ex,ey); lastC,lastQ=nil,nil
                    end
                else
                    cmd=nil
                end
            end
        end
    end
    local tagCount=0
    for tagName,tag in string.gmatch(markup,"<([%a][%w:_%-]*)(.-)>") do
        tagCount=tagCount+1
        if tagName=="path" then
            local d=attr(tag,"d",""); local stroke=attr(tag,"stroke","currentColor")
            if d~="" and stroke~="none" then path(d,tn(attr(tag,"stroke-width","2")) or 2) end
        elseif tagName=="line" then
            local stroke=attr(tag,"stroke","currentColor")
            if stroke~="none" then line(tn(attr(tag,"x1","0")) or 0,tn(attr(tag,"y1","0")) or 0,tn(attr(tag,"x2","0")) or 0,tn(attr(tag,"y2","0")) or 0,(tn(attr(tag,"stroke-width","2")) or 2)) end
        elseif tagName=="circle" then
            local stroke=attr(tag,"stroke","currentColor"); local fill=attr(tag,"fill","none")~="none"
            if stroke~="none" or fill then circle(tn(attr(tag,"cx","0")) or 0,tn(attr(tag,"cy","0")) or 0,tn(attr(tag,"r","0")) or 0,tn(attr(tag,"stroke-width","2")) or 2,fill) end
        elseif tagName=="rect" then
            local stroke=attr(tag,"stroke","currentColor"); local fill=attr(tag,"fill","none")~="none"
            if stroke~="none" or fill then
                local x0=tn(attr(tag,"x","0")) or 0; local y0=tn(attr(tag,"y","0")) or 0
                local w=tn(attr(tag,"width","0")) or 0; local h=tn(attr(tag,"height","0")) or 0
                local sw=tn(attr(tag,"stroke-width","2")) or 2
                if fill then local px,py=coord(x0+w/2,y0+h/2); local f=I("Frame"); f.Name="IconDot"; f.BorderSizePixel=0; f.Position=U3(ro(px-w*scale/2),ro(py-h*scale/2)); f.Size=U3(ro(w*scale),ro(h*scale)); f.Parent=root end
                if stroke~="none" then line(x0,y0,x0+w,y0,sw); line(x0+w,y0,x0+w,y0+h,sw); line(x0+w,y0+h,x0,y0+h,sw); line(x0,y0+h,x0,y0,sw) end
            end
        elseif tagName=="polyline" or tagName=="polygon" then
            local raw=attr(tag,"points",""); local pts=numbers(raw); local stroke=attr(tag,"stroke","currentColor")
            if #pts>=4 and stroke~="none" then
                for n=1,#pts-2,2 do line(pts[n],pts[n+1],pts[n+2],pts[n+3],tn(attr(tag,"stroke-width","2")) or 2) end
                if tagName=="polygon" then line(pts[#pts-1],pts[#pts],pts[1],pts[2],tn(attr(tag,"stroke-width","2")) or 2) end
            end
        end
    end
    if tagCount==0 or #root:GetChildren()==0 then root:Destroy(); return nil end
    return root
end

local SVGIcons={
    home='<svg viewBox="0 0 24 24"><path d="M3 10 L12 3 L21 10 V21 H14 V15 H10 V21 H3 Z"/></svg>',
    bell='<svg viewBox="0 0 24 24"><path d="M18 8 A6 6 0 0 0 6 8 C6 15 3 15 3 17 H21 C21 15 18 15 18 8 M10 21 H14"/></svg>',
    activity='<svg viewBox="0 0 24 24"><path d="M2 12 H6 L9 4 L15 20 L18 12 H22"/></svg>',
    user='<svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 21 C4 16 7 14 12 14 C17 14 20 16 20 21"/></svg>',
    keyboard='<svg viewBox="0 0 24 24"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M6 9 H6.1 M10 9 H10.1 M14 9 H14.1 M18 9 H18.1 M7 13 H17 M9 16 H15"/></svg>',
    server='<svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="8" rx="2"/><rect x="3" y="13" width="18" height="8" rx="2"/><path d="M7 7 H7.1 M7 17 H7.1 M11 7 H17 M11 17 H17"/></svg>',
    save='<svg viewBox="0 0 24 24"><path d="M4 3 H18 L21 6 V21 H3 V3 Z M7 3 V9 H16 V3 M7 21 V13 H17 V21"/></svg>',
    settings='<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15 A8 8 0 0 0 20 12 L22 10 L20 6 L17 7 A8 8 0 0 0 15 6 L14 3 H10 L9 6 A8 8 0 0 0 7 7 L4 6 L2 10 L4 12 A8 8 0 0 0 4.6 15 L3 18 L7 21 L9 19 A8 8 0 0 0 12 20 L14 22 L18 20 L17 17 Z"/></svg>',
    info='<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 11 V17 M12 7 H12.1"/></svg>',
    trash='<svg viewBox="0 0 24 24"><path d="M3 6 H21 M8 6 V4 H16 V6 M6 6 L7 21 H17 L18 6 M10 10 V17 M14 10 V17"/></svg>',
    ['arrow-right']='<svg viewBox="0 0 24 24"><path d="M5 12 H19 M12 5 L19 12 L12 19"/></svg>',
    x='<svg viewBox="0 0 24 24"><path d="M18 6 L6 18 M6 6 L18 18"/></svg>',
    alert='<svg viewBox="0 0 24 24"><path d="M12 3 L22 21 H2 Z M12 9 V14 M12 17 H12.1"/></svg>',
    ['alert-circle']='<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8 V13 M12 17 H12.1"/></svg>',
    search='<svg viewBox="0 0 24 24"><circle cx="10.8" cy="10.8" r="7.2"/><path d="M16 16 L21 21"/></svg>',
    menu='<svg viewBox="0 0 24 24"><path d="M4 6 H20 M4 12 H20 M4 18 H20"/></svg>',
    check='<svg viewBox="0 0 24 24"><path d="M4 12 L9 17 L20 6"/></svg>',
    plus='<svg viewBox="0 0 24 24"><path d="M12 5 V19 M5 12 H19"/></svg>',
    minus='<svg viewBox="0 0 24 24"><path d="M5 12 H19"/></svg>',
    ['chevron-down']='<svg viewBox="0 0 24 24"><path d="M5 9 L12 16 L19 9"/></svg>',
    ['chevron-up']='<svg viewBox="0 0 24 24"><path d="M5 15 L12 8 L19 15"/></svg>',
    ['chevron-left']='<svg viewBox="0 0 24 24"><path d="M15 5 L8 12 L15 19"/></svg>',
    ['chevron-right']='<svg viewBox="0 0 24 24"><path d="M9 5 L16 12 L9 19"/></svg>',
    refresh='<svg viewBox="0 0 24 24"><path d="M20 7 V3 L16 7 A8 8 0 1 0 20 13"/></svg>',
    download='<svg viewBox="0 0 24 24"><path d="M12 3 V16 M7 11 L12 16 L17 11 M4 20 H20"/></svg>',
    upload='<svg viewBox="0 0 24 24"><path d="M12 21 V8 M7 13 L12 8 L17 13 M4 4 H20"/></svg>',
    star='<svg viewBox="0 0 24 24"><path d="M12 3 L14.8 9 L21 9.7 L16.4 14 L17.6 21 L12 17.7 L6.4 21 L7.6 14 L3 9.7 L9.2 9 Z"/></svg>',
    heart='<svg viewBox="0 0 24 24"><path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/></svg>',
    shield='<svg viewBox="0 0 24 24"><path d="M12 3 L20 6 V11 C20 16 17 19 12 22 C7 19 4 16 4 11 V6 Z M9 12 L11 14 L15 10"/></svg>',
    play='<svg viewBox="0 0 24 24"><path d="M7 4 L20 12 L7 20 Z"/></svg>',
    pause='<svg viewBox="0 0 24 24"><path d="M8 5 V19 M16 5 V19"/></svg>',
}
local function MakeSVGRenderer(markup)
    return function(parent,iconSize) return IC.SVG(parent,iconSize,markup) end
end

IC.ByName={home=IC.Home,bell=IC.Bell,alert=IC.Alert,activity=IC.Activity,user=IC.User,keyboard=IC.Keyboard,ping=IC.Ping,server=IC.Server,save=IC.Save,settings=IC.Settings,info=IC.Info,trash=IC.Trash,["trash-2"]=IC.Trash,["arrow-right"]=IC.ArrowR,x=IC.X,["alert-circle"]=IC.Alert,monitor=IC.Settings,boxes=IC.Settings,wrench=IC.Settings,dots=IC.Dots,moon=IC.Moon,plus=IC.Plus,minus=IC.Minus,check=IC.Check,search=IC.Search,menu=IC.Menu,eye=IC.Eye,["eye-off"]=IC.EyeOff,shield=IC.Shield,sword=IC.Sword,swords=IC.Swords,target=IC.Target,crosshair=IC.Crosshair,zap=IC.Zap,play=IC.Play,pause=IC.Pause,["chevron-down"]=IC.ChevronDown,["chevron-up"]=IC.ChevronUp,["chevron-left"]=IC.ChevronLeft,["chevron-right"]=IC.ChevronRight,refresh=IC.Refresh,download=IC.Download,upload=IC.Upload,copy=IC.Copy,edit=IC.Edit,folder=IC.Folder,lock=IC.Lock,unlock=IC.Unlock,star=IC.Star,heart=IC.Heart,palette=IC.Palette,sliders=IC.Sliders,filter=IC.Filter,list=IC.List,grid=IC.Grid,smartphone=IC.Smartphone,gamepad=IC.Gamepad,globe=IC.Globe,clock=IC.Clock,volume=IC.Volume,mic=IC.Mic,trophy=IC.Trophy,users=IC.Users,package=IC.Package,database=IC.Database,terminal=IC.Terminal,code=IC.Code,help=IC.Help,sparkles=IC.Sparkles}

for svgName,svgMarkup in pairs(SVGIcons) do
    IC.ByName[svgName]=MakeSVGRenderer(svgMarkup)
end


IC.TintCache=setmetatable({},{__mode="k"})
function IC.CT(ic)
    if not ic or not ic.Parent then return {} end
    local c=IC.TintCache[ic]
    if c then return c end
    local l={}
    local ok,d=pcall(function() return ic:GetDescendants() end)
    if not ok or not d then IC.TintCache[ic]=l return l end
    for i=1,#d do
        local x=d[i]
        local n=x.Name
        if n=="IconLine" or n=="IconDot" or n=="IconStroke" then
            l[#l+1]=x
        end
    end
    IC.TintCache[ic]=l
    return l
end
function IC.T(c,cl)
    if not c or not c.Parent then return end
    local l=IC.CT(c)
    for i=1,#l do
        local x=l[i]
        if x and x.Parent then
            local n=x.Name
            if n=="IconLine" or n=="IconDot" then
                x.BackgroundColor3=cl
            elseif n=="IconStroke" then
                x.Color=cl
            end
        end
    end
end
function IC.Render(p,sz,spec,cl)
    if not p or not p.Parent then return nil end
    cl=cl or CFG.Purple
    if spec==nil then spec="dots" end
    if ty(spec)=="function" then
        local ok,ic=pcall(spec,p,sz)
        if not ok or not ic then
            ic=IC.Dots(p,sz)
        end
        ic.AnchorPoint=V2(.5,.5)
        ic.Position=Uv(.5,.5)
        IC.T(ic,cl)
        return ic
    end
    if ty(spec)=="string" then
        if sm(spec,"^%s*<svg") then
            local svg=IC.SVG(p,sz,spec)
            if svg then IC.T(svg,cl); return svg end
            return IC.Dots(p,sz)
        end
        local lk=sl(spec)
        local fn=IC.ByName[lk]
        if not fn then
            if sm(spec,"^%d+$") then
                local im=I("ImageLabel")
                im.BackgroundTransparency=1
                im.Image="rbxassetid://"..spec
                im.ImageColor3=cl
                im.ScaleType=Enum.ScaleType.Fit
                im.Size=U3(sz,sz)
                im.AnchorPoint=V2(.5,.5)
                im.Position=Uv(.5,.5)
                im.Parent=p
                Tk(im:GetPropertyChangedSignal("IsLoaded"):Connect(function()
                    if not im.Parent then return end
                    if not im.IsLoaded then
                        im:Destroy()
                        IC.Dots(p,sz)
                    end
                end))
                return im
            end
            fn=IC.ByName.dots
        end
        local ic=fn(p,sz)
        ic.AnchorPoint=V2(.5,.5)
        ic.Position=Uv(.5,.5)
        IC.T(ic,cl)
        return ic
    end
    local ic=IC.Dots(p,sz)
    ic.AnchorPoint=V2(.5,.5)
    ic.Position=Uv(.5,.5)
    IC.T(ic,cl)
    return ic
end

local opD=false
local RC,DC,SR
local IH={}
local function RegI(h) IH[#IH+1]=h end
Tk(S.U.InputChanged:Connect(function(i)
    if not (opD or RC.active or DC.active or SR.active) then return end
    for k=1,#IH do pcall(IH[k],i) end
end))
local EH={}
local function RegE(h) EH[#EH+1]=h end
Tk(S.U.InputEnded:Connect(function(i)
    for k=1,#EH do pcall(EH[k],i) end
end))


UI.Particles={}
UI.Gui=I("ScreenGui")
UI.Gui.Name="LuaInterface"
UI.Gui.ResetOnSpawn=false
UI.Gui.IgnoreGuiInset=true
UI.Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
UI.Gui.DisplayOrder=100
UI.Gui.Parent=S.PG
UI.PGui=I("ScreenGui")
UI.PGui.Name="LuaPopups"
UI.PGui.ResetOnSpawn=false
UI.PGui.IgnoreGuiInset=true
UI.PGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
UI.PGui.DisplayOrder=150
UI.PGui.Parent=S.PG
UI.DGui=I("ScreenGui")
UI.DGui.Name="LuaDialogs"
UI.DGui.ResetOnSpawn=false
UI.DGui.IgnoreGuiInset=true
UI.DGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
UI.DGui.DisplayOrder=175
UI.DGui.Parent=S.PG
UI.OGui=I("ScreenGui")
UI.OGui.Name="LuaOpenButton"
UI.OGui.ResetOnSpawn=false
UI.OGui.IgnoreGuiInset=true
UI.OGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
UI.OGui.DisplayOrder=250
UI.OGui.Parent=S.PG

UI.Main=I("Frame")
UI.Main.Name="Main"
UI.Main.Size=U3(1180,700)
UI.Main.Position=Uv(.5,.5)
UI.Main.AnchorPoint=V2(.5,.5)
UI.Main.BackgroundColor3=CFG.Bg
UI.Main.BorderSizePixel=0
UI.Main.ClipsDescendants=true
UI.Main.Active=true
UI.Main.Parent=UI.Gui
FT.C(UI.Main,CFG.CornerRadius)
Reg(UI.Main,"BackgroundColor3","Bg")
UI.MStroke=FT.S(UI.Main,CFG.CardHoverBorder,1.2)
Reg(UI.MStroke,"Color","CardHoverBorder")

UI.PartL=I("Frame")
UI.PartL.Size=Uv(1,1)
UI.PartL.BackgroundTransparency=1
UI.PartL.ClipsDescendants=true
UI.PartL.ZIndex=1
UI.PartL.Parent=UI.Main
local PR=Random.new()
local PC={Count=CFG.PartCount,Low=-.08,SD=1/650,DD=1/100}
for i=1,PC.Count do
    local s=PR:NextInteger(2,5)
    local Dot=I("Frame")
    Dot.Size=U3(s,s)
    local x0=PR:NextNumber(0,1)
    local y0=PR:NextNumber(.05,1.05)
    Dot.Position=U2(x0,0,y0,0)
    Dot.BackgroundColor3=ST.PColor
    Dot.BackgroundTransparency=PR:NextNumber(ST.PTmin,ST.PTmax)
    Dot.BorderSizePixel=0
    Dot.ZIndex=1
    FT.C(Dot,s)
    Dot.Parent=UI.PartL
    UI.Particles[i]={Object=Dot,X=x0,Y=y0,Speed=PR:NextNumber(12,28),Drift=PR:NextNumber(-8,8),Phase=PR:NextNumber(0,math.pi*2)}
end

UI.Sidebar=I("Frame")
UI.Sidebar.BackgroundColor3=CFG.Sidebar
UI.Sidebar.BorderSizePixel=0
UI.Sidebar.ZIndex=5
UI.Sidebar.ClipsDescendants=true
UI.Sidebar.Parent=UI.Main
FT.C(UI.Sidebar,CFG.CornerRadius)
Reg(UI.Sidebar,"BackgroundColor3","Sidebar")
UI.Footer=FT.L(UI.Sidebar,"",11,CFG.SubText)
UI.Footer.Size=U2(1,-24,0,22)
UI.Footer.AnchorPoint=V2(0,1)
UI.Footer.Position=U2(0,12,1,-10)
UI.Footer.TextXAlignment=Enum.TextXAlignment.Left
UI.Footer.TextTruncate=Enum.TextTruncate.AtEnd
UI.Footer.Visible=false
Reg(UI.Footer,"TextColor3","SubText")
UI.BgImage=I("ImageLabel")
UI.BgImage.Name="BackgroundImage"
UI.BgImage.BackgroundTransparency=1
UI.BgImage.Size=Uv(1,1)
UI.BgImage.Position=Uv(.5,.5)
UI.BgImage.AnchorPoint=V2(.5,.5)
UI.BgImage.ScaleType=Enum.ScaleType.Crop
UI.BgImage.ImageTransparency=.78
UI.BgImage.ZIndex=0
UI.BgImage.Parent=UI.Main
UI.BgImage.Visible=false
UI.SidebarResize=I("TextButton")
UI.SidebarResize.Name="SidebarResizeHandle"
UI.SidebarResize.BackgroundTransparency=1
UI.SidebarResize.Text=""
UI.SidebarResize.AutoButtonColor=false
UI.SidebarResize.Size=U3(8,0)
UI.SidebarResize.Position=U2(1,-4,0,0)
UI.SidebarResize.AnchorPoint=V2(.5,0)
UI.SidebarResize.ZIndex=20
UI.SidebarResize.Visible=false
UI.SidebarResize.Parent=UI.Sidebar
UI.pTR=I("Frame")
UI.pTR.Size=U3(CFG.CornerRadius+2,CFG.CornerRadius+2)
UI.pTR.Position=U2(1,-(CFG.CornerRadius+2),0,0)
UI.pTR.BackgroundColor3=CFG.Sidebar
UI.pTR.BorderSizePixel=0
UI.pTR.ZIndex=6
UI.pTR.Parent=UI.Sidebar
Reg(UI.pTR,"BackgroundColor3","Sidebar")
UI.pBR=I("Frame")
UI.pBR.Size=U3(CFG.CornerRadius+2,CFG.CornerRadius+2)
UI.pBR.Position=U2(1,-(CFG.CornerRadius+2),1,-(CFG.CornerRadius+2))
UI.pBR.BackgroundColor3=CFG.Sidebar
UI.pBR.BorderSizePixel=0
UI.pBR.ZIndex=6
UI.pBR.Parent=UI.Sidebar
Reg(UI.pBR,"BackgroundColor3","Sidebar")
UI.Div=I("Frame")
UI.Div.Size=U2(0,1,1,0)
UI.Div.Position=U2(1,-1,0,0)
UI.Div.BackgroundColor3=CFG.Stroke
UI.Div.BorderSizePixel=0
UI.Div.ZIndex=7
UI.Div.Parent=UI.Sidebar
Reg(UI.Div,"BackgroundColor3","Stroke")

UI.Logo=I("Frame")
UI.Logo.Size=U2(1,-30,0,75)
UI.Logo.Position=U3(15,15)
UI.Logo.BackgroundTransparency=1
UI.Logo.ZIndex=8
UI.Logo.Parent=UI.Sidebar
UI.LogoIco=I("Frame")
UI.LogoIco.Size=U3(48,48)
UI.LogoIco.Position=U3(0,4)
UI.LogoIco.BackgroundColor3=CFG.Purple
UI.LogoIco.ZIndex=8
UI.LogoIco.Parent=UI.Logo
FT.C(UI.LogoIco,12)
Reg(UI.LogoIco,"BackgroundColor3","Purple")
UI.LogoImg=I("ImageLabel")
UI.LogoImg.BackgroundTransparency=1
UI.LogoImg.Size=U2(1,-8,1,-8)
UI.LogoImg.Position=Uv(.5,.5)
UI.LogoImg.AnchorPoint=V2(.5,.5)
UI.LogoImg.Image="rbxassetid://"..CFG.LogoId
UI.LogoImg.ScaleType=Enum.ScaleType.Fit
UI.LogoImg.ZIndex=9
UI.LogoImg.Parent=UI.LogoIco
Tk(UI.LogoImg:GetPropertyChangedSignal("IsLoaded"):Connect(function()
    if UI.LogoImg.Parent and not UI.LogoImg.IsLoaded then
        UI.LogoImg.Visible=false
        local fb=FT.L(UI.LogoIco,"L",26,WH)
        fb.Size=Uv(1,1)
        fb.TextXAlignment=Enum.TextXAlignment.Center
        fb.Font=Enum.Font.GothamBold
        fb.ZIndex=10
    end
end))
UI.LogoName=FT.L(UI.Logo,"Lua",22,CFG.Text)
UI.LogoName.Position=U3(60,0)
UI.LogoName.Size=U2(1,-60,1,0)
UI.LogoName.Font=Enum.Font.GothamBold
UI.LogoName.TextYAlignment=Enum.TextYAlignment.Center
UI.LogoName.ZIndex=8
Reg(UI.LogoName,"TextColor3","Text")

UI.Nav=I("ScrollingFrame")
UI.Nav.Size=U2(1,-30,1,-115)
UI.Nav.Position=U3(15,95)
UI.Nav.BackgroundTransparency=1
UI.Nav.BorderSizePixel=0
UI.Nav.ScrollBarThickness=2
UI.Nav.ScrollBarImageColor3=CFG.Purple
UI.Nav.ScrollBarImageTransparency=.65
UI.Nav.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar
UI.Nav.VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right
UI.Nav.ScrollingDirection=Enum.ScrollingDirection.Y
UI.Nav.CanvasSize=U2(0,0,0,0)
UI.Nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
UI.Nav.ElasticBehavior=Enum.ElasticBehavior.Never
UI.Nav.ScrollingEnabled=true
UI.Nav.Active=true
UI.Nav.ClipsDescendants=true
UI.Nav.ZIndex=8
UI.Nav.Parent=UI.Sidebar
Reg(UI.Nav,"ScrollBarImageColor3","Purple")
UI.NavL=I("UIListLayout")
UI.NavL.Padding=Un(0,7)
UI.NavL.SortOrder=Enum.SortOrder.LayoutOrder
UI.NavL.Parent=UI.Nav

UI.Content=I("Frame")
UI.Content.BackgroundTransparency=1
UI.Content.ZIndex=3
UI.Content.ClipsDescendants=true
UI.Content.Size=Uv(1,1)
UI.Content.Parent=UI.Main
UI.Header=I("Frame")
UI.TabInfoName=FT.L(UI.Header,"",13,CFG.Text)
UI.TabInfoName.Position=U3(0,0)
UI.TabInfoName.Size=U2(1,-250,0,22)
UI.TabInfoName.Visible=false
Reg(UI.TabInfoName,"TextColor3","Text")
UI.TabInfoDesc=FT.L(UI.Header,"",10,CFG.SubText)
UI.TabInfoDesc.Position=U3(0,21)
UI.TabInfoDesc.Size=U2(1,-250,0,18)
UI.TabInfoDesc.Visible=false
Reg(UI.TabInfoDesc,"TextColor3","SubText")
UI.Header.BackgroundTransparency=1
UI.Header.Active=true
UI.Header.Parent=UI.Content
UI.DragHandle=I("TextButton")
UI.DragHandle.Name="DragHandle"
UI.DragHandle.BackgroundTransparency=1
UI.DragHandle.Text=""
UI.DragHandle.AutoButtonColor=false
UI.DragHandle.Size=U2(1,-420,1,0)
UI.DragHandle.ZIndex=2
UI.DragHandle.Parent=UI.Header
UI.PT=FT.L(UI.Header,"Home",27,CFG.Text)
UI.PT.Font=Enum.Font.GothamBold
UI.PT.ZIndex=3
Reg(UI.PT,"TextColor3","Text")
UI.Search=I("Frame")
UI.Search.BackgroundColor3=CFG.Field
UI.Search.Parent=UI.Header
UI.Search.ZIndex=4
FT.C(UI.Search,10)
Reg(UI.Search,"BackgroundColor3","Field")
UI.SStroke=FT.S(UI.Search,CFG.Stroke,1)
Reg(UI.SStroke,"Color","Stroke")
UI.SIcon=I("Frame")
UI.SIcon.Name="SearchIcon"
UI.SIcon.BackgroundTransparency=1
UI.SIcon.Position=U3(12,0)
UI.SIcon.Size=U3(30,42)
UI.SIcon.ZIndex=5
UI.SIcon.Parent=UI.Search
UI.SearchVectorIcon=IC.Render(UI.SIcon,18,"search",CFG.SubText)
for _,node in ipairs(UI.SIcon:GetDescendants()) do
    if node.Name=="IconStroke" then Reg(node,"Color","SubText")
    elseif node.Name=="IconLine" or node.Name=="IconDot" then Reg(node,"BackgroundColor3","SubText") end
end
UI.SBox=I("TextBox")
UI.SBox.Size=U2(1,-55,1,0)
UI.SBox.Position=U3(48,0)
UI.SBox.BackgroundTransparency=1
UI.SBox.PlaceholderText="Search"
UI.SBox.PlaceholderColor3=CFG.SubText
UI.SBox.TextColor3=CFG.Text
UI.SBox.TextSize=14
UI.SBox.Font=Enum.Font.GothamMedium
UI.SBox.ClearTextOnFocus=false
UI.SBox.Text=""
UI.SBox.Parent=UI.Search
UI.SBox.ZIndex=5
Reg(UI.SBox,"TextColor3","Text")
Reg(UI.SBox,"PlaceholderColor3","SubText")
Tk(UI.SBox.Focused:Connect(function() FT.T(UI.SStroke,{Color=CFG.Purple,Thickness=1.4},.2) end))
Tk(UI.SBox.FocusLost:Connect(function() FT.T(UI.SStroke,{Color=CFG.Stroke,Thickness=1},.2) end))
UI.SearchEmpty=FT.L(UI.Search,"No results",12,CFG.SubText)
UI.SearchEmpty.TextTruncate=Enum.TextTruncate.AtEnd
UI.SearchEmpty.Visible=false
UI.SearchEmpty.Position=U3(0,50)
UI.SearchEmpty.Size=U2(1,0,0,20)
UI.SearchEmpty.TextXAlignment=Enum.TextXAlignment.Center
Reg(UI.SearchEmpty,"TextColor3","SubText")
Tk(UI.SBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=sl(UI.SBox.Text or "")
    if q=="" then
        UI.SearchEmpty.Visible=false
        return
    end
    local found=false
    local first=nil
    for BN,B in pairs(ST.Buttons) do
        local low=ST.ButtonLowerNames[BN]
        if B and B.Parent and low and low:find(q,1,true) then found=true first=first or BN end
    end
    if ST.Window.GlobalSearch and first and first~=ST.CurrentPage then SetTab(first) end
    UI.SearchEmpty.Visible=not found
    UI.SearchEmpty.Text=found and "" or ("No results: "..UI.SBox.Text)
end))
UI.PageC=I("ScrollingFrame")
UI.PageC.BackgroundTransparency=1
UI.PageC.BorderSizePixel=0
UI.PageC.ClipsDescendants=true
UI.PageC.ScrollBarThickness=2
UI.PageC.ScrollBarImageColor3=CFG.Purple
UI.PageC.ScrollBarImageTransparency=.65
UI.PageC.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar
UI.PageC.VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right
UI.PageC.ScrollingDirection=Enum.ScrollingDirection.Y
UI.PageC.CanvasSize=U2(0,0,0,0)
UI.PageC.AutomaticCanvasSize=Enum.AutomaticSize.Y
UI.PageC.ElasticBehavior=Enum.ElasticBehavior.Never
UI.PageC.ScrollingEnabled=true
UI.PageC.Active=true
UI.PageC.Parent=UI.Content
Reg(UI.PageC,"ScrollBarImageColor3","Purple")

UI.Home=I("Frame")
UI.Home.Name="Home"
UI.Home.Size=U2(1,0,0,520)
UI.Home.BackgroundTransparency=1
UI.Home.Visible=true
UI.Home.Parent=UI.PageC
ST.Pages.Home=UI.Home
UI.HomeC=I("Frame")
UI.HomeC.Name="Container"
UI.HomeC.BackgroundTransparency=1
UI.HomeC.Size=U2(1,0,0,0)
UI.HomeC.AutomaticSize=Enum.AutomaticSize.Y
UI.HomeC.Parent=UI.Home
UI.HomeP=I("UIPadding")
UI.HomeP.PaddingLeft=Un(0,10)
UI.HomeP.PaddingRight=Un(0,10)
UI.HomeP.PaddingTop=Un(0,6)
UI.HomeP.PaddingBottom=Un(0,12)
UI.HomeP.Parent=UI.HomeC
UI.Greet=I("Frame")
UI.Greet.BackgroundColor3=CFG.Card
UI.Greet.BorderSizePixel=0
UI.Greet.Parent=UI.HomeC
FT.C(UI.Greet,13)
Reg(UI.Greet,"BackgroundColor3","Card")
UI.GStroke=FT.S(UI.Greet,CFG.Stroke,1)
Reg(UI.GStroke,"Color","Stroke")
UI.Avatar=I("ImageLabel")
UI.Avatar.Size=U3(55,55)
UI.Avatar.Position=U3(18,17)
UI.Avatar.BackgroundColor3=CFG.AvatarBg
UI.Avatar.BorderSizePixel=0
UI.Avatar.Parent=UI.Greet
FT.C(UI.Avatar,14)
Reg(UI.Avatar,"BackgroundColor3","AvatarBg")
task.spawn(function()
    local ok,av=pcall(function()
        return S.P:GetUserThumbnailAsync(S.LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
    end)
    if ok and av and UI.Avatar.Parent then
        UI.Avatar.Image=av
        Tk(UI.Avatar:GetPropertyChangedSignal("IsLoaded"):Connect(function()
            if not UI.Avatar.Parent then return end
            if not UI.Avatar.IsLoaded then
                UI.Avatar.Visible=false
                local dn0=S.LP.DisplayName or S.LP.Name or "P"
                local initials=ss(dn0,1,2)
                local fb=FT.L(UI.Greet,string.upper(initials),20,CFG.Text)
                fb.Position=U3(18,17)
                fb.Size=U3(55,55)
                fb.TextXAlignment=Enum.TextXAlignment.Center
                fb.Font=Enum.Font.GothamBold
            end
        end))
    else
        UI.Avatar.Visible=false
        local dn0=S.LP.DisplayName or S.LP.Name or "P"
        local initials=ss(dn0,1,2)
        local fb=FT.L(UI.Greet,string.upper(initials),20,CFG.Text)
        fb.Position=U3(18,17)
        fb.Size=U3(55,55)
        fb.TextXAlignment=Enum.TextXAlignment.Center
        fb.Font=Enum.Font.GothamBold
    end
end)
task.delay(6,function()
    if UI.Avatar and UI.Avatar.Parent and not UI.Avatar.IsLoaded and UI.Avatar.Image~="" then
        UI.Avatar.Visible=false
        local dn0=S.LP.DisplayName or S.LP.Name or "P"
        local initials=string.upper(ss(dn0,1,2))
        local fb=FT.L(UI.Greet,initials,20,CFG.Text)
        fb.Position=U3(18,17); fb.Size=U3(55,55); fb.TextXAlignment=Enum.TextXAlignment.Center; fb.Font=Enum.Font.GothamBold
    end
end)
local dnSafe=S.LP.DisplayName
if not dnSafe or dnSafe=="" then dnSafe=S.LP.Name or "Player" end
UI.Hello=FT.L(UI.Greet,"Hello, "..dnSafe,18,CFG.Text)
UI.Hello.Position=U3(90,19)
UI.Hello.Size=U2(1,-120,0,29)
UI.Hello.Font=Enum.Font.GothamBold
Reg(UI.Hello,"TextColor3","Text")
UI.Sect=FT.L(UI.HomeC,"SYSTEM INFO",12,CFG.SubText)
UI.Sect.Font=Enum.Font.GothamBold
Reg(UI.Sect,"TextColor3","SubText")
UI.Cards=I("Frame")
UI.Cards.BackgroundTransparency=1
UI.Cards.ClipsDescendants=false
UI.Cards.Parent=UI.HomeC
UI.Grid=I("UIGridLayout")
UI.Grid.FillDirection=Enum.FillDirection.Horizontal
UI.Grid.SortOrder=Enum.SortOrder.LayoutOrder
UI.Grid.HorizontalAlignment=Enum.HorizontalAlignment.Center
UI.Grid.VerticalAlignment=Enum.VerticalAlignment.Top
UI.Grid.Parent=UI.Cards

UI.CardL={}
local function CrtCard(par,Ttl,Val,Isp,IsImg)
    local Cd=I("Frame")
    Cd.BackgroundColor3=CFG.Card
    Cd.BorderSizePixel=0
    Cd.BackgroundTransparency=1
    Cd.Parent=par
    FT.C(Cd,12)
    Reg(Cd,"BackgroundColor3","Card")
    local Strk=FT.S(Cd,CFG.Stroke,1)
    Strk.Transparency=1
    Reg(Strk,"Color","Stroke")
    local IF=I("Frame")
    IF.Name="IconFrame"
    IF.BackgroundColor3=CFG.IconBg
    IF.Parent=Cd
    FT.C(IF,10)
    Reg(IF,"BackgroundColor3","IconBg")
    if Isp then IC.Render(IF,IsImg and 30 or 22,Isp,CFG.Purple) end
    local TL=FT.L(Cd,Ttl,14,CFG.SubText)
    TL.Name="Title"
    Reg(TL,"TextColor3","SubText")
    local VL=FT.L(Cd,Val,21,CFG.Text)
    VL.Name="Value"
    VL.Font=Enum.Font.GothamBold
    Reg(VL,"TextColor3","Text")
    task.delay(.05,function()
        if not Cd.Parent then return end
        FT.T(Cd,{BackgroundTransparency=0},.35,"__Card")
        FT.T(Strk,{Transparency=0},.35,"__Card")
    end)
    Tk(Cd.MouseEnter:Connect(function()
        FT.T(Cd,{BackgroundColor3=CFG.CardHover},.18)
        FT.T(Strk,{Color=CFG.Purple},.18)
    end))
    Tk(Cd.MouseLeave:Connect(function()
        FT.T(Cd,{BackgroundColor3=CFG.Card},.18)
        FT.T(Strk,{Color=CFG.Stroke},.18)
    end))
    UI.CardL[#UI.CardL+1]={Card=Cd,IconFrame=IF,Title=TL,Value=VL}
    return Cd,VL
end
UI.FC,UI.FV=CrtCard(UI.Cards,"FPS","0",IMA.FPS,true)
UI.PiC,UI.PiV=CrtCard(UI.Cards,"Ping","0 ms",IMA.Ping,true)
UI.GC,UI.GV=CrtCard(UI.Cards,"Game","Loading...",IMA.Home,true)
local sid=ss(game.JobId or "",1,8)
if sid=="" then sid="N/A" end
UI.SC,UI.SV=CrtCard(UI.Cards,"Server ID",sid,IC.Server,false)
UI.TC,UI.TV=CrtCard(UI.Cards,"Time","--:--",IC.Activity,false)
UI.FC.LayoutOrder,UI.PiC.LayoutOrder,UI.GC.LayoutOrder=1,2,3
UI.SC.LayoutOrder,UI.TC.LayoutOrder=4,5
task.spawn(function()
    local ok,inf=pcall(function() return S.M:GetProductInfo(game.PlaceId) end)
    if UI.GV.Parent then UI.GV.Text=(ok and inf and inf.Name) or "Unknown Game" end
end)

UI.PageCts={}
local function CrtPg(Nm)
    if not Nm or Nm=="" or ty(Nm)~="string" then return nil,nil end
    if ST.Pages[Nm] then
        return ST.Pages[Nm],UI.PageCts[Nm]
    end
    local Pg=I("Frame")
    Pg.Name=Nm
    Pg.Size=Uv(1,1)
    Pg.BackgroundTransparency=1
    Pg.Visible=false
    Pg.Parent=UI.PageC
    ST.Pages[Nm]=Pg
    local Cn=I("Frame")
    Cn.Name="Container"
    Cn.BackgroundTransparency=1
    Cn.Position=U3(0,6)
    Cn.Size=U2(1,0,0,0)
    Cn.AutomaticSize=Enum.AutomaticSize.Y
    Cn.Parent=Pg
    local pd=I("UIPadding")
    pd.PaddingLeft=Un(0,10)
    pd.PaddingRight=Un(0,10)
    pd.PaddingTop=Un(0,6)
    pd.PaddingBottom=Un(0,14)
    pd.Parent=Cn
    UI.PageCts[Nm]=Cn
    return Pg,Cn
end
CrtPg("Example1") CrtPg("Example2") CrtPg("Example3") CrtPg("Example4") CrtPg("Example5") CrtPg("Theme")

local function ScrollU()
    if ST.ScrollScheduled then return end
    ST.ScrollScheduled=true
    task.defer(function()
        ST.ScrollScheduled=false
        if not UI.PageC or not UI.PageC.Parent then return end
        local VH=ma(1,UI.PageC.AbsoluteSize.Y)
        if UI.Cards and UI.Cards.Parent then
            local gh=UI.Grid.AbsoluteContentSize.Y
            if gh>0 then UI.Cards.Size=U2(1,0,0,gh) end
        end
        local hn=VH
        if UI.HomeC then hn=ma(VH,UI.HomeC.AbsoluteSize.Y+24) end
        UI.Home.Size=U2(1,0,0,hn)
        local Nm=ST.CurrentPage
        if Nm and Nm~="Home" then
            local Pg=ST.Pages[Nm]
            if Pg then
                local C=Pg:FindFirstChild("Container")
                local need=VH
                if C then need=ma(VH,C.AbsoluteSize.Y+30) end
                Pg.Size=U2(1,0,0,need)
            end
        end
        local okC,canvasY=pcall(function() return UI.PageC.AbsoluteCanvasSize.Y end)
        if okC and canvasY then
            local maxY=ma(0,canvasY-UI.PageC.AbsoluteSize.Y)
            if UI.PageC.CanvasPosition.Y>maxY then
                UI.PageC.CanvasPosition=V2(0,maxY)
            elseif UI.PageC.CanvasPosition.Y<0 then
                UI.PageC.CanvasPosition=V2(0,0)
            end
        end
    end)
end

Tk(UI.Grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollU()
end))

local function AnimPg(Pg)
    if not Pg or not Pg.Parent then return end
    local C=Pg:FindFirstChild("Container") or Pg
    local ch=C:GetChildren()
    local mt=ST.PageToken
    for i=1,#ch do
        local c=ch[i]
        if c:IsA("GuiObject") then
            local op,ob=c.Position,c.BackgroundTransparency
            local ots={}
            local d=c:GetDescendants()
            for j=1,#d do
                local x=d[j]
                if x:IsA("TextLabel") or x:IsA("TextButton") or x:IsA("TextBox") then
                    ots[x]=x.TextTransparency
                    x.TextTransparency=1
                end
            end
            -- v5.1.4: cancela tweens antigos do mesmo objeto/page anim
            FT.ClearTweens(c)
            local off=tn(ST.Window.TabSwipeOffset) or 26
            local from=ST.Window.TabSwipeFrom
            if from=="left" then c.Position=U2(op.X.Scale,op.X.Offset-off,op.Y.Scale,op.Y.Offset)
            elseif from=="right" then c.Position=U2(op.X.Scale,op.X.Offset+off,op.Y.Scale,op.Y.Offset)
            elseif from=="top" then c.Position=U2(op.X.Scale,op.X.Offset,op.Y.Scale,op.Y.Offset-off)
            else c.Position=U2(op.X.Scale,op.X.Offset,op.Y.Scale,op.Y.Offset+off) end
            if c:IsA("Frame") or c:IsA("TextButton") then c.BackgroundTransparency=1 end
            task.delay(i*.03,function()
                if mt~=ST.PageToken or not c.Parent then return end
                FT.T(c,{Position=op},ST.Window.TabTransitionTime or .22,"PageAnim")
                if c:IsA("Frame") or c:IsA("TextButton") then FT.T(c,{BackgroundTransparency=ob},ST.Window.TabTransitionTime or .22,"PageAnimBG") end
                for x,o in pairs(ots) do
                    if x and x.Parent then FT.T(x,{TextTransparency=o},ST.Window.TabTransitionTime or .22,"PageAnimTxt") end
                end
            end)
        end
    end
end

SetTab=function(Nm)
    local now=os.clock()
    if now-(ST.LastTabChange or 0)<.06 and ST.CurrentPage~=Nm then
        return
    end
    ST.LastTabChange=now
    CloseDropdowns()
    if not ST.Pages[Nm] then Nm="Home" end
    if not ST.Pages[Nm] or ST.CurrentPage==Nm then return end
    SaveScrolls()
    ST.CurrentPage=Nm
    ST.PageToken=ST.PageToken+1
    -- v5.1.4: cancela tweens de página ao trocar
    for _,pgObj in pairs(ST.Pages) do
        FT.ClearTweens(pgObj)
    end
    for PN,Pg in pairs(ST.Pages) do Pg.Visible=(PN==Nm) end
    if ST.Window.Animations.TabSwitch then task.defer(function() AnimPg(ST.Pages[Nm]) end) end
    for BN,B in pairs(ST.Buttons) do
        local A=(BN==Nm)
        local BG=B:FindFirstChild("Background")
        local T=B:FindFirstChild("Text")
        local Bar=B:FindFirstChild("ActiveBar")
        if BG then FT.T(BG,{BackgroundTransparency=A and 0 or 1},.25,"TabBG") end
        if T then FT.T(T,{TextColor3=A and CFG.Text or CFG.SubText},.25,"TabTxt") end
        if Bar then
            Bar.Visible=A
            if A then
                Bar.Size=U3(3,0)
                FT.T(Bar,{Size=U3(3,24)},.28,Enum.EasingStyle.Back,"TabBar")
            end
        end
        local tl=ST.ButtonIcons[BN]
        if tl then
            local cc=A and CFG.Purple or CFG.SubText
            for i=1,#tl do
                local d=tl[i]
                if d and d.Parent then
                    local n=d.Name
                    if n=="IconLine" or n=="IconDot" then FT.T(d,{BackgroundColor3=cc},.25)
                    elseif n=="IconStroke" then FT.T(d,{Color=cc},.25)
                    elseif d:IsA("ImageLabel") then FT.T(d,{ImageColor3=cc},.25) end
                end
            end
        else
            local Ico=B:FindFirstChild("Icon")
            if Ico and Ico:IsA("TextLabel") then FT.T(Ico,{TextColor3=A and CFG.Purple or CFG.SubText},.25) end
        end
    end
    FT.T(UI.PT,{TextTransparency=1},.12,"PTIn")
    task.delay(.12,function()
        if not UI.PT.Parent then return end
        UI.PT.Text=Nm
        FT.T(UI.PT,{TextTransparency=0},.22,"PTIn")
    end)
    UI.Nav.CanvasPosition=V2(0,UI.Nav.CanvasPosition.Y)
    RestoreScroll(Nm)
    ScrollU()
end

local TD={{V=IC.Home,N="Home",D="Home"},{T="◎",N="Example1",D="Example"},{T="◉",N="Example2",D="Example"},{T="ϟ",N="Example3",D="Example"},{V=IC.Settings,N="Example4",D="Example"},{T="◇",N="Example5",D="Example"},{V=IC.Moon,N="Theme",D="Theme"}}
for i=1,#TD do
    local D=TD[i]
    local B=I("TextButton")
    B.Name=D.N
    B.BackgroundTransparency=1
    B.Text=""
    B.AutoButtonColor=false
    B.LayoutOrder=i
    B.Parent=UI.Nav
    local BG=I("Frame")
    BG.Name="Background"
    BG.Size=Uv(1,1)
    BG.BackgroundColor3=CFG.NavActive
    BG.BackgroundTransparency=1
    BG.Parent=B
    FT.C(BG,10)
    Reg(BG,"BackgroundColor3","NavActive")
    local Bar=I("Frame")
    Bar.Name="ActiveBar"
    Bar.Size=U3(3,24)
    Bar.Position=U3(0,12)
    Bar.BackgroundColor3=CFG.Purple
    Bar.BorderSizePixel=0
    Bar.Visible=false
    Bar.Parent=B
    FT.C(Bar,3)
    Reg(Bar,"BackgroundColor3","Purple")
    if D.V then
        local H=I("Frame")
        H.Name="Icon"
        H.BackgroundTransparency=1
        H.Parent=B
        local Ic=D.V(H,20)
        Ic.AnchorPoint=V2(.5,.5)
        Ic.Position=Uv(.5,.5)
        IC.T(Ic,CFG.SubText)
        ST.ButtonIcons[D.N]=IC.CT(Ic)
    else
        local IL2=FT.L(B,D.T,21,CFG.SubText)
        IL2.Name="Icon"
        IL2.TextXAlignment=Enum.TextXAlignment.Center
        Reg(IL2,"TextColor3","SubText")
    end
    local T=FT.L(B,D.D,14,CFG.SubText)
    T.Name="Text"
    Reg(T,"TextColor3","SubText")
    ST.Buttons[D.N]=B
    ST.ButtonLowerNames[D.N]=sl(D.N)
    Tk(B.MouseEnter:Connect(function()
        if ST.CurrentPage~=D.N then FT.T(BG,{BackgroundTransparency=.55},.18,"TabHover") end
    end))
    Tk(B.MouseLeave:Connect(function()
        if ST.CurrentPage~=D.N then FT.T(BG,{BackgroundTransparency=1},.18,"TabHover") end
    end))
    Tk(B.MouseButton1Down:Connect(function() if ST.CurrentPage~=D.N then FT.T(BG,{BackgroundTransparency=.25},.08,"TabPress") end end))
    Tk(B.MouseButton1Up:Connect(function() if ST.CurrentPage~=D.N then FT.T(BG,{BackgroundTransparency=.55},.1,"TabPress") end end))
    Tk(B.MouseButton1Click:Connect(function() SetTab(D.N) end))
end

UI.HdrB=I("Frame")
UI.HdrB.BackgroundTransparency=1
UI.HdrB.AnchorPoint=V2(1,0)
UI.HdrB.ZIndex=50
UI.HdrB.Parent=UI.Header
local function HdrBtn(txt,sz)
    local B=I("TextButton")
    B.BackgroundTransparency=1
    B.Text=txt
    B.TextSize=sz or 22
    B.Font=Enum.Font.GothamMedium
    B.TextColor3=CFG.SubText
    B.AutoButtonColor=false
    B.Size=U3(30,30)
    B.ZIndex=51
    B.Parent=UI.HdrB
    Reg(B,"TextColor3","SubText")
    return B
end
UI.MinB=HdrBtn("—",22)
UI.FSB=HdrBtn("⛶",20)
UI.Close=HdrBtn("×",28)
UI.Close.ZIndex=51
Tk(UI.MinB.MouseEnter:Connect(function() FT.T(UI.MinB,{TextColor3=CFG.Text},.15) end))
Tk(UI.MinB.MouseLeave:Connect(function() FT.T(UI.MinB,{TextColor3=CFG.SubText},.15) end))
Tk(UI.FSB.MouseEnter:Connect(function() FT.T(UI.FSB,{TextColor3=CFG.Text},.15) end))
Tk(UI.FSB.MouseLeave:Connect(function() FT.T(UI.FSB,{TextColor3=CFG.SubText},.15) end))
Tk(UI.Close.MouseEnter:Connect(function() FT.T(UI.Close,{TextColor3=CFG.Text,Rotation=90},.2) end))
Tk(UI.Close.MouseLeave:Connect(function() FT.T(UI.Close,{TextColor3=CFG.SubText,Rotation=0},.2) end))

UI.OpenB=I("TextButton")
UI.OpenB.Name="LuaOpenButton"
UI.OpenB.AnchorPoint=V2(.5,.5)
UI.OpenB.Position=U2(.5,0,0,44)
UI.OpenB.Size=U3(190,58)
UI.OpenB.BackgroundColor3=CFG.Bg
UI.OpenB.Text=""
UI.OpenB.AutoButtonColor=false
UI.OpenB.Visible=false
UI.OpenB.Active=true
UI.OpenB.Parent=UI.OGui
FT.C(UI.OpenB,29)
Reg(UI.OpenB,"BackgroundColor3","Bg")
UI.OpenBS=FT.S(UI.OpenB,CFG.CardHoverBorder,1.5)
Reg(UI.OpenBS,"Color","CardHoverBorder")
UI.OpenBGL=I("Frame")
UI.OpenBGL.BackgroundColor3=CFG.IconBg
UI.OpenBGL.BorderSizePixel=0
UI.OpenBGL.Size=U3(42,42)
UI.OpenBGL.Position=U3(11,8)
UI.OpenBGL.ZIndex=1
UI.OpenBGL.Parent=UI.OpenB
FT.C(UI.OpenBGL,21)
Reg(UI.OpenBGL,"BackgroundColor3","IconBg")
UI.OpenBL=I("ImageLabel")
UI.OpenBL.BackgroundTransparency=1
UI.OpenBL.Size=U3(30,30)
UI.OpenBL.Position=U3(32,29)
UI.OpenBL.AnchorPoint=V2(.5,.5)
UI.OpenBL.Image="rbxassetid://"..IMA.Lua
UI.OpenBL.ImageColor3=CFG.Purple
UI.OpenBL.ScaleType=Enum.ScaleType.Fit
UI.OpenBL.ZIndex=2
UI.OpenBL.Parent=UI.OpenB
Reg(UI.OpenBL,"ImageColor3","Purple")
UI.OpenBT=FT.L(UI.OpenB,CFG.Name or "Lua",16,CFG.Text)
UI.OpenBT.Position=U3(60,0)
UI.OpenBT.Size=U2(1,-72,1,0)
UI.OpenBT.TextXAlignment=Enum.TextXAlignment.Center
UI.OpenBT.Font=Enum.Font.GothamBold
UI.OpenBT.ZIndex=2
Reg(UI.OpenBT,"TextColor3","Text")
Tk(UI.OpenBL:GetPropertyChangedSignal("IsLoaded"):Connect(function()
    if UI.OpenBL.Parent and not UI.OpenBL.IsLoaded then
        UI.OpenBL.Visible=false
        local fb=FT.L(UI.OpenB,"L",22,CFG.Purple)
        fb.Size=U3(42,42)
        fb.Position=U3(11,8)
        fb.TextXAlignment=Enum.TextXAlignment.Center
        fb.Font=Enum.Font.GothamBold
        fb.ZIndex=3
    end
end))

local CachedVP=V2(800,600)
local function GetVP()
    local cam=workspace.CurrentCamera
    if cam then
        local vp=cam.ViewportSize
        if vp and vp.X>0 and vp.Y>0 then CachedVP=vp end
    end
    return CachedVP
end
local UpdateResp,ScheduleResp,ApplyVis,Minimize,TglFS

-- v5.1.4: Open/Close com key "OpenClose" (cancela mutuamente)
ApplyVis=function(show)
    ST.toggleToken=ST.toggleToken+1
    local mt=ST.toggleToken
    ST.MainVisible=show
    if show then
        UI.OpenB.Visible=false
        UI.Main.Visible=true
        UpdateResp()
        if mt~=ST.toggleToken then return end
        CFG.BaseSize=U2(UI.Main.Size.X.Scale,UI.Main.Size.X.Offset,UI.Main.Size.Y.Scale,UI.Main.Size.Y.Offset)
        local shr=U2(CFG.BaseSize.X.Scale,CFG.BaseSize.X.Offset-40,CFG.BaseSize.Y.Scale,CFG.BaseSize.Y.Offset-40)
        UI.Main.Size=shr
        UI.Main.BackgroundTransparency=.5
        FT.T(UI.Main,{Size=CFG.BaseSize,BackgroundTransparency=0},.24,Enum.EasingStyle.Back,nil,"OpenClose")
    else
        FT.T(UI.Main,{Size=UI.Main.Size-U3(40,40),BackgroundTransparency=1},.18,nil,nil,"OpenClose")
        task.delay(.18,function()
            if mt~=ST.toggleToken then return end
            UI.Main.Visible=false
            UI.OpenB.Visible=true
        end)
    end
end
-- v5.1.4: Minimize com key "OpenClose" (não briga com Open)
Minimize=function()
    ST.toggleToken=ST.toggleToken+1
    local mt=ST.toggleToken
    ST.MainVisible=false
    FT.T(UI.Main,{Size=UI.Main.Size-U3(40,40),BackgroundTransparency=1},.18,nil,nil,"OpenClose")
    task.delay(.18,function()
        if mt~=ST.toggleToken then return end
        UI.Main.Visible=false
        UI.OpenB.Visible=true
    end)
end
TglFS=function()
    if not UI.Main.Parent then return end
    CloseDropdowns()
    if not CFG.Fullscreen then
        -- Preserve the exact user window state so fullscreen is reversible.
        ST.Window.FullscreenSaved={
            Position=UI.Main.Position,
            Size=UI.Main.Size,
            CustomSize=ST.CustomSize and V2(ST.CustomSize.X,ST.CustomSize.Y) or nil,
            UserMoved=ST.UserMoved
        }
        CFG.Fullscreen=true
        ST.UserMoved=false
        UpdateResp()
    else
        CFG.Fullscreen=false
        local saved=ST.Window.FullscreenSaved
        ST.Window.FullscreenSaved=nil
        if saved then
            ST.CustomSize=saved.CustomSize
            UI.Main.Size=saved.Size
            UI.Main.Position=saved.Position
            ST.UserMoved=saved.UserMoved==true
        else
            ST.UserMoved=true
        end
        UpdateResp()
    end
end
Tk(UI.MinB.MouseButton1Click:Connect(Minimize))
Tk(UI.Close.MouseButton1Click:Connect(function() ApplyVis(false) end))
Tk(UI.FSB.MouseButton1Click:Connect(TglFS))
Tk(UI.OpenB.MouseEnter:Connect(function() FT.T(UI.OpenB,{Size=U3(198,62)},.16,Enum.EasingStyle.Quad,"OpenHover") end))
Tk(UI.OpenB.MouseLeave:Connect(function() FT.T(UI.OpenB,{Size=U3(190,58)},.16,Enum.EasingStyle.Quad,"OpenHover") end))
Tk(UI.OpenB.MouseButton1Click:Connect(function() if not ST.MainVisible then ApplyVis(true) end end))
opD=false
local opS,opSP,opInput,opSize,opMouseOffset=nil,nil,nil,nil,V2(0,0)
RegI(function(i)
    if not opD or not UI.OpenB.Parent then return end
    local t=i.UserInputType
    if t==Enum.UserInputType.Touch then
        if i~=opInput then return end
        local c=V2(i.Position.X,i.Position.Y)
        opMouseOffset=c-opS
    elseif t==Enum.UserInputType.MouseMovement then
        opMouseOffset=opMouseOffset+V2(i.Delta.X,i.Delta.Y)
    else return end
    local tl=opSP+opMouseOffset
    local v=GetVP(); local sz=opSize or UI.OpenB.AbsoluteSize
    local cx=cl(tl.X+sz.X*.5,10,v.X-10)
    local cy=cl(tl.Y+sz.Y*.5,10,v.Y-10)
    UI.OpenB.Position=U3(cx,cy)
end)
RegE(function(i)
    local t=i.UserInputType
    if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
        if t==Enum.UserInputType.Touch and i~=opInput then return end
        opD=false; opInput=nil; opSize=nil; opS=nil; opSP=nil; opMouseOffset=V2(0,0)
    end
end)
Tk(UI.OpenB.InputBegan:Connect(function(inp)
    local t=inp.UserInputType
    if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
    opD=true
    opInput=inp
    opS=V2(inp.Position.X,inp.Position.Y)
    opSP=V2(UI.OpenB.AbsolutePosition.X,UI.OpenB.AbsolutePosition.Y)
    opSize=UI.OpenB.AbsoluteSize
    opMouseOffset=V2(0,0)
end))

UI.RG=I("Frame")
UI.RG.Name="ResizeGrip"
UI.RG.AnchorPoint=V2(1,1)
UI.RG.Position=U2(1,-6,1,-6)
UI.RG.Size=U3(34,34)
UI.RG.BackgroundTransparency=1
UI.RG.ZIndex=30
UI.RG.Parent=UI.Main
UI.GL={}
for i=1,3 do
    local sz=4+(4-i)*4
    local l=I("Frame")
    l.Size=U3(sz,2)
    l.AnchorPoint=V2(1,1)
    l.Position=U2(1,-4,1,-4-(i-1)*8)
    l.Rotation=-45
    l.BackgroundColor3=CFG.SubText
    l.BackgroundTransparency=.3
    l.BorderSizePixel=0
    l.ZIndex=30
    l.Parent=UI.RG
    FT.C(l,1)
    Reg(l,"BackgroundColor3","SubText")
    UI.GL[#UI.GL+1]=l
end
UI.RHA=I("TextButton")
UI.RHA.BackgroundTransparency=1
UI.RHA.Text=""
UI.RHA.AutoButtonColor=false
UI.RHA.Size=Uv(1,1)
UI.RHA.ZIndex=31
UI.RHA.Parent=UI.RG
RC={active=false,start=nil,size=nil,tl=nil,input=nil,mouseDelta=V2(0,0)}
local function BeginRz(inp)
    if ST.Window.Resizable==false then return end
    local t=inp.UserInputType
    if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
    RC.active=true
    ST.Resizing=true
    CFG.Fullscreen=false
    RC.input=inp
    RC.mouseDelta=V2(0,0)
    RC.start=V2(inp.Position.X,inp.Position.Y)
    RC.size=V2(UI.Main.AbsoluteSize.X,UI.Main.AbsoluteSize.Y)
    RC.tl=V2(UI.Main.AbsolutePosition.X,UI.Main.AbsolutePosition.Y)
end
-- v5.1.4: resize aplica direto (sem tween por frame)
local function UpdRz(inp)
    if not RC.active or not RC.start or not UI.Main.Parent then return end
    if inp.UserInputType==Enum.UserInputType.Touch and inp~=RC.input then return end
    local v=GetVP()
    local dl
    if inp.UserInputType==Enum.UserInputType.Touch then
        dl=V2(inp.Position.X,inp.Position.Y)-RC.start
    elseif inp.UserInputType==Enum.UserInputType.MouseMovement then
        RC.mouseDelta=RC.mouseDelta+V2(inp.Delta.X,inp.Delta.Y)
        dl=RC.mouseDelta
    else return end
    local maxW=ma(CFG.MinW,v.X-20); local maxH=ma(CFG.MinH,v.Y-20)
    if ST.Framework and ST.Framework.MaxW then maxW=mi(maxW,ST.Framework.MaxW) end
    if ST.Framework and ST.Framework.MaxH then maxH=mi(maxH,ST.Framework.MaxH) end
    local nw=cl(RC.size.X+dl.X,CFG.MinW,maxW)
    local nh=cl(RC.size.Y+dl.Y,CFG.MinH,maxH)
    local ncx=RC.tl.X+nw*.5
    local ncy=RC.tl.Y+nh*.5
    UI.Main.Size=U3(nw,nh)
    UI.Main.Position=U3(ncx,ncy)
    ST.CustomSize=V2(nw,nh)
end
local function EndRz()
    RC.active=false
    RC.start=nil
    RC.size=nil
    RC.tl=nil
    RC.input=nil
    RC.mouseDelta=V2(0,0)
    ST.Resizing=false
    ST.UserMoved=true
end
Tk(UI.RHA.MouseEnter:Connect(function()
    for i=1,#UI.GL do FT.T(UI.GL[i],{BackgroundColor3=CFG.Purple,BackgroundTransparency=0,Size=U3(10,2)},.15) end
end))
Tk(UI.RHA.MouseLeave:Connect(function()
    if RC.active then return end
    for i=1,#UI.GL do
        local sz=4+(4-i)*4
        FT.T(UI.GL[i],{BackgroundColor3=CFG.SubText,BackgroundTransparency=.3,Size=U3(sz,2)},.15)
    end
end))
Tk(UI.RHA.InputBegan:Connect(BeginRz))
RegI(function(i)
    if RC.active and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        UpdRz(i)
    end
end)
RegE(function(i)
    local t=i.UserInputType
    if not RC.active then return end
    if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
        if t==Enum.UserInputType.Touch and i~=RC.input then return end
        EndRz()
    end
end)
local lg=0
Tk(UI.RHA.MouseButton1Click:Connect(function()
    local now=os.clock()
    if now-lg<.35 then
        ST.CustomSize=nil
        ST.UserMoved=false
        UpdateResp()
    end
    lg=now
end))

DC={active=false,started=false,input=nil,start=nil,tl=nil,threshold=8,mouseDelta=V2(0,0)}
local function BeginD(inp)
    if DC and DC.active then return end
    if not UI.Main.Visible or not UI.Main.Parent then return end
    local t=inp.UserInputType
    if t~=Enum.UserInputType.MouseButton1 and t~=Enum.UserInputType.Touch then return end
    local px,py=inp.Position.X,inp.Position.Y
    local function hit(g)
        if not g or not g.Parent or not g.Visible then return false end
        local ap=g.AbsolutePosition
        local as=g.AbsoluteSize
        return px>=ap.X and px<=ap.X+as.X and py>=ap.Y and py<=ap.Y+as.Y
    end
    -- Header controls/search must never start a window drag.
    if hit(UI.MinB) or hit(UI.FSB) or hit(UI.Close) or hit(UI.Search) then return end
    if ST.OpenDropdown and hit(ST.OpenDropdown) then return end
    ST.Dragging=true
    DC.active=true
    DC.started=false
    DC.input=inp
    DC.mouseDelta=V2(0,0)
    DC.start=V2(inp.Position.X,inp.Position.Y)
    DC.tl=V2(UI.Main.AbsolutePosition.X,UI.Main.AbsolutePosition.Y)
end
local function SnapWindow()
    if not ST.Window.Snapping or not UI.Main.Parent then return end
    local vp=GetVP() local a=UI.Main.AbsolutePosition local sz=UI.Main.AbsoluteSize
    local margin=tn(ST.Window.SnapMargin) or 8 local dist=tn(ST.Window.SnapDistance) or 28
    local insetY=0
    if ST.Window.SnapAvoidCoreGui then pcall(function() local _,iy=S.G:GetGuiInset(); insetY=iy.Y end) end
    local x,y=a.X,a.Y
    local function near(v,targets) local best,bd=nil,nil for _,t in ipairs(targets) do local d=math.abs(v-t) if d<=dist and (not bd or d<bd) then best,bd=t,d end end return best end
    local nx=near(x,{margin,vp.X-sz.X-margin,(vp.X-sz.X)/2})
    local ny=near(y,{margin+insetY,vp.Y-sz.Y-margin,(vp.Y-sz.Y)/2})
    if nx then x=nx end if ny then y=ny end UI.Main.Position=U2(0,x,0,y)
end

local function StopD()
    if DC.started then
        ST.UserMoved=true
        ST.LastDragTime=os.clock()
    end
    ST.Dragging=false
    DC.active=false
    DC.started=false
    DC.input=nil
    DC.start=nil
    DC.tl=nil
    DC.mouseDelta=V2(0,0)
    if ST.Window.Snapping then SnapWindow() end
end
local function UpdD(inp)
    if not DC.active or not DC.start or not UI.Main.Parent then return end
    if DC.input and DC.input.UserInputType==Enum.UserInputType.Touch and inp~=DC.input then return end
    local d
    if inp.UserInputType==Enum.UserInputType.Touch then
        d=V2(inp.Position.X,inp.Position.Y)-DC.start
    elseif inp.UserInputType==Enum.UserInputType.MouseMovement then
        DC.mouseDelta=DC.mouseDelta+V2(inp.Delta.X,inp.Delta.Y)
        d=DC.mouseDelta
    else return end
    if not DC.started then
        if d.Magnitude<DC.threshold then return end
        DC.started=true
    end
    local tl=DC.tl+d
    local cx=tl.X+UI.Main.AbsoluteSize.X*.5
    local cy=tl.Y+UI.Main.AbsoluteSize.Y*.5
    local v=GetVP()
    local hw=UI.Main.AbsoluteSize.X*.5
    local hh=UI.Main.AbsoluteSize.Y*.5
    local keep=20
    cx=cl(cx,-hw+keep,v.X+hw-keep)
    cy=cl(cy,-hh+keep,v.Y+hh-keep)
    UI.Main.Position=U3(cx,cy)
end
Tk(UI.DragHandle.InputBegan:Connect(BeginD))
-- Header-wide drag fallback: allows dragging from the title/header area even when
-- responsive layout changes the DragHandle width. Controls remain clickable.
Tk(UI.Header.InputBegan:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
    BeginD(inp)
end))
RegI(function(i)
    if DC.active and DC.started and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        UpdD(i)
    end
end)
RegE(function(i)
    local t=i.UserInputType
    if not DC.active then return end
    if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
        if t==Enum.UserInputType.Touch and DC.input~=i then return end
        StopD()
    end
end)
SR={active=false,startX=0,startW=0,input=nil,mouseDelta=0}
Tk(UI.SidebarResize.InputBegan:Connect(function(inp)
    if not ST.Window.EnableSidebarResize or ST.Window.SidebarCompacted then return end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
    SR.active=true SR.input=inp SR.mouseDelta=0 SR.startX=inp.Position.X SR.startW=UI.Sidebar.AbsoluteSize.X
end))
RegI(function(inp)
    if not SR.active then return end
    if inp.UserInputType==Enum.UserInputType.Touch and inp~=SR.input then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
    local maxW=ma(ST.Window.MinSidebarWidth,UI.Main.AbsoluteSize.X-ST.Window.MinContainerWidth)
    local dx
    if inp.UserInputType==Enum.UserInputType.Touch then
        dx=inp.Position.X-SR.startX
    else
        SR.mouseDelta=SR.mouseDelta+inp.Delta.X
        dx=SR.mouseDelta
    end
    local desired=cl(SR.startW+dx,ST.Window.MinSidebarWidth,maxW)
    local compactByWidth=desired<=(ST.Window.CompactWidthActivation or 128)
    local compactByRatio=(UI.Main.AbsoluteSize.X>0 and desired/UI.Main.AbsoluteSize.X<=(ST.Window.SidebarCollapseThreshold or .5))
    if ST.Window.EnableCompacting and not ST.Window.DisableCompactingSnap and (compactByWidth or compactByRatio) then
        ST.Window.LastExpandedSidebarWidth=ST.Window.SidebarWidth or SR.startW
        ST.Window.SidebarCompacted=true
    else
        ST.Window.SidebarCompacted=false ST.Window.SidebarWidth=desired
    end
    UpdateResp()
end)
RegE(function(inp) if not SR.active then return end if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then if inp.UserInputType==Enum.UserInputType.Touch and inp~=SR.input then return end SR.active=false SR.input=nil SR.mouseDelta=0 end end)

local function GetMode()
    local forced=ST.Framework and ST.Framework.ForcedMode
    if forced and (forced=="Mobile" or forced=="Tablet" or forced=="Desktop") then return forced end
    local v=GetVP()
    if not v or v.Y<=0 then return "Desktop" end
    local touch=false
    local ok=pcall(function() touch=S.U.PreferredInput==Enum.PreferredInput.Touch end)
    if not ok then touch=S.U.TouchEnabled and not S.U.MouseEnabled end
    if touch then return "Mobile" end
    local s=mi(v.X,v.Y)
    local aspect=v.X/v.Y
    if aspect>1.8 and v.Y<500 then return "Mobile" end
    if s<760 then return "Mobile" elseif s<1050 then return "Tablet" else return "Desktop" end
end

UpdateResp=function()
    if not UI.Main.Parent then return end
    local v=GetVP()
    local W,Hh=v.X,v.Y
    local mode=GetMode()
    local modeChanged=(ST.LastResizeMode~=mode)
    ST.LastResizeMode=mode
    ST.CurrentMode=mode
    local MW,MH,SW
    if CFG.Fullscreen then
        MW,MH=W-16,Hh-16
    elseif ST.CustomSize then
        MW=mi(ST.CustomSize.X,W-20)
        MH=mi(ST.CustomSize.Y,Hh-20)
    elseif mode=="Mobile" then
        local L=W>Hh
        local WR=L and CFG.MLW or CFG.MPW
        local HR=L and CFG.MLH or CFG.MPH
        MW=cl(fl(W*WR),CFG.MinW,mi(L and 1080 or 900,ma(CFG.MinW,W-28)))
        MH=cl(fl(Hh*HR),CFG.MinH,mi(L and 620 or 680,ma(CFG.MinH,Hh-28)))
    elseif mode=="Tablet" then
        MW=cl(fl(W*CFG.TWR),620,mi(1120,ma(620,W-36)))
        MH=cl(fl(Hh*CFG.THR),450,mi(720,ma(450,Hh-36)))
    else
        MW=mi(1280,ma(860,W-60))
        MH=mi(780,ma(520,Hh-60))
        MW=mi(MW,W-24)
        MH=mi(MH,Hh-24)
    end
    local hdrBtnSz
    if mode=="Mobile" then
        SW=cl(fl(MW*.115),68,84)
        hdrBtnSz=40
    elseif mode=="Tablet" then
        SW=cl(fl(MW*.18),160,190)
        hdrBtnSz=34
    else
        SW=cl(fl(MW*.20),210,245)
        hdrBtnSz=32
    end
    if ST.Window.SidebarCompacted and ST.Window.EnableCompacting then
        SW=ST.Window.SidebarCompactWidth
    elseif ST.Window.SidebarWidth then
        SW=cl(ST.Window.SidebarWidth,ST.Window.MinSidebarWidth,ma(ST.Window.MinSidebarWidth,MW-ST.Window.MinContainerWidth))
    end
    MW=ma(CFG.MinW,MW)
    MH=ma(CFG.MinH,MH)
    UI.Main.Size=U3(MW,MH)
    UI.Sidebar.Size=U2(0,SW,1,0)
    UI.Content.Position=U3(SW,0)
    UI.Content.Size=U2(1,-SW,1,0)
    if mode=="Mobile" then
        UI.MinB.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.FSB.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.Close.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.MinB.TextSize=26
        UI.FSB.TextSize=24
        UI.Close.TextSize=30
    else
        UI.MinB.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.FSB.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.Close.Size=U3(hdrBtnSz,hdrBtnSz)
        UI.MinB.TextSize=22
        UI.FSB.TextSize=20
        UI.Close.TextSize=28
    end
    if mode=="Mobile" then
        local L=MW>MH
        UI.Header.Position=U3(14,10)
        UI.Header.Size=U2(1,-28,0,62)
        UI.DragHandle.Size=U2(1,-150,1,0)
        UI.PT.Position=U3(0,0)
        UI.PT.Size=U2(1,-140,0,30)
        UI.PT.TextSize=ClampTextSize(MW<400 and 18 or 22)
        UI.Search.Visible=false
        UI.HdrB.Position=U2(1,-8,0,4)
        UI.HdrB.Size=U3(3*hdrBtnSz+16,hdrBtnSz)
        UI.MinB.Position=U3(0,0)
        UI.FSB.Position=U3(hdrBtnSz+8,0)
        UI.Close.Position=U3(2*(hdrBtnSz+8),0)
        UI.PageC.Position=U3(14,72)
        UI.PageC.Size=U2(1,-28,1,-84)
        UI.Logo.Size=U2(1,0,0,72)
        UI.Logo.Position=U3(0,10)
        UI.LogoIco.Size=U3(40,40)
        UI.LogoIco.Position=U2(.5,-20,0,8)
        UI.LogoName.Visible=false
        UI.Nav.Size=U2(1,-20,1,-95)
        UI.Nav.Position=U3(10,90)
        for _,B in pairs(ST.Buttons) do
            B.Size=U2(1,0,0,50)
            local Ico=B:FindFirstChild("Icon")
            local T=B:FindFirstChild("Text")
            local Bar=B:FindFirstChild("ActiveBar")
            if Ico then
                Ico.Position=Uv(.5,.5)
                Ico.Size=U3(24,24)
                Ico.AnchorPoint=V2(.5,.5)
                if Ico:IsA("TextLabel") then Ico.TextSize=ClampTextSize(19) end
            end
            if T then T.Visible=false end
            if Bar then Bar.Position=U3(0,12) Bar.Size=U3(3,25) end
        end
        UI.Greet.Size=U2(1,0,0,L and 76 or 82)
        UI.Avatar.Size=U3(L and 44 or 48,L and 44 or 48)
        UI.Avatar.Position=U3(12,L and 16 or 17)
        UI.Hello.Position=U3(68,L and 12 or 15)
        UI.Hello.Size=U2(1,-110,0,28)
        UI.Hello.TextSize=ClampTextSize(L and 15 or 16)
        UI.Sect.Position=U3(0,L and 88 or 95)
        UI.Sect.Size=U2(1,0,0,22)
        UI.Sect.TextSize=ClampTextSize(12)
        UI.Cards.Position=U3(0,L and 116 or 124)
        if L and MW>=680 then
            UI.Grid.FillDirectionMaxCells=2
            UI.Grid.CellSize=U2(.5,-5,0,88)
            UI.Grid.CellPadding=U3(10,9)
        else
            UI.Grid.FillDirectionMaxCells=1
            UI.Grid.CellSize=U2(1,0,0,82)
            UI.Grid.CellPadding=U3(0,9)
        end
    elseif mode=="Tablet" then
        UI.Header.Position=U3(18,10)
        UI.Header.Size=U2(1,-36,0,68)
        UI.DragHandle.Size=U2(1,-380,1,0)
        UI.PT.Position=U3(0,2)
        UI.PT.Size=U2(1,-130,0,34)
        UI.PT.TextSize=ClampTextSize(25)
        UI.Search.Visible=false
        UI.HdrB.Position=U2(1,-10,0,8)
        UI.HdrB.Size=U3(3*hdrBtnSz+16,hdrBtnSz)
        UI.MinB.Position=U3(0,0)
        UI.FSB.Position=U3(hdrBtnSz+8,0)
        UI.Close.Position=U3(2*(hdrBtnSz+8),0)
        UI.PageC.Position=U3(18,78)
        UI.PageC.Size=U2(1,-36,1,-90)
        UI.LogoName.Visible=true
        UI.Nav.Size=U2(1,-28,1,-115)
        UI.Nav.Position=U3(14,95)
        for _,B in pairs(ST.Buttons) do
            B.Size=U2(1,0,0,48)
            local Ico=B:FindFirstChild("Icon")
            local T=B:FindFirstChild("Text")
            if Ico then
                Ico.Position=U3(10,0)
                Ico.Size=U3(36,48)
                if Ico:IsA("TextLabel") then Ico.TextSize=ClampTextSize(18) end
            end
            if T then T.Visible=true T.Position=U3(48,0) T.Size=U2(1,-54,48,0) T.TextSize=ClampTextSize(12) end
        end
        UI.Greet.Size=U2(1,0,0,86)
        UI.Avatar.Size=U3(52,52)
        UI.Avatar.Position=U3(16,17)
        UI.Hello.Position=U3(82,16)
        UI.Hello.Size=U2(1,-120,0,29)
        UI.Hello.TextSize=ClampTextSize(17)
        UI.Sect.Position=U3(0,99)
        UI.Sect.Size=U2(1,0,0,24)
        UI.Sect.TextSize=ClampTextSize(12)
        UI.Cards.Position=U3(0,128)
        UI.Grid.FillDirectionMaxCells=2
        UI.Grid.CellSize=U2(.5,-5,0,105)
        UI.Grid.CellPadding=U3(10,10)
    else
        UI.Header.Position=U3(22,12)
        UI.Header.Size=U2(1,-44,0,70)
        UI.DragHandle.Size=U2(1,-420,1,0)
        UI.PT.Position=U3(0,5)
        UI.PT.Size=U2(1,-380,0,35)
        UI.PT.TextSize=ClampTextSize(27)
        UI.Search.Visible=true
        UI.Search.Size=U3(220,42)
        local hdrW=3*hdrBtnSz+16
        UI.Search.Position=U2(1,-(hdrW+60+220+12),0,5)
        UI.HdrB.Position=U2(1,-60,0,16)
        UI.HdrB.Size=U3(3*hdrBtnSz+16,hdrBtnSz)
        UI.MinB.Position=U3(0,0)
        UI.FSB.Position=U3(hdrBtnSz+8,0)
        UI.Close.Position=U3(2*(hdrBtnSz+8),0)
        UI.PageC.Position=U3(22,82)
        UI.PageC.Size=U2(1,-44,1,-95)
        UI.LogoName.Visible=true
        UI.Nav.Size=U2(1,-34,1,-115)
        UI.Nav.Position=U3(17,95)
        for _,B in pairs(ST.Buttons) do
            B.Size=U2(1,0,0,48)
            local Ico=B:FindFirstChild("Icon")
            local T=B:FindFirstChild("Text")
            if Ico then
                Ico.Position=U3(18,0)
                Ico.Size=U3(35,48)
                if Ico:IsA("TextLabel") then Ico.TextSize=ClampTextSize(21) end
            end
            if T then T.Visible=true T.Position=U3(60,0) T.Size=U2(1,-70,48,0) T.TextSize=ClampTextSize(14) end
        end
        UI.Greet.Size=U2(1,0,0,90)
        UI.Avatar.Size=U3(55,55)
        UI.Avatar.Position=U3(18,17)
        UI.Hello.Position=U3(90,19)
        UI.Hello.Size=U2(1,-140,0,30)
        UI.Hello.TextSize=ClampTextSize(18)
        UI.Sect.Position=U3(0,105)
        UI.Sect.Size=U3(150,25)
        UI.Sect.TextSize=ClampTextSize(12)
        UI.Cards.Position=U3(0,135)
        UI.Grid.FillDirectionMaxCells=2
        UI.Grid.CellSize=U2(.5,-8,0,115)
        UI.Grid.CellPadding=U3(16,14)
    end
    local ILs,IPs,TLs,TSs,TTSs,VLs,VSs,VTSs
    if mode=="Mobile" then
        ILs=U3(44,44) IPs=U3(10,11)
        TLs=U3(66,11) TSs=U2(1,-80,0,22) TTSs=ClampTextSize(12)
        VLs=U3(66,34) VSs=U2(1,-80,0,36) VTSs=ClampTextSize(17)
    elseif mode=="Tablet" then
        ILs=U3(48,48) IPs=U3(14,12)
        TLs=U3(74,14) TSs=U2(1,-90,0,24) TTSs=ClampTextSize(13)
        VLs=U3(74,39) VSs=U2(1,-90,0,38) VTSs=ClampTextSize(19)
    else
        ILs=U3(52,52) IPs=U3(16,15)
        TLs=U3(80,17) TSs=U2(1,-100,0,25) TTSs=ClampTextSize(14)
        VLs=U3(80,43) VSs=U2(1,-100,0,40) VTSs=ClampTextSize(21)
    end
    for i=1,#UI.CardL do
        local E=UI.CardL[i]
        local IF,TL,VL=E.IconFrame,E.Title,E.Value
        if IF and IF.Parent then IF.Size=ILs IF.Position=IPs end
        if TL and TL.Parent then TL.Position=TLs TL.Size=TSs TL.TextSize=TTSs end
        if VL and VL.Parent then VL.Position=VLs VL.Size=VSs VL.TextSize=VTSs end
    end
    UI.SidebarResize.Visible=ST.Window.EnableSidebarResize and mode~="Mobile" and not ST.Window.SidebarCompacted
    UI.Footer.Visible=(ST.Window.Footer or "")~="" and mode~="Mobile"
    if CFG.Fullscreen then
        UI.Main.Position=Uv(.5,.5)
        ST.UserMoved=false
    elseif ST.FirstLayout or modeChanged then
        UI.Main.Position=U3(W*.5,Hh*.5)
        ST.FirstLayout=false
        ST.UserMoved=false
    elseif not ST.UserMoved and not ST.Resizing then
        local A=UI.Main.AbsolutePosition
        local cx=A.X+UI.Main.AbsoluteSize.X*.5
        local cy=A.Y+UI.Main.AbsoluteSize.Y*.5
        local hw=UI.Main.AbsoluteSize.X*.5
        local hh=UI.Main.AbsoluteSize.Y*.5
        local keep=20
        cx=cl(cx,-hw+keep,W+hw-keep)
        cy=cl(cy,-hh+keep,Hh+hh-keep)
        UI.Main.Position=U3(cx,cy)
    end
    SyncState()
    if mode=="Mobile" and not CFG.Fullscreen then
        local A=UI.Main.AbsolutePosition
        local W2=UI.Main.AbsoluteSize.X
        local H2=UI.Main.AbsoluteSize.Y
        if A.X<-W2+40 or A.X>v.X-40 or A.Y<-H2+40 or A.Y>v.Y-40 then
            UI.Main.Position=U3(v.X*.5,v.Y*.5)
            ST.UserMoved=false
        end
    end
end
ScheduleResp=function()
    if ST.RespScheduled then return end
    ST.RespScheduled=true
    task.defer(function()
        ST.RespScheduled=false
        SafeCall("UpdateResp",UpdateResp)
    end)
end
local VC
local function ConVP()
    if VC then VC:Disconnect() end
    local cam=workspace.CurrentCamera
    if not cam then return end
    VC=cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        CloseDropdowns()
        ScheduleResp()
    end)
end
Tk(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(function() ConVP() ScheduleResp() end)
end))
ConVP()
Tk(S.U.InputBegan:Connect(function(inp,proc)
    if proc then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==CFG.ToggleKey then
        ApplyVis(not ST.MainVisible)
    end
end))
TrackTask(task.spawn(function()
    local lt=os.clock()
    local f=0
    while UI.Gui and UI.Gui.Parent do
        S.R.RenderStepped:Wait()
        f=f+1
        local n=os.clock()
        if n-lt>=.5 then
            local fps=fl(f/(n-lt)+.5)
            local txt=ts(fps)
            if UI.FV.Parent and UI.FV.Text~=txt then
                UI.FV.Text=txt
                UI.FV.TextTransparency=.5
                FT.T(UI.FV,{TextTransparency=0},.25)
            end
            f=0
            lt=n
        end
    end
end))
TrackTask(task.spawn(function()
    local DP,GV
    pcall(function()
        DP=S.St.Network.ServerStatsItem["Data Ping"]
        GV=DP and DP.GetValue
    end)
    while UI.Gui and UI.Gui.Parent do
        task.wait(.5)
        if not UI.Gui.Parent then break end
        local ok,p=false,nil
        if GV and DP then
            ok,p=pcall(GV,DP)
        end
        if UI.PiV.Parent then
            local n=(ok and p and (fl(p).." ms")) or "N/A"
            if UI.PiV.Text~=n then
                UI.PiV.Text=n
                UI.PiV.TextTransparency=.5
                FT.T(UI.PiV,{TextTransparency=0},.25)
            end
        end
        if UI.TV.Parent then
            local ok2,timeStr=pcall(function() return os.date("%H:%M:%S") end)
            UI.TV.Text=(ok2 and timeStr) or "--:--"
        end
    end
end))
local HBP=S.R.Heartbeat:Connect(function(DT)
    if not UI.Main.Visible then return end
    local t=os.clock()
    for i=1,PC.Count do
        local D2=UI.Particles[i]
        if D2 and D2.Object and D2.Object.Parent then
            local Dot=D2.Object
            local y=D2.Y-(D2.Speed*DT)*PC.SD
            local x=D2.X+sn(t+D2.Phase)*D2.Drift*DT*PC.DD
            if y<PC.Low then
                x=PR:NextNumber(0,1)
                y=1.05
                Dot.BackgroundColor3=ST.PColor
                Dot.BackgroundTransparency=PR:NextNumber(ST.PTmin,ST.PTmax)
            end
            D2.X,D2.Y=x,y
            Dot.Position=U2(x,0,y,0)
        end
    end
end)
Tk(HBP)
SetTab("Home")
UpdateResp()
UI.Main.Visible=true
ST.MainVisible=true
CFG.BaseSize=UI.Main.Size
UI.Main.Size=UI.Main.Size-U3(80,80)
UI.Main.BackgroundTransparency=1
FT.T(UI.Main,{Size=CFG.BaseSize,BackgroundTransparency=0},.4,Enum.EasingStyle.Back,nil,"OpenClose")

local ThemeC=UI.PageCts["Theme"]
local ThemeLayout=I("UIListLayout")
ThemeLayout.Padding=Un(0,10)
ThemeLayout.SortOrder=Enum.SortOrder.LayoutOrder
ThemeLayout.Parent=ThemeC
local ThemeCards={}
local TOrder={"Dark","Light","Darker","Amoled","Rose","Indigo","Blue","Green","Red","Purple","Mellowsi","Ocean","Amber","Emerald","Violet"}
for i=1,#TOrder do
    local name=TOrder[i]
    local theme=Themes[name]
    if theme then
        local Card,CS=FT.Card(ThemeC,78)
        if Card then
            Card.LayoutOrder=i
            local Emoji=FT.L(Card,theme.E,30,CFG.Text)
            Emoji.Position=U3(16,0)
            Emoji.Size=U3(46,78)
            Emoji.TextXAlignment=Enum.TextXAlignment.Center
            Emoji.TextYAlignment=Enum.TextYAlignment.Center
            Reg(Emoji,"TextColor3","Text")
            local Title=FT.L(Card,name,15,CFG.Text)
            Title.Position=U3(72,0)
            Title.Size=U2(1,-180,1,0)
            Title.Font=Enum.Font.GothamBold
            Title.TextYAlignment=Enum.TextYAlignment.Center
            Reg(Title,"TextColor3","Text")
            local swBG=I("Frame")
            swBG.BackgroundColor3=theme.Bg
            swBG.BorderSizePixel=0
            swBG.Position=U3(16,58)
            swBG.Size=U3(24,16)
            swBG.Parent=Card
            FT.C(swBG,4)
            FT.S(swBG,CFG.Stroke,1)
            local swCard=I("Frame")
            swCard.BackgroundColor3=theme.Card
            swCard.BorderSizePixel=0
            swCard.Position=U3(46,58)
            swCard.Size=U3(24,16)
            swCard.Parent=Card
            FT.C(swCard,4)
            FT.S(swCard,CFG.Stroke,1)
            local swAcc=I("Frame")
            swAcc.BackgroundColor3=theme.Purple
            swAcc.BorderSizePixel=0
            swAcc.Position=U3(76,58)
            swAcc.Size=U3(24,16)
            swAcc.Parent=Card
            FT.C(swAcc,4)
            FT.S(swAcc,CFG.Stroke,1)
            local Check=FT.L(Card,"✓",24,CFG.Purple)
            Check.Position=U2(1,-40,0,0)
            Check.Size=U3(30,78)
            Check.TextXAlignment=Enum.TextXAlignment.Center
            Check.Font=Enum.Font.GothamBold
            Check.Visible=(ST.CurrentTheme==name)
            Reg(Check,"TextColor3","Purple")
            Reg(swBG,"BackgroundColor3","Bg")
            Reg(swCard,"BackgroundColor3","Card")
            Reg(swAcc,"BackgroundColor3","Purple")
            local CK=I("TextButton")
            CK.BackgroundTransparency=1
            CK.Text=""
            CK.AutoButtonColor=false
            CK.Size=Uv(1,1)
            CK.ZIndex=5
            CK.Parent=Card
            Tk(CK.MouseButton1Click:Connect(function()
                ApplyTheme(name)
                for nm,data in pairs(ThemeCards) do
                    if data.Check and data.Check.Parent then
                        data.Check.Visible=(nm==name)
                    end
                end
            end))
            Tk(Card.MouseEnter:Connect(function() FT.T(Card,{BackgroundColor3=CFG.CardHover},.18) end))
            Tk(Card.MouseLeave:Connect(function() FT.T(Card,{BackgroundColor3=CFG.Card},.18) end))
            ThemeCards[name]={Card=Card,Check=Check}
        end
    end
end
ST.Elements["ActiveTheme"]={Type="Theme",Get=function() return ST.CurrentTheme end,Set=function(v)
    local t=Themes[v]
    if not t then v="Dark" end
    ApplyTheme(v)
    for nm,data in pairs(ThemeCards) do
        if data.Check and data.Check.Parent then
            data.Check.Visible=(nm==v)
        end
    end
end}
ST.ElementOrder[#ST.ElementOrder+1]="ActiveTheme"

UI.NGui=I("ScreenGui")
UI.NGui.Name="LuaNotifications"
UI.NGui.ResetOnSpawn=false
UI.NGui.IgnoreGuiInset=true
UI.NGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
UI.NGui.DisplayOrder=200
UI.NGui.Parent=S.PG
UI.NH=I("Frame")
UI.NH.BackgroundTransparency=1
UI.NH.AnchorPoint=V2(1,0)
UI.NH.Position=U2(1,-16,0,16)
UI.NH.Size=U2(0,340,1,-32)
UI.NH.ClipsDescendants=true
UI.NH.Parent=UI.NGui
UI.NL=I("UIListLayout")
UI.NL.Padding=Un(0,8)
UI.NL.SortOrder=Enum.SortOrder.LayoutOrder
UI.NL.HorizontalAlignment=Enum.HorizontalAlignment.Right
UI.NL.Parent=UI.NH
local function UpdNS()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local vp=cam.ViewportSize
    if not vp or vp.X<=0 then vp=V2(800,600) end
    local w=ma(120,mi(340,vp.X-32))
    UI.NH.Size=U2(0,w,1,-32)
end
UpdNS()
Tk(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() task.defer(UpdNS) end))
local NCam=workspace.CurrentCamera
if NCam then Tk(NCam:GetPropertyChangedSignal("ViewportSize"):Connect(UpdNS)) end

local function DetachN(s)
    for i=1,#ST.ActiveNotif do
        if ST.ActiveNotif[i]==s then
            trem(ST.ActiveNotif,i)
            ST.ActiveCount=ST.ActiveCount-1
            task.defer(function()
                if ST.Destroyed then return end
                if ST.ActiveCount<CFG.MaxNotify and #ST.Framework.NotifyQueue>0 then
                    local nextCfg=trem(ST.Framework.NotifyQueue,1)
                    if nextCfg then LuaNotify(nextCfg) end
                end
            end)
            return
        end
    end
end

local function LuaNotifyImpl(cfg)
    if ty(cfg)=="string" then cfg={Content=cfg} end
    cfg=cfg or{}
    while ST.ActiveCount>=CFG.MaxNotify do
        local o=ST.ActiveNotif[1]
        if not o then break end
        if o._alive then
            o:Destroy()
        else
            trem(ST.ActiveNotif,1)
            ST.ActiveCount=ST.ActiveCount-1
        end
    end
    local ntype=cfg.Type or cfg.Kind or "Info"
    ntype=type(ntype)=="string" and ntype:gsub("^%l",string.upper) or "Info"
    local typeColors={
        Success=c3rgb(70,200,120),Info=CFG.Purple,Warning=c3rgb(235,180,70),Error=CFG.Red,Loading=c3rgb(90,160,255),Debug=c3rgb(150,150,160),Option=CFG.Purple
    }
    local title=cfg.Title or (ntype=="Success" and "Sucesso" or ntype=="Warning" and "Aviso" or ntype=="Error" and "Erro" or CFG.Name)
    local content=cfg.Content or cfg.Description or ""
    local time=ma(0,tn(cfg.Duration or cfg.Time) or CFG.NotifyDur)
    local ic=cfg.IconColor
    if ty(ic)~="Color3" then ic=typeColors[ntype] or CFG.Purple end
    local persist=cfg.Persist or false
    local Actions=cfg.Actions
    local dedupe=cfg.DedupeKey
    if dedupe then
        for i=1,#ST.ActiveNotif do
            local old=ST.ActiveNotif[i]
            if old and old._alive and old._dedupe==dedupe and (os.clock()-(old._createdAt or 0))<=CFG.NotifyDedupeWindow then
                if old.SetContent then old:SetContent(content) end
                if old.SetType then old:SetType(ntype) end
                return old
            end
        end
    end
    local W2=I("Frame")
    W2.Name="Wrapper"
    W2.BackgroundTransparency=1
    W2.Size=U2(1,0,0,0)
    W2.AutomaticSize=Enum.AutomaticSize.Y
    W2.ClipsDescendants=true
    W2.Parent=UI.NH
    local C=I("Frame")
    C.BackgroundColor3=CFG.Card
    C.BorderSizePixel=0
    C.Size=U2(1,0,0,0)
    C.AutomaticSize=Enum.AutomaticSize.Y
    C.Position=U2(0,0,0,0)
    C.Parent=W2
    FT.C(C,12)
    Reg(C,"BackgroundColor3","Card")
    local CS=FT.S(C,CFG.Stroke,1)
    Reg(CS,"Color","Stroke")
    local A=I("Frame")
    A.Size=U2(0,3,1,0)
    A.BackgroundColor3=ic
    A.BorderSizePixel=0
    A.Parent=C
    FT.C(A,3)
    local TL=I("TextLabel")
    TL.BackgroundTransparency=1
    TL.Text=title
    TL.TextSize=ClampTextSize(14)
    TL.Font=Enum.Font.GothamBold
    TL.TextColor3=CFG.Text
    TL.TextXAlignment=Enum.TextXAlignment.Left
    TL.Position=U3(20,12)
    TL.Size=U2(1,-70,0,20)
    TL.Parent=C
    Reg(TL,"TextColor3","Text")
    local CB=I("TextButton")
    CB.BackgroundTransparency=1
    CB.Text="×"
    CB.TextSize=22
    CB.Font=Enum.Font.GothamMedium
    CB.TextColor3=CFG.SubText
    CB.AutoButtonColor=false
    CB.Size=U3(32,32)
    CB.Position=U2(1,-38,0,6)
    CB.Parent=C
    Reg(CB,"TextColor3","SubText")
    local Dsc=I("TextLabel")
    Dsc.BackgroundTransparency=1
    Dsc.Text=content
    Dsc.TextSize=ClampTextSize(12)
    Dsc.Font=Enum.Font.Gotham
    Dsc.TextColor3=CFG.SubText
    Dsc.TextXAlignment=Enum.TextXAlignment.Left
    Dsc.TextWrapped=true
    Dsc.AutomaticSize=Enum.AutomaticSize.Y
    Dsc.Position=U3(20,34)
    Dsc.Size=U2(1,-35,0,20)
    Dsc.Parent=C
    Reg(Dsc,"TextColor3","SubText")
    local Pad=I("Frame")
    Pad.BackgroundTransparency=1
    Pad.Size=U2(1,0,0,14)
    Pad.Position=U2(0,0,1,0)
    Pad.Parent=C
    C.BackgroundTransparency=1
    CS.Transparency=1
    local allT={}
    local dt=C:GetDescendants()
    for i=1,#dt do
        local d=dt[i]
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            allT[d]=d.TextTransparency or 0
            d.TextTransparency=1
        end
    end
    -- v5.1.4: notification com key própria
    FT.T(C,{BackgroundTransparency=0},.35,nil,nil,"Notify")
    FT.T(CS,{Transparency=0},.35,nil,nil,"Notify")
    for d,o in pairs(allT) do FT.T(d,{TextTransparency=o},.35,nil,nil,"Notify") end
    local N={_alive=true,_timerThread=nil,_closing=false,_type=ntype,_dedupe=dedupe,_createdAt=os.clock(),_wrapper=W2,_card=C}
    if type(Actions)=="table" and #Actions>0 then
        local AB=I("Frame")
        AB.BackgroundTransparency=1
        AB.Size=U2(1,-35,0,36)
        AB.Position=U3(20,0)
        AB.Parent=C
        local AL=I("UIListLayout")
        AL.FillDirection=Enum.FillDirection.Horizontal
        AL.HorizontalAlignment=Enum.HorizontalAlignment.Right
        AL.VerticalAlignment=Enum.VerticalAlignment.Center
        AL.Padding=Un(0,6)
        AL.Parent=AB
        for ai=1,#Actions do
            local ac=type(Actions[ai])=="table" and Actions[ai] or {Title=ts(Actions[ai])}
            local ab=I("TextButton")
            local destructive=ac.Variant=="Destructive"
            ab.BackgroundColor3=destructive and CFG.Red or CFG.BgButton
            ab.Text=ts(ac.Title or "Action")
            ab.TextColor3=destructive and WH or CFG.Text
            ab.Font=Enum.Font.GothamBold
            ab.TextSize=11
            ab.AutoButtonColor=false
            ab.Size=U3(ma(64,#ab.Text*7+22),30)
            ab.Parent=AB
            FT.C(ab,7)
            Tk(ab.MouseButton1Click:Connect(function()
                if ac.Callback then SafeCall("NotifyAction:"..ts(ac.Title),ac.Callback,N) end
                if ac.Close~=false and N._alive then N:Destroy() end
            end))
        end
    end
    function N:SetContent(v)
        if not self._alive then return self end
        Dsc.Text=ts(v or "")
        return self
    end
    function N:SetTitle(v)
        if not self._alive then return self end
        TL.Text=ts(v or "")
        return self
    end
    function N:SetType(v)
        if not self._alive then return self end
        v=type(v)=="string" and v:gsub("^%l",string.upper) or "Info"
        self._type=v
        A.BackgroundColor3=typeColors[v] or CFG.Purple
        return self
    end
    function N:SetIconColor(v)
        if not self._alive or typeof(v)~="Color3" then return false end
        A.BackgroundColor3=v
        return true
    end
    function N:SetProgress(v)
        if not self._alive then return false end
        v=cl(tn(v) or 0,0,1)
        if not self._progress then
            self._progress=I("Frame"); self._progress.Name="Progress"; self._progress.BackgroundColor3=CFG.Purple; self._progress.BorderSizePixel=0; self._progress.Size=U2(1,0,0,3); self._progress.AnchorPoint=V2(.5,1); self._progress.Position=U2(.5,0,1,0); self._progress.Parent=C; FT.C(self._progress,2); Reg(self._progress,"BackgroundColor3","Purple")
        end
        self._progress.Size=U2(v,0,0,3)
        return true
    end
    function N:SetCallback(fn)
        if fn~=nil and type(fn)~="function" then return false end
        self._callback=fn
        if not self._clickOverlay then
            self._clickOverlay=I("TextButton"); self._clickOverlay.Name="ClickArea"; self._clickOverlay.BackgroundTransparency=1; self._clickOverlay.Text=""; self._clickOverlay.AutoButtonColor=false; self._clickOverlay.Size=U2(1,-48,1,0); self._clickOverlay.Position=U3(0,0); self._clickOverlay.ZIndex=2; self._clickOverlay.Parent=C
            Tk(self._clickOverlay.MouseButton1Click:Connect(function() if self._alive and self._callback then SafeCall("Notification.Callback",self._callback,self) end end))
        end
        return true
    end
    function N:SetDuration(v)
        if self._timerThread then pcall(function() task.cancel(self._timerThread) end) end
        self._timerThread=nil
        local d=ma(0,tn(v) or 0)
        if d>0 then self._timerThread=task.delay(d,function() self:Destroy() end) end
        return self
    end
    function N:Refresh(v)
        if type(v)=="table" then
            if v.Title~=nil then self:SetTitle(v.Title) end
            if v.Content~=nil or v.Description~=nil then self:SetContent(v.Content or v.Description) end
            if v.Type then self:SetType(v.Type) end
            if v.Duration~=nil then self:SetDuration(v.Duration) end
        end
        return self
    end
    function N:Destroy()
        if not self._alive or self._closing then return false end
        self._closing=true
        self._alive=false
        if self._timerThread then pcall(function() task.cancel(self._timerThread) end) end
        DetachN(self)
        FT.T(C,{BackgroundTransparency=1},.25,nil,nil,"Notify")
        local dt2=C:GetDescendants()
        for i=1,#dt2 do
            local d=dt2[i]
            if d:IsA("TextLabel") or d:IsA("TextButton") then FT.T(d,{TextTransparency=1},.2,nil,nil,"Notify") end
        end
        task.delay(.3,function()
            if C and C.Parent then C:Destroy() end
            if W2 and W2.Parent then W2:Destroy() end
        end)
    end
    Tk(CB.MouseButton1Click:Connect(function() N:Destroy() end))
    if not persist and time>0 then N:SetDuration(time) end
    ST.ActiveNotif[#ST.ActiveNotif+1]=N
    ST.ActiveCount=ST.ActiveCount+1
    return N
end

LuaNotify=setmetatable({}, {__call=function(_,cfg) return LuaNotifyImpl(cfg) end})

LuaNotify.Success=function(content,title,duration) return LuaNotify({Type="Success",Title=title or "Sucesso",Content=content,Duration=duration}) end
LuaNotify.Info=function(content,title,duration) return LuaNotify({Type="Info",Title=title or CFG.Name,Content=content,Duration=duration}) end
LuaNotify.Warning=function(content,title,duration) return LuaNotify({Type="Warning",Title=title or "Aviso",Content=content,Duration=duration}) end
LuaNotify.Error=function(content,title,duration) return LuaNotify({Type="Error",Title=title or "Erro",Content=content,Duration=duration,Persist=duration==0}) end
LuaNotify.Loading=function(content,title) return LuaNotify({Type="Loading",Title=title or "Processando",Content=content,Persist=true}) end
LuaNotify.Option=function(name,enabled,duration) return LuaNotify({Type="Option",Title=ts(name or "Opção"),Content=enabled and "Ativado" or "Desativado",Duration=duration or 2,DedupeKey="OPTION:"..ts(name)}) end
LuaNotify.Debug=function(content,title,duration) return LuaNotify({Type="Debug",Title=title or "Debug",Content=content,Duration=duration or 3}) end

local function VColor(v)
    v=v or "Primary"
    if v=="Primary" then return CFG.Purple,WH end
    if v=="Secondary" then return CFG.BgButton,CFG.Text end
    if v=="Destructive" then return CFG.Red,WH end
    return c3rgb(40,30,50),CFG.Text
end
local function NewDialog(cfg)
    cfg=cfg or{}
    if ST.Destroyed then return nil end
    if ST.ActiveDialog and ST.ActiveDialog._alive then pcall(function() ST.ActiveDialog:Close(true) end) end
    CloseDropdowns()
    local ov=I("TextButton")
    ov.BackgroundColor3=CFG.ModalOverlay
    ov.BackgroundTransparency=.55
    ov.BorderSizePixel=0
    ov.Text=""
    ov.AutoButtonColor=false
    ov.Size=Uv(1,1)
    ov.ZIndex=1
    ov.Parent=UI.DGui
    local Box=I("TextButton")
    Box.BackgroundColor3=CFG.PopupBg
    Box.BorderSizePixel=0
    Box.AnchorPoint=V2(.5,.5)
    Box.Position=Uv(.5,.5)
    Box.Text=""
    Box.AutoButtonColor=false
    Box.Size=U3(400,0)
    Box.AutomaticSize=Enum.AutomaticSize.Y
    Box.ZIndex=2
    Box.Active=true
    Box.Parent=ov
    FT.C(Box,14)
    FT.S(Box,CFG.Stroke,1)
    Reg(Box,"BackgroundColor3","PopupBg")
    local pad=I("UIPadding")
    pad.PaddingTop=Un(0,22)
    pad.PaddingBottom=Un(0,22)
    pad.PaddingLeft=Un(0,22)
    pad.PaddingRight=Un(0,22)
    pad.Parent=Box
    local lay=I("UIListLayout")
    lay.SortOrder=Enum.SortOrder.LayoutOrder
    lay.Padding=Un(0,12)
    lay.Parent=Box
    local TL=FT.L(Box,cfg.Title or "Dialog",17,CFG.Text)
    TL.Size=U2(1,0,0,30)
    TL.LayoutOrder=1
    TL.Font=Enum.Font.GothamBold
    Reg(TL,"TextColor3","Text")
    local CL=FT.L(Box,cfg.Content or "",13,CFG.SubText)
    CL.Size=U2(1,0,0,0)
    CL.AutomaticSize=Enum.AutomaticSize.Y
    CL.LayoutOrder=2
    CL.TextWrapped=true
    CL.TextYAlignment=Enum.TextYAlignment.Top
    Reg(CL,"TextColor3","SubText")
    local BR=I("Frame")
    BR.BackgroundTransparency=1
    BR.Size=U2(1,0,0,40)
    BR.LayoutOrder=3
    BR.Parent=Box
    local bl=I("UIListLayout")
    bl.FillDirection=Enum.FillDirection.Horizontal
    bl.HorizontalAlignment=Enum.HorizontalAlignment.Right
    bl.VerticalAlignment=Enum.VerticalAlignment.Center
    bl.Padding=Un(0,8)
    bl.SortOrder=Enum.SortOrder.LayoutOrder
    bl.Parent=BR
    local self={_alive=true,_closing=false,_result=nil,_dismissible=cfg.Dismissible~=false,_buttons=0,_buttonRefs={},_buttonConfigs={}}
    local function close(immediate)
        if not self._alive or self._closing then return end
        self._closing=true
        self._alive=false
        -- v5.1.4: fade out com key própria
        FT.T(ov,{BackgroundTransparency=1},.2,nil,nil,"Dialog")
        FT.T(Box,{BackgroundTransparency=1},.2,nil,nil,"Dialog")
        if immediate then
            if ov and ov.Parent then ov:Destroy() end
        else
            task.delay(.25,function() if ov and ov.Parent then ov:Destroy() end end)
        end
        if ST.ActiveDialog==self then ST.ActiveDialog=nil end
        return true
    end
    function self:Close(immediate) close(immediate==true) end
    function self:Dismiss() close() end
    function self:Show() end
    function self:SetTitle(v) if TL and TL.Parent then TL.Text=ts(v or "") end return true end
    function self:SetDescription(v) if CL and CL.Parent then CL.Text=ts(v or "") end return true end
    function self:SetButtonDisabled(id,disabled)
        local ref=self._buttonRefs[id]
        if not ref or not ref.Button then return false end
        local b=ref.Button
        ref.Disabled=disabled==true
        b.Active=not ref.Disabled
        b.AutoButtonColor=false
        b.BackgroundTransparency=ref.Disabled and .55 or 0
        ref.Label.TextTransparency=ref.Disabled and .35 or 0
        return true
    end
    function self:SetButtonOrder(id,order)
        local ref=self._buttonRefs[id]
        if not ref or not ref.Button then return false end
        ref.Button.LayoutOrder=tn(order) or ref.Button.LayoutOrder
        return true
    end
    function self:AddFooterButton(id,bc)
        if type(id)~="string" then return nil end
        bc=bc or {}
        if self._buttonRefs[id] then return self._buttonRefs[id].Button end
        local bg,fg=VColor(bc.Variant)
        local btnTitle=bc.Title or id
        local totalW=ma(88,#btnTitle*7+54)
        local b=I("TextButton")
        b.BackgroundColor3=bg b.Text="" b.AutoButtonColor=false b.Size=U3(totalW,42) b.LayoutOrder=tn(bc.Order) or (self._buttons+1) b.ZIndex=3 b.Active=true b.Parent=BR
        FT.C(b,8)
        local bt=FT.L(b,btnTitle,13,fg) bt.TextXAlignment=Enum.TextXAlignment.Center bt.Size=U2(1,0,1,0) bt.Font=Enum.Font.GothamBold
        self._buttons=self._buttons+1
        self._buttonRefs[id]={Button=b,Label=bt,Disabled=false,Config=bc}
        self._buttonConfigs[id]=bc
        Tk(b.MouseEnter:Connect(function() if self._buttonRefs[id] and not self._buttonRefs[id].Disabled then FT.T(b,{BackgroundColor3=bg:Lerp(WH,.15)},.15) end end))
        Tk(b.MouseLeave:Connect(function() if self._buttonRefs[id] and not self._buttonRefs[id].Disabled then FT.T(b,{BackgroundColor3=bg},.15) end end))
        Tk(b.MouseButton1Click:Connect(function()
            local ref=self._buttonRefs[id]
            if not self._alive or not ref or ref.Disabled then return end
            local waitTime=tn(bc.WaitTime) or 0
            if waitTime>0 then
                b.Active=false ref.Disabled=true b.BackgroundTransparency=.55
                task.delay(waitTime,function() if self._alive and b.Parent then ref.Disabled=false b.Active=true b.BackgroundTransparency=0 end end)
                return
            end
            self._result=bc.Result or bc.Id or id
            if bc.Callback then SafeCall("Dialog:"..id,bc.Callback,self) end
            if bc.Close~=false then local didClose=close() if didClose and cfg.OnClose then SafeCall("Dialog.OnClose",cfg.OnClose,self._result) end end
        end))
        return b
    end
    function self:RemoveFooterButton(id)
        local ref=self._buttonRefs[id]
        if not ref then return false end
        if ref.Button and ref.Button.Parent then ref.Button:Destroy() end
        self._buttonRefs[id]=nil self._buttonConfigs[id]=nil
        return true
    end
    Tk(ov.MouseButton1Click:Connect(function() if self._dismissible and not self._closing then self._result="dismissed" local didClose=close() if didClose and cfg.OnClose then SafeCall("Dialog.OnClose",cfg.OnClose,self._result) end end end))
    local btns=cfg.Buttons or {}
    if #btns==0 then btns={{Title=cfg.CloseText or "OK",Variant="Primary"}} end
    for i=1,#btns do
        local bc=type(btns[i])=="table" and btns[i] or {}
        self._buttons=self._buttons+1
        local bg,fg=VColor(bc.Variant)
        local btnTitle=bc.Title or "Button"
        local textW=#btnTitle*7+24
        local totalW=ma(88,textW+30)
        local b=I("TextButton")
        b.BackgroundColor3=bg
        b.Text=""
        b.AutoButtonColor=false
        b.Size=U3(totalW,42)
        b.LayoutOrder=i
        b.ZIndex=3
        b.Active=true
        b.Parent=BR
        FT.C(b,8)
        local bt=FT.L(b,btnTitle,13,fg)
        bt.TextWrapped=false
        bt.TextXAlignment=Enum.TextXAlignment.Center
        bt.Size=U2(1,0,1,0)
        bt.Font=Enum.Font.GothamBold
        Tk(b.MouseEnter:Connect(function() FT.T(b,{BackgroundColor3=bg:Lerp(WH,.15)},.15) end))
        Tk(b.MouseLeave:Connect(function() FT.T(b,{BackgroundColor3=bg},.15) end))
        local bid=ts(bc.Id or bc.Name or bc.Title or i)
        self._buttonRefs[bid]={Button=b,Label=bt,Disabled=false,Config=bc}
        self._buttonConfigs[bid]=bc
        Tk(b.MouseButton1Click:Connect(function()
            local ref=self._buttonRefs[bid]
            if not self._alive or not ref or ref.Disabled then return end
            local waitTime=tn(bc.WaitTime) or 0
            if waitTime>0 then
                ref.Disabled=true b.Active=false b.BackgroundTransparency=.55
                task.delay(waitTime,function() if self._alive and b.Parent then ref.Disabled=false b.Active=true b.BackgroundTransparency=0 end end)
                return
            end
            self._result=bc.Result or bc.Id or bc.Title or i
            if bc.Callback then SafeCall("Dialog:"..ts(btnTitle),bc.Callback,self) end
            if self._result=="cancel" or bc.Close~=false then
                local didClose=close()
                if didClose and cfg.OnClose then SafeCall("Dialog.OnClose",cfg.OnClose,self._result) end
            end
        end))
    end
    -- entrada
    ov.BackgroundTransparency=1
    Box.BackgroundTransparency=1
    FT.T(ov,{BackgroundTransparency=.55},.2,nil,nil,"Dialog")
    FT.T(Box,{BackgroundTransparency=0},.2,nil,nil,"Dialog")
    ST.ActiveDialog=self
    return self
end

local function Confirm(cfg)
    cfg=cfg or {}
    local result=false
    local done=false
    local d=NewDialog({
        Title=cfg.Title or "Confirmar ação",
        Content=cfg.Content or "Tem certeza que deseja continuar?",
        Dismissible=cfg.Dismissible==true,
        Buttons={
            {Title=cfg.CancelText or "Cancelar",Variant="Secondary",Result="cancel",Callback=function() result=false if cfg.OnCancel then SafeCall("Confirm.OnCancel",cfg.OnCancel) end end},
            {Title=cfg.ConfirmText or "Confirmar",Variant=cfg.Variant or "Primary",Result="confirm",Callback=function() result=true if cfg.OnConfirm then SafeCall("Confirm.OnConfirm",cfg.OnConfirm) end end},
        },
        OnClose=function(r) done=true if r=="cancel" or r=="dismissed" then result=false end if cfg.OnClose then SafeCall("Confirm.OnClose",cfg.OnClose,result) end end,
    })
    if not d then return nil end
    function d:GetResult() return result end
    function d:IsDone() return done end
    return d
end

local function Choice(cfg)
    cfg=cfg or{}
    local options=cfg.Options or cfg.Buttons or {}
    local buttons={}
    for i=1,#options do
        local o=type(options[i])=="table" and options[i] or {Title=ts(options[i])}
        buttons[i]={Title=o.Title or ("Opção "..i),Variant=o.Variant or "Secondary",Result=o.Result or o.Id or i,Callback=o.Callback,Close=o.Close}
    end
    if #buttons==0 then buttons={{Title="OK",Variant="Primary",Result="ok"}} end
    return NewDialog({Title=cfg.Title or "Escolha",Content=cfg.Content or "Selecione uma opção.",Dismissible=cfg.Dismissible~=false,Buttons=buttons,OnClose=cfg.OnClose})
end

local function AttachTooltip(target,textGetter,disabledGetter)
    if not target or not UI.OGui then return function() end end
    local tip=I("TextLabel")
    tip.Name="LuaTooltip"
    tip.BackgroundColor3=CFG.PopupBg
    tip.TextColor3=CFG.Text
    tip.Font=Enum.Font.GothamMedium
    tip.TextSize=12
    tip.TextWrapped=true
    tip.TextXAlignment=Enum.TextXAlignment.Left
    tip.TextYAlignment=Enum.TextYAlignment.Center
    tip.BorderSizePixel=0
    tip.Visible=false
    tip.ZIndex=1000
    tip.Parent=UI.OGui
    FT.C(tip,7)
    Reg(tip,"BackgroundColor3","PopupBg")
    Reg(tip,"TextColor3","Text")
    local function hide() tip.Visible=false end
    local function show()
        local txt=type(textGetter)=="function" and textGetter() or textGetter
        if type(txt)~="string" or txt=="" then hide() return end
        tip.Text=txt
        tip.Size=U3(math.clamp(#txt*6+24,120,320),36)
        local ap=target.AbsolutePosition local as=target.AbsoluteSize local vp=GetVP()
        local x=cl(ap.X,6,ma(6,vp.X-tip.AbsoluteSize.X-6))
        local y=ap.Y+as.Y+6
        if y+tip.AbsoluteSize.Y>vp.Y-6 then y=ap.Y-tip.AbsoluteSize.Y-6 end
        tip.Position=U3(x,y)
        tip.Visible=true
    end
    local c1=target.MouseEnter:Connect(show)
    local c2=target.MouseLeave:Connect(hide)
    local c3=target.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch then
            task.delay(.35,function() if target.Parent then show() end end)
        end
    end)
    local c4=target.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Touch then hide() end
    end)
    return function() pcall(function() c1:Disconnect() end) pcall(function() c2:Disconnect() end) pcall(function() c3:Disconnect() end) pcall(function() c4:Disconnect() end) if tip.Parent then tip:Destroy() end end
end

local El={}
local function RegEl(idx,t,g,s,ex)
    local previous=ST.Elements[idx]
    if previous and previous.Destroy then pcall(function() previous:Destroy() end) end
    for i=#ST.ElementOrder,1,-1 do
        if ST.ElementOrder[i]==idx then table.remove(ST.ElementOrder,i) end
    end
    local e={Type=t,Get=g,Set=s,Default=nil,_OnChanged={},_Destroyed=false}
    if ex then for k,v in pairs(ex) do e[k]=v end end
    if e.Get then local ok,v=pcall(e.Get) if ok then e.Default=v end end
    function e:OnChanged(fn)
        if type(fn)~="function" or self._Destroyed then return {Disconnect=function() end} end
        local rec={Fn=fn,Active=true}
        self._OnChanged[#self._OnChanged+1]=rec
        return {Disconnect=function() rec.Active=false end}
    end
    function e:_EmitChanged(...)
        if self._Destroyed then return end
        for i=#self._OnChanged,1,-1 do
            local rec=self._OnChanged[i]
            if type(rec)=="table" and rec.Active and type(rec.Fn)=="function" then SafeCall("OnChanged:"..ts(idx),rec.Fn,...)
            else table.remove(self._OnChanged,i) end
        end
        if type(self._CallbackOverride)=="function" then SafeCall("Callback:"..ts(idx),self._CallbackOverride,...) end
    end
    function e:GetValue()
        if self.Get then local ok,v=pcall(self.Get) if ok then return v end end
        return self.Value
    end
    function e:SetValue(v) if self.Set then return self.Set(v) end end
    function e:GetTitle()
        if self._Label and self._Label.Parent then return self._Label.Text end
        return self.Name or self.Index or idx
    end
    function e:SetTitle(v) return self:SetText(v) end
    function e:SetText(v) if self._Label and self._Label.Parent then self._Label.Text=ts(v or "") return true end self.Name=ts(v or "") return true end
    function e:SetDescription(v) self.Description=ts(v or "") if self._Description and self._Description.Parent then self._Description.Text=self.Description end return true end
    function e:GetState()
        return {Type=self.Type,Value=self:GetValue(),Visible=self.Visible~=false,Disabled=self.Disabled==true,Focused=self.Focused==true,Title=self:GetTitle(),Description=self.Description}
    end
    function e:SetCallback(fn)
        if fn~=nil and type(fn)~="function" then return false,"callback inválido" end
        self._CallbackOverride=fn
        return true
    end
    function e:SetDisabled(v) self.Disabled=v==true if self._ApplyDisabled then self._ApplyDisabled(self.Disabled) end return true end
    function e:SetVisible(v) self.Visible=v==true if self._Frame and self._Frame.Parent then self._Frame.Visible=self.Visible end return true end
    function e:DependsOn(source,expected,mode,inverse)
        if not source or type(source.Get)~="function" then return false end
        self._RuleDeps=self._RuleDeps or {}
        self._RuleConns=self._RuleConns or {}
        self._RuleMode=mode or "AND"
        local dep={Source=source,Expected=expected,Inverse=inverse==true}
        self._RuleDeps[#self._RuleDeps+1]=dep
        if type(source.OnChanged)=="function" then self._RuleConns[#self._RuleConns+1]=source:OnChanged(function() self:RefreshRules() end) end
        self:RefreshRules()
        return true
    end
    function e:RefreshRules()
        if self._Destroyed then return false end
        local deps=self._RuleDeps
        if deps and #deps>0 then
            local all=true; local any=false
            for i=1,#deps do
                local d=deps[i]; local ok,v=pcall(d.Source.Get); local match=ok and (d.Expected==nil and v or v==d.Expected)
                if d.Inverse then match=not match end
                if match then any=true else all=false end
            end
            local enabled=(self._RuleMode=="OR") and any or all
            if self.SetVisible and self._RuleVisibility~=false then self:SetVisible(enabled) end
            if self.SetDisabled and self._RuleDisabled~=false then self:SetDisabled(not enabled) end
        end
        if type(self._VisibleWhen)=="function" then local ok,v=pcall(self._VisibleWhen,self); self:SetVisible(ok and v==true) end
        if type(self._DisabledWhen)=="function" then local ok,v=pcall(self._DisabledWhen,self); self:SetDisabled(ok and v==true) end
        return true
    end
    function e:VisibleWhen(fn)
        if type(fn)~="function" then return false end
        self._VisibleWhen=fn; self._RuleVisibility=true; self:RefreshRules(); return true
    end
    function e:DisabledWhen(fn)
        if type(fn)~="function" then return false end
        self._DisabledWhen=fn; self._RuleDisabled=true; self:RefreshRules(); return true
    end
    function e:Destroy()
        if self._Destroyed then return false end
        self._Destroyed=true
        if self._RuleConns then for i=#self._RuleConns,1,-1 do pcall(function() self._RuleConns[i]:Disconnect() end); self._RuleConns[i]=nil end end
        if self._Cleanup then pcall(self._Cleanup) end
        if self._Frame and self._Frame.Parent then self._Frame:Destroy() end
        if ST.Elements[idx]==self then ST.Elements[idx]=nil end
        for i=#ST.ElementOrder,1,-1 do if ST.ElementOrder[i]==idx then table.remove(ST.ElementOrder,i) break end end
        table.clear(self._OnChanged)
        return true
    end
    ST.Elements[idx]=e
    ST.ElementOrder[#ST.ElementOrder+1]=idx
    return e
end

function El.Toggle(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    opts.Name=opts.Name or opts.Text or "Toggle"
    local idx=opts.Index or ("Toggle_"..ts(#ST.ElementOrder+1))
    local st=opts.Default==true
    local disabled=opts.Disabled==true
    local visible=opts.Visible~=false
    local cb=opts.Callback
    local R2,RS=FT.Card(parent,50)
    if not R2 then return nil end
    local L=FT.L(R2,opts.Name,14,opts.Risky and CFG.DangerText or CFG.Text)
    L.Position=U3(16,0); L.Size=U2(1,-90,1,0); Reg(L,"TextColor3",opts.Risky and "DangerText" or "Text")
    local SW=I("TextButton"); SW.Text=""; SW.AutoButtonColor=false; SW.Size=U3(48,26); SW.AnchorPoint=V2(1,.5); SW.Position=U2(1,-14,.5,0); SW.Parent=R2; FT.C(SW,13)
    local K=I("Frame"); K.BackgroundColor3=WH; K.Size=U3(20,20); K.Parent=SW; FT.C(K,10)
    local KON,KOFF=U2(1,-23,.5,-10),U3(3,3)
    local function visual(v)
        st=v; SW.BackgroundColor3=disabled and CFG.Stroke or (st and CFG.Purple or CFG.BgButton); K.Position=st and KON or KOFF
        if disabled then L.TextTransparency=.45 else L.TextTransparency=0 end
    end
    local function applyDisabled(v)
        disabled=v==true; SW.Active=not disabled; R2.Active=not disabled; visual(st)
    end
    local E=nil
    local function set(v)
        if disabled then return false end
        v=v==true; if st==v then return true end
        local old=st; visual(v)
        local ok=true
        if cb then ok=SafeCall("Toggle:"..ts(idx),cb,st) end
        if not ok then visual(old); return false end
        if E then E:_EmitChanged(st) end
        LuaNotify.Option(opts.Name,st)
        return true
    end
    local rH=I("TextButton"); rH.BackgroundTransparency=1; rH.Text=""; rH.AutoButtonColor=false; rH.Size=U2(1,-70,1,0); rH.ZIndex=2; rH.Parent=R2
    E=RegEl(idx,"Toggle",function() return st end,set,{Frame=R2,Label=L})
    if type(opts.OnChanged)=="function" then E:OnChanged(opts.OnChanged) end
    local oldEmit=E._EmitChanged
    -- keep callback and OnChanged separate; Callback is the legacy hook, OnChanged is additive.
    local function emit(v) oldEmit(E,v) end
    E._EmitChanged=function(_,v) emit(v) end
    E._ApplyDisabled=applyDisabled; E.Disabled=disabled; E.Visible=visible; E.Risky=opts.Risky==true
    E.SetValue=function(self,v) return set(v) end
    E.SetText=function(self,v) L.Text=ts(v or ""); return true end
    E.SetDisabled=function(self,v) applyDisabled(v); self.Disabled=v==true; return true end
    E.SetVisible=function(self,v) R2.Visible=v==true; self.Visible=v==true; return true end
    Tk(rH.MouseButton1Click:Connect(function() set(not st) end)); Tk(SW.MouseButton1Click:Connect(function() set(not st) end))
    local cleanupTip=AttachTooltip(R2,function() return disabled and opts.DisabledTooltip or opts.Tooltip end)
    E._Cleanup=function() cleanupTip(); if E._KeyPicker and E._KeyPicker.Destroy then E._KeyPicker:Destroy() end; if E._ColorPicker and E._ColorPicker.Destroy then E._ColorPicker:Destroy() end end
    function E:AddColorPicker(colorId,cfg2)
        cfg2=cfg2 or {}; cfg2.Index=cfg2.Index or colorId; local h=El.ColorPicker(R2.Parent,cfg2); E._ColorPicker=h; return h
    end
    function E:AddKeyPicker(keyId,cfg2)
        cfg2=cfg2 or {}; local cur=cfg2.Default or Enum.KeyCode.Unknown; local listening=false; local conn
        local K=I("TextButton"); K.Name="KeyPicker"; K.Text=type(cur)=="EnumItem" and cur.Name or ts(cur); K.TextSize=10; K.Font=Enum.Font.GothamBold; K.TextColor3=CFG.Text; K.BackgroundColor3=CFG.BgButton; K.AutoButtonColor=false; K.Size=U3(72,28); K.AnchorPoint=V2(1,.5); K.Position=U2(1,-8,.5,0); K.Parent=R2; FT.C(K,7); L.Size=U2(1,-100,1,0); L.TextXAlignment=Enum.TextXAlignment.Left
        local function stop() listening=false; if conn then conn:Disconnect(); conn=nil end; K.Text=type(cur)=="EnumItem" and cur.Name or ts(cur) end
        Tk(K.MouseButton1Click:Connect(function() if listening or disabled then return end; listening=true; K.Text="Press..."; conn=S.U.InputBegan:Connect(function(inp,gpe) if gpe then return end; if inp.KeyCode==Enum.KeyCode.Escape then stop(); return end; if inp.UserInputType==Enum.UserInputType.Keyboard then cur=inp.KeyCode; stop(); if cfg2.Callback then SafeCall("KeyPicker:"..ts(keyId),cfg2.Callback,true) end end end) end))
        local h={Value=cur,SetValue=function(self,v) cur=v; self.Value=v; stop(); return true end,GetValue=function(self) return cur end,Destroy=function(self) stop(); if K.Parent then K:Destroy() end end}
        E._KeyPicker=h; return h
    end
    FT.H(R2,RS); R2.Visible=visible; applyDisabled(disabled); visual(st)
    return E
end


function El.Checkbox(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    opts.Name=opts.Name or opts.Text or "Toggle"
    local idx=opts.Index or ("Checkbox_"..ts(#ST.ElementOrder+1))
    local st=opts.Default==true
    local disabled=opts.Disabled==true
    local visible=opts.Visible~=false
    local cb=opts.Callback
    local R2,RS=FT.Card(parent,44)
    if not R2 then return nil end
    local Box=I("TextButton"); Box.Text=""; Box.AutoButtonColor=false; Box.Size=U3(20,20); Box.Position=U3(16,12); Box.Parent=R2; FT.C(Box,5)
    local Check=FT.L(Box,"✓",13,WH); Check.Size=U2(1,0,1,0); Check.Visible=st
    local L=FT.L(R2,opts.Name,14,opts.Risky and CFG.DangerText or CFG.Text); L.Position=U3(48,0); L.Size=U2(1,-64,1,0); Reg(L,"TextColor3",opts.Risky and "DangerText" or "Text")
    local function visual(v)
        st=v==true
        Box.BackgroundColor3=disabled and CFG.Stroke or (st and CFG.Purple or CFG.BgButton)
        Check.Visible=st
        L.TextTransparency=disabled and .45 or 0
    end
    local E
    local function applyDisabled(vd) disabled=vd==true; Box.Active=not disabled; R2.Active=not disabled; visual(st) end
    local function set(v)
        if disabled then return false end
        v=v==true; if v==st then return true end
        local old=st; visual(v)
        if cb then local ok=SafeCall("Checkbox:"..ts(idx),cb,st); if not ok then visual(old); return false end end
        if E then E:_EmitChanged(st) end
        return true
    end
    E=RegEl(idx,"Checkbox",function() return st end,set,{Frame=R2,Label=L})
    E.Disabled=disabled; E.Visible=visible; E.Risky=opts.Risky==true; E._ApplyDisabled=applyDisabled
    E.SetValue=function(self,v) return set(v) end
    E.SetText=function(self,v) L.Text=ts(v or ""); return true end
    E.SetDisabled=function(self,v) applyDisabled(v); self.Disabled=disabled; return true end
    E.SetVisible=function(self,v) R2.Visible=v==true; self.Visible=v==true; return true end
    local cleanupTip=AttachTooltip(R2,function() return disabled and opts.DisabledTooltip or opts.Tooltip end)
    E._Cleanup=function() cleanupTip() end
    Tk(Box.MouseButton1Click:Connect(function() set(not st) end))
    Tk(R2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then set(not st) end end))
    FT.H(R2,RS); R2.Visible=visible; applyDisabled(disabled); visual(st)
    return E
end

function El.ColorPicker(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    local idx=opts.Index or ("ColorPicker_"..ts(#ST.ElementOrder+1))
    local color=typeof(opts.Default)=="Color3" and opts.Default or Color3.new(1,1,1)
    local transparency=ma(0,ma(1,tn(opts.Transparency) or 0))
    local title=opts.Title
    local resizable=opts.Resizable~=false
    local cb=type(opts.Callback)=="function" and opts.Callback or nil
    local changed=type(opts.Changed)=="function" and opts.Changed or nil
    local R2,RS=FT.Card(parent,50)
    if not R2 then return nil end
    local L=FT.L(R2,title or "Color",14,CFG.Text); L.Position=U3(16,0); L.Size=U2(1,-72,1,0); Reg(L,"TextColor3","Text")
    local sw=I("TextButton"); sw.Text=""; sw.AutoButtonColor=false; sw.Size=U3(34,30); sw.AnchorPoint=V2(1,.5); sw.Position=U2(1,-14,.5,0); sw.Parent=R2; FT.C(sw,7)
    local function applySwatch() sw.BackgroundColor3=color; sw.BackgroundTransparency=transparency end
    applySwatch()
    local popup=nil; local conns={}; local open=false
    local E=nil
    local function cleanup()
        for i=#conns,1,-1 do pcall(function() conns[i]:Disconnect() end); conns[i]=nil end
        if popup and popup.Parent then popup:Destroy() end
        popup=nil; open=false
    end
    local function emit()
        applySwatch()
        if cb then SafeCall("ColorPicker:"..ts(idx),cb,color,transparency) end
        if changed then SafeCall("ColorPickerChanged:"..ts(idx),changed,color,transparency) end
        local e=ST.Elements[idx]; if e and e._EmitChanged then e:_EmitChanged(color,transparency) end
    end
    local function hsv() return Color3.toHSV(color) end
    local function makeRow(parent,y,label,value,minv,maxv,setter)
        local t=FT.L(parent,label,11,CFG.SubText); t.Position=U3(10,y); t.Size=U3(38,24)
        local b=I("TextButton"); b.Text=""; b.AutoButtonColor=false; b.BackgroundColor3=CFG.Field; b.Size=U2(1,-58,0,20); b.Position=U3(48,y+2); b.Parent=parent; FT.C(b,5); Reg(b,"BackgroundColor3","Field")
        local fill=I("Frame"); fill.BackgroundColor3=CFG.Purple; fill.BorderSizePixel=0; fill.Size=U2((value-minv)/(maxv-minv),0,1,0); fill.Parent=b; FT.C(fill,5); Reg(fill,"BackgroundColor3","Purple")
        local val=FT.L(b,ts(math.floor(value*100+0.5)),10,CFG.Text); val.Size=U2(1,0,1,0); val.TextXAlignment=Enum.TextXAlignment.Right; val.Position=U3(-8,0)
        local function setFromX(x)
            local a=ma(0,ma(1,(x-b.AbsolutePosition.X)/ma(1,b.AbsoluteSize.X))); local v=minv+(maxv-minv)*a; setter(v); fill.Size=U2(a,0,1,0); val.Text=ts(math.floor(v*100+0.5)); emit()
        end
        local dragging=false
        local dragInput=nil
        conns[#conns+1]=b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragInput=i; setFromX(i.Position.X) end end)
        conns[#conns+1]=S.U.InputChanged:Connect(function(i) if not dragging then return end if i.UserInputType==Enum.UserInputType.Touch and i~=dragInput then return end if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then setFromX(i.Position.X) end end)
        conns[#conns+1]=S.U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if i.UserInputType==Enum.UserInputType.Touch and i~=dragInput then return end dragging=false; dragInput=nil end end)
    end
    local function build()
        cleanup()
        if not open then return end
        popup=I("Frame"); popup.Name="ColorPickerPopup"; popup.BackgroundColor3=CFG.PopupBg; popup.BorderSizePixel=0; popup.Parent=UI.OGui; popup.ZIndex=80; FT.C(popup,8); Reg(popup,"BackgroundColor3","PopupBg")
        local vp=GetVP()
        local swp=sw.AbsolutePosition; local sws=sw.AbsoluteSize
        local pw=resizable and 280 or 250; local ph=190
        local px=cl(swp.X,8,ma(8,vp.X-pw-8)); local py=swp.Y+sws.Y+4
        if py+ph>vp.Y-8 then py=swp.Y-ph-4 end
        py=cl(py,8,ma(8,vp.Y-ph-8))
        popup.Size=U3(pw,ph); popup.Position=U2(0,px,0,py)
        local ptitle=FT.L(popup,title or "Color Picker",13,CFG.Text); ptitle.Position=U3(12,8); ptitle.Size=U2(1,-24,0,22); Reg(ptitle,"TextColor3","Text")
        local H,Sv,V=Color3.toHSV(color)
        makeRow(popup,36,"H",H,0,1,function(v) local _,s2,v2=Color3.toHSV(color); color=Color3.fromHSV(v,s2,v2) end)
        makeRow(popup,70,"S",Sv,0,1,function(v) local h2,_,v2=Color3.toHSV(color); color=Color3.fromHSV(h2,v,v2) end)
        makeRow(popup,104,"V",V,0,1,function(v) local h2,s2,_=Color3.toHSV(color); color=Color3.fromHSV(h2,s2,v) end)
        if opts.Transparency~=nil then makeRow(popup,138,"A",1-transparency,0,1,function(v) transparency=1-v end) end
        local close=I("TextButton"); close.Text="Done"; close.TextColor3=CFG.Text; close.BackgroundColor3=CFG.BgButton; close.Size=U3(54,24); close.Position=U2(1,-66,1,-30); close.Parent=popup; FT.C(close,6); Reg(close,"BackgroundColor3","BgButton"); Reg(close,"TextColor3","Text")
        conns[#conns+1]=close.MouseButton1Click:Connect(cleanup)
    end
    conns[#conns+1]=sw.MouseButton1Click:Connect(function() open=not open; build() end)
    E=RegEl(idx,"ColorPicker",function() local h,s2,v=Color3.toHSV(color); return {H=h,S=s2,V=v,Color=color,Transparency=transparency} end,function(v,t)
        if typeof(v)=="Color3" then color=v; if tn(t) then transparency=ma(0,ma(1,t)) end
        elseif type(v)=="table" then local h=v.H or 0; local ss=v.S or v.s or 0; local vv=v.V or v.v or 0; color=Color3.fromHSV(h,ss,vv); if tn(t) then transparency=ma(0,ma(1,t)) elseif tn(v.Transparency) then transparency=ma(0,ma(1,v.Transparency)) end end
        applySwatch(); emit(); return true
    end,{Frame=R2,Label=L})
    E.Value=color; E.Transparency=transparency; E.Resizable=resizable
    E.SetValue=function(self,hsv,t) return self:SetValueRGB(Color3.fromHSV(hsv.H or 0,hsv.S or 0,hsv.V or 0),t) end
    E.SetValueRGB=function(self,c,t) if typeof(c)~="Color3" then return false end; color=c; if tn(t) then transparency=ma(0,ma(1,t)) end; self.Value=color; self.Transparency=transparency; emit(); return true end
    local baseOnChanged=E.OnChanged
    E.OnChanged=function(self,fn)
        if type(fn)=="function" then
            local rec={Fn=fn,Active=true}; self._ColorCallbacks=self._ColorCallbacks or {}; table.insert(self._ColorCallbacks,rec)
            local base=baseOnChanged(self,fn)
            return {Disconnect=function() rec.Active=false; if base and base.Disconnect then base.Disconnect() end end}
        end
        return baseOnChanged(self,fn)
    end
    local oldEmit=E._EmitChanged; E._EmitChanged=function(self,...) oldEmit(self,...); for _,rec in ipairs(self._ColorCallbacks or {}) do if rec.Active then SafeCall("ColorPickerOnChanged:"..ts(idx),rec.Fn,self.Value,self.Transparency) end end end
    E.SetText=function(self,v) L.Text=ts(v or ""); return true end
    E._Cleanup=function() cleanup() end
    FT.H(R2,RS)
    return E
end

function El.Dropdown(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    local idx=opts.Index or ("Dropdown_"..ts(#ST.ElementOrder+1))
    local values=type(opts.Values)=="table" and opts.Values or {}
    if opts.SpecialType=="Player" and next(values)==nil then
        values={}
        for _,pl in ipairs(S.P:GetPlayers()) do if not (opts.ExcludeLocalPlayer==true and pl==S.LP) then values[pl.Name]=pl.DisplayName end end
    elseif opts.SpecialType=="Team" and next(values)==nil then
        values={}
        local ok,Teams=pcall(game.GetService,game,"Teams")
        if ok and Teams then for _,team in ipairs(Teams:GetTeams()) do values[team.Name]=team.Name end end
    end
    local multi=opts.Multi==true
    local allowNull=opts.AllowNull==true
    local searchable=opts.Searchable==true
    local dragSelect=opts.DragSelect==true and multi
    local maxItems=ma(1,fl(tn(opts.MaxVisibleDropdownItems) or 8))
    local disabled=opts.Disabled==true
    local visible=opts.Visible~=false
    local cb=opts.Callback
    local fmtDisplay=type(opts.FormatDisplayValue)=="function" and opts.FormatDisplayValue or nil
    local fmtList=type(opts.FormatListValue)=="function" and opts.FormatListValue or nil
    local disabledValues=type(opts.DisabledValues)=="table" and opts.DisabledValues or {}
    local valueImages=type(opts.ValueImages)=="table" and opts.ValueImages or {}
    local keepDisabled=opts.KeepDisabledValuePosition==true
    local special=opts.SpecialType
    local excludeLocal=opts.ExcludeLocalPlayer==true
    local enableImages=opts.EnablePlayerImages==true
    local selected={}
    local conns={}
    local E
    local R2,RS=FT.Card(parent,58)
    if not R2 then return nil end
    local L=FT.L(R2,opts.Text or opts.Name or "Dropdown",13,CFG.Text)
    L.Position=U3(16,4); L.Size=U2(1,-32,0,20); Reg(L,"TextColor3","Text")
    local D=I("TextButton"); D.Text=""; D.AutoButtonColor=false; D.BackgroundColor3=CFG.Field; D.Size=U2(1,-32,0,30); D.Position=U3(16,26); D.Parent=R2; FT.C(D,7); Reg(D,"BackgroundColor3","Field")
    local DT=FT.L(D,"None",11,CFG.SubText); DT.Position=U3(10,0); DT.Size=U2(1,-38,1,0); DT.TextXAlignment=Enum.TextXAlignment.Left; Reg(DT,"TextColor3","SubText")
    local Arrow=FT.L(D,"▾",14,CFG.SubText); Arrow.Position=U2(1,-28,0,0); Arrow.Size=U3(22,30); Arrow.TextXAlignment=Enum.TextXAlignment.Center; Reg(Arrow,"TextColor3","SubText")
    local open=false; local popup=nil; local searchBox=nil; local rows={}; local popupConns={}; local dragDown=false; local entriesCache=nil
    local function disconnectPopup()
        for i=#popupConns,1,-1 do pcall(function() popupConns[i]:Disconnect() end); popupConns[i]=nil end
    end
    local function close()
        if not open then return end
        open=false; dragDown=false; disconnectPopup()
        if ST.OpenDropdown==E then ST.OpenDropdown=nil end
        if popup and popup.Parent then popup:Destroy() end
        popup=nil; searchBox=nil; rows={}; Arrow.Text="▾"
    end
    local function isDictionary(t)
        for k,v in pairs(t) do if type(k)~="number" then return true end end
        return false
    end
    local function entries()
        if entriesCache then return entriesCache end
        local out={}
        if isDictionary(values) then
            for k,v in pairs(values) do out[#out+1]={key=k,label=v} end
            if not keepDisabled then
                table.sort(out,function(a,b)
                    local ad=false; local bd=false
                    for x in pairs(disabledValues) do if x==a.key or x==a.label then ad=true end if x==b.key or x==b.label then bd=true end end
                    if ad~=bd then return not ad end
                    return ts(a.label)<ts(b.label)
                end)
            end
        else
            for i,v in ipairs(values) do out[#out+1]={key=v,label=v,index=i} end
            if not keepDisabled then
                local enabled,dis={},{ }
                for _,e in ipairs(out) do local isD=false for x in pairs(disabledValues) do if x==e.key or x==e.label then isD=true break end end if isD then dis[#dis+1]=e else enabled[#enabled+1]=e end end
                for _,e in ipairs(dis) do enabled[#enabled+1]=e end
                out=enabled
            end
        end
        entriesCache=out
        return out
    end
    local function isDisabledValue(key,label)
        for k,v in pairs(disabledValues) do if k==key or k==label or v==key or v==label then return true end end
        return false
    end
    local function normalizeKey(x)
        if type(x)=="number" and not isDictionary(values) then
            local es=entries(); local e=es[x]
            return e and e.key or x
        end
        return x
    end
    local function contains(x)
        x=normalizeKey(x)
        return selected[normalizeKey(x)]==true
    end
    local function selectedList()
        local out={}
        for _,e in ipairs(entries()) do if selected[e.key] then out[#out+1]=e.key end end
        return out
    end
    local function displayFor(key,label)
        local text=label
        if fmtDisplay then local ok,r=pcall(fmtDisplay,key) if ok and r~=nil then text=r end end
        return ts(text)
    end
    local function listDisplayFor(key,label)
        local text=label
        if fmtList then local ok,r=pcall(fmtList,label) if ok and r~=nil then text=r end end
        return ts(text)
    end
    local function refreshText()
        local active=selectedList()
        local text="None"
        if #active==0 then text=allowNull and "None" or "None"
        elseif multi then text=tostring(#active).." selected"
        else
            local k=active[1]
            for _,e in ipairs(entries()) do if e.key==k then text=displayFor(e.key,e.label); break end end
        end
        DT.Text=text
    end
    local function emit(old)
        if E then E:_EmitChanged(multi and selected or (selectedList()[1])) end
        if cb then
            local val=multi and selected or selectedList()[1]
            local ok=SafeCall("Dropdown:"..ts(idx),cb,val)
            if not ok then
                if old then selected=old end
                refreshText()
            end
        end
    end
    local function cloneSelected()
        local t={}; for k,v in pairs(selected) do t[k]=v end; return t
    end
    local function setValueInternal(val,silent)
        local old=cloneSelected()
        local nextSel={}
        if multi then
            if type(val)=="table" then
                local looksMap=false
                for k,v in pairs(val) do if v==true then looksMap=true; local nk=normalizeKey(k); nextSel[nk]=true end end
                if not looksMap then for _,x in ipairs(val) do local nk=normalizeKey(x); nextSel[nk]=true end end
            elseif val~=nil then nextSel[normalizeKey(val)]=true end
        else
            if type(val)=="table" then val=val[1] end
            if val~=nil then nextSel[normalizeKey(val)]=true end
        end
        for k in pairs(nextSel) do
            local found=false
            for _,e in ipairs(entries()) do if e.key==k then found=true; if isDisabledValue(e.key,e.label) then nextSel[k]=nil end; break end end
            if not found then nextSel[k]=nil end
        end
        if not allowNull and not multi and next(nextSel)==nil then
            local es=entries(); for _,e in ipairs(es) do if not isDisabledValue(e.key,e.label) then nextSel[e.key]=true; break end end
        end
        selected=nextSel; refreshText()
        local changed=false; for k in pairs(old) do if not selected[k] then changed=true end end for k in pairs(selected) do if not old[k] then changed=true end end
        if changed and not silent then emit(old) end
        return true
    end
    local function createPopup()
        close()
        open=true; ST.OpenDropdown=E; Arrow.Text="▴"
        popup=I("Frame"); popup.Name="DropdownPopup"; popup.BackgroundColor3=CFG.PopupBg; popup.BorderSizePixel=0; popup.ZIndex=200; popup.Parent=UI.OGui; FT.C(popup,8); Reg(popup,"BackgroundColor3","PopupBg")
        local abs=D.AbsolutePosition; local size=D.AbsoluteSize
        popup.Position=U2(0,abs.X,0,abs.Y+size.Y+4); popup.Size=U2(0,ma(180,size.X),0,36)
        local searchY=0
        if searchable then
            searchBox=I("TextBox"); searchBox.BackgroundColor3=CFG.Field; searchBox.BorderSizePixel=0; searchBox.PlaceholderText="Search..."; searchBox.Text=""; searchBox.TextColor3=CFG.Text; searchBox.PlaceholderColor3=CFG.SubText; searchBox.TextSize=11; searchBox.ClearTextOnFocus=false; searchBox.Size=U2(1,-12,0,30); searchBox.Position=U3(6,6); searchBox.Parent=popup; FT.C(searchBox,6); Reg(searchBox,"BackgroundColor3","Field"); Reg(searchBox,"TextColor3","Text"); Reg(searchBox,"PlaceholderColor3","SubText"); searchY=42
        end
        local scroll=I("ScrollingFrame"); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.Position=U3(6,searchY); scroll.Size=U2(1,-12,0,maxItems*32); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=U2(0,0,0,0); scroll.ScrollBarThickness=3; scroll.Parent=popup; scroll.ZIndex=201
        local layout=I("UIListLayout"); layout.Padding=Un(0,2); layout.Parent=scroll
        local function rebuild()
            for _,r in ipairs(rows) do if r.Parent then r:Destroy() end end; rows={}
            local q=searchBox and sl(searchBox.Text or "") or ""
            local count=0
            for _,e in ipairs(entries()) do
                local label=listDisplayFor(e.key,e.label)
                if q=="" or sl(ts(label)):find(q,1,true) then
                    count=count+1
                    local row=I("TextButton"); row.Name="Option"; row.Text=""; row.AutoButtonColor=false; row.BackgroundColor3=contains(e.key) and CFG.NavActive or CFG.Field; row.Size=U2(1,-2,0,30); row.Parent=scroll; row.ZIndex=202; FT.C(row,5)
                    local tx=FT.L(row,label,11,isDisabledValue(e.key,e.label) and CFG.SubText or CFG.Text); tx.Position=U3(9,0); tx.Size=U2(1,-18,1,0); tx.TextXAlignment=Enum.TextXAlignment.Left; Reg(tx,"TextColor3",isDisabledValue(e.key,e.label) and "SubText" or "Text")
                    local im=valueImages[e.key] or valueImages[e.label]
                    if special=="Player" and enableImages then
                        local pl=nil; for _,p in ipairs(S.P:GetPlayers()) do if p.Name==e.key or p.DisplayName==e.label then pl=p break end end
                        if pl then im="rbxthumb://type=AvatarHeadShot&id="..pl.UserId.."&w=48&h=48" end
                    end
                    if im then
                        local img=I("ImageLabel"); img.BackgroundTransparency=1; img.Image=ts(im); img.Size=U3(22,22); img.Position=U3(4,4); img.Parent=row; tx.Position=U3(32,0); tx.Size=U2(1,-40,1,0)
                    end
                    rows[#rows+1]=row
                    local conn=row.MouseButton1Click:Connect(function()
                        if isDisabledValue(e.key,e.label) then return end
                        if multi then
                            if selected[e.key] then selected[e.key]=nil else selected[e.key]=true end
                            refreshText(); rebuild(); emit(nil)
                        else
                            setValueInternal(e.key,false); close()
                        end
                    end)
                    popupConns[#popupConns+1]=conn
                    if dragSelect then
                        popupConns[#popupConns+1]=row.MouseEnter:Connect(function() if dragDown and not isDisabledValue(e.key,e.label) then selected[e.key]=true; refreshText(); row.BackgroundColor3=CFG.NavActive end end)
                    end
                end
            end
            local h=ma(32,maxItems*32+(searchable and 42 or 0)); popup.Size=U2(0,ma(180,D.AbsoluteSize.X),0,h)
        end
        if searchBox then popupConns[#popupConns+1]=searchBox:GetPropertyChangedSignal("Text"):Connect(rebuild) end
        popupConns[#popupConns+1]=S.U.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if not popup or not popup.Parent then close(); return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                local p=inp.Position; local pos=popup.AbsolutePosition; local sz=popup.AbsoluteSize
                if p.X<pos.X or p.X>pos.X+sz.X or p.Y<pos.Y or p.Y>pos.Y+sz.Y then close() end
                if dragSelect and p.X>=pos.X and p.X<=pos.X+sz.X and p.Y>=pos.Y and p.Y<=pos.Y+sz.Y then dragDown=true end
            end
        end)
        popupConns[#popupConns+1]=S.U.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragDown=false end end)
        rebuild()
    end
    Tk(D.MouseButton1Click:Connect(function() if disabled then return end; if open then close() else createPopup() end end))
    local function applyDisabled(v) disabled=v==true; D.Active=not disabled; R2.Active=not disabled; R2.BackgroundTransparency=disabled and .12 or 0; L.TextTransparency=disabled and .45 or 0 end
    local E2=RegEl(idx,"Dropdown",function() return multi and selected or selectedList()[1] end,function(v) return setValueInternal(v,false) end,{Frame=R2,Label=L})
    E=E2; E.Disabled=disabled; E.Visible=visible; E.Values=values; E.Multi=multi; E.AllowNull=allowNull; E.DragSelect=dragSelect
    E.SetValue=function(self,v) return setValueInternal(v,false) end
    E.SetValues=function(self,v)
        values=type(v)=="table" and v or {}
        entriesCache=nil
        self.Values=values
        local before=cloneSelected()
        local valid={}
        for _,e in ipairs(entries()) do if selected[e.key] then valid[e.key]=true end end
        selected=valid
        refreshText()
        local changed=false
        for k in pairs(before) do if not selected[k] then changed=true break end end
        if not changed then for k in pairs(selected) do if not before[k] then changed=true break end end end
        if changed then self:_EmitChanged(multi and selected or selectedList()[1]) end
        if open then createPopup() end
        return true
    end
    E.AddValues=function(self,v)
        if type(v)~="table" then return false end
        local dict2=isDictionary(values)
        entriesCache=nil
        if dict2 then for k,x in pairs(v) do if type(k)=="number" then values[x]=x else values[k]=x end end else for _,x in ipairs(v) do values[#values+1]=x end end
        self.Values=values; if open then createPopup() end; return true
    end
    E.SetDisabledValues=function(self,v) disabledValues=type(v)=="table" and v or {}; entriesCache=nil; self.DisabledValues=disabledValues; setValueInternal(multi and selected or selectedList()[1],true); if open then createPopup() end; return true end
    E.AddDisabledValues=function(self,v) local t=type(v)=="table" and v or {v}; entriesCache=nil; for _,x in ipairs(t) do disabledValues[x]=true end; self.DisabledValues=disabledValues; if open then createPopup() end; return true end
    E.SetValueImages=function(self,v) valueImages=type(v)=="table" and v or {}; self.ValueImages=valueImages; if open then createPopup() end; return true end
    E.AddValueImages=function(self,v) if type(v)~="table" then return false end; for k,x in pairs(v) do valueImages[k]=x end; self.ValueImages=valueImages; if open then createPopup() end; return true end
    E.SetText=function(self,v) L.Text=ts(v or ""); return true end
    E.SetDisabled=function(self,v) applyDisabled(v); self.Disabled=disabled; if disabled then close() end; return true end
    E.SetVisible=function(self,v) R2.Visible=v==true; self.Visible=v==true; if not self.Visible then close() end; return true end
    E.SetDragSelect=function(self,v) dragSelect=v==true and multi; self.DragSelect=dragSelect; return true end
    E.GetActiveValues=function(self,count) if count then local n=0 for _ in pairs(selected) do n=n+1 end return n end return multi and selected or selectedList()[1] end
    E._Cleanup=function() close(); for i=#conns,1,-1 do pcall(function() conns[i]:Disconnect() end) end end
    local cleanupTip=AttachTooltip(R2,function() return disabled and opts.DisabledTooltip or opts.Tooltip end)
    local oldCleanup=E._Cleanup; E._Cleanup=function() cleanupTip(); oldCleanup() end
    applyDisabled(disabled); R2.Visible=visible; refreshText()
    -- initial default: index, identity, or table of identities
    if opts.Default~=nil then setValueInternal(opts.Default,true) end
    local function refreshSpecialValues()
        if special=="Player" then
            local nv={}
            for _,pl in ipairs(S.P:GetPlayers()) do
                if not (excludeLocal and pl==S.LP) then nv[pl.Name]=pl.DisplayName end
            end
            values=nv
        elseif special=="Team" then
            local nv={}; local ok,Teams=pcall(game.GetService,game,"Teams")
            if ok and Teams then for _,team in ipairs(Teams:GetTeams()) do nv[team.Name]=team.Name end end
            values=nv
        else return end
        E.Values=values
        entriesCache=nil
        local valid={}
        for _,ent in ipairs(entries()) do if selected[ent.key] then valid[ent.key]=true end end
        selected=valid
        refreshText()
        if open then createPopup() end
    end
    if special=="Player" then
        conns[#conns+1]=S.P.PlayerAdded:Connect(refreshSpecialValues)
        conns[#conns+1]=S.P.PlayerRemoving:Connect(refreshSpecialValues)
    elseif special=="Team" then
        local ok,Teams=pcall(game.GetService,game,"Teams")
        if ok and Teams then
            conns[#conns+1]=Teams.ChildAdded:Connect(refreshSpecialValues)
            conns[#conns+1]=Teams.ChildRemoved:Connect(refreshSpecialValues)
        end
    end
    return E
end

function El.Slider(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    local idx=opts.Index or ("Slider_"..ts(#ST.ElementOrder+1))
    local mn=tn(opts.Min) or 0
    local mx=tn(opts.Max) or 100
    if mx<mn then mn,mx=mx,mn end
    if mx==mn then mx=mn+1 end
    local dec=ma(0,fl(tn(opts.Rounding) or tn(opts.Decimals) or 0))
    local prefix=ts(opts.Prefix or "")
    local suffix=ts(opts.Suffix or "")
    local compact=opts.Compact==true
    local hideMax=opts.HideMax==true
    local disabled=opts.Disabled==true
    local visible=opts.Visible~=false
    local cb=opts.Callback
    local formatter=type(opts.FormatDisplayValue)=="function" and opts.FormatDisplayValue or nil
    local v=cl(tn(opts.Default) or mn,mn,mx)
    local rng=mx-mn
    local inv=(rng>0) and (1/rng) or 0
    local function roundValue(n)
        local mult=10^dec
        return math.floor(n*mult+0.5)/mult
    end
    v=roundValue(v)
    local function displayValue(n)
        if formatter then
            local ok,res=pcall(formatter,n)
            if ok then return ts(res) end
        end
        local raw=(dec>0) and sf("%."..dec.."f",n) or ts(math.floor(n+0.5))
        return prefix..raw..suffix
    end
    local R2,RS=FT.Card(parent,60)
    if not R2 then return nil end
    local L=FT.L(R2,opts.Text or opts.Name or "Slider",13,CFG.Text)
    L.Position=U3(16,compact and 8 or 10)
    L.Size=U2(1,compact and -32 or -90,0,20)
    Reg(L,"TextColor3","Text")
    local VL=FT.L(R2,"",13,CFG.Purple)
    VL.Position=U2(1,-78,0,10)
    VL.Size=U3(68,20)
    VL.TextXAlignment=Enum.TextXAlignment.Right
    VL.Font=Enum.Font.GothamBold
    Reg(VL,"TextColor3","Purple")
    local function refreshText()
        local text=displayValue(v)
        if hideMax then
            VL.Text=text
        else
            local maxText=displayValue(mx)
            if formatter or prefix~="" or suffix~="" then
                VL.Text=text.." / "..maxText
            else
                VL.Text=text.." / "..maxText
            end
        end
    end
    refreshText()
    if compact then L.Visible=false; VL.Position=U2(1,-84,0,8); VL.Size=U3(76,20) end
    local Tk2=I("Frame")
    Tk2.BackgroundColor3=CFG.BgTrack
    Tk2.BorderSizePixel=0
    Tk2.Size=U2(1,-32,0,14)
    Tk2.Position=U3(16,38)
    Tk2.Parent=R2
    Tk2.Active=true
    Tk2.BackgroundTransparency=.5
    FT.C(Tk2,7)
    Reg(Tk2,"BackgroundColor3","BgTrack")
    local TkInner=I("Frame")
    TkInner.BackgroundColor3=CFG.BgTrack
    TkInner.BorderSizePixel=0
    TkInner.AnchorPoint=V2(.5,.5)
    TkInner.Position=Uv(.5,.5)
    TkInner.Size=U2(1,0,0,6)
    TkInner.Parent=Tk2
    FT.C(TkInner,3)
    Reg(TkInner,"BackgroundColor3","BgTrack")
    local F=I("Frame")
    F.BackgroundColor3=CFG.Purple
    F.BorderSizePixel=0
    F.AnchorPoint=V2(0,.5)
    F.Position=U2(0,0,.5,0)
    F.Size=U2((v-mn)*inv,0,0,6)
    F.Parent=Tk2
    FT.C(F,3)
    Reg(F,"BackgroundColor3","Purple")
    local function visual(nv)
        v=roundValue(cl(nv,mn,mx))
        local alpha=(v-mn)*inv
        FT.T(F,{Size=U2(alpha,0,0,6)},.12)
        refreshText()
        VL.TextTransparency=.35
        FT.T(VL,{TextTransparency=0},.16)
    end
    local E
    local function set(nv)
        if disabled then return false end
        nv=roundValue(cl(tn(nv) or mn,mn,mx))
        if nv==v then return true end
        local old=v
        visual(nv)
        if cb then
            local ok=SafeCall("Slider:"..ts(idx),cb,v)
            if not ok then visual(old); return false end
        end
        if E then E:_EmitChanged(v) end
        return true
    end
    local dr=false
    local dragInput=nil
    local function upd(i)
        if Tk2.AbsoluteSize.X<=0 then return end
        local rel=(i.Position.X-Tk2.AbsolutePosition.X)/Tk2.AbsoluteSize.X
        rel=cl(rel,0,1)
        set(mn+rng*rel)
    end
    Tk(Tk2.InputBegan:Connect(function(i)
        if disabled then return end
        local t=i.UserInputType
        if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then dr=true; dragInput=i; upd(i) end
    end))
    RegI(function(i)
        if not dr then return end
        if i.UserInputType==Enum.UserInputType.Touch and i~=dragInput then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then upd(i) end
    end)
    RegE(function(i)
        local t=i.UserInputType
        if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
            if t==Enum.UserInputType.Touch and i~=dragInput then return end
            dr=false; dragInput=nil
        end
    end)
    local function applyDisabled(vd)
        disabled=vd==true
        Tk2.Active=not disabled
        R2.Active=not disabled
        R2.BackgroundTransparency=disabled and .12 or 0
        L.TextTransparency=disabled and .45 or 0
        VL.TextTransparency=disabled and .45 or 0
    end
    E=RegEl(idx,"Slider",function() return v end,set,{Frame=R2,Label=L})
    E.Disabled=disabled; E.Visible=visible; E.Min=mn; E.Max=mx; E.Rounding=dec; E.Prefix=prefix; E.Suffix=suffix
    E._ApplyDisabled=applyDisabled
    E.SetText=function(self,text) L.Text=ts(text or ""); return true end
    E.SetMin=function(self,n)
        n=tn(n); if not n then return false end
        mn=n; if mx<mn then mx=mn end; rng=mx-mn; inv=rng>0 and 1/rng or 0
        if v<mn then set(mn) else visual(v) end
        self.Min=mn; return true
    end
    E.SetMax=function(self,n)
        n=tn(n); if not n then return false end
        mx=n; if mx<mn then mn=mx end; rng=mx-mn; inv=rng>0 and 1/rng or 0
        if v>mx then set(mx) else visual(v) end
        self.Max=mx; return true
    end
    E.SetDisabled=function(self,x) applyDisabled(x); self.Disabled=disabled; return true end
    E.SetVisible=function(self,x) R2.Visible=x==true; self.Visible=x==true; return true end
    E.SetPrefix=function(self,x) prefix=ts(x or ""); self.Prefix=prefix; refreshText(); return true end
    E.SetSuffix=function(self,x) suffix=ts(x or ""); self.Suffix=suffix; refreshText(); return true end
    E._Cleanup=function() dr=false end
    local cleanupTip=AttachTooltip(R2,function() return disabled and opts.DisabledTooltip or opts.Tooltip end)
    if opts.AllowRightClickInput==true then
        Tk(Tk2.InputBegan:Connect(function(i)
            if disabled then return end
            if i.UserInputType==Enum.UserInputType.MouseButton2 then
                local Box=I("TextBox"); Box.BackgroundColor3=CFG.Field; Box.TextColor3=CFG.Text; Box.Text=tostring(v); Box.ClearTextOnFocus=false; Box.TextSize=12; Box.Size=U3(110,30); Box.Position=U2(1,-120,0,-8); Box.Parent=R2; Box.ZIndex=20; FT.C(Box,6)
                Box:CaptureFocus()
                local c; c=Box.FocusLost:Connect(function()
                    local n=tonumber(Box.Text); if n then set(n) end; if c then c:Disconnect() end; if Box.Parent then Box:Destroy() end
                end)
            end
        end))
    end
    local oldSliderCleanup=E._Cleanup; E._Cleanup=function() cleanupTip(); if oldSliderCleanup then oldSliderCleanup() end end
    FT.H(R2,RS)
    R2.Visible=visible
    applyDisabled(disabled)
    refreshText()
    return E
end

function El.Input(parent,opts)
    opts=opts or {}; if not ValidParent(parent) then return nil end
    local idx=opts.Index or ("Input_"..ts(#ST.ElementOrder+1)); local value=ts(opts.Default or ""); local disabled=opts.Disabled==true; local visible=opts.Visible~=false
    local R2=FT.Card(parent,50); if not R2 then return nil end
    local L=FT.L(R2,opts.Name or opts.Text or "Input",13,CFG.Text); L.Position=U3(12,2); L.Size=U2(1,-24,0,18); Reg(L,"TextColor3","Text")
    local box=I("TextBox"); box.BackgroundColor3=CFG.Field; box.TextColor3=CFG.Text; box.PlaceholderColor3=CFG.SubText; box.Text= value; box.PlaceholderText=ts(opts.Placeholder or ""); box.ClearTextOnFocus=opts.ClearTextOnFocus~=false; box.TextSize=12; box.Font=Enum.Font.GothamMedium; box.Size=U2(1,-24,0,24); box.Position=U3(12,23); box.ClearTextOnFocus=false; box.Parent=R2; FT.C(box,6); Reg(box,"BackgroundColor3","Field"); Reg(box,"TextColor3","Text"); Reg(box,"PlaceholderColor3","SubText")
    local cb=opts.Callback
    local E=RegEl(idx,"Input",function() return value end,function(v) value=ts(v or ""); box.Text=value; return true end,{Frame=R2,Label=L})
    E.Value=value; E.Disabled=disabled; E.Visible=visible
    local function apply(v) disabled=v==true; box.Active=not disabled; box.TextEditable=not disabled; box.BackgroundTransparency=disabled and .45 or 0; box.TextTransparency=disabled and .35 or 0 end
    Tk(box:GetPropertyChangedSignal("Text"):Connect(function() value=box.Text; E.Value=value; E:_EmitChanged(value) end))
    Tk(box.FocusLost:Connect(function(enter) if cb then SafeCall("Input:"..ts(idx),cb,value,enter) end end))
    E.SetText=function(self,v) value=ts(v or ""); box.Text=value; self.Value=value; return true end
    E.SetValue=E.SetText; E.GetValue=function() return value end
    E.SetDisabled=function(self,v) apply(v); self.Disabled=v==true; return true end
    E.SetVisible=function(self,v) R2.Visible=v==true; self.Visible=v==true; return true end
    E.Focus=function() if not disabled then box:CaptureFocus(); return true end return false end
    E._Cleanup=function() end; apply(disabled); R2.Visible=visible; return E
end

function El.Button(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    if type(opts)=="string" then opts={Text=opts} end
    opts.Text=opts.Text or opts.Name or "Button"; opts.Name=opts.Text
    local idx=opts.Index or ("Button_"..ts(#ST.ElementOrder+1))
    local cb=opts.Func or opts.Callback
    local buttonText=ts(opts.Text)
    local disabled=opts.Disabled==true; local visible=opts.Visible~=false; local risky=opts.Risky==true
    local busy=false; local waitingDouble=false; local lastClick=0; local cooldown=ma(0,tn(opts.Cooldown) or CFG.ButtonCooldown)
    local E=nil
    local B=I("TextButton"); B.BackgroundColor3=CFG.Card; B.Text=""; B.AutoButtonColor=false; B.Size=U2(1,0,0,46); B.BackgroundTransparency=0; B.Parent=parent; FT.C(B,10)
    local BS=FT.S(B,CFG.Stroke,1); local L=FT.L(B,buttonText,14,risky and CFG.DangerText or CFG.Text); L.Size=U2(1,-20,1,0); L.TextXAlignment=Enum.TextXAlignment.Center; L.Font=Enum.Font.GothamBold
    Reg(B,"BackgroundColor3","Card"); Reg(BS,"Color","Stroke"); Reg(L,risky and "TextColor3" or "TextColor3",risky and "DangerText" or "Text")
    local function applyDisabled(v) disabled=v==true; B.Active=not disabled; B.AutoButtonColor=false; B.BackgroundTransparency=disabled and .45 or 0; L.TextTransparency=disabled and .35 or 0 end
    local function invoke(fromKeyPicker)
        if disabled or busy or not B.Parent then return false end
        if opts.DoubleClick then
            local now=os.clock()
            if not waitingDouble or now-lastClick>.38 then waitingDouble=true; lastClick=now; return false end
            waitingDouble=false
        end
        busy=true; B.Active=false
        local old=L.Text; if opts.LoadingText then L.Text=ts(opts.LoadingText) end
        local ok=SafeCall("Button:"..ts(idx),cb,fromKeyPicker==true)
        if E and type(E._CallbackOverride)=="function" then SafeCall("ButtonOverride:"..ts(idx),E._CallbackOverride,fromKeyPicker==true) end
        if not ok then LuaNotify.Error("Ação falhou no botão: "..ts(idx)) end
        if L.Parent then L.Text=old end
        task.delay(cooldown,function() if B.Parent and not disabled then busy=false B.Active=true end end)
        return ok
    end
    Tk(B.MouseEnter:Connect(function() if not disabled then FT.T(B,{BackgroundColor3=CFG.CardHover},.18,"Hover"); FT.T(BS,{Color=CFG.Purple},.18,"Hover") end end))
    Tk(B.MouseLeave:Connect(function() if not disabled then FT.T(B,{BackgroundColor3=CFG.Card},.18,"Hover"); FT.T(BS,{Color=CFG.Stroke},.18,"Hover") end end))
    Tk(B.MouseButton1Down:Connect(function() if not disabled then FT.T(B,{BackgroundColor3=CFG.CardHover},.08,"Press") end end))
    Tk(B.MouseButton1Click:Connect(function() invoke(false) end))
    E=RegEl(idx,"Button",function() return nil end,nil,{Frame=B,Label=L})
    E.Disabled=disabled; E.Visible=visible; E.Risky=risky
    E._ApplyDisabled=applyDisabled
    E.SetText=function(self,v) buttonText=ts(v or ""); L.Text=buttonText; return true end
    E.SetDisabled=function(self,v) applyDisabled(v); self.Disabled=v==true; return true end
    E.SetVisible=function(self,v) B.Visible=v==true; self.Visible=v==true; return true end
    E.Invoke=function(self,fromKeyPicker) return invoke(fromKeyPicker) end
    local cleanupTip=AttachTooltip(B,function() return disabled and opts.DisabledTooltip or opts.Tooltip end)
    local subHandle=nil; local keyHandle=nil
    function E:AddButton(cfg2)
        cfg2=cfg2 or{}; if type(cfg2)=="string" then cfg2={Text=cfg2} end
        if subHandle and subHandle.Destroy then subHandle:Destroy() end
        local sb=I("TextButton"); sb.Name="SubButton"; sb.Text=ts(cfg2.Text or cfg2.Name or "Sub Button"); sb.TextSize=11; sb.Font=Enum.Font.GothamBold; sb.TextColor3=cfg2.Risky and CFG.DangerText or CFG.Text; sb.BackgroundColor3=CFG.BgButton; sb.AutoButtonColor=false; sb.Size=U3(math.clamp(#sb.Text*7+28,80,150),30); sb.AnchorPoint=V2(1,.5); sb.Position=U2(1,-8,.5,0); sb.Parent=B; FT.C(sb,7)
        L.Size=U2(1,-(sb.Size.X.Offset+24),1,0); L.TextXAlignment=Enum.TextXAlignment.Left; L.Position=U3(14,0)
        local sd=cfg2.Disabled==true
        local function sdset(v) sd=v==true; sb.Active=not sd; sb.BackgroundTransparency=sd and .45 or 0; sb.TextTransparency=sd and .35 or 0 end
        Tk(sb.MouseEnter:Connect(function() if not sd then FT.T(sb,{BackgroundColor3=CFG.CardHover},.12) end end)); Tk(sb.MouseLeave:Connect(function() if not sd then FT.T(sb,{BackgroundColor3=CFG.BgButton},.12) end end))
        Tk(sb.MouseButton1Click:Connect(function() if sd then return end; SafeCall("SubButton:"..ts(idx),cfg2.Func or cfg2.Callback) end))
        local subTip=AttachTooltip(sb,function() return sd and cfg2.DisabledTooltip or cfg2.Tooltip end)
        subHandle={Button=sb,Destroy=function(self) subTip(); if sb.Parent then sb:Destroy() end end,SetDisabled=function(self,v) sdset(v) end}
        sdset(sd)
        return subHandle
    end
    function E:AddKeyPicker(keyId,cfg2)
        cfg2=cfg2 or{}; local mode=cfg2.Mode or "Press"; if mode~="Press" then mode="Press" end
        local cur=cfg2.Default or Enum.KeyCode.Unknown; local listening=false; local kc=I("TextButton"); kc.Name="KeyPicker"; kc.Text=type(cur)=="EnumItem" and cur.Name or ts(cur); kc.TextSize=10; kc.Font=Enum.Font.GothamBold; kc.TextColor3=CFG.Text; kc.BackgroundColor3=CFG.BgButton; kc.AutoButtonColor=false; kc.Size=U3(76,30); kc.AnchorPoint=V2(1,.5); kc.Position=U2(1,-8,.5,0); kc.Parent=B; FT.C(kc,7); L.Size=U2(1,-100,1,0); L.TextXAlignment=Enum.TextXAlignment.Left; L.Position=U3(14,0)
        local conn=nil
        local function name(k) return type(k)=="EnumItem" and k.Name or ts(k or "Unknown") end
        local function stop() listening=false; if conn then conn:Disconnect(); conn=nil end; kc.Text=name(cur); kc.BackgroundColor3=CFG.BgButton end
        Tk(kc.MouseButton1Click:Connect(function() if listening then return end; listening=true; kc.Text="Press..."; kc.BackgroundColor3=CFG.Purple; conn=S.U.InputBegan:Connect(function(inp,gpe) if gpe then return end; if inp.KeyCode==Enum.KeyCode.Escape then stop(); return end; if inp.UserInputType==Enum.UserInputType.Keyboard then cur=inp.KeyCode; stop(); SafeCall("ButtonKeyPicker:"..ts(keyId),function() return invoke(true) end) end end) end))
        keyHandle={SetValue=function(self,v) cur=v; kc.Text=name(v) end,GetValue=function(self) return cur end,Destroy=function(self) stop(); if kc.Parent then kc:Destroy() end end}
        return keyHandle
    end
    E._Cleanup=function() cleanupTip(); if subHandle and subHandle.Destroy then subHandle:Destroy() end; if keyHandle and keyHandle.Destroy then keyHandle:Destroy() end end
    applyDisabled(disabled); B.Visible=visible
    return E
end

function El.Keybind(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil end
    local idx=opts.Index or ("Keybind_"..ts(#ST.ElementOrder+1))
    local cur=opts.Default or Enum.KeyCode.Unknown
    local mode=opts.Mode or "Toggle"
    local modes=type(opts.Modes)=="table" and opts.Modes or {"Always","Toggle","Hold"}
    local st=false
    local syncToggle=opts.SyncToggleState==true
    local noUI=opts.NoUI==true
    local waitCallback=opts.WaitForCallback==true
    local keyBusy=false
    local defaultMods=type(opts.DefaultModifiers)=="table" and opts.DefaultModifiers or {}
    local modifiers={}
    for _,m in ipairs(defaultMods) do modifiers[#modifiers+1]=m end
    local listen=false
    local lastPress=0
    local cb=opts.Callback
    local changedCb=opts.ChangedCallback
    local clickCb=opts.Clicked
    local function K2S(k)
        if ty(k)=="EnumItem" then return k.Name end
        return ts(k)
    end
    local function S2K(s)
        if not s or s=="" then return Enum.KeyCode.Unknown end
        if s=="MouseButton1" then return "MouseButton1" end
        if s=="MouseButton2" then return "MouseButton2" end
        if s=="MouseButton3" then return "MouseButton3" end
        local ok,kc=pcall(function() return Enum.KeyCode[s] end)
        if ok and kc then return kc end
        LuaNotify.Warning("Keybind inválido: "..ts(s))
        return Enum.KeyCode.Unknown
    end
    local function hasMod(name)
        for _,m in ipairs(modifiers) do if m==name then return true end end
        return false
    end
    local function modifierName(k)
        local map={LeftAlt="LAlt",RightAlt="RAlt",LeftControl="LCtrl",RightControl="RCtrl",LeftShift="LShift",RightShift="RShift",Tab="Tab",CapsLock="CapsLock"}
        return map[k.Name] or k.Name
    end
    local KB=nil
    local E=nil
    local function refreshKeyText()
        if not KB or not KB.Parent then return end
        local parts={}; for _,m in ipairs(modifiers) do parts[#parts+1]=m end; parts[#parts+1]=K2S(cur); KB.Text=table.concat(parts,"+")
    end
    local function modifierAllowed(name)
        local bl=type(opts.BlacklistModifiers)=="table" and opts.BlacklistModifiers or {}
        local wl=type(opts.WhitelistedModifiers)=="table" and opts.WhitelistedModifiers or {}
        if #wl>0 then for _,x in ipairs(wl) do if x==name then return true end end return false end
        for _,x in ipairs(bl) do if x==name then return false end end
        return true
    end
    local R2,RS=FT.Card(parent,68)
    if not R2 then return nil end
    local IF=I("Frame")
    IF.BackgroundColor3=CFG.IconBg
    IF.Size=U3(48,48)
    IF.AnchorPoint=V2(0,.5)
    IF.Position=U2(0,12,.5,0)
    IF.Parent=R2
    FT.C(IF,10)
    Reg(IF,"BackgroundColor3","IconBg")
    local IImg=I("ImageLabel")
    IImg.BackgroundTransparency=1
    IImg.Image="rbxassetid://"..IMA.Keybind
    IImg.ImageColor3=CFG.Purple
    IImg.ScaleType=Enum.ScaleType.Fit
    IImg.Size=U3(30,30)
    IImg.AnchorPoint=V2(.5,.5)
    IImg.Position=Uv(.5,.5)
    IImg.Parent=IF
    Reg(IImg,"ImageColor3","Purple")
    local L=FT.L(R2,opts.Name or "Keybind",14,CFG.Text)
    L.Position=U3(70,0)
    L.Size=U2(1,-180,1,0)
    L.Font=Enum.Font.GothamBold
    Reg(L,"TextColor3","Text")
    local MC=I("TextButton")
    MC.BackgroundColor3=CFG.BgButton
    MC.Text=mode
    MC.TextColor3=CFG.SubText
    MC.Font=Enum.Font.GothamBold
    MC.TextSize=10
    MC.AutoButtonColor=false
    MC.Size=U3(56,24)
    MC.AnchorPoint=V2(1,.5)
    MC.Position=U2(1,-10,.5,0)
    MC.Parent=R2
    FT.C(MC,6)
    Reg(MC,"BackgroundColor3","BgButton")
    Reg(MC,"TextColor3","SubText")
    KB=I("TextButton")
    KB.BackgroundColor3=CFG.BgButton
    KB.Text=K2S(cur)
    KB.TextColor3=CFG.Text
    KB.Font=Enum.Font.GothamBold
    KB.TextSize=11
    KB.AutoButtonColor=false
    KB.Size=U3(96,36)
    KB.AnchorPoint=V2(1,.5)
    KB.Position=U2(1,-74,.5,0)
    KB.Parent=R2
    FT.C(KB,8)
    Reg(KB,"BackgroundColor3","BgButton")
    Reg(KB,"TextColor3","Text")
    local listenConn=nil
    local function setK(k)
        k=k or Enum.KeyCode.Unknown
        local keyName=K2S(k)
        if keyName~="Unknown" then
            for otherId,otherKey in pairs(ST.Keybinds) do
                if otherId~=idx and otherKey==keyName then
                    LuaNotify.Warning("Conflito de keybind: "..keyName.." já está em uso por "..ts(otherId),"Keybind")
                    break
                end
            end
        end
        cur=k
        ST.Keybinds[idx]=keyName
        if E then E.Value=cur; E.Modifiers=modifiers end
        KB.Text=keyName
    end
    local function fire(ns)
        if st==ns then return end
        local old=st
        st=ns
        if cb then
            if waitCallback then keyBusy=true end
            local ok,err=SafeCall("Keybind:"..ts(idx),cb,st)
            keyBusy=false
            if not ok then
                st=old
                LuaNotify.Error("Keybind revertido: "..ts(err))
                return
            end
        end
        local el=ST.Elements[idx]; if el and el._EmitChanged then el:_EmitChanged(st) end
    end
    Tk(MC.MouseButton1Click:Connect(function()
        local oldMode=mode
        local pos=1; for i,m in ipairs(modes) do if m==mode then pos=i break end end
        pos=pos%#modes+1; mode=modes[pos]
        MC.Text=mode
        if E then E.Mode=mode end
        if oldMode=="Always" and mode~="Always" and st then
            fire(false)
        elseif mode=="Always" then
            fire(true)
        end
    end))
    Tk(KB.MouseButton1Click:Connect(function()
        if listen or (ST.ListeningKeybind and ST.ListeningKeybind~=idx) then return end
        if clickCb then SafeCall("KeybindClick:"..ts(idx),clickCb) end
        ST.ListeningKeybind=idx; listen=true; modifiers={}
        KB.Text="Press..."; FT.T(KB,{BackgroundColor3=CFG.Purple},.15,"Listen")
        if listenConn then listenConn:Disconnect() end
        listenConn=S.U.InputBegan:Connect(function(inp,gpe)
            if gpe or ST.ListeningKeybind~=idx then return end
            if inp.KeyCode==Enum.KeyCode.Escape then
                listen=false; ST.ListeningKeybind=nil; refreshKeyText(); FT.T(KB,{BackgroundColor3=CFG.BgButton},.15,"Listen"); if listenConn then listenConn:Disconnect() listenConn=nil end; return
            end
            local n=(inp.UserInputType==Enum.UserInputType.Keyboard) and modifierName(inp.KeyCode) or nil
            if n and (n=="LAlt" or n=="RAlt" or n=="LCtrl" or n=="RCtrl" or n=="LShift" or n=="RShift" or n=="Tab" or n=="CapsLock") then
                if modifierAllowed(n) and not hasMod(n) then modifiers[#modifiers+1]=n; refreshKeyText() end
                return
            end
            if inp.KeyCode==Enum.KeyCode.Delete or inp.KeyCode==Enum.KeyCode.Backspace then setK(Enum.KeyCode.Unknown)
            elseif inp.KeyCode==CFG.ToggleKey then return
            elseif inp.UserInputType==Enum.UserInputType.Keyboard then
                local bl=type(opts.Blacklist)=="table" and opts.Blacklist or {}; local wl=type(opts.Whitelisted)=="table" and opts.Whitelisted or {}; local name=inp.KeyCode.Name
                if #wl>0 then local ok=false for _,x in ipairs(wl) do if x==name or x==inp.KeyCode then ok=true end end if not ok then return end end
                for _,x in ipairs(bl) do if x==name or x==inp.KeyCode then return end end
                setK(inp.KeyCode)
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then setK("MouseButton1")
            elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then setK("MouseButton2")
            elseif inp.UserInputType==Enum.UserInputType.MouseButton3 then setK("MouseButton3")
            else return end
            listen=false; ST.ListeningKeybind=nil; refreshKeyText(); FT.T(KB,{BackgroundColor3=CFG.BgButton},.15,"Listen"); if changedCb then SafeCall("KeybindChanged:"..ts(idx),changedCb,cur,modifiers) end
            if listenConn then listenConn:Disconnect() listenConn=nil end
        end)
    end))
    local function match(inp)
        if not cur or cur==Enum.KeyCode.Unknown then return false end
        if ty(cur)=="EnumItem" then return inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==cur end
        if cur=="MouseButton1" then return inp.UserInputType==Enum.UserInputType.MouseButton1 end
        if cur=="MouseButton2" then return inp.UserInputType==Enum.UserInputType.MouseButton2 end
        if cur=="MouseButton3" then return inp.UserInputType==Enum.UserInputType.MouseButton3 end
        return false
    end
    Tk(S.U.InputBegan:Connect(function(inp,gpe)
        if not E or E._Destroyed then return end
        if gpe or listen or keyBusy or mode=="Always" or ST.ListeningKeybind or S.U:GetFocusedTextBox() then return end
        if match(inp) then
            if mode=="Toggle" then fire(not st)
            elseif mode=="Hold" then fire(true)
            elseif mode=="Press" then fire(true); if not waitCallback then fire(false) end
            elseif mode=="DoublePress" then
                local now=os.clock()
                if now-lastPress<=.35 then lastPress=0; fire(true); if not waitCallback then fire(false) end else lastPress=now end
            end
        end
    end))
    Tk(S.U.InputEnded:Connect(function(inp)
        if listen or ST.ListeningKeybind or S.U:GetFocusedTextBox() then return end
        if mode=="Hold" and match(inp) then fire(false) end
    end))
    if mode=="Always" then fire(true) end
    E=RegEl(idx,"Keybind",function() return {Key=K2S(cur),Mode=mode,State=st} end,function(v)
        if type(v)=="table" then
            if v.Key then setK(S2K(v.Key)) end
            if type(v.Modifiers)=="table" then modifiers={}; for _,m in ipairs(v.Modifiers) do if modifierAllowed(m) and not hasMod(m) then modifiers[#modifiers+1]=m end end; E.Modifiers=modifiers; refreshKeyText() end
            if v.Mode then
                local allowed=false; for _,m in ipairs(modes) do if m==v.Mode then allowed=true end end
                if allowed then local oldMode=mode; mode=v.Mode; MC.Text=mode; E.Mode=mode; if oldMode=="Always" and mode~="Always" and st then fire(false) elseif mode=="Always" then fire(true) end end
            end
        elseif type(v)=="string" then
            setK(S2K(v))
        end
    end,{Frame=R2})
    E.Value=cur; E.Mode=mode; E.Modifiers=modifiers; E.NoUI=noUI; E.Modes=modes
    E.GetState=function() return st end
    E.SetText=function(self,v) L.Text=ts(v or ""); return true end
    E.SetMenuVisibility=function(self,v) self.NoUI=v==false and false or true; noUI=self.NoUI; return true end
    E.Update=function() refreshKeyText(); MC.Text=mode; return true end
    E.OnClick=function(self,fn) clickCb=type(fn)=="function" and fn or nil; return self end
    local baseOnChanged=E.OnChanged
    E.OnChanged=function(self,fn)
        changedCb=type(fn)=="function" and fn or nil
        return baseOnChanged(self,fn)
    end
    E._Cleanup=function() if listenConn then listenConn:Disconnect(); listenConn=nil end; if ST.ListeningKeybind==idx then ST.ListeningKeybind=nil end; ST.Keybinds[idx]=nil end
    E._Label=L
    E._ApplyDisabled=function(v) R2.Active=v~=true; R2.BackgroundTransparency=v and .35 or 0 end
    refreshKeyText()
    return E
end

function El.Section(parent,opts)
    opts=opts or{}
    if not ValidParent(parent) then return nil,nil end
    local title=opts.Title or "Section"
    local opened=opts.Opened~=false
    local ts2=opts.TextSize or 17
    local S2=I("Frame")
    S2.BackgroundColor3=CFG.Card
    S2.BorderSizePixel=0
    S2.BackgroundTransparency=1
    S2.Size=U2(1,0,0,0)
    S2.AutomaticSize=Enum.AutomaticSize.Y
    S2.Parent=parent
    Reg(S2,"BackgroundColor3","Card")
    local H2=I("TextButton")
    H2.BackgroundTransparency=1
    H2.BorderSizePixel=0
    H2.Text=""
    H2.AutoButtonColor=false
    H2.Size=U2(1,0,0,42)
    H2.Parent=S2
    FT.C(H2,8)
    local HT=FT.L(H2,title,ts2,CFG.Text)
    HT.Position=U3(14,0)
    HT.Size=U2(1,-60,1,0)
    HT.Font=Enum.Font.GothamBold
    Reg(HT,"TextColor3","Text")
    local Ch=FT.L(H2,"▾",18,CFG.SubText)
    Ch.Position=U2(1,-34,0,0)
    Ch.Size=U3(24,42)
    Ch.TextXAlignment=Enum.TextXAlignment.Center
    Ch.Font=Enum.Font.GothamBold
    Ch.Rotation=opened and 180 or 0
    Reg(Ch,"TextColor3","SubText")
    local C=I("Frame")
    C.BackgroundTransparency=1
    C.Size=U2(1,0,0,0)
    C.AutomaticSize=Enum.AutomaticSize.Y
    C.Position=U3(0,44)
    C.Parent=S2
    local CP=I("UIPadding")
    CP.PaddingLeft=Un(0,4)
    CP.PaddingRight=Un(0,4)
    CP.PaddingTop=Un(0,4)
    CP.PaddingBottom=Un(0,6)
    CP.Parent=C
    local CL=I("UIListLayout")
    CL.Padding=Un(0,8)
    CL.SortOrder=Enum.SortOrder.LayoutOrder
    CL.Parent=C
    if not opened then C.Visible=false end
    Tk(H2.MouseButton1Click:Connect(function()
        opened=not opened
        C.Visible=opened
        FT.T(Ch,{Rotation=opened and 180 or 0},.2)
        ScrollU()
    end))
    return S2,C
end

function El.Divider(parent,opts)
    if not ValidParent(parent) then return nil end
    if type(opts)=="string" then opts={Text=opts} elseif type(opts)~="table" then opts={} end
    local margin=tn(opts.Margin) or 0
    local mt=tn(opts.MarginTop) or margin
    local mb=tn(opts.MarginBottom) or margin
    local Dv=I("Frame"); Dv.Name="Divider"; Dv.BackgroundTransparency=1; Dv.BorderSizePixel=0; Dv.Size=U2(1,0,0,(opts.Text and 24 or 1)+mt+mb); Dv.Parent=parent
    local line=I("Frame"); line.BackgroundColor3=CFG.Stroke; line.BackgroundTransparency=.3; line.BorderSizePixel=0; line.Size=U2(1,0,0,1); line.Position=U2(0,0,.5,0); line.Parent=Dv; Reg(line,"BackgroundColor3","Stroke")
    if opts.Text then
        local T=FT.L(Dv,ts(opts.Text),10,CFG.SubText); T.BackgroundColor3=CFG.Card; T.BackgroundTransparency=0; T.Size=U2(0,0,0,20); T.AutomaticSize=Enum.AutomaticSize.X; T.AnchorPoint=V2(.5,.5); T.Position=Uv(.5,.5); T.TextXAlignment=Enum.TextXAlignment.Center; Reg(T,"TextColor3","SubText"); Reg(T,"BackgroundColor3","Card")
        local pad=I("UIPadding"); pad.PaddingLeft=Un(0,8); pad.PaddingRight=Un(0,8); pad.Parent=T
    end
    local E={Destroy=function() if Dv.Parent then Dv:Destroy() end end,SetText=function(self,v) return false end}
    return E
end

-- ============================================================
-- Obsidian-style Groupbox / Dependency / Tabbox compatibility layer
local API={}
local function ElementAPI(target)
    local api={}
    function api:AddLabel(textOrCfg)
        local cfg=type(textOrCfg)=="table" and textOrCfg or {Text=textOrCfg}
        local row=I("Frame"); row.BackgroundTransparency=1; row.Size=U2(1,0,0,28); row.Parent=target
        local lbl=FT.L(row,ts(cfg.Text or cfg.Name or ""),cfg.TextSize or 13,CFG.Text); lbl.Position=U3(10,0); lbl.Size=U2(1,-20,1,0); Reg(lbl,"TextColor3","Text")
        local obj={Instance=row,Label=lbl,SetText=function(self,v) lbl.Text=ts(v or ""); return true end,Destroy=function(self) if row.Parent then row:Destroy() end end}
        function obj:AddColorPicker(id,cfg2) cfg2=cfg2 or {}; cfg2.Index=cfg2.Index or id; local h=El.ColorPicker(row.Parent,cfg2); self._ColorPicker=h; return h end
        return obj
    end
    function api:AddToggle(id,o)
        o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text
        if API and API.ForceCheckbox==true then return El.Checkbox(target,o) end
        return El.Toggle(target,o)
    end
    function api:AddCheckbox(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text; return El.Checkbox(target,o) end
    function api:AddSlider(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text; return El.Slider(target,o) end
    function api:AddDropdown(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text; return El.Dropdown(target,o) end
    function api:AddMultiDropdown(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text; o.Multi=true; return El.Dropdown(target,o) end
    function api:AddColorPicker(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text or id; return El.ColorPicker(target,o) end
    function api:AddInput(id,o) o=o or{}; o.Index=o.Index or id; o.Name=o.Name or o.Text; return El.Input(target,o) end
    function api:AddButton(id,o)
        if type(id)=="table" then o=id; o.Index=o.Index or o.Id; return El.Button(target,o) end
        if type(o)=="function" then return El.Button(target,{Index=id,Text=ts(id),Func=o}) end
        o=o or{}; o.Index=o.Index or id; o.Text=o.Text or o.Name; return El.Button(target,o)
    end
    function api:AddKeyPicker(id,o) o=o or{}; o.Index=o.Index or id; return El.Keybind(target,o) end
    function api:AddKeybind(id,o) o=o or{}; o.Index=o.Index or id; return El.Keybind(target,o) end
    function api:AddSection(o) return El.Section(target,o) end
    function api:AddDivider(v) return El.Divider(target,v) end
    function api:GetContainer() return target end
    return api
end
local function DependencyMatches(dep)
    if type(dep)~="table" then return true end
    local source=dep[1] or dep.Option or dep.Toggle or dep.Element
    local expected=dep[2]
    if not source or type(source.Get)~="function" then return false end
    local ok,value=pcall(source.Get)
    if not ok then return false end
    if type(expected)=="table" then for _,v in ipairs(expected) do if value==v then return true end end return false end
    return value==expected
end
local function MakeDependency(target,framed)
    local box=I("Frame"); box.Name=framed and "DependencyGroupbox" or "DependencyBox"; box.BackgroundColor3=framed and CFG.Card or CFG.Field; box.BackgroundTransparency=framed and 0 or 1; box.BorderSizePixel=0; box.Size=U2(1,0,0,0); box.AutomaticSize=Enum.AutomaticSize.Y; box.ClipsDescendants=true; box.Parent=target
    if framed then FT.C(box,9); Reg(box,"BackgroundColor3","Card"); local st=FT.S(box,CFG.Stroke,1); Reg(st,"Color","Stroke") end
    local pad=I("UIPadding"); pad.PaddingLeft=Un(0,framed and 8 or 0); pad.PaddingRight=Un(0,framed and 8 or 0); pad.PaddingTop=Un(0,framed and 6 or 0); pad.PaddingBottom=Un(0,framed and 6 or 0); pad.Parent=box
    local deps={} ; local depConns={}
    local function disconnectDeps() for i=#depConns,1,-1 do pcall(function() depConns[i]:Disconnect() end); depConns[i]=nil end end
    local function refresh()
        if not box.Parent then return end
        local visible=true
        for i=1,#deps do if not DependencyMatches(deps[i]) then visible=false break end end
        box.Visible=visible; ScrollU()
    end
    local api=ElementAPI(box)
    function api:SetupDependencies(list)
        disconnectDeps(); deps=type(list)=="table" and list or {}
        for i=1,#deps do
            local source=deps[i][1] or deps[i].Option or deps[i].Toggle or deps[i].Element
            if source and type(source.OnChanged)=="function" then
                depConns[#depConns+1]=source:OnChanged(function() refresh() end)
            end
        end
        refresh(); return true
    end
    api.RefreshDependencies=refresh
    api.Destroy=function(self) disconnectDeps(); if box.Parent then box:Destroy() end; return true end
    api._DependencyCleanup=disconnectDeps
    task.defer(refresh)
    return api
end

local GetGroupColumn

local function MakeTabbox(parent,cfg)
    if not ValidParent(parent) then return nil end
    cfg=cfg or{}
    local side=cfg.Side
    if type(side)=="number" then side=(side==2 and "Right" or "Left") else side=(sl(ts(side or "Left"))=="right" and "Right" or "Left") end
    local name=cfg.Name and ts(cfg.Name) or nil
    local key=parent.Name or tostring(parent)
    ST.Tabboxes[key]=ST.Tabboxes[key] or {Left=0,Right=0}; ST.Tabboxes[key][side]=ST.Tabboxes[key][side]+1
    local idx=ST.Tabboxes[key][side]
    local root=I("Frame") root.Name=name or (side.."Tabbox") root.BackgroundColor3=CFG.Card root.BorderSizePixel=0 root.ClipsDescendants=true root.ZIndex=4 root.Size=U2(1,0,0,0) root.Position=U2(0,0,0,0) root.LayoutOrder=idx root.AutomaticSize=Enum.AutomaticSize.Y root.Parent=GetGroupColumn(parent,side) FT.C(root,10) Reg(root,"BackgroundColor3","Card")
    local bar=I("ScrollingFrame") bar.BackgroundColor3=CFG.Field bar.BorderSizePixel=0 bar.Size=U2(1,0,0,38) bar.ZIndex=5 bar.Parent=root bar.CanvasSize=U2(0,0,0,0) bar.AutomaticCanvasSize=Enum.AutomaticSize.X bar.ScrollingDirection=Enum.ScrollingDirection.X bar.ScrollBarThickness=0 bar.ClipsDescendants=true Reg(bar,"BackgroundColor3","Field")
    local bl=I("UIListLayout") bl.FillDirection=Enum.FillDirection.Horizontal bl.Padding=Un(0,2) bl.SortOrder=Enum.SortOrder.LayoutOrder bl.Parent=bar
    local body=I("Frame") body.BackgroundTransparency=1 body.Size=U2(1,0,0,0) body.AutomaticSize=Enum.AutomaticSize.Y body.Position=U3(0,42) body.Parent=root
    local bp=I("UIPadding") bp.PaddingLeft=Un(0,8) bp.PaddingRight=Un(0,8) bp.PaddingTop=Un(0,4) bp.PaddingBottom=Un(0,8) bp.Parent=body
    local tabs,active={},nil
    local popped=false local popRoot=nil local popBody=nil local maxHeight=tn(cfg.MaxPopOutHeight) local popWidth=tn(cfg.PopOutWidth)
    local function switch(id) if not tabs[id] then return end active=id for k,v in pairs(tabs) do v.Body.Visible=k==id v.Button.BackgroundTransparency=k==id and 0 or 1 v.Button.TextColor3=k==id and CFG.Text or CFG.SubText end end
    local function resize() local h=0 for _,v in pairs(tabs) do if v.Body.Visible then h=math.max(h,v.Body.AbsoluteSize.Y) end end h=math.max(h,80) if maxHeight then h=math.min(h,maxHeight) end if popRoot and popRoot.Parent then popRoot.Size=U3(popWidth or math.max(240,root.AbsoluteSize.X),h+50) end end
    local function setPop(v,pos)
        if v==popped then return end popped=v
        if popped then
            local vp=GetVP(); popRoot=I("Frame") popRoot.Name=(name or "Tabbox").."_PopOut" popRoot.BackgroundColor3=CFG.PopupBg popRoot.BorderSizePixel=0 popRoot.ZIndex=500 popRoot.Parent=UI.OGui
            local px,py=vp.X/2-120,vp.Y/2-160; popRoot.Position=pos or U2(0,cl(px,8,ma(8,vp.X-248)),0,cl(py,8,ma(8,vp.Y-328))) FT.C(popRoot,10) Reg(popRoot,"BackgroundColor3","PopupBg")
            local ph=I("Frame") ph.BackgroundColor3=CFG.Field ph.Size=U2(1,0,0,38) ph.ZIndex=501 ph.Parent=popRoot Reg(ph,"BackgroundColor3","Field")
            local pt=FT.L(ph,name or "Tabbox",13,CFG.Text) pt.Position=U3(12,0) pt.Size=U2(1,-24,1,0) pt.ZIndex=502 Reg(pt,"TextColor3","Text")
            popBody=I("ScrollingFrame") popBody.BackgroundTransparency=1 popBody.BorderSizePixel=0 popBody.Size=U2(1,0,1,-38) popBody.Position=U3(0,38) popBody.ScrollBarThickness=0 popBody.AutomaticCanvasSize=Enum.AutomaticSize.Y popBody.Parent=popRoot
            for _,v2 in pairs(tabs) do v2.Body.Parent=popBody end root.Visible=false resize()
        else
            for _,v2 in pairs(tabs) do v2.Body.Parent=body end root.Visible=true if popRoot then popRoot:Destroy() end popRoot=nil popBody=nil root.Size=U2(1,0,0,0) root.AutomaticSize=Enum.AutomaticSize.Y resize()
        end
    end
    local api={Name=name,Container=root}
    function api:AddTab(title,icon)
        local id=ts(title or ("Tab"..(#tabs+1))); local btn=I("TextButton") btn.BackgroundTransparency=1 btn.Text=(icon and ts(icon).."  " or "")..id btn.TextColor3=CFG.SubText btn.TextSize=12 btn.Font=Enum.Font.GothamBold btn.AutoButtonColor=false btn.Size=U2(0,110,1,0) btn.Parent=bar Reg(btn,"TextColor3","SubText")
        local bt=I("Frame") bt.BackgroundTransparency=1 bt.Size=U2(1,0,0,0) bt.AutomaticSize=Enum.AutomaticSize.Y bt.Visible=false bt.Parent=body
        tabs[id]={Button=btn,Body=bt}; Tk(btn.MouseButton1Click:Connect(function() switch(id) resize() end)); if not active then switch(id) end
        local out=ElementAPI(bt); function out:AddGroupbox(gcfg) return MakeGroupbox(bt,gcfg) end return out
    end
    function api:SetPoppedOut(v,pos) setPop(v==true,pos) return true end
    function api:TogglePoppedOut() setPop(not popped) return popped end
    function api:SetMaxPopOutHeight(v) maxHeight=tn(v) resize() return true end
    function api:SetPopOutWidth(v) popWidth=tn(v) resize() return true end
    function api:Resize() resize() return true end
    function api:GetContainer() return body end
    return api
end
GetGroupColumn=function(parent,side)
    if not ValidParent(parent) then return parent end
    local layer=parent:FindFirstChild("__LuaGroupColumns")
    if not layer then
        layer=I("Frame")
        layer.Name="__LuaGroupColumns"
        layer.BackgroundTransparency=1
        layer.Size=U2(1,0,0,0)
        layer.AutomaticSize=Enum.AutomaticSize.Y
        layer.Parent=parent
        local left=I("Frame")
        left.Name="Left"
        left.BackgroundTransparency=1
        left.Size=U2(.5,-6,0,0)
        left.Position=U2(0,0,0,0)
        left.AutomaticSize=Enum.AutomaticSize.Y
        left.Parent=layer
        local ll=I("UIListLayout")
        ll.Padding=Un(0,10)
        ll.SortOrder=Enum.SortOrder.LayoutOrder
        ll.Parent=left
        local right=I("Frame")
        right.Name="Right"
        right.BackgroundTransparency=1
        right.Size=U2(.5,-6,0,0)
        right.Position=U2(.5,6,0,0)
        right.AutomaticSize=Enum.AutomaticSize.Y
        right.Parent=layer
        local rl=I("UIListLayout")
        rl.Padding=Un(0,10)
        rl.SortOrder=Enum.SortOrder.LayoutOrder
        rl.Parent=right
    end
    return layer:FindFirstChild(side) or parent
end

function MakeGroupbox(parent,cfg)
    if not ValidParent(parent) then return nil end
    cfg=cfg or{}; local side=cfg.Side
    if type(side)=="number" then side=(side==2 and "Right" or "Left") else side=(sl(ts(side or "Left"))=="right" and "Right" or "Left") end
    local key=parent.Name or tostring(parent); ST.Groupboxes[key]=ST.Groupboxes[key] or {Left=0,Right=0}; ST.Groupboxes[key][side]=ST.Groupboxes[key][side]+1
    local idx=ST.Groupboxes[key][side]; local root=I("Frame") root.Name=cfg.Name and ts(cfg.Name) or (side.."Groupbox") root.BackgroundColor3=CFG.Card root.BorderSizePixel=0 root.Size=U2(1,0,0,0) root.AutomaticSize=Enum.AutomaticSize.Y root.Position=U2(0,0,0,0) root.LayoutOrder=idx root.ZIndex=4 root.Visible=cfg.Visible~=false root.Parent=GetGroupColumn(parent,side) FT.C(root,10) Reg(root,"BackgroundColor3","Card") local stroke=FT.S(root,CFG.Stroke,1) Reg(stroke,"Color","Stroke")
    local descOn=cfg.Description~=nil and ts(cfg.Description)~=""; local header=I("TextButton") header.BackgroundTransparency=1 header.Text="" header.AutoButtonColor=false header.Size=U2(1,0,0,descOn and 60 or 42) header.Parent=root
    if cfg.IconName then local ic=I("Frame") ic.BackgroundColor3=CFG.IconBg ic.Size=U3(28,28) ic.Position=U3(10,7) ic.Parent=header FT.C(ic,7) Reg(ic,"BackgroundColor3","IconBg") if API.IconManager then API.IconManager:Create(ic,cfg.IconName,{Size=18,Color="Accent"}) else IC.Render(ic,18,cfg.IconName,CFG.Purple) end end
    local title=FT.L(header,cfg.Name or "Groupbox",14,CFG.Text) title.Position=U3(cfg.IconName and 46 or 12,2) title.Size=U2(1,-(cfg.IconName and 90 or 50),0,22) title.Font=Enum.Font.GothamBold title.Parent=header Reg(title,"TextColor3","Text")
    local desc=FT.L(header,descOn and cfg.Description or "",10,CFG.SubText) desc.Position=U3(cfg.IconName and 46 or 12,25) desc.Size=U2(1,-(cfg.IconName and 90 or 50),0,20) desc.Visible=descOn desc.Parent=header Reg(desc,"TextColor3","SubText")
    local arrow=FT.L(header,cfg.DisableCollapsing and "" or "▾",16,CFG.SubText) arrow.AnchorPoint=V2(1,.5) arrow.Position=U2(1,-10,.5,0) arrow.Size=U3(24,24) arrow.TextXAlignment=Enum.TextXAlignment.Center arrow.Parent=header Reg(arrow,"TextColor3","SubText")
    local body=I("Frame") body.BackgroundTransparency=1 body.Size=U2(1,0,0,0) body.AutomaticSize=Enum.AutomaticSize.Y body.Position=U3(0,descOn and 60 or 42) body.Parent=root
    local pad=I("UIPadding") pad.PaddingLeft=Un(0,10) pad.PaddingRight=Un(0,10) pad.PaddingTop=Un(0,4) pad.PaddingBottom=Un(0,10) pad.Parent=body
    local list=I("UIListLayout") list.Padding=Un(0,8) list.SortOrder=Enum.SortOrder.LayoutOrder list.Parent=body
    local collapsed=cfg.Collapsed==true; local popped=false; local popRoot=nil; local popBody=nil; local maxPopHeight=tn(cfg.MaxPopOutHeight); local popWidth=tn(cfg.PopOutWidth)
    local function setCollapsed(v) if cfg.DisableCollapsing then collapsed=false else collapsed=v==true end body.Visible=not collapsed arrow.Text=cfg.DisableCollapsing and "" or (collapsed and "▸" or "▾") ScrollU() end
    local function resizePop() if not popRoot or not popRoot.Parent then return end local h=body.AbsoluteSize.Y if maxPopHeight then h=math.min(h,maxPopHeight) end local vp=GetVP(); h=math.min(h,math.max(120,vp.Y-70)); popRoot.Size=U3(popWidth or math.max(240,root.AbsoluteSize.X),h+48) end
    local function setPop(v,pos)
        if v==popped then return end popped=v
        if popped then
            local vp=GetVP(); popRoot=I("Frame") popRoot.Name=(cfg.Name or "Groupbox").."_PopOut" popRoot.BackgroundColor3=CFG.PopupBg popRoot.BorderSizePixel=0 popRoot.ZIndex=700 popRoot.Parent=UI.OGui local px,py=vp.X/2-140,vp.Y/2-180 popRoot.Position=pos or U2(0,cl(px,8,ma(8,vp.X-288)),0,cl(py,8,ma(8,vp.Y-368))) FT.C(popRoot,10) Reg(popRoot,"BackgroundColor3","PopupBg")
            local ph=I("Frame") ph.BackgroundColor3=CFG.Field ph.Size=U2(1,0,0,42) ph.Parent=popRoot Reg(ph,"BackgroundColor3","Field") local pt=FT.L(ph,cfg.Name or "Groupbox",14,CFG.Text) pt.Position=U3(12,0) pt.Size=U2(1,-24,1,0) Reg(pt,"TextColor3","Text")
            popBody=I("ScrollingFrame") popBody.BackgroundTransparency=1 popBody.BorderSizePixel=0 popBody.Size=U2(1,0,1,-42) popBody.Position=U3(0,42) popBody.ScrollBarThickness=0 popBody.AutomaticCanvasSize=Enum.AutomaticSize.Y popBody.Parent=popRoot local pp=I("UIPadding") pp.PaddingLeft=Un(0,10) pp.PaddingRight=Un(0,10) pp.PaddingTop=Un(0,8) pp.PaddingBottom=Un(0,10) pp.Parent=popBody body.Parent=popBody root.Visible=false resizePop()
        else body.Parent=root root.Visible=true if popRoot then popRoot:Destroy() end popRoot=nil popBody=nil end
    end
    local api=ElementAPI(body); api.Name=cfg.Name; api.Container=root; api.Body=body
    function api:SetVisible(v) root.Visible=v==true return true end function api:Show() return self:SetVisible(true) end function api:Hide() return self:SetVisible(false) end
    function api:SetDescription(v) local x=v and ts(v) or ""; desc.Text=x; desc.Visible=x~=""; header.Size=U2(1,0,0,desc.Visible and 60 or 42); body.Position=U3(0,desc.Visible and 60 or 42); return true end
    function api:SetPoppedOut(v,pos) setPop(v==true,pos) return true end function api:TogglePoppedOut() setPop(not popped) return popped end
    function api:SetMaxPopOutHeight(v) maxPopHeight=tn(v) resizePop() return true end function api:SetPopOutWidth(v) popWidth=tn(v) resizePop() return true end
    function api:AddTabbox(tcfg) return MakeTabbox(body,tcfg) end function api:AddDependencyBox() return MakeDependency(body,false) end function api:AddDependencyGroupbox() return MakeDependency(body,true) end
    Tk(header.MouseButton1Click:Connect(function() if not cfg.DisableCollapsing then setCollapsed(not collapsed) end end))
    setCollapsed(collapsed); api.PopOut=cfg.PopOut~=false
    return api
end

local SM={Folder="LuaInterface",SubFolder="",AutoloadName="autoload",IgnoreTheme=false,IgnoreIndexes={}}
local function GetFP()
    if SM.SubFolder and SM.SubFolder~="" then return SM.Folder.."/"..SM.SubFolder end
    return SM.Folder
end
local function EnsureFolder(path)
    if not makefolder then return false end
    local acc=""
    for seg in sg(path,"[^/]+") do
        acc=(acc=="" and seg) or (acc.."/"..seg)
        if not (isfolder and isfolder(acc)) then pcall(makefolder,acc) end
    end
    return isfolder and isfolder(path) or true
end
local function SafeConfigName(n) return (ts(n or ""):gsub("[^%w_%-]","_")) end
local function SafeFolderPath(n)
    local out={}
    for seg in ts(n or ""):gmatch("[^/\\]+") do
        if seg~="" and seg~="." and seg~=".." then out[#out+1]=(seg:gsub("[^%w_%-]","_")) end
    end
    return table.concat(out,"/")
end
function SM:SetFolder(v) if type(v)=="string" and v~="" then self.Folder=SafeFolderPath(v) end return self end
function SM:SetSubFolder(v) self.SubFolder=type(v)=="string" and SafeFolderPath(v) or "" return self end
function SM:_Path(name) return GetFP().."/"..SafeConfigName(name)..".json" end
function SM:Save(name)
    if not writefile then return false,"filesystem unavailable" end
    if type(name)~="string" or name=="" then return false,"invalid config name" end
    if not EnsureFolder(GetFP()) then return false,"folder unavailable" end
    local windowSize=ST.Window.Fullscreen and ST.Window.FullscreenSaved and ST.Window.FullscreenSaved.Size or ST.CustomSize
    local windowPosition=ST.Window.Fullscreen and ST.Window.FullscreenSaved and ST.Window.FullscreenSaved.Position or ST.Window.Position
    local data={Theme=SM.IgnoreTheme and nil or ST.CurrentTheme,Elements={},Window={Size=windowSize and {X=windowSize.X,Y=windowSize.Y} or nil,Position=windowPosition,Scale=ST.Scale,Fullscreen=false}}
    for i=1,#ST.ElementOrder do
        local id=ST.ElementOrder[i]
        local e=ST.Elements[id]
        if e and e.Get and not self.IgnoreIndexes[id] then
            local ok,v=pcall(e.Get)
            if ok and (type(v)=="boolean" or type(v)=="number" or type(v)=="string" or type(v)=="table") then data.Elements[id]=v end
        end
    end
    local ok,encoded=pcall(function() return S.H:JSONEncode(data) end)
    if not ok then return false,encoded end
    local wok,werr=pcall(writefile,self:_Path(name),encoded)
    return wok and true or false,werr
end
function SM:Load(name)
    if not readfile or type(name)~="string" or name=="" then return false,"filesystem unavailable or invalid name" end
    local ok,raw=pcall(readfile,self:_Path(name)); if not ok then return false,raw end
    local dok,data=pcall(function() return S.H:JSONDecode(raw) end); if not dok or type(data)~="table" then return false,"invalid config" end
    if data.Theme and not self.IgnoreTheme and Themes[data.Theme] then ApplyTheme(data.Theme) end
    for id,v in pairs(data.Elements or {}) do local e=ST.Elements[id] if e and e.Set and not self.IgnoreIndexes[id] then SafeCall("Load:"..id,e.Set,v) end end
    return true
end
function SM:Delete(name)
    if not delfile or type(name)~="string" or name=="" then return false,"filesystem unavailable or invalid name" end
    local ok,err=pcall(delfile,self:_Path(name)); return ok and true or false,err
end
function SM:SetAutoload(name) self.AutoloadName=name or "autoload" return self:Save(self.AutoloadName) end
function SM:LoadAutoloadConfig()
    if not readfile then return false,"filesystem unavailable" end
    local path=self:_Path(self.AutoloadName); if not isfile or not isfile(path) then return false,"autoload not found" end
    return self:Load(self.AutoloadName)
end
function SM:List()
    if not listfiles then return {} end
    local out={}; local ok,files=pcall(listfiles,GetFP()); if not ok or type(files)~="table" then return out end
    for _,f in ipairs(files) do local n=ts(f):match("([^/]+)%.json$"); if n then out[#out+1]=n end end
    table.sort(out); return out
end
function SM:Refresh() return self:List() end
function SM:Rename(oldName,newName)
    if not readfile or not writefile or not delfile then return false,"filesystem unavailable" end
    oldName,newName=SafeConfigName(oldName),SafeConfigName(newName)
    if oldName=="" or newName=="" then return false,"invalid config name" end
    local oldPath=self:_Path(oldName); local newPath=self:_Path(newName)
    local ok,raw=pcall(readfile,oldPath); if not ok then return false,raw end
    local wok,werr=pcall(writefile,newPath,raw); if not wok then return false,werr end
    pcall(delfile,oldPath); return true
end

local Ex1=UI.PageCts["Example1"]
local Ex2=UI.PageCts["Example2"]
local Ex3=UI.PageCts["Example3"]
local Ex4=UI.PageCts["Example4"]
local Ex5=UI.PageCts["Example5"]

local GB_Left=MakeGroupbox(Ex1,{Side="Left",Name="Basic Groupbox",Description="Left groupbox test",IconName="boxes",Visible=true,Collapsed=false,DisableCollapsing=false,PopOut=true,MaxPopOutHeight=220,PopOutWidth=280})
GB_Left:AddToggle("TestToggle",{Name="Enable test",Default=false,Index="GB_TestToggle"})
GB_Left:AddSlider("TestSlider",{Name="Volume",Default=50,Min=0,Max=100,Decimals=0,Index="GB_TestSlider"})
GB_Left:AddDivider()
GB_Left:AddSection({Title="Static Section",Opened=true})
local GB_Right=MakeGroupbox(Ex1,{Side="Right",Name="Right Groupbox",Description="Right column test",IconName="settings",Visible=true,Collapsed=false,PopOut=true})
GB_Right:AddButton("TestButton",{Name="Test Button",Index="GB_TestButton"})
GB_Right:AddToggle("StartEnabled",{Name="Start Enabled",Default=true,Index="GB_StartEnabled"})
GB_Right:AddKeybind("TestKey",{Name="Test Keybind",Default=Enum.KeyCode.H,Mode="Toggle",Index="GB_TestKeybind",Callback=function(state) LuaNotify({Title="Keybind",Content=state and "ON" or "OFF",Duration=2}) end})

local DepGroup=MakeGroupbox(Ex2,{Side="Left",Name="Dependency Box",Description="Visible only when Enable Audio is true",IconName="wrench"})
local DepToggle=DepGroup:AddToggle("EnableAudio",{Name="Enable Audio",Default=false,Index="Dep_EnableAudio"})
local AudioSettings=DepGroup:AddDependencyBox()
AudioSettings:AddSlider("Volume",{Name="Volume",Default=50,Min=0,Max=100,Index="Dep_Volume"})
AudioSettings:AddToggle("Mute",{Name="Mute",Default=false,Index="Dep_Mute"})
AudioSettings:SetupDependencies({{DepToggle,true}})
local DepGBParent=MakeGroupbox(Ex2,{Side="Right",Name="Dependency Groupbox",Description="Framed dependency container",IconName="boxes"})
local EnableAdvanced=DepGBParent:AddToggle("EnableAdvanced",{Name="Enable Advanced",Default=false,Index="Dep_EnableAdvanced"})
local Advanced=DepGBParent:AddDependencyGroupbox()
Advanced:AddSlider("Power",{Name="Power",Default=25,Min=0,Max=100,Index="Dep_Power"})
Advanced:AddButton("AdvancedButton",{Name="Advanced Button",Index="Dep_AdvancedButton"})
Advanced:SetupDependencies({{EnableAdvanced,true}})

local PopTest=MakeGroupbox(Ex3,{Side="Left",Name="Pop Out Test",Description="Groupbox pop-out",PopOut=true,MaxPopOutHeight=260,PopOutWidth=300})
PopTest:AddToggle("PopToggle",{Name="Popout toggle",Default=false,Index="Pop_PopToggle"})
PopTest:AddSlider("PopSlider",{Name="Popout size",Default=10,Min=1,Max=25,Index="Pop_PopSlider"})
PopTest:AddButton("PopButton",{Name="Popout button",Index="Pop_Button"})
local TabboxParent=MakeGroupbox(Ex3,{Side="Right",Name="Nested Tabbox",Description="Groupbox:AddTabbox()",IconName="boxes"})
local Nested=TabboxParent:AddTabbox({Side="Left",Name="Nested Tabs",MaxPopOutHeight=220,PopOutWidth=280})
local NestedA=Nested:AddTab("General")
NestedA:AddToggle("NestedToggle",{Name="Nested toggle",Default=false,Index="Nested_Toggle"})
NestedA:AddSlider("NestedSlider",{Name="Nested slider",Default=5,Min=0,Max=10,Index="Nested_Slider"})
local NestedB=Nested:AddTab("Options")
NestedB:AddButton("NestedButton",{Name="Nested button",Index="Nested_Button"})
NestedB:AddToggle("NestedSecond",{Name="Second toggle",Default=true,Index="Nested_Second"})

local Methods=MakeGroupbox(Ex4,{Side="Left",Name="Groupbox Methods",Description="Configuration API test"})
Methods:AddButton("ShowTest",{Name="Show / Hide test",Index="Methods_ShowHide"})
Methods:AddButton("PopTest",{Name="PopOut test",Index="Methods_Pop"})
Methods:SetMaxPopOutHeight(240)
Methods:SetPopOutWidth(300)
local AllTypes=MakeGroupbox(Ex4,{Side="Right",Name="All Basic Elements",Description="Configuration-only examples"})
AllTypes:AddToggle("BasicToggle",{Name="Toggle",Default=true,Index="All_Toggle"})
AllTypes:AddSlider("BasicSlider",{Name="Slider",Default=25,Min=0,Max=50,Index="All_Slider"})
AllTypes:AddButton("BasicButton",{Name="Button",Index="All_Button"})
AllTypes:AddKeybind("BasicKey",{Name="Keybind",Default=Enum.KeyCode.K,Mode="Hold",Index="All_Keybind",Callback=function(state) LuaNotify({Title="Keybind",Content=state and "Pressed" or "Released",Duration=1.5}) end})

local Final=MakeGroupbox(Ex5,{Side="Left",Name="Dependency Combination",Description="Multiple dependencies are ANDed"})
local A=Final:AddToggle("A",{Name="Condition A",Default=false,Index="Final_A"})
local B=Final:AddToggle("B",{Name="Condition B",Default=false,Index="Final_B"})
local Both=Final:AddDependencyBox()
Both:AddSection({Title="Visible when A AND B",Opened=true})
Both:AddToggle("Inside",{Name="Dependent option",Default=false,Index="Final_Inside"})
Both:SetupDependencies({{A,true},{B,true}})
local FinalGB=MakeGroupbox(Ex5,{Side="Right",Name="Non-Collapsible",Description="DisableCollapsing=true",DisableCollapsing=true,Collapsed=false,PopOut=true})
FinalGB:AddToggle("Fixed",{Name="Always open",Default=true,Index="Final_Fixed"})
local FixedTabs=FinalGB:AddTabbox({Side="Left",Name="Fixed Tabs"})
local FixedTab=FixedTabs:AddTab("Test")
FixedTab:AddToggle("FixedNested",{Name="Nested fixed",Default=false,Index="Final_FixedNested"})

-- Obsidian-compatible Toggle/Button surface tests. These examples intentionally use no callback functions.
local ToggleDocs=MakeGroupbox(Ex1,{Side="Left",Name="Toggles Docs",Description="Obsidian-compatible Toggle API"})
local DocsToggle=ToggleDocs:AddToggle("DocsToggle",{Text="Enable Speed Hack",Default=true,Tooltip="Toggle tooltip",DisabledTooltip="Disabled tooltip",Risky=true,Disabled=false,Visible=true,Index="Docs_Toggle"})
ToggleDocs:AddToggle("DocsDisabled",{Text="Disabled Toggle",Default=false,Disabled=true,Visible=true,Index="Docs_ToggleDisabled"})
ToggleDocs:AddCheckbox("DocsCheckbox",{Text="Enable Checkbox",Default=true,Visible=true,Index="Docs_Checkbox"})
ToggleDocs:AddCheckbox("DocsCheckboxDisabled",{Text="Disabled Checkbox",Default=false,Disabled=true,DisabledTooltip="Unavailable",Index="Docs_CheckboxDisabled"})
local ButtonDocs=MakeGroupbox(Ex1,{Side="Right",Name="Buttons Docs",Description="Obsidian-compatible Button API"})
local DocsButton=ButtonDocs:AddButton({Text="This is a button",Visible=true,Disabled=false,Risky=true,DoubleClick=false,Tooltip="Button tooltip",DisabledTooltip="Disabled button tooltip",Index="Docs_Button"})
DocsButton:AddButton({Text="Sub Button",Disabled=false,Tooltip="Sub button tooltip"})
DocsButton:AddKeyPicker("DocsButtonKey",{Default=Enum.KeyCode.V,Text="Button Bind",Mode="Press",DefaultModifiers={"LShift"}})
ButtonDocs:AddButton({Text="Disabled Button",Disabled=true,Index="Docs_ButtonDisabled"})
ButtonDocs:AddButton({Text="Double Click Button",DoubleClick=true,Index="Docs_ButtonDouble"})

local DropdownDocs=MakeGroupbox(Ex5,{Side="Right",Name="Dropdown Docs",Description="Obsidian-compatible Dropdown API"})
DropdownDocs:AddDropdown("DocsDropdown",{Text="A dropdown",Values={"This","is","a","dropdown"},Default=1,Multi=false,Searchable=true,MaxVisibleDropdownItems=6,AllowNull=true,Tooltip="Dropdown tooltip",Index="Docs_Dropdown"})
DropdownDocs:AddDropdown("DocsMultiDropdown",{Text="Multi dropdown",Values={item01="Excalibur",item05="Aegis Shield"},Default={item01=true},Multi=true,AllowNull=true,Searchable=true,DisabledValues={item05},Index="Docs_MultiDropdown"})

-- Theme remains the dedicated theme test area. Keybind callbacks above are intentional.

SM:SetFolder("LuaInterface")
SM:SetSubFolder(ts(game.PlaceId))
SM:LoadAutoloadConfig()
ApplyTheme(ST.CurrentTheme)
ST.State="Ready"

function API:Toggle() if not ValidState() then return false end ApplyVis(not ST.MainVisible) return true end
function API:Open() if not ValidState() then return false end if not ST.MainVisible then ApplyVis(true) end return true end
function API:Close() if not ValidState() then return false end if ST.MainVisible then ApplyVis(false) end return true end
function API:Minimize() if not ValidState() then return false end Minimize() return true end
function API:Fullscreen() if not ValidState() then return false end TglFS() return true end
function API:GetMode() return ST.CurrentMode end
function API:ChangeTitle(t) ST.Window.Title=ts(t or "") if UI.PT then UI.PT.Text=ST.Window.Title end if UI.OpenBT then UI.OpenBT.Text=ST.Window.Title end end
function API:SetAlwaysOnTop(v)
    ST.Window.AlwaysOnTop=v==true
    local d=ST.Window.AlwaysOnTop and 1000000 or nil
    if UI.Gui then UI.Gui.DisplayOrder=d and d+100 or 100 end
    if UI.PGui then UI.PGui.DisplayOrder=d and d+150 or 150 end
    if UI.DGui then UI.DGui.DisplayOrder=d and d+175 or 175 end
    if UI.OGui then UI.OGui.DisplayOrder=d and d+250 or 250 end
    if UI.NGui then UI.NGui.DisplayOrder=d and d+200 or 200 end
    return true
end
function API:GetGui() return UI.Gui end
function API:GetCurrentPage() return ST.CurrentPage end
function API:ResetSize() ST.CustomSize=nil ST.Window.Size=nil CFG.Fullscreen=false ST.UserMoved=false UpdateResp() end
function API:SetSize(w,h)
    w=tn(w) h=tn(h)
    if not w or not h then return end
    local v=GetVP()
    w=cl(w,CFG.MinW,ma(CFG.MinW,v.X-20)); if ST.Framework.MaxW then w=mi(w,ST.Framework.MaxW) end
    h=cl(h,CFG.MinH,ma(CFG.MinH,v.Y-20)); if ST.Framework.MaxH then h=mi(h,ST.Framework.MaxH) end
    ST.CustomSize=V2(w,h)
    ST.Window.Size=U3(w,h)
    CFG.Fullscreen=false
    UpdateResp()
end
function API:Dialog(cfg) return NewDialog(cfg) end
function API:Popup(cfg) return NewDialog(cfg) end
function API:Confirm(cfg) return Confirm(cfg) end
function API:Choice(cfg) return Choice(cfg) end
function API:ApplyTheme(name)
    if not Themes[name] then name="Dark" end
    ApplyTheme(name)
end
function API:GetTheme() return ST.CurrentTheme end
function API:GetThemeData(name)
    name=name or ST.CurrentTheme
    local t=Themes[name]
    if not t then return nil,"tema inválido" end
    local out={}
    for k,v in pairs(t) do out[k]=v end
    return out
end
function API:GetThemes() local t={} for k in pairs(Themes) do t[#t+1]=k end table.sort(t) return t end
function API:GetTab(name)
    local n=ts(name or "")
    local page=UI.PageCts[n]
    if not page then return nil,"tab inexistente" end
    local tab={Name=n,Container=page}
    function tab:AddTabbox(cfg) return MakeTabbox(page,cfg) end
    function tab:AddGroupbox(cfg) return MakeGroupbox(page,cfg) end
    return tab
end
function API:AddTabbox(tabName,cfg)
    local tab,err=self:GetTab(tabName)
    if not tab then return nil,err end
    return tab:AddTabbox(cfg)
end
function API:NewSection(parent,opts) return El.Section(parent,opts) end
function API:Divider(parent) return El.Divider(parent or Ex1) end
function API:SetErrorHandler(fn)
    if fn~=nil and type(fn)~="function" then return false,"handler inválido" end
    ST.ErrorHandler=fn
    CFG.ErrorMode=fn and "Custom" or "Notify"
    return true
end
function API:SetErrorMode(mode)
    mode=mode and ts(mode) or "Notify"
    if mode~="Notify" and mode~="Warn" and mode~="Silent" and mode~="Custom" then return false,"modo inválido" end
    CFG.ErrorMode=mode
    return true
end
function API:GetErrors()
    local out={}
    for i=1,#ST.Errors do local e=ST.Errors[i] out[i]={Id=e.Id,Time=e.Time,Source=e.Source,Message=e.Message,Traceback=e.Traceback} end
    return out
end
function API:GetLastError() return ST.Errors[#ST.Errors] end
function API:ClearErrors() for i=#ST.Errors,1,-1 do ST.Errors[i]=nil end return true end
function API:SafeCall(source,fn,...) return SafeCall(source,fn,...) end
function API:HealthCheck()
    local cc=0; for _ in pairs(ST.Conns) do cc=cc+1 end
    local out={State=ST.State,Destroyed=ST.Destroyed,Theme=ST.CurrentTheme,Mode=ST.CurrentMode,Page=ST.CurrentPage,GuiAlive=UI.Gui~=nil and UI.Gui.Parent~=nil,ActiveTweens=0,Notifications=ST.ActiveCount,Connections=cc,Errors=#ST.Errors,HasDialog=ST.ActiveDialog~=nil}
    for _,bucket in pairs(ST.ActiveTweens) do for _ in pairs(bucket) do out.ActiveTweens=out.ActiveTweens+1 end end
    out.Ok=(not out.Destroyed) and out.GuiAlive and out.State~="Destroying"
    return out
end
local function ApplyWindowConfig(c)
    c=c or {} local W=ST.Window
    if type(c.Animations)=="table" then for k,v in pairs(c.Animations) do if type(v)=="boolean" then W.Animations[k]=v end end end
    if type(c.TabButtonsStyle)=="table" then for k,v in pairs(c.TabButtonsStyle) do W.TabButtonsStyle[k]=v end end
    for k,v in pairs(c) do if k~="Animations" and k~="TabButtonsStyle" and W[k]~=nil then W[k]=v end end
    if typeof(W.Size)=="UDim2" then
        local x,y=W.Size.X.Offset,W.Size.Y.Offset if x>0 and y>0 then ST.CustomSize=V2(x,y) end
    elseif type(W.Size)=="table" and W.Size.X and W.Size.Y then
        local x=W.Size.X.Offset or 0 local y=W.Size.Y.Offset or 0 if x>0 and y>0 then ST.CustomSize=V2(x,y) end
    end
    if typeof(W.Position)=="UDim2" then UI.Main.Position=W.Position ST.UserMoved=true end
    if W.Title~=nil then UI.PT.Text=ts(W.Title) if UI.OpenBT then UI.OpenBT.Text=ts(W.Title) end end
    if W.Footer~=nil then UI.Footer.Text=ts(W.Footer) UI.Footer.Visible=ST.CurrentMode~="Mobile" and UI.Footer.Text~="" end
    if W.ToggleKeybind then
        if typeof(W.ToggleKeybind)=="EnumItem" and W.ToggleKeybind.EnumType==Enum.KeyCode then CFG.ToggleKey=W.ToggleKeybind end
    end
    if W.Center==false and not W.Position then UI.Main.Position=U3(20,20) ST.UserMoved=true end
    if W.Icon then
        local id=ts(W.Icon) if tonumber(id) then id="rbxassetid://"..id end
        UI.LogoImg.Image=id UI.LogoImg.Visible=true
    end
    if W.IconSize then local sz=tn(W.IconSize) if sz then UI.LogoIco.Size=U3(sz,sz) end end
    if W.CornerRadius then API:SetCornerRadius(W.CornerRadius) end
    if W.Font then for _,d in ipairs(UI.Main:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then pcall(function() d.Font=W.Font end) end end end
    API:SetAlwaysOnTop(W.AlwaysOnTop)
    API:SetBackgroundImage(W.BackgroundImage)
    UI.Search.Visible=not W.DisableSearch and ST.CurrentMode~="Mobile"
    if typeof(W.SearchbarSize)=="UDim2" then UI.Search.Size=W.SearchbarSize end
    UI.RG.Visible=W.Resizable~=false
    UI.HdrB.Visible=(W.ShowMobileButtons~=false) or ST.CurrentMode~="Mobile"
    UI.SidebarResize.Visible=W.EnableSidebarResize and ST.CurrentMode~="Mobile" and not W.SidebarCompacted
    if W.NotifySide=="Left" then UI.NH.AnchorPoint=V2(0,0) UI.NH.Position=U2(0,16) UI.NL.HorizontalAlignment=Enum.HorizontalAlignment.Left else UI.NH.AnchorPoint=V2(1,0) UI.NH.Position=U2(1,-16) UI.NL.HorizontalAlignment=Enum.HorizontalAlignment.Right end
    UpdateResp()
    if W.AutoShow==false then ApplyVis(false) end
    return true
end
-- ============================================================
-- v5.3.12: Framework-ready systems (Input, State, Scale, Plugins,
-- Localization, Loading, ContextMenu, Debug/Performance and Watermark)
-- ============================================================
function API:GetState()
    return {
        Lifecycle=ST.State, Destroyed=ST.Destroyed, Mode=ST.CurrentMode,
        Visible=ST.MainVisible, CurrentPage=ST.CurrentPage, Theme=ST.CurrentTheme,
        UserMoved=ST.UserMoved, Resizing=ST.Resizing, Dragging=ST.Dragging
    }
end
function API:SetScale(v)
    v=tn(v); if not v then return false,"escala inválida" end
    v=cl(v,.75,1.35)
    local sc=UI.Gui:FindFirstChild("LuaInterfaceScale")
    if not sc then sc=I("UIScale"); sc.Name="LuaInterfaceScale"; sc.Parent=UI.Gui end
    sc.Scale=v; ST.Scale=v; return true
end
function API:GetScale() return ST.Scale or 1 end
function API:RegisterPlugin(name,plugin)
    name=ts(name or ""); if name=="" or type(plugin)~="table" then return false,"plugin inválido" end
    ST.Plugins=ST.Plugins or {}; if ST.Plugins[name] then return false,"plugin já registrado" end
    ST.Plugins[name]=plugin
    if type(plugin.Init)=="function" then SafeCall("Plugin:"..name,plugin.Init,self) end
    return true
end
function API:UnregisterPlugin(name)
    ST.Plugins=ST.Plugins or {}; local pl=ST.Plugins[ts(name or "")]; if not pl then return false end
    if type(pl.Destroy)=="function" then SafeCall("PluginDestroy:"..ts(name),pl.Destroy) end
    ST.Plugins[ts(name)]=nil; return true
end
function API:SetLanguage(lang) ST.Language=ts(lang or "en-US"); return true end
function API:RegisterLocale(lang,data)
    if type(data)~="table" then return false end
    ST.Locales=ST.Locales or {}; ST.Locales[ts(lang)]=data; return true
end
function API:Translate(key,fallback)
    local lang=ST.Language or "en-US"; local d=ST.Locales and ST.Locales[lang]
    if d and d[key]~=nil then return ts(d[key]) end
    return fallback~=nil and ts(fallback) or ts(key)
end
function API:ShowLoading(cfg)
    cfg=cfg or {}; if ST.Loading then pcall(function() ST.Loading:Destroy() end) end
    local ov=I("TextButton"); ov.Name="LoadingOverlay"; ov.Text=""; ov.AutoButtonColor=false; ov.BackgroundColor3=CFG.Bg; ov.Active=true; ov.Selectable=true; ov.Modal=true; ov.BackgroundTransparency=.12; ov.Size=Uv(1,1); ov.ZIndex=900; ov.Parent=UI.OGui; FT.C(ov,12); Reg(ov,"BackgroundColor3","Bg")
    local title=FT.L(ov,cfg.Title or "Loading...",18,CFG.Text); title.AnchorPoint=V2(.5,.5); title.Position=Uv(.5,.5); title.Size=U3(320,30); title.TextXAlignment=Enum.TextXAlignment.Center; title.ZIndex=901; Reg(title,"TextColor3","Text")
    local bar=I("Frame"); bar.BackgroundColor3=CFG.Field; bar.BorderSizePixel=0; bar.Size=U3(260,6); bar.AnchorPoint=V2(.5,.5); bar.Position=U2(.5,0,.5,34); bar.ZIndex=901; bar.Parent=ov; FT.C(bar,3); Reg(bar,"BackgroundColor3","Field")
    local fill=I("Frame"); fill.BackgroundColor3=CFG.Purple; fill.BorderSizePixel=0; fill.Size=U2(0,0,1,0); fill.Parent=bar; FT.C(fill,3); Reg(fill,"BackgroundColor3","Purple")
    local api={Frame=ov,SetProgress=function(self,p) p=cl(tn(p) or 0,0,1); fill.Size=U2(p,0,1,0); return true end,SetStatus=function(self,t) title.Text=ts(t or "") end,Destroy=function(self) if ov.Parent then ov:Destroy() end if ST.Loading==self then ST.Loading=nil end end}
    ST.Loading=api; if cfg.Progress~=nil then api:SetProgress(cfg.Progress) end; return api
end
function API:ContextMenu(target,items)
    if not target or type(items)~="table" then return nil end
    local menu=I("Frame"); menu.Name="ContextMenu"; menu.BackgroundColor3=CFG.PopupBg; menu.BorderSizePixel=0; menu.ZIndex=850; menu.Size=U3(180,0); menu.AutomaticSize=Enum.AutomaticSize.Y; menu.Parent=UI.OGui; FT.C(menu,8); Reg(menu,"BackgroundColor3","PopupBg")
    local lay=I("UIListLayout"); lay.Padding=Un(0,2); lay.Parent=menu
    for _,it in ipairs(items) do
        local b=I("TextButton"); b.Text=ts(it.Text or it.Name or "Item"); b.TextColor3=CFG.Text; b.TextSize=12; b.Font=Enum.Font.GothamMedium; b.BackgroundTransparency=1; b.Size=U2(1,0,0,34); b.Parent=menu; Reg(b,"TextColor3","Text")
        Tk(b.MouseButton1Click:Connect(function() if type(it.Callback)=="function" then SafeCall("ContextMenu",it.Callback) end if menu.Parent then menu:Destroy() end end))
    end
    local p=target.AbsolutePosition; local sz=target.AbsoluteSize; local vp=GetVP(); menu.Position=U2(0,cl(p.X,6,ma(6,vp.X-186)),0,cl(p.Y+sz.Y+4,6,ma(6,vp.Y-180)))
    local api={Frame=menu,Destroy=function(self) if menu.Parent then menu:Destroy() end end}; return api
end
function API:GetPerformance()
    local fps=0; local ok,p=pcall(function() return UI.FV and tonumber(UI.FV.Text) end); if ok then fps=p or 0 end
    local ping=0; pcall(function() local x=S.St.Network.ServerStatsItem["Data Ping"]; ping=x and math.floor(x:GetValue()+.5) or 0 end)
    local inst=0; pcall(function() inst=#UI.Gui:GetDescendants() end)
    local conns=0; for _ in pairs(ST.Conns) do conns=conns+1 end; local tweens=0; for _,bucket in pairs(ST.ActiveTweens) do for _ in pairs(bucket) do tweens=tweens+1 end end
    return {FPS=fps,Ping=ping,Instances=inst,Connections=conns,ActiveTweens=tweens,Notifications=ST.ActiveCount or 0}
end
function API:SetDebug(v) CFG.Debug=v==true; return true end
function API:GetDebug() return CFG.Debug==true end
function API:CreateWatermark(cfg)
    cfg=cfg or {}; if UI.Watermark and UI.Watermark.Parent then UI.Watermark:Destroy() end
    local f=I("TextLabel"); f.Name="Watermark"; f.BackgroundColor3=CFG.Bg; f.BackgroundTransparency=.08; f.TextColor3=CFG.Text; f.TextSize=12; f.Font=Enum.Font.GothamBold; f.Size=U3(cfg.Width or 220,30); f.Position=U2(1,-(cfg.Width or 220)-12,0,12); f.TextXAlignment=Enum.TextXAlignment.Center; f.ZIndex=240; f.Parent=UI.OGui; FT.C(f,15); Reg(f,"BackgroundColor3","Bg"); Reg(f,"TextColor3","Text")
    local api={Frame=f,SetText=function(self,t) f.Text=ts(t or "") end,Destroy=function(self) if f.Parent then f:Destroy() end end}; UI.Watermark=f; if cfg.Text then f.Text=ts(cfg.Text) end; return api
end

function API:CreateWindow(config) if not ValidState() then return nil,"LuaInterface destroyed" end ApplyWindowConfig(config) return self end
function API:ConfigureWindow(config) return self:CreateWindow(config) end
function API:GetWindowConfig() local o={} for k,v in pairs(ST.Window) do if k~="Animations" and k~="TabButtonsStyle" then o[k]=v end end o.Animations={} for k,v in pairs(ST.Window.Animations) do o.Animations[k]=v end o.TabButtonsStyle={} for k,v in pairs(ST.Window.TabButtonsStyle) do o.TabButtonsStyle[k]=v end return o end
function API:SetFooter(v) ST.Window.Footer=ts(v or "") UI.Footer.Text=ST.Window.Footer UI.Footer.Visible=ST.CurrentMode~="Mobile" and ST.Window.Footer~="" return true end
function API:SetBackgroundImage(v) ST.Window.BackgroundImage=v if v==nil or ts(v)=="" then UI.BgImage.Visible=false return true end local id=ts(v) if not id:find("rbxassetid://",1,true) and tonumber(id) then id="rbxassetid://"..id end UI.BgImage.Image=id UI.BgImage.Visible=true return true end
function API:SetCornerRadius(v) v=tn(v) if not v then return false,"radius inválido" end CFG.CornerRadius=v FT.C(UI.Main,v) FT.C(UI.Sidebar,v) return true end
function API:SetSnapping(v,d,m,a) ST.Window.Snapping=v==true if d~=nil then ST.Window.SnapDistance=ma(0,tn(d) or 28) end if m~=nil then ST.Window.SnapMargin=ma(0,tn(m) or 8) end if a~=nil then ST.Window.SnapAvoidCoreGui=a==true end return true end
function API:GetSidebarWidth() return UI.Sidebar.AbsoluteSize.X end
function API:IsSidebarCompacted() return ST.Window.SidebarCompacted==true end
function API:SetSidebarWidth(v) v=tn(v) if not v then return false,"largura inválida" end local maxW=ma(ST.Window.MinSidebarWidth,UI.Main.AbsoluteSize.X-ST.Window.MinContainerWidth) ST.Window.SidebarWidth=cl(v,ST.Window.MinSidebarWidth,maxW) ST.Window.SidebarCompacted=false UpdateResp() return ST.Window.SidebarWidth end
function API:SetCompact(v) if v then ST.Window.LastExpandedSidebarWidth=ST.Window.SidebarWidth or UI.Sidebar.AbsoluteSize.X ST.Window.SidebarCompacted=true else ST.Window.SidebarCompacted=false if ST.Window.LastExpandedSidebarWidth then ST.Window.SidebarWidth=ST.Window.LastExpandedSidebarWidth end end UpdateResp() return true end
function API:ShowTabInfo(n,d) ST.Window.TabInfo={Name=ts(n or ""),Description=ts(d or "")} UI.TabInfoName.Text=ST.Window.TabInfo.Name UI.TabInfoDesc.Text=ST.Window.TabInfo.Description UI.TabInfoName.Visible=true UI.TabInfoDesc.Visible=true return true end
function API:HideTabInfo() ST.Window.TabInfo=nil UI.TabInfoName.Visible=false UI.TabInfoDesc.Visible=false return true end
function API:SetAnimations(c,t,o,f) if type(c)=="table" then for k,v in pairs(c) do if type(v)=="boolean" then ST.Window.Animations[k]=v end end end if t~=nil then ST.Window.TabTransitionTime=ma(0,tn(t) or ST.Window.TabTransitionTime) end if o~=nil then ST.Window.TabSwipeOffset=tn(o) or ST.Window.TabSwipeOffset end if f~=nil then f=sl(ts(f)) if f=="left" or f=="right" or f=="top" or f=="bottom" then ST.Window.TabSwipeFrom=f end end return true end
function API:SetTabButtonsStyle(c)
    if type(c)~="table" then return false,"config inválida" end
    for k,v in pairs(c) do if ST.Window.TabButtonsStyle[k]~=nil then ST.Window.TabButtonsStyle[k]=v end end
    local st=ST.Window.TabButtonsStyle
    if st.Gap~=nil then UI.NavL.Padding=Un(0,tn(st.Gap) or 0) end
    for _,b in pairs(ST.Buttons) do
        local bg=b and b:FindFirstChild("Background")
        if bg and bg:IsA("GuiObject") then pcall(function() FT.C(bg,tn(st.CornerRadius) or CFG.CornerRadius) end) end
        local px=tn(st.Padding) or 0
        local ico=b and b:FindFirstChild("Icon")
        local txt=b and b:FindFirstChild("Text")
        if ico then
            ico.Position=U3(px+(b.AbsoluteSize.X>500 and 12 or 8),0)
            ico.Size=U3(30,48)
        end
        if txt then
            txt.Position=U3(px+48,0)
            txt.Size=U2(1,-(px+56),1,0)
        end
    end
    return true
end
function API:SetResizable(v) ST.Window.Resizable=v~=false if UI.RG then UI.RG.Visible=ST.Window.Resizable end return true end
function API:SetMobileButtons(v,side) ST.Window.ShowMobileButtons=v~=false if side=="Left" or side=="Right" then ST.Window.MobileButtonsSide=side end return true end
function API:SetSearchEnabled(v) ST.Window.DisableSearch=v==false UI.Search.Visible=not ST.Window.DisableSearch and ST.CurrentMode~="Mobile" return true end
function API:SetSearchSize(v) if typeof(v)~="UDim2" then return false,"tamanho inválido" end ST.Window.SearchbarSize=v UI.Search.Size=v return true end
function API:SetPosition(v) if typeof(v)~="UDim2" then return false,"posição inválida" end UI.Main.Position=v ST.Window.Position=v ST.UserMoved=true return true end
function API:SetAutoShow(v) ST.Window.AutoShow=v~=false return true end

function API:ResetAll(cfg)
    cfg=cfg or{}
    return Confirm({Title=cfg.Title or "Resetar configurações?",Content=cfg.Content or "Todas as configurações atuais serão restauradas.",ConfirmText=cfg.ConfirmText or "Resetar",CancelText=cfg.CancelText or "Cancelar",Variant="Destructive",OnConfirm=cfg.OnConfirm or function()
        for i=1,#ST.ElementOrder do local id=ST.ElementOrder[i] local e=ST.Elements[id] if e and e.Set and e.Default~=nil then SafeCall("Reset:"..id,e.Set,e.Default) end end
    end})
end
function API:ConfirmDelete(name,onConfirm)
    return Confirm({Title="Excluir configuração?",Content="A configuração '"..ts(name or "").."' será excluída.",ConfirmText="Excluir",CancelText="Cancelar",Variant="Destructive",OnConfirm=function()
        local ok,err=SM:Delete(name)
        if ok and onConfirm then SafeCall("ConfirmDelete.OnConfirm",onConfirm,name) end
        return ok,err
    end})
end

-- v5.2.0: Destroy cancela todos os tweens/tarefas e invalida callbacks
function API:Destroy()
    if ST.Destroyed or ST.State=="Destroying" then return false end
    ST.State="Destroying"
    ST.Destroyed=true
    ST.ThemeToken=ST.ThemeToken+1
    -- Cancelar todos os tweens ativos ANTES de destruir objetos
    for obj,bucket in pairs(ST.ActiveTweens) do
        for _,tw in pairs(bucket) do
            pcall(function() tw:Cancel() end)
        end
    end
    table.clear(ST.ActiveTweens)
    -- Notificações
    for i=#ST.ActiveNotif,1,-1 do
        local n=ST.ActiveNotif[i]
        ST.ActiveNotif[i]=nil
        if n then pcall(function() n:Destroy() end) end
    end
    table.clear(ST.ActiveNotif)
    ST.ActiveCount=0
    table.clear(IH)
    table.clear(EH)
    CleanHooks()
    table.clear(IC.TintCache)
    if ST.ActiveDialog then pcall(function() ST.ActiveDialog:Close() end) ST.ActiveDialog=nil end
    for i=1,#ST.Tasks do
        local t=ST.Tasks[i]
        if t then pcall(function() task.cancel(t) end) end
        ST.Tasks[i]=nil
    end
    if HBP then pcall(function() HBP:Disconnect() end) end
    if VC then pcall(function() VC:Disconnect() end) end
    for c in pairs(ST.Conns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(ST.Conns)
    ST.ConnCount=0
    ST.MainVisible=false
    ST.CurrentPage=nil
    ST.OpenDropdown=nil
    ST.OpenPopup=nil
    ST.ActiveDialog=nil
    ST.Dragging=false
    table.clear(ST.Pages)
    for i=1,#ST.Framework.ViewportSignals do ST.Framework.ViewportSignals[i]=nil end
    table.clear(ST.Buttons)
    table.clear(ST.ButtonLowerNames)
    table.clear(ST.ButtonIcons)
    if ST.Framework.IconInstances then table.clear(ST.Framework.IconInstances) end
    table.clear(ST.Elements)
    table.clear(ST.Keybinds)
    for i=1,#ST.ElementOrder do ST.ElementOrder[i]=nil end
    table.clear(ST.Themed)
    table.clear(ST.TweenInfoCache)
    table.clear(ST.PageScrolls)
    if UI.Gui and UI.Gui.Parent then UI.Gui:Destroy() end
    if UI.NGui and UI.NGui.Parent then UI.NGui:Destroy() end
    if UI.PGui and UI.PGui.Parent then UI.PGui:Destroy() end
    if UI.DGui and UI.DGui.Parent then UI.DGui:Destroy() end
    if UI.OGui and UI.OGui.Parent then UI.OGui:Destroy() end
    if _G.LuaInterface==API then _G.LuaInterface=nil end
    ST.State="Destroyed"
    return true
end
API.Notify=LuaNotify
API.SaveManager=SM
API.Elements=ST.Elements
API.Options=ST.Elements
API.Toggles=setmetatable({}, {__index=function(_,k) local e=ST.Elements[k]; return e and e.Type=="Toggle" and e or nil end})
API.NewToggle=El.Toggle
API.NewCheckbox=El.Checkbox
API.NewSlider=El.Slider
API.ForceCheckbox=ST.ForceCheckbox
function API:SetForceCheckbox(v) ST.ForceCheckbox=v==true; self.ForceCheckbox=ST.ForceCheckbox; return true end
API.NewButton=El.Button
API.NewKeybind=El.Keybind
API.NewSection=El.Section
API.NewDivider=El.Divider
API.SetTab=function(n) if not ValidState() then return false end return SetTab(n) end
API.Config=CFG
API.Version=CFG.Version
API.Themes=Themes
API.Window=ST.Window


-- ============================================================
-- v5.4.0: UI LIBRARY / FRAMEWORK SYSTEM LAYER
-- Adds public managers and compatibility APIs without adding a
-- large number of chunk-level locals. Runtime state lives in ST.
-- ============================================================
ST.Framework=ST.Framework or {}
ST.Framework.Version="5.4.2"
ST.Framework.Modules=ST.Framework.Modules or {}
ST.Framework.ManagedInstances=ST.Framework.ManagedInstances or {}
ST.Framework.Cleanup=ST.Framework.Cleanup or {}
ST.Framework.UnloadCallbacks=ST.Framework.UnloadCallbacks or {}
ST.Framework.Rules=ST.Framework.Rules or {}
ST.Framework.Input=ST.Framework.Input or {Began={},Ended={},Changed={},Blocked=false,Captures={}}
ST.Framework.Overlays=ST.Framework.Overlays or {}
ST.Framework.NotifyQueue=ST.Framework.NotifyQueue or {}
ST.Framework.AutoSaveTask=nil
ST.Framework.ViewportSignals=ST.Framework.ViewportSignals or {}
ST.Framework.TabMeta=ST.Framework.TabMeta or {}
ST.Framework.TabBadges=ST.Framework.TabBadges or {}
ST.Framework.Cursor=nil
ST.Framework.CursorConn=nil
ST.Framework.CursorEnabled=false
ST.Framework.KeybindList=nil
ST.Framework.PanicKey=nil
ST.Framework.GamepadNavigation=false
ST.Framework.Accessibility={ReducedMotion=false,TextScale=1,LargeText=false,AnimationSnapshot=nil}
ST.Framework.Settings={Notifications=true,Sound=true}

ST.Framework.CustomThemes=ST.Framework.CustomThemes or {}
ST.Framework.CustomThemeNames=ST.Framework.CustomThemeNames or {}

-- ---------- Icon Manager / vector + asset icon registry ----------
-- Public API: Register, RegisterAlias, RegisterPack, Get, Resolve, Exists,
-- Create, Remove, Preload and ClearCache. Built-ins are vector-rendered;
-- asset-backed packs can use Image = "rbxassetid://...". Raw SVG text is
-- intentionally kept as metadata: Roblox ImageLabel cannot consume arbitrary
-- SVG markup directly, so SVGs should be imported/packed as Roblox assets or
-- represented by a renderer function.
ST.Framework.IconRegistry=ST.Framework.IconRegistry or {}
ST.Framework.IconAliases=ST.Framework.IconAliases or {}
ST.Framework.IconPacks=ST.Framework.IconPacks or {}
ST.Framework.IconInstances=setmetatable(ST.Framework.IconInstances or {},{__mode="k"})
ST.Framework.IconManager=ST.Framework.IconManager or {}
ST.Framework.IconManager.Default="dots"

function ST.Framework.IconManager:_Norm(name)
    return sl(ts(name or "")):gsub("%s+","-")
end
function ST.Framework.IconManager:_ResolveName(name)
    local n=self:_Norm(name)
    if n=="" then return "dots" end
    local seen={}
    for _=1,8 do
        if seen[n] then break end
        seen[n]=true
        local a=ST.Framework.IconAliases[n]
        if not a then break end
        n=self:_Norm(a)
    end
    return n
end
function ST.Framework.IconManager:Register(name,spec)
    name=self:_Norm(name)
    if name=="" then return false,"nome de ícone inválido" end
    if type(spec)=="function" then spec={Renderer=spec} end
    if type(spec)=="string" then
        if sm(spec,"^%s*<svg") then spec={SVG=spec} else spec={Image=spec} end
    end
    if type(spec)~="table" then return false,"spec de ícone inválido" end
    local copy={}
    for k,v in pairs(spec) do copy[k]=v end
    if copy.Image and type(copy.Image)=="number" then copy.Image="rbxassetid://"..ts(copy.Image) end
    if copy.Image and type(copy.Image)=="string" and sm(copy.Image,"^%d+$") then copy.Image="rbxassetid://"..copy.Image end
    ST.Framework.IconRegistry[name]=copy
    return true
end
function ST.Framework.IconManager:RegisterSVG(name,markup,opts)
    if type(markup)~="string" or not sm(markup,"^%s*<svg") then return false,"SVG inválido" end
    local spec={SVG=markup}
    if type(opts)=="table" then for k,v in pairs(opts) do spec[k]=v end end
    return self:Register(name,spec)
end
function ST.Framework.IconManager:RegisterAlias(alias,target)
    alias=self:_Norm(alias); target=self:_Norm(target)
    if alias=="" or target=="" or alias==target then return false end
    ST.Framework.IconAliases[alias]=target
    return true
end
function ST.Framework.IconManager:RegisterPack(pack,icons)
    pack=self:_Norm(pack)
    if pack=="" or type(icons)~="table" then return false end
    ST.Framework.IconPacks[pack]=ST.Framework.IconPacks[pack] or {}
    for name,spec in pairs(icons) do
        local key=self:_Norm(name)
        if type(spec)=="function" then spec={Renderer=spec}
        elseif type(spec)=="string" then
            if sm(spec,"^%s*<svg") then spec={SVG=spec} else spec={Image=spec} end
        end
        if type(spec)=="table" then
            local copy={}; for k,v in pairs(spec) do copy[k]=v end
            if type(copy.Image)=="number" then copy.Image="rbxassetid://"..ts(copy.Image)
            elseif type(copy.Image)=="string" and sm(copy.Image,"^%d+$") then copy.Image="rbxassetid://"..copy.Image end
            ST.Framework.IconPacks[pack][key]=copy
        end
    end
    return true
end
function ST.Framework.IconManager:Get(name)
    local raw=self:_Norm(name)
    local n=self:_ResolveName(raw)
    local spec=ST.Framework.IconRegistry[n]
    if spec then return spec end
    local pack,icon=sm(n,"^([^:]+):(.+)$")
    if pack and icon and ST.Framework.IconPacks[pack] then
        local packed=ST.Framework.IconPacks[pack][icon]
        if packed then return packed end
    end
    local fn=IC.ByName[n]
    if fn then return {Renderer=fn,BuiltIn=true,Name=n} end
    return ST.Framework.IconRegistry[self.Default] or {Renderer=IC.Dots,BuiltIn=true,Name="dots"}
end
function ST.Framework.IconManager:Resolve(name)
    local n=self:_ResolveName(name)
    local spec=self:Get(n)
    return n,spec
end
function ST.Framework.IconManager:Exists(name)
    if type(name)=="string" and sm(name,"^%s*<svg") then return true end
    local n=self:_ResolveName(name)
    if ST.Framework.IconRegistry[n] or IC.ByName[n] then return true end
    local pack,icon=sm(n,"^([^:]+):(.+)$")
    return pack~=nil and ST.Framework.IconPacks[pack]~=nil and ST.Framework.IconPacks[pack][icon]~=nil
end
function ST.Framework.IconManager:Remove(name)
    local n=self:_Norm(name)
    ST.Framework.IconRegistry[n]=nil
    ST.Framework.IconAliases[n]=nil
    return true
end
function ST.Framework.IconManager:_Color(value)
    if typeof(value)=="Color3" then return value,nil end
    if type(value)=="string" then
        local key=self:_Norm(value):gsub("-","")
        local map={accent="Purple",text="Text",subtext="SubText",placeholder="SubText",icon="IconBg",button="BgButton",outline="Stroke",stroke="Stroke",background="Bg"}
        key=map[key] or value
        local c=CFG[key]
        if typeof(c)=="Color3" then return c,key end
    end
    return CFG.SubText,"SubText"
end
function ST.Framework.IconManager:_Tint(root,color)
    if not root then return end
    if root:IsA("ImageLabel") or root:IsA("ImageButton") then root.ImageColor3=color end
    IC.T(root,color)
end
function ST.Framework.IconManager:Create(parent,name,opts)
    if not parent then return nil,"parent inválido" end
    opts=opts or {}
    local resolved,spec
    if type(name)=="string" and sm(name,"^%s*<svg") then
        resolved=opts.Name or "custom-svg"
        spec={SVG=name}
    else
        resolved,spec=self:Resolve(name)
    end
    local size=tn(opts.Size) or tn(spec.Size) or 18
    local color,colorKey=self:_Color(opts.Color or spec.Color or "SubText")
    local holder=parent
    local root
    if spec.Renderer or type(spec)=="function" then
        local renderer=type(spec)=="function" and spec or spec.Renderer
        local ok,ico=pcall(renderer,holder,size)
        root=(ok and ico) or IC.Dots(holder,size)
    elseif type(spec.SVG)=="string" then
        local ok,ico=pcall(IC.SVG,holder,size,spec.SVG,opts)
        root=(ok and ico) or IC.Dots(holder,size)
    elseif spec.Image then
        local im=I("ImageLabel")
        im.Name="Icon"
        im.BackgroundTransparency=1
        im.Image=spec.Image
        im.ImageColor3=color
        im.ScaleType=opts.ScaleType or Enum.ScaleType.Fit
        im.Size=U3(size,size)
        im.AnchorPoint=V2(.5,.5)
        im.Position=opts.Position or Uv(.5,.5)
        im.Parent=holder
        root=im
    else
        root=IC.Dots(holder,size)
    end
    if root then
        root.Name=opts.Name or "Icon"
        if opts.AnchorPoint then root.AnchorPoint=opts.AnchorPoint end
        if opts.Position then root.Position=opts.Position end
        if opts.Size and (root:IsA("ImageLabel") or root:IsA("ImageButton")) then root.Size=U3(size,size) end
        self:_Tint(root,color)
        ST.Framework.IconInstances[root]={Name=resolved,Color=color,ThemeKey=colorKey,Size=size}
    end
    return root
end
function ST.Framework.IconManager:Tint(icon,color)
    if not icon then return false end
    local c,key=self:_Color(color)
    self:_Tint(icon,c)
    local rec=ST.Framework.IconInstances[icon]
    if rec then rec.Color=c; rec.ThemeKey=key end
    return true
end
function ST.Framework.IconManager:SetSize(icon,size)
    if not icon then return false end
    size=tn(size) or 18
    local rec=ST.Framework.IconInstances[icon]
    local oldSize=(rec and tn(rec.Size)) or size
    local ratio=oldSize>0 and size/oldSize or 1
    if icon:IsA("ImageLabel") or icon:IsA("ImageButton") then
        icon.Size=U3(size,size)
    else
        for _,node in ipairs(icon:GetDescendants()) do
            if node:IsA("GuiObject") then
                local p=node.Position; local z=node.Size
                node.Position=U2(p.X.Scale,p.X.Offset*ratio,p.Y.Scale,p.Y.Offset*ratio)
                node.Size=U2(z.X.Scale,z.X.Offset*ratio,z.Y.Scale,z.Y.Offset*ratio)
            elseif node:IsA("UIStroke") then
                node.Thickness=node.Thickness*ratio
            elseif node:IsA("UICorner") then
                local r=node.CornerRadius
                node.CornerRadius=Un(r.Scale,r.Offset*ratio)
            end
        end
        icon.Size=U3(size,size)
    end
    if rec then rec.Size=size end
    return true
end
function ST.Framework.IconManager:Preload(names)
    local list={}
    if type(names)=="string" then names={names} end
    names=names or {}
    for i=1,#names do
        local _,spec=self:Resolve(names[i])
        if type(spec)=="table" and type(spec.Image)=="string" and spec.Image~="" then
            local im=I("ImageLabel")
            im.BackgroundTransparency=1; im.Image=spec.Image
            list[#list+1]=im
        end
    end
    if #list==0 then return true end
    local ok,err=pcall(function() S.CP:PreloadAsync(list) end)
    for i=1,#list do pcall(function() list[i]:Destroy() end) end
    return ok,err
end
function ST.Framework.IconManager:ClearCache()
    table.clear(IC.TintCache)
    return true
end

-- Built-in names + common Lucide/Tabler/Phosphor-style aliases.
for iconName,iconFn in pairs(IC.ByName) do
    if not ST.Framework.IconRegistry[iconName] then
        ST.Framework.IconRegistry[iconName]={Renderer=iconFn,BuiltIn=true,Name=iconName}
    end
end
for alias,target in pairs({config="settings",options="settings",cog="settings",gear="settings",configuration="settings",["home-icon"]="home",magnify="search",find="search",danger="alert",warning="alert",error="alert-circle",close="x",cancel="x",remove="x",delete="trash",["trash-2"]="trash",arrowright="arrow-right",next="chevron-right",back="chevron-left",down="chevron-down",up="chevron-up",left="chevron-left",right="chevron-right",lightning="zap",bolt="zap",combat="swords",player="user",players="users",theme="palette",appearance="palette",controls="sliders",reload="refresh",sync="refresh",["save-file"]="save",["download-file"]="download",["upload-file"]="upload",["help-circle"]="help",sparkle="sparkles"}) do ST.Framework.IconManager:RegisterAlias(alias,target) end
ST.Framework.IconManager:RegisterPack("lucide",IC.ByName)
ST.Framework.IconManager:RegisterPack("tabler",IC.ByName)
ST.Framework.IconManager:RegisterPack("phosphor",IC.ByName)
API.IconManager=ST.Framework.IconManager
API.Icons=ST.Framework.IconManager

-- ---------- Core / lifecycle ----------
function API:Unload()
    return self:Destroy()
end
function API:GetVersion()
    return CFG.Version
end
function API:IsAlive()
    return ValidState()
end
function API:GetConnectionCount()
    local n=0
    for _ in pairs(ST.Conns) do n=n+1 end
    return n
end
function API:GiveSignal(signal)
    if not signal then return signal end
    return Tk(signal)
end
function API:GiveInstance(obj)
    if not obj then return obj end
    ST.Framework.ManagedInstances[obj]=true
    return obj
end
function API:GiveTask(thread)
    if thread then TrackTask(thread) end
    return thread
end
function API:OnUnload(fn)
    if type(fn)~="function" then return nil end
    ST.Framework.UnloadCallbacks[#ST.Framework.UnloadCallbacks+1]=fn
    return {Disconnect=function()
        for i=#ST.Framework.UnloadCallbacks,1,-1 do
            if ST.Framework.UnloadCallbacks[i]==fn then
                table.remove(ST.Framework.UnloadCallbacks,i)
                break
            end
        end
    end}
end
function API:CreateSignal()
    local sig={Listeners={},Alive=true}
    function sig:Connect(fn)
        if not self.Alive or type(fn)~="function" then return {Disconnect=function() end} end
        local rec={Fn=fn,Active=true}
        self.Listeners[#self.Listeners+1]=rec
        return {Disconnect=function() rec.Active=false end}
    end
    function sig:Once(fn)
        local con
        con=self:Connect(function(...)
            if con then con:Disconnect() end
            return fn(...)
        end)
        return con
    end
    function sig:Fire(...)
        if not self.Alive then return end
        for i=#self.Listeners,1,-1 do
            local rec=self.Listeners[i]
            if rec and rec.Active then
                SafeCall("Signal",rec.Fn,...)
            else
                table.remove(self.Listeners,i)
            end
        end
    end
    function sig:DisconnectAll()
        for i=#self.Listeners,1,-1 do self.Listeners[i]=nil end
    end
    function sig:Destroy()
        if not self.Alive then return end
        self.Alive=false
        self:DisconnectAll()
    end
    return sig
end
function API:CreateMaid()
    local maid={Tasks={},Alive=true}
    function maid:Give(taskItem)
        if not self.Alive then
            pcall(function()
                if type(taskItem)=="function" then taskItem()
                elseif taskItem and taskItem.Disconnect then taskItem:Disconnect()
                elseif taskItem and taskItem.Destroy then taskItem:Destroy() end
            end)
            return taskItem
        end
        self.Tasks[#self.Tasks+1]=taskItem
        return taskItem
    end
    maid.GiveTask=maid.Give
    maid.GiveSignal=maid.Give
    maid.GiveInstance=maid.Give
    function maid:Clean()
        if not self.Alive then return end
        self.Alive=false
        for i=#self.Tasks,1,-1 do
            local item=self.Tasks[i]
            self.Tasks[i]=nil
            pcall(function()
                if type(item)=="function" then item()
                elseif item and item.Disconnect then item:Disconnect()
                elseif item and item.Destroy then item:Destroy() end
            end)
        end
    end
    maid.Destroy=maid.Clean
    return maid
end

-- ---------- State / registry ----------
function API:CreateState(initial)
    local state={Value=initial,Listeners={},Alive=true}
    function state:Get() return self.Value end
    function state:Set(v)
        if not self.Alive then return false end
        local old=self.Value
        if old==v then return true end
        self.Value=v
        for i=#self.Listeners,1,-1 do
            local rec=self.Listeners[i]
            if rec and rec.Active then SafeCall("State",rec.Fn,v,old) else table.remove(self.Listeners,i) end
        end
        return true
    end
    function state:OnChanged(fn)
        if type(fn)~="function" or not self.Alive then return {Disconnect=function() end} end
        local rec={Fn=fn,Active=true}
        self.Listeners[#self.Listeners+1]=rec
        return {Disconnect=function() rec.Active=false end}
    end
    function state:Destroy()
        self.Alive=false
        table.clear(self.Listeners)
    end
    return state
end
function API:GetStateSnapshot()
    return self:GetState()
end
function API:GetRegistry(name)
    local n=ts(name or "")
    if n=="Theme" or n=="ThemeRegistry" then return ST.Themed end
    if n=="Element" or n=="ElementRegistry" then return ST.Elements end
    if n=="Connection" or n=="ConnectionRegistry" then return ST.Conns end
    if n=="Animation" or n=="AnimationRegistry" then return ST.ActiveTweens end
    if n=="Config" or n=="ConfigRegistry" then return SM end
    if n=="Plugin" or n=="PluginRegistry" then return ST.Plugins end
    if n=="Tab" or n=="TabRegistry" then return ST.Pages end
    return {
        Theme=ST.Themed,Elements=ST.Elements,Connections=ST.Conns,Animations=ST.ActiveTweens,
        Config=SM,Plugins=ST.Plugins,Pages=ST.Pages
    }
end
function API:RegisterRegistry(kind,key,value)
    ST.Framework.Registries=ST.Framework.Registries or {}
    ST.Framework.Registries[kind]=ST.Framework.Registries[kind] or {}
    ST.Framework.Registries[kind][key]=value
    return value
end
function API:GetRegistered(kind,key)
    local r=ST.Framework.Registries and ST.Framework.Registries[kind]
    return r and r[key] or nil
end
function API:Unregister(kind,key)
    local r=ST.Framework.Registries and ST.Framework.Registries[kind]
    if r then r[key]=nil end
    return true
end
function API:RegisterModule(name,module)
    name=ts(name or "")
    if name=="" then return false,"nome inválido" end
    if ST.Framework.Modules[name] then return false,"módulo já registrado" end
    ST.Framework.Modules[name]=module
    if type(module)=="table" and type(module.Init)=="function" then SafeCall("Module:"..name,module.Init,self) end
    return true
end
function API:GetModule(name)
    return ST.Framework.Modules[ts(name or "")]
end
function API:UnregisterModule(name)
    name=ts(name or "")
    local m=ST.Framework.Modules[name]
    if not m then return false end
    if type(m)=="table" and type(m.Destroy)=="function" then SafeCall("ModuleDestroy:"..name,m.Destroy) end
    ST.Framework.Modules[name]=nil
    return true
end

-- ---------- Window system ----------
function API:GetPosition()
    return UI.Main and UI.Main.Position or nil
end
function API:GetSize()
    if not UI.Main then return nil end
    return UI.Main.AbsoluteSize
end
function API:SetMinSize(w,h)
    w=tn(w) or CFG.MinW; h=tn(h) or CFG.MinH
    CFG.MinW=ma(1,w); CFG.MinH=ma(1,h)
    UpdateResp()
    return true
end
function API:SetMaxSize(w,h)
    ST.Framework.MaxW=tn(w); ST.Framework.MaxH=tn(h)
    UpdateResp()
    return true
end
function API:GetMinSize()
    return V2(CFG.MinW,CFG.MinH)
end
function API:GetMaxSize()
    return V2(ST.Framework.MaxW or math.huge,ST.Framework.MaxH or math.huge)
end
function API:SetMaximized(v)
    if v then return self:Fullscreen() end
    if CFG.Fullscreen then return self:Fullscreen() end
    return true
end
function API:IsMaximized()
    return CFG.Fullscreen==true
end
function API:Restore()
    if CFG.Fullscreen then self:Fullscreen() end
    return true
end
function API:SetTransparency(v)
    v=cl(tn(v) or 0,0,1)
    ST.Framework.Transparency=v
    if UI.Main then UI.Main.BackgroundTransparency=v end
    return true
end
function API:GetTransparency()
    return ST.Framework.Transparency or 0
end
function API:SetHeaderVisible(v)
    if UI.Header then UI.Header.Visible=v~=false end
    return true
end
function API:SetBackground(v)
    if typeof(v)=="Color3" and UI.Main then UI.Main.BackgroundColor3=v end
    return true
end

-- ---------- Dynamic tab system ----------
function API:AddTab(name,cfg)
    cfg=cfg or {}
    name=ts(name or cfg.Name or "Tab")
    if name=="" then return nil,"nome inválido" end
    if name=="Home" then return self:GetTab("Home") end
    if ST.Pages[name] then return self:GetTab(name) end
    local page
    page=select(1,CrtPg(name))
    if not page then return nil,"não foi possível criar tab" end
    local nextOrder=0
    for _,meta in pairs(ST.Framework.TabMeta) do
        local o=tn(meta and meta.Order) or 0
        if o>nextOrder then nextOrder=o end
    end
    ST.Framework.TabMeta[name]={Description=ts(cfg.Description or ""),Visible=cfg.Visible~=false,Order=tn(cfg.Order) or (nextOrder+1),Icon=cfg.Icon}
    local b=I("TextButton")
    b.Name=name
    b.BackgroundTransparency=1
    b.Text=""
    b.AutoButtonColor=false
    b.Active=true
    b.Selectable=true
    b.LayoutOrder=ST.Framework.TabMeta[name].Order
    b.Parent=UI.Nav
    local bg=I("Frame")
    bg.Name="Background"; bg.Size=Uv(1,1); bg.BackgroundColor3=CFG.NavActive; bg.BackgroundTransparency=1; bg.Parent=b; FT.C(bg,10); Reg(bg,"BackgroundColor3","NavActive")
    local bar=I("Frame")
    bar.Name="ActiveBar"; bar.Size=U3(3,24); bar.Position=U3(0,12); bar.BackgroundColor3=CFG.Purple; bar.BorderSizePixel=0; bar.Visible=false; bar.Parent=b; FT.C(bar,3); Reg(bar,"BackgroundColor3","Purple")
    local iconText=nil
    if type(cfg.Icon)=="function" then
        local holder=I("Frame"); holder.Name="Icon"; holder.BackgroundTransparency=1; holder.Size=U3(30,30); holder.Position=U3(6,9); holder.Parent=b
        local ico=cfg.Icon(holder,18)
        if ico then ico.AnchorPoint=V2(.5,.5); ico.Position=Uv(.5,.5); IC.T(ico,CFG.SubText); ST.ButtonIcons[name]=ST.ButtonIcons[name] or {}; ST.ButtonIcons[name][#ST.ButtonIcons[name]+1]=ico end
    elseif type(cfg.Icon)=="string" and API.IconManager and API.IconManager:Exists(cfg.Icon) then
        local holder=I("Frame"); holder.Name="Icon"; holder.BackgroundTransparency=1; holder.Size=U3(30,30); holder.Position=U3(6,9); holder.Parent=b
        local ico=API.IconManager:Create(holder,cfg.Icon,{Size=18,Color="SubText"})
        if ico then ST.ButtonIcons[name]=IC.CT(ico); ST.Framework.IconInstances[ico]=ST.Framework.IconInstances[ico] or {Name=cfg.Icon,Color=CFG.SubText,ThemeKey="SubText",Size=18} end
    else
        iconText=FT.L(b,ts(cfg.Icon or ""),18,CFG.SubText); iconText.Name="Icon"; iconText.Size=U3(30,48); iconText.Position=U3(4,0); iconText.TextXAlignment=Enum.TextXAlignment.Center; Reg(iconText,"TextColor3","SubText")
    end
    local text=FT.L(b,name,13,CFG.SubText); text.Name="Text"; text.Position=U3(44,0); text.Size=U2(1,-50,1,0); text.TextTruncate=Enum.TextTruncate.AtEnd; Reg(text,"TextColor3","SubText")
    ST.Buttons[name]=b; ST.ButtonLowerNames[name]=sl(name)
    Tk(b.MouseEnter:Connect(function() if ST.CurrentPage~=name then FT.T(bg,{BackgroundTransparency=.55},.16,"TabHover") end end))
    Tk(b.MouseLeave:Connect(function() if ST.CurrentPage~=name then FT.T(bg,{BackgroundTransparency=1},.16,"TabHover") end end))
    Tk(b.MouseButton1Click:Connect(function() SetTab(name) end))
    if cfg.Visible==false then b.Visible=false; page.Visible=false end
    local tab=self:GetTab(name)
    function tab:AddLeftGroupbox(gcfg) gcfg=gcfg or {}; gcfg.Side="Left"; return MakeGroupbox(page,gcfg) end
    function tab:AddRightGroupbox(gcfg) gcfg=gcfg or {}; gcfg.Side="Right"; return MakeGroupbox(page,gcfg) end
    function tab:AddGroupbox(gcfg) return MakeGroupbox(page,gcfg or {}) end
    function tab:AddTabbox(tcfg) return MakeTabbox(page,tcfg or {}) end
    function tab:AddDependencyBox() return MakeDependency(page,false) end
    function tab:AddDependencyGroupbox() return MakeDependency(page,true) end
    function tab:AddLabel(c) return ElementAPI(page):AddLabel(c) end
    function tab:AddButton(a,b) return ElementAPI(page):AddButton(a,b) end
    function tab:AddToggle(a,b) return ElementAPI(page):AddToggle(a,b) end
    function tab:AddCheckbox(a,b) return ElementAPI(page):AddCheckbox(a,b) end
    function tab:AddSlider(a,b) return ElementAPI(page):AddSlider(a,b) end
    function tab:AddDropdown(a,b) return ElementAPI(page):AddDropdown(a,b) end
    function tab:AddMultiDropdown(a,b) b=b or {}; b.Multi=true; return ElementAPI(page):AddDropdown(a,b) end
    function tab:AddInput(a,b) return ElementAPI(page):AddInput(a,b) end
    function tab:AddKeybind(a,b) return ElementAPI(page):AddKeybind(a,b) end
    function tab:AddColorPicker(a,b) b=b or {}; b.Index=b.Index or a; return El.ColorPicker(page,b) end
    function tab:AddSection(a) return El.Section(page,a) end
    function tab:AddDivider(a) return El.Divider(page,a) end
    tab.GetContainer=function() return UI.PageCts[name] end
    if cfg.Select==true then SetTab(name) end
    ScheduleResp()
    return tab
end
function API:CreateTab(name,cfg) return self:AddTab(name,cfg) end
function API:AddMultiDropdown(target,id,cfg)
    if not target then return nil,"container inválido" end
    cfg=cfg or {}; cfg.Multi=true; cfg.Index=cfg.Index or id
    if type(target)=="table" and target.AddDropdown then return target:AddDropdown(id,cfg) end
    return El.Dropdown(target,cfg)
end
function API:AddLeftGroupbox(tabName,cfg)
    local t=self:GetTab(tabName); if not t then return nil,"tab inexistente" end
    cfg=cfg or {}; cfg.Side="Left"; return MakeGroupbox(t.Container,cfg)
end
function API:AddRightGroupbox(tabName,cfg)
    local t=self:GetTab(tabName); if not t then return nil,"tab inexistente" end
    cfg=cfg or {}; cfg.Side="Right"; return MakeGroupbox(t.Container,cfg)
end
function API:RemoveTab(name)
    name=ts(name or "")
    if name=="Home" then return false,"Home não pode ser removida" end
    local b=ST.Buttons[name]; local p=ST.Pages[name]; local c=UI.PageCts[name]
    if not b and not p then return false end
    if ST.CurrentPage==name then
        if ST.Pages.Home then SetTab("Home") end
    end
    if b and b.Parent then b:Destroy() end
    if p and p.Parent then p:Destroy() end
    if c and c.Parent then c:Destroy() end
    ST.Buttons[name]=nil; ST.Pages[name]=nil; UI.PageCts[name]=nil; ST.ButtonIcons[name]=nil; ST.ButtonLowerNames[name]=nil; ST.Framework.TabMeta[name]=nil
    ScheduleResp()
    return true
end
function API:SelectTab(name) return SetTab(ts(name or "Home")) end
function API:SetTabVisible(name,v)
    name=ts(name or ""); local b=ST.Buttons[name]; local p=ST.Pages[name]; if not b then return false end
    local vis=v~=false; b.Visible=vis; if p and ST.CurrentPage~=name then p.Visible=false end
    if not vis and ST.CurrentPage==name then SetTab("Home") end
    if ST.Framework.TabMeta[name] then ST.Framework.TabMeta[name].Visible=vis end
    return true
end
function API:SetTabOrder(name,order)
    local b=ST.Buttons[ts(name or "")]; if not b then return false end
    b.LayoutOrder=tn(order) or b.LayoutOrder
    if ST.Framework.TabMeta[ts(name or "")] then ST.Framework.TabMeta[ts(name or "")].Order=b.LayoutOrder end
    return true
end
function API:SetTabDescription(name,desc)
    name=ts(name or ""); ST.Framework.TabMeta[name]=ST.Framework.TabMeta[name] or {}; ST.Framework.TabMeta[name].Description=ts(desc or ""); return true
end
function API:SetTabBadge(name,text,visible)
    name=ts(name or ""); local b=ST.Buttons[name]; if not b then return false end
    local badge=ST.TabBadges[name]
    if not badge then
        badge=I("TextLabel"); badge.Name="Badge"; badge.BackgroundColor3=CFG.Purple; badge.TextColor3=WH; badge.TextSize=10; badge.Font=Enum.Font.GothamBold; badge.AnchorPoint=V2(1,.5); badge.Position=U2(1,-8,.5,0); badge.Size=U3(24,18); badge.Parent=b; FT.C(badge,8); Reg(badge,"BackgroundColor3","Purple"); ST.TabBadges[name]=badge
    end
    badge.Text=ts(text or ""); badge.Visible=visible~=false and badge.Text~=""; return true
end
function API:GetTabs()
    local out={}
    for name,b in pairs(ST.Buttons) do out[#out+1]={Name=name,Visible=b.Visible,Order=b.LayoutOrder,Description=ST.Framework.TabMeta[name] and ST.Framework.TabMeta[name].Description or ""} end
    table.sort(out,function(a,b) return a.Order<b.Order end)
    return out
end

-- ---------- Container / card / scrolling system ----------
function API:CreateCard(parent,cfg)
    if not parent then return nil end
    cfg=cfg or {}
    local f=I("Frame")
    f.Name=cfg.Name and ts(cfg.Name) or "Card"
    f.BackgroundColor3=CFG.Card; f.BorderSizePixel=0; f.Size=cfg.Size or U2(1,0,0,48); f.AutomaticSize=cfg.AutomaticSize or Enum.AutomaticSize.None; f.Parent=parent
    FT.C(f,tn(cfg.CornerRadius) or 10); Reg(f,"BackgroundColor3","Card")
    if cfg.Stroke~=false then local st=FT.S(f,CFG.Stroke,tn(cfg.StrokeThickness) or 1); Reg(st,"Color","Stroke") end
    if cfg.Padding then
        local pd=I("UIPadding"); pd.PaddingLeft=Un(0,tn(cfg.Padding) or 8); pd.PaddingRight=Un(0,tn(cfg.Padding) or 8); pd.PaddingTop=Un(0,tn(cfg.Padding) or 8); pd.PaddingBottom=Un(0,tn(cfg.Padding) or 8); pd.Parent=f
    end
    return f
end
function API:CreateScrollContainer(parent,cfg)
    if not parent then return nil end
    cfg=cfg or {}
    local s=I("ScrollingFrame")
    s.Name=cfg.Name or "ScrollContainer"; s.BackgroundTransparency=cfg.BackgroundTransparency or 1; s.BorderSizePixel=0; s.Size=cfg.Size or U2(1,0,1,0); s.CanvasSize=cfg.CanvasSize or U2(0,0,0,0); s.AutomaticCanvasSize=cfg.AutomaticCanvasSize or Enum.AutomaticSize.Y; s.ScrollBarThickness=tn(cfg.ScrollBarThickness) or 3; s.ScrollingDirection=cfg.ScrollingDirection or Enum.ScrollingDirection.Y; s.Parent=parent
    if cfg.Padding then local pd=I("UIPadding"); pd.PaddingLeft=Un(0,cfg.Padding); pd.PaddingRight=Un(0,cfg.Padding); pd.PaddingTop=Un(0,cfg.Padding); pd.PaddingBottom=Un(0,cfg.Padding); pd.Parent=s end
    return s
end
function API:CreateSection(parent,cfg) return El.Section(parent,cfg) end
function API:CreateDivider(parent,cfg) return El.Divider(parent,cfg) end

-- ---------- Element API / dependency helpers ----------
function API:GetElement(id)
    return ST.Elements[ts(id or "")]
end
function API:GetElements()
    local out={}
    for i=1,#ST.ElementOrder do
        local id=ST.ElementOrder[i]; local e=ST.Elements[id]
        if e then out[id]=e end
    end
    return out
end
function API:DestroyElement(id)
    local e=ST.Elements[ts(id or "")]
    return e and e:Destroy() or false
end
function API:SetElementValue(id,v)
    local e=self:GetElement(id); if not e or type(e.SetValue)~="function" then return false end
    return e:SetValue(v)
end
function API:GetElementValue(id)
    local e=self:GetElement(id); if not e then return nil end
    if e.Get then local ok,v=pcall(e.Get); if ok then return v end end
    return e.Value
end
function API:DependsOn(element,source,expected,mode)
    if not element or type(element.OnChanged)~="function" then return false end
    element._FrameworkDeps=element._FrameworkDeps or {}
    element._FrameworkDepMode=mode or "AND"
    element._FrameworkDepRefresh=function()
        local deps=element._FrameworkDeps; local okAll=true; local okAny=false
        for i=1,#deps do
            local d=deps[i]; local value=nil; local got=false
            if d.Source and type(d.Source.Get) == "function" then local ok,v=pcall(d.Source.Get); got=ok; value=v end
            local match=got and (d.Expected==nil and value or value==d.Expected)
            if d.Inverse then match=not match end
            if match then okAny=true else okAll=false end
        end
        local enabled=(element._FrameworkDepMode=="OR") and okAny or okAll
        if element.SetVisible and element._FrameworkVisibleRule==nil then element:SetVisible(enabled) end
        if element.SetDisabled and element._FrameworkDisabledRule==nil then element:SetDisabled(not enabled) end
    end
    element._FrameworkDeps[#element._FrameworkDeps+1]={Source=source,Expected=expected,Inverse=false}
    if source and type(source.OnChanged)=="function" then
        element._FrameworkRuleConns=element._FrameworkRuleConns or {}
        element._FrameworkRuleConns[#element._FrameworkRuleConns+1]=source:OnChanged(function() if element._FrameworkDepRefresh then element._FrameworkDepRefresh() end end)
    end
    element._FrameworkDepRefresh()
    return true
end
function API:VisibleWhen(element,fn)
    if not element or type(fn)~="function" then return false end
    element._FrameworkVisibleRule=fn
    element._FrameworkVisibleConn=element._FrameworkVisibleConn or nil
    element._FrameworkVisibleRefresh=function()
        local ok,v=pcall(fn,element); if element.SetVisible then element:SetVisible(ok and v==true) end
    end
    element._FrameworkVisibleRefresh()
    return true
end
function API:DisabledWhen(element,fn)
    if not element or type(fn)~="function" then return false end
    element._FrameworkDisabledRule=fn
    element._FrameworkDisabledRefresh=function()
        local ok,v=pcall(fn,element); if element.SetDisabled then element:SetDisabled(ok and v==true) end
    end
    element._FrameworkDisabledRefresh()
    return true
end
function API:BindDependency(element,deps,mode)
    if not element or type(deps)~="table" then return false end
    element._FrameworkDeps=element._FrameworkDeps or {}
    element._FrameworkDepMode=mode or element._FrameworkDepMode or "AND"
    for i=1,#deps do
        local d=deps[i]; if type(d)=="table" then self:DependsOn(element,d[1] or d.Source,d[2] or d.Expected,d.Inverse and "AND" or (mode or "AND")); if d.Inverse and element._FrameworkDeps[#element._FrameworkDeps] then element._FrameworkDeps[#element._FrameworkDeps].Inverse=true end end
    end
    if element._FrameworkDepRefresh then element._FrameworkDepRefresh() end
    return true
end

-- ---------- Theme manager ----------
function API:RegisterTheme(name,data,base)
    name=ts(name or "")
    if name=="" or type(data)~="table" then return false,"tema inválido" end
    local source=Themes[base or ST.CurrentTheme] or Themes.Dark
    local t={}
    for k,v in pairs(source) do t[k]=v end
    for k,v in pairs(data) do t[k]=v end
    if not t.Background and t.Bg then t.Background=t.Bg end
    if not t.Bg and t.Background then t.Bg=t.Background end
    if not t.Accent and t.Purple then t.Accent=t.Purple end
    if not t.Purple and t.Accent then t.Purple=t.Accent end
    Themes[name]=t
    ST.Framework.CustomThemes[name]=t
    local exists=false
    for i=1,#ST.Framework.CustomThemeNames do if ST.Framework.CustomThemeNames[i]==name then exists=true break end end
    if not exists then ST.Framework.CustomThemeNames[#ST.Framework.CustomThemeNames+1]=name end
    return true
end
function API:SetTheme(theme)
    if type(theme)=="table" then
        local name="Custom_"..S.H:GenerateGUID(false):gsub("[^%w_]","_")
        self:RegisterTheme(name,theme,ST.CurrentTheme)
        return self:ApplyTheme(name)
    end
    return self:ApplyTheme(ts(theme or "Dark"))
end
function API:GetThemeRegistry()
    return ST.Themed
end
function API:ValidateTheme(name)
    local t=Themes[ts(name or "")]
    if not t then return false,{Missing="theme"} end
    local required={"Background","Sidebar","Card","Purple","Text","SubText","Stroke","IconBg","BgButton","BgTrack","NavActive","PopupBg","DangerBg","DangerText"}
    local miss={}
    for i=1,#required do if t[required[i]]==nil then miss[#miss+1]=required[i] end end
    return #miss==0,{Missing=miss}
end
API.ThemeManager={
    Set=function(_,name) return API:SetTheme(name) end,
    Apply=function(_,name) return API:ApplyTheme(name) end,
    Register=function(_,name,data,base) return API:RegisterTheme(name,data,base) end,
    Get=function(_) return API:GetThemeData() end,
    List=function(_) return API:GetThemes() end,
    Validate=function(_,name) return API:ValidateTheme(name) end,
}

-- ---------- Config manager / autosave / import-export ----------
ST.Framework.ConfigDefaults=ST.Framework.ConfigDefaults or {}
function SM:SetDefault(name)
    self.DefaultName=ts(name or "")
    return self.DefaultName
end
function SM:GetDefault() return self.DefaultName end
function SM:ResetDefaults()
    for i=1,#ST.ElementOrder do
        local id=ST.ElementOrder[i]; local e=ST.Elements[id]
        if e and e.Set and e.Default~=nil then SafeCall("ResetDefault:"..id,e.Set,e.Default) end
    end
    return true
end
function SM:Export(name)
    if type(name)~="string" or name=="" then return false,"config inválida" end
    local function packUDim2(v)
        if typeof(v)~="UDim2" then return nil end
        return {XS=v.X.Scale,XO=v.X.Offset,YS=v.Y.Scale,YO=v.Y.Offset}
    end
    local data={Theme=SM.IgnoreTheme and nil or ST.CurrentTheme,Scale=ST.Scale,Elements={},Window={Position=packUDim2(UI.Main.Position),Size=packUDim2(UI.Main.Size),Fullscreen=false}}
    for i=1,#ST.ElementOrder do
        local id=ST.ElementOrder[i]; local e=ST.Elements[id]
        if e and e.Get and not self.IgnoreIndexes[id] then local ok,v=pcall(e.Get); if ok then data.Elements[id]=v end end
    end
    local ok,out=pcall(function() return S.H:JSONEncode(data) end)
    if not ok then return false,out end
    return out
end
function SM:Import(raw,applyNow)
    if type(raw)~="string" then return false,"dados inválidos" end
    local ok,data=pcall(function() return S.H:JSONDecode(raw) end)
    if not ok or type(data)~="table" then return false,"json inválido" end
    if applyNow~=false then
        if data.Theme and Themes[data.Theme] and not self.IgnoreTheme then API:ApplyTheme(data.Theme) end
        if tn(data.Scale) then API:SetScale(data.Scale) end
        for id,v in pairs(data.Elements or {}) do local e=ST.Elements[id]; if e and e.Set then SafeCall("Import:"..id,e.Set,v) end end
        if type(data.Window)=="table" then
            local w=data.Window
            if type(w.Position)=="table" then
                UI.Main.Position=U2(tn(w.Position.XS) or 0,tn(w.Position.XO) or 0,tn(w.Position.YS) or 0,tn(w.Position.YO) or 0)
                ST.Window.Position=UI.Main.Position
                ST.UserMoved=true
            end
            if type(w.Size)=="table" and tn(w.Size.XO) and tn(w.Size.YO) then
                ST.CustomSize=V2(w.Size.XO,w.Size.YO)
                ST.Window.Size=U3(w.Size.XO,w.Size.YO)
            end
        end
    end
    return data
end
function SM:StartAutoSave(name,seconds)
    self:StopAutoSave()
    name=ts(name or self.AutoloadName or "autosave")
    seconds=ma(5,tn(seconds) or 60)
    ST.Framework.AutoSaveTask=task.spawn(function()
        while ValidState() do
            task.wait(seconds)
            if not ValidState() then break end
            local ok,err=pcall(function() self:Save(name) end)
            if not ok and CFG.Debug then warn("[LuaInterface] AutoSave: "..ts(err)) end
        end
    end)
    TrackTask(ST.Framework.AutoSaveTask)
    self.AutoSaveName=name; self.AutoSaveInterval=seconds; self.AutoSaveEnabled=true
    return true
end
function SM:StopAutoSave()
    if ST.Framework.AutoSaveTask then pcall(function() task.cancel(ST.Framework.AutoSaveTask) end) end
    ST.Framework.AutoSaveTask=nil; self.AutoSaveEnabled=false
    return true
end
function SM:IsAutoSaveEnabled() return self.AutoSaveEnabled==true end
function SM:GetAutoSaveInfo() return {Enabled=self.AutoSaveEnabled==true,Name=self.AutoSaveName,Interval=self.AutoSaveInterval} end
API.ConfigManager=SM

-- Full config payload: elements + theme + scale + window/runtime preferences.
ST._FrameworkOriginalSave=ST._FrameworkOriginalSave or SM.Save
ST._FrameworkOriginalLoad=ST._FrameworkOriginalLoad or SM.Load
function SM:Save(name)
    if not writefile then return false,"filesystem unavailable" end
    if type(name)~="string" or name=="" then return false,"invalid config name" end
    if not EnsureFolder(GetFP()) then return false,"folder unavailable" end
    local function packUDim2(v)
        if typeof(v)~="UDim2" then return nil end
        return {XS=v.X.Scale,XO=v.X.Offset,YS=v.Y.Scale,YO=v.Y.Offset}
    end
    local data={
        Version=CFG.Version,
        Theme=self.IgnoreTheme and nil or ST.CurrentTheme,
        Scale=ST.Scale,
        Language=ST.Language,
        Elements={},
        Window={
            Position=packUDim2(UI.Main.Position),
            Size=packUDim2(UI.Main.Size),
            CustomSize=ST.CustomSize and {X=ST.CustomSize.X,Y=ST.CustomSize.Y} or nil,
            Fullscreen=CFG.Fullscreen==true,
            AlwaysOnTop=ST.Window.AlwaysOnTop==true,
            SidebarWidth=ST.Window.SidebarWidth,
            SidebarCompacted=ST.Window.SidebarCompacted==true,
            GlobalSearch=ST.Window.GlobalSearch==true,
        }
    }
    for i=1,#ST.ElementOrder do
        local id=ST.ElementOrder[i]; local e=ST.Elements[id]
        if e and e.Get and not self.IgnoreIndexes[id] then
            local ok,v=pcall(e.Get)
            if ok and (type(v)=="boolean" or type(v)=="number" or type(v)=="string" or type(v)=="table") then data.Elements[id]=v end
        end
    end
    local ok,encoded=pcall(function() return S.H:JSONEncode(data) end)
    if not ok then return false,encoded end
    local wok,werr=pcall(writefile,self:_Path(name),encoded)
    return wok and true or false,werr
end
function SM:Load(name)
    if not readfile or type(name)~="string" or name=="" then return false,"filesystem unavailable or invalid name" end
    local ok,raw=pcall(readfile,self:_Path(name)); if not ok then return false,raw end
    local dok,data=pcall(function() return S.H:JSONDecode(raw) end); if not dok or type(data)~="table" then return false,"invalid config" end
    local function unpackUDim2(v)
        if type(v)~="table" then return nil end
        return U2(tn(v.XS) or 0,tn(v.XO) or 0,tn(v.YS) or 0,tn(v.YO) or 0)
    end
    if data.Theme and not self.IgnoreTheme and Themes[data.Theme] then API:ApplyTheme(data.Theme) end
    if tn(data.Scale) then API:SetScale(data.Scale) end
    if data.Language then API:SetLanguage(data.Language) end
    for id,v in pairs(data.Elements or {}) do
        local e=ST.Elements[id]
        if e and e.Set and not self.IgnoreIndexes[id] then SafeCall("Load:"..id,e.Set,v) end
    end
    local w=data.Window
    if type(w)=="table" then
        local pos=unpackUDim2(w.Position); local size=unpackUDim2(w.Size)
        if pos then UI.Main.Position=pos; ST.Window.Position=pos; ST.UserMoved=true end
        if size then UI.Main.Size=size; ST.Window.Size=size; ST.CustomSize=V2(size.X.Offset,size.Y.Offset) end
        if type(w.CustomSize)=="table" and tn(w.CustomSize.X) and tn(w.CustomSize.Y) then ST.CustomSize=V2(w.CustomSize.X,w.CustomSize.Y) end
        if w.AlwaysOnTop~=nil then API:SetAlwaysOnTop(w.AlwaysOnTop) end
        if w.SidebarWidth then API:SetSidebarWidth(w.SidebarWidth) end
        if w.SidebarCompacted~=nil then API:SetCompact(w.SidebarCompacted) end
        ST.Window.GlobalSearch=w.GlobalSearch==true
        if w.Fullscreen==true and not CFG.Fullscreen then API:Fullscreen() end
    end
    UpdateResp()
    return true
end

-- ---------- Keybind manager / list / panic ----------
function API:GetKeybinds()
    local out={}
    for id,key in pairs(ST.Keybinds) do
        local e=ST.Elements[id]
        out[#out+1]={Id=id,Key=key,Mode=e and e.Mode or nil,Value=e and e.Value or nil}
    end
    table.sort(out,function(a,b) return ts(a.Id)<ts(b.Id) end)
    return out
end
function API:SetPanicKey(key,handler)
    ST.Framework.PanicKey=key
    ST.Framework.PanicHandler=type(handler)=="function" and handler or function() API:Close() end
    if ST.Framework.PanicConn then pcall(function() ST.Framework.PanicConn:Disconnect() end) end
    ST.Framework.PanicConn=Tk(S.U.InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        local match=false
        if typeof(key)=="EnumItem" and inp.KeyCode==key then match=true end
        if type(key)=="string" and inp.KeyCode and inp.KeyCode.Name==key then match=true end
        if match then SafeCall("PanicKey",ST.Framework.PanicHandler) end
    end))
    return true
end
function API:ShowKeybindList(cfg)
    cfg=cfg or {}
    if ST.Framework.KeybindList and ST.Framework.KeybindList.Frame and ST.Framework.KeybindList.Frame.Parent then ST.Framework.KeybindList:Destroy() end
    local f=I("Frame"); f.Name="KeybindList"; f.BackgroundColor3=CFG.PopupBg; f.BorderSizePixel=0; f.Size=U3(cfg.Width or 210,100); f.AutomaticSize=Enum.AutomaticSize.Y; f.Position=U2(1,-(cfg.Width or 210)-12,0,cfg.Y or 50); f.ZIndex=245; f.Parent=UI.OGui; FT.C(f,10); Reg(f,"BackgroundColor3","PopupBg")
    local title=FT.L(f,cfg.Title or "ACTIVE KEYBINDS",11,CFG.SubText); title.Position=U3(12,7); title.Size=U2(1,-24,0,20); Reg(title,"TextColor3","SubText")
    local list=I("Frame"); list.BackgroundTransparency=1; list.Size=U2(1,-20,0,0); list.Position=U3(10,31); list.AutomaticSize=Enum.AutomaticSize.Y; list.Parent=f
    local lay=I("UIListLayout"); lay.Padding=Un(0,3); lay.Parent=list
    local obj={Frame=f,Alive=true}
    function obj:Refresh()
        for _,x in ipairs(list:GetChildren()) do if x~=lay then x:Destroy() end end
        local items=API:GetKeybinds()
        for i=1,#items do
            local row=I("TextLabel"); row.BackgroundTransparency=1; row.Size=U2(1,0,0,20); row.TextXAlignment=Enum.TextXAlignment.Left; row.TextSize=11; row.Font=Enum.Font.GothamMedium; row.TextColor3=CFG.Text; row.Text=ts(items[i].Key).."    "..ts(items[i].Id); row.Parent=list; Reg(row,"TextColor3","Text")
        end
        return true
    end
    function obj:Destroy()
        self.Alive=false
        if f.Parent then f:Destroy() end
        if ST.Framework.KeybindList==self then ST.Framework.KeybindList=nil end
    end
    obj:Refresh()
    if cfg.AutoRefresh~=false then
        ST.Framework.KeybindListTask=task.spawn(function()
            while obj.Alive and f.Parent do task.wait(.5); if obj.Alive then obj:Refresh() end end
        end)
        TrackTask(ST.Framework.KeybindListTask)
    end
    ST.Framework.KeybindList=obj
    return obj
end
API.KeybindManager={GetAll=function(_) return API:GetKeybinds() end,SetPanic=function(_,k,fn) return API:SetPanicKey(k,fn) end,ShowList=function(_,cfg) return API:ShowKeybindList(cfg) end}

-- ---------- Input manager ----------
function API:BindInput(kind,id,fn)
    kind=sl(ts(kind or "began")); id=ts(id or "")
    if id=="" or type(fn)~="function" then return false end
    local bucket=ST.Framework.Input[kind]
    if not bucket then return false end
    bucket[id]=fn
    return {Disconnect=function() bucket[id]=nil end}
end
function API:BlockInput(v) ST.Framework.Input.Blocked=v==true; return true end
function API:IsInputBlocked() return ST.Framework.Input.Blocked==true end
function API:CaptureTouch(id,input)
    id=ts(id or ""); if id=="" then return false end
    ST.Framework.Input.Captures[id]=input
    return true
end
function API:ReleaseTouch(id) ST.Framework.Input.Captures[ts(id or "")]=nil; return true end
function API:GetFocusedTextBox() return S.U:GetFocusedTextBox() end
function API:GetLastInputType() return S.U:GetLastInputType() end
function API:IsGamepadAvailable() return S.U.GamepadEnabled or false end
function API:IsTouchCaptured(input)
    for _,v in pairs(ST.Framework.Input.Captures) do if v==input then return true end end
    return false
end
ST.Framework.Input.BeganConn=Tk(S.U.InputBegan:Connect(function(inp,gpe)
    if ST.Framework.Input.Blocked then return end
    for id,fn in pairs(ST.Framework.Input.Began) do SafeCall("InputBegan:"..id,fn,inp,gpe) end
end))
ST.Framework.Input.EndedConn=Tk(S.U.InputEnded:Connect(function(inp,gpe)
    if ST.Framework.Input.Blocked then return end
    for id,fn in pairs(ST.Framework.Input.Ended) do SafeCall("InputEnded:"..id,fn,inp,gpe) end
end))
ST.Framework.Input.ChangedConn=Tk(S.U.InputChanged:Connect(function(inp,gpe)
    if ST.Framework.Input.Blocked then return end
    for id,fn in pairs(ST.Framework.Input.Changed) do SafeCall("InputChanged:"..id,fn,inp,gpe) end
end))
API.InputManager={Bind=function(_,k,id,fn) return API:BindInput(k,id,fn) end,Block=function(_,v) return API:BlockInput(v) end,Capture=function(_,id,input) return API:CaptureTouch(id,input) end,Release=function(_,id) return API:ReleaseTouch(id) end,Focused=function(_) return API:GetFocusedTextBox() end}
function API:OnWindowFocus(focused,unfocused)
    local out={}
    if type(focused)=="function" and S.U.WindowFocused then out[#out+1]=Tk(S.U.WindowFocused:Connect(function() SafeCall("WindowFocused",focused) end)) end
    if type(unfocused)=="function" and S.U.WindowFocusReleased then out[#out+1]=Tk(S.U.WindowFocusReleased:Connect(function() SafeCall("WindowFocusReleased",unfocused) end)) end
    return out
end
API.InputManager.Focus=function(_,a,b) return API:OnWindowFocus(a,b) end

-- ---------- Notification / queue manager ----------
function API:ClearNotifications()
    for i=#ST.ActiveNotif,1,-1 do local n=ST.ActiveNotif[i]; if n and n.Destroy then n:Destroy() end end
    table.clear(ST.Framework.NotifyQueue)
    return true
end
function API:SetNotificationLimit(n) CFG.MaxNotify=ma(1,fl(tn(n) or CFG.MaxNotify)); return true end
function API:GetNotifications()
    local out={}
    for i=1,#ST.ActiveNotif do
        local n=ST.ActiveNotif[i]
        if n and n._alive then out[#out+1]=n end
    end
    return out
end
function API:QueueNotification(cfg)
    if ST.ActiveCount<CFG.MaxNotify then return LuaNotify(cfg) end
    ST.Framework.NotifyQueue[#ST.Framework.NotifyQueue+1]=cfg
    return nil
end
API.NotificationManager={Notify=LuaNotify,Queue=function(_,cfg) return API:QueueNotification(cfg) end,Clear=function(_) return API:ClearNotifications() end,GetActive=function(_) return API:GetNotifications() end,SetLimit=function(_,n) return API:SetNotificationLimit(n) end}

-- ---------- Tooltip manager ----------
function API:AttachTooltip(target,text,opts)
    opts=opts or {}
    return AttachTooltip(target,function()
        if type(text)=="function" then return text() end
        return text
    end,function() return opts.Disabled==true and opts.DisabledTooltip or nil end)
end
API.TooltipManager={Attach=function(_,target,text,opts) return API:AttachTooltip(target,text,opts) end}

-- ---------- Context menu ----------
function API:ShowContextMenu(target,items) return self:ContextMenu(target,items) end
API.ContextMenuManager={Open=function(_,target,items) return API:ContextMenu(target,items) end}
function API:AttachContextMenu(target,items)
    if not target or not target:IsA("GuiButton") then return false end
    return Tk(target.MouseButton2Click:Connect(function() API:ContextMenu(target,items) end))
end
API.ContextMenuManager.Attach=function(_,target,items) return API:AttachContextMenu(target,items) end

-- ---------- Search manager ----------
function API:Search(query,cfg)
    query=sl(ts(query or "")); cfg=cfg or {}
    local results={}
    if query=="" then return results end
    for name,b in pairs(ST.Buttons) do
        local meta=ST.Framework.TabMeta[name] or {}
        local hay=sl(name.." "..ts(meta.Description or ""))
        if hay:find(query,1,true) then results[#results+1]={Type="Tab",Id=name,Name=name,Description=meta.Description or ""} end
    end
    for id,e in pairs(ST.Elements) do
        local label=e and e._Label and e._Label.Text or e and e.Name or id
        local hay=sl(ts(id).." "..ts(label or "").." "..ts(e and e.Description or ""))
        if hay:find(query,1,true) then results[#results+1]={Type="Element",Id=id,Name=label or id,Element=e} end
    end
    if cfg.SelectFirst and results[1] and results[1].Type=="Tab" then SetTab(results[1].Id) end
    return results
end
function API:SetGlobalSearch(v) ST.Window.GlobalSearch=v==true; return true end
function API:SetSearchPlaceholder(v) if UI.SBox then UI.SBox.PlaceholderText=ts(v or "Search") end return true end
API.SearchManager={Find=function(_,q,cfg) return API:Search(q,cfg) end,SetGlobal=function(_,v) return API:SetGlobalSearch(v) end}

-- ---------- Animation manager ----------
API.AnimationManager={}
function API.AnimationManager:Tween(obj,props,duration,style,direction,key)
    return FT.T(obj,props,duration,style,direction,key)
end
function API.AnimationManager:Fade(obj,show,duration,key)
    if not obj then return false end
    local to=show and 0 or 1
    local props={BackgroundTransparency=to}
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then props.TextTransparency=to end
    return FT.T(obj,props,duration or .2,nil,nil,key or "Fade")
end
function API.AnimationManager:Slide(obj,offset,duration,direction,key)
    if not obj then return false end
    direction=sl(ts(direction or "bottom")); local p=obj.Position
    local o=tn(offset) or 20
    local start
    if direction=="left" then start=U2(p.X.Scale,p.X.Offset-o,p.Y.Scale,p.Y.Offset)
    elseif direction=="right" then start=U2(p.X.Scale,p.X.Offset+o,p.Y.Scale,p.Y.Offset)
    elseif direction=="top" then start=U2(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset-o)
    else start=U2(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset+o) end
    obj.Position=start
    return FT.T(obj,{Position=p},duration or .2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,key or "Slide")
end
function API.AnimationManager:Scale(obj,value,duration,key)
    if not obj then return false end
    local sc=obj:FindFirstChild("LuaLibraryScale")
    if not sc then sc=I("UIScale"); sc.Name="LuaLibraryScale"; sc.Scale=1; sc.Parent=obj end
    return FT.T(sc,{Scale=tn(value) or 1},duration or .2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,key or "Scale")
end
function API.AnimationManager:Spring(obj,props,duration,key)
    return FT.T(obj,props,duration or .32,Enum.EasingStyle.Back,Enum.EasingDirection.Out,key or "Spring")
end
function API.AnimationManager:Cancel(obj,key)
    return FT.Cancel(obj,key)
end
function API.AnimationManager:Clear(obj)
    return FT.ClearTweens(obj)
end
function API:SetReducedMotion(v)
    local enabled=v==true
    local acc=ST.Framework.Accessibility
    if enabled and not acc.ReducedMotion then
        acc.AnimationSnapshot={}
        for k,val in pairs(ST.Window.Animations) do acc.AnimationSnapshot[k]=val end
        for k in pairs(ST.Window.Animations) do ST.Window.Animations[k]=false end
    elseif not enabled and acc.ReducedMotion then
        for k in pairs(ST.Window.Animations) do
            local saved=acc.AnimationSnapshot and acc.AnimationSnapshot[k]
            ST.Window.Animations[k]=saved==nil and true or saved
        end
        acc.AnimationSnapshot=nil
    end
    acc.ReducedMotion=enabled
    return true
end
function API:GetReducedMotion() return ST.Framework.Accessibility.ReducedMotion==true end

-- ---------- Responsive / DPI / safe area ----------
function API:GetViewport()
    return GetVP()
end
function API:IsMobile() return ST.CurrentMode=="Mobile" end
function API:IsTablet() return ST.CurrentMode=="Tablet" end
function API:IsDesktop() return ST.CurrentMode=="Desktop" end
function API:SetDPIScale(v) return self:SetScale(v) end
function API:GetDPIScale() return self:GetScale() end
function API:GetSafeArea()
    local topLeft,bottomRight=V2(0,0),V2(0,0)
    pcall(function() topLeft,bottomRight=S.G:GetGuiInset() end)
    return {TopLeft=topLeft,BottomRight=bottomRight}
end
function API:OnViewportChanged(fn)
    if type(fn)~="function" or not workspace.CurrentCamera then return nil end
    local c=Tk(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() SafeCall("ViewportChanged",fn,GetVP(),ST.CurrentMode) end))
    local index=#ST.Framework.ViewportSignals+1
    ST.Framework.ViewportSignals[index]=c
    return {Disconnect=function()
        pcall(function() c:Disconnect() end)
        if ST.Framework.ViewportSignals[index]==c then ST.Framework.ViewportSignals[index]=nil end
    end}
end
function API:SetResponsiveMode(mode)
    mode=ts(mode or "Auto")
    if mode~="Auto" and mode~="Mobile" and mode~="Tablet" and mode~="Desktop" then return false,"modo responsivo inválido" end
    ST.Framework.ForcedMode=mode=="Auto" and nil or mode
    UpdateResp()
    return true
end

-- ---------- Drag / resize public manager ----------
API.DragManager={}
function API.DragManager:SetSnapping(enabled,distance,margin,avoidCoreGui) return API:SetSnapping(enabled,distance,margin,avoidCoreGui) end
function API.DragManager:SetResizable(enabled) return API:SetResizable(enabled) end
function API.DragManager:GetState() return {Dragging=ST.Dragging,Resizing=ST.Resizing,UserMoved=ST.UserMoved} end

-- ---------- Cursor system ----------
function API:SetCustomCursor(enabled,cfg)
    cfg=cfg or {}
    if not enabled then
        ST.Framework.CursorEnabled=false
        if ST.Framework.CursorConn then pcall(function() ST.Framework.CursorConn:Disconnect() end); ST.Framework.CursorConn=nil end
        if ST.Framework.Cursor and ST.Framework.Cursor.Parent then ST.Framework.Cursor:Destroy() end
        ST.Framework.Cursor=nil
        pcall(function() S.U.MouseIconEnabled=true end)
        return true
    end
    if not UI.OGui then return false end
    local f=ST.Framework.Cursor
    if not f or not f.Parent or (cfg.Image and not f:IsA("ImageLabel")) or (not cfg.Image and not f:IsA("TextLabel")) then
        if f and f.Parent then f:Destroy() end
        if cfg.Image then
            f=I("ImageLabel"); f.BackgroundTransparency=1; f.Image=ts(cfg.Image)
        else
            f=I("TextLabel"); f.BackgroundTransparency=1; f.Text=cfg.Symbol or "➤"; f.Font=Enum.Font.GothamBlack; f.TextSize=20
        end
        f.Name="CustomCursor"; f.Size=U3(24,24); f.AnchorPoint=V2(.15,.15); f.ZIndex=1000; f.Parent=UI.OGui; ST.Framework.Cursor=f
        if f:IsA("TextLabel") then f.TextColor3=CFG.Purple; Reg(f,"TextColor3","Purple") else f.ImageColor3=CFG.Purple; Reg(f,"ImageColor3","Purple") end
    end
    if cfg.Image and f:IsA("ImageLabel") then f.Image=ts(cfg.Image) end
    if not cfg.Image and f:IsA("TextLabel") then f.Text=cfg.Symbol or "➤" end
    if cfg.Color and typeof(cfg.Color)=="Color3" then f.TextColor3=cfg.Color end
    if cfg.Size then f.TextSize=tn(cfg.Size) or f.TextSize end
    ST.Framework.CursorEnabled=true
    pcall(function() S.U.MouseIconEnabled=false end)
    if ST.Framework.CursorConn then pcall(function() ST.Framework.CursorConn:Disconnect() end) end
    ST.Framework.CursorConn=Tk(S.U.InputChanged:Connect(function(inp)
        if ST.Framework.CursorEnabled and f.Parent and inp.UserInputType==Enum.UserInputType.MouseMovement then
            f.Position=U2(0,inp.Position.X,0,inp.Position.Y)
        end
    end))
    return true
end
function API:GetCustomCursor() return ST.Framework.Cursor end
API.CursorManager={Set=function(_,v,cfg) return API:SetCustomCursor(v,cfg) end,Get=function(_) return API:GetCustomCursor() end}

-- ---------- Loading / modal / overlay ----------
function API:CreateLoading(cfg) return self:ShowLoading(cfg) end
function API:HideLoading()
    if ST.Loading then ST.Loading:Destroy() end
    return true
end
function API:CreateModal(cfg) return NewDialog(cfg) end
function API:CreateOverlay(cfg)
    cfg=cfg or {}
    local f=I("Frame"); f.Name=cfg.Name or "Overlay"; f.BackgroundColor3=cfg.Color or CFG.ModalOverlay; f.BackgroundTransparency=cfg.Transparency~=nil and cl(cfg.Transparency,0,1) or .5; f.Size=Uv(1,1); f.ZIndex=tn(cfg.ZIndex) or 600; f.Parent=UI.OGui
    if cfg.CornerRadius then FT.C(f,cfg.CornerRadius) end
    ST.Framework.Overlays[f.Name]=f
    local api={Frame=f,Destroy=function(self) ST.Framework.Overlays[f.Name]=nil; if f.Parent then f:Destroy() end end}
    return api
end
function API:DestroyOverlays()
    for k,v in pairs(ST.Framework.Overlays) do ST.Framework.Overlays[k]=nil; if v and v.Parent then v:Destroy() end end
    return true
end
API.OverlayManager={Create=function(_,cfg) return API:CreateOverlay(cfg) end,DestroyAll=function(_) return API:DestroyOverlays() end}

-- ---------- Dropdown engine helpers ----------
function API:PositionPopup(popup,target,padding)
    if not popup or not target then return false end
    local vp=GetVP(); local pos=target.AbsolutePosition; local size=target.AbsoluteSize; local psize=popup.AbsoluteSize; local pad=tn(padding) or 6
    local x=cl(pos.X,pad,ma(pad,vp.X-psize.X-pad)); local y=pos.Y+size.Y+4
    if y+psize.Y>vp.Y-pad then y=pos.Y-psize.Y-4 end
    y=cl(y,pad,ma(pad,vp.Y-psize.Y-pad))
    popup.Position=U2(0,x,0,y)
    return true
end
API.DropdownManager={Position=function(_,popup,target,pad) return API:PositionPopup(popup,target,pad) end}

-- ---------- Color picker helpers ----------
function API:ColorToHex(color)
    if typeof(color)~="Color3" then return nil end
    return string.format("#%02X%02X%02X",ro(color.R*255),ro(color.G*255),ro(color.B*255))
end
function API:HexToColor(hex)
    local ok,c=pcall(c3hex,ts(hex or "#FFFFFF")); if ok then return c end return nil
end
function API:ColorToRGB(color)
    if typeof(color)~="Color3" then return nil end
    return {R=ro(color.R*255),G=ro(color.G*255),B=ro(color.B*255)}
end
API.ColorPickerManager={ToHex=function(_,c) return API:ColorToHex(c) end,FromHex=function(_,h) return API:HexToColor(h) end,ToRGB=function(_,c) return API:ColorToRGB(c) end}

-- ---------- Accessibility ----------
function API:SetTextScale(v)
    v=cl(tn(v) or 1,.75,1.5)
    ST.Framework.Accessibility.TextScale=v
    for _,d in ipairs(UI.Main:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            local base=d:GetAttribute("LuaBaseTextSize")
            if base==nil then base=d.TextSize; d:SetAttribute("LuaBaseTextSize",base) end
            d.TextSize=base*v
        end
    end
    return true
end
function API:GetTextScale() return ST.Framework.Accessibility.TextScale or 1 end
function API:SetLargeText(v) return self:SetTextScale(v and 1.15 or 1) end
function API:SetGamepadNavigation(v)
    ST.Framework.GamepadNavigation=v==true
    if UI.Main then UI.Main.Selectable=ST.Framework.GamepadNavigation end
    if ST.Framework.GamepadNavigation then
        for _,b in pairs(ST.Buttons) do if b and b:IsA("GuiButton") then b.Selectable=true end end
    end
    return true
end
function API:IsGamepadNavigationEnabled() return ST.Framework.GamepadNavigation==true end

-- ---------- Performance / debug ----------
function API:GetMetrics()
    local p=self:GetPerformance()
    p.ThemeRegistry=0
    for _ in pairs(ST.Themed) do p.ThemeRegistry=p.ThemeRegistry+1 end
    p.Elements=#ST.ElementOrder
    p.Pages=0; for _ in pairs(ST.Pages) do p.Pages=p.Pages+1 end
    p.Plugins=0; for _ in pairs(ST.Plugins) do p.Plugins=p.Plugins+1 end
    p.ManagedInstances=0; for _ in pairs(ST.Framework.ManagedInstances) do p.ManagedInstances=p.ManagedInstances+1 end
    return p
end
function API:DebugLog(tag,...)
    if not CFG.Debug then return end
    warn("[LuaInterface]["..ts(tag or "Debug").."]",...)
end
function API:PrintDiagnostics()
    local m=self:GetMetrics(); warn("[LuaInterface]",S.H:JSONEncode(m)); return m
end
API.PerformanceManager={Get=function(_) return API:GetMetrics() end,Diagnostics=function(_) return API:PrintDiagnostics() end}

-- ---------- Watermark / monitor ----------
function API:CreatePerformanceWatermark(cfg)
    cfg=cfg or {}; cfg.AutoUpdate=true; cfg.Text=cfg.Text or ""
    local w=self:CreateWatermark(cfg)
    if not w then return nil end
    if cfg.AutoUpdate~=false then
        w._MonitorAlive=true
        w._MonitorTask=task.spawn(function()
            while w._MonitorAlive and w.Frame and w.Frame.Parent do
                task.wait(tn(cfg.Interval) or 1)
                if not w._MonitorAlive then break end
                local p=self:GetPerformance()
                local t=os.date("%H:%M:%S")
                local base=cfg.Prefix or (CFG.Name.." | ")
                w.Frame.Text=base.."FPS: "..ts(p.FPS).." | Ping: "..ts(p.Ping).."ms | "..t
            end
        end)
        TrackTask(w._MonitorTask)
        local oldDestroy=w.Destroy
        w.Destroy=function(self) self._MonitorAlive=false; if oldDestroy then oldDestroy(self) end end
    end
    return w
end
API.WatermarkManager={Create=function(_,cfg) return API:CreateWatermark(cfg) end,CreatePerformance=function(_,cfg) return API:CreatePerformanceWatermark(cfg) end}

-- ---------- Localization manager ----------
API.Localization={SetLanguage=function(_,lang) return API:SetLanguage(lang) end,Register=function(_,lang,data) return API:RegisterLocale(lang,data) end,Translate=function(_,key,fallback) return API:Translate(key,fallback) end}

-- ---------- Plugin manager ----------
API.PluginManager={Register=function(_,name,plugin) return API:RegisterPlugin(name,plugin) end,Unregister=function(_,name) return API:UnregisterPlugin(name) end,Get=function(_,name) return ST.Plugins[ts(name or "")] end}

-- ---------- Settings system ----------
function API:ConfigureSettings(cfg)
    cfg=cfg or {}
    if cfg.Theme then self:SetTheme(cfg.Theme) end
    if cfg.Scale then self:SetScale(cfg.Scale) end
    if cfg.DPIScale then self:SetDPIScale(cfg.DPIScale) end
    if cfg.Language then self:SetLanguage(cfg.Language) end
    if cfg.ReducedMotion~=nil then self:SetReducedMotion(cfg.ReducedMotion) end
    if cfg.TextScale then self:SetTextScale(cfg.TextScale) end
    if cfg.GamepadNavigation~=nil then self:SetGamepadNavigation(cfg.GamepadNavigation) end
    if cfg.CustomCursor~=nil then self:SetCustomCursor(cfg.CustomCursor,cfg.Cursor) end
    if cfg.MaxNotifications then self:SetNotificationLimit(cfg.MaxNotifications) end
    return true
end
function API:GetSettings()
    return {
        Theme=ST.CurrentTheme,Scale=ST.Scale,Language=ST.Language,ReducedMotion=ST.Framework.Accessibility.ReducedMotion,
        TextScale=ST.Framework.Accessibility.TextScale,GamepadNavigation=ST.Framework.GamepadNavigation,
        MaxNotifications=CFG.MaxNotify,GlobalSearch=ST.Window.GlobalSearch,AlwaysOnTop=ST.Window.AlwaysOnTop
    }
end
API.SettingsManager={Apply=function(_,cfg) return API:ConfigureSettings(cfg) end,Get=function(_) return API:GetSettings() end}
function API:CreateSettingsTab(name)
    name=ts(name or "Settings")
    local tab=self:GetTab(name) or self:AddTab(name,{Description="Library settings",Icon="settings"})
    if not tab then return nil end
    if tab._FrameworkBuilt then return tab end
    tab._FrameworkBuilt=true
    local general=tab:AddLeftGroupbox({Name="Interface",Description="Theme, scale and accessibility"})
    local themes=self:GetThemes()
    general:AddDropdown("__LI_Theme",{Name="Theme",Values=themes,Default=ST.CurrentTheme,Searchable=true,Callback=function(v) if type(v)=="string" and Themes[v] then self:SetTheme(v) end end,Index="__LI_Theme"})
    general:AddSlider("__LI_Scale",{Name="Scale",Default=ST.Scale or 1,Min=.75,Max=1.35,Rounding=2,Prefix="x",Callback=function(v) self:SetScale(v) end,Index="__LI_Scale"})
    general:AddToggle("__LI_ReducedMotion",{Name="Reduced motion",Default=ST.Framework.Accessibility.ReducedMotion,Callback=function(v) self:SetReducedMotion(v) end,Index="__LI_ReducedMotion"})
    general:AddToggle("__LI_Gamepad",{Name="Gamepad navigation",Default=ST.Framework.GamepadNavigation,Callback=function(v) self:SetGamepadNavigation(v) end,Index="__LI_Gamepad"})
    local runtime=tab:AddRightGroupbox({Name="Runtime",Description="Search, notifications and recovery"})
    runtime:AddToggle("__LI_GlobalSearch",{Name="Global search",Default=ST.Window.GlobalSearch,Callback=function(v) self:SetGlobalSearch(v) end,Index="__LI_GlobalSearch"})
    runtime:AddToggle("__LI_AlwaysOnTop",{Name="Always on top",Default=ST.Window.AlwaysOnTop,Callback=function(v) self:SetAlwaysOnTop(v) end,Index="__LI_AlwaysOnTop"})
    runtime:AddSlider("__LI_MaxNotify",{Name="Max notifications",Default=CFG.MaxNotify,Min=1,Max=12,Rounding=0,Callback=function(v) self:SetNotificationLimit(v) end,Index="__LI_MaxNotify"})
    runtime:AddButton({Text="Clear notifications",Func=function() self:ClearNotifications() end})
    runtime:AddButton({Text="Print diagnostics",Func=function() self:PrintDiagnostics() end})
    runtime:AddButton({Text="Reset element defaults",Func=function() SM:ResetDefaults() end})
    return tab
end
API.SettingsManager.CreateTab=function(_,name) return API:CreateSettingsTab(name) end

-- ---------- Window proxy methods ----------
function ST.Window:Toggle() return API:Toggle() end
function ST.Window:Open() return API:Open() end
function ST.Window:Close() return API:Close() end
function ST.Window:Minimize() return API:Minimize() end
function ST.Window:Fullscreen() return API:Fullscreen() end
function ST.Window:AddTab(name,cfg) return API:AddTab(name,cfg) end
function ST.Window:SelectTab(name) return API:SelectTab(name) end
function ST.Window:GetTabs() return API:GetTabs() end
function ST.Window:SetSize(w,h) return API:SetSize(w,h) end
function ST.Window:SetPosition(v) return API:SetPosition(v) end
function ST.Window:SetTheme(v) return API:SetTheme(v) end
function ST.Window:Destroy() return API:Destroy() end

-- ---------- compatibility aliases ----------
API.Unload=API.Destroy
API.DestroyLibrary=API.Destroy
API.Library=API
API.Core=API
API.ElementsRegistry=ST.Elements
API.ConnectionRegistry=ST.Conns
API.ThemeRegistry=ST.Themed
API.AnimationRegistry=ST.ActiveTweens
API.StateManager={Get=function(_) return API:GetState() end,Create=function(_,v) return API:CreateState(v) end}
API.Cleanup={GiveSignal=function(_,c) return API:GiveSignal(c) end,GiveTask=function(_,t) return API:GiveTask(t) end,GiveInstance=function(_,i) return API:GiveInstance(i) end,CreateMaid=function(_) return API:CreateMaid() end}
API.ErrorHandler={Capture=function(_,src,fn,...) return SafeCall(src,fn,...) end,GetErrors=function(_) return API:GetErrors() end,Clear=function(_) return API:ClearErrors() end,SetMode=function(_,m) return API:SetErrorMode(m) end}
API.ResponsiveManager={GetMode=function(_) return API:GetMode() end,SetScale=function(_,v) return API:SetScale(v) end,GetScale=function(_) return API:GetScale() end,Viewport=function(_) return API:GetViewport() end,SafeArea=function(_) return API:GetSafeArea() end}
ST.Framework.TabSwipeEnabled=true
ST.Framework.TabSwipeStart=nil
ST.Framework.TabSwipeInput=nil
function API:SetTabSwipe(v) ST.Framework.TabSwipeEnabled=v~=false; return true end
ST.Framework.TabSwipeConn=Tk(UI.PageC.InputBegan:Connect(function(inp)
    if not ST.Framework.TabSwipeEnabled or inp.UserInputType~=Enum.UserInputType.Touch then return end
    ST.Framework.TabSwipeInput=inp; ST.Framework.TabSwipeStart=V2(inp.Position.X,inp.Position.Y)
end))
ST.Framework.TabSwipeEndConn=Tk(S.U.InputEnded:Connect(function(inp)
    if not ST.Framework.TabSwipeEnabled or inp~=ST.Framework.TabSwipeInput or not ST.Framework.TabSwipeStart then return end
    local s=ST.Framework.TabSwipeStart; local dx=inp.Position.X-s.X; local dy=inp.Position.Y-s.Y
    ST.Framework.TabSwipeInput=nil; ST.Framework.TabSwipeStart=nil
    if math.abs(dx)<48 or math.abs(dx)<math.abs(dy)*1.25 then return end
    local tabs=API:GetTabs(); local idx=0
    for i=1,#tabs do if tabs[i].Name==ST.CurrentPage then idx=i break end end
    if idx==0 then return end
    if dx<0 and tabs[idx+1] then API:SelectTab(tabs[idx+1].Name) elseif dx>0 and tabs[idx-1] then API:SelectTab(tabs[idx-1].Name) end
end))
API.DialogManager={Open=function(_,cfg) return NewDialog(cfg) end,Confirm=function(_,cfg) return Confirm(cfg) end,Choice=function(_,cfg) return Choice(cfg) end}
API.LoadingManager={Show=function(_,cfg) return API:ShowLoading(cfg) end,Hide=function(_) return API:HideLoading() end}

-- Make the framework managers discoverable from the public Library object.
API.Framework={
    Core=API,
    Window=ST.Window,
    Theme=API.ThemeManager,
    Config=SM,
    Input=API.InputManager,
    Animation=API.AnimationManager,
    Notification=API.NotificationManager,
    Tooltip=API.TooltipManager,
    Search=API.SearchManager,
    Responsive=API.ResponsiveManager,
    Dependency={Bind=function(_,e,d,m) return API:BindDependency(e,d,m) end,DependsOn=function(_,e,s,v,m) return API:DependsOn(e,s,v,m) end,VisibleWhen=function(_,e,f) return API:VisibleWhen(e,f) end,DisabledWhen=function(_,e,f) return API:DisabledWhen(e,f) end},
    Dialog=API.DialogManager,
    Overlay=API.OverlayManager,
    Dropdown=API.DropdownManager,
    ColorPicker=API.ColorPickerManager,
    Keybind=API.KeybindManager,
    Cursor=API.CursorManager,
    Loading=API.LoadingManager,
    Localization=API.Localization,
    Plugin=API.PluginManager,
    Performance=API.PerformanceManager,
    Watermark=API.WatermarkManager,
    Settings=API.SettingsManager,
    Cleanup=API.Cleanup,
    Error=API.ErrorHandler,
    State=API.StateManager,
    Registry=API,
    Icons=API.IconManager,
}

-- ---------- safer Destroy wrapper for framework-owned tasks/objects ----------
ST._FrameworkOriginalDestroy=ST._FrameworkOriginalDestroy or API.Destroy
ST._FrameworkOriginalDestroy=ST._FrameworkOriginalDestroy
API.Destroy=function(self)
    if ST.Destroyed or ST.State=="Destroying" then return false end
    for i=#ST.Framework.UnloadCallbacks,1,-1 do
        local fn=ST.Framework.UnloadCallbacks[i]
        ST.Framework.UnloadCallbacks[i]=nil
        SafeCall("OnUnload",fn,self)
    end
    for k,v in pairs(ST.Framework.Modules) do
        if type(v)=="table" and type(v.Destroy)=="function" then SafeCall("ModuleDestroy:"..k,v.Destroy) end
    end
    for k,v in pairs(ST.Plugins or {}) do
        if type(v)=="table" and type(v.Destroy)=="function" then SafeCall("PluginDestroy:"..k,v.Destroy) end
    end
    ST.Framework.Modules={}
    ST.Framework.Plugins={}
    ST.Framework.Input.Blocked=false
    ST.Framework.Input.Began={}; ST.Framework.Input.Ended={}; ST.Framework.Input.Changed={}; ST.Framework.Input.Captures={}
    if ST.Framework.CursorConn then pcall(function() ST.Framework.CursorConn:Disconnect() end); ST.Framework.CursorConn=nil end
    if ST.Framework.Cursor and ST.Framework.Cursor.Parent then ST.Framework.Cursor:Destroy() end
    ST.Framework.Cursor=nil
    for k,v in pairs(ST.Framework.Overlays) do ST.Framework.Overlays[k]=nil; if v and v.Parent then v:Destroy() end end
    for obj in pairs(ST.Framework.ManagedInstances) do if obj and obj.Parent then pcall(function() obj:Destroy() end) end ST.Framework.ManagedInstances[obj]=nil end
    for k,v in pairs(ST.Framework.Rules) do ST.Framework.Rules[k]=nil end
    if ST.Framework.AutoSaveTask then pcall(function() task.cancel(ST.Framework.AutoSaveTask) end); ST.Framework.AutoSaveTask=nil end
    if SM.StopAutoSave then pcall(function() SM:StopAutoSave() end) end
    return ST._FrameworkOriginalDestroy(self)
end

API.Version=CFG.Version
API.Window=ST.Window
API.SaveManager=SM
API.Library=API
API.Unload=API.Destroy
API.UnloadLibrary=API.Destroy

return API
end)()
