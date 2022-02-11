#!/bin/bash -l
#SBATCH --job-name=hello-serial
#SBATCH --reservation=courseq
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --export=NONE

# load modules
module load cray-python 

# launch serial python script
python3 hello-serial.py

