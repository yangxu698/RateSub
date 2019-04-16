#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 24
#$ -q debug ##*@@emichaellab
#$ -N DepositInst

module load R

R CMD BATCH DepositSubset.r
