import path from "path";
import fs from "fs";

const rootDir = process.cwd();
const isWatch = process.argv.includes("--watch");
const isProduction = process.env.NODE_ENV === "production";

const jsConfig = {
  sourcemap: "external",
  entrypoints: ["app/javascript/application.js"],
  outdir: path.join(rootDir, "app/assets/builds"),
  minify: isProduction,
};

const tailwindInput = path.join(rootDir, "app/assets/stylesheets/tailwind.css");
const tailwindOutput = path.join(rootDir, "app/assets/builds/tailwind.css");
const tailwindConfig = path.join(rootDir, "config/tailwind.config.js");
const tailwindExecutable = resolveTailwindExecutable();

function tailwindCmdArgs(options = {}) {
  if (!tailwindExecutable) {
    const installHint = "Run `bun install` (or your package installer) to install `tailwindcss` and `@tailwindcss/cli`.";
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
  const result = await Bun.build(jsConfig);

  if (!result.success) {
    console.error("JavaScript build failed");
    for (const message of result.logs) {
      console.error(message);
    }

    if (!isWatch) {
      throw new AggregateError(result.logs, "JavaScript build failed");
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
  const javascriptDir = path.join(rootDir, "app/javascript");

  fs.watch(javascriptDir, { recursive: true }, (_eventType, filename) => {
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

function resolveTailwindExecutable() {
  const packageCandidates = ["tailwindcss", "@tailwindcss/cli"];

  for (const packageName of packageCandidates) {
    const packageJsonPath = path.join(rootDir, "node_modules", ...packageName.split("/"), "package.json");

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
          const binPath = path.join(path.dirname(packageJsonPath), binCandidate);
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
