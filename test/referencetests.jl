using Graphs
using CairoMakie
using GraphMakie
using ReferenceTests
using Literate
using FileIO

const ASSETS = joinpath(@__DIR__, "..", "assets")
const EXAMPLE_BASEPATH = joinpath(@__DIR__, "..", "docs", "examples")

const TMPDIR = joinpath(ASSETS, "tmp")
isdir(TMPDIR) && rm(TMPDIR; recursive=true)
mkdir(TMPDIR)

const IMAGE_COUNTERS = Dict{String, Int}()

macro save_reference(fig)
    f = splitpath(string(__source__.file))[end]
    postfix = if haskey(IMAGE_COUNTERS, f)
        IMAGE_COUNTERS[f] += 1
    else
        IMAGE_COUNTERS[f] = 1
    end
    quote
        path = joinpath(TMPDIR, $f*"-"*lpad($postfix, 2, "0")*".png")
        save(path, $(esc(fig)))
        println("   saved fig $path")
    end
end

@info "Generate reference images..."
for exfile in filter(contains(r".jl$"), readdir(EXAMPLE_BASEPATH))
    expath = joinpath(EXAMPLE_BASEPATH, exfile)

    hasassets = false
    for l in eachline(expath)
        if contains(l, r"@save_reference")
            hasassets = true
            break
        end
    end

    if !hasassets
        @info "$exfile has no reference images!"
        continue
    end

    Literate.script(expath, TMPDIR)
    script = joinpath(TMPDIR, exfile)
    include(script)
    rm(script)
end

oldassets = filter(contains(r".png$"), readdir(ASSETS))
newassets = filter(contains(r".png$"), readdir(TMPDIR))

@testset "Reference Tests" begin
    for ass in oldassets
        # skip unresolved conflicts
        occursin(r"\+.png$", ass) && continue

        old = joinpath(ASSETS, ass)
        new = joinpath(TMPDIR, ass)

        if !isfile(new)
            @warn "New version for $ass missing! Delete file if not needed anymore."
            @test false
            continue
        end

        equal = ReferenceTests.psnr_equality()(load(old), load(new))
        if equal
            printstyled(" ✓ $ass\n"; color=:green)
            @test true
            rm(new)
        else
            printstyled(" 𐄂 $ass\n"; color=:red)
            @test false
            parts = rsplit(ass, "."; limit=2)
            @assert length(parts) == 2
            newname = parts[1] * "+." *parts[2]
            mv(new, joinpath(ASSETS, newname), force=true)
            @warn "There is a difference in $(ass)! New version moved to $newname. Resolve manually!"
        end
    end

    for new in setdiff(newassets, oldassets)
        printstyled(" 𐄂 Move new asset $(new)!\n"; color=:red)
        @test false
        mv(joinpath(TMPDIR, new), joinpath(ASSETS, new))
    end

    rm(TMPDIR)
end
