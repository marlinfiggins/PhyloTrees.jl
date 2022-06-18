# How am I going to read in trees from given file formats?

# Start with newick?
TIP_REGEX = r"(\(|,)(\'|\")*([^\(\):\[\'\"#]+)(\'|\"|)*(\[)*"
LENGTH_REGEX = r"(\:)*([0-9\.\-Ee]+)"

# Could use tree object with root and cur_node to simplify addchild!()
mutable struct Tree
    root::Node
    cur_node::Node
end 

function Tree(root)
    root_node = Node(root)
    return Tree(root_node, root_node)
end

function addchild!(tree::Tree, data)
    tree.cur_node = addchild!(tree.cur_node,  Node(data)) # Who is parent of root?
end

function load_newick(data::String, verbose=true)
    
    # Initialize tree
    tree = Tree(Internal(0.0))

    index = 1
    index_stored = nothing

    while index < length(data)
        if data[index] == '(' # Parentheses denote new internal nodes
            addchild!(tree, Internal(0.0)) # How are we gonna get heights or names?
            index += 1
        end
        # Match tips
        matched = match(TIP_REGEX, data[index-1:end])
        if !isnothing(matched) 
            # Make new leaf
            name = matched.captures[3]
            
            # Give parent and update current node
            addchild!(tree, Leaf(name))
            index += length(name)
        end

        # Match branch lengths
        matched = match(LENGTH_REGEX, data[index:end])
        if !isnothing(matched)
            tree.cur_node.data.length = parse(Float64, matched.captures[2])
            index += length(matched.match)
        end

        if data[index] == ',' || data[index] == ')' # Move up tree at splits, clade ends
            index += 1
            tree.cur_node = tree.cur_node.parent
        end

        if data[index] == ';'
            return tree
        end
    end
    return tree
end