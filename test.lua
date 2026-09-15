local GameplayStatics=import("GameplayStatics")
local GameplayData=require("GameLua.GameCore.Data.GameplayData")

-- [SỬA LỖI LOGIC] Đưa khai báo các hàm trống lên đầu cùng để Bypass hoạt động
function nop() return true end
function retFalse() return false end
function retZero() return 0 end
function retEmpty() return {} end
function retTrue() return true end

local function InitializeSkinProtect()
    pcall(function()
        local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if ptlog then ptlog.ReportEvent = nop; ptlog.ReportDownloadResult = nop end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("FileCheckSubsystem")
        if sub then sub.StartCheck = nop; sub.ReportAbnormalFile = nop end
    end)
end

local function InitializeLogBlocker()
    pcall(function()
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Report = nop; TLog.Flush = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local origData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (data:find("report", 1, true) or data:find("exception", 1, true) or data:find("cheat", 1, true) or data:find("violation", 1, true)) then return end
                if origData then origData(data) end
            end
            TssSdk.SendReportInfo = nop
            TssSdk.ScanMemory = retTrue
        end
    end)
end

local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logRep then logRep.ReportReplay = nop; logRep.SendReportReq = nop end
    end)
end

local function InitializeReportFlowBlocker()
    pcall(function()
        if _G.GameplayCallbacks then
            local GC = _G.GameplayCallbacks
            local reports = {"ReportAttackFlow", "ReportHitFlow", "ReportAimFlow", "ReportPlayerBehavior", "ReportEquipmentFlow", "SendClientStats", "ReportCircleFlow"}
            for _, f in ipairs(reports) do GC[f] = nop end
        end
    end)
end

local function InitializeHiggsBosonProtect()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty
            Higgs.GetCurWeaponSkinID = retZero
            Higgs.bMHActive = false
            Higgs.bCallPreReplication = false
        end
        _G.BlackList = {}
    end)
end

local function InitializeAntiReport()
    pcall(function()
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem"]
        if sub then
            for k, v in pairs(sub) do
                if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Record")) then sub[k] = nop end
            end
        end
    end)
end

local function InitializeGameplayProtect()
    pcall(function()
        if not _G.GameplayCallbacks then return end
        if _G.GameplayCallbacks.IsProtected then return end
        local GC = _G.GameplayCallbacks
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, ...)
            local s = State and string.lower(tostring(State)) or ""
            -- Chỉ chặn trạng thái xử lý gian lận/ban, TUYỆT ĐỐI KHÔNG đụng mạng (connectionlost/timeout)
            local blocked = {["cheatdetected"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, ...) end
        end
        GC.IsProtected = true
    end)
end

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"ClientReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "GameReportSubsystem", "AntiCheatSubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do
                    if type(v) == "function" then sub[k] = nop end
                end
            end
        end
    end)
end

_G.StartProtect_VIP_v3 = function()
    pcall(function()       
        InitializeSkinProtect()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializeHiggsBosonProtect()
        InitializeAntiReport()
        InitializeGameplayProtect()
        InitializeKillAllSubsystems()
    end)
end


_pcall         = pcall
_type          = type
_tostring      = tostring
_tonumber      = tonumber
_pairs         = pairs
_ipairs        = ipairs
_os_clock      = os.clock
_math_floor    = math.floor
_math_sqrt     = math.sqrt
_math_abs      = math.abs
_math_max      = math.max
_math_cos      = math.cos
_math_sin      = math.sin
_math_rad      = math.rad
_math_deg      = math.deg
_math_atan2    = math.atan2 or math.atan
_math_pi       = math.pi
_string_format = string.format
_string_find   = string.find
_string_lower  = string.lower
_string_upper  = string.upper
_string_sub    = string.sub
_table_insert  = table.insert
_table_remove  = table.remove
ESlateVis_HitTestInv = 1
ESlateVis_Collapsed  = 2 
_slua = rawget(_G, "slua")
_slua_isValid = _slua and _slua.isValid or function(o) return o ~= nil end
function Valid(obj) 
    if not obj then return false end 
    if _slua and _slua.isValid then 
        local ok, v = _pcall(_slua.isValid, obj) 
        if not ok or not v then return false end 
    end 
    return true 
end
function Notify(msg) 
    local s = "[TDx08 VIP New] " .. _tostring(msg)
    _pcall(function() if _G.LexusNotify then _G.LexusNotify(s) end end)
    _pcall(function() 
        local sh = import("ScriptHelperClient") 
        if sh and sh.AddOnScreenDebugMessage then 
            sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1, G=1, B=0, A=1}, {X=1.2, Y=1.2}) 
        end 
    end) 
    print(s) 
end

C_GREEN = {R=0, G=255, B=0, A=255}
C_RED = {R=255, G=0, B=0, A=255}
C_CYAN = {R=0, G=255, B=255, A=255}
C_YELLOW = {R=255, G=255, B=0, A=255}
C_WHITE = {R=255, G=255, B=255, A=255}
C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}
ZERO_VECTOR3 = {X=0, Y=0, Z=0}
local F_ZERO_VECTOR = nil 
_pcall(function() F_ZERO_VECTOR = FVector(0,0,0) end)
local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}
local GLOBAL_CONNECTIONS = {
    {"neck_01", "pelvis", C_YELLOW},
    {"neck_01", "upperarm_l", C_CYAN}, {"upperarm_l", "lowerarm_l", C_CYAN}, {"lowerarm_l", "hand_l", C_CYAN},
    {"neck_01", "upperarm_r", C_CYAN}, {"upperarm_r", "lowerarm_r", C_CYAN}, {"lowerarm_r", "hand_r", C_CYAN},
    {"pelvis", "thigh_l", C_CYAN}, {"thigh_l", "calf_l", C_CYAN}, {"calf_l", "foot_l", C_CYAN},
    {"pelvis", "thigh_r", C_CYAN}, {"thigh_r", "calf_r", C_CYAN}, {"calf_r", "foot_r", C_CYAN}
}
CONFIG_VERSION = 1.8

DEFAULT_TOGGLES = {    
    WallXuyenTuong = false, 
    ColorBodyV2 = false,    
    ColorBodyV3 = false,  
    WallVehicle = false,
    WhiteBody = false, 
    BlackSky = false, 
    RemoveGrass = false, 
    RemoveFog = false,     
    AimbotV1 = false,
    AimTouchEnable = false,
    AimTouchHipfire = false,
    AimTouchSG = false,
    AimTouchScopeAll = false,
    AimTouchScoESPniper = false,    
    EspTenText = false,        
    EspKhoangCachText = false, 
    EspMauDocText = false,     
    EspXuong = false,          
    EspChiTiet = false,        
    EspSoLuong = true,         
    EspVuKhi = true,           
    EspTuThe = true,           
    EspAntenna = false,        
    EspVien = false,           
    EspKhungMau = false,       
    EspMauTrenDau = false,     
    EspThongTinGoc = false,  
    EspItem_Master = false, 
    EspItem_AR = true,      
    EspItem_Sniper = true,  
    EspItem_SMG = true,     
    EspItem_Shotgun = true, 
    EspItem_LMG = true,       
    EspItem_Pistol = true,    
    EspItem_Special = true,   
    EspItem_Scope = true,   
    EspItem_Grenade = true,   
    EspItemBom = false,   
    EspActiveBom = false, 
    EspBomMaster = false, 
    EspVehicle = false,   
    EspVeh_Dacia = true,  
    EspVeh_UAZ = true,    
    EspVeh_Buggy = true,  
    EspVeh_Coupe = true,  
    EspVeh_Mirado = true, 
    EspVeh_Motor = true,  
    EspVeh_Other = true,  
    UnlockFPS = false, 
    IpadView = false, 
    CustomMagicBullet = false,
    WeaponGlow = false,
    BugManEnable = false,
    CustomBrightnessEnable = false,
    FakeHWID = true,
    ModSkin = false,           
    SkinDeadBox = false,   
    SkinAttachment = false, 
    SkinOptionOpen = false,
    SkinOpenLink = false,  
    KillMessage = false,    
    KillCountUI = false,    
    ModEmote = false,
    SkinMenu_AR = false,
    SkinMenu_SMG = false,
    SkinMenu_Sniper = false,
    SkinMenu_SG = false,
    SkinMenu_Vehicle = false,
    LangEnglish = false,
    EspThongTinLoai2 = false,
    LangEnglish = false,
    EspThongTinLoai2 = false,
    AimTouchCrossbow = false,
    AimTouchBow = false,
    EspItem_Melee = true,
    DanThang = false,
    CanhBaoDichNhin = false,
    EspItem_Helmet = true,
    EspItem_Bag = true,
    IpadViewVehicle = false,
    EspItem_Coin = true,   -- ESP Xu Cửa Hàng
    EspItem_Heal = true,   -- ESP Máu, Nước
    EspItem_Attach = true,     -- ESP Băng đạn
    IpadViewVehicle = false,
    EspLoai9 = false,               -- [THÊM VÀO ĐÂY] Nút Bật/Tắt Tổng ESP Kẻ Chỉ
    EspLoai9_Line = false,          -- [THÊM VÀO ĐÂY] Nút Bật/Tắt Line
    EspLoai9_Line_VisCheck = false,
    EspFovCircle = false,
    EspItem_FlareGun = true, -- [THÊM VÀO ĐÂY] Nút Bật/Tắt Check Tường Line
}

DEFAULT_VALUES = {  
    OutlineThickness = 1,
    EspLoai9_Line_Vis_Color = 2, -- [THÊM VÀO ĐÂY] Màu mặc định Line (Lộ)
    EspLoai9_Line_Hid_Color = 1,
    iPadViewVehicleFOV = 0,
    EspFovCircle_Color = 7,
    FastCarSpeed = 150,
    OutlineColor = 4,
    ThuTam = 0, 
    GiamGiatNgang = 0, 
    GiamGiatDoc = 0, 
    GiamRungScope = 0, 
    MagicHead = 1.0, 
    MagicBody = 1.0, 
    MagicLegs = 1.0, 
    IpadViewFOV = 120,
    V3_Hidden_Color = 1, 
    V3_Visible_Color = 2, 
    V3_Glow = 1,    
    BugManRatio = 133, 
    WeaponGlowThickness = 1, 
    WeaponGlowColor = 5,
    CustomBrightnessValue = 10,  
    AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 30, AimTouchHipFOV = 15, AimTouchHipDist = 150,
    AimTouchSGPrio = 1, AimTouchSGBone = 1, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
    AimTouchScopePrio = 1, AimTouchScopeBone = 1, AimTouchScopeCond = 1, AimTouchScoESPpeed = 20, AimTouchScopeFOV = 10, AimTouchScopeDist = 250, AimTouchScopePred = 26, AimTouchScopeRecoil = 0,
    AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 55, AimTouchSniperFOV = 20, AimTouchSniperDist = 400, AimTouchSniperPred = 10,    
    AimTouchHipIgKnock = 1, AimTouchHipVisCheck = 0, AimTouchHipIgBot = 0,
    AimTouchSGIgKnock = 1, AimTouchSGVisCheck = 0, AimTouchSGIgBot = 0,
    AimTouchScopeIgKnock = 1, AimTouchScopeVisCheck = 0, AimTouchScopeIgBot = 0,
    AimTouchSniperIgKnock = 1, AimTouchSniperVisCheck = 0, AimTouchSniperIgBot = 0,
    AimTouchCrossbowPrio = 1, AimTouchCrossbowBone = 1, AimTouchCrossbowCond = 2, AimTouchCrossbowSpeed = 54, AimTouchCrossbowFOV = 19, AimTouchCrossbowDist = 150, 
    AimTouchCrossbowVel = 122,
    AimTouchCrossbowDrop = 27,
    AimTouchBowCond = 1,     -- Điều kiện Aim Cung
    AimTouchBowBone = 1,     -- Vị trí xương Cung
    AimTouchBowSpeed =60, 
    AimTouchBowFOV = 15,   
    AimTouchBowDist = 150,
    AimTouchCrossbowDropProne = 25,
    AimTouchCrossbowPred = 30, -- Đoán hướng Nỏ
    AimTouchBowPred = 18,      -- Đoán hướng Cung
    AimTouchBowRecoil = 1,    -- Bù giật Cung
    AimTouchBowDrop = 15,     -- Bù rơi Cung (Mặc định 50 vì nó cong nhẹ)
    AimTouchMortarPred = 0,
    AimTouchCrossbowIgKnock = 1, AimTouchCrossbowVisCheck = 0, AimTouchCrossbowIgBot = 0,
    AimTouchBowIgKnock = 1, AimTouchBowVisCheck = 0, AimTouchBowIgBot = 0,   
}    

_G.LexusConfig = _G.LexusConfig or {}
for k, v in pairs(DEFAULT_TOGGLES) do if _G.LexusConfig[k] == nil then _G.LexusConfig[k] = v end end
_G.LexusState = _G.LexusState or {}
_G.LexusState.CustomTextData = _G.LexusState.CustomTextData or {}
for k, v in pairs(DEFAULT_VALUES) do if _G.LexusState.CustomTextData[k] == nil then _G.LexusState.CustomTextData[k] = v end end
_G.LexusConfig.OutlineThickness = _G.LexusState.CustomTextData.OutlineThickness
_G.LexusState.LoopToken = 0
_G.LexusState.NativeESPReady = false
_G.LexusState.GraphicsUnlocked = false
_G.LexusState.MenuStep = 0
_G.LexusState.TrackedMarks = {}
_G.LexusState.EnemyMarks = {}
_G.LexusState.PrevGraphicsState = {}
local limitTime = os.time({ year = 2036, month = 8, day = 20, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
pcall(function()
    local tm = package.loaded["client.logic.common.TimeManager"]
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then currentTime = serverTime end
    end
end)
isExpired = (currentTime > limitTime)
local SaveFilePath = "Saved/Paks/TD_SETTING.json"
local FallbackPath = "TD_SETTING.json"
local function ForceWriteFile(content)
    local isSaved = false
    pcall(function()
        if Client and Client.SaveStringToFile then
            isSaved = Client.SaveStringToFile(SaveFilePath, content)
            if not isSaved then isSaved = Client.SaveStringToFile(FallbackPath, content) end
        end
    end)
    if not isSaved then
        local paths = {
            "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            (os.getenv("HOME") or "") .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "Documents/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "../../ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            FallbackPath
        }
        for _, p in ipairs(paths) do
            pcall(function()
                local f = io.open(p, "w")
                if f then f:write(content); f:close(); isSaved = true end
            end)
            if isSaved then break end
        end
    end
    return isSaved
end

local function ForceReadFile()
    local content = nil
    pcall(function()
        if Client and Client.LoadFileToString then
            content = Client.LoadFileToString(SaveFilePath)
            if not content or content == "" then content = Client.LoadFileToString(FallbackPath) end
        end
    end)
    if not content or content == "" then
        local paths = {
            "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            (os.getenv("HOME") or "") .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "Documents/ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "../../ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            "ShadowTrackerExtra/Saved/Paks/" .. FallbackPath,
            FallbackPath
        }
        for _, p in ipairs(paths) do
            pcall(function()
                local f = io.open(p, "r")
                if f then content = f:read("*a"); f:close() end
            end)
            if content and content ~= "" then break end
        end
    end
    return content
end

_G.SaveModSettings = function()
    pcall(function()
        local dataToSave = {
            LexusConfig = _G.LexusConfig or {},
            CustomTextData = _G.LexusState.CustomTextData or {}
        }
        local json_lib = json or require("json")
        local ok, jsonString = pcall(function() return json_lib.encode(dataToSave) end)
        if ok and jsonString then
            ForceWriteFile(jsonString)
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        _G.LexusConfig = _G.LexusConfig or {}
        _G.LexusState = _G.LexusState or {}
        _G.LexusState.CustomTextData = _G.LexusState.CustomTextData or {}
        for k, v in pairs(DEFAULT_TOGGLES) do _G.LexusConfig[k] = v end
        for k, v in pairs(DEFAULT_VALUES) do _G.LexusState.CustomTextData[k] = v end
        local content = ForceReadFile()
        if content and content ~= "" then
            local json_lib = json or require("json")
            local ok, parsedData = pcall(function() return json_lib.decode(content) end)
            
            if ok and type(parsedData) == "table" then
                if parsedData.LexusConfig then
                    for k, v in pairs(parsedData.LexusConfig) do
                        _G.LexusConfig[k] = v
                    end
                end
                if parsedData.CustomTextData then
                    for k, v in pairs(parsedData.CustomTextData) do
                        _G.LexusState.CustomTextData[k] = v
                    end
                end
            end
        end
        _G.EnvRequiresUpdate = true
        _G.LexusState.MagicUpdateVersion = (_G.LexusState.MagicUpdateVersion or 1) + 1
    end)
end

local function AutoSaveLoop()
    pcall(function() 
        if _G.NeedSaveConfig and _G.SaveModSettings then 
            _G.SaveModSettings() 
            _G.NeedSaveConfig = false 
        end 
    end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerLoop then 
            if not _G.AutoSaveLoopRunning then
                _G.AutoSaveLoopRunning = true
                ticker.AddTimerLoop(3.0, function()
                    if _G.NeedSaveConfig and _G.SaveModSettings then 
                        _G.SaveModSettings() 
                        _G.NeedSaveConfig = false 
                    end 
                end, -1, 3.0)
            end
        end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

_G.ReadLiveConfig = function()
    if _G.NeedSaveConfig then
        if _G.SaveModSettings then _G.SaveModSettings() end
        _G.NeedSaveConfig = false
    end
end

local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    _pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.LexusState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    _pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.LexusState.TrackedMarks[mark] = nil
end

local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return "PK_" .. _tostring(enemy.PlayerKey) end
        if _type(enemy.GetUniqueID) == "function" then return "UID_" .. _tostring(enemy:GetUniqueID()) end
    end
    return "DEAD_" .. _tostring(enemy)
end

local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end    
    local isAI = false
    local hasChecked = false
    _pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if _type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end        
        local pState = pawn.PlayerState or (_type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if _type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end        
        if not isAI then
            local name = pawn.PlayerName or (_type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (_string_find(name, "Cobra") or _string_find(name, "Target") or _string_find(name, "bot_") or _string_find(name, "b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

function _G.InitializeAutoHeadHooks()
    _pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end
        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }        
        for _, path in _ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.LexusConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end
                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.LexusConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

_G.ApplyWeaponGlow = function(PlayerCharacter)
    _pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end
        local isGlowEnabled = _G.LexusConfig.WeaponGlow
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local glowIntensity = 80.0 
        local thickness = _G.LexusState.CustomTextData.WeaponGlowThickness or 3
        local colorMode = _G.LexusState.CustomTextData.WeaponGlowColor or 5      
        local r, g, b = 1.0, 1.0, 0.0
        if colorMode == 1 then r, g, b = 1.0, 0.0, 0.0
        elseif colorMode == 2 then r, g, b = 0.0, 1.0, 0.0
        elseif colorMode == 3 then r, g, b = 0.0, 0.0, 1.0
        elseif colorMode == 4 then r, g, b = 1.0, 1.0, 0.0
        elseif colorMode == 5 then 
            local time = _os_clock() * 2.0
            r = (_math_sin(time) + 1) / 2
            g = (_math_sin(time + 2) + 1) / 2
            b = (_math_sin(time + 4) + 1) / 2
        end
        local finalColor = LinearColorClass and LinearColorClass(r * glowIntensity, g * glowIntensity, b * glowIntensity, 1.0) or { R = r * 255 * glowIntensity, G = g * 255 * glowIntensity, B = b * 255 * glowIntensity, A = 255 }
        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) then
                local ok, meshComponent = _pcall(function() return import("/Script/Engine.MeshComponent") end)
                if ok then
                    local ok2, components = _pcall(function() return Weapon:GetComponentsByClass(meshComponent) end)
                    if ok2 and components then
                        local count = _type(components.Num) == "function" and components:Num() or #components
                        for i = 1, count do
                            local comp = _type(components.Get) == "function" and components:Get(i-1) or components[i]
                            if slua.isValid(comp) then
                                if isGlowEnabled then
                                    _pcall(function()
                                        comp.UseScopeDistanceCulling = false
                                        comp.PrimitiveShadingStrategy = 1
                                        comp.ShadingRate = 6
                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(true)
                                            if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, finalColor) end
                                            if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, thickness) end
                                        elseif comp.SetRenderCustomDepth then
                                            comp:SetRenderCustomDepth(true)
                                        end
                                    end)
                                else
                                    _pcall(function()
                                        if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false)
                                        elseif comp.SetRenderCustomDepth then comp:SetRenderCustomDepth(false) end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    -- Hàm dịch tự động dựa trên công tắc ngôn ngữ
    local function T(vi, en)
        return _G.LexusConfig.LangEnglish and en or vi
    end

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    local FakeTextMap = {
        [999000] = "TDx08",
        [999001] = T("ESP & WALL", "ESP & WALL"),
        [999002] = T("SÚNG & AIM GỐC", "SETTING GUN"),
        [999003] = T("AIMBOT", "AIMBOT"),
        [999004] = T("MAGIC BULLET", "MAGIC BULLET"),
        [999006] = T("MOD SKIN", "MOD SKIN"),
        [999007] = T("CÁC CHỨC NĂNG KHÁC", "OTHER FEATURES")
    }
    
    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(id)
            if FakeTextMap[id] then return FakeTextMap[id] end
            if type(id) == "string" and not tonumber(id) then return id end
            return old_get(id)
        end
        LocUtil._IsModMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")

    local function SetB(key, v)
        local isTrue = (v == true or v == 1 or v == "1" or v == "true" or v == "ON")
        if _G.LexusConfig[key] ~= isTrue then
            _G.LexusConfig[key] = isTrue
            if _G.SaveModSettings then _G.SaveModSettings() end 
        end
        return true
    end

    local function GetB(key) return _G.LexusConfig[key] == true end
    local function SaveS() 
        if _G.SaveModSettings then _G.SaveModSettings() end 
        return true 
    end

    local function MergeStacks(...)
        local res = {}
        for _, stack in ipairs({...}) do
            for _, item in ipairs(stack) do table.insert(res, item) end
        end
        return res
    end    

    if not SettingPageDefine.ModMenu then
        local StackESP = {
            { Key = "ModMenu_EspText_Ex", UI = AliasMap.TitleSwitcher, Text = T("ESP THANH MÁU LOẠI 1 CUSTOM", "ESP HEALTH BAR V1 CUSTOM"), ExpandIndex = 0, GetFunc = function() return GetB("EspTenText") or GetB("EspKhoangCachText") or GetB("EspMauDocText") end, SetFunc = function(c,v) SetB("EspTenText", v); SetB("EspKhoangCachText", v); return SetB("EspMauDocText", v) end },
            { Key = "ModMenu_EspTen", UI = AliasMap.Switcher, Text = T("   HIỆN TÊN NGƯỜI CHƠI", "   SHOW PLAYER NAME"), ExpandHandle = "ModMenu_EspText_Ex", GetFunc = function() return GetB("EspTenText") end, SetFunc = function(c,v) return SetB("EspTenText", v) end },
            { Key = "ModMenu_EspKhoangCach", UI = AliasMap.Switcher, Text = T("   HIỆN KHOẢNG CÁCH MÉT", "   SHOW DISTANCE (METERS)"), ExpandHandle = "ModMenu_EspText_Ex", GetFunc = function() return GetB("EspKhoangCachText") end, SetFunc = function(c,v) return SetB("EspKhoangCachText", v) end },
            { Key = "ModMenu_EspMauDoc", UI = AliasMap.Switcher, Text = T("   HIỆN THANH MÁU", "   SHOW HEALTH BAR"), ExpandHandle = "ModMenu_EspText_Ex", GetFunc = function() return GetB("EspMauDocText") end, SetFunc = function(c,v) return SetB("EspMauDocText", v) end },            
            
            { Key = "ModMenu_ESP9_Ex", UI = AliasMap.TitleSwitcher, Text = T("ESP KẺ CHỈ", "ESP SNAPLINES"), ExpandIndex = 0, GetFunc = function() return GetB("EspLoai9") end, SetFunc = function(c,v) return SetB("EspLoai9", v) end },
            { Key = "ModMenu_ESP9_Line", UI = AliasMap.Switcher, Text = T("   KẺ CHỈ(MÁY YẾU KHÔNG NÊN)", "   SHOW SNAPLINES"), ExpandHandle = "ModMenu_ESP9_Ex", GetFunc = function() return GetB("EspLoai9_Line") end, SetFunc = function(c,v) local ret = SetB("EspLoai9_Line", v); if _G.PlayerMapMarker then _G.PlayerMapMarker.bUseSnapLines = v; if not v then _G.PlayerMapMarker.ClearAllSnapLines() end end return ret end },
            { Key = "ModMenu_ESP9_Line_VisCheck", UI = AliasMap.Switcher, Text = T("   PHÂN BIỆT MÀU LỘ/KHUẤT", "   VISIBILITY COLOR CHECK"), ExpandHandle = "ModMenu_ESP9_Ex", GetFunc = function() return GetB("EspLoai9_Line_VisCheck") end, SetFunc = function(c,v) return SetB("EspLoai9_Line_VisCheck", v) end },
            { Key = "ModMenu_ESP9_Line_VisColor", UI = AliasMap.Slider, Text = T("   [LỘ] MÀU KẺ CHỈ (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:X.Lam 7:Trắng)", "   [VISIBLE] LINE COLOR (1-7)"), ExpandHandle = "ModMenu_ESP9_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.EspLoai9_Line_Vis_Color or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.EspLoai9_Line_Vis_Color = tonumber(v); return SaveS() end },
            { Key = "ModMenu_ESP9_Line_HidColor", UI = AliasMap.Slider, Text = T("   [KHUẤT] MÀU KẺ CHỈ (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:X.Lam 7:Trắng)", "   [HIDDEN] LINE COLOR (1-7)"), ExpandHandle = "ModMenu_ESP9_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.EspLoai9_Line_Hid_Color or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.EspLoai9_Line_Hid_Color = tonumber(v); return SaveS() end },

            { Key = "ModMenu_EspChiTiet_Ex", UI = AliasMap.TitleSwitcher, Text = T("HIỂN THỊ THÔNG TIN ĐỊCH", "SHOW ENEMY INFO"), ExpandIndex = 0, GetFunc = function() return GetB("EspChiTiet") end, SetFunc = function(c,v) return SetB("EspChiTiet", v) end },
            { Key = "ModMenu_EspSoLuong", UI = AliasMap.Switcher, Text = T("   HIỆN SỐ LƯỢNG ĐỊCH LOẠI 1", "   SHOW ENEMY COUNT AROUND"), ExpandHandle = "ModMenu_EspChiTiet_Ex", GetFunc = function() return GetB("EspSoLuong") end, SetFunc = function(c,v) return SetB("EspSoLuong", v) end },
            { Key = "ModMenu_EspThongTinLoai2", UI = AliasMap.Switcher, Text = T("   HIỂN THỊ SỐ LƯỢNG ĐỊCH LOẠI 2(Phạm vi 400m)", "   ESP INFO TYPE 2 (TOP)"), ExpandHandle = "ModMenu_EspChiTiet_Ex", GetFunc = function() return GetB("EspThongTinLoai2") end, SetFunc = function(c,v) return SetB("EspThongTinLoai2", v) end },            
            { Key = "ModMenu_EspVuKhi", UI = AliasMap.Switcher, Text = T("   HIỆN VŨ KHÍ ĐỊCH CẦM", "   SHOW ENEMY WEAPON"), ExpandHandle = "ModMenu_EspChiTiet_Ex", GetFunc = function() return GetB("EspVuKhi") end, SetFunc = function(c,v) return SetB("EspVuKhi", v) end },
            { Key = "ModMenu_EspTuThe", UI = AliasMap.Switcher, Text = T("   HIỆN TƯ THẾ ĐỨNG/NGỒI/NẰM", "   SHOW ENEMY POSE (STAND/CROUCH/PRONE)"), ExpandHandle = "ModMenu_EspChiTiet_Ex", GetFunc = function() return GetB("EspTuThe") end, SetFunc = function(c,v) return SetB("EspTuThe", v) end },
            { Key = "ModMenu_CanhBaoDichNhin", UI = AliasMap.Switcher, Text = T("   CẢNH BÁO ĐỊCH ĐANG NGẮM", "   WARNING ENEMY AIMING"), ExpandHandle = "ModMenu_EspChiTiet_Ex", GetFunc = function() return GetB("CanhBaoDichNhin") end, SetFunc = function(c,v) return SetB("CanhBaoDichNhin", v) end },            
            { Key = "ModMenu_ESPOutline_Ex", UI = AliasMap.TitleSwitcher, Text = T("VIỀN MÀU NHÂN VẬT", "CHARACTER OUTLINE"), ExpandIndex = 0, GetFunc = function() return GetB("EspVien") end, SetFunc = function(c,v) return SetB("EspVien", v) end },
            { Key = "ModMenu_ESPOutline_Thickness", UI = AliasMap.Slider, Text = T("   ĐỘ DÀY VIỀN", "   OUTLINE THICKNESS"), ExpandHandle = "ModMenu_ESPOutline_Ex", Min = 1, Max = 20, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.OutlineThickness or 10 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.OutlineThickness = tonumber(v) or 10; _G.LexusConfig.OutlineThickness = tonumber(v) or 10; return SaveS() end },
            { Key = "ModMenu_ESPOutline_Color", UI = AliasMap.Slider, Text = T("   MÀU VIỀN (1:ĐỎ 2:LỤC 3:LAM 4:VÀNG 5:TÍM 6:X.LAM 7:TRẮNG)", "   COLOR (1:RED 2:GRN 3:BLU 4:YEL 5:PUR 6:CYN 7:WHT)"), ExpandHandle = "ModMenu_ESPOutline_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.OutlineColor or 4 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.OutlineColor = tonumber(v) or 4; return SaveS() end },            
            { Key = "ModMenu_EspItem_Ex", UI = AliasMap.TitleSwitcher, Text = "ESP VẬT PHẨM", ExpandIndex = 0, GetFunc = function() return GetB("EspItem_Master") end, SetFunc = function(c,v) return SetB("EspItem_Master", v) end },
            { Key = "ModMenu_EspItem_AR", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG AR (M4, AKM, BERYL...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_AR") end, SetFunc = function(c,v) return SetB("EspItem_AR", v) end },
            { Key = "ModMenu_EspItem_Sniper", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG NGẮM (KAR98, AWM, M24...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Sniper") end, SetFunc = function(c,v) return SetB("EspItem_Sniper", v) end },
            { Key = "ModMenu_EspItem_SMG", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG SMG (UZI, UMP, VECTOR...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_SMG") end, SetFunc = function(c,v) return SetB("EspItem_SMG", v) end },
            { Key = "ModMenu_EspItem_Shotgun", UI = AliasMap.Switcher, Text = "   HIỆN SHOTGUN (S686, S12K, DBS...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Shotgun") end, SetFunc = function(c,v) return SetB("EspItem_Shotgun", v) end },
            { Key = "ModMenu_EspItem_LMG", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG MÁY LMG (M249, DP-28...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_LMG") end, SetFunc = function(c,v) return SetB("EspItem_LMG", v) end },
            { Key = "ModMenu_EspItem_Pistol", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG LỤC", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Pistol") end, SetFunc = function(c,v) return SetB("EspItem_Pistol", v) end },
            { Key = "ModMenu_EspItem_Pistol", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG LỤC", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Pistol") end, SetFunc = function(c,v) return SetB("EspItem_Pistol", v) end },
{ Key = "ModMenu_EspItem_FlareGun", UI = AliasMap.Switcher, Text = "   HIỆN SÚNG PHÁO (FLARE GUN)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_FlareGun") end, SetFunc = function(c,v) return SetB("EspItem_FlareGun", v) end },
            { Key = "ModMenu_EspItem_Melee", UI = AliasMap.Switcher, Text = "   HIỆN CẬN CHIẾN (CHẢO, DAO...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Melee") end, SetFunc = function(c,v) return SetB("EspItem_Melee", v) end },
            { Key = "ModMenu_EspItem_Special", UI = AliasMap.Switcher, Text = "   HIỆN VŨ KHÍ ĐẶC BIỆT (CỐI, NỎ,CUNG...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Special") end, SetFunc = function(c,v) return SetB("EspItem_Special", v) end },
            { Key = "ModMenu_EspItem_Scope", UI = AliasMap.Switcher, Text = "   HIỆN ỐNG NGẮM (X3, X4, X6, X8...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Scope") end, SetFunc = function(c,v) return SetB("EspItem_Scope", v) end },
            { Key = "ModMenu_EspItem_Grenade", UI = AliasMap.Switcher, Text = "   HIỆN LỰU ĐẠN (NỔ, KHÓI, LỬA...)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Grenade") end, SetFunc = function(c,v) return SetB("EspItem_Grenade", v) end },
            { Key = "ModMenu_EspItem_Helmet", UI = AliasMap.Switcher, Text = "   HIỆN MŨ (LV1, LV2, LV3)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Helmet") end, SetFunc = function(c,v) return SetB("EspItem_Helmet", v) end },
            { Key = "ModMenu_EspItem_Bag", UI = AliasMap.Switcher, Text = "   HIỆN BA LÔ (LV1, LV2, LV3)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Bag") end, SetFunc = function(c,v) return SetB("EspItem_Bag", v) end },
            { Key = "ModMenu_EspItem_Armor", UI = AliasMap.Switcher, Text = "   HIỆN GIÁP (LV1, LV2, LV3)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Armor") end, SetFunc = function(c,v) return SetB("EspItem_Armor", v) end },
            { Key = "ModMenu_EspItem_Coin", UI = AliasMap.Switcher, Text = "   HIỆN XU CỬA HÀNG", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Coin") end, SetFunc = function(c,v) return SetB("EspItem_Coin", v) end },
            { Key = "ModMenu_EspItem_Heal", UI = AliasMap.Switcher, Text = "   HIỆN ĐỒ HỒI PHỤC (MÁU, NƯỚC)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Heal") end, SetFunc = function(c,v) return SetB("EspItem_Heal", v) end },
            { Key = "ModMenu_EspItem_Attach", UI = AliasMap.Switcher, Text = "   HIỆN PHỤ KIỆN (NÒNG, TAY CẦM)", ExpandHandle = "ModMenu_EspItem_Ex", GetFunc = function() return GetB("EspItem_Attach") end, SetFunc = function(c,v) return SetB("EspItem_Attach", v) end },
            
            { Key = "ModMenu_ESPBom_Ex", UI = AliasMap.TitleSwitcher, Text = T("ESP BOM", "ESP GRENADES"), ExpandIndex = 0, GetFunc = function() return GetB("EspBomMaster") end, SetFunc = function(c,v) return SetB("EspBomMaster", v) end },
            { Key = "ModMenu_ESPItemBom", UI = AliasMap.Switcher, Text = T("   ĐỊNH VỊ BOM DƯỚI ĐẤT", "   SHOW GROUND GRENADES"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return GetB("EspItemBom") end, SetFunc = function(c,v) return SetB("EspItemBom", v) end },
            { Key = "ModMenu_ESPActiveBom", UI = AliasMap.Switcher, Text = T("   CẢNH BÁO TRẠNG THÁI BOM", "   ACTIVE GRENADE WARNING"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return GetB("EspActiveBom") end, SetFunc = function(c,v) return SetB("EspActiveBom", v) end },           
            { Key = "ModMenu_ESPVehicle_Ex", UI = AliasMap.TitleSwitcher, Text = T("ESP ĐỊNH VỊ XE", "ESP VEHICLES"), ExpandIndex = 0, GetFunc = function() return GetB("EspVehicle") end, SetFunc = function(c,v) return SetB("EspVehicle", v) end },
            { Key = "ModMenu_ESPVeh_Dacia", UI = AliasMap.Switcher, Text = T("   HIỆN XE CON (DACIA)", "   SHOW CARS (DACIA)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Dacia") end, SetFunc = function(c,v) return SetB("EspVeh_Dacia", v) end },
            { Key = "ModMenu_ESPVeh_UAZ", UI = AliasMap.Switcher, Text = T("   HIỆN XE JEEP (UAZ)", "   SHOW JEEPS (UAZ)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_UAZ") end, SetFunc = function(c,v) return SetB("EspVeh_UAZ", v) end },
            { Key = "ModMenu_ESPVeh_Buggy", UI = AliasMap.Switcher, Text = T("   HIỆN XE BUGGY", "   SHOW BUGGYS"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Buggy") end, SetFunc = function(c,v) return SetB("EspVeh_Buggy", v) end },
            { Key = "ModMenu_ESPVeh_Coupe", UI = AliasMap.Switcher, Text = T("   HIỆN XE THỂ THAO (COUPE RB)", "   SHOW SPORTS CARS (COUPE RB)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Coupe") end, SetFunc = function(c,v) return SetB("EspVeh_Coupe", v) end },
            { Key = "ModMenu_ESPVeh_Mirado", UI = AliasMap.Switcher, Text = T("   HIỆN XE MIRADO", "   SHOW MIRADOS"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Mirado") end, SetFunc = function(c,v) return SetB("EspVeh_Mirado", v) end },
            { Key = "ModMenu_ESPVeh_Motor", UI = AliasMap.Switcher, Text = T("   HIỆN XE MÁY (MOTOR)", "   SHOW MOTORCYCLES"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Motor") end, SetFunc = function(c,v) return SetB("EspVeh_Motor", v) end },
            { Key = "ModMenu_ESPVeh_Other", UI = AliasMap.Switcher, Text = T("   HIỆN XE KHÁC (THUYỀN/BRDM)", "   SHOW OTHERS (BOAT/BRDM)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return GetB("EspVeh_Other") end, SetFunc = function(c,v) return SetB("EspVeh_Other", v) end },
            { Key = "ModMenu_EspKhungMau", UI = AliasMap.Switcher, Text = "ESP BOX", GetFunc = function() return GetB("EspKhungMau") end, SetFunc = function(c,v) return SetB("EspKhungMau", v) end },
            { Key = "ModMenu_EspMauDau", UI = AliasMap.Switcher, Text = T("ESP THANH MÁU LOẠI 2", "ESP HEALTH BAR V2"), GetFunc = function() return GetB("EspMauTrenDau") end, SetFunc = function(c,v) return SetB("EspMauTrenDau", v) end },
            { Key = "ModMenu_EspThongTin", UI = AliasMap.Switcher, Text = T("ESP ĐỊNH VỊ GỐC", "ESP ORIGINAL LOCATOR"), GetFunc = function() return GetB("EspThongTinGoc") end, SetFunc = function(c,v) return SetB("EspThongTinGoc", v) end },            
            { Key = "ModMenu_EspXuong", UI = AliasMap.Switcher, Text = T("ESP XƯƠNG (SKELETON)", "ESP SKELETON"), GetFunc = function() return GetB("EspXuong") end, SetFunc = function(c,v) return SetB("EspXuong", v) end },
        }
        local StackWall = {
            { Key = "ModMenu_ColorBodyV3_Ex", UI = AliasMap.TitleSwitcher, Text = T("WALL NEW", "WALL NEW"), ExpandIndex = 0, GetFunc = function() return GetB("ColorBodyV3") end, SetFunc = function(c,v) return SetB("ColorBodyV3", v) end },            
            { Key = "ModMenu_V3_Hidden_Color", UI = AliasMap.Slider, Text = T("   [KHUẤT] 1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Xanh Lam 7:Trắng", "   [HIDDEN] 1:Red 2:Grn 3:Blu 4:Yel 5:Pur 6:Cyan 7:Wht"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.V3_Hidden_Color or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.V3_Hidden_Color = tonumber(v); return SaveS() end },
            { Key = "ModMenu_V3_Visible_Color", UI = AliasMap.Slider, Text = T("   [LỘ] 1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Xanh Lam 7:Trắng", "   [VISIBLE] 1:Red 2:Grn 3:Blu 4:Yel 5:Pur 6:Cyn 7:Wht"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.V3_Visible_Color or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.V3_Visible_Color = tonumber(v); return SaveS() end },
            { Key = "ModMenu_CustomBright_Ex", UI = AliasMap.TitleSwitcher, Text = T("ĐỘ SÁNG MÀN HÌNH GAME", "GAME SCREEN BRIGHTNESS"), ExpandIndex = 0, GetFunc = function() return GetB("CustomBrightnessEnable") end, SetFunc = function(c,v) return SetB("CustomBrightnessEnable", v) end },
            { Key = "ModMenu_CustomBright_Val", UI = AliasMap.Slider, Text = T("   CHỈ SỐ (10 LÀ GỐC MẶC ĐỊNH)", "   VALUE (10 IS DEFAULT)"), ExpandHandle = "ModMenu_CustomBright_Ex", Min = 0, Max = 50, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.CustomBrightnessValue or 10 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.CustomBrightnessValue = tonumber(v); return SaveS() end },
            { Key = "ModMenu_WhiteBody", UI = AliasMap.Switcher, Text = T("NGƯỜI TRẮNG", "WHITE BODY"), GetFunc = function() return GetB("WhiteBody") end, SetFunc = function(c,v) return SetB("WhiteBody", v) end },
            { Key = "ModMenu_WallVehicle", UI = AliasMap.Switcher, Text = T("WALL PHƯƠNG TIỆN", "WALL VEHICLE"), GetFunc = function() return GetB("WallVehicle") end, SetFunc = function(c,v) return SetB("WallVehicle", v) end },
        }

        -- GỘP AIM GỐC VÀ CÀI ĐẶT SÚNG VÀO CHUNG TAB THEO Ý BẠN
        local StackAimbot = {
            -- Phần 1: AIM GỐC
            { Key = "ModMenu_AimbotV1_Ex", UI = AliasMap.TitleSwitcher, Text = T(" BẬT AIMBOT", "▶ ENABLE AIMBOT"), ExpandIndex = 0, GetFunc = function() return GetB("AimbotV1") end, SetFunc = function(c,v) return SetB("AimbotV1", v) end },
            { Key = "ModMenu_SpeedAimbotV1", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      AIMBOT SPEED"), ExpandHandle = "ModMenu_AimbotV1_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.SpeedAimbotV1 or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.SpeedAimbotV1 = tonumber(v) or 0; return SaveS() end },
            { Key = "ModMenu_FovAimbotV1", UI = AliasMap.Slider, Text = T("      FOV", "      AIMBOT FOV"), ExpandHandle = "ModMenu_AimbotV1_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.FovAimbotV1 or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.FovAimbotV1 = tonumber(v) or 0; return SaveS() end },

            -- Phần 2: CÀI ĐẶT SÚNG
          
            { Key = "ModMenu_GunSetting_Ex", UI = AliasMap.TitleSwitcher, Text = T(" BẬT CÀI ĐẶT SÚNG", "▶ ENABLE GUN SETTINGS"), ExpandIndex = 0, GetFunc = function() return GetB("AimbotV1") end, SetFunc = function(c,v) return SetB("AimbotV1", v) end },
            { Key = "ModMenu_ThuTam", UI = AliasMap.Slider, Text = T("      THU NHỎ TÂM BẮN", "      SHRINK CROSSHAIR"), ExpandHandle = "ModMenu_GunSetting_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.ThuTam or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.ThuTam = tonumber(v) or 0; return SaveS() end },
            { Key = "ModMenu_GiamGiatNgang", UI = AliasMap.Slider, Text = T("      GIẢM GIẬT NGANG (Dưới 50)", "      REDUCE H-RECOIL (Under 50)"), ExpandHandle = "ModMenu_GunSetting_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.GiamGiatNgang or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.GiamGiatNgang = tonumber(v) or 0; return SaveS() end },
            { Key = "ModMenu_GiamGiatDoc", UI = AliasMap.Slider, Text = T("      GIẢM GIẬT DỌC (Dưới 50)", "      REDUCE V-RECOIL (Under 50)"), ExpandHandle = "ModMenu_GunSetting_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.GiamGiatDoc or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.GiamGiatDoc = tonumber(v) or 0; return SaveS() end },
            { Key = "ModMenu_GiamRungScope", UI = AliasMap.Slider, Text = T("      GIẢM RUNG SCOPE", "      REDUCE SCOPE SHAKE"), ExpandHandle = "ModMenu_GunSetting_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.GiamRungScope or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.GiamRungScope = tonumber(v) or 0; return SaveS() end },
            { Key = "ModMenu_DanThang", UI = AliasMap.Switcher, Text = T("      ĐẠN THẲNG (NO SPREAD)", "      MAGIC ACCURACY (NO SPREAD)"), ExpandHandle = "ModMenu_GunSetting_Ex", GetFunc = function() return GetB("DanThang") end, SetFunc = function(c,v) return SetB("DanThang", v) end },
            { UI = AliasMap.Title, Text = T("LƯU Ý:NẾU BỊ LỖI DAME HÃY GIẢM GIÁ TRỊ XUỐNG (ÁP DỤNG CHO CÁC CHỨC NĂNG TRONG CÀI ĐẶT SÚNG)", "NOTE: IF YOU EXPERIENCE A DAMAGE ERROR, REDUCE THE VALUE.") },
            { UI = AliasMap.Title, Text = T("SAU KHI TẮT HÃY SET VỀ 0 VÀ VỨT SÚNG RA NHẶT LẠI ĐỂ RESET", "DROP AND PICK UP WEAPON AGAIN AFTER TURNING OFF") }
        }

        local StackAimbotV2 = {
            { UI = AliasMap.Title, Text = T("HỖ TRỢ TẤT CẢ CHẾ ĐỘ", "SUPPORTS ALL MODES") },            
            { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = T("BẬT AIMBOT", "ENABLE AIMBOT"), ExpandIndex = 0, GetFunc = function() return GetB("AimTouchEnable") end, SetFunc = function(c,v) return SetB("AimTouchEnable", v) end },
            
            -- [THÊM VÀO ĐÂY]: Nút bật tắt FOV và Custom màu FOV
            { Key = "ModMenu_AT_FovCircle", UI = AliasMap.Switcher, Text = T("   HIỂN THỊ VÒNG FOV", "   SHOW FOV CIRCLE"), ExpandHandle = "ModMenu_AT_Ex", GetFunc = function() return GetB("EspFovCircle") end, SetFunc = function(c,v) return SetB("EspFovCircle", v) end },
            { Key = "ModMenu_AT_FovCircle_Color", UI = AliasMap.Slider, Text = T("      MÀU FOV (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Xanh 7:Trắng)", "      FOV COLOR (1-7)"), ExpandHandle = "ModMenu_AT_Ex", Min = 1, Max = 7, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.EspFovCircle_Color or 7 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.EspFovCircle_Color = tonumber(v); return SaveS() end },
            
            { Key = "ModMenu_AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM TÂM TRẮNG", "   HIPFIRE AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchHipfire") end, SetFunc = function(c,v) return SetB("AimTouchHipfire", v) end },
            { Key = "ModMenu_AT_Hip_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Hip_IgBot", UI = AliasMap.Switcher, Text = T("      BỎ QUA BOT", "      IGNORE BOTS"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipIgBot == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipIgBot = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Hip_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      VISIBILITY CHECK"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Hip_Cond", UI = AliasMap.Slider, Text = T("      ĐIỀU KIỆN (1:BẮN MỚI AIM 2:LUÔN AIM)", "      CONDITION (1:ON FIRE 2:ALWAYS)"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 2, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipCond = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Hip_Prio", UI = AliasMap.Slider, Text = T("      ƯU TIÊN (1:TÂM 2:GẦN 3:HP 4:%HP)", "      PRIORITY (1:CROSSHAIR 2:DIST 3:HP)"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 4, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipPrio = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Hip_Bone", UI = AliasMap.Slider, Text = T("      VỊ TRÍ (1:ĐẦU 2:CỔ 3:BỤNG)", "      TARGET BONE (1:HEAD 2:NECK 3:PELVIS)"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 3, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipBone or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipBone = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Hip_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      SPEED"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipSpeed or 50 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Hip_FOV", UI = AliasMap.Slider, Text = T("      FOV (BÁN KÍNH)", "      FOV"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipFOV or 30 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Hip_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 5 Mét)", "      DISTANCE (1 Step = 5m)"), ExpandHandle = "ModMenu_AT_Hip_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchHipDist or 250) / 5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipDist = tonumber(v) * 5; return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM KHI MỞ SCOPE", "   SCOPE AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchScopeAll") end, SetFunc = function(c,v) return SetB("AimTouchScopeAll", v) end },
            { Key = "ModMenu_AT_ScopeAll_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_IgBot", UI = AliasMap.Switcher, Text = T("      BỎ QUA BOT", "      IGNORE BOTS"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeIgBot == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeIgBot = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      VISIBILITY CHECK"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Cond", UI = AliasMap.Slider, Text = T("      ĐIỀU KIỆN (1:BẮN MỚI AIM 2:LUÔN AIM)", "      CONDITION (1:ON FIRE 2:ALWAYS)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 2, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeCond or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeCond = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Prio", UI = AliasMap.Slider, Text = T("      ƯU TIÊN (1:TÂM 2:GẦN 3:HP 4:%HP)", "      PRIORITY (1:CROSSHAIR 2:DIST 3:HP)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 4, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopePrio or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopePrio = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Bone", UI = AliasMap.Slider, Text = T("      VỊ TRÍ (1:ĐẦU 2:CỔ 3:BỤNG)", "      TARGET BONE (1:HEAD 2:NECK 3:PELVIS)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 3, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeBone or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeBone = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      SPEED"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeSpeed or 50 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_FOV", UI = AliasMap.Slider, Text = T("      VÒNG FOV", "      FOV"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeFOV or 30 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 5 Mét)", "      DISTANCE (1 Step = 5m)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchScopeDist or 300) / 5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeDist = tonumber(v) * 5; return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Pred", UI = AliasMap.Slider, Text = T("      DỰ ĐOÁN HƯỚNG CHẠY", "      PREDICT MOVEMENT (AIM AHEAD)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopePred or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopePred = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_ScopeAll_Recoil", UI = AliasMap.Slider, Text = T("      TỰ ĐỘNG BÙ GIẬT", "      AUTO RECOIL COMPENSATION"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchScopeRecoil or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchScopeRecoil = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM SHOTGUN", "   SHOTGUN AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchSG") end, SetFunc = function(c,v) return SetB("AimTouchSG", v) end },
            { Key = "ModMenu_AT_SG_AutoFire", UI = AliasMap.Switcher, Text = T("      TỰ ĐỘNG BẮN", "      AUTO FIRE"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return GetB("AimTouchSGAutoFire") end, SetFunc = function(c,v) return SetB("AimTouchSGAutoFire", v) end },
            { Key = "ModMenu_AT_SG_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_SG_IgBot", UI = AliasMap.Switcher, Text = T("      BỎ QUA BOT", "      IGNORE BOTS"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGIgBot == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGIgBot = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_SG_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      VISIBILITY CHECK"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_SG_Cond", UI = AliasMap.Slider, Text = T("      ĐIỀU KIỆN (1:BẮN MỚI AIM 2:LUÔN AIM)", "      CONDITION (1:ON FIRE 2:ALWAYS)"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 2, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGCond or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGCond = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_SG_Prio", UI = AliasMap.Slider, Text = T("      ƯU TIÊN (1:TÂM 2:GẦN 3:HP 4:%HP)", "      PRIORITY (1:CROSSHAIR 2:DIST 3:HP)"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 4, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGPrio or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGPrio = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_SG_Bone", UI = AliasMap.Slider, Text = T("      VỊ TRÍ (1:ĐẦU 2:CỔ 3:BỤNG)", "      TARGET BONE (1:HEAD 2:NECK 3:BODY)"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 3, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGBone or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGBone = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_SG_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      SPEED"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGSpeed or 80 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_SG_FOV", UI = AliasMap.Slider, Text = T("      FOV", "      FOV (RADIUS)"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGFOV or 40 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_SG_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 3 Mét)", "      DISTANCE (1 Step = 3m)"), ExpandHandle = "ModMenu_AT_SG_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchSGDist or 30) / 3) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGDist = tonumber(v) * 3; return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM SNIPER", "   SNIPER AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchScopeSniper") end, SetFunc = function(c,v) return SetB("AimTouchScopeSniper", v) end },
            { Key = "ModMenu_AT_Sniper_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Sniper_IgBot", UI = AliasMap.Switcher, Text = T("      BỎ QUA BOT", "      IGNORE BOTS"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperIgBot == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperIgBot = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      CHECK WALL"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Cond", UI = AliasMap.Slider, Text = T("      ĐIỀU KIỆN (1:BẮN MỚI AIM 2:LUÔN AIM)", "      CONDITION (1:ON FIRE 2:ALWAYS)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 2, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperCond or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperCond = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Prio", UI = AliasMap.Slider, Text = T("      ƯU TIÊN (1:TÂM 2:GẦN 3:HP 4:%HP)", "      PRIORITY (1:CROSSHAIR 2:DIST 3:HP)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 4, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperPrio or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperPrio = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Bone", UI = AliasMap.Slider, Text = T("      VỊ TRÍ (1:ĐẦU 2:CỔ 3:BỤNG)", "      TARGET BONE (1:HEAD 2:NECK 3:PELVIS)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 3, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperBone or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperBone = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      SPEED"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperSpeed or 30 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_FOV", UI = AliasMap.Slider, Text = T("      FOV", "      FOV (RADIUS)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperFOV or 20 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 8 Mét)", "      DISTANCE (1 Step = 8m)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchSniperDist or 400) / 8) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperDist = tonumber(v) * 8; return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Pred", UI = AliasMap.Slider, Text = T("      DỰ ĐOÁN HƯỚNG CHẠY", "      PREDICT MOVEMENT (AIM AHEAD)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperPred or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperPred = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Sniper_Recoil", UI = AliasMap.Slider, Text = T("      TỰ ĐỘNG BÙ GIẬT", "      AUTO RECOIL COMPENSATION"), ExpandHandle = "ModMenu_AT_Sniper_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSniperRecoil or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSniperRecoil = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Mortar_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM SÚNG CỐI (MORTAR)", "   MORTAR AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchMortar") end, SetFunc = function(c,v) return SetB("AimTouchMortar", v) end },
            { Key = "ModMenu_AT_Mortar_Pred", UI = AliasMap.Slider, Text = T("      DỰ ĐOÁN HƯỚNG CHẠY", "      PREDICT MOVEMENT"), ExpandHandle = "ModMenu_AT_Mortar_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchMortarPred or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchMortarPred = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM NỎ (CROSSBOW)", "   CROSSBOW AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchCrossbow") end, SetFunc = function(c,v) return SetB("AimTouchCrossbow", v) end },
            { Key = "ModMenu_AT_CB_Vel", UI = AliasMap.Slider, Text = T("      VẬN TỐC TÊN (ĐỂ CĂN GÓC)", "      ARROW VELOCITY"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 100, Max = 300, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowVel or 160 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowVel = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_Drop", UI = AliasMap.Slider, Text = T("      BÙ RƠI  ", "      GRAVITY DROP COMP (%)"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 0, Max = 150, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowDrop or 100 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowDrop = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_DropProne", UI = AliasMap.Slider, Text = T("      BÙ RƠI KHI ĐỊCH NẰM (Chỉnh khoảng 22-25) ", "      PRONE GRAVITY DROP (%)"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 0, Max = 200, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowDropProne or 120 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowDropProne = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_CB_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_CB_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      VISIBILITY CHECK"), ExpandHandle = "ModMenu_AT_CB_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_CB_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ ", "      AIM SPEED"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowSpeed or 100 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_FOV", UI = AliasMap.Slider, Text = T("       FOV", "      FOV (RADIUS)"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowFOV or 40 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_CB_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 5 Mét)", "      DISTANCE (1 Step = 5m)"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchCrossbowDist or 150) / 5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowDist = tonumber(v) * 5; return SaveS() end },
            { Key = "ModMenu_AT_CB_Pred", UI = AliasMap.Slider, Text = T("      DỰ ĐOÁN HƯỚNG CHẠY", "      PREDICT MOVEMENT"), ExpandHandle = "ModMenu_AT_CB_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchCrossbowPred or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchCrossbowPred = tonumber(v); return SaveS() end },            
            { Key = "ModMenu_AT_Bow_Ex", UI = AliasMap.TitleSwitcher, Text = T("   AIM CUNG NỔ (EXPLOSIVE BOW)", "   BOW AIM"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return GetB("AimTouchBow") end, SetFunc = function(c,v) return SetB("AimTouchBow", v) end },
            { Key = "ModMenu_AT_Bow_IgKnock", UI = AliasMap.Switcher, Text = T("      BỎ QUA ĐỊCH KNOCK", "      IGNORE KNOCKED ENEMIES"), ExpandHandle = "ModMenu_AT_Bow_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowIgKnock == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowIgKnock = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Bow_Vis", UI = AliasMap.Switcher, Text = T("      CHECK TƯỜNG(AIM XUYÊN TƯỜNG)", "      VISIBILITY CHECK"), ExpandHandle = "ModMenu_AT_Bow_Ex", GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowVisCheck == 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowVisCheck = v and 1 or 0; return SaveS() end },
            { Key = "ModMenu_AT_Bow_Cond", UI = AliasMap.Slider, Text = T("      ĐIỀU KIỆN (1:VƯƠN CUNG 2:LUÔN AIM)", "      CONDITION (1:DRAW 2:ALWAYS)"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 1, Max = 2, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowCond or 1 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowCond = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Bow_Bone", UI = AliasMap.Slider, Text = T("      VỊ TRÍ (1:ĐẦU 2:NGỰC 3:BỤNG)", "      TARGET BONE"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 1, Max = 3, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowBone or 2 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowBone = math.floor(tonumber(v)+0.5); return SaveS() end },
            { Key = "ModMenu_AT_Bow_Spd", UI = AliasMap.Slider, Text = T("      TỐC ĐỘ", "      AIM SPEED"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowSpeed or 80 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Bow_FOV", UI = AliasMap.Slider, Text = T("       FOV", "      FOV (RADIUS)"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowFOV or 40 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowFOV = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Bow_Dist", UI = AliasMap.Slider, Text = T("      KHOẢNG CÁCH (1 Nấc = 5 Mét)", "      DISTANCE (1 Step = 5m)"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return math.floor((_G.LexusState.CustomTextData.AimTouchBowDist or 150) / 5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowDist = tonumber(v) * 5; return SaveS() end },
            { Key = "ModMenu_AT_Bow_Recoil", UI = AliasMap.Slider, Text = T("      TỰ ĐỘNG BÙ GIẬT", "      AUTO RECOIL"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowRecoil or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowRecoil = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Bow_Drop", UI = AliasMap.Slider, Text = T("      BÙ RƠI CUNG", "      BOW DROP COMP"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 0, Max = 150, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowDrop or 50 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowDrop = tonumber(v); return SaveS() end },
            { Key = "ModMenu_AT_Bow_Pred", UI = AliasMap.Slider, Text = T("      DỰ ĐOÁN HƯỚNG CHẠY", "      PREDICT MOVEMENT"), ExpandHandle = "ModMenu_AT_Bow_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchBowPred or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchBowPred = tonumber(v); return SaveS() end }
        }         
        local StackSkin = {
            { Key = "ModMenu_ModSkin", UI = AliasMap.Switcher, Text = "MOD SKIN(Bật Rồi Đợi 5-10S Rồi Ra Sảnh Là Thấy)", GetFunc = function() return _G.LexusConfig.ModSkin end, SetFunc = function(c,v) 
    _G.LexusConfig.ModSkin = v 
    if _G.SaveModSettings then _G.SaveModSettings() end
    
    if v == true then
        _G.AddOutfitLobbyRestored = false
        _G.LobbyRestoreAttempts = 0
    end
    return true 
end },
            { Key = "ModMenu_ModEmote", UI = AliasMap.Switcher, Text = "UNLOCK EMOTE (DÙNG TRONG TRẬN)", GetFunc = function() return _G.LexusConfig.ModEmote end, SetFunc = function(c,v) _G.LexusConfig.ModEmote = v return true end },
            { Key = "ModMenu_SkinAttachment", UI = AliasMap.Switcher, Text = "PHỤ KIỆN SÚNG", GetFunc = function() return _G.LexusConfig.SkinAttachment end, SetFunc = function(c,v) _G.LexusConfig.SkinAttachment = v return true end },
            { UI = AliasMap.Title, Text = T("MÁY YẾU HẠN CHẾ BẬT HÒM + TBD + ĐẾM KILL", "THIS NOT FOR LOW DEVICE") },
            { Key = "ModMenu_SkinDeadBox", UI = AliasMap.Switcher, Text = "HÒM XÁC", GetFunc = function() return _G.LexusConfig.SkinDeadBox end, SetFunc = function(c,v) _G.LexusConfig.SkinDeadBox = v return true end },            
            { Key = "ModMenu_KillMessage", UI = AliasMap.Switcher, Text = "THÔNG BÁO DIỆT", GetFunc = function() return _G.LexusConfig.KillMessage end, SetFunc = function(c,v) _G.LexusConfig.KillMessage = v return true end },
            { Key = "ModMenu_KillCountUI", UI = AliasMap.Switcher, Text = "BỘ ĐẾM KILL", GetFunc = function() return _G.LexusConfig.KillCountUI end, SetFunc = function(c,v) _G.LexusConfig.KillCountUI = v return true end },
            { UI = AliasMap.Title, Text = T("OWNER", "OWNER") },
            { Key = "ModMenu_SkinOpenLink", UI = AliasMap.Switcher, Text = "THAM GIA TELEGRAM", GetFunc = function() return _G.LexusConfig.SkinOpenLink end, SetFunc = function(c,v) _G.LexusConfig.SkinOpenLink = v; if v == true then _pcall(function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/tdx088") end end) end return true end },
            { Key = "ModMenu_SkinOpenLink", UI = AliasMap.Switcher, Text = "ADMIN", GetFunc = function() return _G.LexusConfig.SkinOpenLink end, SetFunc = function(c,v) _G.LexusConfig.SkinOpenLink = v; if v == true then _pcall(function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/Thanhdat1690") end end) end return true end },
        }                
        local StackMagic = {
            { Key = "ModMenu_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "MAGIC BULLET", ExpandIndex = 0, GetFunc = function() return GetB("CustomMagicBullet") end, SetFunc = function(c,v) return SetB("CustomMagicBullet", v) end },
            { Key = "ModMenu_Magic_Head", UI = AliasMap.Slider, Text = T("   SÁT THƯƠNG ĐẦU", "   HEAD DAMAGE"), ExpandHandle = "ModMenu_Magic_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return math.floor(((_G.LexusState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicHead = (tonumber(v) / 100.0) * 5.0; return SaveS() end },
            { Key = "ModMenu_Magic_Body", UI = AliasMap.Slider, Text = T("   SÁT THƯƠNG THÂN", "   BODY DAMAGE"), ExpandHandle = "ModMenu_Magic_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return math.floor(((_G.LexusState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicBody = (tonumber(v) / 100.0) * 5.0; return SaveS() end },
            { Key = "ModMenu_Magic_Legs", UI = AliasMap.Slider, Text = T("   SÁT THƯƠNG CHÂN", "   LEGS DAMAGE"), ExpandHandle = "ModMenu_Magic_Ex", Min = 0, Max = 100, Step = 1, GetFunc = function() return math.floor(((_G.LexusState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicLegs = (tonumber(v) / 100.0) * 5.0; return SaveS() end },
            { UI = AliasMap.Title, Text = T("CHỨC NĂNG DỄ GÂY BAN MẠNG CÂN NHẮC TRƯỚC KHI BẬT", "DANGEROUS FEATURE, USE WITH CAUTION") },
            { UI = AliasMap.Title, Text = T("LƯU Ý:ĐỪNG CHỈNH QUÁ CAO SẼ BỊ LỖI DAME", "NOTE: DO NOT ADJUST TOO HIGH OR IT WILL CAUSE DAMAGE ERRORS") },
        }
        local StackCombat = {
            { Key = "ModMenu_LangEnglish", UI = AliasMap.Switcher, Text = T("NGÔN NGỮ: TIẾNG VIỆT (BẬT LÊN ĐỂ CHUYỂN ENGLISH)", "LANGUAGE: ENGLISH (TURN OFF FOR VIETNAMESE)"), GetFunc = function() return GetB("LangEnglish") end, SetFunc = function(c,v) SetB("LangEnglish", v); if Notify then Notify(T("Vui lòng khởi động lại game để cập nhật Menu Ngôn Ngữ!", "Please restart the game to apply the Language change!")) end return true end },          
            { Key = "ModMenu_UnlockFPS", UI = AliasMap.Switcher, Text = T("MỞ KHOÁ 165 FPS", "UNLOCK 165 FPS"), GetFunc = function() return GetB("UnlockFPS") end, SetFunc = function(c,v) local st = SetB("UnlockFPS", v); if GetB("UnlockFPS") then _G.LexusState.GraphicsUnlocked = false end; return st end },
            { Key = "ModMenu_IpadView_Ex", UI = AliasMap.TitleSwitcher, Text = "IPAD VIEW ĐI BỘ", ExpandIndex = 0, GetFunc = function() return GetB("IpadView") end, SetFunc = function(c,v) return SetB("IpadView", v) end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = T("   FOV IPAD", "   IPAD FOV"), ExpandHandle = "ModMenu_IpadView_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return (_G.LexusState.CustomTextData.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.IpadViewFOV = 90 + tonumber(v); return SaveS() end },            
            { Key = "ModMenu_IpadVeh_Ex", UI = AliasMap.TitleSwitcher, Text = T("IPAD VIEW LÁI XE", "VEHICLE POV"), ExpandIndex = 0, GetFunc = function() return GetB("IpadViewVehicle") end, SetFunc = function(c,v) return SetB("IpadViewVehicle", v) end },
            { Key = "ModMenu_IpadVeh_FOV", UI = AliasMap.Slider, Text = T("   FOV LÁI XE", "   VEHICLE FOV"), ExpandHandle = "ModMenu_IpadVeh_Ex", Min = 1, Max = 100, Step = 1, GetFunc = function() return (_G.LexusState.CustomTextData.IpadViewVehicleFOV or 120) - 90 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.IpadViewVehicleFOV = 90 + tonumber(v); return SaveS() end },            
            { Key = "ModMenu_BugMan_Ex", UI = AliasMap.TitleSwitcher, Text = T("BUG MÀN / KÉO GIÃN", "SCREEN STRETCH"), ExpandIndex = 0, GetFunc = function() return GetB("BugManEnable") end, SetFunc = function(c,v) return SetB("BugManEnable", v) end },
            { Key = "ModMenu_BugMan_Ratio", UI = AliasMap.Slider, Text = T("   ĐỘ KÉO DÃN (CÀNG NHỎ CÀNG MẬP)", "   STRETCH RATIO (LOWER = FATTER)"), ExpandHandle = "ModMenu_BugMan_Ex", Min = 110, Max = 200, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.BugManRatio or 133 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.BugManRatio = tonumber(v); return SaveS() end },           
            { Key = "ModMenu_WeaponGlow_Ex", UI = AliasMap.TitleSwitcher, Text = T("VIỀN MÀU SÚNG (VŨ KHÍ PHÁT SÁNG)", "WEAPON GLOW"), ExpandIndex = 0, GetFunc = function() return GetB("WeaponGlow") end, SetFunc = function(c,v) return SetB("WeaponGlow", v) end },
            { Key = "ModMenu_WeaponGlowColor", UI = AliasMap.Slider, Text = T("   MÀU(1:ĐỎ 2:LỤC 3:LAM 4:VÀNG 5:RGB)", "   COLOR(1:RED 2:GRN 3:BLU 4:YEL 5:RGB)"), ExpandHandle = "ModMenu_WeaponGlow_Ex", Min = 1, Max = 5, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.WeaponGlowColor or 5 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.WeaponGlowColor = tonumber(v); return SaveS() end },
            { Key = "ModMenu_WeaponGlowThick", UI = AliasMap.Slider, Text = T("   ĐỘ DÀY VIỀN SÁNG", "   GLOW THICKNESS"), ExpandHandle = "ModMenu_WeaponGlow_Ex", Min = 1, Max = 15, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.WeaponGlowThickness or 3 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.WeaponGlowThickness = tonumber(v); return SaveS() end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = T("TRỜI ĐEN (BLACK SKY)", "BLACK SKY"), GetFunc = function() return GetB("BlackSky") end, SetFunc = function(c,v) return SetB("BlackSky", v) end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = T("XÓA SƯƠNG MÙ", "REMOVE FOG"), GetFunc = function() return GetB("RemoveFog") end, SetFunc = function(c,v) return SetB("RemoveFog", v) end },
            { Key = "ModMenu_RemoveGrass", UI = AliasMap.Switcher, Text = T("XÓA CỎ", "REMOVE GRASS"), GetFunc = function() return GetB("RemoveGrass") end, SetFunc = function(c,v) return SetB("RemoveGrass", v) end },
            { Key = "ModMenu_WallClimb", UI = AliasMap.Switcher, Text = T("LEO TƯỜNG CAO", "HIGH WALL CLIMB"), GetFunc = function() return GetB("WallClimb") end, SetFunc = function(c,v) return SetB("WallClimb", v) end },
            { Key = "ModMenu_FastCar_Ex", UI = AliasMap.TitleSwitcher, Text = T("XE NHANH", "FAST CAR"), ExpandIndex = 0, GetFunc = function() return GetB("FastCar") end, SetFunc = function(c,v) return SetB("FastCar", v) end },
            { Key = "ModMenu_FastCarSpeed", UI = AliasMap.Slider, Text = T("   TỐC ĐỘ XE (CHỈNH 1 LÀ ÍT LỘ)", "   CAR SPEED (0: DEFAULT, MAX 200)"), ExpandHandle = "ModMenu_FastCar_Ex", Min = 0, Max = 200, Step = 1, GetFunc = function() return _G.LexusState.CustomTextData.FastCarSpeed or 0 end, SetFunc = function(c,v) _G.LexusState.CustomTextData.FastCarSpeed = tonumber(v); return SaveS() end },
            { Key = "ModMenu_FakeHWID", UI = AliasMap.Switcher, Text = T("FAKE HWID (CHỐNG GHIM ID)", "FAKE HWID (ANTI-BAN)"), GetFunc = function() return GetB("FakeHWID") end, SetFunc = function(c,v) return SetB("FakeHWID", v) end },
          
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text = 999000, 
            UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_ESP", Text = 999001, Stack = MergeStacks(StackESP, StackWall) },
                { Key = "Cat_Aimbot", Text = 999002, Stack = StackAimbot },
                { Key = "Cat_AimbotV2", Text = 999003, Stack = StackAimbotV2 },
                { Key = "Cat_Magic", Text = 999004, Stack = StackMagic },
                { Key = "Cat_Skin", Text = 999006, Stack = StackSkin },
                { Key = "Cat_Combat", Text = 999007, Stack = StackCombat }
            }
        }
        
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName and (string.find(string.lower(config.keyName), "setting_main") or string.find(string.lower(config.keyName), "setting")) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then
                            hasModMenu = true
                            break
                        end
                    end
                    if not hasModMenu then
                        table.insert(catalog, 1, SettingPageDefine.ModMenu)
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end


local function ShowLexusVIPMenu() 
    if _G.LexusMenuAlreadyShown then return end
    if _G.LexusState.MenuStep ~= 0 then return end
    local function T(vi, en) return _G.LexusConfig.LangEnglish and en or vi end
    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end
        local function Step_ScamAlert()
            Msg.Show(2, T("THÔNG BÁO TỪ ADMIN", "MESSAGE FROM ADMIN"), 
            T("THAM GIA TELEGRAM TÔI ĐỂ TRÁNH CÁC THÀNH PHẦN BÁN MOD LỪA ĐẢO.\nADMIN @Thanhdat1690\n NHẤN ĐỒNG Ý ĐỂ THAM GIA KÊNH", "JOIN MY TELEGRAM TO AVOID SCAMMERS.\nADMIN @Thanhdat1690\n PRESS AGREE TO JOIN THE CHANNEL"), 
            function() 
                local Web = require("client.slua.logic.url.logic_webview_sdk")
                if Web and Web.OpenURL then Web:OpenURL("https://t.me/Thanhdat1690") end 
            end, 
            function() end, 
            T("THAM GIA", "JOIN"), T("HỦY", "CANCEL"))            
            _G.LexusState.MenuStep = 99
            _G.LexusMenuAlreadyShown = true
        end
        local function Step_Welcome()
            Msg.Show(2, T("WELCOME TO LUA FREE V11", "WELCOME TO LUA FREE V11"),
            T("\nVUI LÒNG KHÔNG BẬT QUÁ NHIỀU CHỨC NĂNG ESP CÙNG LÚC ĐỂ TRÁNH QUÁ TẢI RAM VÀ DROP FPS.", "\nPLEASE DO NOT ENABLE TOO MANY ESP FEATURES AT ONCE TO AVOID RAM OVERLOAD AND FPS DROP."), 
            function() 
                _G.InitModMenuTab()
                if Notify then
                    Notify(T("ĐÃ THÊM 'VIP MOD MENU' VÀO PHẦN CÀI ĐẶT CỦA GAME!\nHãy mở Cài Đặt (Răng Cưa) -> VIP MOD MENU để bật/tắt!", "ADDED 'VIP MOD MENU' TO GAME SETTINGS!\nOpen Settings (Gear icon) -> VIP MOD MENU to toggle features!"))
                end
                Step_ScamAlert()
            end, 
            function() end, T("MỞ MENU", "OPEN MENU"), T("ĐÓNG", "CLOSE"))
        end
        _G.LexusState.MenuStep = 1
        Step_Welcome() 
    end)
end

local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.LexusState.GraphicsUnlocked or currentTime > limitTime then return end
    _pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)
    _pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")        
        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor
        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then 
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end
        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true) 
                        _pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then 
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) 
                        end
                    end
                end
            end
        end
        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end            
            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end
            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end
            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)               
                itemRoot.Veihclescreen3:SetText(_tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)                
                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end
            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", _tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", _tostring(FPSFineTuneNum))
                end
            end
            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end            
            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.LexusState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

local function InitializeNativeESP() 
    if _G.LexusState.NativeESPReady then return end    
    _pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local offset1006 = FVector(0, 0, -30)
        local offset8888 = FVector(0, 0, 30)
        local offset9999 = FVector(0, 0, 50)
        local uiPath = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C"
        local MAX_DIST = 40000 
        local MAX_WGT = 35 
        local function ApplyCfg(cfg)
            if not cfg then return end             
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true
                cfg[1006].bBindOutScreen = true 
                cfg[1006].MaxWidgetNum = MAX_WGT
                cfg[1006].MaxShowDistance = MAX_DIST 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root" 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = offset1006 
            end             
            cfg[8888] = { 
                UIPathName = uiPath,
                MaxWidgetNum = MAX_WGT, 
                MaxShowDistance = MAX_DIST, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = offset8888,
                bNeedPreLoad = false, 
                Priority = 2 
            }             
            cfg[9999] = { 
                UIPathName = uiPath,
                MaxWidgetNum = MAX_WGT, 
                MaxShowDistance = MAX_DIST, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = offset9999,
                bNeedPreLoad = false, 
                Priority = 2 
            } 
        end         
        ApplyCfg(currentMarkCfg)         
        for k, cfg in _pairs(package.loaded) do 
            if _type(k) == "string" and _string_find(k, "ScreenMarkConfig") and _type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    
    _G.LexusState.NativeESPReady = true 
end


local function GetDirectAvatarMeshes(enemy)
    local meshes = {}
    if slua.isValid(enemy.Mesh) then 
        table.insert(meshes, enemy.Mesh) 
    end
    local avatarComp = enemy.CharacterAvatarComp2_BP or (enemy.getAvatarComponent2 and enemy:getAvatarComponent2())
    if slua.isValid(avatarComp) and avatarComp.GetMeshCompBySlot then
        for _, slot in ipairs({0, 1, 2, 3, 4, 5, 6, 7}) do 
            local mesh = avatarComp:GetMeshCompBySlot(slot)
            if slua.isValid(mesh) then table.insert(meshes, mesh) end
        end
    end
    local currentWeapon = nil
    pcall(function() currentWeapon = enemy.GetCurrentWeapon and enemy:GetCurrentWeapon() or enemy.CurrentWeapon end)
    if slua.isValid(currentWeapon) and slua.isValid(currentWeapon.Mesh) then
        table.insert(meshes, currentWeapon.Mesh)
    end
    return meshes, currentWeapon
end

-- ==============================================================
-- [FIX CRASH] HỆ THỐNG CACHE MÀU VÀ CHỐNG TRÀN BỘ NHỚ
-- ==============================================================
local _ColorCacheV3 = {}
local function GetCachedMenuColorV3(idx)
    if _ColorCacheV3[idx] then return _ColorCacheV3[idx] end
    local r, g, b = 0, 0, 0
    if idx == 1 then r = 100; g = 0;   b = 0   end 
    if idx == 2 then r = 0;   g = 100; b = 0   end 
    if idx == 3 then r = 0;   g = 0;   b = 100 end 
    if idx == 4 then r = 100; g = 100; b = 0   end 
    if idx == 5 then r = 100; g = 0;   b = 100 end 
    if idx == 6 then r = 0;   g = 100; b = 100 end
    if idx == 7 then r = 100; g = 100; b = 100 end 
    local LinearColorClass = import("LinearColor") or _G.FLinearColor
    local col = LinearColorClass and LinearColorClass(r, g, b, 1) or {R=r, G=g, B=b, A=1}
    _ColorCacheV3[idx] = col
    return col
end

local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        if not _G.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and slua.isValid(world) then
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
                _G.ConsoleNewWallReady = true
            end
        end
        
        local meshes, currentWeapon = GetDirectAvatarMeshes(enemy)
        local meshCount = #meshes
        local weaponHash = slua.isValid(currentWeapon) and tostring(currentWeapon) or "NO_WEP"
        
        local cData = _G.LexusState and _G.LexusState.CustomTextData or {}
        local invisIdx = tonumber(cData.V3_Hidden_Color) or 1 
        local visIdx = tonumber(cData.V3_Visible_Color) or 2         
        
        local stateHash = "V3_" .. tostring(meshCount) .. "_" .. tostring(invisIdx) .. "_" .. tostring(visIdx) .. "_" .. weaponHash
        
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied then
            return 
        end        
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true
        
        local visColor = GetCachedMenuColorV3(visIdx)
        local occColor = GetCachedMenuColorV3(invisIdx)
        
        for _, mesh in ipairs(meshes) do
            if slua.isValid(mesh) then
                pcall(function()
                    -- [CHỐNG VĂNG 1]: Double check! Đảm bảo mesh không bị hủy ngang giữa frame
                    if not slua.isValid(mesh) then return end
                    
                    -- [CHỐNG VĂNG 2]: Tách biệt súng ra khỏi việc áp dụng Outline/Depth
                    local isWeapon = slua.isValid(currentWeapon) and (mesh == currentWeapon.Mesh)

                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true)
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor)
                        mesh:SetOccludedDyeingColor(occColor)
                        
                        -- Chỉ áp dụng các hiệu ứng nặng (Outline, Custom Depth) cho cơ thể, BỎ QUA SÚNG
                        if not isWeapon then
                            mesh:SetDrawHighlight(true)
                            mesh:OverrideHighlightColor(visColor)
                            mesh:SetHighlightCanBeOccluded(false)
                            
                            mesh:SetDrawIdeaOutline(true)
                            mesh:SetIdeaOutlineNew(true)
                            mesh:SetIdeaOutlineOcclusionHighlight(true)
                            mesh:OverrideIdeaOutlineColor(visColor)
                            mesh:SetIdeaOutlineOcclusionColor(occColor)
                            
                            -- Giảm độ dày xuống 5.0 (20.0 quá lớn, dễ gây tràn Shader trên máy yếu)
                            mesh:OverrideIdeaOutlineThickness(5.0)
                            mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                            
                            mesh:SetRenderCustomDepth(true)
                            mesh:SetCustomDepthStencilValue(255)
                        end
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyV3(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes, _ = GetDirectAvatarMeshes(enemy)
            for _, mesh in ipairs(meshes) do
                if slua.isValid(mesh) then
                    pcall(function()
                        if not slua.isValid(mesh) then return end
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false)
                            mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false)
                            mesh:SetRenderCustomDepth(false)
                            mesh:SetCustomDepthStencilValue(0)
                        end
                    end)
                end
            end          
            markData.ColorNewApplied = false
            markData.LastColorNewHash = ""
        end
    end)
end

_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then
        return result
    end
    
    local curTime = os.clock()
    -- Bước 1: Cache danh sách tổng (Sống & Khác Team) trong 0.1s
    if not _G.GlobalEnemyCacheTime or (curTime - _G.GlobalEnemyCacheTime > 0.1) then
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then
            allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then
            for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
        end
        
        local validEnemies = {}
        local myTeam = player:GetTeamID()
        for _, actor in pairs(allCharacters) do
            if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
                if actor:GetTeamID() ~= myTeam then
                    table.insert(validEnemies, actor)
                end
            end
        end
        _G.GlobalEnemyCache = validEnemies
        _G.GlobalEnemyCacheTime = curTime
    end
    
    -- Bước 2: Duyệt danh sách Cache và lọc khoảng cách Radius (Đảm bảo 100% không vỡ logic của Aim và Recoil)
    local enemies = _G.GlobalEnemyCache or {}
    for _, actor in ipairs(enemies) do
        if slua.isValid(actor) then
            local dist = player:GetDistanceTo(actor)
            if dist <= radius then
                table.insert(result, actor)
            end
        end
    end
    
    return result
end

-- =========================================================================
-- HÀM AIMBOT DÀNH RIÊNG CHO VŨ KHÍ ĐẶC BIỆT (GIỮ NGUYÊN BẢN LOGIC CŨ 100%)
-- =========================================================================
-- =========================================================================
-- HÀM AIMBOT DÀNH RIÊNG CHO VŨ KHÍ ĐẶC BIỆT (GIỮ NGUYÊN BẢN LOGIC CŨ 100%)
-- =========================================================================
_G.AimTouch_SpecialWeapons = function(player, pc, weapon, WEAPON_TYPE, isADS, isFiring, cData, viewportX, centerX, centerY, camLoc, currentRot, camManager, currentTime)
    local cond, prioMode, boneIdx, speedVal, fovVal, maxDistMeters = 2, 1, 1, 50, 30, 50
    local ignoreWall, igKnock, igBot = false, false, false
    local predVal, recoilCompVal = 0, 0

    if WEAPON_TYPE == "MORTAR" then
        if not _G.LexusConfig.AimTouchMortar then return end
        local isPlaced = false
        pcall(function() if weapon and weapon.MortarState == 2 then isPlaced = true end end)
        if not isPlaced then 
            _G.AimTouchLockedSpecial = nil
            return 
        end
        cond, prioMode, boneIdx, speedVal, fovVal, maxDistMeters, ignoreWall = 2, 1, 4, 100, 360, 2000, true
        predVal = cData.AimTouchMortarPred or 0 

    elseif WEAPON_TYPE == "CROSSBOW" then
        if not _G.LexusConfig.AimTouchCrossbow then return end
        cond = cData.AimTouchCrossbowCond or 2
        if cond == 1 and not (isFiring or isADS) then 
            _G.AimTouchLockedSpecial = nil
            return 
        end
        prioMode = cData.AimTouchCrossbowPrio or 1
        boneIdx = cData.AimTouchCrossbowBone or 1
        speedVal = cData.AimTouchCrossbowSpeed or 100 
        fovVal = cData.AimTouchCrossbowFOV or 40
        maxDistMeters = cData.AimTouchCrossbowDist or 150
        predVal = cData.AimTouchCrossbowPred or 0 
        ignoreWall = (cData.AimTouchCrossbowVisCheck == 1)
        igKnock = (cData.AimTouchCrossbowIgKnock == 1)
        igBot = (cData.AimTouchCrossbowIgBot == 1) 

    elseif WEAPON_TYPE == "BOW" then
        if not _G.LexusConfig.AimTouchBow then return end
        cond = cData.AimTouchBowCond or 1
        if cond == 1 and not (isFiring or isADS) then 
            _G.AimTouchLockedSpecial = nil
            return 
        end
        prioMode = 1
        boneIdx = cData.AimTouchBowBone or 1 
        speedVal = cData.AimTouchBowSpeed or 80
        fovVal = cData.AimTouchBowFOV or 40
        maxDistMeters = cData.AimTouchBowDist or 150
        predVal = cData.AimTouchBowPred or 0 
        recoilCompVal = cData.AimTouchBowRecoil or 0 
        ignoreWall = (cData.AimTouchBowVisCheck == 1)
        igKnock = (cData.AimTouchBowIgKnock == 1)
        igBot = (cData.AimTouchBowIgBot == 1) 
    end

    local currentMaxDist = maxDistMeters * 100 
    local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
    if not enemies or #enemies == 0 then 
        _G.AimTouchLockedSpecial = nil 
        return 
    end
    
    local FVector2D = import("Vector2D")
    local KismetMathLibrary = import("KismetMathLibrary")
    local FOV_RADIUS = (fovVal / 100.0) * (viewportX / 2.0)
    
    local bestTarget = nil
    local bestScore = 99999999 
    local selBoneName = "head"
    if boneIdx == 1 then selBoneName = "head"
    elseif boneIdx == 2 then selBoneName = "spine_03"
    elseif boneIdx == 3 then selBoneName = "spine_01"
    elseif boneIdx == 4 then selBoneName = "pelvis" end

    _G.AimTouchLockedSpecial = _G.AimTouchLockedSpecial or nil
    local isLockedTargetValid = false

    for i, target in ipairs(enemies) do
        if not slua.isValid(target) then goto continue end
        if igKnock and target.HealthStatus == 1 then goto continue end
        if igBot then
            local tIsBot = false
            if target.bIsAI == true or target.IsAI == true then tIsBot = true end
            local pState = target.PlayerState
            if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
            if tIsBot then goto continue end
        end
        
        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
        if not tPos then goto continue end
        tPos.Z = tPos.Z + 30 
        
        _G.ReusableScreenVec = _G.ReusableScreenVec or FVector2D()
        local screen = _G.ReusableScreenVec
        local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
        if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
        
        local dx = screen.X - centerX
        local dy = screen.Y - centerY
        local distScreen = math.sqrt(dx*dx + dy*dy)
        
        local currentFovLimit = FOV_RADIUS
        if target == _G.AimTouchLockedSpecial then
            currentFovLimit = FOV_RADIUS * 5.0
        end            
        if distScreen > currentFovLimit then goto continue end
        
        if not ignoreWall then
            local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
            _G.AimTouchVisCache = _G.AimTouchVisCache or {}
            if not _G.AimTouchVisCache[tId] or (currentTime - _G.AimTouchVisCache[tId].time) > 0.3 then
                local isHidden = true
                pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                _G.AimTouchVisCache[tId] = { hidden = isHidden, time = currentTime }
            end
            if _G.AimTouchVisCache[tId].hidden then goto continue end
        end
        
        local currentScore = distScreen
        if prioMode == 2 then currentScore = player:GetDistanceTo(target)
        elseif prioMode == 3 then currentScore = target.Health or 100
        elseif prioMode == 4 then 
            local hp, maxhp = target.Health or 100, target.HealthMax or 100
            if maxhp <= 0 then maxhp = 100 end
            currentScore = hp / maxhp
        end
        
        if target == _G.AimTouchLockedSpecial then
            currentScore = currentScore - 999999 
            isLockedTargetValid = true
        end            

        if currentScore < bestScore then
            bestScore = currentScore
            bestTarget = target
        end
        ::continue::
    end
    
    if not slua.isValid(bestTarget) then 
        _G.AimTouchLockedSpecial = nil 
        return 
    end
    if not isLockedTargetValid then
        _G.AimTouchLockedSpecial = bestTarget
    end   
    
    local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
    if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
        if type(bestTarget.GetSocketLocation) == "function" then
            finalBonePos = bestTarget:GetSocketLocation(selBoneName)
        end
    end
    if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
        if type(bestTarget.K2_GetActorLocation) == "function" then
            finalBonePos = bestTarget:K2_GetActorLocation()
            if finalBonePos then
                if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
            end
        end
    end
    if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
    
    local targetPose = 0
    pcall(function()
        if type(bestTarget.GetPoseState) == "function" then targetPose = bestTarget:GetPoseState()
        elseif bestTarget.PoseState then targetPose = bestTarget.PoseState end
    end)   

    if boneIdx == 1 then
        if targetPose == 2 then
            finalBonePos.Z = finalBonePos.Z + 5
        else
            finalBonePos.Z = finalBonePos.Z + 8  
        end
    elseif boneIdx == 2 or boneIdx == 3 then
        if targetPose == 2 then
            finalBonePos.Z = finalBonePos.Z - 6
        end
    end

    local tVelocity = type(bestTarget.GetVelocity) == "function" and bestTarget:GetVelocity() or nil
    
    local function GetADSOffset(rotLoc)
        local dYaw = rotLoc.Yaw - currentRot.Yaw
        local dPitch = rotLoc.Pitch - currentRot.Pitch
        if isADS then
            local camRot = type(camManager.GetCameraRotation) == "function" and camManager:GetCameraRotation() or nil
            if camRot then
                dYaw = dYaw - (camRot.Yaw - currentRot.Yaw)
                dPitch = dPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end
        if dYaw > 180 then dYaw = dYaw - 360 end
        if dYaw < -180 then dYaw = dYaw + 360 end
        if dPitch > 180 then dPitch = dPitch - 360 end
        if dPitch < -180 then dPitch = dPitch + 360 end
        return dPitch, dYaw
    end

    local smoothFactor = speedVal >= 100 and 1.0 or math.max((speedVal / 100.0) * 0.3, 0.01)
    local finalPitch = currentRot.Pitch
    local finalYaw = currentRot.Yaw

    if WEAPON_TYPE == "MORTAR" then
        local targetPos = { X = finalBonePos.X, Y = finalBonePos.Y, Z = finalBonePos.Z }
        local launchPos = camLoc
        pcall(function()
            if player.K2_GetActorLocation then
                local pLoc = player:K2_GetActorLocation()
                if pLoc then launchPos = { X = pLoc.X, Y = pLoc.Y, Z = pLoc.Z + 50 } end
            end
        end)
        local function CalcMortarTrajectory(V, G, tX, tY, tZ)
            local mDx = math.sqrt((tX - launchPos.X)^2 + (tY - launchPos.Y)^2) - 80 
            if mDx < 500 then mDx = 500 end 
            local mDy = tZ - launchPos.Z                
            local minVSq = G * (mDy + math.sqrt(mDx*mDx + mDy*mDy))
            if (V * V) < minVSq then V = math.sqrt(minVSq) + 100 end
            local v2 = V * V
            local root = v2*v2 - G*(G*mDx*mDx + 2*mDy*v2)                
            if root >= 0 then
                local angleRad = math.atan((v2 + math.sqrt(root)) / (G * mDx))
                local deg = math.deg(angleRad)
                if deg >= 35 and deg <= 89.5 then return true, deg end
            end
            return false, 45
        end
        local okNear, angNear = CalcMortarTrajectory(9070, 980 * 2.8, targetPos.X, targetPos.Y, targetPos.Z)
        local physAngle = okNear and angNear or 45
        local targetCameraPitch = ((physAngle - 45) / 43.0) * 90.0 - 60.0
        
        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, targetPos)
        local deltaPitchMortar = targetCameraPitch - currentRot.Pitch
        local deltaYawMortar = rot.Yaw - currentRot.Yaw
        
        if deltaPitchMortar > 180 then deltaPitchMortar = deltaPitchMortar - 360 end
        if deltaPitchMortar < -180 then deltaPitchMortar = deltaPitchMortar + 360 end
        if deltaYawMortar > 180 then deltaYawMortar = deltaYawMortar - 360 end
        if deltaYawMortar < -180 then deltaYawMortar = deltaYawMortar + 360 end
        
        finalPitch = currentRot.Pitch + (deltaPitchMortar * smoothFactor)
        finalYaw = currentRot.Yaw + (deltaYawMortar * smoothFactor)

    elseif WEAPON_TYPE == "CROSSBOW" then
        local distUU = player:GetDistanceTo(bestTarget) 
        local vMeters = cData.AimTouchCrossbowVel or 160
        local dropScale = 1.0
        if targetPose == 2 then
            dropScale = (cData.AimTouchCrossbowDropProne or 120) / 100.0
        else
            dropScale = (cData.AimTouchCrossbowDrop or 100) / 100.0
        end   

        local vUU = vMeters * 100 
        local ToF = distUU / vUU                                               
        
        if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) and predVal > 0 then
            local predScale = predVal / 50.0
            finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF * predScale)
            finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF * predScale)
        end                
        
        if isADS then
            local gravity = 980 
            local dropAmount = 0.5 * gravity * (ToF * ToF) * dropScale * 1.15
            finalBonePos.Z = finalBonePos.Z + dropAmount
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        local dPitch, dYaw = GetADSOffset(rot)
        finalPitch = currentRot.Pitch + (dPitch * smoothFactor)
        finalYaw = currentRot.Yaw + (dYaw * smoothFactor)

    elseif WEAPON_TYPE == "BOW" then
        local distUU = player:GetDistanceTo(bestTarget)
        local distMeters = distUU / 100.0                
        
        if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) and predVal > 0 then
            local ToF_Pred = (distMeters / 150.0) * (predVal / 50.0)
            finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF_Pred)
            finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF_Pred)
        end
        local dropVal = cData.AimTouchBowDrop or 50
        if dropVal > 0 then
            local ToF_Drop = distUU / 15000.0 
            local dropScale = dropVal / 100.0
            local gravity = 980
            local dropAmount = 0.5 * gravity * (ToF_Drop * ToF_Drop) * dropScale
            finalBonePos.Z = finalBonePos.Z + dropAmount
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        local dPitch, dYaw = GetADSOffset(rot)
        
        finalPitch = currentRot.Pitch + (dPitch * smoothFactor)
        if recoilCompVal > 0 and (isFiring or isADS) then
            finalPitch = finalPitch - ((recoilCompVal / 50.0) * 1.5)
        end
        finalYaw = currentRot.Yaw + (dYaw * smoothFactor)
    end

    local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
    pc:SetControlRotation(finalRot, "AimTouch")
end

-- =========================================================================
-- [TỐI ƯU HÓA AIMBOT V2] - DÀNH CHO SÚNG THƯỜNG (AR, SMG, SG, SNIPER)
-- =========================================================================
_G.__AimTouch_PlayerCacheTime = 0
_G.__AimTouch_ViewportCacheTime = 0
_G.__AimTouch_LastRunTime = 0
local zero_vector = {X = 0, Y = 0, Z = 0}

local function setMeshFlag(mesh)
    pcall(function() mesh.MeshComponentUpdateFlag = 0 end)
end

local function safeLineOfSight(pc, target)
    return pc:LineOfSightTo(target)
end

_G.AimTouch = function()
    pcall(function()
        if not _G.LexusConfig.AimTouchEnable then 
            _G.AimTouchLockedTarget = nil
            return 
        end

        local currentTime = os.clock()
        if (currentTime - _G.__AimTouch_LastRunTime) < 0.005 then return end
        _G.__AimTouch_LastRunTime = currentTime

        -- [FIX CHÍNH]: KHAI BÁO BÊN TRONG HÀM ĐỂ TRÁNH LỖI NIL KHI GAME CHƯA LOAD XONG
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        local FVector2D = import("Vector2D")
        local ui_util = require("client.common.ui_util")
        local math_sqrt = math.sqrt

        -- 1. TỐI ƯU CACHE
        if not _G.__AimTouch_PlayerCacheTime or (currentTime - _G.__AimTouch_PlayerCacheTime) > 0.1 then
            local lp = GameplayData.GetPlayerCharacter()
            if slua.isValid(lp) then
                _G.__AimTouch_CachedPlayer = lp
                _G.__AimTouch_CachedPC = lp:GetPlayerControllerSafety()
                
                local currentWeapon = type(lp.GetCurrentWeapon) == "function" and lp:GetCurrentWeapon() or lp.CurrentWeapon
                if slua.isValid(currentWeapon) then
                    local wID = type(currentWeapon.GetWeaponID) == "function" and currentWeapon:GetWeaponID() or 0
                    local wName = type(currentWeapon.GetWeaponName) == "function" and currentWeapon:GetWeaponName() or ""
                    wName = string.lower(tostring(wName))
                    
                    local wepType = "NORMAL"
                    if wName:find("mortar") or wName:find("cối") then wepType = "MORTAR"
                    elseif wName:find("crossbow") or wName:find("nỏ") or wID == 107001 or wID == 107007 or wID == 107020 then wepType = "CROSSBOW"
                    elseif wID == 107008 or wID == 107009 or (wName:find("bow") and not wName:find("crossbow")) or wName:find("cung") then wepType = "BOW"
                    elseif (wID >= 1030000 and wID < 1040000) or wName:find("s686") or wName:find("s1897") or wName:find("s12") or wName:find("dbs") or wName:find("m1014") then wepType = "SHOTGUN"
                    elseif wName:find("kar98") or wName:find("m24") or wName:find("awm") or wName:find("mosin") or wName:find("win94") or wName:find("amr") or wName:find("sks") or wName:find("slr") or wName:find("mini") or wName:find("mk14") or wName:find("qbu") or wName:find("mk12") or wName:find("vss") then wepType = "SNIPER"
                    end
                    _G.__AimTouch_WeaponType = wepType
                    _G.__AimTouch_CachedWeapon = currentWeapon
                    
                    local currentAmmo = 1
                    if type(currentWeapon.GetCurrentAmmo) == "function" then currentAmmo = currentWeapon:GetCurrentAmmo()
                    elseif currentWeapon.ShootWeaponComponent and type(currentWeapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then currentAmmo = currentWeapon.ShootWeaponComponent:GetCurrentAmmo()
                    elseif currentWeapon.CurrentAmmo ~= nil then currentAmmo = currentWeapon.CurrentAmmo end
                    _G.__AimTouch_CurrentAmmo = currentAmmo
                else
                    _G.__AimTouch_WeaponType = "NORMAL"
                    _G.__AimTouch_CurrentAmmo = 0
                end
            else
                _G.__AimTouch_CachedPlayer = nil
                _G.__AimTouch_CachedPC = nil
            end
            _G.__AimTouch_PlayerCacheTime = currentTime
        end

        local player = _G.__AimTouch_CachedPlayer
        local pc = _G.__AimTouch_CachedPC
        if not slua.isValid(player) or not slua.isValid(pc) then return end

        local WEAPON_TYPE = _G.__AimTouch_WeaponType or "NORMAL"
        local currentAmmo = _G.__AimTouch_CurrentAmmo or 0
        local currentWeapon = _G.__AimTouch_CachedWeapon
        local cData = _G.LexusState.CustomTextData

        if not _G.__AimTouch_ViewportCacheTime or (currentTime - _G.__AimTouch_ViewportCacheTime) > 0.5 then
            local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
            _G.__AimTouch_CachedCamManager = camManager
            local viewportSize = ui_util.GetViewportSize()
            if viewportSize then
                _G.__AimTouch_CenterX = viewportSize.X * 0.5
                _G.__AimTouch_CenterY = viewportSize.Y * 0.5
                _G.__AimTouch_ViewportX = viewportSize.X
            end
            _G.__AimTouch_ViewportCacheTime = currentTime
        end

        local camManager = _G.__AimTouch_CachedCamManager
        if not slua.isValid(camManager) then return end
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end

        local centerX = _G.__AimTouch_CenterX or 0
        local centerY = _G.__AimTouch_CenterY or 0
        local viewportX = _G.__AimTouch_ViewportX or 1920
        if centerX == 0 or centerY == 0 then return end

        local isADS = player.bIsGunADS or false
        local isFiring = player.bIsWeaponFiring or false

        -- [PHÂN NHÁNH LOGIC] Đẩy vũ khí đặc biệt qua hàm riêng biệt
        if WEAPON_TYPE == "MORTAR" or WEAPON_TYPE == "CROSSBOW" or WEAPON_TYPE == "BOW" then
            if _G.AimTouch_SpecialWeapons then
                _G.AimTouch_SpecialWeapons(player, pc, currentWeapon, WEAPON_TYPE, isADS, isFiring, cData, viewportX, centerX, centerY, camLoc, pc:GetControlRotation(), camManager, currentTime)
            end
            return
        end

        -- NHẢ CÒ KHI MẤT MỤC TIÊU HOẶC SHOTGUN HẾT ĐẠN
        if _G.LexusState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.LexusState.IsAutoFiring = false
        end
        if WEAPON_TYPE == "SHOTGUN" and currentAmmo <= 0 then return end

        -- 2. ĐỌC CONFIG THEO VŨ KHÍ TỪ MENU CHO SÚNG THƯỜNG
        local cond, prioMode, boneIdx, speedVal, fovVal, maxDistMeters = 2, 1, 1, 50, 30, 50
        local ignoreWall, igKnock, igBot = false, false, false
        local predVal, recoilCompVal = 0, 0
        local isActive = false

        if WEAPON_TYPE == "SHOTGUN" then
            if _G.LexusConfig.AimTouchSG then
                isActive = true
                cond = cData.AimTouchSGCond or 1
                if _G.LexusConfig.AimTouchSGAutoFire then cond = 2 end
                prioMode = cData.AimTouchSGPrio or 1
                boneIdx = cData.AimTouchSGBone or 2
                speedVal = cData.AimTouchSGSpeed or 80
                fovVal = cData.AimTouchSGFOV or 40
                maxDistMeters = cData.AimTouchSGDist or 30
                ignoreWall = (cData.AimTouchSGVisCheck == 1)
                igKnock = (cData.AimTouchSGIgKnock == 1)
                igBot = (cData.AimTouchSGIgBot == 1)
            end
        elseif isADS then
            if WEAPON_TYPE == "SNIPER" and _G.LexusConfig.AimTouchScoESPniper then
                isActive = true
                cond = cData.AimTouchSniperCond or 2
                prioMode = cData.AimTouchSniperPrio or 1
                boneIdx = cData.AimTouchSniperBone or 1
                speedVal = cData.AimTouchSniperSpeed or 30
                fovVal = cData.AimTouchSniperFOV or 20
                maxDistMeters = cData.AimTouchSniperDist or 400
                ignoreWall = (cData.AimTouchSniperVisCheck == 1)
                igKnock = (cData.AimTouchSniperIgKnock == 1)
                igBot = (cData.AimTouchSniperIgBot == 1)
                predVal = cData.AimTouchSniperPred or 0 
            elseif _G.LexusConfig.AimTouchScopeAll then
                isActive = true
                cond = cData.AimTouchScopeCond or 1
                prioMode = cData.AimTouchScopePrio or 1
                boneIdx = cData.AimTouchScopeBone or 2
                speedVal = cData.AimTouchScoESPpeed or 40
                fovVal = cData.AimTouchScopeFOV or 20
                maxDistMeters = cData.AimTouchScopeDist or 300
                ignoreWall = (cData.AimTouchScopeVisCheck == 1)
                igKnock = (cData.AimTouchScopeIgKnock == 1)
                igBot = (cData.AimTouchScopeIgBot == 1)
                predVal = cData.AimTouchScopePred or 0 
                recoilCompVal = cData.AimTouchScopeRecoil or 0 
            end
        else
            if _G.LexusConfig.AimTouchHipfire then
                isActive = true
                cond = cData.AimTouchHipCond or 1
                prioMode = cData.AimTouchHipPrio or 1
                boneIdx = cData.AimTouchHipBone or 1
                speedVal = cData.AimTouchHipSpeed or 50
                fovVal = cData.AimTouchHipFOV or 30
                maxDistMeters = cData.AimTouchHipDist or 250
                ignoreWall = (cData.AimTouchHipVisCheck == 1)
                igKnock = (cData.AimTouchHipIgKnock == 1)
                igBot = (cData.AimTouchHipIgBot == 1)
            end
        end

        if not isActive then 
            _G.AimTouchLockedTarget = nil
            return 
        end

        -- [FIX BUG AIM SCOPE] ĐIỀU KIỆN CHÍNH XÁC
        if cond == 1 then
            if not isFiring then 
                _G.AimTouchLockedTarget = nil
                return 
            end
        end

        local boneName = "spine_03"
        if boneIdx == 1 then boneName = "head"
        elseif boneIdx == 2 then boneName = "spine_03"
        elseif boneIdx == 3 then boneName = "spine_01"
        elseif boneIdx == 4 then boneName = "pelvis" end

        local fovRadius = (fovVal / 100.0) * (viewportX * 0.5)
        _G.__AimTouch_ReusableScreen = _G.__AimTouch_ReusableScreen or FVector2D()
        local cached_screen = _G.__AimTouch_ReusableScreen

        -- 3. TÌM VÀ KHÓA MỤC TIÊU
        local bestTarget = nil
        local keepCurrentTarget = false
        local currentTarget = _G.AimTouchLockedTarget

        local function GetTargetBoneLocation(target, bName)
            local tPos = target:GetBonePos(bName, zero_vector)
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then tPos = target:GetSocketLocation(bName) end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if bName == "head" then tPos.Z = tPos.Z + 70
                        elseif bName == "spine_03" then tPos.Z = tPos.Z + 40
                        else tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            return tPos
        end

        if slua.isValid(currentTarget) and currentTarget:IsAlive() then
            local isKnocked = igKnock and (currentTarget.HealthStatus == 1 or currentTarget.bIsNearDeath == true)
            local isBot = false
            if not isKnocked and igBot then
                isBot = currentTarget.bIsAI or currentTarget.IsAI or (slua.isValid(currentTarget.PlayerState) and currentTarget.PlayerState.bIsABot)
            end

            if not isKnocked and not isBot then
                local distToTarget = player:GetDistanceTo(currentTarget)
                if distToTarget <= (maxDistMeters * 100) then
                    local tPos = GetTargetBoneLocation(currentTarget, boneName)
                    if tPos then
                        tPos.Z = tPos.Z + 20 
                        if pc:ProjectWorldLocationToScreen(tPos, cached_screen, false) and cached_screen.X > 0 and cached_screen.Y > 0 then
                            local dx = cached_screen.X - centerX
                            local dy = cached_screen.Y - centerY
                            local distScreen = math_sqrt(dx*dx + dy*dy)
                            
                            if distScreen <= fovRadius then
                                local isVisible = true
                                if not ignoreWall then
                                    local tId = type(currentTarget.GetUniqueID) == "function" and currentTarget:GetUniqueID() or tostring(currentTarget)
                                    _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                                    local cache = _G.AimTouchVisCache[tId]
                                    if not cache or (currentTime - cache.time) > 0.2 then
                                        local status, isLineOfSight = pcall(safeLineOfSight, pc, currentTarget)
                                        cache = { hidden = not (status and isLineOfSight), time = currentTime }
                                        _G.AimTouchVisCache[tId] = cache
                                    end
                                    isVisible = not cache.hidden
                                end

                                if isVisible then
                                    keepCurrentTarget = true
                                    bestTarget = currentTarget
                                end
                            end
                        end
                    end
                end
            end
        end

        if not keepCurrentTarget then
            local enemies = _G.GetEnemyTargetsFromActors(maxDistMeters * 100)
            if enemies and #enemies > 0 then
                local bestScore = 99999999
                local enemyCount = #enemies
                
                for i = 1, enemyCount do
                    local target = enemies[i]
                    if slua.isValid(target) and target ~= currentTarget then
                        if slua.isValid(target.Mesh) and not target.__MeshFlagFixed then
                            setMeshFlag(target.Mesh)
                            target.__MeshFlagFixed = true
                        end

                        local isKnocked = igKnock and (target.HealthStatus == 1 or target.bIsNearDeath == true)
                        local isBot = false
                        if not isKnocked and igBot then
                            isBot = target.bIsAI or target.IsAI or (slua.isValid(target.PlayerState) and target.PlayerState.bIsABot)
                        end

                        if not isKnocked and not isBot then
                            local tPos = GetTargetBoneLocation(target, boneName)
                            if tPos then
                                tPos.Z = tPos.Z + 20
                                if pc:ProjectWorldLocationToScreen(tPos, cached_screen, false) and cached_screen.X > 0 and cached_screen.Y > 0 then
                                    local dx = cached_screen.X - centerX
                                    local dy = cached_screen.Y - centerY
                                    local distScreen = math_sqrt(dx*dx + dy*dy)
                                    
                                    if distScreen <= fovRadius then
                                        local isVisible = true
                                        if not ignoreWall then
                                            local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                                            _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                                            local cache = _G.AimTouchVisCache[tId]
                                            if not cache or (currentTime - cache.time) > 0.2 then
                                                local status, isLineOfSight = pcall(safeLineOfSight, pc, target)
                                                cache = { hidden = not (status and isLineOfSight), time = currentTime }
                                                _G.AimTouchVisCache[tId] = cache
                                            end
                                            isVisible = not cache.hidden
                                        end
                                        
                                        if isVisible then
                                            local score
                                            if prioMode == 1 then score = distScreen
                                            elseif prioMode == 2 then score = player:GetDistanceTo(target)
                                            elseif prioMode == 3 then score = target.Health or 100
                                            elseif prioMode == 4 then
                                                local hp = target.Health or 100
                                                local maxhp = target.HealthMax or 100
                                                if maxhp <= 0 then maxhp = 100 end
                                                score = hp / maxhp
                                            else score = distScreen end
                                            
                                            if score < bestScore then 
                                                bestScore = score
                                                bestTarget = target 
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        _G.AimTouchLockedTarget = bestTarget

        if not slua.isValid(bestTarget) then
            if WEAPON_TYPE == "SHOTGUN" and _G.LexusConfig.AimTouchSGAutoFire and _G.LexusState.IsAutoFiring then 
                pcall(function()
                    player.bIsWeaponFiring = false
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
                end)
                _G.LexusState.IsAutoFiring = false
            end
            return
        end

        local finalPos = GetTargetBoneLocation(bestTarget, boneName)
        if not finalPos then return end

        local tVelocity = type(bestTarget.GetVelocity) == "function" and bestTarget:GetVelocity() or nil
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end

        -- SÚNG THƯỜNG (AR, SMG, SNIPER, SHOTGUN) TÍNH TOÁN DỰ ĐOÁN
        if predVal > 0 and tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
            local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
            local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
            finalPos.X = finalPos.X + (tVelocity.X * ToF)
            finalPos.Y = finalPos.Y + (tVelocity.Y * ToF)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalPos)
        local dPitch, dYaw = rot.Pitch - currentRot.Pitch, rot.Yaw - currentRot.Yaw

        if isADS then
            local camRot = type(camManager.GetCameraRotation) == "function" and camManager:GetCameraRotation() or nil
            if camRot then
                dYaw = dYaw - (camRot.Yaw - currentRot.Yaw)
                dPitch = dPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if dPitch > 180 then dPitch = dPitch - 360 elseif dPitch < -180 then dPitch = dPitch + 360 end
        if dYaw > 180 then dYaw = dYaw - 360 elseif dYaw < -180 then dYaw = dYaw + 360 end
        
        -- =========================================================================
        -- [FIX VIP - ĐỘ NHẠY/DÍNH AIMBOT]
        -- Điều chỉnh hệ số nhân lên 0.615 (Giúp Aim bám dính hơn ~1% so với 0.6 cũ)
        -- Tốc độ 70 sẽ có lực kéo ~ 43%
        -- =========================================================================
        local smoothFactor = 1.0
        if speedVal < 100 then
            smoothFactor = math.max((speedVal / 100.0) * 0.615, 0.02)
        end
        
        local finalPitch = currentRot.Pitch + (dPitch * smoothFactor)
        
        -- Cân bằng lại Recoil cho mượt khớp với tốc độ kéo
        if recoilCompVal > 0 and isFiring then
            local recoilPower = (recoilCompVal / 50.0) * 1.5
            finalPitch = finalPitch - (recoilPower * (0.8 + (smoothFactor * 0.2)))
        end
        local finalYaw = currentRot.Yaw + (dYaw * smoothFactor)
        -- =========================================================================

        -- GÁN GÓC QUAY VÀ XỬ LÝ SHOTGUN AUTO FIRE
        pc:SetControlRotation({ Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }, "AimTouch")

        if WEAPON_TYPE == "SHOTGUN" and _G.LexusConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = type(player.GetCurrentWeapon) == "function" and player:GetCurrentWeapon() or player.CurrentWeapon
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.LexusState.IsAutoFiring = true
                end
            end)
        end

    end)
end

local C_AR      = {R = 255, G = 255, B = 0, A = 255}
local C_SMG     = {R = 255, G = 255, B = 0, A = 255}
local C_Sniper  = {R = 255, G = 255, B = 0, A = 255}
local C_Shotgun = {R = 255, G = 255, B = 0, A = 255}
local C_LMG     = {R = 255, G = 255, B = 0, A = 255}
local C_Pistol  = {R = 255, G = 255, B = 0, A = 255}
local C_FlareGun = {R = 255, G = 50, B = 50, A = 255}
local C_Special = {R = 255, G = 255, B = 0, A = 255}
local C_Melee   = {R = 255, G = 255, B = 0, A = 255}
local C_Scope   = {R = 0, G = 255, B = 255, A = 255}
local C_Grenade = {R = 0, G = 255, B = 255, A = 255}
local C_Helmet  = {R = 255, G = 150, B = 255, A = 255} 
local C_Bag     = {R = 150, G = 255, B = 150, A = 255} 
local C_Armor   = {R = 255, G = 165, B = 0, A = 255}  
local C_Coin    = {R = 255, G = 215, B = 0, A = 255}  
local C_Heal    = {R = 0, G = 255, B = 100, A = 255}   
local C_Attach  = {R = 173, G = 216, B = 230, A = 255} 

local C_FlareGun = {R = 255, G = 50, B = 50, A = 255} -- Màu đỏ tươi cho súng pháo

local ItemDatabase = {
    -- AR
    [101001] = { name = "AKM", cat = "AR", color = C_AR }, [101002] = { name = "M16A4", cat = "AR", color = C_AR },
    [101003] = { name = "SCAR-L", cat = "AR", color = C_AR }, [101004] = { name = "M416", cat = "AR", color = C_AR },
    [101005] = { name = "GROZA", cat = "AR", color = C_AR }, [101006] = { name = "AUG", cat = "AR", color = C_AR },
    [101007] = { name = "QBZ", cat = "AR", color = C_AR }, [101008] = { name = "M762", cat = "AR", color = C_AR },
    [101009] = { name = "MK47 MUTANT", cat = "AR", color = C_AR }, [101010] = { name = "G36C", cat = "AR", color = C_AR },
    [101011] = { name = "AC-VAL", cat = "AR", color = C_AR }, [101012] = { name = "HONEY BADGER", cat = "AR", color = C_AR },
    [101100] = { name = "FAMAS", cat = "AR", color = C_AR }, [101101] = { name = "ASM ABAKAN AR", cat = "AR", color = C_AR },
    [101102] = { name = "ACE32", cat = "AR", color = C_AR },
    -- SMG
    [102001] = { name = "UZI", cat = "SMG", color = C_SMG }, [102002] = { name = "UMP45", cat = "SMG", color = C_SMG },
    [102003] = { name = "VECTOR", cat = "SMG", color = C_SMG }, [102004] = { name = "THOMPSON SMG", cat = "SMG", color = C_SMG },
    [102005] = { name = "PP-19 BIZON", cat = "SMG", color = C_SMG }, [102007] = { name = "MP5K", cat = "SMG", color = C_SMG },
    [102008] = { name = "JS9", cat = "SMG", color = C_SMG }, [102105] = { name = "P90", cat = "SMG", color = C_SMG },
    [103001] = { name = "KAR98K", cat = "Sniper", color = C_Sniper }, [103002] = { name = "M24", cat = "Sniper", color = C_Sniper },
    [103003] = { name = "AWM", cat = "Sniper", color = C_Sniper }, [103004] = { name = "SKS", cat = "Sniper", color = C_Sniper },
    [103005] = { name = "VSS", cat = "Sniper", color = C_Sniper }, [103006] = { name = "MINI14", cat = "Sniper", color = C_Sniper },
    [103007] = { name = "MK14", cat = "Sniper", color = C_Sniper }, [103008] = { name = "WIN94", cat = "Sniper", color = C_Sniper },
    [103009] = { name = "SLR", cat = "Sniper", color = C_Sniper }, [103010] = { name = "QBU", cat = "Sniper", color = C_Sniper },
    [103011] = { name = "MOSIN NAGANT", cat = "Sniper", color = C_Sniper }, [103012] = { name = "AMR", cat = "Sniper", color = C_Sniper },
    [103100] = { name = "MK12", cat = "Sniper", color = C_Sniper }, [103101] = { name = "TR-2A AIR GUN", cat = "Sniper", color = C_Sniper },
    [103102] = { name = "DSR", cat = "Sniper", color = C_Sniper }, [103103] = { name = "SNIPER RIFLE", cat = "Sniper", color = C_Sniper },
    [103104] = { name = "SNIPER RIFLE", cat = "Sniper", color = C_Sniper }, [103105] = { name = "SR", cat = "Sniper", color = C_Sniper },
    [104001] = { name = "S686", cat = "Shotgun", color = C_Shotgun }, [104002] = { name = "S1897", cat = "Shotgun", color = C_Shotgun },
    [104003] = { name = "S12K", cat = "Shotgun", color = C_Shotgun }, [104004] = { name = "DBS", cat = "Shotgun", color = C_Shotgun },
    [104100] = { name = "SPAS-12", cat = "Shotgun", color = C_Shotgun }, [104101] = { name = "M1014", cat = "Shotgun", color = C_Shotgun },
    [104102] = { name = "NS2000", cat = "Shotgun", color = C_Shotgun },
    [105001] = { name = "M249", cat = "LMG", color = C_LMG }, [105002] = { name = "DP-28", cat = "LMG", color = C_LMG },
    [105003] = { name = "M134", cat = "LMG", color = C_LMG }, [105010] = { name = "MG3", cat = "LMG", color = C_LMG },
    [105101] = { name = "GATLING", cat = "LMG", color = C_LMG }, [105115] = { name = "LIB GATLING MG", cat = "LMG", color = C_LMG },
    [105004] = { name = "FLAMETHROWER", cat = "LMG", color = C_LMG }, [105006] = { name = "M2 FIXED MG", cat = "LMG", color = C_LMG },
    [105007] = { name = "GATLING FIXED MG", cat = "LMG", color = C_LMG }, [105008] = { name = "MOUNTED FLAMETHROWER", cat = "LMG", color = C_LMG },
    [105009] = { name = "M2 MOUNTED MG", cat = "LMG", color = C_LMG }, [105102] = { name = "VEHICLE SG", cat = "LMG", color = C_LMG },
    [105103] = { name = "RPG", cat = "LMG", color = C_LMG }, [105104] = { name = "RPG", cat = "LMG", color = C_LMG },
    [105105] = { name = "POWPOW MG", cat = "LMG", color = C_LMG }, [105106] = { name = "TANK CANNON", cat = "LMG", color = C_LMG },
    [105107] = { name = "TANK MG", cat = "LMG", color = C_LMG }, [105108] = { name = "TANK FLARE GUN", cat = "LMG", color = C_LMG },
    [105116] = { name = "LIB AUTOCANNON", cat = "LMG", color = C_LMG }, [105117] = { name = "JET MISSILE", cat = "LMG", color = C_LMG },
    [105118] = { name = "JET AUTOCANNON", cat = "LMG", color = C_LMG },
    [106001] = { name = "P92", cat = "Pistol", color = C_Pistol }, [106002] = { name = "P1911", cat = "Pistol", color = C_Pistol },
    [106003] = { name = "R1895", cat = "Pistol", color = C_Pistol }, [106004] = { name = "P18C", cat = "Pistol", color = C_Pistol },
    [106005] = { name = "R45", cat = "Pistol", color = C_Pistol }, [106006] = { name = "SAWED-OFF", cat = "Pistol", color = C_Pistol },
    [106008] = { name = "SKORPION", cat = "Pistol", color = C_Pistol }, [106010] = { name = "DESERT EAGLE", cat = "Pistol", color = C_Pistol },
    [106007] = { name = "SÚNG PHÁO (FLARE GUN)", cat = "FlareGun", color = C_FlareGun }, [106009] = { name = "SÚNG PHÁO (FLARE GUN)", cat = "FlareGun", color = C_FlareGun },
    [106011] = { name = "DUAL MP7", cat = "Pistol", color = C_Pistol }, [106012] = { name = "WELDING GUN", cat = "Pistol", color = C_Pistol },
    [106013] = { name = "STUN GUN", cat = "Pistol", color = C_Pistol }, [106101] = { name = "PHÁO GỌI XE", cat = "FlareGun", color = C_FlareGun },
    [106103] = { name = "SÚNG PHÁO (FLARE GUN)", cat = "FlareGun", color = C_FlareGun }, [106106] = { name = "PHÁO RỖNG (HẾT ĐẠN)", cat = "FlareGun", color = C_FlareGun },
    [106107] = { name = "PHÁO GỌI ĐỒNG ĐỘI", cat = "FlareGun", color = C_FlareGun }, [106203] = { name = "MAGNET GUN", cat = "Pistol", color = C_Pistol },
    [107011] = { name = "SÚNG CỐI (MORTAR)", cat = "Special", color = C_Special },
    [107001] = { name = "NỎ (CROSSBOW)", cat = "Special", color = C_Special }, [107002] = { name = "RPG-7", cat = "Special", color = C_Special },
    [107003] = { name = "RIOT SHIELD", cat = "Special", color = C_Special }, [107004] = { name = "COMBAT DRONE", cat = "Special", color = C_Special },
    [107005] = { name = "PANZERFAUST", cat = "Special", color = C_Special }, [107006] = { name = "RPG-7", cat = "Special", color = C_Special },
    [107007] = { name = "TACTICAL CROSSBOW", cat = "Special", color = C_Special }, [107008] = { name = "CUNG NỔ(EX BOW)", cat = "Special", color = C_Special },
    [107009] = { name = "CUNG NỔ(EX BOW)", cat = "Special", color = C_Special }, [107010] = { name = "M79 SMOKE LAUNCHER", cat = "Special", color = C_Special },
    [107019] = { name = "ATLAS GAUNTLET", cat = "Special", color = C_Special }, [107020] = { name = "EXPLOSIVE CROSSBOW", cat = "Special", color = C_Special },
    [107021] = { name = "MERCURY HAMMER", cat = "Special", color = C_Special }, [107022] = { name = "FISHBONES ROCKET", cat = "Special", color = C_Special },
    [107031] = { name = "SUMMER GRENADE LAUNCHER", cat = "Special", color = C_Special }, [107032] = { name = "SUMMER BAZOOKA", cat = "Special", color = C_Special },
    [107033] = { name = "SUMMER MG", cat = "Special", color = C_Special }, [107034] = { name = "COLOR BAZOOKA", cat = "Special", color = C_Special },
    [107035] = { name = "BUBBLE MG", cat = "Special", color = C_Special }, [107036] = { name = "SNOWBALL BLASTER", cat = "Special", color = C_Special },
    [107037] = { name = "WATER ORB BLASTER", cat = "Special", color = C_Special }, [107092] = { name = "MGL", cat = "Special", color = C_Special },
    [107093] = { name = "M202 QUAD RPG", cat = "Special", color = C_Special }, [107094] = { name = "AT4-A LASER MISSILE", cat = "Special", color = C_Special },
    [107095] = { name = "M202 QUAD RPG", cat = "Special", color = C_Special }, [107096] = { name = "M79 SAWED-OFF", cat = "Special", color = C_Special },
    [107097] = { name = "M79", cat = "Special", color = C_Special }, [107098] = { name = "MGL", cat = "Special", color = C_Special },
    [107099] = { name = "M3E1-A", cat = "Special", color = C_Special }, [107901] = { name = "ZOMBIE PIERCER", cat = "Special", color = C_Special },
    [107903] = { name = "MOUNTED RPG", cat = "Special", color = C_Special }, [107904] = { name = "HELICOPTER RPG", cat = "Special", color = C_Special },
    [107911] = { name = "M3E1-B MISSILE", cat = "Special", color = C_Special },
    [108001] = { name = "MACHETE", cat = "Melee", color = C_Melee }, [108002] = { name = "CROWBAR", cat = "Melee", color = C_Melee },
    [108003] = { name = "SICKLE", cat = "Melee", color = C_Melee }, [108004] = { name = "PAN", cat = "Melee", color = C_Melee },
    [108005] = { name = "DAGGER", cat = "Melee", color = C_Melee }, [108006] = { name = "MUTATION BLADE", cat = "Melee", color = C_Melee },
    [108007] = { name = "MUTATION GAUNTLETS", cat = "Melee", color = C_Melee },
    [203001] = { name = "RED DOT SIGHT", cat = "Scope", color = C_Scope }, [203002] = { name = "HOLOGRAPHIC SIGHT", cat = "Scope", color = C_Scope },
    [203003] = { name = "2X SCOPE", cat = "Scope", color = C_Scope }, [203004] = { name = "4X SCOPE", cat = "Scope", color = C_Scope },
    [203005] = { name = "8X SCOPE", cat = "Scope", color = C_Scope }, [203014] = { name = "3X SCOPE", cat = "Scope", color = C_Scope },
    [203015] = { name = "6X SCOPE", cat = "Scope", color = C_Scope },
    [602001] = { name = "LỰU CHOÁNG(STUN NADE)", cat = "Grenade", color = C_Grenade }, [602002] = { name = "LỰU KHÓI(SMOKE)", cat = "Grenade", color = C_Grenade },
    [602003] = { name = "BOM XĂNG(MOLOTOV)", cat = "Grenade", color = C_Grenade }, [602004] = { name = "BOM NỔ(NADE)", cat = "Grenade", color = C_Grenade },
    [502001] = { name = "MŨ LV1", cat = "Helmet", color = C_Helmet }, 
    [502002] = { name = "MŨ LV2", cat = "Helmet", color = C_Helmet }, 
    [502003] = { name = "MŨ LV3", cat = "Helmet", color = C_Helmet }, 
    [501001] = { name = "BA LÔ LV1", cat = "Bag", color = C_Bag }, 
    [501002] = { name = "BA LÔ LV2", cat = "Bag", color = C_Bag }, 
    [501003] = { name = "BA LÔ LV3", cat = "Bag", color = C_Bag }, 
    [503001] = { name = "GIÁP LV1", cat = "Armor", color = C_Armor }, 
    [503002] = { name = "GIÁP LV2", cat = "Armor", color = C_Armor }, 
    [503003] = { name = "GIÁP LV3", cat = "Armor", color = C_Armor },
    [3000324] = { name = "XU CỬA HÀNG", cat = "Coin", color = C_Coin },
    [3000328] = { name = "XU CỬA HÀNG", cat = "Coin", color = C_Coin },
    [601001] = { name = "NƯỚC TĂNG LỰC", cat = "Heal", color = C_Heal },
    [601002] = { name = "ADRENALINE", cat = "Heal", color = C_Heal },
    [601003] = { name = "GIẢM ĐAU", cat = "Heal", color = C_Heal },
    [601004] = { name = "BĂNG GẠC", cat = "Heal", color = C_Heal },
    [601005] = { name = "BỘ SƠ CỨU", cat = "Heal", color = C_Heal },
    [601006] = { name = "CỨU THƯƠNG", cat = "Heal", color = C_Heal },
    [201002] = { name = "HÃM GIẬT (SMG)", cat = "Attach", color = C_Attach },
    [201003] = { name = "HÃM GIẬT (SR)", cat = "Attach", color = C_Attach },
    [201004] = { name = "ẨN TIA LỬA (SMG)", cat = "Attach", color = C_Attach },
    [201005] = { name = "ẨN TIA LỬA (SR)", cat = "Attach", color = C_Attach },
    [201006] = { name = "GIẢM THANH (SMG/LỤC)", cat = "Attach", color = C_Attach },
    [201007] = { name = "GIẢM THANH (SR)", cat = "Attach", color = C_Attach },
    [201008] = { name = "GIẢM THANH (LỤC)", cat = "Attach", color = C_Attach },
    [201009] = { name = "HÃM GIẬT (AR)", cat = "Attach", color = C_Attach },
    [201010] = { name = "ẨN TIA LỬA (AR)", cat = "Attach", color = C_Attach },
    [201011] = { name = "GIẢM THANH (AR)", cat = "Attach", color = C_Attach },
    [201012] = { name = "MỎ VỊT (SG)", cat = "Attach", color = C_Attach },
    [201050] = { name = "NÒNG MR (SMG)", cat = "Attach", color = C_Attach },
    [201051] = { name = "NÒNG MR (AR)", cat = "Attach", color = C_Attach },
    [201052] = { name = "HÃM GIẬT (SR)", cat = "Attach", color = C_Attach },
    [201053] = { name = "HÃM GIẬT (AR)", cat = "Attach", color = C_Attach },
    [201054] = { name = "HÃM GIẬT (SMG)", cat = "Attach", color = C_Attach },
    [201055] = { name = "NÒNG MR (SR)", cat = "Attach", color = C_Attach },
    [201101] = { name = "ĐC ĐẦU NÒNG", cat = "Attach", color = C_Attach },
    [201102] = { name = "ĐC ĐẦU NÒNG", cat = "Attach", color = C_Attach },
    [201103] = { name = "ĐC ĐẦU NÒNG", cat = "Attach", color = C_Attach },
    [202001] = { name = "TAY CẦM TAM GIÁC", cat = "Attach", color = C_Attach },
    [202002] = { name = "TAY CẦM ĐỨNG", cat = "Attach", color = C_Attach },
    [202004] = { name = "TAY CẦM NHẸ", cat = "Attach", color = C_Attach },
    [202005] = { name = "TAY CẦM NỬA", cat = "Attach", color = C_Attach },
    [202006] = { name = "TAY CẦM NGÓN CÁI", cat = "Attach", color = C_Attach },
    [202007] = { name = "ỐNG NGẮM LASER", cat = "Attach", color = C_Attach },
    [202051] = { name = "TAY CẦM C.T.HỌC", cat = "Attach", color = C_Attach }
}

_G.CachedItems = {}
_G.LastScanItemTime = 0
_G.AppliedVehicleWall = {}
_G.AppliedItemESP = {}

_G.RunOptimizedItemAndVehicleESP = function(pc)
    local curTime = _os_clock()

    if curTime - _G.LastScanItemTime > 1.0 then
        _G.LastScanItemTime = curTime
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        if _G.LexusConfig.WallVehicle then
            local ASTExtraVehicleBase = import("STExtraVehicleBase")
            if ASTExtraVehicleBase then
                local Actors = Game:GetActorsByClass(ASTExtraVehicleBase)
                if Actors then
                    local count = Actors:Num() or 0
                    for i = 0, count - 1 do
                        local vehicle = Actors:Get(i)
                        if slua.isValid(vehicle) and vehicle.GetMesh then
                            local dist = player:GetDistanceTo(vehicle)
                            if dist <= 200000 then 
                                local vId = _tostring(vehicle)
                                if not _G.AppliedVehicleWall[vId] then
                                    local mesh = vehicle:GetMesh()
                                    if slua.isValid(mesh) then
                                        local matInterface = mesh:GetMaterial(0)
                                        if slua.isValid(matInterface) then
                                            local baseMat = matInterface:GetBaseMaterial()
                                            if slua.isValid(baseMat) then
                                                baseMat.bDisableDepthTest = true
                                                baseMat.BlendMode = 2
                                                _G.AppliedVehicleWall[vId] = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else _G.AppliedVehicleWall = {} end

        if _G.LexusConfig.EspItem_Master then
            local APickUpWrapperActor = import("PickUpWrapperActor") or import("STPickupWrapperActor")
            if APickUpWrapperActor then
                local Actors = Game:GetActorsByClass(APickUpWrapperActor)
                _G.CachedItems = {}
                if Actors then
                    local count = Actors:Num() or 0
                    for i = 0, count - 1 do
                        local item = Actors:Get(i)
                        -- Thêm check bHidden ngay lúc quét để tối ưu
                        if slua.isValid(item) and not item.bHidden and not item.bPendingKill then
                            local dist = player:GetDistanceTo(item)
                            if dist <= 7000 then
                                local itemId = item.DefineID and item.DefineID.TypeSpecificID or item.DefineId
                                local itemData = ItemDatabase[itemId]
                                
                                if itemData then
                                    local isShow = false
                                    if itemData.cat == "AR" and _G.LexusConfig.EspItem_AR then isShow = true
                                    elseif itemData.cat == "Sniper" and _G.LexusConfig.EspItem_Sniper then isShow = true
                                    elseif itemData.cat == "SMG" and _G.LexusConfig.EspItem_SMG then isShow = true
                                    elseif itemData.cat == "Shotgun" and _G.LexusConfig.EspItem_Shotgun then isShow = true
                                    elseif itemData.cat == "LMG" and _G.LexusConfig.EspItem_LMG then isShow = true
                                    elseif itemData.cat == "Pistol" and _G.LexusConfig.EspItem_Pistol then isShow = true
                                    elseif itemData.cat == "FlareGun" and _G.LexusConfig.EspItem_FlareGun then isShow = true -- ĐÃ THÊM LOGIC FLARE GUN
                                    elseif itemData.cat == "Melee" and _G.LexusConfig.EspItem_Melee then isShow = true
                                    elseif itemData.cat == "Special" and _G.LexusConfig.EspItem_Special then isShow = true
                                    elseif itemData.cat == "Grenade" and _G.LexusConfig.EspItem_Grenade then isShow = true
                                    elseif itemData.cat == "Scope" and _G.LexusConfig.EspItem_Scope then isShow = true
                                    elseif itemData.cat == "Helmet" and _G.LexusConfig.EspItem_Helmet then isShow = true
                                    elseif itemData.cat == "Bag" and _G.LexusConfig.EspItem_Bag then isShow = true
                                    elseif itemData.cat == "Armor" and _G.LexusConfig.EspItem_Armor then isShow = true
                                    elseif itemData.cat == "Coin" and _G.LexusConfig.EspItem_Coin then isShow = true
                                    elseif itemData.cat == "Heal" and _G.LexusConfig.EspItem_Heal then isShow = true
                                    elseif itemData.cat == "Attach" and _G.LexusConfig.EspItem_Attach then isShow = true
                                    end

                                    if isShow then
                                        _table_insert(_G.CachedItems, item)

                                        local iId = _tostring(item)
                                        if not _G.AppliedItemESP[iId] then
                                            local meshes = {}
                                            if item.GetPickupMesh then
                                                local pMesh = item:GetPickupMesh()
                                                if slua.isValid(pMesh) then _table_insert(meshes, pMesh) end
                                            end
                                            local childs = item:GetComponentsByClass(import("StaticMeshComponent"))
                                            if childs then
                                                for _, v in _pairs(childs) do
                                                    if slua.isValid(v) then _table_insert(meshes, v) end
                                                end
                                            end
                                            for _, mesh in _pairs(meshes) do
                                                _pcall(function() mesh:SetRenderCustomDepth(true) end)
                                                for mi = 0, 8 do
                                                    local mid = mesh:CreateAndSetMaterialInstanceDynamic(mi)
                                                    if slua.isValid(mid) then
                                                        local colorVisible = {R = 50, G = 50, B = 0, A = 10}
                                                        _pcall(function()
                                                            mid:SetVectorParameterValue("LightColor", colorVisible)
                                                            mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                                                            mid:SetScalarParameterValue("RimLight", 999)
                                                            mid:SetScalarParameterValue("Brightness", 999)
                                                            mid:SetScalarParameterValue("Exposure", 999)
                                                        end)
                                                    end
                                                end
                                            end
                                            _G.AppliedItemESP[iId] = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else 
            _G.AppliedItemESP = {}
            _G.CachedItems = {}
        end
    end

    if _G.LexusConfig.EspItem_Master and slua.isValid(pc) and pc.MyHUD then
        local hud = pc.MyHUD
        local player = GameplayData.GetPlayerCharacter()
        for _, item in _ipairs(_G.CachedItems) do
            -- SỬA Ở ĐÂY: Thêm check not item.bHidden và not item.bPendingKill
            -- Để khi nhặt đồ (game ẩn đồ đi), nó sẽ mất text ngay lập tức
            if slua.isValid(item) and not item.bHidden and not item.bPendingKill then
                local itemId = item.DefineID and item.DefineID.TypeSpecificID or item.DefineId
                if itemId and ItemDatabase[itemId] then
                    local itemData = ItemDatabase[itemId]
                    local dist = (player.GetDistanceTo and player:GetDistanceTo(item) or 0) / 100
                    local displayText = _string_format("%s [%.0fm]", itemData.name, dist)
                    local textColor = {R = itemData.color.R, G = itemData.color.G, B = itemData.color.B, A = 255}
                    hud:AddDebugText(
                        displayText, item, 0.06, 
                        ZERO_VECTOR3, ZERO_VECTOR3, 
                        textColor, true, false, true, nil, 0.8, true
                    )
                end
            end
        end
    end
end

local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"

_G.EnemyCounterWidget = nil
_G.IsCreatingCounterWidget = false 
_G.CounterWidgetSessionKey = nil 

-- BIẾN CHO KHUNG CẢNH BÁO RIÊNG
_G.WarningCounterWidget = nil
_G.IsCreatingWarningWidget = false

-- 1. HÀM DỌN DẸP
function _G.CleanUpEnemyCounterWidget()
    if _G.EnemyCounterWidget and slua.isValid(_G.EnemyCounterWidget) then
        pcall(function() _G.EnemyCounterWidget:RemoveFromParent() end)
    end
    _G.EnemyCounterWidget = nil

    if _G.WarningCounterWidget and slua.isValid(_G.WarningCounterWidget) then
        pcall(function() _G.WarningCounterWidget:RemoveFromParent() end)
    end
    _G.WarningCounterWidget = nil
end

-- 2. HÀM TẠO KHUNG ĐẾM ĐỊCH CHÍNH (ÉP KHÍT CHIỀU NGANG & DỌC)
local function CreateEnemyCounterWidget()
    if _G.EnemyCounterWidget then
        if slua.isValid(_G.EnemyCounterWidget) then return _G.EnemyCounterWidget end
        _G.EnemyCounterWidget = nil
    end

    if _G.IsCreatingCounterWidget then return nil end
    _G.IsCreatingCounterWidget = true

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        
        pcall(function()
            local hud = require("game_frontend_hud")
            if hud and hud.AddToContainer and UIContainers then
                hud.AddToContainer(UIContainers.Top, btn, 10500)
            end
        end)
        
        pcall(function()
            if btn.Image_Normal then btn.Image_Normal:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
            if btn.Image_Bg then btn.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
            if btn.Image_Down then btn.Image_Down:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
        end)
        
        if btn.RichText_Content then
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then
                fontInfo.Size = 15 -- Chỉnh size chữ vừa vặn khung nhỏ
                fontInfo.TypefaceFontName = "Bold"
                btn.RichText_Content:SetFont(fontInfo)
            end
        end
        
        -- BÓP KHUNG ĐẾM ĐỊCH (PHÂN BIỆT) SIÊU KHÍT
        pcall(function()
            local WLL = import("WidgetLayoutLibrary")
            local slot = WLL and WLL.SlotAsCanvasSlot and WLL.SlotAsCanvasSlot(btn)
            if slot then
                slot:SetAnchors({Minimum={X=0.5,Y=0},Maximum={X=0.5,Y=0}})
                slot:SetAlignment({X=0.5,Y=0})
                slot:SetPosition({X=0,Y=55}) -- Giữ nguyên vị trí Y
                
                -- Chiều ngang bóp từ 400 xuống 320, Chiều cao bóp từ 36 xuống 30
                slot:SetSize({X=320,Y=30}) 
            end
        end)
        
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        _G.EnemyCounterWidget = btn
    end)
    
    _G.IsCreatingCounterWidget = false 
    return _G.EnemyCounterWidget
end

-- 3. HÀM TẠO KHUNG CẢNH BÁO (ÉP KHÍT & NỐI SÁT VỚI KHUNG TRÊN)
local function CreateWarningCounterWidget()
    if _G.WarningCounterWidget then
        if slua.isValid(_G.WarningCounterWidget) then return _G.WarningCounterWidget end
        _G.WarningCounterWidget = nil
    end

    if _G.IsCreatingWarningWidget then return nil end
    _G.IsCreatingWarningWidget = true

    pcall(function()
        local widget = slua.loadUI(BTN_BP)
        if not widget or not slua.isValid(widget) then return end
        
        pcall(function()
            local hud = require("game_frontend_hud")
            if hud and hud.AddToContainer and UIContainers then
                hud.AddToContainer(UIContainers.Top, widget, 10501)
            end
        end)
        
        if widget.RichText_Content then
            local fontInfo = widget.RichText_Content.Font
            if fontInfo then
                fontInfo.Size = 14 -- Size chữ cảnh báo
                fontInfo.TypefaceFontName = "Bold"
                widget.RichText_Content:SetFont(fontInfo)
            end
        end
        
        -- BÓP KHUNG CẢNH BÁO VÀ GẮN SÁT VÀO KHUNG TRÊN
        pcall(function()
            local WLL = import("WidgetLayoutLibrary")
            local slot = WLL and WLL.SlotAsCanvasSlot and WLL.SlotAsCanvasSlot(widget)
            if slot then
                slot:SetAnchors({Minimum={X=0.5,Y=0},Maximum={X=0.5,Y=0}})
                slot:SetAlignment({X=0.5,Y=0})
                
                -- Đẩy Y lên 86 (55 + 30 + 1 px viền) để 2 khung dính liền vào nhau
                slot:SetPosition({X=0,Y=86}) 
                
                -- Bóp ngang xuống 340 (Vừa khít chữ), chiều cao 30
                slot:SetSize({X=330,Y=30}) 
            end
        end)
        
        widget:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
        _G.WarningCounterWidget = widget
    end)
    
    _G.IsCreatingWarningWidget = false 
    return _G.WarningCounterWidget
end

-- 4. HÀM QUÉT VÀ VẼ LÊN MÀN HÌNH
local function _M_DrawCounter()
    if not _G.LexusConfig.EspThongTinLoai2 or isExpired then
        _G.CleanUpEnemyCounterWidget()
        return
    end

    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        
        if not slua.isValid(player) then 
            _G.CleanUpEnemyCounterWidget()
            _G.CounterWidgetSessionKey = nil
            return 
        end

        local currentSession = tostring(player.PlayerKey or player)
        if _G.CounterWidgetSessionKey ~= currentSession then
            _G.CounterWidgetSessionKey = currentSession
            _G.CleanUpEnemyCounterWidget()
        end

        local widget = CreateEnemyCounterWidget()
        if not widget or not slua.isValid(widget) then return end
        widget:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)

        local curTime = os.clock()
        if not _G.LastCounterTime then _G.LastCounterTime = 0 end
        
        if (curTime - _G.LastCounterTime) > 0.5 then
            _G.LastCounterTime = curTime
            
            local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
            local realCount = 0
            local botCount = 0
            local nearest = 400
            local aimingCount = 0

            local allCharacters = {}
            if GameplayData.GetAllPlayerCharacters then
                allCharacters = GameplayData.GetAllPlayerCharacters()
            elseif GameplayData.GameCharacters then
                for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
            end

            for _, tPawn in pairs(allCharacters) do
                if slua.isValid(tPawn) and tPawn ~= player then
                    local isAlive = false
                    if tPawn.HealthStatus ~= nil then
                        isAlive = (tPawn.HealthStatus ~= 2) 
                    else
                        isAlive = (tPawn.Health or 0) > 0 or (type(tPawn.IsAlive) == "function" and tPawn:IsAlive())
                    end
                    
                    if isAlive then
                        local tTeam = tPawn.TeamID or (type(tPawn.GetTeamID) == "function" and tPawn:GetTeamID()) or 0
                        if tTeam ~= myTeam then
                            
                            local eKey = GetSafeEnemyKey(tPawn)
                            _G.LexusState.EnemyMarks = _G.LexusState.EnemyMarks or {}
                            _G.LexusState.EnemyMarks[eKey] = _G.LexusState.EnemyMarks[eKey] or {}
                            local markData = _G.LexusState.EnemyMarks[eKey]

                            local isBot = false
                            if markData.Counter_IsBot ~= nil then
                                isBot = markData.Counter_IsBot
                            else
                                pcall(function()
                                    -- Bê nguyên 100% bộ Code Check gốc của bạn vào đây
                                    if Game and type(Game.IsAI) == "function" and Game:IsAI(tPawn) then isBot = true; return end
                                    local ctrl = type(tPawn.GetController) == "function" and tPawn:GetController() or tPawn.Controller
                                    if slua.isValid(ctrl) then
                                        if Game and type(Game.IsAIController) == "function" and Game:IsAIController(ctrl) then isBot = true; return end
                                        if type(ctrl.IsA) == "function" then
                                            local AIControllerClass = import("AIController") or import("/Script/AIModule.AIController")
                                            if AIControllerClass and ctrl:IsA(AIControllerClass) then isBot = true; return end
                                        end
                                    end
                                    if tPawn.MonsterSyncID ~= nil or tPawn.MobAttributeFeature ~= nil then isBot = true; return end 
                                    if tPawn.FakePlayerAttributeFeature ~= nil then isBot = true; return end
                                    local pState = tPawn.PlayerState or (type(tPawn.GetPlayerState) == "function" and tPawn:GetPlayerState())
                                    if slua.isValid(pState) then
                                        if pState.bIsABot == true or pState.bIsBot == true then isBot = true; return end
                                        if type(pState.IsBot) == "function" and pState:IsBot() then isBot = true; return end
                                        if pState.TeammateTakeOverFeature and pState.TeammateTakeOverFeature.bAITakeOver == true then isBot = true; return end
                                    end
                                    if tPawn.bIsAI == true or tPawn.IsAI == true then isBot = true; return end
                                    if type(tPawn.IsBot) == "function" and tPawn:IsBot() then isBot = true; return end
                                    local name = tPawn.PlayerName or (type(tPawn.GetPlayerName) == "function" and tPawn:GetPlayerName()) or ""
                                    local nameLower = string.lower(name)
                                    if nameLower ~= "" and (string.find(nameLower, "cobra") or string.find(nameLower, "target") or string.find(nameLower, "b_")) then
                                        isBot = true; return
                                    end
                                end)
                                markData.Counter_IsBot = isBot
                            end

                            if isBot then botCount = botCount + 1 else realCount = realCount + 1 end

                            local d = math.floor(player:GetDistanceTo(tPawn) / 100)
                            if d < nearest then nearest = d end

                            -- Quét góc nhìn cảnh báo
                            if _G.LexusConfig.CanhBaoDichNhin then
                                pcall(function()
                                    local myLoc = player:K2_GetActorLocation()
                                    local enemyLoc = tPawn:K2_GetActorLocation()
                                    
                                    local enemyFwd = nil
                                    if type(tPawn.GetActorForwardVector) == "function" then
                                        enemyFwd = tPawn:GetActorForwardVector()
                                    end
                                    if not enemyFwd and type(tPawn.K2_GetActorRotation) == "function" then
                                        local rot = tPawn:K2_GetActorRotation()
                                        if rot then
                                            local pitch = math.rad(rot.Pitch or 0)
                                            local yaw = math.rad(rot.Yaw or 0)
                                            enemyFwd = { X = math.cos(pitch) * math.cos(yaw), Y = math.cos(pitch) * math.sin(yaw), Z = math.sin(pitch) }
                                        end
                                    end

                                    if myLoc and enemyLoc and enemyFwd then
                                        local dirX = myLoc.X - enemyLoc.X
                                        local dirY = myLoc.Y - enemyLoc.Y
                                        local dirZ = myLoc.Z - enemyLoc.Z
                                        local dist = math.sqrt(dirX*dirX + dirY*dirY + dirZ*dirZ)
                                        
                                        if dist > 0 then
                                            dirX, dirY, dirZ = dirX/dist, dirY/dist, dirZ/dist
                                            local dot = (dirX * enemyFwd.X) + (dirY * enemyFwd.Y) + (dirZ * enemyFwd.Z)
                                            if dot > 0.95 then
                                                aimingCount = aimingCount + 1
                                            end
                                        end
                                    end
                                end)
                            end
                            
                        end
                    end
                end
            end

            -- CẬP NHẬT CHỮ KHUNG 1 (TRÊN NỀN VÀNG ĐÃ BÓP KHÍT)
            local total = realCount + botCount
            local displayText = string.format("(NGƯỜI: %d) (BOT: %d) (GẦN NHẤT: %dm)", realCount, botCount, total > 0 and nearest or 0)

            if widget.RichText_Content then
                widget.RichText_Content:SetText(displayText)
                local txtColor = {R=0, G=0, B=0, A=255} 
                if realCount > 0 then txtColor = {R=220, G=0, B=0, A=255} 
                elseif botCount > 0 then txtColor = {R=0, G=50, B=200, A=255} end
                
                pcall(function()
                    local LinearColorClass = import("LinearColor") or _G.FLinearColor
                    if LinearColorClass and widget.RichText_Content.SetColorAndOpacity then
                        widget.RichText_Content:SetColorAndOpacity(LinearColorClass(txtColor.R/255, txtColor.G/255, txtColor.B/255, 1.0))
                    end
                end)
            end

            -- CẬP NHẬT CHỮ KHUNG 2 (CẢNH BÁO BÓP KHÍT)
            if _G.LexusConfig.CanhBaoDichNhin and aimingCount > 0 then
                local warningWidget = CreateWarningCounterWidget()
                if warningWidget and slua.isValid(warningWidget) then
                    warningWidget:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
                    
                    if warningWidget.RichText_Content then
                        warningWidget.RichText_Content:SetText(string.format("[!] CẢNH BÁO (%d ĐỊCH) ĐANG NGẮM BẠN [!]", aimingCount))
                        
                        -- Set chữ màu đỏ tươi
                        pcall(function()
                            local LinearColorClass = import("LinearColor") or _G.FLinearColor
                            if LinearColorClass and warningWidget.RichText_Content.SetColorAndOpacity then
                                warningWidget.RichText_Content:SetColorAndOpacity(LinearColorClass(1.0, 0.0, 0.0, 1.0))
                            end
                        end)
                    end
                end
            else
                if _G.WarningCounterWidget and slua.isValid(_G.WarningCounterWidget) then
                    _G.WarningCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
            end

        end
    end)
end

local FLinearColorClass = nil
local HP_COLOR_GREEN, HP_COLOR_YELLOW, HP_COLOR_RED = nil, nil, nil
_pcall(function() 
    FLinearColorClass = import("LinearColor") or _G.FLinearColor 
    if FLinearColorClass then
        HP_COLOR_GREEN = FLinearColorClass(0, 1, 0, 1)
        HP_COLOR_YELLOW = FLinearColorClass(1, 1, 0, 1)
        HP_COLOR_RED = FLinearColorClass(1, 0, 0, 1)
    end
end)
local PlayerMapMarker = {}
local RedBoxOverlay = {
    bActive = false, MainContainer = nil, WidgetSlot = nil, TextBlock = nil,
    Width = 300, Height = 28, OffsetY = 10, PlayerCount = 0, BotCount = 0,
    FontSize = 16, TextScaleValue = 1.1, NumLayers = 50,
    Red = 0.65, Green = 0, Blue = 0, LayerAlpha = 0.038,
    _CachedText = "", _CachedPosVec = nil
}


function RedBoxOverlay.Create()
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return true end
    local ParentCanvas = PlayerMapMarker.ESPCanvas
    if not ParentCanvas or not slua.isValid(ParentCanvas) then 
        if not PlayerMapMarker.InitESPCanvas() then return false end
        ParentCanvas = PlayerMapMarker.ESPCanvas
    end
    if not ParentCanvas or not slua.isValid(ParentCanvas) then return false end

    local Container = nil
    _pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
    if not Container or not slua.isValid(Container) then return false end

    local color = {R = RedBoxOverlay.Red, G = RedBoxOverlay.Green, B = RedBoxOverlay.Blue, A = RedBoxOverlay.LayerAlpha}

    for i = 1, RedBoxOverlay.NumLayers do
        local layerWidth = ((i / RedBoxOverlay.NumLayers) ^ 1.15) * RedBoxOverlay.Width
        local layerX = (RedBoxOverlay.Width - layerWidth) / 2.0
        local border = nil
        _pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
        if border and slua.isValid(border) then
            _pcall(function()
                border:SetBrushColor(color)
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                slot:SetPosition({X=layerX, Y=0})
                slot:SetSize({X=layerWidth, Y=RedBoxOverlay.Height})
            end
        end
    end

    local txtWidget = nil
    _pcall(function() txtWidget = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
    if txtWidget and slua.isValid(txtWidget) then
        _pcall(function()
            local strText = _string_format("Player: %d   Bot: %d", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount)
            txtWidget:SetText(strText)
            RedBoxOverlay._CachedText = strText
            local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
            local whiteLinear = {R=1, G=1, B=1, A=1}
            if FSlateColor then txtWidget:SetColorAndOpacity(FSlateColor(whiteLinear)) else txtWidget:SetColorAndOpacity(whiteLinear) end
            if txtWidget.Font then
                local font = txtWidget.Font
                font.Size = RedBoxOverlay.FontSize
                txtWidget.Font = font
            end
            txtWidget:SetRenderScale({X=RedBoxOverlay.TextScaleValue, Y=RedBoxOverlay.TextScaleValue})
            txtWidget:SetRenderTransformPivot({X=0.5, Y=0.5})
            txtWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local txtSlot = Container:AddChildToCanvas(txtWidget)
        if txtSlot then
            _pcall(function()
                txtSlot:SetAutoSize(true)
                txtSlot:SetAlignment({X=0.5, Y=0.5})
                txtSlot:SetPosition({X=RedBoxOverlay.Width * 0.5, Y=RedBoxOverlay.Height * 0.5})
                txtSlot:SetZOrder(1000)
            end)
        end
        RedBoxOverlay.TextBlock = txtWidget
    end

    local MainSlot = nil
    _pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
    if not MainSlot then return false end
    RedBoxOverlay.MainContainer = Container
    RedBoxOverlay.WidgetSlot = MainSlot
    
    _pcall(function()
        MainSlot:SetAutoSize(false)
        MainSlot:SetZOrder(999)
        MainSlot:SetAlignment({X=0.5, Y=0.0})
        MainSlot:SetSize({X=RedBoxOverlay.Width, Y=RedBoxOverlay.Height})
    end)
    RedBoxOverlay.UpdatePosition()
    return true
end

function RedBoxOverlay.SetCounts(players, bots)
    if RedBoxOverlay.PlayerCount == players and RedBoxOverlay.BotCount == bots then return end
    RedBoxOverlay.PlayerCount = players or 0
    RedBoxOverlay.BotCount = bots or 0
    if RedBoxOverlay.TextBlock and slua.isValid(RedBoxOverlay.TextBlock) then
        _pcall(function()
            local strText = _string_format("Player: %d   Bot: %d", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount)
            if RedBoxOverlay._CachedText ~= strText then
                RedBoxOverlay.TextBlock:SetText(strText)
                RedBoxOverlay._CachedText = strText
            end
        end)
    end
end

function RedBoxOverlay.UpdatePosition()
    local Slot = RedBoxOverlay.WidgetSlot
    if not Slot or not slua.isValid(Slot) then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not slua.isValid(PC) then return end

    local fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    local offsetX = -50
    local offsetY = -20  

    _pcall(function()
        if not RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec = {X = fromX + offsetX, Y = fromY + offsetY}
        else
            RedBoxOverlay._CachedPosVec.X = fromX + offsetX
            RedBoxOverlay._CachedPosVec.Y = fromY + offsetY
        end
        Slot:SetPosition(RedBoxOverlay._CachedPosVec)
    end)
end

function RedBoxOverlay.Start()
    if RedBoxOverlay.bActive and RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return end
    if RedBoxOverlay.Create() then
        RedBoxOverlay.bActive = true
        _pcall(function() RedBoxOverlay.MainContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
end

function RedBoxOverlay.Stop()
    RedBoxOverlay.bActive = false
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then
        _pcall(function()
            RedBoxOverlay.MainContainer:RemoveFromParent()
            RedBoxOverlay.MainContainer:ConditionalBeginDestroy()
        end)
    end
    RedBoxOverlay.MainContainer = nil
    RedBoxOverlay.WidgetSlot = nil
    RedBoxOverlay.TextBlock = nil
    RedBoxOverlay._CachedPosVec = nil
end

_G.RedBoxOverlay = RedBoxOverlay

local SlateBlueprintLibrary, WidgetLayoutLibrary = nil, nil
_pcall(function() SlateBlueprintLibrary = import("SlateBlueprintLibrary") or import("/Script/UMG.SlateBlueprintLibrary") end)
_pcall(function() WidgetLayoutLibrary = import("WidgetLayoutLibrary") or import("/Script/UMG.WidgetLayoutLibrary") end)

PlayerMapMarker.bUseScreenESP = true
PlayerMapMarker.ESPBoneName = "head"
PlayerMapMarker.ESPWorldOffsetZ = 0
PlayerMapMarker.ESPAnchorOffsetX = 50
PlayerMapMarker.ESPAnchorOffsetY = 0
PlayerMapMarker.ESPWidgetAlignment = {X=0.5, Y=1.0}
PlayerMapMarker.ESPWidgetSize = {X=100, Y=30}
PlayerMapMarker.bShowDistance = true
PlayerMapMarker.bUseSnapLines = true
PlayerMapMarker.SnapLineThickness = 1.5
PlayerMapMarker.SnapLineOriginY = 50
PlayerMapMarker.SnapLineOpacity = 0.7
PlayerMapMarker.bIncludeMe = false
PlayerMapMarker.bIncludeAI = true
PlayerMapMarker.bActive = false
PlayerMapMarker.ESPWidgets = {}
PlayerMapMarker.ESPWidgetPtrs = {}
PlayerMapMarker.SnapLineWidgets = {}
PlayerMapMarker.WidgetPool = {}
PlayerMapMarker.SnapLinePool = {}
PlayerMapMarker._cachedViewportW = 1920
PlayerMapMarker._cachedViewportH = 1080

local function ValidSafe(obj)
    if obj == nil then return false end
    if slua and slua.isValid then return slua.isValid(obj) end
    return obj ~= nil
end

function PlayerMapMarker.GetGameplayData()
    if PlayerMapMarker._CachedGameplayData then return PlayerMapMarker._CachedGameplayData end
    local ok, GDP = _pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and GDP then PlayerMapMarker._CachedGameplayData = GDP; return GDP end
    return nil
end

function PlayerMapMarker.GetMyPlayerController()
    local PC = PlayerMapMarker._CachedPC
    if PC and ValidSafe(PC) then return PC end
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    _pcall(function() PC = GDP.GetPlayerController and GDP.GetPlayerController() end)
    if PC and ValidSafe(PC) then PlayerMapMarker._CachedPC = PC; return PC end
    return nil
end

function PlayerMapMarker.GetCGameState()
    if CGameState and ValidSafe(CGameState) then return CGameState end
    local ok, GS = _pcall(require, "GameLua.GameCore.Data.CGameState")
    if ok and GS then return GS end
    return nil
end

function PlayerMapMarker.GetAllCharacters()
    local AllChars = {}
    _pcall(function()
        local Pawns = Game:GetAllPlayerPawns()
        if Pawns then
            for _, Pawn in _pairs(Pawns) do
                if Pawn and slua.isValid(Pawn) then
                    local pKey = Pawn.GetPlayerKey and Pawn:GetPlayerKey() or Pawn.PlayerKey
                    if not pKey and Pawn.PlayerState then pKey = Pawn.PlayerState.PlayerKey end
                    if pKey then AllChars[pKey] = Pawn end
                end
            end
        end
    end)
    if not next(AllChars) then
        local GS = PlayerMapMarker.GetCGameState()
        if GS and GS.GetAllCharacters then _pcall(function() AllChars = GS:GetAllCharacters() end) end
    end
    return AllChars
end

function PlayerMapMarker.GetMyPlayerKey()
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not ValidSafe(PC) then return nil end
    local MyKey = nil
    _pcall(function() MyKey = PC.GetPlayerKey and PC:GetPlayerKey() or (PC.PlayerState and PC.PlayerState.PlayerKey) end)
    return MyKey
end

function PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
    local bIsMe = false
    _pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then
            local MyChar = GDP.GetLocalCharacter()
            if MyChar and Character == MyChar then bIsMe = true; return end
        end
        local PC = PlayerMapMarker.GetMyPlayerController()
        if PC and PC.GetPawn then
            local Pawn = PC:GetPawn()
            if Pawn and Character == Pawn then bIsMe = true; return end
        end
    end)
    if not bIsMe and MyKey ~= nil and PlayerKey ~= nil then bIsMe = (_tostring(PlayerKey) == _tostring(MyKey)) end
    return bIsMe
end

function PlayerMapMarker.GetCharacterLocation(Character)
    if not ValidSafe(Character) then return nil end
    local Loc = nil
    _pcall(function() if Character.K2_GetActorLocation then Loc = Character:K2_GetActorLocation() end end)
    return Loc
end

function PlayerMapMarker.CalcDistance(Loc1, Loc2)
    if not Loc1 or not Loc2 then return nil end
    local Dist = nil
    _pcall(function() if FVector and FVector.Dist2D then Dist = FVector.Dist2D(Loc1, Loc2) end end)
    if not Dist then
        local DX = (Loc1.X or 0) - (Loc2.X or 0)
        local DY = (Loc1.Y or 0) - (Loc2.Y or 0)
        Dist = _math_sqrt(DX * DX + DY * DY)
    end
    return Dist
end

function PlayerMapMarker.GetDistanceString(MyLoc, TargetLoc)
    if not PlayerMapMarker.bShowDistance or not MyLoc or not TargetLoc then return "" end
    local Dist = PlayerMapMarker.CalcDistance(MyLoc, TargetLoc)
    if not Dist then return "" end
    local Meters = Dist / 100
    if Meters < 1000 then return _string_format("%dm", _math_floor(Meters)) else return _string_format("%.1fkm", Meters / 1000) end
end

function PlayerMapMarker.GetMyLocation()
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    local MyChar = nil
    _pcall(function() MyChar = GDP.GetLocalCharacter and GDP.GetLocalCharacter() end)
    if not ValidSafe(MyChar) then
        local PC = PlayerMapMarker.GetMyPlayerController()
        if ValidSafe(PC) then
            _pcall(function()
                if PC.GetPawn then
                    local Pawn = PC:GetPawn()
                    if ValidSafe(Pawn) and Pawn.K2_GetActorLocation then return Pawn:K2_GetActorLocation() end
                end
            end)
        end
        return nil
    end
    return PlayerMapMarker.GetCharacterLocation(MyChar)
end

function PlayerMapMarker.GetPlayerName(Character)
    if not ValidSafe(Character) then return "Unknown" end
    local Name = nil
    _pcall(function() if Character.GetPlayerNameSafety then Name = Character:GetPlayerNameSafety() end end)
    if not Name then
        _pcall(function()
            local PS = Character.GetPlayerStateSafety and Character:GetPlayerStateSafety() or Character.GetPlayerState and Character:GetPlayerState()
            if ValidSafe(PS) and PS.GetPlayerName then Name = PS:GetPlayerName() end
        end)
    end
    return Name or "Unknown"
end

function PlayerMapMarker.IsAI(Character)
    local bAI = false
    _pcall(function() if Game and Game.IsAI then bAI = Game:IsAI(Character) end end)
    return bAI
end

function PlayerMapMarker.IsAlive(Character)
    local bAlive = true
    _pcall(function() if Character.IsAlive then bAlive = Character:IsAlive() end end)
    return bAlive
end

function PlayerMapMarker.IsOurESPWidget(w)
    if not w or not slua.isValid(w) then return false end
    if _G.FovCircleOverlay and w == _G.FovCircleOverlay.Container then return false end
    
    local bIsOurs = false
    _pcall(function()
        local wstr = _tostring(w)
        for KeyStr, ESPData in _pairs(PlayerMapMarker.ESPWidgets) do
            if ESPData and ESPData.Widget and ESPData.Widget.Container then
                if _tostring(ESPData.Widget.Container) == wstr then bIsOurs = true; return end
            end
        end
    end)
    if bIsOurs then return true end
    _pcall(function()
        if w.GetChildrenCount then
            for i = 0, w:GetChildrenCount() - 1 do
                local child = w:GetChildAt(i)
                if child and slua.isValid(child) and _string_find(_tostring(child), "Border") then bIsOurs = true; break end
            end
        end
    end)
    return bIsOurs
end

function PlayerMapMarker.InitESPCanvas()
    if PlayerMapMarker.ESPCanvas then
        local valid = false
        _pcall(function() valid = Game:IsValid(PlayerMapMarker.ESPCanvas) and slua.isValid(PlayerMapMarker.ESPCanvas) end)
        if valid then return true end
        PlayerMapMarker.ESPCanvas = nil
    end

    local InGameUITools = nil
    _pcall(function() InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools") end)
    if not InGameUITools then return false end
    local MainControlBaseUI = nil
    _pcall(function() MainControlBaseUI = InGameUITools.GetMainControlBaseUI() end)
    if not MainControlBaseUI or not Game:IsValid(MainControlBaseUI) then return false end

    local ParentCanvas = nil
    _pcall(function()
        if MainControlBaseUI.CanvasPanel_0 and Game:IsValid(MainControlBaseUI.CanvasPanel_0) then ParentCanvas = MainControlBaseUI.CanvasPanel_0
        elseif MainControlBaseUI.CanvasPanel_42 and Game:IsValid(MainControlBaseUI.CanvasPanel_42) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    end)
    if not ParentCanvas then return false end
    
    PlayerMapMarker.ESPCanvas = ParentCanvas
    _pcall(function()
        for i = ParentCanvas:GetChildrenCount() - 1, 0, -1 do
            local child = ParentCanvas:GetChildAt(i)
            if child and slua.isValid(child) and PlayerMapMarker.IsOurESPWidget(child) then _pcall(function() ParentCanvas:RemoveChild(child) end) end
        end
    end)
    return true
end

function PlayerMapMarker.GetTeamID(Character)
    if not ValidSafe(Character) then return nil end
    local TeamID = nil
    _pcall(function() if Character.GetTeamID then TeamID = Character:GetTeamID() end end)
    if not TeamID then
        _pcall(function()
            local PS = Character.GetPlayerStateSafety and Character:GetPlayerStateSafety() or Character.GetPlayerState and Character:GetPlayerState()
            if ValidSafe(PS) then TeamID = PS.GetTeamID and PS:GetTeamID() or PS.TeamID end
        end)
    end
    if not TeamID then _pcall(function() TeamID = Character.TeamID end) end
    return TeamID
end

local _TeamColorsCache = {}
function PlayerMapMarker.GetTeamColor(TeamID)
    if TeamID == nil then return nil end
    if _TeamColorsCache[TeamID] then return _TeamColorsCache[TeamID] end
    local TeamColors = {
        [1] = {R=1.0, G=0.2, B=0.2, A=1.0}, [2] = {R=0.2, G=0.4, B=1.0, A=1.0},
        [3] = {R=0.2, G=0.9, B=0.3, A=1.0}, [4] = {R=1.0, G=0.9, B=0.2, A=1.0},
        [5] = {R=0.8, G=0.3, B=1.0, A=1.0}, [6] = {R=0.2, G=0.9, B=0.9, A=1.0},
        [7] = {R=1.0, G=0.5, B=0.2, A=1.0}, [8] = {R=1.0, G=0.4, B=0.7, A=1.0},
    }
    _TeamColorsCache[TeamID] = TeamColors[TeamID] or {R=0.2, G=0.4, B=1.0, A=1.0}
    return _TeamColorsCache[TeamID]
end

function PlayerMapMarker._GetWidgetRoot(WidgetObj)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    local Root = nil
    _pcall(function() if WidgetObj.GetRootWidget then Root = WidgetObj:GetRootWidget() end end)
    if Root and slua.isValid(Root) then return Root end
    _pcall(function() if WidgetObj.WidgetTree and WidgetObj.WidgetTree.RootWidget then Root = WidgetObj.WidgetTree.RootWidget end end)
    if Root and slua.isValid(Root) then return Root end
    _pcall(function() if WidgetObj.RootWidget and slua.isValid(WidgetObj.RootWidget) then Root = WidgetObj.RootWidget end end)
    return Root
end

function PlayerMapMarker._FindNamedWidgetInTree(WidgetObj, TargetName, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    MaxDepth = MaxDepth or 8
    local wname = nil
    _pcall(function() if WidgetObj.GetName then wname = WidgetObj:GetName() end end)
    if wname and wname == TargetName then return WidgetObj end
    local wstr = _tostring(WidgetObj)
    if wstr and _string_find(wstr, TargetName, 1, true) then
        if wname and wname == TargetName then return WidgetObj
        elseif not wname or wname == "" then
            local _, endPos = _string_find(wstr, TargetName, 1, true)
            if endPos then
                local nextChar = _string_sub(wstr, endPos + 1, endPos + 1)
                if nextChar ~= "_" and nextChar ~= "" then return WidgetObj end
            end
        end
    end
    local nChildren = 0
    _pcall(function() if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end end)
    if nChildren > 0 then
        for i = 0, nChildren - 1 do
            local child = nil
            _pcall(function() child = WidgetObj:GetChildAt(i) end)
            if child and slua.isValid(child) then
                local found = PlayerMapMarker._FindNamedWidgetInTree(child, TargetName, MaxDepth - 1)
                if found then return found end
            end
        end
    else
        local Root = PlayerMapMarker._GetWidgetRoot(WidgetObj)
        if Root and slua.isValid(Root) and Root ~= WidgetObj then
            local found = PlayerMapMarker._FindNamedWidgetInTree(Root, TargetName, MaxDepth - 1)
            if found then return found end
        end
    end
    return nil
end

local _WhiteTexture = nil
local _bWhiteTextureFailed = false
local function GetWhiteTexture()
    if _WhiteTexture then return _WhiteTexture end
    if _bWhiteTextureFailed then return nil end
    _pcall(function()
        local paths = {"/Game/BluePrints/UI/Textures/White.White", "/Engine/EngineResources/WhiteSquareTexture.WhiteSquareTexture"}
        for _, path in _ipairs(paths) do
            _pcall(function() local tex = import(path); if tex and slua.isValid(tex) then _WhiteTexture = tex; return end end)
            if _WhiteTexture then break end
        end
    end)
    if not _WhiteTexture then _bWhiteTextureFailed = true end
    return _WhiteTexture
end

local function SetImageColor(Image, color)
    if not Image or not slua.isValid(Image) then return false end
    local bOK = false
    _pcall(function() if Image.SetBrushTintColor then Image:SetBrushTintColor(color); bOK = true end end)
    _pcall(function() if Image.SetColorAndOpacity then Image:SetColorAndOpacity(color); bOK = true end end)
    _pcall(function()
        if Image.SetBrushFromTexture then
            local whiteTex = GetWhiteTexture()
            if whiteTex then
                Image:SetBrushFromTexture(whiteTex, false)
                if Image.SetColorAndOpacity then Image:SetColorAndOpacity(color) end
                bOK = true
            end
        end
    end)
    _pcall(function() Image:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible); Image:SetRenderOpacity(1.0) end)
    return bOK
end

function PlayerMapMarker.ApplyTeamColor(WidgetData, TeamID)
    if not WidgetData or not WidgetData.Container then return end
    local color = PlayerMapMarker.GetTeamColor(TeamID)
    if not color then return end
    _pcall(function()
        local W = WidgetData.Container
        if not W or not slua.isValid(W) then return end
        
        if not WidgetData._CachedTeamBGs then
            WidgetData._CachedTeamBGs = {
                TeamBG = PlayerMapMarker._FindNamedWidgetInTree(W, "Image_TeamBG", 8),
                TeamLogoBG = PlayerMapMarker._FindNamedWidgetInTree(W, "Image_TeamLogoBG", 8)
            }
        end

        local bgCache = WidgetData._CachedTeamBGs
        if bgCache.TeamBG and slua.isValid(bgCache.TeamBG) then SetImageColor(bgCache.TeamBG, color) end
        if bgCache.TeamLogoBG and slua.isValid(bgCache.TeamLogoBG) then SetImageColor(bgCache.TeamLogoBG, color) end
        
        if W.SetTeamColor then _pcall(function() W:SetTeamColor(TeamID) end) end
    end)
end

function PlayerMapMarker.GetESPLocation(Character)
    if not ValidSafe(Character) then return nil end
    local BoneLoc = PlayerMapMarker.GetCharacterLocation(Character)
    if BoneLoc then
        local heightOffset = 85
        _pcall(function() if Character.bIsCrouched then heightOffset = 60 end; if Character.IsProne and Character:IsProne() then heightOffset = 30 end end)
        BoneLoc.Z = BoneLoc.Z + heightOffset + (PlayerMapMarker.ESPWorldOffsetZ or 0)
    end
    return BoneLoc
end

function PlayerMapMarker.GetCharacterWeaponInfo(Character)
    if not ValidSafe(Character) then return nil end
    local WeaponID, WeaponName, WeaponIconPath, WeaponIconTexture, CurrentWeapon = nil, nil, nil, nil, nil
    _pcall(function() if Character.GetCurrentWeapon then CurrentWeapon = Character:GetCurrentWeapon() end end)
    if not CurrentWeapon then _pcall(function() CurrentWeapon = Character.CurrentWeapon end) end
    if not CurrentWeapon then
        _pcall(function() if Character.GetWeaponManager then local WM = Character:GetWeaponManager(); if WM and WM.GetCurrentWeapon then CurrentWeapon = WM:GetCurrentWeapon() end end end)
    end
    if CurrentWeapon and ValidSafe(CurrentWeapon) then
        _pcall(function() if CurrentWeapon.GetWeaponID then WeaponID = CurrentWeapon:GetWeaponID() end end)
        if not WeaponID then _pcall(function() WeaponID = CurrentWeapon.WeaponID end) end
        if not WeaponID then _pcall(function() if CurrentWeapon.GetItemID then WeaponID = CurrentWeapon:GetItemID() end end) end
        
        _pcall(function() if CurrentWeapon.GetWeaponName then WeaponName = CurrentWeapon:GetWeaponName() end end)
        _pcall(function() if CurrentWeapon.GetWeaponIconPath then WeaponIconPath = CurrentWeapon:GetWeaponIconPath() end end)
        _pcall(function() if CurrentWeapon.GetWeaponIcon then WeaponIconTexture = CurrentWeapon:GetWeaponIcon() end end)
    end

    if not WeaponID then
        _pcall(function()
            local PS = Character.GetPlayerStateSafety and Character:GetPlayerStateSafety() or Character.GetPlayerState and Character:GetPlayerState()
            if ValidSafe(PS) then
                if PS.GetCurrentWeaponID then WeaponID = PS:GetCurrentWeaponID() end
                if not WeaponID and PS.CurWeaponID then WeaponID = PS.CurWeaponID end
            end
        end)
    end
    return { WeaponID = WeaponID, WeaponName = WeaponName, WeaponIconPath = WeaponIconPath, WeaponIconTexture = WeaponIconTexture, CurrentWeapon = CurrentWeapon }
end

function PlayerMapMarker.FindWeaponIconInWidget(WidgetObj, Depth, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    Depth = Depth or 0; MaxDepth = MaxDepth or 8
    local propNames = {"Image_Weapon", "Image_WeaponIcon", "Image_Gun", "Image_Icon", "WeaponIcon", "WeaponImage", "WeaponIconImage", "Image_Equip", "Image_WeaponIcon_2"}
    for _, pname in _ipairs(propNames) do
        _pcall(function()
            local prop = WidgetObj[pname]
            if prop and slua.isValid(prop) then
                local hasBrush = false
                _pcall(function() if prop.Brush then hasBrush = true end end)
                if hasBrush then return prop end
            end
        end)
    end
    if Depth >= MaxDepth then return nil end
    local nChildren = 0
    _pcall(function() if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end end)
    for i = 0, _math_max(nChildren - 1, 0) do
        local child = nil
        _pcall(function() child = WidgetObj:GetChildAt(i) end)
        if child and slua.isValid(child) then
            local result = PlayerMapMarker.FindWeaponIconInWidget(child, Depth + 1, MaxDepth)
            if result then return result end
        end
    end
    if nChildren == 0 then
        local Root = PlayerMapMarker._GetWidgetRoot(WidgetObj)
        if Root and slua.isValid(Root) and Root ~= WidgetObj then
            local result = PlayerMapMarker.FindWeaponIconInWidget(Root, Depth + 1, MaxDepth)
            if result then return result end
        end
    end
    return nil
end

function PlayerMapMarker.FixWeaponIconBrushSize(ImageWidget, DefaultW, DefaultH)
    if not ImageWidget or not slua.isValid(ImageWidget) then return end
    DefaultW = DefaultW or 138; DefaultH = DefaultH or 69
    _pcall(function()
        local brush = ImageWidget.Brush
        if brush then
            brush.ImageSize = {X=DefaultW, Y=DefaultH}
            brush.DrawAs = 3
            brush.TintColor = {R=1,G=1,B=1,A=1}
            if ImageWidget.SetBrush then ImageWidget:SetBrush(brush) end
        end
        if ImageWidget.SetDesiredSizeOverride then ImageWidget:SetDesiredSizeOverride({X=DefaultW, Y=DefaultH}) end
        local slot = ImageWidget.Slot
        if slot and slot.SetSize then slot:SetSize({X=DefaultW, Y=DefaultH}) end
        ImageWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        ImageWidget:SetRenderOpacity(1.0)
        ImageWidget:SetColorAndOpacity({R=1,G=1,B=1,A=1})
    end)
end

function PlayerMapMarker.ApplyWeaponIconFullOpacity(Container, ourWeaponIcon)
    local fullIcon = {R=1,G=1,B=1,A=1}
    if not ourWeaponIcon or not slua.isValid(ourWeaponIcon) then return end
    _pcall(function() if ourWeaponIcon.SetRenderOpacity then ourWeaponIcon:SetRenderOpacity(1.0) end end)
    _pcall(function() if ourWeaponIcon.SetColorAndOpacity then ourWeaponIcon:SetColorAndOpacity(fullIcon) end end)
    _pcall(function()
        local brush = ourWeaponIcon.Brush
        if brush then brush.TintColor = fullIcon; if ourWeaponIcon.SetBrush then ourWeaponIcon:SetBrush(brush) end end
    end)
    local chainNames = {"Border_WeaponColor", "Border_Weapon", "Border_WeaponIcon", "SizeBox_Weapon", "ScaleBox_Weapon", "Switcher_WeaponIcon"}
    for _, pname in _ipairs(chainNames) do
        _pcall(function()
            local node = Container and Container[pname]
            if node and slua.isValid(node) then
                if node.SetRenderOpacity then node:SetRenderOpacity(1.0) end
                if node.SetColorAndOpacity then node:SetColorAndOpacity(fullIcon) end
            end
        end)
    end
end

function PlayerMapMarker.ApplyWeaponIconToImage(ImageWidget, winfo)
    if not ImageWidget or not slua.isValid(ImageWidget) then return false end
    if not winfo or not winfo.WeaponID then return false end
    local iconPath = nil
    local method = "none"
    local bHasAddKnownMissing = false
    _pcall(function()
        local itemRecord = CDataTable.GetTableData("Item", winfo.WeaponID)
        if itemRecord and itemRecord.KillWhiteIcon and itemRecord.KillWhiteIcon ~= "" then iconPath = itemRecord.KillWhiteIcon; method = "KillWhiteIcon" end
        if (not iconPath or iconPath == "") and winfo.WeaponIconPath and winfo.WeaponIconPath ~= "" then iconPath = winfo.WeaponIconPath; method = "WeaponIconPath" end
        if (not iconPath or iconPath == "") and winfo.WeaponIconTexture and slua.isValid(winfo.WeaponIconTexture) then
            if ImageWidget.SetBrushFromTexture then ImageWidget:SetBrushFromTexture(winfo.WeaponIconTexture, true); method = "WeaponIconTexture"; return end
        end
        if not iconPath or iconPath == "" then
            local UIUtil = require("client.common.ui_util")
            iconPath, bHasAddKnownMissing = UIUtil.GetItemBigIcon(winfo.WeaponID, ImageWidget)
            if iconPath and iconPath ~= "" then method = "GetItemBigIcon" end
        end
    end)
    if method == "WeaponIconTexture" then PlayerMapMarker.FixWeaponIconBrushSize(ImageWidget); return true, method end
    if not iconPath or iconPath == "" then return false, "no_path" end

    local bOK = false
    _pcall(function()
        if ImageWidget.SetBrushResourceFromPathSync then ImageWidget:SetBrushResourceFromPathSync(iconPath, true); bOK = true end
        if not bOK then
            local util = require("client.slua_ui_framework.util")
            local result = util.SetTexture(ImageWidget, iconPath, {sync = true, bMatchSize = true, bIsInCombatState = true, bHasAddKnownMissing = bHasAddKnownMissing})
            bOK = result ~= nil
        end
        if not bOK then
            local tex = import(iconPath)
            if tex and slua.isValid(tex) and ImageWidget.SetBrushFromTexture then ImageWidget:SetBrushFromTexture(tex, true); bOK = true end
        end
    end)
    if bOK then PlayerMapMarker.FixWeaponIconBrushSize(ImageWidget) end
    return bOK, method .. ":" .. _tostring(iconPath)
end

function PlayerMapMarker.CopyWeaponIconBrushFromNative(ourWeaponIcon, nativeWeaponIcon)
    if not ourWeaponIcon or not slua.isValid(ourWeaponIcon) then return false end
    if not nativeWeaponIcon or not slua.isValid(nativeWeaponIcon) then return false end
    local bCopied = false
    _pcall(function()
        local nBrush = nativeWeaponIcon.Brush
        if nBrush then
            local resObj = nil
            _pcall(function() resObj = nBrush.ResourceObject end)
            if resObj and slua.isValid(resObj) and ourWeaponIcon.SetBrushFromTexture then
                ourWeaponIcon:SetBrushFromTexture(resObj, true)
                bCopied = true
            end
            if bCopied then
                local imgSize = nil
                _pcall(function() imgSize = nBrush.ImageSize end)
                if imgSize then
                    local oBrush = ourWeaponIcon.Brush
                    if oBrush then oBrush.ImageSize = imgSize; if ourWeaponIcon.SetBrush then ourWeaponIcon:SetBrush(oBrush) end end
                end
            end
        end
    end)
    return bCopied
end

function PlayerMapMarker.AddWeaponIconToESP(WidgetData, Character)
    if not WidgetData or not WidgetData.Container then return end
    local Container = WidgetData.Container
    if not slua.isValid(Container) then return end

    _pcall(function()
        local ourWeaponIcon = WidgetData._CachedWeaponIcon
        if not ourWeaponIcon or not slua.isValid(ourWeaponIcon) then
            ourWeaponIcon = Container.WeaponIcon
            if not ourWeaponIcon or not slua.isValid(ourWeaponIcon) then
                ourWeaponIcon = PlayerMapMarker.FindWeaponIconInWidget(Container, 0, 8)
            end
            WidgetData._CachedWeaponIcon = ourWeaponIcon
        end
        if not ourWeaponIcon or not slua.isValid(ourWeaponIcon) then return end

        local winfo = Character and PlayerMapMarker.GetCharacterWeaponInfo(Character) or nil
        if not winfo or not winfo.WeaponID or winfo.WeaponID == 0 then
            _pcall(function() ourWeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            local chainNames = {"Border_WeaponColor", "Border_Weapon", "Border_WeaponIcon", "SizeBox_Weapon", "ScaleBox_Weapon", "Switcher_WeaponIcon"}
            for _, pname in _ipairs(chainNames) do
                _pcall(function()
                    local node = Container and Container[pname]
                    if node and slua.isValid(node) and node.SetWidgetVisibility then node:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                end)
            end
            WidgetData._LastWeaponID = 0
            WidgetData._WeaponIconApplied = false
            return
        end

        if WidgetData._LastWeaponID == winfo.WeaponID and WidgetData._WeaponIconApplied then 
            _pcall(function() ourWeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            _pcall(function() ourWeaponIcon:SetRenderOpacity(1.0) end)
            local chainNames = {"Border_WeaponColor", "Border_Weapon", "Border_WeaponIcon", "SizeBox_Weapon", "ScaleBox_Weapon", "Switcher_WeaponIcon"}
            for _, pname in _ipairs(chainNames) do
                _pcall(function()
                    local node = Container and Container[pname]
                    if node and slua.isValid(node) and node.SetWidgetVisibility then node:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end
                end)
            end
            for _, switcherName in _ipairs({"Switcher_WeaponIcon", "WidgetSwitcher_Type", "WidgetSwitcher_Type2"}) do
                local ws = Container[switcherName]
                if ws and slua.isValid(ws) and ws.SetActiveWidgetIndex then _pcall(function() ws:SetActiveWidgetIndex(0) end) end
            end
            return 
        end

        local chainNames = {"Border_WeaponColor", "Border_Weapon", "Border_WeaponIcon", "SizeBox_Weapon", "ScaleBox_Weapon", "Switcher_WeaponIcon"}
        for _, pname in _ipairs(chainNames) do
            _pcall(function()
                local node = Container and Container[pname]
                if node and slua.isValid(node) and node.SetWidgetVisibility then node:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end
            end)
        end

        local bCopied = false
        if winfo and winfo.WeaponID then
            local ok, method = PlayerMapMarker.ApplyWeaponIconToImage(ourWeaponIcon, winfo)
            if ok then bCopied = true end
        end

        local bWeaponIconSet = false
        if Character and winfo and winfo.WeaponID then
            _pcall(function() if Container.SetWeaponIcon then Container:SetWeaponIcon(winfo.WeaponID); bWeaponIconSet = true end end)
            if not bWeaponIconSet then _pcall(function() if Container.UpdateWeaponIcon then Container:UpdateWeaponIcon(winfo.WeaponID); bWeaponIconSet = true end end) end
            _pcall(function() if Container.SetData then Container:SetData(Character) end end)
            _pcall(function() if Container.SetPlayerInfo then Container:SetPlayerInfo(Character) end end)
        end

        if bWeaponIconSet then
            _pcall(function()
                local innerIcon = Container.Image_Icon
                if not innerIcon or not slua.isValid(innerIcon) then if Container.CanvasPanel_Type1 then innerIcon = Container.CanvasPanel_Type1.Image_Icon end end
                if innerIcon and slua.isValid(innerIcon) and innerIcon ~= ourWeaponIcon then
                    _pcall(function()
                        local ibrush = innerIcon.Brush
                        if ibrush then
                            local iresObj = nil
                            _pcall(function() iresObj = ibrush.ResourceObject end)
                            if iresObj and slua.isValid(iresObj) and ourWeaponIcon.SetBrushFromTexture then
                                ourWeaponIcon:SetBrushFromTexture(iresObj, false)
                                PlayerMapMarker.FixWeaponIconBrushSize(ourWeaponIcon)
                                bCopied = true
                            end
                        end
                    end)
                end
            end)
        end

        if not bCopied then
            local nativeWeaponIcon = nil
            if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
                local nChildren = 0
                _pcall(function() nChildren = PlayerMapMarker.ESPCanvas:GetChildrenCount() end)
                for i = 0, _math_max(nChildren - 1, 0) do
                    local child = nil
                    _pcall(function() child = PlayerMapMarker.ESPCanvas:GetChildAt(i) end)
                    if child and slua.isValid(child) and _string_find(_tostring(child), "OB_PlayerHeadHPItem") and not PlayerMapMarker.IsOurESPWidget(child) then
                        if child.WeaponIcon and slua.isValid(child.WeaponIcon) then nativeWeaponIcon = child.WeaponIcon; break end
                    end
                end
            end
            if nativeWeaponIcon and slua.isValid(nativeWeaponIcon) then
                local okNative = PlayerMapMarker.CopyWeaponIconBrushFromNative(ourWeaponIcon, nativeWeaponIcon)
                if okNative then bCopied = true end
            end
        end

        _pcall(function() ourWeaponIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        PlayerMapMarker.ApplyWeaponIconFullOpacity(Container, ourWeaponIcon)
        PlayerMapMarker.FixWeaponIconBrushSize(ourWeaponIcon)

        for _, switcherName in _ipairs({"Switcher_WeaponIcon", "WidgetSwitcher_Type", "WidgetSwitcher_Type2"}) do
            local ws = Container[switcherName]
            if ws and slua.isValid(ws) and ws.SetActiveWidgetIndex then _pcall(function() ws:SetActiveWidgetIndex(0) end) end
        end

        _pcall(function() if Container.UpdateWeapon then Container:UpdateWeapon() end end)
        _pcall(function() if Container.RefreshWeapon then Container:RefreshWeapon() end end)
        
        WidgetData._LastWeaponID = winfo.WeaponID
        WidgetData._WeaponIconApplied = true
    end)
end

function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return nil end
    if not PlayerMapMarker._OBHeadWidgetClass then
        _pcall(function()
            local Path = "/Game/BluePrints/UI/OBUI/Item/OB_PlayerHeadHPItem_UIBP.OB_PlayerHeadHPItem_UIBP"
            local uClass = slua.loadClass(Path)
            if uClass then PlayerMapMarker._OBHeadWidgetClass = uClass end
        end)
        if not PlayerMapMarker._OBHeadWidgetClass then PlayerMapMarker._OBHeadWidgetLoadFailed = true; return nil end
    end

    local Widget = nil
    _pcall(function()
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local PC = PlayerMapMarker.GetMyPlayerController()
        local OuterObj = ValidSafe(PC) and PC.Object or PlayerMapMarker.ESPCanvas
        Widget = STExtraBlueprintFunctionLibrary.CreateWidgetByClass(PlayerMapMarker._OBHeadWidgetClass, OuterObj)
    end)
    if not Widget then return nil end

    _pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    _pcall(function() Widget:SetRenderOpacity(1.0) end)

    local NameText = nil
    local HealthFill = nil
    local bIsOriginalProgressBar = false

    _pcall(function()
        NameText = Widget.TextBlock_TeamName
        if NameText and slua.isValid(NameText) then _pcall(function() NameText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end

        local SizeBox_HP = Widget.SizeBox_HP
        if SizeBox_HP and slua.isValid(SizeBox_HP) then
            _pcall(function() SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            _pcall(function() SizeBox_HP:SetHeightOverride(6) end)
            _pcall(function() SizeBox_HP:SetWidthOverride(100) end)

            local ExistingChild = nil
            _pcall(function()
                if SizeBox_HP.GetContent then
                    ExistingChild = SizeBox_HP:GetContent()
                end
            end)
            if not ExistingChild then
                _pcall(function()
                    if SizeBox_HP.GetChildAt then
                        ExistingChild = SizeBox_HP:GetChildAt(0)
                    end
                end)
            end

            if ExistingChild and slua.isValid(ExistingChild) then
                _pcall(function() ExistingChild:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                _pcall(function() ExistingChild:SetRenderOpacity(1.0) end)

                local FoundPB = PlayerMapMarker.FindProgressBarInWidget(ExistingChild, 0, 5)
                if FoundPB and slua.isValid(FoundPB) then
                    HealthFill = FoundPB
                    bIsOriginalProgressBar = true
                    _pcall(function() FoundPB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                    _pcall(function() FoundPB:SetRenderOpacity(1.0) end)
                else
                    local PB = CGame:NewObjectFromPath("/Script/UMG.ProgressBar", ExistingChild)
                    if PB then
                        _pcall(function() PB:SetFillColorAndOpacity({R=0,G=1,B=0,A=1}) end)
                        _pcall(function() PB:SetPercent(1.0) end)
                        _pcall(function() PB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                        _pcall(function() PB:SetRenderOpacity(1.0) end)
                        _pcall(function() PB:SetDesiredSizeOverride({X=100, Y=6}) end)
                        _pcall(function() ExistingChild:AddChild(PB) end)
                        HealthFill = PB
                    end
                end
            else
                local PB = CGame:NewObjectFromPath("/Script/UMG.ProgressBar", SizeBox_HP)
                if PB then
                    _pcall(function() PB:SetFillColorAndOpacity({R=0,G=1,B=0,A=1}) end)
                    _pcall(function() PB:SetPercent(1.0) end)
                    _pcall(function() PB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                    _pcall(function() PB:SetRenderOpacity(1.0) end)
                    _pcall(function() PB:SetDesiredSizeOverride({X=100, Y=6}) end)

                    local bUsedSetContent = false
                    _pcall(function()
                        if SizeBox_HP.SetContent then
                            SizeBox_HP:SetContent(PB)
                            bUsedSetContent = true
                        end
                    end)
                    if not bUsedSetContent then
                        _pcall(function() SizeBox_HP:AddChild(PB) end)
                    end
                    HealthFill = PB
                end
            end
        end
    end)

    return {
        Container = Widget,
        NameText = NameText,
        HealthFill = HealthFill,
        IsGameWidget = true,
        IsOriginalProgressBar = bIsOriginalProgressBar
    }
end

function PlayerMapMarker.GetOrCreateESPWidget()
    if #PlayerMapMarker.WidgetPool > 0 then
        local w = _table_remove(PlayerMapMarker.WidgetPool)
        if w and w.Container and slua.isValid(w.Container) then
            _pcall(function() w.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            return w
        end
    end
    return PlayerMapMarker.CreateESPWidget()
end

function PlayerMapMarker.RemoveESPWidget(Widget)
    if not Widget then return end
    local Container = Widget.Container or Widget
    _pcall(function()
        local ptr = _tostring(Container)
        PlayerMapMarker.ESPWidgetPtrs[ptr] = nil
        Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        _table_insert(PlayerMapMarker.WidgetPool, Widget)
    end)
end

function PlayerMapMarker.GetDynamicViewportSize(PC)
    local width, height = 0, 0
    if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
        _pcall(function()
            local cg = PlayerMapMarker.ESPCanvas:GetCachedGeometry()
            if cg and cg.GetLocalSize then
                local sz = cg:GetLocalSize()
                if sz and sz.X and sz.X > 200 then width = sz.X; height = sz.Y end
            end
        end)
    end
    if width > 200 then return width, height end
    _pcall(function()
        local WLL = WidgetLayoutLibrary
        if WLL and WLL.GetViewportSize then
            local sz = WLL.GetViewportSize(PC or PlayerMapMarker.GetMyPlayerController())
            if sz and sz.X and sz.X > 200 then width = sz.X; height = sz.Y end
        end
    end)
    if width > 200 then
        _pcall(function()
            local WLL = WidgetLayoutLibrary
            if WLL and WLL.GetViewportScale then
                local scale = WLL.GetViewportScale(PC or PlayerMapMarker.GetMyPlayerController())
                if scale and _type(scale) == "number" and scale > 0 and scale ~= 1.0 then width = width / scale; height = height / scale end
            end
        end)
        return width, height
    end
    return PlayerMapMarker._cachedViewportW or 1920, PlayerMapMarker._cachedViewportH or 1080
end

function PlayerMapMarker.UpdateCanvasTransform(PC)
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end
    local success = false
    _pcall(function()
        if SlateBlueprintLibrary and SlateBlueprintLibrary.AbsoluteToLocal then
            local cg = PlayerMapMarker.ESPCanvas:GetCachedGeometry()
            if cg then
                local FVector2D = import("Vector2D")
                local pt0 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D and FVector2D(0, 0) or {X=0,Y=0})
                local pt1 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D and FVector2D(100, 100) or {X=100,Y=100})
                if pt0 and pt1 then
                    PlayerMapMarker._CanvasScaleX = (pt1.X - pt0.X) / 100
                    PlayerMapMarker._CanvasScaleY = (pt1.Y - pt0.Y) / 100
                    PlayerMapMarker._CanvasOffsetX = pt0.X
                    PlayerMapMarker._CanvasOffsetY = pt0.Y
                    success = true
                end
            end
        end
    end)
    if not success then
        local scale = 1.0
        if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then scale = WidgetLayoutLibrary.GetViewportScale(PC) or 1.0 end
        PlayerMapMarker._CanvasScaleX = 1.0 / scale
        PlayerMapMarker._CanvasScaleY = 1.0 / scale
        PlayerMapMarker._CanvasOffsetX = 0
        PlayerMapMarker._CanvasOffsetY = 0
    end
end

local _CachedVector2D = nil
function PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    if not ScreenPixelPos then return {X=0,Y=0} end
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    
    local finalX = ScreenPixelPos.X * scaleX + offsetX
    local finalY = ScreenPixelPos.Y * scaleY + offsetY
    
    if not _CachedVector2D then
        local FVector2D = import("Vector2D")
        if FVector2D then _CachedVector2D = FVector2D(finalX, finalY) end
    end
    
    if _CachedVector2D then
        _CachedVector2D.X = finalX
        _CachedVector2D.Y = finalY
        return _CachedVector2D
    end
    
    return {X = finalX, Y = finalY}
end

function PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    if not ValidSafe(PC) or not WorldLoc then return false, {X=0,Y=0} end
    local FVector2D = import("Vector2D")
    local ScreenPixelPos = FVector2D and FVector2D(0, 0) or {X=0,Y=0}
    local bOK = false
    _pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, ScreenPixelPos, true)
        if res == true or res == 1 or (ScreenPixelPos and (ScreenPixelPos.X ~= 0 or ScreenPixelPos.Y ~= 0)) then bOK = true end
    end)
    if not bOK or not ScreenPixelPos or (ScreenPixelPos.X == 0 and ScreenPixelPos.Y == 0) then return false, ScreenPixelPos end
    local CanvasLocalPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    return true, CanvasLocalPos
end

function PlayerMapMarker.ApplyAnchorBasedPosition(Slot, ScreenPos, Canvas)
    if not Slot or not ScreenPos then return false end
    local sx = ScreenPos.X or 0
    local sy = ScreenPos.Y or 0
    local sz = PlayerMapMarker.ESPWidgetSize
    local align = PlayerMapMarker.ESPWidgetAlignment

    local canvasW, canvasH = PlayerMapMarker.GetDynamicViewportSize(PlayerMapMarker.GetMyPlayerController())

    if canvasW > 200 and canvasH > 200 then
        local anchorX = (sx + (PlayerMapMarker.ESPAnchorOffsetX or 0)) / canvasW
        local anchorY = (sy + (PlayerMapMarker.ESPAnchorOffsetY or 0)) / canvasH
        anchorX = _math_max(0, _math_max(1, anchorX))
        anchorY = _math_max(0, _math_max(1, anchorY))

        local bSuccess = false
        _pcall(function()
            local FAnchors = import("Anchors") or import("/Script/SlateCore.Anchors")
            if Slot.SetAnchors and FAnchors then
                local anchors = FAnchors(anchorX, anchorY, anchorX, anchorY)
                if anchors then Slot:SetAnchors(anchors); Slot:SetPosition({X=0, Y=0}); bSuccess = true end
            end
        end)
        if not bSuccess then
            _pcall(function() if Slot.SetAnchors then Slot:SetAnchors(anchorX, anchorY, anchorX, anchorY); Slot:SetPosition({X=0, Y=0}); bSuccess = true end end)
        end
        if bSuccess then
            _pcall(function() if Slot.SetOffsets then local FMargin = import("Margin") or import("/Script/SlateCore.Margin"); if FMargin then Slot:SetOffsets(FMargin(0, 0, sz.X, sz.Y)) end end end)
            _pcall(function() Slot:SetSize(sz) end)
            _pcall(function() Slot:SetAlignment(align) end)
            _pcall(function() if Slot.SetAutoSize then Slot:SetAutoSize(PlayerMapMarker.ESPWidgetAutoSize or true) end end)
            _pcall(function() if Slot.SetZOrder then Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 2) end end)
            return true
        end
    end

    _pcall(function()
        Slot:SetPosition({X=sx, Y=sy})
        _pcall(function() Slot:SetSize(sz) end)
        _pcall(function() Slot:SetAlignment(align) end)
        _pcall(function() if Slot.SetAutoSize then Slot:SetAutoSize(PlayerMapMarker.ESPWidgetAutoSize or true) end end)
        _pcall(function() if Slot.SetZOrder then Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 2) end end)
    end)
    return false
end

function PlayerMapMarker.UpdateESPPositionWithPC(Widget, WorldLoc, PC, CanvasPos)
    if not Widget or not ValidSafe(PC) then return false end
    local Container = Widget.Container or Widget
    local bOnScreen = true
    if not CanvasPos then
        if not WorldLoc then return false end
        bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    end
    if not bOnScreen then
        _pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
        return false
    end
    _pcall(function()
        if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
            local ptr = _tostring(Container)
            local Slot = PlayerMapMarker.ESPWidgetPtrs[ptr]
            if not Slot or not slua.isValid(Slot) or _type(Slot) == "boolean" then
                local addedSlot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Container)
                if addedSlot and slua.isValid(addedSlot) then
                    Slot = addedSlot
                    PlayerMapMarker.ESPWidgetPtrs[ptr] = addedSlot
                    if _type(Widget) == "table" then Widget.Slot = addedSlot end
                    _pcall(function() Slot:SetAutoSize(true) end)
                    _pcall(function() Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 20) end)
                end
            end
            Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            if not Widget._OffsetResetDone then
                _pcall(function() Container:SetRenderTranslation({X=0, Y=0}) end)
                if Widget and _type(Widget) == "table" then
                    if Widget.NameText and slua.isValid(Widget.NameText) then _pcall(function() Widget.NameText:SetRenderTranslation({X=0, Y=0}) end) end
                    if Widget.HealthFill and slua.isValid(Widget.HealthFill) then _pcall(function() Widget.HealthFill:SetRenderTranslation({X=0, Y=0}) end) end
                end
                Widget._OffsetResetDone = true
                _pcall(function() Container:SetRenderScale({X=0.8, Y=0.8}) end)
            end
            if Slot and slua.isValid(Slot) and Slot ~= PlayerMapMarker.ESPCanvas then
                local bAnchored = PlayerMapMarker.ApplyAnchorBasedPosition(Slot, CanvasPos, PlayerMapMarker.ESPCanvas)
                if not bAnchored then
                    local finalX = CanvasPos.X + (PlayerMapMarker.ESPAnchorOffsetX or 0)
                    local finalY = CanvasPos.Y + (PlayerMapMarker.ESPAnchorOffsetY or 0)
                    _pcall(function() Slot:SetPosition({X=finalX, Y=finalY}) end)
                end
            end
        end
    end)
    return true
end

function PlayerMapMarker.FindProgressBarInWidget(WidgetObj, Depth, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    Depth = Depth or 0
    MaxDepth = MaxDepth or 5
    if Depth > MaxDepth then return nil end

    local bIsPB = false
    _pcall(function()
        if WidgetObj.SetPercent and WidgetObj.SetFillColorAndOpacity then
            bIsPB = true
        end
    end)
    if bIsPB then return WidgetObj end

    local nChildren = 0
    _pcall(function()
        if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end
    end)

    for i = 0, _math_max(nChildren - 1, 0) do
        local child = nil
        _pcall(function() child = WidgetObj:GetChildAt(i) end)
        if child and slua.isValid(child) then
            local result = PlayerMapMarker.FindProgressBarInWidget(child, Depth + 1, MaxDepth)
            if result then return result end
        end
    end

    return nil
end

function PlayerMapMarker.UpdateESPText(Widget, Text)
    if not Widget then return end
    if Widget._LastESPText == Text then return end
    Widget._LastESPText = Text
    local function applyTextAndCenter(w, txt)
        if not w or not slua.isValid(w) then return end
        _pcall(function() w:SetText(txt) end)
    end
    if Widget.NameText and slua.isValid(Widget.NameText) then applyTextAndCenter(Widget.NameText, Text) end
    if Widget.IsGameWidget and Widget.Container then
        _pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                if W.SetPlayerName then
                    local Name = Text
                    local idx = _string_find(Text, " %[")
                    if idx then Name = _string_sub(Text, 1, idx - 1) end
                    W:SetPlayerName(Name)
                end
                applyTextAndCenter(W.TextBlock_TeamName, Text)
                applyTextAndCenter(W.TextBlock_PlayerName, Text)
            end
        end)
    end
end


function PlayerMapMarker.UpdateESPHealth(Widget, pct)
    if not Widget then return end
    if Widget.LastPct == pct then return end
    Widget.LastPct = pct

    if Widget.HealthFill then
        local bValid = false
        _pcall(function() bValid = slua.isValid(Widget.HealthFill) end)
        if bValid then
            local bHasSetPercent = false
            _pcall(function() bHasSetPercent = (Widget.HealthFill.SetPercent ~= nil) end)
            
            if not bHasSetPercent then
                local PB = PlayerMapMarker.FindProgressBarInWidget(Widget.HealthFill, 0, 5)
                if PB and slua.isValid(PB) then
                    Widget.HealthFill = PB
                else
                    return
                end
            end

            _pcall(function()
                if Widget.HealthFill.SetWidgetVisibility then
                    Widget.HealthFill:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                end
                if Widget.HealthFill.SetRenderOpacity then
                    Widget.HealthFill:SetRenderOpacity(1.0)
                end
                if Widget.HealthFill.SetPercent then
                    Widget.HealthFill:SetPercent(pct)
                    
                    local color
                    if pct > 0.6 then
                        color = {R=0,G=1,B=0,A=1}
                    elseif pct > 0.3 then
                        color = {R=1,G=1,B=0,A=1}
                    else
                        color = {R=1,G=0,B=0,A=1}
                    end
                    
                    if Widget.HealthFill.SetFillColorAndOpacity then
                        Widget.HealthFill:SetFillColorAndOpacity(color)
                    end
                end
            end)
        end
    end
end

function PlayerMapMarker.CreateSnapLine()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end
    local Border = nil
    _pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", PlayerMapMarker.ESPCanvas) end)
    if not Border or not slua.isValid(Border) then return nil end
    local color = PlayerMapMarker.SnapLineColor or {R=1,G=1,B=1,A=0.7}
    _pcall(function() Border:SetBrushColor(color) end)
    _pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    _pcall(function() Border.RenderTransformPivot = {X=0.0, Y=0.5}; Border:SetRenderTransformPivot({X=0.0, Y=0.5}) end)
    local Slot = nil
    _pcall(function()
        Slot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Border)
        if Slot then Slot:SetAutoSize(false); Slot:SetZOrder(1) end
    end)
    return { Widget = Border, Slot = Slot }
end

function PlayerMapMarker.GetOrCreateSnapLine()
    if #PlayerMapMarker.SnapLinePool > 0 then
        local l = _table_remove(PlayerMapMarker.SnapLinePool)
        if l and l.Widget and slua.isValid(l.Widget) then
            _pcall(function() l.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            return l
        end
    end
    return PlayerMapMarker.CreateSnapLine()
end

function PlayerMapMarker.RemoveSnapLine(KeyStr)
    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
        _pcall(function() 
            LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) 
            _table_insert(PlayerMapMarker.SnapLinePool, LineData)
        end)
        PlayerMapMarker.SnapLineWidgets[KeyStr] = nil
    end
end

function PlayerMapMarker.GetSnapLineStartPos(PC)
    local canvasW, canvasH = PlayerMapMarker.GetDynamicViewportSize(PC)
    local fromX = canvasW / 2.0
    local fromY = 70
    return fromX, fromY
end

local _SnapLineColorCache = {}
local RAD_TO_DEG = 180.0 / math.pi
local _math_sqrt = math.sqrt
local _math_abs = math.abs
local _math_atan2 = math.atan2 or math.atan

local function GetCachedSnapLineColor(colIdx, alpha)
    local key = colIdx .. "_" .. tostring(alpha)
    if _SnapLineColorCache[key] then return _SnapLineColorCache[key] end
    local r, g, b = (colIdx==1 or colIdx==4 or colIdx==5 or colIdx==7) and 1 or 0, (colIdx==2 or colIdx==4 or colIdx==6 or colIdx==7) and 1 or 0, (colIdx==3 or colIdx==5 or colIdx==6 or colIdx==7) and 1 or 0
    local color = {R=r*255, G=g*255, B=b*255, A=alpha*255}
    _SnapLineColorCache[key] = color
    return color
end

function PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY, bIsVisible)
    local cfg = _G.LexusConfig
    local cData = _G.LexusState.CustomTextData

    if not cfg.EspLoai9_Line then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end
    
    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    
    -- [TỐI ƯU 1]: Ẩn đi nếu khuất màn hình (Kiểm tra State tránh gọi SLUA liên tục)
    if not bOnScreen or not CanvasPos then
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            if not LineData._isHidden then
                _pcall(function() LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                LineData._isHidden = true
            end
        end
        return
    end

    local bIsNew = false
    if not LineData then
        -- [TỐI ƯU 2]: Sửa lỗi chết người ở code cũ (gọi Create thay vì GetOrCreate)
        LineData = PlayerMapMarker.GetOrCreateSnapLine()
        if not LineData or not LineData.Widget or not LineData.Slot then return end
        PlayerMapMarker.SnapLineWidgets[KeyStr] = LineData
        bIsNew = true
    end

    local Widget = LineData.Widget
    local Slot = LineData.Slot

    if bIsNew or LineData._isHidden then
        _pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        LineData._isHidden = false
    end

    -- [TỐI ƯU 3]: Xử lý Màu bằng Cache
    local colIdx = 7
    if cfg.EspLoai9_Line_VisCheck then
        colIdx = bIsVisible and (tonumber(cData.EspLoai9_Line_Vis_Color) or 2) or (tonumber(cData.EspLoai9_Line_Hid_Color) or 1)
    else
        colIdx = tonumber(cData.EspLoai9_Line_Vis_Color) or 2
    end

    local currentAlpha = PlayerMapMarker.SnapLineOpacity or 0.7
    
    if LineData._lastColorIdx ~= colIdx or LineData._lastAlpha ~= currentAlpha then
        local finalColor = GetCachedSnapLineColor(colIdx, currentAlpha)
        _pcall(function() Widget:SetBrushColor(finalColor) end)
        LineData._lastColorIdx = colIdx
        LineData._lastAlpha = currentAlpha
    end

    -- [TỐI ƯU 4]: Toán học và State Caching Transform (Chỉ Update khi xê dịch)
    local thickness = PlayerMapMarker.SnapLineThickness or 1.5
    local toX = CanvasPos.X + (PlayerMapMarker.SnapLineHeadOffsetX or 0)
    local toY = CanvasPos.Y + (PlayerMapMarker.SnapLineHeadOffsetY or 0)
    local adjustedFromX = fromX - 45
    
    local dx = toX - adjustedFromX
    local dy = toY - fromY
    local length = _math_sqrt(dx * dx + dy * dy)
    local angle = _math_atan2(dy, dx) * RAD_TO_DEG
    
    local needsTransformUpdate = bIsNew
    if not LineData._CachedPosVec then
        LineData._CachedPosVec = {X = adjustedFromX, Y = fromY - thickness / 2.0}
        LineData._CachedSizeVec = {X = length, Y = thickness}
        needsTransformUpdate = true
    else
        -- Chỉ update Widget nếu địch di chuyển đáng kể (> 0.5 pixel)
        if _math_abs(LineData._CachedPosVec.X - adjustedFromX) > 0.5 or 
           _math_abs(LineData._CachedPosVec.Y - (fromY - thickness / 2.0)) > 0.5 or 
           _math_abs(LineData._CachedSizeVec.X - length) > 0.5 or 
           _math_abs((LineData._lastAngle or 0) - angle) > 0.5 then
           
            LineData._CachedPosVec.X = adjustedFromX
            LineData._CachedPosVec.Y = fromY - thickness / 2.0
            LineData._CachedSizeVec.X = length
            LineData._CachedSizeVec.Y = thickness
            needsTransformUpdate = true
        end
    end
    
    if needsTransformUpdate then
        _pcall(function() 
            Slot:SetPosition(LineData._CachedPosVec)
            Slot:SetSize(LineData._CachedSizeVec)
            Widget:SetRenderAngle(angle)
            if bIsNew then Slot:SetZOrder(1) end
        end)
        LineData._lastAngle = angle
    end
end

function PlayerMapMarker.ClearAllSnapLines()
    for KeyStr, LineData in _pairs(PlayerMapMarker.SnapLineWidgets or {}) do
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            _pcall(function() 
                LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) 
                LineData._isHidden = true
                _table_insert(PlayerMapMarker.SnapLinePool, LineData)
            end)
        end
    end
    PlayerMapMarker.SnapLineWidgets = {}
end

function PlayerMapMarker.ClearAllESP()
    RedBoxOverlay.Stop()
    for KeyStr, Data in _pairs(PlayerMapMarker.ESPWidgets) do 
        local Container = Data.Widget.Container or Data.Widget
        _pcall(function() Container:RemoveFromParent(); Container:ConditionalBeginDestroy() end)
    end
    PlayerMapMarker.ESPWidgets = {}
    PlayerMapMarker.ESPWidgetPtrs = {}
    
    for _, Widget in _ipairs(PlayerMapMarker.WidgetPool) do
        local Container = Widget.Container or Widget
        _pcall(function() Container:RemoveFromParent(); Container:ConditionalBeginDestroy() end)
    end
    PlayerMapMarker.WidgetPool = {}

    -- [TỐI ƯU DỌN RÁC MAINLOOP]: Hủy diệt tận gốc Snaplines khi hết trận
    for KeyStr, LineData in _pairs(PlayerMapMarker.SnapLineWidgets or {}) do
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            _pcall(function() LineData.Widget:RemoveFromParent(); LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    for _, LineData in _ipairs(PlayerMapMarker.SnapLinePool or {}) do
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            _pcall(function() LineData.Widget:RemoveFromParent(); LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    PlayerMapMarker.SnapLineWidgets = {}
    PlayerMapMarker.SnapLinePool = {}

    if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
        _pcall(function()
            local n = PlayerMapMarker.ESPCanvas:GetChildrenCount()
            for i = n - 1, 0, -1 do
                local child = PlayerMapMarker.ESPCanvas:GetChildAt(i)
                if child and slua.isValid(child) and PlayerMapMarker.IsOurESPWidget(child) then PlayerMapMarker.ESPCanvas:RemoveChild(child) end
            end
        end)
    end
    PlayerMapMarker.ESPCanvas = nil
end

function PlayerMapMarker.UpdateESP(AllPlayers, MyLoc)
    local cfg = _G.LexusConfig
    if not PlayerMapMarker.bUseScreenESP then return end
    if not PlayerMapMarker.InitESPCanvas() then return end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if ValidSafe(PC) then PlayerMapMarker.UpdateCanvasTransform(PC) end
    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines and ValidSafe(PC) then fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC) end
    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local SeenKeys = {}
    local MyChar = nil
    _pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)
    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)
    
    local widgets = PlayerMapMarker.ESPWidgets
    local curTime = _os_clock()
    local visCheckEnabled = cfg.EspLoai9_Line_VisCheck

    for PlayerKey, Character in _pairs(AllPlayers) do
        if ValidSafe(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local KeyStr = _tostring(PlayerKey)

            local bSkip = false
            if bIsMe and not PlayerMapMarker.bIncludeMe then bSkip = true end
            if bIsAI and not PlayerMapMarker.bIncludeAI then bSkip = true end
            local TeamID = PlayerMapMarker.GetTeamID(Character)
            if MyTeamID ~= nil and TeamID == MyTeamID and not bIsMe then bSkip = true end

            local Loc = nil
            if not bSkip then Loc = PlayerMapMarker.GetESPLocation(Character) end

            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if not bSkip and Loc then
                SeenKeys[KeyStr] = true
                local ESPData = widgets[KeyStr]
                
                -- Lazy load Name and DistStr ONLY if we need to
                local Name = ESPData and ESPData.Name or PlayerMapMarker.GetPlayerName(Character)
                local DistStr = ""
                if MyLoc then DistStr = PlayerMapMarker.GetDistanceString(MyLoc, Loc) end

                local Text = Name
                if DistStr ~= "" then Text = _string_format("%s [%s]", Name, DistStr) end
                
                local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)

                local bIsVisible = true
                if visCheckEnabled then
                    if ESPData then
                        if ESPData.LastVisCheckTime == nil or (curTime - ESPData.LastVisCheckTime > 0.2) then
                            _pcall(function() ESPData.bIsVisible = PC:LineOfSightTo(Character) end)
                            ESPData.LastVisCheckTime = curTime
                        end
                        bIsVisible = ESPData.bIsVisible or false
                    else
                        _pcall(function() bIsVisible = PC:LineOfSightTo(Character) end)
                    end
                end

                if not ESPData then
                    local Widget = PlayerMapMarker.GetOrCreateESPWidget()
                    if Widget then
                        widgets[KeyStr] = { Widget = Widget, Character = Character, Name = Name, LastDistStr = DistStr, TeamID = TeamID, LastVisCheckTime = curTime, bIsVisible = bIsVisible }
                        PlayerMapMarker.UpdateESPText(Widget, Text)
                        if bIsAlive then
                            PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)
                            PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
                            local HP, MaxHP = Character.Health or 0, Character.MaxHealth or 120
                            local pct = (HP > 0 and MaxHP > 0) and _math_max(0, _math_max(1, HP / MaxHP)) or 0
                            PlayerMapMarker.UpdateESPHealth(Widget, pct)
                            PlayerMapMarker.AddWeaponIconToESP(Widget, Character)
                            if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY, bIsVisible)
                            else PlayerMapMarker.RemoveSnapLine(KeyStr) end
                        else
                            local Container = Widget.Container or Widget
                            _pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                            PlayerMapMarker.UpdateESPHealth(Widget, 0)
                            PlayerMapMarker.RemoveSnapLine(KeyStr)
                        end
                    end
                else
                    ESPData.Character = Character; ESPData.Name = Name; ESPData.LastDistStr = DistStr
                    if bIsAlive then
                        if TeamID ~= ESPData.TeamID then ESPData.TeamID = TeamID; PlayerMapMarker.ApplyTeamColor(ESPData.Widget, TeamID) end
                        PlayerMapMarker.UpdateESPText(ESPData.Widget, Text)
                        PlayerMapMarker.UpdateESPPositionWithPC(ESPData.Widget, Loc, PC, CanvasPos)
                        local HP, MaxHP = 0, 120
                _pcall(function()
                    HP = Character.Health or 0
                    MaxHP = Character.MaxHealth or 120
                end)
                local pct = 0
                if HP > 0 and MaxHP > 0 then
                    pct = HP / MaxHP
                    if pct > 1.0 then pct = 1.0 elseif pct < 0.0 then pct = 0.0 end
                end
                        PlayerMapMarker.UpdateESPHealth(ESPData.Widget, pct)
                        PlayerMapMarker.AddWeaponIconToESP(ESPData.Widget, Character)
                        if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY, bIsVisible)
                        else PlayerMapMarker.RemoveSnapLine(KeyStr) end
                    else
                        local Container = ESPData.Widget.Container or ESPData.Widget
                        _pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                        PlayerMapMarker.UpdateESPHealth(ESPData.Widget, 0)
                        PlayerMapMarker.RemoveSnapLine(KeyStr)
                    end
                end
            end
        end
    end

    for KeyStr, Data in _pairs(widgets) do
        if not SeenKeys[KeyStr] then
            PlayerMapMarker.RemoveESPWidget(Data.Widget)
            PlayerMapMarker.RemoveSnapLine(KeyStr)
            widgets[KeyStr] = nil
        end
    end
end

function PlayerMapMarker.UpdateESPLight()
    local cfg = _G.LexusConfig
    if RedBoxOverlay.bActive then RedBoxOverlay.UpdatePosition() end
    if not PlayerMapMarker.bUseScreenESP then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not ValidSafe(PC) then return end
    PlayerMapMarker.UpdateCanvasTransform(PC)
    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines then fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC) end
    
    local widgets = PlayerMapMarker.ESPWidgets
    local curTime = _os_clock()
    local visCheckEnabled = cfg.EspLoai9_Line_VisCheck

    for KeyStr, ESPData in _pairs(widgets) do
        local Widget = ESPData.Widget; local Character = ESPData.Character
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        _pcall(function() bWidgetValid = Container and slua.isValid(Container) end)
        if Widget and bWidgetValid and Character and ValidSafe(Character) then
            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if not bIsAlive then
                _pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                PlayerMapMarker.RemoveSnapLine(KeyStr)
            else
                _pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                local Loc = PlayerMapMarker.GetESPLocation(Character)
                if Loc then
                    local bIsVisible = true
                    if visCheckEnabled then
                        if ESPData.LastVisCheckTime == nil or (curTime - ESPData.LastVisCheckTime > 0.2) then
                            _pcall(function() ESPData.bIsVisible = PC:LineOfSightTo(Character) end)
                            ESPData.LastVisCheckTime = curTime
                        end
                        bIsVisible = ESPData.bIsVisible or false
                    end

                    local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)
                    PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)
                    if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY, bIsVisible)
                    else PlayerMapMarker.RemoveSnapLine(KeyStr) end
                else
                    PlayerMapMarker.RemoveSnapLine(KeyStr)
                end
            end
        end
    end
end

function PlayerMapMarker.UpdateESPDistances()
    if not PlayerMapMarker.bUseScreenESP then return end
    local MyLoc = PlayerMapMarker.GetMyLocation()
    if not MyLoc then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not ValidSafe(PC) then return end
    PlayerMapMarker.UpdateCanvasTransform(PC)
    for KeyStr, ESPData in _pairs(PlayerMapMarker.ESPWidgets) do
        local Character = ESPData.Character; local Widget = ESPData.Widget
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        _pcall(function() bWidgetValid = Container and slua.isValid(Container) end)
        if Character and ValidSafe(Character) and Widget and bWidgetValid then
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            if Loc then
                local Dist = PlayerMapMarker.CalcDistance(MyLoc, Loc)
                ESPData.LastDistance = Dist
                if PlayerMapMarker.bShowDistance then
                    local DistStr = ""
                    local Meters = 0
                    if Dist then
                        Meters = Dist / 100
                        if Meters < 1000 then DistStr = _string_format("%dm", _math_floor(Meters))
                        else DistStr = _string_format("%.1fkm", Meters / 1000) end
                    end
                    local Name = ESPData.Name or "Unknown"
                    local Text = Name
                    if DistStr and DistStr ~= "" then Text = _string_format("%s [%s]", Name, DistStr) end
                    ESPData.LastDistStr = DistStr
                    PlayerMapMarker.UpdateESPText(Widget, Text)
                end
            end
        end
    end
end

function PlayerMapMarker.ScanAndUpdate()
    -- [Tối ưu] Lấy dữ liệu từ cache MainLoop để khỏi quét lại Map
    local AllChars = {}
    if _G.MainLoopEnemyCache then
        for _, char in _ipairs(_G.MainLoopEnemyCache) do
            if ValidSafe(char) then
                local pKey = nil
                _pcall(function() pKey = char.GetPlayerKey and char:GetPlayerKey() or char.PlayerKey end)
                if not pKey then _pcall(function() pKey = char.PlayerState and char.PlayerState.PlayerKey end) end
                if pKey then AllChars[pKey] = char end
            end
        end
    else
        AllChars = PlayerMapMarker.GetAllCharacters()
    end

    if not AllChars then RedBoxOverlay.SetCounts(0, 0); return 0 end
    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local MyLoc = PlayerMapMarker.GetMyLocation()
    local MyChar = nil
    _pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else local PC = PlayerMapMarker.GetMyPlayerController(); if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)
    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)
    local realPlayers = 0; local botPlayers = 0

    for PlayerKey, Character in _pairs(AllChars) do
        if ValidSafe(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if bIsAlive and not bIsMe then
                local bIsMyTeam = false
                if MyTeamID ~= nil then
                    if PlayerMapMarker.GetTeamID(Character) == MyTeamID then bIsMyTeam = true end
                end
                if not bIsMyTeam then
                    if bIsAI then botPlayers = botPlayers + 1 else realPlayers = realPlayers + 1 end
                end
            end
        end
    end

    if RedBoxOverlay.bActive then RedBoxOverlay.SetCounts(realPlayers, botPlayers)
    else RedBoxOverlay.Start() end

    if PlayerMapMarker.bUseScreenESP then
        PlayerMapMarker.UpdateESP(AllChars, MyLoc)
        return 0
    end
    return 0
end

-- =========================================================================
-- [ FIX CHUẨN 100% LOGIC VÒNG FOV ] - Khớp Tâm Ngắm & Khớp Size Aimbot
-- =========================================================================

_G.FovCircleOverlay = _G.FovCircleOverlay or {
    Container = nil,
    WidgetSlot = nil,
    Lines = {},
    NumSegments = 90, 
    Thickness = 1.2,  
    LastRadius = -1,
    LastColor = -1,
    LastCX = -1,
    LastCY = -1
}

local function GetFOVColor(idx)
    if idx == 1 then return 1.0, 0.0, 0.0 end
    if idx == 2 then return 0.0, 1.0, 0.0 end
    if idx == 3 then return 0.0, 0.0, 1.0 end
    if idx == 4 then return 1.0, 1.0, 0.0 end
    if idx == 5 then return 0.65, 0.15, 1.0 end
    if idx == 6 then return 0.0, 1.0, 1.0 end
    if idx == 7 then return 1.0, 1.0, 1.0 end
    return 1.0, 1.0, 1.0 
end

function _G.FovCircleOverlay.Create()
    if _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then return true end
    
    local ParentCanvas = nil
    pcall(function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local MainUI = InGameUITools.GetMainControlBaseUI()
        if slua.isValid(MainUI) then
            if slua.isValid(MainUI.CanvasPanel_0) then ParentCanvas = MainUI.CanvasPanel_0
            elseif slua.isValid(MainUI.CanvasPanel_42) then ParentCanvas = MainUI.CanvasPanel_42 end
        end
    end)
    
    if not ParentCanvas or not slua.isValid(ParentCanvas) then return false end

    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
    if not Container or not slua.isValid(Container) then return false end

    local FVector2D = import("Vector2D")
    
    for i = 1, _G.FovCircleOverlay.NumSegments do
        local border = nil
        pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
        if border and slua.isValid(border) then
            pcall(function() 
                local pivot = FVector2D and FVector2D(0, 0.5) or {X=0, Y=0.5}
                border.RenderTransformPivot = pivot
                border:SetRenderTransformPivot(pivot) 
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                pcall(function() 
                    local align = FVector2D and FVector2D(0, 0.5) or {X=0, Y=0.5}
                    slot:SetAlignment(align) 
                end)
            end
            _G.FovCircleOverlay.Lines[i] = { widget = border, slot = slot }
        end
    end

    local MainSlot = nil
    pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
    if MainSlot then
        pcall(function()
            local vecZero = FVector2D and FVector2D(0, 0) or {X=0, Y=0}
            MainSlot:SetAutoSize(false)
            MainSlot:SetSize(vecZero)
            MainSlot:SetZOrder(995)
            MainSlot:SetAlignment(vecZero)
            MainSlot:SetPosition(vecZero)
        end)
    end
    _G.FovCircleOverlay.Container = Container
    _G.FovCircleOverlay.WidgetSlot = MainSlot
    return true
end

function _G.FovCircleOverlay.Update(pc, player)
    -- [1. FIX ĐỘC LẬP TẮT/BẬT & LIÊN KẾT CHẶT CHẼ VỚI AIMTOUCH]
    -- BẮT BUỘC phải bật AimTouch VÀ bật Vòng FOV thì mới hiển thị vòng
    if not _G.LexusConfig.AimTouchEnable or not _G.LexusConfig.EspFovCircle then
        if _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then
            pcall(function() _G.FovCircleOverlay.Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
        end
        -- [FIX BUG]: Xóa sạch toàn bộ thông số rác khi người dùng TẮT nút, để lúc BẬT lại nó sẽ vẽ mượt mà
        _G.FovCircleOverlay.LastRadius = -1
        _G.FovCircleOverlay.LastCX = -1
        _G.FovCircleOverlay.LastCY = -1
        _G.FovCircleOverlay.LastColor = -1
        return
    end

    if not slua.isValid(player) then return end

    local cData = _G.LexusState.CustomTextData or {}
    local isADS = player.bIsGunADS or false
    local fovVal = cData.AimTouchHipFOV or 30

    -- [2. NHẬN DIỆN VŨ KHÍ TRỰC TIẾP (GIỐNG HỆT AIMTOUCH)]
    -- Mục đích: Đảm bảo vòng FOV lấy đúng số liệu của vũ khí đang cầm trên tay
    pcall(function()
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not slua.isValid(weapon) and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            local isShotgun, isSniper, isMortar, isCrossbow, isBow = false, false, false, false, false
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then isShotgun = true end
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then isSniper = true end
            if wID == 107011 or wName:lower():find("mortar") or wName:lower():find("cối") then isMortar = true end
            if wID == 107001 or wID == 107007 or wID == 107020 or wName:find("Crossbow") then isCrossbow = true end
            if wID == 107008 or wID == 107009 or wName:find("Bow") then isBow = true end

            if isMortar then fovVal = 360
            elseif isCrossbow then fovVal = cData.AimTouchCrossbowFOV or 40
            elseif isBow then fovVal = cData.AimTouchBowFOV or 40
            elseif isShotgun then fovVal = cData.AimTouchSGFOV or 40
            elseif isADS then
                if isSniper then fovVal = cData.AimTouchSniperFOV or 20
                else fovVal = cData.AimTouchScopeFOV or 30 end
            else
                fovVal = cData.AimTouchHipFOV or 30
            end
        end
    end)

    -- [3. TÍNH TOÁN KÍCH THƯỚC MÀN HÌNH Y HỆT AIMTOUCH ĐỂ KHỚP SIZE 100%]
    local vpX, vpY = 1920, 1080
    pcall(function()
        local ui_util = require("client.common.ui_util")
        if ui_util then
            local vp = ui_util.GetViewportSize()
            if vp and vp.X > 0 then 
                vpX = vp.X 
                vpY = vp.Y 
            end
        end
    end)

    local rawCX = vpX / 2.0
    local rawCY = vpY / 2.0

    -- Tính Bán Kính FOV tuyệt đối theo công thức AimTouch
    local rawRadius = (fovVal / 100.0) * (vpX / 2.0)

    -- [4. TỰ ĐỘNG KHÔI PHỤC UI NẾU BỊ XÓA]
    if _G.FovCircleOverlay.Container and slua.isValid(_G.FovCircleOverlay.Container) then
        local parent = nil
        pcall(function() parent = _G.FovCircleOverlay.Container:GetParent() end)
        if not parent or not slua.isValid(parent) then
            _G.FovCircleOverlay.Container = nil
        end
    end

    if not _G.FovCircleOverlay.Create() then return end
    pcall(function() _G.FovCircleOverlay.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)

    -- [5. ĐỘC LẬP TỌA ĐỘ CANVAS (KHÔNG DÙNG CHUNG VỚI PLAYERMAPMARKER CỦA ESP NỮA)]
    local parentCanvas = nil
    pcall(function() parentCanvas = _G.FovCircleOverlay.Container:GetParent() end)
    
    local scaleX, scaleY, offsetX, offsetY = 1.0, 1.0, 0, 0
    local successTransform = false
    
    if parentCanvas and slua.isValid(parentCanvas) then
        pcall(function()
            local SlateBlueprintLibrary = import("SlateBlueprintLibrary") or import("/Script/UMG.SlateBlueprintLibrary")
            if SlateBlueprintLibrary and SlateBlueprintLibrary.AbsoluteToLocal then
                local cg = parentCanvas:GetCachedGeometry()
                if cg then
                    local FVector2D = import("Vector2D")
                    local pt0 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D and FVector2D(0, 0) or {X=0,Y=0})
                    local pt1 = SlateBlueprintLibrary.AbsoluteToLocal(cg, FVector2D and FVector2D(100, 100) or {X=100,Y=100})
                    if pt0 and pt1 then
                        scaleX = (pt1.X - pt0.X) / 100
                        scaleY = (pt1.Y - pt0.Y) / 100
                        offsetX = pt0.X
                        offsetY = pt0.Y
                        successTransform = true
                    end
                end
            end
        end)
    end
    
    -- Nếu tính qua geometry thất bại (khi UI chưa render xong), tự fallback bằng tỷ lệ UI
    if not successTransform then
        pcall(function()
            local WidgetLayoutLibrary = import("WidgetLayoutLibrary") or import("/Script/UMG.WidgetLayoutLibrary")
            if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then
                local scale = WidgetLayoutLibrary.GetViewportScale(pc)
                if scale and scale > 0 then
                    scaleX = 1.0 / scale
                    scaleY = 1.0 / scale
                end
            end
        end)
    end

    -- Tọa độ và Kích thước vẽ UI
    local centerX = rawCX * scaleX + offsetX
    local centerY = rawCY * scaleY + offsetY
    local targetRadius = rawRadius * scaleX

    local colIdx = tonumber(cData.EspFovCircle_Color) or 7

    -- Tối ưu hóa: Không vẽ lại khung nếu tọa độ/thông số không đổi
    if _G.FovCircleOverlay.LastRadius == targetRadius and _G.FovCircleOverlay.LastColor == colIdx and _G.FovCircleOverlay.LastCX == centerX and _G.FovCircleOverlay.LastCY == centerY then
        return
    end

    _G.FovCircleOverlay.LastRadius = targetRadius
    _G.FovCircleOverlay.LastColor = colIdx
    _G.FovCircleOverlay.LastCX = centerX
    _G.FovCircleOverlay.LastCY = centerY

    local FLinearColor = import("LinearColor") or _G.FLinearColor
    local r, g, b = GetFOVColor(colIdx)
    local dim = 0.55 
    local color = FLinearColor and FLinearColor(r * dim, g * dim, b * dim, 1.0) or {R=r*255, G=g*255, B=b*255, A=255}

    local numSegments = _G.FovCircleOverlay.NumSegments
    local angleStep = 360.0 / numSegments
    local math_cos = math.cos
    local math_sin = math.sin
    local math_rad = math.rad

    -- [6. VẼ CÁC CẠNH ĐƯỜNG TRÒN LÊN MÀN HÌNH]
    local FVector2D = import("Vector2D")
    pcall(function()
        for i = 1, numSegments do
            local angle1 = math_rad((i - 1) * angleStep)
            local angle2 = math_rad(i * angleStep)

            local x1 = targetRadius * math_cos(angle1)
            local y1 = targetRadius * math_sin(angle1)
            local x2 = targetRadius * math_cos(angle2)
            local y2 = targetRadius * math_sin(angle2)

            local dx = x2 - x1
            local dy = y2 - y1
            local dist = math.sqrt(dx*dx + dy*dy)
            
            local math_atan2 = math.atan2 or math.atan
            local angleDeg = math.deg(math_atan2(dy, dx))

            local line = _G.FovCircleOverlay.Lines[i]
            if line and line.slot and slua.isValid(line.slot) then
                local pos = FVector2D and FVector2D(centerX + x1, centerY + y1) or {X=centerX + x1, Y=centerY + y1}
                local size = FVector2D and FVector2D(dist + 0.8, _G.FovCircleOverlay.Thickness) or {X=dist+0.8, Y=_G.FovCircleOverlay.Thickness}
                
                line.slot:SetPosition(pos)
                line.slot:SetSize(size)
                line.widget:SetRenderAngle(angleDeg)
                
                if line.widget.SetBrushColor then 
                    line.widget:SetBrushColor(color) 
                end
            end
        end
    end)
end

function PlayerMapMarker.AttachTimers() end

function PlayerMapMarker.OnTick()
    if not PlayerMapMarker.bActive then return end
    local curTime = _os_clock()
    
    if not PlayerMapMarker.LastLightTime or (curTime - PlayerMapMarker.LastLightTime > 0.03) then
        PlayerMapMarker.LastLightTime = curTime
        _pcall(PlayerMapMarker.UpdateESPLight)
    end
    
    if not PlayerMapMarker.LastDistTime or (curTime - PlayerMapMarker.LastDistTime > 0.2) then
        PlayerMapMarker.LastDistTime = curTime
        if PlayerMapMarker.bUseScreenESP and PlayerMapMarker.bShowDistance then
            _pcall(PlayerMapMarker.UpdateESPDistances)
        end
    end

    if not PlayerMapMarker.LastScanTime or (curTime - PlayerMapMarker.LastScanTime > 0.5) then
        PlayerMapMarker.LastScanTime = curTime
        _pcall(PlayerMapMarker.ScanAndUpdate)
    end
end

function PlayerMapMarker.Start()
    if PlayerMapMarker.bActive then return end
    PlayerMapMarker.bActive = true
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ScanAndUpdate()
end

function PlayerMapMarker.Stop()
    PlayerMapMarker.bActive = false
    PlayerMapMarker._FrameCount = 0
    _pcall(function() PlayerMapMarker.ClearAllESP() end)
    
    PlayerMapMarker._CachedPC = nil
    PlayerMapMarker._CachedGameplayData = nil
    PlayerMapMarker.LastLightTime = nil
    PlayerMapMarker.LastDistTime = nil
    PlayerMapMarker.LastScanTime = nil
    
    PlayerMapMarker._OBHeadWidgetLoadFailed = false 
    PlayerMapMarker.ESPCanvas = nil 
end

_G.PlayerMapMarker = PlayerMapMarker

_G.ProcessIndependentMagicBullet = function()
    pcall(function()
        local isActive = _G.LexusConfig.CustomMagicBullet == true
        local cData = _G.LexusState.CustomTextData or {}
        local mHead = isActive and (tonumber(cData.MagicHead) or 1.0) or 1.0
        local mBody = isActive and (tonumber(cData.MagicBody) or 1.0) or 1.0
        local mLegs = isActive and (tonumber(cData.MagicLegs) or 1.0) or 1.0

        -- FIX VIP: Nếu trạng thái đang Tắt và chưa từng bật Magic trong trận này -> Bỏ qua hoàn toàn (Chống Ban Mạng)
        if not isActive and not _G.MagicWasEverActive then return end
        if isActive then _G.MagicWasEverActive = true end

        local currentHash = isActive and ("M_"..tostring(mHead).."_"..tostring(mBody).."_"..tostring(mLegs)) or "OFF"
        
        if _G.LexusState.LastMagicConfigHash ~= currentHash then
            _G.LexusState.MagicUpdateVersion = (_G.LexusState.MagicUpdateVersion or 0) + 1
            _G.LexusState.LastMagicConfigHash = currentHash
        end

        local BoneScaleMap = {
            ["head"] = mHead, ["neck_01"] = mHead, 
            ["pelvis"] = mBody, ["spine_01"] = mBody, ["spine_02"] = mBody, ["spine_03"] = mBody,
            ["thigh_l"] = mLegs, ["thigh_r"] = mLegs, ["calf_l"] = mLegs, ["calf_r"] = mLegs, ["foot_l"] = mLegs, ["foot_r"] = mLegs    
        }

        local enemies = _G.MainLoopEnemyCache or {}
        
        for _, enemy in ipairs(enemies) do
            if slua.isValid(enemy) then
                local eKey = GetSafeEnemyKey(enemy)
                _G.LexusState.EnemyMarks[eKey] = _G.LexusState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.LexusState.EnemyMarks[eKey]
                
                local EnemyMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil)
                
                if slua.isValid(EnemyMesh) then
                    local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                    
                    -- Chỉ chạy xử lý nếu Hash cấu hình thay đổi HOẶC gặp địch mới (Chống Loop Ghi Memory)
                    if markData.MagicBulletHash ~= currentHash or markData.MagicTargetID ~= uniqueID then
                        
                        local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                        if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then 
                            PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset 
                        end

                        if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                            local PhysAssetName = "DefaultPhys"
                            pcall(function() PhysAssetName = PhysicsAsset:GetName() end)
                            
                            if not _G.AK_OrigHitboxes then _G.AK_OrigHitboxes = {} end
                            if not _G.AK_OrigHitboxes[PhysAssetName] then _G.AK_OrigHitboxes[PhysAssetName] = {} end
                            local OrigHitboxData = _G.AK_OrigHitboxes[PhysAssetName]

                            local SkeletalBodySetups = PhysicsAsset.SkeletalBodySetups
                            local numSetups = type(SkeletalBodySetups.Num) == "function" and SkeletalBodySetups:Num() or #SkeletalBodySetups
                            local limit = numSetups > 50 and 50 or numSetups

                            local function GetFirstElemSafe(elemArray)
                                if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                                    if type(elemArray.Get) == "function" then return elemArray:Get(0) end
                                elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then return elemArray[1] end
                                return nil
                            end

                            local isModifiedAny = false

                            for i = 1, limit do 
                                local BodySetup = type(SkeletalBodySetups.Get) == "function" and SkeletalBodySetups:Get(i-1) or SkeletalBodySetups[i]
                                if slua.isValid(BodySetup) then
                                    local LowerBoneName = string.lower(tostring(BodySetup.BoneName))
                                    local MatchedBoneKey = nil
                                    for k, _ in pairs(BoneScaleMap) do
                                        if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end
                                    end

                                    if MatchedBoneKey then
                                        local TargetScale = BoneScaleMap[MatchedBoneKey]
                                        
                                        local AggGeom = BodySetup.AggGeom
                                        local BoxElems = AggGeom and AggGeom.BoxElems or BodySetup.BoxElems
                                        local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                        local SphylElems = AggGeom and AggGeom.SphylElems or BodySetup.SphylElems

                                        local BoxElem = GetFirstElemSafe(BoxElems)
                                        local SphereElem = GetFirstElemSafe(SphereElems)
                                        local SphylElem = GetFirstElemSafe(SphylElems)

                                        -- Chỉ lưu Hitbox zin gốc ở lần đầu tiên chạm vào
                                        if not OrigHitboxData[MatchedBoneKey] then
                                            OrigHitboxData[MatchedBoneKey] = { Box = nil, Sphere = nil, Sphyl = nil }
                                            if BoxElem then OrigHitboxData[MatchedBoneKey].Box = { X = BoxElem.X, Y = BoxElem.Y, Z = BoxElem.Z } end
                                            if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                            if SphylElem then OrigHitboxData[MatchedBoneKey].Sphyl = { Radius = SphylElem.Radius, Length = SphylElem.Length } end
                                        end

                                        local OrigElemData = OrigHitboxData[MatchedBoneKey]

                                        if OrigElemData then
                                            if OrigElemData.Box and BoxElem then
                                                BoxElem.X = OrigElemData.Box.X * TargetScale; BoxElem.Y = OrigElemData.Box.Y * TargetScale; BoxElem.Z = OrigElemData.Box.Z * TargetScale
                                                if type(BoxElems.Set) == "function" then BoxElems:Set(0, BoxElem) else BoxElems[1] = BoxElem end
                                                if AggGeom then AggGeom.BoxElems = BoxElems; BodySetup.AggGeom = AggGeom else BodySetup.BoxElems = BoxElems end
                                                isModifiedAny = true
                                            end

                                            if OrigElemData.Sphere and SphereElem then
                                                SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                isModifiedAny = true
                                            end

                                            if OrigElemData.Sphyl and SphylElem then
                                                SphylElem.Radius = OrigElemData.Sphyl.Radius * TargetScale; SphylElem.Length = OrigElemData.Sphyl.Length * TargetScale
                                                if type(SphylElems.Set) == "function" then SphylElems:Set(0, SphylElem) else SphylElems[1] = SphylElem end
                                                if AggGeom then AggGeom.SphylElems = SphylElems; BodySetup.AggGeom = AggGeom else BodySetup.SphylElems = SphylElems end
                                                isModifiedAny = true
                                            end
                                        end
                                    end
                                end
                            end
                            
                            -- CẬP NHẬT GÓI VẬT LÝ VÀO GAME
                            if isModifiedAny then
                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset
                            end
                            
                            -- Đánh dấu là đã xử lý
                            markData.MagicBulletHash = currentHash
                            markData.MagicTargetID = uniqueID 
                        end
                    end
                end
            end
        end
    end)
end

local function MainLoop() 
    if isExpired then return end
    
    -- [TỐI ƯU]: Gọi require 1 lần duy nhất
    if not Cached_GameplayData then 
        Cached_GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData") 
    end
    if not Cached_KismetSystemLibrary then
        Cached_KismetSystemLibrary = import("KismetSystemLibrary")
    end
    
    _pcall(function()
        if Cached_KismetSystemLibrary and not _G.FakeHWID_Hooked then
            _G.FakeHWID_Hooked = true
        end
    end)

    if not Cached_GameplayData then return end 
    local pc = Cached_GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 
 
    -- =========================================================
    -- [ SMART CLEANUP ] - XÓA SẠCH RAM ĐÚNG 1 LẦN KHI RA SẢNH
    -- =========================================================
    if not Valid(localPlayer) then
        if _G.LexusState.MatchActive then
            _G.LexusState.MatchActive = false -- Đánh dấu đã ra sảnh
            
            -- [FIX BUG FOV]: Tiêu diệt UI Vòng FOV cũ kĩ của trận trước, chống kẹt tàng hình ở trận sau
            if _G.FovCircleOverlay and slua.isValid(_G.FovCircleOverlay.Container) then
                pcall(function() 
                    _G.FovCircleOverlay.Container:RemoveFromParent()
                    _G.FovCircleOverlay.Container:ConditionalBeginDestroy()
                end)
                _G.FovCircleOverlay.Container = nil
            end

            -- 1. Xóa Map Marks an toàn
            if _G.LexusState.TrackedMarks then
                for markId, _ in pairs(_G.LexusState.TrackedMarks) do
                    SafeRemoveMark(markId)
                end
            end
            _G.LexusState.TrackedMarks = {} 
            
            -- 2. Cắt đứt toàn bộ tham chiếu Metatable C++ của Enemy
            if _G.LexusState.EnemyMarks then
                for key, data in pairs(_G.LexusState.EnemyMarks) do
                    if data.radarMark and data.radarMark ~= 0 then SafeRemoveMark(data.radarMark) end
                    if data.hpMark and data.hpMark ~= 0 then SafeRemoveMark(data.hpMark) end
                    if data.distMark and data.distMark ~= 0 then SafeRemoveMark(data.distMark) end
                    
                    if data.MIDs then 
                        for _, midTable in pairs(data.MIDs) do 
                            for k in pairs(midTable) do midTable[k] = nil end 
                        end 
                    end
                    if data.MIDs_V3 then 
                        for _, midTable in pairs(data.MIDs_V3) do 
                            for k in pairs(midTable) do midTable[k] = nil end 
                        end 
                    end
                    -- Xóa trắng data để cắt đứt liên kết
                    for k in pairs(data) do data[k] = nil end
                    _G.LexusState.EnemyMarks[key] = nil
                end
            end
            
            -- Reset toàn bộ biến Cache lớn
            _G.LexusState.EnemyMarks = {}
            _G.AK_OrigHitboxes = {}
            _G.AK_ModdedPhysAssets = {}
            _G.LexusState.PrevGraphicsState = {}
            _G.AimTouchVisCache = {}
            
            if _G.MainLoopEnemyCache then
                for k in pairs(_G.MainLoopEnemyCache) do _G.MainLoopEnemyCache[k] = nil end
            end
            _G.CachedActiveBombs = nil
            _G.CachedItemBombs = nil
            _G.CachedVehicles = nil
            
            _G.ConsoleNewWallReady = false
            _G.ConsoleOutlineReady = false
            _G.HasRecoilTargetCached = false
            
            if _G.CleanUpEnemyCounterWidget then _G.CleanUpEnemyCounterWidget() end
            if _G.PlayerMapMarker and _G.PlayerMapMarker.bActive then
                _G.PlayerMapMarker.Stop()
            end
            
            -- 3. Lệnh Thần Thánh: Ép Lua gom rác NGAY LẬP TỨC 1 LẦN DUY NHẤT
            collectgarbage("collect")
        end
        return -- Dừng MainLoop tại đây để sảnh cực kì mượt mà
    end

    -- Đánh dấu đang trong trận
    _G.LexusState.MatchActive = true

    -- Lấy thời gian chuẩn 1 lần cho cả vòng lặp
    local currentGlobalTime = _os_clock()

    local Cached_PPM = nil
    _pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    
    if not Cached_SecurityCommonUtils then
        _pcall(function() Cached_SecurityCommonUtils = package.loaded["GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"] or require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    end
    
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.LexusConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowLexusVIPMenu()
    _M_DrawCounter()
    
    if _G.FovCircleOverlay then _G.FovCircleOverlay.Update(pc, localPlayer) end
    
    if _G.LexusConfig.WallVehicle or _G.LexusConfig.EspItem_Master then
        _G.RunOptimizedItemAndVehicleESP(pc)
    end
    
    if _G.LexusConfig.EspLoai9 then
        if _G.PlayerMapMarker then
            if not _G.PlayerMapMarker.bActive then
                _G.PlayerMapMarker.Start()
            end
            _G.PlayerMapMarker.OnTick()
        end
    else
        if _G.PlayerMapMarker and _G.PlayerMapMarker.bActive then
            _G.PlayerMapMarker.Stop()
        end
    end
    
    -- [ SIÊU TỐI ƯU POV (IPAD VIEW) ĐÃ FIX LỖI NHÁY SCOPE ]
        _pcall(function()
            local isAiming = false
            if localPlayer.bIsWeaponAiming or localPlayer.bIsGunADS then isAiming = true end

            local currentVehicle = localPlayer.CurrentVehicle or (_type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
            local isInVehicle = Valid(currentVehicle) or localPlayer.bIsInVehicle

            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            local uVehCam = localPlayer.VehicleCameraComponent

            -- 1. XOÁ CÁC CAN THIỆP CAMERA TOÀN CỤC (Bắt buộc để không bị lỗi Ipad View trên Máy Bay, Sảnh, Dù...)
            if not isInVehicle or isAiming or not _G.LexusConfig.IpadViewVehicle then
                if _type(pc.FOV) == "function" then pc:FOV(0) end
                local camMgr = pc.PlayerCameraManager
                if Valid(camMgr) and _type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
            end

            -- 2. IPAD VIEW ĐI BỘ
            if not isInVehicle then
                -- [FIX] Chỉ can thiệp FOV khi KHÔNG ngắm bắn
                if not isAiming then 
                    if _G.LexusConfig.IpadView and _G.LexusState.CustomTextData then
                        local targetTPP = _G.LexusState.CustomTextData.IpadViewFOV or 120
                        if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then 
                            uTPPCam.FieldOfView = targetTPP 
                        end
                    else
                        -- Chỉ trả về 90 khi công tắc IpadView BỊ TẮT
                        if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then 
                            uTPPCam.FieldOfView = 90 
                        end
                    end
                end
            end

            -- 3. IPAD VIEW TRÊN XE
            if isInVehicle then
                -- [FIX] Không can thiệp FOV khi đang nhoài người ra cửa xe để ngắm bắn
                if not isAiming then 
                    if _G.LexusConfig.IpadViewVehicle and _G.LexusState.CustomTextData then
                        local targetVeh = _G.LexusState.CustomTextData.IpadViewVehicleFOV or 120
                        
                        -- Chỉnh Component xe
                        if Valid(uVehCam) and uVehCam.FieldOfView ~= targetVeh then 
                            uVehCam.FieldOfView = targetVeh 
                        end
                        
                        -- Ép Camera Cấp Cao để xe không bị khoá góc nhìn
                        if targetVeh > 90 then
                            if _type(pc.FOV) == "function" then pc:FOV(targetVeh) end
                            local camMgr = pc.PlayerCameraManager
                            if Valid(camMgr) then
                                camMgr.DefaultFOV = targetVeh
                                if _type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetVeh) end
                            end
                        end
                    else
                        -- Trả về 90 khi tắt iPad View Xe
                        if Valid(uVehCam) and uVehCam.FieldOfView ~= 90 then 
                            uVehCam.FieldOfView = 90 
                        end
                    end
                end
            end
        end)
    if _G.LexusConfig.AimTouchEnable and _G.AimTouch then
        _G.AimTouch()
    end    
    if not _G.LastGlowTime or (_os_clock() - _G.LastGlowTime) > 0.5 then
        _G.LastGlowTime = _os_clock()
        if _G.ApplyWeaponGlow then _G.ApplyWeaponGlow(localPlayer) end
    end
    _pcall(function()
        if _G.LexusConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.LexusState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = _os_clock()
                if not _G.RecoilTargetCacheTime or (curTime - _G.RecoilTargetCacheTime) > 0.2 then
                    _G.RecoilTargetCacheTime = curTime
                    _G.HasRecoilTargetCached = false
                    local ui_util = require("client.common.ui_util")
                    if ui_util then
                        local viewportSize = ui_util.GetViewportSize()
                        if viewportSize then
                            local centerX = viewportSize.X * 0.5
                            local centerY = viewportSize.Y * 0.5
                            local FOV_RADIUS = (6 / 100.0) * (viewportSize.X / 2.0) 
                            local enemies = _G.GetEnemyTargetsFromActors(40000) 
                            if enemies and #enemies > 0 then
                                local FVector2D = import("Vector2D")
                                for _, target in _ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = _type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if _math_sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
                                                    _G.HasRecoilTargetCached = true
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if _G.HasRecoilTargetCached then
                    local currentRot = pc:GetControlRotation()
                    if currentRot then
                        local pullDownForce = (outerRecoilVal / 50.0) * 1.5
                        currentRot.Pitch = currentRot.Pitch - pullDownForce
                        pc:SetControlRotation(currentRot, "CustomAimbotRecoil")
                    end
                end
            end
        else
            _G.HasRecoilTargetCached = false
        end
    end)
    if _G.LexusConfig.ModSkin then
        local curTime = _os_clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 2.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.HandlePetLogic then _G.HandlePetLogic() end
                    if _G.LexusConfig.SkinDeadBox and _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then
                        _G.DeadBox_TemperRequest(pc)
                    end
                    if _G.AddOutfit then
                        if _G.AddOutfit.isInRealMatch() then
                            _G.AddOutfitLobbyRestored = false 
                            local ticker = require("common.time_ticker")
                            if ticker and ticker.AddTimerOnce then
                                _G.AddOutfit.matchApplyAllSlots(localPlayer)
                                ticker.AddTimerOnce(0.2, function() if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() then _G.AddOutfit.matchApplyHat(localPlayer) end end)
                                ticker.AddTimerOnce(0.4, function() if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() then _G.AddOutfit.matchApplyWeaponSkin(localPlayer) end end)
                                ticker.AddTimerOnce(0.6, function() if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() and _G.AddOutfit.isCharacterAirborne(localPlayer) then _G.AddOutfit.applyAirborneSlots(localPlayer, true) end end)
                            else
                                _G.AddOutfit.matchApplyAllSlots(localPlayer)
                                _G.AddOutfit.matchApplyHat(localPlayer)
                                _G.AddOutfit.matchApplyWeaponSkin(localPlayer)
                                if _G.AddOutfit.isCharacterAirborne(localPlayer) then _G.AddOutfit.applyAirborneSlots(localPlayer, true) end
                            end
                        else
                            _G.AddOutfit.reapplyLobbyEquipped()
                        end
                    end
                end
            end)
        end
    end

    pcall(function()
        if Valid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false end
        end
    end)


    if _G.LexusConfig.WallClimb then
        _pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) then
                if not _G.LexusState.WallClimbOriginals then _G.LexusState.WallClimbOriginals = { WalkableFloorAngle = charMove.WalkableFloorAngle, MaxStepHeight = charMove.MaxStepHeight } end
                charMove.WalkableFloorAngle = 199.0
                charMove.MaxStepHeight = 999.0
                _G.LexusState.WallClimbApplied = true
            end
        end)
    elseif _G.LexusState.WallClimbApplied then
        _pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) and _G.LexusState.WallClimbOriginals then
                charMove.WalkableFloorAngle = _G.LexusState.WallClimbOriginals.WalkableFloorAngle or 50.0
                charMove.MaxStepHeight = _G.LexusState.WallClimbOriginals.MaxStepHeight or 45.0
            end
        end)
        _G.LexusState.WallClimbApplied = false
    end

    if _G.LexusConfig.FastCar then
        _pcall(function()
            local currentVehicle = localPlayer.CurrentVehicle or (_type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
            if Valid(currentVehicle) then
                local rootComp = currentVehicle.RootComponent or (_type(currentVehicle.K2_GetRootComponent) == "function" and currentVehicle:K2_GetRootComponent())
                if Valid(rootComp) and _type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                    local isAccelerating = false
                    local moveComp = currentVehicle.VehicleMovement or currentVehicle.MovementComponent
                    if Valid(moveComp) then
                        local throttle = moveComp.ThrottleInput or 0
                        if _type(moveComp.GetThrottleInput) == "function" then throttle = moveComp:GetThrottleInput() end
                        if throttle > 0.05 or throttle < -0.05 then isAccelerating = true end
                    end
                    if currentVehicle.bIsPressingGas or (currentVehicle.Throttle and currentVehicle.Throttle ~= 0) then isAccelerating = true end

                    local currentVel = nil
                    if _type(currentVehicle.GetVelocity) == "function" then currentVel = currentVehicle:GetVelocity()
                    elseif _type(rootComp.GetPhysicsLinearVelocity) == "function" then currentVel = rootComp:GetPhysicsLinearVelocity()
                    elseif rootComp.ComponentVelocity then currentVel = rootComp.ComponentVelocity end

                    if currentVel then
                        local speedVal = _G.LexusState.CustomTextData.FastCarSpeed or 0
                        -- Chỉ can thiệp lực đẩy nếu tốc độ tùy chỉnh lớn hơn 0
                        if speedVal > 0 then
                            local currentSpeed = _math_sqrt(currentVel.X^2 + currentVel.Y^2)
                            -- Tính hệ số gia tốc: 1.0 là gốc. 50 là x1.5, 100 là x2.0, 200 là x3.0
                            local customSpeed = 1.0 + (speedVal / 100.0)
                            local minSpeedToBoost, maxSpeed, accelFactor, brakeFactor = 50.0, 5000.0, customSpeed, 0.85       
                            if currentSpeed > minSpeedToBoost then
                                local dirX, dirY = currentVel.X / currentSpeed, currentVel.Y / currentSpeed
                                if isAccelerating then
                                    local targetSpeed = currentSpeed * accelFactor
                                    if targetSpeed > maxSpeed then targetSpeed = maxSpeed end
                                    rootComp:SetAllPhysicsLinearVelocity(FVector(dirX * targetSpeed, dirY * targetSpeed, currentVel.Z), false)
                                else
                                    local targetSpeed = currentSpeed * brakeFactor
                                    if targetSpeed > minSpeedToBoost then
                                        rootComp:SetAllPhysicsLinearVelocity(FVector(dirX * targetSpeed, dirY * targetSpeed, currentVel.Z), false)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    _pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.LexusConfig.RemoveGrass and not _G.LexusState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("foliage.DensityScale", "1"); gi:ExecuteCMD("r.Foliage.DensityScale", "1"); gi:ExecuteCMD("foliage.MinimumScreenSize", "0.0001"); gi:ExecuteCMD("r.DisableTreeRender", "0")
                _G.LexusState.PrevGraphicsState.RemoveTrees = false
            end
            if _G.LexusConfig.RemoveFog and not _G.LexusState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1"); gi:ExecuteCMD("r.Fog", "0"); gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.LexusState.PrevGraphicsState.RemoveFog = true
            elseif not _G.LexusConfig.RemoveFog and _G.LexusState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1"); gi:ExecuteCMD("r.Fog", "1"); gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.LexusState.PrevGraphicsState.RemoveFog = false
            end
            if _G.LexusConfig.WhiteBody and not _G.LexusState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2"); gi:ExecuteCMD("r.CharacterDiffusePower", "5"); gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.LexusState.PrevGraphicsState.WhiteBody = true
            elseif not _G.LexusConfig.WhiteBody and _G.LexusState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0"); gi:ExecuteCMD("r.CharacterDiffusePower", "1"); gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.LexusState.PrevGraphicsState.WhiteBody = false
            end
            if _G.LexusConfig.CustomBrightnessEnable then
                local actualBright = (_G.LexusState.CustomTextData.CustomBrightnessValue or 10) / 10.0
                if actualBright <= 0 then actualBright = 0.01 end                 
                gi:ExecuteCMD("r.Mobile.Brightness", _tostring(actualBright))
                _G.LexusState.PrevGraphicsState.CustomBrightness = true
            elseif not _G.LexusConfig.CustomBrightnessEnable and _G.LexusState.PrevGraphicsState.CustomBrightness then
                gi:ExecuteCMD("r.Mobile.Brightness", "1.0")
                _G.LexusState.PrevGraphicsState.CustomBrightness = false
            end
            if _G.LexusConfig.ColorBodyV2 and not _G.LexusState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "4"); gi:ExecuteCMD("r.CharacterDiffuseOffset", "200"); gi:ExecuteCMD("r.CharacterDiffusePower", "200")
                _G.LexusState.PrevGraphicsState.ColorBodyV2 = true
            elseif not _G.LexusConfig.ColorBodyV2 and _G.LexusState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1"); gi:ExecuteCMD("r.CharacterDiffuseOffset", "0"); gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.LexusState.PrevGraphicsState.ColorBodyV2 = false
            end
            if _G.LexusConfig.ColorBodyV3 then
                -- Đã giảm mặc định xuống mức 2 để màu sắc hiện rõ nhưng không chói
                local currentV3Glow = _G.LexusState.CustomTextData.V3_Glow or 2 
                if not _G.LexusState.PrevGraphicsState.ColorBodyV3 or _G.LexusState.PrevGraphicsState.LastV3Glow ~= currentV3Glow then
                    -- FIX: Chuyển DiffuseOffset và DiffusePower từ "500" xuống "1" hoặc "2"
                    gi:ExecuteCMD("r.CharacterMinShadowFactor", tostring(currentV3Glow)); 
                    gi:ExecuteCMD("r.CharacterDiffuseOffset", "1"); 
                    gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                    _G.LexusState.PrevGraphicsState.ColorBodyV3 = true; _G.LexusState.PrevGraphicsState.LastV3Glow = currentV3Glow
                end
            elseif not _G.LexusConfig.ColorBodyV3 and _G.LexusState.PrevGraphicsState.ColorBodyV3 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1"); gi:ExecuteCMD("r.CharacterDiffuseOffset", "0"); gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.LexusState.PrevGraphicsState.ColorBodyV3 = false; _G.LexusState.PrevGraphicsState.LastV3Glow = nil
            end
            if _G.LexusConfig.BlackSky and not _G.LexusState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.LexusState.PrevGraphicsState.BlackSky = true
            elseif not _G.LexusConfig.BlackSky and _G.LexusState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.LexusState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    _pcall(function()
        local weapon = nil
        _pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and _type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if _type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif _type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then _table_insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then _table_insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponEntityComponent) then 
                _table_insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
            end

            local cData = _G.LexusState.CustomTextData or {}
            local isAimbotV1On = _G.LexusConfig.AimbotV1

            for _, entity in _ipairs(entities) do
                -- CHỈ KHI NÚT "BẬT AIMBOT V1" ĐƯỢC GẠT LÊN THÌ MỚI ÁP DỤNG THÔNG SỐ
                if isAimbotV1On then
                    local thuTam = cData.ThuTam or 0
                    local giamGiatNgang = cData.GiamGiatNgang or 0
                    local giamGiatDoc = cData.GiamGiatDoc or 0
                    local giamRungScope = cData.GiamRungScope or 0

                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end
                    
                    -- 1. THU NHỎ TÂM (Crosshair)
                    if thuTam > 0 then
                        entity.GameDeviationFactor = 3.36 - (3.36 * (thuTam / 100.0))
                    end
                    
                    -- 2. GIẢM GIẬT NGANG (HRecoil)
                    if giamGiatNgang > 0 then
                        entity.AccessoriesHRecoilFactor = 0.80 - (0.80 * (giamGiatNgang / 100.0))
                    end
                    
                    -- 3. GIẢM GIẬT DỌC (VRecoil)
                    if giamGiatDoc > 0 then
                        entity.AccessoriesVRecoilFactor = 0.50 - (0.50 * (giamGiatDoc / 100.0))
                    end
                    
                    -- 4. GIẢM RUNG SCOPE (Scope Recoil)
                    -- 4. GIẢM RUNG SCOPE (Scope Recoil)
                    if giamRungScope > 0 then
                        entity.RecoilKickADS = 0.20 - (0.20 * (giamRungScope / 100.0))
                    end
                    
                    -- =============================================
                    -- 5. ĐẠN THẲNG (NO SPREAD)
                    -- =============================================
                    if _G.LexusConfig.DanThang then 
                        entity.GameDeviationAccuracy = 0.0 
                    end
                    
                    -- 5. AIMBOT V1 LOGIC
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        local aimSpeedVal = 3.0 + (3.0 * ((cData.SpeedAimbotV1 or 0) / 100.0))
                        local aimFovVal = 1.5 + (1.5 * ((cData.FovAimbotV1 or 0) / 100.0))
                        
                        if entity.AutoAimingConfig.OuterRange then
                            entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            entity.AutoAimingConfig.OuterRange.Speed = aimSpeedVal
                            entity.AutoAimingConfig.OuterRange.SpeedRate = aimSpeedVal
                            entity.AutoAimingConfig.OuterRange.RangeRate = aimFovVal
                            entity.AutoAimingConfig.OuterRange.RangeRateSight = aimFovVal
                            entity.AutoAimingConfig.OuterRange.SpeedRateSight = aimSpeedVal
                        end
                        if entity.AutoAimingConfig.InnerRange then
                            entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            entity.AutoAimingConfig.InnerRange.Speed = aimSpeedVal
                            entity.AutoAimingConfig.InnerRange.SpeedRate = aimSpeedVal
                            entity.AutoAimingConfig.InnerRange.RangeRate = aimFovVal
                            entity.AutoAimingConfig.InnerRange.RangeRateSight = aimFovVal
                            entity.AutoAimingConfig.InnerRange.SpeedRateSight = aimSpeedVal
                        end
                    end
                    
                    entity.LexusWeaponModsActive = true

                -- NẾU CÔNG TẮC BỊ TẮT, TRẢ VỀ ZIN 100%
                elseif entity.LexusWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.LexusWeaponModsActive = false
                end
            end
        end
    end)

    -- =========================================================================
    -- [SIÊU TỐI ƯU] HỆ THỐNG ESP QUÉT ĐỊCH & RENDERING
    -- =========================================================================
    pcall(function()
        local curClock = _os_clock()
        -- THUẬT TOÁN CACHE: Cập nhật danh sách người chơi thực 0.5s/lần thay vì mỗi frame
        if not _G.MainLoopEnemyCacheTime or (curClock - _G.MainLoopEnemyCacheTime > 0.5) then
            _G.MainLoopEnemyCacheTime = curClock
            local rawList = {}
            if GameplayData.GetAllPlayerCharacters then rawList = GameplayData.GetAllPlayerCharacters()
            elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(rawList, char) end end
            
            local validList = {}
            local myTeam = localPlayer.TeamID or (type(localPlayer.GetTeamID) == "function" and localPlayer:GetTeamID()) or -1
            
            for _, char in pairs(rawList) do
                if Valid(char) and char ~= localPlayer then
                    local isDead = char.HealthStatus == 2 or char.HealthStatus == 3
                    local eTeam = char.TeamID or (type(char.GetTeamID) == "function" and char:GetTeamID()) or -2
                    -- Lọc sạch: Chỉ lấy địch còn sống và khác team
                    if not isDead and eTeam ~= myTeam then
                        table.insert(validList, char)
                    end
                end
            end
            _G.MainLoopEnemyCache = validList
        end

        local allCharacters = _G.MainLoopEnemyCache or {}
        local currentValidKeys = {}
        for _, enemy in ipairs(allCharacters) do
            currentValidKeys[GetSafeEnemyKey(enemy)] = true
        end
        
        -- Dọn rác MIDs cho các kẻ địch đã mất tích
        for key, data in pairs(_G.LexusState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then _G.AimTouchVisCache[key] = nil end
                if data.MIDs then for _, mTable in pairs(data.MIDs) do for k in pairs(mTable) do mTable[k]=nil end end data.MIDs = nil end
                if data.MIDs_V3 then for _, mTable in pairs(data.MIDs_V3) do for k in pairs(mTable) do mTable[k]=nil end end data.MIDs_V3 = nil end
                data.enemy = nil
                data.CachedMeshes = nil
                _G.LexusState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and _type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if _type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and _type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end
        
        local mLoc = nil
        _pcall(function() if _type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)


        local FVector2D = nil
        if _G.LexusConfig.EspXuong or _G.LexusConfig.EspTenText or _G.LexusConfig.EspMauDocText or _G.LexusConfig.EspKhoangCachText or _G.LexusConfig.EspChiTiet then
            FVector2D = import("Vector2D")
        end

        for _, enemy in ipairs(allCharacters) do
            if Valid(enemy) then
                local eKey = GetSafeEnemyKey(enemy)
                _G.LexusState.EnemyMarks[eKey] = _G.LexusState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.LexusState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if markData.lastEnemyActor ~= enemy then
                    if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                    if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                    markData.lastEnemyActor = enemy
                    markData.LastUIComp = nil
                    markData.LastFrameUIState = nil
                end
                
                local eMesh = nil
                _pcall(function() eMesh = enemy.Mesh or (_type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                local aLoc = nil
                _pcall(function() if _type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                
                local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                local isBot = markData.AK_IS_BOT or false

                -- [ĐÃ TỐI ƯU HÓA: CHỈ CHẠY WALL NEW V3]
                if _G.LexusConfig.ColorBodyV3 then 
                    ApplyColorBodyV3(enemy, markData) 
                else 
                    UndoColorBodyV3(enemy, markData) 
                end

                _pcall(function()
                    if Valid(eMesh) then
                        local targetScale = 1.0
                        if _G.LexusConfig.BugManEnable and _G.LexusState.CustomTextData then
                            targetScale = 177.0 / (_G.LexusState.CustomTextData.BugManRatio or 133)
                            if targetScale < 1.0 then targetScale = 1.0 end; if targetScale > 2.0 then targetScale = 2.0 end 
                        end
                        if markData.LastFatScale ~= targetScale then
                            eMesh:SetRelativeScale3D(FVector(targetScale, targetScale, 1.0))
                            markData.LastFatScale = targetScale
                        end
                    end
                end)

              

                -- CHỐT CHẶN TỐI ƯU CỰC MẠNH: Tính khoảng cách, nếu trên 400m -> Dừng luôn.
                local distM = 0
                _pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                if distM > 0 and distM <= 400 then
                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.LexusConfig.EspKhungMau
                    
                    _pcall(function()
                        if enemy.Health then currentHp = enemy.Health elseif _type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                        if enemy.HealthMax then maxHp = enemy.HealthMax elseif _type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                    end)
                    if maxHp <= 0 then maxHp = 100 end
                    local hpRatio = currentHp / maxHp
                    local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)

                    -- Kiểm tra xem địch có nằm trong khung hình màn hình không
                    local isOnScreen = false
                    local screenPos = nil
                    if FVector2D and aLoc and pc then
                        _pcall(function()
                            screenPos = FVector2D()
                            isOnScreen = pc:ProjectWorldLocationToScreen(aLoc, screenPos, false)
                        end)
                    end

                    -- CHỈ VẼ XƯƠNG VÀ CHỮ KHI ĐỊCH Ở TRONG MÀN HÌNH
                    if isOnScreen and screenPos and screenPos.X > 0 and screenPos.Y > 0 then
                        
                        -- 1. ESP XƯƠNG
                        if _G.LexusConfig.EspXuong and distM <= 200 then
                            _pcall(function()
                                local tCur = _os_clock()
                                if markData.LastEsp6Time == nil or (tCur - markData.LastEsp6Time) >= 0.05 then
                                    markData.LastEsp6Time = tCur
                                    local MyHUD = Cached_MyHUD
                                    if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                        for _, bName in _ipairs(GLOBAL_BONE_LIST) do
                                            if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                -- Bỏ qua tay chân khi địch ở xa
                                            else
                                                local wLoc = eMesh:GetSocketLocation(bName)
                                                if wLoc then
                                                    local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                    local mark, fixedSize, color = "▪", 0.25, C_CYAN
                                                    if bName == "head" then mark, fixedSize, color = "●", 0.45, C_RED
                                                    elseif bName == "pelvis" or bName == "neck_01" then mark, fixedSize, color = "▪", 0.35, C_YELLOW end
                                                    MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                        end

                        -- 2. ESP TÊN, MÁU V1, KHOẢNG CÁCH (Gộp chung thành 1 Draw Call duy nhất)
                        if _G.LexusConfig.EspTenText or _G.LexusConfig.EspMauDocText then
                        _pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = _math_max(0.55, 0.95 - (distM / 400))
                                    local hpPercent = hpRatio
                                    local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)
                                    
                                    local hpColor = C_GREEN
                                    if hpPercent < 0.3 then hpColor = C_RED
                                    elseif hpPercent < 0.7 then hpColor = C_YELLOW end
                                    if isKnock then hpColor = C_RED end
                                    
                                    if _G.LexusConfig.EspTenText then
                                        local enemyName = "ENEMY"
                                        _pcall(function() if enemy.PlayerName then enemyName = enemy.PlayerName elseif _type(enemy.GetPlayerName) == "function" then enemyName = enemy:GetPlayerName() end end)
                                        if enemyName == "" then enemyName = "ENEMY" end
                                        if isKnock then enemyName = "KNOCK: " .. enemyName end
                                        hud:AddDebugText(enemyName, enemy, 0.06, {X=0, Y=0, Z=-370}, {X=0, Y=0, Z=-370}, C_WHITE, true, false, true, nil, dynamicScale * 1.1, true)
                                    end
                                    
                                    if _G.LexusConfig.EspMauDocText then
                                        if not isKnock then
                                            local segments = 11
                                            local filled = _math_floor(hpPercent * segments)
                                            local startZ = 20
                                            local spacing = 8.0 * dynamicScale 
                                            for j = 1, segments do
                                                local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
                                                hud:AddDebugText("■", enemy, 0.06, {X=0, Y=-115, Z=startZ + (j * spacing)}, {X=0, Y=-115, Z=startZ + (j * spacing)}, color, true, false, true, nil, dynamicScale * 0.8, true)
                                            end
                                            hud:AddDebugText(_string_format("%d%%", _math_floor(hpPercent * 100)), enemy, 0.06, {X=0, Y=-60, Z=startZ - 12}, {X=0, Y=-60, Z=startZ - 12}, hpColor, true, false, true, nil, dynamicScale * 0.6, true)
                                        else
                                            hud:AddDebugText("DOWN", enemy, 0.06, {X=0, Y=-115, Z=50}, {X=0, Y=-115, Z=50}, C_RED, true, false, true, nil, dynamicScale * 1.0, true)
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    if _G.LexusConfig.EspKhoangCachText then
                        _pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = _math_max(0.55, 0.95 - (distM / 400))
                                    hud:AddDebugText(_string_format("[%dm]", _math_floor(distM)), enemy, 0.06, {X=0, Y=115, Z=20}, {X=0, Y=115, Z=20}, C_BLUE_TEXT, true, false, true, nil, dynamicScale * 0.8, true)
                                end
                            end
                        end)
                    end

                        -- 3. ESP CHI TIẾT (Vũ khí, Tư thế)
                    if _G.LexusConfig.EspChiTiet then
                        _pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) then
                                if distM <= 600 then if isBot then aiCount = aiCount + 1 else realCount = realCount + 1 end end
                                
                                if distM <= 400 then
                                    local stateText = ""
                                    
                                    if _G.LexusConfig.EspTuThe then
                                        local pose = nil
                                        if enemy.PoseState then pose = enemy.PoseState
                                        elseif _type(enemy.GetPoseState) == "function" then pose = enemy:GetPoseState() end
                                        
                                        if pose == 0 or pose == "Stand" then stateText = "ĐỨNG"
                                        elseif pose == 1 or pose == "Crouch" then stateText = "NGỒI"
                                        elseif pose == 2 or pose == "Prone" then stateText = "NẰM"
                                        else stateText = "ĐỨNG" end
                                    end
                                    
                                    if _G.LexusConfig.EspVuKhi then
                                        local curTime = _os_clock()
                                        if markData.AK_LAST_WEP_TIME == nil or curTime > markData.AK_LAST_WEP_TIME + 1.5 then
                                            local eWeapon = nil
                                            if enemy.CurrentWeapon then eWeapon = enemy.CurrentWeapon
                                            elseif _type(enemy.GetCurrentWeapon) == "function" then eWeapon = enemy:GetCurrentWeapon()
                                            elseif enemy.WeaponManagerComponent then eWeapon = enemy.WeaponManagerComponent.CurrentWeaponReplicated end
                                            
                                            local weaponName = "TAY KHÔNG"
                                            if Valid(eWeapon) then if _type(eWeapon.GetWeaponName) == "function" then weaponName = eWeapon:GetWeaponName() end end
                                            markData.AK_CACHED_WEP_NAME = _string_upper(_tostring(weaponName))
                                            markData.AK_LAST_WEP_TIME = curTime
                                        end

                                        if stateText ~= "" then
                                            stateText = stateText .. " - " .. (markData.AK_CACHED_WEP_NAME or "TAY KHÔNG")
                                        else
                                            stateText = (markData.AK_CACHED_WEP_NAME or "TAY KHÔNG")
                                        end
                                    end

                                    if stateText ~= "" then
                                    local textColor = isBot and C_CYAN or C_YELLOW
                                    local dynamicScale = _math_max(0.5, 0.8 - (distM / 400))
                                    
                                    -- Đảm bảo đã có vị trí địch (aLoc) và nhân vật của bạn (localPlayer)
                                    if aLoc and Valid(localPlayer) then
                                        -- Lấy hướng BÊN PHẢI của máy quay / nhân vật của BẠN
                                        local pRight = localPlayer:GetActorRightVector()
                                        
                                        -- Tính toán 1 điểm 3D cố định cách địch 80 đơn vị về phía tay phải của bạn
                                        -- Bạn có thể tăng số 80 lên 100 hoặc 120 nếu muốn chữ xa người hơn nữa
                                        local rightPos = {
                                            X = aLoc.X + (pRight.X * 80), 
                                            Y = aLoc.Y + (pRight.Y * 80), 
                                            Z = aLoc.Z + 15 -- Z+15 để chữ ngang thắt lưng
                                        }
                                        
                                        -- Lưu ý: Mình đã đổi tham số thứ 8 từ 'false' thành 'true' (bAbsoluteLocation)
                                        -- Để báo cho game biết hãy ghim chữ cứng ở tọa độ tuyệt đối này!
                                        MyHUD:AddDebugText(stateText, enemy, 0.06, rightPos, rightPos, textColor, true, true, true, nil, dynamicScale, true)
                                    else
                                        -- Dự phòng nếu xảy ra lỗi không lấy được vị trí
                                        local offsetToaDo = {X=0, Y=0, Z=15}
                                        MyHUD:AddDebugText("   " .. stateText, enemy, 0.06, offsetToaDo, offsetToaDo, textColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                                end
                            end
                        end)
                    end
                end -- End isOnScreen

                    -- ========================================================
                    -- ESP GỐC UE4 & KHUNG (Vẽ xuyên tường/không cần check screen)
                    -- ========================================================
                    
                    if _G.LexusConfig.EspMauTrenDau then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, ZERO_VECTOR3, 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                    end

                    if _G.LexusConfig.EspThongTinGoc then
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, ZERO_VECTOR3, 0, "", 4, enemy) end
                    else
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end
                    
                    if _G.LexusConfig.EspRadar360 then
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, ZERO_VECTOR3, 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark); markData.radarMark = nil
                        end
                    end
                    
                    if showFrameUI then
                        _pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (_type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if _type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if _type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        _pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (_type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if _type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if _type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    -- GLOW VIỀN SÁNG ĐỊCH
                    -- GLOW VIỀN SÁNG ĐỊCH
                    if _G.LexusConfig.EspVien then
                        _pcall(function()
                            if not _G.ConsoleOutlineReady then
                                local KismetSystemLibrary = import("KismetSystemLibrary")
                                local world = slua.getWorld()
                                if KismetSystemLibrary and world then
                                    KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                                    KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                                    _G.ConsoleOutlineReady = true
                                end
                            end

                            -- Lấy giá trị màu từ Menu
                            local colorMode = _G.LexusState.CustomTextData.OutlineColor or 4
                            local outlineHash = _tostring(_G.LexusConfig.OutlineThickness) .. "_" .. _tostring(colorMode)
                            
                            local meshes = GetAllSkeletalMeshes(enemy, markData)
                            local currentMeshCount = #meshes
                            
                            -- Nếu Độ Dày, Màu Sắc hoặc số lượng Mesh thay đổi thì mới cập nhật lại để chống Drop FPS
                            if markData.OutlineState ~= outlineHash or markData.LastMeshCountOutline ~= currentMeshCount then
                                local glowIntensity = 80.0
                                local r, g, b = 1.0, 1.0, 0.0 -- Mặc định Vàng (4)
                                
                                if colorMode == 1 then r = 1.0; g = 0.0; b = 0.0 end -- Đỏ
                                if colorMode == 2 then r = 0.0; g = 1.0; b = 0.0 end -- Lục (Xanh lá)
                                if colorMode == 3 then r = 0.0; g = 0.0; b = 1.0 end -- Lam (Xanh biển)
                                if colorMode == 4 then r = 1.0; g = 1.0; b = 0.0 end -- Vàng
                                if colorMode == 5 then r = 1.0; g = 0.0; b = 1.0 end -- Tím
                                if colorMode == 6 then r = 0.0; g = 1.0; b = 1.0 end -- Xanh lơ (Cyan)
                                if colorMode == 7 then r = 1.0; g = 1.0; b = 1.0 end -- Trắng
                                
                                local LinearColorClass = import("LinearColor") or _G.FLinearColor
                                local customGlowColor = LinearColorClass and LinearColorClass(r * glowIntensity, g * glowIntensity, b * glowIntensity, 1.0) or { R = r * 255 * glowIntensity, G = g * 255 * glowIntensity, B = b * 255 * glowIntensity, A = 255 }

                                for _, comp in _ipairs(meshes) do
                                    if Valid(comp) then
                                        _pcall(function() comp.UseScopeDistanceCulling = false; comp.PrimitiveShadingStrategy = 1; comp.ShadingRate = 6 end)
                                        if type(comp.SetDrawIdeaOutline) == "function" then
                                            comp:SetDrawIdeaOutline(true)
                                            if type(comp.SetIdeaOutlineNew) == "function" then comp:SetIdeaOutlineNew(true) end
                                            
                                            if type(comp.OverrideIdeaOutlineColor) == "function" then comp:OverrideIdeaOutlineColor(true, customGlowColor) end
                                            if type(comp.OverrideIdeaOutlineThickness) == "function" then comp:OverrideIdeaOutlineThickness(true, _G.LexusConfig.OutlineThickness) end
                                            
                                            if type(comp.SetRenderCustomDepth) == "function" then comp:SetRenderCustomDepth(true) end
                                            if type(comp.SetCustomDepthStencilValue) == "function" then comp:SetCustomDepthStencilValue(255) end
                                        end
                                    end
                                end
                                markData.OutlineState = outlineHash; markData.LastMeshCountOutline = currentMeshCount
                            end
                        end)
                    else
                        _pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local meshes = GetAllSkeletalMeshes(enemy, markData)
                                for _, comp in _ipairs(meshes) do
                                    if Valid(comp) then
                                        _pcall(function() comp.PrimitiveShadingStrategy = 0; comp.ShadingRate = 1 end)
                                        if type(comp.SetDrawIdeaOutline) == "function" then comp:SetDrawIdeaOutline(false) end
                                        if type(comp.SetRenderCustomDepth) == "function" then comp:SetRenderCustomDepth(false) end
                                    end
                                end
                                markData.OutlineState = "OFF"; markData.LastMeshCountOutline = 0
                            end
                        end)
                    end
                end -- End If distM <= 400

                -- ========================================================
                -- BỘ ĐẾM SỐ LƯỢNG ĐỊCH XUNG QUANH (Dùng thông số đã culling)
                -- ========================================================
                if distM > 0 and distM <= 400 then
                    if isBot then aiCount = aiCount + 1 else realCount = realCount + 1 end
                end
            end
        end

        if _G.LexusConfig.EspChiTiet and _G.LexusConfig.EspSoLuong then
            _pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    local totalEnemies = realCount + aiCount
                    local text = _string_format("KẺ ĐỊCH XUNG QUANH: %d", totalEnemies)
                    MyHUD:AddDebugText(text, localPlayer, 0.06, ZERO_VECTOR3, ZERO_VECTOR3, C_RED, true, false, true, nil, 0.8, true)
                end
            end)
        end
    end)
    -- =========================================================================
    -- KẾT THÚC HỆ THỐNG ESP
    -- =========================================================================

    if _G.LexusConfig.EspBomMaster and (_G.LexusConfig.EspItemBom or _G.LexusConfig.EspActiveBom) then
        _pcall(function()
            local MyHUD = Cached_MyHUD
            if Valid(MyHUD) then
                if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end 
                if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                
                if not _G.ActorBombCacheInit then
                    _G.NonBombCache = setmetatable({}, { __mode = "k" })
                    _G.BombCache = setmetatable({}, { __mode = "k" })
                    _G.ActorBombCacheInit = true
                end
                
                local ui_util = require("client.common.ui_util")
                local gameInstance = ui_util and ui_util.GetGameInstance()
                
                if gameInstance and _G.CachedGameplayStatics then
                    local curTime = _os_clock()
                    
                    if not _G.LastBombScanTime or (curTime - _G.LastBombScanTime) > 0.5 then
                        _G.LastBombScanTime = curTime
                        if _G.CachedProjArray and type(_G.CachedProjArray.Clear) == "function" then _G.CachedProjArray:Clear() end
                        local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                        
                        local activeBombs = {}
                        local itemBombs = {}
                        
                        if allActors then
                            for _, actor in _pairs(allActors) do
                                if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                    if not _G.NonBombCache[actor] then
                                        local bType = 0
                                        local isItem = false
                                        local isKnownBomb = _G.BombCache[actor]
                                        
                                        if isKnownBomb then
                                            bType = isKnownBomb.type
                                            isItem = isKnownBomb.isItem
                                        else
                                            -- Đã khôi phục lệnh lấy tên vật phẩm:
                                            local nameLower = nil
                                            _pcall(function() nameLower = _string_lower(_type(actor.GetName) == "function" and actor:GetName() or _tostring(actor)) end)
                                            
                                            if nameLower then
                                                if _string_find(nameLower, "m79") or _string_find(nameLower, "launcher") then bType = 5
                                                elseif _string_find(nameLower, "smoke") then bType = 2
                                                elseif _string_find(nameLower, "burn") or _string_find(nameLower, "molotov") then bType = 3
                                                -- Fix phân biệt Flashbang và Nòng giấu tia lửa (Flash Hider)
                                                elseif (_string_find(nameLower, "flash") or _string_find(nameLower, "stun")) and not _string_find(nameLower, "hider") and not _string_find(nameLower, "attach") then bType = 4
                                                elseif _string_find(nameLower, "grenade") and not _string_find(nameLower, "launcher") then bType = 1 end
                                                
                                                if bType > 0 then
                                                    if _string_find(nameLower, "projectile") or _string_find(nameLower, "thrown") then isItem = false
                                                    else
                                                        isItem = true
                                                        local shouldAdd = true
                                                        if bType == 3 and not (_string_find(nameLower, "pickup") or _string_find(nameLower, "wrapper") or _string_find(nameLower, "weapon")) then shouldAdd = false
                                                        elseif bType == 5 then
                                                            local attachParent = nil
                                                            _pcall(function() if _type(actor.GetAttachParentActor) == "function" then attachParent = actor:GetAttachParentActor() end end)
                                                            if slua.isValid(attachParent) then
                                                                local isHolding = false
                                                                _pcall(function()
                                                                    local curWeapon = _type(attachParent.GetCurrentWeapon) == "function" and attachParent:GetCurrentWeapon() or attachParent.CurrentWeapon
                                                                    if curWeapon == actor then isHolding = true end
                                                                end)
                                                                if not isHolding then shouldAdd = false end
                                                            end
                                                        end
                                                        if not shouldAdd then bType = 0 end
                                                    end
                                                end
                                            end
                                            
                                            if bType > 0 then _G.BombCache[actor] = { type = bType, isItem = isItem }
                                            else _G.NonBombCache[actor] = true end
                                        end
                                        
                                        if bType > 0 then
                                            local isPendingKill = false
                                            _pcall(function() if _type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                            if not isPendingKill then
                                                if isItem then _table_insert(itemBombs, {act = actor, type = bType})
                                                else _table_insert(activeBombs, {act = actor, type = bType}) end
                                            else
                                                _G.BombCache[actor] = nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        _G.CachedActiveBombs = activeBombs
                        _G.CachedItemBombs = itemBombs
                    end

                    local curGameTime = 0
                    _pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)

                    local function DrawBombs(bombList, isItem, maxDist)
                        if not bombList then return end
                        for _, item in _ipairs(bombList) do
                            local bomb = item.act
                            local bType = item.type
                            if slua.isValid(bomb) and not bomb.bHidden then
                                local distM = 0
                                _pcall(function() distM = localPlayer:GetDistanceTo(bomb) / 100 end)
                                if distM > 0 and distM <= maxDist then
                                    local displayName = ""
                                    local bombColor = C_WHITE
                                    local zOffset = isItem and 15 or 25
                                    
                                    if bType == 1 then displayName = "BOM NỔ"; bombColor = isItem and {R=255, G=100, B=100, A=255} or C_RED
                                    elseif bType == 2 then displayName = "KHÓI"; bombColor = isItem and {R=200, G=200, B=200, A=255} or C_WHITE
                                    elseif bType == 3 then displayName = "LỬA"; bombColor = isItem and {R=255, G=160, B=50, A=255} or {R=255, G=100, B=0, A=255}
                                    elseif bType == 4 then displayName = "CHOÁNG"; bombColor = isItem and {R=150, G=255, B=255, A=255} or C_CYAN
                                    elseif bType == 5 then displayName = "ĐẠN KHÓI"; bombColor = isItem and {R=150, G=255, B=150, A=255} or {R=100, G=255, B=100, A=255} end
                                    
                                    local text = _string_format("%s [%dm]", displayName, _math_floor(distM))
                                    local shouldTimerRun = not isItem 
                                    if isItem then _pcall(function() if bomb.bIsPinPulled or bomb.bPinPulled or (_type(bomb.IsPinPulled) == "function" and bomb:IsPinPulled()) then shouldTimerRun = true end end) end

                                    if shouldTimerRun and curGameTime > 0 then
                                        local timeLeft = -1
                                        _pcall(function() if bomb.ExplosionTime then timeLeft = bomb.ExplosionTime - curGameTime elseif bomb.ExplodeTime then timeLeft = bomb.ExplodeTime - curGameTime end end)
                                        if timeLeft == -1 or timeLeft > 100 then
                                            _G.ActiveBombTimers = _G.ActiveBombTimers or {}
                                            local bombId = _tostring(bomb)
                                            if not _G.ActiveBombTimers[bombId] then _G.ActiveBombTimers[bombId] = curGameTime end
                                            local elapsed = curGameTime - _G.ActiveBombTimers[bombId]
                                            local maxTime = (bType == 1 and 7.0) or (bType == 2 and 45.0) or (bType == 3 and 12.0) or (bType == 4 and 5.0) or 45.0
                                            timeLeft = maxTime - elapsed
                                        end
                                        if timeLeft < 0 then timeLeft = 0 end
                                        if timeLeft > 0.1 then text = _string_format("%s (%.1fs)", text, timeLeft) end
                                    end
                                    local dynamicScale = _math_max(0.6, 1.1 - (distM / maxDist))
                                    MyHUD:AddDebugText(text, bomb, 0.06, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, bombColor, true, false, true, nil, dynamicScale, true)
                                end
                            end
                        end
                    end
                    
                    if not _G.LastClearTimer or (curTime - _G.LastClearTimer) > 1.0 then
                        _G.LastClearTimer = curTime
                        _pcall(function() if _G.ActiveBombTimers then for k, v in _pairs(_G.ActiveBombTimers) do if (curGameTime - v) > 60.0 then _G.ActiveBombTimers[k] = nil end end end end)
                    end

                    if _G.LexusConfig.EspItemBom then DrawBombs(_G.CachedItemBombs, true, 50) end
                    if _G.LexusConfig.EspActiveBom then DrawBombs(_G.CachedActiveBombs, false, 150) end
                end
            end
        end)
    end

    if _G.LexusConfig.EspVehicle then
        _pcall(function()
            local MyHUD = Cached_MyHUD
            if Valid(MyHUD) then
                if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                if not _G.CachedActorClass_ForVehicle then _G.CachedActorClass_ForVehicle = import("STExtraVehicleBase") end 
                if not _G.CachedVehicleArray then _G.CachedVehicleArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForVehicle) end
                
                local ui_util = require("client.common.ui_util")
                local gameInstance = ui_util and ui_util.GetGameInstance()
                
                if gameInstance and _G.CachedGameplayStatics then
                    local curTime = _os_clock()
                    if not _G.LastVehicleScanTime or (curTime - _G.LastVehicleScanTime) > 1.0 then
                        _G.LastVehicleScanTime = curTime
                        if _G.CachedVehicleArray and type(_G.CachedVehicleArray.Clear) == "function" then _G.CachedVehicleArray:Clear() end
                        local allVehicles = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForVehicle, _G.CachedVehicleArray)
                        local activeVehicles = {}
                        if allVehicles then
                            for _, veh in _pairs(allVehicles) do
                                if slua.isValid(veh) and not veh.bHidden and not veh.bTearOff then
                                    local isPendingKill = false
                                    _pcall(function() if _type(veh.IsPendingKill) == "function" then isPendingKill = veh:IsPendingKill() end end)
                                    if not isPendingKill then
                                        local vehName = "XE"
                                        local hasDriver = false
                                        _pcall(function()
                                            if _type(veh.GetVehicleName) == "function" then vehName = veh:GetVehicleName() elseif veh.VehicleName then vehName = veh.VehicleName end
                                            local driver = _type(veh.GetDriver) == "function" and veh:GetDriver() or nil
                                            if slua.isValid(driver) then hasDriver = true end
                                        end)
                                        local nameLower = _string_lower(_tostring(vehName) .. _tostring(veh))
                                        local displayName = "XE"
                                        if _string_find(nameLower, "uaz") then displayName = "UAZ"
                                        elseif _string_find(nameLower, "dacia") then displayName = "DACIA"
                                        elseif _string_find(nameLower, "buggy") then displayName = "BUGGY"
                                        elseif _string_find(nameLower, "mirado") then displayName = "MIRADO"
                                        elseif _string_find(nameLower, "bike") or _string_find(nameLower, "motor") then displayName = "MOTOR"
                                        elseif _string_find(nameLower, "scooter") then displayName = "SCOOTER"
                                        elseif _string_find(nameLower, "coupe") then displayName = "COUPE RB"
                                        elseif _string_find(nameLower, "brdm") then displayName = "BRDM"
                                        elseif _string_find(nameLower, "boat") or _string_find(nameLower, "aquarail") then displayName = "THUYỀN"
                                        elseif _string_find(nameLower, "glider") then displayName = "TÀU LƯỢN"
                                        else displayName = "XE (" .. _string_sub(_string_upper(vehName), 1, 8) .. ")" end
                                        _table_insert(activeVehicles, {act = veh, name = displayName, hasDriver = hasDriver})
                                    end
                                end
                            end
                        end
                        _G.CachedVehicles = activeVehicles
                    end

                    if _G.CachedVehicles then
                        for _, item in _ipairs(_G.CachedVehicles) do
                            local veh = item.act
                            if slua.isValid(veh) and not veh.bHidden then
                                local isShow = false
                                if item.name == "DACIA" then isShow = _G.LexusConfig.EspVeh_Dacia
                                elseif item.name == "UAZ" then isShow = _G.LexusConfig.EspVeh_UAZ
                                elseif item.name == "BUGGY" then isShow = _G.LexusConfig.EspVeh_Buggy
                                elseif item.name == "COUPE RB" then isShow = _G.LexusConfig.EspVeh_Coupe
                                elseif item.name == "MIRADO" then isShow = _G.LexusConfig.EspVeh_Mirado
                                elseif item.name == "MOTOR" or item.name == "SCOOTER" then isShow = _G.LexusConfig.EspVeh_Motor
                                else isShow = _G.LexusConfig.EspVeh_Other end

                                if isShow then
                                    local distM = 0
                                    _pcall(function() distM = localPlayer:GetDistanceTo(veh) / 100 end)
                                    if distM > 0 and distM <= 300 then
                                        local text = _string_format("%s [%dm]", item.name, _math_floor(distM))
                                        local vehColor = item.hasDriver and {R=255, G=50, B=50, A=255} or {R=0, G=255, B=150, A=255}
                                        local dynamicScale = _math_max(0.6, 0.9 - (distM / 500))
                                        MyHUD:AddDebugText(text, veh, 0.06, {X=0, Y=0, Z=50}, {X=0, Y=0, Z=50}, vehColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end


_G.BaseAttachToIndex = {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2, 
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4, 
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6, 
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13, 
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19, 
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22 
}

_G.VIP_Attachments = {
    [1101006098]={1010061045,1010061044,1010061046,1010061040,1010061039,1010061043,1010061038,1010061037,1010061036,1010061035,1010061034,1010061033,0,1010061049,1010061047,1010061053,1010061054,1010061050,1010061048,0,1010061055,0},
    [1101006106]={1010061005,1010061004,1010061006,1010061000,1010060999,1010061003,1010060998,1010060997,1010060996,1010060995,1010060994,1010060993,0,1010061009,1010061007,1010061013,1010061014,1010061010,1010061008,0,1010061015,0},
    [1101003219]={1010032223,1010032222,1010032224,1010032219,1010032218,1010032220,1010032217,1010032216,1010032215,1010032214,1010032213,1010032212,0,1010032227,1010032225,1010032229,1010032230,1010032228,1010032226,0,1010032232,0},   
    [1101003227]={0,0,0,1010032209,1010032208,1010032210,1010032207,1010032206,1010032205,1010032204,1010032203,1010032202,0,0,0,0,0,0,0,0,0,0},
    [1102002446]={1020024403,1020024402,1020024404,1020024399,1020024398,1020024400,1020024397,1020024396,1020024395,1020024394,1020024393,1020024392,0,1020024407,1020024405,1020024409,1020024410,1020024408,1020024406,0,1020024412,0},    
    [1102002438]={1020024323,1020024322,1020024324,1020024319,1020024318,1020024320,1020024317,1020024316,1020024315,1020024314,1020024313,1020024312,0,1020024327,1020024325,1020024329,1020024330,1020024328,1020024326,0,1020024332,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},           
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0}
}

local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil
_G.NeedCheckDeadBoxTimer = 0

_G.DeadBox_TemperRequest = function(PlayerController)
    if not _G.LexusConfig.SkinDeadBox or _G.NeedCheckDeadBoxTimer <= 0 then return end
    
    local curTime = os.clock()
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < 2.0 then return end
    _G.LastCheckDeadBoxTime = curTime
    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end
    
    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end
    
    if not _G.CachedActorArray_DB then
        _G.CachedActorArray_DB = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end
    
    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    -- Tối ưu: Lấy trước ID người chơi và ID súng/xe ở ngoài vòng lặp để tránh tính toán lại
    local myPlayerKey = PlayerController.PlayerKey
    local currentBoxSkinId = 0
    pcall(function()
        local curVeh = PlayerCharacter.CurrentVehicle or (type(PlayerCharacter.GetCurrentVehicle) == "function" and PlayerCharacter:GetCurrentVehicle())
        if slua.isValid(curVeh) and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
            currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
        else
            -- [FIX CHUẨN VIP]: Lấy ID của vũ khí đang cầm trên tay để xuất đúng hòm xác, Bỏ vòng lặp để chống Drop FPS
            local curWeapon = PlayerCharacter.GetCurrentWeapon and PlayerCharacter:GetCurrentWeapon() or PlayerCharacter.CurrentWeapon
            if slua.isValid(curWeapon) then
                local defineIDObj = curWeapon.GetItemDefineID and curWeapon:GetItemDefineID()
                local curWeaponID = (defineIDObj and slua.isValid(defineIDObj)) and defineIDObj.TypeSpecificID or 0
                
                -- Đối chiếu với kho Skin đã lưu để lấy đúng ID Skin hiện tại
                if curWeaponID > 0 and _G.AddOutfitLastAppliedSkin and _G.AddOutfitLastAppliedSkin[curWeaponID] then
                    local skinID = _G.AddOutfitLastAppliedSkin[curWeaponID]
                    if skinID and skinID > 1000000 then 
                        currentBoxSkinId = skinID 
                    end
                end
            end
        end
    end)

    if currentBoxSkinId == 0 then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray_DB)
    if not deadBoxes then return end
    
    local count = type(deadBoxes.Num) == "function" and deadBoxes:Num() or #deadBoxes
    for i = 1, count do
        local deadBoxActor = type(deadBoxes.Get) == "function" and deadBoxes:Get(i-1) or deadBoxes[i]
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            -- So sánh cực nhanh bằng MyPlayerKey đã cache
            if slua.isValid(damageCauser) and damageCauser.PlayerKey == myPlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    pcall(function()
                        DeadBoxAvatarComponent:ResetItemAvatar()
                        DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                        DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                    end)
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end


local F = {}
local DEBUG = false  
function F.log(...)
    if DEBUG then print("[AddOutfit]", ...) end
end

local MATCH_CONFIG = {
    outfitRes = 0,        
    hatRes    = 0,        
    maskRes   = 0,
    glassRes  = 0,
    tshirtRes = 0,        
    pantsRes  = 0,        
    shoesRes  = 0,        
    bagRes    = 0,        
    helmetRes = 0,        
    weaponSkins = {},
}


local ITEMS = {
   
    703029, 703044, 703046, 703048, 1400010, 1400062, 1400070, 1400083, 1400100, 1400106, 1400112, 1400117, 1400134, 1407917, 1400170, 
    1400172, 1400173, 1400174, 1400175, 1400177, 1400179, 1400180, 1400228, 1400231, 1400233, 1400236, 1400237, 1400238, 1400242, 1400244,
    202408070, 202408071, 202408072, 202408073, 202408074, 202408075,
    1407905, 1407906, 1407907, 1407908, 1407909, 1407910, 1407911, 1407912, 1407913, 1407914, 1407915, 1407916, 1410585,
    -- [ M416 ]
    1101004163, -- Hoàng Gia Lộng Lẫy - M416 (Cấp 8)
    1101004201, -- Bạch Lân Nhả Ngọc - M416 (Cấp 8)
    1101004209, -- Thủy Triều Dậy Sóng - M416 (Cấp 8)
    1101004218, -- Ma Ảnh - M416 (Cấp 8)
    1101004226, -- Phong Ấn U Minh - M416 (Cấp 8)
    1101004236, -- Lam Sư Đoạt Mệnh - M416 (Cấp 8)
    1101004246, -- Hỏa Liên - M416 (Cấp 8)
    1101004046, -- Băng giá - M416 (Cấp 7)
    1101004062, -- Chú hề - M416 (Cấp 7)
    1101004078, -- Kẻ lang thang - M416 (Cấp 7)
    1101004086, -- Bò Sát Gầm Gừ - M416 (Cấp 7)
    1101004098, -- Tiếng Gọi Hoang Dã - M416 (Cấp 7)
    1101004138, -- Lõi Công Nghệ - M416 (Cấp 7)
    
    1101002156,
    1101002133,
    1101002125,
    1101002117,
    1101002110,
    1101002103,
    1101002081,
    1101002068,
    1101002056,
    1101002029,
    

    -- [ AKM ]
    1101001174, -- Bạo Chúa Bộ Lạc - AKM (Cấp 8)
    1101001213, -- Đô Đốc Hải Long Tinh - AKM (Cấp 8)
    1101001242, -- Ngày Phán Quyết - AKM (Cấp 8)
    1101001265, -- Thời Quang Khả Biến - AKM (Cấp 8)
    1101001276, -- Huyễn Thần - AKM (Cấp 8)
    1101001063, -- Huyền thoại Seven Seas - AKM (Cấp 7)
    1101001089, -- Băng giá - AKM (Cấp 7)
    1101001103, -- Hóa Thạch - AKM (Cấp 7)
    1101001116, -- Bí Ngô Kinh Dị - AKM (Cấp 7)
    1101001128, -- Long Vương - AKM (Cấp 7)
    1101001143, -- Hải Tặc Vàng - AKM (Cấp 7)
    1101001154, -- Người Giải Mã - AKM (Cấp 7)
    1101001231, -- Thỏ Tinh Nghịch - AKM (Cấp 7)
    1101001249, -- Thánh Quang (Trăng Thần) - AKM (Cấp 7)
    1101001256, -- Thánh Quang (Lông Vũ Hoàng Kim) - AKM (Cấp 7)
    1101001042, -- Ánh kim - AKM (Cấp 6)
    1101001068, -- Hổ gầm gừ - AKM (Cấp 5)

    -- [ SCAR-L ]
    1101003146, -- Gai Tà Ác - SCAR-L (Cấp 8)
    1101003167, -- Ma Vương Huyết Hồn - SCAR-L (Cấp 8)
    1101003227, -- Thiên Điểu - SCAR-L (Cấp 8)
    1101003057, -- Súng nước - SCAR-L (Cấp 7)
    1101003070, -- Bí Ngô Ma Quái - SCAR-L (Cấp 7)
    1101003080, -- Chiến Dịch Vì Ngày Mai - SCAR-L (Cấp 7)
    1101003099, -- Drop Da Bass - SCAR-L (Cấp 7)
    1101003119, -- Tinh thể Hextech SCAR-L (Cấp 7)
    1101003188, -- Cái Ôm Của Chú Hề - SCAR-L (Cấp 7)
    1101003195, -- Thánh Nữ Huyền Ảo - SCAR-L (Cấp 7)
    1101003208, -- Vương Quốc Huyền Ảo - SCAR-L (Cấp 7)
    1101003219, -- Kính Pha Lê - SCAR-L (Cấp 7)
    1101003173, -- Ánh Sáng Hoàng Tộc - SCAR-L (Cấp 5)
    1101003212, -- Mèo Ăn Vặt - SCAR-L (Cấp 3)

    -- [ M762 ]
    1101008081, -- Vị Khách Nổi Loạn - M762 (Cấp 8)
    1101008104, -- Lõi Sao Huyền Ảo - M762 (Cấp 8)
    1101008146, -- Bạch Cốt U Minh - M762 (Cấp 8)
    1101008154, -- Khung Xương - M762 (Cấp 8)
    1101008051, -- Bản Nhạc Tình Yêu - M762 (Cấp 7)
    1101008061, -- Phát Bắn Chí Mạng - M762 (Cấp 7)
    1101008070, -- GACKT MOONSAGA - M762 (Cấp 7)
    1101008116, -- Biểu Tượng Bóng Đá Messi - M762 (Cấp 7)
    1101008126, -- Huyết Rồng - M762 (Cấp 7)
    1101008136, -- Tiên Linh Lưu Ly - M762 (Cấp 7)
    1101008163, -- Cổ Vật Hắc Ám - M762 (Cấp 7)
    1101008026, -- Pony Bé Nhỏ - M762 (Cấp 5)
    1101008036, -- Đóa Sen Phẫn Nộ - M762 (Cấp 5)

    -- [ AUG ]
    1101006062, -- Tinh Linh Băng Giá - AUG (Cấp 8)
    1101006085, -- Hoa Hồng Ma Mị - AUG (Cấp 8)
    1101006075, -- Hỏa Ca - AUG (Cấp 7)
    1101006033, -- Gánh Xiếc Rong - AUG (Cấp 5)
    1101006044, -- Evangelion Angel Thứ 4 - AUG (Cấp 5)
    1101006067, -- Ác Mộng Biển Sâu - AUG (Cấp 5)

    -- [ GROZA ]
    1101005038, -- Ryomen Sukuna - Groza (Cấp 7)
    1101005052, -- Lửa U Minh - Groza (Cấp 7)
    1101005098, -- Godzilla Bốc Lửa - Groza (Cấp 7)
    1101005019, -- Kỵ Binh Rừng Sâu - GROZA (Cấp 5)
    1101005025, -- Đêm Huyền Ảo - GROZA (Cấp 5)
    1101005043, -- Trận Chiến Sắc Màu - Groza (Cấp 5)
    1101005082, -- Lồng Đèn Bí Ngô - Groza (Cấp 5)
    1101005090, -- Di Tích Thượng Cổ - Groza (Cấp 5)
    1101005105, -- Singam Roar - Groza (Cấp 5)

    -- [ QBZ & Mk47 & G36C & Honey Badger & FAMAS & ASM Abakan & ACE32 ]
    1101007046, -- Công Chúa Hắc Ám - QBZ (Cấp 7)
    1101007062, -- Hoa Kiếm Chí Mạng - QBZ (Cấp 7)
    1101007071, -- Thiên Mệnh - QBZ (Cấp 7)
    1101007025, -- Ánh Dương - QBZ (Cấp 5)
    1101007036, -- Càn Quét - QBZ (Cấp 5)
    1101007079, -- Băng Quyền - QBZ (Cấp 5)
    1101009019, -- Thỏ Tinh Quái - Mk47 (Cấp 3)
    1101010029, -- Xung Nhịp Sân Cỏ - G36C (Cấp 5)
    1101012033, -- Cổ Mộc Chiến Khí - Honey Badger (Cấp 7)
    1101012009, -- Sắc Màu Huyền Ảo - Honey Badger (Cấp 5)
    1101012018, -- Thanh Âm Du Dương - Honey Badger (Cấp 5)
    1101012024, -- Honey Badger Mikey (Cấp 5)
    1101100012, -- Đế Vương Thần Vực - FAMAS (Cấp 8)
    1101100018, -- Ảo Ảnh Điện Tử - FAMAS (Cấp 5)
    1101101007, -- Uy Vũ Hắc Điểu - ASM Abakan (Cấp 7)
    1101102025, -- Thủy Quái - ACE32 (Cấp 8)
    1101102041, -- Tiên Tri Điềm Lành - ACE32 (Cấp 8)
    1101102049, -- Thì Thầm Cánh Bướm - ACE32 (Cấp 8)
    1101102007, -- Kamehameha - ACE32 (Cấp 7)
    1101102017, -- Ngọc Bích - ACE32 (Cấp 7)
    1101102032, -- Cáo Tinh Nghịch - ACE32 (Cấp 5)
    202408087,

    -- [ SMG (UZI, UMP45, Vector, Thompson, Bizon, MP5K, P90) ]
    1102001120, -- Băng Giá - UZI (Cấp 8)
    1102001130, -- Xiềng Xích Hỏa Ngục - UZI (Cấp 7)
    1102001024, -- Savagery - UZI (Cấp 6)
    1102001036, -- Vật Tổ Thần Bí - UZI (Cấp 5)
    1102001058, -- Khoảnh Khắc Bất Ngờ - UZI (Cấp 5)
    1102001069, -- UZI Quang Hóa (Cấp 5)
    1102001089, -- Ma Pháp - UZI (Cấp 5)
    1102001103, -- Cam Tươi Mát - UZI (Cấp 5)
    1102001102, -- Máy Ép Trái Cây - UZI (Cấp 5)
    1102002438, -- Song Tử Chiến - UMP45 (Cấp 8)
    1102002446, -- Song Tử Đỏ Thẫm - UMP45 (Cấp 8)
    1102002043, -- Hỏa long - UMP45 (Cấp 7)
    1102002061, -- Ảo Mộng Chết Chóc - UMP45 (Cấp 7)
    1102002136, -- Băng Giá - UMP45 (Cấp 7)
    1102002424, -- Thần Khí Anukhra - UMP45 (Cấp 7)
    1102002053, -- EMP - UMP45 (Cấp 5)
    1102002070, -- Đồ Tể Bạch Kim - UMP45 (Cấp 5)
    1102002090, -- Cuộc Chiến 8-Bit - UMP45 (Cấp 5)
    1102002112, -- Ngày Giáng Sinh - UMP45 (Cấp 5)
    1102002117, -- Ong Bắp Cày - UMP45 (Cấp 5)
    1102002129, -- Con Sóng Lễ Hội - UMP45 (Cấp 5)
    1102002143, -- PUBGM X NewJeans - UMP45 (Cấp 5)
    1102003080, -- Cánh Rồng - Vector (Cấp 7)
    1102003100, -- Tuyết Diệt Ảnh - Vector (Cấp 7)
    1102003020, -- Nanh Dơi Huyết Tộc - Vector (Cấp 5)
    1102003031, -- Hoa Hồng Đêm - Vector (Cấp 5)
    1102003039, -- Gấu Tinh Nghịch - Vector (Cấp 5)
    1102003052, -- Bá Tước Vàng - Vector (Cấp 5)
    1102003065, -- Lưỡi Liềm Vàng - Vector (Cấp 5)
    1102003072, -- Sát Thủ Tối Thượng - Vector (Cấp 5)
    1102003090, -- KMF Lancelot - Vector (Cấp 5)
    1102004018, -- Kẹo ngọt - Thompson (Cấp 5)
    1102004034, -- Máy Chạy Hơi Nước - Thompson (Cấp 5)
    1102004048, -- Tử Đằng - Thompson SMG (Cấp 3)
    1102005064, -- Quang Ảo Điện Tử - PP-19 Bizon (Cấp 7)
    1102005007, -- Tắc Kè - PP-19 Bizon (Cấp 5)
    1102005020, -- Skullcrusher - PP-19 Bizon (Cấp 5)
    1102005041, -- Thần Binh Võ Thuật - PP-19 Bizon (Cấp 5)
    1102005052, -- DP Quantum Quake - Bizon (Cấp 5)
    1102005057, -- Lân Sư - PP-19 Bizon (Cấp 5)
    1102005072, -- Huyết Tế - PP-19 Bizon (Cấp 5)
    1102005078, -- SAKAMOTO SHOP - PP-19 (Cấp 5)
    1102007019, -- PUBGM X QWER - MP5K (Cấp 5)
    1102007022, -- Pixel Cổ Điển - MP5K (Cấp 3)
    1102105012, -- Miêu Nữ Công Nghệ - P90 (Cấp 7)
    1102105028, -- Thiên Mã - P90 (Cấp 7)
    1102105018, -- Móng Vuốt Hoàng Kim - P90 (Cấp 5)

    -- [ SNIPER & MARKSMAN RIFLE (Kar98, M24, AWM, SKS, SLR, Mk14, etc.) ]
    1103001202, -- Băng Yêu - Kar98K (Cấp 8)
    1103001060, -- Dấu nanh Phẫn nộ - Kar98K (Cấp 7)
    1103001079, -- Kukulkan Cuồng Nộ - Kar98K (Cấp 7)
    1103001101, -- Ánh Trăng - Kar98K (Cấp 7)
    1103001129, -- Gackt Moon - Kar98K (Cấp 7)
    1103001146, -- Cá Mập Titan - Kar98K (Cấp 7)
    1103001154, -- Mật Mã Chết Chóc - Kar98K (Cấp 7)
    1103001179, -- Điện Cực Tím - Kar98K (Cấp 7)
    1103001191, -- Hồng Hỏa Diệm - Kar98K (Cấp 7)
    1103001085, -- Đêm Nhạc Rock - Kar98K (Cấp 5)
    1103001160, -- Thợ Săn Tinh Vân - Kar98K (Cấp 5)
    1103001183, -- Nhịp Điệu Mèo Con - Kar98K (Cấp 3)
    1103002030, -- Quyền Trượng Pharaoh - M24 (Cấp 7)
    1103002059, -- Tuần Hoàn Sự Sống - M24 (Cấp 7)
    1103002087, -- Nhịp Điệu Hoàn Mỹ - M24 (Cấp 7)
    1103002106, -- Minh Nguyệt Cấm Vực - M24 (Cấp 7)
    1103002156, -- Bình Minh Bóng Tối - M24 (Cấp 7)
    1103002049, -- Hồ Điệp Phu Nhân - M24 (Cấp 5)
    1103002047, -- Giai Điệu Chí Mạng - M24 (Cấp 5)
    1103002094, -- Công Nghệ Cao - M24 (Cấp 5)
    1103003022, -- Neon - AWM (Cấp 7)
    1103003030, -- Chỉ Huy Chiến Trường - AWM (Cấp 7)
    1103003042, -- Godzilla - AWM (Cấp 7)
    1103003051, -- Đại Long Cầu Vồng - AWM (Cấp 7)
    1103003062, -- Hỏa Phượng Hoàng - AWM (Cấp 7)
    1103003079, -- Huyết Hải Thiên Long - AWM (Cấp 7)
    1103003087, -- Thanh Hoa Xà - AWM (Cấp 7)
    1103003099, -- Hắc Khí - AWM (Cấp 7)
    1103003092, -- Hồng Hoang - AWM (Cấp 5)
    1103004037, -- Quý Bà Đỏ - SKS (Cấp 7)
    1103004046, -- Rừng Thép - SKS (Cấp 5)
    1103004058, -- Năng Lượng Băng Tuyết - SKS (Cấp 5)
    1103004080, -- Khiết Hoa Nở Rộ - SKS (Cấp 5)
    1103004087, -- Giai Điệu Tử Thần - SKS (Cấp 5)
    1103005024, -- Quạ Đen - VSS (Cấp 5)
    1103005048, -- Trinh Sát Tuyết Trắng - VSS (Cấp 3)
    1103009022, -- Mùa Hoa Đào - SLR (Cấp 5)
    1103009037, -- Ngọn Lửa Ma Thuật - SLR (Cấp 5)
    1103009051, -- Ma Mộng - SLR (Cấp 5)
    1103009042, -- Thanh Âm Hải Huyền - SLR (Cấp 3)
    1103006030, -- Sông Băng - Mini14 (Cấp 7)
    1103006046, -- Nét Đẹp Thuần Khiết - Mini14 (Cấp 5)
    1103006058, -- Mèo Chiêu Tài - Mini14 (Cấp 5)
    1103006063, -- Tay Đua Gan Dạ - Mini14 (Cấp 5)
    1103006075, -- Nhịp Chiến Nhanh - Mini14 (Cấp 5)
    1103007028, -- Vương Quốc Rồng - Mk14 (Cấp 8)
    1103007020, -- Sức Mạnh Ngân Hà - Mk14 (Cấp 5)
    1103007038, -- Rồng Sữa Mềm Mại - Mk14 (Cấp 5)
    1103007043, -- Hộp Quà May Mắn - Mk14 (Cấp 5)
    1103012010, -- Khủng Long Ephialtes - AMR (Cấp 8)
    1103012019, -- Hỏa Thần - AMR (Cấp 7)
    1103012031, -- Vô Âm Ly Biệt - AMR (Cấp 7)
    1103012039, -- Đại Chiến Huyễn Sắc - AMR (Cấp 7)
    1103012024, -- Tinh Thể Onyx - AMR (Cấp 5)
    1103100007, -- Thú Săn Mồi - Mk12 (Cấp 5)
    1103102007, -- Chiến Hạm Vũ Trụ - DSR (Cấp 7)
    1103103007, -- Vinh Quang Chiến Binh - M1 Garand (Cấp 7)

    -- [ SHOTGUN & MACHINE GUN (S12K, DBS, M249, DP-28, MG3...) ]
    1104001035, -- Độc Hồn - S686 (Cấp 5)
    1104002022, -- Chạng Vạng - S1897 (Cấp 5)
    1104002049, -- Xung Kích Sắc Màu - S1897 (Cấp 3)
    1104003026, -- S12K GACKT (Cấp 7)
    1104003037, -- Kích Hoạt Nguyên Tử - S12K (Cấp 5)
    1104003046, -- Trái Tim Cyber - S12K (Cấp 5)
    1104004035, -- Chiến Giáp Quái Thú - DBS (Cấp 5)
    1104004041, -- Sandsinger - DBS (Cấp 5)
    1104004051, -- Okarun - DBS (Cấp 5)
    1104004024, -- Báo Sắc Màu - DBS (Cấp 3)
    1104102004, -- Tàn Tích Hoàng Kim - NS2000 (Cấp 3)
    1105001034, -- Pháo Giáng Sinh - M249 (Cấp 7)
    1105001048, -- Nữ Đế Ánh Sáng - M249 (Cấp 7)
    1105001069, -- Vương Quyền Hắc Ám - M249 (Cấp 7)
    1105001020, -- Nữ Hoàng Băng Giá M249 V (Cấp 5)
    1105001054, -- Stargaze Fury - M249 (Cấp 5)
    1105001062, -- Graffiti Đường Phố - M249 (Cấp 5)
    1105001075, -- Cá Mập Thép - M249 (Cấp 4)
    1105002091, -- Huyết Họa - DP28 (Cấp 8)
    1105002018, -- Sát Thủ Bí Ẩn - DP-28 (Cấp 5)
    1105002035, -- Ngọc Long - DP-28 (Cấp 5)
    1105002058, -- Chiến Binh Hàng Hải - DP28 (Cấp 5)
    1105002063, -- Rồng Thần Shenron - DP-28 (Cấp 5)
    1105002071, -- Chiến Sĩ Thần Giáp - DP-28 (Cấp 5)
    1105002076, -- Mèo Số Hóa - DP-28 (Cấp 5)
    1105002083, -- DP-28 Frieren's Staff (Cấp 5)
    1105002096, -- Hồ Tộc - DP-28 (Cấp 3)
    1105010019, -- Chiến Thần Bầu Trời - MG3 (Cấp 7)
    1105010008, -- Thiên Khung - MG3 (Cấp 5)
    1105010026, -- Mina Ashiro - MG3 (Cấp 5)

    -- [ CẬN CHIẾN & VŨ KHÍ KHÁC (Skorpion, Nỏ, Chảo, Dao...) ]
    1106008013, -- Mật Mã Vàng - Skorpion (Cấp 5)
    1106008022, -- Bí Ẩn Tinh Tú - Skorpion (Cấp 3)
    1106011008, -- Rồng Rắn Lên Mây - MP7 Kép (Cấp 5)
    1106011003, -- Thợ Săn Kẹo - MP7 (Cấp 3)
    1107001018, -- Chúa Hề Thịnh Nộ - Nỏ (Cấp 3)
    1107098003, -- Rung Chấn Công Nghệ - MGL (Cấp 3)
    1108001057, -- Săn Rồng - Dao (Cấp 3)
    1108001064, -- Đoản Kiếm Yor SPY×FAMILY (Cấp 3)
    1108001069, -- Ki Sword (Cấp 3)
    1108001081, -- Rìu Godzilla Bốc Lửa (Cấp 3)
    1108001085, -- Kiếm Trung Đoàn Trinh Sát Cấp 3
    1108001098, -- Thương Đảo Ngược Thiên Đường - Dao (Cấp 3)
    1108001104, -- Xích Tay - Dao (Cấp 3)
    1108002059, -- Đinh Ba Thủy Triều Thịnh Nộ (Cấp 5)
    1108004125, -- Hũ Mật Ong - Chảo (Cấp 5)
    1108004160, -- Cá Sấu - Chảo (Cấp 5)
    1108004145, -- Đêm Nhạc Rock - Chảo (Cấp 5)
    1108004283, -- Vinh Quang - Chảo (Cấp 6)
    1108004337, -- Chảo Điện Nguyên Tử (Cấp 6)
    1108004356, -- Gà Rán - Chảo (Cấp 3)
    1108004365, -- Yokai Huyền Bí - Chảo (Cấp 3)
    1108004377, -- Chảo Cánh Cụt Vui Vẻ (Cấp 5)
    1108004416, -- Quạt Vũ Điệu Nóng Bỏng - Chảo (Cấp 3)
    1108005050, -- Rồng Băng Giá - Dao Găm (Cấp 3)
    1961007, -- McLaren 570S (Đen)
    1961010, -- McLaren 570S (Trắng)
    1961012, -- McLaren 570S (Hồng)
    1961013, -- McLaren 570S (Vàng Trắng)
    1961014, -- McLaren 570S (Vàng Đen)
    1961015, -- McLaren 570S (Ánh Kim)
    1961147, -- McLaren P1 (Trời Sao)
    1961148, -- McLaren P1 (Hồng Rực Rỡ)
    1961149, -- McLaren P1 (Vàng Núi Lửa)
    1907054, -- Xe Đua Đội McLaren F1 (Điện Tử)
    1907058, -- Xe Đua Đội McLaren F1
    1907059, -- Xe Đua Đội McLaren F1 (Chiến Thắng)

    -- [ Koenigsegg ]
    1961016, -- Koenigsegg Jesko (Xám Bạc)
    1961017, -- Koenigsegg Jesko (Cầu Vồng)
    1961018, -- Koenigsegg Jesko (Bình Minh)
    1961029, -- Koenigsegg One:1 Gilt
    1961030, -- Koenigsegg One:1 Cyber Nebula
    1961031, -- Koenigsegg One:1 Jade
    1961032, -- Koenigsegg One:1 Phoenix
    1903074, -- Koenigsegg Gemera (Xám Bạc)
    1903075, -- Koenigsegg Gemera (Cầu Vồng)
    1903076, -- Koenigsegg Gemera (Bình Minh)

    -- [ Lamborghini ]
    1961020, -- Lamborghini Aventador SVJ Verde Alceo
    1961021, -- Lamborghini Centenario Galassia
    1961024, -- Lamborghini Aventador SVJ Blue
    1961025, -- Lamborghini Centenario Carbon Fiber
    1961144, -- Lamborghini Invencible Rosso Efesto
    1961145, -- Lamborghini Invencible Nebula Drift
    1903079, -- Lamborghini Estoque Oro
    1903080, -- Lamborghini Estoque Metal Grey
    1908066, -- Lamborghini Urus Pink
    1908067, -- Lamborghini Urus Giallo Inti
    1961041, -- Bugatti Veyron 16.4 (Sắc Màu)
    1961042, -- Bugatti Veyron 16.4 (Vàng)
    1961043, -- Bugatti Veyron 16.4
    1961044, -- Bugatti La Voiture Noire
    1961045, -- Bugatti La Voiture Noire (Hợp Kim)
    1961046, -- Bugatti La Voiture Noire (Chiến Binh)
    1961047, -- Bugatti La Voiture Noire (Tinh Vân)
    1961151, -- Bugatti Bolide (Lưỡi Gương)
    1961152, -- Bugatti Bolide (Bỉ Ngạn)
    1961153, -- Bugatti Bolide (Ảo Ảnh Hồ Băng)
    1961048, -- Aston Martin Valkyrie (Luminous Diamond)
    1961049, -- Aston Martin Valkyrie (Racing Green)
    1915005, -- Aston Martin DBS Volante (Deep Cosmos)
    1915006, -- Aston Martin DBS Volante (Celestial Pink)
    1915007, -- Aston Martin DBS Volante (Black-Bronze Satin)
    1908084, -- Aston Martin DBX707 (Neon Purple)
    1908085, -- Aston Martin DBX707 (Quasar Blue)
    1961051, -- Pagani Zonda R (Tricolore Carbon)
    1961052, -- Pagani Zonda R (Bianco Benny)
    1961053, -- Pagani Zonda R (Melodic Midnight)
    1961054, -- Pagani Imola (Grigio Montecarlo)
    1961055, -- Pagani Imola (Crystal Clear Carbon)
    1961056, -- Pagani Imola (Nebula Dream)
    1961057, -- Pagani Imola (Arctic Aegis)
    1961137, -- Bentley Batur (Kim Cương Lấp Lánh)
    1961138, -- Bentley Batur (Tận Cùng Thời Gian)
    1961139, -- Bentley Betayga Azure (Vương Quốc Huyền Ảo)
    1903200, -- Bentley Flying Spur Mulliner (Tinh Vân Xanh)
    1903201, -- Bentley Flying Spur Mulliner (Dòng Chảy Vịnh Hẹp)
    1908094, -- Bentley Betayga Azure (Mưa Hoa)
    1908095, -- Bentley Betayga Azure (Đêm Yên Tĩnh)
    1915008, -- Bentley Continental GTC Mulliner (Mộng Cảnh Lung Linh)
    1915009, -- Bentley Continental GTC Mulliner (Quý Tộc Áo Tím)
    1961038, -- Maserati MC20 Bianco Audace
    1961039, -- Maserati MC20 Rosso Vincente
    1961040, -- Maserati MC20 Sogni
    1908075, -- Maserati Levante Blu Emozione
    1908076, -- Maserati Luce Arancione
    1908077, -- Maserati Levante Neon Urbano
    1908078, -- Maserati Levante Firmamento
    1961036, -- Dodge Challenger SRT Hellcat - Blaze
    1961037, -- Dodge Challenger SRT Hellcat - Lime
    1961050, -- Dodge Challenger SRT Hellcat Jailbreak - Hellfire
    1961136, -- Dodge Challenger SRT Hellcat - Blaze
    1961150, -- Dodge Challenger SRT Hellcat Jailbreak - Hellfire
    1903088, -- Dodge Charger SRT Hellcat - Fuchsia
    1903089, -- Dodge Charger SRT Hellcat - Tuscan Torque
    1903090, -- Dodge Charger SRT Hellcat Jailbreak - Violet Venom
    1903189, -- Dodge Charger SRT Hellcat - Tuscan Torque
    1903190, -- Dodge Charger SRT Hellcat Jailbreak - Violet Venom
    1908086, -- Dodge Hornet - Scarlet Sting
    1908088, -- Dodge Hornet GLH Concept - Redline
    1908089, -- Dodge Hornet - Sunburst
    1908188, -- Dodge Hornet GLH Concept - Redline
    1908189, -- Dodge Hornet - Sunburst
    1961062, -- Porsche 918 Spyder (Dòng Nước)
    1961063, -- Porsche 918 Spyder (964 Bạc Ánh Kim)
    1961064, -- Porsche 918 Spyder (Hồng)
    1903218, -- Porsche Panamera Turbo S (Lam Ngọc)
    1903219, -- Porsche Panamera Turbo S (Xanh Viper)
    1908108, -- Porsche Cayenne Turbo GT (Đường Đua Rực Lửa)
    1908109, -- Porsche Cayenne Turbo GT (Cam Dung Nham)
    1915021, -- Porsche 911 Carrera 4 GTS Cabriolet (Ngàn Sao)
    1915022, -- Porsche 911 Carrera 4 GTS Cabriolet (Đỏ Ruby)
    1961058, -- Shelby 427 Cobra(Xanh & Trắng)
    1961059, -- Shelby 427 Cobra (Graffiti Phục Cổ)
    1903210, -- Shelby GT500 (Đen & Đỏ)
    1903211, -- Shelby GT500 (Người Ngoài Hành Tinh Cyber)
    1961068, -- Ford Mustang GTD (Huyền Thoại Xanh Tươi)
    1961069, -- Ford Mustang GTD (Tinh Thần Nước Mỹ)
    1961060, -- Lotus Emira (Rừng Sâu Thẫm)
    1961061, -- Lotus Emira (Lướt Sắc Xanh)
    1961065, -- Apollo EVO (Vàng Rực Rỡ)
    1961066, -- Apollo EVO (Hoàng Hôn)
    1961067, -- Apollo EVO (Băng Giá)
    1903220, -- Apollo Intensa Emozione (Hỏa Ngục Nóng Chảy)
    1903221, -- Apollo Intensa Emozione (Bóng Ma Tím)
    1903222, -- Apollo Intensa Emozione (Quyết Đấu)
    1903223, -- Apollo Intensa Emozione (Bão Tố)
    1961140, -- Ảo Ảnh Hoa Hồng SSC Tuatara
    1961141, -- Hạc Trời SSC Tuatara
    1961142, -- Đao Bình Minh SSC Tuatara Striker
    1961143, -- Màn Đêm Xanh SSC Tuatara Striker
    1903071, -- Tesla Roadster (Kim Cương)
    1903072, -- Tesla Roadster (Pha Lê Tím)
    1903073, -- Tesla Roadster (Xanh Biển Cả)
    1901073, -- DUCATI Panigale V4S
    1901074, -- Ducati Panigale V4S Black Phantom
    1901075, -- Ducati Panigale V4S Crimson Storm
    1901076, -- Ducati Panigale V4S Swift Mirage
    1401000, -- New Years Blessing Parachute
    1401001, -- Happy New Year Parachute
    1401002, -- Dù Xương Đỏ
    1401003, -- Dù tiểu quỷ tinh nghịch
    1401005, -- Dù nhện biến hình
    1401006, -- Dù Mùa 5
    1401007, -- Dù sinh nhật
    1401008, -- Dù Sếu Vàng
    1401009, -- Dù Quỷ Đỏ
    1401010, -- Dù hoa bách thảo
    1401011, -- Dù anh đào
    1401012, -- Dù Campus Tournament
    1401013, -- Dù Joker
    1401014, -- Dù chú hề
    1401015, -- Carabao Parachute
    1401016, -- Orange Life Parachute
    1401017, -- Dù ưng vàng
    1401018, -- Dù Quán quân Mùa 8
    1401019, -- Dù Đội trưởng Ryan
    1401020, -- Dù kẻ lang thang
    1401021, -- Dù cung trăng
    1401022, -- OPPO F11 PRO SURVIVOURS PARACHUTE
    1401023, -- Dù lãnh chúa Sekigahara (Vuông)
    1401024, -- Dù Đồng Minh Loot Thính
    1401025, -- Dù Đêm Mê Hoặc (Vuông)
    1401026, -- Dù cát tường
    1401027, -- Dù PMCO
    1401028, -- Dù Quán quân Mùa 7
    1401029, -- Dù sinh nhật rực rỡ
    1401031, -- Dù Quán quân Mùa 6
    1401032, -- Dù Dao Găm Đỏ
    1401033, -- Dù WALKER
    1401034, -- Dù Phù Thủy Băng Giá
    1401035, -- Dù người thách đấu
    1401036, -- Dù BAPE X PUBGM CAMO
    1401037, -- Dù Godzilla (Trắng)
    1401038, -- Dù Godzilla (Vàng)
    1401039, -- Dù Godzilla (Xanh)
    1401040, -- Dù Monarch
    1401041, -- Dù Cà Ri
    1401043, -- Dù Người Gác Đêm
    1401044, -- Dù hoa hồng đen
    1401045, -- Dù Mèo May Mắn
    1401046, -- Dù Đêm u ám
    1401047, -- Dù Cá Voi Sát Thủ
    1401048, -- Dù thủy quái Kraken
    1401050, -- Dù giai điệu âm nhạc
    1401051, -- Dù OPPO Reno
    1401052, -- Dù OPPO VOOC
    1401053, -- Dù Đêm Mê Hoặc
    1401054, -- Dù Chú Heo Tinh Nghịch
    1401055, -- Dù Red (Dài)
    1401056, -- PMJC Parachute
    1401057, -- PMSC Parachute
    1401059, -- Dù Quán quân Draconian
    1401060, -- Dù lãnh chúa Sekigahara
    1401061, -- Dù Tiểu Quỷ
    1401062, -- Dù Quán quân Mùa 9
    1401063, -- Dù Quán quân Mùa 10
    1401064, -- Dù Mèo Đen
    1401065, -- Dù Gà trống
    1401066, -- Dù Mọt Sách Băng Giá
    1401067, -- Dù Người Giảm Đau #11
    1401068, -- Super Power Parachute
    1401071, -- Dù Luân Hồi Vô Tận
    1401072, -- Dù Chúa Tể Muôn Loài
    1401074, -- Dù Bí Ngô Kinh Dị
    1401085, -- Dù Gà Thơm Ngon
    1401086, -- Dù Quán quân Mùa 11
    1401087, -- Dù Hoa Sen Máu
    1401088, -- Dù Hành Tinh Trôi Dạt
    1401089, -- Dù Quán Quân Mùa 12
    1401090, -- Dù Ninja Sát Thủ
    1401091, -- Dù Neko Sakura
    1401092, -- Dù Người Tiên Phong
    1401094, -- Dù Fantasy Girl
    1401095, -- Dù Tranh Vẽ Chiến Trường
    1401096, -- Dù Người Phán Quyết
    1401097, -- Dù Africa Pride
    1401098, -- Dù Africa Unite
    1401100, -- Dù Cậu Vàng
    1401102, -- Dù đặc vụ PMSC World Cup
    1401103, -- Dù Quân Đoàn Thất Lạc
    1401104, -- Dù Giải Đấu PMCO
    1401106, -- Dù Trung Úy Vũ Trụ
    1401107, -- Dù Đầy Tớ Huyết Nha
    1401108, -- Dù Street Dancer 3
    1401109, -- Dù Unique KingCard
    1401111, -- Dù Bánh Ú
    1401112, -- Dù Gào Thét
    1401113, -- Dù Thủ Vệ Tự Do
    1401115, -- Dù Kẹo Ngọt
    1401117, -- Dù Cao Bồi Viễn Tây
    1401119, -- Dù Giáp Samurai
    1401122, -- Incredible Parachute
    1401124, -- Dù Warrior
    1401125, -- Dù Quý Cô Gothic
    1401127, -- Dù Thần Thoại Ả Rập
    1401128, -- Dù Nhà Vô Địch Arena
    1401129, -- Dù Quán Quân Mùa 13
    1401130, -- Dù Gorilla
    1401131, -- Dù PMGC
    1401133, -- Dù Mùa 15
    1401134, -- Dù Tulip
    1401135, -- Dù Ác Ma Cuồng Nộ
    1401137, -- Dù Mùa 14
    1401138, -- Dù Pro League (Vàng)
    1401139, -- Dù Pro League (Bạc)
    1401140, -- Dù Lạc Đà Bảnh Bao
    1401141, -- Dù Gà Rán
    1401142, -- Dù CLB Hoàng Gia
    1401145, -- Dù Bảy Sắc
    1401146, -- Dù Mountain Dew
    1401147, -- Dù Tư Tế Tối Cao
    1401148, -- Dù Idol
    1401149, -- Dù Dang Rộng Đôi Cánh
    1401150, -- Dù Chiến Binh Thép
    1401151, -- Dù Quán Quân Mùa 16
    1401152, -- Dù Liềm Tử Thần
    1401153, -- Dù emoji Thỏa Mãn
    1401154, -- Dù emoji
    1401155, -- Dù emoji Vui Nhộn
    1401156, -- Dù Qualcomm
    1401157, -- Dù Điểm Sơ Tán
    1401159, -- Dù Lãnh Chúa Độc Tài
    1401160, -- Dù Kẹp Hạt Dẻ Vui Vẻ
    1401161, -- Dù Long Vương
    1401163, -- Dù Giáp Chiến Thần
    1401164, -- Dù Giai Điệu Yêu Thương
    1401165, -- Dù Quán Quân Mùa 17
    1401167, -- Dù Ánh Trăng Huyền Bí
    1401168, -- Dù Tiệc Disco
    1401169, -- Dù Quán Quân Mùa 18
    1401170, -- Dù Tuyết Anh Đào
    1401171, -- Dù Tổ Ong
    1401174, -- Dù Quán Quân Mùa 19
    1401177, -- Dù Quán Quân C1S1
    1401178, -- Dù Băng Cát Sét
    1401179, -- Dù El Diablo
    1401181, -- Chúa Tể Băng Giá - Dù
    1401182, -- Dù Kẻ Săn Mồi Biển Xanh
    1401183, -- Dù Mộng Điệp
    1401184, -- Dù Bọ Cánh Cứng
    1401186, -- Dù Rùa và Thỏ
    1401187, -- Dù Nhịp Bước Mạnh Mẽ
    1401188, -- Dù PMPL Mùa Xuân 2021
    1401189, -- Dù GodzillaVsKong
    1401190, -- Dù Hành Trình Kỳ Diệu
    1401191, -- Dù Dấu Ấn Vũ Trụ
    1401192, -- Dù Đầu Bếp Gà
    1401193, -- Dù Nghệ Thuật Sắc Màu
    1401194, -- Dù Aerial Punk Rich Brian
    1401195, -- Dù OPPO
    1401196, -- Dù BUG
    1401197, -- Dù Chúa Tể Bánh Răng
    1401198, -- Dù Xiaomi
    1401200, -- Dù Đôi Mắt Biển Sâu
    1401201, -- Dù OnePlus
    1401204, -- Dù foodpanda
    1401205, -- Dù PMPL Mùa Thu 2021
    1401208, -- Dù Thành Phố Trên Không
    1401209, -- Dù Bóng Ma Tương Lai
    1401210, -- Dù Mật Thám Cơ Khí
    1401212, -- Dù Thành Phố Sắc Màu
    1401213, -- Dù Súng Hoa Hồng
    1401215, -- Dù Băng Giá
    1401216, -- Dù Bản Đồ Kho Báu
    1401217, -- Dù Cơn Sốt Giáng Sinh
    1401218, -- Dù Họa Tiết Vàng
    1401219, -- Dù Vương Quốc Vàng
    1401220, -- Dù Hoàng Hôn Rực Rỡ
    1401221, -- Dù Bồ Câu Trắng
    1401222, -- Dù Vòng Xoay Thời Gian
    1401223, -- Dù Zong
    1401224, -- Dù Quán Quân C1S2
    1401225, -- Dù Quán Quân C1S3
    1401227, -- Dù Đại Hạ Giá
    1401228, -- Dù Lãng Khách Thời Thượng
    1401231, -- Dù PMGC 2021
    1401232, -- Dù Liverpool FC
    1401233, -- Dù Đột Phá
    1401234, -- Dù Voi Sắc Màu
    1401235, -- Dù Hợp Tác Egor Kreed
    1401236, -- Gackt Moon Parachute
    1401237, -- Dù Dune
    1401238, -- Dù Guruh Gundala
    1401239, -- Dù C2S4
    1401240, -- Dù Baby Shark
    1401241, -- Dù JAPAN LEAGUE S2
    1401242, -- Dù Đầu Bếp Quái Thú
    1401243, -- Dù Bá Chủ Đại Dương
    1401244, -- Dù C2S5
    1401245, -- Dù Nữ Hoàng Điện Tử
    1401246, -- Dù Nhâm Dần
    1401247, -- Dù Sắc Xuân
    1401248, -- Dù Jujutsu Kaisen
    1401249, -- Dù Shiba Inu
    1401250, -- Dù Motorola
    1401252, -- Dù Trận Chiến Trendy
    1401254, -- Dù DJ Cá Tính
    1401255, -- Dù Chị Chị Em Em
    1401256, -- Dù Graffiti Neon
    1401257, -- Dù C2S6
    1401258, -- Dù Người Nhện: Không Còn Nhà
    1401259, -- Dù Sát Thủ Thời Không
    1401260, -- Dù Vùng Đất Hoang
    1401261, -- Dù Sắc Màu
    1401262, -- Dù Lễ Hội Sắc Màu
    1401263, -- Dù Rạp Xiếc Thần Kỳ
    1401264, -- Dù Thiếu Nữ Tóc Đỏ
    1401265, -- Dù Bộ Đôi Hoàn Hảo
    1401266, -- Dù Thiếu Nữ Song Sinh
    1401267, -- Dù Cánh Cổng Kỳ Dị
    1401268, -- Dù Thiếu Nữ Anime
    1401269, -- Dù Gà Chiến Đấu
    1401270, -- Dù Nến Xanh
    1401271, -- Dù Hồn Ma Nghịch Ngợm
    1401272, -- Dù Thiếu Nữ Cầu Nguyện
    1401273, -- Dù Ma Nữ Đáng Yêu
    1401274, -- Dù Evangelion NERV
    1401275, -- Dù Chị Em Song Sinh
    1401276, -- Dù PMPL Mùa Xuân 2022
    1401277, -- Dù Gấu Teddy GB
    1401278, -- Dù Sư Tử Thời Trang
    1401280, -- Dù Kỷ Niệm Tuổi Thơ
    1401281, -- Dù C3S7
    1401282, -- Dù Mèo Khổng Lồ
    1401283, -- Dù Butterfinger
    1401284, -- Siêu Dù Nhảy
    1401285, -- Dù Đồng Minh Mùa Hè
    1401286, -- Dù Sóc Chuột
    1401287, -- Dù Hỏa Diệm Ma Giáp
    1401289, -- Dù Heartrocker
    1401290, -- Dù Sư Tử Lưỡng Hà
    1401291, -- Dù realme
    1401292, -- Dù Lil Burger
    1401294, -- Dù Dòng Sông Mộng Mơ
    1401295, -- Dù C3S8
    1401296, -- Dù Đêm Của Phép Màu
    1401298, -- Dù Vinh Quang
    1401299, -- Dù Bản Đồ Sao
    1401300, -- Dù Chúa Tể Gai Độc
    1401301, -- Dù Bóng Ma Và Nàng
    1401302, -- Dù Gai Bé Bỏng
    1401303, -- Dù Uqabi
    1401308, -- Dù Phù Thủy Băng Giá
    1401309, -- Dù Tốc Độ Cực Hạn
    1401310, -- Dù PMWI 2022
    1401311, -- BGMI Esports Parachute
    1401312, -- PMJL SEASON3 Parachute
    1401313, -- PMPS 2022 Parachute
    1401314, -- Dù Chiến Binh Ngưu
    1401315, -- Dù Quyền Lực Tối Thượng
    1401316, -- Dù Đội Bóng Ả Rập
    1401317, -- Dù Ngàn Sao Rực Rỡ
    1401318, -- Dù Pháp Sư Thiên Văn
    1401319, -- Dù C3S9
    1401320, -- Dù BoBoiBoy
    1401323, -- Dù Đường Đua Hoang Dã
    1401324, -- Dù Tuần Lộc Trắng
    1401325, -- Dù Rìu Hoàng Kim
    1401326, -- Dù Vàng Huyền Bí
    1401330, -- Dù Du Hành Tinh Vân
    1401332, -- Dù Mèo Tuyết
    1401334, -- Dù KFC
    1401335, -- Dù Thủy Sư Cuồng Nộ
    1401336, -- Dù Sọ Nham Thạch
    1401337, -- Dù Bá Chủ Bầu Trời
    1401338, -- Dù Grubhub
    1401339, -- Dù AFA
    1401340, -- Dù Huyền Thoại Siêu Sao Messi
    1401343, -- Dù PMGC 2022
    1401345, -- Dù Bản Đồ Kho Báu
    1401346, -- Dù Nobru
    1401347, -- Dù Sony
    1401349, -- Dù Đột Kích Trên Không
    1401351, -- Dù Nữ Hiệp
    1401353, -- Dù Chú Hề Quỷ Quyệt
    1401355, -- Dù Lý Tiểu Long
    1401356, -- Dù Cặp Đôi Diễn Võ
    1401357, -- Dù Donkey King
    1401360, -- Dù Pro League
    1401361, -- Dù Kế Hoạch Đỏ Thẫm
    1401362, -- Dù C4S11
    1401363, -- Dù Bản Đồ Vũ Trụ
    1401364, -- Dù BE@RBRICK
    1401365, -- Dù Nguồn Sáng Vinh Quang
    1401366, -- Dù Ký Ức Xưa
    1401367, -- Dù Bugatti
    1401368, -- Dù Hóa Thạch Khủng Long
    1401369, -- Dù Trốn Thoát T-Rex
    1401370, -- Dù Dragon Ball Super
    1401371, -- Dù C4S12
    1401372, -- Dù Huyết Rồng
    1401373, -- UNIVERSTAR BT21 Parachute
    1401374, -- Dù HUAWEI AppGallery
    1401375, -- Dù PMWI 2023
    1401376, -- Dù C5S13
    1401377, -- Dù Thỏ Disco
    1401378, -- Dù Aston Martin
    1401379, -- Dù Mùa Hè Trên Bãi Biển
    1401380, -- Dù C5S14
    1401381, -- Dù C5S15
    1401382, -- Dù PMGC 2023
    1401383, -- Dù KFC
    1401385, -- Dù Yeti Khổng Lồ
    1401386, -- Dù Pagani
    1401387, -- Dù Báo Sắc Màu
    1401388, -- Dù Bé Sóc Đáng Yêu
    1401389, -- Dù Kỳ Giông Hồng
    1401390, -- RS Swagster Parachute
    1401391, -- Dù Gấu Trúc Ngọt Ngào
    1401392, -- Dù Chiến Binh Hoa Hồng
    1401393, -- Dù Cuộc Chiến Chính Nghĩa
    1401394, -- Dù LINE FRIENDS
    1401395, -- Dù Hồ Ly Thần Bí
    1401396, -- Dù Zanmang Loopy
    1401397, -- Hardik Sky Parachute
    1401398, -- Dù C6S16
    1401399, -- Dù Bóng Ma Quyến Rũ
    1401400, -- Dù Bảo Hộ Hoàng Gia
    1401401, -- Dù Bentley
    1401402, -- SPY×FAMILY Dù
    1401403, -- Dù Nhật Thực
    1401404, -- Dù Chiến Sĩ Thần Giáp
    1401405, -- Dù C6S17
    1401406, -- Dù Giai Điệu Mèo Con
    1401407, -- Dù Thành Phố Hỗn Loạn
    1401408, -- Dù Đôi Cánh Cận Vệ
    1401409, -- Dù Thiết Mã
    1401410, -- Dù Bay Lướt Vũ Trụ
    1401411, -- Dù C6 S18
    1401412, -- Dù Nữ Đế Hắc Ám
    1401413, -- Dù Hợp Tác Lamborghini
    1401416, -- Dù Tượng Đá Cổ Xưa
    1401417, -- Dù Đại Dương Xanh
    1401418, -- KAKAO FRIENDS Parachute
    1401419, -- Dù Infinix GT
    1401420, -- Dù Esports World Cup 2024
    1401421, -- Dù C7S19
    1401422, -- Dù Thỏ Tinh Quái
    1401423, -- Dù Hợp Tác VW
    1401424, -- Dù Miêu Linh Sắc Màu
    1401425, -- Dù Hắc Long Ma Nhãn
    1401426, -- Dù Âm Dương
    1401427, -- NieR:Automata Parachute
    1401428, -- Dù Đam Mê Esports
    1401429, -- Dù C7S20
    1401430, -- Dù Venom: Kèo Cuối
    1401431, -- Dù Bộ Tộc Ngân Hà
    1401432, -- Dù Tuần Lộc Hoàng Gia
    1401433, -- Dù McLaren
    1401434, -- Dù PMGC 2024
    1401435, -- Dù lượn Sói Tuyết
    1401436, -- Dù lượn Bóng Nước
    1401437, -- Dù lượn C7S21
    1401438, -- Dù Cá Koi Xuân Sắc
    1401439, -- Dù Đại Bàng
    1401440, -- Dù Hoa Hồng Bóng Đêm
    1401441, -- Opanchu Parachute
    1401442, -- Neon Drop BE 6 Parachute
    1401443, -- Dù C8S22
    1401444, -- Dù Lượn Hắc Cốt
    1401445, -- Dù Cực Quang Tinh Tú
    1401446, -- Godzilla vs. Dù Destoroyah
    1401447, -- Dù Thỏ Bồng Bềnh
    1401448, -- Parachute(Frieren&Fern)
    1401449, -- Dù C8S23
    1401450, -- Dù Lượn Mã Số Hóa 
    1401451, -- Dù Lượn Khuếch Đại Sắc Màu
    1401452, -- Dù Hợp Tác Shelby
    1401453, -- Dù Ráng Chiều Rực Cháy
    1401454, -- Dù Attack on Titan
    1401455, -- Dù Cơ Khí 
    1401456, -- Mountain Dew Neon Shard Parachute
    1401457, -- Dù C8S24
    1401458, -- Dù Vũ Trụ
    1401459, -- Dù Transformers
    1401460, -- Dù Thần Mệnh
    1401461, -- Dù Cún Yêu
    1401462, -- Bbangbbang's diary Parachute
    1401463, -- Realme Parachute
    1401464, -- Dù Infinix GT
    1401465, -- Dù C9S25
    1401466, -- Dù Ác Quỷ
    1401467, -- Dù Kaiju No. 8
    1401468, -- Dù TEAM SONIC
    1401469, -- Dù Hồ Điệp Lấp Lánh
    1401470, -- Dù Lotus
    1401471, -- Dù Bông Xù
    1401472, -- Dù Gen Hoàn Hảo
    1401473, -- Tokyo Revengers Parachute
    1401474, -- Sky Striker Parachute
    1401475, -- Dù C9S26
    1401476, -- Dù Lượn Gấu Ngọt Ngào
    1401477, -- Dù Balenciaga
    1401478, -- Dù Lượn Tuyết Hàn
    1401479, -- Dù Porsche
    1401480, -- Dù Hắc Linh
    1401481, -- Dù Chồn Chill
    1401482, -- TV Anime DAN DA DAN Parachute
    1401483, -- Dù C9S27
    1401484, -- Dù Lượn Shuriken
    1401485, -- Dù Bóng Ma Anh Quốc
    1401486, -- Dù The King of Fighters
    1401487, -- Dù Lượn Vũ Khúc
    1401488, -- Dù Bảo Thạch
    1401489, -- Dù Chuỗi Mùa Giải (2026H1)
    1401490, -- Dù S28
    1401491, -- Dù Trò Chơi Chúa Hề Lém Lĩnh
    1401492, -- Dù Apollo
    1401493, -- Dù Hacker Lạnh Lùng
    1401494, -- Dù Hội Tụ Đa Chiều
    1401495, -- Catch! Teenieping Parachute
    1401496, -- SAKAMOTO TARO Parachute
    1401497, -- Nakiri Ayame Parachute
    1401498, -- Dù S29
    1401499, -- Toxic Parachute
    1401500, -- Dù Red (Tròn)
    1401511, -- Dù Mèo Tinh Nghịch
    1401513, -- Dù San Martin FC
    1401515, -- Dù Mắt Quỷ
    1401516, -- Dù Sóng Đêm
    1401517, -- Dù Quả Quýt
    1401519, -- Dù Gấu Ngáy Ngủ
    1401520, -- Dù Hậu Duệ Đế Vương
    1401521, -- Dù Mây Cuộn
    1401526, -- Dù Hoa Văn Tráng Lệ
    1401527, -- Dù Trái Tim Biển Cả
    1401528, -- Dù Hành Tinh Mẹ
    1401529, -- Dù Hoàng Tử Ánh Kim
    1401530, -- Dù Giáp Gai
    1401531, -- Dù Vùng Nguy Hiểm
    1401532, -- Dù Ốc Biển
    1401534, -- Dù Vịt Vàng B.Duck
    1401538, -- Dù Thỏ Dịu Dàng
    1401540, -- Dù Yeti
    1401541, -- Dù Pixel Sắc Màu
    1401542, -- Dù Mỹ Vị
    1401543, -- Dù I Love Tao Kae Noi
    1401544, -- Dù Vẹt Baby
    1401545, -- Dù U.F.O
    1401546, -- Dù Baby Shark
    1401547, -- Dù Gấu Nhồi Bông
    1401548, -- Dù Mèo Nghiêm Túc
    1401549, -- Dù Vinh Quang Trường Tồn
    1401551, -- Dù Nữ Vương Khôi Giáp
    1401554, -- Dù Khủng Long Pixel
    1401555, -- Dù Cánh Bướm Hoàng Gia
    1401556, -- Dù Hành Trình Ngọt Ngào
    1401610, -- Dù Chúc Mừng Sinh Nhật
    1401611, -- Dù Sân Khấu Lấp Lánh
    1401613, -- Dù Thẩm Phán Anubis
    1401615, -- Dù Thần Horus
    1401616, -- Dù One Plus
    1401617, -- Dù Sư Tử Hống
    1401618, -- Dù Facebook
    1401619, -- Dù Bùa Hộ Mệnh Pharaoh
    1401620, -- Dù Pharaoh (Xanh)
    1401621, -- Dù Huyết Nha
    1401622, -- Dù LINE FRIENDS
    1401623, -- Dù PMNC 2021
    1401624, -- Dù Poseidon
    1401625, -- Dù Công Chúa Bộ Lạc
    1401628, -- Dù Phượng Hoàng Adarna Ảo Diệu
    1401629, -- Dù Thiếu Nữ Sáng Thế
    1401811, -- Giannis Parachute
    1401813, -- Dù Hành Trình Anh Hùng
    1401814, -- Dù Rock 'n' Roll
    1401815, -- Dù Chỉ Huy Chiến Trường
    1401816, -- Dù BURGER KING
    1401817, -- Dù Chiến Binh Huyết Ưng
    1401820, -- Dù Cá Chuồn
    1401822, -- Dù Quái Thú Đầm Lầy
    1401823, -- Dù Lãnh Chúa Phong
    1401824, -- Dù Hộp Quà
    1401826, -- Dù - Mối Tình Đầu
    1401827, -- Dù Nữ Hoàng Cà Phê
    1401828, -- Dù Vệ Binh Cổ Đại
    1401829, -- Dù Cơn Giận Của Thần
    1401832, -- Dù C4S10
    1401833, -- Dù Quái Thú Mê Cung
    1401835, -- Dù Poker Đối Kháng
    1401836, -- Dù Trò Chơi Chú Hề
    1401837, -- Dù Huyễn Ảnh
    1401838, -- Dù BLUE LOCK
    1401839, -- Dù Ford
    1401840, -- Dù Harley-Davidson®
    1401841, -- Dù Hoa Hồng Cốt
    1401842, -- Dù Song Tử
    1401843, -- Dù Lượn Vòng Nguyệt Quế
    1401844, -- Parachute(Pubniku)
    1401845, -- Dù S30
    1401846, -- Dù Sự Kiện Trial of Fire
    4151001, -- Dù (Xanh)
    4151002, -- Hiệu ứng nhảy dù (Vàng)
    4151003, -- Khói Lượn Dù (Hồng)
    4151004, -- Khói lượn xanh
    4151006, -- Khói lượn cầu vồng
    4151010, -- Thiết bị bay Bằng Chíu
    4151012, -- Ván Trượt Chu Kỳ
    4151013, -- Ván Trượt Tuyết
    4151014, -- Ván trượt CHU KỲ 2
    4151015, -- Khói Lượn Dù Chúc Mừng (3 màu)
    4151017, -- Ván trượt Trái Tim Rừng Xanh
    4151018, -- Ván trượt Sinh Nhật
    4151019, -- Tàu Lượn Chiến Thần Tình Yêu
    4151020, -- Ván Trượt Cảnh Vệ C3
    4151021, -- Tàu Lượn Sứ Giả Của Thần
    4151022, -- Tàu Lượn Cánh Vàng
    4151023, -- Ván Trượt Hợp Tác Messi
    4151024, -- Tàu Lượn Giáo Sĩ Đỏ Thẫm
    4151025, -- Tàu Lượn Diều Giấy
    4151026, -- Ván Trượt Đại Sư Võ Hồn
    4151027, -- Ván Trượt Cycle 4
    4151028, -- Ván Trượt Giọt Lệ Huyết
    4151029, -- Tàu Lượn Nữ Đế Ánh Sáng
    4151030, -- Tàu Lượn Ma Vương Huyết Hồn
    4151031, -- Tàu Lượn Khủng Long Túi Tiền
    4151032, -- Tàu Lượn Cánh Rồng Đỏ Thẫm
    4151034, -- Cân Đẩu Vân
    4151035, -- Tàu Lượn Giao Hưởng Gió
    4151036, -- Ván Trượt Máy Dập Sóng
    4151037, -- Ván Trượt CYCLE 5
    4151038, -- Dù Lượn Ngọc Trai Tuyệt Hảo
    4151040, -- Ván trượt Thợ Săn Điện Quang
    4151041, -- Dù Lượn Xương Xanh
    4151042, -- Tàu Lượn Công Chúa Công Nghệ
    4151043, -- Tàu Lượn Công Chúa Công Nghệ
    4151044, -- Ván Trượt Cá Mập
    4151045, -- Dù Lượn Mùa Đông Hoàng Gia
    4151046, -- Ván Trượt Lưỡi Dao Trời Xanh
    4151056, -- Dù Lượn Mùa Đông Hoàng Gia
    4151057, -- Ván Trượt Hỏa Hồ Ly
    4151058, -- Dù Lượn LINE FRIENDS
    4151059, -- Ván Trượt Xuyên Mây
    4151060, -- Dù Lượn Xà Kim
    4151061, -- Ván Trượt CYCLE 6
    4151062, -- Khói Lượn Dù Zanmang Loopy
    4151063, -- SPY×FAMILY Tàu Lượn Bond
    4151064, -- Dù Lượn Thiên Sứ
    4151065, -- Dù Lượn Thiên Sứ
    4151066, -- Dù Lượn Đế Vương Thần Vực
    4151067, -- Dù Lượn Kính Vạn Hoa
    4151068, -- Tàu Lượn Chúa Tể Gai Độc
    4151069, -- Tàu Lượn Tinh Vân Sấm Sét
    4151070, -- Tàu Lượn Kỵ Binh Thần Giáp
    4151071, -- Dù Lượn Vệ Thần Tình Ái
    4151072, -- Dù Lượn Ngao Du Vũ Trụ
    4151073, -- Dù Lượn Neon Huyền Bí
    4151074, -- PUBGM X NewJeans Glider
    4151075, -- Dù Lượn Vệ Thần Tình Ái
    4151076, -- Tàu Lượn Cửu Phong Thiên Tôn
    4151077, -- Máy Bay
    4151078, -- Tàu Lượn Hải Mã Sắt
    4151079, -- Tàu Lượn Đôi Cánh Thế Giới Ngầm
    4151080, -- Ván Trượt Cycle 7
    4151083, -- Dù Lượn Long Cốt
    4151084, -- Hồng Hỏa Diệm - Kar98 (Cấp 8)
    4151085, -- Dù Lượn Cánh Thép Xuyên Không
    4151086, -- DP Drift Parachute
    4151087, -- Dù Lượn Long Cốt
    4151089, -- Dù Lượn Hắc Điểu 
    4151090, -- Dù Lượn Giấc Mộng Ngọt Ngào
    4151091, -- Tàu Lượn Nhà Khám Phá Vũ Trụ
    4151092, -- Dù Lượn Lam Sư Tinh Hà
    4151093, -- Dù Lượn Ngọc Lang Thiên Giới
    4151094, -- Ván Trượt CYCLE 8
    4151095, -- Dù Lượn Đôi Cánh Anukhra
    4151096, -- Dù Lượn Đôi Cánh Pharaoh
    4151097, -- Tàu Lượn Siêu Thú Ghidorah
    4151098, -- Dù Lượn Thời Quang Khả Biến
    4151099, -- Dù Lượn Vương Quyền Hắc Ám
    4151103, -- Dù Lượn Chiến Xa Tinh Tú
    4151104, -- Tàu Lượn Thiết Bị ODM
    4151105, -- Dù Lượn Định Mệnh Huyết Chú
    4151106, -- Dù Lượn Quang Ảo Điện Từ 
    4151107, -- Dù Lượn Chiến Xa Tinh Tú
    4151108, -- Tàu Lượn Laserbreak
    4151109, -- Tàu Lượn Băng Thần
    4151110, -- Tàu Lượn Long Thánh
    4151111, -- Tàu Lượn Thợ Săn Phản Lực
    4151112, -- Tàu Lượn Tà Thần Mỹ Quang
    4151113, -- Ván Trượt CYCLE 9
    4151114, -- Tàu Lượn Long Thánh
    4151115, -- Tàu Lượn Băng Thần
    4151117, -- Tàu Lượn Preondactyl
    4151118, -- Dù Lượn Hồ Điệp Lấp Lánh
    4151119, -- Dù Lượn Chổi Phép Thuật
    4151120, -- Dù Lượn Long Kính
    4151121, -- Mikey Glider
    4151122, -- Dù Lượn Hồ Điệp Lấp Lánh
    4151123, -- Tàu Lượn Băng Linh Lưu Ly
    4151124, -- Tàu Lượn Huyết Dực Tử Thần
    4151125, -- Tàu Lượn Vệ Binh Ngân Hà
    4151126, -- Tàu Lượn Giải Trí
    4151127, -- Tàu Lượn Linh Mộc Vĩnh Cửu
    4151128, -- Tàu Lượn Thần Quang
    4151129, -- Ván Trượt Chuỗi Mùa Giải (2026H1)
    4151130, -- Tàu Lượn Nue
    4151131, -- Tàu Lượn Phượng Hoàng Đế Vương
    4151132, -- Tàu Lượn Huyết Dực Hắc Điểu
    4151133, -- Tàu Lượn Dịch Chuyển Không Gian
    4151134, -- Dù Lượn Đa Vũ Trụ
    4151135, -- SAKAMOTO TARO Glider
    4151138, -- Tàu Lượn Sấm Sét Đỏ
    4151139, -- Tàu Lượn Hư Không
    4151140, -- Tàu Lượn Song Tử
    4151141, -- Tàu Lượn Cerberus
    4151142, -- Tàu Lượn Ngọc Trai
    4151143, -- Tàu Lượn Song Tử
    4152031, -- Tàu Lượn Ma Vương Huyết Hồn
    4152035, -- Cân Đẩu Vân
    4152036, -- Windborne Euphony Glider
    4152037, -- Ván Trượt Máy Dập Sóng
    4152038, -- Ván Trượt CYCLE 5
    4152039, -- Tàu Lượn Ngọc Trai Tuyệt Hảo
    4152041, -- Boxerbolt Hoverboard (Shop)
    4152042, -- Blueyonder Glider
    4152043, -- Agile Charmer Glider
    4152044, -- Agile Charmer Glider
    4152045, -- Chilly Perch Glider
    4152046, -- Foxy Flare Hoverboard
    4152058, -- LINE FRIENDS Glider (Shop)
    4152059, -- Cloud Piercer Hoverboard (Shop)
    4152060, -- Golden Wings Glider (Shop)
    4152061, -- CYCLE 6 Skateboard (Shop)
    4152063, -- Tàu Lượn Bond SPY×FAMILY (Cửa Hàng)
    4152066, -- Dù Lượn Đế Vương Thần Vực (Cửa Hàng)
    4152067, -- Tàu Lượn Kính Vạn Hoa (Cửa Hàng)
    4152068, -- Tàu Lượn Chúa Tể Gai Độc (Cửa Hàng)
    4152069, -- Tàu Lượn Tinh Vân Sấm Sét (Cửa Hàng)
    4152070, -- Tàu Lượn Kỵ Binh Thần Giáp (Cửa Hàng)
    4152076, -- Tàu Lượn Cửu Phong Thiên Tôn (Cửa Hàng)
    4152077, -- Tàu Lượn (Cửa Hàng)
    4152078, -- Tàu Lượn Hải Mã Sắt (Cửa Hàng)
    4152079, -- Tàu Lượn Đôi Cánh Thế Giới Ngầm (Cửa Hàng)
    4152080, -- Ván Trượt CYCLE 7 (Cửa Hàng)
    4152092, -- Tàu Lượn Lam Sư Tinh Hà (Cửa Hàng)
    4152093, -- Tàu Lượn Ngọc Lang Thiên Giới (Cửa Hàng)
    4152094, -- Ván Trượt CYCLE 8 (Cửa Hàng)
    4152095, -- Dù Lượn Đôi Cánh Anukhra
    4152096, -- Dù Lượn Đôi Cánh Pharaoh
    4152097, -- Tàu Lượn Siêu Thú Ghidorah
    4152098, -- Dù Lượn Thời Quang Khả Biến
    4152099, -- Dù Lượn Vương Quyền Hắc Ám
    4152116, -- Tàu Lượn Long Thánh (Sảnh Một Người)
    1407895, -- X-Suit Quạ Huyết (7 Sao)
    1407856, -- X-Suit Phượng Hoàng (7 Sao)
    1405628, -- X-Suit Pharaoh Vàng (6 Sao)
    1406469, -- X-Suit Pharaoh Vàng (7 Sao)
    1405870, -- X-Suit Quạ Huyết (6 Sao)
    1407140, -- X-Suit Poseidon (7 Sao)
    1407142, -- X-Suit Silvanus (7 Sao)
    1407141, -- X-Suit Bão Tuyết (7 Sao)
    1407550, -- X-Suit Ánh Sáng Cầu Vồng (7 Sao)
    1406638, -- X-Suit Hề Bí Ẩn (6 Sao) [Đen]
    1406641, -- X-Suit Hề Bí Ẩn (6 Sao) [Trắng]
    1406872, -- X-Suit Chúa Tể Âm Ty (7 Sao)
    1406971, -- X-Suit Marmoris (7 Sao)
    1407103, -- X-Suit Fiore (7 Sao)
    1407219, -- X-Suit Ignis (7 Sao)
    1407366, -- X-Suit Galadria (7 Sao)
    1407512, -- X-Suit Anukhra (7 Sao)
    1407625, -- X-Suit Dravion (7 Sao) [Nam]
    1407667, -- X-Suit Dravion (7 Sao) [Nữ
    1407870, -- Bộ Nữ Thần Không Gian
    1407871, -- Bộ Thám Tử Đa Vũ Trụ
    1407812, -- Bộ Vệ Binh Hoang Dã
    1407758, -- Bộ Tiên Nữ Mùa Đông
    1407286, -- Bộ Mèo Cyber Tinh Nghịch
    1407329, -- Bộ Ánh Sáng Tĩnh Lặng
    1407391, -- Bộ Nữ Bá Tước Ma Cà Rồng
    1407392, -- Bộ Kẻ Phá Hoại Man Rợ
    1407387, -- Bộ Tử Thần Tận Thế
    1407440, -- Bộ Kẻ Chinh Phục Bắc Cực
    1406985, -- Bộ Người Tình Bãi Biển
    1407470, -- Bộ Thiên Thần Nổi Loạn
    1407471, -- Bộ Cực Quang Nanh Ngọc
    1407522, -- Bộ Hậu Duệ Tiên Cát
    1407330, -- Bộ Đô Đốc Bóng Ma
    1407523, -- Bộ Uy Quyền Tà Ác
    1407558, -- Bộ Thái Dương Thăng Hoa
    1407559, -- Bộ Ánh Sáng Nguyệt Cung
    1407572, -- Bộ Huyết Dạ Hoàng Hôn
    1407682, -- Bộ Kén Ẩn Sĩ
    1407695, -- Bộ Lễ Tình Nhân Rùng Rợn
    1407696, -- Bộ Lăng Kính Thăng Hoa
    1407632, -- Bộ Hắc Dạ Tà Ác
    1407573, -- Bộ Bóng Ma Điện Tử
    1406398, -- Bộ Bóng Ma Rực Lửa
    1406399, -- Bộ Kỵ Binh Oai Vệ
    1406482, -- Bộ Chúa Tể Gai Góc
    1406483, -- Bộ Tinh Vân Sấm Sét
    1406555, -- Bộ Khuôn Mặt Địa Ngục
    1406573, -- Bộ Thiên Nga Bóng Ma
    1406574, -- Bộ Quan Tòa Vũ Trụ
    1406656, -- Bộ Trưa Đẫm Máu
    1406657, -- Bộ Đô Đốc Biển Sao
    1406742, -- Bộ Đạo Sư Bạc
    1406744, -- Bộ Hiệp Sĩ Thái Dương
    1406789, -- Bộ Bóng Ma Địa Ngục
    1406823, -- Bộ Giọt Nguyệt Bất Diệt
    1406824, -- Bộ Kẻ Thù Nhuốm Máu
    1406897, -- Bộ Ác Mộng Đỏ Thẫm
    1407277, -- Trang Phục Hỏa Thần Cổ Ngữ
    1406891, -- Trang Phục Linh Hồn Xác Ướp
    1405623, -- Bộ Xác Ướp Vàng
    1400687, -- Bộ Xác Ướp Trắng
    1407618, -- Bộ Thực Hồn Bắc Cực (Polar Spectrophage)
    1406937, -- Trang Phục Nhân Vật Super Saiyan Son Goku
    1406938, -- Trang Phục Nhân Vật Frieza
    1406939, -- Trang Phục Nhân Vật Son Goku
    1406947, -- Trang Phục Nhân Vật Vegeta
    1406948, -- Trang Phục Nhân Vật Super Saiyan Vegeta
    1406950, -- Trang Phục Beerus
    1406951, -- Trang Phục Ma Bư
    1406952, -- Trang Phục Quy Lão Kame
    1406953, -- Trang Phục Nhân Vật Gohan Siêu Cấp
    1406954, -- Trang Phục Nhân Vật Piccolo
    1407264, -- Trang Phục Nhân Vật Vegito
    1407265, -- Trang Phục Nhân Vật Vegito Siêu Saiyan
    1407266, -- Trang Phục Nhân Vật Vegito Siêu Saiyan Xanh
    1407267, -- Trang Phục Nhân Vật Son Goku Siêu Saiyan Xanh
    1407268, -- Trang Phục Nhân Vật Son Goku Siêu Saiyan Xanh (Bị Thương)
    1407269, -- Trang Phục Nhân Vật Vegeta Super Saiyan Xanh
    1407270, -- Trang Phục Nhân Vật Vegeta Siêu Saiyan Xanh (Bị Thương)
    1407271, -- Trang Phục Nhân Vật Bulma
    1406385, -- Plugsuit Evangelion Shinji
    1406386, -- Plugsuit Evangelion Rei
    1406387, -- Plugsuit Evangelion Asuka
    1406388, -- Plugsuit Evangelion Mari
    1406389, -- Plugsuit Evangelion Kaworu
    1407563, -- Trang Phục Nhân Vật Eren Jaeger
    1407565, -- Trang Phục Nhân Vật Mikasa Ackermann
    1407566, -- Trang Phục Nhân Vật Armin Arlelt
    1407567, -- Trang Phục Titan Khổng Lồ (Armin)
    1407568, -- Trang Phục Nhân Vật Levi
    1407569, -- Trang Phục Titan Bọc Thép
    1407672, -- Trang Phục Nhân Vật Kafka Hibino
    1407673, -- Trang Phục Kaiju No. 8
    1407674, -- Trang Phục Nhân Vật Kikoru Shinomiya
    1407675, -- Trang Phục Kaiju No. 9
    1407676, -- Trang Phục Kaiju No. 10
    1407677, -- Trang Phục Nhân Vật Mina Ashiro
    1407678, -- Trang Phục Nhân Vật Reno Ichikawa
    1407679, -- Trang Phục Nhân Vật Soshiro Hoshina
    1406132, -- Trang phục DDU-DU DDU-DU ROSÉ
    1406133, -- Trang phục DDU-DU DDU-DU JENNIE
    1406134, -- Trang phục DDU-DU DDU-DU JISOO
    1406135, -- Trang phục DDU-DU DDU-DU LISA
    1406161, -- Trang phục How You Like That ROSÉ
    1406162, -- Trang phục How You Like That JENNIE
    1406163, -- Trang phục How You Like That JISOO 
    1406164, -- Trang phục How You Like That LISA
    1406178, -- Trang phục Lovesick Girls ROSÉ
    1406179, -- Trang phục Lovesick Girls JENNIE
    1406180, -- Trang phục Lovesick Girls JISOO
    1406181, -- Trang phục Lovesick Girls LISA
    1407346, -- PUBGM X NewJeans MINJI Set
    1407347, -- PUBGM X NewJeans HANNI Set
    1407348, -- PUBGM X NewJeans HAERIN Set
    1407349, -- PUBGM X NewJeans DANIELLE Set
    1407350, -- PUBGM X NewJeans HYEIN Set
    1407745, -- Trang Phục RAMI (Babymonster)
    1407746, -- Trang Phục ASA (Babymonster)
    1407747, -- Trang Phục AHYEON (Babymonster)
    1407748, -- Trang Phục RORA (Babymonster)
    1407749, -- Trang Phục CHIQUITA (Babymonster)
    1407750, -- Trang Phục PHARITA (Babymonster)
    1407751, -- Trang Phục RUKA (Babymonster)
    1407826, -- Trang Phục PUBG MOBILE × aespa KARINA
    1407827, -- Trang Phục PUBG MOBILE × aespa GISELLE
    1407828, -- Trang Phục PUBG MOBILE × aespa WINTER
    1407829, -- Trang Phục PUBG MOBILE × aespa NINGNING
    1407687, -- Trang Phục G-DRAGON PEACEMINUSONE
    1407688, -- Trang Phục Sân Khấu của G-DRAGON
    1410934,
    1407275,
    1410646,
    1407276,
    1410647,
    1407369,
    1406648, -- Trang Phục Biểu Tượng Bóng Đá Messi
    1406649, -- Trang Phục Huyền Thoại Siêu Sao Messi
    1406728, -- Trang Phục Kung Fu Lý Tiểu Long
    1406729, -- Trang Phục Chuyên Gia Cận Chiến Lý Tiểu Long
    1406730, -- Trang Phục Rồng Gầm Lý Tiểu Long
    1406731, -- Trang Phục Võ Sĩ Lý Tiểu Long
    1407206, -- SPY×FAMILY Trang Phục Hoàng Hôn
    1407401, -- C.C. Set
    1407402, -- Kallen Kozuki Set
    1407404, -- Suzaku Kururugi Set
    1407405, -- ZERO Set
    1407408, -- Emperor Lelouch Set
    1407769, -- Okarun(transformed) Set
    1407770, -- Okarun Set
    1407771, -- Momo Set
    1407772, -- Jiji(transformed) Set
    1407773, -- Aira Set
    1407794, -- Trang Phục Nhân Vật John Shelby
    1407795, -- Trang Phục Nhân Vật Arthur Shelby
    1407796, -- Trang phục Thomas Shelby
    1407798, -- Trang Phục Nhân Vật Iori Yagami
    1407800, -- Trang Phục Nhân Vật Mai Shiranui
    1407801, -- Trang Phục Nhân Vật Nakoruru
    1407846, -- Trang Phục Nhân Vật Kimono Ryomen Sukuna
    1407848, -- Trang Phục Nhân Vật Suguru Geto
    1407901, -- Trang Phục Nhân Vật Isagi Yoichi
    1407902, -- Trang Phục Nhân Vật Bachira Meguru
    1407211,
    1407285,
    1407921,
    1407921,
    1407425,
    1406140,
    1407049,
    1407161,
    1407224,
    1407459,
    1405160, -- Huyền Thoại Godzilla
    1405161, -- Siêu Thú Ghidorah
    1405186, -- Bộ Đồ Godzilla
    1405662, -- Trang phục Giáp Samurai
    1405663, -- Trang phục Sát Thủ Bóng Đêm
    1406020, -- Trang phục Quái Thú
    1406398, -- Trang phục Hỏa Diệm Ma Giáp
    1406399, -- Trang phục Kỵ Binh Thần Giáp
    1406456, -- Trang Phục Anh Hùng Truyền Thuyết
    1406568, -- Trang Phục Nữ Hoàng Bóng Đêm
    1406569, -- Trang Phục Minh Vương Hành Quyết
    1406732, -- Trang Phục Nữ Đế Hoàng Kim
    1406733, -- Trang Phục Hoàng Đế Hoàng Kim
    1406764, -- Trang Phục Thiếu Nữ Đỏ Rực
    1400569, -- BAPE MIX CAMO HOODIE
    1400650, -- BAPE MIX CAMO SHORTS
    1400651, -- BAPE STA MID
    1404000, -- BAPE City Camo Hoodie
    1404002, -- BAPE City Camo Pants
    1404003, -- BAPE Sta Mid
    1404048, -- Áo BAPE X PUBGM CAMO
    1404049, -- Áo Hoodie cá mập BAPE X PUBGM CAMO
    1404050, -- Quần BAPE X PUBGM CAMO
    1404051, -- Giày BAPE X PUBGM CAMO
    1404016, -- Alan Walker T-shirt
    1404017, -- Alan Walker Hoodie
    1404042, -- Trang phục Alan Walker
    1404043, -- Áo Alan Walker
    1404044, -- Quần Alan Walker
    1404045, -- Giày Alan Walker
    1404340, -- Trang phục Alan Walker 2021
    1403038, -- Alan Walker Mask
    1403064, -- Khẩu trang Alan Walker
    402001, -- Khăn rằn sinh tồn
    402037, -- Khăn quàng cao bồi
    402043, -- Khăn quàng PUBG (Đỏ-Đen)
    402045, -- Khăn quàng PUBG (Chiến thuật)
    1400158, -- Mặt Nạ Hockey
    1402005, -- Mysterious Leather Mask
    1403100, -- Mặt nạ người leo núi
    403010, -- Áo Ba Lỗ Bẩn (Trắng)
    403028, -- Áo Trench coat (Màu đen)
    403181, -- Áo lính sa mạc
    403182, -- Áo Hoodie săn mồi (Đen)
    403183, -- Áo Hoodie biệt kích (Trắng)
    403192, -- Áo khoác bomber
    404006, -- Quần Jeans (Nâu)
    404008, -- Quần lính (Ka-ki)
    404013, -- Quần lính (Rằn ri)
    404015, -- Quần Jeans Bó (Màu Lam)
    404026, -- Quần túi hộp (Màu be)
    404028, -- Quần túi hộp (Màu đen)
    404084, -- Quần thể thao ngắn (Đen)
    404100, -- Quần người ẩn nấp (Đen)
    405001, -- Giày đế mềm (Màu trắng)
    405002, -- Giày thể thao cổ cao
    405019, -- Giày lính chim ưng (Đen)
    405044, -- Giày đế mềm (Đen)
    1400013, -- Quần Jeans Mỹ
    1404142, -- Áo thun THE WALKING DEAD (Trắng)
    1404143, -- Áo thun THE WALKING DEAD (Đen)
    1404218, -- Áo Hoodie COVERNAT (Trắng)
    1404219, -- Áo Hoodie COVERNAT (Đen)
    1404326, -- Áo thun Xiaomi
    1404327, -- Áo thun OnePlus
    1404405, -- Áo Đấu Hợp Tác Messi × PUBG MOBILE
    1404406, -- Áo Thun Lý Tiểu Long
    1404411, -- Hoodie Ducati
    1404412, -- Giày Ducati Corse City C2
    1404413, -- Quần Ducati Sport C2
    1404414, -- Áo Khoác Ducati Speed Evo C2
    1404426, -- Áo PMGC 2023
    1404427, -- Quần Người Chinh Phục Pagani
    1404428, -- Giày Người Chinh Phục Pagani
    1404508, -- Áo Hoodie Mr.Beast
    1400324, -- áo b
    1400325, -- áo a
    452001, 452002, 452003, -- Găng Tay (Gloves
    12201301, -- Hành động Sát thủ Gothic
    12216101, -- Hành động Võ sĩ Huyết Ưng
    12212201, -- Hành động Sát thủ Cực Ám
    12219207, -- Hành động Đại tướng Thiên Ngưu
    12209001, -- Hành động Võ sĩ (Samurai)
    12219561, -- Hành động Áo choàng Đỏ thẫm
    12210001, -- Hành động Cái chạm của Tử thần
    12219022, -- Hành động Thiết vệ Gai góc
    12208801, -- Hành động Dũng sĩ Bán thần
    12210801, -- Hành động Thợ săn Vỏ bạc
    12200701, -- Hành động Du hành Không thời gian
    12219242, -- Hành động Dạo bước Bầu trời
    12206001, -- Hành động Hoa linh Đồng xanh
    12205401, -- Hành động Vua của muôn thú
    12205201, -- Hành động Trái tim Cự thú
    12212601, -- Hành động Sát lục Thần bí
    12205601, -- Hành động Linh hồn Cự thú
    12219208, -- Hành động Hầu vương Cyber
    12212001, -- Hành động Võ thánh
    12206801, -- Hành động Hải long Thần bí
    12209801, -- Hành động Ngự linh sư
    12211401, -- Hành động Nữ phù thủy Băng tuyết
    12207001, -- Hành động Du hành Biển sao
    12211801, -- Hành động Chúa tể Trật tự
    12207901, -- Hành động Hải vương Quyến rũ
    12203401, -- Hành động Kỷ niệm Ảo ảnh
    12204001, -- Hành động Chú hề (Ngày Cá tháng Tư)
    12201801, -- Hành động Người bảo vệ Vùng tuyết
    12215601, -- Hành động Siêu nhân Hằng tinh
    12215532, -- Hành động Lãnh chúa Ngọn lửa
    12213201, -- Hành động Kế hoạch Ngày mai
    12215529, -- Hành động Kỵ sĩ Đua xe
    12219053, -- Hành động Nữ hoàng Trân bảo
    12204601, -- Hành động Thiên hạ Bố võ
    12215701, -- Hành động Hành tinh Vượn người
    12219003, -- Hành động Bóng tối Thần linh
    12219004, -- Hành động Ngân hồn Rực lửa
    12219009, -- Hành động Mê hoặc Rực lửa
    12219216, -- Hành động Tế tư Héo úa
    1404198, 
    1410085, 
    1404366, 
    1403137, 
    1410480, 
    1403028, 
    1400158, 
    40605011, 
    1404323, 
    1406001, 
    1403002,
    1104003046,
    1400127,
    1400371,
    1400376,    
    1501001174, -- Ba lô Pharaoh (Cấp 1)
    1501001220, -- Ba lô Huyết Nha (Cấp 1)
    1501001265, -- Ba lô Poseidon (Cấp 1)
    1501001548, -- Balo Thần Thoại Viễn Cổ (Cấp 1)
    1501001559, -- Balo Thanh Hoa Xà (Cấp 1)
    1501001567, -- Ba Lô Hỏa Linh Chí Tôn (Cấp 1)
    1501001577, -- Balo Đôi Cánh Vệ Thần (Cấp 1)
    1501001607, -- Balo Dơi Bóng Đêm (Cấp 1)
    1501001061, -- Ba lô Godzilla (Cấp 1)
    1501001062, -- Ba Lô Siêu Thú Ghidorah (Cấp 1)
    1501001082, -- Ba lô Genbu (Cấp 1)
    1501001112, -- Ba lô Pig Ngốc Nghếch (Cấp 1)
    1501001133, -- Ba lô Joker Khát Máu (Cấp 1)
    1501001243, -- Ba Lô Vịt Vàng B.Duck (Cấp 1)
    1501001273, -- Ba lô MECHAGODZILLA (Cấp 1)
    1501001304, -- Ba lô Ma Vương (Cấp 1)
    1501001331, -- Ba lô của Jinx (Cấp 1)
    1501001340, -- Ba Lô Hải Cẩu Tuyết (Cấp 1)
    1501001376, -- Ba lô Máy Hát Cổ Điển (Cấp 1)
    1501001400, -- Ba lô Baby Shark (Cấp 1)
    1501001463, -- Ba Lô BoBoiBoy (Cấp 1)
    1501001476, -- Ba Lô Biểu Tượng Bóng Đá Messi (Cấp 1)
    1501001480, -- Ba Lô Mì Indomie (Cấp 1)
    1501001487, -- Ba Lô Con Mắt Chết Chóc (Cấp 1)
    1501001521, -- Ba Lô Quy Lão Kame (Cấp 1)
    1501001539, -- Ba Lô PMGC 2023 (Cấp 1)
    1501001540, -- Ba Lô Gà Rán KFC (Cấp 1)
    1501001554, -- Ba Lô LINE FRIENDS SALLY (Cấp 1)
    1501001587, -- Ba Lô Đại Úy Loạn Thế (Cấp 1)
    1501001597, -- Bellygom Backpack (LV.1)
    1501001632, -- Opanchu Backpack (Lv.1)
    1501001643, -- Frieren&Mimic Backbag (Lv.1)
    1501001650, -- Ba Lô Titan Khổng Lồ Cấp 1
    1501001683, -- Ba Lô Balenciaga (Cấp 1)
    1501001715, -- SAKAMOTO TARO Backpack (Lv.1)
    1501001720, -- Ba Lô BLUE LOCK (Cấp 1)    
    1501001024, -- Balo Bá Tước
    1502001014, -- Mũ Đinh
    1502001439, -- mũ vương miện
    1502001069, -- mũ cương thi
    1502001023, -- mũ băng
    1400092, 
    1400101, 
    1400122, 
    1404191, 
    4151102,
    1406146,
    1403366,
    1404367,
    1405128, 1405129, 140224445, 140224445, -- crew
    1407961, 1407962, 1407963, 1407964, 1407965, 1407966, 1407967, 1407968, 1407969, 1407970, 1407971, 1502001508, 1502002508, 1502003508, 1411134, 1411133, 1411135, 1403771, 1403770, 1407994, 1407993, 1101006106, 1101006098, 4151145, 1903230, 1903231, 1903232, 1908117, 1908118, 1908119, 19116002, 19116003, 19116004, 1961070, 1961071, 1961072, 1961073, 1408045, 1408038, 1407990,
    -- ==============================================================================
    -- CÁC ID THEME SẢNH & NHẠC NỀN (LOBBY THEME & BGM) MỚI BỔ SUNG
    -- ==============================================================================
    202408035, -- Monument Tour Theme
    202408036, -- Expired Items
    202408037, -- Strange Town Theme
    202408038, -- Expired Items
    202408039, -- Street Art Theme
    202408040, -- Cyberpunk Hangar Theme
    202408041, -- Expired Items
    202408042, -- Champion Theme
    202408043, -- Pitch Paradise Theme
    202408044, -- Brilliant Winter
    202408045, -- Martial Arts Contest Theme
    202408046, -- Valentines Island Theme
    202408047, -- Moonlight Bazaar
    202408048, -- World of Wonder Theme
    202408049, -- Dino Island Theme
    202408050, -- World Martial Arts Tournament
    202408051, -- Sapphire Coast Lobby Theme
    202408052, -- Lobby
    202408053, -- Wasted Land Theme
    202408054, -- Midnight Circus Theme
    202408055, -- Chrono Portal Theme
    202408056, -- Champion Theme
    202408057, -- Civilization Wonder Lobby Theme
    202408058, -- Glacial Castle Lobby Theme
    202408059, -- Dragon Abode Theme
    202408060, -- Shinobi Warzone Theme
    202408061, -- Auto Showroom
    202408062, -- One Thousand and One Nights Lobby Theme
    202408063, -- City in the Sky Lobby Theme
    202408064, -- India 3.1 Lobby
    202408065, -- One Thousand and One Nights Lobby Theme
    202408066, -- Mecha Warship Theme
    202408067, -- Devious Cybercat Theme
    202408068, -- Lightshift Temple Theme
    202408069, -- Devious Chromacat Theme
    202408076, -- Mysterious Manor Theme
    202408077, -- Lupine Heights Theme
    202408078, -- Beyond Underworld Theme
    202408079, -- Poseidon's Trident Theme
    202408080, -- 2024 PMGC Theme
    202408081, -- Frostbound Kingdom Theme
    202408082, -- Arctic Era Theme
    202408083, -- Ice Witch Theme
    202408084, -- Imperial Palace Theme
    202408085, -- Eternal Citadel Theme
    202408086, -- Ethereal Brush Theme
    202408087, -- Luxury Drive Space
    202408088, -- Duneshine Theme
    202408089, -- Eternal Dunes Theme
    202408090, -- Sands of Fortune Theme
    202408091, -- Cogwheel Express Theme
    202408092, -- Gearbound Steamliner Theme
    202408093, -- Neonforge Metropolis Theme
    202408094, -- Imperial Pair Theme
    202408095, -- Spaceport Hub Theme
    202408096, -- Starship Port Theme
    202408097, -- Milky Way Expanse Theme
    202408098, -- Phantom Courtyard Theme
    202408099, -- Enchanted Terrace Theme
    202408100, -- Folded Mirage Theme
    202408101, -- Astral Reverie Theme
    202408102, -- Halloweeks Eve Theme
    202408103, -- Icy World Theme
    202408104, -- First Snow Party Theme
    202408105, -- Frigid Fairytale Theme
    202408106, -- Frontier Stronghold Theme
    202408107, -- 2025 PMGC Theme
    202408108, -- Forest City Theme
    202408109, -- Rootspring Theme
    202408110, -- Great Tree Theme
    202408111, -- Nature Temple Theme
    202501001, -- Classic Lobby BGM
    202501002, -- Lobby BGM
    202501003, -- Cozy Cabin BGM
    202501004, -- Runic Power
    202501007, -- YOU ARE MY HIGH
    1400563,
    40605012,
    40605010,
    1404423,
    403170,
    1400426,
    474031,
    -- [ BA LÔ CẤP 1 (BỔ SUNG) ]
    1501001001, -- Ba lô pizza nóng (Cấp 1)
    1501001002, -- Ba lô thỏ trắng (Cấp 1)
    1501001003, -- Ba lô bàn tay xương (Cấp 1)
    1501001004, -- Ba lô Cyberpunk (Lam) (Cấp 1)
    1501001005, -- Ba lô Cyberpunk (Tím) (Cấp 1)
    1501001006, -- Ba lô rạp xiếc (Cấp 1)
    1501001007, -- Ba lô hộp sọ (Cấp 1)
    1501001008, -- Ba lô đỏ & đen (Cấp 1)
    1501001009, -- Ba lô bão cô-ban (Cấp 1)
    1501001011, -- Ba lô gà chiến thắng (Cấp 1)
    1501001012, -- Ba lô ngôi sao nhạc rock (Cấp 1)
    1501001013, -- Ba lô hoa hồng (Cấp 1)
    1501001014, -- Ba lô kẻ lưu dạt (Cấp 1)
    1501001015, -- Ba lô gấu hồng (Cấp 1)
    1501001016, -- Ba lô người cứu hộ (Cấp 1)
    1501001017, -- Ba lô kiếm thủ (Cấp 1)
    1501001018, -- Ba ô người du hành xuyên thời gian (Cấp 1)
    1501001019, -- Ba lô Túi Giấy (Cấp 1)
    1501001020, -- Ba lô nhám (Cấp 1)
    1501001021, -- Ba lô bạc sáng (Cấp 1)
    1501001022, -- Ba lô kẻ lừa đảo (Cấp 1)
    1501001023, -- Ba lô nỗi kinh hoàng dưới màn đêm (Cấp 1)
    1501001025, -- Ba lô tiệc gà tây (Cấp 1)
    1501001026, -- Ba lô Gà Ngớ Ngẩn (Cấp 1)
    1501001027, -- Ba lô tiên phong (Cấp 1)
    1501001028, -- Ba lô thủ lĩnh (Cấp 1)
    1501001029, -- Ba lô dã ngoại (Cấp 1)
    1501001030, -- Ba lô Lính chì (Cấp 1)
    1501001031, -- Ba lô Yeti (Cấp 1)
    1501001032, -- Ba lô - Gấu Trúc (Cấp 1)
    1501001033, -- Ba lô dã ngoại (Cấp 1)
    1501001034, -- Ba lô Noel ấm áp (Cấp 1)
    1501001035, -- Ba lô thợ săn hủy diệt (Cấp 1)
    1501001036, -- Ba lô tuần lộc chibi (Cấp 1)
    1501001037, -- MOMMYSON Backpack (Lv. 1)
    1501001038, -- Ba lô Kẻ Săn Mồi Rừng Xanh (Cấp 1)
    1501001039, -- Ba lô sang chảnh (Cấp 1)
    1501001041, -- Ba lô thiên thần Cherubic (Cấp 1)
    1501001042, -- Ba lô hủy diệt (Cấp 1)
    1501001043, -- Ba lô Người Phán Quyết (Cấp 1)
    1501001044, -- Balo Sinh nhật (Cấp 1)
    1501001045, -- Ba lô sinh nhật sắc màu (Cấp 1)
    1501001046, -- Ba lô Samurai - Đỏ (Cấp 1)
    1501001047, -- Ba lô cánh bướm (Cấp 1)
    1501001048, -- Ba lô chiến binh vũ trụ (Cấp 1)
    1501001051, -- Ba lô chú hề (Cấp 1)
    1501001052, -- Ba lô bóng đá (Cấp 1)
    1501001053, -- Ba lô Quán quân Draconian (Cấp 1)
    1501001054, -- Ba lô nhà thám hiểm (Cấp 1)
    1501001055, -- Ba lô rùa (Cấp 1)
    1501001056, -- Ba lô kẻ lang thang (Cấp 1)
    1501001057, -- Ba lô Đội trưởng Ryan (Cấp 1)
    1501001058, -- Ba lô BAPE X PUBGM CAMO (Cấp 1)
    1501001059, -- Ba lô Thám Hiểm Cực Hạn (Cấp 1)
    1501001060, -- Ba lô Chiến Trường Đam Mê (Cấp 1)
    1501001063, -- Ba lô đơn giản (Cấp 1)
    1501001064, -- Ba lô Công Chúa Gà (Cấp 1)
    1501001065, -- Ba lô Quái vật (Cấp 1)
    1501001066, -- Ba lô cá heo (Cấp 1)
    1501001067, -- Ba lô mực con (Cấp 1)
    1501001068, -- Ba lô thời khắc chiến thắng (Cấp 1)
    1501001069, -- Ba lô cá mập (Cấp 1)
    1501001070, -- Ba lô Ngân Hà (Cấp 1)
    1501001071, -- Ba lô dao găm đỏ (Cấp 1)
    1501001072, -- Ba lô nhà khảo cổ (Cấp 1)
    1501001073, -- Ba lô thuyền trưởng khỉ đột (Cấp 1)
    1501001074, -- Ba lô Mặt cười (Cấp 1)
    1501001075, -- Ba lô Mặt buồn (Cấp 1)
    1501001076, -- Ba lô Mặt thông minh (Cấp 1)
    1501001077, -- Ba lô Mặt si tình (Cấp 1)
    1501001078, -- Ba lô Mặt ngưỡng mộ (Cấp 1)
    1501001079, -- Ba lô Thỏ Ngọc (Cấp 1)
    1501001081, -- Ba lô Thiên Sứ (Cấp 1)
    1501001083, -- Ba lô Huyền thoại vịnh Fjord (Cấp 1)
    1501001084, -- Ba lô đấu sĩ Demigod (Cấp 1)
    1501001085, -- Ba lô Tiểu Quỷ (Cấp 1)
    1501001086, -- Ba lô Huyết Tộc (Cấp 1)
    1501001087, -- Ba lô Giáp Sĩ Tương Lai (Cấp 1)
    1501001088, -- Ba lô Mèo Đen (Cấp 1)
    1501001089, -- Ba lô ếch bức xạ (Cấp 1)
    1501001090, -- Ba lô Đêm Mê Hoặc (Cấp 1)
    1501001091, -- Ba lô Angry Bird (Cấp 1)
    1501001092, -- Ba lô Tình Ca Mùa Đông (Cấp 1)
    1501001093, -- Ba lô Phù Thủy Băng Giá (Cấp 1)
    1501001094, -- Ba lô Lính Bóng Đêm (Cấp 1)
    1501001095, -- Ba lô Mùa Đông Không Lạnh (Cấp 1)
    1501001097, -- Ba lô hoa tuyết (Cấp 1)
    1501001098, -- Ba lô Gấu Trúc Đỏ (Cấp 1)
    1501001099, -- Ba lô Ninja Mèo (Cấp 1)
    1501001100, -- Ba lô Hoa Sen Máu (Cấp 1)
    1501001101, -- Ba lô Chỉ Huy Chiến Trường (Cấp 1)
    1501001102, -- Ba lô Kẻ Săn Mồi (Cấp 1)
    1501001103, -- Ba lô Ninja Sát Thủ (Cấp 1)
    1501001104, -- Ba lô Sên Khò Khò (Cấp 1)
    1501001105, -- Ba lô Thợ Săn Biển Cả (Cấp 1)
    1501001107, -- Ba lô Thần Horus (Cấp 1)
    1501001108, -- Ba lô Hoa Anh Đào (Cấp 1)
    1501001109, -- Ba lô Jason Địa Ngục (Cấp 1)
    1501001110, -- Ba lô Tổ Ong (Cấp 1)
    1501001114, -- Ba lô Sinh Tồn Đất Hoang (Cấp 1)
    1501001115, -- Ba lô Đại Bàng Vàng (Cấp 1)
    1501001116, -- Ba lô Bánh Ngọt (Cấp 1)
    1501001118, -- Ba lô Pony Bé Nhỏ (Cấp 1)
    1501001120, -- Ba lô Khỉ Buskin (Cấp 1)
    1501001122, -- Ba lô Hoàng Tử Ếch (Cấp 1)
    1501001123, -- Ba lô Trung Úy Vũ Trụ (Cấp 1)
    1501001125, -- Ba lô Thiên Thần Sa Ngã (Cấp 1)
    1501001126, -- Ba lô Đôi Cánh Ánh Sáng (Cấp 1)
    1501001127, -- Ba lô Đôi Cánh Bóng Đêm (Cấp 1)
    1501001128, -- Ba lô Lông Vũ Bảy Sắc (Cấp 1)
    1501001129, -- Ba lô Vua Poker (Cấp 1)
    1501001130, -- Ba lô Nữ Tiên Tri (Cấp 1)
    1501001131, -- Ba lô Tư Tế Bóng Đêm (Cấp 1)
    1501001132, -- Ba lô Corgi (Cấp 1)
    1501001134, -- Ba lô Kitty May Mắn (Cấp 1)
    1501001135, -- Ba lô Vua Cờ Bạc (Cấp 1)
    1501001136, -- Ba lô Tàng Hình (Cấp 1)
    1501001137, -- Ba lô Thú Cưng (Cấp 1)
    1501001140, -- Ba lô Voi Bản Đôn (Cấp 1)
    1501001141, -- Ba lô Mắt Quỷ (Cấp 1)
    1501001142, -- Ba lô Găngxtơ (Cấp 1)
    1501001143, -- Ba lô Sắc Màu Tuổi Trẻ (Cấp 1)
    1501001144, -- Ba lô Mèo Cute (Cấp 1)
    1501001145, -- Ba lô Thủy Thủ Cánh Cụt (Cấp 1)
    1501001146, -- Ba lô Dải Ngân Hà (Cấp 1)
    1501001147, -- Ba Lô Gà Rán (Cấp 1)
    1501001149, -- Ba lô Lính Cứu Hỏa (Cấp 1)
    1501001150, -- Ba lô Cơ Giáp Tím (Cấp 1)
    1501001151, -- Ba lô Cúp Danh Dự (Cấp 1)
    1501001153, -- Ba lô Bánh Ú (Cấp 1)
    1501001154, -- Ba lô Ác Thú (Cấp 1)
    1501001155, -- Ba lô Dino Park (Cấp 1)
    1501001156, -- Ba lô Kẹo Ngọt (Cấp 1)
    1501001157, -- Ba lô Sư Tử Hống (Cấp 1)
    1501001158, -- Ba lô Búp Bê Nga (Cấp 1)
    1501001160, -- Ba lô Bọ Rùa (Cấp 1)
    1501001161, -- Ba lô Giáp Hợp Kim (Cấp 1)
    1501001162, -- Ba Lô Tinh Hoa Ẩm Thực (Cấp 1)
    1501001163, -- Ba Lô Tiên Nữ Ngọt Ngào (Cấp 1)
    1501001164, -- Ba lô Cá Sấu (Cấp 1)
    1501001165, -- Ba lô Cảnh Sát Trưởng (Cấp 1)
    1501001166, -- Ba lô Giáp Samurai (Cấp 1)
    1501001168, -- Ba lô Nghìn Lẻ Một Đêm (Cấp 1)
    1501001169, -- Ba lô Chiến Binh Dân Tộc (Cấp 1)
    1501001170, -- Ba lô Hồ Ly Gian Xảo (Cấp 1)
    1501001171, -- Ba lô Kỵ Sĩ Kẹo Ngọt (Cấp 1)
    1501001172, -- Ba lô Bậc Thầy Võ Thuật (Cấp 1)
    1501001173, -- Ba lô Cảnh Sát Hoàng Gia (Cấp 1)
    1501001175, -- Ba lô Thiếu Nữ Goth (Cấp 1)
    1501001176, -- Ba Lô Nhà Thú Cưng (Cấp 1)
    1501001177, -- Ba lô Xương Cáo (Cấp 1)
    1501001178, -- Ba lô Búp Bê Ma (Cấp 1)
    1501001179, -- Ba lô Lãnh Chúa Cuồng Nộ (Cấp 1)
    1501001180, -- Ba lô Tiên Hoa Tuyết (Cấp 1)
    1501001182, -- Ba lô Bóng Ma Halloween (Cấp 1)
    1501001183, -- Ba lô quý Cô Gothic (Cấp 1)
    1501001185, -- Ba lô Tay Đua Kỵ Sĩ (Cấp 1)
    1501001187, -- Ba lô Bánh Cá (Cấp 1)
    1501001188, -- Ba lô Hộ Vệ Tinh Tú (Cấp 1)
    1501001189, -- Ba Lô Thần Điểu (Cấp 1)
    1501001190, -- Ba lô Yêu Quái (Cấp 1)
    1501001191, -- Ba Lô Nhà Vô Địch Arena (Cấp 1)
    1501001193, -- Ba lô Chúa Tể Thế Giới Ngầm (Cấp 1)
    1501001194, -- Ba lô Kỵ Sĩ Thép (Cấp 1)
    1501001195, -- Mũ Nữ Hoàng Máu (Cấp 1)
    1501001196, -- Ba lô Da Báo (Cấp 1)
    1501001197, -- Ba lô Hiệp Hội Pháp Sư (Cấp 1)
    1501001198, -- Ba lô Kiên Cường (Cấp 1)
    1501001199, -- Ba Lô Cảnh Sát Xương Rồng (Cấp 1)
    1501001200, -- Ba lô Thành Phố Sắc Màu (Cấp 1)
    1501001201, -- Ba lô Tulip (Cấp 1)
    1501001202, -- Ba lô Vua Hạt Dẻ (Cấp 1)
    1501001204, -- Ba lô Idol (Cấp 1)
    1501001205, -- Ba lô Người Tuyết Jolly (Cấp 1)
    1501001206, -- Ba lô Ma Nữ Mê Hoặc (Cấp 1)
    1501001207, -- Ba lô Sứ Giả Chính Nghĩa (Cấp 1)
    1501001209, -- Ba Lô Đồng Hồ Cổ Điển (Cấp 1)
    1501001210, -- Ba lô Chiến Binh Thép (Cấp 1)
    1501001211, -- Ba lô Tê Giác Punky (Cấp 1)
    1501001212, -- Ba Lô Hộ Vệ Rồng (Cấp 1)
    1501001213, -- Ba lô Thần Mặt Trời (Cấp 1)
    1501001215, -- Ba lô Vùng Nguy Hiểm (Cấp 1)
    1501001216, -- Ba lô Nữ Hoàng Mùa Đông (Cấp 1)
    1501001217, -- Ba lô Người Tuyết (Cấp 1)
    1501001221, -- Ba lô Hồ Điệp Phu Nhân (Cấp 1)
    1501001222, -- Ba lô Trái Tim Biển Cả (Cấp 1)
    1501001224, -- Ba lô Lãnh Chúa Độc Tài (Cấp 1)
    1501001225, -- Ba lô Vua Kẹp Hạt Dẻ (Cấp 1)
    1501001226, -- Ba lô Cọp Con (Cấp 1)
    1501001227, -- Ba Lô Kho Báu Quái Thú (Cấp 1)
    1501001229, -- Ba lô emoji Hôn (Cấp 1)
    1501001231, -- Ba lô Ca Vương (Cấp 1)
    1501001233, -- Ba Lô Vũ Công Công Nghệ (Cấp 1)
    1501001236, -- Ba lô Hành Tinh Mẹ (Cấp 1)
    1501001237, -- Ba lô Sắc Tố Cầu Vồng (Cấp 1)
    1501001238, -- Ba lô Giáp Ngọc (Cấp 1)
    1501001239, -- Ba lô Bướm Đồng Hành (Cấp 1)
    1501001240, -- Ba lô Mèo Đáng Yêu (Cấp 1)
    1501001241, -- Ba lô Pha Lê Anh Đào (Cấp 1)
    1501001242, -- Ba lô Ma Pháp Huyền Thoại (Cấp 1)
    1501001244, -- Ba lô Đặc Công QUACK (Cấp 1)
    1501001245, -- Ba lô Tuyết Anh Đào (Cấp 1)
    1501001246, -- Ba lô Hộp Đựng Côn Trùng (Cấp 1)
    1501001247, -- Ba lô Vua Khỉ Thế Giới Ảo (Cấp 1)
    1501001248, -- Ba lô Thần Bí Mị Ảnh (Cấp 1)
    1501001249, -- Ba lô Ong Chiến Binh (Cấp 1)
    1501001250, -- Ba lô Lãnh Chúa Hắc Ám (Cấp 1)
    1501001251, -- Ba lô Thành Phố Về Đêm (Cấp 1)
    1501001252, -- Ba lô Ong Công Nghệ (Cấp 1)
    1501001253, -- Ba lô Chuối May Mắn (Cấp 1)
    1501001258, -- Ba lô Kẻ Báo Thù Băng Giá (Cấp 1)
    1501001259, -- Ba lô Rùa Điện (Cấp 1)
    1501001260, -- Ba lô Sát Thủ Thành Thị (Cấp 1)
    1501001261, -- Ba Lô Gấu Nâu Khủng Long (Cấp 1)
    1501001262, -- Ba lô Nữ Hề (Cấp 1)
    1501001263, -- Ba lô Kiến Chúa (Cấp 1)
    1501001266, -- Ba Lô Sally (Cấp 1)
    1501001267, -- Ba lô Tái Chế (Cấp 1)
    1501001268, -- Ba Lô Cú Lệnh Bài (Cấp 1)
    1501001269, -- Ba Lô Bazzi Dễ Thương (Cấp 1)
    1501001270, -- Ba lô Chuyến Đi Tuyệt Vời (Cấp 1)
    1501001271, -- Ba lô Chiến Binh Hồng Miêu (Cấp 1)
    1501001274, -- Ba lô Đôi Cánh Đỏ (Cấp 1)
    1501001275, -- Ba lô Tường Thành Đá Quý (Cấp 1)
    1501001276, -- Ba lô Vịt Vàng B.Duck (Cấp 1)
    1501001277, -- Ba lô Godzilla (Cấp 1)
    1501001279, -- Ba lô Dũng Sĩ Công Lý (Cấp 1)
    1501001280, -- Ba lô Thùng Rượu (Cấp 1)
    1501001281, -- Ba Lô Thỏ Sóng Âm (Cấp 1)
    1501001282, -- Ba Lô Gà Hảo Hạng (Cấp 1)
    1501001283, -- Ba lô Thế Giới Ảo (Cấp 1)
    1501001286, -- Ba lô Ông Trùm Hoang Dại (Cấp 1)
    1501001287, -- Ba lô Hộp Ảo Thuật (Cấp 1)
    1501001288, -- Ba Lô Game Cổ Điển (Cấp 1)
    1501001291, -- Ba lô Hộp Đựng Rau (Cấp 1)
    1501001292, -- Ba lô Lò Nướng BBQ (Cấp 1)
    1501001293, -- Ba lô Đầu Lâu Đường Phố (Cấp 1)
    1501001294, -- Ba lô Thợ Săn Xứ Tuyết (Cấp 1)
    1501001295, -- Ba lô Vật Tổ Hoang Dã (Cấp 1)
    1501001296, -- Ba lô Giáp Biển Sâu (Cấp 1)
    1501001297, -- Ba Lô Bento Tình Yêu (Cấp 1)
    1501001298, -- Ba lô Bộ Đầu Bếp (Cấp 1)
    1501001300, -- Ba lô Chồn Dễ Thương (Cấp 1)
    1501001301, -- Ba lô Xương Rồng Vui Vẻ (Cấp 1)
    1501001302, -- Ba lô Nấm Lùn (Cấp 1)
    1501001303, -- ADIDAS Backpack(Lv1)
    1501001305, -- Ba lô Hồi Ức Tuyệt Đẹp (Cấp 1)
    1501001306, -- Ba lô Giáp Hầu Gái (Cấp 1)
    1501001307, -- Ba lô Vương Quốc Vàng (Cấp 1)
    1501001308, -- Ba lô Phô Mai (Cấp 1)
    1501001309, -- Ba Lô Máy Quét Linh Hồn (Cấp 1)
    1501001310, -- Ba Lô Khủng Long Pixel (Cấp 1)
    1501001311, -- Ba lô Hộp Pha Lê (Cấp 1)
    1501001312, -- Ba lô Chiến Xa Giáng Sinh (Cấp 1)
    1501001314, -- Ba lô Đôi Cánh Của Biển (Cấp 1)
    1501001316, -- Ba lô Cơn Sốt Giáng Sinh (Cấp 1)
    1501001317, -- Ba lô Nữ Hoàng Mùa Đông (Cấp 1)
    1501001318, -- Ba lô Kỵ Binh Thần Giáp (Cấp 1)
    1501001320, -- Ba lô Thời Đại Huy Hoàng (Cấp 1)
    1501001321, -- Ba lô GACKT MOONSAGA (Cấp 1)
    1501001323, -- Ba lô Mèo Hốt Hoảng (Cấp 1)
    1501001324, -- Ba lô Tinh Linh Tuyết (Cấp 1)
    1501001325, -- Ba lô FC Liverpool (Cấp 1)
    1501001326, -- Ba lô Thỏ Pháp Sư (Cấp 1)
    1501001330, -- Ba lô Vận Động Viên Mạo Hiểm (Cấp 1)
    1501001332, -- Ba lô tinh thể Hextech (Cấp 1)
    1501001333, -- Ba lô Gundala (Cấp 1)
    1501001336, -- Ba lô Nữ Hoàng Tinh Linh (Cấp 1)
    1501001337, -- Ba lô Thợ Lặn (Cấp 1)
    1501001338, -- Ba lô Bé Hổ (Cấp 1)
    1501001339, -- Ba lô Thỏ Mùa Đông (Cấp 1)
    1501001341, -- Ba lô Gấu Hồng (Cấp 1)
    1501001342, -- Ba lô Thiếu Nữ Hiếu Chiến (Cấp 1)
    1501001343, -- Ba lô Rồng Baby (Cấp 1)
    1501001344, -- Ba lô Máy Trò Chơi (Cấp 1)
    1501001345, -- Ba lô Tiểu Quỷ Ngoại Đạo (Cấp 1)
    1501001346, -- Ba lô Công Chúa Thỏ (Cấp 1)
    1501001348, -- Ba lô Hộp Pixel (Cấp 1)
    1501001349, -- Ba lô Nền Văn Minh Thất Lạc (Cấp 1)
    1501001350, -- Ba Lô Hộp Ánh Sáng (Cấp 1)
    1501001351, -- Ba lô Năng Lượng Băng Tuyết (Cấp 1)
    1501001352, -- Ba Lô Bình Xăng Công Nghệ (Cấp 1)
    1501001354, -- Ba Lô Thiếu Nữ Thời Đại (Cấp 1)
    1501001355, -- Ba lô Thám Hiểm Tinh Vân (Cấp 1)
    1501001356, -- Ba Lô Cây Ăn Thịt (Cấp 1)
    1501001357, -- Ba Lô Mộ Huyệt Ác Quỷ (Cấp 1)
    1501001359, -- Balo Gai Nhọn (Cấp 1)
    1501001361, -- Ba lô Nhà Thám Hiểm Vùng Đất Chết (Cấp 1)
    1501001362, -- Ba lô Màn Đêm Dị Biến (Cấp 1)
    1501001363, -- Ba Lô Hộp Quà Hù Dọa (Cấp 1)
    1501001364, -- Ba Lô Hộp Gấu (Cấp 1)
    1501001366, -- Ba lô Mèo Chơi Khăm (Cấp 1)
    1501001367, -- Ba Lô Kẹo Gấu (Cấp 1)
    1501001368, -- Ba Lô Sói Và Thỏ (Cấp 1)
    1501001369, -- Ba Lô Ông Trùm Dầu Mỏ (Cấp 1)
    1501001370, -- Ba Lô Thủ Vệ Bộ Lạc (Cấp 1)
    1501001371, -- Ba lô Nhâm Dần (Cấp 1)
    1501001372, -- Ba Lô Trinh Thám Hành Tinh (Cấp 1)
    1501001373, -- Ba Lô Cá Mập Dễ Thương (Cấp 1)
    1501001374, -- Ba Lô Đồng Phục Học Sinh (Cấp 1)
    1501001375, -- Ba lô Lễ Hội Sắc Màu (Cấp 1)
    1501001377, -- Ba Lô Linh Hồn Lục Bảo (Cấp 1)
    1501001378, -- Ba Lô Cá Mập Giận Dữ (Cấp 1)
    1501001380, -- Ba Lô Chiến Thần Tình Yêu (Cấp 1)
    1501001381, -- Ba lô Cún Con Đáng Yêu (Cấp 1)
    1501001383, -- Ba lô Đá Phỉ Thúy (Cấp 1)
    1501001384, -- Ba Lô U Linh Giới (Cấp 1)
    1501001385, -- Ba Lô Thời Đại Cơ Khí (Cấp 1)
    1501001386, -- Ba Lô Thời Đại Cơ Khí (Cấp 1)
    1501001387, -- Ba Lô Evangelion-01 (Cấp 1)
    1501001388, -- Ba lô Bão Thiết Giáp (Cấp 1)
    1501001389, -- Ba Lô Dạo Phố Thời Trang (Cấp 1)
    1501001390, -- Ba Lô Hoa Nạm Vàng (Cấp 1)
    1501001391, -- Ba Lô Gấu Polar (Cấp 1)
    1501001392, -- Ba Lô Bóng Ma Tinh Nghịch (Cấp 1)
    1501001393, -- Ba Lô Cá Đuối Dễ Thương (Cấp 1)
    1501001394, -- Ba Lô Sao Ước Nguyện (Cấp 1)
    1501001395, -- Ba Lô Da Cao Cấp (Cấp 1)
    1501001396, -- Ba Lô Vỏ Kho Báu (Cấp 1)
    1501001397, -- Ba Lô Thuyền Trưởng Hải Tặc (Cấp 1)
    1501001398, -- Ba Lô Biểu Tượng Hoàng Gia (Cấp 1)
    1501001399, -- Ba Lô Bom Hẹn Giờ (Cấp 1)
    1501001401, -- Ba Lô Bộ Lạc Rừng Sâu (Cấp 1)
    1501001402, -- Ba Lô Sói Cool Ngầu (Cấp 1)
    1501001408, -- Ba Lô Huyền Thoại Đánh Cá (Cấp 1)
    1501001409, -- Ba Lô Hoàng Tử Lời Nguyền (Cấp 1)
    1501001410, -- Ba Lô Tàu Ngầm (Cấp 1)
    1501001411, -- Ba lô Hỏa Diệm Ma Giáp (Cấp 1)
    1501001412, -- Ba Lô Hộp Châu Báu (Cấp 1)
    1501001414, -- Ba Lô Cánh Tiên (Cấp 1)
    1501001415, -- Ba Lô Chim Lửa (Cấp 1)
    1501001416, -- Ba Lô Máy Bán Hàng Tự Động (Cấp 1)
    1501001417, -- Ba Lô Butterfinger (Cấp 1)
    1501001418, -- Ba Lô Sẵn Sàng Chiến Đấu (Cấp 1)
    1501001419, -- Ba Lô Phục Thù (Cấp 1)
    1501001420, -- Ba Lô Trứng Khủng Long (Cấp 1)
    1501001421, -- Ba Lô Thỏ Ngất Ngây (Cấp 1)
    1501001422, -- Ba Lô Chúa Tể Gai Độc (Cấp 1)
    1501001423, -- Ba Lô Thiếu Nữ Sáng Thế (Cấp 1)
    1501001424, -- Ba Lô Sơn Dương (Cấp 1)
    1501001425, -- Ba Lô Mối Tình Đầu (Cấp 1)
    1501001426, -- Ba Lô Lil Burger (Cấp 1)
    1501001430, -- Ba Lô Đêm Hội Đầu Lâu (Cấp 1)
    1501001433, -- Ba Lô Lễ Phục (Cấp 1)
    1501001437, -- Ba lô Chiến Thần Đột Biến (Cấp 1)
    1501001441, -- Ba Lô Pháo Chú Hề (Cấp 1)
    1501001443, -- Ba Lô Tinh Hà Dạ Quang (Cấp 1)
    1501001444, -- Ba Lô Lễ Phục Hoàng Gia (Cấp 1)
    1501001446, -- Ba Lô Bắp Năng Động (Cấp 1)
    1501001448, -- Ba Lô Di Sản Bí Ẩn (Cấp 1)
    1501001451, -- Ba Lô Hộp Đựng Hoa (Cấp 1)
    1501001452, -- Ba Lô Basta (Cấp 1)
    1501001453, -- Ba Lô Chiến Binh Khủng Long (Cấp 1)
    1501001454, -- Ba Lô Bậc Thầy Chế Tạo Thuốc (Cấp 1)
    1501001457, -- Ba Lô Nền Văn Minh Cổ Đại (Cấp 1)
    1501001458, -- Ba Lô Thỏ Ngọt Ngào (Cấp 1)
    1501001459, -- Ba Lô Mèo Nghiêm Túc (Cấp 1)
    1501001462, -- Ba Lô Chiến Binh Ngưu (Cấp 1)
    1501001466, -- Ba Lô Vẻ Đẹp Huyền Bí (Cấp 1)
    1501001467, -- Ba Lô Rồng Đen Dễ Mến (Cấp 1)
    1501001468, -- Ba Lô Gấu Sắc Màu (Cấp 1)
    1501001469, -- Ba Lô Thiếu Nữ Bông Tuyết (Cấp 1)
    1501001471, -- Ba Lô Thủy Sư Cuồng Nộ (Cấp 1)
    1501001474, -- Ba Lô Sói Điện Tử (Cấp 1)
    1501001475, -- Ba Lô Sát Thủ Tối Thượng (Cấp 1)
    1501001478, -- Ba Lô Két Vàng (Cấp 1)
    1501001479, -- Ba Lô Mithu Tota (Cấp 1)
    1501001481, -- Ba Lô Vũ. - Phi Hành Gia (Cấp 1)
    1501001482, -- Ba Lô Quái Vật Kỳ Dị (Cấp 1)
    1501001483, -- Ba Lô Hộp Giấy Khủng Long (Cấp 1)
    1501001484, -- Ba Lô Thánh Đường Võ Thuật (Cấp 1)
    1501001485, -- Ba Lô Cà Rốt Nàng Tiên Thỏ Ngọc (Cấp 1)
    1501001486, -- Ba Lô Vest Đỏ Lấp Lánh (Cấp 1)
    1501001489, -- Ba Lô Ma Cà Rồng Nham Hiểm (Cấp 1)
    1501001490, -- Ba Lô Gấu Hoàng Gia (Cấp 1)
    1501001492, -- Ba Lô Mèo Lấp Lánh (Cấp 1)
    1501001494, -- Ba Lô Nổi Loạn (Cấp 1)
    1501001495, -- Ba Lô Yêu Thỏ (Cấp 1)
    1501001496, -- Ba Lô Mèo Điện Tử (Cấp 1)
    1501001497, -- Ba Lô Hộp Khóa (Cấp 1)
    1501001500, -- Ba Lô Khiêu Khích Đối Thủ (Cấp 1)
    1501001501, -- Ba Lô Chúa Hề Nổi Loạn (Cấp 1)
    1501001502, -- Ba Lô Hộp Sang Chảnh (Cấp 1)
    1501001503, -- Ba Lô Đại Sư Võ Hồn (Cấp 1)
    1501001506, -- Ba Lô Mèo Chiêu Tài (Cấp 1)
    1501001507, -- Ba Lô Hoàng Tử Chuột (Cấp 1)
    1501001509, -- Ba Lô Cừu Vàng Lấp Lánh (Cấp 1)
    1501001510, -- Ba Lô Thủ Công (Cấp 1)
    1501001511, -- Ba Lô Báu Vật Đại Dương (Cấp 1)
    1501001512, -- Ba Lô Thích Khách Vượt Sóng (Cấp 1)
    1501001513, -- Ba Lô Cá Ngựa Lãng Mạn (Cấp 1)
    1501001514, -- Ba Lô Gấu Trúc Múa Lân (Cấp 1)
    1501001515, -- Ba Lô Ma Vương Huyết Hồn (Cấp 1)
    1501001516, -- Ba Lô Hầu Gái Hồng (Cấp 1)
    1501001517, -- Ba Lô Dưa Leo Hài Hước (Cấp 1)
    1501001519, -- Ba Lô Gấu Chổng Ngược (Cấp 1)
    1501001520, -- Ba Lô Công Vàng (Cấp 1)
    1501001522, -- Ba Lô Khách Hàng Thượng Đỉnh (Cấp 1)
    1501001523, -- Ba Lô Vệ Sĩ Cung Đình (Cấp 1)
    1501001524, -- Ba Lô Ảo Ảnh Chớp Nhoáng (Cấp 1)
    1501001525, -- Ba Lô Thỏ Tinh Nghịch (Cấp 1)
    1501001526, -- Ba Lô Thú Cưng Siêu Ngầu (Cấp 1)
    1501001527, -- Ba Lô Giỏ Picnic (Cấp 1)
    1501001528, -- Ba Lô Nguy Hiểm Sinh Học (Cấp 1)
    1501001529, -- Ba Lô Vật Tổ Chim Ưng (Cấp 1)
    1501001530, -- Ba Lô Viên Nang (Cấp 1)
    1501001531, -- Ba Lô Thủy Triều Long Vương (Cấp 1)
    1501001532, -- Ba Lô Dơi Ác Ma (Cấp 1)
    1501001533, -- Ba Lô Nhịp Điều Hoài Cổ (Cấp 1)
    1501001534, -- Ba Lô Hộp Nước Trái Cây (Cấp 1)
    1501001535, -- Ba Lô Mòng Biển Bụng Bự (Cấp 1)
    1501001536, -- Ba Lô Nhựa Vinyl (Cấp 1)
    1501001537, -- Ba Lô Thợ Săn Điện Quang (Cấp 1)
    1501001538, -- Ba Lô Báo Thời Thượng (Cấp 1)
    1501001541, -- Ba Lô Tài Liệu Cơ Mật (Cấp 1)
    1501001542, -- Ba Lô Quà Cổ Đại (Cấp 1)
    1501001543, -- Ba Lô Chuột Công Nghệ (Cấp 1)
    1501001544, -- Ba Lô Ác Quỷ Bộ Tộc (Cấp 1)
    1501001545, -- RS Swagster Backpack(Lv. 1)
    1501001546, -- Ba Lô Thiên Đường (Cấp 1)
    1501001547, -- Ba Lô Bộ Lạc Tiền Sử (Cấp 1)
    1501001549, -- Ba Lô Robot Hồ Ly (Cấp 1)
    1501001550, -- Ba Lô Băng Tuyết Mùa Đông (Cấp 1)
    1501001551, -- Ba Lô Bánh Kẹo Giáng Sinh (Cấp 1)
    1501001552, -- Ba Lô Thỏ Nổi Loạn (Cấp 1)
    1501001553, -- Sweetheart Arrow Backpack (Lv. 1)
    1501001555, -- Rose Warrior Princess Backpack (Lv. 1)
    1501001556, -- Gold Ink Tiggy Backpack (Lv. 1)
    1501001557, -- Love Letter Backpack (Lv. 1)
    1501001558, -- Mech Soul Ninja Backpack (Lv. 1)
    1501001560, -- Golden Porcelain Secret Treasure Backpack (Lv. 1)
    1501001561, -- Love Mouse Backpack (Lv. 1)
    1501001562, -- Cute Owl Backpack (Lv. 1)
    1501001563, -- Ba Lô Zanmang Loopy (Cấp 1)
    1501001564, -- Ba Lô Cánh Vàng Trời Xanh (Cấp 1)
    1501001565, -- Ba Lô Hộ Vệ Ánh Sáng (Cấp 1)
    1501001566, -- Ba Lô Lữ Khách Hoàng Gia (Cấp 1)
    1501001568, -- Ba Lô Phù Thủy Khả Ái (Cấp 1)
    1501001569, -- Ba Lô Tay Đua Gan Dạ (Cấp 1)
    1501001570, -- Ba Lô Đế Vương Thần Vực (Cấp 1)
    1501001571, -- Ba Lô Tiên Linh Lưu Ly (Cấp 1)
    1501001572, -- Ba Lô Tím Mộng Mơ (Cấp 1)
    1501001573, -- Ba Lô Thỏ Pastel (Cấp 1)
    1501001574, -- Ba Lô Chiến Sĩ Thần Giáp (Cấp 1)
    1501001575, -- Ba Lô Bánh Răng Hoàng Kim (Cấp 1)
    1501001576, -- Ba Lô Thủ Lĩnh Đền Thờ (Cấp 1)
    1501001578, -- Ba Lô Thiết Mã (Cấp 1)
    1501001579, -- Ba Lô Quý Ông Quái Lạ (Cấp 1)
    1501001581, -- Ba Lô Chiến Binh Thủy Ngân (Cấp 1)
    1501001582, -- Ba Lô Neon Huyền Bí  (Cấp 1)
    1501001583, -- Ba Lô Hộp Nhạc Công Nghệ Cao (Cấp 1)
    1501001584, -- Ba Lô Quái Vật Âm Thanh (Cấp 1)
    1501001585, -- Ba Lô Nhím Bé Bỏng (Cấp 1)
    1501001586, -- Ba Lô Hầu Gái Bóng Đêm (Cấp 1)
    1501001588, -- Ba Lô Phong Linh (Cấp 1)
    1501001589, -- Ba Lô Tượng Cổ Đại (Cấp 1)
    1501001590, -- Ba Lô Giáp Sắc Đẹp Gợn Sóng (Cấp 1)
    1501001591, -- Ba Lô Thánh Nữ Huyền Ảo (Cấp 1)
    1501001592, -- Ba Lô Thợ Săn Quỷ (Cấp 1)
    1501001593, -- Ba Lô Bạch Tuộc Hồng (Cấp 1)
    1501001594, -- Ba Lô Thủy Quái (Cấp 1)
    1501001595, -- APEACH Backpack (LV.1)
    1501001596, -- Choonsik Backpack (LV.1)
    1501001598, -- Ba Lô Anjat (Cấp 1)
    1501001599, -- Ba Lô Thỏ Tinh Quái (Cấp 1)
    1501001600, -- Ba Lô Nữ Sinh Nổi Loạn (Cấp 1)
    1501001601, -- Ba Lô Trái Tim Bảo Hộ (Cấp 1)
    1501001602, -- Ba Lô Lữ Hành Pocong (Cấp 1)
    1501001603, -- Ba Lô Lướt Sóng Sành Điệu (Cấp 1)
    1501001604, -- Ba Lô Miêu Linh Sắc Màu (Cấp 1)
    1501001605, -- Ba Lô Quỷ Diện Bóng Đêm (Cấp 1)
    1501001606, -- Ba Lô Chiến Giáp Quái Thú (Cấp 1)
    1501001608, -- Ba Lô Lửa Ngục Rực Cháy (Cấp 1)
    1501001609, -- Ba Lô Phong Ấn Bảo Hộ (Cấp 1)
    1501001610, -- Ba Lô Thân Sĩ Hắc Đạo (Cấp 1)
    1501001611, -- Ba Lô Chiến Binh Mùa Đông (Cấp 1)
    1501001612, -- Ba Lô Không Gian Đa Chiều (Cấp 1)
    1501001613, -- Ba Lô Băng Tỏa Mộc Tàn (Cấp 1)
    1501001614, -- Ba Lô Lính Gác Skadiwynn (Cấp 1)
    1501001615, -- Ba Lô Tuần Lộc Hoàng Gia (Cấp 1)
    1501001616, -- Ba Lô PMGC × ROLLIO (Cấp 1)
    1501001617, -- Ba Lô Cánh Cụt Vui Vẻ (Cấp 1)
    1501001618, -- Ba Lô Kiếm Băng Tuyết (Cấp 1)
    1501001619, -- Ba Lô Giấc Mộng Ngọt Ngào (Cấp 1)
    1501001620, -- Ba Lô Lãnh Chúa Băng Giá (Cấp 1)
    1501001621, -- Ba Lô Tinh Thể Huyết (Cấp 1)
    1501001622, -- Ba Lô Bóng Nước (Cấp 1)
    1501001623, -- Ba Lô Quái Rừng Tham Ăn (Cấp 1)
    1501001624, -- Ba Lô Long Thái Tử (Cấp 1)
    1501001625, -- Ba Lô Kho Báu Rắn (Cấp 1)
    1501001626, -- Ba Lô Lông Vũ Hoàng Kim (Cấp 1)
    1501001627, -- Ba Lô Mãnh Hổ Lam Hoa (Cấp 1)
    1501001628, -- Ba Lô Khế Ước Thi Sĩ (Cấp 1)
    1501001629, -- Ba Lô Cổ Vật Thiên Giới (Cấp 1)
    1501001630, -- Ba Lô Dạ Khúc Sâu Thẳm (Cấp 1)
    1501001631, -- Ba Lô Nơ Hoa Ngọt Ngào (Cấp 1)
    1501001633, -- Neon Drop BE 6 Backpack (Lv. 1)
    1501001635, -- Ba Lô Quái Vật Thư Giãn (Cấp 1)
    1501001636, -- Ba Lô Phản Diện Neon (Cấp 1)
    1501001637, -- Ba Lô Vua Quái Vật Godzilla (Cấp 1)
    1501001638, -- Ba Lô Cáo Tinh Nghịch (Cấp 1)
    1501001639, -- Ba Lô Thời Quang Khả Biến (Cấp 1)
    1501001640, -- Ba Lô Chúa Hề Hắc Ám (Cấp 1)
    1501001641, -- Ba Lô Thỏ Tinh (Cấp 1)
    1501001642, -- Ba Lô Thánh Vật Cổ Quốc (Cấp 1)
    1501001644, -- Frieren Backbag(Lv.1)
    1501001645, -- Ba Lô Măng Cụt Khả Ái (Cấp 1)
    1501001646, -- Ba lô Cá Sấu (Cấp 1)
    1501001647, -- Ba Lô Dấu Ấn Ván Trượt (Cấp 1)
    1501001648, -- Ba Lô Xung Lực Đỏ (Cấp 1)
    1501001649, -- Ba Lô Tinh Tú Hư Không (Cấp 1)
    1501001651, -- Ba Lô San Hô Băng Xanh (Cấp 1)
    1501001652, -- Ba Lô Định Mệnh Huyết Chú (Cấp 1)
    1501001653, -- Ba Lô Nhiễu Sóng (Cấp 1)
    1501001654, -- Bá Lô Thí Nghiệm Cuồng Loạn (Cấp 1)
    1501001655, -- Ba Lô Nhựa Vinyl (Cấp 1)
    1501001656, -- Hero Xtreme Backpack (Lv.1)
    1501001657, -- Ba Lô Tinh Vân Dị Tượng (Cấp 1)
    1501001658, -- Ba Lô Đặc Công Hoàng Kim (Cấp 1)
    1501001659, -- Ba Lô Rồng Sữa Mềm Mại (Cấp 1)
    1501001660, -- Ba Lô Thần Sứ Tinh Cầu (Cấp 1)
    1501001661, -- Ba Lô Long Thánh (Cấp 1)
    1501001662, -- Ba Lô Tinh Quang (Cấp 1)
    1501001663, -- Ba Lô Tinh Không (Cấp 1)
    1501001664, -- Ba Lô Tà Thần Mỹ Quang (Cấp 1)
    1501001665, -- Ba Lô Cún Tinh Nghịch (Cấp 1)
    1501001667, -- Bbangbbang's diary Backpack(Lv.1)
    1501001668, -- Ba Lô Chúa Hề Hắc Ám (Cấp 1)
    1501001669, -- Ba Lô Tiểu Yêu Nổi Loạn (Cấp 1)
    1501001670, -- Ba Lô Boxing (Cấp 1)
    1501001671, -- Ba Lô Kaiju No. 8 (Cấp 1)
    1501001672, -- Ba Lô Sải Cánh Hồ Điệp (Cấp 1)
    1501001673, -- Ba Lô Đô Thị Hoa Lệ (Cấp 1)
    1501001674, -- Ba Lô Sát Thủ Bông Mềm (Cấp 1)
    1501001675, -- Ba Lô Hỏa Đinh Ba (Cấp 1)
    1501001676, -- Ba Lô Điện Thánh U Linh (Cấp 1)
    1501001677, -- Ba Lô Kính Linh Hồn (Cấp 1)
    1501001678, -- Ba Lô Thập Cẩm Ngọt Ngào (Cấp 1)
    1501001679, -- Ba Lô U Linh Ú Nu (Cấp 1)
    1501001680, -- Jungle Core Backpack (Lv. 1)
    1501001681, -- Ba Lô Thuỷ Thủ Gấu Trắng (Cấp 1)
    1501001682, -- Ba Lô Hiệp Sĩ Gấu (Cấp 1)
    1501001684, -- Ba Lô Chiến Giáp Tuyết (Cấp 1)
    1501001685, -- Ba Lô Hắc Linh (Cấp 1)
    1501001686, -- Ba Lô Bữa Tiệc Sương Giá (Cấp 1)
    1501001687, -- Ba Lô Tuyết Tử Thần (Cấp 1)
    1501001688, -- Ba Lô Cực Quang Pha Lê (Cấp 1)
    1501001689, -- Ba Lô Chồn Tuyết (Cấp 1)
    1501001690, -- Ba Lô Vương Miện Hòa Âm (Cấp 1)
    1501001691, -- Turbo Granny(Beckoning cat) Backpack (Lv. 1)
    1501001692, -- Ba Lô Tre Xanh (Cấp 1)
    1501001693, -- Ba Lô Kim Ấn (Cấp 1)
    1501001694, -- Ba Lô Đạn Dược (Cấp 1)
    1501001695, -- Ba Lô KO Vui Chơi (Cấp 1)
    1501001696, -- Ba Lô Vũ Khúc (Cấp 1)
    1501001697, -- Ba Lô Thanh Ngọc (Cấp 1)
    1501001698, -- Ba Lô Linh Hồn (Cấp 1)
    1501001699, -- Ba Lô Ấn Chú Thuật Sư (Cấp 1)
    1501001700, -- Ba Lô Hoa Mộng (Cấp 1)
    1501001701, -- Ba Lô Rương Cát Tường (Cấp 1)
    1501001702, -- Roadborn Rucksack Backpack (Lv. 1)
    1501001703, -- Ba Lô Bóng Ma Anh Quốc (Cấp 1)
    1501001704, -- Ba Lô S28 (Cấp 1)
    1501001705, -- Ba Lô Cát Xoáy (Cấp 1)
    1501001706, -- Ba Lô Tân Binh Nổi Loạn (Cấp 1)
    1501001707, -- Ba Lô Ngục Tù (Cấp 1)
    1501001708, -- Ba Lô Mã Độc (Cấp 1)
    1501001709, -- Ba Lô Năng Lượng Xung Kích (Cấp 1)
    1501001710, -- Ba Lô Pha Lê Tím (Cấp 1)
    1501001711, -- Ba lô Du Hành Vũ Trụ (Cấp 1)
    1501001712, -- Ba Lô Nhiễu Loạn Tần Số (Cấp 1)
    1501001713, -- Ba Lô Mèo Con Duyên Dáng (Cấp 1)
    1501001714, -- Catch! Teenieping Graceping Backpack(Lv.1)
    1501001716, -- Nakiri Ayame Backpack (Lv.1)
    1501001717, -- Ba Lô S29 (Cấp 1)
    1501001718, -- Ba Lô Át Chủ Bài (Cấp 1)
    1501001719, -- Ba Lô Quý Tộc Ba Tư (Cấp 1)
    1501001721, -- Ba Lô Tốc Độ (Cấp 1)
    1501001722, -- Ba Lô Thánh Chiến (Cấp 1)
    1501001723, -- Ba Lô Chúa Hề (Cấp 1)
    1501001724, -- Ba Lô Song Tử (Cấp 1)
    1501001725, -- Ba Lô Xà Vương (Cấp 1)
    1501001726, -- Ba Lô Lửa Chiến (Cấp 1)
    1501001727, -- Ba Lô Tình Yêu Quyến Rũ (Cấp 1)
    1501001728, -- Ba Lô Học Viện Nguyệt Quế (Cấp 1)
    1501001729, -- Ba Lô Chiến Binh Nhiệt Huyết (Cấp 1)
    1501001730, -- Usada Pekora Backpack ​​(Lv.1)
    1501001731, -- Ba Lô Giai Điệu Sấm Sét (Cấp 1)
    1501001732, -- Ba Lô Xung Điện Hủy Diệt (Cấp 1)
    1501001733, -- Ba Lô S30 (Cấp 1)
    1501001734, -- Ba Lô Thích Khách (Cấp 1)
    1501001735, -- Ba Lô Thỏ Hồng (Cấp 1)
    1501001736, -- Ba Lô Atlantis (Cấp 1)
    1501001737, -- Ba Lô Huyền Thoại Đường Đua (Cấp 1)
    1501001738, -- Ba Lô Ferrari (Cấp 1)
    1501001739, -- Ba Lô Dưỡng Khí (Cấp 1)
    1501001740, -- Ba Lô Mèo Anh Đào (Cấp 1)
    1501001741, -- Ba Lô Thánh Điện (Cấp 1)
    1501001742, -- Ba Lô Cuộn Trục Naruto (Cấp 1)
    1501001743, -- Ba Lô Tổ Kén Mê Hoặc (Cấp 1)
    1501001744, -- Ba Lô Thủy Thủ (Cấp 1)
    1501001745, -- Ba Lô Kho Vũ Khí Không Gian (Cấp 1)
    1501001747, -- 999HUMANITY Backpack (Lv.1)
    -- [ COVER & HEADGEAR (BỔ SUNG) ]
    1410000, -- Chroma Valkyrie Cover
    1410001, -- Vivid Beast Cover
    1410002, -- Furry Bunny Cover
    1410003, -- Coyote Rider Cover
    1410004, -- Badlands Punk Cover
    1410005, -- Radiant Youth Cover
    1410006, -- Festive Bash Cover
    1410007, -- Elite Oni Cover
    1410008, -- G.O.L.D 24K Cover
    1410009, -- Mystic Protector Cover
    1410012, -- Alfheim Wonder Cover
    1410013, -- Enigmatic Nomad Cover
    1410014, -- Heart of Jade Cover
    1410015, -- Mystic Artificer Cover
    1410016, -- Roguish Imp Cover
    1410017, -- Aurora Flash Cover
    1410018, -- Nocturnal Rhapsody Cover
    1410019, -- Maniacal Baron Cover
    1410020, -- Plasma Chic Cover
    1410021, -- Steadfast Guard Cover
    1410022, -- Trendsetter Cover
    1410023, -- Fashion Leader Cover
    1410024, -- Street Stroller Cover
    1410028, -- Infernal Chef Cover
    1410029, -- Sweet Supporter Cover
    1410030, -- Pink Shelter Cover
    1410035, -- Leprechaun Cover
    1410036, -- Green Guardian Cover
    1410037, -- Fabled Defender Cover
    1410038, -- Fearless Hero Cover
    1410039, -- Space Traveler Cover
    1410040, -- Suave Rebel Cover
    1410041, -- Masameer's Trad Headgear
    1410042, -- Dauntless Leader Cover
    1410043, -- Swole Hen Cover
    1410044, -- Honor & Glory Cover
    1410045, -- Duty & Loyalty Cover
    1410046, -- C2S5 Cover
    1410047, -- Peerless Conqueror Cover
    1410048, -- Cobalt Shadow Cover
    1410049, -- Wasteland Survivor Cover
    1410050, -- Maverick Warlock Cover
    1410051, -- Underwraith Cover
    1410052, -- Primordial Cover
    1410053, -- Swagger Lion Cover
    1410054, -- Trendy Samurai Cover
    1410055, -- Grim Bisector Cover
    1410056, -- Frost Fire Cover
    1410057, -- Draconic Cavalier Cover
    1410058, -- Wasteland Explorer Cover
    1410059, -- Nebula Dreamscape Cover
    1410060, -- Extreme Armor Model EVA-08 Cover
    1410061, -- Extreme Armor Model EVA-02 Cover
    1410062, -- Extreme Armor Model EVA-00 Cover
    1410063, -- Extreme Armor Model EVA-01 Cover
    1410064, -- GB Teddy Bear Cover
    1410065, -- Interstellar Chimera Cover
    1410066, -- Floret Fairy Cover
    1410067, -- Sacred Eminence Cover
    1410068, -- Styx Sovereign Cover
    1410069, -- Captain Woof Cover
    1410070, -- Foxy Youth Cover
    1410071, -- Ominous Fox Cover
    1410072, -- Flamewraith Mask
    1410073, -- Majestic Cavalry Cover
    1410074, -- Shady Shark Cover
    1410075, -- Shady Minion Cover
    1410077, -- Festive Meow Cover
    1410078, -- Green Wayfarer Cover
    1410079, -- Purity Defender Cover
    1410080, -- Ultimate Trendsetter Cover
    1410081, -- High Elf Cover
    1410082, -- Candle Alert Cover
    1410083, -- Captain Happy Cover
    1410084, -- Roseate Luster Cover
    1410086, -- Beach Sweetie Cover
    1410087, -- Ultimate Dancer Cover
    1410088, -- Ursa Hunter Cover
    1410089, -- Opulence Cover
    1410090, -- Cute Mummy Cover
    1410091, -- Beach Life Cover
    1410092, -- Hobby Holiday Cover
    1410093, -- Lovely Lotus Cover
    1410094, -- Phoenix Adarna Cover
    1410095, -- Mythirium Cover
    1410096, -- Butterfinger Headgear
    1410097, -- Soldier Boy Super Mask
    1410098, -- Matcha Cone Cover
    1410099, -- Mobile Plate Cover
    1410100, -- Adorable Sheep Cover
    1410101, -- Fluffy Sheep Cover
    1410102, -- Royal Bard Cover
    1410103, -- Prairie Hunter Cover
    1410104, -- Glory Guard Cover
    1410105, -- Junkrat Empire Cover
    1410106, -- Conquest Nation Cover
    1410107, -- C2S6 Cover
    1410108, -- Hipster Rebel Cover
    1410109, -- Starlight Super Suit Headband
    1410110, -- Stoic Grace Cover
    1410111, -- X-Anima Cover
    1410112, -- Funky Diver Cover
    1410113, -- Aurelian Magnate Cover
    1410114, -- Solar Oracle Cover
    1410115, -- Fabled Hero Cover
    1410116, -- Fatal Charm Cover
    1410117, -- Mystic Genie Cover
    1410118, -- Celestial Oracle Cover
    1410119, -- Garden Fairy Cover
    1410120, -- Ruthless Falconer Cover
    1410121, -- Sylvan Shaman Cover
    1410122, -- Desert Oracle Cover
    1410123, -- Maritime Agent Cover
    1410124, -- Urbane Captain Cover
    1410125, -- Bionic Sage Cover
    1410126, -- Crimson Speedster Mask
    1410127, -- Genesis Knight Cover
    1410132, -- Netherbringer Cover
    1410133, -- Eminent Seer Cover
    1410134, -- Profane Templar Cover
    1410135, -- Star Gazer Cover
    1410136, -- Bubblegum Cyborg Cover
    1410137, -- Nocturnal Hunter Cover
    1410138, -- Bramble Overlord Cover
    1410139, -- Lightning Nebula Cover
    1410140, -- Sushi Fantasy Cover
    1410141, -- Immortal Guardian Mask
    1410142, -- Fluorescent Blossom Cover
    1410143, -- Patrician's Dream Cover
    1410144, -- Noctum Terror Cover
    1410145, -- Mecha Sanctum Cover
    1410146, -- Trendy Hiker Cover
    1410147, -- Royal Aurum Cover
    1410148, -- Agent Fox Cover
    1410149, -- Oasis Idol Cover
    1410150, -- Nightfarer Glasses
    1410151, -- Crocodile Overlord Cover
    1410152, -- Merciless Jester Cover
    1410153, -- Space Buddy Cover
    1410154, -- Dimensional Butterfly Cover
    1410155, -- Wintry Azure Cover
    1410156, -- Beach Outing Cover
    1410157, -- Swagmeister Cover
    1410158, -- Noble Ruler Cover
    1410159, -- Ocean Warrior Cover
    1410160, -- Camel Rockstar Cover
    1410161, -- Al Mazyunah Headgear
    1410162, -- Markhor Cover
    1410163, -- Lahore Qalandars Hat
    1410164, -- First Mate Cover
    1410165, -- Tabasco Cover
    1410166, -- Softserved Cover
    1410167, -- Burrito Cover
    1410168, -- Brave Commander Hat
    1410169, -- Youth Hat
    1410170, -- CyberGen: Zero Cover
    1410171, -- Edgy Brawler Cover
    1410172, -- CYCLE 3 Cover
    1410173, -- C3S7 Cover
    1410174, -- C3S7 Colombina
    1410175, -- Nightfarer Mask
    1410176, -- Green Soldier Cover
    1410177, -- Yellow Soldier Cover
    1410178, -- Red Soldier Cover
    1410179, -- Violet Vengeance Cover
    1410180, -- Leopard Spot Cover
    1410181, -- Rhythm Junkie Cover
    1410182, -- Flamingo Cover
    1410183, -- PMPS 2022 Headgear
    1410184, -- Acolyte of Justice Cover
    1410185, -- General Nutcracker Cover
    1410186, -- Exalted Serenity Cover
    1410187, -- 2022 PMWI Special Cover
    1410188, -- Clockwork Illusionist Cover
    1410189, -- Doom Guardian Cover
    1410190, -- Python Warrior Cover
    1410191, -- Mutant Squid Cover
    1410192, -- Midnight Shadow Cover
    1410193, -- Nebulous Conqueror Cover
    1410194, -- Abyssal Judge Cover
    1410195, -- Underworld Adjudicator Cover
    1410196, -- Tide Commander Cover
    1410198, -- Tribal Hero Cover
    1410199, -- Spectral Swan Cover
    1410200, -- Cosmic Inquisitor Cover
    1410201, -- Fjord Warrior Cover
    1410202, -- Ceremonial Rose Cover
    1410203, -- Space Idol Cover
    1410204, -- Scarlet Shadow Cover
    1410205, -- Desert Taskforce Cover
    1410206, -- Midas Fortune Cover
    1410207, -- Clairvoyant Fox Cover
    1410208, -- Groovy Peck Cover
    1410209, -- BGMI Esports Headgear
    1410210, -- Hip Hop Scarecrow Cover
    1410211, -- DJ Dancer Cover
    1410212, -- Chromakey Comedian Cover
    1410213, -- Chromakey Comedian Mask
    1410214, -- Arctic Fox Cover
    1410215, -- Dino Mama Cover
    1410216, -- Skull Bunny Cover
    1410217, -- Floral Fresh Cover
    1410218, -- Forest Fruits Cover
    1410219, -- Eventide Butterfly Cover
    1410220, -- Jade Sultan Cover
    1410221, -- Jade General Cover
    1410222, -- Jade Princess Cover
    1410223, -- Sindhi Topi Hat
    1410224, -- Passionate Cactus Cover
    1410225, -- Dino Trooper Cover
    1410226, -- Crimson Claw Cover
    1410227, -- White Grace Cover
    1410228, -- 4EVE T-POP Idol Cover
    1410229, -- 4EVE Bubbly Bomb Cover
    1410230, -- Dazzling Dance Cover
    1410231, -- C3S8 Cover
    1410232, -- Nether Visage Cover
    1410233, -- Phantom of Erangel Cover
    1410234, -- PMJL SEASON3 Headgear
    1410235, -- Imperial Enforcer Cover
    1410236, -- Martial Warlord Cover
    1410237, -- Fiery Rhythm Cover
    1410238, -- Cybernetic Trance Cover
    1410239, -- Visionary Clairvoyant Cover
    1410240, -- Silverwing Conjurer Cover
    1410241, -- Divine Seer Cover
    1410248, -- Illustrious Archon Cover
    1410249, -- Scarlet Magus Cover
    1410250, -- Messi Super Legend Hat
    1410251, -- Mountain Ancestry Cover
    1410252, -- Glacial Heredity Cover
    1410253, -- Carmine Tribesperson Cover
    1410254, -- Conquering Soul Cover
    1410255, -- Bloody Noon Cover
    1410256, -- Starsea Admiral Cover
    1410257, -- Tribal Hipster Cover
    1410258, -- Hazmat Vanguard Cover
    1410259, -- Monochrome Radiance Cover
    1410260, -- Aurulent Antlers Cover
    1410261, -- Frore Warden Cover
    1410262, -- Sanguine Nightmare Cover
    1410263, -- Luxury Gala Cover
    1410264, -- Merry Snowman Cover
    1410265, -- Youthful Charm Cover
    1410266, -- Stern Kitty Cover
    1410267, -- Remote Excursion Glasses
    1410268, -- Prestigious Noble Cover
    1410269, -- Sun Warrior Cover
    1410270, -- Sun Warrior Princess Cover
    1410271, -- Sun Mask
    1410272, -- Test Cricket Cap - Classic
    1410273, -- T20 Cricket Cap - Classic
    1410274, -- Yak Warrior Cover
    1410275, -- Icy Slayer Cover
    1410276, -- AFA Hat
    1410277, -- Viet Indie Prince Astronaut Glasses
    1410278, -- Indomie Warrior Robot Cover
    1410279, -- Spring Spirit Cover
    1410280, -- Will to Win Cover
    1410281, -- Peculiar Magician Cover
    1410282, -- C3S9 Cover
    1410283, -- Twilight Warden Cover
    1410284, -- Astral Arcanist Cover
    1410285, -- Cursed Heir Cover
    1410286, -- Foxy Charmer Cover
    1410287, -- Arcane Jester's Mask
    1410288, -- Arcane Jester's Mask
    1410289, -- Bruce Lee Kung Fu Soul Cover
    1410290, -- Solar Empress Cover
    1410291, -- Solar Emperor Cover
    1410292, -- Seafoam Assassin Cover
    1410293, -- Battle Puppet Cover
    1410294, -- Blazetech Patrol Cover
    1410295, -- Symphonic Solace Cover
    1410296, -- Mystic Veteran Cover
    1410297, -- Ascendant Agent Mask
    1410298, -- Cherry Fox Cover
    1410299, -- Silver Guru Cover
    1410300, -- Nether Phantom Cover
    1410301, -- Solar Knight Cover
    1410302, -- Vile Invader Cover
    1410303, -- Fistfight Maiden Cover
    1410304, -- Agile Charmer Cover
    1410305, -- Dragonflame Berserker Cover
    1410306, -- Venerable Assassin Cover
    1410307, -- Royal Guard Cover
    1410308, -- Martial Champion Cover
    1410309, -- Mythical Monkey Cover
    1410310, -- Bunny Uniform Cover
    1410311, -- Wonderful Bunny Cover
    1410312, -- Crimson Charm Cover
    1410313, -- Floral Snowflake Cover
    1410314, -- Snowpaw Cover
    1410315, -- Red Tuxedo Hat
    1410316, -- Fyonka Mask
    1410317, -- Mithu Tota Mask
    1410318, -- Maxi Cover
    1410319, -- Sherwani Cover
    1410320, -- Shock Cyberarmor Cover
    1410323, -- Frost Queen Cover
    1410324, -- Crimson Academia Cover (Female)
    1410325, -- Rabbit Sprite Cover
    1410326, -- Elemental Burst Cover
    1410327, -- Azure Defender Cover
    1410328, -- CYCLE 4 Cover
    1410329, -- Falcon Cast Cover
    1410330, -- C4S10 Cover
    1410331, -- Warrior Techwear Cover
    1410332, -- Gilded Idol Cover
    1410333, -- Bushido Grace Cover
    1410334, -- Monkey Vanguard Cover
    1410335, -- Monkey Vanguard Mask
    1410336, -- Scarlet Phantom Cover
    1410337, -- Trendy Bunny Cover
    1410338, -- Pink Sweetie Cover
    1410339, -- Royal Admiral Cover
    1410340, -- Mirage Executive Cover
    1410341, -- Veiled Princess Cover
    1410342, -- New Potential Cover
    1410343, -- Gilded Bone Cover
    1410344, -- Gemstone Noble Cover
    1410345, -- Sly Bunny Cover
    1410349, -- Mystic Sorceress Cover
    1410350, -- Sacred Maiden Cover
    1410351, -- Resplendent Prince Cover
    1410352, -- Crescent Princess Cover
    1410353, -- Cucumber Genius Cover
    1410354, -- Falcon Warrior Cover
    1410355, -- Moondrop Eterna Cover
    1410356, -- Bloodstained Nemesis Mask
    1410357, -- Slime Warrior Cover
    1410358, -- Wondrous Magician Cover
    1410359, -- Violet Buccaneer Cover
    1410360, -- Dark Reign Cover
    1410361, -- Aureate Splendor Cover
    1410362, -- Secret Fashion Cover
    1410363, -- Rising Rebel Cover
    1410364, -- Bunny Lover Cover
    1410365, -- Ears & Bow Cover
    1410366, -- Gold King Cover
    1410367, -- Saltooh Cover
    1410368, -- Miss Fitna Cover
    1410369, -- Donkey Raja Cover
    1410370, -- Tidal Soldier Cover
    1410371, -- Angus Cloud What's Next Hat
    1410372, -- Origin Flame Cover
    1410373, -- Wings of Fury Cover
    1410374, -- Wild Wolf Mask
    1410375, -- Dark Bunny Cover
    1410376, -- Neon Force Helmet
    1410377, -- Nasi Lemak Cover
    1410378, -- Pro League Cover
    1410379, -- Kitty Dancer Cover
    1410380, -- Butterfly Wayfarer Cover
    1410381, -- C4S11 Cover
    1410382, -- Acrobatic Bear Cover
    1410383, -- Circus Star Cover
    1410384, -- Bunny Academy Mascot Cover
    1410385, -- Thriller Doll Cover
    1410386, -- Bunny Academy Sailor Visor
    1410387, -- Rose Conjurer Cover
    1410388, -- Blood Rose Cover
    1410390, -- Shackled Horns Cover
    1410391, -- Dracolith Assassin Cover
    1410393, -- Umbral Starfall Cover
    1410394, -- Radiant Dawnstar Cover
    1410395, -- Shamate Rex Cover
    1410396, -- Golden Blessing Cover (Female)
    1410397, -- Golden Blessing Cover (Male)
    1410398, -- Exo Fossil Cover
    1410399, -- Draconic Empress Cover
    1410400, -- Mr. Tooth Cover
    1410401, -- Horned Kingpin Cover
    1410402, -- Ruby Trickster Cover
    1410403, -- Dino Dream Cover
    1410404, -- Noctum Sunder Cover
    1410405, -- Night Vixen Cover
    1410406, -- Graffiti Whiz Cover
    1410407, -- Glacier Squad Cover
    1410408, -- Detective Bunny Cover
    1410409, -- Hemabone Shaman Cover
    1410410, -- Neon Slayer Cover
    1410411, -- Mystic Punk Cover
    1410412, -- Dawn Vigilante Cover
    1410413, -- Dino Paradise Alex Cover
    1410414, -- Dino Paradise Mascot Cover
    1410415, -- Potato Man Cover
    1410416, -- Kebab Skewer Cover
    1410417, -- Light of Glory Cover
    1410418, -- 5 Stars Customer Cover
    1410419, -- Innocent Love Cover
    1410420, -- Dusk Vigilante Cover
    1410421, -- Dazzling Dancer Cover
    1410422, -- Star Maestro Cover
    1410423, -- Day Out Cover
    1410424, -- Nocturnal Slayer Cover
    1410425, -- C4S12 Cover
    1410427, -- Dino Rider Cover
    1410428, -- Phantom Commando (Lv. 1)
    1410429, -- Phantom Commando (Lv. 2)
    1410430, -- Phantom Commando (Lv. 3)
    1410431, -- Odd Bunny Cover
    1410432, -- Kappa Hoodie Cover
    1410433, -- Mr. Tooth Cover
    1410434, -- Ruby Trickster Cover
    1410435, -- Horned Kingpin Cover
    1410436, -- Psychophage Cover
    1410437, -- DJ Vibe Cover
    1410438, -- Tealara Maiden Cover
    1410439, -- Amplifire Cover
    1410440, -- Forest Whisper Cover
    1410441, -- Summer Surf Cover
    1410442, -- Deep Dive Hat
    1410443, -- Frieza Style Cover
    1410444, -- Beerus Style Cover
    1410445, -- Majin Buu Style Cover
    1410446, -- Neon Vixen Cover
    1410447, -- Ladybug Lover Cover
    1410448, -- Shadow Squad Assault Cover
    1410449, -- Shadow Squad Medic Cover
    1410450, -- Shadow Squad Sharpshooter Cover
    1410451, -- Shadow Squad MachineGunner Cover
    1410452, -- Great White Virtuoso Cover
    1410453, -- Cerulean Slayer Cover
    1410454, -- Fashionista Ink Cover
    1410455, -- Molluscan Waverider Cover
    1410456, -- Molluscan Waverider Mask
    1410457, -- Icy Bliss Cover
    1410458, -- Gulping Gull Cover
    1410460, -- Bubblegum Shark Cover
    1410461, -- Teddy Belle Cover
    1410463, -- Vogue Surfer Cover
    1410464, -- Surfside Sweetheart Cover
    1410465, -- Playful Prankster Cover
    1410466, -- Boxy Battlegrounder Cover
    1410467, -- Rave Luminary Cover
    1410468, -- Poolside Getaway Cover
    1410469, -- Beachside Getaway Cover
    1410470, -- Ripple Strider Cover
    1410471, -- Cool Husky Cover
    1410472, -- Ribbon Straw Hat (Black)
    1410473, -- Ribbon Straw Hat (Blue)
    1410474, -- Gentlebear Cover
    1410475, -- Garuda Series Hunter Cover
    1410478, -- Rose Royal Cover
    1410479, -- Honor Guard Cover
    1410481, -- CYCLE 5 Cover
    1410482, -- C5S13 Cover
    1410483, -- Mad Drifter Mask
    1410484, -- Battle Crescendo Cover
    1410485, -- Battleground Assassin Cover
    1410486, -- Charming Cook Cover
    1410487, -- Emberfox Cover
    1410490, -- Butterflame Cover
    1410491, -- Cruel Torment Cover
    1410492, -- Tricky Witch Cover
    1410494, -- KFC Chicken Champ Cover
    1410495, -- Carnival Celebration Cover
    1410497, -- Red Eagle Prince Cover
    1410498, -- Light Feather Princess Cover
    1410499, -- Suave Master Cover
    1410500, -- Ducky Slasher Cover
    1410501, -- Ducky Archer Cover
    1410502, -- Sakura Samurai Cover
    1410503, -- Roseate Moonling Cover
    1410504, -- Venust Evenfall Cover
    1410505, -- Madame Carmine Cover
    1410506, -- Cursed Scarecrow Mask
    1410507, -- Hacker Bunny Cover
    1410508, -- Glacial Bride Cover
    1410509, -- Colorburst Hat
    1410510, -- Ducky Fighter Cover
    1410511, -- Ducky Fraud Cover
    1410512, -- Nitro Maniac Cover
    1410513, -- Gutsy Lass Cover
    1410514, -- Seadrake Champion Cover
    1410515, -- Citrus Bodysuit Cover
    1410516, -- Dark Kitten Cover
    1410517, -- Batblitz Cover
    1410518, -- Maple Master Cover
    1410519, -- Sleepy Bunny Hat
    1410520, -- Sleepless Cat Cover
    1410521, -- Lady Nocturne Cover
    1410522, -- Chaosbound Shackles Cover
    1410523, -- Skeletal Chevalier Cover
    1410524, -- Blossom Belle Cover
    1410525, -- Grungehead Cover
    1410526, -- Deific Hunter Cover
    1410527, -- C5S14 Cover
    1410528, -- Lunahowl Set (Lv. 1)
    1410529, -- Lunahowl Set (Lv. 2)
    1410530, -- Lunahowl Set (Lv. 3)
    1410531, -- Ironthorn Anubis Cover
    1410532, -- The Magician's Arcane Cover
    1410533, -- The Fool's Delight Cover
    1410534, -- No.33 Blue Cricket Headgear
    1410535, -- Pastel Puff Cover
    1410536, -- Sweet Horns Cover
    1410537, -- Winged Legend Cover
    1410538, -- 2023 PMGC One Shot Cover
    1410539, -- 2023 PMGC Gold Champ Cover
    1410540, -- Frigid Beast Cover
    1410541, -- Midnight Muse Cover
    1410542, -- Shadowfire Captain Cover
    1410543, -- Spirited Maiden Cover
    1410544, -- Fiestabelle Cover
    1410545, -- Foxy Flare Cover
    1410546, -- Winter Highness Cover
    1410547, -- Cryptic Hunter Cover
    1410548, -- Biowave Trekker Cover
    1410549, -- Avian Charmer Cover
    1410550, -- Ebil Bunny Cover
    1410551, -- Polar Bear Cover
    1410552, -- Merry Darkness Cover
    1410553, -- Lurik Nusantara Cover
    1410554, -- Klava Koka Cover
    1410555, -- Maula Jatt Cover
    1410556, -- Pearly White Cover
    1410557, -- Vivid Voyager Cover
    1410558, -- C5S15 Cover
    1410559, -- Fiore X-Suit - Hair (Lv. 1)
    1410560, -- Fiore X-Suit - Hair (Lv. 2)
    1410562, -- Panthera Prime Set (Lv. 1)
    1410563, -- Panthera Prime Set (Lv. 2)
    1410564, -- Panthera Prime Set (Lv. 3)
    1410565, -- Furs 'n' Spots Cover
    1410566, -- Pagani Driver Cover
    1410567, -- Panda Sweetie Cover
    1410568, -- Dracostride Cover
    1410569, -- Mystic Maroon Mask
    1410570, -- Beary Bouquet Cover
    1410571, -- Oasis Charm Mask
    1410572, -- Ninja Mouse Cover
    1410573, -- Dragon Emperor Cover
    1410574, -- Dragon Empress Cover
    1410575, -- Rosy Riding Hood Cover
    1410576, -- Inferno Valkyrie Cover
    1410577, -- LINE FRIENDS Dragon BROWN Cover
    1410578, -- LINE FRIENDS Dragon CONY Cover
    1410579, -- Inkstripe Tiger Cover
    1410580, -- Mansion Maiden Cover
    1410581, -- Cyberfighter Mask
    1410582, -- Fatal Fox Cover
    1410583, -- Cheeky Romance Cover
    1410584, -- Vibrant Bride Cover
    1410586, -- Dreamy Lass Cover
    1410587, -- Snowflake Fox Cover
    1410588, -- Sakura Fox Cover
    1410589, -- Half-Bald Zanmang Loopy Cover
    1410590, -- Zanmang Loopy Cover
    1410591, -- Happy Zanmang Loopy Cover
    1410592, -- Angry Zanmang Loopy Cover
    1410593, -- Hardik Blitz 33 Cap 
    1410594, -- Livik Huskies Cover
    1410595, -- Extreme Cyberwear Cover
    1410596, -- CYCLE 6 Cover
    1410597, -- C6S16 Cover
    1410598, -- Lion Reign Cover
    1410602, -- Phantom Luster Cover
    1410603, -- Striped Sweetheart Cover
    1410604, -- Theater Tycoon Cover
    1410605, -- Auric Guardian Cover
    1410606, -- Royal Rogue Cover
    1410607, -- Groove Socialite Cover
    1410608, -- Prim Prestige Cover
    1410609, -- Tech Striker Cover
    1410610, -- SPY×FAMILY Thorn Princess Set
    1410611, -- SPY×FAMILY Anya Hairstyle
    1410612, -- Seraphic Princess Hairstyle
    1410613, -- Seraphic Princess Cover
    1410614, -- Seraphic Genie Cover
    1410615, -- Gilded Wings Cover
    1410616, -- Chic Boxhead Cover
    1410617, -- Patched Puppet Cover
    1410618, -- Suave Royal Cover
    1410619, -- Feline Fighter Cover
    1410620, -- Magick Delight Cover
    1410621, -- Gallant Jockey Cover
    1410622, -- Dread Doc Mask
    1410623, -- Skyreign Cover
    1410624, -- Limit Breaker Cover
    1410625, -- Manor Mage Cover
    1410626, -- Vogue Vigor Cover
    1410627, -- Punk Pink Cover
    1410628, -- Ethereal Flutter Cover
    1410629, -- Bunny Beauty Cover
    1410630, -- Tira the Power of 9 Dragons Cover
    1410631, -- Bunny Pilot Cover
    1410633, -- Phantom Streetwear Hairstyle
    1410634, -- Silent Stalker Mask
    1410635, -- C6S17 Cover
    1410639, -- Graceful Hairdo Cover
    1410640, -- Melodic Feline Cover
    1410641, -- Squeakology Cover
    1410642, -- Wasteland Samurai Mask
    1410643, -- Future Trunks Style Hair
    1410644, -- Mai Style Hair
    1410645, -- Shrine Keeper Cover
    1410648, -- Iron Warden Cover
    1410650, -- Dr. Quirk Cover
    1410651, -- Devious Cybercat Cover
    1410652, -- Graceful Watcher Cover
    1410653, -- Virtual Pilgrim Cover
    1410654, -- Verdant Fairy Cover
    1410655, -- Peepkin Cover
    1410656, -- Regal Fox Cover
    1410657, -- Enchanting Succubus Cover
    1410658, -- Alluring Angel Cover
    1410659, -- Royal Heir Cover
    1410660, -- Sunfire Archon Cover
    1410661, -- Mech Surge Cowgirl Hat
    1410662, -- Vibrant Gaze Cover
    1410663, -- C6S18 Cover
    1410667, -- Innovative Artisan Cover
    1410668, -- Inferno Fiend Set
    1410669, -- Shadow Empress Cover
    1410670, -- Night Maiden Cover
    1410671, -- Lieutenant Chaos Cover
    1410672, -- Pyrosoul Renegade Cover
    1410673, -- Sting Queen Cover
    1410674, -- Bloodmoon Assassin Cover
    1410675, -- Swiftfoot Phantom Cover
    1410676, -- Fallen Spirit Cover
    1410677, -- Eternal Champion Cover
    1410678, -- Violet Thunder Cover
    1410679, -- Imperial Patriarch Cover
    1410680, -- Imperial Matriarch Cover
    1410681, -- Illumispark Cover
    1410682, -- Deep Sea Admiral Cover
    1410683, -- Deep Sea Princess Cover
    1410684, -- White Wave Operation Hat
    1410685, -- Rippling Charm Cover
    1410686, -- Spectral Admiral Cover
    1410687, -- Wave Whisperer Cover
    1410688, -- Fluorescent Raider Cover
    1410689, -- MUZI Sunglasses
    1410690, -- RYAN School Uniform Headgear
    1410691, -- Bellygom Classic Headgear
    1410692, -- Bellygom Snug Bowl Headear
    1410693, -- Private Aviator Cover
    1410694, -- Speedwolf Cover
    1410695, -- CYCLE 7 Cover
    1410696, -- C7S19 Cover
    1410697, -- Shark Tech Cover
    1410698, -- Bhaala Yodha Headgear
    1410699, -- Speedster Jav Headgear
    1410700, -- PUBGM X NewJeans MINJI Headpiece
    1410702, -- PUBGM X NewJeans HANNI Headpiece
    1410704, -- PUBGM X NewJeans HAERIN Headpiece
    1410706, -- PUBGM X NewJeans DANIELLE Headpiece
    1410708, -- PUBGM X NewJeans HYEIN Headpiece
    1410710, -- Imperial Guard Cover
    1410714, -- Manic Bunny Cover
    1410715, -- Chaos Academy Cover
    1410716, -- Heart Warden Cover
    1410717, -- Silvermoon Agent Cover
    1410718, -- Paranormal Feline Mask
    1410719, -- Flamestrider Cover
    1410720, -- The Reaper's End Cover
    1410721, -- Judgment's Ruling Cover
    1410722, -- Strength's Domination Cover
    1410723, -- Cosmic Beast Cover
    1410724, -- Vampyra Countess Cover
    1410725, -- Festering Gravewalker Cover
    1410726, -- Lethal Lady Cover
    1410727, -- Underworld Aristocrat Cover
    1410728, -- Order of the Black Knights Headpiece
    1410729, -- Jeremiah Gottwald Mask
    1410730, -- Emperor Lelouch Headpiece
    1410731, -- Floral Descent Cover
    1410732, -- DP Ice Queen Guardian Dazzle
    1410733, -- DP Glamour Gladiator Crown
    1410734, -- DP Techno Fairy Cyber Glam
    1410735, -- Emil Headpiece
    1410736, -- 9S Hair
    1410737, -- NieR Hair
    1410738, -- 2B Hair
    1410739, -- Kaine Hair
    1410740, -- Serial Pumpkin Cover
    1410741, -- Scarlet Steel Cover
    1410742, -- Noir Feline Cover
    1410743, -- Breakthrough Civilization Cover
    1410744, -- Rubiz Lasuly Cover
    1410745, -- Shadow Enigma Mask
    1410746, -- C7S20 Cover
    1410752, -- The Reaper's End Cover
    1410753, -- Quasar Clan Cover
    1410754, -- Winter Warrior Cover
    1410755, -- Hypernova Fission Cover
    1410756, -- Joyful Snowman Cover
    1410757, -- Carefree Snowman Cover
    1410758, -- Vetr Champion Cover
    1410759, -- Skadiwynn Sentinel Cover
    1410760, -- Royal Deeress Cover
    1410761, -- Mecha Dawn Cover
    1410762, -- Cyberbeat Kitty Cover
    1410763, -- NeoViolet Fighter Cover
    1410764, -- McLaren Formula 1 Team Helmet
    1410766, -- Midnight Raven Cover
    1410767, -- Midnight Enigma Cover
    1410768, -- Snowstar Sweetheart Cover
    1410769, -- Glacial Mirage Cover
    1410770, -- Night Phantasma Cover
    1410771, -- Funky Fusion Cover
    1410772, -- Meowy Spirit Cover
    1410773, -- Playful Imp Cover
    1410774, -- Sweet Darling Cover
    1410775, -- Winter Earl Cover
    1410776, -- Snowbound Elegance Cover
    1410777, -- Ranga Headpiece
    1410778, -- Rimuru Headpiece
    1410779, -- Energy Drink Rimuru Headpiece
    1410780, -- Mystic Prism Princess Cover
    1410781, -- Rakhim Mask
    1410782, -- Gilded Feather Mask
    1410783, -- Nomad Warrior Cover
    1410784, -- Easy Swag Headgear
    1410785, -- C7S21 Cover
    1410789, -- Scarlet Grace Cover
    1410790, -- New Age Channeler Cover
    1410791, -- Dragontide Pulse Glasses
    1410792, -- Empyrean Mystique Cover
    1410793, -- Empyrean Exemplar Cover
    1410794, -- Brightfeather Prince Cover
    1410795, -- Chill Flow Cover
    1410796, -- Dreamweaver Cover
    1410797, -- Jadefang Aurora Cover
    1410798, -- Midnight Revenant Cover
    1410799, -- Agent Rose Cover
    1410800, -- Opanchu Face Headgear
    1410801, -- Opanchu Face Headgear
    1410802, -- Opanchu Panchu Face Headgear
    1410803, -- Rainbow Wiz Cover
    1410804, -- Elegant Nightwear Cover
    1410805, -- Emerald Soldier Cover
    1410806, -- Gridiron Gladiator Cover
    1410807, -- Frosty Glampunk Cover
    1410808, -- Flora Queen Cover
    1410809, -- Panda Warrior Cover
    1410810, -- Rosy Sweetie Cover
    1410811, -- CYCLE 8 Cover
    1410812, -- C8S22 Cover
    1410813, -- Elysian Bloom Set
    1410814, -- Nightfall Blossom Set
    1410818, -- Camel Super Fan Cover
    1410819, -- Netherbound Rider Cover
    1410820, -- Ecliptic Guardian Cover
    1410821, -- Neon Renegade Cover
    1410822, -- Crimson Cadence Cover
    1410823, -- Feline Enigma Cover
    1410824, -- Anarchy Medley Cover
    1410825, -- Burning Godzilla Urban Cover
    1410826, -- Godzilla Urban Cover
    1410827, -- King Ghidorah Urban Cover
    1410828, -- Foxie Moxie Cover
    1410829, -- Lumara Grace Cover
    1410830, -- Starion Defender Cover
    1410831, -- Stepstar Flair Cover
    1410832, -- Malus Majesty Cover
    1410833, -- Miss Marionette Cover
    1410834, -- Orangepop Idol Cover
    1410835, -- Revolt Rabbit Cover
    1410836, -- Aura's Hairstyle
    1410837, -- Classic Thawb Cover
    1410838, -- Verdant Whisper Cover
    1410839, -- 7th Anniversary Cover
    1410840, -- C8S23 Cover
    1410843, -- Patchmetal Bunny Set (Lv. 1)
    1410844, -- Patchmetal Bunny Set (Lv. 2)
    1410845, -- Patchmetal Bunny Set (Lv. 3)
    1410847, -- Galvanic Judge Cover
    1410848, -- Chronomuse Cover
    1410849, -- Battleworn Strider Cover
    1410850, -- Outland Maiden Cover
    1410851, -- Polychrome Bunny Cover
    1410852, -- Steamline Scholar Cover
    1410853, -- Cybersanct Paradox Cover
    1410854, -- Cybersanct Enigma Cover
    1410855, -- Stellar Honey Cover
    1410856, -- Stepflair Flux Cover
    1410857, -- Belle Tinkerer Cover
    1410858, -- Steamwork Artisan Cover
    1410859, -- Lilac Delight Cover
    1410860, -- Springtime Charm Cover
    1410861, -- Urban Allure Cover
    1410862, -- Trendy Leather Cover
    1410863, -- Featherweight Boxer Cover
    1410864, -- Sunny Hayride Cover
    1410865, -- Vibrant Streetwear Cover
    1410866, -- Maasai Headband
    1410867, -- Brute Gentleman Cover
    1410868, -- Urban Flow Cover
    1410869, -- C8S24 Cover
    1410877, -- Graviton Sentinel Cover
    1410878, -- Neon Nova Cover
    1410879, -- Goldline Ace Glasses
    1410880, -- Optimus Prime Style Cover
    1410881, -- Elita-1 Style Cover
    1410882, -- Shockwave Style Cover
    1410883, -- Sweet Nailoong Cover
    1410884, -- Archon Oracle Mask
    1410885, -- Goldhorn Steward Cover
    1410886, -- Keenhorn Sentry Cover
    1410887, -- Jungle Operative Cover
    1410888, -- Strayhound Style Cover
    1410889, -- Seaside Stunner Cover
    1410890, -- Darling Defiance Cover
    1410891, -- Goldfeather Insight Cover
    1410892, -- Lil Hit the Hitmaker Cover
    1410893, -- Yellowjacket Mech Cover
    1410894, -- Frontline Explorer Cover
    1410895, -- C9S25 Cover
    1410911, -- Strawberry Fantasy Cover
    1410919, -- Ribclad Reaper Cover
    1410920, -- Saccharine Riot Cover
    1410921, -- Sonic Style Cover
    1410922, -- Tails Style Cover
    1410923, -- The Hermit's Chrysalis Cover
    1410924, -- Blackthorn Marquis Cover
    1410925, -- Floralith Muse Cover
    1410926, -- Highstreet Haze Cover
    1410927, -- Grimtail Pelt Cover
    1410928, -- Velvet Jack Cover
    1410929, -- Velvet Dusk Cover
    1410930, -- Moonrabbit Maiden Cover
    1410931, -- Eternal Godfather Cover
    1410932, -- Departed Aria Cover
    1410933, -- Madcap Punk Cover
    1410935, -- Sugarspell Curse Cover
    1410936, -- Pumpkin Pixie Cover
    1410937, -- Spook Sweepers Cover
    1410938, -- Royal Scion Cover
    1410939, -- Peachy Pop Cover
    1410940, -- Cameraman Cover
    1410941, -- Dawn Academy Cover
    1410942, -- Darkheart Operative Mask
    1410943, -- Tungsten Sentinel Cover
    1410944, -- C9S26 Cover
    1410945, -- The Hermit's Chrysalis Cover
    1410955, -- The Hermit's Chrysalis Cover
    1410956, -- The Hermit's Chrysalis Cover
    1410957, -- Sugarcone Darling Cover
    1410958, -- Frost Admiral Cover
    1410959, -- Mellow Vogue Cover
    1410960, -- Eagleborne Aurora Cover
    1410961, -- Wolfborne Pathfinder Cover
    1410962, -- Cozy Charm Cover
    1410963, -- Porsche Racing Helmet
    1410964, -- Aurorion Mirage Cover
    1410965, -- Aeroflux Phase Cover
    1410966, -- Onyxis Witch Cover
    1410967, -- ASA Cover
    1410968, -- RORA Cover
    1410969, -- RUKA Cover
    1410970, -- Merry Mauler Hairstyle
    1410971, -- Jolly Antlers Cover
    1410972, -- Blizzard Belle Cover
    1410973, -- Winterglow Sylph Cover
    1410974, -- Tundrawalk Agent Cover
    1410975, -- Arctic Tracker Cover
    1410976, -- Fresh Fit Cover
    1410977, -- Youth Beat Hat
    1410978, -- Fluffy Time Hat
    1410979, -- Flow Balance Hat
    1410980, -- Polar Traveler Cover
    1410981, -- Serpoians Head
    1410982, -- District Zero Hat
    1410983, -- Wild Tracker Cover
    1410984, -- Wild Pioneer Cover
    1410985, -- SCHOTT NYC Hat
    1410986, -- Jolly Snowjoy Cover
    1410987, -- Electro Edge Cover
    1410988, -- C9S27 Cover
    1410989, -- Red Afro (Lv. 1)
    1410990, -- Red Afro (Lv. 2)
    1410991, -- Red Afro (Lv. 3)
    1410996, -- Yellow Afro (Lv. 1)
    1410997, -- Yellow Afro (Lv. 2)
    1410998, -- Yellow Afro (Lv. 3)
    1410999, -- Green Afro (Lv. 1)
    1411000, -- Green Afro (Lv. 2)
    1411001, -- Green Afro (Lv. 3)
    1411014, -- Noh Mask Ninja Cover
    1411015, -- Floral Waltz Cover
    1411016, -- Panda Darling Cover
    1411017, -- Dune Prince Cover
    1411018, -- Heart Hacker Cover
    1411019, -- Party Bunny Cover
    1411020, -- Sweet Influencer Cover
    1411021, -- Grand Debutante Cover
    1411022, -- Radiant Stardom Hairstyle
    1411023, -- Veiled Enchantress Cover
    1411024, -- Jade Viper Cover
    1411025, -- Feral Witchdoctor Cover
    1411026, -- Fragrant Motion Cover
    1411027, -- Garden Stroll Cover
    1411028, -- Tailgate Craze Hairstyle
    1411029, -- Serene Affection Cover
    1411030, -- Stage Vibe Sunglasses
    1411031, -- El Omda Cover
    1411032, -- Ornate Blossom Cover
    1411033, -- S28 Cover
    1411048, -- Rose Coronet
    1411049, -- Sunflower Cover
    1411050, -- Kokoshnik (Red)
    1411051, -- Crying Cat Mask
    1411052, -- Jester's Gambit Cover
    1411053, -- Twirling Sands Cover
    1411054, -- Punk Vanguard Cover
    1411055, -- Aoi Todo Cover
    1411056, -- Choso Cover
    1411057, -- Meowlectric Flash Cover
    1411058, -- Nightfall Blade Cover
    1411059, -- Aerial Recon Cover
    1411060, -- Coldsteel Hacker Cover
    1411061, -- Mutant Doctor Cover
    1411062, -- Gothic Nurse Cover
    1411063, -- Orange Squad: Special Edition Hairstyle
    1411064, -- Dynamic Realm Cover
    1411065, -- Steampunk Princess Cover
    1411066, -- Ironwatch Sentinel Cover
    1411067, -- Fortune Teller Cover
    1411068, -- Dimensional Diva Cover
    1411069, -- Sonic Siren Cover
    1411070, -- Urban Patrol Cover
    1411071, -- Lightning Circuit Cover
    1411072, -- BamBam Infinite Octave Cover
    1411073, -- Minnie Infinite Octave Cover
    1411074, -- FiNCH Cover
    1411075, -- Dungeon Rogue Cover
    1411076, -- Sparkle Spec Ops Cover
    1411077, -- S29 Cover
    1411087, -- Thala Legacy Cover
    1411088, -- Queen of Suits Cover
    1411089, -- Legendary Noble Cover
    1411090, -- Maid Berserker Cover
    1411091, -- Clash of Duty Glasses
    1411092, -- Harley-Davidson® Blacktop Biker Sunglasses
    1411093, -- Harley-Davidson® Street Smart Bandana
    1411094, -- Chicken Winner Cover
    1411095, -- Denim Rebel Cover
    1411096, -- Lethal Beat Cover
    1411097, -- Rose Requiem Cover
    1411098, -- Wondrous Academy Cover
    1411099, -- Fantasy Academy Cover
    1411100, -- Castor Cover
    1411101, -- Pollux Cover
    1411102, -- Serpent Handler Cover
    1411103, -- Aberrant Aphrodite Cover
    1411104, -- Eminent Scholar Cover
    1411105, -- Feathered Scholar Cover
    1411106, -- Laurel Melody Cover
    1411107, -- Elegant Dancer Glasses
    1411108, -- Urban Stride Glasses
    1411109, -- Stylish Traveler Cover
    1411110, -- City Stroll Glasses
    1411111, -- Street Wiz Cover
    1411112, -- Wild rabbit Cover
    1411113, -- Veteran Guard Cover
    1411114, -- Magixx Cover
    1411115, -- Tahilalats Sunset Rhythm Beanie
    1411116, -- Acolyte Operative Cover
    1411117, -- Turf Superfan Cover
    1411118, -- S30 Cover
    1411119, -- Civil Harmony Cover
    1411130, -- Cybernetic Samurai Cover
    1411131, -- Nightfall Stalker Cover
    1411132, -- Pink Bunny Cadet Cover
    1411136, -- Atlantean Ranger Cover
    1411137, -- Futuretech Jackal Mask
    1411138, -- Racing Superstar Helmet
    1411139, -- Street Breaker Hat
    1411140, -- Sunbasker Cover
    1411141, -- Tide Tracker Cover
    1411142, -- Electron Energy Cover
    1411143, -- Proton Power Cover
    1411144, -- Sakura Neko Cover
    1411145, -- Equinox Vulpes Cover
    1411146, -- Darkmoon Corvus Cover
    1411147, -- Phantasia Siren Cover
    1411148, -- Puppet Maestro Cover
    1411149, -- Chromeshark Shredder Sunglasses
    1411150, -- Fishy Fun Cover
    1411151, -- Breezy Beachgoer Cover
    1411152, -- Ayo Maff Hat
    1411153, -- Seaside Traveler Hat
    1411154, -- Light Ninjawear Cover
    1411155, -- Season Series Cover (2026H2)
    1411156, -- S31 Cover
    -- [ MŨ / HELMET CẤP 1 (BỔ SUNG) ]
    1502001001, -- Mũ pizza nóng (Cấp 1)
    1502001002, -- Mũ thỏ trắng (Cấp 1)
    1502001003, -- Mũ Cyberpunk (Lam) (Cấp 1)
    1502001004, -- Mũ Cyberpunk (Tím) (Cấp 1)
    1502001005, -- Mũ hộp sọ (Cấp 1)
    1502001006, -- Mũ lạc quan (Cấp 1)
    1502001008, -- Mũ gà chiến thắng (Cấp 1)
    1502001009, -- Mũ NGÔI SAO NHẠC ROCK (Cấp 1)
    1502001012, -- Mũ ngân hà (Cấp 1)
    1502001013, -- Mũ gà vô địch (Cấp 1)
    1502001015, -- Mũ hoa hướng dương (Cấp 1)
    1502001016, -- Mũ khủng long phiến sừng (Cấp 1)
    1502001017, -- Mũ người cứu hộ (Cấp 1)
    1502001018, -- Mũ bí đỏ thịnh nộ (Cấp 1)
    1502001019, -- Mũ điều hướng viên (Cấp 1)
    1502001020, -- Mũ bí đỏ vui vẻ (Cấp 1)
    1502001021, -- Mũ tim sói (Cấp 1)
    1502001022, -- Mũ lava (Cấp 1)
    1502001025, -- Mũ sắt bảo hộ Bắc Cực (Cấp 1)
    1502001026, -- Mũ Yeti (Cấp 1)
    1502001027, -- Mũ gấu trúc (Cấp 1)
    1502001028, -- Mũ quái thú (Cấp 1)
    1502001029, -- Mũ ngà voi vàng (Cấp 1)
    1502001030, -- Mũ ông già Noel vui vẻ (Cấp 1)
    1502001031, -- Mũ bảo hiểm dị nhân (Cấp 1)
    1502001032, -- Mũ Xương Đỏ (Cấp 1)
    1502001033, -- Mũ du ngoạn thiên hà (Cấp 1)
    1502001034, -- Mũ Lấp La Lấp Lánh (Cấp 1)
    1502001035, -- Mũ ếch bức xạ (Cấp 1)
    1502001036, -- Mũ Thần Tình Yêu (Cấp 1)
    1502001037, -- Mũ Cảm xúc X (Cấp 1) 
    1502001038, -- Mũ bảo hiểm nhện biến hình (Cấp 1)
    1502001039, -- Mũ rồng con (Cấp 1)
    1502001040, -- Nón quân đội tinh anh (Cấp 1)
    1502001041, -- Mũ bảo hiểm chiến binh vũ trụ (Cấp 1)
    1502001042, -- Mũ sinh nhật sắc màu (Cấp 1)
    1502001043, -- Mũ Quỷ Đỏ (Cấp 1)
    1502001044, -- Mũ hoa cỏ (Cấp 1)
    1502001045, -- Mũ thỏ phục sinh (Cấp 1)
    1502001046, -- Mũ Samurai - danh dự  (Cấp 1)
    1502001047, -- Mũ Hổ Phách (Cấp 1)
    1502001048, -- Mũ Thần Mặt Trời (Cấp 1)
    1502001049, -- Mũ Du Kích (Cấp 1)
    1502001050, -- Mũ sắt (Cấp 1)
    1502001051, -- Mũ Fan cuồng bóng đá (Cấp 1)
    1502001052, -- Mũ Cáo Ác Quỷ (Cấp 1)
    1502001053, -- Mũ Arena Mùa 11(Cấp 1)
    1502001054, -- Mũ Đội trưởng Ryan (Cấp 1)
    1502001055, -- Mũ thợ săn ngọc trai (Cấp 1)
    1502001058, -- Mũ bảo hiểm Monarch (Cấp 1)
    1502001060, -- Mũ bảo hiểm nhà khảo cổ (Cấp 1)
    1502001062, -- Mũ giai điệu âm nhạc (Cấp 1)
    1502001063, -- Mũ bảo hiểm thủy triều đỏ (cấp 1)
    1502001064, -- Mũ bảo hiểm Thiên Sứ (Cấp 1)
    1502001065, -- Mũ Thỏ Ngọc (Cấp 1)
    1502001070, -- Mũ Ngôi sao (Cấp 1)
    1502001071, -- Mũ vinh quang quá khứ (Cấp 1)
    1502001072, -- Mũ Angry Bird (Cấp 1)
    1502001073, -- Mũ Vệ Binh Robot (Cấp 1)
    1502001074, -- Mũ hoa tuyết (Cấp 1)
    1502001075, -- Mũ Hải Cẩu (Cấp 1)
    1502001076, -- Mũ Giáp Sĩ Tương Lai (Cấp 1)
    1502001077, -- Mũ Chỉ Huy Chiến Trường (Cấp 1)
    1502001078, -- Mũ Ninja Sát Thủ (Cấp 1)
    1502001079, -- Mũ Hoa Sen Máu (Cấp 1)
    1502001080, -- Mũ Sên Khò Khò (Cấp 1)
    1502001081, -- Mũ Kẻ Săn Mồi (Cấp 1)
    1502001082, -- Mũ Bánh Ngọt (Cấp 1)
    1502001084, -- Mũ Đại Bàng Vàng (Cấp 1)
    1502001085, -- Mũ Cậu Vàng (Cấp 1)
    1502001086, -- Mũ Chuột Tinh Nghịch (Cấp 1)
    1502001087, -- Mũ Thợ Săn Băng Giá (Cấp 1)
    1502001088, -- Mũ Rock 'n' Roll (Cấp 1)
    1502001089, -- Mũ Gà Con (Cấp 1)
    1502001090, -- Mũ Ma Nữ Hồng (Cấp 1)
    1502001091, -- Mũ Mèo Tinh Nghịch (Cấp 1)
    1502001092, -- Mũ Rào Chắn Bầu Trời (Cấp 1)
    1502001093, -- Mũ Thẩm Phán Anubis (Cấp 1)
    1502001094, -- Mũ Dâu Tây Ngọt Ngào (Cấp 1)
    1502001096, -- Mũ Nữ Tiên Tri (Cấp 1)
    1502001097, -- Mũ Mèo Vàng (Cấp 1)
    1502001098, -- Mũ Thần Horus (Cấp 1)
    1502001099, -- Mũ Corgi (Cấp 1)
    1502001100, -- GACKT Helmet (Lv. 1)
    1502001101, -- Mũ Sắc Màu Tuổi Trẻ (Cấp 1)
    1502001102, -- Mũ Táo Thối (Cấp 1)
    1502001103, -- Mũ Gà Báo Thức (Cấp 1)
    1502001104, -- Mũ Chiến Binh Thần Thoại (Cấp 1)
    1502001105, -- Mũ Tàng Hình (Cấp 1)
    1502001106, -- Mũ Nốt Nhạc Cầu Vồng (Cấp 1)
    1502001107, -- Mũ Dải Ngân Hà (Cấp 1)
    1502001108, -- Mũ Găngxtơ (Cấp 1)
    1502001109, -- Mũ Sư Tử Hống (Cấp 1)
    1502001110, -- Mũ Cúp Danh Dự (Cấp 1)
    1502001111, -- Mũ Ác Thú (Cấp 1)
    1502001113, -- Mũ Kỳ Lân Hồng (Cấp 1)
    1502001114, -- Mũ Cơ Giáp Tím (Cấp 1)
    1502001115, -- Mũ Bọ Rùa (Cấp 1)
    1502001116, -- Mũ Cảnh Sát Hoàng Gia (Cấp 1)
    1502001119, -- Mũ Chiến Binh Dân Tộc (Cấp 1)
    1502001121, -- Mũ Bánh Ốc Quế (Cấp 1)
    1502001123, -- Mũ Gấu Ngáy Ngủ (Cấp 1)
    1502001124, -- Mũ Giáp Samurai (Cấp 1)
    1502001125, -- Mũ Sóc Chuột (Cấp 1)
    1502001126, -- Mũ Ma Nữ Gợi Cảm (Cấp 1)
    1502001127, -- Mũ Cảnh Sát Trưởng (Cấp 1)
    1502001128, -- Mũ Đấu Sĩ Kim Sư (Cấp 1)
    1502001129, -- Mũ Nữ Pháp Sư (Cấp 1)
    1502001130, -- Mũ Sĩ Quan (Cấp 1)
    1502001132, -- Mũ Lâu Đài (Cấp 1)
    1502001133, -- Mũ Bí Ngô Kinh Dị (Cấp 1)
    1502001134, -- Mũ Lân Trung Thu (Cấp 1)
    1502001135, -- Mũ Giáp Nữ Hoàng Bánh Ngọt (Cấp 1)
    1502001136, -- Mũ Chim Cánh Cụt (Cấp 1)
    1502001137, -- Mũ Gấu Tinh Nghịch (Cấp 1)
    1502001138, -- Mũ Ác Ma Mộ Huyệt (Cấp 1)
    1502001141, -- Mũ Tulip (Cấp 1)
    1502001143, -- Mũ Idol (Cấp 1)
    1502001145, -- Mũ Chú Lính Chì (Cấp 1)
    1502001146, -- Mũ Hộ Vệ Tinh Tú (Cấp 1)
    1502001149, -- Mũ Giáp Cá Koi (Cấp 1)
    1502001150, -- Mũ Sứ Giả Chính Nghĩa (Cấp 1)
    1502001151, -- Mũ Hoàng Đế Tôn Quý (Cấp 1)
    1502001154, -- Mũ Giáp Đại Bàng Tỏa Sáng (Cấp 1)
    1502001155, -- Mũ Giáp Cảnh Sát Xương Rồng (Cấp 1)
    1502001156, -- Mũ Gà Điên (Cấp 1)
    1502001157, -- Mũ Hộp Quà (Cấp 1)
    1502001159, -- Mũ Giai Điệu Yêu Thương (Cấp 1)
    1502001160, -- Mũ Tuyết Anh Đào (Cấp 1)
    1502001163, -- Mũ Hoàng Tử Ánh Kim (Cấp 1)
    1502001164, -- Mũ Chiến Binh Hồng Miêu (Cấp 1)
    1502001165, -- Mũ Giáp Chó Tuần Lộc (Cấp 1)
    1502001167, -- Mũ Giáp Xửng Hấp (Cấp 1)
    1502001169, -- Mũ Sừng Bọ Đỏ (Cấp 1)
    1502001170, -- Mũ Kỳ Lân Cầu Vồng (Cấp 1)
    1502001171, -- Mũ Thần Tượng Giới Trẻ (Cấp 1)
    1502001172, -- Mũ Bé Rồng (Cấp 1)
    1502001173, -- Mũ Cá Chép Hóa Rồng (Cấp 1)
    1502001174, -- Mũ Thành Phố Về Đêm (Cấp 1)
    1502001175, -- Mũ Vịt Vàng (Cấp 1)
    1502001177, -- Mũ Đặc Công QUACK (Cấp 1)
    1502001179, -- Mũ Rùa Điện (Cấp 1)
    1502001180, -- Chiến Thần Đột Biến (Cấp 1)
    1502001181, -- Mũ Sắc Tố Cầu Vồng (Cấp 1)
    1502001182, -- Mũ Kiến Chúa (Cấp 1)
    1502001183, -- Godzilla Helmet (Lv. 1)
    1502001184, -- Mũ Ong Chiến Binh (Cấp 1)
    1502001185, -- Mũ Ong Thợ (Cấp 1)
    1502001186, -- Mũ Lãnh Chúa Hắc Ám (Cấp 1)
    1502001187, -- Mũ Bazzi Dễ Thương (Cấp 1)
    1502001189, -- Mũ Giáp Người Bạn Hiếu Chiến (Cấp 1)
    1502001190, -- Mũ Vua Khỉ Thế Giới Ảo (Cấp 1)
    1502001191, -- Chiến Binh Ánh Sáng - Mũ (Cấp 1)
    1502001192, -- Mũ Sally (Cấp 1)
    1502001193, -- Mũ Kẻ Nổi Loạn (Cấp 1)
    1502001194, -- Mũ MECHAGODZILLA (Cấp 1)
    1502001195, -- Mũ Thần Sóng (Cấp 1)
    1502001196, -- Mũ Lãng Khách Thời Thượng (Cấp 1)
    1502001197, -- Mũ Mắt Quỷ (Cấp 1)
    1502001198, -- Mũ Giáp Hành Trình Kỳ Diệu (Cấp 1)
    1502001199, -- Mũ Chiến Thần Hợp Kim (Cấp 1)
    1502001200, -- Mũ Quái Thú San Hô (Cấp 1)
    1502001201, -- Mũ Giáp Lục Bảo (Cấp 1)
    1502001202, -- Mũ Thám Hiểm Vũ Trụ (Cấp 1)
    1502001203, -- Mũ Quái Thú Công Nghệ (Cấp 1)
    1502001204, -- Mũ BUG (Cấp 1)
    1502001205, -- Mũ Thợ Lặn Cực Hạn (Cấp 1)
    1502001207, -- Mũ Giáp Chiến Thần (Cấp 1)
    1502001209, -- Mũ Quý Ngài Rơm (Cấp 1)
    1502001210, -- Mũ Giáp Đầu Bếp Dễ Thương (Cấp 1)
    1502001211, -- Mũ Sát Thủ Thành Thị (Cấp 1)
    1502001214, -- Mũ Biên Giới Hoang Dã (Cấp 1)
    1502001217, -- Mũ Party Giáng Sinh (Cấp 1)
    1502001219, -- Mũ Giáp Bữa Cơm Gà (Cấp 1)
    1502001220, -- Mũ Trang Trí Giáng Sinh (Cấp 1)
    1502001221, -- Mũ Sát Thủ Hoàng Kim (Cấp 1)
    1502001222, -- Mũ Kỵ Binh Thần Giáp (Cấp 1)
    1502001223, -- Mũ Gốm Sứ (Cấp 1)
    1502001224, -- Mũ Xứ Sở Thần Tiên (Cấp 1)
    1502001225, -- Mũ Người Cây (Cấp 1)
    1502001227, -- Mũ giáp quang hóa (Cấp 1)
    1502001228, -- Đông Huyền Ảo - Mũ (Cấp 1)
    1502001229, -- Mũ Mèo Vui Vẻ (Cấp 1)
    1502001230, -- Mũ Rồng Công Nghệ (Cấp 1)
    1502001231, -- Mũ Công Nghệ Slime (Cấp 1)
    1502001232, -- Mũ Công Chúa Thỏ (Cấp 1)
    1502001233, -- Mũ Thỏ Mùa Đông (Cấp 1)
    1502001234, -- Mũ Gấu Hồng (Cấp 1)
    1502001235, -- Mũ Rồng Baby (Cấp 1)
    1502001236, -- Mũ Vẹt Baby (Cấp 1)
    1502001237, -- Mũ Tiểu Quỷ Ngoại Đạo (Cấp 1)
    1502001238, -- Mũ Giáp Tinh Nhuệ (Cấp 1)
    1502001239, -- Mũ Ma Pháp Huyền Thoại (Cấp 1)
    1502001241, -- Mũ Nữ Hoàng Tiệc Đêm (Cấp 1)
    1502001242, -- Gackt Moon Helmet (Lv. 1)
    1502001243, -- Mũ Giáp Mật Ong (Cấp 1)
    1502001244, -- Mũ Quái Nhân Thành Thị (Cấp 1)
    1502001246, -- Mũ Dũng Sĩ Bộ Lạc (Cấp 1)
    1502001247, -- Mũ Thời Đại Phủ Xanh (Cấp 1)
    1502001248, -- Mũ Người Mở Đường (Cấp 1)
    1502001249, -- Mũ Bẫy Ăn Thịt Người (Cấp 1)
    1502001252, -- Mũ Kẻ Phản Nghịch Dị Biến (Cấp 1)
    1502001253, -- Mũ Thợ Săn Bóng Đêm (Cấp 1)
    1502001254, -- Mũ Kẹo Gấu (Cấp 1)
    1502001255, -- Mũ Mèo Chơi Khăm (Cấp 1)
    1502001256, -- Mũ Giáp Thủ Vệ Bộ Lạc (Cấp 1)
    1502001257, -- Mũ Chạm Khắc (Cấp 1)
    1502001258, -- Mũ Baby Shark (Cấp 1)
    1502001259, -- Mũ Lễ Hội Sắc Màu (Cấp 1)
    1502001260, -- Mũ Giáp Vệ Sĩ Robot (Cấp 1)
    1502001261, -- Mũ Bá Chủ Đại Dương (Cấp 1)
    1502001263, -- Mũ Vũ Hội Huyễn Hoặc (Cấp 1)
    1502001264, -- Mũ Ét Ô Ét (Cấp 1)
    1502001265, -- Mũ Giáp Ngai Vàng Bí Ngô (Cấp 1)
    1502001267, -- Mũ Giáp Tàn Tích Huy Hoàng (Cấp 1)
    1502001268, -- Mũ Con Lừa Vui Vẻ (Cấp 1)
    1502001269, -- Mũ Vẹt Ngọt Ngào (Cấp 1)
    1502001270, -- Mũ Lời Thề Hoàng Kim (Cấp 1)
    1502001271, -- Mũ Giáp Hộ Vệ Bang Hội (Cấp 1)
    1502001272, -- Mũ Giáp Chiến Trường Cầu Vồng (Cấp 1)
    1502001273, -- Mũ Giáp Chiến Binh Bức Xạ (Cấp 1)
    1502001274, -- Mũ Hoàng Gia Sang Chảnh (Cấp 1)
    1502001275, -- Mũ Trào Lưu Cực Hạn (Cấp 1)
    1502001276, -- Mũ Vũ Công Bí Ẩn (Cấp 1)
    1502001277, -- Mũ Khỉ Bùng Nổ (Cấp 1)
    1502001278, -- Mũ Evangelion-01 (Cấp 1)
    1502001279, -- Mũ Gojek (Cấp 1)
    1502001280, -- Mũ Giáp Thỏ Ngất Ngây (Cấp 1)
    1502001284, -- Mũ Giáp Đài Phát Thanh (Cấp 1)
    1502001285, -- Mũ Giáp Đêm Của Phép Màu (Cấp 1)
    1502001286, -- Mũ Sơn Dương (Cấp 1)
    1502001287, -- Mũ Mối Tình Đầu (Cấp 1)
    1502001288, -- Mũ Giáp Hạnh Phúc Vĩnh Cửu (Cấp 1)
    1502001289, -- Mũ Giáp Rạp Chiếu Đêm (Cấp 1)
    1502001290, -- Mũ Giáp Âm Điệu Hải Tặc (Cấp 1)
    1502001292, -- Mũ Giáp Lễ Phục Hoàng Gia (Cấp 1)
    1502001293, -- Mũ Giáp Hình Bóng Tuyết (Cấp 1)
    1502001294, -- Mũ Giáp Ma Pháp Sư (Cấp 1)
    1502001295, -- Mũ Giáp Tinh Vân (Cấp 1)
    1502001297, -- Mũ Giáp Chiến Binh Khủng Long (Cấp 1)
    1502001298, -- Mũ Vương Quốc Vĩnh Hằng (Cấp 1)
    1502001299, -- Mũ Bức Màn Vũ Trụ (Cấp 1)
    1502001300, -- Mũ Giáp Samurai Cao Quý (Cấp 1)
    1502001301, -- Mũ Giáp Archon Lừng Lẫy (Cấp 1)
    1502001302, -- Mũ Giáp Mật Mã Chết Chóc (Cấp 1)
    1502001305, -- Mũ Giáp Siêu Nhân Thép (Cấp 1)
    1502001306, -- Mũ Giáp Thám Hiểm Ngân Hà (Cấp 1)
    1502001307, -- Mũ Giáp BoBoiBoy (Cấp 1)
    1502001309, -- Mũ Giáp Vườn Hoa Phù Thủy (Cấp 1)
    1502001311, -- Mũ Giáp Dơi Hút Máu (Cấp 1)
    1502001314, -- Mũ Giáp Nhà Quan Cung Đình (Cấp 1)
    1502001315, -- Mũ Giáp Thiếu Nữ Bông Tuyết (Cấp 1)
    1502001317, -- Mũ Giáp Đội Trưởng Đặc Chiến (Cấp 1)
    1502001320, -- Mũ Giáp Biểu Tượng Bóng Đá Messi (Cấp 1)
    1502001322, -- Mũ Giáp Tộc Trưởng (Cấp 1)
    1502001323, -- Mũ Giáp Nhạc Cụ Hoàng Gia (Cấp 1)
    1502001325, -- Mũ Giáp Thủy Triều (Cấp 1)
    1502001327, -- Mũ Giáp Sọ Nham Thạch (Cấp 1)
    1502001328, -- Mũ Giáp Lông Vũ Tím (Cấp 1)
    1502001330, -- Mũ Giáp Quái Thú Carton (Cấp 1)
    1502001332, -- Mũ Giáp Nổi Loạn (Cấp 1)
    1502001333, -- Mũ Giáp Lính Gác Hào Quang (Cấp 1)
    1502001335, -- Mũ Giáp Công Nghệ Tân Tiến (Cấp 1)
    1502001336, -- Mũ Giáp Hộ Vệ Rồng (Cấp 1)
    1502001337, -- Mũ Giáp Gấu Hồng (Cấp 1)
    1502001338, -- Mũ Giáp Âm Nhạc Sắc Tím (Cấp 1)
    1502001339, -- Mũ Giáp Gấu Trúc Dễ Thương (Cấp 1)
    1502001341, -- Mũ Giáp Chú Hề Vui Tính (Cấp 1)
    1502001342, -- Mũ Giáp Nữ Đế Ánh Sáng (Cấp 1)
    1502001343, -- Mũ Giáp Dưa Leo Hài Hước (Cấp 1)
    1502001344, -- Mũ Giáp Kế Hoạch Đỏ Thẫm (Cấp 1)
    1502001345, -- Mũ Giáp Cơn Bão Đỏ (Cấp 1)
    1502001346, -- Mũ Giáp Cuộc Sống Công Nghệ (Cấp 1)
    1502001347, -- Mũ Giáp Khủng Long Ngờ Nghệch (Cấp 1)
    1502001348, -- Mũ Giáp Cây ăn Thịt (Cấp 1)
    1502001349, -- Mũ Giáp Khủng Long Ephialtes (Cấp 1)
    1502001350, -- Mũ Giáp Huyết Rồng (Cấp 1)
    1502001351, -- Mũ Giáp Tử Thần Hoàng Kim (Cấp 1)
    1502001352, -- Mũ Giáp Chiến Giáp DJ (Cấp 1)
    1502001353, -- Mũ Giáp Huýt Sáo (Cấp 1)
    1502001354, -- Mũ Giáp Cap'n Feathers (Cấp 1)
    1502001355, -- Mũ Giáp Ánh Kim (Cấp 1)
    1502001357, -- Mũ Giáp Son Goku (Cấp 1)
    1502001358, -- Mũ Giáp Nữ Thần Cực Quang (Cấp 1)
    1502001359, -- Mũ Giáp Dị Nhân Ghê Rợn (Cấp 1)
    1502001360, -- Mũ Giáp Sóc Ngủ Đông (Cấp 1)
    1502001361, -- Mũ Giáp Não Zombie (Cấp 1)
    1502001362, -- Mũ Giáp Ốc Công Nghệ (Cấp 1)
    1502001363, -- Mũ Giáp Xác Sống Sinh Tồn (Cấp 1)
    1502001364, -- Mũ Giáp PMGC 2023 (Cấp 1)
    1502001365, -- Mũ Giáp Màu Đỏ Tốc Độ (Cấp 1)
    1502001366, -- RS Swagster Helmet(Lv. 1)
    1502001367, -- Mũ Hộ Vệ Vô Tận (Cấp 1)
    1502001368, -- Mũ Giáp Đầu Gỗ Giáng Sinh (Cấp 1)
    1502001369, -- Mũ Giáp Gấu Trúc Ngọt Ngào (Cấp 1)
    1502001370, -- Mũ Giáp Rồng Thời Thượng (Cấp 1)
    1502001371, -- Mũ Giáp Lân Khả Ái (Cấp 1)
    1502001372, -- Mũ Giáp Âm Thanh Đỉnh Cao (Cấp 1)
    1502001373, -- Mũ Giáp LINE FRIENDS BROWN (Cấp 1)
    1502001374, -- Mũ Giáp Hổ Vân Tinh (Cấp 1)
    1502001375, -- Mũ Giáp Gấu Ngàn Hoa (Cấp 1)
    1502001376, -- Mũ Giáp Hồ Ly Thần Bí (Cấp 1)
    1502001377, -- Mũ Giáp Bóng Ma Quyến Rũ (Cấp 1)
    1502001378, -- Mũ Giáp Hoàng Tộc Ngọt Ngào (Cấp 1)
    1502001379, -- Mũ Giáp Hộ Vệ Ánh Sáng (Cấp 1)
    1502001381, -- Mũ Giáp Hỏa Linh Chí Tôn (Cấp 1)
    1502001382, -- Mũ Giáp Phù Thủy Khả Ái (Cấp 1)
    1502001383, -- Mũ Giáp Tay Đua Gan Dạ (Cấp 1)
    1502001384, -- Mũ Giáp Tím Mộng Mơ (Cấp 1)
    1502001385, -- Mũ Chiến Sĩ Thần Giáp (Cấp 1)
    1502001386, -- Mũ Giáp Giai Điệu Mèo Con (Cấp 1)
    1502001387, -- Mũ Giáp Chuột Công Nghệ (Cấp 1)
    1502001388, -- Mũ Giáp Võ Sĩ Đảo Hoang (Cấp 1)
    1502001389, -- Mũ Giáp Thủ Lĩnh Đền Thờ (Cấp 1)
    1502001390, -- Mũ Giáp Vệ Thần Tình Ái (Cấp 1)
    1502001391, -- Mũ Giáp Quý Ông Quái Lạ (Cấp 1)
    1502001392, -- Mũ Giáp Trinh Sát Hóa Sinh (Cấp 1)
    1502001393, -- Mũ Giáp Quái Vật Âm Thanh (Cấp 1)
    1502001394, -- Mũ Giáp Nữ Đế Hắc Ám (Cấp 1)
    1502001395, -- Mũ Giáp Hầu Gái Bóng Đêm (Cấp 1)
    1502001396, -- Mũ Giáp Đại Úy Loạn Thế (Cấp 1)
    1502001397, -- Mũ Giáp Phong Linh (Cấp 1)
    1502001398, -- Mũ Giáp Sắc Đẹp Gợn Sóng (Cấp 1)
    1502001399, -- Mũ Giáp Vườn Hoa Phù Thủy (Cấp 1)
    1502001400, -- Mũ Giáp - Cá Hề Nemo (Cấp 1)
    1502001401, -- Mũ Giáp Nụ Hôn Gai (Cấp 1)
    1502001402, -- APEACH Helmet (LV.1)
    1502001403, -- Bellygom Helmet(LV.1)
    1502001404, -- Mũ Giáp Thỏ Tinh Quái (Cấp 1)
    1502001405, -- Mũ Giáp Nữ Sinh Nổi Loạn (Cấp 1)
    1502001406, -- Mũ Giáp Trái Tim Bảo Hộ (Cấp 1)
    1502001407, -- Mũ Giáp Khiên Sáng Trí Tuệ (Cấp 1)
    1502001408, -- Mũ Giáp Quỷ Diện Bóng Đêm (Cấp 1)
    1502001409, -- Mũ Giáp Chiến Giáp Quái Thú (Cấp 1)
    1502001410, -- Mũ Giáp Thủ Lĩnh Man Tộc (Cấp 1)
    1502001411, -- Mũ Giáp Phong Ấn Bảo Hộ (Cấp 1)
    1502001412, -- Mũ Giáp Khí Thân Sĩ Hắc Đạo (Cấp 1)
    1502001413, -- Mũ Giáp Bộ Tộc Ngân Hà (Cấp 1)
    1502001414, -- Mũ Giáp Chiến Binh Mùa Đông (Cấp 1)
    1502001415, -- Mũ Giáp Không Gian Đa Chiều (Cấp 1)
    1502001416, -- Mũ Giáp PMGC 2024 (Cấp 1)
    1502001417, -- Mũ Giáp Cánh Cụt Vui Vẻ (Cấp 1)
    1502001418, -- Mũ Chiến Binh Viking (Cấp 1)
    1502001419, -- Mũ Giáp Trò Đùa Xanh Lam (Cấp 1)
    1502001420, -- Mũ giáp Bóng Nước (Cấp 1)
    1502001421, -- Mũ Giáp Cá Koi Xuân Sắc (Cấp 1)
    1502001422, -- Mũ Giáp Ảo Mộng Tím (Cấp 1)
    1502001423, -- Mũ Giáp Quyền Lực Long Thần (Cấp 1)
    1502001424, -- Mũ Lam Sư Đoạt Mệnh (Cấp 1)
    1502001425, -- Mũ Giáp Vương Giả Bóng Đêm (Cấp 1)
    1502001426, -- Mũ Giáp Hoa Khả Ái (Cấp 1)
    1502001427, -- Opanchu Helmet (Lv.1)
    1502001428, -- Mũ Giáp Kị Sĩ Ma Giới (Cấp 1)
    1502001429, -- Mũ Giáp Hộ Thần Nhật Thực (Cấp 1)
    1502001430, -- Mũ Giáp Quái Vật Thư Giãn (Cấp 1)
    1502001431, -- Mũ Giáp Chiến Đấu Godzilla (Cấp 1)
    1502001432, -- Mũ Giáp Cáo Tinh Nghịch (Cấp 1)
    1502001433, -- Mũ Giáp Thỏ Hồng Tẩm Độc (Cấp 1)
    1502001434, -- Mũ Giáp Thần Binh (Cấp 1)
    1502001435, -- Mũ Giáp Thiểm Lôi Phán Vương (Cấp 1)
    1502001436, -- Mũ Cơ Thú Tinh Không (Cấp 1)
    1502001437, -- Mũ Giáp Carameow (Cấp 1)
    1502001438, -- Mũ Giáp Phản Ứng Hóa Học (Cấp 1)
    1502001440, -- Mũ Giáp Titan Búa Chiến (Cấp 1)
    1502001441, -- Mũ Giáp Cá Mập Xanh (Cấp 1)
    1502001442, -- Mũ Giáp Cô Nàng Cơ Khí (Cấp 1)
    1502001443, -- Mũ Giáp Sóng Âm Cuồng Loạn (Cấp 1)
    1502001444, -- Hero Xtreme Helmet (Lv.1)
    1502001445, -- Mũ Giáp Vệ Binh Tinh Hà (Cấp 1)
    1502001446, -- Mũ Giáp Tinh Vực (Cấp 1)
    1502001447, -- Mũ Giáp Chủ Lực Hoàng Kim (Cấp 1)
    1502001448, -- Mũ Giáp Long Thánh (Cấp 1)
    1502001449, -- Mũ Giáp Chiến Binh Tinh Tú (Cấp 1)
    1502001450, -- Mũ Giáp Cún Tinh Nghịch (Cấp 1)
    1502001451, -- Mũ Giáp Kim Vệ Thần Quân (Cấp 1)
    1502001452, -- Bbangbbang's diary Helmet(Lv.1)
    1502001453, -- 2025 Esports Helmet (Lv. 1)
    1502001454, -- Mũ Giáp Bá Tước Xương (Cấp 1)
    1502001455, -- Mũ Giáp Tiểu Yêu Nổi Loạn (Cấp 1)
    1502001456, -- Mũ Giáp Cuồng Loạn Ngọt Ngào (Cấp 1)
    1502001457, -- Mũ Giáp Kaiju No. 8 (Cấp 1)
    1502001458, -- Mũ Giáp Dạ Quang Tinh Vân (Cấp 1)
    1502001459, -- Mũ Giáp Ảo Ảnh Đô Thị (Cấp 1)
    1502001460, -- Mũ Giáp Hỏa Đinh Ba (Cấp 1)
    1502001461, -- Mũ Giáp Lung Linh (Cấp 1)
    1502001462, -- Mũ Giáp U Linh Ú Nu (Cấp 1)
    1502001463, -- Mũ Giáp Gấu Ngọt Ngào (Cấp 1)
    1502001464, -- Mũ Giáp Dũng Sĩ Tuyết Trắng (Cấp 1)
    1502001465, -- Mũ Giáp Quái Thú Sợi Len (Cấp 1)
    1502001466, -- Mũ Lông Thú Giả (Cấp 1)
    1502001467, -- Mũ Đinh Chiến Thần Bão Tuyết (Cấp 1)
    1502001468, -- Mũ Giáp Đại Tiệc Giáng Sinh (Cấp 1)
    1502001469, -- Mũ Giáp Xứ Sở Cực Địa (Cấp 1)
    1502001470, -- Mũ Giáp Tuyết Vũ (Cấp 1)
    1502001471, -- Turbo Granny(Beckoning cat) Helmet (Lv. 1)
    1502001472, -- Mũ Ngọn Lửa Địa Ngục (Cấp 1)
    1502001473, -- Mũ Giáp Ninja Hắc Vũ (Cấp 1)
    1502001474, -- Mũ Giáp Gấu Trúc May Mắn (Cấp 1)
    1502001475, -- Mũ Giáp Hoàng Xà (Cấp 1)
    1502001476, -- Mũ Giáp KO Vui Chơi (Cấp 1)
    1502001477, -- Mũ Giáp Lục Phỉ Thúy (Cấp 1)
    1502001478, -- Mũ Giáp Hoa Mộng (Cấp 1)
    1502001479, -- Mũ Giáp Cá Koi (Cấp 1)
    1502001480, -- Mũ Giáp PUBG MOBILE × aespa (Cấp 1)
    1502001481, -- CrankGuard Helmet (Lv. 1)
    1502001482, -- Mũ Giáp S28 (Cấp 1)
    1502001483, -- Mũ Giáp Chúa Hề Lém Lĩnh (Cấp 1)
    1502001484, -- Mũ Giáp Hoàng Kim (Cấp 1)
    1502001485, -- Mũ Giáp Tiên Phong Nổi Loạn (Cấp 1)
    1502001486, -- Mũ Jogo (Cấp 1)
    1502001487, -- Mũ Giáp Vùng Đất Năng Động (Cấp 1)
    1502001488, -- Mũ Giáp Sắc Màu (Cấp 1)
    1502001489, -- Mũ Giáp Hộ Vệ Duyên Dáng (Cấp 1)
    1502001490, -- Nakiri Ayame Helmet (Lv.1)
    1502001491, -- Mũ Giáp S29 (Cấp 1)
    1502001492, -- Mũ Giáp Huyễn Ảnh (Cấp 1)
    1502001493, -- Mũ Giáp Át Chủ Bài (Cấp 1)
    1502001494, -- Mũ Giáp Quý Tộc Ba Tư (Cấp 1)
    1502001495, -- Mũ BLUE LOCK (Cấp 1)
    1502001496, -- Mũ Giáp Tốc Độ Đỉnh (Cấp 1)
    1502001497, -- Mũ Giáp Song Tử (Cấp 1)
    1502001498, -- Mũ Giáp Xà Vương (Cấp 1)
    1502001499, -- Mũ Giáp Chiến Binh Huyết Vũ (Cấp 1)
    1502001500, -- Mũ Giáp Vòng Nguyệt Quế (Cấp 1)
    1502001501, -- Mũ Giáp Cuồng Chiến (Cấp 1)
    1502001502, -- Mũ Giáp Tia Chớp (Cấp 1)
    1502001503, -- Mũ Giáp Điện N
    1407990,
    1408045,
    1101102056,
    1407835,
    1400113,
    1405222,
    1953003,
    1953008,
    1953016,
    1953020,
    1953019,
    1907071,
    1907063,
    1907047,
    1902034,
    1902030,
    1901102,
    1901089,
    1901085,
    1901047,
    1901027,
    1901018,
    1405207,
    1405208
    
}

local INS_BASE = 2000000000
local PKG_SLOT = 3
local MELEE_ID = 108
local HAT_SUB = 401
local MASK_SUB = 402
local OUTFIT_SUB = 403
local PANTS_SUB = 404
local SHOES_SUB = 405
local GLASS_SUB = 407
local GLIDER_SUB = 415      
local GLOVES_SUB = 452
local GLIDER_SUBS = { [413] = true, [414] = true, [415] = true }

F.CUST_SLOT = {
    NONE = 0,
    HeadEquipemtSlot = 1,
    HairEquipemtSlot = 2,
    HatEquipemtSlot = 3,
    FaceEquipemtSlot = 4,
    ClothesEquipemtSlot = 5,
    PantsEquipemtSlot = 6,
    ShoesEquipemtSlot = 7,
    BackpackEquipemtSlot = 8,
    HelmetEquipemtSlot = 9,
    ArmorEquipemtSlot = 10,
    ParachuteEquipemtSlot = 11,
    GlassEquipemtSlot = 12,
    NightVisionEquipemtSlot = 13,
    BeardEquipemtSlot = 14,
    GlideEquipemtSlot = 15,
    HandEffectEquipemtSlot = 16,
    BackPack_PendantSlot = 17,
}
_G.CustSlotType = F.CUST_SLOT

local CHASSIS_LIGHT_SUB = 7302
local CHASSIS_LIGHT_IDS = { [7302001] = true, [7302002] = true }
local DEFAULT_CHASSIS_LIGHT = 7302002
local PARACHUTE_SUB = 701   
local DEFAULT_PARACHUTE_RES = 703001  
local TAB_SUIT = 10
local TAB_CLOTHES = 3
local PAGE_AVATAR = 1
local PAGE_VEHICLE = 6
local PAGE_PARACHUTE = 5
local HALL_THEME_TYPE = 202
local SUBTYPE_DEFAULT_TAB = {
    [401] = 1, [402] = 2, [403] = 10, [404] = 4, [405] = 5, [407] = 14,
    [501] = 15, [504] = 15, [502] = 16, [505] = 16,
}
local HAT_SUBS = { [401] = true }
local HELMET_SUBS = { [502] = true, [505] = true }
local HEAD_SUBS = { [401] = true } -- [FIX VIP] Đã xóa 502 và 505 để tách biệt hoàn toàn Mũ Bảo Hiểm khỏi Tóc/Mũ Thời Trang
local BAG_SUBS = { [501] = true, [504] = true }
local FACE_SUBS = { [402] = true, [407] = true }
local BODY_SUBS = { [404] = true, [405] = true, [501] = true, [504] = true, [502] = true, [505] = true }
local GUN_SUB = { [101]=true, [102]=true, [103]=true, [104]=true, [105]=true, [106]=true, [107]=true }
local NET_OK = NetErrorCode_NONE or "ok"

local R = { insToRes = {}, resToIns = {}, byWeapon = {} }
local _matchApplied = false

_G.AddOutfitPersist = _G.AddOutfitPersist or { path = nil, dirty = false, scheduled = false, loaded = nil, lastWritten = nil, configVehicleSlots = nil, configWeapons = nil, configSlots = nil, lobbyVehicleSubType = nil, lobbyVehicleIns = nil, lobbyVehicleResID = nil, hallThemeResID = nil, hallThemeIns = nil, configChassisLight = nil, configChassisLightMap = nil }
local PERSIST = _G.AddOutfitPersist

F.persistMarkDirty = function() end

local PERF = {
    lobbySynced     = false,
    mappingsDirty   = true,
    desiredSkins    = nil,
    skinTarget      = {},
    matchActive     = false,
    lastBootstrapAt = 0,
    wearDoneThisMatch = false,  
}
local MATCH_TICK_SEC    = 3.0
local MATCH_MAX_SEC     = 45.0
local BOOTSTRAP_COOLDOWN = 2.0
local INJECT_RETRY_MAX  = 5
local INJECT_RETRY_SEC  = 3.0

function F.lobbyState()
    _G.AddOutfitLobbyState = _G.AddOutfitLobbyState or {
        wardrobeRefreshed = false,
        reapplyScheduled  = false,
        reapplyDone       = false,
        outfitResolved    = false,
        skinResolved      = false,
        cachedOutfit      = nil,
        cachedSkin        = nil,
        injectRefreshGen  = 0,
        lobbySynced       = false,
    }
    return _G.AddOutfitLobbyState
end

local LOBBY = setmetatable({}, {
    __index = function(_, k) return F.lobbyState()[k] end,
    __newindex = function(_, k, v) F.lobbyState()[k] = v end,
})

function F.invalidateLobbyResolved()
    LOBBY.outfitResolved = false
    LOBBY.skinResolved   = false
    LOBBY.cachedOutfit   = nil
    LOBBY.cachedSkin     = nil
end

function F.perfInvalidateLobby()
    LOBBY.lobbySynced   = false
    PERF.mappingsDirty = true
    PERF.desiredSkins  = nil
    for k in pairs(PERF.skinTarget) do PERF.skinTarget[k] = nil end
    F.invalidateLobbyResolved()
end

function F.cache()
    _G.AddOutfitEquippedCache = _G.AddOutfitEquippedCache or {
        outfitRes = nil, outfitIns = nil,
        hatRes = nil, hatIns = nil,
        maskRes = nil, maskIns = nil,
        glassRes = nil, glassIns = nil,
        tshirtRes = nil, tshirtIns = nil,
        pantsRes = nil, pantsIns = nil,
        shoesRes = nil, shoesIns = nil,
        bagRes = nil, bagIns = nil,
        helmetRes = nil, helmetIns = nil,
        weapons = {},
        vehicleSlots = {},  
        hallThemeRes = nil, hallThemeIns = nil,
        parachuteRes = nil, parachuteIns = nil,
        gliderRes = nil, gliderIns = nil,
        glovesRes = nil, glovesIns = nil,
    }
    return _G.AddOutfitEquippedCache
end

function F.cfg(resID)
    if not resID or not CDataTable or not CDataTable.GetTableData then return nil end
    return CDataTable.GetTableData("Item", resID)
end

function F.subType(c)
    return c and (c.ItemSubType or c.itemSubType) or nil
end

function F.wardrobeTab(resID)
    local c = F.cfg(resID)
    return c and tonumber(c.WardrobeTab) or 0
end

function F.depotResID(v)
    return v and tonumber(v.resID or v.res_id) or nil
end

function F.resToCustSlot(resID, st)
    resID, st = tonumber(resID), tonumber(st)
    if not resID or resID <= 0 then return nil end
    st = st or F.subType(F.cfg(resID))
    if st == HAT_SUB or HAT_SUBS[st] then return F.CUST_SLOT.HatEquipemtSlot end
    if st == OUTFIT_SUB then return F.CUST_SLOT.ClothesEquipemtSlot end
    if st == PANTS_SUB then return F.CUST_SLOT.PantsEquipemtSlot end
    if st == SHOES_SUB then return F.CUST_SLOT.ShoesEquipemtSlot end
    if st == MASK_SUB then return F.CUST_SLOT.FaceEquipemtSlot end
    if st == GLASS_SUB then return F.CUST_SLOT.GlassEquipemtSlot end
    if st == GLOVES_SUB then return F.CUST_SLOT.HandEffectEquipemtSlot end
    if BAG_SUBS[st] then return F.CUST_SLOT.BackpackEquipemtSlot end
    if HELMET_SUBS[st] then return F.CUST_SLOT.HelmetEquipemtSlot end
    if F.isParachuteRes(resID) or st == PARACHUTE_SUB then return F.CUST_SLOT.ParachuteEquipemtSlot end
    if F.isGlideRes(resID) or GLIDER_SUBS[st] then return F.CUST_SLOT.GlideEquipemtSlot end
    return nil
end

function F.isSuitRes(resID)
    if F.subType(F.cfg(resID)) ~= OUTFIT_SUB then return false end
    return F.wardrobeTab(resID) ~= TAB_CLOTHES
end

function F.isTshirtRes(resID)
    return F.subType(F.cfg(resID)) == OUTFIT_SUB and F.wardrobeTab(resID) == TAB_CLOTHES
end

function F.weaponIdFromSkin(resID)
    local m = CDataTable and CDataTable.GetTableData and CDataTable.GetTableData("WeaponSkinMapping", resID)
    if not m then return nil end
    return m.WeaponID or m.WeaponId
end

function F.isValidWeaponId(weaponID)
    weaponID = tonumber(weaponID)
    if not weaponID or weaponID <= 0 then return false end
    if weaponID == MELEE_ID then return true end
    return weaponID >= 101000 and weaponID < 108000
end

function F.isValidWeaponPersistEntry(weaponID, resID)
    weaponID, resID = tonumber(weaponID), tonumber(resID)
    if not F.isValidWeaponId(weaponID) or not resID or resID <= 0 then return false end
    if weaponID == resID then return false end
    if resID >= 1800000 and resID < 1810000 then return false end
    if resID >= 1900000 and resID < 2000000 then return false end
    if F.isInjectedRes(resID) then
        local wid = tonumber(F.weaponIdFromSkin(resID))
        return wid and wid == weaponID
    end
    local wid = tonumber(F.weaponIdFromSkin(resID))
    return wid and wid == weaponID
end

function F.sanitizeConfigWeapons(wmap)
    if type(wmap) ~= "table" then return {} end
    local clean = {}
    for wid, res in pairs(wmap) do
        wid, res = tonumber(wid), tonumber(res)
        if F.isValidWeaponPersistEntry(wid, res) then clean[wid] = res end
    end
    return clean
end

function F.indexWeaponSkin(resID, insID)
    resID, insID = tonumber(resID), tonumber(insID)
    if not resID or not insID then return end
    local c = F.cfg(resID)
    local st = F.subType(c)
    if not (GUN_SUB[st] or st == MELEE_ID) then return end
    local wid = F.weaponIdFromSkin(resID)
    wid = tonumber(wid)
    if not wid or wid <= 0 then return end
    R.byWeapon[wid] = R.byWeapon[wid] or {}
    R.byWeapon[wid][resID] = insID
end

function F.isInjectedIns(ins)
    return ins and R.insToRes[tonumber(ins)] ~= nil
end

function F.isInjectedRes(res)
    return res and R.resToIns[tonumber(res)] ~= nil
end

function F.isWeaponSkinRes(resID)
    resID = tonumber(resID)
    if not resID then return false end
    local st = F.subType(F.cfg(resID))
    return GUN_SUB[st] or st == MELEE_ID
end

function F.isWeaponSkinIns(insID)
    insID = tonumber(insID)
    if not insID then return false end
    local res = R.insToRes[insID]
    return res and F.isWeaponSkinRes(res)
end

function F.cleanArmoryPollution()
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if not Arm.rsp_list then return end
        if Arm.rsp_list.install_list then
            for wid, entry in pairs(Arm.rsp_list.install_list) do
                local ins = tonumber(entry and entry.skin_id)
                if ins and not F.isWeaponSkinIns(ins) then
                    Arm.rsp_list.install_list[wid] = nil
                end
            end
        end
        if Arm.rsp_list.skin_list then
            for wid, skins in pairs(Arm.rsp_list.skin_list) do
                if type(skins) == "table" then
                    for resID in pairs(skins) do
                        if not F.isWeaponSkinRes(tonumber(resID)) then
                            skins[resID] = nil
                        end
                    end
                end
            end
        end
    end)
end

function F.depotSubType(insID, resID)
    resID = tonumber(resID) or tonumber(R.insToRes[insID])
    local st = F.subType(F.cfg(resID))
    if st then return st end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    return d and tonumber(d.itemSubType)
end

function F.tryLocalWearByIns(insID)
    insID = tonumber(insID)
    if not insID then return false end
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end -- Bỏ qua nếu tắt Mod Skin
    local resID = R.insToRes[insID]
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not resID and d then resID = tonumber(d.resID or d.res_id) end
    if not resID or resID <= 0 then return false end
    local st = F.depotSubType(insID, resID)

    local function mapLocal()
        if not R.insToRes[insID] then
            R.insToRes[insID] = resID
            R.resToIns[resID] = insID
        end
    end

    if st == GLOVES_SUB then mapLocal(); F.putOnGloves(insID) return true end
    F.clearItemExpire(d, insID, resID)
    F.ensureDepotItemValid(insID, resID)
    if F.isParachuteRes(resID) then mapLocal(); return F.putOnParachute(insID) end
    if F.isGlideRes(resID) or GLIDER_SUBS[st] then mapLocal(); return F.putOnGlider(insID) end

    if st == OUTFIT_SUB then
        mapLocal()
        if F.isSuitRes(resID) or F.wardrobeTab(resID) == TAB_SUIT then
            F.putOnOutfit(insID)
        else
            F.putOnRoleWear(insID)
        end
        return true
    end
    if st == HAT_SUB or HEAD_SUBS[st] then mapLocal(); F.putOnHat(insID) return true end
    if FACE_SUBS[st] then mapLocal(); F.putOnFaceAccessory(insID) return true end
    if BODY_SUBS[st] or HELMET_SUBS[st] then mapLocal(); F.putOnRoleWear(insID) return true end

    if not F.isInjectedIns(insID) then return false end
    if GUN_SUB[st] then
        local wid = F.weaponIdFromSkin(resID)
        if wid then F.equipWeaponSkin(wid, insID) end
        return true
    end
    if st == MELEE_ID then F.equipWeaponSkin(MELEE_ID, insID) return true end
    if F.isHallThemeRes(resID) and (F.isInjectedIns(insID) or F.isInjectedRes(resID)) then
        mapLocal()
        return F.putOnHallTheme(insID)
    end
    if F.isVehicleRes(resID) and (F.isInjectedIns(insID) or F.isInjectedRes(resID)) then
        mapLocal()
        return F.putOnVehicle(insID)
    end
    return false
end

function F.isHallThemeRes(resID)
    local c = F.cfg(tonumber(resID))
    if not c then return false end
    local t = c.ItemType or c.itemType
    return t == HALL_THEME_TYPE
end

function F.isResourcesReady(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    if not F.isInjectedRes(resID) then return true end
    local ready = false
    pcall(function()
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr and mgr.GetStateByItemID then
            local st = mgr:GetStateByItemID(resID)
            ready = st == PufferConst.ENUM_DownloadState.Done
        end
    end)
    return ready
end

function F.requestResourceDownload(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 or not F.isInjectedRes(resID) then return end
    if F.isResourcesReady(resID) then return end
    _G.AddOutfitDownloadQueued = _G.AddOutfitDownloadQueued or {}
    if _G.AddOutfitDownloadQueued[resID] then return end
    _G.AddOutfitDownloadQueued[resID] = true
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        PM.Download(PufferConst.ENUM_DownloadType.ODPAK, { resID }, "AddOutfit", function()
            _G.AddOutfitDownloadQueued[resID] = nil
        end)
    end)
end

function F.ensureInjectedResources()
    for res in pairs(R.resToIns) do
        F.requestResourceDownload(tonumber(res))
    end
end

function F.restorePufferHooks()
    pcall(function()
        local mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if mgr and _G.AddOutfitPufferOrig then
            mgr.GetStateByItemID = _G.AddOutfitPufferOrig
        end
    end)
    pcall(function()
        local PM = require("client.slua.logic.download.puffer.puffer_manager")
        if PM and _G.AddOutfitPufferGetStateOrig then
            PM.GetState = _G.AddOutfitPufferGetStateOrig
        end
    end)
    pcall(function()
        local VAC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")
        local vacImpl = VAC and VAC.__inner_impl
        if vacImpl and _G.AddOutfitVehOrigAssets then
            vacImpl.LuaIsAssetsAlreadyAvailable = _G.AddOutfitVehOrigAssets
        end
    end)
end

function F.invalidateSocialWearCache()
    local s = _G.AddOutfitSocialState
    if s then
        s.wearPatchKey, s.snapshotKey, s.fullSnapshot, s.lastHandSkin = nil, nil, nil, nil
    end
end

function F.clearWeaponEquippedMark(weaponID)
    _G.AddOutfitWeaponEquipped = _G.AddOutfitWeaponEquipped or {}
    if weaponID then
        _G.AddOutfitWeaponEquipped[tonumber(weaponID)] = nil
    else
        for k in pairs(_G.AddOutfitWeaponEquipped) do _G.AddOutfitWeaponEquipped[k] = nil end
    end
end

function F.isWeaponVisuallyEquipped(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID then return false end
    return _G.AddOutfitWeaponEquipped and _G.AddOutfitWeaponEquipped[weaponID] == insID
end

function F.saveWeaponToCache(weaponID, resID, insID)
    F.clearWeaponEquippedMark(weaponID)
    weaponID, resID, insID = tonumber(weaponID), tonumber(resID), tonumber(insID)
    if not F.isValidWeaponPersistEntry(weaponID, resID) then return end
    local cch = F.cache()
    cch.weapons[weaponID] = { resID = resID, insID = insID or 0 }
    PERSIST.configWeapons = PERSIST.configWeapons or {}
    PERSIST.configWeapons[weaponID] = resID
    _G.AddOutfitLastAppliedSkin = {}
    _matchApplied = false
    F.perfInvalidateLobby()
    F.invalidateSocialWearCache()
    F.persistMarkDirty()
    F.log("ذاكرة سكن", weaponID, "→", resID)
end

function F.cacheWeaponSkinFromIns(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or insID <= 0 then return end
    if F.isInjectedIns(insID) then
        F.saveWeaponToCache(weaponID, R.insToRes[insID], insID)
        return
    end
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        if d and d.resID and tonumber(d.resID) > 0 then
            F.saveWeaponToCache(weaponID, tonumber(d.resID), insID)
        end
    end)
end

function F.saveEquip(resID, insID)
    resID, insID = tonumber(resID), tonumber(insID)
    if not resID or not insID then return end
    local c = F.cfg(resID)
    local st = F.subType(c)
    local cch = F.cache()
    if st == OUTFIT_SUB then
        if F.wardrobeTab(resID) == TAB_CLOTHES then
            cch.tshirtRes, cch.tshirtIns = resID, insID
            _G.AddOutfitLastLobbyTshirtRes = resID
            F.persistRememberSlot("tshirt", resID)
        else
            cch.outfitRes, cch.outfitIns = resID, insID
            _G.AddOutfitLastLobbyOutfitRes = resID
            F.persistRememberSlot("outfit", resID)
            F.invalidateSocialWearCache()
        end
    elseif st == HAT_SUB then
        cch.hatRes, cch.hatIns = resID, insID
        _G.AddOutfitLastLobbyHatRes = resID
        F.persistRememberSlot("hat", resID)
    elseif st == MASK_SUB then
        cch.maskRes, cch.maskIns = resID, insID
        _G.AddOutfitLastLobbyMaskRes = resID
        F.persistRememberSlot("mask", resID)
    elseif st == GLASS_SUB then
        cch.glassRes, cch.glassIns = resID, insID
        _G.AddOutfitLastLobbyGlassRes = resID
        F.persistRememberSlot("glass", resID)
    elseif st == PANTS_SUB then
        cch.pantsRes, cch.pantsIns = resID, insID
        _G.AddOutfitLastLobbyPantsRes = resID
        F.persistRememberSlot("pants", resID)
    elseif st == SHOES_SUB then
        cch.shoesRes, cch.shoesIns = resID, insID
        _G.AddOutfitLastLobbyShoesRes = resID
        F.persistRememberSlot("shoes", resID)
    elseif BAG_SUBS[st] then
        cch.bagRes, cch.bagIns = resID, insID
        _G.AddOutfitLastLobbyBagRes = resID
        F.persistRememberSlot("bag", resID)
    elseif HELMET_SUBS[st] then
        cch.helmetRes, cch.helmetIns = resID, insID
        _G.AddOutfitLastLobbyHelmetRes = resID
        F.persistRememberSlot("helmet", resID)
    elseif st == PARACHUTE_SUB then
        cch.parachuteRes, cch.parachuteIns = resID, insID
        _G.AddOutfitLastLobbyParachuteRes = resID
        F.persistRememberSlot("parachute", resID)
    elseif F.isGlideRes(resID) then
        cch.gliderRes, cch.gliderIns = resID, insID
        _G.AddOutfitLastLobbyGliderRes = resID
        F.persistRememberSlot("glider", resID)
    elseif st == GLOVES_SUB then
        cch.glovesRes, cch.glovesIns = resID, insID
        _G.AddOutfitLastLobbyGlovesRes = resID
        F.persistRememberSlot("gloves", resID)
    elseif GUN_SUB[st] then
        local wid = F.weaponIdFromSkin(resID)
        if wid then F.saveWeaponToCache(wid, resID, insID) end
    elseif st == MELEE_ID then
        F.saveWeaponToCache(MELEE_ID, resID, insID)
    end
    _matchApplied = false
    F.perfInvalidateLobby()
    F.persistMarkDirty()
end

function F.findWornInsBySubType(st, filterFn)
    st = tonumber(st)
    if not st then return nil end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local AvatarData = require("client.logic.data.AvatarData")
    for _, ins in pairs(AvatarData.GetRoleWear()) do
        ins = tonumber(ins)
        if ins and ins > 0 then
            local d = wd:GetHallDepotItemDataByInsID(ins)
            if d and tonumber(d.itemSubType) == st then
                local res = tonumber(d.resID)
                if not filterFn or filterFn(res, d) then
                    return ins, res
                end
            end
        end
    end
    return nil
end

function F.syncHatCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(HAT_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.hatRes, cch.hatIns = tonumber(res), ins
            return
        end
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        local headIns = tonumber(bag and bag.head_show) or 0
        if headIns <= 0 then return end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(headIns) or wd:GetHallDepotItemDataByInsID(headIns)
        if not d or not d.resID or tonumber(d.resID) <= 0 then return end
        local st = tonumber(d.itemSubType or F.subType(F.cfg(d.resID)))
        if HEAD_SUBS[st] then
            cch.hatRes, cch.hatIns = tonumber(d.resID), headIns
        end
    end)
end

function F.syncFaceCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(MASK_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.maskRes, cch.maskIns = tonumber(res), ins
            _G.AddOutfitLastLobbyMaskRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(GLASS_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.glassRes, cch.glassIns = tonumber(res), ins
            _G.AddOutfitLastLobbyGlassRes = tonumber(res)
        end
    end)
end

function F.syncBodyCacheFromLobby()
    local cch = F.cache()
    pcall(function()
        local ins, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.wardrobeTab(r) == TAB_CLOTHES end)
        if ins and res and tonumber(res) > 0 then
            cch.tshirtRes, cch.tshirtIns = tonumber(res), ins
            _G.AddOutfitLastLobbyTshirtRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(PANTS_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.pantsRes, cch.pantsIns = tonumber(res), ins
            _G.AddOutfitLastLobbyPantsRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(SHOES_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.shoesRes, cch.shoesIns = tonumber(res), ins
            _G.AddOutfitLastLobbyShoesRes = tonumber(res)
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(GLOVES_SUB)
        if ins and res and tonumber(res) > 0 then
            cch.glovesRes, cch.glovesIns = tonumber(res), ins
            _G.AddOutfitLastLobbyGlovesRes = tonumber(res)
        end
    end)
    pcall(function()
        for st in pairs(BAG_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res and tonumber(res) > 0 then
                cch.bagRes, cch.bagIns = tonumber(res), ins
                _G.AddOutfitLastLobbyBagRes = tonumber(res)
                break
            end
        end
    end)
    pcall(function()
        for st in pairs(HELMET_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res and tonumber(res) > 0 then
                cch.helmetRes, cch.helmetIns = tonumber(res), ins
                _G.AddOutfitLastLobbyHelmetRes = tonumber(res)
                break
            end
        end
    end)
    pcall(function()
        local ins, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isSuitRes(r) end)
        if ins and res and tonumber(res) > 0 then
            cch.outfitRes, cch.outfitIns = tonumber(res), ins
            _G.AddOutfitLastLobbyOutfitRes = tonumber(res)
        end
    end)
end

function F.syncAirborneCacheFromLobby(saveToConfig)
    local cch = F.cache()
    local cfgPara = tonumber(PERSIST.configSlots and PERSIST.configSlots.parachute)
    local cfgGlide = tonumber(PERSIST.configSlots and PERSIST.configSlots.glider)
    local changed = false

    local function maybeSave(slotName, res)
        if not saveToConfig or not res or res <= 0 then return end
        if slotName == "parachute" and res == DEFAULT_PARACHUTE_RES
            and cfgPara and cfgPara > 0 and cfgPara ~= DEFAULT_PARACHUTE_RES then
            return
        end
        F.persistRememberSlot(slotName, res)
        changed = true
    end

    local function applyPara(res, ins)
        res, ins = tonumber(res), tonumber(ins)
        if not res or not ins or not F.isParachuteRes(res) then return end
        if cfgPara and cfgPara > 0 and not saveToConfig then
            if res == cfgPara then cch.parachuteIns = ins end
            return
        end
        if res == DEFAULT_PARACHUTE_RES and not saveToConfig then return end
        if cch.parachuteRes ~= res or cch.parachuteIns ~= ins then
            cch.parachuteRes, cch.parachuteIns = res, ins
            _G.AddOutfitLastLobbyParachuteRes = res
            maybeSave("parachute", res)
        end
    end

    local function applyGlide(res, ins)
        res, ins = tonumber(res), tonumber(ins)
        if not res or not ins or not F.isGlideRes(res) then return end
        if cfgGlide and cfgGlide > 0 and not saveToConfig then
            if res == cfgGlide then cch.gliderIns = ins end
            return
        end
        if cch.gliderRes ~= res or cch.gliderIns ~= ins then
            cch.gliderRes, cch.gliderIns = res, ins
            _G.AddOutfitLastLobbyGliderRes = res
            maybeSave("glider", res)
        end
    end

    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local paraIns = tonumber(fbd.GetParachute and fbd:GetParachute()) or 0
        if paraIns > 0 then
            local d = wd:GetValidHallDepotItemDataByInsID(paraIns) or wd:GetHallDepotItemDataByInsID(paraIns)
            applyPara(d and tonumber(d.resID), paraIns)
        end
        local glideIns = tonumber(fbd.GetAircraftOrGliding and fbd:GetAircraftOrGliding()) or 0
        if glideIns > 0 then
            local d = wd:GetValidHallDepotItemDataByInsID(glideIns) or wd:GetHallDepotItemDataByInsID(glideIns)
            applyGlide(d and tonumber(d.resID), glideIns)
        end
    end)
    pcall(function()
        for st in pairs(GLIDER_SUBS) do
            local ins, res = F.findWornInsBySubType(st)
            if ins and res then applyGlide(res, ins) break end
        end
        local ins, res = F.findWornInsBySubType(PARACHUTE_SUB)
        if ins and res then applyPara(res, ins) end
    end)
    if changed then F.persistMarkDirty() end
end

function F.syncWeaponCacheFromLobby(force)
    if LOBBY.lobbySynced and not force then return end
    LOBBY.lobbySynced = true
    PERF.mappingsDirty = true
    PERF.desiredSkins = nil
    for k in pairs(PERF.skinTarget) do PERF.skinTarget[k] = nil end
    local cch = F.cache()
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        if bag and bag.weapon_skin_list then
            for weaponID, entry in pairs(bag.weapon_skin_list) do
                weaponID = tonumber(weaponID)
                local insID = tonumber(entry and (entry.skin_id or entry.skinId)) or 0
                if weaponID and weaponID > 0 and insID > 0 then
                    local res
                    if F.isInjectedIns(insID) then
                        res = tonumber(R.insToRes[insID])
                    else
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(insID)
                            or wd:GetHallDepotItemDataByInsID(insID)
                        res = d and tonumber(d.resID)
                    end
                    if res and res > 0 and F.isValidWeaponPersistEntry(weaponID, res) then
                        cch.weapons[weaponID] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end)
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if Arm.rsp_list and Arm.rsp_list.install_list then
            for weaponID, entry in pairs(Arm.rsp_list.install_list) do
                weaponID = tonumber(weaponID)
                local insID = tonumber(entry and entry.skin_id) or 0
                if weaponID and weaponID > 0 and insID > 0 then
                    local res
                    if F.isInjectedIns(insID) then
                        res = tonumber(R.insToRes[insID])
                    else
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(insID)
                            or wd:GetHallDepotItemDataByInsID(insID)
                        res = d and tonumber(d.resID)
                    end
                    if res and res > 0 and F.isValidWeaponPersistEntry(weaponID, res) then
                        cch.weapons[weaponID] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end)
    F.syncHatCacheFromLobby()
    F.syncFaceCacheFromLobby()
    F.syncBodyCacheFromLobby()
end

function F.getCachedWeaponSkin(weaponID)
    weaponID = tonumber(weaponID) or 0
    if weaponID <= 0 then return nil end
    F.syncWeaponCacheFromLobby()
    local w = F.cache().weapons[weaponID]
    if w and w.resID and w.resID > 0 then return w.resID end
    return nil
end

function F.getMatchWeaponSkin(weaponID)
    weaponID = tonumber(weaponID) or 0
    local fromCache = F.getCachedWeaponSkin(weaponID)
    if fromCache then return fromCache end
    if MATCH_CONFIG.weaponSkins then
        local fixed = tonumber(MATCH_CONFIG.weaponSkins[weaponID])
        if fixed and fixed > 0 then return fixed end
    end
    return nil
end

function F.removeRoleWearBySubType(st, filterFn)
    st = tonumber(st)
    if not st then return end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local AvatarData = require("client.logic.data.AvatarData")
    for _, ins in pairs(AvatarData.GetRoleWear()) do
        ins = tonumber(ins)
        if ins and ins > 0 then
            local d = wd:GetHallDepotItemDataByInsID(ins)
            if d and tonumber(d.itemSubType) == st then
                local res = tonumber(d.resID)
                if not filterFn or filterFn(res, d) then
                    AvatarData.RemoveRoleWearDataByValue(ins)
                end
            end
        end
    end
end

function F.syncFashionBagRolewear()
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fbd:SaveRolewearToFashionBag(fbd:GetFashionBagUseIndex())
    end)
end

local _ticker
pcall(function() _ticker = require("common.time_ticker") end)
function F.later(sec, fn)
    if _G.SetTimer then pcall(_G.SetTimer, sec, fn) return end
    if _ticker and _ticker.AddTimer then pcall(_ticker.AddTimer, sec, fn) end
end

function F.getPC()
    if slua_GameFrontendHUD then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    local ok, gd = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and gd then
        local pc = gd.GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    return nil
end

function F.syncVehicleSlotsToDataMgr()
    local cch = F.cache()
    DataMgr.VehicleSlotList = DataMgr.VehicleSlotList or {}
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        local arr = DataMgr.VehicleSlotList[subType]
        if not arr then arr = {}; DataMgr.VehicleSlotList[subType] = arr end
        for k in pairs(arr) do arr[k] = nil end
        for idx, e in pairs(slots or {}) do
            if e and tonumber(e.insID) and tonumber(e.insID) > 0 then
                arr[tonumber(idx)] = tonumber(e.insID)
            end
        end
    end
end

function F.mergeInjectedIntoVehicleSlotList(serverList)
    serverList = serverList or {}
    local cch = F.cache()
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        subType = tonumber(subType)
        if subType and type(slots) == "table" then
            local arr = serverList[subType]
            if not arr then arr = {}; serverList[subType] = arr end
            for idx, e in pairs(slots) do
                idx = tonumber(idx)
                local insID = e and tonumber(e.insID)
                if idx and insID and insID > 0 and F.isInjectedIns(insID) then
                    arr[idx] = insID
                end
            end
        end
    end
    local cfg = PERSIST.configVehicleSlots
    if cfg then
        for subType, slotMap in pairs(cfg) do
            subType = tonumber(subType)
            if subType and type(slotMap) == "table" then
                local arr = serverList[subType]
                if not arr then arr = {}; serverList[subType] = arr end
                for idx, res in pairs(slotMap) do
                    idx, res = tonumber(idx), tonumber(res)
                    local ins = res and R.resToIns[res]
                    if idx and ins and F.isInjectedIns(ins) then
                        arr[idx] = ins
                    end
                end
            end
        end
    end
    return serverList
end

function F.applyVehicleSlotsFromConfigMap(slotMap)
    if not slotMap or not next(slotMap) then return false end
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    local any = false
    for subType, slots in pairs(slotMap) do
        subType = tonumber(subType)
        if subType then
            cch.vehicleSlots[subType] = cch.vehicleSlots[subType] or {}
            for idx, res in pairs(slots) do
                idx, res = tonumber(idx), tonumber(res)
                local ins = res and R.resToIns[res]
                if idx and ins then
                    cch.vehicleSlots[subType][idx] = { resID = res, insID = ins }
                    any = true
                end
            end
        end
    end
    return any
end

function F.notifyVehicleSlotUI()
    pcall(function()
        local WRH = require("client.network.Protocol.WardrobeNewHandler")
        WRH.on_depot_modify_combat_vehicle_rsp(0, DataMgr.VehicleSlotList or {})
    end)
end

function F.mergeInjectedVehicleSkinTable(serverTable)
    serverTable = serverTable or {}
    local cfg = PERSIST.configVehicleSlots
    if not cfg then return serverTable end
    for subType, slotMap in pairs(cfg) do
        subType = tonumber(subType)
        if subType and type(slotMap) == "table" then
            local res = tonumber(slotMap[1] or slotMap["1"])
            local ins = res and R.resToIns[res]
            if ins and F.isInjectedIns(ins) then
                serverTable[subType] = ins
            end
        end
    end
    local cch = F.cache()
    for subType, slots in pairs(cch.vehicleSlots or {}) do
        subType = tonumber(subType)
        local e = slots and (slots[1] or slots["1"])
        local insID = e and tonumber(e.insID)
        if subType and insID and insID > 0 and F.isInjectedIns(insID) then
            serverTable[subType] = insID
        end
    end
    return serverTable
end

function F.equipVehicleTypesFromConfig(slotMap)
    slotMap = slotMap or PERSIST.configVehicleSlots
    if not slotMap or not next(slotMap) then return false end
    DataMgr.vehicleSkinInsIDTable = DataMgr.vehicleSkinInsIDTable or {}
    local subTypes = {}
    for st in pairs(slotMap) do
        local n = tonumber(st)
        if n then subTypes[#subTypes + 1] = n end
    end
    table.sort(subTypes)
    local any, lobbyRes, lobbyIns = false, nil, nil
    for _, subType in ipairs(subTypes) do
        local slots = slotMap[subType] or slotMap[tostring(subType)]
        if type(slots) == "table" then
            local res = tonumber(slots[1] or slots["1"])
            local ins = res and R.resToIns[res]
            if ins and F.isInjectedIns(ins) then
                DataMgr.vehicleSkinInsIDTable[subType] = ins
                any = true
                if not lobbyIns then
                    lobbyRes, lobbyIns = res, ins
                end
            end
        end
    end
    if any then
        pcall(function()
            local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
            TabSurveillance.VehicleChange()
        end)
    end
    return any, lobbyRes, lobbyIns
end

function F.applyLobbyVehicleDisplay(resID, insID, showVehicle)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or insID <= 0 then return end
    _G.AddOutfitApplyingConfig = true
    pcall(function() DataMgr.vst_skin = insID end)
    pcall(function()
        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
        HallThemeUtils.ProcPutOnVehicle({ res_id = resID, instid = insID }, showVehicle ~= false)
    end)
    pcall(F.applyVehicleSkinsToPC)
    _G.AddOutfitApplyingConfig = false
end

function F.setLobbyVehicleManual(subType, resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    subType = tonumber(subType)
    if not insID then return end
    if F.isChassisLightId(resID) or subType == CHASSIS_LIGHT_SUB then return end
    if resID and not F.isVehicleRes(resID) then return end
    if not F.isInjectedIns(insID) and not F.isVehicleRes(resID) then return end
    if not resID then resID = R.insToRes[insID] end
    if not subType and resID then subType = tonumber(F.vehicleSubType(resID)) end
    _G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or {}
    _G.AddOutfitLobbyVeh.manual = true
    _G.AddOutfitLobbyVeh.subType = subType
    _G.AddOutfitLobbyVeh.resID = resID
    _G.AddOutfitLobbyVeh.insID = insID
    PERSIST.lobbyVehicleSubType = subType
    PERSIST.lobbyVehicleIns = insID
    PERSIST.lobbyVehicleResID = resID
    F.persistMarkDirty()
end

function F.resolveLobbyVehicle(slotMap)
    slotMap = slotMap or PERSIST.configVehicleSlots
    local L = _G.AddOutfitLobbyVeh or {}
    local st = tonumber(PERSIST.lobbyVehicleSubType) or tonumber(L.subType)
    local res = tonumber(PERSIST.lobbyVehicleResID) or tonumber(L.resID)
    if res and res > 0 then
        local ins = R.resToIns[res]
        if ins then
            if not st then st = tonumber(F.vehicleSubType(res)) end
            return res, ins, st
        end
    end
    local ins = tonumber(PERSIST.lobbyVehicleIns) or tonumber(L.insID)
    if ins and F.isInjectedIns(ins) then
        res = R.insToRes[ins] or res
        if not st and res then st = tonumber(F.vehicleSubType(res)) end
        return res, ins, st
    end
    if st and slotMap then
        local slots = slotMap[st] or slotMap[tostring(st)]
        local res = slots and tonumber(slots[1] or slots["1"])
        ins = res and R.resToIns[res]
        if ins then return res, ins, st end
    end
    local subTypes = {}
    for s in pairs(slotMap or {}) do
        local n = tonumber(s)
        if n then subTypes[#subTypes + 1] = n end
    end
    table.sort(subTypes)
    if subTypes[1] then
        st = subTypes[1]
        local slots = slotMap[st] or slotMap[tostring(st)]
        local res = slots and tonumber(slots[1] or slots["1"])
        ins = res and R.resToIns[res]
        if ins then return res, ins, st end
    end
    return nil, nil, nil
end

function F.syncLobbyVehicleResFromIns()
    if PERSIST.lobbyVehicleResID and PERSIST.lobbyVehicleResID > 0 then return end
    local ins = tonumber(PERSIST.lobbyVehicleIns)
    if ins and R.insToRes[ins] then
        PERSIST.lobbyVehicleResID = R.insToRes[ins]
        F.persistMarkDirty()
    end
end

function F.hasExplicitLobbyVehicle()
    local res = tonumber(PERSIST.lobbyVehicleResID)
    local st = tonumber(PERSIST.lobbyVehicleSubType)
    if F.isChassisLightId(res) or st == CHASSIS_LIGHT_SUB then return false end
    if res and res > 0 and not F.isVehicleRes(res) then return false end
    if res and res > 0 then return true end
    if (tonumber(PERSIST.lobbyVehicleIns) or 0) > 0 then return true end
    local L = _G.AddOutfitLobbyVeh
    if L and L.manual and ((tonumber(L.resID) or 0) > 0 or (tonumber(L.insID) or 0) > 0) then return true end
    return false
end

function F.shouldApplyLobbyFromConfig(silent)
    if not F.hasExplicitLobbyVehicle() then return false end
    local _, lobbyIns = F.resolveLobbyVehicle(PERSIST.configVehicleSlots)
    if not lobbyIns then return false end
    local cur = tonumber(DataMgr.vst_skin)
    if cur == lobbyIns then return false end
    return true
end

function F.reapplyVehicleSlotsFromConfig(silent)
    local slotMap = PERSIST.configVehicleSlots
    if not slotMap or not next(slotMap) then return false end
    if not F.applyVehicleSlotsFromConfigMap(slotMap) then return false end
    F.syncVehicleSlotsToDataMgr()
    F.notifyVehicleSlotUI()
    F.equipVehicleTypesFromConfig(slotMap)
    if F.shouldApplyLobbyFromConfig(silent) then
        local lobbyRes, lobbyIns = F.resolveLobbyVehicle(slotMap)
        if lobbyIns then
            F.applyLobbyVehicleDisplay(lobbyRes, lobbyIns, not silent)
        elseif not silent then
            pcall(F.applyVehicleSkinsToPC)
            F.perfInvalidateLobby()
        end
    end
    return true
end

function F.applyHallThemeDisplay(resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or not resID then return false end
    if not F.isInjectedIns(insID) then return false end
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return false
    end
    _G.AddOutfitApplyingTheme = true
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        HT.ProcPutOnHallTheme({ res_id = resID, instid = insID }, nil)
    end)
    _G.AddOutfitApplyingTheme = false
    local cch = F.cache()
    cch.hallThemeRes, cch.hallThemeIns = resID, insID
    return true
end

function F.setHallThemeManual(resID, insID)
    insID = tonumber(insID)
    resID = tonumber(resID)
    if not insID or not F.isInjectedIns(insID) then return end
    if not resID then resID = R.insToRes[insID] end
    _G.AddOutfitLobbyTheme = _G.AddOutfitLobbyTheme or {}
    _G.AddOutfitLobbyTheme.manual = true
    _G.AddOutfitLobbyTheme.resID = resID
    _G.AddOutfitLobbyTheme.insID = insID
    PERSIST.hallThemeResID = resID
    PERSIST.hallThemeIns = insID
    local cch = F.cache()
    cch.hallThemeRes, cch.hallThemeIns = resID, insID
    F.persistMarkDirty()
end

function F.resolveHallTheme()
    local L = _G.AddOutfitLobbyTheme or {}
    local res = tonumber(PERSIST.hallThemeResID) or tonumber(L.resID)
    if res and R.resToIns[res] then return res, R.resToIns[res] end
    local ins = tonumber(PERSIST.hallThemeIns) or tonumber(L.insID)
    if ins and F.isInjectedIns(ins) then return R.insToRes[ins], ins end
    return nil, nil
end

function F.shouldApplyHallThemeFromConfig(silent)
    local _, ins = F.resolveHallTheme()
    if not ins then return false end
    local cur = nil
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        cur = tonumber(HT.GetThemeInstId())
    end)
    if cur == ins then return false end
    if _G.AddOutfitLobbyTheme and _G.AddOutfitLobbyTheme.manual then return true end
    if silent and cur and cur > 0 and F.isInjectedIns(cur) then return false end
    return true
end

function F.putOnHallTheme(insID)
    insID = tonumber(insID)
    if not insID or not F.isInjectedIns(insID) then return false end
    local resID = R.insToRes[insID]
    if F.applyHallThemeDisplay(resID, insID) then
        F.setHallThemeManual(resID, insID)
        return true
    end
    return false
end

function F.reapplyHallThemeFromConfig(silent)
    if not F.shouldApplyHallThemeFromConfig(silent) then return false end
    local res, ins = F.resolveHallTheme()
    if not res or not ins then return false end
    return F.applyHallThemeDisplay(res, ins)
end

function F.syncVehicleCacheFromDataMgr()
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    for subType, slots in pairs(DataMgr.VehicleSlotList or {}) do
        subType = tonumber(subType)
        if subType and type(slots) == "table" then
            cch.vehicleSlots[subType] = cch.vehicleSlots[subType] or {}
            for idx, insID in pairs(slots) do
                idx, insID = tonumber(idx), tonumber(insID)
                if idx and insID and insID > 0 then
                    local res = R.insToRes[insID]
                    if not res then
                        pcall(function()
                            local d = wd:GetHallDepotItemDataByInsID(insID)
                            res = d and tonumber(d.resID)
                        end)
                    end
                    if res and res > 0 then
                        cch.vehicleSlots[subType][idx] = { resID = res, insID = insID }
                    end
                end
            end
        end
    end
end

function F.vehicleSubType(resID)
    local c = F.cfg(resID)
    return c and (c.ItemSubType or c.itemSubType)
end

function F.modifyInjectedVehicleSlot(insID, slotIndex, equip)
    insID = tonumber(insID)
    slotIndex = tonumber(slotIndex)
    if not insID or not slotIndex then return false end
    local resID = R.insToRes[insID]
    if not resID and insID >= INS_BASE then
        pcall(function()
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            resID = d and tonumber(d.resID or d.res_id)
        end)
    end
    if not resID then return false end
    local st = F.vehicleSubType(resID)
    if not st or tonumber(st) < 900 then return false end
    local cch = F.cache()
    cch.vehicleSlots = cch.vehicleSlots or {}
    cch.vehicleSlots[st] = cch.vehicleSlots[st] or {}
    if equip then
        for _, slots in pairs(cch.vehicleSlots) do
            for i, e in pairs(slots) do
                if e and tonumber(e.insID) == insID then slots[i] = nil end
            end
        end
        cch.vehicleSlots[st][slotIndex] = { resID = resID, insID = insID }
        PERSIST.configVehicleSlots = PERSIST.configVehicleSlots or {}
        PERSIST.configVehicleSlots[st] = PERSIST.configVehicleSlots[st] or {}
        PERSIST.configVehicleSlots[st][slotIndex] = resID
    else
        local e = cch.vehicleSlots[st][slotIndex]
        if e and tonumber(e.insID) == insID then
            cch.vehicleSlots[st][slotIndex] = nil
            if PERSIST.configVehicleSlots and PERSIST.configVehicleSlots[st] then
                PERSIST.configVehicleSlots[st][slotIndex] = nil
            end
        end
    end
    F.syncVehicleSlotsToDataMgr()
    if equip and slotIndex == 1 then
        DataMgr.vehicleSkinInsIDTable = DataMgr.vehicleSkinInsIDTable or {}
        DataMgr.vehicleSkinInsIDTable[st] = insID
        pcall(function()
            local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
            TabSurveillance.VehicleChange()
        end)
    end
    F.persistMarkDirty()
    F.notifyVehicleSlotUI()
    return true
end

function F.buildVstInBattleFromSlots()
    local vst = {}
    local function insToRes(insID)
        insID = tonumber(insID)
        if not insID or insID <= 0 then return nil end
        local res = R.insToRes[insID]
        if res and res > 0 then return res end
        pcall(function()
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            res = d and tonumber(d.resID)
        end)
        if res and res > 0 then return res end
        if insID >= 1000000 and F.cfg(insID) then return insID end
        return nil
    end
    local function fillFromSlots(subType, slots)
        subType = tonumber(subType)
        if not subType or type(slots) ~= "table" then return end
        local resList = {}
        for idx = 1, 8 do
            local val = slots[idx] or slots[tostring(idx)]
            local res = insToRes(val)
            if not res and type(val) == "table" then
                res = tonumber(val.resID or val.res_id)
            end
            if res and res > 0 then resList[#resList + 1] = res end
        end
        if #resList > 0 then vst[subType] = resList end
    end
    for subType, slots in pairs(DataMgr.VehicleSlotList or {}) do
        fillFromSlots(subType, slots)
    end
    if not next(vst) then
        local cch = F.cache()
        for subType, slots in pairs(cch.vehicleSlots or {}) do
            local resList = {}
            for idx = 1, 8 do
                local e = slots[idx]
                local res = e and tonumber(e.resID)
                if res and res > 0 then resList[#resList + 1] = res end
            end
            if #resList > 0 then vst[tonumber(subType)] = resList end
        end
    end
    if not next(vst) then
        local bySub = {}
        for res, _ in pairs(R.resToIns) do
            res = tonumber(res)
            local c = F.cfg(res)
            local st = c and tonumber(F.subType(c))
            if res and st and st >= 900 then
                bySub[st] = bySub[st] or {}
                bySub[st][#bySub[st] + 1] = res
            end
        end
        for st, list in pairs(bySub) do
            table.sort(list)
            vst[st] = list
        end
    end
    return vst
end

function F.isVehicleSkinAllowed(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    if F.isInjectedRes(skinId) then return true end
    for _, list in pairs(F.buildVstInBattleFromSlots()) do
        for _, res in ipairs(list) do
            if tonumber(res) == skinId then return true end
        end
    end
    if R.resToIns[skinId] then
        local c = F.cfg(skinId)
        local st = F.subType(c)
        if st and tonumber(st) >= 900 then return true end
    end
    return false
end

function F.isSkinInVehiclePCList(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    local pc = F.getPC()
    if not slua.isValid(pc) or not pc.VehicleAvatarSkinList then return false end
    local UAvatarUtils = import("AvatarUtils")
    local shape = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
    if shape and shape >= 0 then
        local entry = pc.VehicleAvatarSkinList:Get(shape)
        if entry and entry.SkinList then
            for _, id in pairs(entry.SkinList) do
                if tonumber(id) == skinId then return true end
            end
        end
    end
    return false
end

function F.shouldHandleVehicleSkinClick(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    return F.isVehicleSkinAllowed(resID) or F.isSkinInVehiclePCList(resID)
end

function F.getMatchVehicle()
    local found = nil
    pcall(function()
        local subs = SubsystemMgr:Get("VehicleControlUISubSystem")
        if subs and subs.GetVehicleUserComponent then
            local uuc = subs:GetVehicleUserComponent()
            if slua.isValid(uuc) and slua.isValid(uuc.Vehicle) then found = uuc.Vehicle end
        end
    end)
    if slua.isValid(found) then return found end
    local pc = F.getPC()
    if slua.isValid(pc) and pc.GetPlayerCharacterSafety then
        local char = pc:GetPlayerCharacterSafety()
        if slua.isValid(char) then
            if char.GetCurrentVehicle then
                local v = char:GetCurrentVehicle()
                if slua.isValid(v) then return v end
            end
            if char.CurrentVehicle and slua.isValid(char.CurrentVehicle) then
                return char.CurrentVehicle
            end
        end
    end
    return nil
end

function F.applyClientVehicleSkin(skinId, vehicle, pc)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    pc = pc or F.getPC()
    vehicle = vehicle or F.getMatchVehicle()
    if not slua.isValid(vehicle) then return false end

    local UAvatarUtils = import("AvatarUtils")
    pcall(function()
        if slua.isValid(pc) then
            pc.ShowVehicleSkin = skinId
            local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
            if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
                pc.VehicleAvatarList:Add(shapeType, skinId)
            end
        end
    end)

    local applied = false
    local av = nil
    pcall(function()
        if vehicle.GetAvatarComponent then av = vehicle:GetAvatarComponent() end
        if not slua.isValid(av) then av = vehicle.VehicleAvatarComponent_BP end
    end)

    if slua.isValid(av) then
        pcall(function() if av.bIsLobbyAvatar ~= nil then av.bIsLobbyAvatar = false end end)
        pcall(function() if av.CanChangeAvatar ~= nil then av.CanChangeAvatar = true end end)
        pcall(function()
            if slua.isValid(pc) and av.SetVehicleNetAvatarData then
                av:SetVehicleNetAvatarData(pc)
            end
        end)
        pcall(function()
            if av.ChangeItemAvatar then
                av:ChangeItemAvatar(skinId, false)
                applied = true
            elseif av.PreChangeVehicleAvatar then
                av:PreChangeVehicleAvatar(skinId)
                applied = true
            end
        end)
        pcall(function()
            if av.PostChangeItemAvatar then av:PostChangeItemAvatar(false) end
        end)
    end

    pcall(function()
        local battleCls = import("VehicleAvatarComponentBattleBase")
        local battleAv = vehicle:GetComponentByClass(battleCls)
        if slua.isValid(battleAv) then
            if battleAv.ChangeVehicleAvatar then
                battleAv:ChangeVehicleAvatar(skinId, false)
                applied = true
            end
            pcall(function()
                local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
                local uid = pc and pc.PlayerUID or 0
                local bTire = VehiclePlateLicenseUtil.NeedOpenHighTire(tonumber(uid), skinId)
                if battleAv.PreChangeHighTireLight then
                    battleAv:PreChangeHighTireLight(skinId, bTire)
                end
            end)
        end
    end)

    pcall(function()
        if vehicle.ChangeVehicleAvatar and slua.isValid(pc) then
            vehicle:ChangeVehicleAvatar(pc)
            applied = true
        end
    end)

    pcall(function() if vehicle.ForceNetUpdate then vehicle:ForceNetUpdate() end end)
    pcall(function() if slua.isValid(pc) and pc.ForceNetUpdate then pc:ForceNetUpdate() end end)
    return applied
end

function F.getVehicleSkinIds()
    local out, seen = {}, {}
    local function add(res)
        res = tonumber(res)
        if res and res > 0 and not seen[res] then
            seen[res] = true
            out[#out + 1] = res
        end
    end
    for _, list in pairs(F.buildVstInBattleFromSlots()) do
        for _, res in ipairs(list) do add(res) end
    end
    for res in pairs(R.resToIns) do
        local c = F.cfg(tonumber(res))
        local st = c and tonumber(F.subType(c))
        if st and st >= 900 then add(res) end
    end
    return out
end

function F.buildVehVst(skinIds)
    local bySub = {}
    for _, skinId in ipairs(skinIds or {}) do
        local subType = 961
        local ok, c = pcall(function() return CDataTable.GetTableData("Item", skinId) end)
        if ok and c and c.ItemSubType then subType = c.ItemSubType end
        bySub[subType] = bySub[subType] or {}
        bySub[subType][#bySub[subType] + 1] = skinId
    end
    return bySub
end

function F.directInjectVehicleSkinList(pc, skinIds)
    if not slua.isValid(pc) or not pc.VehicleAvatarSkinList then return end
    local UAvatarUtils = import("AvatarUtils")
    for _, skinId in ipairs(skinIds or {}) do
        local shapeType = nil
        pcall(function() shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId) end)
        if shapeType and shapeType >= 0 then
            pcall(function() pc.VehicleAvatarList:Add(shapeType, skinId) end)
            local entry = pc.VehicleAvatarSkinList:Get(shapeType)
            if entry and entry.SkinList then
                pcall(function() entry.SkinList:Add(skinId) end)
            end
        end
    end
end

function F.mergeVstIntoPlayerInfo(playerInfo)
    if not playerInfo then return end
    F.syncVehicleCacheFromDataMgr()
    local vst = F.buildVehVst(F.getVehicleSkinIds())
    if not next(vst) then return end
    playerInfo.vst_in_battle = playerInfo.vst_in_battle or {}
    for subType, list in pairs(vst) do
        playerInfo.vst_in_battle[subType] = list
    end
    local first
    for _, list in pairs(vst) do first = list[1]; break end
    if first and first > 0 then playerInfo.vst_skin = first end
end

function F.applyVehicleSkinsToPC(pc)
    pc = pc or F.getPC()
    if not slua.isValid(pc) then return false end
    local skinIds = F.getVehicleSkinIds()
    if #skinIds == 0 then return false end
    local vst = F.buildVehVst(skinIds)
    local avatarList, avatarSkinList = {}, {}
    for _, skinList in pairs(vst) do
        local itemArray = {}
        for _, resid in ipairs(skinList) do
            if resid and resid > 0 then
                itemArray[#itemArray + 1] = { ItemTableID = resid, Count = 1 }
                avatarList[#avatarList + 1] = { ItemTableID = resid, Count = 1 }
            end
        end
        if #itemArray > 0 then
            avatarSkinList[#avatarSkinList + 1] = { Items = itemArray }
        end
    end
    pcall(function() pc.bEnableFuzzyAvatarOnClient = false end)
    pcall(function() pc.ShowVehicleSkin = skinIds[1] end)
    if #avatarList > 0 then
        pcall(function()
            pc.InitialVehicleAvatarList = avatarList
            pc:InitVehicleAvatarList()
        end)
    end
    if #avatarSkinList > 0 then
        pcall(function()
            pc.InitialVehicleAvatarSkinList = avatarSkinList
            pc:InitVehicleAvatarSkinList()
        end)
    end
    F.directInjectVehicleSkinList(pc, skinIds)
    return true
end

function F.serverChangeVehicleAvatar(skinId, pc)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    pc = pc or F.getPC()
    if not slua.isValid(pc) then return false end

    F.applyVehicleSkinsToPC(pc)

    pcall(function()
        pc.ShowVehicleSkin = skinId
        local UAvatarUtils = import("AvatarUtils")
        local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
        if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
            pc.VehicleAvatarList:Add(shapeType, skinId)
        end
        F.directInjectVehicleSkinList(pc, { skinId })
    end)

    local ok = false
    pcall(function()
        if pc.ServerChangeVehicleAvatar then
            pc:ServerChangeVehicleAvatar(skinId)
            ok = true
        end
    end)

    pcall(function()
        if pc.PlayerState and slua.isValid(pc.PlayerState) then
            pc.PlayerState.nVst_skin = skinId
        end
    end)

    pcall(function() pc:ForceNetUpdate() end)
    return ok
end

_G.AddOutfitVehSel = _G.AddOutfitVehSel or { override = nil, overrideVehicle = nil, byShape = {} }
local VEHSEL = _G.AddOutfitVehSel
_G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or { manual = false, subType = nil, resID = nil, insID = nil }
local _vehTickLastApply = 0
local VEH_SWITCH_EFFECT_ID = 7303001

function F.prepVehicleSwitchEffect(av, vehicle)
    if not slua.isValid(av) then return end
    if not F.isInRealMatch() then
        pcall(function() av.curSwitchEffectId = 0 end)
        return
    end
    pcall(function()
        av.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
        local defaultId = 0
        pcall(function() defaultId = tonumber(av:GetDefaultAvatarID()) or 0 end)
        local curId = 0
        if slua.isValid(vehicle) then
            pcall(function() curId = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) or 0 end)
            if curId <= 0 then
                pcall(function() curId = tonumber(vehicle.ClientUsedAvatarID) or 0 end)
            end
        end
        if curId <= 0 then curId = defaultId end
        if not av.lastEquipedAvatarId or av.lastEquipedAvatarId <= 0 then
            av.lastEquipedAvatarId = curId > 0 and curId or defaultId
        end
    end)
end

function F.isParachuteRes(resID)
    return F.subType(F.cfg(tonumber(resID))) == PARACHUTE_SUB
end

function F.isGlideRes(resID)
    resID = tonumber(resID)
    if not resID then return false end
    local st = F.subType(F.cfg(resID))
    if GLIDER_SUBS[st] then return true end
    local ok, r = pcall(function()
        local MDH = require("client.logic.avatar.ModelDisplayTypeHelper")
        if MDH.IsGlideByItemID and MDH.IsGlideByItemID(resID) then return true end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        return wd.IsGlideType(st)
    end)
    return ok and r == true
end

function F.isVehicleRes(resID)
    resID = tonumber(resID)
    if not resID or F.isChassisLightId(resID) then return false end
    local st = tonumber(F.subType(F.cfg(resID)))
    return st and st >= 900 and st < 7000 and st ~= CHASSIS_LIGHT_SUB
end

function F.ensureInjectedItemAlive(entity, resID, insID)
    entity = entity or F.getEntity()
    insID = tonumber(insID) or (resID and R.resToIns[tonumber(resID)])
    resID = tonumber(resID) or (insID and R.insToRes[insID])
    if not entity or not insID then return end
    pcall(function()
        local d = entity:GetDataByInsID(insID)
        if d then
            d.expire_ts = 0
            d.expireTS = 0
            d.valid_hours = 0
        end
    end)
end

function F.sanitizeAllInjectedExpire()
    local entity = F.getEntity()
    if not entity then return end
    for res, ins in pairs(R.resToIns) do
        F.ensureInjectedItemAlive(entity, res, ins)
    end
end

function F.putOnVehicle(insID)
    insID = tonumber(insID)
    if not insID then return false end
    local resID = R.insToRes[insID]
    if not resID or not F.isVehicleRes(resID) then return false end
    F.ensureInjectedItemAlive(nil, resID, insID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return false
    end
    local item = {
        res_id = resID, resID = resID,
        instid = insID, ins_id = insID, insID = insID,
        expire_ts = 0, expireTS = 0, count = 1,
    }
    local WRH = require("client.network.Protocol.WardRobeHandler")
    WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    F.setLobbyVehicleManual(F.vehicleSubType(resID), resID, insID)
    pcall(function()
        local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
        TabSurveillance.VehicleChange()
    end)
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_ITEM_LIST then
            EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
        end
    end)
    return true
end

function F.isChassisLightId(id)
    return CHASSIS_LIGHT_IDS[tonumber(id)] == true
end

function F.getDesiredChassisLight(vehicleSkinId)
    vehicleSkinId = tonumber(vehicleSkinId)
    local map = PERSIST.configChassisLightMap
    if vehicleSkinId and map and map[vehicleSkinId] then
        local v = tonumber(map[vehicleSkinId])
        if F.isChassisLightId(v) then return v end
    end
    local def = tonumber(PERSIST.configChassisLight) or DEFAULT_CHASSIS_LIGHT
    return F.isChassisLightId(def) and def or DEFAULT_CHASSIS_LIGHT
end

function F.saveChassisLight(vehicleSkinId, lightId)
    vehicleSkinId = tonumber(vehicleSkinId)
    lightId = tonumber(lightId)
    if not F.isChassisLightId(lightId) then return end
    PERSIST.configChassisLightMap = PERSIST.configChassisLightMap or {}
    if vehicleSkinId and vehicleSkinId > 0 then
        PERSIST.configChassisLightMap[vehicleSkinId] = lightId
    else
        PERSIST.configChassisLight = lightId
    end
    F.requestResourceDownload(lightId)
    F.persistMarkDirty()
end

function F.getVehicleLicenseComp(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local lic = nil
    pcall(function()
        if vehicle.GetLicenseComponent then lic = vehicle:GetLicenseComponent() end
    end)
    if slua.isValid(lic) then return lic end
    pcall(function() lic = vehicle.BP_Lobby_VehicleLicenseComponent end)
    if slua.isValid(lic) then return lic end
    pcall(function()
        local cls = import("VehicleLicenseNumberComponent")
        lic = vehicle:GetComponentByClass(cls)
    end)
    return slua.isValid(lic) and lic or nil
end

function F.applyVehicleChassisLight(vehicle, skinId, lightId)
    -- [FIX VIP] Nếu tắt Mod Skin thì bỏ qua không load đèn gầm
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end 
    
    skinId = tonumber(skinId)
    lightId = tonumber(lightId) or F.getDesiredChassisLight(skinId)
    if not F.isChassisLightId(lightId) then return false end
    if not slua.isValid(vehicle) then return false end
    if skinId and skinId > 0 then
        F.requestResourceDownload(skinId)
    end
    F.requestResourceDownload(lightId)
    local applied = false
    pcall(function()
        if vehicle.SetChassisLightShowData then
            vehicle:SetChassisLightShowData(lightId)
            applied = true
        end
    end)
    local lic = F.getVehicleLicenseComp(vehicle)
    if not slua.isValid(lic) then return applied end
    pcall(function()
        local vid = skinId
        if not vid or vid <= 0 then
            pcall(function()
                if vehicle.GetAvatarId then vid = tonumber(vehicle:GetAvatarId()) end
            end)
        end
        if not vid or vid <= 0 then
            pcall(function() vid = tonumber(lic.LicensePlate and lic.LicensePlate.ItemID) end)
        end
        if vid and vid > 0 then
            lic.curVehicleAvatarId = vid
            if lic.ChangeNetData_ItemID then
                lic:ChangeNetData_ItemID(vid)
            elseif lic.LicensePlate then
                lic.LicensePlate.ItemID = vid
            end
        end
        if lic.LicensePlate then
            lic.LicensePlate.ChassisLightId = lightId
        end
        if lic.SetChassisLightData and vid and vid > 0 then
            lic:SetChassisLightData(vid, lightId)
        elseif lic.PreChangeChassisLight then
            lic:PreChangeChassisLight()
        end
        applied = true
    end)
    return applied
end

function F.scheduleChassisLightApply(vehicle, skinId)
    skinId = tonumber(skinId)
    local vref = slua.isValid(vehicle) and vehicle or nil
    local function try()
        local v = slua.isValid(vref) and vref or F.getCurrentVehicleForSkin()
        if slua.isValid(v) then
            F.applyVehicleChassisLight(v, skinId)
        end
    end
    F.later(0.4, try)
    F.later(1.1, try)
end

function F.getVehicleShape(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local shape = vehicle.VehicleShapeType
    if shape and tonumber(shape) >= 0 then return tonumber(shape) end
    pcall(function()
        local UAvatarUtils = import("AvatarUtils")
        local defId = vehicle.AvatarDefaultCfg and vehicle.AvatarDefaultCfg.TypeSpecificID
        if defId and tonumber(defId) > 0 then
            shape = UAvatarUtils.GetVehicleShapeBySkinID(tonumber(defId))
        end
    end)
    return shape and tonumber(shape) >= 0 and tonumber(shape) or nil
end

function F.getDesiredVehicleSkinForShape(shape)
    shape = tonumber(shape)
    if not shape or shape < 0 then return nil end
    F.syncVehicleCacheFromDataMgr()
    local UAvatarUtils = import("AvatarUtils")
    local vst = F.buildVstInBattleFromSlots()
    for _, list in pairs(vst) do
        local skin = list and tonumber(list[1])
        if skin and skin > 0 then
            local s = UAvatarUtils.GetVehicleShapeBySkinID(skin)
            if s == shape then return skin end
        end
    end
    local pc = F.getPC()
    if slua.isValid(pc) and pc.VehicleAvatarList then
        local skin = tonumber(pc.VehicleAvatarList:Get(shape))
        if skin and skin > 0 then return skin end
    end
    return nil
end

function F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(vehicle) then return nil end
    local av = nil
    pcall(function() av = vehicle.VehicleAvatar end)
    if slua.isValid(av) then return av end
    pcall(function() if vehicle.GetAvatarComponent then av = vehicle:GetAvatarComponent() end end)
    if slua.isValid(av) then return av end
    pcall(function() av = vehicle.VehicleAvatarComponent_BP end)
    if slua.isValid(av) then return av end
    return nil
end

function F.getCurrentVehicleForSkin()
    local char = F.getLocalChar()
    if char and slua.isValid(char) then
        local v = nil
        pcall(function() v = char.CurrentVehicle end)
        if slua.isValid(v) then return v end
    end
    return F.getMatchVehicle()
end

function F.forceVehicleAvatar(skinId, vehicle)
    -- [CHỐT CHẶN 100%] Từ chối mọi lệnh load Skin Xe nếu công tắc tắt
    if not _G.LexusConfig.ModSkin then return false end
    
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end
    if not F.isResourcesReady(skinId) then
        F.requestResourceDownload(skinId)
        return false
    end
    vehicle = slua.isValid(vehicle) and vehicle or F.getCurrentVehicleForSkin()
    if not slua.isValid(vehicle) then return false end
    local av = F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(av) then return false end
    local applied = false
    F.prepVehicleSwitchEffect(av, vehicle)
    pcall(function() if av.CanChangeAvatar ~= nil then av.CanChangeAvatar = true end end)
    pcall(function()
        av:ChangeItemAvatar(skinId, true)
        applied = true
        _G.CurrentEquipVehicleID = skinId
    end)
    if applied then F.scheduleChassisLightApply(vehicle, skinId) end
    return applied
end

function F.vehicleAvatarTemper()
    local vehicle = F.getCurrentVehicleForSkin()
    if not slua.isValid(vehicle) then return end
    local av = F.getVehicleAvatarComp(vehicle)
    if not slua.isValid(av) then return end

    local defaultId = 0
    pcall(function() defaultId = tonumber(av:GetDefaultAvatarID()) or 0 end)
    if defaultId <= 0 then return end

    local shape = nil
    pcall(function() shape = tonumber(import("AvatarUtils").GetVehicleShapeBySkinID(defaultId)) end)

    local skinId = nil
    if VEHSEL.override and slua.isValid(VEHSEL.overrideVehicle) and VEHSEL.overrideVehicle == vehicle then
        skinId = VEHSEL.override
    end
    if not skinId and shape then skinId = VEHSEL.byShape[shape] end
    if not skinId then skinId = F.getDesiredVehicleSkinForShape(shape) end
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 or skinId == defaultId then return end

    local cur = 0
    pcall(function() cur = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) or 0 end)
    if cur <= 0 then
        pcall(function() cur = tonumber(vehicle.GetVehicleSkinItemID and vehicle:GetVehicleSkinItemID()) or 0 end)
    end
    if cur == skinId then return end

    F.forceVehicleAvatar(skinId, vehicle)
end

function F.vehicleSkinTick()
    -- [FIX VIP] Nếu đã tắt Mod Skin thì chặn luôn vòng lặp ép xe và mặt nạ
    if not _G.LexusConfig.ModSkin then return end

    F.vehicleAvatarTemper()
    
    -- [FIX VIP] Ép hiển thị Kính & Mặt Nạ liên tục mỗi 1 giây (Bất chấp việc nhặt mũ bảo hiểm)
    pcall(function()
        local char = F.getLocalChar()
        if char then F.matchApplyFaceWear(char) end
    end)

    local now = os.clock()
    if now - _vehTickLastApply < 5.0 then return end
    _vehTickLastApply = now
    F.applyVehicleSkinsToPC()
end

function F.startVehicleSkinTicker()
    pcall(function()
        if not _ticker then return end
        if _G.AddOutfitVehTickerId then return end
        if _ticker.AddTimerLoop then
            _G.AddOutfitVehTickerId = _ticker.AddTimerLoop(1.0, function()
                local fn = _G.AddOutfit and _G.AddOutfit.vehicleSkinTick
                if fn then pcall(fn) end
            end, -1, 1.0)
        end
    end)
end

function F.matchApplyVehicleSkin(skinId)
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end

    local vehicle = F.getCurrentVehicleForSkin()

    VEHSEL.override = skinId
    VEHSEL.overrideVehicle = slua.isValid(vehicle) and vehicle or nil

    pcall(function()
        local UAvatarUtils = import("AvatarUtils")
        local shape = tonumber(UAvatarUtils.GetVehicleShapeBySkinID(skinId))
        if shape and shape >= 0 then VEHSEL.byShape[shape] = skinId end
        local av = F.getVehicleAvatarComp(vehicle)
        if slua.isValid(av) then
            local defaultId = tonumber(av:GetDefaultAvatarID()) or 0
            if defaultId > 0 then
                local defShape = tonumber(UAvatarUtils.GetVehicleShapeBySkinID(defaultId))
                if defShape and defShape >= 0 then VEHSEL.byShape[defShape] = skinId end
            end
        end
    end)

    F.applyVehicleSkinsToPC(F.getPC())
    local ok = F.forceVehicleAvatar(skinId, vehicle)
    F.startVehicleSkinTicker()
    return ok
end

function F.autoApplyVehicleSkinOnEnter(vehicle)
    -- [FIX VIP] Chặn không cho tự đổi skin khi bấm nút "Lái xe / Lên xe"
    if not _G.LexusConfig.ModSkin then return end
    
    if not slua.isValid(vehicle) then return end
    F.syncVehicleCacheFromDataMgr()
    F.applyVehicleSkinsToPC(F.getPC())
    F.startVehicleSkinTicker()
    F.later(0.35, function() pcall(F.vehicleAvatarTemper) end)
    F.later(0.9, function() pcall(F.vehicleAvatarTemper) end)
    F.later(0.5, function()
        local skinId = nil
        pcall(function() skinId = tonumber(vehicle.GetAvatarId and vehicle:GetAvatarId()) end)
        F.scheduleChassisLightApply(vehicle, skinId)
    end)
end

local function GetOutfitConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName
    }
    pcall(function()
        if os and os.getenv then
            local homeDir = os.getenv("HOME")
            if homeDir and homeDir ~= "" then
                table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName)
            end
        end
    end)
    return paths
end

local CONFIG_PATHS = GetOutfitConfigPaths("skin_save.json")

local PERSIST_SLOTS = {
    { "outfit", "outfitRes", "outfitIns", "AddOutfitLastLobbyOutfitRes" },
    { "tshirt", "tshirtRes", "tshirtIns", "AddOutfitLastLobbyTshirtRes" },
    { "pants",  "pantsRes",  "pantsIns",  "AddOutfitLastLobbyPantsRes"  },
    { "shoes",  "shoesRes",  "shoesIns",  "AddOutfitLastLobbyShoesRes"  },
    { "hat",    "hatRes",    "hatIns",    "AddOutfitLastLobbyHatRes"    },
    { "mask",   "maskRes",   "maskIns",   "AddOutfitLastLobbyMaskRes"   },
    { "glass",  "glassRes",  "glassIns",  "AddOutfitLastLobbyGlassRes"  },
    { "bag",    "bagRes",    "bagIns",    "AddOutfitLastLobbyBagRes"    },
    { "helmet", "helmetRes", "helmetIns", "AddOutfitLastLobbyHelmetRes" },
    { "parachute", "parachuteRes", "parachuteIns", "AddOutfitLastLobbyParachuteRes" },
    { "glider", "gliderRes", "gliderIns", "AddOutfitLastLobbyGliderRes" },
    { "gloves", "glovesRes", "glovesIns", "AddOutfitLastLobbyGlovesRes" },
}

function F.isPersistableWearRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return false end
    if F.isInjectedRes(resID) then return true end
    if F.isParachuteRes(resID) or F.isGlideRes(resID) then return true end
    if PERSIST.configSlots then
        for _, v in pairs(PERSIST.configSlots) do
            if tonumber(v) == resID then return true end
        end
    end
    return false
end

function F.persistRememberSlot(slotName, resID)
    slotName = slotName and tostring(slotName)
    resID = tonumber(resID)
    if not slotName or not resID or resID <= 0 then return end
    PERSIST.configSlots = PERSIST.configSlots or {}
    PERSIST.configSlots[slotName] = resID
end

function F.persistForgetSlot(slotName)
    if PERSIST.configSlots and slotName then
        PERSIST.configSlots[tostring(slotName)] = nil
    end
end

function F.persistLoadSlotsFromSaved(saved)
    if type(saved) ~= "table" then return end
    PERSIST.configSlots = PERSIST.configSlots or {}
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(saved[s[1]])
        if res and res > 0 then PERSIST.configSlots[s[1]] = res end
    end
    F.applyPersistSlotsToCache()
end

function F.resolveInsForRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return nil end
    if R.resToIns[resID] then return R.resToIns[resID] end
    local ins
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local list = wd.GetHallDepotItemListByResID and wd:GetHallDepotItemListByResID(resID)
        if list then
            for _, v in pairs(list) do
                local id = tonumber(v.insID or v.instid or v.ins_id)
                if id and id > 0 then ins = id break end
            end
        end
        if not ins then
            local d = wd.GetValidHallDepotItemDataByInsID and wd:GetValidHallDepotItemDataByInsID(resID)
            if not d and wd.GetHallDepotItemDataByResID then
                d = wd:GetHallDepotItemDataByResID(resID)
            end
            if d then ins = tonumber(d.insID or d.instid or d.ins_id) end
        end
    end)
    return ins
end

function F.applyPersistSlotsToCache()
    if not PERSIST.configSlots then return end
    local cch = F.cache()
    for _, s in ipairs(PERSIST_SLOTS) do
        local slotName, cacheResKey, cacheInsKey, globalKey = s[1], s[2], s[3], s[4]
        local res = tonumber(PERSIST.configSlots[slotName])
        if res and res > 0 then
            cch[cacheResKey] = res
            _G[globalKey] = res
            local ins = F.resolveInsForRes(res)
            if ins and ins > 0 then cch[cacheInsKey] = ins end
        end
    end
end

function F.getDesiredGliderRes()
    F.applyPersistSlotsToCache()
    local r = tonumber(PERSIST.configSlots and PERSIST.configSlots.glider)
    if r and r > 0 then return r end
    F.syncAirborneCacheFromLobby()
    return F.getDesiredWear("gliderRes", "gliderRes", "AddOutfitLastLobbyGliderRes")
end

function F.getDesiredParachuteRes()
    F.applyPersistSlotsToCache()
    local r = tonumber(PERSIST.configSlots and PERSIST.configSlots.parachute)
    if r and r > 0 then return r end
    F.syncAirborneCacheFromLobby()
    return F.getDesiredWear("parachuteRes", "parachuteRes", "AddOutfitLastLobbyParachuteRes")
end

function F.getAvatarComp2(char)
    if not char or not slua.isValid(char) then return nil end
    local comp
    pcall(function()
        if char.getAvatarComponent2 then
            comp = char:getAvatarComponent2()
        end
        if (not comp or not slua.isValid(comp)) and char.AvatarComponent2 then
            comp = char.AvatarComponent2
        end
        if (not comp or not slua.isValid(comp)) and char.CharacterAvatarComp2_BP then
            comp = char.CharacterAvatarComp2_BP
        end
    end)
    return comp
end

function F.isCharacterAirborne(char)
    if not char or not slua.isValid(char) then return false end
    local ok, r = pcall(function()
        local EParachuteState = import("EParachuteState")
        local st = char.ParachuteState
        return st and st ~= EParachuteState.PS_None
    end)
    return ok and r == true
end

function F.reapplyWeaponsFromConfig()
    local wmap = F.sanitizeConfigWeapons(PERSIST.configWeapons)
    local dropped = false
    for k in pairs(PERSIST.configWeapons or {}) do
        if not wmap[tonumber(k) or k] then dropped = true break end
    end
    PERSIST.configWeapons = wmap
    if dropped then F.persistMarkDirty() end
    if not next(wmap) then return false end
    local cch = F.cache()
    local any = false
    for wid, res in pairs(wmap) do
        wid, res = tonumber(wid), tonumber(res)
        local ins = res and R.resToIns[res]
        if wid and ins and F.isInjectedIns(ins) then
            cch.weapons[wid] = { resID = res, insID = ins }
            if F.equipWeaponSkin(wid, ins) then
                any = true
            else
                F.syncWeaponArmorySilent(wid, ins)
            end
        end
    end
    return any
end

function F.persistEncode()
    local cch = F.cache()
    local parts = {}
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(PERSIST.configSlots and PERSIST.configSlots[s[1]])
            or tonumber(cch[s[2]])
        if res and res > 0 and F.isPersistableWearRes(res) then
            parts[#parts + 1] = string.format('  "%s": %d', s[1], res)
        end
    end
    local wparts = {}
    local wmap = {}
    for wid, res in pairs(F.sanitizeConfigWeapons(PERSIST.configWeapons)) do
        wmap[wid] = res
    end
    for wid, w in pairs(cch.weapons or {}) do
        local res = w and tonumber(w.resID)
        wid = tonumber(wid)
        if F.isValidWeaponPersistEntry(wid, res) then wmap[wid] = res end
    end
    for wid, res in pairs(wmap) do
        wparts[#wparts + 1] = string.format('    "%d": %d', wid, res)
    end
    table.sort(wparts)
    parts[#parts + 1] = '  "weapons": {\n' .. table.concat(wparts, ",\n") .. "\n  }"
    local vparts = {}
    local function appendVehicleSlots(src)
        for subType, slots in pairs(src or {}) do
            local sparts = {}
            if type(slots) == "table" then
                for idx, val in pairs(slots) do
                    local res = type(val) == "table" and tonumber(val.resID) or tonumber(val)
                    if res and res > 0 then
                        sparts[#sparts + 1] = string.format('      "%d": %d', tonumber(idx), res)
                    end
                end
            end
            table.sort(sparts)
            if #sparts > 0 then
                vparts[#vparts + 1] = string.format('    "%d": {\n%s\n    }', tonumber(subType), table.concat(sparts, ",\n"))
            end
        end
    end
    local hasCacheSlots = false
    for _ in pairs(cch.vehicleSlots or {}) do hasCacheSlots = true; break end
    if hasCacheSlots then
        appendVehicleSlots(cch.vehicleSlots)
    elseif PERSIST.configVehicleSlots then
        appendVehicleSlots(PERSIST.configVehicleSlots)
    end
    local mparts = {}
    if DataMgr and DataMgr.MotionSlotList then
        for i, ins in ipairs(DataMgr.MotionSlotList) do
            ins = tonumber(ins)
            if ins and ins > 0 and F.isInjectedIns(ins) then
                local res = R.insToRes[ins]
                if res then mparts[#mparts+1] = string.format('      "%d": %d', i, res) end
            end
        end
    end
    if #mparts > 0 then
        parts[#parts + 1] = '  "motions": {\n' .. table.concat(mparts, ",\n") .. "\n  }"
    end
    if PERSIST.lobbyVehicleSubType and PERSIST.lobbyVehicleSubType > 0
        and PERSIST.lobbyVehicleSubType ~= CHASSIS_LIGHT_SUB
        and not F.isChassisLightId(PERSIST.lobbyVehicleResID)
        and F.isVehicleRes(PERSIST.lobbyVehicleResID) then
        parts[#parts + 1] = string.format('  "lobbyVehicleSubType": %d', PERSIST.lobbyVehicleSubType)
    end
    if PERSIST.lobbyVehicleResID and PERSIST.lobbyVehicleResID > 0
        and F.isVehicleRes(PERSIST.lobbyVehicleResID) then
        parts[#parts + 1] = string.format('  "lobbyVehicleResID": %d', PERSIST.lobbyVehicleResID)
    end
    if PERSIST.lobbyVehicleIns and PERSIST.lobbyVehicleIns > 0
        and F.isVehicleRes(PERSIST.lobbyVehicleResID or R.insToRes[PERSIST.lobbyVehicleIns]) then
        parts[#parts + 1] = string.format('  "lobbyVehicleIns": %d', PERSIST.lobbyVehicleIns)
    end
    local hres = tonumber(cch.hallThemeRes) or tonumber(PERSIST.hallThemeResID)
    if hres and hres > 0 and F.isInjectedRes(hres) then
        parts[#parts + 1] = string.format('  "hallTheme": %d', hres)
    end
    local cl = tonumber(PERSIST.configChassisLight)
    if F.isChassisLightId(cl) then
        parts[#parts + 1] = string.format('  "chassisLight": %d', cl)
    end
    local cmap = PERSIST.configChassisLightMap
    if cmap and next(cmap) then
        local cparts = {}
        for vid, lid in pairs(cmap) do
            vid, lid = tonumber(vid), tonumber(lid)
            if vid and vid > 0 and F.isChassisLightId(lid) then
                cparts[#cparts + 1] = string.format('    "%d": %d', vid, lid)
            end
        end
        table.sort(cparts)
        if #cparts > 0 then
            parts[#parts + 1] = '  "chassisLightMap": {\n' .. table.concat(cparts, ",\n") .. "\n  }"
        end
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n}\n"
end

function F.persistWrite(txt)
    if not (io and io.open) then return false end
    if PERSIST.path then
        local f
        pcall(function() f = io.open(PERSIST.path, "w") end)
        if f then f:write(txt) f:close() return true end
        PERSIST.path = nil
    end
    for _, p in ipairs(CONFIG_PATHS) do
        local f
        pcall(function() f = io.open(p, "w") end)
        if not f then
            pcall(function()
                local dir = p:match("^(.*)/[^/]+$")
                if dir and os and os.execute then os.execute('mkdir -p "' .. dir .. '"') end
            end)
            pcall(function() f = io.open(p, "w") end)
        end
        if f then
            f:write(txt) f:close()
            PERSIST.path = p
            return true
        end
    end
    return false
end

function F.persistFlush()
    if not PERSIST.dirty then return end
    PERSIST.dirty = false
    pcall(function()
        local txt = F.persistEncode()
        if txt == PERSIST.lastWritten then return end
        if F.persistWrite(txt) then
            PERSIST.lastWritten = txt
        end
    end)
end

F.persistMarkDirty = function()
    PERSIST.dirty = true
    if PERSIST.scheduled then return end
    PERSIST.scheduled = true
    F.later(2.0, function()
        PERSIST.scheduled = false
        F.persistFlush()
    end)
end

function F.persistParse(txt)
    if not txt or #txt == 0 then return nil end
    local out = { weapons = {}, vehicleSlots = {} }
    local parsed = false
    pcall(function()
        local t = json and json.decode and json.decode(txt)
        if type(t) == "table" then
            for k, v in pairs(t) do
                if k == "weapons" and type(v) == "table" then
                    for wk, wv in pairs(v) do
                        local wid, res = tonumber(wk), tonumber(wv)
                        if F.isValidWeaponPersistEntry(wid, res) then out.weapons[wid] = res end
                    end
                elseif k == "vehicleSlots" and type(v) == "table" then
                    for stk, slotMap in pairs(v) do
                        local st = tonumber(stk)
                        if st then
                            out.vehicleSlots[st] = out.vehicleSlots[st] or {}
                            for idxStr, res in pairs(slotMap) do
                                local idx, r = tonumber(idxStr), tonumber(res)
                                if idx and r and r > 0 then out.vehicleSlots[st][idx] = r end
                            end
                        end
                    end
                elseif k == "motions" and type(v) == "table" then
                    out.motions = {}
                    for mk, mv in pairs(v) do
                        local slot = tonumber(mk)
                        local res = tonumber(mv)
                        if slot and res and res > 0 then out.motions[slot] = res end
                    end
                else
                    local n = tonumber(v)
                    if n and n > 0 then out[k] = n end
                end
            end
            parsed = true
        end
    end)
    if not parsed then
        for k, v in txt:gmatch('"([%w_]+)"%s*:%s*(%d+)') do
            local n = tonumber(v)
            if n and n > 0 then
                local wid = tonumber(k)
                if wid and F.isValidWeaponPersistEntry(wid, n) then
                    out.weapons[wid] = n
                elseif not wid then
                    out[k] = n
                end
            end
        end
    end
    return out
end

function F.persistLoadFromDisk()
    if not (io and io.open) then return end
    pcall(function()
        for _, p in ipairs(CONFIG_PATHS) do
            local f
            pcall(function() f = io.open(p, "r") end)
            if f then
                local txt = f:read("*a")
                f:close()
                PERSIST.path = p
                PERSIST.lastWritten = txt
                PERSIST.loaded = F.persistParse(txt)
                F.persistLoadSlotsFromSaved(PERSIST.loaded)
                if PERSIST.loaded and PERSIST.loaded.vehicleSlots then
                    PERSIST.configVehicleSlots = PERSIST.loaded.vehicleSlots
                end
                if PERSIST.loaded and PERSIST.loaded.weapons then
                    local raw = PERSIST.loaded.weapons
                    PERSIST.configWeapons = F.sanitizeConfigWeapons(raw)
                    if next(raw) and not next(PERSIST.configWeapons) then
                        F.persistMarkDirty()
                    elseif next(raw) then
                        for wid, res in pairs(raw) do
                            if not F.isValidWeaponPersistEntry(tonumber(wid), tonumber(res)) then
                                F.persistMarkDirty()
                                break
                            end
                        end
                    end
                end
                PERSIST.lobbyVehicleSubType = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleSubType)
                PERSIST.lobbyVehicleResID = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleResID)
                PERSIST.lobbyVehicleIns = tonumber(PERSIST.loaded and PERSIST.loaded.lobbyVehicleIns)
                if PERSIST.lobbyVehicleSubType or PERSIST.lobbyVehicleIns or PERSIST.lobbyVehicleResID then
                    if F.isChassisLightId(PERSIST.lobbyVehicleResID)
                        or PERSIST.lobbyVehicleSubType == CHASSIS_LIGHT_SUB
                        or not F.isVehicleRes(PERSIST.lobbyVehicleResID) then
                        PERSIST.lobbyVehicleSubType = nil
                        PERSIST.lobbyVehicleResID = nil
                        PERSIST.lobbyVehicleIns = nil
                    else
                        _G.AddOutfitLobbyVeh = _G.AddOutfitLobbyVeh or {}
                        _G.AddOutfitLobbyVeh.manual = true
                        _G.AddOutfitLobbyVeh.subType = PERSIST.lobbyVehicleSubType
                        _G.AddOutfitLobbyVeh.resID = PERSIST.lobbyVehicleResID
                        _G.AddOutfitLobbyVeh.insID = PERSIST.lobbyVehicleIns
                    end
                end
                PERSIST.hallThemeResID = tonumber(PERSIST.loaded and PERSIST.loaded.hallTheme)
                PERSIST.hallThemeIns = nil
                if PERSIST.hallThemeResID then
                    _G.AddOutfitLobbyTheme = _G.AddOutfitLobbyTheme or {}
                    _G.AddOutfitLobbyTheme.manual = true
                    _G.AddOutfitLobbyTheme.resID = PERSIST.hallThemeResID
                end
                PERSIST.configChassisLight = tonumber(PERSIST.loaded and PERSIST.loaded.chassisLight)
                if PERSIST.loaded and PERSIST.loaded.chassisLightMap then
                    PERSIST.configChassisLightMap = PERSIST.loaded.chassisLightMap
                end
                return
            end
        end
    end)
end

function F.persistApplyLoaded()
    local saved = PERSIST.loaded
    if not saved then return end
    PERSIST.loaded = nil
    local cch = F.cache()
    local any = false
    for _, s in ipairs(PERSIST_SLOTS) do
        local res = tonumber(saved[s[1]]) or tonumber(PERSIST.configSlots and PERSIST.configSlots[s[1]])
        if res and res > 0 and not cch[s[2]] then
            local ins = R.resToIns[res]
            if ins then
                cch[s[2]], cch[s[3]] = res, ins
                _G[s[4]] = res
                any = true
            end
        end
    end
    PERSIST.configWeapons = F.sanitizeConfigWeapons(saved.weapons or PERSIST.configWeapons)
    if saved.weapons and F.reapplyWeaponsFromConfig() then
        any = true
    end
    if saved.vehicleSlots then
        PERSIST.configVehicleSlots = saved.vehicleSlots
        if F.reapplyVehicleSlotsFromConfig(true) then
            any = true
        end
    end
    if saved.hallTheme then
        PERSIST.hallThemeResID = tonumber(saved.hallTheme)
        if PERSIST.hallThemeResID and F.reapplyHallThemeFromConfig(true) then
            any = true
        end
    end
    if saved.chassisLight then
        PERSIST.configChassisLight = tonumber(saved.chassisLight)
    end
    if saved.chassisLightMap then
        PERSIST.configChassisLightMap = saved.chassisLightMap
    end
    
    if saved.motions then
        PERSIST.configMotions = saved.motions
        DataMgr.MotionSlotList = DataMgr.MotionSlotList or {}
        for slot, res in pairs(saved.motions) do
            local ins = R.resToIns[res]
            if ins then DataMgr.MotionSlotList[slot] = ins end
        end
        if EventSystem and EVENTTYPE_MOTION and EVENTID_MOTION_UPDATE_SLOT_LIST then
            EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST)
        end
    end
    if any then
        _matchApplied = false
        F.perfInvalidateLobby()
    end
end

function F.getEntity()
    local ok, dc = pcall(require, "client.slua.logic.wardrobe.logic_wardrobe_data_center")
    if not ok or not dc then return nil end
    local ok2, e = pcall(dc.GetWardrobeData)
    return ok2 and e or nil
end

function F.firstInsForRes(entity, resID)
    local arr = entity.ResIDToIndexArrayMap and entity.ResIDToIndexArrayMap[resID]
    if not arr then return nil end
    for _, idx in pairs(arr) do
        local d = entity._data[idx]
        if d and d.count and d.count > 0 then return d.insID end
    end
    return nil
end

function F.injectOne(entity, resID, insID)
    local ownedIns = F.firstInsForRes(entity, resID)
    if ownedIns then
        F.ensureInjectedItemAlive(entity, resID, ownedIns)
        R.resToIns[resID] = ownedIns
        R.insToRes[ownedIns] = resID
        F.indexWeaponSkin(resID, ownedIns)
        return true
    end
    local row = {
        instid = insID,
        res_id = resID,
        count = 1,
        lock_cnt = 0,
        isnew = 0,
        valid_hours = 0,
        expire_ts = 0,
    }
    entity:AddData(row)
    pcall(function()
        if entity.LoadConfigForData and CDataTable and CDataTable.GetTableData then
            local idx = entity._DataCount
            if idx and entity._data[idx] then
                entity:LoadConfigForData(entity._data[idx], CDataTable.GetTableData)
            end
        end
    end)
    R.insToRes[insID] = resID
    R.resToIns[resID] = insID
    F.indexWeaponSkin(resID, insID)
    return true
end

function F.reviveExpiredOwned(entity)
    entity = entity or F.getEntity()
    if not entity or not entity.bInit or not entity._data then return end
    local now = 0
    pcall(function()
        local TimeUtil = require("client.common.time_util")
        now = tonumber(TimeUtil.GetServerTimeInSec()) or 0
    end)
    if now <= 0 then return end
    _G.AddOutfitRevived = _G.AddOutfitRevived or {}
    local n = 0
    for i = 1, (entity._DataCount or #entity._data) do
        local d = entity._data[i]
        if d then
            local exp = tonumber(d.expire_ts or d.expireTS) or 0
            local res = tonumber(d.res_id or d.resID)
            local ins = tonumber(d.instid or d.insID)
            if exp > 0 and exp <= now and res and ins and (tonumber(d.count) or 0) > 0 then
                d.expire_ts = 0
                if d.expireTS ~= nil then d.expireTS = 0 end
                if d.valid_hours ~= nil then d.valid_hours = 0 end
                _G.AddOutfitRevived[res] = ins
                n = n + 1
            end
        end
    end
end

function F.mergeRevivedIntoMaps()
    for res, ins in pairs(_G.AddOutfitRevived or {}) do
        if not R.resToIns[res] then
            R.resToIns[res] = ins
            R.insToRes[ins] = res
            F.indexWeaponSkin(res, ins)
        end
    end
end

function F.injectArmory(resID, insID)
    local wid = F.weaponIdFromSkin(resID)
    if not wid then return end
    local Arm = require("client.logic.armory.logic_armory")
    Arm.rsp_list = Arm.rsp_list or { skin_list = {}, install_list = {} }
    Arm.rsp_list.skin_list = Arm.rsp_list.skin_list or {}
    Arm.rsp_list.install_list = Arm.rsp_list.install_list or {}
    if not Arm.rsp_list.skin_list[wid] then Arm.rsp_list.skin_list[wid] = {} end
    Arm.rsp_list.skin_list[wid][resID] = { is_open = 1 }
    Arm.WardrobeInsList = Arm.WardrobeInsList or {}
    Arm.WardrobeInsList[resID] = insID
end

function F.mergeInjectedArmorySkins()
    for _, skins in pairs(R.byWeapon) do
        for resID, insID in pairs(skins) do
            F.injectArmory(resID, insID)
        end
    end
end

function F.injectAll(entity)
    if _G.LexusConfig and _G.LexusConfig.ModSkin == false then return false end -- Bỏ qua nếu tắt Mod Skin
    entity = entity or F.getEntity()
    if not entity or not entity.bInit then return false end
    local n, nNew = 0, 0
    
    -- [FIX VIP] TỰ ĐỘNG TẠO THÊM ID MŨ/BALO CẤP 2 VÀ CẤP 3 ĐỂ CHỮA LỖI UI NỐT NHẠC
    local expandedItems = {}
    for _, resID in ipairs(ITEMS) do
        table.insert(expandedItems, resID)
        local resNum = tonumber(resID)
        if resNum then
            -- Nhận diện dải ID của Balo (1501...) và Mũ (1502..., 1505...)
            local isBag = (resNum >= 1501000000 and resNum <= 1501999999)
            local isHelmet = (resNum >= 1502000000 and resNum <= 1502999999) or (resNum >= 1505000000 and resNum <= 1505999999)
            
            if isBag or isHelmet then
                table.insert(expandedItems, resNum + 1000) -- Bơm thêm Cấp 2 vào tủ đồ
                table.insert(expandedItems, resNum + 2000) -- Bơm thêm Cấp 3 vào tủ đồ
            end
        end
    end

    -- Đọc danh sách đã được nhân bản
    for i, resID in ipairs(expandedItems) do
        local insID = INS_BASE + i
        local had = R.resToIns[resID] ~= nil
        if F.injectOne(entity, resID, insID) then
            n = n + 1
            if not had then nNew = nNew + 1 end
            local c = F.cfg(resID)
            if GUN_SUB[F.subType(c)] or F.subType(c) == MELEE_ID then
                F.injectArmory(resID, insID)
            end
        end
    end

    if not _G.AddOutfitUnexpireDone then
        _G.AddOutfitUnexpireDone = true
        pcall(F.reviveExpiredOwned, entity)
    end
    F.mergeRevivedIntoMaps()
    F.sanitizeAllInjectedExpire()
    F.ensureInjectedResources()
    return n > 0
end

function F.refreshWardrobe()
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE then
            if EVENTID_WARDROBE_UPDATE_ITEM_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_AVATAR_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_GUN_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_GUN_LIST, -1)
            end
        end
    end)
end

function F.refreshWardrobeOnce()
    if LOBBY.wardrobeRefreshed then return end
    LOBBY.wardrobeRefreshed = true
    F.refreshWardrobe()
end

function F.scheduleInjectRefresh()
    LOBBY.injectRefreshGen = (LOBBY.injectRefreshGen or 0) + 1
    local gen = LOBBY.injectRefreshGen
    F.later(0.4, function()
        if gen ~= LOBBY.injectRefreshGen then return end
        F.refreshWardrobe()
    end)
end

function F.putOnOutfit(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    if not F.isSuitRes(resID) then
        if F.isTshirtRes(resID) then return F.putOnRoleWear(insID) end
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end

    local suitFilter = function(r) return F.isSuitRes(r) end
    local oldIns, oldRes = F.findWornInsBySubType(OUTFIT_SUB, suitFilter)
    F.removeRoleWearBySubType(OUTFIT_SUB, suitFilter)
    F.saveEquip(resID, insID)

    local slot = PKG_SLOT
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(OUTFIT_SUB)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local av = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
        av:AddToWearInfo(OUTFIT_SUB, insID, resID, 0, 0)
        F.syncFashionBagRolewear()
    end)
end

function F.putOnHat(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or HAT_SUB

    local oldIns, oldRes = F.findWornInsBySubType(st)
    if not oldIns and st ~= HAT_SUB then
        oldIns, oldRes = F.findWornInsBySubType(HAT_SUB)
    end
    F.removeRoleWearBySubType(st)
    if st ~= HAT_SUB then F.removeRoleWearBySubType(HAT_SUB) end
    F.saveEquip(resID, insID)

    local slot = 1
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        fbd:SetHeadShow(insID)
        F.syncFashionBagRolewear()
    end)
    F.invalidateSocialWearCache()
end

function F.putOnFaceAccessory(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or tonumber(d.itemSubType)
    if not FACE_SUBS[st] then return end

    local oldIns, oldRes = F.findWornInsBySubType(st)
    F.removeRoleWearBySubType(st)
    F.saveEquip(resID, insID)

    local slot = (st == MASK_SUB) and 2 or 6
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function() F.syncFashionBagRolewear() end)
    F.invalidateSocialWearCache()
end

function F.canRoleWear(resID, st)
    st = st or F.subType(F.cfg(resID))
    if FACE_SUBS[st] or BODY_SUBS[st] then return true end
    if st == GLOVES_SUB then return true end
    if st == OUTFIT_SUB and F.wardrobeTab(resID) == TAB_CLOTHES then return true end
    return false
end

F.putOnRoleWear = function(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end
    local st = F.subType(F.cfg(resID)) or tonumber(d.itemSubType)
    if not F.canRoleWear(resID, st) then return end

    local filterFn
    if st == OUTFIT_SUB then
        filterFn = function(r) return F.wardrobeTab(r) == TAB_CLOTHES end
    end
    local oldIns, oldRes = F.findWornInsBySubType(st, filterFn)
    F.removeRoleWearBySubType(st, filterFn)
    F.saveEquip(resID, insID)

    local slot = PKG_SLOT
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(st)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    if BAG_SUBS[st] or HELMET_SUBS[st] then
        pcall(function()
            DataMgr.equipmentSkinInsIDTable = DataMgr.equipmentSkinInsIDTable or {}
            DataMgr.equipmentSkinInsIDTable[st] = insID
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag then
                if st == 504 or st == 501 then
                    DataMgr.equipmentSkinInsIDTable[504] = insID
                    bag.bag_skin = insID
                    -- [FIX VIP] Ép hiển thị Balo 3D ngoài sảnh
                    local HT = require("client.logic.lobby.hall_theme_utils")
                    if HT and HT.PutOnBag then HT.PutOnBag(fbd:GetFashionBagUseIndex()) end
                elseif st == 505 or st == 502 then
                    DataMgr.equipmentSkinInsIDTable[505] = insID
                    bag.helmet_skin = insID
                    -- [FIX VIP] Ép hiển thị Mũ 3D ngoài sảnh
                    fbd:SetHeadShow(insID)
                    local WRH = require("client.network.Protocol.WardRobeHandler")
                    if WRH and WRH.send_depot_set_head_show_req then 
                        WRH.send_depot_set_head_show_req(insID) 
                    end
                end
            end
            
            -- [FIX VIP] Ép Load Mô hình 3D lên nhân vật
            local lav = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
            if lav and lav.AvatarChange then
                lav:AvatarChange(resID, true, 0, 0)
            end
        end)
    end

    pcall(function() F.syncFashionBagRolewear() end)
    F.invalidateSocialWearCache()
end

function F.putOnGloves(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d0 = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d0 and tonumber(d0.resID or d0.res_id)
    end
    if not resID or resID <= 0 then return end
    if not R.insToRes[insID] then R.insToRes[insID] = resID; R.resToIns[resID] = insID end
    F.ensureDepotItemValid(insID, resID)
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
    local d = wd:GetHallDepotItemDataByInsID(insID)
    if not d then return end

    local oldIns, oldRes = F.findWornInsBySubType(GLOVES_SUB)
    F.removeRoleWearBySubType(GLOVES_SUB)
    F.saveEquip(resID, insID)

    local slot = 8
    pcall(function()
        local wfu = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
        local idx = wfu.GetRoleWearIndexBySubType and wfu:GetRoleWearIndexBySubType(GLOVES_SUB)
        if idx then slot = idx end
    end)

    local olditem
    if oldIns and oldIns ~= insID then
        olditem = { res_id = oldRes or R.insToRes[oldIns], count = 1, instid = oldIns }
    end

    local WRH = require("client.network.Protocol.WardRobeHandler")
    local item = { res_id = resID, count = 1, instid = insID, color = d.color, pattern = d.pattern, expire_ts = 0 }
    WRH.on_depot_put_on_rsp(NET_OK, item, olditem, slot, insID, oldIns or 0)

    pcall(function()
        local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
        logic_wardrobe_avatar:AddToWearInfo(GLOVES_SUB, insID, resID, d.color or 0, d.pattern or 0)
        DataMgr.UpdateRoleWearData(insID, oldIns or 0)
        logic_wardrobe_avatar:AvatarChange(resID, true, d.color, d.pattern)
    end)
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl.SetClickItemInsId then wl:SetClickItemInsId(insID) end
    end)
    pcall(function()
        if EventSystem and EVENTTYPE_WARDROBE then
            if EVENTID_WARDROBE_UPDATE_ITEM_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
            end
            if EVENTID_WARDROBE_UPDATE_AVATAR_LIST then
                EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_AVATAR_LIST)
            end
        end
    end)
    F.invalidateSocialWearCache()
end

function F.ensureDepotItemValid(insID, resID)
    insID = tonumber(insID)
    if not insID then return end
    pcall(function()
        local entity = F.getEntity()
        if entity and entity.GetDataByInsID then
            local d = entity:GetDataByInsID(insID)
            if d then
                d.expire_ts = 0
                if d.expireTS ~= nil then d.expireTS = 0 end
                if d.valid_hours ~= nil then d.valid_hours = 0 end
            end
        end
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local hd = wd:GetHallDepotItemDataByInsID(insID)
        if hd then
            hd.expire_ts = 0
            if hd.expireTS ~= nil then hd.expireTS = 0 end
            if hd.valid_hours ~= nil then hd.valid_hours = 0 end
        end
    end)
end

function F.clearItemExpire(itemData, insID, resID)
    F.ensureDepotItemValid(insID, resID)
    if type(itemData) == "table" then
        itemData.expireTS = 0
        itemData.expire_ts = 0
        itemData.expireTs = 0
    end
end

function F.onGlideClick(self, itemData)
    if not itemData then return end
    local insID = tonumber(itemData.ins_id)
    local resID = tonumber(itemData.res_id)
    F.clearItemExpire(itemData, insID, resID)
    local isGlide = resID and F.isGlideRes(resID)
    if not isGlide and itemData.itemSubType then
        isGlide = GLIDER_SUBS[tonumber(itemData.itemSubType)] == true
    end
    if insID and resID and isGlide then
        F.saveEquip(resID, insID)
        if F.putOnGlider(insID) then
            pcall(function()
                if self.ShowGlide then self:ShowGlide(resID) end
                if self.ChangeItemStatus then self:ChangeItemStatus(insID, true) end
            end)
            return
        end
    end
    if _G.AddOutfitGlideClickOrig then
        F.clearItemExpire(itemData, insID, resID)
        return _G.AddOutfitGlideClickOrig(self, itemData)
    end
end

function F.onParachuteClick(self, itemData)
    if not itemData then return end
    local insID = tonumber(itemData.ins_id)
    local resID = tonumber(itemData.res_id)
    F.clearItemExpire(itemData, insID, resID)
    if insID and resID and F.isParachuteRes(resID) then
        F.saveEquip(resID, insID)
        if F.putOnParachute(insID) then
            pcall(function()
                if self.ChangeItemStatus then self:ChangeItemStatus(insID, true) end
            end)
            return
        end
    end
    if _G.AddOutfitParaClickOrig then
        return _G.AddOutfitParaClickOrig(self, itemData)
    end
end

function F.hookAirborneClick()
    pcall(function()
        local WG = require("client.slua.umg.Wardrobe.subtab_gliding")
        if WG then
            if not WG._AddOutfitGlideWrapped then
                WG._AddOutfitGlideWrapped = true
                _G.AddOutfitGlideClickOrig = WG.ClickItem
            end
            WG.ClickItem = function(self, itemData)
                return F.onGlideClick(self, itemData)
            end
        end
        local WP = require("client.slua.umg.Wardrobe.subtab_parachute")
        if WP then
            if not WP._AddOutfitParaWrapped then
                WP._AddOutfitParaWrapped = true
                _G.AddOutfitParaClickOrig = WP.ClickItem
            end
            WP.ClickItem = function(self, itemData)
                return F.onParachuteClick(self, itemData)
            end
        end
    end)
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd and not fbd._AddOutfitAirborneFBHooked then
            fbd._AddOutfitAirborneFBHooked = true
            local oG = fbd.UpdateAircraftOrGliding
            fbd.UpdateAircraftOrGliding = function(self, putOnID, bAircraft)
                local r = oG(self, putOnID, bAircraft)
                local ins = tonumber(putOnID)
                if ins and ins > 0 then
                    local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                    local d = wd:GetValidHallDepotItemDataByInsID(ins) or wd:GetHallDepotItemDataByInsID(ins)
                    local res = d and tonumber(d.resID)
                    if res and F.isGlideRes(res) then F.saveEquip(res, ins) end
                end
                return r
            end
            local oP = fbd.UpdateParachute
            if oP then
                fbd.UpdateParachute = function(self, insID)
                    local r = oP(self, insID)
                    local ins = tonumber(insID)
                    if ins and ins > 0 then
                        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                        local d = wd:GetValidHallDepotItemDataByInsID(ins) or wd:GetHallDepotItemDataByInsID(ins)
                        local res = d and tonumber(d.resID)
                        if res and F.isParachuteRes(res) then F.saveEquip(res, ins) end
                    end
                    return r
                end
            end
        end
    end)
    pcall(function()
        if not ModuleManager or not ModuleManager.GetModule then return end
        local FB = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
        if FB and not FB._AddOutfitFBBagHooked then
            FB._AddOutfitFBBagHooked = true
            local o = FB.PutOnFashionBagItem
            FB.PutOnFashionBagItem = function(self, itemData)
                if itemData then
                    F.clearItemExpire(itemData, itemData.ins_id, itemData.res_id)
                end
                local r = o(self, itemData)
                if itemData then
                    local res = tonumber(itemData.res_id)
                    local ins = tonumber(itemData.ins_id)
                    if res and ins and (F.isGlideRes(res) or F.isParachuteRes(res)) then
                        F.saveEquip(res, ins)
                    end
                end
                return r
            end
        end
    end)
end

function F.putOnParachute(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d and tonumber(d.resID)
    end
    if not resID or not F.isParachuteRes(resID) then return false end
    if not R.insToRes[insID] then R.insToRes[insID] = resID end
    F.ensureDepotItemValid(insID, resID)
    F.saveEquip(resID, insID)
    F.ensureInjectedItemAlive(nil, resID, insID)
    local ready = F.isResourcesReady(resID)
    if not ready then F.requestResourceDownload(resID) end
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.SetParachute then fbd:SetParachute(insID) end
        if fbd.UpdateParachute then fbd:UpdateParachute(insID) end
    end)
    if ready then
        local item = {
            res_id = resID, resID = resID,
            instid = insID, ins_id = insID, insID = insID,
            expire_ts = 0, expireTS = 0, count = 1,
        }
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    end
    return true
end

function F.putOnGlider(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local d = wd:GetValidHallDepotItemDataByInsID(insID) or wd:GetHallDepotItemDataByInsID(insID)
        resID = d and tonumber(d.resID)
    end
    if not resID or resID <= 0 then return false end
    local st = F.depotSubType(insID, resID)
    if not F.isGlideRes(resID) and not GLIDER_SUBS[st] then return false end
    if not R.insToRes[insID] then R.insToRes[insID] = resID end
    F.ensureDepotItemValid(insID, resID)
    F.saveEquip(resID, insID)
    F.ensureInjectedItemAlive(nil, resID, insID)
    local ready = F.isResourcesReady(resID)
    if not ready then F.requestResourceDownload(resID) end
    local bAircraft = false
    pcall(function()
        local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
        local st = F.subType(F.cfg(resID))
        bAircraft = ModelDisplayTypeHelper.IsGlideSmoke(st)
    end)
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.UpdateAircraftOrGliding then
            fbd:UpdateAircraftOrGliding(insID, bAircraft)
        elseif fbd.SetGliding then
            fbd:SetGliding(insID)
            if DataMgr.UpdateEffect then DataMgr.UpdateEffect(insID) end
        end
    end)
    if ready then
        local item = {
            res_id = resID, resID = resID,
            instid = insID, ins_id = insID, insID = insID,
            expire_ts = 0, expireTS = 0, count = 1,
        }
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_on_rsp(NET_OK, item, nil, 1, insID, 0)
    end
    return true
end

function F.syncAirborneToDataMgr()
    F.applyPersistSlotsToCache()
    local cch = F.cache()
    local paraRes = F.getDesiredParachuteRes()
    local gliderRes = F.getDesiredGliderRes()
    if paraRes and paraRes > 0 and not cch.parachuteIns then
        cch.parachuteIns = F.resolveInsForRes(paraRes)
        cch.parachuteRes = paraRes
    end
    if gliderRes and gliderRes > 0 and not cch.gliderIns then
        cch.gliderIns = F.resolveInsForRes(gliderRes)
        cch.gliderRes = gliderRes
    end
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if cch.parachuteIns and tonumber(cch.parachuteIns) > 0 then
            if fbd.SetParachute then fbd:SetParachute(cch.parachuteIns) end
            if DataMgr.roleData then DataMgr.roleData.parachute = tostring(cch.parachuteIns) end
        end
        if cch.gliderIns and tonumber(cch.gliderIns) > 0 then
            local bAircraft = false
            if cch.gliderRes then
                pcall(function()
                    local MDH = require("client.logic.avatar.ModelDisplayTypeHelper")
                    bAircraft = not MDH.IsGlideSmoke(F.subType(F.cfg(cch.gliderRes)))
                end)
            end
            if fbd.UpdateAircraftOrGliding then
                fbd:UpdateAircraftOrGliding(cch.gliderIns, bAircraft)
            elseif fbd.SetGliding then
                fbd:SetGliding(cch.gliderIns)
                if DataMgr.UpdateEffect then DataMgr.UpdateEffect(cch.gliderIns) end
            end
            if DataMgr.roleData then
                if bAircraft then
                    DataMgr.roleData.aircraft_put_id = tostring(cch.gliderIns)
                    DataMgr.gliding = cch.gliderIns
                else
                    DataMgr.roleData.gliding = tostring(cch.gliderIns)
                end
            end
        end
    end)
end

function F.putOnGenericInjected(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then return end
    if not F.isResourcesReady(resID) then
        F.requestResourceDownload(resID)
        return
    end
    F.saveEquip(resID, insID)
    local WRH = require("client.network.Protocol.WardRobeHandler")
    WRH.on_depot_put_on_rsp(NET_OK, { res_id = resID, count = 1, instid = insID }, nil, 1, insID, 0)
end

function F.clearEquipCache(resID)
    local st = F.subType(F.cfg(resID))
    local cch = F.cache()
    if st == OUTFIT_SUB then
        if F.wardrobeTab(resID) == TAB_CLOTHES then
            cch.tshirtRes, cch.tshirtIns = nil, nil
            _G.AddOutfitLastLobbyTshirtRes = nil
            F.persistForgetSlot("tshirt")
        else
            cch.outfitRes, cch.outfitIns = nil, nil
            _G.AddOutfitLastLobbyOutfitRes = nil
            F.persistForgetSlot("outfit")
        end
    elseif st == HAT_SUB or HEAD_SUBS[st] then
        cch.hatRes, cch.hatIns = nil, nil
        _G.AddOutfitLastLobbyHatRes = nil
        F.persistForgetSlot("hat")
    elseif st == MASK_SUB then
        cch.maskRes, cch.maskIns = nil, nil
        _G.AddOutfitLastLobbyMaskRes = nil
        F.persistForgetSlot("mask")
    elseif st == GLASS_SUB then
        cch.glassRes, cch.glassIns = nil, nil
        _G.AddOutfitLastLobbyGlassRes = nil
        F.persistForgetSlot("glass")
    elseif st == PANTS_SUB then
        cch.pantsRes, cch.pantsIns = nil, nil
        _G.AddOutfitLastLobbyPantsRes = nil
        F.persistForgetSlot("pants")
    elseif st == SHOES_SUB then
        cch.shoesRes, cch.shoesIns = nil, nil
        _G.AddOutfitLastLobbyShoesRes = nil
        F.persistForgetSlot("shoes")
    elseif BAG_SUBS[st] then
        cch.bagRes, cch.bagIns = nil, nil
        _G.AddOutfitLastLobbyBagRes = nil
        F.persistForgetSlot("bag")
    elseif HELMET_SUBS[st] then
        cch.helmetRes, cch.helmetIns = nil, nil
        _G.AddOutfitLastLobbyHelmetRes = nil
        F.persistForgetSlot("helmet")
    elseif st == PARACHUTE_SUB then
        cch.parachuteRes, cch.parachuteIns = nil, nil
        _G.AddOutfitLastLobbyParachuteRes = nil
        F.persistForgetSlot("parachute")
    elseif F.isGlideRes(resID) then
        cch.gliderRes, cch.gliderIns = nil, nil
        _G.AddOutfitLastLobbyGliderRes = nil
        F.persistForgetSlot("glider")
    elseif st == GLOVES_SUB then
        cch.glovesRes, cch.glovesIns = nil, nil
        _G.AddOutfitLastLobbyGlovesRes = nil
        F.persistForgetSlot("gloves")
    end
    _matchApplied = false
    F.invalidateSocialWearCache()
    F.perfInvalidateLobby()
    F.persistMarkDirty()
end

function F.takeOffInjected(insID)
    insID = tonumber(insID)
    local resID = R.insToRes[insID]
    if not resID then return end
    local st = F.subType(F.cfg(resID))

    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        WRH.on_depot_put_down_rsp(NET_OK, { res_id = resID, count = 1 }, insID)
    end)

    pcall(function()
        local AvatarData = require("client.logic.data.AvatarData")
        AvatarData.RemoveRoleWearDataByValue(insID)
    end)
    if st == HAT_SUB or HEAD_SUBS[st] then
        pcall(function()
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag and tonumber(bag.head_show) == insID then fbd:SetHeadShow(0) end
        end)
    end
    if BAG_SUBS[st] or HELMET_SUBS[st] then
        pcall(function()
            local t = DataMgr.equipmentSkinInsIDTable
            if t then
                for _, k in ipairs({ st, 504, 505 }) do
                    if tonumber(t[k]) == insID then t[k] = 0 end
                end
            end
            local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
            local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
            if bag then
                if tonumber(bag.bag_skin) == insID then bag.bag_skin = 0 end
                if tonumber(bag.helmet_skin) == insID then bag.helmet_skin = 0 end
            end
        end)
    end

    F.clearEquipCache(resID)
    pcall(function() F.syncFashionBagRolewear() end)
end

function F.syncWeaponArmorySilent(weaponID, insID)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or not F.isInjectedIns(insID) then return end
    local resID = R.insToRes[insID]
    if not resID then return end
    local Arm = require("client.logic.armory.logic_armory")
    Arm.rsp_list = Arm.rsp_list or { skin_list = {}, install_list = {} }
    Arm.rsp_list.install_list = Arm.rsp_list.install_list or {}
    F.injectArmory(resID, insID)
    Arm.rsp_list.install_list[weaponID] = { skin_id = insID }
    pcall(function()
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        if fbd.UpdateCurrentFashionBagWeaponSkin then
            fbd:UpdateCurrentFashionBagWeaponSkin(weaponID, insID)
        end
    end)
end

function F.equipWeaponSkin(weaponID, insID, forceVisual)
    weaponID, insID = tonumber(weaponID), tonumber(insID)
    if not weaponID or not insID or not F.isInjectedIns(insID) then return false end
    local resID = R.insToRes[insID]
    if not resID then return false end

    _G.AddOutfitWeaponEquipped = _G.AddOutfitWeaponEquipped or {}
    if not forceVisual and F.isWeaponVisuallyEquipped(weaponID, insID) then
        F.syncWeaponArmorySilent(weaponID, insID)
        return false
    end
    F.saveEquip(resID, insID)

    local Arm = require("client.logic.armory.logic_armory")
    local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local HT = require("client.logic.lobby.hall_theme_utils")
    local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")

    F.injectArmory(resID, insID)
    Arm.rsp_list.install_list[weaponID] = { skin_id = insID }
    if fbd.UpdateCurrentFashionBagWeaponSkin then
        fbd:UpdateCurrentFashionBagWeaponSkin(weaponID, insID)
    end

    local bagIdx = fbd:GetFashionBagUseIndex()
    HT.proc_skin_list_chg("weapon_skin", weaponID, insID, bagIdx, {})

    wgl:SetGunID(weaponID)
    wgl:UpdateCurrentGunAvatar(weaponID, insID)

    if EventSystem and EVENTTYPE_ARMORY and EVENTID_ARMORY_EQUIP_STAT_CHANGE then
        EventSystem:postEvent(EVENTTYPE_ARMORY, EVENTID_ARMORY_EQUIP_STAT_CHANGE, resID)
    end
    if EventSystem and EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, resID)
    end
    _G.AddOutfitWeaponEquipped[weaponID] = insID
    return true
end

local SOCIAL = _G.AddOutfitSocialState or {}
_G.AddOutfitSocialState = SOCIAL
SOCIAL.debGen = SOCIAL.debGen or 0
SOCIAL.wearPatchKey = SOCIAL.wearPatchKey or nil
SOCIAL.snapshotKey = SOCIAL.snapshotKey or nil
SOCIAL.fullSnapshot = SOCIAL.fullSnapshot or nil

function F.socialDebounce(sec, fn)
    SOCIAL.debGen = (SOCIAL.debGen or 0) + 1
    local gen = SOCIAL.debGen
    F.later(sec, function()
        if gen ~= SOCIAL.debGen then return end
        pcall(fn)
    end)
end

function F.getLobbyCurPage()
    local p = nil
    pcall(function()
        local LMC = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
        if LMC.GetCurPage then p = LMC.GetCurPage() end
    end)
    return p
end

function F.isLobbyLeftPage()
    return ENUM_LobbyPageType and F.getLobbyCurPage() == ENUM_LobbyPageType.Left
end

function F.getWeaponSkinResFast()
    local cch = F.cache()
    local wid = tonumber(DataMgr.Weapon_ID) or 0
    local w = wid > 0 and cch.weapons[wid] or nil
    if w and w.resID and w.resID > 0 then return w.resID end
    for _, ww in pairs(cch.weapons) do
        if ww.resID and ww.resID > 0 then return ww.resID end
    end
    return nil
end

function F.resolveLobbyWeaponSkinRes()
    if LOBBY.skinResolved then return LOBBY.cachedSkin end
    local wid = tonumber(DataMgr.Weapon_ID) or 0
    local skin = F.getWeaponSkinResFast()
    if skin and skin > 0 then return skin end

    if wid > 0 then
        local fromMatch = F.getMatchWeaponSkin(wid)
        if fromMatch and fromMatch > 0 then return fromMatch end
    end
    if MATCH_CONFIG.weaponSkins then
        for _, s in pairs(MATCH_CONFIG.weaponSkins) do
            s = tonumber(s)
            if s and s > 0 then return s end
        end
    end

    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        local entry = Arm.rsp_list and Arm.rsp_list.install_list
            and Arm.rsp_list.install_list[wid > 0 and wid or 101004]
        local insID = tonumber(entry and entry.skin_id) or 0
        if insID > 0 and F.isInjectedIns(insID) then
            skin = tonumber(R.insToRes[insID])
        elseif insID > 0 then
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(insID)
            if d and d.resID then skin = tonumber(d.resID) end
        end
    end)
    if skin and skin > 0 then return skin end

    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        if wgl.GetSkinIdByWeaponID and wid > 0 then
            local insID = tonumber(wgl:GetSkinIdByWeaponID(wid)) or 0
            if insID > 0 and F.isInjectedIns(insID) then
                skin = tonumber(R.insToRes[insID])
            end
        end
    end)
    LOBBY.skinResolved = true
    LOBBY.cachedSkin = (skin and skin > 0) and skin or nil
    return LOBBY.cachedSkin
end

function F.resolveLobbyOutfitRes()
    if LOBBY.outfitResolved then return LOBBY.cachedOutfit end
    local cch = F.cache()
    local outfitRes = tonumber(cch.outfitRes) or 0
    if outfitRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = outfitRes
        return outfitRes
    end
    outfitRes = tonumber(_G.AddOutfitLastLobbyOutfitRes) or 0
    if outfitRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = outfitRes
        return outfitRes
    end
    if MATCH_CONFIG.outfitRes and tonumber(MATCH_CONFIG.outfitRes) > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = tonumber(MATCH_CONFIG.outfitRes)
        return LOBBY.cachedOutfit
    end

    local injectedRes, anyRes
    pcall(function()
        local AvatarData = require("client.logic.data.AvatarData")
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        local function resFromIns(ins)
            ins = tonumber(ins)
            if not ins or ins <= 0 then return nil end
            if F.isInjectedIns(ins) then return tonumber(R.insToRes[ins]) end
            local d = wd:GetHallDepotItemDataByInsID(ins)
            return d and tonumber(d.resID) or nil
        end
        for _, ins in pairs(AvatarData.GetRoleWear()) do
            local res = resFromIns(ins)
            if res and F.isSuitRes(res) then
                if F.isInjectedRes(res) then injectedRes = res end
                anyRes = anyRes or res
            end
        end
        local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local bag = fbd.GetCurrentFashionBag and fbd:GetCurrentFashionBag()
        if bag and bag.rolewear_list then
            for _, ins in pairs(bag.rolewear_list) do
                local res = resFromIns(ins)
                if res and F.isSuitRes(res) then
                    if F.isInjectedRes(res) then injectedRes = res end
                    anyRes = anyRes or res
                end
            end
        end
    end)
    if injectedRes and injectedRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = injectedRes
        return injectedRes
    end
    if anyRes and anyRes > 0 then
        LOBBY.outfitResolved = true
        LOBBY.cachedOutfit = anyRes
        return anyRes
    end
    LOBBY.outfitResolved = true
    LOBBY.cachedOutfit = nil
    return nil
end

function F.rememberLobbyOutfitRes(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 or not F.isSuitRes(resID) then return end
    _G.AddOutfitLastLobbyOutfitRes = resID
    F.invalidateLobbyResolved()
    local cch = F.cache()
    if not cch.outfitRes or cch.outfitRes <= 0 then
        cch.outfitRes = resID
        if F.isInjectedRes(resID) then cch.outfitIns = R.resToIns[resID] end
    end
end

function F.wearPatchKey()
    local outfit = F.resolveLobbyOutfitRes() or 0
    local skin = F.resolveLobbyWeaponSkinRes() or 0
    local openGun = 1
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data and lds.data.OpenGun ~= nil then openGun = lds.data.OpenGun and 1 or 0 end
    end)
    return outfit .. "_" .. skin .. "_" .. openGun
end

function F.syncDepotShowWeaponFlags(depot)
    depot = depot or {}
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data then
            if lds.data.OpenGun ~= nil then depot.weapon = lds.data.OpenGun end
            if lds.data.OpenSocialWeapon ~= nil then depot.social_weapon = lds.data.OpenSocialWeapon end
        end
    end)
    return depot
end

function F.applyInjectedPspace(roleData)
    if not roleData then return end
    roleData.bshow = true
    roleData.pspace_wear_ext = roleData.pspace_wear_ext or {}
    local outfitRes = F.resolveLobbyOutfitRes()
    if outfitRes and outfitRes > 0 then
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = { outfitRes, 0, 0 }
    end
    local skinRes = F.resolveLobbyWeaponSkinRes()
    if skinRes and skinRes > 0 then
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON] = { 0, 0, 0 }
        roleData.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN] = { skinRes, 0, 0 }
        roleData.depot_show_info = roleData.depot_show_info or {}
        if roleData.depot_show_info.weapon == nil then
            roleData.depot_show_info.weapon = true
        end
    end
    roleData.depot_show_info = F.syncDepotShowWeaponFlags(roleData.depot_show_info)
end

function F.patchSelfWearCache(force)
    local key = F.wearPatchKey()
    if not force and SOCIAL.wearPatchKey == key then return false end
    SOCIAL.wearPatchKey = key
    SOCIAL.snapshotKey = nil
    SOCIAL.fullSnapshot = nil

    local myUid = tonumber(DataMgr.roleData.uid)
    if not myUid then return false end

    local changed = false
    pcall(function()
        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
        local d = BD:GetCacheData(myUid)
        if not d then
            BD:OnHandleMsgDataAndCallback(myUid, F.buildLocalRoleDataForCoupleAvatar())
            return true
        end
        local oldCloth = d.pspace_wear_ext and d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
        local oldSkin = d.pspace_wear_ext and d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN]
        F.applyInjectedPspace(d)
        local nc = d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH]
        local ns = d.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN]
        if oldCloth ~= nc or oldSkin ~= ns or not d.bshow then changed = true end
    end)
    return force or changed
end

function F.requestSocialAvatarRefresh()
    pcall(function()
        if EventSystem and EVENTTYPE_LOBBY_SOCIAL and EVENTID_SOCIAL_LOBBY_REFRESH_AVATAR then
            EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_REFRESH_AVATAR)
        end
    end)
end

function F.onSocialWearDirty(forceRefresh)
    SOCIAL.lastHandSkin = nil
    if F.patchSelfWearCache(forceRefresh) then
        F.requestSocialAvatarRefresh()
    end
end

function F.buildLocalRoleDataForCoupleAvatar()
    local key = F.wearPatchKey()
    if SOCIAL.fullSnapshot and SOCIAL.snapshotKey == key then
        return SOCIAL.fullSnapshot
    end
    F.syncWeaponCacheFromLobby()
    local cch = F.cache()
    local ad = DataMgr.avatarData or {}
    local gender = tonumber(ad.gamegender) or 2
    if gender < 1 then gender = 2 end

    local data = {
        uid = DataMgr.roleData.uid,
        gender = gender,
        bshow = true,
        pspace_wear_ext = {
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HEAD] = { tonumber(ad.headid) or 401993, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_HAIR] = { tonumber(ad.hairid) or 40601001, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON] = { 0, 0, 0 },
            [ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN] = { 0, 0, 0 },
        },
        depot_show_info = {
            weapon = true, social_weapon = true, idle = true,
            helmet = true, bag = true, vehicle = true, hand = true,
        },
    }

    local outfitRes = F.resolveLobbyOutfitRes()
    if outfitRes and outfitRes > 0 then
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_CLOTH] = { outfitRes, 0, 0 }
    end

    local skinRes = F.resolveLobbyWeaponSkinRes()
    if skinRes and skinRes > 0 then
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPON][1] = 0
        data.pspace_wear_ext[ENUM_AVATAR_SHOW_TYPE.SHOW_POS_WEAPONSKIN][1] = skinRes
    end
    data.depot_show_info = F.syncDepotShowWeaponFlags(data.depot_show_info)
    SOCIAL.fullSnapshot = data
    SOCIAL.snapshotKey = F.wearPatchKey()
    return data
end

local _myUidCached
function F.isMyWearData(wearData)
    if not wearData then return false end
    if not _myUidCached then
        pcall(function() _myUidCached = tonumber(DataMgr.roleData.uid) end)
    end
    return _myUidCached and tonumber(wearData.uid) == _myUidCached
end

function F.mergeInjectedWeaponIntoWearData(wearData)
    if not F.isMyWearData(wearData) then return end
    local skinRes = F.resolveLobbyWeaponSkinRes()
    wearData.depot_show_info = F.syncDepotShowWeaponFlags(wearData.depot_show_info)
    if not skinRes or skinRes <= 0 then return end
    wearData.mainWeaponInfo = wearData.mainWeaponInfo or {
        weaponResId = 0, weaponSkinId = 0,
        diyInfo = { diyWeaponId = 0, diyDefaultScheme = false, diyScheme = nil },
    }
    if wearData.mainWeaponInfo.weaponSkinId == skinRes
        and (tonumber(wearData.mainWeaponInfo.weaponResId) or 0) == 0 then
        return
    end
    wearData.mainWeaponInfo.weaponSkinId = skinRes
    wearData.mainWeaponInfo.weaponResId = 0
end

function F.equipSocialHandWeapon(avatar, skinRes)
    if not avatar or not skinRes or skinRes <= 0 then return end
    if SOCIAL.lastHandSkin == skinRes then return end
    SOCIAL.lastHandSkin = skinRes
    pcall(function()
        avatar:PutonEquipment(skinRes, nil, { bIsUse = true })
    end)
end

function F.shouldShowHandWeapon()
    local show = true
    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        if lds.data and lds.data.OpenGun ~= nil then
            show = lds.data.OpenGun ~= false
        end
    end)
    return show
end

function F.mergeInjectedOutfitIntoWearData(wearData)
    if not F.isMyWearData(wearData) then return end
    local outfitRes = F.resolveLobbyOutfitRes()
    if not outfitRes or outfitRes <= 0 then return end
    F.rememberLobbyOutfitRes(outfitRes)
    local AvatarData = require("client.logic.data.AvatarData")
    local converted = AvatarData.ConvertToAvatarCustom({ outfitRes, 0, 0 })
    if not converted then return end
    wearData.WearInfoList = wearData.WearInfoList or {}
    local replaced = false
    for i, e in ipairs(wearData.WearInfoList) do
        if e and e.ItemID and F.isSuitRes(e.ItemID) then
            wearData.WearInfoList[i] = converted
            replaced = true
            break
        end
    end
    if not replaced then
        table.insert(wearData.WearInfoList, converted)
    end
end

function F.mergeInjectedIntoWearData(wearData)
    if not wearData then return end
    F.mergeInjectedWeaponIntoWearData(wearData)
    F.mergeInjectedOutfitIntoWearData(wearData)
end

function F.reapplyLobbyEquipped()
    -- [FIX VIP] Chặn không cho sảnh đắp lại skin ảo khi bạn đã tắt công tắc
    if not _G.LexusConfig.ModSkin then return end
    
    if not GameStatus or not GameStatus.IsInLobbyOrMainCity or not GameStatus.IsInLobbyOrMainCity() then
        return
    end
    F.syncWeaponCacheFromLobby()
    F.applyPersistSlotsToCache()
    local curPage = F.getLobbyCurPage()

    if ENUM_LobbyPageType and curPage == ENUM_LobbyPageType.Left then
        F.onSocialWearDirty(true)
        return
    end

    local cch = F.cache()
    if cch.outfitIns and F.isInjectedIns(cch.outfitIns) then
        F.putOnOutfit(cch.outfitIns)
    end
    if cch.hatIns and F.isInjectedIns(cch.hatIns) then
        F.putOnHat(cch.hatIns)
    end
    if cch.maskIns and F.isInjectedIns(cch.maskIns) then
        F.putOnRoleWear(cch.maskIns)
    end
    if cch.glassIns and F.isInjectedIns(cch.glassIns) then
        F.putOnRoleWear(cch.glassIns)
    end
    if cch.tshirtIns and F.isInjectedIns(cch.tshirtIns) then
        F.putOnRoleWear(cch.tshirtIns)
    end
    if cch.pantsIns and F.isInjectedIns(cch.pantsIns) then
        F.putOnRoleWear(cch.pantsIns)
    end
    if cch.shoesIns and F.isInjectedIns(cch.shoesIns) then
        F.putOnRoleWear(cch.shoesIns)
    end
    if cch.bagIns and F.isInjectedIns(cch.bagIns) then
        F.putOnRoleWear(cch.bagIns)
    end
    if cch.helmetIns and F.isInjectedIns(cch.helmetIns) then
        F.putOnRoleWear(cch.helmetIns)
    end
    if cch.parachuteIns then
        F.putOnParachute(cch.parachuteIns)
    end
    if cch.gliderIns then
        F.putOnGlider(cch.gliderIns)
    end
    if cch.glovesIns and F.isInjectedIns(cch.glovesIns) then
        F.putOnGloves(cch.glovesIns)
    end

    local mainWid = tonumber(DataMgr.Weapon_ID) or 0
    local w = mainWid > 0 and cch.weapons[mainWid] or nil
    if w and w.resID and w.resID > 0 then
        if w.insID and F.isInjectedIns(w.insID) then
            F.equipWeaponSkin(mainWid, w.insID)
        else
            pcall(function() DataMgr.InitWeaponData(mainWid, w.resID, w.insID or 0) end)
        end
    end

    pcall(function()
        local uid = tostring(DataMgr.roleData.uid)
        local LAM = require("client.logic.avatar.LobbyAvatarManager")
        local TAM = require("client.logic.avatar.logic_team_avatar_manager")
        if w and w.resID and w.resID > 0 and TAM.GetAvatarByUid(uid) then
            LAM.EquipWeapon(uid, { weaponId = mainWid, skinId = w.resID }, nil, true)
        end
    end)

    F.reapplyVehicleSlotsFromConfig(true)
    F.reapplyHallThemeFromConfig(true)
    F.reapplyWeaponsFromConfig()
    pcall(F.applyVehicleSkinsToPC)
end

F.scheduleLobbyReapplyOnce = function()
    if LOBBY.reapplyDone or LOBBY.reapplyScheduled then return end
    LOBBY.reapplyScheduled = true
    F.later(2.0, function()
        LOBBY.reapplyScheduled = false
        if LOBBY.reapplyDone then return end
        LOBBY.reapplyDone = true
        F.reapplyLobbyEquipped()
    end)
end

function F.hookLobbySwipePersistence()
    if _G.AddOutfitLobbySwipeHooked then return end
    _G.AddOutfitLobbySwipeHooked = true
    pcall(function()
        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
        local oRsp = BD.on_get_avatar_show_rsp
        BD.on_get_avatar_show_rsp = function(self, res, target_uid, data)
            oRsp(self, res, target_uid, data)
                if tonumber(target_uid) == tonumber(DataMgr.roleData.uid) then
                F.patchSelfWearCache(true)
                SOCIAL.forceAvatarRedraw = true
                SOCIAL.lastHandSkin = nil
                if ENUM_LobbyPageType and F.getLobbyCurPage() == ENUM_LobbyPageType.Left then
                    F.requestSocialAvatarRefresh()
                end
            end
        end
    end)

    pcall(function()
        local AC = require("client.slua.logic.avatar.avatar_common")
        local oGetWear = AC.GetWearDataFromRoleData
        AC.GetWearDataFromRoleData = function(roleData)
            local wearData = oGetWear(roleData)
            if wearData and roleData and tonumber(roleData.uid) == tonumber(DataMgr.roleData.uid)
                and F.isLobbyLeftPage() then
                F.mergeInjectedIntoWearData(wearData)
            end
            return wearData
        end
        local oUp = AC.UpdateAvatar
        AC.UpdateAvatar = function(avatar, wearData, isShowWeapon, isShowHelmet, isShowBag)
            if F.isMyWearData(wearData) and F.isLobbyLeftPage() then
                F.mergeInjectedIntoWearData(wearData)
            end
            local showGun = isShowWeapon and F.shouldShowHandWeapon()
            if wearData and wearData.depot_show_info then
                showGun = showGun and wearData.depot_show_info.weapon ~= false
            end
            if F.isMyWearData(wearData) and F.isLobbyLeftPage() then
                for _, e in ipairs(wearData.WearInfoList or {}) do
                    if e and e.ItemID and F.isInjectedRes(e.ItemID) and F.isSuitRes(e.ItemID) then
                        F.rememberLobbyOutfitRes(e.ItemID)
                        break
                    end
                end
            end
            local ret = oUp(avatar, wearData, showGun, isShowHelmet, isShowBag)
            if showGun and F.isMyWearData(wearData) and avatar and F.isLobbyLeftPage() then
                local skin = tonumber(wearData.mainWeaponInfo and wearData.mainWeaponInfo.weaponSkinId) or 0
                if skin <= 0 then skin = F.resolveLobbyWeaponSkinRes() or 0 end
                if skin > 0 then F.equipSocialHandWeapon(avatar, skin) end
            end
            return ret
        end
    end)

    pcall(function()
        local CA = require("client.logic.avatar.CoupleAvatar")
        local Cfg = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
        local oMulti = CA._UpdateMultiAvatar
        if oMulti then
            CA._UpdateMultiAvatar = function(self, avatar, avatarType)
                local isSelf = avatarType == Cfg.AvatarType.Self
                    and self.SelfUID and tostring(self.SelfUID) == tostring(DataMgr.roleData.uid)
                if isSelf and F.isLobbyLeftPage() then
                    pcall(function()
                        local BD = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
                        local d = BD:GetCacheData(tonumber(self.SelfUID))
                        if d then F.applyInjectedPspace(d) end
                    end)
                    if SOCIAL.forceAvatarRedraw then
                        self.CompareDataCache[avatarType] = nil
                        SOCIAL.forceAvatarRedraw = nil
                    end
                end
                oMulti(self, avatar, avatarType)
                if isSelf and F.isLobbyLeftPage() and self.isShowWeapon ~= false and F.shouldShowHandWeapon() then
                    local skin = F.resolveLobbyWeaponSkinRes()
                    if skin and skin > 0 then F.equipSocialHandWeapon(avatar, skin) end
                end
            end
        end
        local oHideCheck = CA.CheckSelfIsHideAvatar
        CA.CheckSelfIsHideAvatar = function(self, nSelfUId, tRoleData)
            if F.isLobbyLeftPage() and tostring(nSelfUId) == tostring(DataMgr.roleData.uid) then
                return false
            end
            return oHideCheck(self, nSelfUId, tRoleData)
        end

        local oUpdate = CA.Update
        CA.Update = function(self)
            if not F.isLobbyLeftPage() then
                return oUpdate(self)
            end
            local isSelf = self.SelfUID and tostring(self.SelfUID) == tostring(DataMgr.roleData.uid)
            local oHide = CA.HideAvatars
            if isSelf then
                CA.HideAvatars = function() end
            end
            local ok, err = pcall(oUpdate, self)
            CA.HideAvatars = oHide
        end

        local oRecv = CA.OnReceiveData
        CA.OnReceiveData = function(self, uid, data)
            if F.isLobbyLeftPage() and uid == self.SelfUID and tostring(uid) == tostring(DataMgr.roleData.uid) then
                if data then
                    F.applyInjectedPspace(data)
                else
                    data = F.buildLocalRoleDataForCoupleAvatar()
                end
            end
            return oRecv(self, uid, data)
        end
    end)

    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_LOBBY and EVENTID_SWITCHTO_PAGE_START then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, function(_, _, toPage)
                if ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Left then
                    F.syncWeaponCacheFromLobby()
                    SOCIAL.lastHandSkin = nil
                    local o = F.resolveLobbyOutfitRes()
                    if o then F.rememberLobbyOutfitRes(o) end
                    F.patchSelfWearCache(true)
                    SOCIAL.forceAvatarRedraw = true
                end
            end)
        end
        if EVENTTYPE_LOBBY and EVENTID_SWITCHTO_PAGE_END then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, function(_, _, _, toPage)
                if ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Left then
                    F.syncWeaponCacheFromLobby()
                    SOCIAL.lastHandSkin = nil
                    F.socialDebounce(0.45, function()
                        F.onSocialWearDirty(true)
                    end)
                elseif ENUM_LobbyPageType and toPage == ENUM_LobbyPageType.Mid then
                    SOCIAL.wearPatchKey = nil
                    F.invalidateLobbyResolved()
                    if not LOBBY.reapplyDone then
                        F.socialDebounce(0.5, F.scheduleLobbyReapplyOnce)
                    end
                end
            end)
        end
        if EVENTTYPE_LOBBY_SOCIAL and EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA then
            EventSystem:registEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_GOT_SOCIAL_LOBBY_SHOW_DATA, function(_, _, nUId)
                if tonumber(nUId) == tonumber(DataMgr.roleData.uid) then
                    F.socialDebounce(0.2, function() F.patchSelfWearCache(false) end)
                end
            end)
        end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, function()
                SOCIAL.wearPatchKey = nil
                SOCIAL.snapshotKey = nil
                F.syncWeaponCacheFromLobby()
                
                local curPage = ENUM_LobbyPageType and F.getLobbyCurPage()
                if curPage == ENUM_LobbyPageType.Left then
                    F.socialDebounce(0.25, function() F.onSocialWearDirty(true) end)
                end
                
                -- [FIX LỖI VIP] Tự động đắp lại Skin Mod khi game có dấu hiệu update súng ở sảnh
                F.socialDebounce(0.3, function()
                    if F.reapplyLobbyEquipped then F.reapplyLobbyEquipped() end
                end)
            end)
        end
    end)

    pcall(function()
        local lds = require("client.slua.logic.wardrobe.logic_display_setting")
        local oSwitch = lds.SwitchGun
        lds.SwitchGun = function(...)
            local r = oSwitch(...)
            SOCIAL.wearPatchKey = nil
            
            local curPage = ENUM_LobbyPageType and F.getLobbyCurPage()
            if curPage == ENUM_LobbyPageType.Left then
                F.socialDebounce(0.2, function() F.onSocialWearDirty(true) end)
            end
            
            -- [FIX LỖI VIP] Khi Click vào ô vũ khí ở Sảnh, đợi game đổi súng gốc xong thì 0.3s sau đắp skin Mod lên lại
            F.socialDebounce(0.3, function()
                if F.reapplyLobbyEquipped then F.reapplyLobbyEquipped() end
            end)
            
            return r
        end
    end)
end

function F.hookDepotInit()
    pcall(function()
        local WDE = require("client.slua.logic.wardrobe.WardrobeDataEntity")
        if WDE._AddOutfitInitHooked then return end
        WDE._AddOutfitInitHooked = true
        local orig = WDE.InitData
        WDE.InitData = function(self, pkg)
            orig(self, pkg)
            _G.AddOutfitUnexpireDone = false
            pcall(function()
                if F.injectAll(self) then
                    F.scheduleInjectRefresh()
                    LOBBY.reapplyDone = false
                    LOBBY.reapplyScheduled = false
                    F.scheduleLobbyReapplyOnce()
                end
            end)
        end
    end)
end

function F.hookWardrobeData()
    pcall(function()
        local wd = require("client.slua.logic.wardrobe.wardrobe_data")
        if wd._AddOutfitDataHooked then return end
        wd._AddOutfitDataHooked = true
        local function wrapGet(name)
            local o = wd[name]
            if not o then return end
            wd[name] = function(self, insID, ...)
                insID = tonumber(insID)
                local r
                if F.isInjectedIns(insID) then
                    local e = F.getEntity()
                    if e then r = e:GetDataByInsID(insID) end
                else
                    r = o(self, insID, ...)
                end
                if r and (F.isInjectedIns(insID) or F.isInjectedRes(r.resID or r.res_id)) then
                    r.expire_ts = 0
                    r.expireTS = 0
                    r.valid_hours = 0
                end
                return r
            end
        end
        wrapGet("GetHallDepotItemDataByInsID")
        wrapGet("GetValidHallDepotItemDataByInsID")
        local function wrapBool(name)
            local o = wd[name]
            if not o then return end
            wd[name] = function(self, id, ...)
                if F.isInjectedRes(tonumber(id)) or F.isInjectedIns(tonumber(id)) then return true end
                return o(self, id, ...)
            end
        end
        wrapBool("HasItem")
        wrapBool("HasValidItem")
        wrapBool("CheckHasPermanentItem")
    end)
end

function F.hookPageFilter()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl._AddOutfitPageFilterHooked then return end
        wl._AddOutfitPageFilterHooked = true
        local o1 = wl.IsValidCurrentPageItem
        wl.IsValidCurrentPageItem = function(self, mainTab, subTab, v, t)
            if v and F.isInjectedRes(v.resID) then
                local itemTab = tonumber(v.subTabType) or F.wardrobeTab(v.resID)
                if itemTab and itemTab == subTab then
                    if mainTab == PAGE_AVATAR or mainTab == PAGE_VEHICLE then return true end
                    if mainTab == PAGE_PARACHUTE and F.isHallThemeRes(v.resID) then return true end
                end
            end
            return o1(self, mainTab, subTab, v, t)
        end
        local o2 = wl.IsCanUse
        wl.IsCanUse = function(self, resId)
            if F.isInjectedRes(resId) then return true end
            return o2(self, resId)
        end
        local o3 = wl.IsCharacterUse
        wl.IsCharacterUse = function(self, resId)
            if F.isInjectedRes(resId) then return true end
            return o3(self, resId)
        end
        local o4 = wl.GetWardrobeInsIdByResId
        wl.GetWardrobeInsIdByResId = function(self, resid)
            resid = tonumber(resid)
            if F.isInjectedRes(resid) then return R.resToIns[resid] end
            return o4(self, resid)
        end
    end)
end

function F.hookArmory()
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        if Arm._AddOutfitArmoryHooked then return end
        Arm._AddOutfitArmoryHooked = true
        local oa = Arm.get_weapon_skin_list_rsp
        Arm.get_weapon_skin_list_rsp = function(a, b, c, d)
            oa(a, b, c, d)
            F.mergeInjectedArmorySkins()
        end
        local oi = Arm.install_weapon_skin
        Arm.install_weapon_skin = function(cd, wid, ins)
            ins = tonumber(ins)
            if F.isWeaponSkinIns(ins) then
                wid = tonumber(F.weaponIdFromSkin(R.insToRes[ins]) or wid)
                F.equipWeaponSkin(wid, ins)
                return
            end
            return oi(cd, wid, ins)
        end
    end)
    pcall(function()
        local AH = require("client.network.Protocol.ArmoryHandler")
        if AH._AddOutfitArmorySendHooked then return end
        AH._AddOutfitArmorySendHooked = true
        local o = AH.send_install_weapon_skin
        AH.send_install_weapon_skin = function(cd, wid, ins)
            ins = tonumber(ins)
            if F.isWeaponSkinIns(ins) then
                wid = tonumber(F.weaponIdFromSkin(R.insToRes[ins]) or wid)
                F.equipWeaponSkin(wid, ins)
                return
            end
            return o(cd, wid, ins)
        end
    end)
end

function F.hookGunSkinId()
    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        if wgl._AddOutfitGunSkinHooked then return end
        wgl._AddOutfitGunSkinHooked = true
        local o = wgl.GetSkinIdByWeaponID
        wgl.GetSkinIdByWeaponID = function(self, wid)
            local c = F.cache()
            local w = c.weapons[wid]
            if w and F.isWeaponSkinIns(w.insID) then return w.insID end
            local Arm = require("client.logic.armory.logic_armory")
            if Arm.rsp_list and Arm.rsp_list.install_list and Arm.rsp_list.install_list[wid] then
                local sid = Arm.rsp_list.install_list[wid].skin_id
                if sid and F.isWeaponSkinIns(sid) then return sid end
            end
            return o(self, wid)
        end
    end)
end

function F.hookPutOn()
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        if WRH._AddOutfitPutOnHooked then return end
        WRH._AddOutfitPutOnHooked = true
        local o = WRH.send_depot_put_on_req
        WRH.send_depot_put_on_req = function(insID, extra)
            insID = tonumber(insID)
            if F.tryLocalWearByIns(insID) then return end
            return o(insID, extra)
        end
    end)
end

function F.hookPutDown()
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        if WRH._AddOutfitPutDownHooked then return end
        WRH._AddOutfitPutDownHooked = true
        local o = WRH.send_depot_put_down_req
        WRH.send_depot_put_down_req = function(insID)
            if F.isInjectedIns(tonumber(insID)) then
                F.takeOffInjected(insID)
                return
            end
            return o(insID)
        end
        local ob = WRH.send_depot_batch_put_down_req
        WRH.send_depot_batch_put_down_req = function(instid_list)
            local rest = {}
            for _, id in ipairs(instid_list or {}) do
                if F.isInjectedIns(tonumber(id)) then
                    F.takeOffInjected(id)
                else
                    rest[#rest + 1] = id
                end
            end
            if #rest > 0 then return ob(rest) end
        end
    end)
end

function F.hookVehicleSwitchEffect()
    if _G.AddOutfitVehSwitchHooked then return end
    pcall(function()
        local VAC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")
        local impl = VAC and VAC.__inner_impl
        if not impl or impl._AddOutfitVehSwitchHooked then return end
        impl._AddOutfitVehSwitchHooked = true

        if not _G.AddOutfitVehOrigCanSwitch then
            _G.AddOutfitVehOrigCanSwitch = impl.CheckCanPlaySkinSwitchEffect
        end
        impl.CheckCanPlaySkinSwitchEffect = function(self, curVehicleId, lastVehicleId)
            if self.IsLobbyActor and self:IsLobbyActor() then return false end
            if not F.isInRealMatch() then return false end
            return true
        end

        if not _G.AddOutfitVehOrigShowSwitch then
            _G.AddOutfitVehOrigShowSwitch = impl.ShowVehicleSwitchEffect
        end
        impl.ShowVehicleSwitchEffect = function(self)
            if self.IsLobbyActor and self:IsLobbyActor() then return false end
            if not F.isInRealMatch() then return false end
            if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
                self.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
            end
            local vehicleActor = self:GetOwner()
            if not slua.isValid(vehicleActor) then return false end
            if self.uSwitchEffectActor then
                self:StopSkinSwitchEffect()
                pcall(function() self.uSwitchEffectActor:K2_DestroyActor() end)
                self.uSwitchEffectActor = nil
            end
            if not self.lastEquipedAvatarId or self.lastEquipedAvatarId <= 0 then
                local defId = 0
                pcall(function() defId = self:GetDefaultAvatarID() or 0 end)
                self.lastEquipedAvatarId = vehicleActor.ClientUsedAvatarID or defId or 0
            end
            local currentAvatarID = vehicleActor.ClientUsedAvatarID or self.lastEquipedAvatarId or 0
            local bIsLobbyActor = self:IsLobbyActor()
            local world = slua_GameFrontendHUD:GetWorld()
            local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
            local SkinSwitchEffectActorPath = VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
            local BP_DissolveVehicleClass = import(SkinSwitchEffectActorPath)
            self.uSwitchEffectActor = world:SpawnActor(BP_DissolveVehicleClass, nil, nil, nil)
            if not slua.isValid(self.uSwitchEffectActor) then
                self.uSwitchEffectActor = nil
                return false
            end
            self.uSwitchEffectActor:K2_AttachToActor(vehicleActor, "None", 1, 1, 1, false)
            self.uSwitchEffectActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
            self.uSwitchEffectActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
            pcall(function() self:HideParticles() end)
            self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
            self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
            self.uSwitchEffectActor:StartVehicleSwitchEffect(
                vehicleActor, self.curSwitchEffectId, self.lastEquipedAvatarId, currentAvatarID, bIsLobbyActor)
            self.uOldVehicleMeshAnimClass = nil
            return true
        end

        if not _G.AddOutfitVehOrigBeginPlay then
            _G.AddOutfitVehOrigBeginPlay = impl.ReceiveBeginPlay
        end
        local oBegin = _G.AddOutfitVehOrigBeginPlay
        impl.ReceiveBeginPlay = function(self)
            oBegin(self)
            pcall(function()
                if self.uSwitchEffectActor then
                    self:StopSkinSwitchEffect()
                    pcall(function() self.uSwitchEffectActor:K2_DestroyActor() end)
                    self.uSwitchEffectActor = nil
                end
                self.lastEquipedAvatarId = 0
                if self.IsLobbyActor and self:IsLobbyActor() then
                    self.curSwitchEffectId = 0
                elseif F.isInRealMatch() then
                    self.curSwitchEffectId = VEH_SWITCH_EFFECT_ID
                else
                    self.curSwitchEffectId = 0
                end
            end)
        end

        if impl.LuaIsAssetsAlreadyAvailable and not _G.AddOutfitVehOrigAssets then
            _G.AddOutfitVehOrigAssets = impl.LuaIsAssetsAlreadyAvailable
            impl.LuaIsAssetsAlreadyAvailable = function(self, avatarId)
                if F.isVehicleSkinAllowed(tonumber(avatarId)) then return true end
                return _G.AddOutfitVehOrigAssets(self, avatarId)
            end
        end

        _G.AddOutfitVehSwitchHooked = true
    end)
end

function F.hookVehicleChassisLight()
    if _G.AddOutfitVehChassisHooked then return end
    pcall(function()
        local LIC = require("GameLua.Activity.Commercialize.Actor.ActorComponent.BP_VehicleLicenseComponentBase")
        if LIC and LIC.CheckHasVehicleDownloaded and not _G.AddOutfitVehOrigLicDownload then
            _G.AddOutfitVehOrigLicDownload = LIC.CheckHasVehicleDownloaded
            LIC.CheckHasVehicleDownloaded = function(self, itemID)
                local id = tonumber(itemID)
                if F.isVehicleSkinAllowed(id) or F.isChassisLightId(id) then return true end
                return _G.AddOutfitVehOrigLicDownload(self, itemID)
            end
        end
    end)
    pcall(function()
        local LVF = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
        if not LVF or LVF._AddOutfitChassisHooked then return end
        LVF._AddOutfitChassisHooked = true

        if not _G.AddOutfitVehOrigGetFeature then
            _G.AddOutfitVehOrigGetFeature = LVF.CheckHasGetFeatureItem
        end
        LVF.CheckHasGetFeatureItem = function(self, featureId)
            if F.isChassisLightId(featureId) then return true end
            return _G.AddOutfitVehOrigGetFeature(self, featureId)
        end

        if not _G.AddOutfitVehOrigEquippedFeature then
            _G.AddOutfitVehOrigEquippedFeature = LVF.CheckHasEquippedItem
        end
        LVF.CheckHasEquippedItem = function(self, featureId, vehicleId)
            -- [FIX VIP] Bổ sung check điều kiện ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                if F.isChassisLightId(featureId) then
                    return F.getDesiredChassisLight(vehicleId) == tonumber(featureId)
                end
            end
            return _G.AddOutfitVehOrigEquippedFeature(self, featureId, vehicleId)
        end

        if not _G.AddOutfitVehOrigEquipChassisData then
            _G.AddOutfitVehOrigEquipChassisData = LVF.GetEquipedChassisLightData
        end
        LVF.GetEquipedChassisLightData = function(self, vehicleId, source)
            -- [FIX VIP] Bổ sung check điều kiện ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                local our = F.getDesiredChassisLight(vehicleId)
                if our then return our end
            end
            return _G.AddOutfitVehOrigEquipChassisData(self, vehicleId, source)
        end

        if not _G.AddOutfitVehOrigChassisLightData then
            _G.AddOutfitVehOrigChassisLightData = LVF.GetVehicleChassisLightData
        end
        LVF.GetVehicleChassisLightData = function(self, uid, vehicleId, position, source)
            -- [FIX VIP] Bổ sung check điều kiện ModSkin
            if _G.LexusConfig and _G.LexusConfig.ModSkin ~= false then
                if uid and DataMgr and DataMgr.roleData and tonumber(uid) == tonumber(DataMgr.roleData.uid) then
                    local our = F.getDesiredChassisLight(vehicleId)
                    if our then return our end
                end
            end
            return _G.AddOutfitVehOrigChassisLightData(self, uid, vehicleId, position, source)
        end

        if not _G.AddOutfitVehOrigPutOnFeature then
            _G.AddOutfitVehOrigPutOnFeature = LVF.PutOnVehicleFeature
        end
        LVF.PutOnVehicleFeature = function(self, featureId, vehicleId)
            featureId = tonumber(featureId)
            vehicleId = tonumber(vehicleId)
            if F.isChassisLightId(featureId) then
                F.saveChassisLight(vehicleId, featureId)
                self.equip_chassis_light = self.equip_chassis_light or {}
                if vehicleId and vehicleId > 0 then
                    self.equip_chassis_light[vehicleId] = featureId
                end
                return
            end
            return _G.AddOutfitVehOrigPutOnFeature(self, featureId, vehicleId)
        end

        if not _G.AddOutfitVehOrigPutOffFeature then
            _G.AddOutfitVehOrigPutOffFeature = LVF.PutOffVehicleFeature
        end
        LVF.PutOffVehicleFeature = function(self, featureId, vehicleId)
            featureId = tonumber(featureId)
            vehicleId = tonumber(vehicleId)
            if F.isChassisLightId(featureId) then
                PERSIST.configChassisLightMap = PERSIST.configChassisLightMap or {}
                if vehicleId and vehicleId > 0 then
                    PERSIST.configChassisLightMap[vehicleId] = nil
                end
                if self.equip_chassis_light and vehicleId then
                    self.equip_chassis_light[vehicleId] = nil
                end
                F.persistMarkDirty()
                return
            end
            return _G.AddOutfitVehOrigPutOffFeature(self, featureId, vehicleId)
        end
    end)
    _G.AddOutfitVehChassisHooked = true
end

function F.hookVehicles()
    F.hookVehicleSwitchEffect()
    F.hookVehicleChassisLight()
    pcall(function()
        local WV = require("client.slua.umg.Wardrobe.subtab_vehicles")
        if not WV or WV._AddOutfitVehClickHooked then return end
        WV._AddOutfitVehClickHooked = true
        local oClick = WV.ClickItem
        WV.ClickItem = function(self, vehicleSkin, bForceUsing)
            if vehicleSkin and F.isInjectedRes(vehicleSkin.res_id) then
                vehicleSkin.expireTS = 0
                vehicleSkin.expire_ts = 0
            end
            return oClick(self, vehicleSkin, bForceUsing)
        end
        local oDrop = WV.OnVehicleSlotDrop
        if oDrop then
            WV.OnVehicleSlotDrop = function(self, DragWidget, Index, DragDropData)
                pcall(function()
                    local ins = DragDropData and DragDropData.ins_id
                    if F.isInjectedIns(tonumber(ins)) then
                        F.ensureInjectedItemAlive(nil, nil, ins)
                    end
                end)
                return oDrop(self, DragWidget, Index, DragDropData)
            end
        end
    end)
    pcall(function()
        local WNH = require("client.network.Protocol.WardrobeNewHandler")
        if WNH._AddOutfitVehicleHooked then return end
        WNH._AddOutfitVehicleHooked = true
        local oMod = WNH.send_depot_modify_combat_vehicle_req
        WNH.send_depot_modify_combat_vehicle_req = function(instid, slot_index, ope_type)
            if F.modifyInjectedVehicleSlot(instid, slot_index, ope_type == true) then return end
            return oMod(instid, slot_index, ope_type)
        end
        local oRsp = WNH.on_depot_modify_combat_vehicle_rsp
        WNH.on_depot_modify_combat_vehicle_rsp = function(err_code, knapsack_vst)
            if err_code == 0 or err_code == NET_OK then
                knapsack_vst = F.mergeInjectedIntoVehicleSlotList(knapsack_vst)
            end
            oRsp(err_code, knapsack_vst)
            if err_code == 0 or err_code == NET_OK then
                F.syncVehicleSlotsToDataMgr()
                F.equipVehicleTypesFromConfig(PERSIST.configVehicleSlots)
                if not (_G.AddOutfitLobbyVeh and _G.AddOutfitLobbyVeh.manual) then
                    pcall(F.applyVehicleSkinsToPC)
                end
                F.persistMarkDirty()
            end
        end
    end)
    pcall(function()
        local gsm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
        if gsm and gsm.VehicleNeedClothes and not gsm._AddOutfitVehClothesHooked then
            gsm._AddOutfitVehClothesHooked = true
            local o = gsm.VehicleNeedClothes
            gsm.VehicleNeedClothes = function(self, vehicleId)
                vehicleId = tonumber(vehicleId)
                if vehicleId and F.isInjectedRes(vehicleId) then return 0 end
                return o(self, vehicleId)
            end
        end
    end)
    pcall(function()
        local mod = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
        if mod._FillVehicleSkinList then
            if not _G.AddOutfitVehFillOrig then
                _G.AddOutfitVehFillOrig = mod._FillVehicleSkinList
            end
            local o = _G.AddOutfitVehFillOrig
            mod._FillVehicleSkinList = function(self, playerInfo, uPlayerController)
                F.mergeVstIntoPlayerInfo(playerInfo)
                return o(self, playerInfo, uPlayerController)
            end
            mod._AddOutfitFillVehHooked = true
        end
    end)
    pcall(function()
        local classMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinItem")
        if not classMod or not classMod.__inner_impl then return end
        local impl = classMod.__inner_impl
        if not _G.AddOutfitVehOrigClick then
            _G.AddOutfitVehOrigClick = impl.OnClickSkinButton
        end
        local oClick = _G.AddOutfitVehOrigClick
        impl.OnClickSkinButton = function(self)
            local resID = tonumber(self.resID)
            if resID and resID > 0 then
                if F.matchApplyVehicleSkin(resID) then
                    pcall(function()
                        if EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL and EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK then
                            EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK)
                        end
                    end)
                end
                return
            end
            return oClick(self)
        end
        if not _G.AddOutfitVehOrigRefresh then
            _G.AddOutfitVehOrigRefresh = impl.OnRefresh
        end
        local oRefresh = _G.AddOutfitVehOrigRefresh
        impl.OnRefresh = function(self, resID, selectIndex)
            oRefresh(self, resID, selectIndex)
            if self.resID and tonumber(self.resID) and tonumber(self.resID) > 0 then
                if F.isResourcesReady(self.resID) then
                    pcall(function()
                        local PufferConst = require("client.slua.logic.download.puffer_const")
                        self.dowloadState = PufferConst.ENUM_DownloadState.Done
                        self.UIRoot.Image_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                        self:SetWidgetVisible(self.UIRoot.Image_Mask, false)
                    end)
                else
                    F.requestResourceDownload(self.resID)
                end
            end
        end
        classMod._AddOutfitSkinClickHooked = true
    end)
    pcall(function()
        local utilMod = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
        if utilMod.CheckHasUnLockFeature and not utilMod._AddOutfitVehPlateHooked then
            utilMod._AddOutfitVehPlateHooked = true
            local orig = utilMod.CheckHasUnLockFeature
            utilMod.CheckHasUnLockFeature = function(ft, uid, itemId)
                local id = tonumber(itemId)
                if F.isVehicleSkinAllowed(id) or F.isChassisLightId(id) then return true end
                return orig(ft, uid, itemId)
            end
        end
    end)
    pcall(function()
        local panelMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinAndMusicPanel")
        if panelMod and panelMod.__inner_impl and not panelMod._AddOutfitInitSkinHooked then
            panelMod._AddOutfitInitSkinHooked = true
            local o = panelMod.__inner_impl.InitSkinList
            panelMod.__inner_impl.InitSkinList = function(self)
                F.applyVehicleSkinsToPC(F.getPC())
                return o(self)
            end
        end
    end)
    pcall(function()
        local VUC = require("GameLua.GameCore.Module.Vehicle.Component.VehicleUserComponent")
        if not VUC then return end
        if not _G.AddOutfitVehOrigEnter then
            _G.AddOutfitVehOrigEnter = VUC.SendUIMsgWhenEnterVehicleCompleted
        end
        local oEnter = _G.AddOutfitVehOrigEnter
        VUC.SendUIMsgWhenEnterVehicleCompleted = function(self)
            oEnter(self)
            pcall(function()
                if slua.isValid(self.Vehicle) then
                    F.autoApplyVehicleSkinOnEnter(self.Vehicle)
                end
            end)
        end
        VUC._AddOutfitEnterVehHooked = true
    end)
end

function F.hookWeaponWear()
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        local o = HT.IsWeaponWear
        HT.IsWeaponWear = function(insId)
            insId = tonumber(insId)
            if F.isInjectedIns(insId) then
                local c = F.cache()
                local Arm = require("client.logic.armory.logic_armory")
                for wid, w in pairs(c.weapons) do
                    if tonumber(w.insID) == insId then
                        if Arm.rsp_list and Arm.rsp_list.install_list and Arm.rsp_list.install_list[wid] then
                            return tonumber(Arm.rsp_list.install_list[wid].skin_id) == insId
                        end
                        return true
                    end
                end
            end
            return o(insId)
        end
    end)
end

function F.hookNotice()
    pcall(function()
        if DataMgr and not DataMgr._AddOutfitExpireHooked then
            DataMgr._AddOutfitExpireHooked = true
            local oValid = DataMgr.IsValidTime
            DataMgr.IsValidTime = function(expireTS)
                if expireTS == nil or tonumber(expireTS) == 0 then return true end
                if oValid and oValid(expireTS) then return true end
                local inMatch = false
                pcall(function()
                    inMatch = GameStatus and GameStatus.IsInFightingStatus and GameStatus.IsInFightingStatus()
                end)
                if not inMatch then return true end
                return false
            end
        end
    end)
end

function F.wrapWardrobeClick(classMod, key)
    if not classMod or not classMod[key] or classMod["_AddOutfitWrap_" .. key] then return end
    classMod["_AddOutfitWrap_" .. key] = true
    local orig = classMod[key]
    classMod[key] = function(self, widget, index)
        local itemData = self.LoopScrollGrid_Normal and self.LoopScrollGrid_Normal:GetItemData(index)
        if itemData then
            F.clearItemExpire(itemData, itemData.ins_id, itemData.res_id)
            F.ensureDepotItemValid(itemData.ins_id, itemData.res_id)
        end
        return orig(self, widget, index)
    end
end

function F.hookWardrobeWearClicks()
    if _G.AddOutfitWearClickHooked then return end
    _G.AddOutfitWearClickHooked = true
    F.hookNotice()
    pcall(function()
        local avatarClass = require("client.slua.umg.Wardrobe.subtab_avatar")
        F.wrapWardrobeClick(avatarClass, "OnClickItem")
        F.wrapWardrobeClick(avatarClass, "ClickAvatarItem")
    end)
    pcall(function()
        local suitClass = require("client.slua.umg.Wardrobe.subtab_suit")
        F.wrapWardrobeClick(suitClass, "OnClickItem")
    end)
    pcall(function()
        local bagClass = require("client.slua.umg.Wardrobe.subtab_bag")
        F.wrapWardrobeClick(bagClass, "OnClickItem")
    end)
end

function F.hookAvatarValid()
    pcall(function()
        local path = "GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarComponent"
        local comp = require(path)
        if comp and comp.CheckItemValid then
            local o = comp.CheckItemValid
            comp.CheckItemValid = function(self, resID)
                if F.isInjectedRes(resID) then return true end
                return o(self, resID)
            end
        end
    end)
end

function F.isInRealMatch()
    local ok, r = pcall(function()
        return GameStatus and GameStatus.IsInFightingStatus and GameStatus.IsInFightingStatus()
    end)
    return ok and r == true
end

function F.getLocalChar()
    local ok, GD = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not ok or not GD then return nil end
    local char = GD.GetPlayerCharacter()
    if char and slua.isValid(char) then return char end
    return nil
end

function F.getWAC(char)
    local w = char and char.GetCurrentWeapon and char:GetCurrentWeapon()
    if slua.isValid(w) and slua.isValid(w.WeaponAvatarComponent) then
        return w.WeaponAvatarComponent
    end
    return nil
end

function F.notify(msg)
    if not DEBUG then return end
    pcall(function() if ShowNotice then ShowNotice("[AddOutfit] " .. tostring(msg)) end end)
end

function F.getDesiredOutfit()
    if MATCH_CONFIG.outfitRes and MATCH_CONFIG.outfitRes > 0 then
        return MATCH_CONFIG.outfitRes
    end
    local wornSuitRes
    pcall(function()
        local _, res = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isSuitRes(r) end)
        wornSuitRes = tonumber(res)
    end)
    if wornSuitRes and wornSuitRes > 0 then return wornSuitRes end
    local tshirtWorn = false
    pcall(function()
        local ins = F.findWornInsBySubType(OUTFIT_SUB, function(r) return F.isTshirtRes(r) end)
        tshirtWorn = ins ~= nil
    end)
    if tshirtWorn then return nil end
    F.syncBodyCacheFromLobby()
    local c = F.cache()
    return c.outfitRes
end

function F.matchApplyOutfit(char)
    local outfitRes = F.getDesiredOutfit()
    if not outfitRes then return true end
    if not F.isResourcesReady(outfitRes) then
        F.requestResourceDownload(outfitRes)
        return false
    end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    local ok = F.setMakeSkin(comp, outfitRes, F.CUST_SLOT.ClothesEquipemtSlot, { allowPutOn = true })
    return ok
end

function F.getDesiredHat()
    if MATCH_CONFIG.hatRes and tonumber(MATCH_CONFIG.hatRes) > 0 then
        return tonumber(MATCH_CONFIG.hatRes)
    end
    F.syncHatCacheFromLobby()
    local h = F.cache().hatRes
    if h and tonumber(h) > 0 then return tonumber(h) end
    return tonumber(_G.AddOutfitLastLobbyHatRes) or nil
end

function F.ensureSkinDownload(resID)
    resID = tonumber(resID)
    if not resID or resID <= 0 then return end
    _G.skinIdCache = _G.skinIdCache or {}
    if not _G.skinIdCache[resID] then
        F.requestResourceDownload(resID)
        _G.skinIdCache[resID] = true
    end
end

function F.syncGlobalWearSkins()
    _G.CustSlotType = F.CUST_SLOT
    _G.skinIdCache = _G.skinIdCache or {}
    _G.HatSkin = tonumber(F.getDesiredHat()) or 0
    local outfit = F.getDesiredOutfit()
    _G.SuitSkin = tonumber(outfit)
        or tonumber(F.getDesiredWear("tshirtRes", "tshirtRes", "AddOutfitLastLobbyTshirtRes", F.syncBodyCacheFromLobby))
        or 0
    _G.PantsSkin = tonumber(F.getDesiredWear("pantsRes", "pantsRes", "AddOutfitLastLobbyPantsRes", F.syncBodyCacheFromLobby)) or 0
    _G.ShoesSkin = tonumber(F.getDesiredWear("shoesRes", "shoesRes", "AddOutfitLastLobbyShoesRes", F.syncBodyCacheFromLobby)) or 0
    _G.GlovesSkin = tonumber(F.getDesiredWear("glovesRes", "glovesRes", "AddOutfitLastLobbyGlovesRes", F.syncBodyCacheFromLobby)) or 0
    _G.MaskSkin = tonumber(F.getDesiredMask()) or 0
    _G.GlassSkin = tonumber(F.getDesiredGlass()) or 0
    _G.GliderSkin = tonumber(F.getDesiredGliderRes()) or 0
    _G.ParachuteSkin = tonumber(F.getDesiredParachuteRes()) or 0
end

function F.setMakeSkinAtIndex(comp, applyIdx, resID, slotID)
    resID = tonumber(resID)
    slotID = tonumber(slotID)
    applyIdx = tonumber(applyIdx)
    if not comp or not slua.isValid(comp) or not resID or resID <= 0 or not slotID or applyIdx == nil then
        return false
    end
    local changed = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local equipment = applyData:Get(applyIdx)
        if equipment and equipment.SlotID == slotID then
            local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
            if cur ~= resID then
                F.ensureSkinDownload(resID)
                equipment.ItemId = resID
                if equipment.ItemID ~= nil then equipment.ItemID = resID end
                applyData:Set(applyIdx, equipment)
                changed = true
            end
        end
    end)
    return changed
end

function F.applySlotSkinBatch(comp, entries, opts)
    opts = opts or {}
    if not comp or not slua.isValid(comp) or not entries then return false end
    local changed, anyOk = false, false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local num = applyData:Num()
        for _, e in ipairs(entries) do
            local itemId, slotId = tonumber(e[1]), tonumber(e[2])
            if itemId and itemId > 0 and slotId then
                F.ensureSkinDownload(itemId)
                for i = 0, num - 1 do
                    local equipment = applyData:Get(i)
                    if equipment and equipment.SlotID == slotId then
                        local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                        if cur == itemId then
                            anyOk = true
                        elseif cur ~= itemId then
                            equipment.ItemId = itemId
                            if equipment.ItemID ~= nil then equipment.ItemID = itemId end
                            applyData:Set(i, equipment)
                            changed = true
                            anyOk = true
                        end
                        break
                    end
                end
            end
        end
        if (changed or opts.forceRep) and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
    end)
    return anyOk or changed
end

function F.setMakeSkin(comp, resID, slotID, opts)
    -- [CHỐT CHẶN 100%] Từ chối vẽ Skin VIP (>1000000) lên cơ thể nếu công tắc tắt
    if not _G.LexusConfig.ModSkin and tonumber(resID) and tonumber(resID) > 1000000 then return false end

    opts = opts or {}
    slotID, resID = tonumber(slotID), tonumber(resID)
    if not comp or not slua.isValid(comp) or not slotID or not resID or resID <= 0 then return false end
    local changed = false
    local already = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local num = applyData:Num()
        for i = 0, num - 1 do
            local equipment = applyData:Get(i)
            if equipment and equipment.SlotID == slotID then
                local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                if cur == resID then
                    already = true
                elseif cur ~= resID then
                    F.ensureSkinDownload(resID)
                    equipment.ItemId = resID
                    if equipment.ItemID ~= nil then equipment.ItemID = resID end
                    applyData:Set(i, equipment)
                    changed = true
                end
                break
            end
        end
        if changed and not opts.skipRep and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
        if opts.inAir and comp.PutOnCustomEquipmentByID then
            comp:PutOnCustomEquipmentByID(resID)
        end
    end)
    if already or changed then return true end
    if opts.allowPutOn and comp.PutOnCustomEquipmentByID then
        pcall(function() comp:PutOnCustomEquipmentByID(resID) end)
        return true
    end
    return false
end
F.setSlotSkin = F.setMakeSkin

_G.setMakeSkin = function(applyIdx, itemId, applyEquipSlot)
    local char = F.getLocalChar()
    if not char then return end
    local comp = F.getAvatarComp2(char)
    if not comp then return end
    if F.setMakeSkinAtIndex(comp, applyIdx, itemId, applyEquipSlot) then
        pcall(function()
            if comp.OnRep_BodySlotStateChanged then comp:OnRep_BodySlotStateChanged() end
        end)
    end
end

function F.patchWearNetAvatar(comp, resID, slotName, noForceShow)
    if not comp or not slua.isValid(comp) or not resID or resID <= 0 or not slotName then return false end
    local ok = false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local ESyncOperation = import("ESyncOperation")
        local slot = EAvatarSlotType[slotName]
        if not slot then return end
        local sync = comp.GetSlotSyncData and comp:GetSlotSyncData(slot)
        if sync then
            sync.ItemID = resID
            if sync.FakeItemID ~= nil then sync.FakeItemID = resID end
            sync.OperationType = ESyncOperation.PutOn
            if comp.ChangeSlotSyncData then
                comp:ChangeSlotSyncData(sync)
                ok = true
            end
        end
        if not noForceShow and comp.SetAvatarVisibility then
            comp:SetAvatarVisibility(slot, true, true)
        end
    end)
    return ok
end

function F.patchHatNetAvatar(comp, hatRes)
    return F.patchWearNetAvatar(comp, hatRes, "EAvatarSlotType_HatEquipemtSlot")
end

function F.matchApplyWearItem(char, resID, slotID, label, opts)
    if not resID or resID <= 0 then return true end
    slotID = slotID or F.resToCustSlot(resID)
    if not slotID then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    opts = opts or {}
    opts.allowPutOn = true
    local ok = F.setMakeSkin(comp, resID, slotID, opts)
    return ok
end

function F.getDesiredMask()
    if MATCH_CONFIG.maskRes and tonumber(MATCH_CONFIG.maskRes) > 0 then
        return tonumber(MATCH_CONFIG.maskRes)
    end
    F.syncFaceCacheFromLobby()
    local m = F.cache().maskRes
    if m and tonumber(m) > 0 then return tonumber(m) end
    return tonumber(_G.AddOutfitLastLobbyMaskRes) or nil
end

function F.getDesiredGlass()
    if MATCH_CONFIG.glassRes and tonumber(MATCH_CONFIG.glassRes) > 0 then
        return tonumber(MATCH_CONFIG.glassRes)
    end
    F.syncFaceCacheFromLobby()
    local g = F.cache().glassRes
    if g and tonumber(g) > 0 then return tonumber(g) end
    return tonumber(_G.AddOutfitLastLobbyGlassRes) or nil
end

function F.matchApplyFaceWear(char)
    local maskRes = F.getDesiredMask()
    local glassRes = F.getDesiredGlass()
    if (not maskRes or maskRes <= 0) and (not glassRes or glassRes <= 0) then
        return true
    end
    char = char or F.getLocalChar()
    if not char then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end

    local ok = false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local ESyncOperation = import("ESyncOperation")
        local net = comp.NetAvatarData
        local applyData = net and net.SlotSyncData

        local function forceApplySlot(resID, slotID, slotNameStr)
            if not resID or resID <= 0 then return end
            
            local slotEnum = EAvatarSlotType and EAvatarSlotType[slotNameStr]
            local needRep = false
            
            -- 1. GHI ĐÈ DATA MẠNG (Chống lỗi không đồng bộ)
            if applyData and slua.isValid(applyData) then
                local found = false
                for i = 0, applyData:Num() - 1 do
                    local equipment = applyData:Get(i)
                    if equipment and equipment.SlotID == slotID then
                        found = true
                        local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                        if cur ~= resID then
                            F.ensureSkinDownload(resID)
                            equipment.ItemId = resID
                            if equipment.ItemID ~= nil then equipment.ItemID = resID end
                            if equipment.FakeItemID ~= nil then equipment.FakeItemID = resID end
                            applyData:Set(i, equipment)
                            needRep = true
                        end
                        break
                    end
                end
                
                if not found then
                    F.ensureSkinDownload(resID)
                    local entry = import("AvatarSyncData")()
                    entry.SlotID = slotID
                    entry.ItemId = resID
                    entry.ItemID = resID
                    entry.FakeItemID = resID
                    entry.OperationType = ESyncOperation.PutOn
                    applyData:Add(entry)
                    needRep = true
                end
            end

            -- [LOGIC NGỦ ĐÔNG] - TỐI ƯU FPS TUYỆT ĐỐI
            _G.FaceWearStateCache = _G.FaceWearStateCache or {}
            -- Tạo ID định danh riêng biệt cho nhân vật hiện tại tránh trùng lặp
            local cacheKey = tostring(comp) .. "_" .. tostring(slotID)

            if needRep or _G.FaceWearStateCache[cacheKey] ~= resID then
                -- Lần đầu tiên ép hiển thị / Hoặc ID Skin bị thay đổi -> Chạy Full C++
                if slotEnum then
                    if comp.CancelHideAvatarBySlot then comp:CancelHideAvatarBySlot(slotEnum) end
                    if comp.SetAvatarVisibility then comp:SetAvatarVisibility(slotEnum, true, true) end
                end
                if comp.PutOnCustomEquipmentByID then
                    comp:PutOnCustomEquipmentByID(resID)
                end
                
                -- Cập nhật Cache để vòng lặp sau đi vào Ngủ Đông
                _G.FaceWearStateCache[cacheKey] = resID
                ok = true -- Bật cờ để gọi OnRep_BodySlotStateChanged (vẽ lại Mesh)
            else
                -- TRẠNG THÁI NGỦ ĐÔNG: Data đã đúng, Mesh 3D đã được render.
                -- Chỉ chạy hàm cực nhẹ CancelHide để chống Game tự ẩn khi nhặt Mũ bảo hiểm (1,2,3).
                -- BỎ QUA việc Render lại Mesh để tránh Drop FPS.
                if slotEnum and comp.CancelHideAvatarBySlot then 
                    comp:CancelHideAvatarBySlot(slotEnum) 
                end
            end
        end

        -- Gọi lệnh ép cho Mặt nạ (Mask)
        forceApplySlot(maskRes, F.CUST_SLOT.FaceEquipemtSlot, "EAvatarSlotType_FaceEquipemtSlot")
        -- Gọi lệnh ép cho Mắt kính (Glass)
        forceApplySlot(glassRes, F.CUST_SLOT.GlassEquipemtSlot, "EAvatarSlotType_GlassEquipemtSlot")
        
        -- Cập nhật hình ảnh 3D CHỈ KHI THOÁT KHỎI NGỦ ĐÔNG (Khi cần thiết)
        if ok and comp.OnRep_BodySlotStateChanged then
            comp:OnRep_BodySlotStateChanged()
        end
    end)
    return ok
end

function F.getDesiredWear(configKey, cacheResKey, globalKey, syncFn)
    local fixed = MATCH_CONFIG[configKey] and tonumber(MATCH_CONFIG[configKey])
    if fixed and fixed > 0 then return fixed end
    local persistKey = cacheResKey and cacheResKey:gsub("Res$", "")
    if persistKey and PERSIST.configSlots then
        local pr = tonumber(PERSIST.configSlots[persistKey])
        if pr and pr > 0 then return pr end
    end
    if syncFn then syncFn() end
    local v = F.cache()[cacheResKey]
    if v and tonumber(v) > 0 then return tonumber(v) end
    return tonumber(_G[globalKey]) or nil
end

-- ==========================================================
    -- HỆ THỐNG MŨ/BALO VIP (AUTO LEVEL 1, 2, 3 + SYNC INGAME)
    -- ==========================================================
    local GAME_HELMET_LEVEL = {
        [502001] = 1, [502004] = 1, [502002] = 2, [502005] = 2, [502003] = 3,
    }
    local GAME_BAG_LEVEL = {
        [501001] = 1, [501004] = 1, [501002] = 2, [501005] = 2, [501003] = 3,
    }
    local EQUIP_LEVEL_SETS = {}
    local _equipLevelByRes = {}

    function F.registerEquipLevelSet(catalog, lv1, lv2, lv3, slot)
        catalog = tonumber(catalog)
        if not catalog then return end
        local set = { catalog = catalog, lv1 = tonumber(lv1) or 0, lv2 = tonumber(lv2) or 0, lv3 = tonumber(lv3) or 0, slot = slot or "helmet" }
        EQUIP_LEVEL_SETS[catalog] = set
        for _, rid in ipairs({ catalog, set.lv1, set.lv2, set.lv3 }) do
            if rid and rid > 0 then _equipLevelByRes[rid] = set end
        end
    end

    local EQUIP_LEVEL_RANGES = {
        { base = 1502000000, slot = "helmet" },
        { base = 1501000000, slot = "bag"    },
    }

    function F.findEquipLevelRange(resID)
        resID = tonumber(resID)
        if not resID then return nil end
        for _, r in ipairs(EQUIP_LEVEL_RANGES) do
            if resID >= r.base and resID < r.base + 1000000 then return r end
        end
        return nil
    end

    function F.detectLevelFromPattern(resID)
        resID = tonumber(resID)
        if not resID then return nil, nil end
        local r = F.findEquipLevelRange(resID)
        if not r then return nil, nil end
        if resID < r.base + 1000 or resID >= r.base + 4000 then return nil, nil end
        local tail = resID - r.base
        local levelDigit = math.floor(tail / 1000)
        if levelDigit >= 1 and levelDigit <= 3 then
            return levelDigit, r.base + (tail - levelDigit * 1000)
        end
        return nil, nil
    end

    function F.buildPatternLevelSet(catalog)
        catalog = tonumber(catalog)
        if not catalog then return nil end
        local r = F.findEquipLevelRange(catalog)
        if not r then return nil end
        local tail = catalog - r.base
        if tail < 0 or tail >= 1000 then return nil end
        return { catalog = catalog, lv1 = catalog + 1000, lv2 = catalog + 2000, lv3 = catalog + 3000, slot = r.slot }
    end

    function F.getEquipLevelSet(resID)
        resID = tonumber(resID)
        if not resID then return nil end
        local set = _equipLevelByRes[resID]
        if set then return set end
        local level, catalog = F.detectLevelFromPattern(resID)
        if catalog then
            if EQUIP_LEVEL_SETS[catalog] then return EQUIP_LEVEL_SETS[catalog] end
            if level then return F.buildPatternLevelSet(catalog) end
        end
        local direct = F.buildPatternLevelSet(resID)
        if direct then
            _equipLevelByRes[resID] = direct
            if direct.lv1 > 0 then _equipLevelByRes[direct.lv1] = direct end
            if direct.lv2 > 0 then _equipLevelByRes[direct.lv2] = direct end
            if direct.lv3 > 0 then _equipLevelByRes[direct.lv3] = direct end
        end
        return direct
    end

    function F.normalizeEquipCatalogRes(resID)
        resID = tonumber(resID)
        if not resID or resID <= 0 then return 0 end
        local set = F.getEquipLevelSet(resID)
        if set then return set.catalog end
        return resID
    end

    function F.detectLevelFromEquipRes(resID)
        resID = tonumber(resID)
        if not resID then return nil end
        local set = F.getEquipLevelSet(resID)
        if set then
            if resID == set.lv1 then return 1
            elseif resID == set.lv2 then return 2
            elseif resID == set.lv3 then return 3 end
        end
        return F.detectLevelFromPattern(resID)
    end

    function F.mapEquipLevelSet(set, level)
        if not set then return 0 end
        level = tonumber(level) or 3
        if level == 1 then return set.lv1 or 0
        elseif level == 2 then return set.lv2 or 0 end
        return set.lv3 or 0
    end

    function F.mapEquipSkinRes(resID, level)
        resID, level = tonumber(resID), tonumber(level) or 3
        if not resID or resID <= 0 then return 0 end
        local catalogRes = F.normalizeEquipCatalogRes(resID)
        local set = F.getEquipLevelSet(catalogRes)
        if set then
            local mapped = F.mapEquipLevelSet(set, level)
            if mapped > 0 then return mapped end
        end
        local mapped = 0
        pcall(function()
            local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", catalogRes)
            if itemMappingCfg then
                if level == 1 then mapped = tonumber(itemMappingCfg.SkinItemIDLv1) or 0
                elseif level == 2 then mapped = tonumber(itemMappingCfg.SkinItemIDLv2) or 0
                else mapped = tonumber(itemMappingCfg.SkinItemIDLv3) or 0 end
            end
        end)
        if mapped > 0 then return mapped end
        if F.isInjectedRes(catalogRes) then return catalogRes end
        return 0
    end

    function F.buildEquipSkinLists(resID)
        resID = F.normalizeEquipCatalogRes(resID)
        return { F.mapEquipSkinRes(resID, 1), F.mapEquipSkinRes(resID, 2), F.mapEquipSkinRes(resID, 3) }
    end

    function F.detectEquipLevelFromBaseId(baseId, catalogResID)
        baseId, catalogResID = tonumber(baseId), tonumber(catalogResID)
        if not baseId or baseId <= 0 then return nil end
        local level
        pcall(function()
            catalogResID = catalogResID and F.normalizeEquipCatalogRes(catalogResID) or catalogResID
            if catalogResID then
                local set = F.getEquipLevelSet(catalogResID)
                if set then
                    if baseId == set.lv1 then level = 1
                    elseif baseId == set.lv2 then level = 2
                    elseif baseId == set.lv3 then level = 3 end
                end
                if not level then
                    local m = CDataTable.GetTableData("BackpackMapping", catalogResID)
                    if m then
                        if tonumber(m.SkinItemIDLv1) == baseId then level = 1
                        elseif tonumber(m.SkinItemIDLv2) == baseId then level = 2
                        elseif tonumber(m.SkinItemIDLv3) == baseId then level = 3 end
                    end
                end
            end
            if not level then
                local patLevel, patCatalog = F.detectLevelFromPattern(baseId)
                if patLevel and (not catalogResID or patCatalog == catalogResID) then level = patLevel end
            end
            if not level then level = GAME_HELMET_LEVEL[baseId] or GAME_BAG_LEVEL[baseId] end
            if not level and baseId >= 1505000001 and baseId <= 1505000003 then level = baseId - 1505000000 end
            if not level then
                local BU = import("BackpackUtils")
                if BU and BU.GetEquipmentHelmetLevel then
                    local hl = BU.GetEquipmentHelmetLevel(baseId)
                    if hl and hl >= 1 and hl <= 3 then level = hl end
                end
                if not level and BU and BU.GetEquipmentBagLevel then
                    local bl = BU.GetEquipmentBagLevel(baseId)
                    if bl and bl >= 1 and bl <= 3 then level = bl end
                end
            end
        end)
        return level
    end

    function F.isBaseEquipItemId(itemId)
        itemId = tonumber(itemId)
        if not itemId or itemId <= 0 then return false end
        if GAME_HELMET_LEVEL[itemId] or GAME_BAG_LEVEL[itemId] then return true end
        if itemId >= 1505000001 and itemId <= 1505000100 then return true end
        if itemId >= 1501000000 and itemId < 1502000000 then return true end
        if itemId >= 502001 and itemId <= 502999 then return true end
        if itemId >= 501001 and itemId <= 501999 then return true end
        return false
    end

    function F.resolveMatchEquipSkin(catalogResID, baseItemID)
        catalogResID = F.normalizeEquipCatalogRes(catalogResID)
        if not catalogResID or catalogResID <= 0 then return 0 end
        local level = F.detectEquipLevelFromBaseId(baseItemID, catalogResID) or 3
        return F.mapEquipSkinRes(catalogResID, level)
    end

    function F.getCharEquipLevel(char, slotID)
        local found = nil
        pcall(function()
            local comp = char and char.CharacterAvatarComp2_BP
            if not slua.isValid(comp) then return end
            local NetAvatarData = slua.IndexReference(comp, "NetAvatarData")
            if not NetAvatarData then return end
            local TempSlotSyncData = slua.IndexReference(NetAvatarData, "SlotSyncData")
            if not TempSlotSyncData then return end
            local n = TempSlotSyncData:Num()
            for i = 0, n - 1 do
                local AvatarSynData = TempSlotSyncData:Get(i)
                if AvatarSynData and AvatarSynData.SlotID == slotID and AvatarSynData.ItemID and AvatarSynData.ItemID > 0 then
                    found = AvatarSynData.ItemID
                    return
                end
            end
        end)
        return found
    end

    function F.isWearingEquip(char, slot)
        local slotID = (slot == "helmet") and 9 or (slot == "bag") and 8 or nil
        if not slotID then return false end
        local itemID = F.getCharEquipLevel(char, slotID)
        if itemID and itemID > 0 then return true end
        local wearing = false
        pcall(function()
            local pc = F.getPC()
            if not pc or not slua.isValid(pc) then return end
            if pc.PlayerState and pc.PlayerState.MetroPlayerStateAvatarFeature then
                local psEquip = pc.PlayerState.MetroPlayerStateAvatarFeature.EquipmentAvatarData
                if psEquip then
                    if slot == "helmet" and psEquip.HelmetAvatar and psEquip.HelmetAvatar > 0 then wearing = true
                    elseif slot == "bag" and psEquip.BagAvatar and psEquip.BagAvatar > 0 then wearing = true end
                end
            end
        end)
        return wearing
    end

    local EQUIP_APPLY = { lastBagWrite = 0, lastHelmetWrite = 0 }

function F.levelSkinID(baseSkin, level)
    level = tonumber(level) or 1
    if level < 1 then level = 1 end
    local mapped = 0
    pcall(function()
        local t = CDataTable.GetTableData("BackpackMapping", baseSkin)
        if t then
            if level <= 1 then mapped = tonumber(t.SkinItemIDLv1) or 0
            elseif level == 2 then mapped = tonumber(t.SkinItemIDLv2) or 0
            else mapped = tonumber(t.SkinItemIDLv3) or 0 end
        end
    end)
    if mapped > 0 then return mapped end
    return baseSkin + (level - 1) * 1000
end

function F.applyEquipSkinToComp(comp, bagRes, helmetRes)
    local applied, found = false, false
    pcall(function()
        local EAvatarSlotType = import("EAvatarSlotType")
        local BackpackUtils = import("BackpackUtils")
        local function doSlot(slotEnum, res, levelFn, lastKey)
            res = tonumber(res) or 0
            if res <= 0 or not slotEnum then return end
            local sync = comp.GetSlotSyncData and comp:GetSlotSyncData(slotEnum)
            if not sync then return end
            local cur = tonumber(sync.ItemID) or 0
            local addID = tonumber(sync.AdditionalItemID) or 0
            if cur <= 0 and addID <= 0 then return end
            found = true
            local lvl = 1
            pcall(function()
                if levelFn then lvl = levelFn(addID > 0 and addID or cur) or 1 end
            end)
            if lvl < 1 then lvl = 1 end
            local target = F.levelSkinID(res, lvl)
            if target > 0 and cur ~= target then
                sync.ItemID = target
                comp:ChangeSlotSyncData(sync)
                applied = true
                EQUIP_APPLY[lastKey] = target
            end
        end
        doSlot(EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot, bagRes,
               BackpackUtils.GetEquipmentBagLevel, "lastBagWrite")
        doSlot(EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot, helmetRes,
               BackpackUtils.GetEquipmentHelmetLevel, "lastHelmetWrite")
    end)
    return applied, found
end

function F.matchApplyEquipmentSkin(char, bagRes, helmetRes)
    bagRes = tonumber(bagRes) or 0
    helmetRes = tonumber(helmetRes) or 0
    if bagRes <= 0 and helmetRes <= 0 then return true end
    local comp = char.CharacterAvatarComp2_BP
    if not slua.isValid(comp) then return false end

    local applied, found = F.applyEquipSkinToComp(comp, bagRes, helmetRes)

    if applied then
        pcall(function()
            if comp.OnRep_BodySlotStateChanged then comp:OnRep_BodySlotStateChanged() end
        end)
        return true
    end
    return found
end

function F.hookEquipmentRectify()
    _G.AddOutfitEquipRectifyFn = function(self)
        pcall(function()
            if self.IsLobbyActor and self:IsLobbyActor() then return end
            if not (self.IsSelf and self:IsSelf()) then return end
            local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
            local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
            if (tonumber(bagRes) or 0) <= 0 and (tonumber(helmetRes) or 0) <= 0 then return end
            F.applyEquipSkinToComp(self, bagRes, helmetRes)
        end)
    end
    pcall(function()
        local MCAC = require("GameLua.Mod.TPlan.Component.MetroCharacterAvatarComponent")
        if MCAC._AddOutfitRectifyHooked then return end
        MCAC._AddOutfitRectifyHooked = true
        local o = MCAC.ProcessClientAvatarRectify
        MCAC.ProcessClientAvatarRectify = function(self)
            o(self)
            if _G.AddOutfitEquipRectifyFn then _G.AddOutfitEquipRectifyFn(self) end
        end
    end)
end

function F.hookBackpackValid()
    if _G.DEV_WARDROBE_BP_HOOKED then return end
    _G.DEV_WARDROBE_BP_HOOKED = true
    pcall(function()
        local BU = import("BackpackUtils")
        if BU and BU.GetBPIDByResID then
            local orig = BU.GetBPIDByResID
            BU.GetBPIDByResID = function(resID)
                resID = tonumber(resID)
                if resID and F.isInjectedRes(resID) then
                    local bp = orig(resID)
                    if bp and bp > 0 then return bp end
                    return resID
                end
                return orig(resID)
            end
        end
    end)
    pcall(function()
        local AU = import("AvatarUtils")
        if AU and AU.GetBPIDByResID then
            local orig = AU.GetBPIDByResID
            AU.GetBPIDByResID = function(resID, ...)
                resID = tonumber(resID)
                if resID and F.isInjectedRes(resID) then
                    local bp = orig(resID, ...)
                    if bp and bp > 0 then return bp end
                    return resID
                end
                return orig(resID, ...)
            end
        end
    end)
end

function F.hookEquipMapping()
    pcall(function()
        if DataMgr and not DataMgr._lava_equip_map_hooked then
            DataMgr._lava_equip_map_hooked = true
            local orig = DataMgr.GetEquipmentItemIDByResID
            DataMgr.GetEquipmentItemIDByResID = function(level, itemResID)
                level, itemResID = tonumber(level) or 3, tonumber(itemResID)
                local r = orig(level, itemResID)
                if r and r > 0 then return r end
                
                -- Đây là lệnh ĐỘC QUYỀN giúp game nhận diện Icon Mũ/Balo VIP ở Sảnh
                if F.isInjectedIns(itemResID) then
                    local resID = R.insToRes[itemResID]
                    if resID then return F.levelSkinID(resID, level) end
                end
                if F.isInjectedRes(itemResID) then
                    return F.levelSkinID(itemResID, level)
                end
                return r or 0
            end
        end
    end)
end

    function F.hookEquipMapping()
        pcall(function()
            if DataMgr and not DataMgr._lava_equip_map_hooked then
                DataMgr._lava_equip_map_hooked = true
                local orig = DataMgr.GetEquipmentItemIDByResID
                DataMgr.GetEquipmentItemIDByResID = function(level, itemResID)
                    level, itemResID = tonumber(level) or 3, tonumber(itemResID)
                    local catalogRes = F.normalizeEquipCatalogRes(itemResID)
                    local r = orig(level, catalogRes)
                    if r and r > 0 then return r end
                    if F.isInjectedIns(itemResID) then
                        return F.mapEquipSkinRes(F.normalizeEquipCatalogRes(R.insToRes[itemResID]), level)
                    end
                    if F.isInjectedRes(itemResID) then
                        return F.mapEquipSkinRes(catalogRes, level)
                    end
                    return r or 0
                end
            end
        end)
        pcall(function()
            local CAC = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarComponent")
            if CAC._lava_equip_skin_hooked then return end
            CAC._lava_equip_skin_hooked = true
            local orig3 = CAC.GetEquipmentSkinItemID
            CAC.GetEquipmentSkinItemID = function(self, InItemID)
                if self.IsSelf and not self:IsSelf() then return orig3(self, InItemID) end
                local cch = F.cache()
                InItemID = tonumber(InItemID) or 0

                local function tryGetSkin(catalogRes)
                    if not catalogRes or catalogRes <= 0 then return 0 end
                    catalogRes = F.normalizeEquipCatalogRes(catalogRes)
                    local skin = F.resolveMatchEquipSkin(catalogRes, InItemID)
                    if skin > 0 then return skin end
                    for lvl = 1, 3 do
                        local s = F.mapEquipSkinRes(catalogRes, lvl)
                        if s > 0 then return s end
                    end
                    return 0
                end

                local origResult = orig3(self, InItemID)
                if origResult and origResult > 0 and origResult ~= InItemID then return origResult end

                local isHelmetQuery = GAME_HELMET_LEVEL[InItemID] ~= nil or (InItemID >= 502001 and InItemID <= 502999)
                local isBagQuery = GAME_BAG_LEVEL[InItemID] ~= nil or (InItemID >= 501001 and InItemID <= 501999)
                local char = F.getLocalChar()

                if isHelmetQuery and cch.helmetRes and cch.helmetRes > 0 then
                    if char and F.isWearingEquip(char, "helmet") then
                        local skin = tryGetSkin(cch.helmetRes)
                        if skin > 0 then return skin end
                    end
                end
                if isBagQuery and cch.bagRes and cch.bagRes > 0 then
                    if char and F.isWearingEquip(char, "bag") then
                        local skin = tryGetSkin(cch.bagRes)
                        if skin > 0 then return skin end
                    end
                end
                return origResult
            end
            
            local origEquipFinish = CAC.OnAvatarEquipFinish
            CAC.OnAvatarEquipFinish = function(self, slotType, isEquipped, itemID)
                if origEquipFinish then origEquipFinish(self, slotType, isEquipped, itemID) end
                if not isEquipped then return end
                if not self.IsSelf or not self:IsSelf() then return end
                pcall(function()
                    if self.IsLobbyActor and self:IsLobbyActor() then return end
                    local EAvatarSlotType = import("EAvatarSlotType")
                    local cch = F.cache()
                    local isHelmet = slotType == EAvatarSlotType.EAvatarSlotType_HelmetEquipemtSlot
                    local isBag = slotType == EAvatarSlotType.EAvatarSlotType_BackpackEquipemtSlot
                    if (isHelmet and cch.helmetRes and cch.helmetRes > 0)
                        or (isBag and cch.bagRes and cch.bagRes > 0) then
                        local owner = self.GetOwner and self:GetOwner()
                        if owner and slua.isValid(owner) and owner.AddGameTimer then
                            owner:AddGameTimer(0.25, false, function()
                                if slua.isValid(owner) then F.matchApplyEquipSkins(owner) end
                            end)
                        end
                    end
                    F.applyMatchEquipAvatarToController()
                end)
            end
        end)
    end

function F.applyAirborneSlots(char, forceInAir)
    local comp = F.getAvatarComp2(char)
    if not comp or not slua.isValid(comp) then return false end
    pcall(function() F.syncAirborneToDataMgr() end)
    local inAir = forceInAir == true or F.isCharacterAirborne(char)
    local any = false
    local paraRes = F.getDesiredParachuteRes()
    if paraRes and paraRes > 0 then
        any = true
        if not F.isResourcesReady(paraRes) then F.requestResourceDownload(paraRes) end
        F.setMakeSkin(comp, paraRes, F.CUST_SLOT.ParachuteEquipemtSlot, { inAir = inAir })
    end
    local gliderRes = F.getDesiredGliderRes()
    if gliderRes and gliderRes > 0 then
        any = true
        if not F.isResourcesReady(gliderRes) then F.requestResourceDownload(gliderRes) end
        F.setMakeSkin(comp, gliderRes, F.CUST_SLOT.GlideEquipemtSlot, { inAir = inAir })
    end
    return any
end

function F.matchApplyBodyWear(char)
    local pieces = {}
    if not F.getDesiredOutfit() then
        pieces[#pieces + 1] = {
            F.getDesiredWear("tshirtRes", "tshirtRes", "AddOutfitLastLobbyTshirtRes", F.syncBodyCacheFromLobby),
            F.CUST_SLOT.ClothesEquipemtSlot, "تيشرت",
        }
    end
    pieces[#pieces + 1] = { F.getDesiredWear("pantsRes", "pantsRes", "AddOutfitLastLobbyPantsRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.PantsEquipemtSlot, "سروال" }
    pieces[#pieces + 1] = { F.getDesiredWear("shoesRes", "shoesRes", "AddOutfitLastLobbyShoesRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.ShoesEquipemtSlot, "حذاء" }
    pieces[#pieces + 1] = { F.getDesiredWear("glovesRes", "glovesRes", "AddOutfitLastLobbyGlovesRes", F.syncBodyCacheFromLobby), F.CUST_SLOT.HandEffectEquipemtSlot, "قفازات" }
    local any, okAll = false, true
    for _, p in ipairs(pieces) do
        local res, slot, label = p[1], p[2], p[3]
        if res and res > 0 then
            any = true
            okAll = F.matchApplyWearItem(char, res, slot, label) and okAll
        end
    end
    local anyAir = F.applyAirborneSlots(char, false)
    if anyAir then any = true end
    local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
    local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
    if (tonumber(bagRes) or 0) > 0 or (tonumber(helmetRes) or 0) > 0 then
        any = true
        okAll = F.matchApplyEquipmentSkin(char, bagRes, helmetRes) and okAll
    end
    return not any or okAll
end

function F.matchApplyAllSlots(char)
    if not char then return false end
    F.syncGlobalWearSkins()
    local comp = F.getAvatarComp2(char)
    if not comp then return false end

    local entries = {}
    local function add(skin, slot)
        skin = tonumber(skin)
        if skin and skin > 0 and slot then entries[#entries + 1] = { skin, slot } end
    end
    add(_G.HatSkin, F.CUST_SLOT.HatEquipemtSlot)
    add(_G.SuitSkin, F.CUST_SLOT.ClothesEquipemtSlot)
    add(_G.PantsSkin, F.CUST_SLOT.PantsEquipemtSlot)
    add(_G.ShoesSkin, F.CUST_SLOT.ShoesEquipemtSlot)
    add(_G.GlovesSkin, F.CUST_SLOT.HandEffectEquipemtSlot)
    add(_G.MaskSkin, F.CUST_SLOT.FaceEquipemtSlot)
    add(_G.GlassSkin, F.CUST_SLOT.GlassEquipemtSlot)

    local ok = false
    if #entries > 0 then
        ok = F.applySlotSkinBatch(comp, entries, { forceRep = true })
        if not ok then
            for _, e in ipairs(entries) do
                if F.setMakeSkin(comp, e[1], e[2], { allowPutOn = true }) then ok = true end
            end
        end
    end

    F.applyAirborneSlots(char, false)

    local bagRes = F.getDesiredWear("bagRes", "bagRes", "AddOutfitLastLobbyBagRes", F.syncBodyCacheFromLobby)
    local helmetRes = F.getDesiredWear("helmetRes", "helmetRes", "AddOutfitLastLobbyHelmetRes", F.syncBodyCacheFromLobby)
    if (tonumber(bagRes) or 0) > 0 or (tonumber(helmetRes) or 0) > 0 then
        ok = F.matchApplyEquipmentSkin(char, bagRes, helmetRes) or ok
    end

    return ok or #entries == 0
end

function F.matchApplyHat(char)
    local hatRes = tonumber(F.getDesiredHat())
    if not hatRes or hatRes <= 0 then return true end
    char = char or F.getLocalChar()
    if not char then return false end
    local comp = F.getAvatarComp2(char)
    if not comp then return false end
    local slotID = F.CUST_SLOT.HatEquipemtSlot
    local ok = false
    pcall(function()
        local net = comp.NetAvatarData
        if not net then return end
        local applyData = net.SlotSyncData
        if not applyData or not slua.isValid(applyData) then return end
        local found = false
        for i = 0, applyData:Num() - 1 do
            local equipment = applyData:Get(i)
            if equipment and equipment.SlotID == slotID then
                found = true
                local cur = tonumber(equipment.ItemId) or tonumber(equipment.ItemID) or 0
                if cur ~= hatRes then
                    F.ensureSkinDownload(hatRes)
                    equipment.ItemId = hatRes
                    if equipment.ItemID ~= nil then equipment.ItemID = hatRes end
                    if equipment.FakeItemID ~= nil then equipment.FakeItemID = hatRes end
                    applyData:Set(i, equipment)
                end
                ok = true
                break
            end
        end
        if not found then
            F.ensureSkinDownload(hatRes)
            local ESyncOperation = import("ESyncOperation")
            local entry = import("AvatarSyncData")()
            entry.SlotID = slotID
            entry.ItemId = hatRes
            entry.ItemID = hatRes
            entry.FakeItemID = hatRes
            entry.OperationType = ESyncOperation.PutOn
            applyData:Add(entry)
            ok = true
        end
        
    end)
    return ok
end

local _avatarItemsRegistered = false

function F.getDesiredWeaponSkins()
    if PERF.desiredSkins then return PERF.desiredSkins end
    F.syncWeaponCacheFromLobby()
    local out, seen = {}, {}
    local function add(res)
        res = tonumber(res)
        if res and res > 0 and not seen[res] then seen[res] = true; out[#out+1] = res end
    end
    for wid, w in pairs(F.cache().weapons) do
        if wid ~= MELEE_ID and w.resID then add(w.resID) end
    end
    if MATCH_CONFIG.weaponSkins then
        for _, res in pairs(MATCH_CONFIG.weaponSkins) do add(res) end
    end
    PERF.desiredSkins = out
    return out
end

function F._cacheSkinTarget(weaponResID, skin)
    if skin and skin > 0 then PERF.skinTarget[weaponResID] = skin else PERF.skinTarget[weaponResID] = 0 end
    return skin
end

local GUN_MASTER_SYN_SLOT = 7

function F.findSkinSlotInSynData(weapon)
    if not slua.isValid(weapon) then return GUN_MASTER_SYN_SLOT, 0 end
    local arr = weapon.synData
    if not arr or not slua.isValid(arr) then return GUN_MASTER_SYN_SLOT, 0 end
    local count = 0
    pcall(function() count = arr:Num() end)
    for i = 0, math.min(count - 1, 15) do
        local ok2, att = pcall(function() return arr:Get(i) end)
        if ok2 and att then
            local ok3, defRef = pcall(slua.IndexReference, att, "defineID")
            if ok3 and defRef then
                local tid = 0
                pcall(function() tid = tonumber(defRef.TypeSpecificID) or 0 end)
                if tid >= 1000000 then
                    return i, tid
                end
            end
        end
    end
    return GUN_MASTER_SYN_SLOT, 0
end

function F.resolveWeaponTypeID(weaponResID)
    weaponResID = tonumber(weaponResID) or 0
    if weaponResID <= 0 then return 0 end
    local found = 0
    pcall(function()
        local wc = CDataTable.GetTableData("WeaponConfig", weaponResID)
        if wc then found = tonumber(wc.WeaponID or wc.WeaponId or wc.weaponID or 0) end
    end)
    if found > 0 then return found end
    pcall(function()
        local ic = CDataTable.GetTableData("Item", weaponResID)
        if ic then found = tonumber(ic.WeaponID or ic.weaponId or 0) end
    end)
    return found > 0 and found or weaponResID
end

function F.findTargetSkinForWeaponRes(weaponResID)
    weaponResID = tonumber(weaponResID) or 0
    if weaponResID <= 0 then return nil end
    local cached = PERF.skinTarget[weaponResID]
    if cached ~= nil then return cached == 0 and nil or cached end

    local memSkin = F.getMatchWeaponSkin(weaponResID)
    if memSkin then return F._cacheSkinTarget(weaponResID, memSkin) end
    local typeID = F.resolveWeaponTypeID(weaponResID)
    if typeID > 0 and typeID ~= weaponResID then
        memSkin = F.getMatchWeaponSkin(typeID)
        if memSkin then return F._cacheSkinTarget(weaponResID, memSkin) end
    end

    if MATCH_CONFIG.weaponSkins and MATCH_CONFIG.weaponSkins[weaponResID] then
        local fixed = tonumber(MATCH_CONFIG.weaponSkins[weaponResID])
        if fixed and fixed > 0 then return F._cacheSkinTarget(weaponResID, fixed) end
    end

    for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
        local wid = F.weaponIdFromSkin(skinRes)
        if wid and tonumber(wid) == weaponResID then return F._cacheSkinTarget(weaponResID, skinRes) end
    end

    local typeID = F.resolveWeaponTypeID(weaponResID)
    if typeID > 0 and typeID ~= weaponResID then
        if MATCH_CONFIG.weaponSkins and MATCH_CONFIG.weaponSkins[typeID] then
            local fixed = tonumber(MATCH_CONFIG.weaponSkins[typeID])
            if fixed and fixed > 0 then return F._cacheSkinTarget(weaponResID, fixed) end
        end
        for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
            local wid = F.weaponIdFromSkin(skinRes)
            if wid and tonumber(wid) == typeID then return F._cacheSkinTarget(weaponResID, skinRes) end
        end
    end

    local avatarMatch = nil
    pcall(function()
        local AU = import("AvatarUtils")
        local weaponBase = AU.GetWeaponAvatarParentID(AU.GetBPIDByResID(weaponResID), false)
        if not weaponBase or weaponBase <= 0 then return end
        for _, skinRes in ipairs(F.getDesiredWeaponSkins()) do
            local skinBase = AU.GetWeaponAvatarParentID(AU.GetBPIDByResID(skinRes), false)
            if skinBase and skinBase > 0 and skinBase == weaponBase then
                avatarMatch = skinRes
                return
            end
        end
    end)
    if avatarMatch then return F._cacheSkinTarget(weaponResID, avatarMatch) end

    local c = F.cfg(weaponResID)
    local st = F.subType(c)
    if st and GUN_SUB[st] and MATCH_CONFIG.weaponSkins then
        for _, skinRes in pairs(MATCH_CONFIG.weaponSkins) do
            local skinWid = F.weaponIdFromSkin(skinRes)
            if skinWid then
                local sc = F.cfg(tonumber(skinWid))
                if sc and F.subType(sc) == st then return F._cacheSkinTarget(weaponResID, skinRes) end
            end
            local sc = F.cfg(skinRes)
            if sc and GUN_SUB[F.subType(sc)] and F.subType(sc) == st then return F._cacheSkinTarget(weaponResID, skinRes) end
        end
    end

    PERF.skinTarget[weaponResID] = 0
    return nil
end

function F.getSynMasterSkinID(weapon)
    if not slua.isValid(weapon) then return 0 end
    local id = 0
    pcall(function()
        local slot, tid = F.findSkinSlotInSynData(weapon)
        id = tid
        if id == 0 then
            local arr = weapon.synData
            if not arr or not slua.isValid(arr) then return end
            local att = arr:Get(GUN_MASTER_SYN_SLOT)
            if not att then return end
            id = slua.IndexReference(att, "defineID").TypeSpecificID or 0
        end
    end)
    return id
end

_G.AddOutfitSkinIdMappings = _G.AddOutfitSkinIdMappings or {}
_G.AddOutfitLastAppliedSkin = _G.AddOutfitLastAppliedSkin or {}

function F.buildSkinMappings()
    if not PERF.mappingsDirty then return end
    F.syncWeaponCacheFromLobby()
    PERF.mappingsDirty = false
    local m = _G.AddOutfitSkinIdMappings
    for k in pairs(m) do m[k] = nil end
    for wid, w in pairs(F.cache().weapons) do
        wid = tonumber(wid)
        if wid and w.resID and w.resID > 0 then
            m[wid] = { tonumber(w.resID) }
        end
    end
    if MATCH_CONFIG.weaponSkins then
        for weaponKey, skinRes in pairs(MATCH_CONFIG.weaponSkins) do
            weaponKey = tonumber(weaponKey)
            skinRes = tonumber(skinRes)
            if weaponKey and skinRes and skinRes > 0 and not m[weaponKey] then
                m[weaponKey] = { skinRes }
            end
        end
    end
end

function F.get_skin_id(currentGunId, maxIt)
    currentGunId = tonumber(currentGunId) or 0
    maxIt = tonumber(maxIt) or 0
    if currentGunId <= 0 and maxIt <= 0 then return 0 end
    F.buildSkinMappings()
    if maxIt > 0 then
        local fromMem = F.getMatchWeaponSkin(maxIt)
        if fromMem then return fromMem end
    end
    local fromMem2 = F.getMatchWeaponSkin(F.resolveWeaponTypeID(currentGunId))
    if fromMem2 then return fromMem2 end
    local m = _G.AddOutfitSkinIdMappings
    if maxIt > 0 and m[maxIt] and m[maxIt][1] then return tonumber(m[maxIt][1]) end
    local list = m[currentGunId]
    if list and list[1] then return tonumber(list[1]) end
    local typeId = F.resolveWeaponTypeID(currentGunId)
    if typeId > 0 and m[typeId] and m[typeId][1] then return tonumber(m[typeId][1]) end
    local target = F.findTargetSkinForWeaponRes(maxIt > 0 and maxIt or currentGunId)
    if target then return target end
    return currentGunId
end

function F.applySkinToWeaponRef(CurWeapon)
    -- [CHỐT CHẶN 100%] Từ chối mọi yêu cầu vẽ Skin Súng nếu công tắc tắt
    if not _G.LexusConfig.ModSkin then return false end
    
    if not slua.isValid(CurWeapon) then return false end
    local AttachmentArray = CurWeapon.synData
    if not AttachmentArray or not slua.isValid(AttachmentArray) then return false end

    local AttachmentData = AttachmentArray:Get(GUN_MASTER_SYN_SLOT)
    if not AttachmentData then return false end

    local current_gunid = 0
    pcall(function() current_gunid = slua.IndexReference(AttachmentData, "defineID").TypeSpecificID or 0 end)
    if not current_gunid or current_gunid <= 0 then return false end

    local MaxIt = 0
    pcall(function()
        if CurWeapon.GetWeaponID then MaxIt = CurWeapon:GetWeaponID() end
        if MaxIt <= 0 then MaxIt = CurWeapon:GetItemDefineID().TypeSpecificID end
    end)
    MaxIt = tonumber(MaxIt) or 0
    local tmp_id = F.get_skin_id(current_gunid, MaxIt)
    tmp_id = tonumber(tmp_id) or 0
    if tmp_id <= 0 or MaxIt <= 0 then return false end
    
    local changedAny = false

    -- LOGIC 1: LẤY ID HÌNH ẢNH ĐANG HIỂN THỊ THỰC TẾ
    local wac = CurWeapon.WeaponAvatarComponent
    local currentVisualID = 0
    if slua.isValid(wac) then currentVisualID = wac.CachedLoadedID or 0 end

    -- NẾU SÚNG CHÍNH CHƯA PHẢI LÀ SKIN VIP -> THAY ĐỔI DATA
    if currentVisualID ~= tmp_id then
        changedAny = true
        pcall(function()
            local defRef = slua.IndexReference(AttachmentData, "defineID")
            defRef.TypeSpecificID = tmp_id
            local c0 = F.cfg(tmp_id)
            if c0 and c0.ItemType and defRef.Type ~= nil then defRef.Type = c0.ItemType end
            AttachmentData.operationType = 0
            AttachmentArray:Set(GUN_MASTER_SYN_SLOT, AttachmentData)
        end)
    end

    -- LOGIC 2: XỬ LÝ PHỤ KIỆN (ATTACHMENTS)
    if _G.LexusConfig.SkinAttachment and tmp_id >= 1000000 then
        local dynamicAttachMap = nil
        pcall(function() dynamicAttachMap = F.getDynamicAttachmentSkinMap(tmp_id) end)
        local attachSkinConfig = (_G.VIP_Attachments and _G.VIP_Attachments[tmp_id]) or nil
        local baseAttachMap = _G.BaseAttachToIndex

        if dynamicAttachMap or attachSkinConfig then
            -- Quét tới slot 9 để bao gồm cả khiên súng DP28, M249...
            for AttachIdx = 0, 9 do
                if AttachIdx ~= 7 then -- Bỏ qua slot 7 vì là thân súng (Master Gun)
                    pcall(function()
                        local attachData = AttachmentArray:Get(AttachIdx)
                        if attachData then
                            local defineIDRef = slua.IndexReference(attachData, "defineID")
                            if defineIDRef then
                                local attachmentId = defineIDRef.TypeSpecificID
                                if attachmentId and attachmentId > 0 then
                                    local baseAttId = attachmentId
                                    if baseAttId > 1000000 then
                                        local strId = tostring(baseAttId)
                                        if #strId >= 9 then baseAttId = tonumber(string.sub(strId, 2, 7)) or baseAttId end
                                    end

                                    local targetAttachId = 0
                                    if dynamicAttachMap then
                                        targetAttachId = dynamicAttachMap[baseAttId] or 0
                                    end
                                    if (not targetAttachId or targetAttachId <= 0) and attachSkinConfig and baseAttachMap then
                                        local mapIndex = baseAttachMap[baseAttId]
                                        if mapIndex then
                                            targetAttachId = attachSkinConfig[mapIndex] or 0
                                        end
                                    end

                                    if targetAttachId and targetAttachId > 0 and targetAttachId ~= attachmentId then
                                        defineIDRef.TypeSpecificID = targetAttachId
                                        attachData.defineID = defineIDRef
                                        AttachmentArray:Set(AttachIdx, attachData)
                                        changedAny = true
                                        
                                        -- Xóa cache Phụ kiện cũ để game Load phụ kiện VIP
                                        if slua.isValid(wac) then
                                            if wac.ClearMeshPathCacheBySlot then wac:ClearMeshPathCacheBySlot(AttachIdx) end
                                            if wac.ClearMeshBySlot then wac:ClearMeshBySlot(AttachIdx, true, true) end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end

    -- [FIX VIP] LUÔN GHI NHỚ SKIN ĐANG ÁP (KỂ CẢ KHI MESH ĐÃ ĐÚNG) ĐỂ BALO ĐỒNG BỘ
    if tmp_id > 1000000 and MaxIt > 0 then
        _G.AddOutfitLastAppliedSkin = _G.AddOutfitLastAppliedSkin or {}
        _G.AddOutfitLastAppliedSkin[MaxIt] = tmp_id
    end

    -- LOGIC 3: LỆNH THẦN THÁNH ÉP GAME VẼ LẠI MESH NGAY TRÊN TAY
    if changedAny then
        pcall(function()
            if slua.isValid(wac) then
                -- Nếu là súng mới nhặt, xóa cái vỏ súng cũ kĩ đi
                if currentVisualID ~= tmp_id then
                    if wac.ClearMeshPathCacheBySlot then wac:ClearMeshPathCacheBySlot(0) end
                    if wac.ClearMeshBySlot then wac:ClearMeshBySlot(0, true, true) end
                end
                
                if CurWeapon.DelayHandleAvatarMeshChanged then
                    CurWeapon:DelayHandleAvatarMeshChanged()
                end
                if wac.ReloadAllEquippedAvatar then
                    wac:ReloadAllEquippedAvatar(1) 
                end
            end
        end)
        _G.AddOutfitLastAppliedSkin[MaxIt] = tmp_id
        return true
    end
    
    return false
end

function _G.equip_weapon_avatar(uCharacter)
    if not uCharacter or not slua.isValid(uCharacter) then return false end
    F.buildSkinMappings()
    local WeaponManager = uCharacter:GetWeaponManager()
    if not WeaponManager or not slua.isValid(WeaponManager) then return false end
    local uWeaponList = WeaponManager:GetAllInventoryWeaponList(false)
    if not uWeaponList or not slua.isValid(uWeaponList) then return false end

    local appliedAny = false
    for i = 0, uWeaponList:Num() - 1 do
        local CurWeapon = uWeaponList:Get(i)
        if slua.isValid(CurWeapon) and F.applySkinToWeaponRef(CurWeapon) then
            appliedAny = true
        end
    end
    return appliedAny
end

function F.equipWeaponAvatarSynData(char)
    return _G.equip_weapon_avatar(char)
end

F.applySkinToWeapon = F.applySkinToWeaponRef

function F.registerWeaponAvatarItems(char)
    local pc = char.GetPlayerControllerSafety and char:GetPlayerControllerSafety()
    if not slua.isValid(pc) then return false end
    local AU = import("AvatarUtils")
    local BU = import("BackpackUtils")
    local addedCount = 0

    for _, resID in ipairs(F.getDesiredWeaponSkins()) do
        local doneDirect = false
        pcall(function()
            if pc.AddWeaponAvatarItem then
                pc:AddWeaponAvatarItem(tonumber(resID))
                doneDirect = true
                addedCount = addedCount + 1
            end
        end)
        if not doneDirect then
            pcall(function()
                local skinBPID = BU.GetBPIDByResID(tonumber(resID))
                local arr = slua.Array(UEnums.EPropertyClass.Int)
                local parents = AU.GetWeaponAvatarParentIDList(skinBPID, arr, false)
                if parents and parents.Num and parents:Num() > 0 and pc.WeaponAvatarItemList then
                    for _, parentID in pairs(parents) do
                        pc.WeaponAvatarItemList:Add(parentID, skinBPID)
                    end
                    addedCount = addedCount + 1
                end
            end)
        end
    end

    if addedCount == 0 then return false end

    pcall(function() if pc.InitWeaponAvatarItems then pc:InitWeaponAvatarItems() end end)
    pcall(function() if pc.OnWeaponAvatarUpdate then pc:OnWeaponAvatarUpdate() end end)
    return true
end

function F.reloadCurrentWeaponAvatar(char)
    pcall(function()
        local weapon = char.GetCurrentWeapon and char:GetCurrentWeapon()
        if not slua.isValid(weapon) then return end
        local wac = weapon.WeaponAvatarComponent
        if slua.isValid(wac) then
            local ES = import("EWeaponAttachmentSocketType")
            pcall(function() wac:ClearMeshPathCacheBySlot(ES.MasterGun) end)
            pcall(function() wac:ClearMeshBySlot(ES.MasterGun, true, true) end)
        end
        if weapon.DelayHandleAvatarMeshChanged then
            weapon:DelayHandleAvatarMeshChanged()
        elseif slua.isValid(wac) and wac.ReloadAllEquippedAvatar then
            local ESlotDescDiff = import("ESlotDescDiff")
            wac:ReloadAllEquippedAvatar(ESlotDescDiff.MeshDiff)
        end
    end)
end

local _weaponDiagDone = false
local _weaponApplied = false
local _lastWeaponResID = 0
local _weaponSpawnHooked = false

function F.onWeaponLuaInit(_, _, weapon)
    -- [FIX VIP] Ngăn không cho súng load Skin khi vừa cầm lên nếu đã tắt
    if not _G.LexusConfig.ModSkin then return end
    
    if not weapon or not slua.isValid(weapon) then return end
    local char = F.getLocalChar()
    if not char then return end
    local owner = nil
    pcall(function()
        if weapon.GetOwnerPawn then owner = weapon:GetOwnerPawn() end
    end)
    if not slua.isValid(owner) or owner ~= char then return end
    pcall(function()
        char:AddGameTimer(0.15, false, function()
            local c = F.getLocalChar()
            if c and slua.isValid(weapon) then
                F.applySkinToWeapon(weapon)
                _weaponApplied = false
            end
        end)
    end)
end

function F.hookWeaponSpawn()
    if _weaponSpawnHooked then return end
    pcall(function()
        if EventSystem and EventSystem.registEvent and EVENTTYPE_PLAYEREVENT_WEAPON and EVENTID_PLAYEREVENT_WEAPON_LUA_INIT then
            EventSystem:registEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_LUA_INIT, onWeaponLuaInit)
            _weaponSpawnHooked = true
        end
    end)
end

function F.matchApplyWeaponSkin(char)
    if not _avatarItemsRegistered then
        _avatarItemsRegistered = F.registerWeaponAvatarItems(char)
    end

    local curWeapon = char.GetCurrentWeapon and char:GetCurrentWeapon()
    if not slua.isValid(curWeapon) then return false end

    local currentVisualID = 0
    pcall(function()
        local wac = curWeapon.WeaponAvatarComponent
        if slua.isValid(wac) then currentVisualID = wac.CachedLoadedID or 0 end
    end)

    local curWeaponResID = 0
    pcall(function() curWeaponResID = curWeapon:GetItemDefineID().TypeSpecificID end)
    local targetSkin = F.findTargetSkinForWeaponRes(curWeaponResID) or curWeaponResID

    local isVisualMatched = false
    if currentVisualID > 0 and currentVisualID == targetSkin then
        isVisualMatched = true
    end

    -- [HỆ THỐNG SMART WATCHER V3] Quét toàn bộ Súng trên tay & Súng trong Balo
    if not _G.SmartWeaponWatcherActive then
        _G.SmartWeaponWatcherActive = true
        pcall(function()
            local ticker = require("common.time_ticker")
            if ticker and ticker.AddTimerLoop then
                ticker.AddTimerLoop(0, function()
                    if not _G.LexusConfig.ModSkin then return end
                    
                    -- [CỜ NGỦ ĐÔNG IN-GAME]: Nếu đã ra Sảnh -> Ngủ luôn, không chạy gì hết!
                    if _G.AddOutfit and not _G.AddOutfit.isInRealMatch() then return end
                    
                    local pController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                    if not pController or not slua.isValid(pController) then return end
                    local pChar = pController:GetPlayerCharacterSafety()
                    if not pChar or not slua.isValid(pChar) then return end
                    
                    -- Thay vì chỉ lấy súng trên tay, lấy luôn KHO VŨ KHÍ (Weapon Manager)
                    local WeaponManager = pChar:GetWeaponManager()
                    if not WeaponManager or not slua.isValid(WeaponManager) then return end
                    local uWeaponList = WeaponManager:GetAllInventoryWeaponList(false)
                    if not uWeaponList or not slua.isValid(uWeaponList) then return end
                    
                    local count = uWeaponList:Num()
                    -- Lặp qua từng khẩu súng bạn đang sở hữu (Súng 1, Súng 2, Lục, Dao)
                    for i = 0, count - 1 do
                        local wep = uWeaponList:Get(i)
                        if slua.isValid(wep) then
                            -- Kiểm tra data (synData) của súng xem đã là Data VIP chưa
                            local synSkinID = F.getSynMasterSkinID(wep)
                            local baseID = 0
                            pcall(function() baseID = wep:GetItemDefineID().TypeSpecificID end)
                            local tSkin = F.findTargetSkinForWeaponRes(baseID) or baseID
                            
                            -- NẾU DATA CHƯA PHẢI LÀ VIP -> Vừa lụm thẳng vào Balo -> Bắn lệnh Load ngầm!
                            -- HOẶC bật Skin Phụ Kiện -> Kiểm tra phụ kiện
                            if synSkinID ~= tSkin or _G.LexusConfig.SkinAttachment then
                                if _G.AddOutfit and _G.AddOutfit.applySkinToWeapon then
                                    _G.AddOutfit.applySkinToWeapon(wep)
                                end
                            end
                        end
                    end
                end, -1, 0.4) 
            end
        end)
    end

    -- BÁO CÁO HOÀN THÀNH: Nếu súng cầm trên tay đã xong xuôi thì khóa luồng gốc của Engine
    if isVisualMatched and not _G.LexusConfig.SkinAttachment then
        _weaponApplied = true
        return true
    end

    F.buildSkinMappings()
    local okSyn = F.applySkinToWeapon(curWeapon)

    return okSyn
end

local _matchTimer = nil
local _matchWearDone = false

function F.startMatchWatcher(char)
    if _matchTimer or PERF.matchActive then return end
    PERF.matchActive = true
    local skipWear = PERF.wearDoneThisMatch
    _matchWearDone = skipWear
    _avatarItemsRegistered = false
    _weaponDiagDone = false
    _weaponApplied = false
    _lastWeaponResID = 0
    local elapsed = 0

    _matchTimer = char:AddGameTimer(MATCH_TICK_SEC, true, function()
        -- [FIX VIP] Nếu tắt Mod Skin thì dừng việc ép skin vào trận
        if not _G.LexusConfig.ModSkin then return end
        
        elapsed = elapsed + MATCH_TICK_SEC
        local cur = F.getLocalChar()
        if not cur or not slua.isValid(cur) then return end

        if not _matchWearDone then
            _matchWearDone = F.matchApplyAllSlots(cur)
        end
        F.matchApplyHat(cur)
        F.matchApplyFaceWear(cur) -- [FIX VIP] Bổ sung lệnh gọi ép Kính & Mặt Nạ chạy liên tục giống Mũ
        if not _weaponApplied then
            F.matchApplyWeaponSkin(cur)
        end
        if F.isCharacterAirborne(cur) then
            F.applyAirborneSlots(cur, true)
        end

        if (_matchWearDone and _weaponApplied) or elapsed >= MATCH_MAX_SEC then
            if _matchWearDone then
                PERF.wearDoneThisMatch = true
            end
            if _matchTimer and cur.RemoveGameTimer then
                pcall(function() cur:RemoveGameTimer(_matchTimer) end)
            end
            _matchTimer = nil
            PERF.matchActive = false
        end
    end)
end

function F.stopMatchWatcher()
    if _matchTimer then
        pcall(function()
            local char = F.getLocalChar()
            if char and char.RemoveGameTimer then char:RemoveGameTimer(_matchTimer) end
        end)
        _matchTimer = nil
    end
    PERF.matchActive = false
    PERF.wearDoneThisMatch = false
    _matchWearDone = false
    _avatarItemsRegistered = false
    _weaponApplied = false
    _weaponDiagDone = false
    _lastWeaponResID = 0
end

function F.hookAirborneCache()
    if _G.AddOutfitAirborneHooked then return end
    _G.AddOutfitAirborneHooked = true
    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_ITEM_LIST then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST, function()
                F.syncAirborneCacheFromLobby()
            end)
        end
    end)
end

function F.hookPutOnRsp()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        local o = wl.on_puton_rsp
        wl.on_puton_rsp = function(self, res, item, olditem, index, extra)
            o(self, res, item, olditem, index, extra)
            if not item or not item.instid then return end
            local resID = tonumber(item.res_id)
            local insID = tonumber(item.instid)
            if not resID or not insID then return end
            local c = F.cfg(resID)
            local st = F.subType(c)
            if st == OUTFIT_SUB then
                F.saveEquip(resID, insID)
            elseif st == HAT_SUB or FACE_SUBS[st] or BODY_SUBS[st] or HELMET_SUBS[st]
                or st == PARACHUTE_SUB or F.isGlideRes(resID) or st == GLOVES_SUB then
                F.saveEquip(resID, insID)
            elseif F.isParachuteRes(resID) or F.isGlideRes(resID) then
                F.saveEquip(resID, insID)
            elseif HEAD_SUBS[st] then
                F.saveEquip(resID, insID)
            elseif GUN_SUB[st] then
                local wid = F.weaponIdFromSkin(resID)
                if wid then F.cacheWeaponSkinFromIns(wid, insID) end
            elseif st == MELEE_ID then
                F.cacheWeaponSkinFromIns(MELEE_ID, insID)
            elseif F.isInjectedIns(insID) then
                F.saveEquip(resID, insID)
            end
        end
    end)
end

function F.hookLobbyWeaponCache()
    if _G.AddOutfitLobbyWeaponCacheHooked then return end
    _G.AddOutfitLobbyWeaponCacheHooked = true
    pcall(function()
        local Arm = require("client.logic.armory.logic_armory")
        local oRsp = Arm.install_weapon_skin_rsp
        Arm.install_weapon_skin_rsp = function(client_data, errorCode, weapon_id, instanceID)
            oRsp(client_data, errorCode, weapon_id, instanceID)
            if (errorCode == 0 or errorCode == NET_OK) and F.isWeaponSkinIns(instanceID) then
                F.cacheWeaponSkinFromIns(weapon_id, instanceID)
            end
        end
        local oH = Arm.HandleWeaponSkinChange
        Arm.HandleWeaponSkinChange = function(client_data, weapon_id, instanceID)
            oH(client_data, weapon_id, instanceID)
            if F.isWeaponSkinIns(instanceID) then
                F.cacheWeaponSkinFromIns(weapon_id, instanceID)
            end
        end
    end)
    pcall(function()
        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
        local o = wgl.on_put_on_weapon_wear_rsp
        wgl.on_put_on_weapon_wear_rsp = function(self, client_data, res, weapon_id, new_skin_id, extra_weapon_list)
            o(self, client_data, res, weapon_id, new_skin_id, extra_weapon_list)
            if res == 0 or res == NET_OK then
                F.cacheWeaponSkinFromIns(weapon_id, new_skin_id)
            end
        end
    end)
    pcall(function()
        if not EventSystem or not EventSystem.registEvent then return end
        if EVENTTYPE_WARDROBE and EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN then
            EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, function(_, _, resOrFlag, weapon_id)
                weapon_id = tonumber(weapon_id)
                if weapon_id and weapon_id > 0 then
                    pcall(function()
                        local wgl = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
                        local insID = tonumber(wgl:GetSkinIdByWeaponID(weapon_id)) or 0
                        if insID > 0 then F.cacheWeaponSkinFromIns(weapon_id, insID) end
                    end)
                elseif tonumber(resOrFlag) and tonumber(resOrFlag) > 100000 then
                    pcall(function()
                        local wid = F.weaponIdFromSkin(resOrFlag)
                        if wid then
                            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                            local ins = wd.GetWardrobeInsIdByResId and wd:GetWardrobeInsIdByResId(resOrFlag)
                            if ins and ins > 0 then F.cacheWeaponSkinFromIns(wid, ins) end
                        end
                    end)
                end
            end)
        end
    end)
    pcall(function()
        local WRH = require("client.network.Protocol.WardRobeHandler")
        local oHeadReq = WRH.send_depot_set_head_show_req
        WRH.send_depot_set_head_show_req = function(insID)
            insID = tonumber(insID) or 0
            if insID > 0 and F.isInjectedIns(insID) then
                local wd = require("client.slua.logic.wardrobe.wardrobe_data")
                local d = wd:GetHallDepotItemDataByInsID(insID)
                if d and d.resID then
                    F.saveEquip(tonumber(d.resID), insID)
                end
                local fbd = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
                fbd:SetHeadShow(insID)
                WRH.on_depot_set_head_show_rsp(NET_OK, insID)
                return
            end
            return oHeadReq(insID)
        end
        local oHead = WRH.on_depot_set_head_show_rsp
        WRH.on_depot_set_head_show_rsp = function(err_code, id)
            oHead(err_code, id)
            if err_code ~= 0 and err_code ~= NET_OK then return end
            id = tonumber(id) or 0
            if id <= 0 then return end
            local wd = require("client.slua.logic.wardrobe.wardrobe_data")
            local d = wd:GetHallDepotItemDataByInsID(id)
            if d and d.resID then
                local st = tonumber(d.itemSubType or F.subType(F.cfg(d.resID)))
                if st == HAT_SUB or HELMET_SUBS[st] then
                    F.saveEquip(tonumber(d.resID), id)
                end
            end
        end
    end)
end

function F.hookWardrobePutOnReq()
    pcall(function()
        local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
        if wl._AddOutfitPutOnReqHooked then return end
        wl._AddOutfitPutOnReqHooked = true
        local oReq = wl.wardrobe_puton_req
        wl.wardrobe_puton_req = function(self, insID, extra)
            insID = tonumber(insID)
            F.ensureDepotItemValid(insID)
            if F.tryLocalWearByIns(insID) then return end
            return oReq(self, insID, extra)
        end
        if not wl._AddOutfitPutOnDataHooked then
            wl._AddOutfitPutOnDataHooked = true
            local oData = wl.wardrobe_puton_data_req
            wl.wardrobe_puton_data_req = function(self, itemData)
                if itemData then
                    local insID = tonumber(itemData.ins_id or itemData.insID)
                    local resID = tonumber(itemData.res_id or itemData.resID)
                    F.clearItemExpire(itemData, insID, resID)
                    F.ensureDepotItemValid(insID, resID)
                end
                return oData(self, itemData)
            end
        end
    end)
end

local _bootstrapNotified = false

function F.bootstrapMatch(char)
    char = char or F.getLocalChar()
    if not char or not slua.isValid(char) then return false end
    if PERF.matchActive then return true end
    local now = os.clock()
    if (now - PERF.lastBootstrapAt) < BOOTSTRAP_COOLDOWN then return false end
    PERF.lastBootstrapAt = now
    F.syncWeaponCacheFromLobby(true)
    F.applyPersistSlotsToCache()
    F.cleanArmoryPollution()
    F.syncGlobalWearSkins()
    F.syncAirborneToDataMgr()
    pcall(function() F.applyAirborneSlots(char, F.isCharacterAirborne(char)) end)
    F.syncVehicleCacheFromDataMgr()
    F.syncVehicleSlotsToDataMgr()
    pcall(function() F.applyVehicleSkinsToPC(F.getPC()) end)
    F.startVehicleSkinTicker()
    pcall(function()
        local v = F.getMatchVehicle()
        if slua.isValid(v) then F.autoApplyVehicleSkinOnEnter(v) end
    end)
    _weaponApplied = false
    _weaponDiagDone = false
    _matchApplied = false
    if not _bootstrapNotified then
        _bootstrapNotified = true
    end
    F.startMatchWatcher(char)
    return true
end

function F.hookMatchAvatar()
    pcall(function()
        local CAC = require("GameLua.Mod.Library.GamePlay.Avatar.Component.CharacterAvatarComponent")
        local o = CAC.OnAvatarAllMeshLoadedLua
        CAC.OnAvatarAllMeshLoadedLua = function(self)
            o(self)
            pcall(function()
                if self.IsLobbyActor and self:IsLobbyActor() then return end
                local isSelf = self.IsSelf and self:IsSelf()
                if not isSelf then return end
                if PERF.wearDoneThisMatch or PERF.matchActive then return end
                local char = F.getLocalChar()
                if char and char.AddGameTimer then
                    char:AddGameTimer(0.5, false, function() F.bootstrapMatch(char) end)
                end
            end)
        end
    end)
    pcall(function()
        local WAC = require("GameLua.Mod.Library.GamePlay.Avatar.Component.WeaponAvatarComponent")
        local oLoad = WAC.OnWeaponAvatarLoadedLua
        WAC.OnWeaponAvatarLoadedLua = function(self, slotID, definedID)
            oLoad(self, slotID, definedID)
            pcall(function()
                if self.IsLobbyActor and self:IsLobbyActor() then return end
                local isSelf = self.IsSelf and self:IsSelf()
                if not isSelf then return end
                local char = F.getLocalChar()
                if not char then return end
                _weaponApplied = false
                if not PERF.matchActive then F.bootstrapMatch(char)
                elseif char.AddGameTimer then
                    char:AddGameTimer(0.25, false, function()
                        local c = F.getLocalChar()
                        if c then F.matchApplyWeaponSkin(c) end
                    end)
                end
            end)
        end
    end)
end

function F.hookVehicleInfoInit()
    pcall(function()
        if DataMgr._AddOutfitVehInfoHooked then return end
        DataMgr._AddOutfitVehInfoHooked = true
        local orig = DataMgr.InitVehicleInfo
        DataMgr.InitVehicleInfo = function(vehicle_info, vst_skin)
            vehicle_info = F.mergeInjectedIntoVehicleSlotList(vehicle_info)
            orig(vehicle_info, vst_skin)
            F.later(0.15, function()
                F.reapplyVehicleSlotsFromConfig()
                F.reapplyHallThemeFromConfig()
                LOBBY.reapplyDone = false
                LOBBY.reapplyScheduled = false
                F.scheduleLobbyReapplyOnce()
            end)
        end
    end)
end

function F.hookVehicleSkinDataInit()
    pcall(function()
        if DataMgr._AddOutfitVehSkinDataHooked then return end
        DataMgr._AddOutfitVehSkinDataHooked = true
        local origInit = DataMgr.InitVehicleSkinData
        DataMgr.InitVehicleSkinData = function(data)
            data = F.mergeInjectedVehicleSkinTable(data)
            origInit(data)
            F.later(0.1, function()
                F.equipVehicleTypesFromConfig(PERSIST.configVehicleSlots)
            end)
        end
        local origUpd = DataMgr.UpdateVehicleSkin
        DataMgr.UpdateVehicleSkin = function(itemSubType, putOnId)
            origUpd(itemSubType, putOnId)
            if not _G.AddOutfitApplyingConfig and F.isInjectedIns(putOnId) then
                F.setLobbyVehicleManual(itemSubType, R.insToRes[putOnId], putOnId)
            end
        end
    end)
    pcall(function()
        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
        if HallThemeUtils._AddOutfitLobbyVehHooked then return end
        HallThemeUtils._AddOutfitLobbyVehHooked = true
        local orig = HallThemeUtils.ProcPutOnVehicle
        HallThemeUtils.ProcPutOnVehicle = function(putOnItem, bShowVehicle)
            orig(putOnItem, bShowVehicle)
            if not _G.AddOutfitApplyingConfig and putOnItem then
                local ins = tonumber(putOnItem.instid)
                local res = tonumber(putOnItem.res_id)
                if ins and F.isInjectedIns(ins) then
                    F.setLobbyVehicleManual(F.vehicleSubType(res or R.insToRes[ins]), res or R.insToRes[ins], ins)
                end
            end
        end
    end)
end

function F.hookHallTheme()
    pcall(function()
        local HT = require("client.logic.lobby.hall_theme_utils")
        if HT._AddOutfitHallThemeHooked then return end
        HT._AddOutfitHallThemeHooked = true
        local orig = HT.ProcPutOnHallTheme
        HT.ProcPutOnHallTheme = function(putOnItem, putOffItem)
            orig(putOnItem, putOffItem)
            if not _G.AddOutfitApplyingTheme and putOnItem then
                local ins = tonumber(putOnItem.instid)
                local res = tonumber(putOnItem.res_id)
                if ins and F.isInjectedIns(ins) then
                    F.setHallThemeManual(res or R.insToRes[ins], ins)
                end
            end
        end
    end)
end

function F.hookGarageTheme()
    pcall(function()
        local TeamupHandler = require("client.network.Protocol.TeamupHandler")
        local ModuleManager = require("client.module_framework.ModuleManager")
        if not TeamupHandler then return end
        
        -- Hook: Update Từng Slot Xe ở sảnh
        local o_send_update = TeamupHandler.send_update_car_main_page_slot_req
        if o_send_update and not TeamupHandler._AddOutfitGarageUpdateHooked then
            TeamupHandler._AddOutfitGarageUpdateHooked = true
            TeamupHandler.send_update_car_main_page_slot_req = function(slot_id, item_inst_id)
                
                -- [TỐI ƯU FPS - NGỦ ĐÔNG] Nếu đang trong trận thực sự -> Bỏ qua toàn bộ logic Gara Sảnh, trả về game gốc ngay lập tức!
                if F.isInRealMatch() then 
                    return o_send_update(slot_id, item_inst_id) 
                end

                if F.isInjectedIns(tonumber(item_inst_id)) then
                    local resID = R.insToRes[tonumber(item_inst_id)]
                    local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
                    if not GarageThemeSystem then return end

                    GarageThemeSystem.GarageVehicleInfo[slot_id] = {
                        inst_id = tonumber(item_inst_id),
                        res_id = resID
                    }

                    for k, v in pairs(GarageThemeSystem.GarageVehicleInfo) do
                        if k ~= slot_id and v.inst_id == tonumber(item_inst_id) then
                            GarageThemeSystem.GarageVehicleInfo[k] = nil
                        end
                    end

                    pcall(function() GarageThemeSystem:ReportSpecialEffectTlog() end)
                    if EventSystem and EVENTTYPE_LOBBY_THEME and EVENTID_GARAGE_VEHICLE_DATA_CHANGE then
                        EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
                    end

                    local itemCfg = F.cfg(resID)
                    if itemCfg and DataMgr and DataMgr.UpdateVehicleSkin then
                        local subType = itemCfg.ItemSubType or itemCfg.itemSubType
                        DataMgr.UpdateVehicleSkin(subType, tonumber(item_inst_id))
                    end
                    if DataMgr then DataMgr.vst_skin = tonumber(item_inst_id) end
                    
                    pcall(function()
                        local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
                        if HallThemeUtils then
                            if HallThemeUtils.UpdateThemeVehicleShow then HallThemeUtils.UpdateThemeVehicleShow() end
                            if HallThemeUtils.ShowThemeVehicle then HallThemeUtils.ShowThemeVehicle() end
                        end
                    end)
                    return
                end
                return o_send_update(slot_id, item_inst_id)
            end
        end

        -- Hook: Update Hàng loạt xe ở sảnh
        local o_send_batch = TeamupHandler.send_batch_put_on_sportscar_req
        if o_send_batch and not TeamupHandler._AddOutfitGarageBatchHooked then
            TeamupHandler._AddOutfitGarageBatchHooked = true
            TeamupHandler.send_batch_put_on_sportscar_req = function(instid_list)
                
                -- [TỐI ƯU FPS - NGỦ ĐÔNG] Tương tự, chặn đứng khi đang trong trận
                if F.isInRealMatch() then 
                    return o_send_batch(instid_list) 
                end

                if type(instid_list) ~= "table" then
                    return o_send_batch(instid_list)
                end

                local hasInjected = false
                for slot_id, item_inst_id in pairs(instid_list) do
                    if F.isInjectedIns(tonumber(item_inst_id)) then
                        hasInjected = true
                        break
                    end
                end

                if not hasInjected then
                    return o_send_batch(instid_list)
                end

                local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
                if not GarageThemeSystem then return end

                for slot_id, item_inst_id in pairs(instid_list) do
                    local insID = tonumber(item_inst_id)
                    if F.isInjectedIns(insID) then
                        local resID = R.insToRes[insID]
                        if insID ~= 0 and resID then
                            GarageThemeSystem.GarageVehicleInfo[slot_id] = {
                                inst_id = insID,
                                res_id = resID
                            }
                        else
                            GarageThemeSystem.GarageVehicleInfo[slot_id] = nil
                        end
                    end
                end

                pcall(function() GarageThemeSystem:ReportSpecialEffectTlog() end)
                if EventSystem and EVENTTYPE_LOBBY_THEME and EVENTID_GARAGE_VEHICLE_DATA_CHANGE then
                    EventSystem:postEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE)
                end

                local nonInjected = {}
                for slot_id, item_inst_id in pairs(instid_list) do
                    if not F.isInjectedIns(tonumber(item_inst_id)) then
                        nonInjected[slot_id] = item_inst_id
                    end
                end
                if next(nonInjected) then
                    return o_send_batch(nonInjected)
                end
            end
        end
    end)
end

function F.hookEnterGame()
    if _G.AddOutfitEnterGameHooked then return end
    _G.AddOutfitEnterGameHooked = true
    pcall(function()
        if EventSystem and EventSystem.registEvent and EVENTTYPE_LOBBY and EVENTID_ENTER_GAME_BEGIN then
            EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, function()
                F.perfInvalidateLobby()
                F.syncWeaponCacheFromLobby(true)
                F.reapplyVehicleSlotsFromConfig(true)
                F.reapplyHallThemeFromConfig(true)
                pcall(F.applyVehicleSkinsToPC)
                F.stopMatchWatcher()
                _bootstrapNotified = false
            end)
        end
    end)
end

function F.afterInjectApply(firstTime)
    F.mergeInjectedArmorySkins()
    F.cleanArmoryPollution()
    if firstTime then
        F.refreshWardrobeOnce()
        F.persistApplyLoaded()
        F.hookGarageTheme()
        F.syncLobbyVehicleResFromIns()
        F.reapplyVehicleSlotsFromConfig(true)
        F.reapplyHallThemeFromConfig(true)
        F.reapplyWeaponsFromConfig()
        F.scheduleLobbyReapplyOnce()
    else
        F.reapplyWeaponsFromConfig()
    end
end

-- ==============================================================================
-- [FIX VIP] HỆ THỐNG ĐỒNG BỘ SKIN BALO + KILL COUNTER (V2)
-- Đọc skin THẬT đang gắn trên súng (synData slot 7) của nhân vật local.
-- ==============================================================================
local EquippedSkinScan = { skins = {}, lastScan = 0 }

function F.getAppliedWeaponSkinByBase(baseWeaponID)
    baseWeaponID = tonumber(baseWeaponID) or 0
    if baseWeaponID <= 0 then return nil end
    local now = os.clock()
    if not EquippedSkinScan.skins or (now - (EquippedSkinScan.lastScan or 0)) > 2.0 then
        EquippedSkinScan.lastScan = now
        local fresh = {}
        pcall(function()
            local char = F.getLocalChar()
            if not char or not slua.isValid(char) then return end
            local WeaponManager = nil
            pcall(function() if char.GetWeaponManager then WeaponManager = char:GetWeaponManager() end end)
            if not slua.isValid(WeaponManager) then return end
            local uWeaponList = nil
            pcall(function() if WeaponManager.GetAllInventoryWeaponList then uWeaponList = WeaponManager:GetAllInventoryWeaponList(false) end end)
            if not slua.isValid(uWeaponList) then return end
            local count = 0
            pcall(function() if type(uWeaponList.Num) == "function" then count = uWeaponList:Num() end end)
            for i = 0, count - 1 do
                local wep = nil
                pcall(function() if type(uWeaponList.Get) == "function" then wep = uWeaponList:Get(i) end end)
                if slua.isValid(wep) then
                    local baseID = 0
                    pcall(function()
                        if wep.GetWeaponID then baseID = tonumber(wep:GetWeaponID()) or 0 end
                        if baseID <= 0 then
                            local did = nil
                            if wep.GetItemDefineID then did = wep:GetItemDefineID() end
                            if did and slua.isValid(did) then baseID = tonumber(did.TypeSpecificID) or 0 end
                        end
                    end)
                    local skinID = tonumber(F.getSynMasterSkinID(wep)) or 0
                    if baseID > 0 and skinID > 1000000 then
                        fresh[baseID] = skinID
                    end
                end
            end
        end)
        EquippedSkinScan.skins = fresh
    end
    return EquippedSkinScan.skins[baseWeaponID]
end

function F.baseWeaponIDFromAny(skinOrBaseID)
    skinOrBaseID = tonumber(skinOrBaseID) or 0
    if skinOrBaseID <= 0 then return 0 end
    if skinOrBaseID < 1000000 then return skinOrBaseID end
    local s = tostring(skinOrBaseID)
    if #s >= 9 then
        local base = tonumber(string.sub(s, 2, 7))
        if base and base > 100000 then return base end
    end
    local m = CDataTable and CDataTable.GetTableData and CDataTable.GetTableData("WeaponSkinMapping", skinOrBaseID)
    if m and m.WeaponID then
        local wid = tonumber(m.WeaponID)
        if wid and wid > 0 then return wid end
    end
    return skinOrBaseID
end

-- ==============================================================================
-- [THÊM MỚI] SKIN PHỤ KIỆN TRONG BALO: quét súng đang cầm
-- ==============================================================================
function F.getModSkinForWeapon(wid)
    local lookupID = F.baseWeaponIDFromAny(wid)
    local skinID = 0
    pcall(function()
        if _G.AddOutfitLastAppliedSkin and _G.AddOutfitLastAppliedSkin[lookupID] then
            skinID = tonumber(_G.AddOutfitLastAppliedSkin[lookupID]) or 0
        end
    end)
    if not skinID or skinID <= 0 then
        pcall(function() skinID = tonumber(F.getAppliedWeaponSkinByBase(lookupID)) or 0 end)
    end
    if not skinID or skinID <= 0 then
        pcall(function() skinID = tonumber(F.findTargetSkinForWeaponRes(lookupID)) or 0 end)
    end
    return tonumber(skinID) or 0
end

-- ==============================================================================
-- BẢNG PHỤ KIỆN ĐỘNG LẤY TỪ CHÍNH GAME (TỰ ĐỘNG TƯƠNG THÍCH MỌI SÚNG)
-- ==============================================================================
local DynamicAttachMapCache = {}

function F.getDynamicAttachmentSkinMap(skinID)
    skinID = tonumber(skinID) or 0
    if skinID <= 0 then return nil end
    if DynamicAttachMapCache[skinID] ~= nil then
        return DynamicAttachMapCache[skinID] 
    end
    local result = nil
    pcall(function()
        local rawList = nil
        local itemCfg = CDataTable.GetTableData("Item", skinID)
        if itemCfg and itemCfg.BPID then
            local bpCfg = CDataTable.GetTableData("WeaponAttrBPTable", itemCfg.BPID)
            if bpCfg then rawList = bpCfg.AttachmentSkinIDList end
        end
        if (not rawList or rawList == "") then
            local mapCfg = CDataTable.GetTableData("WeaponSkinMapping", skinID)
            if mapCfg then rawList = mapCfg.AttachmentSkinIDList end
        end
        if rawList and rawList ~= "" then
            local StringUtil = require("common.string_util")
            result = {}
            for _, v in pairs(StringUtil.Split(rawList, "|")) do
                local parts = StringUtil.Split(v, "-")
                local baseId = tonumber(parts[1]) or 0
                local attachSkinId = tonumber(parts[2]) or 0
                if baseId > 0 and attachSkinId > 0 then
                    result[baseId] = attachSkinId
                end
            end
            if not next(result) then result = nil end
        end
    end)
    DynamicAttachMapCache[skinID] = result
    return result
end

local AttachSkinScan = { last = 0, map = nil }

function F.getAttachmentSkinForBase(baseAttachID, specificWeaponSkinID)
    baseAttachID = tonumber(baseAttachID) or 0
    if baseAttachID <= 0 then return nil end
    if not (_G.LexusConfig and _G.LexusConfig.ModSkin == true) then return nil end
    
    if specificWeaponSkinID and specificWeaponSkinID > 1000000 then
        local dyn = nil
        pcall(function() dyn = F.getDynamicAttachmentSkinMap(specificWeaponSkinID) end)
        if dyn and dyn[baseAttachID] then
            local s = tonumber(dyn[baseAttachID])
            if s and s > 0 then return s end
        end
        local cfg = _G.VIP_Attachments and _G.VIP_Attachments[specificWeaponSkinID]
        if cfg then
            for base, idx in pairs(_G.BaseAttachToIndex or {}) do
                if tonumber(base) == baseAttachID then
                    local s = tonumber(cfg[idx])
                    if s and s > 0 then return s end
                end
            end
        end
    end

    local now = os.clock()
    if not AttachSkinScan.map or (now - (AttachSkinScan.last or 0)) > 2.0 then
        AttachSkinScan.last = now
        local fresh = {}
        pcall(function()
            local char = F.getLocalChar()
            if not char or not slua.isValid(char) then return end
            local WeaponManager = nil
            pcall(function() if char.GetWeaponManager then WeaponManager = char:GetWeaponManager() end end)
            if not slua.isValid(WeaponManager) then return end
            local uWeaponList = nil
            pcall(function() if WeaponManager.GetAllInventoryWeaponList then uWeaponList = WeaponManager:GetAllInventoryWeaponList(false) end end)
            if not slua.isValid(uWeaponList) then return end
            local count = 0
            pcall(function() if type(uWeaponList.Num) == "function" then count = uWeaponList:Num() end end)
            for i = 0, count - 1 do
                local wep = nil
                pcall(function() if type(uWeaponList.Get) == "function" then wep = uWeaponList:Get(i) end end)
                if slua.isValid(wep) then
                    local rawID = tonumber(F.getSynMasterSkinID(wep)) or 0
                    local skinID = 0
                    if rawID > 0 then
                        skinID = F.getModSkinForWeapon(rawID)
                        if not skinID or skinID <= 0 then skinID = rawID end
                    end
                    
                    if skinID > 1000000 then
                        local dyn = nil
                        pcall(function() dyn = F.getDynamicAttachmentSkinMap(skinID) end)
                        if dyn then
                            for base, skin in pairs(dyn) do
                                base = tonumber(base)
                                skin = tonumber(skin)
                                if base and skin and base > 0 and skin > 0 then fresh[base] = skin end
                            end
                        end
                        local cfg = _G.VIP_Attachments and _G.VIP_Attachments[skinID]
                        if cfg then
                            for base, idx in pairs(_G.BaseAttachToIndex or {}) do
                                local v = tonumber(cfg[idx]) or 0
                                if v > 0 then fresh[base] = v end
                            end
                        end
                    end
                end
            end
        end)
        AttachSkinScan.map = fresh
    end
    return AttachSkinScan.map[baseAttachID]
end

-- ==============================================================================
    -- ================= HỆ THỐNG MOD EMOTE VIP (SẢNH + TRONG TRẬN) =================
    -- ==============================================================================
    function F.hookMotionEquip()
        pcall(function()
            local wl = require("client.slua.logic.wardrobe.logic_wardrobe_new")
            if wl._lava_hooked_motion then return end
            wl._lava_hooked_motion = true

            local origEquip = wl.EquipMotion
            wl.EquipMotion = function(self, instid, dst_slot)
                instid = tonumber(instid)
                if instid and F.isInjectedIns(instid) then
                    local insSlot = 0
                    for i, v in ipairs(DataMgr.MotionSlotList) do
                        if v == instid then insSlot = i; break end
                    end
                    if insSlot > 0 then
                        local curIns = DataMgr.MotionSlotList[dst_slot]
                        if curIns == instid then return end
                        DataMgr.MotionSlotList[insSlot] = curIns or 0
                        DataMgr.MotionSlotList[dst_slot] = instid
                    else
                        while #DataMgr.MotionSlotList < dst_slot do
                            table.insert(DataMgr.MotionSlotList, 0)
                        end
                        DataMgr.MotionSlotList[dst_slot] = instid
                    end
                    if EventSystem and EVENTTYPE_MOTION and EVENTID_MOTION_UPDATE_SLOT_LIST then
                        EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST)
                    end
                    pcall(F.persistMarkDirty)
                    return
                end
                return origEquip(self, instid, dst_slot)
            end

            local origUnequip = wl.unequip_motion_req
            wl.unequip_motion_req = function(self, instid, slot)
                instid = tonumber(instid)
                if instid and F.isInjectedIns(instid) then
                    for i, v in ipairs(DataMgr.MotionSlotList) do
                        if v == instid then
                            table.remove(DataMgr.MotionSlotList, i)
                            break
                        end
                    end
                    if EventSystem and EVENTTYPE_MOTION and EVENTID_MOTION_UPDATE_SLOT_LIST then
                        EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST)
                    end
                    pcall(F.persistMarkDirty)
                    return
                end
                return origUnequip(self, instid, slot)
            end
        end)
    end

    local _emoteSlotKey = nil
    local _emoteSlotCache = {}
    function F.getInjectedEmotes()
        local slotList = DataMgr and DataMgr.MotionSlotList or {}
        local key = table.concat(slotList, ",")
        if key == _emoteSlotKey then return _emoteSlotCache end
        _emoteSlotKey = key
        _emoteSlotCache = {}
        for _, insID in ipairs(slotList) do
            insID = tonumber(insID)
            if insID and insID > 0 and F.isInjectedIns(insID) then
                local resID = R.insToRes[insID]
                if resID then
                    local c = F.cfg(resID)
                    if c and tonumber(c.ItemType or c.itemType) == 22 then
                        _emoteSlotCache[#_emoteSlotCache + 1] = {
                            resID = resID,
                            name = c.ItemName or "",
                            icon = c.ItemSmallIcon or c.ItemIcon or ""
                        }
                    end
                end
            end
        end
        return _emoteSlotCache
    end

    function F.hookIngameEmote()
        pcall(function()
            local QEU = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
            if QEU._lava_hooked_emote then return end
            QEU._lava_hooked_emote = true

            local origGetList = QEU.GetShowExpressionList
            QEU.GetShowExpressionList = function()
                local tShowEmoteList, nWeaponEmoteId = origGetList()
                tShowEmoteList = tShowEmoteList or {}
                
                if _G.LexusConfig and _G.LexusConfig.ModEmote then
                    local emotes = F.getInjectedEmotes()
                    if #emotes > 0 then
                        local existingIDs = {}
                        for _, existing in pairs(tShowEmoteList) do
                            if existing.DefineID then
                                existingIDs[tonumber(existing.DefineID.TypeSpecificID) or 0] = true
                            end
                        end
                        for _, em in ipairs(emotes) do
                            if not existingIDs[em.resID] then
                                tShowEmoteList[#tShowEmoteList + 1] = {
                                    DefineID = {TypeSpecificID = em.resID},
                                    Name = em.name
                                }
                            end
                        end
                    end
                end
                return tShowEmoteList, nWeaponEmoteId
            end
        end)

        pcall(function()
            local QE = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpression")
            if QE._lava_hooked_emote_img then return end
            QE._lava_hooked_emote_img = true

            local origGetImg = QE.GetEmoteImagePalthMap
            QE.GetEmoteImagePalthMap = function(self, ...)
                origGetImg(self, ...)
                if _G.LexusConfig and _G.LexusConfig.ModEmote then
                    local emotes = F.getInjectedEmotes()
                    for _, em in ipairs(emotes) do
                        if em.icon ~= "" then
                            self.ItemIDToImagePathMap[em.resID] = em.icon
                        end
                    end
                end
            end
        end)

        pcall(function()
            local le = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
            if le._lava_hooked_emote_exist then return end
            le._lava_hooked_emote_exist = true

            local origExist = le.IsEmoteExist
            le.IsEmoteExist = function(EmoteID)
                if _G.LexusConfig and _G.LexusConfig.ModEmote and F.isInjectedRes(tonumber(EmoteID)) then return true end
                return origExist(EmoteID)
            end

            local origDownloaded = le.CheckEmoteDownloaded
            if origDownloaded then
                le.CheckEmoteDownloaded = function(EmoteID, bUseCache, bLobby, bForeceLobby)
                    if _G.LexusConfig and _G.LexusConfig.ModEmote and F.isInjectedRes(tonumber(EmoteID)) then return true end
                    return origDownloaded(EmoteID, bUseCache, bLobby, bForeceLobby)
                end
            end
        end)
    end

function F.start()
    F.restorePufferHooks()
    F.buildSkinMappings()
    if not _G.AddOutfitPersistLoaded then
        _G.AddOutfitPersistLoaded = true
        F.persistLoadFromDisk()
    end
    F.applyPersistSlotsToCache()
    F.syncGlobalWearSkins()
    
    _G.apply_vehicle_skin = F.matchApplyVehicleSkin
    _G.skinIdMappings = _G.AddOutfitSkinIdMappings
    
    F.hookDepotInit()
    F.hookWardrobeData()
    F.hookPageFilter()
    F.hookArmory()
    F.hookGunSkinId()
    F.hookPutOn()
    F.hookPutDown()
    F.hookVehicles()
    F.hookAirborneClick()
    F.hookVehicleInfoInit()
    F.hookVehicleSkinDataInit()
    F.hookHallTheme()
    F.hookWeaponWear()
    F.hookNotice()
    F.hookAvatarValid()
    F.hookPutOnRsp()
    F.hookAirborneCache()
    F.hookLobbyWeaponCache()
    F.hookLobbySwipePersistence()
    F.hookWardrobePutOnReq()
    F.hookWardrobeWearClicks()
    F.hookMatchAvatar()
    F.hookBackpackValid()
    F.hookEquipMapping()
    F.hookWeaponSpawn()
    F.hookMotionEquip()
    F.hookIngameEmote()
    
    -- Hook backpack avatar skin to show VIP skin in balo (V2 - live synData scan, đồng bộ 100% với súng trên tay)
    pcall(function()
        local BPL = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackFunctionLibrary")
        if BPL and type(BPL.GetWeaponAvatarRes) == "function" and not BPL._lex_hooked_avatar_v2 then
            BPL._lex_hooked_avatar_v2 = true
            local _origGetRes = BPL.GetWeaponAvatarRes
            BPL.GetWeaponAvatarRes = function(WeaponID, AdditionalDataArray)
                local origID, origDIY = nil, nil
                pcall(function() origID, origDIY = _origGetRes(WeaponID, AdditionalDataArray) end)
                local wid = tonumber(WeaponID) or 0
                if wid > 0 and _G.LexusConfig and _G.LexusConfig.ModSkin == true then
                    local skinID = F.getModSkinForWeapon(wid)
                    if skinID > 1000000 and skinID ~= wid and F.cfg(skinID) then
                        return skinID, origDIY
                    end
                end
                return origID, origDIY
            end
        end
    end)

    -- [THÊM MỚI] Hook icon phụ kiện trong Balo -> đè bằng icon skin VIP.
    -- Hook đúng theo cách cũ đã chạy được: MyFittingSlotItemUI.__inner_impl.UpdateSlotItem.
    pcall(function()
        local function lexDbg(msg)
            pcall(function()
                if Client and type(Client.SaveStringToFile) == "function" then
                    Client.SaveStringToFile(tostring(msg or ""), "SaveGames/lex_attach_debug.txt")
                end
            end)
        end

        local MyMainWeaponInfoItemUI = require("GameLua.Mod.BaseMod.Client.Backpack.MainWeaponInfoItemUI")
        local MyFittingSlotItemUI = nil
        pcall(function() MyFittingSlotItemUI = require("GameLua.Mod.BaseMod.Client.Backpack.FittingSlotItemUI") end)

        -- (1) Ô súng: ghi nhớ base weapon + skin (để ô phụ kiện con biết skin của súng cha)
        if MyMainWeaponInfoItemUI and MyMainWeaponInfoItemUI.__inner_impl and MyMainWeaponInfoItemUI.__inner_impl.UpdateWeaponAppearanceInfo then
            if not MyMainWeaponInfoItemUI.__inner_impl._lex_appearance_v3 then
                MyMainWeaponInfoItemUI.__inner_impl._lex_appearance_v3 = true
                local orig = MyMainWeaponInfoItemUI.__inner_impl.UpdateWeaponAppearanceInfo
                MyMainWeaponInfoItemUI.__inner_impl.UpdateWeaponAppearanceInfo = function(self, TypeSpecificID, BattleData, DragOrigin)
                    pcall(function()
                        local baseID = F.baseWeaponIDFromAny(TypeSpecificID)
                        local skinID = F.getModSkinForWeapon(TypeSpecificID)
                        self.NVHWeaponBaseID = baseID
                        self.NVHWeaponSkinID = skinID
                        _G.LexusCurrentBackpackWeaponSkin = skinID
                    end)
                    return orig(self, TypeSpecificID, BattleData, DragOrigin)
                end
                lexDbg("hook appearance OK")
            end
        end

        -- (2) Ô phụ kiện: thay icon gốc bằng icon skin VIP
        if MyFittingSlotItemUI and MyFittingSlotItemUI.__inner_impl and MyFittingSlotItemUI.__inner_impl.UpdateSlotItem then
            if not MyFittingSlotItemUI.__inner_impl._lex_slot_v3 then
                MyFittingSlotItemUI.__inner_impl._lex_slot_v3 = true
                local orig = MyFittingSlotItemUI.__inner_impl.UpdateSlotItem
                MyFittingSlotItemUI.__inner_impl.UpdateSlotItem = function(self, resID, defineID, dragOrigin, additionalDataType)
                    local renderID = resID
                    local patchedDefineID = defineID
                    if _G.LexusConfig.SkinAttachment then -- Check công tắc phụ kiện
                        pcall(function()
                            local baseID = tonumber(resID) or 0
                            if baseID > 0 and baseID < 1000000 then
                                local weaponSkinID = _G.LexusCurrentBackpackWeaponSkin
                                pcall(function()
                                    if self and self.parentWeaponInfo and self.parentWeaponInfo.NVHWeaponSkinID then
                                        weaponSkinID = tonumber(self.parentWeaponInfo.NVHWeaponSkinID) or weaponSkinID
                                    end
                                end)
                                
                                local skinID = F.getAttachmentSkinForBase(baseID, weaponSkinID)
                                if skinID then
                                    renderID = skinID
                                    lexDbg("slot res=" .. tostring(resID) .. " -> skin=" .. tostring(skinID))
                                    
                                    -- Mấu chốt: Phải thay đổi cả defineID.TypeSpecificID vì UI vẽ dựa vào nó!
                                    pcall(function()
                                        if defineID and defineID.clone then
                                            patchedDefineID = defineID:clone()
                                        end
                                        if not patchedDefineID then patchedDefineID = defineID end
                                        patchedDefineID.TypeSpecificID = renderID
                                    end)
                                end
                            end
                        end)
                    end
                    return orig(self, renderID, patchedDefineID, dragOrigin, additionalDataType)
                end
                lexDbg("hook slot OK")
            end
        end
    end)

    F.hookEnterGame()

-- ==============================================================================
-- [THÊM MỚI] LOGIC KILL MESSENGER, DEADBOX, BỘ ĐẾM KILL & ICON TỪ CODE MẪU
-- ==============================================================================
local function decodeExpand(expandContent)
    local ok, exp = pcall(function() return slua.LuaArchiverDecode(LuaStateWrapper, expandContent) or {} end)
    return ok and exp or {}
end

local function encodeExpand(exp)
    return slua.LuaArchiverEncode(LuaStateWrapper, exp or {})
end

local _cachedMyName = nil
local function isMyKill(data)
    if not data then return false end
    if data.bIamCauser then return true end
    -- Tối ưu: Chỉ lấy tên 1 lần duy nhất, tránh gọi C++ SLUA hàng ngàn lần
    if not _cachedMyName then
        local hud = slua_GameFrontendHUD
        if hud then
            local pc = hud:GetPlayerController()
            if slua.isValid(pc) then
                local ch = pc:GetPlayerCharacterSafety()
                if slua.isValid(ch) then _cachedMyName = ch:GetPlayerNameSafety() end
            end
        end
    end
    if not _cachedMyName or _cachedMyName == "" then return false end
    return data.Causer == _cachedMyName or data.CauserRealPlayerName == _cachedMyName or data.CauserPlayerName == _cachedMyName
end

local function getCurrentWeaponSkinID()
    -- [ĐÃ FIX] Lấy chính xác Skin ID của cây súng ĐANG CẦM TRÊN TAY để tránh hiện nhầm Kill Message
    local hud = slua_GameFrontendHUD
    if not hud then return 0 end
    local pc = hud:GetPlayerController()
    if not slua.isValid(pc) then return 0 end
    local ch = pc:GetPlayerCharacterSafety()
    if not slua.isValid(ch) then return 0 end
    
    local currWeapon = ch:GetCurrentWeapon()
    if slua.isValid(currWeapon) and currWeapon.synData then
        local currentSkinID = 0
        pcall(function()
            local synDataRef = slua.IndexReference(currWeapon.synData:Get(7), "defineID")
            local skinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
            
            -- Chỉ xuất Kill Message nếu súng trên tay thực sự là súng VIP (ID > 1000000)
            if skinID > 1000000 then 
                currentSkinID = skinID
            end
        end)
        return currentSkinID
    end
    return 0
end

local _downloadedAssetsCache = {}
local function downloadTeamAssets(skinID)
    if not skinID or skinID == 0 or skinID == 69 then return end
    -- Tối ưu: Chỉ tải 1 lần duy nhất mỗi skin, tránh spam băng thông và CPU
    if _downloadedAssetsCache[skinID] then return end
    _downloadedAssetsCache[skinID] = true

    pcall(function()
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local PufferConst = require("client.slua.logic.download.puffer_const")
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {skinID})
        
        local cfg = CDataTable.GetTableData("TeamKillBroadcast", skinID)
        if cfg then
            if cfg.EffectPath and cfg.EffectPath ~= "" then
                PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {cfg.EffectPath})
            end
            if cfg.BgPath and cfg.BgPath ~= "" then
                PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {cfg.BgPath})
            end
        end
    end)
end

local function patchTeamKill(messageData)
    if not _G.LexusConfig.KillMessage then return messageData end -- [CHẶN NẾU TẮT CÔNG TẮC]
    if not messageData or not isMyKill(messageData) then return messageData end
    local currentSkinID = getCurrentWeaponSkinID()
    if not currentSkinID or currentSkinID == 0 or currentSkinID == 69 then return messageData end
    local broadcastCfg = CDataTable.GetTableData("TeamKillBroadcast", currentSkinID)
    if not broadcastCfg or (not broadcastCfg.BgPath and not broadcastCfg.EffectPath) then return messageData end
    pcall(function()
        local exp = decodeExpand(messageData.ExpandDataContent)
        exp.CauserWeaponAvatarID = currentSkinID
        messageData.ExpandDataContent = encodeExpand(exp)
        messageData.bShowBottomBothSidesKillInfo = true
        messageData.bIamCauser = true
        downloadTeamAssets(currentSkinID)
    end)
    return messageData
end

local function installTeamBroadcastHooks()
    local function wrapCopy(mod, tag)
        if not mod then return end
        local impl2 = mod.__inner_impl or mod
        if not impl2 or not impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable then return end
        local key = "__teamKillCopy_" .. tag
        if not impl2[key] then impl2[key] = impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable end
        local O_Copy = impl2[key]
        impl2.CopyKillOrPutDownMessageDataUserDataToLuaTable = function(self, messageData)
            local copied = O_Copy(self, messageData)
            
            -- [TỐI ƯU TUYỆT ĐỐI] Nếu tắt Kill Message -> Bỏ qua toàn bộ logic bên dưới, trả về nguyên bản của game luôn.
            if not _G.LexusConfig.KillMessage then return copied end
            
            local ok2, result = pcall(function() return patchTeamKill(copied) end)
            if ok2 then return result end
            return copied
        end
    end
    pcall(function() wrapCopy(require("GameLua.Mod.BaseMod.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem"), "base") end)
    pcall(function() wrapCopy(require("GameLua.Mod.SingleTraining.Client.BattleKillBroadcast.BattleKillBroadcastSubSystem"), "training") end)
end

-- Khởi tạo hệ thống Kill Count
_G.killCountInfo = {
    [101001] = 0000, [101004] = 0000, [101003] = 0000, [103001] = 0000,
    [102001] = 0000, [105001] = 0000, [102002] = 0000, [103002] = 0000
}

function _G.saveKillCountToFile()
    -- Đã làm rỗng hàm lưu file để chống Drop FPS
end

function _G.loadKillCountFromFile()
    -- Đã làm rỗng hàm đọc file để chống Drop FPS
end

function _G.addKill(weaponID, count)
    if not weaponID or not count then return end
    _G.killCountInfo[weaponID] = (_G.killCountInfo[weaponID] or 0) + count
    _G.saveKillCountToFile()
end

function _G.getKills(weaponID) return weaponID and _G.killCountInfo[weaponID] or 0 end

-- Hook Deadbox (Tạo Hòm Xác) và KillInfo
pcall(function()
    local SKillInfo = require("GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo")
    local SKillInfoModuleManager = require("client.module_framework.ModuleManager")
    local UEnums = _ENV.UEnums
    local ECharacterHealthStatus = import("ECharacterHealthStatus")
    
    if SKillInfo and SKillInfo.__inner_impl and SKillInfo.__inner_impl.FileItem then
        local O_FileItem = SKillInfo.__inner_impl.FileItem
        SKillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
            if not self or not DamageRecordData then return end
            if not _G.LexusConfig.SkinDeadBox and not _G.LexusConfig.KillCountUI and not _G.LexusConfig.KillMessage then
                return O_FileItem(self, DamageRecordData)
            end

            local LogicKillCounter = SKillInfoModuleManager.GetModule(SKillInfoModuleManager.CommonModuleConfig.LogicKillCounter)
            if not LogicKillCounter then return O_FileItem(self, DamageRecordData) end

            local uCharacter = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() and slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            if not uCharacter or not slua.isValid(uCharacter) then return O_FileItem(self, DamageRecordData) end

            local SelfName = uCharacter:GetPlayerNameSafety()
            local bIsCauser = DamageRecordData.Causer == SelfName

            if bIsCauser then
                if DamageRecordData.DamageType == UEnums.DamageType.VehicleDamage then
                    if _G.LexusConfig.SkinDeadBox or _G.LexusConfig.KillMessage then 
                        local carSkinID = _G.CurrentEquipVehicleID or 0
                        if carSkinID ~= 0 then
                            local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, DamageRecordData.ExpandDataContent) or {}
                            ExpandData.CauserVehicleSkinID = carSkinID
                            if _G.LexusConfig.KillMessage then
                                self:ChangeInfoBgByWeaponAvatarIDLua(carSkinID)
                                DamageRecordData.CauserWeaponAvatarID = carSkinID
                                DamageRecordData.CauserClothAvatarID = _G.SuitSkin or 0
                            end
                            DamageRecordData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                        end
                    end
                elseif DamageRecordData.CauserWeaponAvatarID ~= 69 and DamageRecordData.CauserClothAvatarID ~= 69 then
                    local currWeapon = uCharacter:GetCurrentWeapon()
                    if currWeapon and slua.isValid(currWeapon) then
                        local defineID = currWeapon:GetItemDefineID()
                        local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                        if DefineID ~= 0 then
                            local ExpandData = slua.LuaArchiverDecode(LuaStateWrapper, DamageRecordData.ExpandDataContent) or {}
                            local hasChanged = false

                            local SupportKillCounter = LogicKillCounter:GetBaseKillCounterIdByWeaponId(DefineID)
                            if SupportKillCounter and DamageRecordData.ResultHealthStatus == ECharacterHealthStatus.FinishedLastBreath then
                                local synDataRef = slua.IndexReference(currWeapon.synData:Get(7), "defineID")
                                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                                
                                if SkinID > 1000000 then 
                                    if _G.LexusConfig.KillCountUI then 
                                        ExpandData.KillCounterItemId = DefineID
                                        ExpandData.KillCounterNum = (ExpandData.KillCounterNum or 0) + 1
                                        _G.addKill(DefineID, 1)
                                        hasChanged = true
                                    end
                                    if _G.LexusConfig.SkinDeadBox then 
                                        _G.NeedCheckDeadBoxTimer = 5 
                                        hasChanged = true
                                    end
                                end
                            end

                            if hasChanged or _G.LexusConfig.KillMessage then
                                _G.UpdateMyKillCounter = true
                                if _G.LexusConfig.KillMessage then
                                    local synData = currWeapon.synData
                                    if synData and slua.isValid(synData) then
                                        local weaponDefineID = slua.IndexReference(synData:Get(7), "defineID")
                                        if weaponDefineID and slua.isValid(weaponDefineID) then
                                            DamageRecordData.CauserWeaponAvatarID = weaponDefineID.TypeSpecificID
                                        end
                                    end
                                    DamageRecordData.CauserClothAvatarID = _G.SuitSkin or 0
                                end
                                DamageRecordData.ExpandDataContent = slua.LuaArchiverEncode(LuaStateWrapper, ExpandData)
                            end
                        end
                    end
                end
            end
            O_FileItem(self, DamageRecordData)
        end
    end
end)

-- Hook UI Kill Counter (Cập nhật số đếm & Icon trên màn hình)
pcall(function()
    local MyMainKillCounter = require("GameLua.Mod.BaseMod.Client.KillCounter.MainKillCounter")
    local MyKillCountSubSystem = require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
    local MyMainWeaponInfoItemUI = require("GameLua.Mod.BaseMod.Client.Backpack.MainWeaponInfoItemUI")
    local MyMainWeaponKillCounter = require("GameLua.Mod.BaseMod.Client.KillCounter.MainWeaponKillCounter")
    local SlotBase = require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local UIManager = require("client.slua_ui_framework.manager")
    local ModuleManager = require("client.module_framework.ModuleManager")

    if MyKillCountSubSystem and MyKillCountSubSystem.__inner_impl then
        _G.OurkillCountSystem = MyKillCountSubSystem.__inner_impl
        
        local o_OnRefreshUI = MyMainKillCounter.__inner_impl.OnRefreshUI
        MyMainKillCounter.__inner_impl.OnRefreshUI = function(self, _, _, UID)
            if not _G.LexusConfig.KillCountUI then return end -- CHẶN KHI TẮT
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            local curEquipedKillCounter = LogicKillCounter:GetEquipedKillCounterId(6114302174, self.WeaponID)
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
            if currweapon ~= nil then
                local defineID = currweapon:GetItemDefineID()
                local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                local synDataRef = slua.IndexReference(currweapon.synData:Get(7), "defineID")
                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                self.KillCounterItem:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), SkinID)
            end
        end

        MyKillCountSubSystem.__inner_impl.CheckSupportKCUI = function(self) return _G.LexusConfig.KillCountUI end

        local o_UpdateMainKillCounterUI = MyKillCountSubSystem.__inner_impl.UpdateMainKillCounterUI
        MyKillCountSubSystem.__inner_impl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
            -- [TỐI ƯU TUYỆT ĐỐI] Bóp nghẹt ngay lệnh gọi UI của Game nếu đang tắt, CHỐNG CHỚP (FLASH)
            if not _G.LexusConfig.KillCountUI then
                o_UpdateMainKillCounterUI(self, false, WeaponID, AvatarID) -- Ép tham số False
                local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
                if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
                return
            end

            o_UpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID)
            local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
         
            if not bShow and MainKillCounter then
                UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter)
            elseif bShow and currweapon ~= nil then
                local DefineID = currweapon:GetItemDefineID().TypeSpecificID
                local currentEquipAvatrid = slua.IndexReference(currweapon.synData:Get(7), "defineID").TypeSpecificID
                local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
                local SupportKillCounter = LogicKillCounter:GetBaseKillCounterIdByWeaponId(DefineID)
                
                local curEquipedKillCounter = LogicKillCounter:GetEquipedKillCounterId(6114302174, currentEquipAvatrid)
                
                -- [TỐI ƯU FPS] NHẬN DIỆN SÚNG MOD: Súng thường ID < 1.000.000, Súng Mod ID > 1.000.000
                local isModdedSkin = (currentEquipAvatrid and currentEquipAvatrid > 1000000)
                
                -- Đóng UI nếu là súng lục, dao, CHẢO hoặc SÚNG THƯỜNG KHÔNG CÓ SKIN
                if (SupportKillCounter == nil or not isModdedSkin) then
                    if MainKillCounter then
                        UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter)
                    end
                else
                    -- Hiện UI nếu là súng Mod (Dù curEquipedKillCounter có trả về nil do server không nhận diện được)
                    if not MainKillCounter then
                        UIManager.ShowUI(UIManager.UI_Config_InGame.MainKillCounter, DefineID, currentEquipAvatrid)
                        MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
                        if MainKillCounter then
                            MainKillCounter:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), currentEquipAvatrid)
                        end
                    else
                        MainKillCounter:UpdateWeaponID(DefineID, currentEquipAvatrid)
                        MainKillCounter:SetKillCounterItemShowWithNum(curEquipedKillCounter, _G.getKills(DefineID), currentEquipAvatrid)
                    end
                end
            end
        end

        local o_CheckNeedMainKillCounterUI = MyKillCountSubSystem.__inner_impl.CheckNeedMainKillCounterUI
        MyKillCountSubSystem.__inner_impl.CheckNeedMainKillCounterUI = function(self, Weapon, PlayerID)
            if not _G.LexusConfig.KillCountUI then return end -- CHẶN KHI TẮT
            local uCharacter = slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
            local currweapon = uCharacter:GetCurrentWeapon()
            if currweapon ~= nil then
                local defineID = currweapon:GetItemDefineID()
                local DefineID = defineID and slua.isValid(defineID) and defineID.TypeSpecificID or 0
                local synDataRef = slua.IndexReference(currweapon.synData:Get(7), "defineID")
                local SkinID = synDataRef and slua.isValid(synDataRef) and synDataRef.TypeSpecificID or 0
                self:UpdateMainKillCounterUI(true, DefineID, SkinID)
            end
        end
    end
end)

-- Vòng lặp Updater (Đã tối ưu Cache: Chỉ Update UI khi đổi súng hoặc có mạng Kill)
local _lastKCWeaponID = 0
local _lastKCSkinID = 0

_G.GameAvatarHandlerkillcounter = function()
    local UIManager = require("client.slua_ui_framework.manager")
    
    if not _G.LexusConfig.KillCountUI then
        local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
        if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
        return 
    end

    local PlayerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not PlayerController or not slua.isValid(PlayerController) then return end
    
    local uCharacter = PlayerController:GetPlayerCharacterSafety()
    if not uCharacter or not slua.isValid(uCharacter) then return end
    
    local currweapon = uCharacter:GetCurrentWeapon()
    if currweapon and slua.isValid(currweapon) then
        -- Lấy DefineID an toàn, không tạo rác RAM
        local defineIDObj = currweapon:GetItemDefineID()
        local currentWeaponID = (defineIDObj and slua.isValid(defineIDObj)) and defineIDObj.TypeSpecificID or 0
        
        -- Lấy Skin ID từ Cache của hệ thống Skin V7.5 (Cực nhẹ, không gọi SLUA)
        local currentSkinID = 0
        if _G.AddOutfitLastAppliedSkin and _G.AddOutfitLastAppliedSkin[currentWeaponID] then
            currentSkinID = _G.AddOutfitLastAppliedSkin[currentWeaponID]
        end

        -- TỐI ƯU CỰC ĐỘ: Chỉ gửi lệnh cập nhật UI nếu MỚI ĐỔI SÚNG hoặc MỚI GIẾT NGƯỜI
        if _G.UpdateMyKillCounter or currentWeaponID ~= _lastKCWeaponID or currentSkinID ~= _lastKCSkinID then
            _lastKCWeaponID = currentWeaponID
            _lastKCSkinID = currentSkinID
            _G.UpdateMyKillCounter = false
            
            if _G.OurkillCountSystem then
                _G.OurkillCountSystem:UpdateMainKillCounterUI(true, currentWeaponID, currentSkinID)
            end
        end
    else
        _lastKCWeaponID = 0
        _lastKCSkinID = 0
        local MainKillCounter = UIManager.GetUI(UIManager.UI_Config_InGame.MainKillCounter)
        if MainKillCounter then UIManager.CloseUI(UIManager.UI_Config_InGame.MainKillCounter) end
    end
end

local function LobbyTickSetup()
    if not _G.CounterUpdated then
        _G.CounterUpdated = true
        _G.loadKillCountFromFile()
    end
    -- ĐÃ XÓA LOGIC QUÉT FILE translateec.conf LIÊN TỤC GÂY LAG
end

-- Kích hoạt Hooks và Loop
pcall(function()
    installTeamBroadcastHooks()
    LobbyTickSetup() -- Chỉ gọi đọc file 1 lần duy nhất khi vào game, không lặp lại nữa
    
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(0, _G.GameAvatarHandlerkillcounter, -1, 0.5)
        -- ĐÃ XÓA VÒNG LẶP ĐỌC FILE 0.4 GIÂY ĐỂ TRÁNH DROP FPS
    end
end)
-- ==============================================================================

    F.startVehicleSkinTicker()
    if not _G.AddOutfitVehInitTimers then
        _G.AddOutfitVehInitTimers = true
        F.later(1.5, function() pcall(F.applyVehicleSkinsToPC) end)
        F.later(4.0, function() pcall(F.applyVehicleSkinsToPC) end)
    end

    pcall(function()
        if F.isInRealMatch() then
            local char = F.getLocalChar()
            if char then
                F.bootstrapMatch(char)
            end
        end
    end)

    local firstLobby = not _G.AddOutfitLobbyInitDone
    if F.injectAll() then
        if firstLobby then _G.AddOutfitLobbyInitDone = true end
        F.afterInjectApply(firstLobby)
        return
    end
    local tries = 0
    local function retry()
        tries = tries + 1
        if F.injectAll() then
            local ft = not _G.AddOutfitLobbyInitDone
            if ft then _G.AddOutfitLobbyInitDone = true end
            F.afterInjectApply(ft)
            return
        end
        if tries < INJECT_RETRY_MAX then F.later(INJECT_RETRY_SEC, retry) end
    end
    F.later(INJECT_RETRY_SEC, retry)
end

_G.AddOutfitLobbyRestored = false
_G.LobbyRestoreAttempts = 0

_G.AutoRestoreLobbySkin = function()
    if _G.AddOutfit and _G.AddOutfit.isInRealMatch() then 
        _G.AddOutfitLobbyRestored = false
        _G.LobbyRestoreAttempts = 0
        return 
    end
    if _G.AddOutfitLobbyRestored then return end
    
    pcall(function()
        if GameStatus and GameStatus.IsInLobbyOrMainCity and GameStatus.IsInLobbyOrMainCity() then
            local entity = _G.AddOutfit.getEntity()
            if entity and entity.GetDataByInsID then
                local checkIns = 2000000001
                if not entity:GetDataByInsID(checkIns) then
                    _G.AddOutfit.injectAll(entity)
                    _G.AddOutfit.afterInjectApply(false)
                end
            end

            if DataMgr and DataMgr.roleData and DataMgr.roleData.uid then
                local LMC = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
                if LMC and LMC.GetCurPage then
                    if _G.AddOutfit and _G.AddOutfit.reapplyLobbyEquipped then
                        _G.AddOutfit.persistLoadFromDisk() 
                        _G.AddOutfit.persistApplyLoaded() 
                        _G.AddOutfit.reapplyLobbyEquipped()
                        _G.LobbyRestoreAttempts = (_G.LobbyRestoreAttempts or 0) + 1
                        if _G.LobbyRestoreAttempts >= 5 then
                            _G.AddOutfitLobbyRestored = true
                        end
                    end
                end
            end
        end
    end)
end

-- Chạy ngầm 1 giây / lần lúc vừa vô game, load xong là tự động ngưng
pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerLoop then
        ticker.AddTimerLoop(0, AutoRestoreLobbySkin, -1, 1.0)
    end
end)

pcall(function()
    local QuickExpressionUtils = require("GameLua.Mod.BaseMod.Client.Emote.QuickExpressionUtils")
    local EXTRA_EMOTES = {
        12220964, 12220954, 12220416, 12201301, 12216101, 12212201, 12219207, 12209001,
        12219561, 12210001, 12219022, 12208801, 12210801, 12200701, 12219242, 12206001,
        12205401, 12205201, 12212601, 12205601, 12219208, 12212001, 12206801, 12209801,
        12211401, 12207001, 12211801, 12207901, 12203401, 12204001, 12201801, 12215601,
        12215532, 12213201, 12215529, 12219053, 12204601, 12215701, 12219003, 12219004,
        12219009, 12219216
    }

    local CachedInGameEmotes = nil
    local LastBaseCount = -1
    local LastEmoteSwitchState = nil

    local function GetOptimizedEmoteList(baseList)
        local baseCount = baseList and #baseList or 0
        local isEmoteModEnabled = _G.LexusConfig.ModEmote == true

        if CachedInGameEmotes and LastBaseCount == baseCount and LastEmoteSwitchState == isEmoteModEnabled then
            return CachedInGameEmotes
        end

        local compact = {}
        local seen = {}
        
        if baseList then
            for _, data in pairs(baseList) do
                if data and data.DefineID and data.DefineID.TypeSpecificID then
                    table.insert(compact, data)
                    seen[data.DefineID.TypeSpecificID] = true
                end
            end
        end

        if isEmoteModEnabled then
            for _, nEmoteID in ipairs(EXTRA_EMOTES) do
                if not seen[nEmoteID] then
                    table.insert(compact, { DefineID = {TypeSpecificID = nEmoteID}, Name = tostring(nEmoteID) })
                    seen[nEmoteID] = true
                end
            end
        end

        CachedInGameEmotes = compact
        LastBaseCount = baseCount
        LastEmoteSwitchState = isEmoteModEnabled
        return CachedInGameEmotes
    end

    if QuickExpressionUtils and not _G.__EMOTE_INGAME_HOOKED then
        _G.__EMOTE_INGAME_HOOKED = true
        _G.__EMOTE_ORIG_GET_LIST = QuickExpressionUtils.GetShowExpressionList
        QuickExpressionUtils.GetShowExpressionList = function()
            local baseList, nWeaponShowEmoteID = _G.__EMOTE_ORIG_GET_LIST()
            return GetOptimizedEmoteList(baseList), nWeaponShowEmoteID
        end
    end

    if not _G.__EMOTE_MENU_EVENT_HOOKED and EventSystem and EventSystem.registEvent then
        _G.__EMOTE_MENU_EVENT_HOOKED = true
        EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK, function()
            pcall(function()
                if not _G.LexusConfig.ModEmote then return end 
                local UIManager = require("client.slua_ui_framework.manager")
                if not UIManager or not UIManager.UI_Config_InGame then return end
                local subPanel = UIManager.GetUI(UIManager.UI_Config_InGame.QuickExpressionDecalSubPanel)
                
                if subPanel and subPanel.GetQuickExpressionDecalItemByIndex and CachedInGameEmotes then
                    local showCount = 0
                    for _, data in ipairs(CachedInGameEmotes) do
                        local nEmoteID = data.DefineID and data.DefineID.TypeSpecificID
                        if nEmoteID and nEmoteID > 0 then
                            showCount = showCount + 1
                            local item = subPanel:GetQuickExpressionDecalItemByIndex(showCount)
                            if item then
                                if item.UIRoot.WidgetSwitcher_Effect then item.UIRoot.WidgetSwitcher_Effect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                if item.UIRoot.Image_Weapon then item.UIRoot.Image_Weapon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end
                                item:Show()
                                item:RefreshData(nEmoteID, -1)
                            end
                        end
                    end
                    if subPanel.HideRestBlocks then subPanel:HideRestBlocks(showCount) end
                    if subPanel.UIRoot then
                        subPanel.UIRoot.WrapBox_List:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
                        subPanel.UIRoot.VerticalBox_Empty:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                    end
                end
            end)
        end)
    end
end)

_G.InitModDone = false
function _G.InitAllModSystems()
    if _G.InitModDone then return end
    _G.InitModDone = true
    if isExpired then 
        pcall(function()
            local Msg = require("client.slua.logic.common.logic_common_msg_box")
            if Msg and Msg.Show then
                Msg.Show(1, "MOD HẾT HẠN", "PHIÊN BẢN MOD CỦA BẠN ĐÃ HẾT HẠN!\nVUI LÒNG INBOX ADMIN ĐỂ MUA VIP.", function() end, function() end, "ĐÓNG", "")
            end
        end)
        Notify("MOD HẾT HẠN! VUI LÒNG INBOX ADMIN ĐỂ GIA HẠN!")
        return 
    end
    pcall(function()
        if _G.StartProtect_VIP_v3 then _G.StartProtect_VIP_v3() end
        installTeamBroadcastHooks()
        if not _G.CounterUpdated then
            _G.CounterUpdated = true
            _G.loadKillCountFromFile()
        end
    end)
    pcall(function()
        local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
        if GameplayData and GameplayData.GetPlayerCharacter then
            local LocalPlayer = GameplayData.GetPlayerCharacter()
            if slua.isValid(LocalPlayer) then
                if LocalPlayer.bHasShownDevNotice == nil then
                    LocalPlayer.bHasShownDevNotice = false 
                    LocalPlayer.bHasShownExpiredNotice = false 
                    LocalPlayer.bIsDeadFlag = false
                end
            end
        end
    end)
    pcall(function()
        _G.AddOutfit = F
        if F and F.start then F.start() end
    end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerLoop then
            ticker.AddTimerLoop(0.05, function() 
                pcall(MainLoop) 
                pcall(_M_DrawCounter) 
            end, -1, 0.05)
            ticker.AddTimerLoop(0.01, function() 
                if _G.LexusConfig and _G.LexusConfig.AimTouchEnable and _G.AimTouch then
                    pcall(_G.AimTouch)
                end
            end, -1, 0.01)
            ticker.AddTimerLoop(0.5, function() 
                pcall(_G.GameAvatarHandlerkillcounter) 
            end, -1, 0.5)
            ticker.AddTimerLoop(1.0, function() 
                pcall(_G.AutoRestoreLobbySkin) 
            end, -1, 1.0)
        end
    end)

    Notify("Kích Hoạt VIP V1.1 Thành Công!")
end

_G.InitAllModSystems()