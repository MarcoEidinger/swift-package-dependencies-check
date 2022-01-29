# Swift Package Dependencies Checker

This action process your Package.swift file to detect outdated versions based on your [package dependency requirements](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#package-dependency-requirement).

This action requires [actions/checkout](https://github.com/actions/checkout) in order to function correctly.

```yaml
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: MarcoEidinger/swift-package-dependencies-check@v2
```

Action will fail in case there are outdated dependencies. This can be suppressed by setting input parameter `failWhenOutdated` to false. Then use output parameter `outdatedDependencies` to know if action detected any outdated dependencies.

```yaml
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: MarcoEidinger/swift-package-dependencies-check@2.1.0
        with:
          failWhenOutdated: false # or 'false'
```

By setting `isMutating` you declare the intention to update `Package.resolved` (if present). Please note that the action itself does not commit/push changes.

```yaml
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: MarcoEidinger/swift-package-dependencies-check@v2
        with:
          isMutating: 'true' # or true
```

When setting `isMutating` the tool [SwiftPackageIndex/ReleaseNotes](https://github.com/SwiftPackageIndex/ReleaseNotes) is used to return release notes URLs for detected, necessary updates.

A possible _workflow_ to periodically check for outdated dependencies and then create a pull request to update them: 

```yaml
name: Swift Package Dependencies

on: 
  schedule:
    - cron: '0 8 * * 1' # every monday AM 8:00
jobs:
  spm-dep-check:
    runs-on: ubuntu-20.04
    steps:
    - uses: actions/checkout@v2
    - name: Check Swift package dependencies
      id: spm-dep-check
      uses: MarcoEidinger/swift-package-dependencies-check@2.1.0
      with:
         isMutating: true
         failWhenOutdated: false
    - name: Create Pull Request
      if: steps.spm-dep-check.outputs.outdatedDependencies  == 'true'
      uses: peter-evans/create-pull-request@v3
      with:
        commit-message: 'chore: update package dependencies'
        branch: updatePackageDepedencies
        delete-branch: true
        title: 'chore: update package dependencies'
        body: ${{ steps.spm-dep-check.outputs.releaseNotes }}
```

For your convenience I created a workflow which can reuse like this.

```yaml
name: Swift Package Dependencies

on: 
  schedule:
    - cron: '0 8 * * 1' # every monday AM 8:00 
jobs:
  dependencies:
    uses: MarcoEidinger/swift-package-dependencies-check/.github/workflows/reusableWorkflow.yml@v2
    with:
      commit-message: 'chore: update package dependencies'

```

Internally the action utilizes `swift package show-dependencies` and `swift package update` (either with or without the `--dry-run` option). Per default it runs as non-modifying, i.e. with `--dry-run`.

You can also pin to a [specific release](MarcoEidinger/swift-package-dependencies-check/releases) version in the format @2.x.x

- Version 1.0.x is using Swift 5.2
- Version 1.1.x is using Swift 5.3
- Version 2.0.x is using Swift 5.5
- Version 2.1.x is using Swift 5.5
