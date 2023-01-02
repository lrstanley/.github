import { parse as yamlParse } from "https://deno.land/std@0.170.0/encoding/yaml.ts"
import { walk } from "https://deno.land/std@0.170.0/fs/mod.ts"
import * as log from "https://deno.land/std@0.170.0/log/mod.ts"
import { process } from "./process-image.ts"

import type { Config } from "./types.ts"

if (import.meta.main) {
  log.info(`checking ${Deno.cwd()}`)
  for await (const file of walk(".", {
    includeDirs: false,
    followSymlinks: false,
    match: [/ci-config\.yaml$/],
  })) {
    const config = yamlParse(await Deno.readTextFile(file.path)) as Config
    config.file = file

    await process(config)
  }
}
