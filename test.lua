-- ==============================================================================
-- BẢN FULL MOD VIP DUNGCU LOGIC - PHẦN 1 (CORE, FULL CONFIG & AUTH)
-- ==============================================================================
local function Notify(msg)
    local s = "[ngocdoian VIP] " .. tostring(msg)
    pcall(function() if _G.LexusNotify then _G.LexusNotify(s) end end)
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

-- ========================================== 
-- 1. DANH SÁCH CẤU HÌNH ĐẦY ĐỦ (FULL TÍNH NĂNG NHƯ YÊU CẦU)
-- ========================================== 
_G.LexusConfig = _G.LexusConfig or { 
    -- WALL & ESP
    WallXuyenTuong = false, WhiteBody = false, EspVipPro = false, EspDistance = false, EspLoai5 = false,
    Esp7_VuKhi = true, EspBot = true, EspVehicle = false, EspBomMaster = false, EspItem_Master = false,
    EspLoai9 = false, EspAimWarning = false, EspAimWarningVisCheck = false,
    
    -- AIM TOUCH
    AimTouchEnable = false,
    AimTouchHipfire = false, AimTouchHipIgBot = false, AimTouchHipIgKnock = false, AimTouchHipVisCheck = false,
    AimTouchScopeSniper = false, AimTouchSniperIgBot = false, AimTouchSniperIgKnock = false, AimTouchSniperVisCheck = false,
    AimTouchSG = false, AimTouchSGAutoFire = false, AimTouchSGIgBot = false, AimTouchSGIgKnock = false, AimTouchSGVisCheck = false,
    AimTouchCrossbow = false,
    AutoTap = false,
    
    -- WEAPON & MAGIC
    Crosshair = false, CustomMagicBullet = false,
    
    -- IPAD VIEW & MAP
    IpadView = false, IpadViewVehicle = false, IpadViewScope = false,
    RemoveGrass = false, RemoveTrees = false, RemoveWater = false, RemoveFog = false, BlackSky = false,
    
    -- EXTRA & BẢO MẬT
    AimGrenade = false, AimMolotov = false, AimStun = false, AimSticky = false,
    FakeHWID = false
}

-- STATE CHỨA CÁC BIẾN THANH KÉO (SLIDERS) VÀ DỮ LIỆU CHẠY NGẦM
_G.LexusState = _G.LexusState or { 
    LoopToken = 0, MenuStep = 0, CustomTextData = {
        WallVis = 3, WallHid = 2, DetectRange = 400,
        AimTouchHipCond = 1, AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipSpeed = 48, AimTouchHipFOV = 15, AimTouchHipDist = 400, AimTouchHipPred = 0, AimTouchHipRecoil = 50,
        AimSnipFov = 15, AimSnipSpd = 48, AimSnipPred = 65,
        AimTouchSGBone = 2, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
        AimBowFov = 15, AimBowSpd = 48, AimBowPred = 0,
        AutoTapSpeed = 5, AutoTapForce = 35, AutoTapBone = 1, AutoTapMode = 3,
        CrosshairSize = 50, MagicHead = 0, MagicBody = 0, MagicLegs = 0,
        IpadViewFOV = 115, IpadViewVehicleFOV = 130, IpadViewScopeFOV = 15
    } 
}

-- ========================================== 
-- 2. HỆ THỐNG LƯU FILE TỰ ĐỘNG (LƯU TẤT CẢ CÔNG TẮC & THANH KÉO)
-- ========================================== 
local ConfigFileName = "ngocdoian_settings_v2.txt"
_G.LastConfigSaveStr = ""

local function GetConfigPaths(fileName)
    return {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "/Documents/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName
    }
end

_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nLexusConfig = {\n"
        for k, v in pairs(_G.LexusConfig or {}) do data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n" end
        data = data .. "},\nCustomTextData = {\n"
        if _G.LexusState and _G.LexusState.CustomTextData then
            for k, v in pairs(_G.LexusState.CustomTextData) do data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n" end
        end
        data = data .. "}\n}"
        
        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        for _, path in ipairs(GetConfigPaths(ConfigFileName)) do
            local file = io.open(path, "w")
            if file then file:write(data); file:close(); break end
        end
    end)
end

