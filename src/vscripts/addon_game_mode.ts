import "./lib/timers";
import { GameMode } from "./GameMode";

Object.assign(getfenv(), {
    Activate: GameMode.Activate,
    Precache: GameMode.Precache,
});

if (GameRules.Addon !== undefined) {
    GameRules.Addon.Reload();
}
