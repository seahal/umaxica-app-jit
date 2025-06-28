import { defineConfig } from 'vite'


export default defineConfig
({
  server
: {
    cors
: {
    origin
    : 'http://dist.net.localhost:3000/',
    },
  },
  build
: {
    // outDir に .vite/manifest.json を出力
    manifest
: true,
    rollupOptions
: {
      // デフォルトの .html エントリーを上書き
      input
: '/dist/main.js',
    },
  },
})
