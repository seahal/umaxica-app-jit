import { defineConfig } from 'vite'

export default defineConfig({
    server: {
        cors: {
            // ブラウザ経由でアクセスするオリジン
            origin: 'http://www.app.localdomain:3334',
        },
    },
    build: {
        // Rails assets ディレクトリに出力
        outDir: 'dist',
        // manifest.json を生成して Rails から参照できるようにする
        manifest: true,
        rollupOptions: {
            input: {
                application: 'src/application.jsx',
                helloworld: 'src/HelloWorld.tsx',
            },
        },
        // アセットファイル名をシンプルに
        assetsDir: '',
    },
    esbuild: {
        loader: 'tsx',
        include: /src\/.*\.[jt]sx?$/,
    },
})