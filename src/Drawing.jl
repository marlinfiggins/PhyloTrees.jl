# Reset heights
# Need a function to traverse and set heights for all objects
function traversetree(cur_node::Node;
  include_cond=k -> isleaf(k),
  traverse_cond=k -> true)

  # Set the height of root to be zero
  cur_node.data.height = 0.0

  # Prepare to collect nodes of interest
  collected = Node[]

  for node in PreOrderDFS(cur_node, traverse_cond)
    # if not root 
    if isdefined(node, :parent)
      node.data.height = node.data.length + node.parent.data.height # Set parent height
      if include_cond(node)
        push!(collected, node)
      end
    end
  end

  for node in PostOrderDFS(cur_node)
    if isdefined(node, :children)
      node.data.childheight = maximum(map(x -> x.data.height, Leaves(node)))
    end
  end
  return collected
end


# This should some tree structure with X and Y values
struct PlotTree{T<:Real}
  x::Vector{T}
  y::Vector{T}
  objects::Vector{V} where {V <: Node}
  mapping::Dict{V,Int} where {V <: Node}
  PlotTree(x::Vector{T}, y::Vector{T}, objects) where {T} = new{T}(x, y, objects, Dict(x => i for (i, x) in enumerate(objects)))
end

function drawtree(cur_node, order=nothing)
  if isnothing(order)
    order = traversetree(cur_node)
  end

  name_order = Dict(x.data.name => i for (i, x) in enumerate(order))

  getwidth(x) = isleaf(x) ? 1 : 1.5
  skips = getwidth.(order)

  X = Float64[]
  Y = Float64[]
  objects = Node[]

  for tip in order
    x = tip.data.height
    y_idx = name_order[tip.data.name]
    y = sum(skips[y_idx:end]) - 0.5 * skips[y_idx]

    push!(X, x)
    push!(Y, y)
    push!(objects, tip)
  end

  # We want to draw objects for whom the y coordinates of all children are none
  # We want to visit children before their parents
  for node in PostOrderDFS(cur_node)
    if isinternal(node)
      children_idx = findall(x -> in(x, node.children), objects)
      x = node.data.height
      y = sum(Y[children_idx]) / length(children_idx)
      push!(X, x)
      push!(Y, y) # We need these to be associated with correct objects
      push!(objects, node)
    end
  end
  return X, Y, objects
end


# We need a function that will draw all of the branches
function addbranches!(ax, T::PlotTree)
  bx = []
  by = []
  for obj in T.objects
      idx = T.mapping[obj]
      p_idx = isdefined(obj, :parent) ? T.mapping[obj.parent] : idx
      x = T.x[idx]
      xp = T.x[p_idx]
      y = T.y[idx]
      
      # Baltic connections
      push!(bx, [xp,x])
      push!(by, [y,y])
      
      # Add extra bits for internal nodes
      if isinternal(obj)
          child_y = map(i -> T.y[T.mapping[i]], collect(obj.children))
          yl, yr = extrema(child_y) 
          push!(bx, [x,x])
          push!(by, [yl, yr])
      end
  end
  
  for (x,y) in zip(bx,by)
        lines!(ax, x, y, color=:black)
  end   
end
