
# ======================================================================================================
# operations for balancing trees

# -----------------------------------------------------------------------------------------------------------------------
# nodes operations

opposite(dir::Symbol) = dir == :left ? (:right) : (:left)
opposite(dir::Nothing) = nothing ###

isnull(Node::AbstractNode) = false
isnull(Node::NullNode) = true

height(Node::AbstractNode) = 0
height(Node::HeightBinaryNode) = Node.height
height(Node::NullNode) = -1

function link!(parent::AbstractNode,child::AbstractNode,dir::Symbol)
    setfield!(parent,dir,child)
    setfield!(child,:parent,parent)
end

link!(parent::AbstractNode,child::NullNode,dir::Symbol) = setfield!(parent,dir,child)
link!(parent::NullNode,child::AbstractNode,dir::Symbol) = setfield!(child,:parent,parent)
link!(parent::NullNode,child::AbstractNode,dir::Nothing) = setfield!(child,:parent,parent)
link!(parent::NullNode,child::NullNode,dir::Symbol) = nothing

function cut!(parent::AbstractNode,child::AbstractNode,dir::Symbol)
    setfield!(parent,dir,NullNode())
    setfield!(child,:parent,NullNode())
end

cut!(parent::AbstractNode,child::NullNode,dir::Symbol) = nothing
cut!(parent::NullNode,child::AbstractNode,dir::Symbol) = nothing

getdir(parent::AbstractNode,child) = parent.left == child ? (:left) : (:right)
getdir(parent::NullNode,child::AbstractNode) = nothing
getdir(parent::NullNode,child::NullNode) = nothing

getproperty(node::NullNode,dir::Symbol) = NullNode
getproperty(node::NullNode,dir::Nothing) = NullNode

function findrightmin(node::AbstractNode)
    node = node.right
    while !isnull(node.left)
        node = node.left
    end
    return node
end

function findleftmax(node::AbstractNode)
    node = node.left
    while !isnull(node.right)
        node = node.right
    end
    return node
end

function findmin(node::AbstractNode)
    while !isnull(node.left)
        node = node.left
    end
    return node
end

function findmax(node::AbstractNode)
    while !isnull(node.right)
        node = node.right
    end
    return node
end

function findchild(grandparent::AbstractNode,dir::Symbol)
    parent = getproperty(grandparent,dir)
    child1 = getproperty(parent,dir)
    child2 = getproperty(parent,opposite(dir))
    return parent,child1,child2
end

# -------------------------------------------------------------------------------------------------
# rotations

function SingleRotation!(grandparent::AbstractNode,parent::AbstractNode,child::AbstractNode,dir1::Symbol)
    dir2 = opposite(dir1)
    sister = getproperty(parent,dir2)
    ggparent = grandparent.parent
    link!(grandparent,sister,dir1)
    link!(parent,grandparent,dir2)
    dir3 = getdir(ggparent,grandparent)
    link!(ggparent,parent,dir3)
    grandparent.height -= 1 
    return ggparent,parent,child,dir3
end

function DoubleRotation!(grandparent::AbstractNode,parent::AbstractNode,child::AbstractNode,
    dir1::Symbol,dir2::Symbol)
    ggparent = grandparent.parent
    outerchild = getproperty(child,dir1)
    innerchild = getproperty(child,dir2)
    link!(parent,outerchild,dir2)
    link!(grandparent,innerchild,dir1)
    link!(child,parent,dir1)
    link!(child,grandparent,dir2)
    dir3 = getdir(ggparent,grandparent)
    link!(ggparent,child,dir3)
    child.height += 1
    parent.height -= 1
    grandparent.height -= 1
    return ggparent,child,parent,dir3
end

function Zig!(grandparent::SimpleBinaryNode,parent::SimpleBinaryNode,dir1::Symbol)
    dir2 = opposite(dir1)
    child = getproperty(parent,dir2)
    link!(grandparent,child,dir1)
    link!(parent,grandparent,dir2)
    parent.parent = NullNode()
    return 
end


function ZigZig!(grandparent::SimpleBinaryNode,parent::SimpleBinaryNode,child::SimpleBinaryNode,
    dir1::Symbol,dir2::Symbol)
    sister = getproperty(parent,dir2)
    grandchild = getproperty(child,dir2)
    ggparent = grandparent.parent
    dir3 = getdir(ggparent,grandparent)
    link!(grandparent,sister,dir1)
    link!(parent,grandparent,dir2)
    link!(parent,grandchild,dir1)
    link!(child,parent,dir2)
    link!(ggparent,child,dir3)
    return ggparent,dir3
end

function ZigZag!(grandparent::SimpleBinaryNode,parent::SimpleBinaryNode,child::SimpleBinaryNode,
    dir1::Symbol,dir2::Symbol)
    grandchild1 = getproperty(child,dir1)
    grandchild2 = getproperty(child,dir2)
    ggparent = grandparent.parent
    dir3 = getdir(ggparent,grandparent)
    link!(parent,grandchild1,dir2)
    link!(child,parent,dir1)
    link!(grandparent,grandchild2,dir1)
    link!(child,grandparent,dir2)
    link!(ggparent,child,dir3)
    return ggparent,dir3
end 

function TopDownZig!(parent::SimpleBinaryNode,child::SimpleBinaryNode,dir::Symbol)
    cut!(parent,child,dir)
    dir == :left ? (return child,NullNode(),parent) : (return child,parent,NullNode())
end


