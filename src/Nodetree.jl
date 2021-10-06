# ===================================================================================
# AbstractTypes

abstract type AbstractTree{N} end
abstract type AbstractNode{T} end
abstract type AbstractBinaryNode{T} <: AbstractNode{T} end

# ------------------------------------------------------------------------------------
# Nodes

"""
    NullNode()

Empty node for leaves and roots. 
"""
struct NullNode <: AbstractNode{Nothing} end

Base.getproperty(::NullNode, ::Symbol) = nothing
Base.getproperty(::NullNode, ::Nothing) = nothing

"""
    SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    const SBN = SimpleBinaryNode
    SBN(data)
    SBN(::Type{T}, data)

Binary nodes without height information.

* `data`: stored data.
* `parent`: parent node.
* `left`: left child node.
* `right`: right child node.
"""
mutable struct SimpleBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{SimpleBinaryNode{T}, NullNode}
    left::Union{SimpleBinaryNode{T}, NullNode}
    right::Union{SimpleBinaryNode{T}, NullNode}

    # Initial constructor
    SimpleBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode())
end

const SBN = SimpleBinaryNode

"""
    HeightBinaryNode{T} <: AbstractBinaryNode{T}
    const HBN = HeightBinaryNode
    HBN(data)
    HBN(::Type{T}, data)

Binary nodes with height information. 

* `height`: if this node is a leaf of tree, it is 0; otherwise, it is the number of nodes between this node and the deepest node (not including itself).

For other fields, please see `SimpleBinaryNode`.
"""
mutable struct HeightBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{HeightBinaryNode{T}, NullNode}
    left::Union{HeightBinaryNode{T}, NullNode}
    right::Union{HeightBinaryNode{T}, NullNode}
    height::Int

    # Initial constructor
    HeightBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode(), 0)
end

const HBN = HeightBinaryNode

"""
    RedBlackBinaryNode{T} <: AbstractBinaryNode{T}
    const RBN = RedBlackBinaryNode
    RBN(data)
    RBN(::Type{T}, data)

Binary nodes for red black tree.

* `red`: true for red, false for black.

For other fields, please see `SimpleBinaryNode`.
"""
mutable struct RedBlackBinaryNode{T} <: AbstractBinaryNode{T}
    data::T
    parent::Union{RedBlackBinaryNode{T}, NullNode}
    left::Union{RedBlackBinaryNode{T}, NullNode}
    right::Union{RedBlackBinaryNode{T}, NullNode}
    red::Bool # true for red, false for black

    # Initial constructor
    RedBlackBinaryNode{T}(data) where T = new{T}(convert(T, data), NullNode(), NullNode(), NullNode(), false)
end

const RBN = RedBlackBinaryNode

const NSBN = Union{NullNode, SimpleBinaryNode}

for Node in [:SBN, :HBN, :RBN]
    @eval begin
        $Node(data) = $Node{typeof(data)}(data)
        $Node(::Type{T}, data) where T = $Node{T}(data)
    end
end

# ------------------------------------------------------------------------------------
# Trees

"""
    BinarySearchTree <: AbstractTree

Binary search tree. Nodes can be `SimpleBinaryNode` or `HeightBinaryNode`.

# Constructors
    const BST = BinarySearchTree
    BST(height::Bool = false)
    BST(data, height::Bool = false)
    BST(::Type{T}, height::Bool = false)
    BST(::Type{T}, data, height::Bool = false)

# Fields
* `root`: the root node.
* `size`: number of nodes in this tree.
* `height`: the height of root. Only valid when using `HeightBinaryNode`.
"""
mutable struct BinarySearchTree{N <: AbstractBinaryNode} <: AbstractTree{N}
    root::Union{N, NullNode}
    size::Int
    height::Int # Only valid when using HBN

    # Initial constructor
    BinarySearchTree{N}() where N = new{N}(NullNode(), 0, -1)
    # W/ data constructor
    BinarySearchTree{N}(data) where N = new{N}(N(data), 1, 0)
