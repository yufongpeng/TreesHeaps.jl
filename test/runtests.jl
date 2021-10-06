using Test, TreesHeaps
import TreesHeaps: link!, cut!, getdir, opposite

test_show(x) = show(IOBuffer(), x)
test_showmime(x) = show(IOBuffer(), MIME{Symbol("text/plain")}(), x)

@testset "Constructors" begin
    @test SBN(1) == SBN(Int, 1.0)
    @test HBN(1) == HBN(Int, 1.0)
    @test RBN(1) == RBN(Int, 1.0)
    @test BST() == BST(Any)
    @test BST(0, 1) == insert!(BST(Int, 0.0), 1.0)
    @test AVL() == AVL(Any)
    @test AVL(0, 1) == insert!(AVL(Int, 0.0), 1.0)
    @test Splay() == Splay(Any)
    @test Splay(0, 1) == insert!(Splay(Int, 0.0), 1.0)
    @test RBT() == RBT(Any)
    @test RBT(0, 1) == insert!(RBT(Int, 0.0), 1.0)
end

@testset "Interface" begin
    s1 = BST(Float64, 1.0)
    insert!(s1, 0, 2)
    insert!(s1, -1, 3)
    nodes1 = [n for n in s1.root]
    s2 = BST(Float64, 1.0, height = true)
    insert!(s2, 0, 2)
    insert!(s2, -1, 3)
    nodes2 = [n for n in s2.root]
    @test eltype(s1) == eltype(s1.root)
    @test eltype(typeof(s1)) == eltype(typeof(s1.root))
    @test size(s2) == s2.size 
    @test length(s2) == length(s2.root)
    @test height(s1.root) == 0
    @test first(nodes1) == s1.root.left
    @test last(nodes2) == s2.root.right
    x = collect(PreOrderDFS(s1))
    @test first(x) === s1.root
    @test last(x) === s1.root.right.right
    y = collect(PostOrderDFS(s2))
    @test first(y) === s2.root.left.left
    @test last(y) === s2.root
    z = [i * n.data for (i, n) in pairs(s1.root)]
    @test last(z) == 4
    @test s1.root == s2.root
    @test s1.root != NullNode()
    @test NullNode() != s2.root
    @test NullNode() == NullNode()
    @test s1 == s2
    @test findmax(NullNode()) == NullNode() == findmin(NullNode())
    test_show(s1)
    test_show(s2)
    test_showmime(s1)
    test_showmime(s2)
    test_show(s1.root)
    test_show(s2.root)
    test_showmime(s1.root)
    test_showmime(s2.root)
    test_show(NullNode())
    test_showmime(NullNode())
    plot_init()
end

@testset "Node operations" begin
    @test opposite(:left) == :right
    @test isnothing(opposite(nothing))
    @test !isnull(SBN(1))
    @test isnull(NullNode())
    @test height(SBN(0)) == 0
    @test height(HBN(0)) == 0
    @test height(NullNode()) == -1
    s = SBN(1)
    link!(s, SBN(2), :left)
    @test s.left.data == 2
    cut!(s, s.left)
    @test isnothing(s.left.data)
    link!(s, NullNode(), :left)
    @test isnothing(s.left.data)
    s = SBN(2)
    link!(NullNode(), s, :left)
    @test isnothing(s.parent.data)
    @test isnothing(cut!(NullNode(), s, :left))
    @test isnothing(cut!(s, NullNode(), :left))
    link!(NullNode(), s, nothing)
    @test isnothing(s.parent.data)
    @test isnothing(getdir(NullNode(), s))
    @test isnothing(getdir(s, NullNode()))
    @test isnothing(getdir(NullNode(), NullNode()))
    @test isnothing(link!(NullNode(), NullNode(), :left))
    @test isnothing(link!(NullNode(), NullNode(), nothing))
end

@testset "BinarySearchTree" begin
    s = BST(Float64)
    search(s, 1)
    search(s, 1, true)
    delete!(s, 1)
    delete!(s, 1, 2)
    search(s, 1.0)
    @test !first(search(s, 1.0, true))
    insert!(s, 1.0)
    insert!(s, 1.0, 0, 2)
    insert!(s, -1)
    insert!(s, 2.5)
    @test first(search(s, 0, true))
    @test !first(search(s, 3, true))
    @test s.root.data == 1.0
    delete!(s, 0)
    delete!(s, -1.5)
    @test !first(search(s, 0, true))
    @test isnull(s.root.parent)
    x = collect(PostOrderDFS(s))
    @test last(x) === s.root
    @test first(x) === s.root.left
    @test size(s) == 4
    @test findmax(s).data == 2.5
    @test findmin(s).data == -1
    test_show(s)
    test_showmime(s)
