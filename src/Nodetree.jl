# ===================================================================================
# AbstractTypes

abstract type AbstractTree{N, T} end
abstract type AbstractNode{T} end
abstract type AbstractBinaryNode{T} <: AbstractNode{T} end

# ------------------------------------------------------------------------------------
# Nodes

"""
    NullNode()

Empty node for leaves and roots. 
"""
struct NullNode <: AbstractNode{Nothing}
    data::Nothing  

    NullNode() = new(nothing)
end

"""
    SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    SimpleBinaryNode{T}(data)
    SimpleBinaryNode(data)

Binary nodes without height information.

* `data`: stored data.
* `parent`: parent node.
* `left`: left child node.
* `right`: right child node.
"""
mutable struct SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{SimpleBinaryNode{T},NullNode}
    left::Union{SimpleBinaryNode{T},NullNode}
    right::Union{SimpleBinaryNode{T},NullNode}

    # Initial constructor
    SimpleBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode())
end

const SBN = SimpleBinaryNode
SBN(data) = SBN{typeof(data)}(data)

"""
    HeightBinaryNode{T} <: AbstractBinaryNode{T}
    HeightBinaryNode{T}(data)
    HeightBinaryNode(data)

Binary nodes without height information. 

* `height`: if node is the root of a tree, it is 0; otherwise, it is the number of nodes between the node and the farthest node (including both nodes).

For other fields, please see `SimpleBinaryNode`.
"""
mutable struct HeightBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{HeightBinaryNode{T},NullNode}
    left::Union{HeightBinaryNode{T},NullNode}
    right::Union{HeightBinaryNode{T},NullNode}
    height::Int

    # Initial constructor
    HeightBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode(), 0)
end

const HBN = HeightBinaryNode
HBN(data) = HBN{typeof(data)}(data)

"""
    RedBlackBinaryNode{T} <: AbstractBinaryNode{T}

Binary nodes for red black tree.

* `red`: true for red, false for black.

For other fields, please see `SimpleBinaryNode`.
"""
mutable struct RedBlackBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{RedBlackBinaryNode{T},NullNode}
    left::Union{RedBlackBinaryNode{T},NullNode}
    right::Union{RedBlackBinaryNode{T},NullNode}
    red::Bool # true for red, false for black

    # Initial constructor
    RedBlackBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode(), false)
end

# ------------------------------------------------------------------------------------
# Trees

"""
    BinarySearchTree{T} <: AbstractTree{T}
    BinarySearchTree{T}()
    BinarySearchTree{SBN, T}(data)
    BinarySearchTree{HBN, T}(data)
    const BST = BinarySearchTree
    BST()
    BST(data)

Binary search tree.

Nodes can be `SimpleBinaryNode` or `HeightBinaryNode`.

* `root`: the root node.
* `size`: number of nodes in this tree.
* `height`: the height of root. Only valid when using `HeightBinaryNode`.
"""
mutable struct BinarySearchTree{N,T} <: AbstractTree{N, T}
    root::Union{AbstractBinaryNode, NullNode}
    size::Int
    height::Int # Only valid when using HBN

    # Initial constructor
    BinarySearchTree{N, T}() where {T, N <: AbstractBinaryNode} = new{N, T}(NullNode(), 0, -1)
    # W/ data constructor
    BinarySearchTree{SBN, T}(data) where T = new{SBN, T}(SBN(convert(T, data)), 1, 0)
    BinarySearchTree{HBN, T}(data) where T = new{HBN, T}(HBN(convert(T, data)), 1, 0)
end

const BST = BinarySearchTree
BST(height::Bool = false) = height ? BST{HBN, Any}() : BST{SBN, Any}()
BST{T}(height::Bool = false) where T = height ? BST{HBN, T}() : BST{SBN, T}()
BST(data, height::Bool = false) = height ? BST{HBN, typeof(data)}(data) : BST{SBN, typeof(data)}(data)
BST{T}(data, height::Bool = false) where T = height ? BST{HBN, T}(data) : BST{SBN, T}(data)

"""
    AVLTree{T} <: AbstractTree{T}
    AVLTree{T}()
    AVLTree{T}(data)
    AVL()
    AVL(data)

AVL tree.

Nodes must be `HeightBinaryNode` to be able to do rotations.

* `root`: the root node.
* `size`: number of nodes in this tree.
* `height`: the height of root.
"""
mutable struct AVLTree{N, T} <: AbstractTree{N, T}
    root::Union{HBN{T}, NullNode}
    size::Int
    height::Int

    # Initial constructor
    AVLTree{HBN, T}() where T = new{HBN, T}(NullNode(), 0, -1)
    # W/ data constructor
    AVLTree{HBN, T}(data) where T = new{HBN, T}(HeightBinaryNode(convert(T, data)), 1, 0)
end

const AVL = AVLTree
AVL() = AVL{HBN, Any}()
AVL{T}() where T = AVL{HBN, T}()
AVL(data) = AVL{HBN, typeof(data)}(data)
AVL{T}(data) where T = AVL{HBN, T}(data)

"""
    SplayTree{N, T} <: AbstractTree{N, T}
    Splay()
    Splay{T}()
    Splay(data)
    Splay{T}(data)

Splay tree.

Nodes should be `SimpleBinaryNode`, though `HeightBinaryNode` is ok in theory.
    
* `root`: the root node.
* `size`: number of nodes in this tree.
"""
mutable struct SplayTree{N, T} <: AbstractTree{N, T}
    root::Union{SBN{T}, NullNode}
    size::Int

    # Initial constructor
    SplayTree{SBN, T}() where T = new{SBN, T}(NullNode(), 0)
    # W/ data constructor
    SplayTree{SBN, T}(data) where T = new{SBN, T}(SimpleBinaryNode(convert(T, data)), 1)
end

const Splay = SplayTree
Splay() = Splay{SBN, Any}()
Splay{T}() where T = Splay{SBN, T}()
Splay(data) = Splay{SBN, typeof(data)}(data)
Splay{T}(data) where T = Splay{SBN, T}(data)
# ------------------------------------------------------------------------------------------
const NSBN = Union{NullNode, SimpleBinaryNode}