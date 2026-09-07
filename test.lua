-- ==============================================================================
-- BẢN FULL MOD SIÊU TỐI ƯU (CÓ ĐẠN MA, CHAMS, XÓA CỎ, IPAD VIEW)
-- ==============================================================================

local function Notify(msg) 
    local s = "[AKMOD VIP] " .. tostring(msg)
    pcall(function() if _G.ngocdoianNotify then _G.ngocdoianNotify(s) end end)
    pcall(function() local sh = import("ScriptHelperClient") if sh and sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1, G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) 
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

local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}

_G.ngocdoianConfig = _G.ngocdoianConfig or { 
    EspVipPro = false, EspDistance = false, EspLoai5 = false, Esp7_VuKhi = false, AimTouchEnable = false,
    IpadView = false, BugManEnable = false,
    -- Hàng nặng ní order đây:
    ColorBodyV3 = false, ColorBodyNew = false,
    RemoveGrass = false, RemoveFog = false, CustomMagicBullet = false
}

_G.ngocdoianState = _G.ngocdoianState or { 
    LoopToken = 0, NativeESPReady = false, GraphicsUnlocked = false, MenuStep = 0, 
    TrackedMarks = {}, EnemyMarks = {}, PrevGraphicsState = {},
    LastMagicConfigHash = "", MagicUpdateVersion = 1,
    CustomTextData = {
        IpadViewFOV = 120, BugManRatio = 133,
        ColorV3Hidden = 1, ColorV3Visible = 2, ColorV3Thickness = 4,
        MagicHead = 1.05, MagicBody = 1.0, MagicLegs = 1.0
    }
}

-- Hàm lấy xương để vẽ Chams
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
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
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

local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.ngocdoianState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then InGameMarkTools.HideMapMark(mark) end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then InGameMarkTools.RemoveMapMark(mark) end
    end)
    _G.ngocdoianState.TrackedMarks[mark] = nil
end

