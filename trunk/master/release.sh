#!/bin/bash

cd `dirname $0`
S_SCRIPTDIR=`pwd`
. ./getopts.sh

X_RELEASE=$1
X_CMD=$2

function f_local_msg() {
	local P_ENV=$1
	local P_MSG=$2

	cd $C_CONFIG_PRODUCT_DEPLOYMENT_HOME/master/deployment/$P_ENV
	echo "chatmsg: $P_MSG"
	./sendchatmsg.sh "$P_MSG"

	cd $S_SCRIPTDIR
}

function f_local_release_check_exists() {
	local P_RELEASE=$1

	if [ ! -f $C_CONFIG_DISTR_PATH/$P_RELEASE/release.xml ]; then
		echo "invalid release $P_RELEASE. Exiting"
		exit 1
	fi

	echo "using release definition file: $C_CONFIG_DISTR_PATH/$P_RELEASE/release.xml"
}

function f_local_release_build() {
	local P_RELEASE=$1

	echo "start build..."

	cd $C_CONFIG_PRODUCT_DEPLOYMENT_HOME/master/makedistr/branch
	./buildall-release.sh -release $P_RELEASE -dist
	if [ "$?" != "0" ]; then
		echo "buildall-release.sh failed. Exiting"
		exit 1
	fi

	cd $S_SCRIPTDIR
}

function f_local_release_getsql() {
	echo "get database scripts..."

	# get database scripts
	local F_SQLFOLDER=prod-patch-$P_RELEASE
	cd $C_CONFIG_PRODUCT_DEPLOYMENT_HOME/master/database

	./getsql.sh -m -s $F_SQLFOLDER
	if [ "$?" != "0" ]; then
		echo "getsql.sh failed. Exiting"
		exit 1
	fi

	cd $S_SCRIPTDIR
}

function f_local_release_applydb() {
	local P_RELEASE=$1
	local P_ENV=$2

	echo "apply scripts..."

	cd $C_CONFIG_PRODUCT_DEPLOYMENT_HOME/master/deployment/$P_ENV/database
	./sqlapply.sh -x -s -l $P_RELEASE
	if [ "$?" != "0" ]; then
		echo "sqlapply.sh failed. Exiting"
		exit 1
	fi

	cd $S_SCRIPTDIR
}

function f_local_release_deploy() {
	local P_RELEASE=$1
	local P_ENV=$2

	echo "apply scripts..."

	cd $C_CONFIG_PRODUCT_DEPLOYMENT_HOME/master/deployment/$P_ENV
	./redist.sh $P_RELEASE
	if [ "$?" != "0" ]; then
		echo "redist.sh failed. Exiting"
		exit 1
	fi

	./deployredist.sh $P_RELEASE
	if [ "$?" != "0" ]; then
		echo "deployredist.sh failed. Exiting"
		exit 1
	fi

	cd $S_SCRIPTDIR
}

function f_execute_cmd_uat() {
	local P_RELEASE=$1

	local F_ENV="uat"
	if [ "$GETOPT_ENV" != "" ]; then
		F_ENV=$GETOPT_ENV
	fi

	f_local_msg $F_ENV "start build release $P_RELEASE and deploy into environment $F_ENV..."

	# check release exists
	f_local_release_check_exists $P_RELEASE

	# build release and get distributive
	f_local_release_build $P_RELEASE

	# get database scripts
	f_local_release_getsql $P_RELEASE

	f_local_msg $F_ENV "apply scripts and stop environment to deploy release..."

	# apply scripts
	f_local_release_applydb $P_RELEASE $F_ENV

	# deploy binaries and configuration files
	f_local_release_deploy $P_RELEASE $F_ENV

	f_local_msg $F_ENV "done."
}

function f_execute_all() {
	# action by command
	if [ "$P_CMD" = "uat" ]; then
		f_execute_cmd_uat $X_RELEASE
	else
		echo "unknown command=$P_CMD. Exiting"
		exit 1
	fi
}

f_execute_all
echo release.sh: successfully completed.
