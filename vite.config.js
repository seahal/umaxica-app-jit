import { defineConfig } from 'vite'


export default defineConfig({
  server: {
    cors: {
      // ブラウザ経由でアクセスするオリジン
      origin: 'http://my-backend.example.com',
    },
  },
  build: {
    // outDir に .vite/manifest.json を出力
    manifest: true,
    rollupOptions: {
      // デフォルトの .html エントリーを上書き
      input: './src/application.tsx',
    },
  },
})