local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    local FakeTextMap = { [999000] = "MENU MOD ADMIN", [999001] = "CHỨC NĂNG ESP", [999002] = "AIMBOT & VŨ KHÍ", [999004] = "HỖ TRỢ GAME" }
    local LocUtil = _G.LocUtil or package.loaded["client.common.LocUtil"] and require("client.common.LocUtil")
    if LocUtil and not LocUtil._IsModMenuHooked_V2 then
        local hookFuncs = {"GetLocalizeResStr", "GetText", "GetTextByID", "GetLocalText", "GetLocalizeStr"}
        for _, fn in ipairs(hookFuncs) do
            if LocUtil[fn] then
                local old = LocUtil[fn]
                LocUtil[fn] = function(id) return FakeTextMap[id] or (old and old(id)) or (type(id) == "string" and not tonumber(id) and id) or "" end
            end
        end
        LocUtil._IsModMenuHooked_V2 = true
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")

    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")

        local StackESP = {
            { Key = "ModMenu_ESP_Mau", UI = AliasMap.Switcher, Text = "ESP THANH MÁU", GetFunc = function() return _G.ngocdoianConfig.EspVipPro end, SetFunc = function(c,v) _G.ngocdoianConfig.EspVipPro = v return true end },
            { Key = "ModMenu_ESP_KhoangCach", UI = AliasMap.Switcher, Text = "ESP KHOẢNG CÁCH", GetFunc = function() return _G.ngocdoianConfig.EspDistance end, SetFunc = function(c,v) _G.ngocdoianConfig.EspDistance = v return true end },
            { Key = "ModMenu_ESP_Box", UI = AliasMap.Switcher, Text = "ESP BOX", GetFunc = function() return _G.ngocdoianConfig.EspLoai5 end, SetFunc = function(c,v) _G.ngocdoianConfig.EspLoai5 = v return true end },
            { Key = "ModMenu_ColorV3", UI = AliasMap.Switcher, Text = "CHAMS MÀU V3 (Tùy chỉnh)", GetFunc = function() return _G.ngocdoianConfig.ColorBodyV3 end, SetFunc = function(c,v) _G.ngocdoianConfig.ColorBodyV3 = v return true end },
            { Key = "ModMenu_ColorNew", UI = AliasMap.Switcher, Text = "CHAMS MÀU NEW (Xanh/Đỏ)", GetFunc = function() return _G.ngocdoianConfig.ColorBodyNew end, SetFunc = function(c,v) _G.ngocdoianConfig.ColorBodyNew = v return true end },
        }
        local StackAimbotV2 = {
            { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Bật Aimbot Roy & Custom", ExpandIndex = 0, GetFunc = function() return _G.ngocdoianConfig.AimTouchEnable end, SetFunc = function(c,v) _G.ngocdoianConfig.AimTouchEnable = v return true end },
            { Key = "ModMenu_MagicBullet", UI = AliasMap.Switcher, Text = "ĐẠN MA (Magic Bullet)", GetFunc = function() return _G.ngocdoianConfig.CustomMagicBullet end, SetFunc = function(c,v) _G.ngocdoianConfig.CustomMagicBullet = v return true end }
        }
        local StackCombat = {
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Ipad View", ExpandIndex = 0, GetFunc = function() return _G.ngocdoianConfig.IpadView end, SetFunc = function(c,v) _G.ngocdoianConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   Góc Nhìn FOV", ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, GetFunc = function() return (_G.ngocdoianState.CustomTextData.IpadViewFOV or 120) - 90 end, SetFunc = function(c,v) _G.ngocdoianState.CustomTextData.IpadViewFOV = 90 + v return true end },
            { Key = "ModMenu_RemoveGrass", UI = AliasMap.Switcher, Text = "XÓA CỎ", GetFunc = function() return _G.ngocdoianConfig.RemoveGrass end, SetFunc = function(c,v) _G.ngocdoianConfig.RemoveGrass = v return true end },
            { Key = "ModMenu_RemoveFog", UI = AliasMap.Switcher, Text = "XÓA SƯƠNG MÙ", GetFunc = function() return _G.ngocdoianConfig.RemoveFog end, SetFunc = function(c,v) _G.ngocdoianConfig.RemoveFog = v return true end },
            { Key = "ModMenu_BugMan_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Kéo Dãn Màn Hình (Nhân Vật Mập)", ExpandIndex = 0, GetFunc = function() return _G.ngocdoianConfig.BugManEnable end, SetFunc = function(c,v) _G.ngocdoianConfig.BugManEnable = v return true end },
            { Key = "ModMenu_BugMan_Ratio", UI = AliasMap.Slider, Text = "   Độ Kéo Dãn", ExpandHandle = "ModMenu_BugMan_Ex", MinValue = 110, MaxValue = 200, GetFunc = function() return _G.ngocdoianState.CustomTextData.BugManRatio or 133 end, SetFunc = function(c,v) _G.ngocdoianState.CustomTextData.BugManRatio = v return true end }
        }

        SettingPageDefine.ModMenu = {
            Key = "ModMenu", Text = 999000, UIKey = "Setting_Page_Privacy", 
            Category = {
                { Key = "Cat_ESP", Text = 999001, Stack = StackESP },
                { Key = "Cat_AimbotV2", Text = 999002, Stack = StackAimbotV2 },
                { Key = "Cat_Combat", Text = 999004, Stack = StackCombat }
            }
        }
        table.insert(SettingCatalog, 1, SettingPageDefine.ModMenu)
    end
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
                        if type(page) == "table" and page.Key == "ModMenu" then hasModMenu = true break end
                    end
                    if not hasModMenu then table.insert(catalog, 1, SettingPageDefine.ModMenu) end
                end
            end
        end
        return old_ShowUI(config, table.unpack(args, 1, n))
    end
    UIManager._IsModMenuHooked = true
end

local function ShowngocdoianVIPMenu() 
    if _G.ngocdoianMenuAlreadyShown then return end
    if _G.ngocdoianState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end
        if _G.InitModMenuTab then _G.InitModMenuTab() end

        Msg.Show(1, "BẢN DEMO ADMIN", "Bản Demo trải nghiệm tính năng.\nTham gia nhóm Telegram để nhận bản cập nhật mới nhất nhé!", 
        function() 
            local Web = require("client.slua.logic.url.logic_webview_sdk")
            if Web and Web.OpenURL then Web:OpenURL("https://t.me/hackmodpubgmobile") end 
        end, function() end, "THAM GIA", "ĐÓNG")

        _G.ngocdoianState.MenuStep = 99
        _G.ngocdoianMenuAlreadyShown = true
    end)
