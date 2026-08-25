

-- ==========================================
-- 1. HỆ THỐNG THÔNG BÁO CHUẨN XỊN
-- ==========================================
_G._Authenticated_ = false
_G.AuthChecking = false
_G.AuthTriggered = false

_G.AkmodNotify = function(msg)
  print("[AKMOD_VIP] " .. tostring(msg))
  pcall(function()
    local s4, LocUtil = pcall(require, "common.loc_util")
    if s4 and LocUtil and LocUtil.ShowNotice then LocUtil.ShowNotice("AKMOD: " .. msg) end

    local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    if s3 and IngameTipsTools then
      if IngameTipsTools.BattleNormalTips then IngameTipsTools.BattleNormalTips("AKMOD: " .. msg, 2, 3) end
      if string.find(msg, "Lỗi") or string.find(msg, "Thất bại") or string.find(msg, "Từ chối") then
        if IngameTipsTools.ShowMsgBox then IngameTipsTools.ShowMsgBox(1, "AKMOD BẢO MẬT", msg) end
      end
    end

    local s, GD = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if s and GD then
      local uPC = GD.GetPlayerController()
      if uPC then
        local s2, STExtra = pcall(import, "STExtraBlueprintFunctionLibrary")
        if s2 and STExtra then
          local chatComp = STExtra.GetChatComponentFromController(uPC)
          if chatComp and chatComp.AddMsgInClient then chatComp:AddMsgInClient("<ChatQuickMsg>" .. msg .. "</>") end
        end
      end
    end
  end)
end

