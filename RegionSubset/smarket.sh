#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 8
#$ -q long ##*@@emichaellab
#$ -N SmallMarket

module load R

R CMD BATCH SmlMarket.r
