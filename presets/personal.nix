# Personal preset: jdr's opinionated defaults layered on the generic module.
# Everything uses mkDefault so profiles and consumers can still override.
{ lib, ... }:
{
  pi = {
    defaultModel = lib.mkDefault "openai-codex/gpt-5.6-sol";
    enabledModels = lib.mkDefault [
      "openai-codex/gpt-5.6-terra"
      "openai-codex/gpt-5.6-luna"
      "openai-codex/gpt-5.6-sol"
    ];
    defaultThinkingLevel = lib.mkDefault "low";
    theme = lib.mkDefault "gruvbox-dark-hard";

    localSkills = lib.mkDefault [
      "commit"
      "github"
      "herdr"
      "librarian"
      "session-reader"
      "tmux"
    ];

    bundledExtensions = lib.mkDefault [
      "better-openai"
      "clanker-working-messages"
      "context"
      "explore"
      "host-statusline"
      "librarian"
      "multi-edit"
      "split-fork"
      "todos"
      "tree-summary-model"
    ];

    fff.enable = lib.mkDefault true;
    dynamicWorkflows.enable = lib.mkDefault true;
    goal.enable = lib.mkDefault true;
    mattPocockSkills.enable = lib.mkDefault true;
    herdrIntegration.enable = lib.mkDefault true;

    settings = {
      compaction.enabled = lib.mkDefault true;
      hideThinkingBlock = lib.mkDefault false;
    };

    keybindings = lib.mkDefault {
      "tui.editor.cursorUp" = [
        "up"
        "ctrl+p"
      ];
      "tui.editor.cursorDown" = [
        "down"
        "ctrl+n"
      ];
      "tui.select.up" = [
        "up"
        "ctrl+p"
      ];
      "tui.select.down" = [
        "down"
        "ctrl+n"
      ];
      "app.model.cycleForward" = [ ];
      "app.session.togglePath" = [ ];
      "app.models.toggleProvider" = [ ];
      "app.session.toggleNamedFilter" = "ctrl+shift+n";
    };
  };
}