end

-- ========================================== 
-- HỆ THỐNG VẼ ESP & NATIVE
-- ========================================== 
local function InitializeNativeESP() 
    if _G.ngocdoianState.NativeESPReady then return end
    pcall(function() 
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools") 
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig") 
        local function ApplyCfg(cfg)
            if not cfg then return end 
            if cfg[1006] then 
                cfg[1006].bBindBlocked = true; cfg[1006].bBindOutScreen = true; cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000; cfg[1006].bScaleByDistance = false; cfg[1006].BindSocketName = "root"
                cfg[1006].bUseLuaWorldSocketName = true; cfg[1006].WorldPositionOffset = FVector(0, 0, -30) 
            end 
        end 
        ApplyCfg(currentMarkCfg) 
        for k, cfg in pairs(package.loaded) do 
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then ApplyCfg(cfg) end 
        end 
    end)
    _G.ngocdoianState.NativeESPReady = true 
end

-- ========================================== 
-- CHAMS V3 VÀ NEW ENGINE
-- ========================================== 
local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local cData = _G.ngocdoianState.CustomTextData or {}
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
                pcall(function() comp.UseScopeDistanceCulling = false; comp.PrimitiveShadingStrategy = 1; comp.ShadingRate = 6 end)
                
                for i = 0, 10 do
                    local matInterface = comp:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then baseMat.bDisableDepthTest = true; baseMat.BlendMode = 2 end
                    
                    local currentCached = markData.MIDs_V3[compKey][i]
                    local needUpdateColor = false
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then markData.MIDs_V3[compKey][i] = newMid; currentCached = newMid; needUpdateColor = true end
                    elseif colorChanged then needUpdateColor = true end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
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
            markData.ColorV3Applied = false
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
        markData.ColorNewApplied = true
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local c_vis = LinearColorClass and LinearColorClass(0, 100, 0, 1) or {R=0, G=100, B=0, A=1}
        local c_occ = LinearColorClass and LinearColorClass(100, 0, 0, 1) or {R=100, G=0, B=0, A=1}

        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true); mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(c_vis); mesh:SetOccludedDyeingColor(c_occ)
                        mesh:SetDrawHighlight(true); mesh:OverrideHighlightColor(c_vis)
                        mesh:SetHighlightCanBeOccluded(false)
                        mesh:SetDrawIdeaOutline(true); mesh:SetIdeaOutlineNew(true)
                        mesh:OverrideIdeaOutlineColor(c_vis); mesh:SetIdeaOutlineOcclusionColor(c_occ)
                        mesh:OverrideIdeaOutlineThickness(20.0); mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true); mesh:SetCustomDepthStencilValue(255)
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
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false); mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false); mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
        end
    end)
end

