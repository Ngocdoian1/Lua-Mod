-- ==============================================================================
-- BẢN FULL MOD WORKER VIP - TÍCH HỢP AKMOD AUTH (PHẦN 1 FULL LOGIC)
-- ==============================================================================
local function Notify(msg)
    local s = "[VIP MOD] " .. tostring(msg)
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

-- [1] DANH SÁCH CẤU HÌNH ĐẦY ĐỦ NHẤT (KHÔNG CẮT XÉN)
_G.VIPConfig = _G.VIPConfig or { 
    -- WALL & ESP
    WallXuyenTuong = false, WhiteBody = false, EspVipPro = false, EspDistance = false, EspLoai5 = false,
    Esp7_VuKhi = true, Esp7_TuThe = true, EspBot = true, EspVehicle = false, EspBomMaster = false,
    EspItemBom = false, EspActiveBom = false, EspItem_Master = false,
    EspAimWarning = false, EspAimWarningVisCheck = false,
    
    -- AIM TOUCH
    AimTouchEnable = false,
    AimTouchHipfire = false, AimTouchHipIgBot = false, AimTouchHipIgKnock = false, AimTouchHipVisCheck = false,
    AimTouchSG = false, AimTouchSGAutoFire = false, AimTouchSGIgBot = false, AimTouchSGIgKnock = false, AimTouchSGVisCheck = false,
    AimTouchScopeAll = false, AimTouchScopeIgBot = false, AimTouchScopeIgKnock = false, AimTouchScopeVisCheck = false,
    AimTouchScopeSniper = false, AimTouchSniperIgBot = false, AimTouchSniperIgKnock = false, AimTouchSniperVisCheck = false,
    AimTouchCrossbow = false, AimTouchCrossbowHip = false, AimTouchCrossbowVis = false,
    AutoTap = false, AutoTapHip = false, AutoTapScope = false,
    
    -- WEAPON & MAGIC
    Crosshair = false, CustomMagicBullet = false,
    
    -- IPAD VIEW & MAP
    IpadView = false, IpadViewVehicle = false, IpadViewScope = false,
    RemoveGrass = false, RemoveTrees = false, RemoveWater = false, RemoveFog = false, BlackSky = false,
    
    -- EXTRA
    AimGrenade = false, AimMolotov = false, AimStun = false, AimSticky = false
}

_G.VIPState = _G.VIPState or { 
    LoopToken = 0, MenuInitialized = false, LastMenuFixTime = 0, CustomTextData = {} 
}

-- [2] HỆ THỐNG LƯU FILE TỰ ĐỘNG (AUTO SAVE/LOAD)
local ConfigFileName = "vip_full_settings.txt"
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
        data = data .. "},\nVIPState = {\nCustomTextData = {\n"
        if _G.VIPState.CustomTextData then
            for k, v in pairs(_G.VIPState.CustomTextData) do data = data .. "  [\"" .. tostring(k) .. "\"] = " .. tostring(v) .. ",\n" end
        end
        data = data .. "}\n}\n}"
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
                    if savedData.VIPState and savedData.VIPState.CustomTextData then 
                        for k, v in pairs(savedData.VIPState.CustomTextData) do _G.VIPState.CustomTextData[k] = v end 
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

