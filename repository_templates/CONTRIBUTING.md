# Contributing

## Issue submission

When submitting an issue or bug report, please follow these guidelines:

   * Provide as much information as possible (logs, metrics, screenshots,
     runtime environment, etc).
   * Ensure that you are running on the latest stable version (tagged), or
     when using master, provide the specific commit being used.
   * Provide the minimum needed viable source to replicate the problem.

## Feature requests

When submitting a feature request, please follow these guidelines:

   * Does this feature benefit others? or just your usecase? If the latter,
     it will likely be declined, unless it has a more broad benefit to others.
   * Please include the pros and cons of the feature.
   * If possible, describe how the feature would work, and any diagrams/mock
     examples of what the feature would look like.

## Pull requests

To review what is currently being worked on, or looked into, feel free to head
over to the [issues list](../../issues).

## Guidelines

### Language agnostic

Below are a few guidelines if you would like to contribute:

   * If the feature is large or the bugfix has potential breaking changes,
     please open an issue first to ensure the changes go down the best path.
   * If possible, break the changes into smaller PRs if possible. Pull requests
     should be focused on a specific feature/sbx.
   * Pull requests will only be accepted with sufficient documentation
     describing the new functionality/fixes.
   * Keep the code simple where possible. Code that is smaller/more compact
     does not mean better. Don't do magic behind the scenes.
   * Use the same formatting/styling/structure as existing code.
   * Follow idioms and community-best-practices of the related language,
     unless the previous above guidelines override what the community
     recommends.
   * Always test your changes, both the features/fixes being implemented, but
     also in the standard way that a user would use the project (not just
     your configuration, to fix your issue).
   * Only use 3rd party libraries if necessary. If only a small portion of
     the library is needed, simply rewrite it within the library to prevent
     useless imports.

### Golang

   * See [golang/go/wiki/CodeReviewComments](https://github.com/golang/go/wiki/CodeReviewComments)

## References

   * [Open Source: How to Contribute](0https://opensource.guide/how-to-contribute/)
   * [About pull requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
   * [GitHub Docs](https://docs.github.com/en)

## Questions

Have any questions? Feel free to [reach out here](https://liam.sh/chat).
