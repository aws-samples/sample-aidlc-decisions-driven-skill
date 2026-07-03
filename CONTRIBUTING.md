# Contributing Guidelines

Thank you for your interest in contributing to our project. Whether it's a bug report, new feature, correction, or additional
documentation, we greatly value feedback and contributions from our community.

Please read through this document before submitting any issues or pull requests to ensure we have all the necessary
information to effectively respond to your bug report or contribution.


## Reporting Bugs/Feature Requests

We welcome you to use the GitHub issue tracker to report bugs or suggest features.

When filing an issue, please check existing open, or recently closed, issues to make sure somebody else hasn't already
reported the issue. Please try to include as much information as you can. Details like these are incredibly useful:

* A reproducible test case or series of steps
* The version of our code being used
* Any modifications you've made relevant to the bug
* Anything unusual about your environment or deployment


## Contributing via Pull Requests
Contributions via pull requests are much appreciated. Before sending us a pull request, please ensure that:

1. You are working against the latest source on the *main* branch.
2. You check existing open, and recently merged, pull requests to make sure someone else hasn't addressed the problem already.
3. You open an issue to discuss any significant work - we would hate for your time to be wasted.

To send us a pull request, please:

1. Fork the repository.
2. Modify the source; please focus on the specific change you are contributing. If you also reformat all the code, it will be hard for us to focus on your change.
3. Run `./scripts/validate.sh` to verify cross-references are intact.
4. Commit to your fork using clear commit messages.
5. Send us a pull request, answering any default questions in the pull request interface.
6. Pay attention to any automated CI failures reported in the pull request, and stay involved in the conversation.

GitHub provides additional document on [forking a repository](https://help.github.com/articles/fork-a-repo/) and
[creating a pull request](https://help.github.com/articles/creating-a-pull-request/).


## Finding contributions to work on
Looking at the existing issues is a great way to find something to contribute on. As our projects, by default, use the default GitHub issue labels (enhancement/bug/duplicate/help wanted/invalid/question/wontfix), looking at any 'help wanted' issues is a great place to start.


## Skill Development Notes

For a complete guide on creating a new skill, see [docs/developing-skills.md](docs/developing-skills.md).

### Validation

Before submitting a PR, run the validation script to check cross-references:

```bash
./scripts/validate.sh
```

This verifies: core/optional skill files exist, shared resources present, all action files referenced in SKILL.md exist, frontmatter has required fields, and example manifest is valid. CI runs this automatically on every PR.

### Shared Base Consistency

The shared base (`skills/aidlc/shared/base.md`) is loaded by all skills. When modifying it:
1. Verify all skills (12 phase/supporting skills + the orchestrator) still work with the updated base
2. Check that §Summary still covers the essentials for chained dispatch
3. Run `./scripts/validate.sh`

### Template Conventions

- All output templates must include a `## Summary` section as the first content section (after the title). Downstream skills read only this section during initialization.
- Conditional sections (e.g., GraphQL in api-spec.md, NoSQL in data-model.md) should be clearly gated with comments like `> Include this section ONLY if D3 chose [option]`.


## Code of Conduct
This project has adopted the [Amazon Open Source Code of Conduct](https://aws.github.io/code-of-conduct).
For more information see the [Code of Conduct FAQ](https://aws.github.io/code-of-conduct-faq) or contact
opensource-codeofconduct@amazon.com with any additional questions or comments.


## Security issue notifications
If you discover a potential security issue in this project we ask that you notify AWS/Amazon Security via our [vulnerability reporting page](http://aws.amazon.com/security/vulnerability-reporting/). Please do **not** create a public github issue.


## Licensing

See the [LICENSE](LICENSE.md) file for our project's licensing. We will ask you to confirm the licensing of your contribution.
