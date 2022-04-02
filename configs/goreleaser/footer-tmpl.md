~START_GHCR~
### Container Images (ghcr)

```console
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:latest
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.RawVersion}}
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.Major}}.{{.Minor}}
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.Major}}
```
~END_GHCR~

#### Build info

   * **Built with**: `${GOBUILDINFO}`
   * **Release job**: [${GITHUB_WORKFLOW}/${GITHUB_JOB}](https://github.com/lrstanley/liam.sh/actions/runs/${GITHUB_RUN_ID}) by @${GITHUB_ACTOR}.

## What to do next?

   * Running into an issue or want a specific feature?
     [Submit a new issue](https://github.com/${GITHUB_REPOSITORY}/issues/new)
     or join [the Discord](https://liam.sh/chat) (`#coding` channel)!
   * Find [previous releases](https://github.com/${GITHUB_REPOSITORY}/releases).
   * Find a vulnerability? Check out our [Security and Disclosure](https://github.com/${GITHUB_REPOSITORY}/security/policy)
     policy.
   * Other useful links:
     [License](https://github.com/${GITHUB_REPOSITORY}/blob/master/LICENSE)
     [Contributing](${CONTRIBUTING}),
     [Support](${SUPPORT}),
     [Code of Conduct](https://github.com/lrstanley/.github/blob/master/CODE_OF_CONDUCT.md).
