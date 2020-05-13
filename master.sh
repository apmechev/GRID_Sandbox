#!/bin/bash

# ===================================================================== #
# authors: Alexandar Mechev <apmechev@strw.leidenuniv.nl> --Leiden	#
#	   Natalie Danezi <anatoli.danezi@surfsara.nl>  --  SURFsara    #
#          J.B.R. Oonk <oonk@strw.leidenuniv.nl>    -- Leiden/ASTRON    #
#                                                                       #
# helpdesk: Grid Services <grid.support@surfsara.nl>    --  SURFsara    #
#                                                                       #
# usage: ./master.sh [OPTIONS]                                          #
#                                                                       #
# description:                                                          #
#       Set Lofar environment, fetch input from Grid Storage,           #
#       do averaging or demixing, then flag output with std. strategy,  #
#       finally copy the output to a (temporary) Grid Storage           #
# ===================================================================== #

#--- NEW SD ---
JOBDIR=${PWD}
OLD_PYTHON=$( which python)
echo $OLD_PYTHON

echo ""
echo ""
echo "Current rundir has:"
ls
echo ""
if [ -z "$TOKEN" ] || [  -z "$PICAS_USR" ] || [  -z "$PICAS_USR_PWD" ] || [  -z "$PICAS_DB" ]
 then
  echo "One of Token=${TOKEN}, Picas_usr=${PICAS_USR}, Picas_db=${PICAS_DB} not set"; exit 1 
fi



########################
### Importing functions
########################

for setupfile in `ls bin/* `; do source ${setupfile} ; done

trap cleanup EXIT
############################
#Initialize the environment
############################

setup_LOFAR_env $LOFAR_PATH      ##Imported from setup_LOFAR_env.sh

#trap cleanup EXIT #This ensures the script cleans_up regardless of how and where it exits

print_worker_info                      ##Imported from bin/print_worker_info

if [[ -z "$PIPELINE_STEP" ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!!!!!!NO PIPELINE_STEP!!!!!!!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi  



if [[ -z "$PARSET" ]]; then
    ls "$PARSET"
    echo "not found"
    exit 3  #exit 3=> Parset doesn't exist
fi

setup_run_dir                     #imported from bin/setup_run_dir.sh

print_job_info                  #imported from bin/print_job_info.sh
rm -rf ${RUNDIR}/prefactor/docs/*
echo ""
echo "---------------------------------------------------------------------------"
echo "START PROCESSING" $OBSID "SUBBAND:" $STARTSB
echo "---------------------------------------------------------------------------"
echo ""
echo "---------------------------"
echo "Starting Data Retrieval"
echo "---------------------------"

download_files srm.txt $PIPELINE_STEP

mkdir ${RUNDIR}/prefactor/cal_results/
find ${RUNDIR}/Input/ -name "*.h5" -exec mv {} ${RUNDIR}/prefactor/cal_results/ \; 

echo "Download finished, list contents"
ls -l $PWD/Input
du -hs $PWD/Input

replace_dirs            #imported from bin/modify_files.sh

if [[ ! -z ${CAL_OBSID} || ! -z ${CAL2_SOLUTIONS} ]]
then
 download_cals $CAL_OBSID
fi

if [[ ! -z $( echo $PIPELINE_STEP |grep targ1 ) ]]
  then
    runtaql 
    source /cvmfs/softdrive.nl/lofar_sw/env/current_RMextract.sh 

fi


#########
#Starting processing
#########
echo "Current directory is $PWD"
cd $PWD/prefactor
echo "+++++++++++++"
echo "++prefactor++"
echo "+++version+++"

git log --graph --decorate |head  -24
echo "+++++++++++++"
echo "+++++++++++++"
echo "Current directory is $PWD"
cd $RUNDIR/lofar-vlbi
echo "Contents of $RUNDIR/lofar-vlbi:"
ls
echo "+++++++++++++"
echo "++lofarvlbi++"
echo "+++version+++"

git log --graph --decorate |head  -24
echo "+++++++++++++"
echo "+++++++++++++"

cd $RUNDIR
rm -rf ${RUNDIR}/Input/inspection/*
rm -rf ${JOBDIR}/prefactor/docs/*
start_profile

run_pipeline

stop_profile

process_output output


#####################
# Make plots
#
######################

make_plots
#make_pie
# - step3 finished check contents

upload_results

cleanup 

echo ""
echo `date`
echo "---------------------------------------------------------------------------"
echo "FINISHED PROCESSING TOKEN " ${TOKEN}
echo "---------------------------------------------------------------------------"
