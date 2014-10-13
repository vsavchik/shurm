#!/bin/bash
# Copyright 2011-2014 vsavchik@gmail.com

cd `dirname $0`
. ./getopts.sh

TAG1=$1
BRANCH2=$2
shift 2

SCOPE=$*

# check params
if [ "$TAG1" = "" ]; then
	echo TAG1 not set
	exit 1
fi
if [ "$BRANCH2" = "" ]; then
	echo BRANCH2 not set
	exit 1
fi

# execute

. ./common.sh

export C_TAG1=$TAG1
export C_BRANCH2=$BRANCH2

if [ "$SCOPE" = "" ]; then
	SCOPE=all
fi

f_execute_all "$SCOPE" VCSCOPYTAGTOBRANCH

echo codebase-copytagtobranch.sh: tags $TAG1 copied to $BRANCH2
