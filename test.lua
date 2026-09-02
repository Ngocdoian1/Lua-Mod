local function Notify(msg)
    local s = "[IPAD VIEW VIP] " .. tostring(msg)
    pcall(function() local sh = import("ScriptHelperClient") if sh and sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end)
    print(s)
end

local _slua = rawget(_G, "slua")

local function Valid(obj)
    if not obj then return false end
    if _slua and _slua.isValid then
        local ok, v = pcall(_slua.isValid, obj)
        if not ok or not v then return false end
    end
    return true
end

-- [1. CẤU HÌNH & STATE]
_G.VIPConfig = _G.VIPConfig or { IpadView = false, IpadViewVehicle = false }
_G.VIPState = _G.VIPState or { IpadViewFOV = 120, IpadViewVehicleFOV = 120, MenuInitialized = false }

-- [2. HỆ THỐNG LƯU/TẢI SETTING TỰ ĐỘNG]
local ConfigFileName = "ipad_view_setting.txt"
_G.LastConfigSaveStr = ""

local function GetConfigPaths()
    return {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. ConfigFileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. ConfigFileName,
        "ShadowTrackerExtra/Saved/Paks/" .. ConfigFileName,
        ConfigFileName
    }
end

_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nVIPConfig = {\n"
        for k, v in pairs(_G.VIPConfig) do data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n" end
        data = data .. "},\nVIPState = {\n"
        for k, v in pairs(_G.VIPState) do data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n" end
        data = data .. "}\n}"
        
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        for _, path in ipairs(GetConfigPaths()) do
            local file = io.open(path, "w")
            if file then file:write(data); file:close(); break end
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        local content = nil
        for _, path in ipairs(GetConfigPaths()) do
            local file = io.open(path, "r")
            if file then content = file:read("*a"); file:close(); break end
        end
        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.VIPConfig then for k, v in pairs(savedData.VIPConfig) do _G.VIPConfig[k] = v end end
                    if savedData.VIPState then for k, v in pairs(savedData.VIPState) do _G.VIPState[k] = v end end
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
        if okTicker and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(3.0, AutoSaveLoop) end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

-- [3. TẠO MENU CÀI ĐẶT IN-GAME]
function _G.InitModMenuTab()
    if _G.VIPState.MenuInitialized then return end
    _G.VIPState.MenuInitialized = true

    local LocUtil = _G.LocUtil or require("client.common.LocUtil")
    local FakeTextMap = {
        [999000] = " MENU IPAD VIEW VIP",
        [999001] = "TÙY CHỈNH IPAD VIEW"
    }

    if LocUtil and not LocUtil._IsIpadMenuHooked then
        local old_func = LocUtil.GetTextByID
        LocUtil.GetTextByID = function(id)
            if FakeTextMap[id] then return FakeTextMap[id] end
            if old_func then return old_func(id) end
            return ""
        end
        LocUtil._IsIpadMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.IpadMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        local StackIpad = {
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Bật Ipad View (Góc Nhìn Rộng)", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.IpadView end, SetFunc = function(c,v) _G.VIPConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   Độ Rộng FOV (90 Gốc - 120 Max)", ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 30, min = 1, max = 30, GetFunc = function() return (_G.VIPState.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.VIPState.IpadViewFOV = 90 + v return true end },

            { Key = "ModMenu_IpadVeh_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Bật Ipad View Lái Xe", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.IpadViewVehicle end, SetFunc = function(c,v) _G.VIPConfig.IpadViewVehicle = v return true end },
            { Key = "ModMenu_IpadVeh_FOV", UI = AliasMap.Slider, Text = "   Độ Rộng FOV Xe", ExpandHandle = "ModMenu_IpadVeh_Ex", MinValue = 1, MaxValue = 30, min = 1, max = 30, GetFunc = function() return (_G.VIPState.IpadViewVehicleFOV or 120) - 90 end, SetFunc = function(c,v) _G.VIPState.IpadViewVehicleFOV = 90 + v return true end }
        }

        SettingPageDefine.IpadMenu = {
            Key = "IpadMenu",
            Text = 999000, 
            UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_Ipad", Text = 999001, Stack = StackIpad }
            }
        }
        
        table.insert(SettingCatalog, 1, SettingPageDefine.IpadMenu)
        pcall(function() 
            local SettingBattleCatalog = require("client.logic.NewSetting.SettingBattleCatalog")
            table.insert(SettingBattleCatalog, 1, SettingPageDefine.IpadMenu)
        end)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsIpadMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and string.find(string.lower(config.keyName), "setting") then
                local catalog = args[1]
                if type(catalog) == "table" and catalog[1] and type(catalog[1]) == "table" and catalog[1].Key then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "IpadMenu" then hasModMenu = true; break end
                    end
                    if not hasModMenu then table.insert(catalog, 1, SettingPageDefine.IpadMenu) end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, select('#', ...)))
        end
        UIManager._IsIpadMenuHooked = true
    end
end

-- [4. VÒNG LẶP CHÍNH (LOGIC IPAD VIEW)]
local function MainLoop()
    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = Valid(pc) and pc:GetPlayerCharacterSafety() or nil

    if not Valid(localPlayer) then return end

    pcall(function()
        local isAiming = localPlayer.bIsWeaponAiming or localPlayer.bIsGunADS
        local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
        local isInVehicle = Valid(currentVehicle) or localPlayer.bIsInVehicle
        local uTPPCam = localPlayer.ThirdPersonCameraComponent
        local uVehCam = localPlayer.VehicleCameraComponent
        local camMgr = pc.PlayerCameraManager

        -- Tự động nhả góc nhìn về mặc định khi ngắm bắn
        if isAiming then
            if type(pc.FOV) == "function" then pc:FOV(0) end
            if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
            return 
        end

        if not isInVehicle then
            if _G.VIPConfig.IpadView then
                local targetTPP = _G.VIPState.IpadViewFOV or 120
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then 
                    uTPPCam.FieldOfView = targetTPP 
                end
            else
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then 
                    uTPPCam.FieldOfView = 90 
                end
            end
        end

        if isInVehicle then
            if _G.VIPConfig.IpadViewVehicle then
                local targetVeh = _G.VIPState.IpadViewVehicleFOV or 120
                if Valid(uVehCam) and uVehCam.FieldOfView ~= targetVeh then 
                    uVehCam.FieldOfView = targetVeh 
                end
                if targetVeh > 90 then
                    if type(pc.FOV) == "function" then pc:FOV(targetVeh) end
                    if Valid(camMgr) then
                        camMgr.DefaultFOV = targetVeh
                        if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetVeh) end
                    end
                end
            else
                if Valid(uVehCam) and uVehCam.FieldOfView ~= 90 then 
                    uVehCam.FieldOfView = 90 
                end
            end
        end
    end)
end

-- [5. KÍCH HOẠT HỆ THỐNG TRONG WORKER]
_G.InitModMenuTab()

_G.FastTick = function() 
    pcall(MainLoop) 
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.01, _G.FastTick) 
    end 
end
_G.FastTick()
