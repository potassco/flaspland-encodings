#!/bin/bash

cd "$(dirname $0)"
sbatch "start0000.dist"
sbatch "start0001.dist"
sbatch "start0002.dist"
sbatch "start0003.dist"
sbatch "start0004.dist"
sbatch "start0005.dist"
sbatch "start0006.dist"
sbatch "start0007.dist"