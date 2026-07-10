import { getSettingsListTheme, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Container, SettingsList, Text } from "@earendil-works/pi-tui";
import type { ResolvedConfig } from "./config.ts";
export type SettingChange = (id: string, value: string) => void;
export async function showSettings(ctx: ExtensionContext, cfg: ResolvedConfig, change: SettingChange, diagnostics: string): Promise<void> { if (ctx.mode !== "tui") { ctx.ui.notify("/openai-settings requires TUI mode.", "warning"); return; } const items = [
 { id: "desiredActive", label: "Fast mode requested", currentValue: String(cfg.desiredActive), values: ["true", "false"] },
 { id: "persistState", label: "Persist fast state", currentValue: String(cfg.persistState), values: ["true", "false"] },
 { id: "usage.enabled", label: "Usage fetching", currentValue: String(cfg.usage.enabled), values: ["true", "false"] },
 { id: "usage.refreshIntervalMs", label: "Usage refresh (ms)", currentValue: String(cfg.usage.refreshIntervalMs), values: ["15000", "30000", "60000", "120000", "300000", "600000"] },
 { id: "usage.showOnlyOnSubscriptionModels", label: "Usage only on OAuth", currentValue: String(cfg.usage.showOnlyOnSubscriptionModels), values: ["true", "false"] },
 { id: "usage.showResetTimes", label: "Compact reset times", currentValue: String(cfg.usage.showResetTimes), values: ["true", "false"] },
 { id: "image.enabled", label: "Image command", currentValue: String(cfg.image.enabled), values: ["true", "false"] },
 { id: "image.defaultSave", label: "Image save", currentValue: cfg.image.defaultSave, values: ["project", "global", "custom", "none"] },
 { id: "image.outputFormat", label: "Image format", currentValue: cfg.image.outputFormat, values: ["png", "jpeg", "webp"] },
 { id: "image.timeoutMs", label: "Image timeout (ms)", currentValue: String(cfg.image.timeoutMs), values: ["30000", "60000", "120000", "180000", "300000"] },
 ]; await ctx.ui.custom((tui, theme, _keys, done) => { const c = new Container(); c.addChild(new Text(theme.fg("accent", theme.bold("Better OpenAI Settings")) + `\n${theme.fg("dim", diagnostics)}`, 1, 1)); const list = new SettingsList(items, 12, getSettingsListTheme(), (id, value) => { change(id, value); list.updateValue(id, value); tui.requestRender(); }, () => done(undefined), { enableSearch: true }); c.addChild(list); return { render: w => c.render(w), invalidate: () => c.invalidate(), handleInput: d => { list.handleInput(d); tui.requestRender(); } }; }); }
