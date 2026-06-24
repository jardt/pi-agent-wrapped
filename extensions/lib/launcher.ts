import { existsSync } from "node:fs";
import * as path from "node:path";

function normalizeEnvLauncher(value: string | undefined): string[] | null {
	const trimmed = value?.trim();
	if (!trimmed) return null;
	return [trimmed];
}

export function getPiInvocationParts(): string[] {
	const envLauncher = normalizeEnvLauncher(process.env.PI_LAUNCHER_BIN);
	if (envLauncher) return envLauncher;

	const currentScript = process.argv[1];
	if (currentScript && existsSync(currentScript)) {
		return [process.execPath, currentScript];
	}

	const execName = path.basename(process.execPath).toLowerCase();
	const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
	if (!isGenericRuntime) {
		return [process.execPath];
	}

	throw new Error("Unable to determine the current Pi launcher. Set PI_LAUNCHER_BIN so spawned processes reuse the active wrapper.");
}
