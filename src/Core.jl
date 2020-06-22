
# ====================================================================================
# Core Tree strucures and operations

abstract type AbstractTree{N,T} end
abstract type AbstractNode{T} end
abstract type AbstractBinaryNode{T} <: AbstractNode{T} end

# ------------------------------------------------------------------------------------
# Nodes

"""
    NullNode()

Empty node for leaves and roots 

"""
struct NullNode <: AbstractNode{Nothing}
    data::Nothing  

    NullNode() = new(nothing)
end

"""
    SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    SimpleBinaryNode{T}(data)
    SimpleBinaryNode(data)

"""
mutable struct SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{SimpleBinaryNode{T},NullNode}
    left::Union{SimpleBinaryNode{T},NullNode}
    right::Union{SimpleBinaryNode{T},NullNode}

    # Initial constructor
    SimpleBinaryNode{T}(data) where T = new{T}(convert(T,data),NullNode(),NullNode(),NullNode())
end

const SBN = SimpleBinaryNode
SBN(data) = SBN{typeof(data)}(data)

"""
    HeightBinaryNode{T} <: AbstractBinaryNode{T}
    HeightBinaryNode{T}(data)
    HeightBinaryNode(data)

"""
mutable struct HeightBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{HeightBinaryNode{T},NullNode}
    left::Union{HeightBinaryNode{T},NullNode}
    right::Union{HeightBinaryNode{T},NullNode}
    height::Int

    # Initial constructor
    HeightBinaryNode{T}(data) where T = new{T}(convert(T,data),NullNode(),NullNode(),NullNode(),0)
end

const HBN = HeightBinaryNode
HBN(data) = HBN{typeof(data)}(data)

"""
    RedBlackNode
"""
mutable struct RedBlackBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{RedBlackBinaryNode{T},NullNode}
    left::Union{RedBlackBinaryNode{T},NullNode}
    right::Union{RedBlackBinaryNode{T},NullNode}
    red::Bool # true for red, false for black

    # Initial constructor
    RedBlackBinaryNode{T}(data) where T = new{T}(convert(T,data),NullNode(),NullNode(),NullNode(),false)
end

# ------------------------------------------------------------------------------------
# Trees

"""
    BinarySearchTree{T} <: AbstractTree{T}
    BinarySearchTree{T}()
    BinarySearchTree{SBN,T}(data)
    BinarySearchTree{HBN,T}(data)
    const BST = BinarySearchTree
    BST()
    BST(data)

"""
mutable struct BinarySearchTree{N,T} <: AbstractTree{N,T}
    root::Union{AbstractBinaryNode,NullNode}
    size::Int
    height::Int # Only valid when using HBN

    # Initial constructor
    BinarySearchTree{N,T}() where {T,N<:AbstractBinaryNode} = new{N,T}(NullNode(),0,-1)
    # W/ data constructor
    BinarySearchTree{SBN,T}(data) where T = new{SBN,T}(SBN(convert(T,data)),1,0)
    BinarySearchTree{HBN,T}(data) where T = new{HBN,T}(HBN(convert(T,data)),1,0)
end

const BST = BinarySearchTree
BST(height::Bool=false) = height ? BST{HBN,Any}() : BST{SBN,Any}()
BST{T}(height::Bool=false) where T = height ? BST{HBN,T}() : BST{SBN,T}()
BST(data,height::Bool=false) = height ? BST{HBN,typeof(data)}(data) : BST{SBN,typeof(data)}(data)
BST{T}(data,height::Bool=false) where T = height ? BST{HBN,T}(data) : BST{SBN,T}(data)

"""
    AVLTree{T} <: AbstractTree{T}
    AVLTree{T}()
    AVLTree{T}(data)
    AVL()
    AVL(data)
"""
mutable struct AVLTree{N,T} <: AbstractTree{N,T}
    root::Union{HBN{T},NullNode}
    size::Int
    height::Int

    # Initial constructor
    AVLTree{HBN,T}() where T = new{HBN,T}(NullNode(),0,-1)
    # W/ data constructor
    AVLTree{HBN,T}(data) where T = new{HBN,T}(HeightBinaryNode(convert(T,data)),1,0)
end

const AVL = AVLTree
AVL() = AVL{HBN,Any}()
AVL{T}() where T = AVL{HBN,T}()
AVL(data) = AVL{HBN,typeof(data)}(data)
AVL{T}(data) where T = AVL{HBN,T}(data)

