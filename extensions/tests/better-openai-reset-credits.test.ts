import test from "node:test";
import assert from "node:assert/strict";
import { availableCredits, parseResetCredits } from "../lib/better-openai/reset-credits.ts";
test("reset credits use backend count and sort available by expiration", () => { const list = parseResetCredits({ available_count: 4, credits: [{ id: "later", status: "available", expires_at: "2030-01-02T00:00:00Z" }, { credit_id: "used", status: "redeemed" }, { id: "first", status: "available", expires_at: "2030-01-01T00:00:00Z" }] }); assert.equal(list.availableCount, 4); assert.deepEqual(availableCredits(list).map(x => x.id), ["first", "later"]); });
test("reset credits safely compute a count", () => assert.equal(parseResetCredits({ credits: [{ id: "a", status: "available" }, { id: "b", status: "unknown" }] }).availableCount, 1));
test("reset credits sort missing and invalid expirations last", () => { const list = parseResetCredits({ credits: [{ id: "missing", status: "available" }, { id: "invalid", status: "available", expires_at: "not-a-date" }, { id: "dated", status: "available", expires_at: "2030-01-01T00:00:00Z" }] }); assert.deepEqual(availableCredits(list).map(x => x.id), ["dated", "missing", "invalid"]); });
