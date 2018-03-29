#=========
#Updates the status of the token from a shell script or another python script
#
#=========

import GRID_PiCaS_Launcher.couchdb as couchdb
import os,sys,time,subprocess
from GRID_PiCaS_Launcher.update_token_status import update_status

start=0
def progress_loop(db,uname,paswd,tok_id,directory,parset="Pre-Facet-Calibrator.parset"):
    '''
        Loops while generic pipeline is running and updates the token to the current
        step running and the timestamp of the step start.
    '''
    #Get the number of steps from the parset and update progress % (+1 for downloading)

    p=subprocess.Popen(['pgrep','-u',os.environ["USER"],'-f','pipeline.py'],stdout=subprocess.PIPE)
    running=p.communicate()[0]
    finished_steps=[]
    print(start)
    while len(running)>0 or time.time()-start<120:
        time.sleep(10)
        steps=get_steps(directory)
        for st in steps:
            if st not in finished_steps:
                update_status(db,uname,paswd,tok_id,st)
        p=subprocess.Popen(['pgrep','-u',os.environ["USER"],'-f','pipeline.py'],stdout=subprocess.PIPE)
        running=p.communicate()[0]
        finished_steps=steps



def get_steps(directory='logs'):
    p_find=subprocess.Popen(['find',directory,'-name',"*.log"],stdout=subprocess.PIPE)
    grep_results=p_find.communicate()[0].split('.log\n')
    results=[]
    for line in grep_results:
        if len(line)>2:
            results.append(line.split('/')[-1])
    return results

if __name__ == '__main__':
    start=time.time()
    progress_loop(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])

