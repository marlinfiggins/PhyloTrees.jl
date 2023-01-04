using PhyloTrees
using AbstractTrees
using Test

@testset "PhyloTrees.jl" begin
    # Write your tests here.

    # Create simple tree with 3 leaves and two internal nodes
    root = Node(Internal(0.)) # Do I want to automatically wrap root?
    lbranch = addchild!(root, Internal(0.5))
    A = addchild!(lbranch, Leaf("A", 1.5))
    B = addchild!(lbranch, Leaf("B", 1.5))
    C = addchild!(root, Leaf("C", 2.0))

    # Check root has one internal child and one leaf child
    @test sum(map(x -> isleaf(x), collect(root.children))) == 1
    @test sum(map(x -> isinternal(x), collect(root.children))) == 1

    # Check that Leaves returns leaves in descendents
    @test sort!(map(x -> x.data.name, Leaves(lbranch))) == ["A", "B"]
    @test sort!(map(x -> x.data.name, Leaves(root))) == ["A", "B", "C"]

    # Check that traverse tree works
    traverse_root = traversetree(root, include_cond = k -> isleaf(k))
    @test length(traverse_root) == 3
    @test all(isleaf.(traverse_root))

    traverse_root = traversetree(root, include_cond = k -> isinternal(k))
    @test length(traverse_root) == 1 # Currently ignores root

    # Do not traverse long branches, should return only C
    traverse_root = traversetree(root, include_cond = k -> isleaf(k), traverse_cond = k -> k.data.length < 0.5)
    @test map(x -> x.data.name, traverse_root) == ["C"]

    # Test Newick
    NEWICK_TEST = "(Alpha:0.1,Beta:0.2,(Gamma:0.3,Delta:0.4):0.5);"
    tree = load_newick(NEWICK_TEST)
    println(tree.root)
    println(tree.root.children)
    @test sort!(map(x -> x.data.name, Leaves(tree.root))) == ["Alpha", "Beta","Delta",  "Gamma"]

    # Traversing newick
    traverse_newick = traversetree(tree.root, include_cond = k -> isleaf(k))
    @test length(traverse_newick) == 4

    traverse_newick = traversetree(tree.root, include_cond = k -> isinternal(k))
    @test length(traverse_newick) == 2

    # Only Gamma and Delta should have total height greater than or equal to 0.8
    traverse_newick = traversetree(tree.root, include_cond = k -> isleaf(k))
    filtered_tips = filter(x -> x.data.height >= 0.8, traverse_newick)
    @test sort!(map(x -> x.data.name, filtered_tips)) == ["Delta", "Gamma"]
end
