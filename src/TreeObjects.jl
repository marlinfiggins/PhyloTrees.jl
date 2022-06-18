mutable struct Node{T} 
    data::T
    parent::Node
    children::Set{Node}

    # For root node
    Node{T}(data) where T = new{T}(data)

    # If given parent
    Node{T}(data, parent::Node{V}) where {T, V} = new{T}(data, parent)
end

Node(data) = Node{typeof(data)}(data)
Node(data, parent) = Node{typeof(data)}(data, parent)

function addchild!(parent::Node, node::Node)
    if !isdefined(parent, :children) 
        parent.children = Set{Node}() 
    end
    node.parent = parent
    push!(parent.children, node)
    return node
end

# Need to implement iterate
function Base.iterate(node::Node)
    isdefined(node, :children) && return iterate(node.children)
    return nothing
end

function Base.iterate(node::Node, state)
    if isdefined(node, :children)
        if !isnothing(state)
            return iterate(node.children, state+1)
        end
    end
    return nothing
end

Base.IteratorSize(::Type{Node{T}}) where T = Base.SizeUnknown()
Base.eltype(::Type{Node{T}}) where T =  Node{T}

Base.eltype(::Type{<:TreeIterator{Node{T}}}) where T = Node{T}
Base.IteratorEltype(::Type{<:TreeIterator{Node{T}}}) where T = Base.HasEltype()
AbstractTrees.parentlinks(::Type{Node{T}}) where T = AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{Node{T}}) where T = AbstractTrees.StoredSiblings()
AbstractTrees.children(node::Node) = node

Base.parent(root::Node, node::Node) = isdefined(node, :parent) ? node.parent : nothing

function AbstractTrees.nextsibling(root::Node, child::Node)
    isdefined(child, :parent) || return nothing
    p = child.parent
    keep = false # Loop through find child after given child
    for c in p.children
        keep && return c
        if c == child keep = true end
    end
end

Base.pairs(node::Node) = enumerate(node)

isleaf(node::Node{T}) where T = isleaf(T)
isinternal(node::Node{T}) where T = isinternal(T)
AbstractTrees.printnode(io::IO, node::Node) = print(io, node.data)

# Add plotting related functionality to this class
abstract type PhyloObject end

isleaf(P::T) where {T <: PhyloObject} = isleaf(T)
isinternal(P::T) where {T <: PhyloObject} = isleaf(T)

isleaf(::Type{PhyloObject}) = false
isinternal(::Type{PhyloObject}) = false

function addchild!(parent::Node, data::PhyloObject)
    addchild!(parent, Node(data, parent))
end

mutable struct Leaf <: PhyloObject
    name::N where { N <: AbstractString}
    length::T where {T <: Real}
    traits::Dict
    height::T where {T <: Real}

    Leaf(name) = new(name) 
    Leaf(name, length) = new(name, length)
    Leaf(name, length, traits) = new(name, length, traits)
end

isleaf(::Type{Leaf}) = true
isinternal(::Type{Leaf}) = false

mutable struct Internal <: PhyloObject
    length::T where {T <: Real}
    traits::Dict
    height::T where {T <: Real}
    childheight::T where {T <: Real}

    Internal(length) = new(length)
    Internal(length, traits) = new(length, traits)
end

isleaf(::Type{Internal}) = false
isinternal(::Type{Internal}) = true


Base.show(io::IO, node::Node) = Base.show(io::IO, node.data)
