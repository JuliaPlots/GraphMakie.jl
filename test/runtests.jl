using CairoMakie
using GraphMakie
using GraphMakie.LightGraphs
using GraphMakie.NetworkLayout
using Test

@testset "GraphMakie.jl" begin
    g = Node(wheel_digraph(10))
    f, ax, p = graphplot(g)
    f, ax, p = graphplot(g, node_attr=Attributes(visible=false))
    f, ax, p = graphplot(g, node_attr=(;visible=false))

    a = Attributes(visible=true)
    scatter([1,2,3], [4,1,2])
    scatter!([1,2,3], [1,2,3]; visible=true, a...)

    # try to update graph
    add_edge!(g[], 2, 4)
    g[] = g[]
    # try to update network
    p.layout = NetworkLayout.SFDP.layout
    # TODO: viewport stays constant uppon changing of g and layout, is this desired?

    # update node observables
    p.nodecolor = :blue
    p.nodesize = 30
    p.marker = :rect

    # update edge observables
    p.edgewidth = 5.0
    p.edgecolor = :green

    # it should be also possible to pass multiple values
    f, ax, p = graphplot(g, nodecolor=[rand([:blue,:red,:green]) for i in 1:nv(g[])])
end
