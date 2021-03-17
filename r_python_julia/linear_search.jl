# Copyright (c) 2021 Daniel C. Moura
# ** LINK TO ARTICLE GOES HERE **
# linkedin.com/in/dmoura
# twitter.com/daniel_c_moura

# running this file:
# julia --optimize=3 --check-bounds=no linear_search.jl

using CPUTime

### functions under evaluation ###

# 0.37 seconds
in_search(vec, x) = x in vec

# 0.32 seconds
ff_search(vec, x) = findfirst(el -> el == x, vec) != nothing

# 0.38 seconds
mapr_search(vec, x) = mapreduce(el -> el == x, |, vec)

# 1.10 seconds
vec_search(vec, x) = any(vec .== x)

gen_search(vec, x) = !isempty(nothing for v in vec if v == x)

# 0.33 seconds
function foreach_search(vec, x)
    @simd for v in vec
        if v == x
            return true
        end
    end
    false
end

# 0.32 seconds
function for_search(vec, x)
    @inbounds @simd for i in eachindex(vec)
        if vec[i] == x
            return true
        end
    end
    false
end



### aux functions ###

function bench(label, f, v)
    f(v[1:10], 0) #warmup

    println("$label:")
    for r in 1:3 # three runs
        print("\t")
        GC.gc() #cleaning the garbage before each measurement
        @CPUtime begin
            nmatches = 0
            for i = 1:1000 # one thousand searches per run
                if f(v, i)
                    nmatches += 1
                end
            end
        end
        println("\t\tmatches: $nmatches")
    end
    println()
end

# reads a vector of Ints from a text file
function readvec(filename)
    open(filename, "r") do f
        map(line -> parse(Int, line), eachline(f))
    end
end

# reads a vector of Ints from a text file, but the result is
#   a vector of Any... will hurt performance
function readvec_bad(filename)
	a = [] # this is the problem... it should be `a = Int[]`
    open(filename, "r") do f
        for line in eachline(f)
            push!(a, parse(Int, line))
        end
    end
    a
end


### main ###

function main()
    a = readvec("vec.txt")
    #a = readvec_bad("vec.txt")
    println("$(length(a)) records")

    bench("IN",         in_search,      a)
    bench("FINDFIRST",  ff_search,      a)
    bench("MAPR",       mapr_search,    a)
    bench("VEC",        vec_search,     a)
    bench("FOREACH",    foreach_search, a)
    bench("FOR",        for_search,     a)
end

main()