end

@testset "BinarySearchTree with height" begin
    s = BST(1.0, height = true)
    insert!(s, 0, 2)
    insert!(s, -1)
    insert!(s, 2.5)
    @test first(search(s, 0, true))
    @test !first(search(s, 3, true))
    @test s.root.data == 1.0
    delete!(s, 0)
    delete!(s, -1.5)
    @test !first(search(s, 0, true))
    @test isnull(s.root.parent)
    @test size(s) == 4
    @test length(s) == 2
    delete!(s, 2, 2.5)
    delete!(s, 1)
    @test s.root.data == -1
    insert!(s, 0)
    delete!(s, -1)
    @test s.root.data == 0
    delete!(s, 0)
    @test isnull(s.root)
    test_show(s)
    test_showmime(s)
end

@testset "AVLTree" begin
    s = AVL(Float64)
    delete!(s, 1, 2)
    insert!(s, 1, 2, 0, 3)
    @test s.root.data == 1.0
    insert!(s, 1)
    insert!(s, 4)
    @test s.root.right.data == 3.0
    insert!(s, 0.5, -1, -2, 5)
    insert!(s, -3)
    @test s.root.left.left.data == -2.0
    insert!(s, 4.5)
    insert!(s, 6, 5.5, 7, 8)
    @test s.root.right.right.data == 5.5
    delete!(s, 5.5)
    @test s.root.right.right.data == 6.0
    subs = 
    delete!(s, 0.5)
    @test s.root.left.data == -1.0
    delete!(s, -1)
    @test s.root.left.right.data == 3.0
    delete!(s, 1)
    @test s.root.left.data == 2.0
    delete!(s, 4, 2)
    @test s.root.left.data == 0.0
    delete!(s, 4.5)
    @test s.root.data == 5
    insert!(s, -1)
    delete!(s, -3, 3, 0, -2, -1)
    @test size(s) == 4
    @test length(s) == 2
    test_show(s)
    test_showmime(s)
end

@testset "SplayTree" begin
    s = Splay(Float64)
    delete!(s, 1)
    delete!(s, 1, 2)
    splay!(s, 1)
    insert!(s, 1, 2, 0, 3, -1)
    @test s.root.data == -1.0
    splay!(s, 3)
    @test s.root.data == 3.0
    @test s.root.left.left.data == -1.0
    insert!(s, 10, 5, -10, -7, -2, 6, -1.5)
    splay!(s, 3)
    @test s.root.right.data == 6.0
    @test s.root.left.data == -1.5
    splay!(s, 1)
    @test s.root.right.data == 3.0
    delete!(s, 0)
    @test !first(search(s, 0.0, true))
    @test s.root.data == -1.0
    delete!(s, -1)
    @test s.root.data == -1.5
    delete!(s, -10)
    delete!(s, -10, 6, 2, 5)
    @test s.root.data == 3.0
    @test s.root.left.data == 1.0
    @test size(s) == 6
    test_show(s)
    test_showmime(s)
end

@testset "SplayTree with topdown operations" begin
    s = Splay(Float64)
    topdowndelete!(s, 1)
    topdowndelete!(s, 1, 2)
    topdownsplay!(s, 1)
    topdowninsert!(s, 1, 2)
    insert!(s, 0, 3, -1)
    topdownsplay!(s, 2)
    @test s.root.data == 2.0
    @test s.root.right.data == 3.0
    topdownsplay!(s, 3)
    @test s.root.left.data == 2.0
    @test s.root.left.left.data == 0.0
    topdowninsert!(s, 1, 0.5)
    @test s.root.left.data == 0.0
    @test s.root.right.data == 1.0
    topdowninsert!(s, 1.5)
    @test s.root.left.data == 1.0
    @test s.root.right.data == 2.0
    topdowndelete!(s, 1.2)
    @test s.root.data == 1.0
    @test s.root.right.data == 1.5
    topdowndelete!(s, 2, 0)
    @test s.root.data == -1
    @test s.root.right.data == 1.0
    topdowninsert!(s, -2.5, -3, -2, -1.5)
    topdownsplay!(s, -1)
    topdownsplay!(s, 0.5)
    @test size(s) == 10
    nodes = [n for n in s.root]
    @test first(nodes) == s.root.left
    test_show(s)
    test_showmime(s)
end