-- ========================================== 
-- HỆ THỐNG AIMBOT V2
-- ========================================== 
_G.GetEnemyTargetsFromActors = function(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end

    local myTeam = player:GetTeamID()
    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then table.insert(result, actor) end
            end
        end
    end
    return result
end

_G.AimTouch = function()
    pcall(function()
        if not _G.ngocdoianConfig.AimTouchEnable then return end
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        if not isFiring then return end 

        local currentMaxDist = 30000 
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
        local FOV_RADIUS = (30 / 100.0) * (viewportSize.X / 2.0) 
        
        local bestTarget = nil
        local bestScore = 99999999 

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            if target.HealthStatus == 1 then goto continue end 
            
            local tPos = target:GetBonePos("head", {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            if distScreen < bestScore then
                bestScore = distScreen
                bestTarget = target
            end
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        local finalBonePos = bestTarget:GetBonePos("head", {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.4
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)

        pc:SetControlRotation({ Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }, "AimTouch")
    end)
end

-- ========================================== 
-- VÒNG LẶP CHÍNH (MAIN LOOP)
-- ========================================== 
local function MainLoop()
    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData") 
    if not okData or not GameplayData then return end 
    local pc = GameplayData.GetPlayerController() 
    local localPlayer = nil
    if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end 

    if not Valid(localPlayer) then 
        if _G.ngocdoianState.TrackedMarks then
            for markId, _ in pairs(_G.ngocdoianState.TrackedMarks) do SafeRemoveMark(markId) end
        end
        _G.ngocdoianState.TrackedMarks = {} 
        _G.ngocdoianState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        return 
    end

    InitializeNativeESP()
    _G.InitModMenuTab() 
    
    if _G.ngocdoianConfig.IpadView and _G.ngocdoianState.CustomTextData then
        pcall(function()
            local targetTPP = _G.ngocdoianState.CustomTextData.IpadViewFOV or 120
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

    if _G.ngocdoianConfig.AimTouchEnable then _G.AimTouch() end

    -- LOGIC CỎ & SƯƠNG MÙ
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then
            if _G.ngocdoianConfig.RemoveGrass and not _G.ngocdoianState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "0")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "1")
                _G.ngocdoianState.PrevGraphicsState.RemoveGrass = true
            elseif not _G.ngocdoianConfig.RemoveGrass and _G.ngocdoianState.PrevGraphicsState.RemoveGrass then
                gi:ExecuteCMD("grass.DensityScale", "1")
                gi:ExecuteCMD("grass.DiscardDataOnLoad", "0")
                _G.ngocdoianState.PrevGraphicsState.RemoveGrass = false
            end
            
            if _G.ngocdoianConfig.RemoveFog and not _G.ngocdoianState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") ; gi:ExecuteCMD("r.Fog", "0") ; gi:ExecuteCMD("r.VolumetricFog", "0") 
                _G.ngocdoianState.PrevGraphicsState.RemoveFog = true
            elseif not _G.ngocdoianConfig.RemoveFog and _G.ngocdoianState.PrevGraphicsState.RemoveFog then
                gi:ExecuteCMD("r.SkyAtmosphere", "1") ; gi:ExecuteCMD("r.Fog", "1") ; gi:ExecuteCMD("r.VolumetricFog", "1") 
                _G.ngocdoianState.PrevGraphicsState.RemoveFog = false
            end
        end
    end)

    -- LOGIC MAGIC BULLET XỬ LÝ HITBOX
    local mHead_Global, mBody_Global, mLegs_Global = 1.0, 1.0, 1.0
    local runInject_Global = false
    pcall(function()
        if _G.ngocdoianConfig.CustomMagicBullet then
            runInject_Global = true
            mHead_Global = 1.05; mBody_Global = 1.0; mLegs_Global = 1.0
        end

        if runInject_Global then
            local currentMagicHash = "M_"..tostring(mHead_Global)
            if _G.ngocdoianState.LastMagicConfigHash ~= currentMagicHash then
                _G.ngocdoianState.MagicUpdateVersion = (_G.ngocdoianState.MagicUpdateVersion or 0) + 1
                _G.ngocdoianState.LastMagicConfigHash = currentMagicHash
            end
        else
            if _G.ngocdoianState.LastMagicConfigHash ~= "OFF" then
                _G.ngocdoianState.MagicUpdateVersion = (_G.ngocdoianState.MagicUpdateVersion or 0) + 1
                _G.ngocdoianState.LastMagicConfigHash = "OFF"
            end
        end
    end)

    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end
        
        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then currentValidKeys[GetSafeEnemyKey(enemy)] = true end
        end
        
        for key, data in pairs(_G.ngocdoianState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.hpMark); SafeRemoveMark(data.distMark)
                data.enemy = nil; _G.ngocdoianState.EnemyMarks[key] = nil
            end
        end

        local BoneScaleMap = { ["head"] = mHead_Global, ["neck_01"] = mHead_Global }
        
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                    elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.ngocdoianState.EnemyMarks[eKey] = _G.ngocdoianState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.ngocdoianState.EnemyMarks[eKey]
                markData.enemy = enemy 

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        markData.lastEnemyActor = enemy
                    end
                    
                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)

                    -- CHAMS MÀU
                    if _G.ngocdoianConfig.ColorBodyV3 then ApplyColorBodyV3(enemy, markData) else UndoColorBodyV3(enemy, markData) end
                    if _G.ngocdoianConfig.ColorBodyNew then ApplyColorBodyNew(enemy, markData) else UndoColorBodyNew(enemy, markData) end

                    -- KÉO DÃN MÀN HÌNH
                    pcall(function()
                        if Valid(eMesh) then
                            local targetScale = 1.0
                            if _G.ngocdoianConfig.BugManEnable and _G.ngocdoianState.CustomTextData then
                                targetScale = 177.0 / (_G.ngocdoianState.CustomTextData.BugManRatio or 133)
                                if targetScale < 1.0 then targetScale = 1.0 end
                                if targetScale > 2.0 then targetScale = 2.0 end 
                            end
                            if markData.LastFatScale ~= targetScale then
                                eMesh:SetRelativeScale3D(FVector(targetScale, targetScale, 1.0))
                                markData.LastFatScale = targetScale
                            end
                        end
                    end)

                    -- ĐẠN MA MAGIC BULLET (Sửa Hitbox)
                    pcall(function()
                        local EnemyMesh = eMesh
                        if slua.isValid(EnemyMesh) then
                            local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)
                            if markData.MagicBulletHash == _G.ngocdoianState.LastMagicConfigHash and markData.MagicTargetID == uniqueID then return end

                            local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                            if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset end

                            if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                                if not _G.AK_ModdedPhysAssets then _G.AK_ModdedPhysAssets = {} end
                                local PhysAssetName = "DefaultPhys"
                                pcall(function() PhysAssetName = PhysicsAsset:GetName() end)
                                
                                if _G.AK_ModdedPhysAssets[PhysAssetName] ~= _G.ngocdoianState.LastMagicConfigHash then
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
                                            for k, _ in pairs(BoneScaleMap) do if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end end

                                            if MatchedBoneKey then
                                                local TargetScale = 1.0 
                                                if runInject_Global then TargetScale = BoneScaleMap[MatchedBoneKey] end
                                                local AggGeom = BodySetup.AggGeom
                                                local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                                
                                                local function GetFirstElemSafe(elemArray)
                                                    if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                                                        if type(elemArray.Get) == "function" then return elemArray:Get(0) end
                                                    elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then return elemArray[1] end
                                                    return nil
                                                end

                                                local SphereElem = GetFirstElemSafe(SphereElems)

                                                if not OrigHitboxData[MatchedBoneKey] then
                                                    OrigHitboxData[MatchedBoneKey] = { Sphere = nil }
                                                    if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                                end

                                                local OrigElemData = OrigHitboxData[MatchedBoneKey]
                                                if OrigElemData.Sphere and SphereElem then
                                                    SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                    if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                    if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                end
                                            end
                                        end
                                    end
                                    _G.AK_ModdedPhysAssets[PhysAssetName] = _G.ngocdoianState.LastMagicConfigHash
                                end
                                
                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset
                                markData.MagicBulletHash = _G.ngocdoianState.LastMagicConfigHash
                                markData.MagicTargetID = uniqueID 
                            end
                        end
                    end)

                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    pcall(function()
                        if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                        if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                    end)
                    if maxHp <= 0 then maxHp = 100 end
                    local hpRatio = currentHp / maxHp

                    -- VẼ ESP MÁU THEO TỌA ĐỘ 3D VÀ UI CỦA NATIVE
                    if _G.ngocdoianConfig.EspVipPro and pc and pc.MyHUD then
                        pcall(function()
                            local hud = pc.MyHUD
                            if Valid(hud) and hud.AddDebugText and distM <= 400 then
                                local dynamicScale = math.max(0.55, 0.95 - (distM / 400))
                                local isKnock = (currentHp <= 0 and enemy.HealthStatus == 1)
                                local hpColor = C_GREEN
                                if hpRatio < 0.3 then hpColor = C_RED elseif hpRatio < 0.7 then hpColor = C_YELLOW end
                                if isKnock then hpColor = C_RED end
                                
                                local enemyName = "Enemy"
                                pcall(function() if enemy.PlayerName then enemyName = enemy.PlayerName elseif type(enemy.GetPlayerName) == "function" then enemyName = enemy:GetPlayerName() end end)
                                if isKnock then enemyName = "KNOCK: " .. enemyName end
                                hud:AddDebugText(enemyName, enemy, 0.06, {X=0, Y=0, Z=-370}, {X=0, Y=0, Z=-370}, C_WHITE, true, false, true, nil, dynamicScale * 1.1, true)
                                
                                if not isKnock then
                                    local segments = 6
                                    local filled = math.floor(hpRatio * segments)
                                    for j = 1, segments do
                                        local color = (j <= filled) and hpColor or {R=30,G=30,B=30,A=180}
                                        hud:AddDebugText("█", enemy, 0.06, {X=0, Y=-115, Z=20 + (j * 10.0 * dynamicScale)}, {X=0, Y=-115, Z=20 + (j * 10.0 * dynamicScale)}, color, true, false, true, nil, dynamicScale * 1.2, true)
                                    end
                                    hud:AddDebugText(string.format("%d%%", math.floor(hpRatio * 100)), enemy, 0.06, {X=0, Y=-60, Z=8}, {X=0, Y=-60, Z=8}, hpColor, true, false, true, nil, dynamicScale * 0.8, true)
                                else
                                    hud:AddDebugText("DOWN", enemy, 0.06, {X=0, Y=-115, Z=50}, {X=0, Y=-115, Z=50}, C_RED, true, false, true, nil, dynamicScale * 1.0, true)
                                end
                            end
                        end)
                    end

                    if _G.ngocdoianConfig.EspDistance and pc and pc.MyHUD then
                        pcall(function()
                            if distM <= 400 then
                                pc.MyHUD:AddDebugText(string.format("[%dm]", math.floor(distM)), enemy, 0.06, {X=0, Y=115, Z=20}, {X=0, Y=115, Z=20}, C_BLUE_TEXT, true, false, true, nil, math.max(0.55, 0.95 - (distM / 400)) * 1.5, true)
                            end
                        end)
                    end

                    if _G.ngocdoianConfig.EspLoai5 then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                    else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.hpMark); markData.hpMark = nil
                        SafeRemoveMark(markData.distMark); markData.distMark = nil
                        markData.IsCleanedUp = true
                    end
                end
            end
        end
    end)
