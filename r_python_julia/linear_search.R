# Copyright (c) 2021 Daniel C. Moura
# https://towardsdatascience.com/r-vs-python-vs-julia-90456a2bcbab
# linkedin.com/in/dmoura
# twitter.com/daniel_c_moura

# running this file:
# R --vanilla --slave < linear_search.R


### functions under evaluation ###

# 0.93 seconds
in_search <- function(vec, x) x %in% vec

# 2.68 seconds
vec_search <- function(vec, x) any(x == vec)

# 13.33 seconds
foreach_search <- function(vec, x) {
  for (v in vec)
    if (v == x)
      return (TRUE)
  FALSE
}

# 21.94 seconds
for_search <- function(vec, x) {
  for (i in 1:length(vec))
    if (vec[i] == x)
      return (TRUE)
  FALSE
}

# takes too long
mapr_search <- function(vec, x) {
  Reduce("||", Map(function(y) y == x, vec))
}


### aux functions ###

bench <- function(label, f, vec) {
  f(vec[1:10], 0) #warmup
  cat(paste0(label, ":\n"))
  for (r in 1:3) { # three runs
    cpu.time <- sum(
      system.time(
        nmatches <- sum(sapply(1:1000, function(x) f(vec, x))),
        gcFirst = TRUE #runs garbage collector before timing
      )[1:2] # cpu time = user time + system time
    )
    cat(paste("\telapsed CPU time:", cpu.time, "seconds\n"))
    cat(paste0("\t\tmatches: ", nmatches,"\n"))
  }
  cat("\n")
}


### main ###

main <- function() {
  v = scan("vec.txt", sep='\n', what = integer(), quiet = TRUE)
  cat(paste(length(v), "records\n"))

  bench("IN",      in_search,      v)
  bench("VEC",     vec_search,     v)
  bench("FOREACH", foreach_search, v)
  bench("FOR",     for_search,     v)
  #bench("MAPR",    mapr_search,    v) # takes too long!
}

main()
