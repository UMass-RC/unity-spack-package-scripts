#!/bin/bash

# USAGE
# ./install-package <spack package spec>

#SPACK_PACKAGE_NAME=$1
SPACK_PACKAGE_NAME=$*
JOB_NAME="build_${SPACK_PACKAGE_NAME// /_}" # find and replace spaces with underscores

#echo "spack install $SPACK_PACKAGE_NAME"
#[[ "$(read -e -p 'is this correct? [y/N]> '; echo $REPLY)" == [Yy]* ]] || exit


IFS=$'\n' read -d '' -r -a lines < state/archlist.txt

for i in "${lines[@]}"
do
    echo "Queuing job for architecture $i..."
    sbatch --job-name="$JOB_NAME" --constraint=$i --output=logs/$JOB_NAME-$i.out \
	    --export=SPACK_PACKAGE_NAME="$SPACK_PACKAGE_NAME" slurm/slurm-install-batch.sh
    echo log file: logs/$JOB_NAME-$i.out
done

# TODO use -d to make another job dependent on all these which can let me know when they are done
# add to package file if not already there
# TODO only if jobs were a success
grep -qxF "$SPACK_PACKAGE_NAME" state/packagelist.txt || echo $SPACK_PACKAGE_NAME >> state/packagelist.txt

# TODO never use spack gc it's broken, use Simon's Lmod hiding script and then Simon's lmod_regen_modfiles alias
# finished submitting jobs
#echo "Remember to run spack gc afterwards to remove excess build dependencies"