"""
    SplayTree
"""
mutable struct SplayTree{N,T} <: AbstractTree{N,T}
    root::Union{SBN{T},NullNode}
    size::Int

    # Initial constructor
    SplayTree{SBN,T}() where T = new{SBN,T}(NullNode(),0)
    # W/ data constructor
    SplayTree{SBN,T}(data) where T = new{SBN,T}(SimpleBinaryNode(convert(T,data)),1)
end

const Splay = SplayTree
Splay() = Splay{SBN,Any}()
Splay{T}() where T = Splay{SBN,T}()
Splay(data) = Splay{SBN,typeof(data)}(data)
Splay{T}(data) where T = Splay{SBN,T}(data)

# ------------------------------------------------------------------------------------
# operations

"""
    search(tree::AbstractTree{N,T},data::T)
    search(node::AbstractNode{T},data::T)
"""
function search(tree::AbstractTree{T},data,internal::Bool=false) where T
    @assert tree.size > 0 "The tree is empty!"
    current = tree.root
    return search(current,data,internal)
end

function search(node::AbstractBinaryNode{T},data,internal::Bool=false) where T
    while true
        if node.data == data
            internal ? (return true,node) : (println("Find $data",isdefined(node,:height) ? " at height $(node.height)" : "");return nothing)
        elseif node.data > data
            isnull(node.left) && (internal ? (return false,node) : (println("Can't Find $data");return nothing))
            node = node.left
        else
            isnull(node.right) && (internal ? (return false,node) : (println("Can't Find $data");return nothing))
            node = node.right
        end
    end
end

"""
    splay!()

"""
function splay!(tree::SplayTree,data)
    @assert tree.size > 0 "The tree is empty!"
    ex,current = search(tree,data,true)
    if ex
        parent = current.parent
        return Splaytraverse!(tree,parent,current,getdir(parent,current))
    end 
    return tree
end

function split!(tree::SplayTree,data,topdown::Bool=false)
    if topdown
        ex,current = search(tree,data,true)
        parent = current.parent
        isnull(parent) || Splaytraverse!(tree,parent,current,getdir(parent,current))
    else
        topdownsplay!(tree,data)
        ex = tree.root.data == data
    end
    if ex
        return NullNode(),NullNode()
    else
        if data > tree.root.data
            leftnode = tree.root
            rightnode = tree.root.right
            cut!(leftnode,rightnode,:right)
        else
            leftnode = tree.root.left
            rightnode = tree.root
            cut!(rightnode,leftnode,:left)
        end
        return leftnode,rightnode
    end
end

"""
    topdownsplay!()

"""
function topdownsplay!(tree::SplayTree{SBN,T},data) where T
    @assert tree.size > 0 "The tree is empty!"
    lefttree = SplayTree{SBN,T}()
    righttree = SplayTree{SBN,T}()
    current = tree.root
    leftnode = lefttree.root
    rightnode = righttree.root
    return topdownsplay!(tree,lefttree,righttree,current,leftnode,rightnode,data)
end

function topdownsplay!(tree::SplayTree,lefttree::SplayTree,righttree::SplayTree,centernode::SimpleBinaryNode,
    leftnode::Union{NullNode,SimpleBinaryNode},rightnode::Union{NullNode,SimpleBinaryNode},data)
    child = data > centernode.data ? centernode.right : centernode.left
    dir1 = getdir(centernode,child)
    if (isnull(child) | (centernode.data == data)) ||(grandchild = data > child.data ? child.right : child.left;false)
        return join!(tree,lefttree,righttree,centernode,leftnode,rightnode)
    elseif isnull(grandchild)
        centernode,sendleft,sendright = TopDownZig!(centernode,child,dir1)
        leftnode,rightnode = send!(lefttree,righttree,leftnode,rightnode,sendleft,sendright)
        return join!(tree,lefttree,righttree,centernode,leftnode,rightnode)
    else
        dir2 = getdir(child,grandchild)
        if dir1 == dir2
            centernode,sendleft,sendright = TopDownZigZig!(centernode,child,grandchild,dir1,opposite(dir1))
        else
            centernode,sendleft,sendright = TopDownZigZag!(centernode,child,grandchild,dir1,dir2)
        end
        leftnode,rightnode = send!(lefttree,righttree,leftnode,rightnode,sendleft,sendright)
        return topdownsplay!(tree,lefttree,righttree,centernode,leftnode,rightnode,data)
    end
