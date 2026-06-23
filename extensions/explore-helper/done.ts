import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { writeFileSync } from "node:fs";

function writeExitFile(): void {
  const sessionFile = process.env.PI_EXPLORE_SESSION;
  if (!sessionFile) return;
  writeFileSync(`${sessionFile}.exit`, JSON.stringify({ type: "done" }) + "\n", "utf8");
}

export default function exploreDoneExtension(pi: ExtensionAPI) {
  pi.on("agent_end", (_event, ctx) => {
    if (process.env.PI_EXPLORE_AUTO_EXIT !== "1") return;
    writeExitFile();
    ctx.shutdown();
  });

  pi.registerTool({
    name: "explore_done",
    label: "Explore Done",
    description:
      "Call this when your read-only exploration is complete. Your previous assistant message is returned to the parent session as the report.",
    parameters: Type.Object({}),
    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      writeExitFile();
      ctx.shutdown();
      return {
        content: [{ type: "text", text: "Explore complete. Returning report to parent session." }],
        details: {},
      };
    },
  });
}
