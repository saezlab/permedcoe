
if(F) {
  # use this to install deps
  install.packages(c('ggplot2', 'cowplot', 'sitools', 'dplyr'))
}

library(ggplot2)
library(cowplot)
library(dplyr)

x <- read.table('data_ms.tsv', header=T)
# Note that we use the cpus columns as the number of processors used. 
# In MN4 cluster, where these simulations took place, one computation node has 
# 2 processor each with 48 cores. In these simulations, we used the 48 threads 
# in each processor

x <- x %>% mutate(nodes = cpus/2) %>% mutate(size2 = formatC(x$size, digits = 3))

#
# helpers
#

sival <- function(...) Vectorize(function(x)sitools::f2si(x, ...))

labeldf <- function(df) {
  for(x in names(df))
    df[[x]] <- paste(x, '=', df[[x]])
  df
}


# ggplot(x, aes(cpus, time, color=algorithm, shape=algorithm, group=algorithm)) +
#   geom_point() +
#   stat_smooth(geom='line', method='lm') +
#   # scale_x_log10("Nodes", labels=sival()) +
#   scale_x_log10("CPUs", labels=sival()) +
#   scale_y_log10("Wall-clock time (lower is better)", labels=sival('s')) +
#   scale_color_brewer("Software", palette='Dark2') +
#   scale_shape("Software") +
#   ggtitle("Parallelization performance") +
#   # facet_wrap(size+dataset~., scales='free', ncol=3, labeller=labeldf) +
#   facet_wrap(size+dataset~., ncol=3, labeller=labeldf) +
#   theme_cowplot(font_size=9) +
#   theme_bw()+
#   theme(
#     panel.grid.major=element_line(size=.2, color='#cccccc'),
#   )    
    
# original plots ----

#
# Scaling: how much resources do we need to solve a problem of given expected
# size? (is there an unexpected scalability problem?)
#

