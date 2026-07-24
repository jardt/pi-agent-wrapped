import assert from "node:assert/strict";
import test from "node:test";
import { getCapabilities, setCapabilities } from "@earendil-works/pi-tui";
import herdrTerminalImages from "../herdr-terminal-images.ts";

const baseline = { images: null, trueColor: true, hyperlinks: false } as const;

test("Herdr panes enable Kitty images without changing other capabilities", () => {
 const previous = process.env.HERDR_ENV;
 try {
  process.env.HERDR_ENV = "1";
  setCapabilities(baseline);
  herdrTerminalImages({} as never);
  assert.deepEqual(getCapabilities(), { ...baseline, images: "kitty" });
 } finally {
  if (previous === undefined) delete process.env.HERDR_ENV;
  else process.env.HERDR_ENV = previous;
 }
});

test("terminal capabilities are unchanged outside Herdr", () => {
 const previous = process.env.HERDR_ENV;
 try {
  delete process.env.HERDR_ENV;
  setCapabilities(baseline);
  herdrTerminalImages({} as never);
  assert.deepEqual(getCapabilities(), baseline);
 } finally {
  if (previous === undefined) delete process.env.HERDR_ENV;
  else process.env.HERDR_ENV = previous;
 }
});
