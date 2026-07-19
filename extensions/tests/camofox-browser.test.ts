import test from "node:test";
import assert from "node:assert/strict";
import camofoxBrowser, { camofoxFetch } from "../camofox-browser.ts";

test("Camofox requests await API keys before building authorization", async () => {
  const originalFetch = globalThis.fetch;
  const originalKey = process.env.CAMOFOX_API_KEY;
  process.env.CAMOFOX_API_KEY = "secret-key";
  try {
    globalThis.fetch = async (_input, init) => {
      assert.equal((init?.headers as Record<string, string>).Authorization, "Bearer secret-key");
      return new Response("ok");
    };
    assert.equal(await (await camofoxFetch("/screenshot")).text(), "ok");
  } finally {
    globalThis.fetch = originalFetch;
    if (originalKey === undefined) delete process.env.CAMOFOX_API_KEY;
    else process.env.CAMOFOX_API_KEY = originalKey;
  }
});

test("Camofox requests propagate caller cancellation", async () => {
  const originalFetch = globalThis.fetch;
  const controller = new AbortController();
  try {
    globalThis.fetch = async (_input, init) => {
      assert.ok(init?.signal);
      if (init.signal.aborted) throw init.signal.reason;
      return new Promise((_resolve, reject) =>
        init.signal?.addEventListener("abort", () => reject(init.signal?.reason), { once: true }),
      );
    };
    const pending = camofoxFetch("/health", {}, controller.signal);
    controller.abort();
    await assert.rejects(pending);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("Camofox dynamically loads optional tools", async () => {
  const tools = new Map<string, any>();
  const handlers = new Map<string, () => void>();
  let active = ["read", "camofox_click", "camofox_console"];
  const pi = {
    registerCommand() {},
    registerTool(tool: any) { tools.set(tool.name, tool); },
    on(event: string, handler: () => void) { handlers.set(event, handler); },
    getAllTools: () => [...tools.values()],
    getActiveTools: () => active,
    setActiveTools(names: string[]) { active = names; },
  };

  camofoxBrowser(pi as any);
  handlers.get("session_start")?.();

  assert.deepEqual(
    active,
    ["read", "camofox_create_tab", "camofox_list_tabs", "camofox_snapshot", "search_camofox_tools"],
  );

  const result = await tools.get("search_camofox_tools").execute(
    "call-1",
    { query: "fill and click a form" },
  );
  assert.ok(active.includes("camofox_click"));
  assert.ok(active.includes("camofox_type"));
  assert.equal(active.includes("camofox_console_clear"), false);
  assert.equal(active.includes("camofox_go_forward"), false);
  assert.match(result.content[0].text, /Loaded Camofox tools/);
});
