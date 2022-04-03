~START_GHCR~
### :whale: Container Images (ghcr)

```console
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:latest
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.RawVersion}}
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.Major}}.{{.Minor}}
$ docker run -it --rm ghcr.io/${INPUT_IMAGE_NAME}:{{.Major}}
```
~END_GHCR~

#### :test_tube: Build info

{{if .PreviousTag}}   * :open_file_folder: **Full changelog**: [](https://github.com/${GITHUB_REPOSITORY}/compare/{{.PreviousTag}}...{{.Tag}}){{end}}
   * :muscle: **Built with**: `${GOBUILDINFO}`
   * :gear: **Release job**: [${GITHUB_WORKFLOW}/${GITHUB_JOB}](https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}) triggered by @${GITHUB_ACTOR}.

## :speech_balloon: What to do next?

   * :raising_hand_man: Running into an issue or want a specific feature? [Submit a new issue](https://github.com/${GITHUB_REPOSITORY}/issues/new) or join [the Discord](https://liam.sh/chat) (`#coding` channel)!
   * :watch: Find [previous releases](https://github.com/${GITHUB_REPOSITORY}/releases).
   * :old_key: Find a vulnerability? Check out our [Security and Disclosure](https://github.com/${GITHUB_REPOSITORY}/security/policy) policy.
   * :link: Other useful links: [License](https://github.com/${GITHUB_REPOSITORY}/blob/master/LICENSE), [Contributing](${CONTRIBUTING}), [Support](${SUPPORT}), [Code of Conduct](https://github.com/lrstanley/.github/blob/master/CODE_OF_CONDUCT.md).
