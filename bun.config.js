import fs from "fs";
import path from "path";

const rootDir = process.cwd();
const javascriptRoot = path.join(rootDir, "app/javascript");
const controllersRoot = path.join(javascriptRoot, "controllers");
const buildsRoot = path.join(rootDir, "app/assets/builds");
const isWatch = process.argv.includes("--watch");
const isProduction = process.env.NODE_ENV === "production";

const jsConfig = {
	sourcemap: "external",
	minify: isProduction,
};

const tailwindInput = path.join(rootDir, "app/assets/stylesheets/tailwind.css");
const tailwindOutput = path.join(rootDir, "app/assets/builds/tailwind.css");
const tailwindConfig = path.join(rootDir, "config/tailwind.config.js");
const tailwindExecutable = resolveTailwindExecutable();

function tailwindCmdArgs(options = {}) {
	if (!tailwindExecutable) {
		const installHint =
			"Run `bun install` (or your package installer) to install `tailwindcss` and `@tailwindcss/cli`.";
		throw new Error(`Tailwind CLI executable not found. ${installHint}`);
	}

	const args = [
		tailwindExecutable,
		"-i",
		tailwindInput,
		"-o",
		tailwindOutput,
		"-c",
		tailwindConfig,
	];

	if (options.watch) {
		args.push("--watch");
	}

	if (isProduction) {
		args.push("--minify");
	}

	return args;
}

async function buildJavascript() {
	const entrypoints = discoverEntryPoints();
	const failures = [];

	for (const entrypoint of entrypoints) {
		const relativePath = path.relative(javascriptRoot, entrypoint);
		const outputDir = path.join(buildsRoot, path.dirname(relativePath));
		fs.mkdirSync(outputDir, { recursive: true });

		const result = await Bun.build({
			...jsConfig,
			entrypoints: [entrypoint],
			outdir: outputDir,
			entrynames: "[name]",
		});

		if (!result.success) {
			failures.push({ entrypoint, logs: result.logs });
		}
	}

	if (failures.length > 0) {
		console.error("JavaScript build failed");
		for (const failure of failures) {
			console.error(
				`- ${path.relative(rootDir, failure.entrypoint)} failed to compile`,
			);
			for (const log of failure.logs) {
				console.error(log);
			}
		}

		if (!isWatch) {
			throw new AggregateError(
				failures.flatMap((failure) => failure.logs),
				"JavaScript build failed",
			);
		}
	}
}

async function buildTailwind() {
	fs.mkdirSync(path.dirname(tailwindOutput), { recursive: true });

	const tailwindProcess = Bun.spawn({
		cmd: tailwindCmdArgs(),
		cwd: rootDir,
		stdout: "inherit",
		stderr: "inherit",
	});

	const exitCode = await tailwindProcess.exited;

	if (exitCode !== 0) {
		console.error("Tailwind build failed");

		if (!isWatch) {
			throw new Error("Tailwind build failed");
		}
	}
}

function watchJavascript() {
	fs.watch(javascriptRoot, { recursive: true }, (_eventType, filename) => {
		if (filename) {
			console.log(`JS change detected: ${filename}. Rebuilding...`);
		}

		buildJavascript().catch((error) => {
			console.error(error);
		});
	});
}

function watchTailwind() {
	const tailwindProcess = Bun.spawn({
		cmd: tailwindCmdArgs({ watch: true }),
		cwd: rootDir,
		stdout: "inherit",
		stderr: "inherit",
	});

	const stop = () => {
		tailwindProcess.kill();
	};

	process.on("SIGINT", stop);
	process.on("SIGTERM", stop);

	return tailwindProcess.exited;
}

async function run() {
	await buildJavascript();

	if (isWatch) {
		await buildTailwind();
		watchJavascript();
		const exitCode = await watchTailwind();

		if (exitCode !== 0) {
			process.exit(exitCode);
		}
	} else {
		await buildTailwind();
	}
}

run().catch((error) => {
	console.error(error);
	process.exit(1);
});

function discoverEntryPoints() {
	const entryFiles = [];
	const applicationCandidates = ["application.ts", "application.js"];

	for (const candidate of applicationCandidates) {
		const candidatePath = path.join(javascriptRoot, candidate);
		if (fs.existsSync(candidatePath)) {
			entryFiles.push(candidatePath);
			break;
		}
	}

	if (fs.existsSync(controllersRoot)) {
		collectControllerEntries(controllersRoot, entryFiles);
	}

	entryFiles.sort();
	return entryFiles;
}

function collectControllerEntries(directory, entryFiles) {
	const children = fs.readdirSync(directory, { withFileTypes: true });

	for (const child of children) {
		const fullPath = path.join(directory, child.name);

		if (child.isDirectory()) {
			collectControllerEntries(fullPath, entryFiles);
			continue;
		}

		if (/^application\.(t|j)sx?$/.test(child.name)) {
			entryFiles.push(fullPath);
		}
	}
}

function resolveTailwindExecutable() {
	const packageCandidates = ["tailwindcss", "@tailwindcss/cli"];

	for (const packageName of packageCandidates) {
		const packageJsonPath = path.join(
			rootDir,
			"node_modules",
			...packageName.split("/"),
			"package.json",
		);

		if (!fs.existsSync(packageJsonPath)) {
			continue;
		}

		try {
			const packageJsonRaw = fs.readFileSync(packageJsonPath, "utf8");
			const packageJson = JSON.parse(packageJsonRaw);
			const { bin } = packageJson;

			if (typeof bin === "string") {
				const binPath = path.join(path.dirname(packageJsonPath), bin);
				if (fs.existsSync(binPath)) {
					return binPath;
				}
			} else if (typeof bin === "object" && bin !== null) {
				const binCandidates = [
					bin["tailwindcss"],
					bin[packageName],
					...Object.values(bin),
				].filter(Boolean);

				for (const binCandidate of binCandidates) {
					const binPath = path.join(
						path.dirname(packageJsonPath),
						binCandidate,
					);
					if (fs.existsSync(binPath)) {
						return binPath;
					}
				}
			}
		} catch (error) {
			console.warn(`Failed to read ${packageName} package.json`, error);
		}
	}

	const candidates = [
		path.join(rootDir, "node_modules/.bin/tailwindcss"),
		path.join(rootDir, "node_modules/.bin/tailwind"),
	];

	for (const candidate of candidates) {
		if (fs.existsSync(candidate)) {
			return candidate;
		}
	}

	return null;
}
