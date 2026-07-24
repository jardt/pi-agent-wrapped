import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { readAuthFile } from "../lib/better-openai/auth.ts";

function withAuth(entry: unknown, run: () => void) {
 const dir = mkdtempSync(join(tmpdir(), "better-openai-auth-"));
 const previous = process.env.PI_CODING_AGENT_DIR;
 try { process.env.PI_CODING_AGENT_DIR = dir; writeFileSync(join(dir, "auth.json"), JSON.stringify({ "openai-codex": entry })); run(); }
 finally { if (previous === undefined) delete process.env.PI_CODING_AGENT_DIR; else process.env.PI_CODING_AGENT_DIR = previous; rmSync(dir, { recursive: true, force: true }); }
}

test("auth file accepts unexpired OAuth credentials", () => withAuth({ type: "oauth", access: " token ", accountId: " account ", expires: Date.now() + 60_000 }, () => assert.deepEqual(readAuthFile(), { accessToken: "token", accountId: "account" })));
test("auth file rejects expired OAuth credentials", () => withAuth({ type: "oauth", access: "token", accountId: "account", expires: Date.now() - 1 }, () => assert.equal(readAuthFile(), undefined)));
test("auth file rejects non-OAuth credentials", () => withAuth({ type: "api_key", access: "token", accountId: "account" }, () => assert.equal(readAuthFile(), undefined)));
