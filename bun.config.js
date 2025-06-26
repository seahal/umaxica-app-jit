export default {
  entrypoints: ["app/javascript/application.js", "app/javascript/components/HelloWorld.tsx"],
  outdir: "app/assets/builds",
  sourcemap: "linked",
  target: "browser",
  splitting: true,
  format: "esm",
  loader: {
    ".tsx": "tsx",
    ".ts": "ts",
  },
};
