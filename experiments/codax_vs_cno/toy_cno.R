library(CNORode)
library(MEIGOR)

rawmodel=readSIF('C:/Users/pablo/Documents/work/codax/codax/nn_cno/datasets/wcs_benchmark/PKN-test.sif');
cno_data=readMIDAS('C:/Users/pablo/Documents/work/codax/codax/nn_cno/datasets/wcs_benchmark/MD-test.csv');
cnolist=makeCNOlist(cno_data,subfield=FALSE);
model=preprocessing(data=cnolist,rawmodel,cutNONC=T,compression=T,expansion=F)
plotModel(CNOlist=cnolist, model)

ode_parameters=createLBodeContPars(model, LB_n = 1, LB_k = 0.1,
                                   LB_tau = 0.01, UB_n = 5, UB_k = 0.9, UB_tau = 10, default_n = 3,
                                   default_k = 0.5, default_tau = 1, opt_n = TRUE, opt_k = TRUE,
                                   opt_tau = TRUE, random = FALSE)

modelSim=plotLBodeModelSim(cnolist = cnolist, model, ode_parameters,
                           timeSignals=seq(0,2,0.5));


initial_pars=createLBodeContPars(model, LB_n = 1, LB_k = 0.1,
                                 LB_tau = 0.01, UB_n = 5, UB_k = 0.9, UB_tau = 10, random = TRUE)
simulatedData=plotLBodeFitness(cnolist, model,initial_pars)



paramsGA = defaultParametersGA()
paramsGA$maxStepSize = 1
paramsGA$popSize = 100
paramsGA$iter = 1000
paramsGA$transfer_function = 3
opt_pars=parEstimationLBode(cnolist,model,ode_parameters=initial_pars,
                            paramsGA=paramsGA)
#Visualize fitted solution
simulatedData=plotLBodeFitness(cnolist, model,ode_parameters=opt_pars)





requireNamespace("MEIGOR")
initial_pars=createLBodeContPars(model,
                                 LB_n = 1, LB_k = 0.1, LB_tau = 0.01, UB_n = 5,
                                 UB_k = 0.9, UB_tau = 10, random = TRUE)
#Visualize initial solution


tf <- 3
fit_result_ess =
  parEstimationLBodeSSm(cnolist = cnolist,
                        model = model,
                        ode_parameters = initial_pars,
                        maxeval = 1e5,
                        maxtime = 300,
                        local_solver = "DHC",
                        transfer_function = tf
  )
#Visualize fitted solution
simulatedData=plotLBodeFitness(cnolist, model,ode_parameters=fit_result_ess,transfer_function=tf)