function TopDownZigZig!(grandparent::SimpleBinaryNode,parent::SimpleBinaryNode,child::SimpleBinaryNode,
    dir1::Symbol,dir2::Symbol)
    sister = getproperty(parent,dir2)
    cut!(grandparent,parent,dir1)
    cut!(parent,child,dir1)
    link!(parent,grandparent,dir2)
    link!(grandparent,sister,dir1)
    dir1 == :left ? (return child,NullNode(),parent) : (return child,parent,NullNode())
end

function TopDownZigZag!(grandparent::SimpleBinaryNode,parent::SimpleBinaryNode,child::SimpleBinaryNode,
    dir1::Symbol,dir2::Symbol)
    cut!(grandparent,parent,dir1)
    cut!(parent,child,dir2)
    dir1 == :left ? (return child,grandparent,parent) : (return child,grandparent,parent)
end 

# -----------------------------------------------------------------------------------------------
# BinarySearchTree traverse

function traverse!(tree::BinarySearchTree,node::HeightBinaryNode,nodes...)
    value = max(-1,[child.height for child in node]...)+1
    if node.height != value && (node.height = value;true)
        return traverse!(tree,node.parent,node)
    end
    return tree
end

function traverse!(tree::BinarySearchTree,node::SimpleBinaryNode,nodes...)
    return tree
end

function traverse!(tree::BinarySearchTree,node::NullNode,nodes...)
    tree.height = nodes[1].height
    return tree
end

# --------------------------------------------------------------------------------------------------
# AVL tree traverse

## Root case
function traverse!(tree::AVLTree,grandparent::NullNode,parent::HeightBinaryNode,nodes...)
    tree.height = parent.height
    return tree
end

function AVLtraverse!(tree::AVLTree,grandparent::NullNode,parent::HeightBinaryNode,nodes...)
    tree.root = parent
    tree.height = parent.height
    return tree
end

## insert! case
function traverse!(tree::AVLTree,parent::HeightBinaryNode,child::HeightBinaryNode)
    if parent.height == 0
        parent.height = 1
        return AVLtraverse!(tree,parent.parent,parent,child,getdir(parent.parent,parent),getdir(parent,child))
    else
        return tree
    end
end 

function AVLtraverse!(tree::AVLTree,grandparent::HeightBinaryNode,parent::HeightBinaryNode,child::HeightBinaryNode,
    dir1::Symbol,dir2::Symbol)
    delta = [child.height for child in grandparent]
    append!(delta,[-1,-1])
    if abs(delta[1]-delta[2]) > 1
        # AVL property violation
        if dir1 == dir2
            grandparent,parent,child,dir3 = SingleRotation!(grandparent,parent,child,dir1)
        else
            grandparent,parent,child,dir3 = DoubleRotation!(grandparent,parent,child,dir1,dir2)
        end
        return AVLtraverse!(tree,grandparent,parent,child,dir3,dir1)
    else
        value = max(delta...)+1
        if grandparent.height != value && (grandparent.height = value;true)
            # upper node is affected
            ggparent = grandparent.parent
            return AVLtraverse!(tree,ggparent,grandparent,parent,getdir(ggparent,grandparent),dir1)
        else
            return tree
        end
    end
end

## delete! case
function traverse!(tree::AVLTree,grandparent::HeightBinaryNode)
    parent = grandparent.left
    aunt = grandparent.right
    if height(parent) > height(aunt)
        return AVLtraverse!(tree,grandparent,aunt,:left,:right)
    else
        return AVLtraverse!(tree,grandparent,parent,:right,:left)
    end
end 


function AVLtraverse!(tree::AVLTree,grandparent::HeightBinaryNode,aunt::Union{NullNode,HeightBinaryNode},
    dir1::Symbol,dir2::Symbol)
    parent,child1,child2 = findchild(grandparent,dir1)
    if abs(height(parent)-height(aunt)) > 1
        # AVL property violation
        grandparent.height -= 1
        if height(child1) > height(child2)
            grandparent,parent,child,dir3 = SingleRotation!(grandparent,parent,child1,dir1)
        elseif height(child1) < height(child2)
            grandparent,parent,child,dir3 = DoubleRotation!(grandparent,parent,child2,dir1,dir2)
        else
            grandparent,parent,child,dir3 = DoubleRotation!(grandparent,parent,child2,dir1,dir2)
            parent.height += 1
            child.height += 1
            if isnull(grandparent)
                tree.root = parent
                tree.height = parent.height
            end
            return tree
        end
        return AVLtraverse!(tree,grandparent,parent,opposite(dir3),dir3)
    else
        value = max(height(parent),height(aunt))+1
        if grandparent.height != value && (grandparent.height = value;true)
            # upper node is affected
            ggparent = grandparent.parent
            dir3 = getdir(ggparent,grandparent)
            return AVLtraverse!(tree,ggparent,grandparent,opposite(dir3),dir3)
        else
            return tree
        end
    end
end  

# ------------------------------------------------------------------------------------
# Splay tree traverse
function Splaytraverse!(tree::SplayTree,parent::SimpleBinaryNode,child::SimpleBinaryNode,dir2::Symbol)
    grandparent = parent.parent
    if isnull(grandparent)
        Zig!(parent,child,dir2)
        tree.root = child
        return tree
    else
        dir1 = getdir(grandparent,parent)
        if dir1 == dir2
            parent,dir3 = ZigZig!(grandparent,parent,child,dir1,opposite(dir1))
        else
            parent,dir3 = ZigZag!(grandparent,parent,child,dir1,dir2)
        end
        return Splaytraverse!(tree,parent,child,dir3)
    end
end

function Splaytraverse!(tree::SplayTree,parent::NullNode,child::SimpleBinaryNode,dir2::Nothing)
    tree.root = child
    return tree
end