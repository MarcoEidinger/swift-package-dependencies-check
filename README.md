# Swift Package Dependencies Checker

This action process your Package.swift file to detect outdated versions based on your [package dependency requirements](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#package-dependency-requirement).

This action requires [actions/checkout](https://github.com/actions/checkout) in order to function correctly.

```yaml
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: MarcoEidinger/swift-package-dependencies-check@1.0.0
```

Action will fail in case there are outdated dependencies.

By setting `isMutating` you declare the intention to update `Package.resolved` (if present). Please note that the action iteself does not commit/push changes.

```yaml
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: MarcoEidinger/swift-package-dependencies-check@1.0.0
        with:
          isMutating: 'true'
```

A possible _workflow_ to periodically check for outdated dependencies and then create a pull request to update them: 

```yaml
name: Swift Package Dependencies

on: 
  schedule:
    - cron: '0 8 * * 1' # every monday AM 8:00
jobs:
  spm-dep-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Check Swift package dependencies
      uses: MarcoEidinger/swift-package-dependencies-check@1.0.0
      with:
        isMutating: true
    - name: Create Pull Request
      if: failure()
      uses: peter-evans/create-pull-request@v3
      with:
        commit-message: 'chore: update package dependencies'
        branch: updatePackageDepedencies
        delete-branch: true
        title: 'chore: update package dependencies'
        body: ''
```

Interally the action utilizies  `swift package show-dependencies` and `swift package update` (either with or without the `--dry-run` option). Per default it runs as non-modifying, i.e. with `--dry-run`
