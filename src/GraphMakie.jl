module GraphMakie

using NetworkLayout
using LightGraphs
using AbstractPlotting
using LinearAlgebra

"""
    closest_point(p, positions)
Returns the index of the point in `positions` closest to `p`
"""
function closest_point(p, positions)
	return findmin([norm(p .- v) for v in positions])
end

function make_axis(f::Figure)
    ax = f[1, 1] = Axis(
        f,
        visible=false,
        xrectzoom=false,
        yrectzoom=false,
        leftspinevisible=false,
        rightspinevisible=false,
        topspinevisible=false,
        bottomspinevisible=false
    )
    hidedecorations!(ax)
    return ax
end

function plot_graph(g::AbstractGraph)

    f = Figure(resolution=(800, 800))
    ax = make_axis(f)

    # create initial vertex positions
    A = adjacency_matrix(g)
    layout = [Point2f0(p[1], p[2]) for p in NetworkLayout.Spring.layout(A)]
    layout_node = Node(layout)

    # create inital edge lines
    line_indices = vec([getfield(e, src) for src in (:src, :dst), e in edges(g)])

    # initialize for drag & drop
    mouse_left_pressed = false
    selected_vertex = 1

    # handle mouse position
    on(ax.scene.events.mouseposition) do mp
        # offset fixes https://github.com/JuliaPlots/Makie.jl/issues/457

        offset = Point(minimum(pixelarea(ax.scene)[]))
        pos = to_world(ax.scene, Point(mp) .- offset)

        if ispressed(ax.scene, Mouse.left)

            # if Mouse.left was not pressed before, select vertex
            if !mouse_left_pressed
                d, selected_vertex = closest_point(pos, layout)
                d > 0.2 && return
                mouse_left_pressed = true
            end
            # update the position of the selected vertex
            layout[selected_vertex] = pos

            layout_node[] = layout
        else
            mouse_left_pressed = false
        end

    end
    # plot edges
    linesegments!(ax, map(x-> view(x, line_indices), layout_node))
    # plot vertices
    scatter!(ax, layout_node; )
    f
end

end
