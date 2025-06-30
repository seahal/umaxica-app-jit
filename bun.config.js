import path from 'path';
import fs from 'fs';

const config = {
  entrypoints: ["./app/javascript/application.tsx"],
  outdir: "./app/assets/builds",
  sourcemap: "external",
  minify: process.env.NODE_ENV === "production",
  target: "browser",
  format: "esm",
  external: [],
  define: {
    "process.env.NODE_ENV": JSON.stringify(process.env.NODE_ENV || "development"),
  },
  plugins: [],
};

const build = async (config) => {
  console.log("Building...");
  const result = await Bun.build(config);

  if (!result.success) {
    console.error("Build failed:");
    for (const message of result.logs) {
      console.error(message);
    }
    if (!process.argv.includes('--watch')) {
      throw new AggregateError(result.logs, "Build failed");
    }
    return;
  }

  console.log(`Built ${result.outputs.length} files successfully`);
  for (const output of result.outputs) {
    console.log(`  ${output.path}`);
  }
};

const isWatchMode = process.argv.includes('--watch');

(async () => {
  await build(config);

  if (isWatchMode) {
    console.log("Watching for changes...");
    const watcher = fs.watch(
      path.join(process.cwd(), "app/javascript"), 
=======
      path.join(process.cwd(), "app"), 
>>>>>>> feature
      { recursive: true }, 
      async (eventType, filename) => {
        if (filename && (filename.endsWith('.js') || filename.endsWith('.jsx') || filename.endsWith('.ts') || filename.endsWith('.tsx'))) {
          console.log(`File changed: ${filename}. Rebuilding...`);
          await build(config);
        }
      }
    );

    process.on('SIGINT', () => {
      console.log('\nStopping watcher...');
      watcher.close();
      process.exit(0);
    });
  } else {
    process.exit(0);
  }
})();
