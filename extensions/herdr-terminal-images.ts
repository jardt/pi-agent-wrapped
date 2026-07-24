import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getCapabilities, setCapabilities } from "@earendil-works/pi-tui";

/** Herdr forwards Kitty graphics but gives child PTYs a neutral TERM value. */
export default function herdrTerminalImages(_pi: ExtensionAPI): void {
 if (process.env.HERDR_ENV !== "1") return;
 const capabilities = getCapabilities();
 if (!capabilities.images) setCapabilities({ ...capabilities, images: "kitty" });
}
