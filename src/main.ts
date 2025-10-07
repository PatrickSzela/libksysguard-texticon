import * as Config from "./config";

// workaround for Vite/esbuild/rollup or whatever else that keeps removing unused imports
if (typeof window !== "undefined") {
  // @ts-expect-error f
  window.config = Config;
}
