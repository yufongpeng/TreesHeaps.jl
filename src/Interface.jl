
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
Base.IteratorSize(::Type{HeightBinaryNode{T}}) where T = Base.SizeUnknown()
Base.IteratorSize(::Type{SimpleBinaryNode{T}}) where T = Base.SizeUnknown()

#-----------------------------------------------------------------------------------
# Implement eltype, size and length
Base.eltype(::Type{AbstractBinaryNode{T}}) where T = AbstractBinaryNode{T}
Base.eltype(::Type{BinarySearchTree{T}}) where T = BinarySearchTree{T}
Base.size(tree::AbstractTree) = tree.size
Base.length(tree::AbstractTree) = tree.height
Base.length(node::HeightBinaryNode) = node.height

# -----------------------------------------------------------------------------------
## Things we need to define to leverage the native iterator over children
## for the purposes of AbstractTrees.
# Set the traits of this kind of tree
Base.eltype(::Type{<:TreeIterator{AbstractBinaryNode{T}}}) where T = AbstractBinaryNode{T}
Base.IteratorEltype(::Type{<:TreeIterator{AbstractBinaryNode{T}}}) where T = Base.HasEltype()
AbstractTrees.parentlinks(::Type{AbstractBinaryNode{T}}) where T = AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{AbstractBinaryNode{T}}) where T = AbstractTrees.StoredSiblings()
# Use the native iteration for the children
AbstractTrees.children(node::AbstractBinaryNode) = node

parent(root::AbstractBinaryNode, node::AbstractBinaryNode) = node.parent
parent(root::AbstractBinaryNode,state::AbstractTrees.ImplicitRootState) = root

function AbstractTrees.nextsibling(tree::AbstractBinaryNode, child::AbstractBinaryNode)
    !isnull(child.parent) || return nothing
    p = child.parent
    if !isnull(p.right)
        child === p.right && return nothing
        return p.right
    end
    return nothing
end

# ------------------------------------------------------------------------------------------------
# We also need `pairs` to return something sensible.
# If you don't like integer keys, you could do, e.g.,
#   Base.pairs(node::AbstractBinaryNode) = AbstractBinaryNodePairs(node)
# and have its iteration return, e.g., `:left=>node.left` and `:right=>node.right` when defined.
# But the following is easy:
pairs(node::AbstractBinaryNode) = enumerate(node)
print_tree(tree::AbstractTree) = print_tree(tree.root)
printnode(io::IO, node::AbstractBinaryNode) = print(io, node.data)
PostOrderDFS(tree::AbstractTree) = PostOrderDFS(tree.root)
PreOrderDFS(tree::AbstractTree) = PreOrderDFS(tree.root)
Base.show(io::IO, tree::AbstractTree) = print_tree(tree)
Base.show(io::IO, ::MIME"text/plain", tree::BinarySearchTree{N,T}) where{N,T} = 
    print(io,"BinarySearchTree{$N,$T}($(tree.size),$(tree.height)):","\n",tree)
Base.show(io::IO, ::MIME"text/plain", tree::AVLTree{N,T}) where{N,T} = 
    print(io,"AVLTree{$N,$T}($(tree.size),$(tree.height)):","\n",tree)
Base.show(io::IO, ::MIME"text/plain", tree::SplayTree{N,T}) where{N,T} = 
    print(io,"SplayTree{$N,$T}($(tree.size)):","\n",tree)
Base.show(io::IO, node::HeightBinaryNode) = print(io," data: $(node.data)\n"," parent: $(node.parent.data)\n",
                                            " left: $(node.left.data)\n"," right: $(node.right.data)\n",
                                            " height: $(node.height)")
Base.show(io::IO, node::SimpleBinaryNode) = print(io," data: $(node.data)\n"," parent: $(node.parent.data)\n",
                                            " left: $(node.left.data)\n"," right: $(node.right.data)\n")

Base.show(io::IO, node::NullNode) = nothing
Base.show(io::IO, ::MIME"text/plain", node::NullNode) = print(io,"NullNode")
Base.show(io::IO, ::MIME"text/plain", node::HeightBinaryNode{T}) where T = print(io,"HeightBinaryNode{$T}","\n$node")
Base.show(io::IO, ::MIME"text/plain", node::SimpleBinaryNode{T}) where T = print(io,"SimpleBinaryNode{$T}","\n$node")

# --------------------------------------------------------------------------------------------------------------------
# Equality
function ==(node1::AbstractNode,node2::AbstractNode) 
    node1.data == node2.data && (getproperty(node1,:left) == getproperty(node2,:left)) && (getproperty(node1,:right) == getproperty(node2,:right)) 
end
==(node1::AbstractNode,node2::NullNode) = false
==(node1::NullNode,node2::AbstractNode) = false
==(node1::NullNode,node2::NullNode) = true

function ==(tree1::T,tree2::T) where{T<:AbstractTree}
    tree1.root == tree2.root
end

==(tree1::S,tree2::T) where{S<:AbstractTree,T<:AbstractTree} = false