#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 4
#$ -q debug ##*@@emichaellab
#$ -N MSA

module load R

R CMD BATCH MSABranchSelect.r
