# ghaw

ghaw (GitHub at work) is useful CLI tool for professional GitHub users.

# Command
## `ready-for-review`
Display pull-requests awaiting for your review.
One with `WIP` label is filtered.

## `find-pull-requests`
Find pull-requests matching given filename.
```console
$ find-pull-requests HumbergerViewModel
https://github.com/toshi0383/hamburgerapp/pull/4119
https://github.com/toshi0383/hamburgerapp/pull/4089
https://github.com/toshi0383/hamburgerapp/pull/3824
https://github.com/toshi0383/hamburgerapp/pull/3533
https://github.com/toshi0383/hamburgerapp/pull/2912
```

## `job-done`
Display your comment count of each pull-requests which you've reviewed today.
JSON output option (`-u`) is supported.

# Install
## Binary
```
bash <(curl -sL https://raw.githubusercontent.com/toshi0383/scripts/master/swiftpm/install.sh) toshi0383/ghaw
```

## Mint
```
mint install toshi0383/ghaw
```

# Setup
Set `GITHUB_ACCESS_TOKEN` environment variable.

Repository information (owner/name) and GitHub username is automatically extracted from your environment. Use `-u` option if it's not correct or to use different GitHub user.
```
ghaw -u toshi0383 ready-for-review
```

# License
MIT
