
# Contributing Guidelines

Thank you for your interest in contributing to the Mario Progress Bar ! Please read, understand, and agree to the following before making your contribution. Please also ensure you have read and agreed to the [Code of Conduct](CODE_OF_CONDUCT.md).

If you have any issues or questions, please, do not hesitate to contact [the maintainer](https://github.com/KikiManjaro) of this plugin.

## Workflow

The workflow for this project is pretty standard:

```none
open issue and have it assigned to you
            │
            v
    fork repository
            │
            v
create feature/{issueNumber} or 
{fix/issueNumber} branch based off
   of the develop branch
            |
            v
    commit to fix issue
            │
            v
open pull request to develop branch
            │
            v
       code review<────────┐
            │   │          │
            │   └─> address feedback
            v
approved, merged, issue closed
            |
            v
release branch created from develop
    by project maintainer
            |
            v
release branch merged to master
            │
            v
         deployed
```

## Bug Reports

Please make sure all bug reports have not already been reported or fixed, and come with a clear description of the situation, effect, expected experience, and, if at all possible, steps to reproduce the bug.

## Feature Requests

Please make sure all feature requests are clear, concise, feasible, useful, and not already implemented or requested.

## Pull Requests

Pull requests for bugs or features are encouraged, but please open an issue first and ensure it has been discussed & approved. Your code will be reviewed as soon as possible; please be willing to accept feedback & and change your pull request as needed.

Also ensure that the extension still runs properly after your changes, by using the built in extension debugger in IntelliJ.

Ideally, we'd like to work with a branch-per-issue policy, as well as a one-commit-per-issue policy. Feel free to make a separate commit when addressing code review comments, or to amend your existing commit. If new commits are made, they may be squashed into the original before merging.

Preferably you should be using [signed commits](https://help.github.com/en/articles/signing-commits), although this is not required.

### Additional PR Information

* This plugin is written using Java 8 and the IntelliJ SDK. 
* Please also do your best to follow the existing code style. You may be asked to refactor your code if it does not match the existing style, in the interest of consistency.