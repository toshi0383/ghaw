#!/bin/bash
VERSION=${1:?}
CURRENT=0.3.5
#sed -i "" -e "s/master/${VERSION}/" CHANGELOG.md
git grep -l $CURRENT | xargs sed -i "" -e "s/${CURRENT}/${VERSION}/g"
