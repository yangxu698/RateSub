#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 24
#$ -q long ##*@@emichaellab
#$ -N RateWatch

module load R

R CMD BATCH try12.r
