import { defineConfig } from 'vite'

export default defineConfig({
    server: {
        cors: {
            // ブラウザ経由でアクセスするオリジン
            origin: 'http://www.app.localdomain:3334',
        },
        fs: {
            allow: ['..', '.', 'dist']
        }
    },
    publicDir: 'dist',
    build: {
        outDir: 'app/assets/javascript',
        lib: {
            entry: 'src/application.jsx',
            name: 'App',
            fileName: 'main',
            formats: ['iife']
        },
        rollupOptions: {
            external: [],
            output: {
                globals: {}
            }
        },
    },
    esbuild: {
        loader: 'tsx',
        include: /src\/.*\.[jt]sx?$/,
    },
})