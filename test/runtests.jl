using CairoMakie
using GraphMakie
using GraphMakie.LightGraphs
using GraphMakie.NetworkLayout
using Makie.Colors
# using GLMakie
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
    p.layout = NetworkLayout.SFDP()

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

@testset "Hover, click and drag Interaction" begin
    g = wheel_digraph(10)
    f, ax, p = graphplot(g,
                         edge_width = [3.0 for i in 1:ne(g)],
                         edge_color = [colorant"black" for i in 1:ne(g)],
                         node_size = [20 for i in 1:nv(g)],
                         node_color = [colorant"red" for i in 1:nv(g)])
    deregister_interaction!(ax, :rectanglezoom)

    function edge_hover_action(s, idx, event, axis)
        p.edge_width[][idx]= s ? 6.0 : 3.0
        p.edge_width[] = p.edge_width[] # trigger observable
    end
    ehover = EdgeHoverHandler(edge_hover_action)
    register_interaction!(ax, :ehover, ehover)

    function node_hover_action(s, idx, event, axis)
        p.node_size[][idx] = s ? 40 : 20
        p.node_size[] = p.node_size[] # trigger observable
    end
    nhover = NodeHoverHandler(node_hover_action)
    register_interaction!(ax, :nhover, nhover)

    function node_click_action(idx, args...)
        p.node_color[][idx] = rand(RGB)
        p.node_color[] = p.node_color[]
    end
    nclick = NodeClickHandler(node_click_action)
    register_interaction!(ax, :nclick, nclick)

    function edge_click_action(idx, args...)
        p.edge_color[][idx] = rand(RGB)
        p.edge_color[] = p.edge_color[]
    end
    eclick = EdgeClickHandler(edge_click_action)
    register_interaction!(ax, :eclick, eclick)

    function node_drag_action(state, idx, event, axis)
        p[:node_positions][][idx] = event.data
        p[:node_positions][] = p[:node_positions][]
    end
    ndrag = NodeDragHandler(node_drag_action)
    register_interaction!(ax, :ndrag, ndrag)

    mutable struct EdgeDragAction
        init::Union{Nothing, Point2f0} # save click position
        src::Union{Nothing, Point2f0}  # save src vertex position
        dst::Union{Nothing, Point2f0}  # save dst vertex position
        EdgeDragAction() = new(nothing, nothing, nothing)
    end
    function (action::EdgeDragAction)(state, idx, event, axis)
        edge = collect(edges(g))[idx]
        if state == true
            if action.src===action.dst===action.init===nothing
                action.init = event.data
                action.src = p[:node_positions][][edge.src]
                action.dst = p[:node_positions][][edge.dst]
            end
            offset = event.data - action.init
            p[:node_positions][][edge.src] = action.src + offset
            p[:node_positions][][edge.dst] = action.dst + offset
            p[:node_positions][] = p[:node_positions][] # trigger change
        elseif state == false
            action.src = action.dst = action.init =  nothing
        end
    end
    edrag = EdgeDragHandler(EdgeDragAction())
    register_interaction!(ax, :edrag, edrag)
end
