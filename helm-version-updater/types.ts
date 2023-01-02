import type { WalkEntry } from "https://deno.land/std@0.170.0/fs/mod.ts"

export interface Source {
  repository: string
  owner: string
  image: string
}

export interface Config {
  file: WalkEntry

  source: Source
  version_range?: string
}

export interface TagsResponseGithub {
  name: string
  tags: string[]
}

export interface TagsResponseDockerHub {
  count: number
  next?: string
  previous?: string
  results: TagsResponseDockerHubResults[]
}

export interface TagsResponseDockerHubResults {
  name: string
}