end

const BST = BinarySearchTree
BST(;height::Bool = false) = BST(Any; height)
BST(::Type{T}; height::Bool = false) where T = height ? BST{HBN{T}}() : BST{SBN{T}}()
BST(data; height::Bool = false) = BST(typeof(data), data; height)
BST(::Type{T}, data; height::Bool = false) where T = height ? BST{HBN{T}}(data) : BST{SBN{T}}(data)

function BST(datas...; height::Bool = false)
    data = first(datas)
    tree = BST(data; height)
    insert!(tree, datas...)
    tree
end

function BST(::Type{T}, datas...; height::Bool = false) where T
    data = first(datas)
    tree = BST(T, data; height)
    insert!(tree, datas...)
    tree
end

"""
    AVLTree <: AbstractTree

AVL tree. Nodes must be `HeightBinaryNode` to be able to do rotations.

# Constructors
    AVLTree{T}()
    AVLTree{T}(data)
    AVL()
    AVL(data)

# Fields    
* `root`: the root node.
* `size`: number of nodes in this tree.
* `height`: the height of root.
"""
mutable struct AVLTree{N <: HBN} <: AbstractTree{N}
    root::Union{N, NullNode}
    size::Int
    height::Int

    # Initial constructor
    AVLTree{N}() where N = new{N}(NullNode(), 0, -1)
    # W/ data constructor
    AVLTree{N}(data) where N = new{N}(N(data), 1, 0)
end

const AVL = AVLTree

"""
    SplayTree <: AbstractTree

Splay tree. Nodes should be `SimpleBinaryNode`, though `HeightBinaryNode` is ok in theory.

# Constructors
    const Splay = SplayTree
    Splay()
    Splay(::Type{T})
    Splay(data)
    Splay(::Type{T}, data)

# Fields
* `root`: the root node.
* `size`: number of nodes in this tree.
"""
mutable struct SplayTree{N <: SBN} <: AbstractTree{N}
    root::Union{N, NullNode}
    size::Int

    # Initial constructor
    SplayTree{N}() where N = new{N}(NullNode(), 0)
    # W/ data constructor
    SplayTree{N}(data) where N  = new{N}(N(data), 1)
end

const Splay = SplayTree

"""
    RedBlackTree <: AbstractTree

Red black tree. Nodes should be `RedBlackBinaryNode`.

# Constructors
    const RBT = RedBlackTree
    RBT()
    RBT(::Type{T})
    RBT(data)
    RBT(::Type{T}, data)

# Fields
* `root`: the root node.
* `size`: number of nodes in this tree.
"""
mutable struct RedBlackTree{N <: RBN} <: AbstractTree{N}
    root::Union{N, NullNode}
    size::Int

    # Initial constructor
    RedBlackTree{N}() where N = new{N}(NullNode(), 0)
    # W/ data constructor
    RedBlackTree{N}(data) where N = new{N}(N(data), 1)
end

const RBT = RedBlackTree

# ------------------------------------------------------------------------------------------

canonicalnode(::Type{<: AbstractTree}) = SBN
canonicalnode(::Type{<: AVL}) = HBN
canonicalnode(::Type{<: RBT}) = RBN

for Tree in [:AVL, :Splay, :RBT]
    @eval begin
        $Tree() = $Tree{canonicalnode($Tree){Any}}()
        $Tree(::Type{T}) where T = $Tree{canonicalnode($Tree){T}}()
        $Tree(data) = $Tree{canonicalnode($Tree){typeof(data)}}(data)
        $Tree(::Type{T}, data) where T = $Tree{canonicalnode($Tree){T}}(data)

        function $Tree(datas...)
            data = first(datas)
            tree = $Tree(data)
            insert!(tree, datas...)
            tree
        end

        function $Tree(::Type{T}, datas...) where T 
            data = first(datas)
            tree = $Tree(T, data)
            insert!(tree, datas...)
            tree
        end
    end
end