end

function send!(lefttree::SplayTree,righttree::SplayTree,leftnode::SimpleBinaryNode,rightnode::SimpleBinaryNode,
    sendleft::Union{NullNode,SimpleBinaryNode},sendright::Union{NullNode,SimpleBinaryNode})
    link!(leftnode,sendleft,:right)
    link!(rightnode,sendright,:left)
    return findmax(sendleft),findmin(sendright)
end

function send!(lefttree::SplayTree,righttree::SplayTree,leftnode::NullNode,rightnode::SimpleBinaryNode,
    sendleft::Union{NullNode,SimpleBinaryNode},sendright::Union{NullNode,SimpleBinaryNode})
    lefttree.root = sendleft
    link!(rightnode,sendright,:left)
    return sendleft,findmin(sendright)
end


function send!(lefttree::SplayTree,righttree::SplayTree,leftnode::SimpleBinaryNode,rightnode::NullNode,
    sendleft::Union{NullNode,SimpleBinaryNode},sendright::Union{NullNode,SimpleBinaryNode})
    link!(leftnode,sendleft,:right)
    righttree.root = sendright
    return findmax(sendleft),sendright
end

function send!(lefttree::SplayTree,righttree::SplayTree,leftnode::NullNode,rightnode::NullNode,
    sendleft::Union{NullNode,SimpleBinaryNode},sendright::Union{NullNode,SimpleBinaryNode})
    lefttree.root = sendleft
    righttree.root = sendright
    return sendleft,sendright
end

function join!(tree::SplayTree,lefttree::SplayTree,righttree::SplayTree,centernode::SimpleBinaryNode,
    leftnode::Union{NullNode,SimpleBinaryNode},rightnode::Union{NullNode,SimpleBinaryNode})
    isnull(leftnode) ? (lefttree.root = centernode.left) : link!(leftnode,centernode.left,:right)
    isnull(rightnode) ? (righttree.root = centernode.right) : link!(rightnode,centernode.right,:left)
    tree.root = centernode
    link!(centernode,lefttree.root,:left)
    link!(centernode,righttree.root,:right)
    return tree
end

"""
    insert!(tree::AbstractTree{N,T},data)
    insert!(tree::AbstractTree{N,T},datas::Array{T,1})
"""
function insert!(tree::AbstractTree{HBN,T},data) where T
    if tree.size == 0
        tree.size += 1
        tree.root = HBN{T}(data)
        return traverse!(tree,tree.root.parent,tree.root)
    else
        ex,current = search(tree,data,true)
        if ex
            println("The data $data is already in this tree!")
            return tree
        elseif current.data > data
            child = HBN{T}(data)
            current.left = child
            child.parent = current
            tree.size += 1
        else
            child = HBN{T}(data)
            current.right = child
            child.parent = current
            tree.size += 1
        end
        return traverse!(tree,current,child)
    end
end

function insert!(tree::AbstractTree{SBN,T},data) where T
    if tree.size == 0
        tree.size += 1
        tree.root = SBN{T}(data)
        return tree
    else
        ex,current = search(tree,data,true)
        if ex
            println("The data $data is already in this tree!")
            return tree
        elseif current.data > data
            child = SBN{T}(data)
            current.left = child
            child.parent = current
            tree.size += 1
        else
            child = SBN{T}(data)
            current.right = child
            child.parent = current
            tree.size += 1
        end
        return tree
    end
end

function insert!(tree::SplayTree{SBN,T},data,topdown::Bool=false) where T
    if tree.size == 0
        tree.size += 1
        tree.root = SBN{T}(data)
    else
        leftnode,rightnode = split!(tree,data,topdown)
        if leftnode == rightnode == NullNode()
            println("The data $data is already in this tree!")
        else
            tree.size += 1
            tree.root = SBN{T}(data)
            link!(tree.root,leftnode,:left)
            link!(tree.root,rightnode,:right)
        end
    end
    return tree
end

function insert!(tree::AbstractTree,datas...)
    for data in datas
        insert!(tree,data)
    end
    tree
end


"""
    delete!(tree::AbstractTree,data::T)
    delete!(node::AbstractNode{T},data::T)
    delete!(tree::AbstractTree,datas::Array{T,1})
"""
function delete!(tree::AbstractTree,data)
    @assert tree.size > 0 "Can't delete nodes of an empty tree"
    ex,current = search(tree,data,true)
    if ex
        tree.size -= 1
        if tree.root == current
            return delete_root!(tree,current)
        else
            node = delete!(current)
            return traverse!(tree,node)
        end
    else
        println("The data $data is not in this tree!")
    end
