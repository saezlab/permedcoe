library(readr)
library(CARNIVAL)

sif <- readr::read_tsv('https://raw.githubusercontent.com/saezlab/CellNOptR/gh-pages/public/PKN-LiverDREAM.sif.txt', col_names=F)
measurements <- c(1, 1)
names(measurements) <- c('prak', 'erk12')

inputs <- c(1, 1, 1)
names(inputs) <- c('igfr','egfr','ras')

result_actual = runCARNIVAL(inputObj = inputs, 
                            measObj = measurements, 
                            netObj = sif,
                            solver = "lpSolve",
                            timelimit = 60,
                            dir_name = "./test_model1",
                            threads = 1,
                            betaWeight = 0.1)

result_actual