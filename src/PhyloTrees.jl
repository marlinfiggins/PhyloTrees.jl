module PhyloTrees

  using AbstractTrees #: printnode, nextsibling, parentlinks, siblinglinks, children
  using CairoMakie
  using Base #: eltype, parent, pairs 
  #import Base: iterate, IteratorSize, IteratorEltype 

  using Dates: Day, Date, Year
  using Dates: dayofyear, daysinyear, year

  export Node
  export addchild!

  export printnode, nextsibling, parentlinks, siblinglinks, children
  export eltype, parent, pairs 
  export iterate, IteratorSize, IteratorEltype

  export Internal, Leaf
  export isleaf, isinternal

  export PlotTree
  export traversetree, drawtree, addbranches!

  export load_newick

  include("HandleDates.jl")
  include("TreeObjects.jl")
  include("Drawing.jl")
  include("ReadTrees.jl")

  #TODO: Allow generation of subtrees from traversals
  #TODO: Give all nodes names
  #TODO: Figure out how to order branches
  #TODO: Figure out if tree interface can just be wrapper for root?
  #TODO: Sort trees by ordering branches by number of descendents
  #TODO: Methods for getting node names, leaf names, counting number of each in tree
end
