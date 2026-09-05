-- ==============================================================================
-- ============================ BẮT ĐẦU FULL LOGIC MOD ==========================
-- ==============================================================================

local function Notify(msg) local s = "[Ngocdoian MENU New] " .. tostring(msg)
pcall(function() if _G.XthrlenNotify then _G.XthrlenNotify(s) end end)
pcall(function() local sh = import("ScriptHelperClient") if sh and
sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
_slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
then return false end end return true end

-- ========================================== 
-- STATIC VARIABLES & GLOBAL CACHE TỐI ƯU HÓA (CHỐNG LAG)
-- ========================================== 
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}
local SCALE_COLOR_V2 = {R=3, G=3, B=0, A=0}

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

-- ========================================== 
-- CẤU HÌNH XTHRLEN CORE + FULL FEATURES VIP 
-- ========================================== 
_G.XthrlenConfig = _G.XthrlenConfig or { 
    FakeHWID = false,
    CustomMagicBullet = false,
    AutoHead = false, 
    EspVip = false, 
    EspDistance = false, 
    EspVipPro = false, 
    EspRadar = false, 
    EspLoai5 = false, 
    EspLoai6 = false, 
    EspLoai7 = false,
    Esp7_SoLuong = true, 
    Esp7_VuKhi = true,   
    Esp7_TuThe = true,   
    EspLoai8 = false,
    EspBomMaster = false, 
    EspItemBom = false,   
    EspActiveBom = false, 
    EspAimWarning = false,         
    EspAimWarningVisCheck = false, 
    EspVehicle = false,   
    EspVeh_Dacia = true,  
    EspVeh_UAZ = true,    
    EspVeh_Buggy = true,  
    EspVeh_Coupe = true,  
    EspVeh_Mirado = true, 
    EspVeh_Motor = true,  
    EspVeh_Other = true,  
    Esp3ShowName = true,
    Esp3ShowHP = true,
    EspAntenna = false, 
    EspOutline = false, 
    OutlineThickness = 10, 
    UnlockFPS = false, 
    IpadView = false, 
    CustomAimbot = false, 
    CustomAimbotClose = false, 
    CustomHRecoil = false,  
    CustomVRecoil = false,  
    LessShake = false, 
    RemoveGrass = false, 
    RemoveTrees = false,  
    RemoveFog = false, 
    WhiteBody = false, 
    ColorBodyV2 = false,    
    ColorBodyV3 = false,    
    WallXuyenTuong = false, 
    ColorBodyNew = false,   
    WallVehicle = false,  
    Crosshair = false,
    Accuracy = false,
    GodMode = false, 
    WallClimb = false,
    FastCar = false,
    BlackSky = false, 
    
    -- Config Mới Cho Aimbot V2 (Aim Touch)
    AimTouchEnable = false,
    AimTouchHipIgKnock = false,
    AimTouchHipIgBot = false,
    AimTouchSGIgKnock = false,
    AimTouchSGIgBot = false,
    AimTouchHipVisCheck = false,
    AimTouchSGVisCheck = false,
    AimTouchHipfire = false,
    AimTouchSG = false,
    AimTouchSGAutoFire = false,
    AimTouchScopeAll = false,
    AimTouchScopeIgKnock = false,
    AimTouchScopeIgBot = false,
    AimTouchScopeVisCheck = false,
    AimTouchScopeSniper = false,
    AimTouchSniperIgKnock = false,
    AimTouchSniperIgBot = false,
    AimTouchSniperVisCheck = false,
    AimTouchCrossbow = false,

    -- Config Mod Skin VIP
    ModEmote = false,       
    ModSkin = false,           
    SkinDeadBox = false,   
    SkinAttachment = false, 
    SkinOptionOpen = false,
    SkinOpenLink = false,  
    KillMessage = false,    
    KillCountUI = false,    
    
    -- Toggles Bật/Tắt riêng biệt từng món
    SkinEnable_Suit = false, SkinEnable_Top = false, SkinEnable_Gloves = false,
    SkinEnable_Bottom = false, SkinEnable_Shoes = false, SkinEnable_Bag = false, SkinEnable_Helmet = false, SkinEnable_Parachute = false,
    SkinEnable_M416 = false, SkinEnable_AKM = false, SkinEnable_SCAR = false, SkinEnable_M762 = false,
    SkinEnable_AUG = false, SkinEnable_UMP = false, SkinEnable_UZI = false, SkinEnable_Groza = false,
    SkinEnable_S12K = false, SkinEnable_DBS = false,
    SkinEnable_Dacia = false, SkinEnable_UAZ = false, SkinEnable_Coupe = false, SkinEnable_Buggy = false, SkinEnable_Mirado = false,
    
    -- Config Glow Súng
    WeaponGlow = false,
    
    -- Config Bug Màn
    BugManEnable = false
}

-- CHỨA STATE HỆ THỐNG ĐÃ ĐƯỢC TỐI ƯU HÓA HOÀN TOÀN RAM TRỐNG
_G.XthrlenState = _G.XthrlenState or { 
    LoopToken = 0, 
    NativeESPReady = false,
    GraphicsUnlocked = false, 
    MenuStep = 0, 
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0, 
    CustomTextData = nil,     
    LastAimbotConfigString = "",
    MagicUpdateVersion = 1,
    LastMagicConfigHash = "",
    PrevGraphicsState = {}
}

