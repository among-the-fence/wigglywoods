--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["5"] = 1,["6"] = 1,["7"] = 3,["8"] = 4,["9"] = 5,["10"] = 6,["11"] = 7,["12"] = 8,["13"] = 9,["14"] = 17,["15"] = 18,["16"] = 17,["18"] = 19,["19"] = 29,["20"] = 30,["21"] = 30,["22"] = 30,["23"] = 30,["24"] = 30,["25"] = 28,["26"] = 21,["27"] = 21,["28"] = 24,["29"] = 25,["30"] = 24,["31"] = 33,["32"] = 34,["33"] = 35,["34"] = 36,["35"] = 33,["36"] = 39,["37"] = 41,["38"] = 41,["39"] = 41,["40"] = 41,["41"] = 41,["42"] = 42,["43"] = 42,["44"] = 42,["45"] = 42,["46"] = 42,["47"] = 43,["48"] = 43,["49"] = 43,["50"] = 43,["51"] = 43,["52"] = 39,["53"] = 46,["54"] = 47,["55"] = 48,["56"] = 50,["58"] = 46,["59"] = 54,["60"] = 55,["61"] = 55,["62"] = 55,["63"] = 55,["64"] = 56,["65"] = 56,["66"] = 56,["67"] = 56,["68"] = 57,["69"] = 57,["70"] = 57,["71"] = 57,["72"] = 54,["73"] = 61,["74"] = 62,["75"] = 63,["76"] = 64,["77"] = 65,["78"] = 66,["79"] = 67,["80"] = 68,["81"] = 69,["82"] = 70,["83"] = 71,["84"] = 72,["85"] = 61,["86"] = 75,["87"] = 76,["88"] = 79,["89"] = 80,["90"] = 80,["91"] = 80,["92"] = 80,["94"] = 75,["95"] = 84,["96"] = 85,["97"] = 86,["98"] = 86,["99"] = 86,["100"] = 86,["101"] = 84,["102"] = 89,["103"] = 90,["104"] = 91,["105"] = 92,["106"] = 93,["107"] = 93,["108"] = 93,["109"] = 93,["110"] = 93,["111"] = 94,["112"] = 94,["113"] = 94,["114"] = 94,["115"] = 94,["116"] = 95,["117"] = 95,["118"] = 95,["119"] = 95,["120"] = 95,["121"] = 96,["122"] = 96,["123"] = 96,["124"] = 96,["125"] = 96,["126"] = 89,["127"] = 100,["128"] = 100,["129"] = 104,["130"] = 105,["131"] = 106,["132"] = 108,["133"] = 104,["134"] = 111,["135"] = 112,["136"] = 114,["137"] = 115,["139"] = 118,["140"] = 120,["141"] = 111,["142"] = 123,["143"] = 124,["144"] = 125,["145"] = 127,["146"] = 123,["147"] = 130,["148"] = 132,["149"] = 142,["150"] = 144,["151"] = 145,["152"] = 146,["154"] = 149,["155"] = 151,["156"] = 151,["157"] = 151,["158"] = 152,["159"] = 152,["160"] = 152,["161"] = 153,["162"] = 153,["163"] = 153,["164"] = 154,["165"] = 154,["166"] = 154,["167"] = 155,["168"] = 155,["169"] = 155,["170"] = 156,["171"] = 156,["172"] = 156,["174"] = 130,["175"] = 163,["176"] = 165,["177"] = 165,["178"] = 165,["179"] = 167,["180"] = 168,["182"] = 168,["183"] = 168,["184"] = 168,["185"] = 170,["186"] = 171,["187"] = 173,["188"] = 175,["190"] = 178,["192"] = 181,["194"] = 185,["200"] = 176,["205"] = 179,["210"] = 182,["211"] = 183,["216"] = 186,["226"] = 163,["227"] = 17});
local ____exports = {}
local ____tstl_2Dutils = require("game.scripts.vscripts.lib.tstl-utils")
local reloadable = ____tstl_2Dutils.reloadable
local heroSelectionTime = 45
local bansPerTeam = 3
local GOLD_MODIFIER = 2
local XP_MODIFIER = 2
local RESPAWN_MODIFIER = 0.5
local command_listener
local CREEP_SCALE = 0
____exports.GameMode = __TS__Class()
local GameMode = ____exports.GameMode
GameMode.name = "GameMode"
function GameMode.prototype.____constructor(self)
    self.Game = GameRules:GetGameModeEntity()
    self:configure()
    ListenToGameEvent(
        "game_rules_state_change",
        function() return self:OnStateChange() end,
        nil
    )
end
function GameMode.Precache(context)
end
function GameMode.Activate()
    GameRules.Addon = __TS__New(____exports.GameMode)
end
function GameMode.prototype.configure(self)
    self:setGameRules()
    self:setFilters()
    self:setListeners()
end
function GameMode.prototype.setListeners(self)
    ListenToGameEvent(
        "npc_spawned",
        function(event) return self:onNPCSpawned(event) end,
        nil
    )
    command_listener = ListenToGameEvent(
        "player_chat",
        function(event) return self:onPlayerChat(event) end,
        nil
    )
    ListenToGameEvent(
        "entity_killed",
        function(event) return self:onEntityKilled(event) end,
        nil
    )
end
function GameMode.prototype.onEntityKilled(self, event)
    local unit = EntIndexToHScript(event.entindex_killed)
    if unit:IsCourier() then
        print("Courier died!")
    end