_G.LoadModSettings = function()
    pcall(function()
        local content = nil
        for _, path in ipairs(GetConfigPaths(ConfigFileName)) do
            local file = io.open(path, "r")
            if file then content = file:read("*a"); file:close(); break end
        end
        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.LexusConfig then for k, v in pairs(savedData.LexusConfig) do _G.LexusConfig[k] = v end end
                    if savedData.CustomTextData then
                        _G.LexusState.CustomTextData = _G.LexusState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do _G.LexusState.CustomTextData[k] = v end
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
        if okTicker and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(3.0, AutoSaveLoop) end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

-- ========================================== 
-- 3. HỆ THỐNG BẢO MẬT AKMOD VÀ FAKE HWID
-- ========================================== 
_G._Authenticated_ = false

_G.AkmodNotify = function(msg)
  print("[AKMOD] Notify: " .. tostring(msg))
  pcall(function()
    local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    if s3 and IngameTipsTools then
      if IngameTipsTools.BattleNormalTips then IngameTipsTools.BattleNormalTips("AKMOD: " .. msg, 2, 3) end
      if string.find(msg, "Lỗi") or string.find(msg, "thất bại") or string.find(msg, "Từ chối") then
        if IngameTipsTools.ShowMsgBox then IngameTipsTools.ShowMsgBox(1, "AKMOD Thông Báo", msg) end
      end
    end
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if s and GameplayData then
      local uPlayerController = GameplayData.GetPlayerController()
      if uPlayerController then
        local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
        if s2 and STExtraBlueprintFunctionLibrary then
          local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
          if chatComp and chatComp.AddMsgInClient then chatComp:AddMsgInClient("<ChatQuickMsg>" .. msg .. "</>") end
        end
      end
    end
  end)
end

local function ForceStart()
    _G.LexusState.LoopToken = (_G.LexusState.LoopToken or 0) + 1 
    _G.myToken = _G.LexusState.LoopToken
    if _G.InitModMenuTab then _G.InitModMenuTab() end
    if _G.FastTick then _G.FastTick() end
end

local function LoadCloud()
    if _G._Authenticated_ then return end
    local M_Manager = package.loaded["client.logic.module.ModuleManager"] or _G.ModuleManager or require("client.logic.module.ModuleManager")
    if not M_Manager then return end
    local http_manager = M_Manager.GetModule(M_Manager.CommonModuleConfig.http_manager)
    if not http_manager then return end

    local function GetUserKey()
        if Client and Client.LoadFileToString then
            local attempt1 = Client.LoadFileToString("Paks/AKMOD_VIP_KEY.txt")
            if attempt1 and attempt1 ~= "" then return attempt1:gsub("%s+", ""), "Paks/" end
            local attempt2 = Client.LoadFileToString("AKMOD_VIP_KEY.txt")
            if attempt2 and attempt2 ~= "" then return attempt2:gsub("%s+", ""), "" end
        end
        return nil, nil
    end

    local userKey, keyPath = GetUserKey()
    if not userKey or userKey == "" then _G.AkmodNotify("Loi: Khong tim thay file AKMOD_VIP_KEY.txt!"); return end

    local myUid = Client and Client.GetPhoneDeviceID and Client.GetPhoneDeviceID()
    if not myUid or myUid == "" then _G.AkmodNotify("Loi: UID khong hop le hoac game chua load xong!"); return end

    local hwid = tostring(myUid)
    local netType = (Client and Client.GetNetWorkType) and Client.GetNetWorkType() or "unknown"
    local netLabel = (netType == "Wifi" and "WiFi") or (netType == "4G" and "4G") or netType
    local apiUrl = "https://akmod.online:2053/api/check_free"
    local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
    local maxRetries = 3

    local function EngineUnpack(str)
        if not str or str == "" then return nil end
        local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        local s = str:gsub('[\r\n%s]', ''):gsub('%-', '+'):gsub('_', '/')
        local pad = #s % 4; if pad > 0 then s = s .. string.rep('=', 4 - pad) end
        local b = {}; local len = #s
        for i = 1, len, 4 do
            local c1 = b64chars:find(s:sub(i,   i),   1, true); local c2 = b64chars:find(s:sub(i+1, i+1), 1, true)
            local c3 = b64chars:find(s:sub(i+2, i+2), 1, true); local c4 = b64chars:find(s:sub(i+3, i+3), 1, true)
            if not c1 or not c2 then break end
            c1, c2 = c1 - 1, c2 - 1
            c3 = c3 and (c3 - 1) or 0; c4 = c4 and (c4 - 1) or 0
            local n = (c1 * 262144) + (c2 * 4096) + (c3 * 64) + c4
            b[#b+1] = string.char(math.floor(n / 65536) % 256)
            if s:sub(i+2, i+2) ~= '=' then b[#b+1] = string.char(math.floor(n / 256) % 256) end
            if s:sub(i+3, i+3) ~= '=' then b[#b+1] = string.char(n % 256) end
        end
        local raw = table.concat(b)
        local K = {0x7B, 0x21, 0xC5, 0xE2, 0x9A, 0x3F, 0x44, 0x10, 0xD8, 0x6C, 0xB2, 0x0E, 0x55, 0xA9, 0x71, 0x3D}
        local out = {}
        local bxor_fn = bit and bit.bxor or bit32 and bit32.bxor or function(a, x)
            local r, m = 0, 128
            while m >= 1 do
                local va, vb = (a >= m) and 1 or 0, (x >= m) and 1 or 0
                if va ~= vb then r = r + m end
                if a >= m then a = a - m end; if x >= m then x = x - m end
                m = m / 2
            end
            return r
        end
        for i = 1, #raw do
            local k = K[((i - 1) % 16) + 1]
            out[#out+1] = string.char(bxor_fn(string.byte(raw, i), k))
        end
        return table.concat(out)
    end

    local function DoRequest(retryLeft)
        if retryLeft == maxRetries then _G.AkmodNotify("Dang xac thuc key qua server... [" .. netLabel .. "]") end
        local postData = string.format("game=PUBG&user_key=%s&serial=%s", userKey, hwid)
        local _sw_r = "E9zu3xfgz7aLrjVPVPCsJmJ2jU7kLk8mV"
        local _sw = _sw_r:reverse()

        local function SimpleHMAC(msg, key)
            local keyBytes = {}
            for i = 1, #key do keyBytes[i] = string.byte(key, i) end
            local kLen = #keyBytes; local h = 5381
            for i = 1, #msg do
                local kb = keyBytes[((i-1) % kLen) + 1]
                h = ((h * 31) + string.byte(msg, i) + kb) % 4294967296
            end
            local h2 = 0x12345678
            for i = #msg, 1, -1 do
                local kb = keyBytes[((#msg - i) % kLen) + 1]
                h2 = ((h2 * 37) + string.byte(msg, i) + kb) % 4294967296
            end
            return string.format("%08x%08x", h, h2)
        end

        http_manager:Post(apiUrl, headers, postData, nil, function(success, data, content, result)
            if not success then
                if retryLeft > 0 then
                    local delay = 2 ^ (maxRetries - retryLeft + 1)
                    _G.AkmodNotify("Ket noi gap su co [" .. netLabel .. "] (Ma: " .. tostring(result or "NIL") .. "). Thu lai sau " .. delay .. "s...")
                    local ok_t, time_ticker = pcall(require, "common.time_ticker")
                    if ok_t and time_ticker and time_ticker.AddTimerOnce then time_ticker.AddTimerOnce(delay, function() DoRequest(retryLeft - 1) end) else DoRequest(retryLeft - 1) end
                else _G.AkmodNotify("Ket noi that bai. Ma loi: " .. tostring(result or "NIL")) end
                return
            end

            if not data or data == "" then _G.AkmodNotify("Tu choi: Khong co du lieu tra ve"); return end

            local rawData = data
            if not data:find('{"status"', 1, true) then
                local unpacked = EngineUnpack(data)
                if unpacked and unpacked:find('{"status"', 1, true) then rawData = unpacked end
            end

            local sData = tostring(rawData)
            local statusVal = sData:match('"status"%s*:%s*(true)') or sData:match('"status"%s*:%s*(1[^%d])')
            local reasonVal = sData:match('"reason"%s*:%s*"([^"]+)"')

            if statusVal then
                local sigVal = sData:match('"sig"%s*:%s*"([a-f0-9]+)"')
                local tokenVal = sData:match('"token"%s*:%s*"([a-f0-9]+)"')
                local rngVal = sData:match('"rng"%s*:%s*(%d+)')
                local sigOk = false
                if sigVal and tokenVal and rngVal then
                    local expectedSig = SimpleHMAC(tokenVal .. rngVal .. hwid, _sw)
                    if sigVal:sub(1, 16) == expectedSig:sub(1, 16) then sigOk = true end
                end

                if not sigOk then _G.AkmodNotify("Canh bao: Phat hien gia mao! (sig invalid)"); _G._Authenticated_ = false; return end

                _G._Authenticated_ = true                
                ForceStart()
                _G.AkmodNotify("Xac thuc key thanh cong! Chao mung ban.")
            else
                _G.AkmodNotify("Xac thuc key that bai: " .. (reasonVal or "Key khong hop le"))
            end
        end, 30)
    end
    DoRequest(maxRetries)
end

pcall(function() 
    local ok_t, time_ticker = pcall(require, "common.time_ticker")
    if ok_t and time_ticker and time_ticker.AddTimerOnce then
        time_ticker.AddTimerOnce(1.0, LoadCloud) 
    end
end)

-- HOOK SPOOFER ĐỔI HWID ẢO
pcall(function()
    local SystemLib = import("KismetSystemLibrary")
    if SystemLib and not _G.FakeHWID_Hooked then
        _G.Original_GetDeviceId = SystemLib.GetDeviceId
        SystemLib.GetDeviceId = function(...)
            if _G.LexusConfig.FakeHWID then
                if not _G.FakeHWID_String then
                    local chars = "0123456789abcdef"
                    local hwid = ""
                    for i = 1, 32 do hwid = hwid .. chars:sub(math.random(1, 16), math.random(1, 16)) end
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

---- ==============================================================================
-- PHẦN 2: BẢNG CHÀO MỪNG & GIAO DIỆN MENU VIP 5 TAB (CHUẨN 100% DANH SÁCH)
-- ==============================================================================
local function ShowLexusVIPMenu() 
    if _G.LexusMenuAlreadyShown then return end
    if _G.LexusState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_Welcome()
            Msg.Show(1, "CHÀO MỪNG ĐẾN VỚI VIP MOD", "Menu đã được tích hợp thẳng vào Cài Đặt (Răng cưa) của game.\nBật đúng chức năng cần thiết để trải nghiệm mượt mà nhất!", 
            function() 
                _G.InitModMenuTab()
                _G.LexusMenuAlreadyShown = true
                _G.LexusState.MenuStep = 99
            end, function() end, "MỞ MENU TRONG GAME", "MỞ MENU TRONG GAME")
        end
        _G.LexusState.MenuStep = 1
        Step_Welcome()
    end)
end

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    local LocUtil = _G.LocUtil or (pcall(require, "client.common.LocUtil") and require("client.common.LocUtil"))
    local FakeTextMap = { [999000] = " NGOCDOIAN VIP" }
    if LocUtil and not LocUtil._IsMenuHooked then
        local old_func = LocUtil.GetTextByID
        LocUtil.GetTextByID = function(id) if FakeTextMap[id] then return FakeTextMap[id] end if old_func then return old_func(id) end return "" end
        LocUtil._IsMenuHooked = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        -- TAB 1: WALL & ESP
        local StackWallESP = {
            { Key = "M_Wall_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ BẬT WALL", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.WallXuyenTuong end, SetFunc = function(c,v) _G.LexusConfig.WallXuyenTuong = v return true end },
            { Key = "M_WallVis", UI = AliasMap.Slider, Text = "   Màu nhìn thấy (1-9)", ExpandHandle = "M_Wall_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.LexusState.CustomTextData.WallVis end, SetFunc = function(c,v) _G.LexusState.CustomTextData.WallVis = v return true end },
            { Key = "M_WallHid", UI = AliasMap.Slider, Text = "   Màu khuất tường (1-9)", ExpandHandle = "M_Wall_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.LexusState.CustomTextData.WallHid end, SetFunc = function(c,v) _G.LexusState.CustomTextData.WallHid = v return true end },
            { Key = "M_White", UI = AliasMap.Switcher, Text = "NGƯỜI MÀU TRẮNG", GetFunc = function() return _G.LexusConfig.WhiteBody end, SetFunc = function(c,v) _G.LexusConfig.WhiteBody = v return true end },
            { Key = "M_EspHP", UI = AliasMap.Switcher, Text = "ESP THANH MÁU", GetFunc = function() return _G.LexusConfig.Esp9_HP end, SetFunc = function(c,v) _G.LexusConfig.Esp9_HP = v return true end },
            { Key = "M_EspDist", UI = AliasMap.Switcher, Text = "ESP KHOẢNG CÁCH", GetFunc = function() return _G.LexusConfig.Esp9_Distance end, SetFunc = function(c,v) _G.LexusConfig.Esp9_Distance = v return true end },
            { Key = "M_EspBox", UI = AliasMap.Switcher, Text = "ESP BOX", GetFunc = function() return _G.LexusConfig.EspLoai5 end, SetFunc = function(c,v) _G.LexusConfig.EspLoai5 = v return true end },
            { Key = "M_EspWep", UI = AliasMap.Switcher, Text = "HIỆN SÚNG ĐỊCH CẦM", GetFunc = function() return _G.LexusConfig.Esp7_VuKhi end, SetFunc = function(c,v) _G.LexusConfig.Esp7_VuKhi = v return true end },
            { Key = "M_EspBot", UI = AliasMap.Switcher, Text = "PHÂN BIỆT BOT", GetFunc = function() return _G.LexusConfig.EspBot end, SetFunc = function(c,v) _G.LexusConfig.EspBot = v return true end },
            { Key = "M_EspVeh", UI = AliasMap.Switcher, Text = "ESP PHƯƠNG TIỆN", GetFunc = function() return _G.LexusConfig.EspVehicle end, SetFunc = function(c,v) _G.LexusConfig.EspVehicle = v return true end },
            { Key = "M_EspBomb", UI = AliasMap.Switcher, Text = "ESP BOM", GetFunc = function() return _G.LexusConfig.EspBomMaster end, SetFunc = function(c,v) _G.LexusConfig.EspBomMaster = v return true end },
            { Key = "M_EspItem", UI = AliasMap.Switcher, Text = "ESP ITEM", GetFunc = function() return _G.LexusConfig.EspItem_Master end, SetFunc = function(c,v) _G.LexusConfig.EspItem_Master = v return true end },
            { Key = "M_EspInfo", UI = AliasMap.Switcher, Text = "ESP INFO V1 & V2", GetFunc = function() return _G.LexusConfig.EspLoai9 end, SetFunc = function(c,v) _G.LexusConfig.EspLoai9 = v return true end },
            { Key = "M_RadarDist", UI = AliasMap.Slider, Text = "PHẠM VI PHÁT HIỆN ĐỊCH (1-400m)", MinValue = 1, MaxValue = 400, GetFunc = function() return _G.LexusState.CustomTextData.DetectRange end, SetFunc = function(c,v) _G.LexusState.CustomTextData.DetectRange = v return true end },
            { Key = "M_AimWarn_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ CẢNH BÁO ĐỊCH ĐANG NGẮM", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.EspAimWarning end, SetFunc = function(c,v) _G.LexusConfig.EspAimWarning = v return true end },
            { Key = "M_WarnVis", UI = AliasMap.Switcher, Text = "   CHECK VẬT CẢN (TƯỜNG)", ExpandHandle = "M_AimWarn_Ex", GetFunc = function() return _G.LexusConfig.EspAimWarningVisCheck end, SetFunc = function(c,v) _G.LexusConfig.EspAimWarningVisCheck = v return true end }
        }

        -- TAB 2: AIM TOUCH
        local StackAimTouch = {
            { Key = "AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ BẬT AIM TOUCH (TÂM TRẮNG)", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.LexusConfig.AimTouchHipfire = v return true end },
            { Key = "AT_Mode", UI = AliasMap.Slider, Text = "   CHẾ ĐỘ AIMBOT (1:Bắn 2:Ngắm 3:Luôn)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipCond end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipCond = v return true end },
            { Key = "AT_Prio", UI = AliasMap.Slider, Text = "   ƯU TIÊN (1:Tâm 2:Gần 3:HP)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipPrio end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipPrio = v return true end },
            { Key = "AT_Bone", UI = AliasMap.Slider, Text = "   VỊ TRÍ (1:Đầu 2:Ngực 3:Bụng)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipBone end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipBone = v return true end },
            { Key = "AT_IgBot", UI = AliasMap.Switcher, Text = "   BỎ QUA BOT", ExpandHandle = "AT_Hip_Ex", GetFunc = function() return _G.LexusConfig.AimTouchHipIgBot end, SetFunc = function(c,v) _G.LexusConfig.AimTouchHipIgBot = v return true end },
            { Key = "AT_IgKnock", UI = AliasMap.Switcher, Text = "   BỎ QUA KNOCK", ExpandHandle = "AT_Hip_Ex", GetFunc = function() return _G.LexusConfig.AimTouchHipIgKnock end, SetFunc = function(c,v) _G.LexusConfig.AimTouchHipIgKnock = v return true end },
            { Key = "AT_Vis", UI = AliasMap.Switcher, Text = "   CHECK VẬT CẢN", ExpandHandle = "AT_Hip_Ex", GetFunc = function() return _G.LexusConfig.AimTouchHipVisCheck end, SetFunc = function(c,v) _G.LexusConfig.AimTouchHipVisCheck = v return true end },
            { Key = "AT_Spd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ AIMBOT", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipSpeed end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipSpeed = v return true end },
            { Key = "AT_Fov", UI = AliasMap.Slider, Text = "   FOV TÂM TRẮNG", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipFOV end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipFOV = v return true end },
            { Key = "AT_Dist", UI = AliasMap.Slider, Text = "   KHOẢNG CÁCH", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 400, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipDist end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipDist = v return true end },
            { Key = "AT_Pred", UI = AliasMap.Slider, Text = "   DỰ ĐOÁN HƯỚNG", ExpandHandle = "AT_Hip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipPred end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipPred = v return true end },
            { Key = "AT_Recoil", UI = AliasMap.Slider, Text = "   TỰ ĐỘNG GHÌM TÂM", ExpandHandle = "AT_Hip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchHipRecoil end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchHipRecoil = v return true end },

            { Key = "AT_Snip_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SNIP AUTO AIM ĐẦU", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.LexusConfig.AimTouchScopeSniper = v return true end },
            { Key = "AT_SnipFov", UI = AliasMap.Slider, Text = "   FOV SCOPE", ExpandHandle = "AT_Snip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimSnipFov end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimSnipFov = v return true end },
            { Key = "AT_SnipSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ", ExpandHandle = "AT_Snip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimSnipSpd end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimSnipSpd = v return true end },
            { Key = "AT_SnipPred", UI = AliasMap.Slider, Text = "   DỰ ĐOÁN HƯỚNG", ExpandHandle = "AT_Snip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimSnipPred end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimSnipPred = v return true end },

            { Key = "AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AIM SHOTGUN", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.AimTouchSG end, SetFunc = function(c,v) _G.LexusConfig.AimTouchSG = v return true end },
            { Key = "AT_SGAuto", UI = AliasMap.Switcher, Text = "   TỰ ĐỘNG BẮN", ExpandHandle = "AT_SG_Ex", GetFunc = function() return _G.LexusConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.LexusConfig.AimTouchSGAutoFire = v return true end },
            { Key = "AT_SGBone", UI = AliasMap.Slider, Text = "   VỊ TRÍ AIM", ExpandHandle = "AT_SG_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGBone end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGBone = v return true end },
            { Key = "AT_SGVis", UI = AliasMap.Switcher, Text = "   CHECK TƯỜNG", ExpandHandle = "AT_SG_Ex", GetFunc = function() return _G.LexusConfig.AimTouchSGVisCheck end, SetFunc = function(c,v) _G.LexusConfig.AimTouchSGVisCheck = v return true end },
            { Key = "AT_SGSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ AIMBOT", ExpandHandle = "AT_SG_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGSpeed end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGSpeed = v return true end },
            { Key = "AT_SGDist", UI = AliasMap.Slider, Text = "   KHOẢNG CÁCH", ExpandHandle = "AT_SG_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGDist end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGDist = v return true end },
            { Key = "AT_SGFov", UI = AliasMap.Slider, Text = "   FOV AIMBOT", ExpandHandle = "AT_SG_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimTouchSGFOV end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimTouchSGFOV = v return true end },

            { Key = "AT_Bow_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AIM NỎ & CUNG TÊN", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.AimTouchCrossbow end, SetFunc = function(c,v) _G.LexusConfig.AimTouchCrossbow = v return true end },
            { Key = "AT_BowFov", UI = AliasMap.Slider, Text = "   FOV AIMBOT", ExpandHandle = "AT_Bow_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimBowFov end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimBowFov = v return true end },
            { Key = "AT_BowSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ AIMBOT", ExpandHandle = "AT_Bow_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimBowSpd end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimBowSpd = v return true end },
            { Key = "AT_BowPred", UI = AliasMap.Slider, Text = "   DỰ ĐOÁN HƯỚNG", ExpandHandle = "AT_Bow_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AimBowPred end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AimBowPred = v return true end },

            { Key = "AT_Tap_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AUTO TAP", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.AutoTap end, SetFunc = function(c,v) _G.LexusConfig.AutoTap = v return true end },
            { Key = "AT_TapSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ TAP (1-20)", ExpandHandle = "AT_Tap_Ex", MinValue = 1, MaxValue = 20, GetFunc = function() return _G.LexusState.CustomTextData.AutoTapSpeed end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AutoTapSpeed = v return true end },
            { Key = "AT_TapHipScope", UI = AliasMap.Slider, Text = "   CHẾ ĐỘ (1:Tâm 2:Scope 3:Cả)", ExpandHandle = "AT_Tap_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AutoTapMode end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AutoTapMode = v return true end },
            { Key = "AT_TapRecoil", UI = AliasMap.Slider, Text = "   LỰC GHÌM TÂM", ExpandHandle = "AT_Tap_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.AutoTapForce end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AutoTapForce = v return true end },
            { Key = "AT_TapBone", UI = AliasMap.Slider, Text = "   VỊ TRÍ AIM", ExpandHandle = "AT_Tap_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.LexusState.CustomTextData.AutoTapBone end, SetFunc = function(c,v) _G.LexusState.CustomTextData.AutoTapBone = v return true end }
        }

        -- TAB 3: WEAPON & MAGIC
        local StackWepMagic = {
            { Key = "WM_Crosshair", UI = AliasMap.Slider, Text = "TÂM NHỎ", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.CrosshairSize end, SetFunc = function(c,v) _G.LexusState.CustomTextData.CrosshairSize = v return true end },
            { Key = "WM_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ MAGIC BULLET", ExpandIndex = 0, GetFunc = function() return _G.LexusConfig.CustomMagicBullet end, SetFunc = function(c,v) _G.LexusConfig.CustomMagicBullet = v return true end },
            { Key = "WM_MagicH", UI = AliasMap.Slider, Text = "   MAGIC ĐẦU %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.MagicHead end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicHead = v return true end },
            { Key = "WM_MagicB", UI = AliasMap.Slider, Text = "   MAGIC THÂN %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.MagicBody end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicBody = v return true end },
            { Key = "WM_MagicL", UI = AliasMap.Slider, Text = "   MAGIC CHÂN %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.LexusState.CustomTextData.MagicLegs end, SetFunc = function(c,v) _G.LexusState.CustomTextData.MagicLegs = v return true end }
        }

        -- TAB 4: IPAD VIEW & MAP
        local StackIpadMap = {
            { Key = "IM_Ipad", UI = AliasMap.Slider, Text = "IPAD VIEW", MinValue = 90, MaxValue = 150, GetFunc = function() return _G.LexusState.CustomTextData.IpadViewFOV end, SetFunc = function(c,v) _G.LexusState.CustomTextData.IpadViewFOV = v return true end },
            { Key = "IM_IpadVeh", UI = AliasMap.Slider, Text = "IPAD VIEW XE", MinValue = 90, MaxValue = 150, GetFunc = function() return _G.LexusState.CustomTextData.IpadViewVehicleFOV end, SetFunc = function(c,v) _G.LexusState.CustomTextData.IpadViewVehicleFOV = v return true end },
            { Key = "IM_IpadScope", UI = AliasMap.Slider, Text = "IPAD VIEW SCOPE", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.LexusState.CustomTextData.IpadViewScopeFOV end, SetFunc = function(c,v) _G.LexusState.CustomTextData.IpadViewScopeFOV = v return true end },
            { Key = "IM_NoGrass", UI = AliasMap.Switcher, Text = "XÓA CỎ", GetFunc = function() return _G.LexusConfig.RemoveGrass end, SetFunc = function(c,v) _G.LexusConfig.RemoveGrass = v return true end },
            { Key = "IM_NoTree", UI = AliasMap.Switcher, Text = "XÓA CÂY", GetFunc = function() return _G.LexusConfig.RemoveTrees end, SetFunc = function(c,v) _G.LexusConfig.RemoveTrees = v return true end },
            { Key = "IM_NoWater", UI = AliasMap.Switcher, Text = "XÓA NƯỚC", GetFunc = function() return _G.LexusConfig.RemoveWater end, SetFunc = function(c,v) _G.LexusConfig.RemoveWater = v return true end },
            { Key = "IM_NoFog", UI = AliasMap.Switcher, Text = "XÓA SƯƠNG MÙ", GetFunc = function() return _G.LexusConfig.RemoveFog end, SetFunc = function(c,v) _G.LexusConfig.RemoveFog = v return true end },
            { Key = "IM_BlackSky", UI = AliasMap.Switcher, Text = "TRỜI ĐEN", GetFunc = function() return _G.LexusConfig.BlackSky end, SetFunc = function(c,v) _G.LexusConfig.BlackSky = v return true end }
        }

        -- TAB 5: EXTRA FEATURE
        local StackExtra = {
            { Key = "EX_Grenade", UI = AliasMap.Switcher, Text = "AIM BOM NỔ (60m)", GetFunc = function() return _G.LexusConfig.AimGrenade end, SetFunc = function(c,v) _G.LexusConfig.AimGrenade = v return true end },
            { Key = "EX_Molotov", UI = AliasMap.Switcher, Text = "AIM BOM LỬA (60m)", GetFunc = function() return _G.LexusConfig.AimMolotov end, SetFunc = function(c,v) _G.LexusConfig.AimMolotov = v return true end },
            { Key = "EX_Stun", UI = AliasMap.Switcher, Text = "AIM BOM CHOÁNG (60m)", GetFunc = function() return _G.LexusConfig.AimStun end, SetFunc = function(c,v) _G.LexusConfig.AimStun = v return true end },
            { Key = "EX_Sticky", UI = AliasMap.Switcher, Text = "AIM BOM DÍNH (60m)", GetFunc = function() return _G.LexusConfig.AimSticky end, SetFunc = function(c,v) _G.LexusConfig.AimSticky = v return true end }
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu", Text = 999000, UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_WallESP", Text = "WALL & ESP", Stack = StackWallESP },
                { Key = "Cat_AimTouch", Text = "AIM TOUCH", Stack = StackAimTouch },
                { Key = "Cat_WepMagic", Text = "WEAPON & MAGIC", Stack = StackWepMagic },
                { Key = "Cat_IpadMap", Text = "IPAD VIEW & MAP", Stack = StackIpadMap },
                { Key = "Cat_Extra", Text = "EXTRA FEATURE", Stack = StackExtra }
            }
        }
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and string.find(string.lower(config.keyName), "setting_main") then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then hasModMenu = true break end
                    end
                    if not hasModMenu then table.insert(catalog, 1, SettingPageDefine.ModMenu) end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, select('#', ...)))
        end
        UIManager._IsModMenuHooked = true
    end
end

-- ==============================================================================
-- PHẦN 3: LÕI LOGIC ĐỒ HỌA (CHAMS 9 MÀU, IPAD VIEW, XÓA MÔI TRƯỜNG)
-- ==============================================================================
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 0.5) then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            local isPendingKill = false
            pcall(function() if type(cachedMesh.IsPendingKill) == "function" then isPendingKill = cachedMesh:IsPendingKill() end end)
            if Valid(cachedMesh) and not isPendingKill then table.insert(validMeshes, cachedMesh) end
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
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    if markData then markData.CachedMeshes = meshes; markData.CachedMeshTime = curTime end
    return meshes
end

local function GetChamsColorRGB(choice)
    if choice == 1 then return 255, 255, 255 end 
    if choice == 2 then return 255, 0, 0 end     
    if choice == 3 then return 255, 255, 0 end   
    if choice == 4 then return 0, 255, 0 end     
    if choice == 5 then return 0, 255, 255 end   
    if choice == 6 then return 0, 0, 255 end     
    if choice == 7 then return 128, 0, 128 end   
    if choice == 8 then return 255, 105, 180 end 
    if choice == 9 then return 0, 0, 0 end       
    return 255, 0, 0 
end

local function ApplyChams(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local hidChoice = _G.LexusState.CustomTextData.WallHid or 2
        local visChoice = _G.LexusState.CustomTextData.WallVis or 3
        
        local currentHash = string.format("%d_%d", hidChoice, visChoice)
        local colorChanged = (markData.LastChamsHash ~= currentHash)
        markData.LastChamsHash = currentHash

        local hR, hG, hB = GetChamsColorRGB(hidChoice)
        local vR, vG, vB = GetChamsColorRGB(visChoice)

        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        local glowIntensity = 80.0 
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass((vR/255)*glowIntensity, (vG/255)*glowIntensity, (vB/255)*glowIntensity, 1.0) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs = markData.MIDs or {}

        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "Mesh_" .. tostring(meshIndex)
                markData.MIDs[compKey] = markData.MIDs[compKey] or {}
                
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
                    
                    local currentCached = markData.MIDs[compKey][i]
                    local needUpdateColor = false
                    
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then 
                            markData.MIDs[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then needUpdateColor = true end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("MainColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, visColor) end
                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, 4.0) end
                    end
                end)
            end
        end
        markData.ChamsApplied = true
    end)
end

local function UndoChams(enemy, markData)
    pcall(function()
        if markData.ChamsApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function() comp.PrimitiveShadingStrategy = 0; comp.ShadingRate = 1 end)
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then baseMat.bDisableDepthTest = false; baseMat.BlendMode = 1 end
                        end
                    end
                    pcall(function() if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false) end end)
                end
            end
            markData.ChamsApplied = false
            markData.LastChamsHash = ""
            if markData.MIDs then markData.MIDs = nil end
        end
    end)
end

-- ==========================================
-- LOGIC CẬP NHẬT MÔI TRƯỜNG & ĐỒ HỌA
-- ==========================================
_G.LastGraphicsState = _G.LastGraphicsState or {}

local function UpdateEnvironment()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if not gi then return end

        if _G.LexusConfig.RemoveGrass and not _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "0")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            _G.LastGraphicsState.RemoveGrass = true
        elseif not _G.LexusConfig.RemoveGrass and _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "1")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
            _G.LastGraphicsState.RemoveGrass = false
        end

        if _G.LexusConfig.RemoveTrees and not _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "0")
            gi:ExecuteCMD("r.Foliage.DensityScale", "0")
            gi:ExecuteCMD("r.DisableTreeRender", "1")
            _G.LastGraphicsState.RemoveTrees = true
        elseif not _G.LexusConfig.RemoveTrees and _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "1")
            gi:ExecuteCMD("r.Foliage.DensityScale", "1")
            gi:ExecuteCMD("r.DisableTreeRender", "0")
            _G.LastGraphicsState.RemoveTrees = false
        end
        
        if _G.LexusConfig.RemoveFog and not _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "0")           
            gi:ExecuteCMD("r.VolumetricFog", "0") 
            _G.LastGraphicsState.RemoveFog = true
        elseif not _G.LexusConfig.RemoveFog and _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "1")           
            gi:ExecuteCMD("r.VolumetricFog", "1") 
            _G.LastGraphicsState.RemoveFog = false
        end
        
        if _G.LexusConfig.BlackSky and not _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
            _G.LastGraphicsState.BlackSky = true
        elseif not _G.LexusConfig.BlackSky and _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
            _G.LastGraphicsState.BlackSky = false
        end

        if _G.LexusConfig.WhiteBody and not _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
            gi:ExecuteCMD("r.CharacterDiffusePower", "5")
            _G.LastGraphicsState.WhiteBody = true
        elseif not _G.LexusConfig.WhiteBody and _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
            gi:ExecuteCMD("r.CharacterDiffusePower", "1")
            _G.LastGraphicsState.WhiteBody = false
        end
        
        if _G.LexusConfig.RemoveWater and not _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "0")
            _G.LastGraphicsState.RemoveWater = true
        elseif not _G.LexusConfig.RemoveWater and _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "1")
            _G.LastGraphicsState.RemoveWater = false
        end
    end)
end

-- ==========================================
-- LOGIC IPAD VIEW 3 CHẾ ĐỘ
-- ==========================================
local function UpdateIpadView(localPlayer, pc)
    pcall(function()
        if not Valid(localPlayer) or not Valid(pc) then return end
        
        local isAiming = localPlayer.bIsWeaponAiming or localPlayer.bIsGunADS
        local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
        local isInVehicle = Valid(currentVehicle) or localPlayer.bIsInVehicle
        local uTPPCam = localPlayer.ThirdPersonCameraComponent
        local uVehCam = localPlayer.VehicleCameraComponent
        local camMgr = pc.PlayerCameraManager

        if isAiming then
            if _G.LexusConfig.IpadViewScope and _G.LexusState.CustomTextData then
                local targetScope = _G.LexusState.CustomTextData.IpadViewScopeFOV or 15
                if type(pc.FOV) == "function" then pc:FOV(targetScope) end
                if Valid(camMgr) then
                    camMgr.DefaultFOV = targetScope
                    if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetScope) end
                end
            else
                if type(pc.FOV) == "function" then pc:FOV(0) end
                if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
            end
            return 
        end

        if not isInVehicle or not _G.LexusConfig.IpadViewVehicle then
            if type(pc.FOV) == "function" then pc:FOV(0) end
            if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
        end

        if not isInVehicle then
            if _G.LexusConfig.IpadView then
                local targetTPP = _G.LexusState.CustomTextData.IpadViewFOV or 115
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            else
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end

        if isInVehicle then
            if _G.LexusConfig.IpadViewVehicle then
                local targetVeh = _G.LexusState.CustomTextData.IpadViewVehicleFOV or 130
                if Valid(uVehCam) and uVehCam.FieldOfView ~= targetVeh then uVehCam.FieldOfView = targetVeh end
                if targetVeh > 90 then
                    if type(pc.FOV) == "function" then pc:FOV(targetVeh) end
                    if Valid(camMgr) then
                        camMgr.DefaultFOV = targetVeh
                        if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetVeh) end
                    end
                end
            else
                if Valid(uVehCam) and uVehCam.FieldOfView ~= 90 then uVehCam.FieldOfView = 90 end
            end
        end
    end)
end
-- ==============================================================================
-- PHẦN 3: LÕI LOGIC ĐỒ HỌA (CHAMS XUYÊN TƯỜNG, IPAD VIEW, MÔI TRƯỜNG)
-- ==============================================================================

local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    -- Tối ưu: Chỉ quét lại Mesh mỗi 0.5s để tiết kiệm CPU, tránh văng game
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 0.5) then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            local isPendingKill = false
            pcall(function() if type(cachedMesh.IsPendingKill) == "function" then isPendingKill = cachedMesh:IsPendingKill() end end)
            if Valid(cachedMesh) and not isPendingKill then table.insert(validMeshes, cachedMesh) end
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
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    if markData then markData.CachedMeshes = meshes; markData.CachedMeshTime = curTime end
    return meshes
end

local function GetChamsColorRGB(choice)
    if choice == 1 then return 255, 255, 255 end -- 1. Trắng
    if choice == 2 then return 255, 0, 0 end     -- 2. Đỏ
    if choice == 3 then return 255, 255, 0 end   -- 3. Vàng
    if choice == 4 then return 0, 255, 0 end     -- 4. Lục
    if choice == 5 then return 0, 255, 255 end   -- 5. Ngọc
    if choice == 6 then return 0, 0, 255 end     -- 6. Dương
    if choice == 7 then return 128, 0, 128 end   -- 7. Tím
    if choice == 8 then return 255, 105, 180 end -- 8. Hồng
    if choice == 9 then return 0, 0, 0 end       -- 9. Đen
    return 255, 0, 0 -- Mặc định Đỏ
end

_G.ApplyChams = function(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local hidChoice = _G.LexusState.CustomTextData.WallHid or 2
        local visChoice = _G.LexusState.CustomTextData.WallVis or 3
        
        local currentHash = string.format("%d_%d", hidChoice, visChoice)
        local colorChanged = (markData.LastChamsHash ~= currentHash)
        markData.LastChamsHash = currentHash

        local hR, hG, hB = GetChamsColorRGB(hidChoice)
        local vR, vG, vB = GetChamsColorRGB(visChoice)

        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        local glowIntensity = 80.0 
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass((vR/255)*glowIntensity, (vG/255)*glowIntensity, (vB/255)*glowIntensity, 1.0) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs = markData.MIDs or {}

        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "Mesh_" .. tostring(meshIndex)
                markData.MIDs[compKey] = markData.MIDs[compKey] or {}
                
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
                    
                    local currentCached = markData.MIDs[compKey][i]
                    local needUpdateColor = false
                    
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then 
                            markData.MIDs[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then needUpdateColor = true end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("MainColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, visColor) end
                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, 4.0) end
                    end
                end)
            end
        end
        markData.ChamsApplied = true
    end)
end

_G.UndoChams = function(enemy, markData)
    pcall(function()
        if markData.ChamsApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function() comp.PrimitiveShadingStrategy = 0; comp.ShadingRate = 1 end)
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then baseMat.bDisableDepthTest = false; baseMat.BlendMode = 1 end
                        end
                    end
                    pcall(function() if comp.SetDrawIdeaOutline then comp:SetDrawIdeaOutline(false) end end)
                end
            end
            markData.ChamsApplied = false
            markData.LastChamsHash = ""
            if markData.MIDs then markData.MIDs = nil end
        end
    end)
end

-- ==========================================
-- LOGIC CẬP NHẬT MÔI TRƯỜNG & ĐỒ HỌA
-- ==========================================
_G.LastGraphicsState = _G.LastGraphicsState or {}

_G.UpdateEnvironment = function()
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if not gi then return end

        if _G.LexusConfig.RemoveGrass and not _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "0")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            _G.LastGraphicsState.RemoveGrass = true
        elseif not _G.LexusConfig.RemoveGrass and _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "1")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
            _G.LastGraphicsState.RemoveGrass = false
        end

        if _G.LexusConfig.RemoveTrees and not _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "0")
            gi:ExecuteCMD("r.Foliage.DensityScale", "0")
            gi:ExecuteCMD("r.DisableTreeRender", "1")
            _G.LastGraphicsState.RemoveTrees = true
        elseif not _G.LexusConfig.RemoveTrees and _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "1")
            gi:ExecuteCMD("r.Foliage.DensityScale", "1")
            gi:ExecuteCMD("r.DisableTreeRender", "0")
            _G.LastGraphicsState.RemoveTrees = false
        end
        
        if _G.LexusConfig.RemoveFog and not _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "0")           
            gi:ExecuteCMD("r.VolumetricFog", "0") 
            _G.LastGraphicsState.RemoveFog = true
        elseif not _G.LexusConfig.RemoveFog and _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "1")           
            gi:ExecuteCMD("r.VolumetricFog", "1") 
            _G.LastGraphicsState.RemoveFog = false
        end
        
        if _G.LexusConfig.BlackSky and not _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
            _G.LastGraphicsState.BlackSky = true
        elseif not _G.LexusConfig.BlackSky and _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
            _G.LastGraphicsState.BlackSky = false
        end

        if _G.LexusConfig.WhiteBody and not _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
            gi:ExecuteCMD("r.CharacterDiffusePower", "5")
            _G.LastGraphicsState.WhiteBody = true
        elseif not _G.LexusConfig.WhiteBody and _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
            gi:ExecuteCMD("r.CharacterDiffusePower", "1")
            _G.LastGraphicsState.WhiteBody = false
        end
        
        if _G.LexusConfig.RemoveWater and not _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "0")
            _G.LastGraphicsState.RemoveWater = true
        elseif not _G.LexusConfig.RemoveWater and _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "1")
            _G.LastGraphicsState.RemoveWater = false
        end
    end)
end

-- ==========================================
-- LOGIC IPAD VIEW 3 CHẾ ĐỘ CHUẨN XÁC
-- ==========================================
_G.UpdateIpadView = function(localPlayer, pc)
    pcall(function()
        if not Valid(localPlayer) or not Valid(pc) then return end
        
        local isAiming = localPlayer.bIsWeaponAiming or localPlayer.bIsGunADS
        local currentVehicle = localPlayer.CurrentVehicle or (type(localPlayer.GetVehicle) == "function" and localPlayer:GetVehicle())
        local isInVehicle = Valid(currentVehicle) or localPlayer.bIsInVehicle
        local uTPPCam = localPlayer.ThirdPersonCameraComponent
        local uVehCam = localPlayer.VehicleCameraComponent
        local camMgr = pc.PlayerCameraManager

        -- 1. Khi mở ngắm (Scope)
        if isAiming then
            if _G.LexusConfig.IpadViewScope and _G.LexusState.CustomTextData then
                local targetScope = _G.LexusState.CustomTextData.IpadViewScopeFOV or 15
                if type(pc.FOV) == "function" then pc:FOV(targetScope) end
                if Valid(camMgr) then
                    camMgr.DefaultFOV = targetScope
                    if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetScope) end
                end
            else
                if type(pc.FOV) == "function" then pc:FOV(0) end
                if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
            end
            return 
        end

        -- Phục hồi FOV gốc khi nhả ngắm
        if not isInVehicle or not _G.LexusConfig.IpadViewVehicle then
            if type(pc.FOV) == "function" then pc:FOV(0) end
            if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
        end

        -- 2. Đi bộ (TPP Cam)
        if not isInVehicle then
            if _G.LexusConfig.IpadView and _G.LexusState.CustomTextData then
                local targetTPP = _G.LexusState.CustomTextData.IpadViewFOV or 115
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            else
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end

        -- 3. Trên xe (Vehicle Cam)
        if isInVehicle then
            if _G.LexusConfig.IpadViewVehicle and _G.LexusState.CustomTextData then
                local targetVeh = _G.LexusState.CustomTextData.IpadViewVehicleFOV or 130
                if Valid(uVehCam) and uVehCam.FieldOfView ~= targetVeh then uVehCam.FieldOfView = targetVeh end
                if targetVeh > 90 then
                    if type(pc.FOV) == "function" then pc:FOV(targetVeh) end
                    if Valid(camMgr) then
                        camMgr.DefaultFOV = targetVeh
                        if type(camMgr.SetFOV) == "function" then camMgr:SetFOV(targetVeh) end
                    end
                end
            else
                if Valid(uVehCam) and uVehCam.FieldOfView ~= 90 then uVehCam.FieldOfView = 90 end
            end
        end
    end)
end
-- ==============================================================================
-- PHẦN 4: LÕI AIM TOUCH, DỰ ĐOÁN HƯỚNG BẮN & AUTO TAP CHUYÊN SÂU
-- ==============================================================================

local function GetEnemyTargetsFromActors(radius, player)
    local result = {}
    local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not ok or not GameplayData then return result end

    local allCharacters = {}
    pcall(function()
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
    end)

    local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0

    for _, actor in pairs(allCharacters) do
        if Valid(actor) and actor ~= player then
            local isAlive = false
            pcall(function()
                if actor.HealthStatus ~= nil then isAlive = (actor.HealthStatus ~= 2)
                else isAlive = (actor.Health or 0) > 0 or (type(actor.IsAlive) == "function" and actor:IsAlive()) end
            end)

            if isAlive then
                local eTeam = actor.TeamID or (type(actor.GetTeamID) == "function" and actor:GetTeamID()) or 0
                if eTeam ~= myTeam then
                    local dist = 0
                    pcall(function() dist = player:GetDistanceTo(actor) end)
                    if dist <= radius then table.insert(result, actor) end
                end
            end
        end
    end
    return result
end

local function CalculateCrossbowPrediction(player, target, targetBonePos, predUserVal)
    if not Valid(player) or not Valid(target) or not targetBonePos then return targetBonePos end
    local distMeters = player:GetDistanceTo(target) / 100.0
    if distMeters < 5.0 or distMeters > 300.0 then return targetBonePos end

    local CrossbowSpeed = 160.0 
    local baseGravity = 14.5  
    local travelTime = distMeters / CrossbowSpeed
    local targetVelocity = type(target.GetVelocity) == "function" and target:GetVelocity() or nil
    
    local pX, pY, pZ = targetBonePos.X, targetBonePos.Y, targetBonePos.Z

    if targetVelocity and (targetVelocity.X ~= 0 or targetVelocity.Y ~= 0) and predUserVal > 0 then
        local predFactor = (predUserVal / 20.0)
        pX = pX + (targetVelocity.X * travelTime * predFactor)
        pY = pY + (targetVelocity.Y * travelTime * predFactor)
    end

    local zOffset = 0.5 * baseGravity * (travelTime * travelTime) * 100
    if distMeters >= 40.0 then
        zOffset = zOffset * 0.85
        if distMeters >= 50.0 then
            local steps = math.floor((distMeters - 50.0) / 5.0)
            local forceDown = steps * 3.5
            local pose = 0
            pcall(function() pose = target.PoseState or (type(target.GetPoseState) == "function" and target:GetPoseState()) or 0 end)
            if pose == 1 or pose == 2 then forceDown = forceDown * 1.8 end
            zOffset = zOffset - forceDown
        end
    end

    return {X = pX, Y = pY, Z = pZ + zOffset}
end

_G.AutoTapState = { LastTapTime = 0, Firing = false, IsAutoFiring = false }

_G.HandleAimTouch = function(player, pc)
    pcall(function()
        if not Valid(player) or not Valid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then weapon = player:GetCurrentShootWeapon() end
        
        local wName, wID = "", 0
        local isShotgun, isSniper, isCrossbow = false, false, false
        local currentAmmo = 1
        
        if Valid(weapon) then
            pcall(function() wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or "" end)
            pcall(function() wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0 end)
            local lowerName = string.lower(tostring(wName))
            
            if lowerName:find("crossbow") or lowerName:find("nỏ") or lowerName:find("bow") or lowerName:find("cung") then isCrossbow = true end
            if (wID >= 1030000 and wID < 1040000) or lowerName:find("s686") or lowerName:find("s1897") or lowerName:find("s12") or lowerName:find("dbs") or lowerName:find("m1014") then isShotgun = true end
            if lowerName:find("kar98") or lowerName:find("m24") or lowerName:find("awm") or lowerName:find("mosin") or lowerName:find("amr") or lowerName:find("sks") or lowerName:find("slr") or lowerName:find("mini") or lowerName:find("mk14") or lowerName:find("qbu") or lowerName:find("vss") then isSniper = true end
            
            pcall(function()
                if type(weapon.GetCurrentAmmo) == "function" then currentAmmo = weapon:GetCurrentAmmo()
                elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
                elseif weapon.CurrentAmmo ~= nil then currentAmmo = weapon.CurrentAmmo end
            end)
        end

        if _G.AutoTapState.IsAutoFiring then
            pcall(function() 
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end 
            end)
            _G.AutoTapState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then return end

        local cData = _G.LexusState.CustomTextData or {}
        local cond, prioMode, boneIdx, speedVal, fovVal, maxDistMeters, useVisCheck, igKnock, igBot, predVal, recoilCompVal = 2, 1, 1, 50, 30, 50, false, false, false, 0, 0

        -- 1. XỬ LÝ PHÂN LOẠI VŨ KHÍ & CẤU HÌNH
        if isCrossbow and _G.LexusConfig.AimTouchCrossbow then
            cond, prioMode, boneIdx = 2, 1, 1
            speedVal = cData.AimBowSpd or 48
            fovVal = cData.AimBowFov or 15
            predVal = cData.AimBowPred or 0
            maxDistMeters, igKnock = 300, true
        elseif isShotgun and _G.LexusConfig.AimTouchSG then
            cond = _G.LexusConfig.AimTouchSGAutoFire and 2 or 1
            if cond == 1 and not isFiring then return end
            prioMode = 1
            boneIdx = cData.AimTouchSGBone or 2
            speedVal = cData.AimTouchSGSpeed or 80
            fovVal = cData.AimTouchSGFOV or 40
            maxDistMeters = cData.AimTouchSGDist or 30
            useVisCheck = _G.LexusConfig.AimTouchSGVisCheck
        elseif isADS and isSniper and _G.LexusConfig.AimTouchScopeSniper then
            cond = 2
            if cond == 1 and not isFiring then return end
            prioMode = 1
            boneIdx = 1 -- Sniper luôn ưu tiên đầu
            speedVal = cData.AimSnipSpd or 48
            fovVal = cData.AimSnipFov or 15
            predVal = cData.AimSnipPred or 65
            maxDistMeters = 500
            useVisCheck = _G.LexusConfig.AimTouchSniperVisCheck
            igKnock = _G.LexusConfig.AimTouchSniperIgKnock
            igBot = _G.LexusConfig.AimTouchSniperIgBot
        elseif _G.LexusConfig.AimTouchHipfire then
            cond = cData.AimTouchHipCond or 1
            if cond == 1 and not isFiring then return end 
            prioMode = cData.AimTouchHipPrio or 1
            boneIdx = cData.AimTouchHipBone or 1
            speedVal = cData.AimTouchHipSpeed or 48
            fovVal = cData.AimTouchHipFOV or 15
            maxDistMeters = cData.AimTouchHipDist or 400
            predVal = cData.AimTouchHipPred or 0
            recoilCompVal = cData.AimTouchHipRecoil or 50
            useVisCheck = _G.LexusConfig.AimTouchHipVisCheck
            igKnock = _G.LexusConfig.AimTouchHipIgKnock
            igBot = _G.LexusConfig.AimTouchHipIgBot
        else
            return
        end

        -- KẾT HỢP AUTO TAP NẾU ĐƯỢC BẬT
        local isAutoTapActive = false
        if _G.LexusConfig.AutoTap and isFiring and not isShotgun and not isSniper and not isCrossbow then
            local tapMode = cData.AutoTapMode or 3
            if (tapMode == 1 and not isADS) or (tapMode == 2 and isADS) or (tapMode == 3) then
                isAutoTapActive = true
                boneIdx = cData.AutoTapBone or 1
                recoilCompVal = cData.AutoTapForce or 35
            end
        end

        local enemies = GetEnemyTargetsFromActors(maxDistMeters * 100, player)
        if not enemies or #enemies == 0 then return end
        
        local ui_util = require("client.common.ui_util")
        local vp = ui_util and ui_util.GetViewportSize()
        if not vp then return end
        
        local centerX, centerY = vp.X * 0.5, vp.Y * 0.5
        local FOV_RADIUS = (fovVal / 100.0) * (vp.X / 2.0)
        local bestTarget, bestScore = nil, 99999999
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "pelvis" end

        for _, target in ipairs(enemies) do
            if Valid(target) then
                if igKnock and target.HealthStatus == 1 then goto skip end
                if igBot then
                    local tIsBot = false
                    if target.bIsAI == true or target.IsAI == true then tIsBot = true end
                    local pState = target.PlayerState
                    if Valid(pState) and (pState.bIsABot or pState.bIsBot) then tIsBot = true end
                    if tIsBot then goto skip end
                end
                
                -- Check vật cản (Raycast)
                if useVisCheck then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    if isHidden then goto skip end
                end
                
                local tPos = nil
                pcall(function() tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0}) end)
                if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then pcall(function() tPos = target:GetSocketLocation(selBoneName) end) end
                
                if tPos and (tPos.X ~= 0 or tPos.Y ~= 0) then
                    local FVector2D = import("Vector2D")
                    local screen = FVector2D and FVector2D() or {X=0,Y=0}
                    if pc:ProjectWorldLocationToScreen(tPos, screen, false) and screen.X > 0 and screen.Y > 0 then
                        local distScreen = math.sqrt((screen.X - centerX)^2 + (screen.Y - centerY)^2)
                        if distScreen <= FOV_RADIUS then
                            local cScore = distScreen
                            if prioMode == 2 then cScore = player:GetDistanceTo(target)
                            elseif prioMode == 3 then cScore = target.Health or 100 end
                            
                            if cScore < bestScore then bestScore = cScore; bestTarget = target end
                        end
                    end
                end
                ::skip::
            end
        end
        
        if not Valid(bestTarget) then return end
        
        local finalPos = nil
        pcall(function() finalPos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0}) end)
        if not finalPos or (finalPos.X == 0 and finalPos.Y == 0 and finalPos.Z == 0) then pcall(function() finalPos = bestTarget:GetSocketLocation(selBoneName) end) end
        if not finalPos then return end
        
        -- 2. TÍNH TOÁN DỰ ĐOÁN HƯỚNG
        if isCrossbow then
            local res = CalculateCrossbowPrediction(player, bestTarget, finalPos, predVal)
            finalPos.X, finalPos.Y, finalPos.Z = res.X, res.Y, res.Z
        elseif predVal > 0 then
            pcall(function()
                local tVel = type(bestTarget.GetVelocity) == "function" and bestTarget:GetVelocity() or nil
                if tVel and (tVel.X ~= 0 or tVel.Y ~= 0) then
                    local d = player:GetDistanceTo(bestTarget) / 100.0 
                    local tof = (d / 800.0) * (predVal / 50.0) 
                    finalPos.X, finalPos.Y = finalPos.X + (tVel.X * tof), finalPos.Y + (tVel.Y * tof)
                end
            end)
        end

        local KismetMathLibrary = import("KismetMathLibrary")
        local UGameplayStatics = import("GameplayStatics")
        local camMgr = UGameplayStatics and UGameplayStatics.GetPlayerCameraManager(pc, 0)
        local camLoc = camMgr and camMgr:GetCameraLocation()
        if not camLoc or not KismetMathLibrary then return end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalPos)
        local curRot = pc:GetControlRotation()
        if not rot or not curRot then return end
        
        local dYaw, dPitch = rot.Yaw - curRot.Yaw, rot.Pitch - curRot.Pitch
        
        -- Bù trừ Camera khi ADS
        if isADS then
            local cRot = type(camMgr.GetCameraRotation) == "function" and camMgr:GetCameraRotation() or nil
            if cRot then dYaw, dPitch = dYaw - (cRot.Yaw - curRot.Yaw), dPitch - (cRot.Pitch - curRot.Pitch) end
        end

        if dYaw > 180 then dYaw = dYaw - 360 elseif dYaw < -180 then dYaw = dYaw + 360 end
        if dPitch > 180 then dPitch = dPitch - 360 elseif dPitch < -180 then dPitch = dPitch + 360 end
        
        local smooth = (speedVal >= 100) and 1.0 or math.max(0.01, (speedVal / 100.0) * 0.3)
        local fPitch, fYaw = curRot.Pitch + (dPitch * smooth), curRot.Yaw + (dYaw * smooth)
        
        -- 3. TỰ ĐỘNG GHÌM TÂM TRONG AIMBOT
        if recoilCompVal > 0 and isFiring then fPitch = fPitch - ((recoilCompVal / 50.0) * 1.5) end

        pc:SetControlRotation({ Pitch = fPitch, Yaw = fYaw, Roll = 0 }, "AimTouch")
        
        -- 4. AUTO FIRE CHO SHOTGUN
        if isShotgun and _G.LexusConfig.AimTouchSGAutoFire then
            pcall(function()
                if (player:GetDistanceTo(bestTarget) / 100) <= maxDistMeters then
                    player.bIsWeaponFiring = true; if type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    if Valid(weapon) and type(weapon.StartFire) == "function" then weapon:StartFire() end
                    _G.AutoTapState.IsAutoFiring = true
                end
            end)
        end
        
        -- 5. THỰC THI AUTO TAP NHẤP NHẢ
        if isAutoTapActive then
            local tapSpeed = cData.AutoTapSpeed or 5 
            local curTime = os.clock()
            local delay = tapSpeed * 0.01
            
            if curTime - _G.AutoTapState.LastTapTime > delay then
                _G.AutoTapState.Firing = not _G.AutoTapState.Firing
                pcall(function()
                    player.bIsWeaponFiring = _G.AutoTapState.Firing
                    if type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(_G.AutoTapState.Firing) end
                    if _G.AutoTapState.Firing and Valid(weapon) and type(weapon.StartFire) == "function" then weapon:StartFire() end
                end)
                _G.AutoTapState.LastTapTime = curTime
            end
        end
    end)
