#!/bin/bash

function download_cals(){

if [ -z ${CAL2_SOLUTIONS+x}  ];
     then 
         echo "Getting solutions from obsid " $1
         globus-url-copy gsiftp://gridftp.grid.sara.nl:2811/pnfs/grid.sara.nl/data/lofar/user/sksp/diskonly/pipelines/SKSP/prefactor_v1.0/pref_cal2/${1}/${1}.tar file:${RUNDIR}/Input/cal_solutions.tar
     else
         echo "Getting solutions from " $CAL2_SOLUTIONS
         globus-url-copy $CAL2_SOLUTIONS file:${RUNDIR}/Input/cal_solutions.tar 
fi

 wait
 cd ${RUNDIR}/Input
 if [[ -e cal_solutions.tar ]]
  then
    tar -xvf cal_solutions.tar
 else
    exit 23 #exit 23=> solutions do not get downloaded
 fi
 mkdir -p ${RUNDIR}/prefactor/cal_values
 cp ${RUNDIR}/Input/prefactor/cal_results/* ${RUNDIR}/prefactor/cal_values/

 find ${RUNDIR}/Input/ -name "*.h5" -exec mv {} ${RUNDIR}/prefactor/cal_values/ \; 
 cd ${RUNDIR}

echo "Cal_results directory contains:"
ls ${RUNDIR}/prefactor/cal_values

}
