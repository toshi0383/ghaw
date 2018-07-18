# ghaw

ghaw (GitHub at work) is useful cli command for professional GitHub users.

# Actions
## ready-for-review
Display pull-requests awaiting for your review.

## job-done
Display your comment count of each pull-requests which you've reviewed today.

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
