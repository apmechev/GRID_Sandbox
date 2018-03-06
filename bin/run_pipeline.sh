#!/bin/bash

function run_pipeline(){


echo ""
echo "Running test script"
$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'running pipeline'
$OLD_PYTHON update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &

ls ${PWD}
ls ${RUNDIR}/Input

echo ""
echo "Testing LOFAR Environment"
which NDPPP
NDPPP --version

echo "Running script $SCRIPT"

chmod a+x $SCRIPT

./${SCRIPT}

$OLD_PYTHON update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
