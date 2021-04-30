var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GraphMakie","category":"page"},{"location":"#GraphMakie","page":"Home","title":"GraphMakie","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for GraphMakie.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GraphMakie]","category":"page"},{"location":"#GraphMakie.closest_point-Tuple{Any, Any}","page":"Home","title":"GraphMakie.closest_point","text":"closest_point(p, positions)\n\nReturns the index of the point in positions closest to p\n\n\n\n\n\n","category":"method"},{"location":"#GraphMakie.graphplot!-Tuple","page":"Home","title":"GraphMakie.graphplot!","text":"graphplot(graph::AbstractGraph)\n\nCreates a plot of the network graph. Consists of multiple steps:\n\nLayout the nodes: the layout attribute is has to be a function f(adj_matrix)::pos where pos is either an array of Point2f0 or (x, y) tuples\nplot edges as linesegments-plot\nplot nodes as scatter-plot\n\nThe main attributes for the subplots are exposed as attributes for graphplot. Additional attributes for the scatter or linesegments plots can be provided as a named tuples to node_attr and edge_attr.\n\nAttributes\n\nAvailable attributes and their defaults for Combined{GraphMakie.graphplot!, T} where T are: \n\n\n\n\n\n\n\n","category":"method"},{"location":"#GraphMakie.graphplot-Tuple","page":"Home","title":"GraphMakie.graphplot","text":"graphplot(graph::AbstractGraph)\n\nCreates a plot of the network graph. Consists of multiple steps:\n\nLayout the nodes: the layout attribute is has to be a function f(adj_matrix)::pos where pos is either an array of Point2f0 or (x, y) tuples\nplot edges as linesegments-plot\nplot nodes as scatter-plot\n\nThe main attributes for the subplots are exposed as attributes for graphplot. Additional attributes for the scatter or linesegments plots can be provided as a named tuples to node_attr and edge_attr.\n\nAttributes\n\nAvailable attributes and their defaults for Combined{GraphMakie.graphplot, T} where T are: \n\n  edge_attr    Attributes with 0 entries\n  edge_color   :black\n  edge_width   1.0\n  layout       NetworkLayout.Spring.layout\n  node_attr    Attributes with 0 entries\n  node_color   :gray65\n  node_marker  Circle{T} where T\n  node_size    10\n\n\n\n\n\n","category":"method"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"EditURL = \"https://github.com/JuliaPlots/GraphMakie.jl/blob/master/docs/examples/plots.jl\"","category":"page"},{"location":"generated/plots/#Plotting-Graphs-with-GraphMakie.jl","page":"Plot Examples","title":"Plotting Graphs with GraphMakie.jl","text":"","category":"section"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"Plotting your first AbstractGraph from LightGraphs.jl is as simple as","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"using CairoMakie\nCairoMakie.activate!(type=\"png\") # hide\nAbstractPlotting.inline!(true) # hide\nusing GraphMakie\nusing LightGraphs\n\ng = wheel_graph(10)\nf, ax, p = graphplot(g)\nhidedecorations!(ax); hidespines!(ax)\nf # hide","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"The graphplot command is a recipe which wraps several steps","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"layout the graph in 2D space using a layout function,\ncreate a scatter plot for the nodes and\ncreate a linesegments plot for the edges.","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"The default layout is NetworkLayout.Spring.layout from NetworkLayout.jl. The layout attribute can be any function which takes the adjacency matrix of the graph an returns a list of (x,y) tuples or Point2f0 objects.","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"Besides that there are some common attributes which are forwarded to the underlying plot commands. See [graphplot(graph)].","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"using GraphMakie.NetworkLayout\n\ng = SimpleGraph(5)\nadd_edge!(g, 1, 2); add_edge!(g, 2, 4);\nadd_edge!(g, 4, 3); add_edge!(g, 3, 2);\nadd_edge!(g, 2, 5); add_edge!(g, 5, 4);\nadd_edge!(g, 4, 1); add_edge!(g, 1, 5);\n\n# define some edge colors\nedgecolors = [:black for i in 1:ne(g)]\nedgecolors[4] = edgecolors[7] = :red\n\nf, ax, p = graphplot(g, layout=NetworkLayout.Circular.layout,\n                     node_color=[:black, :red, :red, :red, :black],\n                     edge_color=edgecolors)\n\nhidedecorations!(ax); hidespines!(ax)\nax.aspect = DataAspect()\nf #hide","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"We can interactively change the attributes as usual with Makie.","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"fixed_layout(_) = [(0,0), (0,1), (0.5, 1.5), (1,1), (1,0)]\n# set new layout\np.layout = fixed_layout; autolimits!(ax)\n# change edge width & color\np.edge_width = 5.0\np.edge_color[][3] = :green;\np.edge_color = p.edge_color[] # trigger observable\nf #hide","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"","category":"page"},{"location":"generated/plots/","page":"Plot Examples","title":"Plot Examples","text":"This page was generated using Literate.jl.","category":"page"}]
}