end

function delete!(node::AbstractBinaryNode)
    parent = node.parent
    dir = getdir(parent,node)
    if isnull(node.right) & isnull(node.left)
        parent.left === node ? (parent.left = NullNode()) : (parent.right = NullNode())
        return parent
    elseif isnull(node.right)
        link!(parent,node.left,dir)
        return parent
    elseif isnull(node.left)
        link!(parent,node.right,dir)
        return parent
    else
        next = findrightmin(node)
        node.data = next.data
        return delete!(next)
    end
end

function delete_root!(tree::AbstractTree,current::HeightBinaryNode)
    if isnull(current.right) & isnull(current.left)
        tree.root = NullNode()
        tree.height = -1
        tree
    elseif isnull(current.right)
        tree.root = current.left
        tree.height -= 1
        return tree
    elseif isnull(current.left)
        tree.root = current.right
        tree.height -= 1
        return tree
    else
        next = findrightmin(current)
        current.data = next.data
        node = delete!(next)
        return traverse!(tree,node)
    end
end

function delete!(tree::SplayTree,data,topdown::Bool=false)
    topdown ? topdownsplay!(tree,data) : splay!(tree,data)
    if tree.root.data == data
        tree.size -= 1
        rightroot = tree.root.right
        if isnull(tree.root.left)
            tree.root = rightroot
            rightroot.parent = NullNode()
        else
            newroot = findleftmax(tree.root)
            tree.root = tree.root.left
            tree.root.parent = NullNode()
            parent = newroot.parent
            isnull(parent) || Splaytraverse!(tree,parent,newroot,getdir(parent,newroot))
            link!(newroot,rightroot,:right)
        end
    else
        println("The data $data is not in this tree!")
    end
    return tree
end
        
        

function delete!(tree::AbstractTree,datas...)
    for data in datas
        delete!(tree,data)
    end
    tree
end

"""
    findmin(tree::AbstractTree)

"""
findmin(tree::AbstractTree) = findmin(tree.root)

"""
    findmax(tree::AbstractTree)

"""
findmax(tree::AbstractTree) = findmax(tree.node)


# --------------------------------------------------------------------------------
# test code
"""
function test()
    s = BST()
    insert!(s,1)
    insert!(s,0,2)
    insert!(s,-1)
    insert!(s,2.5)
    search(s,0)
    search(s,3)
    delete!(s,0)
    let x = []
        for node in PostOrderDFS(s)
            push!(x,node.data)
        end
        x
    end
end

test()

s = BST(true)
insert!(s,1)
insert!(s,0,2)
insert!(s,-1)
insert!(s,2.5)
search(s,0)
search(s,3)
delete!(s,0)

s = AVL{Float64}()
insert!(s,1,2,0,3)
insert!(s,4)
insert!(s,0.5,-1,-2,5)
insert!(s,-3)
insert!(s,4.5)
delete!(s,0.5)
delete!(s,0)
delete!(s,5)
delete!(s,2)
delete!(s,1)
delete!(s,0.5,0,-3)


s = AVL()
insert!(s,1,2,0,3)
insert!(s,4)
insert!(s,0.5,-1,-2,5)
insert!(s,-3)
insert!(s,4.5)
insert!(s,6,5.5,7,8)
delete!(s,5.5)
delete!(s,0.5)
delete!(s,-1)
delete!(s,1)
delete!(s,4)
delete!(s,2)
delete!(s,3)
delete!(s,-2)
delete!(s,0)
delete!(s,6)

s = Splay()
insert!(s,1)
insert!(s,2)
insert!(s,0)
insert!(s,3)
insert!(s,-1)
splay!(s,3)
insert!(s,10,5,-10,-7,-2,6,-1.5)
splay!(s,3)
splay!(s,1)
delete!(s,0)
delete!(s,-1)
delete!(s,-10)
delete!(s,-10,6,2,5)

s = Splay()
insert!(s,1)
insert!(s,2)
insert!(s,0)
insert!(s,3)
insert!(s,-1)
topdownsplay!(s,3)
insert!(s,1,true)
insert!(s,1.5,true)
delete!(s,1.2,true)
delete!(s,2,true)

#### TODO: 2-4 tree, Red-black tree, 2-3 tree, AA tree
"""
