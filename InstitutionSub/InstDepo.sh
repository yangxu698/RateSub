#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe long 24
#$ -q long ##*@@emichaellab
#$ -N DepositInst

module load R

R CMD BATCH DepositSubset.r
