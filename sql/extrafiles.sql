#!/bin/bash

# This file has the .sql extension, but it is actually launched as a shell
# script. This contortion is necessary because pg_regress normally uses
# psql to run the input scripts, and requires them to have the .sql
# extension, but we use a custom launcher script that runs the scripts using
# a shell instead.

# Test how pg_rewind reacts to extra files and directories in the data dirs.

TESTNAME=extrafiles

. sql/config_test.sh

# Create a subdir that will be present in both
function before_standby
{
  mkdir $TEST_MASTER/tst_both_dir
  echo "in both1" > $TEST_MASTER/tst_both_dir/both_file1
  echo "in both2" > $TEST_MASTER/tst_both_dir/both_file2
}

# Create subdirs that will be present only in one data dir.
function standby_following_master
{
  mkdir $TEST_STANDBY/tst_standby_dir
  echo "in standby1" > $TEST_STANDBY/tst_standby_dir/standby_file1
  echo "in standby2" > $TEST_STANDBY/tst_standby_dir/standby_file2
  mkdir $TEST_MASTER/tst_master_dir
  echo "in master1" > $TEST_MASTER/tst_master_dir/master_file1
  echo "in master2" > $TEST_MASTER/tst_master_dir/master_file2
}

function after_promotion
{
  :
}


# See what files and directories are present after rewind.
function after_rewind
{
    (cd $TEST_MASTER; find tst_* | sort)
}


# Run the test
. sql/run_test.sh