#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 2
#$ -q long ##*@@emichaellab
#$ -N CBSA

module load R

R CMD BATCH try12.r