local limitTime = os.time({ year = 2026, month = 7, day = 30, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache" 
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName
    }
    
    if os and os.getenv then
        local homeDir = os.getenv("HOME")
        if homeDir and homeDir ~= "" then
            table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/SaveGames/" .. fileName)
            table.insert(paths, 2, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Gamelet/logs/" .. fileName)
        end
    end
    
    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then 
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then 
            currentTime = serverTime 
        end
    end

    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        currentTime = lastSeenTime
    else
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = false

-- ========================================== 
-- HÀM QUẢN LÝ DỌN RÁC MAP MARK
-- ========================================== 
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.XthrlenState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.XthrlenState.TrackedMarks[mark] = nil
end

local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end
    
    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end
        
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end
        
        if not isAI then
            local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end

        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }
        
        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.XthrlenConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end

                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.XthrlenConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end

_G.ApplyWeaponGlow = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end

        local isGlowEnabled = _G.XthrlenConfig.WeaponGlow
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local glowIntensity = 80.0 
        local thickness = _G.XthrlenState.CustomTextData.WeaponGlowThickness or 3
        local colorMode = _G.XthrlenState.CustomTextData.WeaponGlowColor or 5
        
        local r, g, b = 1.0, 1.0, 0.0
        if colorMode == 1 then r, g, b = 1.0, 0.0, 0.0
        elseif colorMode == 2 then r, g, b = 0.0, 1.0, 0.0
        elseif colorMode == 3 then r, g, b = 0.0, 0.0, 1.0
        elseif colorMode == 4 then r, g, b = 1.0, 1.0, 0.0
        elseif colorMode == 5 then 
            local time = os.clock() * 2.0
            r = (math.sin(time) + 1) / 2
            g = (math.sin(time + 2) + 1) / 2
            b = (math.sin(time + 4) + 1) / 2
        end

        local finalColor = LinearColorClass and LinearColorClass(r * glowIntensity, g * glowIntensity, b * glowIntensity, 1.0) or { R = r * 255 * glowIntensity, G = g * 255 * glowIntensity, B = b * 255 * glowIntensity, A = 255 }

        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) then
                local ok, meshComponent = pcall(function() return import("/Script/Engine.MeshComponent") end)
                if ok then
                    local ok2, components = pcall(function() return Weapon:GetComponentsByClass(meshComponent) end)
                    if ok2 and components then
                        local count = type(components.Num) == "function" and components:Num() or #components
                        for i = 1, count do
                            local comp = type(components.Get) == "function" and components:Get(i-1) or components[i]
                            if slua.isValid(comp) then
                                if isGlowEnabled then
                                    pcall(function()
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
                                    pcall(function()
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

-- ========================================== 
-- HỆ THỐNG LƯU VÀ TẢI SETTING MENU VIP
-- ========================================== 
local function GetConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName,
        "/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        fileName
    }
    pcall(function()
        if os and os.getenv then
            local homeDir = os.getenv("HOME")
            if homeDir and homeDir ~= "" then
                table.insert(paths, 1, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName)
                table.insert(paths, 2, homeDir .. "/Documents/ShadowTrackerExtra/Saved/Paks/puffer_temp/" .. fileName)
            end
        end
    end)
    return paths
end

local ConfigFileName = "ngocdoian_settings.txt"
_G.LastConfigSaveStr = ""

_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nXthrlenConfig = {\n"
        for k, v in pairs(_G.XthrlenConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
        end
        data = data .. "},\nCustomTextData = {\n"
        if _G.XthrlenState and _G.XthrlenState.CustomTextData then
            for k, v in pairs(_G.XthrlenState.CustomTextData) do
                data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n"
            end
        end
        data = data .. "}\n}"
        
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end

        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.XthrlenConfig then
                        for k, v in pairs(savedData.XthrlenConfig) do
                            _G.XthrlenConfig[k] = v
                        end
                    end
                    if savedData.CustomTextData then
                        _G.XthrlenState.CustomTextData = _G.XthrlenState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do
                            _G.XthrlenState.CustomTextData[k] = v
                        end
                    end
                end
            end
        end
        _G.SaveModSettings() 
    end)
end

local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker") 
        if okTicker and ticker and ticker.AddTimerOnce then 
            ticker.AddTimerOnce(3.0, AutoSaveLoop) 
        end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ========================================== 
-- HỆ THỐNG MENU VIP NATIVE
-- ========================================== 
_G.ModMenuInitialized = false
if _G.UIManager then _G.UIManager._IsModMenuHooked = false end
if _G.LocUtil then _G.LocUtil._IsModMenuHooked_V2 = false end

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    local function T(vnText, enText)
        return _G.XthrlenLang == "EN" and enText or vnText
    end

    _G.XthrlenState.CustomTextData = _G.XthrlenState.CustomTextData or {
        OuterSpeed = 10, InnerSpeed = 10, OuterRecoil = 0, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120,
        AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250,
        AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
        AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchScopePred = 0, AimTouchScopeRecoil = 0,
        AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400, AimTouchSniperPred = 0,
        BugManRatio = 133,
        WeaponGlowThickness = 3, WeaponGlowColor = 5,
        ColorV3Hidden = 1, ColorV3Visible = 2, ColorV3Thickness = 4, OutlineColor = 4
    }

    local LocUtil = _G.LocUtil
    if not LocUtil and package.loaded["client.common.LocUtil"] then
        LocUtil = require("client.common.LocUtil")
    end
    
    local FakeTextMap = {
        [999000] = T("MENU MOD NGOCDOIAN"),
        [999001] = T("DISPLAY (ESP) TELEGRAM  ", "VISUALS (ESP) "),
        [999002] = T("ORIGINAL AIMBOT ", "NATIVE AIMBOT & BULLET TRACK"),
        [999003] = T("AIMBOT TOUCH - CUSTOM ( Aim Near - Aim Scope )", "CUSTOM AIMBOT (Close & Scope)"),
        [999004] = T("SUPPORT & GRAPHICS TELEGRAM  ", "SUPPORT & GRAPHICS"),
        [999005] = T("MOD SKIN IS EASILY BANNED", "MOD SKIN (RISKY)")
    }

    if LocUtil and not LocUtil._IsModMenuHooked_V2 then
        local hookFuncs = {"GetLocalizeResStr", "GetText", "GetTextByID", "GetLocalText", "GetLocalizeStr"}
        for _, funcName in ipairs(hookFuncs) do
            if LocUtil[funcName] then
                local old_func = LocUtil[funcName]
                LocUtil[funcName] = function(id)
                    if FakeTextMap[id] then
                        return FakeTextMap[id]
                    end
                    if type(id) == "string" and not tonumber(id) then
                        return id
                    end
                    if old_func then
                        return old_func(id)
                    end
                    return ""
                end
            end
        end
        LocUtil._IsModMenuHooked_V2 = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        local StackESP = {
            { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = T("ESP Loại 1 (Cảnh báo 360-Máu-Tên)", "ESP Type 1 (360 Alert-HP-Name)"), GetFunc = function() return _G.XthrlenConfig.EspVip end, SetFunc = function(c,v) _G.XthrlenConfig.EspVip = v return true end },
            { Key = "ModMenu_ESP2", UI = AliasMap.Switcher, Text = T("ESP Loại 2 (Khoảng cách mét)", "ESP Type 2 (Distance Meter)"), GetFunc = function() return _G.XthrlenConfig.EspDistance end, SetFunc = function(c,v) _G.XthrlenConfig.EspDistance = v return true end },
            { Key = "ModMenu_ESP3_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Loại 3 (Máu Dọc & Tên)", "▶ ESP Type 3 (Vertical HP & Name)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspVipPro end, SetFunc = function(c,v) _G.XthrlenConfig.EspVipPro = v return true end },
            { Key = "ModMenu_ESP3_Name", UI = AliasMap.Switcher, Text = T("   Hiện Tên Người Chơi", "   Show Player Name"), ExpandHandle = "ModMenu_ESP3_Ex", GetFunc = function() return _G.XthrlenConfig.Esp3ShowName end, SetFunc = function(c,v) _G.XthrlenConfig.Esp3ShowName = v return true end },
            { Key = "ModMenu_ESP3_HP", UI = AliasMap.Switcher, Text = T("   Hiện Thanh Máu Dọc", "   Show Vertical HP Bar"), ExpandHandle = "ModMenu_ESP3_Ex", GetFunc = function() return _G.XthrlenConfig.Esp3ShowHP end, SetFunc = function(c,v) _G.XthrlenConfig.Esp3ShowHP = v return true end },
            { Key = "ModMenu_ESP4", UI = AliasMap.Switcher, Text = T("ESP Loại 4 (Radar 360)", "ESP Type 4 (Radar 360)"), GetFunc = function() return _G.XthrlenConfig.EspRadar end, SetFunc = function(c,v) _G.XthrlenConfig.EspRadar = v return true end },
            { Key = "ModMenu_ESP5", UI = AliasMap.Switcher, Text = T("ESP Loại 5 (Khung Box)", "ESP Type 5 (Box ESP)"), GetFunc = function() return _G.XthrlenConfig.EspLoai5 end, SetFunc = function(c,v) _G.XthrlenConfig.EspLoai5 = v return true end },
            { Key = "ModMenu_ESP6", UI = AliasMap.Switcher, Text = T("ESP Loại 6 (Xương)", "ESP Type 6 (Skeleton)"), GetFunc = function() return _G.XthrlenConfig.EspLoai6 end, SetFunc = function(c,v) _G.XthrlenConfig.EspLoai6 = v return true end },
            { Key = "ModMenu_ESP7_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Loại 7 (Thông Tin Chi Tiết)", "▶ ESP Type 7 (Detail Info)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspLoai7 end, SetFunc = function(c,v) _G.XthrlenConfig.EspLoai7 = v return true end },
            { Key = "ModMenu_ESP7_SoLuong", UI = AliasMap.Switcher, Text = T("   Hiện Số Lượng Địch Xung Quanh", "   Show Enemies Count Around"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.XthrlenConfig.Esp7_SoLuong end, SetFunc = function(c,v) _G.XthrlenConfig.Esp7_SoLuong = v return true end },
            { Key = "ModMenu_ESP7_VuKhi", UI = AliasMap.Switcher, Text = T("   Hiện Vũ Khí Địch Cầm", "   Show Enemy Weapon"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.XthrlenConfig.Esp7_VuKhi end, SetFunc = function(c,v) _G.XthrlenConfig.Esp7_VuKhi = v return true end },
            { Key = "ModMenu_ESP7_TuThe", UI = AliasMap.Switcher, Text = T("   Hiện Tư Thế (Đứng/Ngồi/Nằm)", "   Show Posture (Stand/Crouch/Prone)"), ExpandHandle = "ModMenu_ESP7_Ex", GetFunc = function() return _G.XthrlenConfig.Esp7_TuThe end, SetFunc = function(c,v) _G.XthrlenConfig.Esp7_TuThe = v return true end },
            { Key = "ModMenu_ESP8", UI = AliasMap.Switcher, Text = T("ESP Loại 8 (Thanh Máu Gắn Đầu)", "ESP Type 8 (Head HP Bar)"), GetFunc = function() return _G.XthrlenConfig.EspLoai8 end, SetFunc = function(c,v) _G.XthrlenConfig.EspLoai8 = v return true end },
            { Key = "ModMenu_ESPBom_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Cảnh Báo & Định Vị Bom", "▶ Grenade Warning & Tracker"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspBomMaster end, SetFunc = function(c,v) _G.XthrlenConfig.EspBomMaster = v return true end },
            { Key = "ModMenu_ESPItemBom", UI = AliasMap.Switcher, Text = T("   Định Vị Vật Phẩm Bom Dưới Đất", "   Show Grenades On Ground"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return _G.XthrlenConfig.EspItemBom end, SetFunc = function(c,v) _G.XthrlenConfig.EspItemBom = v return true end },
            { Key = "ModMenu_ESPActiveBom", UI = AliasMap.Switcher, Text = T("   Cảnh Báo Địch Cầm & Ném Bom", "   Active Grenade Warning"), ExpandHandle = "ModMenu_ESPBom_Ex", GetFunc = function() return _G.XthrlenConfig.EspActiveBom end, SetFunc = function(c,v) _G.XthrlenConfig.EspActiveBom = v return true end },
            { Key = "ModMenu_EspAimWarning_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Cảnh Báo Địch Ngắm Bắn", "▶ Enemy Aim Warning"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspAimWarning end, SetFunc = function(c,v) _G.XthrlenConfig.EspAimWarning = v return true end },
            { Key = "ModMenu_EspAimWarning_Vis", UI = AliasMap.Switcher, Text = T("   Check Tường (Chỉ báo khi lộ diện)", "   Visibility Check"), ExpandHandle = "ModMenu_EspAimWarning_Ex", GetFunc = function() return _G.XthrlenConfig.EspAimWarningVisCheck end, SetFunc = function(c,v) _G.XthrlenConfig.EspAimWarningVisCheck = v return true end },
            { Key = "ModMenu_ESPVehicle_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Định Vị Xe", "▶ Vehicle ESP"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspVehicle end, SetFunc = function(c,v) _G.XthrlenConfig.EspVehicle = v return true end },
            { Key = "ModMenu_ESPVeh_Dacia", UI = AliasMap.Switcher, Text = T("   Hiện Xe Con (Dacia)", "   Show Dacia"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Dacia end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Dacia = v return true end },
            { Key = "ModMenu_ESPVeh_UAZ", UI = AliasMap.Switcher, Text = T("   Hiện Xe Jeep (UAZ)", "   Show UAZ"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_UAZ end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_UAZ = v return true end },
            { Key = "ModMenu_ESPVeh_Buggy", UI = AliasMap.Switcher, Text = T("   Hiện Xe Buggy", "   Show Buggy"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Buggy end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Buggy = v return true end },
            { Key = "ModMenu_ESPVeh_Coupe", UI = AliasMap.Switcher, Text = T("   Hiện Xe Thể Thao (Coupe RB)", "   Show Coupe RB"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Coupe end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Coupe = v return true end },
            { Key = "ModMenu_ESPVeh_Mirado", UI = AliasMap.Switcher, Text = T("   Hiện Xe Mirado", "   Show Mirado"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Mirado end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Mirado = v return true end },
            { Key = "ModMenu_ESPVeh_Motor", UI = AliasMap.Switcher, Text = T("   Hiện Xe Máy (Motor/Scooter)", "   Show Motorcycles"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Motor end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Motor = v return true end },
            { Key = "ModMenu_ESPVeh_Other", UI = AliasMap.Switcher, Text = T("   Hiện Xe Khác (Thuyền/BRDM...)", "   Show Others (Boat/BRDM)"), ExpandHandle = "ModMenu_ESPVehicle_Ex", GetFunc = function() return _G.XthrlenConfig.EspVeh_Other end, SetFunc = function(c,v) _G.XthrlenConfig.EspVeh_Other = v return true end },
            { Key = "ModMenu_ESPAntenna", UI = AliasMap.Switcher, Text = T("ESP Antenna (Cột)", "Antenna ESP"), GetFunc = function() return _G.XthrlenConfig.EspAntenna end, SetFunc = function(c,v) _G.XthrlenConfig.EspAntenna = v return true end },
            { Key = "ModMenu_ESPOutline_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ ESP Viền Địch (Bật HDR sẽ sáng)", "▶ Outline ESP (HDR supported)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.EspOutline end, SetFunc = function(c,v) _G.XthrlenConfig.EspOutline = v return true end },
            { Key = "ModMenu_ESPOutline_Color", UI = AliasMap.Slider, Text = T("   Màu Viền (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Trắng)", "   Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.XthrlenState.CustomTextData.OutlineColor or 4 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.OutlineColor = v return true end },
            { Key = "ModMenu_ESPOutline_Thickness", UI = AliasMap.Slider, Text = T("   Độ Dày Viền", "   Outline Thickness"), ExpandHandle = "ModMenu_ESPOutline_Ex", MinValue = 1, MaxValue = 20, min = 1, max = 20, GetFunc = function() return _G.XthrlenConfig.OutlineThickness end, SetFunc = function(c,v) _G.XthrlenConfig.OutlineThickness = v return true end }
        }

        local StackAimbot = {
            { Key = "ModMenu_Aimbot_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Aimbot Xa Tùy Chỉnh", "▶ Custom Long Range Aimbot"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.CustomAimbot end, SetFunc = function(c,v) _G.XthrlenConfig.CustomAimbot = v return true end },
            { Key = "ModMenu_Aimbot_Speed", UI = AliasMap.Slider, Text = T("   Tốc Độ Aimbot Xa", "   Long Range Speed"), ExpandHandle = "ModMenu_Aimbot_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.OuterSpeed end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.OuterSpeed = v return true end },
            { Key = "ModMenu_Aimbot_Recoil", UI = AliasMap.Slider, Text = T("   Bù Giật Ghìm Tâm", "   Recoil Compensation"), ExpandHandle = "ModMenu_Aimbot_Ex", MinValue = 0, MaxValue = 50, min = 0, max = 50, GetFunc = function() return _G.XthrlenState.CustomTextData.OuterRecoil or 0 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.OuterRecoil = v return true end },
            { Key = "ModMenu_AimbotClose_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Aimbot Gần Tùy Chỉnh", "▶ Custom Close Range Aimbot"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.CustomAimbotClose end, SetFunc = function(c,v) _G.XthrlenConfig.CustomAimbotClose = v return true end },
            { Key = "ModMenu_AimbotClose_Speed", UI = AliasMap.Slider, Text = T("   Tốc Độ Aimbot Gần", "   Close Range Speed"), ExpandHandle = "ModMenu_AimbotClose_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.InnerSpeed end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.InnerSpeed = v return true end },
            { Key = "ModMenu_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Magic Bullet Tùy Chỉnh", "▶ Custom Magic Bullet"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.CustomMagicBullet end, SetFunc = function(c,v) _G.XthrlenConfig.CustomMagicBullet = v return true end },
            { Key = "ModMenu_Magic_Head", UI = AliasMap.Slider, Text = T("   Sát Thương Đầu (0.0 - 5.0)", "   Head Damage (0.0 - 5.0)"), ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.XthrlenState.CustomTextData.MagicHead or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.MagicHead = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Magic_Body", UI = AliasMap.Slider, Text = T("   Sát Thương Thân (0.0 - 5.0)", "   Body Damage (0.0 - 5.0)"), ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.XthrlenState.CustomTextData.MagicBody or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.MagicBody = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_Magic_Legs", UI = AliasMap.Slider, Text = T("   Sát Thương Chân (0.0 - 5.0)", "   Legs Damage (0.0 - 5.0)"), ExpandHandle = "ModMenu_Magic_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor(((_G.XthrlenState.CustomTextData.MagicLegs or 1.0) / 5.0) * 100 + 0.5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.MagicLegs = (v / 100.0) * 5.0 return true end },
            { Key = "ModMenu_HRecoil_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Giảm Giật Ngang (Drop súng nhặt lại để load)", "▶ Less Horizontal Recoil (Drop/Pick weapon)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.CustomHRecoil end, SetFunc = function(c,v) _G.XthrlenConfig.CustomHRecoil = v return true end },
            { Key = "ModMenu_HRecoil_Val", UI = AliasMap.Slider, Text = T("   Chỉ Số Giật Ngang", "   Horizontal Recoil Value"), ExpandHandle = "ModMenu_HRecoil_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor((((_G.XthrlenState.CustomTextData.HRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.HRecoil = 0.3 + (v / 100.0) * 4.7 return true end },
            { Key = "ModMenu_VRecoil_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Giảm Giật Dọc (Drop súng nhặt lại để load)", "▶ Less Vertical Recoil (Drop/Pick weapon)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.CustomVRecoil end, SetFunc = function(c,v) _G.XthrlenConfig.CustomVRecoil = v return true end },
            { Key = "ModMenu_VRecoil_Val", UI = AliasMap.Slider, Text = T("   Chỉ Số Giật Dọc", "   Vertical Recoil Value"), ExpandHandle = "ModMenu_VRecoil_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return math.floor((((_G.XthrlenState.CustomTextData.VRecoil or 0.3) - 0.3) / 4.7) * 100 + 0.5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.VRecoil = 0.3 + (v / 100.0) * 4.7 return true end },
            { Key = "ModMenu_LessShake", UI = AliasMap.Switcher, Text = T("Giảm Rung Nẩy Scope", "Less Scope Shake"), GetFunc = function() return _G.XthrlenConfig.LessShake end, SetFunc = function(c,v) _G.XthrlenConfig.LessShake = v return true end },
            { Key = "ModMenu_Accuracy", UI = AliasMap.Switcher, Text = T("Đạn Thẳng Tắp", "100% Accuracy"), GetFunc = function() return _G.XthrlenConfig.Accuracy end, SetFunc = function(c,v) _G.XthrlenConfig.Accuracy = v return true end },
            { Key = "ModMenu_Crosshair", UI = AliasMap.Switcher, Text = T("Tâm Súng Nhỏ", "Small Crosshair"), GetFunc = function() return _G.XthrlenConfig.Crosshair end, SetFunc = function(c,v) _G.XthrlenConfig.Crosshair = v return true end },
            { Key = "ModMenu_AutoHead", UI = AliasMap.Switcher, Text = T("Aimbot Head", "Aimbot Head"), GetFunc = function() return _G.XthrlenConfig.AutoHead end, SetFunc = function(c,v) _G.XthrlenConfig.AutoHead = v return true end },
            { Key = "ModMenu_GodMode", UI = AliasMap.Switcher, Text = T("Hủy Diệt (Bắn Siêu Nhanh)", "God Mode (Fast Shoot)"), GetFunc = function() return _G.XthrlenConfig.GodMode end, SetFunc = function(c,v) _G.XthrlenConfig.GodMode = v return true end }
        }

        local StackAimbotV2 = {
            { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Bật Aimbot Roy & Custom", "▶ Enable Custom Aimbot V2"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchEnable end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchEnable = v return true end },
            { Key = "ModMenu_AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Tâm Trắng", "   ▶ Hipfire Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchHipfire = v return true end },
            { Key = "ModMenu_AT_Hip_IgKnock", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Địch Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchHipIgKnock end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchHipIgKnock = v return true end },
            { Key = "ModMenu_AT_Hip_IgBot", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchHipIgBot end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchHipIgBot = v return true end },
            { Key = "ModMenu_AT_Hip_Vis", UI = AliasMap.Switcher, Text = T("      Check Tường (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchHipVisCheck end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchHipVisCheck = v return true end },
            { Key = "ModMenu_AT_Hip_Prio", UI = AliasMap.Slider, Text = T("      Ưu Tiên (1:Tâm 2:Gần 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchHipPrio = val return true end },
            { Key = "ModMenu_AT_Hip_Bone", UI = AliasMap.Slider, Text = T("      Vị Trí (1:Đầu 2:Ngực 3:Bụng 4:Hông)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchHipBone or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchHipBone = val return true end },
            { Key = "ModMenu_AT_Hip_Cond", UI = AliasMap.Slider, Text = T("      Điều Kiện (1:Bắn mới Aim, 2:Luôn Aim)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.XthrlenState.CustomTextData.AimTouchHipCond = val return true end },
            { Key = "ModMenu_AT_Hip_Spd", UI = AliasMap.Slider, Text = T("      Độ Mượt / Tốc Độ (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchHipSpeed or 50 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchHipSpeed = v return true end },
            { Key = "ModMenu_AT_Hip_FOV", UI = AliasMap.Slider, Text = T("      Vòng FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchHipFOV or 30 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchHipFOV = v return true end },
            { Key = "ModMenu_AT_Hip_Dist", UI = AliasMap.Slider, Text = T("      Khoảng Cách (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.XthrlenState.CustomTextData.AimTouchHipDist or 250) / 5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchHipDist = v * 5 return true end },
            { Key = "ModMenu_AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Shotgun", "   ▶ Shotgun Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchSG end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSG = v return true end },
            { Key = "ModMenu_AT_SG_AutoFire", UI = AliasMap.Switcher, Text = T("      Tự Động Bắn", "      Auto Fire"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSGAutoFire = v return true end },
            { Key = "ModMenu_AT_SG_IgKnock", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Địch Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSGIgKnock end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSGIgKnock = v return true end },
            { Key = "ModMenu_AT_SG_IgBot", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSGIgBot end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSGIgBot = v return true end },
            { Key = "ModMenu_AT_SG_Vis", UI = AliasMap.Switcher, Text = T("      Check Tường (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSGVisCheck end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSGVisCheck = v return true end },
            { Key = "ModMenu_AT_SG_Prio", UI = AliasMap.Slider, Text = T("      Ưu Tiên (1:Tâm 2:Gần 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchSGPrio = val return true end },
            { Key = "ModMenu_AT_SG_Bone", UI = AliasMap.Slider, Text = T("      Vị Trí (1:Đầu 2:Ngực 3:Bụng 4:Hông)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGBone or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchSGBone = val return true end },
            { Key = "ModMenu_AT_SG_Cond", UI = AliasMap.Slider, Text = T("      Điều Kiện (1:Bắn mới Aim, 2:Luôn Aim)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.XthrlenState.CustomTextData.AimTouchSGCond = val return true end },
            { Key = "ModMenu_AT_SG_Spd", UI = AliasMap.Slider, Text = T("      Độ Mượt / Tốc Độ (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGSpeed or 80 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSGSpeed = v return true end },
            { Key = "ModMenu_AT_SG_FOV", UI = AliasMap.Slider, Text = T("      Vòng FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGFOV or 40 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSGFOV = v return true end },
            { Key = "ModMenu_AT_SG_Dist", UI = AliasMap.Slider, Text = T("      Khoảng Cách (1-100m)", "      Distance Limit (1-100m)"), ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSGDist or 30 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSGDist = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Mở Scope", "   ▶ Scope Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchScopeAll end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchScopeAll = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgKnock", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Địch Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchScopeIgKnock end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchScopeIgKnock = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgBot", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchScopeIgBot end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchScopeIgBot = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Vis", UI = AliasMap.Switcher, Text = T("      Check Tường (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchScopeVisCheck end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchScopeVisCheck = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Prio", UI = AliasMap.Slider, Text = T("      Ưu Tiên (1:Tâm 2:Gần 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopePrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchScopePrio = val return true end },
            { Key = "ModMenu_AT_ScopeAll_Bone", UI = AliasMap.Slider, Text = T("      Vị Trí (1:Đầu 2:Ngực 3:Bụng 4:Hông)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopeBone or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchScopeBone = val return true end },
            { Key = "ModMenu_AT_ScopeAll_Cond", UI = AliasMap.Slider, Text = T("      Điều Kiện (1:Bắn mới Aim, 2:Luôn Aim)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopeCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.XthrlenState.CustomTextData.AimTouchScopeCond = val return true end },
            { Key = "ModMenu_AT_ScopeAll_Spd", UI = AliasMap.Slider, Text = T("      Độ Mượt / Tốc Độ (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopeSpeed or 40 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchScopeSpeed = v return true end },
            { Key = "ModMenu_AT_ScopeAll_FOV", UI = AliasMap.Slider, Text = T("      Vòng FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopeFOV or 20 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchScopeFOV = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Dist", UI = AliasMap.Slider, Text = T("      Khoảng Cách (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.XthrlenState.CustomTextData.AimTouchScopeDist or 300) / 5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchScopeDist = v * 5 return true end },
            { Key = "ModMenu_AT_ScopeAll_Pred", UI = AliasMap.Slider, Text = T("      Dự Đoán Hướng Chạy", "      Prediction Value"), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopePred or 0 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchScopePred = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Recoil", UI = AliasMap.Slider, Text = T("      Bù Giật Tự Động", "      Auto Recoil Comp."), ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 50, min = 0, max = 50, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchScopeRecoil or 0 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchScopeRecoil = v return true end },
            { Key = "ModMenu_AT_Sniper_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Mở Scope (Súng Ngắm/Tỉa)", "   ▶ Sniper Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchScopeSniper = v return true end },
            { Key = "ModMenu_AT_Sniper_IgKnock", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Địch Knock", "      Ignore Knocked"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSniperIgKnock end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSniperIgKnock = v return true end },
            { Key = "ModMenu_AT_Sniper_IgBot", UI = AliasMap.Switcher, Text = T("      Bỏ Qua Bot", "      Ignore Bots"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSniperIgBot end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSniperIgBot = v return true end },
            { Key = "ModMenu_AT_Sniper_Vis", UI = AliasMap.Switcher, Text = T("      Check Tường (VisCheck)", "      Visibility Check"), ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchSniperVisCheck end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchSniperVisCheck = v return true end },
            { Key = "ModMenu_AT_Sniper_Prio", UI = AliasMap.Slider, Text = T("      Ưu Tiên (1:Tâm 2:Gần 3:HP)", "      Priority (1:Crosshair 2:Distance 3:HP)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperPrio or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchSniperPrio = val return true end },
            { Key = "ModMenu_AT_Sniper_Bone", UI = AliasMap.Slider, Text = T("      Vị Trí (1:Đầu 2:Ngực 3:Bụng 4:Hông)", "      Bone (1:Head 2:Chest 3:Stomach 4:Pelvis)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 4, min = 1, max = 4, Min = 1, Max = 4, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperBone or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 4 then val = 4 end; _G.XthrlenState.CustomTextData.AimTouchSniperBone = val return true end },
            { Key = "ModMenu_AT_Sniper_Cond", UI = AliasMap.Slider, Text = T("      Điều Kiện (1:Bắn mới Aim, 2:Luôn Aim)", "      Trigger (1:On Fire, 2:Always)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperCond or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.XthrlenState.CustomTextData.AimTouchSniperCond = val return true end },
            { Key = "ModMenu_AT_Sniper_Spd", UI = AliasMap.Slider, Text = T("      Độ Mượt / Tốc Độ (1-100)", "      Smoothness / Speed (1-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperSpeed or 30 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSniperSpeed = v return true end },
            { Key = "ModMenu_AT_Sniper_FOV", UI = AliasMap.Slider, Text = T("      Vòng FOV (1-100)", "      FOV Radius (1-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperFOV or 20 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSniperFOV = v return true end },
            { Key = "ModMenu_AT_Sniper_Dist", UI = AliasMap.Slider, Text = T("      Khoảng Cách (1-500m)", "      Distance Limit (1-500m)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.XthrlenState.CustomTextData.AimTouchSniperDist or 400) / 5) end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSniperDist = v * 5 return true end },
            { Key = "ModMenu_AT_Sniper_Pred", UI = AliasMap.Slider, Text = T("      Dự Đoán Hướng Chạy (0-100)", "      Prediction Value (0-100)"), ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.AimTouchSniperPred or 0 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.AimTouchSniperPred = v return true end },
                                  -- [MENU CÀI ĐẶT NỎ CHUYÊN SÂU]
            { Key = "ModMenu_AT_Crossbow_Ex", UI = AliasMap.TitleSwitcher, Text = T("   ▶ Aimbot Nỏ/Cung Chuyên Sâu", "   ▶ Advanced Bow/Crossbow Aimbot"), ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.AimTouchCrossbow end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchCrossbow = v return true end },
            { Key = "ModMenu_AT_CB_Hipfire", UI = AliasMap.Switcher, Text = T("      Aimbot Bắn Hông (Tâm Trắng)", "      Hipfire Aimbot"), ExpandHandle = "ModMenu_AT_Crossbow_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchCrossbowHip == true end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchCrossbowHip = v return true end },
            { Key = "ModMenu_AT_CB_Drop", UI = AliasMap.Slider, Text = T("      Bù Lực Rơi Mũi Tên (0-100)", "      Arrow Gravity Drop (0-100)"), ExpandHandle = "ModMenu_AT_Crossbow_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.CrossbowDrop or 30 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.CrossbowDrop = v return true end },
            { Key = "ModMenu_AT_CB_Speed", UI = AliasMap.Slider, Text = T("      Tốc Độ / Độ Mượt Aim (1-100)", "      Aim Speed / Smooth (1-100)"), ExpandHandle = "ModMenu_AT_Crossbow_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.CrossbowSpeed or 50 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.CrossbowSpeed = v return true end },
            { Key = "ModMenu_AT_CB_Pred", UI = AliasMap.Slider, Text = T("      Dự Đoán Đón Đầu Địch (0-100)", "      Target Prediction (0-100)"), ExpandHandle = "ModMenu_AT_Crossbow_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.XthrlenState.CustomTextData.CrossbowPred or 20 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.CrossbowPred = v return true end },
            { Key = "ModMenu_AT_CB_Vis", UI = AliasMap.Switcher, Text = T("      Check Tường Nỏ/Cung", "      Crossbow VisCheck"), ExpandHandle = "ModMenu_AT_Crossbow_Ex", GetFunc = function() return _G.XthrlenConfig.AimTouchCrossbowVis == true end, SetFunc = function(c,v) _G.XthrlenConfig.AimTouchCrossbowVis = v return true end },

        }

        local StackSkin = {
            { Key = "Lobby Super Car", UI = AliasMap.Switcher, Text = T("Sảnh Siêu Xe VIP (Tắt Là Về Gốc)", "VIP Super Car Lobby (Disable to revert)"), GetFunc = function() return _G.XthrlenConfig.SanhSieuXeVip end, SetFunc = function(c,v) _G.XthrlenConfig.SanhSieuXeVip = v; if _G.LobbyThemeSystem and _G.LobbyThemeSystem.UpdateTheme then _G.LobbyThemeSystem.UpdateTheme() end return true end },
            { Key = "ModMenu_ModEmote", UI = AliasMap.Switcher, Text = T("Mở Khóa Full Hành Động VIP (Emotes)", "Unlock All VIP Emotes"), GetFunc = function() return _G.XthrlenConfig.ModEmote end, SetFunc = function(c,v) _G.XthrlenConfig.ModEmote = v return true end },
            { Key = "ModMenu_SkinAttachment", UI = AliasMap.Switcher, Text = T("Skin Phụ Kiện Súng (Nòng, Tay cầm...)", "Weapon Attachment Skin"), GetFunc = function() return _G.XthrlenConfig.SkinAttachment end, SetFunc = function(c,v) _G.XthrlenConfig.SkinAttachment = v return true end },
            { Key = "ModMenu_KillCountUI", UI = AliasMap.Switcher, Text = T("Bộ Đếm Kill (Hiển thị số Kill vũ khí)", "Kill Counter UI"), GetFunc = function() return _G.XthrlenConfig.KillCountUI end, SetFunc = function(c,v) _G.XthrlenConfig.KillCountUI = v return true end }
        }

        local StackCombat = {
            { Key = "ModMenu_FakeHWID", UI = AliasMap.Switcher, Text = T("Đổi HWID Ảo (Chống Ghim ID Thiết Bị)", "Fake HWID (Anti-Ban)"), GetFunc = function() return _G.XthrlenConfig.FakeHWID end, SetFunc = function(c,v) _G.XthrlenConfig.FakeHWID = v return true end },
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Ipad View", "▶ Ipad View"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.IpadView end, SetFunc = function(c,v) _G.XthrlenConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = T("   Góc Nhìn FOV", "   FOV Value"), ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return (_G.XthrlenState.CustomTextData.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.IpadViewFOV = 90 + v return true end },
            { Key = "ModMenu_BugMan_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Kéo Dãn Màn Hình (Nhân Vật Mập)", "▶ Screen Stretch (Fat Body)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.BugManEnable end, SetFunc = function(c,v) _G.XthrlenConfig.BugManEnable = v return true end },
            { Key = "ModMenu_BugMan_Ratio", UI = AliasMap.Slider, Text = T("   Độ Kéo Dãn", "   Stretch Ratio"), ExpandHandle = "ModMenu_BugMan_Ex", MinValue = 110, MaxValue = 200, min = 110, max = 200, GetFunc = function() return _G.XthrlenState.CustomTextData.BugManRatio or 133 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.BugManRatio = v return true end },
            { Key = "ModMenu_165FPS", UI = AliasMap.Switcher, Text = T("Mở Khóa 165 FPS", "Unlock 165 FPS"), GetFunc = function() return _G.XthrlenConfig.UnlockFPS end, SetFunc = function(c,v) _G.XthrlenConfig.UnlockFPS = v; if v then _G.XthrlenState.GraphicsUnlocked = false end return true end },
            { Key = "ModMenu_WallXuyenTuong", UI = AliasMap.Switcher, Text = T("Wall Xuyên Tường V1 (Chỉ nhìn xuyên)", "Wallhack V1 (See through)"), GetFunc = function() return _G.XthrlenConfig.WallXuyenTuong end, SetFunc = function(c,v) _G.XthrlenConfig.WallXuyenTuong = v return true end },
            { Key = "ModMenu_ColorBodyV2", UI = AliasMap.Switcher, Text = T("Tô Màu Địch V2 (Chams Cơ Bản)", "Chams V2 (Basic Color)"), GetFunc = function() return _G.XthrlenConfig.ColorBodyV2 end, SetFunc = function(c,v) _G.XthrlenConfig.ColorBodyV2 = v return true end },
            { Key = "ModMenu_ColorBodyNew", UI = AliasMap.Switcher, Text = T("WALL MÀU NEW (Xanh/Đỏ Sáng Engine)", "NEW ENGINE CHAMS (Red/Green)"), GetFunc = function() return _G.XthrlenConfig.ColorBodyNew end, SetFunc = function(c,v) _G.XthrlenConfig.ColorBodyNew = v return true end },
            { Key = "ModMenu_ColorBodyV3_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ WALL V2 + MÀU V3 (Tùy Chỉnh Màu)", "▶ WALL V2 + CHAMS V3 (Custom)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.ColorBodyV3 end, SetFunc = function(c,v) _G.XthrlenConfig.ColorBodyV3 = v return true end },
            { Key = "ModMenu_V3_Hidden", UI = AliasMap.Slider, Text = T("   Màu Sau Tường (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Trắng)", "   Hidden Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.XthrlenState.CustomTextData.ColorV3Hidden or 1 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.ColorV3Hidden = v return true end },
            { Key = "ModMenu_V3_Vis", UI = AliasMap.Slider, Text = T("   Màu Lộ Diện (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Tím 6:Trắng)", "   Visible Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Pur 6:Wht)"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.XthrlenState.CustomTextData.ColorV3Visible or 2 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.ColorV3Visible = v return true end },
            { Key = "ModMenu_V3_Thick", UI = AliasMap.Slider, Text = T("   Độ Dày Viền HDR Lộ Diện", "   HDR Outline Thickness"), ExpandHandle = "ModMenu_ColorBodyV3_Ex", MinValue = 1, MaxValue = 20, GetFunc = function() return _G.XthrlenState.CustomTextData.ColorV3Thickness or 4 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.ColorV3Thickness = v return true end },
            { Key = "ModMenu_WallVehicle", UI = AliasMap.Switcher, Text = T("Wall Phương Tiện", "Vehicle Wallhack"), GetFunc = function() return _G.XthrlenConfig.WallVehicle end, SetFunc = function(c,v) _G.XthrlenConfig.WallVehicle = v return true end },
            { Key = "ModMenu_WhiteBody", UI = AliasMap.Switcher, Text = T("Người Trắng", "White Body"), GetFunc = function() return _G.XthrlenConfig.WhiteBody end, SetFunc = function(c,v) _G.XthrlenConfig.WhiteBody = v return true end },
            { Key = "ModMenu_BlackSky", UI = AliasMap.Switcher, Text = T("Trời Tối (Black Sky)", "Black Sky"), GetFunc = function() return _G.XthrlenConfig.BlackSky end, SetFunc = function(c,v) _G.XthrlenConfig.BlackSky = v return true end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = T("Xóa Sương Mù", "Remove Fog"), GetFunc = function() return _G.XthrlenConfig.RemoveFog end, SetFunc = function(c,v) _G.XthrlenConfig.RemoveFog = v return true end },
            { Key = "ModMenu_RemoveGrass", UI = AliasMap.Switcher, Text = T("Xóa Cỏ", "Remove Grass"), GetFunc = function() return _G.XthrlenConfig.RemoveGrass end, SetFunc = function(c,v) _G.XthrlenConfig.RemoveGrass = v return true end },
            { Key = "ModMenu_RemoveTrees", UI = AliasMap.Switcher, Text = T("Xóa Cây", "Remove Trees"), GetFunc = function() return _G.XthrlenConfig.RemoveTrees end, SetFunc = function(c,v) _G.XthrlenConfig.RemoveTrees = v return true end },
            { Key = "ModMenu_WallClimb", UI = AliasMap.Switcher, Text = T("Leo Tường", "Wall Climb"), GetFunc = function() return _G.XthrlenConfig.WallClimb end, SetFunc = function(c,v) _G.XthrlenConfig.WallClimb = v return true end },
            { Key = "ModMenu_FastCar", UI = AliasMap.Switcher, Text = T("Xe Nhanh Bay", "Fast Car / Flying Car"), GetFunc = function() return _G.XthrlenConfig.FastCar end, SetFunc = function(c,v) _G.XthrlenConfig.FastCar = v return true end },
            { Key = "ModMenu_WeaponGlow_Ex", UI = AliasMap.TitleSwitcher, Text = T("▶ Glow Viền Súng (Phát sáng HDR)", "▶ Weapon Glow (HDR)"), ExpandIndex = 0, GetFunc = function() return _G.XthrlenConfig.WeaponGlow end, SetFunc = function(c,v) _G.XthrlenConfig.WeaponGlow = v return true end },
            { Key = "ModMenu_WeaponGlowColor", UI = AliasMap.Slider, Text = T("   Màu Súng (1:Đỏ 2:Lục 3:Lam 4:Vàng 5:Rainbow)", "   Color (1:Red 2:Grn 3:Blu 4:Ylw 5:Rnb)"), ExpandHandle = "ModMenu_WeaponGlow_Ex", MinValue = 1, MaxValue = 5, GetFunc = function() return _G.XthrlenState.CustomTextData.WeaponGlowColor or 5 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.WeaponGlowColor = v return true end },
            { Key = "ModMenu_WeaponGlowThick", UI = AliasMap.Slider, Text = T("   Độ Dày Viền Súng", "   Glow Thickness"), ExpandHandle = "ModMenu_WeaponGlow_Ex", MinValue = 1, MaxValue = 15, GetFunc = function() return _G.XthrlenState.CustomTextData.WeaponGlowThickness or 3 end, SetFunc = function(c,v) _G.XthrlenState.CustomTextData.WeaponGlowThickness = v return true end }
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text = 999000, 
            UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_ESP", Text = 999001, Stack = StackESP },
                { Key = "Cat_Aimbot", Text = 999002, Stack = StackAimbot },
                { Key = "Cat_AimbotV2", Text = 999003, Stack = StackAimbotV2 },
                { Key = "Cat_Combat", Text = 999004, Stack = StackCombat },
            }
        }
        
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
        pcall(function() 
            local SettingBattleCatalog = require("client.logic.NewSetting.SettingBattleCatalog")
            table.insert(SettingBattleCatalog, 1, SettingPageDefine.ModMenu)
        end)

    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...) 
            
            if config and config.keyName then
                local lowerKeyName = string.lower(config.keyName)
                if string.find(lowerKeyName, "setting") and not string.find(lowerKeyName, "custom") then
                    local catalog = args[1]
                    if type(catalog) == "table" and catalog[1] and type(catalog[1]) == "table" and catalog[1].Key then
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
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowXthrlenVIPMenu() 
    if _G.XthrlenMenuAlreadyShown then return end
    if _G.XthrlenState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_ScamAlert()
            local title = _G.XthrlenLang == "EN" and "SCAM ALERT" or "CẢNH BÁO SCAM MOD"
            local content = _G.XthrlenLang == "EN" 
                and "Join my Telegram to avoid scammers selling free mods. MOD CHEAT PUBG TELE  " 
                or "Tham Gia Telegram Của Tôi Để Tránh Các Thành Phần Bán Mod Free  \nMOD FREE V2 UPDATE WALL NEW VÀ AIM TOUCH"
            local btn1 = _G.XthrlenLang == "EN" and "JOIN" or "THAM GIA"
            local btn2 = _G.XthrlenLang == "EN" and "CLOSE" or "ĐÓNG"

            Msg.Show(1, title, content, function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/hackmodpubgmobile") end end, function() end, btn1, btn2)
            _G.XthrlenState.MenuStep = 99
            _G.XthrlenMenuAlreadyShown = true
        end

        local function Step_Welcome()
            local title = _G.XthrlenLang == "EN" and "WELCOME TO VIP MOD" or "CHÀO MỪNG MÀY"
            local content = _G.XthrlenLang == "EN" 
                and "Hi, ngocdoạn here. The VIP MENU V2 is now inside Game Settings!\nIMPORTANT: Enab fewer features to avoid lag. Play safe!" 
                or "MENU VIP FREE V2 ĐÃ ĐC TỐI ƯU HƠN V1 BẠN CẦN SETTING LẠI CÁC CHỨC NĂNG MAD BẠN CẦN, VỚI LẠI BẮN ĐỪNG LỘ BẮN KỸ TÍ LÀ SAFE"
            local btn1 = _G.XthrlenLang == "EN" and "OPEN GAME MENU" or "MỞ MENU TRONG GAME"
            local btn2 = _G.XthrlenLang == "EN" and "CLOSE" or "ĐÓNG"

            Msg.Show(1, title, content, 
            function() 
                _G.InitModMenuTab()
                if _G.XthrlenLang == "EN" then
                    Notify("VIP MOD MENU ADDED!\nOpen Settings (Gear icon) -> VIP MOD MENU to toggle features.")
                else
                    Notify("ĐÃ THÊM 'VIP MOD MENU' VÀO PHẦN CÀI ĐẶT CỦA GAME!\nHãy mở Cài Đặt (Răng Cưa) -> VIP MOD MENU để bật/tắt.")
                end
                Step_ScamAlert()
            end, 
            function() end, btn1, btn2)
        end

        local function Step_SelectLanguage()
            Msg.Show(2, "SELECT LANGUAGE / CHỌN NGÔN NGỮ", "Please select your preferred language.\nVui lòng chọn ngôn ngữ bạn muốn sử dụng.",
            function()
                _G.XthrlenLang = "VN"
                Step_Welcome()
            end,
            function()
                _G.XthrlenLang = "EN"
                Step_Welcome()
            end, "TIẾNG VIỆT", "ENGLISH")
        end

        _G.XthrlenState.MenuStep = 1
        Step_SelectLanguage() 
    end)
end

-- ========================================== 
-- LOGIC MỞ KHÓA 165 FPS VÀ UI IPAD VIEW 
-- ========================================== 
local function InitializeGraphicsUnlock() 
    if isExpired then return end
    if _G.XthrlenState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
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

    pcall(function()
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
                        pcall(function() widget:SetRenderOpacity(1.0) end)
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
                
                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
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
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
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
    _G.XthrlenState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ========================================== 
-- KHỞI TẠO HỆ THỐNG ESP (GỐC)
-- ========================================== 
local function InitializeNativeESP() 
    if _G.XthrlenState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true; 
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; 
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root"; 
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
            cfg[8888] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true,     
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,        
                Priority = 2 
            } 
            cfg[9999] = { 
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99, 
                MaxShowDistance = 6000000, 
                bBindOutScreen = true,
                bBindBlocked = true, 
                bIsBindingActor = true, 
                BindSocketName = "head",
                bUseLuaWorldSocketName = true, 
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true, 
                Priority = 2 
            } 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then 
                ApplyCfg(cfg) 
            end 
        end 
    end)
    _G.XthrlenState.NativeESPReady = true 
    Notify("Native ESP System Initialized") 
end

-- ========================================== 
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP
-- ========================================== 
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 3.0) then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

local function UndoWallXuyenTuong(enemy, markData)
    pcall(function()
        if markData.WallhackApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function() if type(mesh.SetRenderCustomDepth) == "function" then mesh:SetRenderCustomDepth(false) end end)
                    for i = 0, 10 do 
                        local matInterface = mesh:GetMaterial(i)
                        if Valid(matInterface) then
                            local baseMat = matInterface:GetBaseMaterial()
                            if Valid(baseMat) then baseMat.bDisableDepthTest = false end
                        end
                    end
                end
            end
            markData.WallhackApplied = false
        end
    end)
end

local function ApplyWallXuyenTuong(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then 
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then
                        mesh:SetRenderCustomDepth(true)
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do 
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
end

local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local curTime = os.clock()
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then isHidden = false else isHidden = true end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        local cData = _G.XthrlenState.CustomTextData or {}
        local hiddenColor = {R = cData.HiddenR or 150, G = cData.HiddenG or 0, B = cData.HiddenB or 0, A = cData.HiddenA or 25}
        local visibleColor = {R = cData.VisibleR or 0, G = cData.VisibleG or 150, B = cData.VisibleB or 0, A = cData.VisibleA or 25}
        
        local finalColor = hidden and hiddenColor or visibleColor
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        if not isMeshChanged and markData.LastHiddenState == hidden and markData.LastColorHash == colorHash then return end
        
        if isMeshChanged and markData.MIDs then
            markData.MIDs = {}
        end

        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            
                            if not markData.MIDs[meshKey] then markData.MIDs[meshKey] = {} end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", SCALE_COLOR_V2)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Extra Light Color", defC)
                                mid:SetVectorParameterValue("Para_Color", defC)
                                mid:SetVectorParameterValue("Para_ColorTint", defC)
                                mid:SetVectorParameterValue("Para_Color_1", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                                mid:SetVectorParameterValue("BodyColor", defC)
                                mid:SetVectorParameterValue("MainColor", defC)
                                mid:SetVectorParameterValue("DiffuseColor", defC)
                                mid:SetVectorParameterValue("EmissiveColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local cData = _G.XthrlenState.CustomTextData or {}
        local hidChoice = cData.ColorV3Hidden or 1
        local visChoice = cData.ColorV3Visible or 2
        local v3Thick = cData.ColorV3Thickness or 4
        
        local currentHash = string.format("%d_%d_%d", hidChoice, visChoice, v3Thick)
        local colorChanged = (markData.LastColorV3Hash ~= currentHash)
        markData.LastColorV3Hash = currentHash

        local function GetColorRGB(choice)
            if choice == 1 then return 255, 0, 0 end 
            if choice == 2 then return 0, 255, 0 end 
            if choice == 3 then return 0, 0, 255 end 
            if choice == 4 then return 255, 255, 0 end 
            if choice == 5 then return 255, 0, 255 end 
            if choice == 6 then return 255, 255, 255 end 
            return 255, 0, 0 
        end

        local hR, hG, hB = GetColorRGB(hidChoice)
        local vR, vG, vB = GetColorRGB(visChoice)

        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        local glowIntensity = 80.0 
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass((vR/255)*glowIntensity, (vG/255)*glowIntensity, (vB/255)*glowIntensity, 1.0) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs_V3 = markData.MIDs_V3 or {}

        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "MeshV3_" .. tostring(meshIndex)
                markData.MIDs_V3[compKey] = markData.MIDs_V3[compKey] or {}
                
                pcall(function()
                    if comp.PrimitiveShadingStrategy ~= 1 then
                        comp.UseScopeDistanceCulling = false 
                        comp.PrimitiveShadingStrategy = 1
                        comp.ShadingRate = 6
                    end
                end)
                
                for i = 0, 10 do
                    local matInterface = comp:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                    
                    local currentCached = markData.MIDs_V3[compKey][i]
                    local needUpdateColor = false
                    
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then 
                            markData.MIDs_V3[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then
                        needUpdateColor = true
                    end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_ColorTint", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color_1", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("BodyColor", invisColor)
                            currentCached:SetVectorParameterValue("MainColor", invisColor)
                            currentCached:SetVectorParameterValue("DiffuseColor", invisColor)
                            currentCached:SetVectorParameterValue("EmissiveColor", invisColor)
                            currentCached:SetVectorParameterValue("CustomColor", invisColor)
                            currentCached:SetVectorParameterValue("OverlayColor", invisColor)
                            currentCached:SetVectorParameterValue("GlowColor", invisColor)
                            currentCached:SetVectorParameterValue("EdgeColor", invisColor)
                            currentCached:SetVectorParameterValue("LightColor", invisColor)
                            currentCached:SetVectorParameterValue("OutlineColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            currentCached:SetScalarParameterValue("Opacity", 0.7)
                            currentCached:SetScalarParameterValue("Alpha", 0.7)
                            currentCached:SetScalarParameterValue("GlowIntensity", 1.0)
                            currentCached:SetScalarParameterValue("Intensity", 1.0)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, visColor) end
                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, v3Thick) end
                    end
                end)
            end
        end
        markData.ColorV3Applied = true
    end)
end

local function UndoColorBodyV3(enemy, markData)
    pcall(function()
        if markData.ColorV3Applied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function()
                        comp.PrimitiveShadingStrategy = 0
                        comp.ShadingRate = 1
                    end)
                    
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then
                                baseMat.bDisableDepthTest = false
                                baseMat.BlendMode = 1
                            end
                        end
                    end
                    
                    local compKey = "MeshV3_" .. tostring(meshIndex)
                    if markData.MIDs_V3 and markData.MIDs_V3[compKey] then
                        for i, mid in pairs(markData.MIDs_V3[compKey]) do
                            if Valid(mid) then
                                pcall(function()
                                    local defC = {R=1, G=1, B=1, A=1, r=1, g=1, b=1, a=1}
                                    mid:SetVectorParameterValue("颜色", defC)
                                    mid:SetVectorParameterValue("Extra Light Color", defC)
                                    mid:SetVectorParameterValue("Para_Color", defC)
                                    mid:SetVectorParameterValue("Tint", defC)
                                    mid:SetVectorParameterValue("BaseColor", defC)
                                    mid:SetVectorParameterValue("Color", defC)
                                end)
                            end
                        end
                    end
                    
                    pcall(function()
                        if comp.SetDrawIdeaOutline then
                            comp:SetDrawIdeaOutline(false)
                        end
                    end)
                end
            end
            markData.ColorV3Applied = false
            markData.LastMeshCountV3 = 0 
            if markData.MIDs_V3 then markData.MIDs_V3 = nil end
        end
    end)
end

local function ApplyColorBodyNew(enemy, markData)
    pcall(function()
        if not _G.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and world then
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
                _G.ConsoleNewWallReady = true
            end
        end

        local meshes = GetAllSkeletalMeshes(enemy, markData)
        local weapon = nil
        pcall(function() weapon = enemy:GetCurrentWeapon() end)
        if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
            table.insert(meshes, weapon.Mesh)
        end

        local isBot = markData.AK_IS_BOT or false
        local currentMeshCount = #meshes
        local stateHash = (isBot and "BOT" or "PLAYER") .. "_" .. tostring(currentMeshCount)
        
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied then
            return 
        end
        
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true

        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local c_vis = LinearColorClass and LinearColorClass(0, 100, 0, 1) or {R=0, G=100, B=0, A=1}
        local c_occ = LinearColorClass and LinearColorClass(100, 0, 0, 1) or {R=100, G=0, B=0, A=1}
        local c_bVis = LinearColorClass and LinearColorClass(49, 48, 0, 100) or {R=49, G=48, B=0, A=100}
        local c_bOcc = LinearColorClass and LinearColorClass(9, 1.5, 45, 100) or {R=9, G=1.5, B=45, A=100}

        local visColor = isBot and c_bVis or c_vis
        local occColor = isBot and c_bOcc or c_occ

        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true)
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor)
                        mesh:SetOccludedDyeingColor(occColor)
                        mesh:SetDyeingColorFadeDistance(99999.0)
                        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
                        mesh:SetDrawHighlight(true)
                        mesh:OverrideHighlightColor(visColor)
                        mesh:SetHighlightCanBeOccluded(false)
                        mesh:SetDrawIdeaOutline(true)
                        mesh:SetIdeaOutlineNew(true)
                        mesh:SetIdeaOutlineOcclusionHighlight(true)
                        mesh:OverrideIdeaOutlineColor(visColor)
                        mesh:SetIdeaOutlineOcclusionColor(occColor)
                        mesh:OverrideIdeaOutlineThickness(20.0)
                        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true)
                        mesh:SetCustomDepthStencilValue(255)
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyNew(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            local weapon = nil
            pcall(function() weapon = enemy:GetCurrentWeapon() end)
            if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
                table.insert(meshes, weapon.Mesh)
            end

            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false)
                            mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false)
                            mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
            markData.LastColorNewHash = "" 
        end
    end)
end

-- ========================================== 
-- HỆ THỐNG AIMBOT V2
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return result
    end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

-- ==========================================
-- [UPDATE VIP 4] DỰ ĐOÁN NỎ/CUNG KẾT HỢP ĐỌC TƯ THẾ NGỒI/NẰM CỦA NHÂN VẬT
-- ==========================================
local function CalculateCrossbowPrediction(player, target, targetBonePos)
    if not slua.isValid(player) or not slua.isValid(target) or not targetBonePos then return targetBonePos end
    
    local cData = _G.XthrlenState.CustomTextData or {}
    local dropUserVal = cData.CrossbowDrop or 30
    local predUserVal = cData.CrossbowPred or 20
    
    local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
    if not weapon and type(player.GetCurrentShootWeapon) == "function" then
        weapon = player:GetCurrentShootWeapon()
    end

    local isBow = false
    if slua.isValid(weapon) then
        local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
        local lowerName = string.lower(tostring(wName))
        if lowerName:find("bow") and not lowerName:find("cross") then
            isBow = true
        end
    end

    -- [ĐỌC TƯ THẾ] 0: Đứng, 1: Ngồi, 2: Nằm
    local pose = 0
    pcall(function()
        if player.PoseState then pose = player.PoseState
        elseif type(player.GetPoseState) == "function" then pose = player:GetPoseState() end
    end)

    local CrossbowSpeed = isBow and 220.0 or 160.0 
    local baseGravity = isBow and 9.8 or 14.5  
    
    local GravityDrop = (dropUserVal / 50.0) * baseGravity
    local distMeters = player:GetDistanceTo(target) / 100.0

    if distMeters < 5.0 or distMeters > 300.0 then return targetBonePos end

    local travelTime = distMeters / CrossbowSpeed
    local targetVelocity = type(target.GetVelocity) == "function" and target:GetVelocity() or nil
    
    local pX = targetBonePos.X
    local pY = targetBonePos.Y
    local pZ = targetBonePos.Z

    if targetVelocity and (targetVelocity.X ~= 0 or targetVelocity.Y ~= 0) and predUserVal > 0 then
        local predFactor = (predUserVal / 20.0)
        pX = pX + (targetVelocity.X * travelTime * predFactor)
        pY = pY + (targetVelocity.Y * travelTime * predFactor)
    end

    local zOffset = 0.5 * GravityDrop * (travelTime * travelTime) * 100
    
    -- [THUẬT TOÁN ÉP TÂM THEO TƯ THẾ VÀ KHOẢNG CÁCH]
    if distMeters >= 40.0 then
        -- Mặc định gọt bớt lực bốc ảo của Game Engine khi xa trên 40m
        zOffset = zOffset * (isBow and 0.7 or 0.85)
        
        -- Can thiệp cực mạnh khi qua mốc 50m
        if distMeters >= 50.0 then
            -- Cứ 5m qua mốc 50m là cộng thêm 1 nấc ghìm
            local steps = math.floor((distMeters - 50.0) / 5.0)
            local forceDown = steps * (isBow and 2.5 or 3.5)
            
            -- NẾU ĐANG NGỒI HOẶC NẰM (Trọng tâm súng bị thấp)
            -- Bắt buộc phải nhân lực ép (forceDown) lên 1.8 lần để đè mũi tên khỏi vọt sọ!
            if pose == 1 or pose == 2 then
                forceDown = forceDown * 1.8
            end
            
            zOffset = zOffset - forceDown
        end
    end

    pZ = pZ + zOffset
    
    return FVector(pX, pY, pZ)
end



_G.AimTouch = function()
    pcall(function()
        if not _G.XthrlenConfig.AimTouchEnable then return end
   
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local isCrossbow = false 
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            -- [MẮT THẦN V5] Bắt chết Cung và Nỏ
            local lowerName = string.lower(tostring(wName))
            if _G.XthrlenConfig.AimTouchCrossbow and (wID == 1050001 or wID == 1050002 or wID == 1050100 or wID == 1050010 or lowerName:find("crossbow") or lowerName:find("nỏ") or lowerName:find("bow") or lowerName:find("cung")) then 
                isCrossbow = true 
            end

            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        if _G.XthrlenState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.XthrlenState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then return end

        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        local predVal = 0 
        local recoilCompVal = 0 

        -- [LOGIC ĐỘC LẬP TÁCH RỜI HOÀN TOÀN TẠI ĐÂY]
        if isCrossbow and _G.XthrlenConfig.AimTouchCrossbow then
            if not isADS and (_G.XthrlenConfig.AimTouchCrossbowHip == false or _G.XthrlenConfig.AimTouchCrossbowHip == nil) then
                return -- Tắt bắn hông là ngừng aim lập tức
            end
            cond = 2 -- Luôn Aim
            prioMode = 1
            boneIdx = 1 -- Khóa Đầu
            speedVal = _G.XthrlenState.CustomTextData.CrossbowSpeed or 50
            fovVal = 80
            maxDistMeters = 300
            useVisCheck = (_G.XthrlenConfig.AimTouchCrossbowVis == true) 
            igKnock = true
            igBot = false
            predVal = _G.XthrlenState.CustomTextData.CrossbowPred or 20

        elseif isShotgun and _G.XthrlenConfig.AimTouchSG then
            cond = _G.XthrlenState.CustomTextData.AimTouchSGCond or 1
            if _G.XthrlenConfig.AimTouchSGAutoFire then cond = 2 end
            if cond == 1 and not isFiring then return end
            prioMode = _G.XthrlenState.CustomTextData.AimTouchSGPrio or 1
            boneIdx = _G.XthrlenState.CustomTextData.AimTouchSGBone or 2
            speedVal = _G.XthrlenState.CustomTextData.AimTouchSGSpeed or 80
            fovVal = _G.XthrlenState.CustomTextData.AimTouchSGFOV or 40
            maxDistMeters = _G.XthrlenState.CustomTextData.AimTouchSGDist or 30
            useVisCheck = _G.XthrlenConfig.AimTouchSGVisCheck
            igKnock = _G.XthrlenConfig.AimTouchSGIgKnock
            igBot = _G.XthrlenConfig.AimTouchSGIgBot
            
        elseif isADS then
            if isSniper and _G.XthrlenConfig.AimTouchScopeSniper then
                cond = _G.XthrlenState.CustomTextData.AimTouchSniperCond or 2
                if cond == 1 and not isFiring then return end
                prioMode = _G.XthrlenState.CustomTextData.AimTouchSniperPrio or 1
                boneIdx = _G.XthrlenState.CustomTextData.AimTouchSniperBone or 1
                speedVal = _G.XthrlenState.CustomTextData.AimTouchSniperSpeed or 30
                fovVal = _G.XthrlenState.CustomTextData.AimTouchSniperFOV or 20
                maxDistMeters = _G.XthrlenState.CustomTextData.AimTouchSniperDist or 400
                useVisCheck = _G.XthrlenConfig.AimTouchSniperVisCheck
                igKnock = _G.XthrlenConfig.AimTouchSniperIgKnock
                igBot = _G.XthrlenConfig.AimTouchSniperIgBot
                predVal = _G.XthrlenState.CustomTextData.AimTouchSniperPred or 0 
            elseif _G.XthrlenConfig.AimTouchScopeAll then
                cond = _G.XthrlenState.CustomTextData.AimTouchScopeCond or 1
                if cond == 1 and not isFiring then return end
                prioMode = _G.XthrlenState.CustomTextData.AimTouchScopePrio or 1
                boneIdx = _G.XthrlenState.CustomTextData.AimTouchScopeBone or 2
                speedVal = _G.XthrlenState.CustomTextData.AimTouchScopeSpeed or 40
                fovVal = _G.XthrlenState.CustomTextData.AimTouchScopeFOV or 20
                maxDistMeters = _G.XthrlenState.CustomTextData.AimTouchScopeDist or 300
                useVisCheck = _G.XthrlenConfig.AimTouchScopeVisCheck
                igKnock = _G.XthrlenConfig.AimTouchScopeIgKnock
                igBot = _G.XthrlenConfig.AimTouchScopeIgBot
                predVal = _G.XthrlenState.CustomTextData.AimTouchScopePred or 0 
                recoilCompVal = _G.XthrlenState.CustomTextData.AimTouchScopeRecoil or 0 
            else
                return
            end
        else
            if not _G.XthrlenConfig.AimTouchHipfire then return end
            cond = _G.XthrlenState.CustomTextData.AimTouchHipCond or 1
            if cond == 1 and not isFiring then return end 
            prioMode = _G.XthrlenState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.XthrlenState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.XthrlenState.CustomTextData.AimTouchHipSpeed or 50
            fovVal = _G.XthrlenState.CustomTextData.AimTouchHipFOV or 30
            maxDistMeters = _G.XthrlenState.CustomTextData.AimTouchHipDist or 250
            useVisCheck = _G.XthrlenConfig.AimTouchHipVisCheck
            igKnock = _G.XthrlenConfig.AimTouchHipIgKnock
            igBot = _G.XthrlenConfig.AimTouchHipIgBot
        end

        local currentMaxDist = maxDistMeters * 100 

        local enemies = _G.GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                local tIsBot = false
                if target.bIsAI == true or target.IsAI == true then tIsBot = true end
                local pState = target.PlayerState
                if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
                if tIsBot then goto continue end
            end
            
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
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
        
        if isCrossbow then
            finalBonePos = CalculateCrossbowPrediction(player, bestTarget, finalBonePos)
        elseif predVal > 0 then
            pcall(function()
                local tVelocity = nil
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0 
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)

        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)
        
        if recoilCompVal > 0 and isFiring then
            local pullDownForce = (recoilCompVal / 50.0) * 1.5 
            finalPitch = finalPitch - pullDownForce
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        if isShotgun and _G.XthrlenConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.XthrlenState.IsAutoFiring = true
                end
            end)
        end

    end)
end


-- ========================================== 
-- HỆ THỐNG WALL PHƯƠNG TIỆN
-- ========================================== 
_G.LastScanVehicleTime = 0
_G.AppliedVehicleWall = {}

_G.RunOptimizedVehicleESP = function()
    local curTime = os.clock()

    if curTime - _G.LastScanVehicleTime > 1.0 then
        _G.LastScanVehicleTime = curTime
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        if _G.XthrlenConfig.WallVehicle then
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
                                local vId = tostring(vehicle)
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
        else 
            _G.AppliedVehicleWall = {} 
        end
    end
end

-- ========================================== 
-- UI WIDGET ĐẾM ĐỊCH & KHOẢNG CÁCH
-- ========================================== 
local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local EnemyCounterWidget = nil
local WarningTargetWidget = nil
local LastCounterTime = 0

function _G.CleanUpEnemyCounterWidget()
    if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
        EnemyCounterWidget:RemoveFromParent()
    end
    EnemyCounterWidget = nil

    if WarningTargetWidget and slua.isValid(WarningTargetWidget) then
        WarningTargetWidget:RemoveFromParent()
    end
    WarningTargetWidget = nil
end

local function CreateEnemyCounterWidget()
    if EnemyCounterWidget then
        if slua.isValid(EnemyCounterWidget) then return EnemyCounterWidget else EnemyCounterWidget = nil end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10500)
        
        if btn.RichText_Content then
            btn.RichText_Content:SetText("Kẻ Địch: 0  |  Gần Nhất: 0m")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then fontInfo.Size = 16 btn.RichText_Content:SetFont(fontInfo) end
        end
        
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 30))
            slot:SetSize(FVector2D(240, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        EnemyCounterWidget = btn
    end)
    return EnemyCounterWidget
end

local function CreateWarningTargetWidget()
    if WarningTargetWidget then
        if slua.isValid(WarningTargetWidget) then return WarningTargetWidget else WarningTargetWidget = nil end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10501) 
        
        if btn.RichText_Content then
            btn.RichText_Content:SetText("ĐỊCH ĐANG NHÌN VỀ PHÍA BẠN")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then fontInfo.Size = 18 btn.RichText_Content:SetFont(fontInfo) end
        end
        
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 75)) 
            slot:SetSize(FVector2D(260, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) 
        WarningTargetWidget = btn
    end)
    return WarningTargetWidget
end

local function _M_DrawCounter()
    if isExpired then
        _G.CleanUpEnemyCounterWidget()
        return
    end

    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then 
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
                EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            if WarningTargetWidget and slua.isValid(WarningTargetWidget) then
                WarningTargetWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            return 
        end

        local widgetCounter = CreateEnemyCounterWidget()
        local widgetWarning = CreateWarningTargetWidget()

        if widgetCounter and slua.isValid(widgetCounter) then
            widgetCounter:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end

        local curTime = os.clock()
        if (curTime - LastCounterTime) > 0.5 then
            LastCounterTime = curTime
            
            local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
            local count = 0
            local nearest = 9999
            local isBeingTargeted = false 
            
            local KismetMathLibrary = import("KismetMathLibrary")
            local pc = player:GetPlayerControllerSafety()

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
                            count = count + 1
                            local d = math.floor(player:GetDistanceTo(tPawn) / 100)
                            if d < nearest then nearest = d end
                            
                            if _G.XthrlenConfig.EspAimWarning and not isBeingTargeted and d < 400 then
                                local eLoc = type(tPawn.K2_GetActorLocation) == "function" and tPawn:K2_GetActorLocation()
                                local pLoc = type(player.K2_GetActorLocation) == "function" and player:K2_GetActorLocation()
                                
                                if eLoc and pLoc and KismetMathLibrary then
                                    local lookRot = KismetMathLibrary.FindLookAtRotation(eLoc, pLoc)
                                    local eRot = nil
                                    
                                    if type(tPawn.GetControlRotation) == "function" then
                                        eRot = tPawn:GetControlRotation()
                                    elseif type(tPawn.GetActorRotation) == "function" then
                                        eRot = tPawn:GetActorRotation()
                                    end
                                    
                                    if eRot and lookRot then
                                        local dYaw = math.abs(eRot.Yaw - lookRot.Yaw)
                                        if dYaw > 180 then dYaw = 360 - dYaw end
                                        
                                        local dPitch = math.abs(eRot.Pitch - lookRot.Pitch)
                                        if dPitch > 180 then dPitch = 360 - dPitch end
                                        
                                        if dYaw < 15 and dPitch < 20 then
                                            if _G.XthrlenConfig.EspAimWarningVisCheck then
                                                if slua.isValid(pc) and type(pc.LineOfSightTo) == "function" then
                                                    if pc:LineOfSightTo(tPawn) then
                                                        isBeingTargeted = true
                                                    end
                                                end
                                            else
                                                isBeingTargeted = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if widgetCounter and widgetCounter.RichText_Content then
                widgetCounter.RichText_Content:SetText(string.format("Địch Xung Quanh: %d  |  Gần Nhất: %dm", count, count > 0 and nearest or 0))
            end

            if widgetWarning and slua.isValid(widgetWarning) then
                if _G.XthrlenConfig.EspAimWarning and isBeingTargeted then
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                else
                    widgetWarning:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                end
            end
        end
    end)
end

-- ========================================== 
-- VÒNG LẶP CHÍNH (MAIN LOOP)
-- ========================================== 
local function MainLoop()
    if isExpired then return end

    pcall(function()
        local SystemLib = import("KismetSystemLibrary")
        if SystemLib and not _G.FakeHWID_Hooked then
            _G.Original_GetDeviceId = SystemLib.GetDeviceId

            SystemLib.GetDeviceId = function(...)
                if _G.XthrlenConfig.FakeHWID then
                    if not _G.FakeHWID_String then
                        local chars = "0123456789abcdef"
                        local hwid = ""
                        for i = 1, 32 do 
                            hwid = hwid .. chars:sub(math.random(1, 16), math.random(1, 16)) 
                        end
                        _G.FakeHWID_String = hwid
                    end
                    return _G.FakeHWID_String
                end
                
                if _G.Original_GetDeviceId then return _G.Original_GetDeviceId(...) end
                return "UNKNOWN"
            end
            _G.FakeHWID_Hooked = true
        end
    end)

    _G.GetOriginalHWID = function()
        if _G.Original_GetDeviceId then
            return tostring(_G.Original_GetDeviceId())
        end
        local SystemLib = import("KismetSystemLibrary")
        if SystemLib and type(SystemLib.GetDeviceId) == "function" then
            return tostring(SystemLib.GetDeviceId())
        end
        return "UNKNOWN_DEVICE"
    end

    if _G.XthrlenState.CustomTextData == nil then 
        _G.XthrlenState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, HRecoil = 0.3, VRecoil = 0.3, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120, AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250, AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30, AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    if not Valid(localPlayer) then 
        if _G.XthrlenState.TrackedMarks then
            for markId, _ in pairs(_G.XthrlenState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.XthrlenState.TrackedMarks = {} 
        
        for key, data in pairs(_G.XthrlenState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
            if data and data.MIDs_V3 then
                for meshStr, midTable in pairs(data.MIDs_V3) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs_V3 = nil
            end
        end
        
        _G.XthrlenState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.XthrlenState.PrevGraphicsState = {}
        
        if _G.CleanUpEnemyCounterWidget then _G.CleanUpEnemyCounterWidget() end
        return 
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.XthrlenConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    _G.InitModMenuTab() 
    ShowXthrlenVIPMenu()
    
    if _G.XthrlenConfig.WallVehicle then
        _G.RunOptimizedVehicleESP()
    end
    
    if _G.XthrlenConfig.IpadView and _G.XthrlenState.CustomTextData then
        pcall(function()
            local targetTPP = _G.XthrlenState.CustomTextData.IpadViewFOV or 120
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end)
    else
        pcall(function()
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end)
    end

    if _G.XthrlenConfig.AimTouchEnable then
        _G.AimTouch()
    end
    
    if not _G.LastGlowTime or (os.clock() - _G.LastGlowTime) > 0.5 then
        _G.LastGlowTime = os.clock()
        if _G.ApplyWeaponGlow then _G.ApplyWeaponGlow(localPlayer) end
    end

    pcall(function()
        if _G.XthrlenConfig.CustomAimbot and localPlayer.bIsWeaponFiring and localPlayer.bIsGunADS then
            local outerRecoilVal = _G.XthrlenState.CustomTextData.OuterRecoil or 0
            if outerRecoilVal > 0 then
                local curTime = os.clock()
                
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
                                for _, target in ipairs(enemies) do
                                    if slua.isValid(target) and target.HealthStatus ~= 1 then 
                                        local tPos = type(target.K2_GetActorLocation) == "function" and target:K2_GetActorLocation() or nil
                                        if tPos then
                                            local screen = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                                local dx = screen.X - centerX
                                                local dy = screen.Y - centerY
                                                if math.sqrt(dx*dx + dy*dy) <= FOV_RADIUS then
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
    
    if _G.XthrlenConfig.ModSkin then
        local curTime = os.clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 2.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.HandlePetLogic then _G.HandlePetLogic() end
                    
                    if _G.XthrlenConfig.SkinDeadBox and _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then
                        _G.DeadBox_TemperRequest(pc)
                    end

                    if _G.AddOutfit then
                        if _G.AddOutfit.isInRealMatch() then
                            _G.AddOutfitLobbyRestored = false 
                            
                            local ticker = require("common.time_ticker")
                            if ticker and ticker.AddTimerOnce then
                                _G.AddOutfit.matchApplyAllSlots(localPlayer)
                                ticker.AddTimerOnce(0.2, function()
                                    if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() then 
                                        _G.AddOutfit.matchApplyHat(localPlayer) 
                                    end
                                end)
                                ticker.AddTimerOnce(0.4, function()
                                    if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() then 
                                        _G.AddOutfit.matchApplyWeaponSkin(localPlayer) 
                                    end
                                end)
                                ticker.AddTimerOnce(0.6, function()
                                    if slua.isValid(localPlayer) and _G.AddOutfit.isInRealMatch() and _G.AddOutfit.isCharacterAirborne(localPlayer) then
                                        _G.AddOutfit.applyAirborneSlots(localPlayer, true)
                                    end
                                end)
                            else
                                _G.AddOutfit.matchApplyAllSlots(localPlayer)
                                _G.AddOutfit.matchApplyHat(localPlayer)
                                _G.AddOutfit.matchApplyWeaponSkin(localPlayer)
                                if _G.AddOutfit.isCharacterAirborne(localPlayer) then
                                    _G.AddOutfit.applyAirborneSlots(localPlayer, true)
                                end
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

    pcall(function()
        local autoComp = localPlayer.AutoAimComp
        if Valid(autoComp) then
            if not _G.XthrlenState.OrigAutoAimCompCached then
                _G.XthrlenState.OrigAutoAimCompCached = {
                    bOnlyHitHead = autoComp.bOnlyHitHead,
                    HeadBoneName = autoComp.HeadBoneName,
                    Bones = autoComp.Bones,
                    ChestBoneName = autoComp.ChestBoneName,
                    PelvisBoneName = autoComp.PelvisBoneName,
                    HeadPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.HeadPriority,
                    ChestPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.ChestPriority,
                    PelvisPriority = autoComp.AimAssistConfig and autoComp.AimAssistConfig.PelvisPriority
                }
            end
            
            if _G.XthrlenConfig.AutoHead then
                autoComp.bOnlyHitHead = true
                autoComp.HeadBoneName = "Head"
                pcall(function() autoComp.Bones = {"Head"} end)
                autoComp.ChestBoneName = "Head"
                autoComp.PelvisBoneName = "Head"
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = 100
                    autoComp.AimAssistConfig.ChestPriority = 100
                    autoComp.AimAssistConfig.PelvisPriority = 100
                end
            else
                local orig = _G.XthrlenState.OrigAutoAimCompCached
                autoComp.bOnlyHitHead = orig.bOnlyHitHead
                autoComp.HeadBoneName = orig.HeadBoneName
                pcall(function() autoComp.Bones = orig.Bones or {"Spine_01", "Pelvis", "Head"} end)
                autoComp.ChestBoneName = orig.ChestBoneName
                autoComp.PelvisBoneName = orig.PelvisBoneName
                if autoComp.AimAssistConfig then
                    autoComp.AimAssistConfig.HeadPriority = orig.HeadPriority or 1
                    autoComp.AimAssistConfig.ChestPriority = orig.ChestPriority or 1
                    autoComp.AimAssistConfig.PelvisPriority = orig.PelvisPriority or 1
                end
            end
        end
    end)

    if _G.XthrlenConfig.WallClimb then
        pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) then
                if not _G.XthrlenState.WallClimbOriginals then
                    _G.XthrlenState.WallClimbOriginals = { WalkableFloorAngle = charMove.WalkableFloorAngle, MaxStepHeight = charMove.MaxStepHeight }
                end
                charMove.WalkableFloorAngle = 199.0
                charMove.MaxStepHeight = 999.0
                _G.XthrlenState.WallClimbApplied = true
            end
        end)
    elseif _G.XthrlenState.WallClimbApplied then
        pcall(function()
            local charMove = localPlayer.CharacterMovement
            if Valid(charMove) and _G.XthrlenState.WallClimbOriginals then
                charMove.WalkableFloorAngle = _G.XthrlenState.WallClimbOriginals.WalkableFloorAngle or 50.0
                charMove.MaxStepHeight = _G.XthrlenState.WallClimbOriginals.MaxStepHeight or 45.0
            end
        end)
        _G.XthrlenState.WallClimbApplied = false
    end

    if _G.XthrlenConfig.FastCar then
        pcall(function()
            local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
            if Valid(currentVehicle) then
                local rootComp = currentVehicle.RootComponent or (type(currentVehicle.K2_GetRootComponent) == "function" and currentVehicle:K2_GetRootComponent())
                
                if Valid(rootComp) and type(rootComp.SetAllPhysicsLinearVelocity) == "function" then
                    local isAccelerating = false
                    local moveComp = currentVehicle.VehicleMovement or currentVehicle.MovementComponent
                    if Valid(moveComp) then
                        local throttle = moveComp.ThrottleInput or 0
                        if type(moveComp.GetThrottleInput) == "function" then
                            throttle = moveComp:GetThrottleInput()
                        end
                        if throttle > 0.05 or throttle < -0.05 then 
                            isAccelerating = true
                        end
                    end
                    if currentVehicle.bIsPressingGas or (currentVehicle.Throttle and currentVehicle.Throttle ~= 0) then
                        isAccelerating = true
                    end

                    local currentVel = nil
                    if type(currentVehicle.GetVelocity) == "function" then
                        currentVel = currentVehicle:GetVelocity()
                    elseif type(rootComp.GetPhysicsLinearVelocity) == "function" then
                        currentVel = rootComp:GetPhysicsLinearVelocity()
                    elseif rootComp.ComponentVelocity then
                        currentVel = rootComp.ComponentVelocity
                    end

                    if currentVel then
                        local currentSpeed = math.sqrt(currentVel.X^2 + currentVel.Y^2)
                        local minSpeedToBoost = 50.0   
                        local maxSpeed = 4444.0        
                        local accelFactor = 1.5        
                        local brakeFactor = 0.85       
                        
                        if currentSpeed > minSpeedToBoost then
                            local dirX = currentVel.X / currentSpeed
                            local dirY = currentVel.Y / currentSpeed
                            
                            if isAccelerating then
                                local targetSpeed = currentSpeed * accelFactor
                                if targetSpeed > maxSpeed then targetSpeed = maxSpeed end
                                local newX = dirX * targetSpeed
                                local newY = dirY * targetSpeed
                                local newZ = currentVel.Z 
                                rootComp:SetAllPhysicsLinearVelocity(FVector(newX, newY, newZ), false)
                            else
                                local targetSpeed = currentSpeed * brakeFactor
                                if targetSpeed > minSpeedToBoost then
                                    local newX = dirX * targetSpeed
                                    local newY = dirY * targetSpeed
                                    local newZ = currentVel.Z 
                                    rootComp:SetAllPhysicsLinearVelocity(FVector(newX, newY, newZ), false)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local now = os.clock()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.XthrlenConfig.RemoveGrass and not _G.XthrlenState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.XthrlenState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.XthrlenConfig.RemoveGrass and _G.XthrlenState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.XthrlenState.PrevGraphicsState.RemoveGrass = false
            end

            if _G.XthrlenConfig.RemoveTrees and not _G.XthrlenState.PrevGraphicsState.RemoveTrees then
                gi:ExecuteCMD("foliage.DensityScale", "0")
                gi:ExecuteCMD("r.Foliage.DensityScale", "0")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "10000")
                gi:ExecuteCMD("r.DisableTreeRender", "1")
                _G.XthrlenState.PrevGraphicsState.RemoveTrees = true
            elseif not _G.XthrlenConfig.RemoveTrees and _G.XthrlenState.PrevGraphicsState.RemoveTrees then
                gi:ExecuteCMD("foliage.DensityScale", "1")
                gi:ExecuteCMD("r.Foliage.DensityScale", "1")
                gi:ExecuteCMD("foliage.MinimumScreenSize", "0.0001")
                gi:ExecuteCMD("r.DisableTreeRender", "0")
                _G.XthrlenState.PrevGraphicsState.RemoveTrees = false
            end
            
            if _G.XthrlenConfig.RemoveFog and not _G.XthrlenState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "0")           
                gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.XthrlenState.PrevGraphicsState.RemoveFog = true
            elseif not _G.XthrlenConfig.RemoveFog and _G.XthrlenState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") 
                gi:ExecuteCMD("r.Fog", "1")           
                gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.XthrlenState.PrevGraphicsState.RemoveFog = false
            end
            
            if _G.XthrlenConfig.WhiteBody and not _G.XthrlenState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
                gi:ExecuteCMD("r.CharacterDiffusePower", "5")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "100")
                _G.XthrlenState.PrevGraphicsState.WhiteBody = true
            elseif not _G.XthrlenConfig.WhiteBody and _G.XthrlenState.PrevGraphicsState.WhiteBody then
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                _G.XthrlenState.PrevGraphicsState.WhiteBody = false
            end
            
            if _G.XthrlenConfig.ColorBodyV2 and not _G.XthrlenState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "4")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "200")
                gi:ExecuteCMD("r.CharacterDiffusePower", "200")
                _G.XthrlenState.PrevGraphicsState.ColorBodyV2 = true
            elseif not _G.XthrlenConfig.ColorBodyV2 and _G.XthrlenState.PrevGraphicsState.ColorBodyV2 then
                gi:ExecuteCMD("r.CharacterMinShadowFactor", "1")
                gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
                gi:ExecuteCMD("r.CharacterDiffusePower", "1")
                _G.XthrlenState.PrevGraphicsState.ColorBodyV2 = false
            end
            
            if _G.XthrlenConfig.BlackSky and not _G.XthrlenState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
                _G.XthrlenState.PrevGraphicsState.BlackSky = true
            elseif not _G.XthrlenConfig.BlackSky and _G.XthrlenState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
                _G.XthrlenState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
            elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then 
                table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent) 
            end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.XthrlenConfig.CustomHRecoil or _G.XthrlenConfig.CustomVRecoil or _G.XthrlenConfig.LessShake or _G.XthrlenConfig.Accuracy or _G.XthrlenConfig.Crosshair or _G.XthrlenConfig.GodMode or _G.XthrlenConfig.AutoHead or _G.XthrlenConfig.CustomAimbot or _G.XthrlenConfig.CustomAimbotClose or _G.XthrlenConfig.AimbotMode ~= "None" or _G.XthrlenConfig.LessRecoil or _G.XthrlenConfig.VerticalRecoil

                if anyWeaponModOn then
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
                    
                    if _G.XthrlenConfig.CustomHRecoil then entity.AccessoriesHRecoilFactor = _G.XthrlenState.CustomTextData.HRecoil or 0.3 
                    elseif _G.XthrlenConfig.LessRecoil then entity.AccessoriesHRecoilFactor = 0.3 end
                    
                    if _G.XthrlenConfig.CustomVRecoil then entity.AccessoriesVRecoilFactor = _G.XthrlenState.CustomTextData.VRecoil or 0.3
                    elseif _G.XthrlenConfig.VerticalRecoil then entity.AccessoriesVRecoilFactor = 0.3 end
                    
                    if _G.XthrlenConfig.LessShake then entity.RecoilKick = 0.0; entity.RecoilKickADS = 0.0; entity.AnimationKick = 0.0 end
                    if _G.XthrlenConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.XthrlenConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.XthrlenConfig.GodMode then entity.BulletFireSpeed = 500000.0; entity.ShootInterval = 0.001; entity.BaseDamage = 60000.0 end
                    
                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end
                        
                        if _G.XthrlenConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end
                        
                        if _G.XthrlenConfig.CustomAimbot then
                            local speed = _G.XthrlenState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.RangeRate = 4.5
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 4.5
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.XthrlenConfig.CustomAimbotClose or _G.XthrlenConfig.AimbotMode == "Close" then
                            local speed = _G.XthrlenState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        elseif _G.XthrlenConfig.AimbotMode == "Far" then
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = 5
                                entity.AutoAimingConfig.OuterRange.RangeRate = 0.7
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = 5
                                entity.AutoAimingConfig.InnerRange.RangeRate = 0.7
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1
                            end
                        end
                    end
                    
                    entity.XthrlenWeaponModsActive = true

                elseif entity.XthrlenWeaponModsActive then
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
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.XthrlenWeaponModsActive = false
                end
            end
        end
    end)

    local mHead_Global, mBody_Global, mLegs_Global = 1.0, 1.0, 1.0
    local runInject_Global = false
    
    pcall(function()
        if _G.XthrlenConfig.CustomMagicBullet then
            runInject_Global = true
            mHead_Global = 1.0; mBody_Global = 1.0; mLegs_Global = 1.0
            if _G.XthrlenState.CustomTextData then
                local cData = _G.XthrlenState.CustomTextData
                if cData.MagicHead ~= nil then mHead_Global = tonumber(cData.MagicHead) or mHead_Global end
                if cData.MagicBody ~= nil then mBody_Global = tonumber(cData.MagicBody) or mBody_Global end
                if cData.MagicLegs ~= nil then mLegs_Global = tonumber(cData.MagicLegs) or mLegs_Global end
            end
        elseif _G.XthrlenConfig.MagicBullet then
            runInject_Global = true
            mHead_Global = 1.05; mBody_Global = 1.0; mLegs_Global = 1.0
        end

        if runInject_Global then
            local currentMagicHash = "M_"..tostring(mHead_Global).."_"..tostring(mBody_Global).."_"..tostring(mLegs_Global)
            if _G.XthrlenState.LastMagicConfigHash ~= currentMagicHash then
                _G.XthrlenState.MagicUpdateVersion = (_G.XthrlenState.MagicUpdateVersion or 0) + 1
                _G.XthrlenState.LastMagicConfigHash = currentMagicHash
            end
        else
            if _G.XthrlenState.LastMagicConfigHash ~= "OFF" then
                _G.XthrlenState.MagicUpdateVersion = (_G.XthrlenState.MagicUpdateVersion or 0) + 1
                _G.XthrlenState.LastMagicConfigHash = "OFF"
            end
        end
    end)

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end
        
        for key, data in pairs(_G.XthrlenState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)
                
                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end
                
                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do midTable[k] = nil end
                    end
                    data.MIDs = nil
                end
                if data.MIDs_V3 then
                    for meshStr, midTable in pairs(data.MIDs_V3) do
                        for k, _ in pairs(midTable) do midTable[k] = nil end
                    end
                    data.MIDs_V3 = nil
                end
                
                data.enemy = nil
                data.CachedMeshes = nil
                _G.XthrlenState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
            elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global, 
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,   
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global    
        }
        
        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                    elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.XthrlenState.EnemyMarks[eKey] = _G.XthrlenState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.XthrlenState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end 
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end
                        
                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)
                    
                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                    if _G.XthrlenConfig.WallXuyenTuong then
                        if isMeshChanged or not markData.WallhackApplied then
                            ApplyWallXuyenTuong(enemy, markData)
                            markData.WallhackApplied = true
                            markData.LastMeshCountWall = currentMeshCount
                        end
                    else
                        UndoWallXuyenTuong(enemy, markData)
                    end

                    if _G.XthrlenConfig.ColorBodyV2 then 
                        ApplyColorBodyV2(enemy, pc, markData) 
                    else
                        UndoColorBodyV2(enemy, markData)
                    end
                    
                    if _G.XthrlenConfig.ColorBodyV3 then 
                        ApplyColorBodyV3(enemy, markData)
                    else
                        UndoColorBodyV3(enemy, markData)
                    end
                    
                    if _G.XthrlenConfig.ColorBodyNew then 
                        ApplyColorBodyNew(enemy, markData)
                    else
                        UndoColorBodyNew(enemy, markData)
                    end

                    pcall(function()
                        if Valid(eMesh) then
                            local targetScale = 1.0
                            if _G.XthrlenConfig.BugManEnable and _G.XthrlenState.CustomTextData then
                                targetScale = 177.0 / (_G.XthrlenState.CustomTextData.BugManRatio or 133)
                                if targetScale < 1.0 then targetScale = 1.0 end
                                if targetScale > 2.0 then targetScale = 2.0 end 
                            end
                            
                            if markData.LastFatScale ~= targetScale then
                                eMesh:SetRelativeScale3D(FVector(targetScale, targetScale, 1.0))
                                markData.LastFatScale = targetScale
                            end
                        end
                    end)

                    pcall(function()
                        local EnemyMesh = eMesh
                        if slua.isValid(EnemyMesh) then
                            local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                            
                            if markData.MagicBulletHash == _G.XthrlenState.LastMagicConfigHash and markData.MagicTargetID == uniqueID then
                                return 
                            end

                            local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                            if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset end

                            if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                                if not _G.AK_ModdedPhysAssets then _G.AK_ModdedPhysAssets = {} end
                                local PhysAssetName = "DefaultPhys"
                                pcall(function() PhysAssetName = PhysicsAsset:GetName() end)
                                
                                if _G.AK_ModdedPhysAssets[PhysAssetName] ~= _G.XthrlenState.LastMagicConfigHash then
                                    
                                    if not _G.AK_OrigHitboxes then _G.AK_OrigHitboxes = {} end
                                    if not _G.AK_OrigHitboxes[PhysAssetName] then _G.AK_OrigHitboxes[PhysAssetName] = {} end
                                    local OrigHitboxData = _G.AK_OrigHitboxes[PhysAssetName]

                                    local SkeletalBodySetups = PhysicsAsset.SkeletalBodySetups
                                    local numSetups = type(SkeletalBodySetups.Num) == "function" and SkeletalBodySetups:Num() or #SkeletalBodySetups
                                    local limit = numSetups > 50 and 50 or numSetups

                                    for i = 1, limit do 
                                        local BodySetup = type(SkeletalBodySetups.Get) == "function" and SkeletalBodySetups:Get(i-1) or SkeletalBodySetups[i]
                                        if slua.isValid(BodySetup) then
                                            local LowerBoneName = string.lower(tostring(BodySetup.BoneName))
                                            local MatchedBoneKey = nil
                                            for k, _ in pairs(BoneScaleMap) do
                                                if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end
                                            end

                                            if MatchedBoneKey then
                                                local TargetScale = 1.0 
                                                if runInject_Global then TargetScale = BoneScaleMap[MatchedBoneKey] end
                                                
                                                local AggGeom = BodySetup.AggGeom
                                                
                                                local BoxElems = AggGeom and AggGeom.BoxElems or BodySetup.BoxElems
                                                local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                                local SphylElems = AggGeom and AggGeom.SphylElems or BodySetup.SphylElems

                                                local BoxElem = GetFirstElemSafe(BoxElems)
                                                local SphereElem = GetFirstElemSafe(SphereElems)
                                                local SphylElem = GetFirstElemSafe(SphylElems)

                                                if not OrigHitboxData[MatchedBoneKey] then
                                                    OrigHitboxData[MatchedBoneKey] = { Box = nil, Sphere = nil, Sphyl = nil }
                                                    if BoxElem then OrigHitboxData[MatchedBoneKey].Box = { X = BoxElem.X, Y = BoxElem.Y, Z = BoxElem.Z } end
                                                    if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                                    if SphylElem then OrigHitboxData[MatchedBoneKey].Sphyl = { Radius = SphylElem.Radius, Length = SphylElem.Length } end
                                                end

                                                local OrigElemData = OrigHitboxData[MatchedBoneKey]

                                                if OrigElemData.Box and BoxElem then
                                                    BoxElem.X = OrigElemData.Box.X * TargetScale
                                                    BoxElem.Y = OrigElemData.Box.Y * TargetScale
                                                    BoxElem.Z = OrigElemData.Box.Z * TargetScale
                                                    if type(BoxElems.Set) == "function" then BoxElems:Set(0, BoxElem) else BoxElems[1] = BoxElem end
                                                    if AggGeom then AggGeom.BoxElems = BoxElems; BodySetup.AggGeom = AggGeom else BodySetup.BoxElems = BoxElems end
                                                end

                                                if OrigElemData.Sphere and SphereElem then
                                                    SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                    if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                    if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                end

                                                if OrigElemData.Sphyl and SphylElem then
                                                    SphylElem.Radius = OrigElemData.Sphyl.Radius * TargetScale
                                                    SphylElem.Length = OrigElemData.Sphyl.Length * TargetScale
                                                    if type(SphylElems.Set) == "function" then SphylElems:Set(0, SphylElem) else SphylElems[1] = SphylElem end
                                                    if AggGeom then AggGeom.SphylElems = SphylElems; BodySetup.AggGeom = AggGeom else BodySetup.SphylElems = SphylElems end
                                                end
                                            end
                                        end
                                    end
                                    _G.AK_ModdedPhysAssets[PhysAssetName] = _G.XthrlenState.LastMagicConfigHash
                                end
                                
                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset
                                
                                markData.MagicBulletHash = _G.XthrlenState.LastMagicConfigHash
                                markData.MagicTargetID = uniqueID 
                            end
                        end
                    end)

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.XthrlenConfig.EspLoai5 or _G.XthrlenConfig.EspVipPro or _G.XthrlenConfig.EspVip
                    
                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp

                    if _G.XthrlenConfig.EspAntenna then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) and distM <= 400 then
                                local loopCount = 8  
                                local zStep = 1000     
                                local baseZ = 105     
                                local topZ = baseZ + (loopCount * zStep)
                                for i = 1, loopCount do
                                    local zOffset = baseZ + (i * zStep)
                                    MyHUD:AddDebugText("|", enemy, 0.06,
                                        {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset},
                                        C_GREEN, true, false, true, nil, 1.2, true)
                                end
                                MyHUD:AddDebugText("I", enemy, 0.06,
                                        {X=0, Y=0, Z=topZ + 60}, {X=0, Y=0, Z=topZ + 60},
                                        C_GREEN, true, false, true, nil, 1.5, true)
                            end
                        end)
                    end

                    if _G.XthrlenConfig.EspLoai6 then
                        pcall(function()
                            local curTime = os.clock()
                            if markData.LastEsp6Time == nil or (curTime - markData.LastEsp6Time) >= 0.05 then
                                markData.LastEsp6Time = curTime
                                
                                local MyHUD = Cached_MyHUD
                                if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                    if distM <= 250 then
                                        if type(eMesh.GetSocketLocation) == "function" then
                                            for _, bName in ipairs(GLOBAL_BONE_LIST) do
                                                if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                else
                                                    local wLoc = eMesh:GetSocketLocation(bName)
                                                    if wLoc then
                                                        local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                        local mark = "▪"
                                                        local fixedSize = 0.25 
                                                        local color = C_CYAN
                                                        
                                                        if bName == "head" then 
                                                            mark = "●"
                                                            fixedSize = 0.45
                                                            color = C_RED
                                                        elseif bName == "pelvis" or bName == "neck_01" then 
                                                            mark = "▪"
                                                            fixedSize = 0.35
                                                            color = C_YELLOW 
                                                        end
                                                        
                                                        MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    if _G.XthrlenConfig.EspLoai7 then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) then
                                if distM <= 600 then if isBot then aiCount = aiCount + 1 else realCount = realCount + 1 end end
                                
                                if distM <= 400 then
                                    local stateText = ""
                                    
                                    if _G.XthrlenConfig.Esp7_TuThe then
                                        local pose = nil
                                        if enemy.PoseState then pose = enemy.PoseState
                                        elseif type(enemy.GetPoseState) == "function" then pose = enemy:GetPoseState() end
                                        
                                        if pose == 0 or pose == "Stand" then stateText = "Đứng"
                                        elseif pose == 1 or pose == "Crouch" then stateText = "Ngồi"
                                        elseif pose == 2 or pose == "Prone" then stateText = "Nằm"
                                        else stateText = "Đứng" end
                                    end
                                    
                                    if _G.XthrlenConfig.Esp7_VuKhi then
                                        local curTime = os.clock()
                                        if markData.AK_LAST_WEP_TIME == nil or curTime > markData.AK_LAST_WEP_TIME + 1.5 then
                                            local eWeapon = nil
                                            if enemy.CurrentWeapon then eWeapon = enemy.CurrentWeapon
                                            elseif type(enemy.GetCurrentWeapon) == "function" then eWeapon = enemy:GetCurrentWeapon()
                                            elseif enemy.WeaponManagerComponent then eWeapon = enemy.WeaponManagerComponent.CurrentWeaponReplicated end
                                            
                                            local weaponName = "Tay Không"
                                            if Valid(eWeapon) then if type(eWeapon.GetWeaponName) == "function" then weaponName = eWeapon:GetWeaponName() end end
                                            markData.AK_CACHED_WEP_NAME = tostring(weaponName)
                                            markData.AK_LAST_WEP_TIME = curTime
                                        end

                                        if stateText ~= "" then
                                            stateText = stateText .. " - " .. (markData.AK_CACHED_WEP_NAME or "Tay Không")
                                        else
                                            stateText = (markData.AK_CACHED_WEP_NAME or "Tay Không")
                                        end
                                    end

                                    if stateText ~= "" then
                                        local textColor = isBot and C_CYAN or C_YELLOW
                                        local dynamicScale = math.max(0.5, 0.8 - (distM / 400))
                                        MyHUD:AddDebugText(stateText, enemy, 0.06, {X=0, Y=0, Z=100}, {X=0, Y=0, Z=100}, textColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end)
                    end

                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then 
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end
                                
                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    if _G.XthrlenConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                                    local hpPercent = hpRatio
                                    local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)
                                    
                                    local hpColor = C_GREEN
                                    if hpPercent < 0.3 then hpColor = C_RED
                                    elseif hpPercent < 0.7 then hpColor = C_YELLOW end
                                    if isKnock then hpColor = C_RED end
                                    
                                    if _G.XthrlenConfig.Esp3ShowName then
                                        local enemyName = "Enemy"
                                        pcall(function() if enemy.PlayerName then enemyName = enemy.PlayerName elseif type(enemy.GetPlayerName) == "function" then enemyName = enemy:GetPlayerName() end end)
                                        if enemyName == "" then enemyName = "Enemy" end
                                        if isKnock then enemyName = "KNOCK: " .. enemyName end
                                        hud:AddDebugText(enemyName, enemy, 0.06, {X=0, Y=0, Z=-370}, {X=0, Y=0, Z=-370}, C_WHITE, true, false, true, nil, dynamicScale * 1.1, true)
                                    end
                                    
                                    if _G.XthrlenConfig.Esp3ShowHP then
                                        if not isKnock then
                                            local segments = 6
                                            local filled = math.floor(hpPercent * segments)
                                            local startZ = 20
                                            local spacing = 10.0 * dynamicScale 
                                            for j = 1, segments do
                                                local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
                                                hud:AddDebugText("█", enemy, 0.06, {X=0, Y=-115, Z=startZ + (j * spacing)}, {X=0, Y=-115, Z=startZ + (j * spacing)}, color, true, false, true, nil, dynamicScale * 1.2, true)
                                            end
                                            hud:AddDebugText(string.format("%d%%", math.floor(hpPercent * 100)), enemy, 0.06, {X=0, Y=-60, Z=startZ - 12}, {X=0, Y=-60, Z=startZ - 12}, hpColor, true, false, true, nil, dynamicScale * 0.8, true)
                                        else
                                            hud:AddDebugText("DOWN", enemy, 0.06, {X=0, Y=-115, Z=50}, {X=0, Y=-115, Z=50}, C_RED, true, false, true, nil, dynamicScale * 1.0, true)
                                        end
                                    end
                                end
                            end
                        end)
                    end

                    if _G.XthrlenConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if Valid(hud) and hud.AddDebugText then
                                if distM <= 400 then
                                    local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                                    hud:AddDebugText(string.format("[%dm]", math.floor(distM)), enemy, 0.06, {X=0, Y=115, Z=20}, {X=0, Y=115, Z=20}, C_BLUE_TEXT, true, false, true, nil, dynamicScale * 1.5, true)
                                end
                            end
                        end)
                    end

                    if _G.XthrlenConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    if _G.XthrlenConfig.EspLoai8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end
                    
                    if _G.XthrlenConfig.EspRadar then
                        if not markData.radarMark or markData.radarMark == 0 then 
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy) 
                        end
                    else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end
                    
                    if _G.XthrlenConfig.EspOutline then
                        pcall(function()
                            local outColorChoice = _G.XthrlenState.CustomTextData.OutlineColor or 4
                            local outThick = _G.XthrlenConfig.OutlineThickness or 10
                            local outlineHash = string.format("%d_%d", outThick, outColorChoice)
                            
                            local meshes = GetAllSkeletalMeshes(enemy, markData)
                            local currentMeshCount = #meshes
                            
                            if markData.OutlineState ~= outlineHash or markData.LastMeshCountOutline ~= currentMeshCount then
                                local r, g, b = 255, 255, 0 
                                if outColorChoice == 1 then r, g, b = 255, 0, 0 
                                elseif outColorChoice == 2 then r, g, b = 0, 255, 0 
                                elseif outColorChoice == 3 then r, g, b = 0, 0, 255 
                                elseif outColorChoice == 4 then r, g, b = 255, 255, 0 
                                elseif outColorChoice == 5 then r, g, b = 255, 0, 255 
                                elseif outColorChoice == 6 then r, g, b = 255, 255, 255 end 

                                local glowIntensity = 80.0
                                local LinearColorClass = import("LinearColor") or _G.FLinearColor
                                local glowDynamic = LinearColorClass and LinearColorClass((r/255) * glowIntensity, (g/255) * glowIntensity, (b/255) * glowIntensity, 1.0) or { R = r * glowIntensity, G = g * glowIntensity, B = b * glowIntensity, A = 255 }

                                for _, comp in ipairs(meshes) do
                                    if Valid(comp) then
                                        pcall(function()
                                            comp.UseScopeDistanceCulling = false 
                                            comp.PrimitiveShadingStrategy = 1
                                            comp.ShadingRate = 6
                                        end)

                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(true)
                                            if comp.OverrideIdeaOutlineColor then
                                                comp:OverrideIdeaOutlineColor(true, glowDynamic)
                                            end
                                            if comp.OverrideIdeaOutlineThickness then
                                                comp:OverrideIdeaOutlineThickness(true, _G.XthrlenConfig.OutlineThickness)
                                            end
                                        end
                                    end
                                end
                                markData.OutlineState = outlineHash
                                markData.LastMeshCountOutline = currentMeshCount 
                            end
                        end)
                    else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local meshes = GetAllSkeletalMeshes(enemy, markData)
                                for _, comp in ipairs(meshes) do
                                    if Valid(comp) then
                                        pcall(function()
                                            comp.PrimitiveShadingStrategy = 0
                                            comp.ShadingRate = 1
                                        end)
                                        
                                        if comp.SetDrawIdeaOutline then
                                            comp:SetDrawIdeaOutline(false)
                                        end
                                    end
                                end
                                markData.OutlineState = "OFF"
                                markData.LastMeshCountOutline = 0
                            end
                        end)
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8) 
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil
                        
                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end
                        
                        if markData.MIDs_V3 then
                            for meshStr, midTable in pairs(markData.MIDs_V3) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs_V3 = nil
                        end
                        
                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then 
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end 
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end
                            
                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end

        if _G.XthrlenConfig.EspLoai7 and _G.XthrlenConfig.Esp7_SoLuong then
            _M_DrawCounter() 
        else
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
                EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end

        if _G.XthrlenConfig.EspBomMaster and (_G.XthrlenConfig.EspItemBom or _G.XthrlenConfig.EspActiveBom) then
            pcall(function()
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
                        local curTime = os.clock()
                        
                        if not _G.LastBombScanTime or (curTime - _G.LastBombScanTime) > 0.5 then
                            _G.LastBombScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                            
                            local activeBombs = {}
                            local itemBombs = {}
                            
                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        if not _G.NonBombCache[actor] then
                                            local bType = 0
                                            local isItem = false
                                            local isKnownBomb = _G.BombCache[actor]
                                            
                                            if isKnownBomb then
                                                bType = isKnownBomb.type
                                                isItem = isKnownBomb.isItem
                                            else
                                                local nameLower = nil
                                                pcall(function() nameLower = string.lower(type(actor.GetName) == "function" and actor:GetName() or tostring(actor)) end)
                                                
                                                if nameLower then
                                                    if string.find(nameLower, "m79") or string.find(nameLower, "launcher") then bType = 5
                                                    elseif string.find(nameLower, "smoke") then bType = 2
                                                    elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                                    elseif string.find(nameLower, "flash") or string.find(nameLower, "stun") then bType = 4
                                                    elseif string.find(nameLower, "grenade") then bType = 1 end
                                                    
                                                    if bType > 0 then
                                                        if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                            isItem = false
                                                        else
                                                            isItem = true
                                                            local shouldAdd = true
                                                            if bType == 3 and not (string.find(nameLower, "pickup") or string.find(nameLower, "wrapper") or string.find(nameLower, "weapon")) then
                                                                shouldAdd = false
                                                            elseif bType == 5 then
                                                                local attachParent = nil
                                                                pcall(function() if type(actor.GetAttachParentActor) == "function" then attachParent = actor:GetAttachParentActor() end end)
                                                                if slua.isValid(attachParent) then
                                                                    local isHolding = false
                                                                    pcall(function()
                                                                        local curWeapon = type(attachParent.GetCurrentWeapon) == "function" and attachParent:GetCurrentWeapon() or attachParent.CurrentWeapon
                                                                        if curWeapon == actor then isHolding = true end
                                                                    end)
                                                                    if not isHolding then shouldAdd = false end
                                                                end
                                                            end
                                                            if not shouldAdd then bType = 0 end
                                                        end
                                                    end
                                                end
                                                
                                                if bType > 0 then
                                                    _G.BombCache[actor] = { type = bType, isItem = isItem }
                                                else
                                                    _G.NonBombCache[actor] = true
                                                end
                                            end
                                            
                                            if bType > 0 then
                                                local isPendingKill = false
                                                pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                                
                                                if not isPendingKill then
                                                    if isItem then
                                                        table.insert(itemBombs, {act = actor, type = bType})
                                                    else
                                                        table.insert(activeBombs, {act = actor, type = bType})
                                                    end
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
                        pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)

                        local function DrawBombs(bombList, isItem, maxDist)
                            if not bombList then return end
                            for _, item in ipairs(bombList) do
                                local bomb = item.act
                                local bType = item.type
                                
                                if slua.isValid(bomb) and not bomb.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(bomb) / 100 end)
                                    
                                    if distM > 0 and distM <= maxDist then
                                        local displayName = ""
                                        local bombColor = C_WHITE
                                        local zOffset = isItem and 15 or 25
                                        
                                        if bType == 1 then displayName = "Boom"; bombColor = isItem and {R=255, G=100, B=100, A=255} or C_RED
                                        elseif bType == 2 then displayName = "KHÓI"; bombColor = isItem and {R=200, G=200, B=200, A=255} or C_WHITE
                                        elseif bType == 3 then displayName = "LỬA"; bombColor = isItem and {R=255, G=160, B=50, A=255} or {R=255, G=100, B=0, A=255}
                                        elseif bType == 4 then displayName = "MÙ"; bombColor = isItem and {R=150, G=255, B=255, A=255} or C_CYAN
                                        elseif bType == 5 then displayName = "ĐẠN KHÓI"; bombColor = isItem and {R=150, G=255, B=150, A=255} or {R=100, G=255, B=100, A=255} end
                                        
                                        local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                        local shouldTimerRun = not isItem 
                                        
                                        if isItem then pcall(function() if bomb.bIsPinPulled or bomb.bPinPulled or (type(bomb.IsPinPulled) == "function" and bomb:IsPinPulled()) then shouldTimerRun = true end end) end

                                        if shouldTimerRun and curGameTime > 0 then
                                            local timeLeft = -1
                                            pcall(function() if bomb.ExplosionTime then timeLeft = bomb.ExplosionTime - curGameTime elseif bomb.ExplodeTime then timeLeft = bomb.ExplodeTime - curGameTime end end)
                                            
                                            if timeLeft == -1 or timeLeft > 100 then
                                                _G.ActiveBombTimers = _G.ActiveBombTimers or {}
                                                local bombId = tostring(bomb)
                                                if not _G.ActiveBombTimers[bombId] then _G.ActiveBombTimers[bombId] = curGameTime end
                                                local elapsed = curGameTime - _G.ActiveBombTimers[bombId]
                                                local maxTime = (bType == 1 and 7.0) or (bType == 2 and 45.0) or (bType == 3 and 12.0) or (bType == 4 and 5.0) or 45.0
                                                timeLeft = maxTime - elapsed
                                            end
                                            
                                            if timeLeft < 0 then timeLeft = 0 end
                                            if timeLeft > 0.1 then text = string.format("%s (%.1fs)", text, timeLeft) end
                                        end
                                        
                                        local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                        MyHUD:AddDebugText(text, bomb, 0.06, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, bombColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end
                        
                        if not _G.LastClearTimer or (curTime - _G.LastClearTimer) > 1.0 then
                            _G.LastClearTimer = curTime
                            pcall(function() if _G.ActiveBombTimers then for k, v in pairs(_G.ActiveBombTimers) do if (curGameTime - v) > 60.0 then _G.ActiveBombTimers[k] = nil end end end end)
                        end

                        if _G.XthrlenConfig.EspItemBom then DrawBombs(_G.CachedItemBombs, true, 50) end
                        if _G.XthrlenConfig.EspActiveBom then DrawBombs(_G.CachedActiveBombs, false, 150) end
                    end
                end
            end)
        end

        -- ==========================================================
        -- [LOGIC ESP XE - VEHICLE ESP VVIP] - OPTIMIZED KHÔNG MÁU (SIÊU NHẸ)
        -- ==========================================================
        if _G.XthrlenConfig.EspVehicle then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForVehicle then _G.CachedActorClass_ForVehicle = import("STExtraVehicleBase") end 
                    if not _G.CachedVehicleArray then _G.CachedVehicleArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForVehicle) end
                    
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()

                        -- LUỒNG QUÉT CHÍNH: 1.0s quét 1 lần.
                        if not _G.LastVehicleScanTime or (curTime - _G.LastVehicleScanTime) > 1.0 then
                            _G.LastVehicleScanTime = curTime
                            local allVehicles = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForVehicle, _G.CachedVehicleArray)
                            
                            local activeVehicles = {}
                            if allVehicles then
                                for _, veh in pairs(allVehicles) do
                                    if slua.isValid(veh) and not veh.bHidden and not veh.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(veh.IsPendingKill) == "function" then isPendingKill = veh:IsPendingKill() end end)
                                        
                                        if not isPendingKill then
                                            local vehName = "Xe"
                                            local hasDriver = false
                                            
                                            pcall(function()
                                                if type(veh.GetVehicleName) == "function" then vehName = veh:GetVehicleName() elseif veh.VehicleName then vehName = veh.VehicleName end
                                                local driver = type(veh.GetDriver) == "function" and veh:GetDriver() or nil
                                                if slua.isValid(driver) then hasDriver = true end
                                            end)
                                            
                                            local nameLower = string.lower(tostring(vehName) .. tostring(veh))
                                            local displayName = "Xe"
                                            if string.find(nameLower, "uaz") then displayName = "UAZ"
                                            elseif string.find(nameLower, "dacia") then displayName = "Dacia"
                                            elseif string.find(nameLower, "buggy") then displayName = "Buggy"
                                            elseif string.find(nameLower, "mirado") then displayName = "Mirado"
                                            elseif string.find(nameLower, "bike") or string.find(nameLower, "motor") then displayName = "Motor"
                                            elseif string.find(nameLower, "scooter") then displayName = "Scooter"
                                            elseif string.find(nameLower, "coupe") then displayName = "Coupe RB"
                                            elseif string.find(nameLower, "brdm") then displayName = "BRDM"
                                            elseif string.find(nameLower, "boat") or string.find(nameLower, "aquarail") then displayName = "Thuyền"
                                            elseif string.find(nameLower, "glider") then displayName = "Tàu lượn"
                                            else displayName = "Xe (" .. string.sub(vehName, 1, 8) .. ")" end

                                            table.insert(activeVehicles, {act = veh, name = displayName, hasDriver = hasDriver})
                                        end
                                    end
                                end
                            end
                            _G.CachedVehicles = activeVehicles
                        end

                        if _G.CachedVehicles then
                            for _, item in ipairs(_G.CachedVehicles) do
                                local veh = item.act
                                if slua.isValid(veh) and not veh.bHidden then
                                    local isShow = false
                                    if item.name == "Dacia" then isShow = _G.XthrlenConfig.EspVeh_Dacia
                                    elseif item.name == "UAZ" then isShow = _G.XthrlenConfig.EspVeh_UAZ
                                    elseif item.name == "Buggy" then isShow = _G.XthrlenConfig.EspVeh_Buggy
                                    elseif item.name == "Coupe RB" then isShow = _G.XthrlenConfig.EspVeh_Coupe
                                    elseif item.name == "Mirado" then isShow = _G.XthrlenConfig.EspVeh_Mirado
                                    elseif item.name == "Motor" or item.name == "Scooter" then isShow = _G.XthrlenConfig.EspVeh_Motor
                                    else isShow = _G.XthrlenConfig.EspVeh_Other end

                                    if isShow then
                                        local distM = 0
                                        pcall(function() distM = localPlayer:GetDistanceTo(veh) / 100 end)
                                        
                                        if distM > 0 and distM <= 300 then
                                            local text = string.format("%s [%dm]", item.name, math.floor(distM))
                                            local vehColor = item.hasDriver and {R=255, G=50, B=50, A=255} or {R=0, G=255, B=150, A=255}
                                            local dynamicScale = math.max(0.6, 1.1 - (distM / 500))
                                            
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

    end)
end

_G.XthrlenState.LoopToken = (_G.XthrlenState.LoopToken or 0) + 1 
local myToken = _G.XthrlenState.LoopToken

local function ExpiredTick()
    if not _G.XthrlenNotifiedPopup then
        pcall(function()
            local Msg = require("client.slua.logic.common.logic_common_msg_box")
            if Msg and Msg.Show then
                Msg.Show(1, "MOD ĐÃ HẾT HẠN! VUI LÒNG INBOX ADMIN ĐỂ GIA HẠN!\nInbox Tele  @ngocdoian", 
                function() 
                    local Web = require("client.slua.logic.url.logic_webview_sdk")
                    if Web and Web.OpenURL then Web:OpenURL("https://t.me/ngocdoian") end 
                end, 
                function() end, "INBOX CHỦ MOD", "ĐÓNG")
                _G.XthrlenNotifiedPopup = true 
            end
        end)
        
        if not _G.XthrlenNotifiedPopup then
            local okTicker, ticker = pcall(require, "common.time_ticker") 
            if okTicker and ticker and ticker.AddTimerOnce then 
                ticker.AddTimerOnce(2.0, ExpiredTick) 
            end
        end
    end
end

local function FastTick() 
    if isExpired then 
        if not _G.XthrlenNotifiedExpire then
            Notify("MOD ĐÃ HẾT HẠN! VUI LÒNG INBOX ADMIN ĐỂ GIA HẠN!\nInbox Tele  @ngocdoian")
            _G.XthrlenNotifiedExpire = true
            ExpiredTick() 
        end
        return 
    end

    if myToken ~= _G.XthrlenState.LoopToken then return end
    pcall(MainLoop) 
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.01, FastTick) 
    end 
end

if not isExpired then
    FastTick() 
    Notify("Bạn Đang Chơi Mod V2\n ĐÂY LÀ BẢN FREE NẾU BẠN KUA CỦA AI ĐÓ THÌ BẠN ĐÃ BỊ SCAM RỒI.")
else
    FastTick() 
end

local function InitAllModSystems()
    pcall(function()
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)
end

pcall(function() 
    require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems) 
end)