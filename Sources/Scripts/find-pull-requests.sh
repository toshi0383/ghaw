#!/bin/bash
#
# description:
#   Find pull-requests matching given filename.
#
# author:
#   Toshihiro Suzuki
#
# since:
#   2018-07-20
#
# Copyright © 2018年 Toshihiro Suzuki All rights reserved.

MATCH=${1:?}

if which fd > /dev/null 2>&1
then
    FIND_COMMAND=fd
else
    FIND_COMMAND=find . -name
fi

USER_REPO=$(git remote -v | head -1 | sed -n 's/.*github.com.\(.*\)\.git.*/\1/p')

PULL_URL=https://github.com/$USER_REPO/pull

$FIND_COMMAND $MATCH | \
    xargs git log --pretty=%H | \
    awk '{print $1}' | \
    sed -n 's/\(.*\)/git log --merges --oneline --reverse --ancestry-path \1...master | grep "Merge pull request #" | head -n 1/p' | \
    xargs -0 bash -c | \
    sed -n 's/.*#\([0-9][0-9]*\) .*/\1/p' | \
    sort -nr | \
    uniq | \
    sed "s,^,$PULL_URL/,"
