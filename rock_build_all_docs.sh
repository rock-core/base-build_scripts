#! /bin/bash

set -x

SRC_DIR_WORKSPACE_PREFIX=/home/build/jenkins/workspace
SRC_DIR_FLAVOR_PREFIX=FLAVOR
SRC_DIR_SUFFIX=label/DebianUnstable
LOG_DIR=/home/build/logs
sudo apt-get install doxygen

mkdir -p $LOG_DIR
result=0
for workspace_dir in $SRC_DIR_WORKSPACE_PREFIX/*; do
    workspace_name=`basename $workspace_dir`
    if ! test -d $workspace_dir/$SRC_DIR_FLAVOR_PREFIX; then
        continue
    fi

    for flavor_dir in $workspace_dir/$SRC_DIR_FLAVOR_PREFIX/*; do
	echo
	flavor_name=`basename $flavor_dir`
	path=$flavor_dir/$SRC_DIR_SUFFIX
	if ! test -f $path/dev/doc-successful; then
	    echo "last build of $workspace_name:$flavor_name did not generate documentation, skipping"
	    continue
	fi

        set +e
        if test "$FORCE_DOC_GEN" = "1"; then
            rm -f $path/docgen.stamp
        fi

	if test -f $path/docgen.stamp && test $path/docgen.stamp -nt $path/dev/doc-successful; then
	    echo "build of $workspace_name:$flavor_name did not get updated since last time. Skipping ..."
	    continue
	fi

	echo "generating documentation for $workspace_name:$flavor_name"
        rm -rf $path/doc
        mkdir $path/doc
        cp -r $path/api $path/doc

	( set -e
	  cd $path/dev
	  . ./env.sh
          export PATH=/home/build/rock_admin_scripts/bin:$PATH
          export RUBYLIB=/home/build/rock_admin_scripts/lib:$RUBYLIB

	  gem install webgen coderay --no-rdoc --no-ri

          tempdir=$(mktemp -d)
          echo "creating rock's main documentation"
          cd $tempdir
          git clone http://git.gitorious.org/rock/doc.git main

          cd $path/dev
          rock-directory-pages $status "$tempdir/main/src/package_directory" $path/doc/api

          cd $tempdir/main
          rake
          echo "moving main documentation in $path/doc"
          mv out/* $path/doc

          echo "deleting $tempdir"
          rm -rf $tempdir
	) > $path/docgen.txt 2>&1
	if test "$?" -ne "0"; then
	    echo "generation failed for $workspace_name:$flavor_name"
	    echo "log in $workspace_name-$flavor_name.txt"
	    result=1
	else
	    touch $path/docgen.stamp
	fi
        cp $path/docgen.txt $workspace_name-$flavor_name.txt
	set -e
    done
done
exit $result