-- [3] HỆ THỐNG BẢO MẬT AKMOD NGUYÊN BẢN
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
    _G.VIPState.LoopToken = (_G.VIPState.LoopToken or 0) + 1 
    _G.myToken = _G.VIPState.LoopToken
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
        local pad = #s % 4
        if pad > 0 then s = s .. string.rep('=', 4 - pad) end
        local b = {}
        local len = #s
        for i = 1, len, 4 do
            local c1 = b64chars:find(s:sub(i,   i),   1, true)
            local c2 = b64chars:find(s:sub(i+1, i+1), 1, true)
            local c3 = b64chars:find(s:sub(i+2, i+2), 1, true)
            local c4 = b64chars:find(s:sub(i+3, i+3), 1, true)
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
-- ==============================================================================
-- PHẦN 2: HỆ THỐNG GIAO DIỆN MENU VIP (5 TAB CHUẨN ĐÉT & CHỐNG MẤT)
-- ==============================================================================
function _G.InitModMenuTab()
    local ok1, SettingPageDefine = pcall(require, "client.logic.NewSetting.SettingPageDefine")
    local ok2, SettingCatalog = pcall(require, "client.logic.NewSetting.SettingCatalog")
    if not (ok1 and SettingPageDefine and ok2 and SettingCatalog) then return end

    local LocUtil = _G.LocUtil or (pcall(require, "client.common.LocUtil") and require("client.common.LocUtil"))
    local FakeTextMap = { [999000] = " AKMOD VIP" }

    if LocUtil and not LocUtil._IsMenuHooked then
        local old_func = LocUtil.GetTextByID
        LocUtil.GetTextByID = function(id)
            if FakeTextMap[id] then return FakeTextMap[id] end
            if old_func then return old_func(id) end
            return ""
        end
        LocUtil._IsMenuHooked = true
    end

    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        
        -- TAB 1: WALL & ESP
        local StackWallESP = {
            { Key = "M_Wall_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ BẬT WALL", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.WallXuyenTuong end, SetFunc = function(c,v) _G.VIPConfig.WallXuyenTuong = v return true end },
            { Key = "M_WallVis", UI = AliasMap.Slider, Text = "   Màu nhìn thấy (1-9)", ExpandHandle = "M_Wall_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.VIPState.CustomTextData.WallVis or 3 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.WallVis = v return true end },
            { Key = "M_WallHid", UI = AliasMap.Slider, Text = "   Màu khuất tường (1-9)", ExpandHandle = "M_Wall_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.VIPState.CustomTextData.WallHid or 2 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.WallHid = v return true end },
            { Key = "M_White", UI = AliasMap.Switcher, Text = "NGƯỜI MÀU TRẮNG", GetFunc = function() return _G.VIPConfig.WhiteBody end, SetFunc = function(c,v) _G.VIPConfig.WhiteBody = v return true end },
            { Key = "M_EspHP", UI = AliasMap.Switcher, Text = "ESP THANH MÁU", GetFunc = function() return _G.VIPConfig.EspVipPro end, SetFunc = function(c,v) _G.VIPConfig.EspVipPro = v return true end },
            { Key = "M_EspDist", UI = AliasMap.Switcher, Text = "ESP KHOẢNG CÁCH", GetFunc = function() return _G.VIPConfig.EspDistance end, SetFunc = function(c,v) _G.VIPConfig.EspDistance = v return true end },
            { Key = "M_EspBox", UI = AliasMap.Switcher, Text = "ESP BOX", GetFunc = function() return _G.VIPConfig.EspLoai5 end, SetFunc = function(c,v) _G.VIPConfig.EspLoai5 = v return true end },
            { Key = "M_EspWep", UI = AliasMap.Switcher, Text = "HIỆN SÚNG ĐỊCH CẦM", GetFunc = function() return _G.VIPConfig.Esp7_VuKhi end, SetFunc = function(c,v) _G.VIPConfig.Esp7_VuKhi = v return true end },
            { Key = "M_EspBot", UI = AliasMap.Switcher, Text = "PHÂN BIỆT BOT", GetFunc = function() return _G.VIPConfig.EspBot end, SetFunc = function(c,v) _G.VIPConfig.EspBot = v return true end },
            { Key = "M_EspVeh", UI = AliasMap.Switcher, Text = "ESP PHƯƠNG TIỆN", GetFunc = function() return _G.VIPConfig.EspVehicle end, SetFunc = function(c,v) _G.VIPConfig.EspVehicle = v return true end },
            { Key = "M_EspBomb", UI = AliasMap.Switcher, Text = "ESP BOM", GetFunc = function() return _G.VIPConfig.EspBomMaster end, SetFunc = function(c,v) _G.VIPConfig.EspBomMaster = v return true end },
            { Key = "M_EspItem_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ ESP ITEM", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.EspItem_Master end, SetFunc = function(c,v) _G.VIPConfig.EspItem_Master = v return true end },
            { Key = "M_AimWarn", UI = AliasMap.Switcher, Text = "CẢNH BÁO ĐỊCH ĐANG NGẮM", GetFunc = function() return _G.VIPConfig.EspAimWarning end, SetFunc = function(c,v) _G.VIPConfig.EspAimWarning = v return true end },
            { Key = "M_WarnVis", UI = AliasMap.Switcher, Text = "CHECK VẬT CẢN (CẢNH BÁO NGẮM)", GetFunc = function() return _G.VIPConfig.EspAimWarningVisCheck end, SetFunc = function(c,v) _G.VIPConfig.EspAimWarningVisCheck = v return true end }
        }

        -- TAB 2: AIM TOUCH (FULL CHỨC NĂNG)
        local StackAimTouch = {
            { Key = "AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ BẬT AIM TOUCH TÂM TRẮNG", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.VIPConfig.AimTouchHipfire = v return true end },
            { Key = "AT_Mode", UI = AliasMap.Slider, Text = "   CHẾ ĐỘ AIMBOT (1:Bắn | 2:Ngắm | 3:Luôn Aim)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipCond = v return true end },
            { Key = "AT_Prio", UI = AliasMap.Slider, Text = "   ƯU TIÊN MỤC TIÊU (1:Tâm | 2:Gần | 3:HP)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipPrio = v return true end },
            { Key = "AT_Bone", UI = AliasMap.Slider, Text = "   VỊ TRÍ AIM (1:Đầu | 2:Ngực | 3:Bụng)", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipBone or 1 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipBone = v return true end },
            { Key = "AT_Spd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ AIMBOT", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipSpeed or 48 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipSpeed = v return true end },
            { Key = "AT_Fov", UI = AliasMap.Slider, Text = "   FOV TÂM TRẮNG", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipFOV or 15 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipFOV = v return true end },
            { Key = "AT_Dist", UI = AliasMap.Slider, Text = "   KHOẢNG CÁCH AIMBOT", ExpandHandle = "AT_Hip_Ex", MinValue = 1, MaxValue = 400, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipDist or 400 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipDist = v return true end },
            { Key = "AT_Pred", UI = AliasMap.Slider, Text = "   DỰ ĐOÁN HƯỚNG", ExpandHandle = "AT_Hip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipPred or 0 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipPred = v return true end },
            { Key = "AT_Recoil", UI = AliasMap.Slider, Text = "   LỰC GHÌM TÂM", ExpandHandle = "AT_Hip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimTouchHipRecoil or 50 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimTouchHipRecoil = v return true end },

            { Key = "AT_Snip_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SNIP AUTO AIM ĐẦU", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.VIPConfig.AimTouchScopeSniper = v return true end },
            { Key = "AT_SnipFov", UI = AliasMap.Slider, Text = "   FOV AIMBOT", ExpandHandle = "AT_Snip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimSnipFov or 15 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimSnipFov = v return true end },
            { Key = "AT_SnipSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ AIMBOT", ExpandHandle = "AT_Snip_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimSnipSpd or 48 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimSnipSpd = v return true end },
            { Key = "AT_SnipPred", UI = AliasMap.Slider, Text = "   DỰ ĐOÁN HƯỚNG", ExpandHandle = "AT_Snip_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.AimSnipPred or 65 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AimSnipPred = v return true end },

            { Key = "AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AIM SHOTGUN", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.AimTouchSG end, SetFunc = function(c,v) _G.VIPConfig.AimTouchSG = v return true end },
            { Key = "AT_SGAuto", UI = AliasMap.Switcher, Text = "   TỰ ĐỘNG BẮN", ExpandHandle = "AT_SG_Ex", GetFunc = function() return _G.VIPConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.VIPConfig.AimTouchSGAutoFire = v return true end },

            { Key = "AT_Bow_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AIM CUNG TÊN NỎ", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.AimTouchCrossbow end, SetFunc = function(c,v) _G.VIPConfig.AimTouchCrossbow = v return true end },

            { Key = "AT_Tap_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ AUTO TAP", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.AutoTap end, SetFunc = function(c,v) _G.VIPConfig.AutoTap = v return true end },
            { Key = "AT_TapSpd", UI = AliasMap.Slider, Text = "   TỐC ĐỘ TAP (1:Nhanh | 20:Chậm)", ExpandHandle = "AT_Tap_Ex", MinValue = 1, MaxValue = 20, GetFunc = function() return _G.VIPState.CustomTextData.AutoTapSpeed or 5 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.AutoTapSpeed = v return true end }
        }

        -- TAB 3: WEAPON & MAGIC
        local StackWepMagic = {
            { Key = "WM_Crosshair", UI = AliasMap.Slider, Text = "TÂM NHỎ", MinValue = 1, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.CrosshairSize or 50 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.CrosshairSize = v return true end },
            { Key = "WM_Magic_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ MAGIC BULLET", ExpandIndex = 0, GetFunc = function() return _G.VIPConfig.CustomMagicBullet end, SetFunc = function(c,v) _G.VIPConfig.CustomMagicBullet = v return true end },
            { Key = "WM_MagicH", UI = AliasMap.Slider, Text = "   MAGIC ĐẦU %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.MagicHead or 0 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.MagicHead = v return true end },
            { Key = "WM_MagicB", UI = AliasMap.Slider, Text = "   MAGIC THÂN %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.MagicBody or 0 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.MagicBody = v return true end },
            { Key = "WM_MagicL", UI = AliasMap.Slider, Text = "   MAGIC CHÂN %", ExpandHandle = "WM_Magic_Ex", MinValue = 0, MaxValue = 100, GetFunc = function() return _G.VIPState.CustomTextData.MagicLegs or 0 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.MagicLegs = v return true end }
        }

        -- TAB 4: IPAD VIEW & MAP
        local StackIpadMap = {
            { Key = "IM_Ipad", UI = AliasMap.Slider, Text = "IPAD VIEW", MinValue = 90, MaxValue = 150, GetFunc = function() return _G.VIPState.CustomTextData.IpadViewFOV or 115 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.IpadViewFOV = v return true end },
            { Key = "IM_IpadVeh", UI = AliasMap.Slider, Text = "IPAD VIEW XE", MinValue = 90, MaxValue = 150, GetFunc = function() return _G.VIPState.CustomTextData.IpadViewVehicleFOV or 130 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.IpadViewVehicleFOV = v return true end },
            { Key = "IM_IpadScope", UI = AliasMap.Slider, Text = "IPAD VIEW SCOPE", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.VIPState.CustomTextData.IpadViewScopeFOV or 15 end, SetFunc = function(c,v) _G.VIPState.CustomTextData.IpadViewScopeFOV = v return true end },
            { Key = "IM_NoGrass", UI = AliasMap.Switcher, Text = "XÓA CỎ", GetFunc = function() return _G.VIPConfig.RemoveGrass end, SetFunc = function(c,v) _G.VIPConfig.RemoveGrass = v return true end },
            { Key = "IM_NoTree", UI = AliasMap.Switcher, Text = "XÓA CÂY", GetFunc = function() return _G.VIPConfig.RemoveTrees end, SetFunc = function(c,v) _G.VIPConfig.RemoveTrees = v return true end },
            { Key = "IM_NoWater", UI = AliasMap.Switcher, Text = "XÓA NƯỚC", GetFunc = function() return _G.VIPConfig.RemoveWater end, SetFunc = function(c,v) _G.VIPConfig.RemoveWater = v return true end },
            { Key = "IM_NoFog", UI = AliasMap.Switcher, Text = "XÓA SƯƠNG MÙ", GetFunc = function() return _G.VIPConfig.RemoveFog end, SetFunc = function(c,v) _G.VIPConfig.RemoveFog = v return true end },
            { Key = "IM_BlackSky", UI = AliasMap.Switcher, Text = "TRỜI ĐEN", GetFunc = function() return _G.VIPConfig.BlackSky end, SetFunc = function(c,v) _G.VIPConfig.BlackSky = v return true end }
        }

        -- TAB 5: EXTRA FEATURE
        local StackExtra = {
            { Key = "EX_Grenade", UI = AliasMap.Switcher, Text = "AIM BOM NỔ (60m)", GetFunc = function() return _G.VIPConfig.AimGrenade end, SetFunc = function(c,v) _G.VIPConfig.AimGrenade = v return true end },
            { Key = "EX_Molotov", UI = AliasMap.Switcher, Text = "AIM BOM LỬA (60m)", GetFunc = function() return _G.VIPConfig.AimMolotov end, SetFunc = function(c,v) _G.VIPConfig.AimMolotov = v return true end },
            { Key = "EX_Stun", UI = AliasMap.Switcher, Text = "AIM BOM CHOÁNG (60m)", GetFunc = function() return _G.VIPConfig.AimStun end, SetFunc = function(c,v) _G.VIPConfig.AimStun = v return true end },
            { Key = "EX_Sticky", UI = AliasMap.Switcher, Text = "AIM BOM DÍNH (60m)", GetFunc = function() return _G.VIPConfig.AimSticky end, SetFunc = function(c,v) _G.VIPConfig.AimSticky = v return true end }
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
    end

    local function EnsureInCatalog(catalog)
        if type(catalog) == "table" then
            local hasMenu = false
            for _, page in ipairs(catalog) do
                if type(page) == "table" and page.Key == "ModMenu" then hasMenu = true; break end
            end
            if not hasMenu then table.insert(catalog, 1, SettingPageDefine.ModMenu) end
        end
    end

    EnsureInCatalog(SettingCatalog)
    pcall(function() EnsureInCatalog(require("client.logic.NewSetting.SettingBattleCatalog")) end)

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            if config and config.keyName and string.find(string.lower(config.keyName), "setting") then
                local catalog = args[1]
                EnsureInCatalog(catalog)
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, select('#', ...)))
        end
        UIManager._IsMenuHooked = true
    end
end
-- ==============================================================================
-- PHẦN 3: LÕI LOGIC ĐỒ HỌA (CHAMS XUYÊN TƯỜNG, IPAD VIEW, MÔI TRƯỜNG)
-- ==============================================================================

local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 2.0) then
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

local function ApplyChams(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local hidChoice = _G.VIPState.CustomTextData.WallHid or 2
        local visChoice = _G.VIPState.CustomTextData.WallVis or 3
        
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

        if _G.VIPConfig.RemoveGrass and not _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "0")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
            _G.LastGraphicsState.RemoveGrass = true
        elseif not _G.VIPConfig.RemoveGrass and _G.LastGraphicsState.RemoveGrass then
            gi:ExecuteCMD("grass.DensityScale", "1")
            gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
            _G.LastGraphicsState.RemoveGrass = false
        end

        if _G.VIPConfig.RemoveTrees and not _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "0")
            gi:ExecuteCMD("r.Foliage.DensityScale", "0")
            gi:ExecuteCMD("r.DisableTreeRender", "1")
            _G.LastGraphicsState.RemoveTrees = true
        elseif not _G.VIPConfig.RemoveTrees and _G.LastGraphicsState.RemoveTrees then
            gi:ExecuteCMD("foliage.DensityScale", "1")
            gi:ExecuteCMD("r.Foliage.DensityScale", "1")
            gi:ExecuteCMD("r.DisableTreeRender", "0")
            _G.LastGraphicsState.RemoveTrees = false
        end
        
        if _G.VIPConfig.RemoveFog and not _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "0")           
            gi:ExecuteCMD("r.VolumetricFog", "0") 
            _G.LastGraphicsState.RemoveFog = true
        elseif not _G.VIPConfig.RemoveFog and _G.LastGraphicsState.RemoveFog then
            gi:ExecuteCMD("r.Fog", "1")           
            gi:ExecuteCMD("r.VolumetricFog", "1") 
            _G.LastGraphicsState.RemoveFog = false
        end
        
        if _G.VIPConfig.BlackSky and not _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "9999")
            _G.LastGraphicsState.BlackSky = true
        elseif not _G.VIPConfig.BlackSky and _G.LastGraphicsState.BlackSky then
            gi:ExecuteCMD("r.CylinderMaxDrawHeight", "0000")
            _G.LastGraphicsState.BlackSky = false
        end

        if _G.VIPConfig.WhiteBody and not _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "2")
            gi:ExecuteCMD("r.CharacterDiffusePower", "5")
            _G.LastGraphicsState.WhiteBody = true
        elseif not _G.VIPConfig.WhiteBody and _G.LastGraphicsState.WhiteBody then
            gi:ExecuteCMD("r.CharacterDiffuseOffset", "0")
            gi:ExecuteCMD("r.CharacterDiffusePower", "1")
            _G.LastGraphicsState.WhiteBody = false
        end
        
        if _G.VIPConfig.RemoveWater and not _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "0")
            _G.LastGraphicsState.RemoveWater = true
        elseif not _G.VIPConfig.RemoveWater and _G.LastGraphicsState.RemoveWater then
            gi:ExecuteCMD("r.Water.Enable", "1")
            _G.LastGraphicsState.RemoveWater = false
        end
    end)
end

-- ==========================================
-- LOGIC IPAD VIEW CHUẨN
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

        -- Khi mở ngắm
        if isAiming then
            if _G.VIPConfig.IpadViewScope and _G.VIPState.CustomTextData then
                local targetScope = _G.VIPState.CustomTextData.IpadViewScopeFOV or 15
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

        -- Nhả ngắm (Reset FOV PC)
        if not isInVehicle or not _G.VIPConfig.IpadViewVehicle then
            if type(pc.FOV) == "function" then pc:FOV(0) end
            if Valid(camMgr) and type(camMgr.UnlockFOV) == "function" then camMgr:UnlockFOV() end
        end

        -- Đi bộ
        if not isInVehicle then
            if _G.VIPConfig.IpadView then
                local targetTPP = _G.VIPState.CustomTextData.IpadViewFOV or 115
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            else
                if Valid(uTPPCam) and uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end

        -- Trên xe
        if isInVehicle then
            if _G.VIPConfig.IpadViewVehicle then
                local targetVeh = _G.VIPState.CustomTextData.IpadViewVehicleFOV or 130
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
-- PHẦN 4: LÕI AIM TOUCH, DỰ ĐOÁN HƯỚNG ĐẠN & AUTO TAP (FULL LOGIC)
-- ==============================================================================

local function GetEnemyTargetsFromActors(radius)
    local result = {}
    local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not ok or not GameplayData then return result end
    
    local player = GameplayData.GetPlayerCharacter()
    if not Valid(player) then return result end

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

local function HandleAimTouch()
    pcall(function()
        local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not ok or not GameplayData then return end
        
        local player = GameplayData.GetPlayerCharacter()
        local pc = Valid(player) and player:GetPlayerControllerSafety() or nil
        if not Valid(pc) then return end
        
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

        local cond, prioMode, boneIdx, speedVal, fovVal, maxDistMeters, useVisCheck, igKnock, igBot, predVal, recoilCompVal = 2, 1, 1, 50, 30, 50, false, false, false, 0, 0

        -- Logic phân loại vũ khí dựa vào Config Menu
        if isCrossbow and _G.VIPConfig.AimTouchCrossbow then
            cond, prioMode, boneIdx = 2, 1, 1
            speedVal, fovVal = 49, 15
            maxDistMeters, igKnock = 300, true
            predVal = 0
        elseif isShotgun and _G.VIPConfig.AimTouchSG then
            cond = _G.VIPConfig.AimTouchSGAutoFire and 2 or 1
            if cond == 1 and not isFiring then return end
            speedVal, fovVal = 49, 15
            maxDistMeters, useVisCheck = 30, false
        elseif isADS then
            if isSniper and _G.VIPConfig.AimTouchScopeSniper then
                cond = 2
                if cond == 1 and not isFiring then return end
                speedVal = _G.VIPState.CustomTextData.AimSnipSpd or 48
                fovVal = _G.VIPState.CustomTextData.AimSnipFov or 15
                maxDistMeters, useVisCheck = 400, false
                predVal = _G.VIPState.CustomTextData.AimSnipPred or 65
            else return end
        else
            if not _G.VIPConfig.AimTouchHipfire then return end
            cond = _G.VIPState.CustomTextData.AimTouchHipCond or 1
            prioMode = _G.VIPState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.VIPState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.VIPState.CustomTextData.AimTouchHipSpeed or 48
            fovVal = _G.VIPState.CustomTextData.AimTouchHipFOV or 15
            maxDistMeters = _G.VIPState.CustomTextData.AimTouchHipDist or 400
            predVal = _G.VIPState.CustomTextData.AimTouchHipPred or 0
            recoilCompVal = _G.VIPState.CustomTextData.AimTouchHipRecoil or 50
            if cond == 1 and not isFiring then return end 
            useVisCheck = _G.VIPConfig.AimTouchHipVisCheck or false
            igBot = _G.VIPConfig.AimTouchHipIgBot or false
            igKnock = _G.VIPConfig.AimTouchHipIgKnock or false
        end

        local enemies = GetEnemyTargetsFromActors(maxDistMeters * 100)
        if not enemies or #enemies == 0 then return end
        
        local ui_util = require("client.common.ui_util")
        local vp = ui_util and ui_util.GetViewportSize()
        if not vp then return end
        
        local centerX, centerY = vp.X * 0.5, vp.Y * 0.5
        local FOV_RADIUS = (fovVal / 100.0) * (vp.X / 2.0)
        local bestTarget, bestScore = nil, 99999999
        
        local selBoneName = (boneIdx == 1) and "head" or (boneIdx == 2) and "spine_03" or "pelvis"

        for _, target in ipairs(enemies) do
            if Valid(target) then
                if igKnock and target.HealthStatus == 1 then goto skip end
                if igBot then
                    local isAi = false
                    pcall(function() isAi = target.bIsAI or target.IsAI or (target.PlayerState and (target.PlayerState.bIsABot or target.PlayerState.bIsBot)) end)
                    if isAi then goto skip end
                end
                if useVisCheck then
                    local isVis = false
                    pcall(function() isVis = pc:LineOfSightTo(target) end)
                    if not isVis then goto skip end
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
        
        -- Logic Dự Đoán Hướng Đạn
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
        if isADS then
            local cRot = type(camMgr.GetCameraRotation) == "function" and camMgr:GetCameraRotation() or nil
            if cRot then dYaw, dPitch = dYaw - (cRot.Yaw - curRot.Yaw), dPitch - (cRot.Pitch - curRot.Pitch) end
        end

        if dYaw > 180 then dYaw = dYaw - 360 elseif dYaw < -180 then dYaw = dYaw + 360 end
        if dPitch > 180 then dPitch = dPitch - 360 elseif dPitch < -180 then dPitch = dPitch + 360 end
        
        local smooth = (speedVal >= 100) and 1.0 or math.max(0.01, (speedVal / 100.0) * 0.3)
        local fPitch, fYaw = curRot.Pitch + (dPitch * smooth), curRot.Yaw + (dYaw * smooth)
        
        -- Bù giật
        if recoilCompVal > 0 and isFiring then fPitch = fPitch - ((recoilCompVal / 50.0) * 1.5) end

        pc:SetControlRotation({ Pitch = fPitch, Yaw = fYaw, Roll = 0 }, "AimTouch")
        
        -- Shotgun Tự Động Bắn
        if isShotgun and _G.VIPConfig.AimTouchSGAutoFire then
            pcall(function()
                if (player:GetDistanceTo(bestTarget) / 100) <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    if Valid(weapon) and type(weapon.StartFire) == "function" then weapon:StartFire() end
                    _G.AutoTapState.IsAutoFiring = true
                end
            end)
        end
        
        -- AUTO TAP (Chế độ nhấp nhả)
        if _G.VIPConfig.AutoTap and isFiring then
            local tapSpeed = _G.VIPState.CustomTextData.AutoTapSpeed or 5 
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
-- PHẦN 5: LÕI WEAPON MAGIC, EXTRA ESP & TẠO GIAO DIỆN KHUNG ESP (FULL LOGIC)
-- ==============================================================================

-- [1] LOGIC WEAPON MAGIC (TÂM NHỎ & MAGIC BULLET)
local function HandleWeaponMagic(player)
    pcall(function()
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then weapon = player:GetCurrentShootWeapon() end
        if not Valid(weapon) then return end
        
        -- Logic Tâm Nhỏ
        local crosshairSize = _G.VIPState.CustomTextData.CrosshairSize or 50
        if crosshairSize < 50 and weapon.ShootWeaponComponent then
            local scale = crosshairSize / 50.0
            pcall(function() weapon.ShootWeaponComponent.BaseTargetingFOV = weapon.ShootWeaponComponent.BaseTargetingFOV * scale end)
            pcall(function() weapon.ShootWeaponComponent.RecoilKickADS = 0 end)
        end
        
        -- Logic Magic Bullet (Tăng Hitbox đạn)
        if _G.VIPConfig.CustomMagicBullet and weapon.ShootWeaponComponent then
            local magicH = _G.VIPState.CustomTextData.MagicHead or 0
            local magicB = _G.VIPState.CustomTextData.MagicBody or 0
            if magicH > 0 or magicB > 0 then
                pcall(function() weapon.ShootWeaponComponent.BulletDamageRadius = 15.0 + (magicB * 0.5) end)
            end
        end
    end)
end

-- [2] LOGIC EXTRA ESP (CẢNH BÁO BOM 60m)
local function HandleExtraESP(player, pc)
    pcall(function()
        if not _G.VIPConfig.AimGrenade and not _G.VIPConfig.AimMolotov and not _G.VIPConfig.AimStun and not _G.VIPConfig.AimSticky then return end
        
        local ok, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
        if not ok or not GameplayData then return end
        
        local UGameplayStatics = import("GameplayStatics")
        if not UGameplayStatics then return end

        local world = pc:GetWorld()
        local projectClasses = {
            { class = "ProjGrenade_C", enable = _G.VIPConfig.AimGrenade, name = "Bom Nổ" },
            { class = "ProjMolotov_C", enable = _G.VIPConfig.AimMolotov, name = "Bom Lửa" },
            { class = "ProjStun_C", enable = _G.VIPConfig.AimStun, name = "Bom Choáng" },
            { class = "ProjSticky_C", enable = _G.VIPConfig.AimSticky, name = "Bom Dính" }
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

-- [3] HỆ THỐNG VẼ ESP UMG CHUẨN (KHỞI TẠO BỘ KHUNG)
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

    -- Lấy Canvas để vẽ đè lên màn hình
    local ParentCanvas = MainControlBaseUI.CanvasPanel_0
    if not slua.isValid(ParentCanvas) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    if not slua.isValid(ParentCanvas) then return false end

    PlayerMapMarker.ESPCanvas = ParentCanvas
    return true
end

-- Hàm dọn rác bộ nhớ siêu tốc khi thoát trận hoặc tắt ESP
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

-- Hàm tạo Panel Thông Tin Địch (Tên, Khoảng Cách, Thanh Máu)
function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not slua.isValid(PlayerMapMarker.ESPCanvas) then return nil end
    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", PlayerMapMarker.ESPCanvas) end)
    if not slua.isValid(Container) then return nil end

    -- Chữ hiển thị
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

    -- Thanh máu
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
-- PHẦN 6: LÕI ESP UMG & VÒNG LẶP MAIN LOOP ĐÓNG GÓI 100%
-- ==============================================================================

-- [1] VÒNG QUÉT VÀ CẬP NHẬT GIAO DIỆN ESP LÊN MÀN HÌNH
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
                    
                    if distM <= 400 then
                        SeenKeys[pKey] = true
                        local isBot = false
                        pcall(function() isBot = enemy.bIsAI or enemy.IsAI or (enemy.PlayerState and (enemy.PlayerState.bIsABot or enemy.PlayerState.bIsBot)) end)
                        
                        local eLoc = nil
                        pcall(function() eLoc = enemy:K2_GetActorLocation() end)
                        
                        local bOnScreen = false
                        local FVector2D = import("Vector2D")
                        local screenPos = FVector2D and FVector2D() or {X=0, Y=0}
                        
                        if eLoc then
                            eLoc.Z = eLoc.Z + 85 -- Nâng tọa độ lên đỉnh đầu
                            bOnScreen = pc:ProjectWorldLocationToScreen(eLoc, screenPos, false)
                        end

                        -- [CẬP NHẬT GIAO DIỆN TÊN, MÁU, KHOẢNG CÁCH]
                        if _G.VIPConfig.EspVipPro or _G.VIPConfig.EspDistance or _G.VIPConfig.Esp7_VuKhi then
                            local ESPData = PlayerMapMarker.ESPWidgets[pKey]
                            if not ESPData then
                                ESPData = PlayerMapMarker.CreateESPWidget()
                                if ESPData then PlayerMapMarker.ESPWidgets[pKey] = ESPData end
                            end

                            if ESPData and ESPData.Container and slua.isValid(ESPData.Container) then
                                if bOnScreen then
                                    ESPData.Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
                                    ESPData.Slot:SetPosition(screenPos)
                                    
                                    -- Cập nhật Chữ
                                    local infoText = ""
                                    if _G.VIPConfig.EspVipPro then
                                        local eName = "Enemy"
                                        pcall(function() if enemy.PlayerName then eName = enemy.PlayerName elseif type(enemy.GetPlayerName) == "function" then eName = enemy:GetPlayerName() end end)
                                        infoText = eName
                                    end
                                    if _G.VIPConfig.EspDistance then infoText = infoText .. string.format(" [%dm]", math.floor(distM)) end
                                    if _G.VIPConfig.Esp7_VuKhi then
                                        pcall(function()
                                            local wpn = type(enemy.GetCurrentWeapon) == "function" and enemy:GetCurrentWeapon() or enemy.CurrentWeapon
                                            if Valid(wpn) and type(wpn.GetWeaponName) == "function" then infoText = infoText .. "\n" .. wpn:GetWeaponName() end
                                        end)
                                    end
                                    
                                    if ESPData.NameText and slua.isValid(ESPData.NameText) then
                                        ESPData.NameText:SetText(infoText)
                                        local FLinearColor = import("LinearColor") or _G.FLinearColor
                                        local tColor = isBot and (FLinearColor and FLinearColor(0,1,1,1) or {R=0,G=255,B=255,A=255}) or (FLinearColor and FLinearColor(1,1,1,1) or {R=255,G=255,B=255,A=255})
                                        local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
                                        if FSlateColor then ESPData.NameText:SetColorAndOpacity(FSlateColor(tColor)) else ESPData.NameText:SetColorAndOpacity(tColor) end
                                    end

                                    -- Cập nhật Thanh Máu
                                    if _G.VIPConfig.EspVipPro and ESPData.HealthFill and slua.isValid(ESPData.HealthFill) then
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
                            -- Dọn rác nếu tắt công tắc
                            if PlayerMapMarker.ESPWidgets[pKey] then
                                local c = PlayerMapMarker.ESPWidgets[pKey].Container
                                if slua.isValid(c) then pcall(function() c:RemoveFromParent(); c:ConditionalBeginDestroy() end) end
                                PlayerMapMarker.ESPWidgets[pKey] = nil
                            end
                        end
                        
                        -- Cảnh báo địch ngắm (Xử lý Text đỏ trên màn hình)
                        if _G.VIPConfig.EspAimWarning and distM <= 300 then
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
                                            if _G.VIPConfig.EspAimWarningVisCheck then isVis = pc:LineOfSightTo(enemy) end
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

            -- Dọn rác UI nếu địch ra khỏi tầm hoặc chết
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

-- [2] BỘ ĐỘNG CƠ CHÍNH GÓI GỌN 6 PHẦN VÀO 1 VÒNG LẶP
_G.EnemyMarkData = _G.EnemyMarkData or {}

local function MasterMainLoop()
    local curTime = os.clock()
    -- Liên tục bơm Menu chống tàng hình UI
    if not _G.VIPState.LastMenuFixTime or (curTime - _G.VIPState.LastMenuFixTime) > 2.0 then
        _G.VIPState.LastMenuFixTime = curTime
        pcall(_G.InitModMenuTab)
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = Valid(pc) and pc:GetPlayerCharacterSafety() or nil
    
    if not Valid(localPlayer) then 
        PlayerMapMarker.ClearAllESP() -- Dọn sạch rác khi ra sảnh chờ
        return 
    end

    -- Khởi chạy các Modules Đồ họa & Vũ khí
    pcall(UpdateEnvironment)
    pcall(UpdateIpadView, localPlayer, pc)
    pcall(HandleWeaponMagic, localPlayer)
    pcall(HandleExtraESP, localPlayer, pc)

    -- Khởi chạy Aim Touch
    if _G.VIPConfig.AimTouchHipfire or _G.VIPConfig.AimTouchScopeSniper or _G.VIPConfig.AimTouchSG or _G.VIPConfig.AimTouchCrossbow then
        pcall(HandleAimTouch)
    end

    -- Quét ESP UMG (Giới hạn quét 0.05s để tối ưu FPS)
    if _G.VIPConfig.EspVipPro or _G.VIPConfig.EspDistance or _G.VIPConfig.Esp7_VuKhi or _G.VIPConfig.EspAimWarning then
        if not _G.LastESPScanTime or (curTime - _G.LastESPScanTime) > 0.05 then
            _G.LastESPScanTime = curTime
            pcall(PlayerMapMarker.ScanAndUpdateESP, localPlayer, pc)
        end
    else
        PlayerMapMarker.ClearAllESP() -- Xóa lập tức khi gạt tắt
    end

    -- Khởi chạy Chams
    if _G.VIPConfig.WallXuyenTuong then
        pcall(function()
            -- Do hàm GetEnemyTargetsFromActors đã định nghĩa ở phần 4
            local enemies = GetEnemyTargetsFromActors(40000) 
            for _, enemy in ipairs(enemies) do
                local pKey = tostring(enemy.PlayerKey or enemy:GetUniqueID())
                _G.EnemyMarkData[pKey] = _G.EnemyMarkData[pKey] or {}
                ApplyChams(enemy, _G.EnemyMarkData[pKey])
            end
        end)
    else
        for _, data in pairs(_G.EnemyMarkData) do UndoChams(data.enemy, data) end
    end
end

-- [3] HÀM KÍCH NỔ NHỊP TIM
_G.FastTick = function() 
    -- Chốt chặn Auth siêu cứng: Fake token là đứt bóng
    if not _G._Authenticated_ or _G.myToken ~= _G.VIPState.LoopToken then return end
    
    pcall(MasterMainLoop) 
    
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.01, _G.FastTick) 
    end 
end
