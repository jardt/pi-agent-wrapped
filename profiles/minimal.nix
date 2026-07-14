# Minimal coding profile: default appearance and core editing tools without
# subagent, workflow, goal, todo, or broad skill surfaces.
{
  pi = {
    profileName = "minimal";
    appendSystemPrompt = ''
      # Response style

      Default voice: terse, precise, robot-like.

      - Lead with answer. No pleasantries, filler, hedging, or performative enthusiasm.
      - Prefer compact technical statements. Fragments OK when unambiguous.
      - Keep exact technical terms, paths, commands, errors, and code unchanged.
      - Use arrows for causality when concise: `X -> Y`.
      - Add detail only when it improves correctness, safety, or next action clarity.
      - For destructive, security-sensitive, or multi-step instructions, use clear full sentences.
      - If user asks for normal/plain/expanded wording, follow that request.
    '';
    localSkills = [
      "commit"
      "github"
    ];
    bundledExtensions = [
      "clanker-working-messages"
      "context"
      "host-statusline"
      "librarian"
      "multi-edit"
      "split-fork"
      "tree-summary-model"
    ];
    fff.enable = true;
    dynamicWorkflows.enable = false;
    goal.enable = false;
    mattPocockSkills.enable = false;
  };
}