ggsave("plots_ms/scalability_cpu.png", units="in", width=7, height=7,
       # ggplot(x, aes(size, time*nodes/size, color=algorithm)) +
         ggplot(x, aes(size, time*cpus/size, color=algorithm)) +
         geom_point() +
         geom_smooth(method='loess', aes(fill=algorithm), alpha=.1) +
         scale_x_log10("Base problem size", labels=sival('op')) +
         scale_y_log10("Time per operation", labels=sival('Cs/op')) +
         ggtitle("Overhead of processing different problem sizes") +
         scale_color_brewer("Software", palette='Dark2') +
         scale_fill_brewer("Software", palette='Dark2') +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/scalability_node.png", units="in", width=7, height=7,
       ggplot(x, aes(size, time*nodes/size, color=algorithm)) +
         # ggplot(x, aes(size, time*cpus/size, color=algorithm)) +
         geom_point() +
         geom_smooth(method='loess', aes(fill=algorithm), alpha=.1) +
         scale_x_log10("Base problem size", labels=sival('op')) +
         scale_y_log10("Time per operation", labels=sival('Cs/op')) +
         ggtitle("Overhead of processing different problem sizes") +
         scale_color_brewer("Software", palette='Dark2') +
         scale_fill_brewer("Software", palette='Dark2') +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

#
# Speed: How much does throwing extra CPUs help to solve the problem faster?
#

ggsave("plots_ms/speed_cpu.png", units="in", width=7, height=7,
       # ggplot(x, aes(nodes/size, time/size, color=algorithm)) +
         ggplot(x, aes(cpus/size, time/size, color=algorithm)) +
         geom_point() +
         geom_smooth(method='loess', aes(fill=algorithm), alpha=.1) +
         # scale_x_log10("Base operations assigned to one node", labels=function(x)(sival('op/C')(1/x))) +
         scale_x_log10("Base operations assigned to one CPU", labels=function(x)(sival('op/C')(1/x))) +
         scale_y_log10("Time per base operation", labels=sival('s/op')) +
         ggtitle("Speedup given for invested resources") +
         scale_color_brewer("Software", palette='Dark2') +
         scale_fill_brewer("Software", palette='Dark2') +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/speed_node.png", units="in", width=7, height=7,
       ggplot(x, aes(nodes/size, time/size, color=algorithm)) +
         # ggplot(x, aes(cpus/size, time/size, color=algorithm)) +
         geom_point() +
         geom_smooth(method='loess', aes(fill=algorithm), alpha=.1) +
         scale_x_log10("Base operations assigned to one node", labels=function(x)(sival('op/C')(1/x))) +
         # scale_x_log10("Base operations assigned to one CPU", labels=function(x)(sival('op/C')(1/x))) +
         scale_y_log10("Time per base operation", labels=sival('s/op')) +
         ggtitle("Speedup given for invested resources") +
         scale_color_brewer("Software", palette='Dark2') +
         scale_fill_brewer("Software", palette='Dark2') +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

#
# Other detailed plots
#

ggsave("plots_ms/cputime_cpu.pdf", units="in", width=7, height=7,
       # ggplot(x, aes(nodes, time, color=algorithm, shape=algorithm, group=algorithm)) +
         ggplot(x, aes(cpus, time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         # scale_x_log10("Nodes", labels=sival()) +
         scale_x_log10("CPUs", labels=sival()) +
         scale_y_log10("Wall-clock time (lower is better)", labels=sival('s')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Parallelization performance") +
         # facet_wrap(size+dataset~., scales='free', ncol=3, labeller=labeldf) +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/cputime_node.pdf", units="in", width=7, height=7,
       ggplot(x, aes(nodes, time, color=algorithm, shape=algorithm, group=algorithm)) +
         # ggplot(x, aes(cpus, time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Nodes", labels=sival()) +
         # scale_x_log10("CPUs", labels=sival()) +
         scale_y_log10("Wall-clock time (lower is better)", labels=sival('s')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Parallelization performance") +
         # facet_wrap(size+dataset~., scales='free', ncol=3, labeller=labeldf) +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

ggsave("plots_ms/cpueffi_cpu.pdf", units="in", width=7, height=5,
       # ggplot(x, aes(nodes, time*nodes/size, color=algorithm, shape=algorithm, group=algorithm)) +
         ggplot(x, aes(cpus, time*cpus/size, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         # scale_x_log10("Nodes", labels=sival()) +
         # scale_y_log10("Total node time per base operation (lower is better)", labels=sival('s/op')) +
         scale_x_log10("CPUs", labels=sival()) +
         scale_y_log10("Total CPU time per base operation (lower is better)", labels=sival('s/op')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Parallelization efficiency") +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         # facet_wrap(size2+dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/cpueffi_node.pdf", units="in", width=7, height=5,
       ggplot(x, aes(nodes, time*nodes/size, color=algorithm, shape=algorithm, group=algorithm)) +
         # ggplot(x, aes(cpus, time*cpus/size, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Nodes", labels=sival()) +
         scale_y_log10("Total node time per base operation (lower is better)", labels=sival('s/op')) +
         # scale_x_log10("CPUs", labels=sival()) +
         # scale_y_log10("Total CPU time per base operation (lower is better)", labels=sival('s/op')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Parallelization efficiency") +
         # facet_wrap(size2+dataset~., ncol=4, labeller=labeldf) +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

ggsave("plots_ms/cpuspeed_cpu.pdf", units="in", width=7, height=7,
       # ggplot(x, aes(nodes, size/(nodes*time), color=algorithm, shape=algorithm, group=algorithm)) +
         ggplot(x, aes(cpus, size/(cpus*time), color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         # scale_x_log10("Nodes", labels=sival()) +
         # scale_y_log10("Base operations per total node time (higher is better)", labels=sival('/Cs')) +
         scale_x_log10("CPUs", labels=sival()) +
         scale_y_log10("Base operations per total CPU time (higher is better)", labels=sival('/Cs')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Speed by parallelization") +
         # facet_wrap(size+dataset~., scales='free', ncol=3, labeller=labeldf) +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         # facet_wrap(size2+dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/cpuspeed_node.pdf", units="in", width=7, height=7,
       ggplot(x, aes(nodes, size/(nodes*time), color=algorithm, shape=algorithm, group=algorithm)) +
         # ggplot(x, aes(cpus, size/(cpus*time), color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Nodes", labels=sival()) +
         scale_y_log10("Base operations per total node time (higher is better)", labels=sival('/Cs')) +
         # scale_x_log10("CPUs", labels=sival()) +
         # scale_y_log10("Base operations per total CPU time (higher is better)", labels=sival('/Cs')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Speed by parallelization") +
         # facet_wrap(size+dataset~., scales='free', ncol=3, labeller=labeldf) +
         facet_wrap(dataset~., ncol=3, labeller=labeldf) +
         # facet_wrap(size2+dataset~., ncol=3, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

ggsave("plots_ms/sizetime_cpu.pdf", units="in", width=7, height=7,
       ggplot(x, aes(size, time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         scale_y_log10("Wall-clock time (lower is better)", labels=sival('s')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Scaling performance") +
         # facet_grid(seed+dataset~nodes, scales='free', labeller=labeldf) +
         facet_grid(dataset~cpus, labeller=labeldf) +
         # facet_grid(seed+dataset~cpus, labeller=labeldf) +
         theme_bw()+
         theme_cowplot(font_size=9) +
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/sizetime_node.pdf", units="in", width=7, height=7,
       ggplot(x, aes(size, time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         scale_y_log10("Wall-clock time (lower is better)", labels=sival('s')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Scaling performance") +
         facet_grid(dataset~nodes, labeller=labeldf) +
         # facet_grid(seed+dataset~cpus, scales='free', labeller=labeldf) +
         theme_bw()+
         theme_cowplot(font_size=9) +
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

ggsave("plots_ms/sizeeffi_cpu.pdf", units="in", width=7, height=5,
       # ggplot(x, aes(size, time*nodes/size, color=algorithm, shape=algorithm, group=algorithm)) +
         ggplot(x, aes(size, time*cpus/size, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         # scale_y_log10("Total node time per base operation (lower is better)", labels=sival('Cs/op')) +
         scale_y_log10("Total CPU time per base operation (lower is better)", labels=sival('Cs/op')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Scaling efficiency") +
         # facet_grid(seed+dataset~nodes, labeller=labeldf) +
         facet_grid(dataset~cpus, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/sizeeffi_node.pdf", units="in", width=7, height=5,
       ggplot(x, aes(size, time*nodes/size, color=algorithm, shape=algorithm, group=algorithm)) +
         # ggplot(x, aes(size, time*cpus/size, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         scale_y_log10("Total node time per base operation (lower is better)", labels=sival('Cs/op')) +
         # scale_y_log10("Total CPU time per base operation (lower is better)", labels=sival('Cs/op')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Scaling efficiency") +
         facet_grid(dataset~nodes, labeller=labeldf) +
         # facet_grid(seed+dataset~cpus, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)

ggsave("plots_ms/sizespeed_cpu.pdf", units="in", width=7, height=7,
       # ggplot(x, aes(size, size/nodes/time, color=algorithm, shape=algorithm, group=algorithm)) +
         ggplot(x, aes(size, size/cpus/time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         # scale_y_log10("Tasks per total node time (higher is better)", labels=sival('op/Cs')) +
         scale_y_log10("Tasks per total CPU time (higher is better)", labels=sival('op/Cs')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Speed by scaling") +
         # facet_grid(seed+dataset~nodes, scales='free', labeller=labeldf) +
         facet_grid(dataset~cpus, labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
ggsave("plots_ms/sizespeed_node.pdf", units="in", width=7, height=7,
       ggplot(x, aes(size, size/nodes/time, color=algorithm, shape=algorithm, group=algorithm)) +
         # ggplot(x, aes(size, size/cpus/time, color=algorithm, shape=algorithm, group=algorithm)) +
         geom_point() +
         stat_smooth(geom='line', method='lm') +
         scale_x_log10("Problem size in basic operations", labels=sival('op')) +
         scale_y_log10("Tasks per total node time (higher is better)", labels=sival('op/Cs')) +
         # scale_y_log10("Tasks per total CPU time (higher is better)", labels=sival('op/Cs')) +
         scale_color_brewer("Software", palette='Dark2') +
         scale_shape("Software") +
         ggtitle("Speed by scaling") +
         facet_grid(dataset~nodes, labeller=labeldf) +
         # facet_grid(seed+dataset~cpus, scales='free', labeller=labeldf) +
         theme_cowplot(font_size=9) +
         theme_bw()+
         theme(
           panel.grid.major=element_line(size=.2, color='#cccccc'),
         )
)
