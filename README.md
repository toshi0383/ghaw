# ghaw

ghaw (GitHub at work) is useful CLI tool for professional GitHub users.

# Command

## `find-pull-requests`
Find pull-requests matching given filename.
Requires explicit merge commit with default message from GitHub.

```console
$ ghaw find-pull-requests HumbergerViewModel
https://github.com/toshi0383/hamburgerapp/pull/4119
https://github.com/toshi0383/hamburgerapp/pull/4089
https://github.com/toshi0383/hamburgerapp/pull/3824
https://github.com/toshi0383/hamburgerapp/pull/3533
https://github.com/toshi0383/hamburgerapp/pull/2912
```

## `ready-for-review`
Display pull-requests awaiting for your review.
One with `WIP` label is filtered.
This is the default command when you typed just `ghaw`.

```
$ ghaw
https://github.com/org/app/pull/4187 🔖v2.17.0 ✅0
https://github.com/org/app/pull/4256 🔖v2.16.0 ✅1 🤔
https://github.com/org/app/pull/4243 🔖v2.16.0 ✅2
https://github.com/org/app/pull/4239 🔖v2.16.0 ✅0 🤔
```

JSON output option (`-j`) is also supported in case you want to change the output.

## `job-done`
Display your comment count of each pull-requests which you've reviewed today.

# Install

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
