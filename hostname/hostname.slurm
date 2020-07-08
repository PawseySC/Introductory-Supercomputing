#!/bin/bash -l
#SBATCH --job-name=hostname
#SBATCH --reservation=courseq
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --export=NONE

# print compute node host name
for i in $(seq 1 20); do
   sleep 5s
   date
   echo "The hostname is:"
   hostname
done