end
-- ==============================================================================
-- PHẦN 5: LÕI WEAPON MAGIC, EXTRA ESP & TẠO GIAO DIỆN KHUNG ESP
-- ==============================================================================

-- ==========================================
-- 1. LOGIC WEAPON MAGIC (TÂM NHỎ & MAGIC BULLET)
-- ==========================================
local function HandleWeaponMagic(player)
    pcall(function()
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then weapon = player:GetCurrentShootWeapon() end
        if not Valid(weapon) then return end
        
        -- Logic Tâm Nhỏ
        local crosshairSize = _G.LexusState.CustomTextData.CrosshairSize or 50
        if crosshairSize < 50 and weapon.ShootWeaponComponent then
            local scale = crosshairSize / 50.0
            pcall(function() weapon.ShootWeaponComponent.BaseTargetingFOV = weapon.ShootWeaponComponent.BaseTargetingFOV * scale end)
            pcall(function() weapon.ShootWeaponComponent.RecoilKickADS = 0 end)
        end
        
        -- Logic Magic Bullet (Tăng Hitbox đạn)
        if _G.LexusConfig.CustomMagicBullet and weapon.ShootWeaponComponent then
            local magicH = _G.LexusState.CustomTextData.MagicHead or 0
            local magicB = _G.LexusState.CustomTextData.MagicBody or 0
            if magicH > 0 or magicB > 0 then
                pcall(function() weapon.ShootWeaponComponent.BulletDamageRadius = 15.0 + (magicB * 0.5) end)
            end
        end
    end)
