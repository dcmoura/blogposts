# Copyright (c) 2019 Daniel Moura
# https://towardsdatascience.com/freeing-the-data-scientist-mind-from-the-curse-of-vectorization-11634c370107?source=friends_link&sk=e7b0086f3678261cb64b6dbb43744613
# linkedin.com/in/dmoura
# twitter.com/daniel_c_moura

# running this file:
# R --vanilla --slave < distances_among_pairs.R

library(profmem)
library(Rcpp)

### functions under evaluation ###

# baseline
distances_among_pairs_dist <- function(v)
  as.vector(dist(v, method="manhattan"))

distances_among_pairs_loop <- function(v) {
  nin = length(v)
  nout = (nin * nin - nin) %/% 2 #length of the output vector
  dists = vector(mode=typeof(v), length=nout) #preallocating output vector
  k = 1 #current position in the output vector
  for (i in seq_len(nin-1)) {
    a = v[i]
    for (b in v[seq(i+1, nin)]) {
      dists[k] = abs(a-b)
      k = k + 1
    }
  }
  dists
}

distances_among_pairs_rep <- function(v) {
  row <- rep(1:length(v), each=length(v))  #e.g 1 1 1 2 2 2 3 3 3
  col <- rep(1:length(v), times=length(v)) #e.g 1 2 3 1 2 3 1 2 3
  lower_tri <- which(row > col) #e.g. (2,1) (3,1) (3,2)
  abs(v[row[lower_tri]] - v[col[lower_tri]])
}

distances_among_pairs_outer <- function(v) {
  dists <- outer(v, v, '-')
  abs(dists[lower.tri(dists)])
}

### aux functions ###

bench.cpu <- function(label, f, v) {
  gc()
  cat(paste0(label, ":\n"))
  cpu.time <- sum(system.time(f(v))[1:2])
  cat(paste("  elapsed CPU time: ", cpu.time, "seconds\n"))
}

bench.mem <- function(label, f, v) {
  gc()
  cat(paste0(label, ":\n"))
  mem.used = total(profmem(f(v))) / 1048576
  cat(paste("  allocated:", mem.used, "MiB\n"))
}

readvec <- function(run)
  scan(paste0("vec", run, ".csv"), sep='\n', what = numeric(), quiet = TRUE)


### main ###

main <- function() {
  #compile C++ function
  sourceCpp("distances_among_pairs.cpp")  
  
  cat("Warming up...\n")
  v = vector("numeric", 3)
  distances_among_pairs_dist(v)
  distances_among_pairs_loop(v)
  distances_among_pairs_rep(v)
  distances_among_pairs_outer(v)
  distances_among_pairs_cpp(v)
  
  for (r in 1:3) {
    cat(paste("\n----- RUN", r, "-----\n"))
    v = readvec(r)
    bench.cpu("DIST",   distances_among_pairs_dist,  v)
    bench.cpu("LOOP",   distances_among_pairs_loop,  v)
    bench.cpu("REP",    distances_among_pairs_rep,   v)
    bench.cpu("OUTER",  distances_among_pairs_outer, v)
    bench.cpu("CPP",    distances_among_pairs_cpp,   v)
  }
  
  cat("\n----- MEMORY -----\n")
  bench.mem("DIST",   distances_among_pairs_dist,  v)
  bench.mem("LOOP",   distances_among_pairs_loop,  v)
  bench.mem("REP",    distances_among_pairs_rep,   v)
  bench.mem("OUTER",  distances_among_pairs_outer, v)
  bench.mem("CPP",    distances_among_pairs_cpp,   v)
}

main()
