// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import pdf from 'astro-pdf';
import { internalSpreadAttributes } from 'astro/runtime/server/render/util.js';

const CV_DATA_FILE = process.env.CV_DATA_FILE || 'cv_data.json';
const GENERATE_PDF = process.env.GENERATE_PDF === '1';
const options = {
  pages: {
    '/cv/': 'cv.pdf',
  }
}
const integrations = [];
if (GENERATE_PDF) {
  integrations.push(pdf(options));
}


// https://astro.build/config
export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
    define: {
      // Make the CV_DATA_FILE available to the client-side code
      'import.meta.env.CV_DATA_FILE': JSON.stringify(CV_DATA_FILE)
    }
  },
  devToolbar: { enabled: false },
  integrations: integrations,
  base: '/cv/',
});
