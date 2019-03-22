#!/bin/csh
#$ -M yxu6@nd.edu
#$ -m abe
#$ -pe smp 12
#$ -q long ##*@@emichaellab
#$ -N CBSAnoMSA

module load R

R CMD BATCH CBSAnoMSA.r
