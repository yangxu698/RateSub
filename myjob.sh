#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 1
#$ -q long ##*@@emichaellab 
#$ -N RateWatch

module load  R/3.5.1

R CMD BATCH try1.r 
