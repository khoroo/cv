// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import pdf from 'astro-pdf';

// Define which CV data file to use (can be overridden with environment variables)
const CV_DATA_FILE = process.env.CV_DATA_FILE || 'cv_data.json';

const options = {
  pages: {
    '/cv/': 'cv.pdf',
  }
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
  integrations: [pdf(options)],
  site: 'https://robert.sparks.me.uk',
  base: 'cv',
});
