using Test, TreesHeaps

@testset "BinarySearchTree" begin
    s = BST(1.0)
    insert!(s, 0, 2)
    insert!(s, -1)
    insert!(s, 2.5)
    @test first(search(s, 0, true))
    @test !first(search(s, 3, true))
    @test s.root.data == 1.0
    delete!(s, 0)
    @test !first(search(s, 0, true))
    @test isnull(s.root.parent)
    x = collect(PostOrderDFS(s))
    @test last(x) === s.root
    @test first(x) === s.root.left
    @test size(s) == 4
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
    @test !first(search(s, 0, true))
    @test isnull(s.root.parent)
    x = collect(PreOrderDFS(s))
    @test first(x) === s.root
    @test last(x) === s.root.right.right
    @test size(s) == 4
    @test length(s) == 2
end

@testset "AVLTree" begin
    s = AVL{Float64}()
    insert!(s, 1, 2, 0, 3)
    @test s.root.data == 1.0
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
    @test size(s) == 9
    @test length(s) == 3
end

@testset "SplayTree" begin
    s = Splay{Float64}()
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
end

@testset "SplayTree with topdown operations" begin
    s = Splay{Float64}()
    insert!(s, 1, 2, 0, 3, -1)
    topdownsplay!(s, 2)
    @test s.root.data == 2.0
    @test s.root.right.data == 3.0
    topdownsplay!(s, 3)
    @test s.root.left.data == 2.0
    @test s.root.left.left.data == 0.0
    topdowninsert!(s, 1)
    @test s.root.left.data == 0.0
    @test s.root.right.data == 2.0
    topdowninsert!(s, 1.5)
    @test s.root.left.data == 1.0
    @test s.root.right.data == 2.0
    topdowndelete!(s, 1.2)
    @test s.root.data == 1.0
    @test s.root.right.data == 1.5
    topdowndelete!(s, 2)
    @test s.root.data == 1.5
    @test s.root.right.data == 3.0
    @test size(s) == 5
end