-- ==========================================
-- 2. HỆ THỐNG XÁC THỰC API CHỐNG CLOUDFLARE
-- ==========================================
local function urlencode(str)
    if str then
        str = tostring(str)
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function EngineUnpack(str)
    if not str or str == "" then return nil end
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s = str:gsub('[\r\n%s]', ''):gsub('%-', '+'):gsub('_', '/')
    local pad = #s % 4
    if pad > 0 then s = s .. string.rep('=', 4 - pad) end
    local b = {}
    for i = 1, #s, 4 do
        local c1 = b64chars:find(s:sub(i, i), 1, true) - 1
        local c2 = b64chars:find(s:sub(i+1, i+1), 1, true) - 1
        local c3 = (b64chars:find(s:sub(i+2, i+2), 1, true) or 1) - 1
        local c4 = (b64chars:find(s:sub(i+3, i+3), 1, true) or 1) - 1
        local n = (c1 * 262144) + (c2 * 4096) + (c3 * 64) + c4
        b[#b+1] = string.char(math.floor(n / 65536) % 256)
        if s:sub(i+2, i+2) ~= '=' then b[#b+1] = string.char(math.floor(n / 256) % 256) end
        if s:sub(i+3, i+3) ~= '=' then b[#b+1] = string.char(n % 256) end
    end
    local raw = table.concat(b)
    local K = {0x7B, 0x21, 0xC5, 0xE2, 0x9A, 0x3F, 0x44, 0x10, 0xD8, 0x6C, 0xB2, 0x0E, 0x55, 0xA9, 0x71, 0x3D}
    local out = {}
    local bxor = bit and bit.bxor or bit32 and bit32.bxor
    if not bxor then
        bxor = function(a, x)
            local r, m = 0, 128
            while m >= 1 do
                local va = a >= m and 1 or 0
                local vb = x >= m and 1 or 0
                if va ~= vb then r = r + m end
                if a >= m then a = a - m end
                if x >= m then x = x - m end
                m = m / 2
            end
            return r
        end
    end
    for i = 1, #raw do out[#out+1] = string.char(bxor(string.byte(raw, i), K[((i - 1) % 16) + 1])) end
    return table.concat(out)
end

function _G.ForceStart()
    if _G._Authenticated_ or _G.AuthChecking then return end
    _G.AuthChecking = true

    local M_Manager = _G.ModuleManager or package.loaded["client.logic.module.ModuleManager"] or require("client.logic.module.ModuleManager")
    if not M_Manager then pcall(function() M_Manager = require("GameLua.GameCore.ModuleManager") end) end
    local http_manager = M_Manager and M_Manager.CommonModuleConfig and M_Manager.GetModule(M_Manager.CommonModuleConfig.http_manager)
    
    if not http_manager then 
        _G.AkmodNotify("Lỗi: Không tải được công cụ mạng!")
        _G.AuthChecking = false
        return 
    end

    local userKey = ""
    local paths = {
        "Paks/AKMOD_VIP_KEY.txt", "AKMOD_VIP_KEY.txt", 
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/AKMOD_VIP_KEY.txt",
        "//storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/AKMOD_VIP_KEY.txt"
    }

    for _, path in ipairs(paths) do
        pcall(function()
            local sysLib = import("KismetSystemLibrary")
            if sysLib and sysLib.LoadFileToString then userKey = sysLib.LoadFileToString(path) end
        end)
        if not userKey or userKey == "" then
            pcall(function() local f = io.open(path, "r"); if f then userKey = f:read("*a"); f:close() end end)
        end
        if userKey and userKey ~= "" then userKey = userKey:gsub("%s+", ""); break end
    end

    if not userKey or userKey == "" then 
        _G.AkmodNotify("Lỗi: Không tìm thấy file AKMOD_VIP_KEY.txt!")
        _G.AuthChecking = false
        return 
    end

    local hwid = "UNKNOWN_DEVICE"
    pcall(function()
        if Client and Client.GetPhoneDeviceID then hwid = tostring(Client.GetPhoneDeviceID()) end
        if hwid == "nil" or hwid == "UNKNOWN_DEVICE" then
            local sysLib = import("KismetSystemLibrary")
            if sysLib and sysLib.GetDeviceId then hwid = tostring(sysLib.GetDeviceId()) end
        end
    end)

    _G.AkmodNotify("Đang xác thực Key lên Server...")

    local serverUrl = string.find(string.upper(userKey), "FREE") and "https://akmod.online/api/check_free" or "https://akmod.online/api/check_vip"
    local headers = { 
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Accept"] = "application/json",
        ["x-akmod-auth"] = "####ngocdoianXnanamod96####",
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    local postData = "key=" .. urlencode(userKey) .. "&hwid=" .. urlencode(hwid) .. "&game_id=LUAPAK"

    http_manager:Post(serverUrl, headers, postData, nil, function(success, data, content, result)
        _G.AuthChecking = false
        if not success then
            _G.AkmodNotify("Lỗi mạng: Không thể kết nối Server (" .. tostring(result) .. ")")
            return
        end
        
        local rawData = data
        if data and not data:find('{"status"') then
            local unpacked = EngineUnpack(data)
            if unpacked and unpacked:find('{"status"') then rawData = unpacked end
        end

        local sData = tostring(rawData)
        local statusVal = sData:match('"status"%s*:%s*(true)') or sData:match('"status"%s*:%s*(1[^%d])')
        local reasonVal = sData:match('"msg"%s*:%s*"([^"]+)"')

        if statusVal then
            _G._Authenticated_ = true
            _G.AkmodNotify("XÁC THỰC THÀNH CÔNG! Bật Cài Đặt Game Lên Nhé.")
            if _G.InitModMenuTab then _G.InitModMenuTab() end
            if _G.StartFastTick then _G.StartFastTick() end
        else
            _G.AkmodNotify("TỪ CHỐI: " .. (reasonVal or "Key hết hạn hoặc sai mã máy!"))
        end
    end, 30)
end

-- ==========================================
-- 3. CÁC HÀM BỔ TRỢ ESP
-- ==========================================
function _G.CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT end
    local isAI = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true or (type(pawn.IsBot) == "function" and pawn:IsBot()) then isAI = true end
        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if pState and (pState.bIsABot or pState.bIsBot or (type(pState.IsBot) == "function" and pState:IsBot())) then isAI = true end
    end)
    markData.AK_IS_BOT = isAI
    return isAI
end

function _G.GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

function _G.SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local mgr = import("ScreenMarkManager").GetInstance()
        if mgr and mgr.AddMark then mark = mgr:AddMark(id, pos, z, str, size, actor) end
    end)
    return mark
end

function _G.SafeRemoveMark(markId)
    if not markId or markId == 0 then return end
    pcall(function()
        local mgr = import("ScreenMarkManager").GetInstance()
        if mgr and mgr.RemoveMark then mgr:RemoveMark(markId) end
    end)
end

-- ==========================================
-- 4. CONFIG MENU & TÍNH NĂNG CHÍNH
-- ==========================================
_G.XthrlenConfig = _G.XthrlenConfig or { EspVip = false, AimTouchEnable = false, CustomAimbot = false, AimTouchHipfire = false }
_G.XthrlenState = _G.XthrlenState or { EnemyMarks = {}, CustomTextData = {}, LoopToken = 0 }

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true
    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    
    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
        local StackESP = {
            { Key = "ModMenu_ESP1", UI = AliasMap.Switcher, Text = "BẬT KHUNG & MÁU (ESP VIP)", GetFunc = function() return _G.XthrlenConfig.EspVip end, SetFunc = function(c,v) _G.XthrlenConfig.EspVip = v return true end }
        }
        SettingPageDefine.ModMenu = { Key = "ModMenu", Text = "AKMOD VIP", UIKey = "Setting_Page_Privacy", Category = { { Key = "Cat_ESP", Text = "MENU ESP TÍNH NĂNG", Stack = StackESP } } }
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
    end
end

local function MainLoop()
    if not _G._Authenticated_ then return end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = Valid(pc) and pc:GetPlayerCharacterSafety() or nil

    if not Valid(localPlayer) then return end
    
    pcall(function()
        local allCharacters = GameplayData.GetAllPlayerCharacters and GameplayData.GetAllPlayerCharacters() or GameplayData.GameCharacters or {}
        local myTeam = type(localPlayer.GetTeamID) == "function" and localPlayer:GetTeamID() or localPlayer.TeamID or 0

        for _, enemy in pairs(allCharacters) do
            local eTeam = type(enemy.GetTeamID) == "function" and enemy:GetTeamID() or enemy.TeamID or 0
            if Valid(enemy) and enemy ~= localPlayer and eTeam ~= myTeam then
                local bIsReallyDead = false
                pcall(function() bIsReallyDead = (type(enemy.IsDead) == "function" and enemy:IsDead()) or enemy.bIsDead or enemy.bIsDeadFlag or (enemy.HealthStatus == 2) end)
                
                local eKey = _G.GetSafeEnemyKey(enemy)
                _G.XthrlenState.EnemyMarks[eKey] = _G.XthrlenState.EnemyMarks[eKey] or {}
                local markData = _G.XthrlenState.EnemyMarks[eKey]
                
                if not bIsReallyDead then
                    if _G.XthrlenConfig.EspVip then
                        if not markData.hpMark then markData.hpMark = _G.SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then _G.SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                    end
                else
                    if markData.hpMark then _G.SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                end
            end
        end
    end)
end

_G.StartFastTick = function()
    if not _G._Authenticated_ then return end
    pcall(MainLoop)
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(0.05, _G.StartFastTick) end 
end

-- ==========================================
-- 5. CÁC HÀM CỦA DATA GỐC BRPLAYERCHARACTERBASE
-- ==========================================
function BRPlayerCharacterBase:ctor() end
function BRPlayerCharacterBase:_PostConstruct() BRPlayerCharacterBase.__super._PostConstruct(self); self:InitAddSpecialMoveInfo(); self.bCanNearDeathGiveup = true end
function BRPlayerCharacterBase:ReceiveBeginPlay()
    BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    if Client then GameplayData.AddCharacter(self.Object) end
end
function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
    BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
    if Client then GameplayData.RemoveCharacter(self.Object) end
end
function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue() self:HandleNearDeathGiveupRescue() end
function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
    local uNearDeathComp = self.NearDeatchComponent
    if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
        local uPlayerState = self:GetPlayerStateSafety()
        if slua.isValid(uPlayerState) then uPlayerState:AddGeneralCount(1613, 1, false) end
        uNearDeathComp:TriggerGotoDieExplictly(self.Object)
    end
end

-- ====================================================================
-- [C4 KÍCH NỔ] ÉP CHẠY NGAY TỨC THÌ TỪ LÚC LOAD FILE XONG
-- ====================================================================
pcall(function()
    if not _G.AuthTriggered then
        _G.AuthTriggered = true
        _G.ForceStart()
    end
end)
