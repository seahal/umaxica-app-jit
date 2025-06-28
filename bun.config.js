export default {
  entrypoints: [ "src/HelloWorld.tsx"],
  outdir: "app/assets/builds",
  sourcemap: "linked",
  target: "browser",
  splitting: true,
  format: "esm",
  loader: {
    ".tsx": "tsx",
    ".ts": "ts",
    ".jsx": "jsx",
    ".js": "js",
  },
    test: { coverage: true }
};
