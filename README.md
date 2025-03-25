# Vita Brevis
Life is short - write your CV as JSON data!  

# Quickstart
- `nix develop`
- `npm install`
- `npm run dev`
- `npm run build`
  
  If you want to build a PDF set the enviroment variable `GENERATE_PDF=1`, for example
  `GENERATE_PDF=1 npm run build`
  
My own CV as JSON is located at `src/data/cv_data.json`  
The script `mutate.py` mutates the cv data to toggle between two emails (eg. Firefox Relay & Gmail). Running the dev server allows for a live view of the final output. The print preview can be used to preview page breaks (`astro-pdf` uses Selenium under the hood - the page breaks could be in slightly different places if using a non Chromium browser),