end

-- ==========================================
-- 2. LOGIC EXTRA ESP (CẢNH BÁO BOM 60m)
-- ==========================================
local function HandleExtraESP(player, pc)
    pcall(function()
        if not _G.LexusConfig.AimGrenade and not _G.LexusConfig.AimMolotov and not _G.LexusConfig.AimStun and not _G.LexusConfig.AimSticky then return end
        
        local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not ok or not GameplayData then return end
        
        local UGameplayStatics = import("GameplayStatics")
        if not UGameplayStatics then return end

        local world = pc:GetWorld()
        local projectClasses = {
            { class = "ProjGrenade_C", enable = _G.LexusConfig.AimGrenade, name = "Bom Nổ" },
            { class = "ProjMolotov_C", enable = _G.LexusConfig.AimMolotov, name = "Bom Lửa" },
            { class = "ProjStun_C", enable = _G.LexusConfig.AimStun, name = "Bom Choáng" },
            { class = "ProjSticky_C", enable = _G.LexusConfig.AimSticky, name = "Bom Dính" }
        }

        for _, proj in ipairs(projectClasses) do
            if proj.enable then
                local projClass = import(proj.class)
                if projClass then
                    local actors = UGameplayStatics.GetAllActorsOfClass(world, projClass)
                    local count = type(actors.Num) == "function" and actors:Num() or #actors
                    for i = 1, count do
                        local actor = type(actors.Get) == "function" and actors:Get(i-1) or actors[i]
                        if Valid(actor) then
                            local dist = player:GetDistanceTo(actor) / 100.0
                            if dist <= 60.0 then
                                local msg = string.format("⚠ PHÁT HIỆN %s: %.1fm", proj.name, dist)
                                pcall(function()
                                    local sh = import("ScriptHelperClient")
                                    if sh and sh.AddOnScreenDebugMessage then 
                                        sh.AddOnScreenDebugMessage(msg, 0.5, 2.0, {R=1,G=0,B=0,A=1}, {X=1.5, Y=1.5}) 
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 3. KHỞI TẠO BỘ KHUNG ESP UMG GỐC
-- ==========================================
local PlayerMapMarker = _G.PlayerMapMarker or {}
_G.PlayerMapMarker = PlayerMapMarker
PlayerMapMarker.ESPWidgets = PlayerMapMarker.ESPWidgets or {}
PlayerMapMarker.SnapLineWidgets = PlayerMapMarker.SnapLineWidgets or {}
PlayerMapMarker.SkeletonWidgets = PlayerMapMarker.SkeletonWidgets or {}
PlayerMapMarker.ESPCanvas = nil

function PlayerMapMarker.InitESPCanvas()
    if PlayerMapMarker.ESPCanvas and slua.isValid(PlayerMapMarker.ESPCanvas) then return true end
    local ok, InGameUITools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    if not ok or not InGameUITools then return false end
    local MainControlBaseUI = InGameUITools.GetMainControlBaseUI and InGameUITools.GetMainControlBaseUI()
    if not MainControlBaseUI or not slua.isValid(MainControlBaseUI) then return false end

    local ParentCanvas = MainControlBaseUI.CanvasPanel_0
    if not slua.isValid(ParentCanvas) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    if not slua.isValid(ParentCanvas) then return false end

    PlayerMapMarker.ESPCanvas = ParentCanvas
    return true
end

function PlayerMapMarker.ClearAllESP()
    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        if Data.Container and slua.isValid(Data.Container) then
            pcall(function() Data.Container:RemoveFromParent(); Data.Container:ConditionalBeginDestroy() end)
        end
    end
    for KeyStr, LineData in pairs(PlayerMapMarker.SnapLineWidgets) do
        if LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:RemoveFromParent(); LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    for KeyStr, PlayerBones in pairs(PlayerMapMarker.SkeletonWidgets) do
        for _, LineData in ipairs(PlayerBones) do
            if LineData.Widget and slua.isValid(LineData.Widget) then
                pcall(function() LineData.Widget:RemoveFromParent(); LineData.Widget:ConditionalBeginDestroy() end)
            end
        end
    end
    PlayerMapMarker.ESPWidgets = {}
    PlayerMapMarker.SnapLineWidgets = {}
    PlayerMapMarker.SkeletonWidgets = {}
end

function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not slua.isValid(PlayerMapMarker.ESPCanvas) then return nil end
    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", PlayerMapMarker.ESPCanvas) end)
    if not slua.isValid(Container) then return nil end

    local NameText = nil
    pcall(function() NameText = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
    if slua.isValid(NameText) then
        pcall(function()
            NameText:SetText("Enemy")
            local FLinearColor = import("LinearColor") or _G.FLinearColor
            local color = FLinearColor and FLinearColor(1.0, 1.0, 1.0, 1.0) or {R=255,G=255,B=255,A=255}
            if NameText.SetColorAndOpacity then
                local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
                if FSlateColor then NameText:SetColorAndOpacity(FSlateColor(color)) else NameText:SetColorAndOpacity(color) end
            end
            if NameText.Font then
                local font = NameText.Font; font.Size = 13; NameText.Font = font
            end
            NameText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local slot = Container:AddChildToCanvas(NameText)
        if slot then
            local FVector2D = import("Vector2D")
            slot:SetAutoSize(true)
            slot:SetAlignment(FVector2D and FVector2D(0.5, 1.0) or {X=0.5, Y=1.0})
            slot:SetPosition(FVector2D and FVector2D(0, -15) or {X=0, Y=-15})
        end
    end

    local HealthPB = nil
    pcall(function() HealthPB = CGame:NewObjectFromPath("/Script/UMG.ProgressBar", Container) end)
    if slua.isValid(HealthPB) then
        pcall(function()
            local FLinearColor = import("LinearColor") or _G.FLinearColor
            local hColor = FLinearColor and FLinearColor(0.0, 1.0, 0.0, 1.0) or {R=0,G=255,B=0,A=255}
            HealthPB:SetFillColorAndOpacity(hColor)
            HealthPB:SetPercent(1.0)
            HealthPB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local slot = Container:AddChildToCanvas(HealthPB)
        if slot then
            local FVector2D = import("Vector2D")
            slot:SetAutoSize(false)
            slot:SetSize(FVector2D and FVector2D(80, 5) or {X=80, Y=5})
            slot:SetAlignment(FVector2D and FVector2D(0.5, 1.0) or {X=0.5, Y=1.0})
            slot:SetPosition(FVector2D and FVector2D(0, -5) or {X=0, Y=-5})
        end
    end

    local MainSlot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Container)
    if MainSlot then
        pcall(function()
            local FVector2D = import("Vector2D")
            MainSlot:SetAutoSize(true)
            MainSlot:SetZOrder(5)
            MainSlot:SetAlignment(FVector2D and FVector2D(0.5, 1.0) or {X=0.5, Y=1.0})
        end)
    end

    return { Container = Container, NameText = NameText, HealthFill = HealthPB, Slot = MainSlot }
end
-- ==============================================================================
-- PHẦN 6: LÕI QUÉT ESP TỔNG HỢP VÀ VÒNG LẶP ĐÓNG GÓI CHÍNH (MAIN LOOP)
-- ==============================================================================

-- ==========================================
-- 1. HỆ THỐNG VẼ ESP PHƯƠNG TIỆN VÀ VẬT PHẨM
-- ==========================================
local function DrawItemAndVehicleESP(player, pc)
    local hud = pc.MyHUD
    if not Valid(hud) then return end

    -- ESP Phương Tiện
    if _G.LexusConfig.EspVehicle then
        pcall(function()
            local VehClass = import("STExtraVehicleBase")
            if VehClass then
                local vehs = import("GameplayStatics").GetAllActorsOfClass(pc:GetWorld(), VehClass)
                local vCount = type(vehs.Num) == "function" and vehs:Num() or #vehs
                for i = 1, vCount do
                    local veh = type(vehs.Get) == "function" and vehs:Get(i-1) or vehs[i]
                    if Valid(veh) and not veh.bHidden then
                        local distM = player:GetDistanceTo(veh) / 100.0
                        if distM <= 300 then
                            local vName = type(veh.GetVehicleName) == "function" and veh:GetVehicleName() or veh.VehicleName or "Xe"
                            local hasDriver = Valid(type(veh.GetDriver) == "function" and veh:GetDriver() or nil)
                            local vColor = hasDriver and {R=255,G=0,B=0,A=255} or {R=0,G=255,B=255,A=255}
                            hud:AddDebugText(string.format("%s [%.0fm]", vName, distM), veh, 0.06, {X=0,Y=0,Z=50}, {X=0,Y=0,Z=50}, vColor, true, false, true, nil, 0.8, true)
                        end
                    end
                end
            end
        end)
    end

    -- ESP Vật Phẩm
    if _G.LexusConfig.EspItem_Master then
        pcall(function()
            local PickUpClass = import("PickUpWrapperActor") or import("STPickupWrapperActor")
            if PickUpClass then
                local items = import("GameplayStatics").GetAllActorsOfClass(pc:GetWorld(), PickUpClass)
                local iCount = type(items.Num) == "function" and items:Num() or #items
                for i = 1, iCount do
                    local item = type(items.Get) == "function" and items:Get(i-1) or items[i]
                    if Valid(item) and not item.bHidden then
                        local distM = player:GetDistanceTo(item) / 100.0
                        if distM <= 50 then
                            hud:AddDebugText(string.format("Item [%.0fm]", distM), item, 0.06, {X=0,Y=0,Z=10}, {X=0,Y=0,Z=10}, {R=255,G=255,B=0,A=255}, true, false, true, nil, 0.6, true)
                        end
                    end
                end
            end
        end)
    end
end

-- ==========================================
-- 2. VÒNG QUÉT VÀ CẬP NHẬT ESP ĐỊCH LÊN MÀN HÌNH
-- ==========================================
function PlayerMapMarker.ScanAndUpdateESP(player, pc)
    if not PlayerMapMarker.InitESPCanvas() then return end
    
    local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not ok then return end
    
    local allCharacters = {}
    pcall(function()
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
    end)

    local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
    local SeenKeys = {}
    local hud = pc.MyHUD
    local detectRange = _G.LexusState.CustomTextData.DetectRange or 400

    for _, enemy in pairs(allCharacters) do
        if Valid(enemy) and enemy ~= player then
            local isAlive = false
            pcall(function()
                if enemy.HealthStatus ~= nil then isAlive = (enemy.HealthStatus ~= 2)
                else isAlive = (enemy.Health or 0) > 0 or (type(enemy.IsAlive) == "function" and enemy:IsAlive()) end
            end)

            local pKey = tostring(enemy.PlayerKey or enemy:GetUniqueID())

            if isAlive then
                local eTeam = enemy.TeamID or (type(enemy.GetTeamID) == "function" and enemy:GetTeamID()) or 0
                if eTeam ~= myTeam then
                    local distM = 0
                    pcall(function() distM = player:GetDistanceTo(enemy) / 100 end)
                    
                    if distM <= detectRange then
                        SeenKeys[pKey] = true
                        local isBot = false
                        pcall(function() isBot = enemy.bIsAI or enemy.IsAI or (enemy.PlayerState and (enemy.PlayerState.bIsABot or enemy.PlayerState.bIsBot)) end)
                        
                        local eLoc = nil
                        pcall(function() eLoc = enemy:K2_GetActorLocation() end)
                        
                        local bOnScreen = false
                        local FVector2D = import("Vector2D")
                        local screenPos = FVector2D and FVector2D() or {X=0, Y=0}
                        
                        if eLoc then
                            eLoc.Z = eLoc.Z + 85
                            bOnScreen = pc:ProjectWorldLocationToScreen(eLoc, screenPos, false)
                        end

                        -- Vẽ Box và Khung Xương bằng HUD (Giảm tải UMG)
                        if Valid(hud) and bOnScreen then
                            local eColor = isBot and {R=0,G=255,B=255,A=255} or {R=255,G=0,B=0,A=255}
                            
                            -- Vẽ Box
                            if _G.LexusConfig.EspLoai5 then
                                pcall(function()
                                    local headPos = enemy:GetBonePos("head", {X=0,Y=0,Z=0})
                                    local rootPos = enemy:K2_GetActorLocation()
                                    if headPos and rootPos then
                                        headPos.Z = headPos.Z + 15
                                        rootPos.Z = rootPos.Z - 10
                                        local sHead, sRoot = FVector2D(), FVector2D()
                                        if pc:ProjectWorldLocationToScreen(headPos, sHead, false) and pc:ProjectWorldLocationToScreen(rootPos, sRoot, false) then
                                            local boxHeight = math.abs(sRoot.Y - sHead.Y)
                                            local boxWidth = boxHeight * 0.5
                                            local tl = {X=sHead.X - boxWidth/2, Y=sHead.Y}
                                            local tr = {X=sHead.X + boxWidth/2, Y=sHead.Y}
                                            local bl = {X=sRoot.X - boxWidth/2, Y=sRoot.Y}
                                            local br = {X=sRoot.X + boxWidth/2, Y=sRoot.Y}
                                            hud:DrawLine(tl.X, tl.Y, tr.X, tr.Y, eColor, 1.5)
                                            hud:DrawLine(bl.X, bl.Y, br.X, br.Y, eColor, 1.5)
                                            hud:DrawLine(tl.X, tl.Y, bl.X, bl.Y, eColor, 1.5)
                                            hud:DrawLine(tr.X, tr.Y, br.X, br.Y, eColor, 1.5)
                                        end
                                    end
                                end)
                            end

                            -- Vẽ Khung Xương (Skeleton)
                            if _G.LexusConfig.EspLoai6 then
                                pcall(function()
                                    local bones = {"head", "neck_01", "spine_01", "pelvis", "upperarm_l", "lowerarm_l", "hand_l", "upperarm_r", "lowerarm_r", "hand_r", "thigh_l", "calf_l", "foot_l", "thigh_r", "calf_r", "foot_r"}
                                    local bPos = {}
                                    for _, b in ipairs(bones) do
                                        local wPos = enemy:GetBonePos(b, {X=0,Y=0,Z=0})
                                        if wPos then
                                            local sPos = FVector2D()
                                            if pc:ProjectWorldLocationToScreen(wPos, sPos, false) then bPos[b] = sPos end
                                        end
                                    end
                                    local function DLine(b1, b2)
                                        if bPos[b1] and bPos[b2] then hud:DrawLine(bPos[b1].X, bPos[b1].Y, bPos[b2].X, bPos[b2].Y, {R=255,G=255,B=255,A=255}, 1.2) end
                                    end
                                    DLine("head", "neck_01"); DLine("neck_01", "spine_01"); DLine("spine_01", "pelvis")
                                    DLine("neck_01", "upperarm_l"); DLine("upperarm_l", "lowerarm_l"); DLine("lowerarm_l", "hand_l")
                                    DLine("neck_01", "upperarm_r"); DLine("upperarm_r", "lowerarm_r"); DLine("lowerarm_r", "hand_r")
                                    DLine("pelvis", "thigh_l"); DLine("thigh_l", "calf_l"); DLine("calf_l", "foot_l")
                                    DLine("pelvis", "thigh_r"); DLine("thigh_r", "calf_r"); DLine("calf_r", "foot_r")
                                end)
                            end
                        end

                        -- Cập nhật UMG Text & Health
                        if _G.LexusConfig.EspVipPro or _G.LexusConfig.EspDistance or _G.LexusConfig.Esp7_VuKhi then
                            local ESPData = PlayerMapMarker.ESPWidgets[pKey]
                            if not ESPData then
                                ESPData = PlayerMapMarker.CreateESPWidget()
                                if ESPData then PlayerMapMarker.ESPWidgets[pKey] = ESPData end
                            end

                            if ESPData and ESPData.Container and slua.isValid(ESPData.Container) then
                                if bOnScreen then
                                    ESPData.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                                    ESPData.Slot:SetPosition(screenPos)
                                    
                                    local infoText = ""
                                    if _G.LexusConfig.EspVipPro then
                                        local eName = "Enemy"
                                        pcall(function() if enemy.PlayerName then eName = enemy.PlayerName elseif type(enemy.GetPlayerName) == "function" then eName = enemy:GetPlayerName() end end)
                                        infoText = eName
                                    end
                                    if _G.LexusConfig.EspDistance then infoText = infoText .. string.format(" [%dm]", math.floor(distM)) end
                                    if _G.LexusConfig.Esp7_VuKhi then
                                        pcall(function()
                                            local wpn = type(enemy.GetCurrentWeapon) == "function" and enemy:GetCurrentWeapon() or enemy.CurrentWeapon
                                            if Valid(wpn) and type(wpn.GetWeaponName) == "function" then infoText = infoText .. "\n" .. wpn:GetWeaponName() end
                                        end)
                                    end
                                    
                                    if ESPData.NameText and slua.isValid(ESPData.NameText) then
                                        ESPData.NameText:SetText(infoText)
                                        local tColor = isBot and {R=0,G=255,B=255,A=255} or {R=255,G=255,B=255,A=255}
                                        local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
                                        if FSlateColor then
                                            local lc = import("LinearColor") and import("LinearColor")(tColor.R/255, tColor.G/255, tColor.B/255, 1) or tColor
                                            ESPData.NameText:SetColorAndOpacity(FSlateColor(lc)) 
                                        else 
                                            ESPData.NameText:SetColorAndOpacity(tColor) 
                                        end
                                    end

                                    if _G.LexusConfig.Esp9_HP and ESPData.HealthFill and slua.isValid(ESPData.HealthFill) then
                                        ESPData.HealthFill:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                                        local cHp, mHp = 100, 100
                                        pcall(function()
                                            if enemy.Health then cHp = enemy.Health elseif type(enemy.GetHealth) == "function" then cHp = enemy:GetHealth() end
                                            if enemy.HealthMax then mHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then mHp = enemy:GetHealthMax() end
                                        end)
                                        if mHp <= 0 then mHp = 100 end
                                        local hpRatio = cHp / mHp
                                        ESPData.HealthFill:SetPercent(hpRatio)
                                        
                                        local FLinearColor = import("LinearColor") or _G.FLinearColor
                                        local hpColor = FLinearColor and FLinearColor(0,1,0,1) or {R=0,G=255,B=0,A=255}
                                        if hpRatio < 0.3 then hpColor = FLinearColor and FLinearColor(1,0,0,1) or {R=255,G=0,B=0,A=255}
                                        elseif hpRatio < 0.7 then hpColor = FLinearColor and FLinearColor(1,1,0,1) or {R=255,G=255,0,A=255} end
                                        ESPData.HealthFill:SetFillColorAndOpacity(hpColor)
                                    elseif ESPData.HealthFill and slua.isValid(ESPData.HealthFill) then
                                        ESPData.HealthFill:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                                    end
                                else
                                    ESPData.Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                                end
                            end
                        else
                            if PlayerMapMarker.ESPWidgets[pKey] then
                                local c = PlayerMapMarker.ESPWidgets[pKey].Container
                                if slua.isValid(c) then pcall(function() c:RemoveFromParent(); c:ConditionalBeginDestroy() end) end
                                PlayerMapMarker.ESPWidgets[pKey] = nil
                            end
                        end
                        
                        -- Cảnh báo ngắm
                        if _G.LexusConfig.EspAimWarning and distM <= 300 then
                            pcall(function()
                                local KismetMathLibrary = import("KismetMathLibrary")
                                local pLoc = type(player.K2_GetActorLocation) == "function" and player:K2_GetActorLocation()
                                if eLoc and pLoc and KismetMathLibrary then
                                    local lookRot = KismetMathLibrary.FindLookAtRotation(eLoc, pLoc)
                                    local eRot = type(enemy.GetControlRotation) == "function" and enemy:GetControlRotation() or enemy:GetActorRotation()
                                    if eRot and lookRot then
                                        local dYaw = math.abs(eRot.Yaw - lookRot.Yaw)
                                        if dYaw > 180 then dYaw = 360 - dYaw end
                                        if dYaw < 15 then
                                            local isVis = true
                                            if _G.LexusConfig.EspAimWarningVisCheck then isVis = pc:LineOfSightTo(enemy) end
                                            if isVis then
                                                local sh = import("ScriptHelperClient")
                                                if sh then sh.AddOnScreenDebugMessage("⚠ ĐỊCH ĐANG NGẮM: " .. math.floor(distM) .. "m", 0.5, 2.0, {R=1,G=0,B=0,A=1}, {X=1.5, Y=1.5}) end
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end

            if not SeenKeys[pKey] then
                if PlayerMapMarker.ESPWidgets[pKey] then
                    local c = PlayerMapMarker.ESPWidgets[pKey].Container
                    if slua.isValid(c) then pcall(function() c:RemoveFromParent(); c:ConditionalBeginDestroy() end) end
                    PlayerMapMarker.ESPWidgets[pKey] = nil
                end
            end
        end
    end
end

-- ==========================================
-- 3. BỘ ĐỘNG CƠ CHÍNH GÓI GỌN TẤT CẢ MODULES
-- ==========================================
_G.EnemyMarkData = _G.EnemyMarkData or {}

local function MasterMainLoop()
    local curTime = os.clock()
    -- Liên tục bơm Menu chống tàng hình UI
    if not _G.LexusState.LastMenuFixTime or (curTime - _G.LexusState.LastMenuFixTime) > 2.0 then
        _G.LexusState.LastMenuFixTime = curTime
        pcall(_G.InitModMenuTab)
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = Valid(pc) and pc:GetPlayerCharacterSafety() or nil
    
    if not Valid(localPlayer) then 
        PlayerMapMarker.ClearAllESP()
        return 
    end

    -- Đồ họa & Tính năng phụ
    pcall(_G.UpdateEnvironment)
    pcall(_G.UpdateIpadView, localPlayer, pc)
    pcall(HandleWeaponMagic, localPlayer)
    pcall(HandleExtraESP, localPlayer, pc)

    -- Aim Touch
    if _G.LexusConfig.AimTouchHipfire or _G.LexusConfig.AimTouchScopeSniper or _G.LexusConfig.AimTouchSG or _G.LexusConfig.AimTouchCrossbow then
        pcall(_G.HandleAimTouch, localPlayer, pc)
    end

    -- Quét ESP UMG (Giới hạn 0.05s để tối ưu FPS)
    if _G.LexusConfig.EspVipPro or _G.LexusConfig.EspDistance or _G.LexusConfig.Esp7_VuKhi or _G.LexusConfig.EspLoai5 or _G.LexusConfig.EspLoai6 then
        if not _G.LastESPScanTime or (curTime - _G.LastESPScanTime) > 0.05 then
            _G.LastESPScanTime = curTime
            pcall(PlayerMapMarker.ScanAndUpdateESP, localPlayer, pc)
            pcall(DrawItemAndVehicleESP, localPlayer, pc)
        end
    else
        PlayerMapMarker.ClearAllESP() 
    end

    -- Kích hoạt Chams Xuyên Tường
    if _G.LexusConfig.WallXuyenTuong then
        pcall(function()
            local detectRange = _G.LexusState.CustomTextData.DetectRange or 400
            -- Lấy hàm từ P4
            local enemies = {}
            pcall(function() enemies = _G.GetEnemyTargetsFromActors(detectRange * 100) end)
            if not enemies then return end
            for _, enemy in ipairs(enemies) do
                local pKey = tostring(enemy.PlayerKey or enemy:GetUniqueID())
                _G.EnemyMarkData[pKey] = _G.EnemyMarkData[pKey] or {}
                if _G.ApplyChams then _G.ApplyChams(enemy, _G.EnemyMarkData[pKey]) end
            end
        end)
    else
        for _, data in pairs(_G.EnemyMarkData) do 
            if _G.UndoChams then _G.UndoChams(data.enemy, data) end 
        end
    end
end

-- ==========================================
-- 4. HÀM KÍCH NỔ NHỊP TIM
-- ==========================================
_G.FastTick = function() 
    -- Chốt chặn Auth AKMOD
    if not _G._Authenticated_ or _G.myToken ~= _G.LexusState.LoopToken then return end
    
    pcall(MasterMainLoop) 
    
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.01, _G.FastTick) 
    end 
end
