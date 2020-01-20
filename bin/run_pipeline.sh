#!/bin/bash



function run_with_singularity(){
# first argument is the singularity Image file
# second argument is the script to run

echo "Running prefactor in image ${SIMG}"

singularity exec ${SIMG} which genericpipeline.py
echo ${PARSET}
cat sing_pipeline.cfg
export SINGULARITYENV_PYTHONPATH=$(echo "$PYTHONPATH" | sed -e 's/:\/cvmfs\/softdrive\.nl\/lofar_sw\/RMextract\/lib\/python2.7\/site-packages//')
singularity exec ${SIMG} genericpipeline.py ${PWD}/${PARSET} -d -c sing_pipeline.cfg  > output
}

function run_pipeline(){

mkdir -p ${RUNDIR}/prefactor/rundir
mkdir -p ${RUNDIR}/prefactor/workdir

echo ""
echo "Running Prefactor Parset"
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'launching_pipeline'
python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_progress.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} output ${PARSET} &


if [[ -n $SIMG  ]]; then
    echo "Running using the singularity image at ${SIMG}"
    run_with_singularity 
else
    echo "Running using LOFAR version at $LOFAR_PATH"
    which genericpipeline.py
    echo ${PARSET}
    cat pipeline.cfg
    genericpipeline.py ${PWD}/${PARSET} -d -c pipeline.cfg > output
fi

python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'pipeline_completed'

echo "Output file:"
wc output
#python ${JOBDIR}/GRID_PiCaS_Launcher/update_token_status.py ${PICAS_DB} ${PICAS_USR} ${PICAS_USR_PWD} ${TOKEN} 'processing_finished'

}
