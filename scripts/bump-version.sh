#!/bin/bash
VERSION=${1:?}
CURRENT=0.4.0
#sed -i "" -e "s/master/${VERSION}/" CHANGELOG.md
git grep -l $CURRENT | xargs sed -i "" -e "s/${CURRENT}/${VERSION}/g"
