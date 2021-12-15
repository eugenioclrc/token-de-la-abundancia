import preprocess from "svelte-preprocess";


// svelte.config.js
import adapter from '@sveltejs/adapter-static';

const dev = process.env.NODE_ENV === 'development';
console.log({dev});
export default {
	kit: {
		adapter: adapter({
			// default options are shown
			pages: 'build',
			assets: 'build',
			fallback: null,
		}),
    paths: {
      base: dev ? '' : '/token-de-la-abundancia',
    },
    // If you are not using a .nojekyll file, change your appDir to something not starting with an underscore.
    // For example, instead of '_app', use 'app_', 'internal', etc.
    // appDir: 'internal',
    target: "#svelte",
	},
  preprocess: [
    preprocess({
      postcss: true,
    }),
  ],
};

/*
import adapter from '@sveltejs/adapter-static';
// import adapter from "@sveltejs/adapter-auto";

/** @type {import('@sveltejs/kit').Config} * /
const config = {
  kit: {
    adapter: adapter(),

    // hydrate the <div id="svelte"> element in src/app.html
    target: "#svelte",
  },

  preprocess: [
    preprocess({
      postcss: true,
    }),
  ],
};

export default config;
*/