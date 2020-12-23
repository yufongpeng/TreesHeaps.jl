using Test, TreesHeaps
@testset "Constructors" begin
    @test BST() == BST(Any)
    @test BST(0) == BST(Int, 0.0)
    @test AVL() == AVL(Any)
    @test AVL(0) == AVL(Int, 0.0)
    @test Splay() == Splay(Any)
    @test Splay(0) == Splay(Int, 0.0)
end

@testset "Interface" begin
    s1 = BST(Float64, 1.0)
    insert!(s1, 0, 2)
    insert!(s1, -1, 3)
    nodes1 = [n for n in s1.root]
    s2 = BST(Float64, 1.0, true)
    insert!(s2, 0, 2)
    insert!(s2, -1, 3)
    nodes2 = [n for n in s2.root]
    @test eltype(s1) == eltype(s1.root)
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
end

@testset "BinarySearchTree" begin
    s = BST(Float64)
    delete!(s, 1)
    @test !first(search(s, 1.0, true))
    insert!(s, 1.0)
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
    x = collect(PostOrderDFS(s))
    @test last(x) === s.root
    @test first(x) === s.root.left
    @test size(s) == 4
    @test findmax(s).data == 2.5
    @test findmin(s).data == -1
    s
end

@testset "BinarySearchTree with height" begin
    s = BST(1.0, true)
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
    s
end

@testset "AVLTree" begin
    s = AVL(Float64)
    delete!(s, 1)
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
    delete!(s, -3, 3)
    @test size(s) == 7
    @test length(s) == 2
    s
end

@testset "SplayTree" begin
    s = Splay(Float64)
    delete!(s, 1)
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
    s
end

@testset "SplayTree with topdown operations" begin
    s = Splay(Float64)
    topdowndelete!(s, 1)
    topdowninsert!(s, 1)
    insert!(s, 2, 0, 3, -1)
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
    @test size(s) == 6
    nodes = [n for n in s.root]
    @test first(nodes) == s.root.right
    s
end

