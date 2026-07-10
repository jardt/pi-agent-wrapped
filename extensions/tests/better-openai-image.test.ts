import test from "node:test";
import assert from "node:assert/strict";
import { buildImageRequest, parseImageSse } from "../lib/better-openai/image.ts";
test("image request uses hosted image_generation", () => { const request = buildImageRequest("cat", "gpt-x", "png"); assert.equal(request.tools[0].type, "image_generation"); assert.equal(request.stream, true); assert.equal(request.input[0].content[0].text, "cat"); });
test("SSE parser ignores partial images and requires completed", async () => { const body = ['data: {"partial_image_b64":"bad"}\n\n', 'data: {"type":"response.output_item.done","item":{"type":"image_generation_call","id":"ig_1","status":"completed","result":"aGVsbG8="}}\n\n'].join(""); const response = new Response(body, { headers: { "content-type": "text/event-stream" } }); assert.deepEqual(await parseImageSse(response), { id: "ig_1", data: "aGVsbG8=", mimeType: "image/png" }); });
