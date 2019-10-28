#!/bin/bash

function runtaql(){

    echo "running taql on "$( ls -d ${RUNDIR}/Input/*${OBSID}*SB*  )"/SPECTRAL_WINDOW"
    if  [ ! -z ${SIMG+x} ]; then
        MS=$(ls -d ${RUNDIR}/Input/*${OBSID}*SB*)
        singularity exec -B /scratch,$PWD $SIMG taql select distinct REF_FREQUENCY from $MS::SPECTRAL_WINDOW
        FREQ=$(singularity exec -B /scratch,$PWD $SIMG taql select distinct REF_FREQUENCY from $MS::SPECTRAL_WINDOW | tail -n 1 | head -n 1)
    else
        FREQ=$( echo "select distinct REF_FREQUENCY from $( ls -d ${RUNDIR}/Input/*${OBSID}*SB*  )/SPECTRAL_WINDOW"| taql | tail -1 | head -1)
    fi
    export A_SBN=$( python  update_token_freq.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} ${FREQ} )
    export ABN=$( python  update_token_freq.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} ${FREQ} )
    echo "Frequency is "${FREQ}" and Absolute Subband is "${ABN}
    mv prefactor/results/L*ms ${RUNDIR}  #moves untarred results from targ1 to ${RUNDIR} 


}

