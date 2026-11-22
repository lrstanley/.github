<!-- Default community health file: used by every lrstanley repository without its own copy. Source: https://github.com/lrstanley/.github -->
# :handshake: Contributing

This document outlines some of the guidelines that we try and adhere to while
working on this project.

> [!IMPORTANT]
> before participating in the community, please read our [Code of Conduct][coc].
> By interacting with this repository, organization, or community you agree to
> abide by our Code of Conduct.

> [!CAUTION]
> If you contribute **any source code** to this repository, you agree to the terms
> of the [Developer Certificate of Origin][dco]. This helps ensure that contributions
> aren't in violation of 3rd party license terms.
>
> ### AI Assisted Development
> **AI Agents MUST NOT add `Signed-off-by` tags to commits.**
> Only humans can legally certify the [Developer Certificate of Origin][dco]. The
> human submitter is responsible for:
>
> - Reviewing all AI-generated code
> - Ensuring compliance with licensing requirements
> - Adding their own Sign-off-by tag to certify the DCO
> - Taking full responsibility for the contribution

## :lady_beetle: Issue submission

When submitting an issue or bug report (from the **Issues** tab of the
project's repository), please follow these guidelines:

- Provide as much information as possible (logs, metrics, screenshots,
  runtime environment, etc).
- Ensure that you are running on the latest stable version (tagged), or
  when using the default branch, provide the specific commit being used.
- Provide the minimum needed viable source to replicate the problem.

## :bulb: Feature requests

When submitting a feature request (also from the **Issues** tab), please follow
these guidelines:

- Does this feature benefit others? or just your usecase? If the latter,
  it will likely be declined, unless it has a more broad benefit to others.
- Please include the pros and cons of the feature.
- If possible, describe how the feature would work, and any diagrams/mock
  examples of what the feature would look like.

## :rocket: Pull requests

To review what is currently being worked on, or looked into, feel free to head
over to the open pull requests or issues of the project's repository.

## :raised_back_of_hand: Assistance with discussions

- Take a look at the open discussions in the **Discussions** tab of the
  project's repository, and if you feel like you'd like to help out other
  members of the community, it would be much appreciated!

## :pushpin: Guidelines

### :test_tube: Language agnostic

Below are a few guidelines if you would like to contribute:

- If the feature is large or the bugfix has potential breaking changes,
  please open an issue first to ensure the changes go down the best path.
- If possible, break the changes into smaller PRs. Pull requests should be
  focused on a specific feature/fix.
- Pull requests will only be accepted with sufficient documentation
  describing the new functionality/fixes.
- Keep the code simple where possible. Code that is smaller/more compact
  does not mean better. Don't do magic behind the scenes.
- Use the same formatting/styling/structure as existing code.
- Follow idioms and community-best-practices of the related language,
  unless the previous above guidelines override what the community
  recommends.
- Always test your changes, both the features/fixes being implemented, but
  also in the standard way that a user would use the project (not just
  your configuration that fixes your issue).
- Only use 3rd party libraries when necessary. If only a small portion of
  the library is needed, simply rewrite it within the library to prevent
  useless imports.

The sections below apply if the project uses that language.

### :hamster: Golang

- See [golang/go/wiki/CodeReviewComments](https://github.com/golang/go/wiki/CodeReviewComments)
- Lint Go code with [golangci-lint](https://golangci-lint.run/). Most editors
  that support `gopls` can run it for you, or run `golangci-lint run` locally
  after installing it.

### :penguin: Bash/Posix-shell

- Lint `bash` and `sh` scripts with [shellcheck](https://github.com/koalaman/shellcheck).
  It helps write proper scripts, and should help catch any potential
  bugs/issues. This is available in VSCode [here](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck).
- Format shell scripts with `shfmt` where possible, generally with the flags
  `shfmt -s -bn -ci -sr`. This is available in VSCode
  [here](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format).

### :whale: Dockerfile

- Follow container best practices, like [keeping images as small as possible](https://phoenixnap.com/kb/docker-image-size).
- Lint `Dockerfile`s with [shellcheck](https://github.com/koalaman/shellcheck),
  or your editor's native Docker extension. This is available in VSCode
  [here](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck).

### :snake: Python

- All functions/methods/files should use type annotations when available, in
  addition to ensuring all functions/methods have proper docstrings.

## :clipboard: References

- [Open Source: How to Contribute](https://opensource.guide/how-to-contribute/)
- [About pull requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
- [GitHub Docs](https://docs.github.com/)

## :speech_balloon: What to do next?

- :old_key: Find a vulnerability? Check out our [Security and Disclosure][security] policy.
- :link: See the `LICENSE` file in the project's repository.
- [Support][support]
- [Code of Conduct][coc].

<!-- definitions -->
[coc]: https://github.com/lrstanley/.github/blob/master/.github/CODE_OF_CONDUCT.md
[dco]: https://developercertificate.org/
[security]: https://github.com/lrstanley/.github/blob/master/.github/SECURITY.md
[support]: https://github.com/lrstanley/.github/blob/master/.github/SUPPORT.md
