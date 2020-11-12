__precompile__()

module Trees
using DataStructures, AbstractTrees
import Base:pairs, parent, insert!, delete!, fieldnames, getproperty, ==
import AbstractTrees: printnode, print_tree, PostOrderDFS, PreOrderDFS, TreeIterator

export 
    # Abstract types
    AbstractTree, AbstractNode, AbstractBinaryNode,

    # Nodes
    NullNode, SimpleBinaryNode, HeightBinaryNode, 
    
    # Trees
    BinarySearchTree, BST, AVLTree, AVL, SplayTree, Splay,

    # preoperty
    height, isnull, 
    # not imported: eltype, size and length

    # operations
    search, splay!, split!,topdownsplay!, insert!, delete!,

    # initialize plotting
    plot_init


include("Core.jl")
include("Balance.jl")
include("Interface.jl")

# Avoid importing Plots as default
const path = @__DIR__()
plot_init() = include("$path\\Plot.jl")

__init__() = precompile(plot_init,())

end # module
