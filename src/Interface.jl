# ==================================================================================
# Interface for Base and AbstractTrees

# nextsibling,parentlinks,siblinglinks,children,StoredParents,StoredSiblings

#----------------------------------------------------------------------------------
# Implement iteration over the immediate children of a node
function Base.iterate(node::AbstractBinaryNode)
    !isnull(node.left) && return (node.left, false)
    !isnull(node.right) && return (node.right, true)
    return nothing
end
function Base.iterate(node::AbstractBinaryNode, state::Bool)
    state && return nothing
    !isnull(node.right) && return (node.right, true)
    return nothing
end
Base.IteratorSize(::Type{<: HBN})  = Base.SizeUnknown()
Base.IteratorSize(::Type{<: SBN})  = Base.SizeUnknown()

#-----------------------------------------------------------------------------------
# Implement eltype, size and length
"""
    eltype(::Type{<: AbstractTree})

The type of nodes.
"""
Base.eltype(::Type{T}) where {T <: AbstractTree{N}} where N = N
Base.eltype(::Type{N}) where {N <: AbstractNode{T}} where T = N
"""
    size(tree::AbstractTree)

`size(tree) === tree.size`
"""
Base.size(tree::AbstractTree) = tree.size

"""
    length(tree::AbstractTree)
    length(node::HeightBinaryNode)

The height of tree and node.
"""
Base.length(tree::AbstractTree) = tree.height
Base.length(node::HeightBinaryNode) = node.height

# -----------------------------------------------------------------------------------
# Things we need to define to leverage the native iterator over children
# for the purposes of AbstractTrees.

Base.eltype(::Type{<: TreeIterator{N}}) where {N <: AbstractBinaryNode{T}} where T = N
Base.IteratorEltype(::Type{<: TreeIterator{<: AbstractBinaryNode}}) = Base.HasEltype()
AbstractTrees.parentlinks(::Type{<: AbstractBinaryNode}) = AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{<: AbstractBinaryNode}) = AbstractTrees.StoredSiblings()

# Use the native iteration for the children
AbstractTrees.children(node::AbstractBinaryNode) = node

Base.parent(::AbstractBinaryNode, node::AbstractBinaryNode) = node.parent
Base.parent(root::AbstractBinaryNode, ::AbstractTrees.ImplicitRootState) = root

function AbstractTrees.nextsibling(::AbstractBinaryNode, child::AbstractBinaryNode)
    !isnull(child.parent) || return nothing
    p = child.parent
    if !isnull(p.right)
        child === p.right && return nothing
        return p.right
    end
    return nothing
end

pairs(node::AbstractBinaryNode) = enumerate(node)

# ---------------------------------------------------------------------------------
# IO
# print data in node
printnode(io::IO, node::AbstractBinaryNode) = print(io, node.data)

# Specific order generators
PostOrderDFS(tree::AbstractTree) = PostOrderDFS(tree.root)
PreOrderDFS(tree::AbstractTree) = PreOrderDFS(tree.root)


# show tree
print_tree(io::IO, tree::AbstractTree) = print_tree(io, tree.root)
Base.show(io::IO, tree::AbstractTree) = print_tree(io,tree)

Base.show(io::IO, ::MIME"text/plain", tree::BST{N}) where N = 
    print(io, "BinarySearchTree{$N}($(tree.size), $(tree.height)):", "\n", tree)

Base.show(io::IO, ::MIME"text/plain", tree::AVLTree{N}) where N = 
    print(io, "AVLTree{$N}($(tree.size), $(tree.height)):", "\n", tree)

Base.show(io::IO, ::MIME"text/plain", tree::SplayTree{N}) where N = 
    print(io, "SplayTree{$N}($(tree.size)):", "\n", tree)

# show node
Base.show(io::IO, node::HBN) = print(io, " data: $(node.data)\n", " parent: $(node.parent.data)\n",
                                            " left: $(node.left.data)\n", " right: $(node.right.data)\n",
                                            " height: $(node.height)")
Base.show(io::IO, node::SBN) = print(io, " data: $(node.data)\n", " parent: $(node.parent.data)\n",
                                            " left: $(node.left.data)\n", " right: $(node.right.data)\n")

Base.show(::IO, ::NullNode) = nothing

Base.show(io::IO, ::MIME"text/plain", node::NullNode) = print(io, "NullNode")

Base.show(io::IO, ::MIME"text/plain", node::HeightBinaryNode{T}) where T = 
    print(io, "HeightBinaryNode{$T}", "\n$node")
Base.show(io::IO, ::MIME"text/plain", node::SimpleBinaryNode{T}) where T = 
    print(io, "SimpleBinaryNode{$T}", "\n$node")

# --------------------------------------------------------------------------------------------------------------------
# Equality
function ==(node1::AbstractBinaryNode, node2::AbstractBinaryNode) 
    node1.data == node2.data && (getproperty(node1, :left) == getproperty(node2, :left)) && (getproperty(node1, :right) == getproperty(node2, :right)) 
end

==(node1::AbstractNode, node2::NullNode) = false
==(node1::NullNode, node2::AbstractNode) = false
==(node1::NullNode, node2::NullNode) = true

==(tree1::AbstractTree, tree2::AbstractTree) = 
    tree1.root == tree2.root

