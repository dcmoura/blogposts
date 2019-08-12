# Daniel C. Moura
# https://towardsdatascience.com/freeing-the-data-scientist-mind-from-the-curse-of-vectorization-11634c370107?source=friends_link&sk=e7b0086f3678261cb64b6dbb43744613
# linkedin.com/in/dmoura
# twitter.com/daniel_c_moura

# running this file:
# julia --optimize=3 --check-bounds=no distances_among_pairs.jl

using CPUTime
using LinearAlgebra

### functions under evaluation ###

function distances_among_pairs_loop(v)
    nin = length(v)
    nout = div(nin * nin - nin, 2) #length of the output vector
    dists = Vector{eltype(v)}(undef,nout) #preallocating output vector
    k = 1 #current position in the output vector
    @inbounds for i in 1:(nin-1)
        a = v[i]
        @inbounds for j in (i+1):nin
            b = v[j]
            dists[k] = abs(a-b)
            k += 1
        end
    end
    dists
end

distances_among_pairs_comp(v) =
    [abs(v[i]-v[j]) for i in eachindex(v), j in eachindex(v) if i<j]

function distances_among_pairs_outer(v)
    dists = v .- v'
    abs.(dists[tril!(trues(size(dists)), -1)])
end


### aux functions ###

function bench(label, f, v)
    GC.gc() #cleaning the garbage before each measurement
    print("$label:\n  ")
    @time @CPUtime f(v)
    println()
end

function readvec(run)
    a = Float64[]
    f = open("vec$run.csv", "r")
    for line in eachline(f)
        push!(a, parse(Float64, line))
    end
    close(f)
    a
end


### main ###

function main()
    println("Warming up...")
    v = fill(1.0, 3)
    distances_among_pairs_loop(v)
    distances_among_pairs_comp(v)
    distances_among_pairs_outer(v)

    for r in 1:3
        println("\n----- RUN $r -----")
        v = readvec(r)
        bench("LOOP",           distances_among_pairs_loop,  v)
        bench("COMPREHENSION",  distances_among_pairs_comp,  v)
        bench("OUTER",          distances_among_pairs_outer, v)
    end
end

main()
