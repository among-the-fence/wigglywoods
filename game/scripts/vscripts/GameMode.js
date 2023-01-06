var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var GameMode_1;
import { reloadable } from "./lib/tstl-utils";
const heroSelectionTime = 45;
const bansPerTeam = 3;
let GOLD_MODIFIER = 2;
let XP_MODIFIER = 2;
let RESPAWN_MODIFIER = .5;
let command_listener;
let CREEP_SCALE = 0.0;
let GameMode = GameMode_1 = class GameMode {
    constructor() {
        this.Game = GameRules.GetGameModeEntity();
        this.configure();
        ListenToGameEvent("game_rules_state_change", () => this.OnStateChange(), undefined);
    }
    static Precache(context) {
    }
    static Activate() {
        GameRules.Addon = new GameMode_1();
    }
    configure() {
        this.setGameRules();
        this.setFilters();
        this.setListeners();
    }
    setListeners() {
        ListenToGameEvent("npc_spawned", event => this.onNPCSpawned(event), undefined);
        command_listener = ListenToGameEvent("player_chat", event => this.onPlayerChat(event), undefined);
        ListenToGameEvent("entity_killed", event => this.onEntityKilled(event), undefined);
    }
    onEntityKilled(event) {
        let unit = EntIndexToHScript(event.entindex_killed);
        if (unit.IsCourier()) {
            print("Courier died!");
        }
    }
    setFilters() {
        this.Game.SetModifyGoldFilter(event => this.modifyGoldFilter(event), this);
        this.Game.SetModifyExperienceFilter(event => this.modifyXPFilter(event), this);
        this.Game.SetBountyRunePickupFilter(event => this.modifyBountyFilter(event), this);
    }
    setGameRules() {
        GameRules.SetFilterMoreGold(true);
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_GOODGUYS, 3);
        GameRules.SetCustomGameTeamMaxPlayers(DOTATeam_t.DOTA_TEAM_BADGUYS, 3);
        GameRules.SetShowcaseTime(0);
        GameRules.SetHeroSelectionTime(heroSelectionTime);
        this.Game.SetDraftingHeroPickSelectTimeOverride(heroSelectionTime);
        GameRules.SetCustomGameBansPerTeam(bansPerTeam);
        GameRules.SetGoldTickTime(1000);
        this.Game.SetRespawnTimeScale(RESPAWN_MODIFIER);
        this.Game.SetFreeCourierModeEnabled(true);
        this.Game.SetUseDefaultDOTARuneSpawnLogic(true);
    }
    OnStateChange() {
        const state = GameRules.State_Get();
        // Start game once pregame hits
        if (state == DOTA_GameState.DOTA_GAMERULES_STATE_PRE_GAME) {
            Timers.CreateTimer(0.2, () => this.StartGame());
        }
    }
    StartGame() {
        print("Game starting!");
        Timers.CreateTimer(90, () => this.DeleteCommandListener());
        // Do some stuff here
    }
    DeleteCommandListener() {
        print("Removing Command Listener!");
        StopListeningToGameEvent(command_listener);
        GameRules.SendCustomMessage("Game Rules Set!", 0, 0);
        GameRules.SendCustomMessage("Gold Scale: " + GOLD_MODIFIER, 1, 1);
        GameRules.SendCustomMessage("XP Scale: " + XP_MODIFIER, 0, 0);
        GameRules.SendCustomMessage("Respawn Scale: " + RESPAWN_MODIFIER, 0, 0);
        GameRules.SendCustomMessage("Creep Scale: " + CREEP_SCALE, 0, 0);
    }
    // Called on script_reload
    Reload() {
        // Do some stuff here
    }
    modifyXPFilter(event) {
        let xp = event.experience;
        event.experience = xp * XP_MODIFIER;
        return true;
    }
    modifyGoldFilter(event) {
        let gold = event.gold;
        //ignore things like selling/buying items, buyback, etc
        if (event.reason_const < 10) {
            return true;
        }
        event.gold = gold * GOLD_MODIFIER;
        return true;
    }
    modifyBountyFilter(event) {
        let gold = event.gold_bounty;
        event.gold_bounty = gold * GOLD_MODIFIER;
        return true;
    }
    onNPCSpawned(event) {
        let unit = EntIndexToHScript(event.entindex);
        // DeepPrintTable(getmetatable(unit));
        // print((unit.GetClassname() == "npc_dota_creep_lane" || unit.GetClassname() == "npc_dota_creep_neutral"));
        // if (unit.GetName() == "npc_dota_roshan")
        // {
        //     unit.AddAbility("roshan_multiply");
        //     unit.FindAbilityByName("roshan_multiply")?.SetLevel(1);
        // }
        if (unit.IsCourier()) {
            unit.AddAbility("courier_autodeliver");
            unit.FindAbilityByName("courier_autodeliver")?.SetLevel(1);
            unit.SetBaseMoveSpeed(1100);
        }
        if ((unit.GetClassname() == "npc_dota_creep_lane" || unit.GetClassname() == "npc_dota_creep_neutral")) {
            let game_minute = Math.floor(GameRules.GetDOTATime(false, false) / 60);
            unit.SetBaseDamageMin(unit.GetBaseDamageMin() * ((CREEP_SCALE * game_minute) + 1));
            unit.SetBaseDamageMax(unit.GetBaseDamageMax() * ((CREEP_SCALE * game_minute) + 1));
            unit.SetMaxHealth(unit.GetMaxHealth() * ((CREEP_SCALE * game_minute) + 1));
            unit.SetHealth(unit.GetHealth() * ((CREEP_SCALE * game_minute) + 1));
            unit.SetPhysicalArmorBaseValue(unit.GetPhysicalArmorBaseValue() * ((CREEP_SCALE * game_minute) + 1));
        }
    }
    onPlayerChat(event) {
        if (event.text[0] == "-" && GameRules.PlayerHasCustomGameHostPrivileges(PlayerResource.GetPlayer(event.playerid))) {
            let msg = event.text.split(" ");
            if (!isNaN(Number(msg[1]))) {
                let command = msg[0];
                let arg = Number(msg[1]);
                switch (command) {
                    case "-gold_scale":
                        GOLD_MODIFIER = arg;
                        break;
                    case "-xp_scale":
                        XP_MODIFIER = arg;
                        break;
                    case "-respawn_scale":
                        RESPAWN_MODIFIER = arg;
                        this.Game.SetRespawnTimeScale(arg);
                        break;
                    case "-creep_scale":
                        CREEP_SCALE = arg;
                        break;
                    default:
                        break;
                }
            }
        }
    }
};
GameMode = GameMode_1 = __decorate([
    reloadable
], GameMode);
export { GameMode };