end
function GameMode.prototype.setFilters(self)
    self.Game:SetModifyGoldFilter(
        function(____, event) return self:modifyGoldFilter(event) end,
        self
    )
    self.Game:SetModifyExperienceFilter(
        function(____, event) return self:modifyXPFilter(event) end,
        self
    )
    self.Game:SetBountyRunePickupFilter(
        function(____, event) return self:modifyBountyFilter(event) end,
        self
    )
end
function GameMode.prototype.setGameRules(self)
    GameRules:SetFilterMoreGold(true)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 3)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 3)
    GameRules:SetShowcaseTime(0)
    GameRules:SetHeroSelectionTime(heroSelectionTime)
    self.Game:SetDraftingHeroPickSelectTimeOverride(heroSelectionTime)
    GameRules:SetCustomGameBansPerTeam(bansPerTeam)
    GameRules:SetGoldTickTime(1000)
    self.Game:SetRespawnTimeScale(RESPAWN_MODIFIER)
    self.Game:SetFreeCourierModeEnabled(true)
    self.Game:SetUseDefaultDOTARuneSpawnLogic(true)
end
function GameMode.prototype.OnStateChange(self)
    local state = GameRules:State_Get()
    if state == DOTA_GAMERULES_STATE_PRE_GAME then
        Timers:CreateTimer(
            0.2,
            function() return self:StartGame() end
        )
    end
end
function GameMode.prototype.StartGame(self)
    print("Game starting!")
    Timers:CreateTimer(
        90,
        function() return self:DeleteCommandListener() end
    )
end
function GameMode.prototype.DeleteCommandListener(self)
    print("Removing Command Listener!")
    StopListeningToGameEvent(command_listener)
    GameRules:SendCustomMessage("Game Rules Set!", 0, 0)
    GameRules:SendCustomMessage(
        "Gold Scale: " .. tostring(GOLD_MODIFIER),
        1,
        1
    )
    GameRules:SendCustomMessage(
        "XP Scale: " .. tostring(XP_MODIFIER),
        0,
        0
    )
    GameRules:SendCustomMessage(
        "Respawn Scale: " .. tostring(RESPAWN_MODIFIER),
        0,
        0
    )
    GameRules:SendCustomMessage(
        "Creep Scale: " .. tostring(CREEP_SCALE),
        0,
        0
    )
end
function GameMode.prototype.Reload(self)
end
function GameMode.prototype.modifyXPFilter(self, event)
    local xp = event.experience
    event.experience = xp * XP_MODIFIER
    return true
end
function GameMode.prototype.modifyGoldFilter(self, event)
    local gold = event.gold
    if event.reason_const < 10 then
        return true
    end
    event.gold = gold * GOLD_MODIFIER
    return true
end
function GameMode.prototype.modifyBountyFilter(self, event)
    local gold = event.gold_bounty
    event.gold_bounty = gold * GOLD_MODIFIER
    return true
end
function GameMode.prototype.onNPCSpawned(self, event)
    local unit = EntIndexToHScript(event.entindex)
    if unit:IsCourier() then
        unit:AddAbility("courier_autodeliver")
        unit:FindAbilityByName("courier_autodeliver"):SetLevel(1)
        unit:SetBaseMoveSpeed(1100)
    end
    if (unit:GetClassname() == "npc_dota_creep_lane") or (unit:GetClassname() == "npc_dota_creep_neutral") then
        local game_minute = math.floor(
            GameRules:GetDOTATime(false, false) / 60
        )
        unit:SetBaseDamageMin(
            unit:GetBaseDamageMin() * ((CREEP_SCALE * game_minute) + 1)
        )
        unit:SetBaseDamageMax(
            unit:GetBaseDamageMax() * ((CREEP_SCALE * game_minute) + 1)
        )
        unit:SetMaxHealth(
            unit:GetMaxHealth() * ((CREEP_SCALE * game_minute) + 1)
        )
        unit:SetHealth(
            unit:GetHealth() * ((CREEP_SCALE * game_minute) + 1)
        )
        unit:SetPhysicalArmorBaseValue(
            unit:GetPhysicalArmorBaseValue() * ((CREEP_SCALE * game_minute) + 1)
        )
    end
end
function GameMode.prototype.onPlayerChat(self, event)
    if (__TS__StringAccess(event.text, 0) == "-") and GameRules:PlayerHasCustomGameHostPrivileges(
        PlayerResource:GetPlayer(event.playerid)
    ) then
        local msg = __TS__StringSplit(event.text, " ")
        if not __TS__NumberIsNaN(
            __TS__Number(
                __TS__Number(msg[2])
            )
        ) then
            local command = msg[1]
            local arg = __TS__Number(msg[2])
            local ____switch35 = command
            if ____switch35 == "-gold_scale" then
                goto ____switch35_case_0
            elseif ____switch35 == "-xp_scale" then
                goto ____switch35_case_1
            elseif ____switch35 == "-respawn_scale" then
                goto ____switch35_case_2
            elseif ____switch35 == "-creep_scale" then
                goto ____switch35_case_3
            end
            goto ____switch35_case_default
            ::____switch35_case_0::
            do
                GOLD_MODIFIER = arg
                goto ____switch35_end
            end
            ::____switch35_case_1::
            do
                XP_MODIFIER = arg
                goto ____switch35_end
            end
            ::____switch35_case_2::
            do
                RESPAWN_MODIFIER = arg
                self.Game:SetRespawnTimeScale(arg)
                goto ____switch35_end
            end
            ::____switch35_case_3::
            do
                CREEP_SCALE = arg
                goto ____switch35_end
            end
            ::____switch35_case_default::
            do
                goto ____switch35_end
            end
            ::____switch35_end::
        end
    end
end
GameMode = __TS__Decorate({reloadable}, GameMode)
return ____exports