end

_G.ngocdoianState.LoopToken = (_G.ngocdoianState.LoopToken or 0) + 1 
_G.myToken = _G.ngocdoianState.LoopToken

-- =======================================================
-- HỆ THỐNG CHECK KEY AKMOD VIP
-- =======================================================
_G._Authenticated_ = false

_G.FastTick = function() 
    if not _G._Authenticated_ then return end 
    if _G.myToken ~= _G.ngocdoianState.LoopToken then return end
    pcall(MainLoop) 
    local okTicker, ticker = pcall(require, "common.time_ticker") 
    if okTicker and ticker and ticker.AddTimerOnce then 
        ticker.AddTimerOnce(0.05, _G.FastTick) 
    end 
end

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
  end)
end

local function ForceStart()
    if _G.InitModMenuTab then _G.InitModMenuTab() end
    if ShowngocdoianVIPMenu then ShowngocdoianVIPMenu() end
    if _G.FastTick then _G.FastTick() end
end

-- =======================================================
-- BYPASS AUTH SERVER - MOD BY CHUYÊN GIA
-- =======================================================
local function LoadCloud()
    if _G._Authenticated_ then return end
    
    -- Hack thẳng vào biến hệ thống, ép nó tin là mình đã mua Key VIP
    _G._Authenticated_ = true                
    
    -- Kích hoạt Menu và Aimbot
    ForceStart()
    
    -- In thông báo khè bạn bè
    _G.AkmodNotify("Bypass Server Thành Công! Chúc ní quẩy rank vui vẻ!")
end

-- Kích nổ tự động sau 1 giây vào game
pcall(function() 
    local ok_t, time_ticker = pcall(require, "common.time_ticker")
    if ok_t and time_ticker and time_ticker.AddTimerOnce then
        time_ticker.AddTimerOnce(1.0, LoadCloud) 
    end
end)
