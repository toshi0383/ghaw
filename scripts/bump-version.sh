#!/bin/bash
VERSION=${1:?}
CURRENT=0.3.6
#sed -i "" -e "s/master/${VERSION}/" CHANGELOG.md
git grep -l $CURRENT | xargs sed -i "" -e "s/${CURRENT}/${VERSION}/g"
