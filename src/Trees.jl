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
include("Bakance.jl")
include("Interface.jl")

# Avoid importing Plots as default
plot_init() = include("$path\\Plot.jl")

const path = @__DIR__()

__init__() = precompile(plot_init,())

end # module
