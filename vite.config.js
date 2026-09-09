import { defineConfig } from 'vite'
import { resolve } from 'node:path'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        civilian: resolve(__dirname, 'civilian/index.html'),
        dispatcher: resolve(__dirname, 'dispatcher/index.html'),
        responder: resolve(__dirname, 'responder/index.html'),
      },
    },
  },
})
