import test from "node:test";
import assert from "node:assert/strict";
import { parseUsage } from "../lib/better-openai/usage.ts";
test("usage converts used percent and prefers reset_at", () => { const now = 1_700_000_000_000; const value = parseUsage({ rate_limit: { allowed: false, primary_window: { used_percent: 25, reset_at: now / 1000 + 60, reset_after_seconds: 999 }, secondary_window: { used_percent: 80, reset_after_seconds: 120 } }, rate_limit_reset_credits: { available_count: 2 } }, now); assert.equal(value.primaryRemaining, 75); assert.equal(value.secondaryRemaining, 20); assert.equal(value.primaryResetSeconds, 60); assert.equal(value.secondaryResetSeconds, 120); assert.equal(value.limited, true); assert.equal(value.resetCredits, 2); });
