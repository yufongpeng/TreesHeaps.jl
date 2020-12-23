# ====================================================================================
# Core Tree strucures and operations
# operations

"""
    search(tree::AbstractTree, data, internal::Bool = false)

Search if `data` in the tree
`internal = true` for internal function use.
"""
function search(tree::AbstractTree, data, internal::Bool = false)
    tree.size > 0 || (internal ? (return false, tree.root) : begin
        @info "The tree is empty!"
        return tree.root
    end)
    current = tree.root
    return treesearch(current, data, internal)
end

# Specialized function for tree
function treesearch(node::AbstractBinaryNode, data, internal::Bool = false)
    while true
        if node.data == data
            # gotcha
            internal ? (return true, node) : begin
                isdefined(node, :height) ? @info("Find $data at height $(node.height)") : @info("Find $data"); return node
            end
        elseif node.data > data
            isnull(node.left) && begin
                internal ? (return false, node) : @info("Can't Find $data"); return NullNode()
            end
            node = node.left
        else
            isnull(node.right) && begin
                internal ? (return false, node) : @info("Can't Find $data"); return NullNode()
            end
            node = node.right
        end
    end
end

"""
"""
function heapsearch() end

"""
    splay!(tree::SplayTree, data)

Bottom up splay for `data`, i.e. search and moving data node up.    
"""
function splay!(tree::SplayTree, data)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    ex, current = search(tree, data, true)
    ex ? begin
        parent = current.parent
        return Splaytraverse!(tree, parent, current, getdir(parent, current))
    end : return tree
end

"""
    split!(tree::SplayTree, data; topdown::Bool = false)

Split at `data`. For internal use; join! should be applied subsequantly. 
"""
function split!(tree::SplayTree, data)
    ex, current = search(tree, data, true)
    parent = current.parent
    isnull(parent) || Splaytraverse!(tree, parent, current, getdir(parent, current))
    split!(tree, data, ex)
end

"""
    topdownsplit!(tree::SplayTree, data)

Top-down split at `data`. For internal use; join! should be applied subsequantly.
"""
function topdownsplit!(tree::SplayTree, data)
    topdownsplay!(tree, data)
    ex = tree.root.data == data
    split!(tree, data, ex)
end

function split!(tree::SplayTree, data, ex::Bool)
    if ex
        return NullNode(), NullNode()
    else
        if data > tree.root.data
            leftnode = tree.root
            rightnode = tree.root.right
            cut!(leftnode, rightnode, :right)
        else
            leftnode = tree.root.left
            rightnode = tree.root
            cut!(rightnode, leftnode, :left)
        end
        return leftnode, rightnode
    end
end

"""
    topdownsplay!(tree::SplayTree, data)
    
Top-down splay, i.e. search and moving nodes up at the same time.
"""
function topdownsplay!(tree::T, data) where{T <: SplayTree}
    # deal with root
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    lefttree = T()
    righttree = T()
    current = tree.root
    leftnode = lefttree.root
    rightnode = righttree.root
    return topdownsplay!(tree, lefttree, righttree, current, leftnode, rightnode, data)
end

function topdownsplay!(tree::SplayTree, 
                    lefttree::SplayTree, 
                    righttree::SplayTree, 
                    centernode::SBN,
                    leftnode::NSBN, 
                    rightnode::NSBN, 
                    data)
    child = data > centernode.data ? centernode.right : centernode.left
    dir1 = getdir(centernode, child)
    if (isnull(child) | (centernode.data == data)) ||(grandchild = data > child.data ? child.right : child.left; false)
        # join
        return join!(tree, lefttree, righttree, centernode, leftnode, rightnode)
    elseif isnull(grandchild)
        # 1 level operation and join
        centernode, sendleft, sendright = TopDownZig!(centernode, child, dir1)
        leftnode, rightnode = send!(lefttree, righttree, leftnode, rightnode, sendleft, sendright)
        return join!(tree, lefttree, righttree, centernode, leftnode, rightnode)
    else
        # 2 level operation and recurse
        dir2 = getdir(child,grandchild)
        if dir1 == dir2
            centernode, sendleft, sendright = TopDownZigZig!(centernode, child, grandchild, dir1, opposite(dir1))
        else
            centernode, sendleft, sendright = TopDownZigZag!(centernode, child, grandchild, dir1, dir2)
        end
        # New operations node
        leftnode, rightnode = send!(lefttree, righttree, leftnode, rightnode, sendleft, sendright)
        return topdownsplay!(tree, lefttree, righttree, centernode, leftnode, rightnode, data)
    end
end

# Send nodes to given position and find new left/right nodes.
function send!(::SplayTree, ::SplayTree,
            leftnode::SBN,
            rightnode::SBN,
            sendleft::NSBN,
            sendright::NSBN)
    link!(leftnode, sendleft, :right)
    link!(rightnode, sendright, :left)
    return findmax(sendleft), findmin(sendright)
end

function send!(lefttree::SplayTree, ::SplayTree, ::NullNode,
            rightnode::SBN,
            sendleft::NSBN,
            sendright::NSBN)
    lefttree.root = sendleft
    link!(rightnode, sendright, :left)
    return sendleft, findmin(sendright)
end


function send!(::SplayTree, righttree::SplayTree, 
            leftnode::SBN, ::NullNode,
            sendleft::NSBN,
            sendright::NSBN)
    link!(leftnode, sendleft, :right)
    righttree.root = sendright
    return findmax(sendleft), sendright
end

function send!(lefttree::SplayTree, 
            righttree::SplayTree,
            ::NullNode, ::NullNode,
            sendleft::NSBN,
            sendright::NSBN)
    lefttree.root = sendleft
    righttree.root = sendright
    return sendleft, sendright
end

"""
    join!(tree::SplayTree, leftnode::NSBN, rightnode::NSBN, data)

Join two subtrees. Called internally after `split!`.
"""
function join!(tree::SplayTree{N}, 
            leftnode::NSBN,
            rightnode::NSBN,
            data) where N
    tree.size += 1
    tree.root = N(data)
    link!(tree.root, leftnode, :left)
    link!(tree.root, rightnode, :right)
    tree
end

# Both null
function join!(tree::SplayTree, ::NullNode, ::NullNode, data)
    @info "The data $data is already in this tree!"
    tree
end

function join!(tree::SplayTree,
            lefttree::SplayTree,
            righttree::SplayTree,
            centernode::SBN,
            leftnode::NSBN,
            rightnode::NSBN)
    isnull(lefttree.root) ? (lefttree.root = centernode.left) : link!(leftnode, centernode.left, :right)
    isnull(righttree.root) ? (righttree.root = centernode.right) : link!(rightnode, centernode.right, :left)
    tree.root = centernode
    link!(centernode, lefttree.root, :left)
    link!(centernode, righttree.root, :right)
    tree
end

"""
    insert!(tree::AbstractTree, data)
    insert!(tree::AbstractTree, datas...)
    insert!(tree::SplayTree, data)
    insert!(tree::SplayTree, datas...)

Insert `data` or multiple `datas`
"""
function insert!(tree::AbstractTree{N}, data) where {N <: HBN}
    tree.size == 0 && begin
        tree.size += 1
        tree.root = N(data)
        return traverse!(tree, tree.root.parent, tree.root)
    end
    ex, current = search(tree, data, true)
    if ex
        @info "The data $data is already in this tree!"
        return tree
    elseif current.data > data
        child = N(data)
        current.left = child
        child.parent = current
        tree.size += 1
    else
        child = N(data)
        current.right = child
        child.parent = current
        tree.size += 1
    end
    traverse!(tree, current, child)
end

function insert!(tree::AbstractTree{N}, data) where {N <: SBN}
    tree.size == 0 && begin
        tree.size += 1
        tree.root = N(data)
        return tree
    end
    ex, current = search(tree, data, true)
    if ex
        @info "The data $data is already in this tree!"
    elseif current.data > data
        child = N(data)
        current.left = child
        child.parent = current
        tree.size += 1
    else
        child = N(data)
        current.right = child
        child.parent = current
        tree.size += 1
    end
    tree
end

function insert!(tree::SplayTree{N}, data) where {N <: SBN}
    if tree.size == 0
        tree.size += 1
        tree.root = N(data)
        tree
    else
        leftnode, rightnode = split!(tree, data)
        join!(tree, leftnode, rightnode, data)
    end
end

function insert!(tree::SplayTree, datas...)
    @inbounds for data in datas
        insert!(tree, data)
    end
    tree
end

function insert!(tree::AbstractTree, datas...)
    @inbounds for data in datas
        insert!(tree, data)
    end
    tree
end

"""
    topdowninsert!(tree::SplayTree, data)
    topdowninsert!(tree::SplayTree, datas...)
    
Top-down insert `data` or multiple `datas`
"""
function topdowninsert!(tree::SplayTree{N}, data) where {N <: SBN}
    if tree.size == 0
        tree.size += 1
        tree.root = N(data)
        tree
    else
        leftnode, rightnode = topdownsplit!(tree, data)
        join!(tree, leftnode, rightnode, data)
    end
end

function topdowninsert!(tree::SplayTree, datas...)
    @inbounds for data in datas
        topdowninsert!(tree, data)
    end
    tree
end

"""
    delete!(tree::AbstractTree, data)
    delete!(tree::AbstractTree, datas...)
    delete!(tree::SplayTree, data)
    delete!(tree::SplayTree, datas...)

Delete `data` or multiple `datas`.
"""
function delete!(tree::AbstractTree, data)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    ex, current = search(tree, data, true)
    if ex
        tree.size -= 1
        # specialized for root
        if tree.root == current
            return delete_root!(tree, current)
        else
            node = treedelete!(current)
            return traverse!(tree, node)
        end
    else
        @info "The data $data is not in this tree!"
        tree
    end
end

# Specialized function for tree
function treedelete!(node::AbstractBinaryNode)
    parent = node.parent
    dir = getdir(parent, node)
    if isnull(node.right) & isnull(node.left)
        parent.left === node ? (parent.left = NullNode()) : (parent.right = NullNode())
    elseif isnull(node.right)
        link!(parent, node.left, dir)
    elseif isnull(node.left)
        link!(parent, node.right, dir)
    else
        next = findrightmin(node)
        node.data = next.data
        return treedelete!(next)
    end
    parent
end

# Deal with the root
function delete_root!(tree::AbstractTree, current::HBN)
    if isnull(current.right) & isnull(current.left)
        tree.root = NullNode()
        tree.height = -1
    elseif isnull(current.right)
        tree.root = current.left
        tree.height -= 1
    elseif isnull(current.left)
        tree.root = current.right
        tree.height -= 1
    else
        next = findrightmin(current)
        current.data = next.data
        node = treedelete!(next)
        return traverse!(tree, node)
    end
    tree
end
     
function delete!(tree::AbstractTree, datas...)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    @inbounds for data in datas
        delete!(tree, data)
    end
    tree
end

function delete!(tree::SplayTree, data)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    splay!(tree, data)
    if tree.root.data == data
        delete!(tree)
    else
        @info "The data $data is not in this tree!"
    end
    tree
end

function delete!(tree::SplayTree)
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
        isnull(parent) || Splaytraverse!(tree, parent, newroot, getdir(parent, newroot))
        link!(newroot, rightroot, :right)
    end
end

function delete!(tree::SplayTree, datas...)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    for data in datas
        delete!(tree, data)
    end
    tree
end

"""
    topdowndelete!(tree::SplayTree, data)
    topdowndelete!(tree::SplayTree, datas...)

Top-down delete `data` or multiple `datas`.
"""
function topdowndelete!(tree::SplayTree, data)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    topdownsplay!(tree, data)
    if tree.root.data == data
        delete!(tree)
    else
        @info "The data $data is not in this tree!"
    end
    tree
end

function topdowndelete!(tree::SplayTree, datas...)
    tree.size > 0 || begin
        @info "The tree is empty!"
        return tree
    end
    for data in datas
        topdowndelete!(tree, data)
    end
    tree
end

"""
    findmin(tree::AbstractTree)
    findmin(node::AbstractNode)

Find minimum value for a tree or descendants of a certain node.
"""
findmin(tree::AbstractTree) = findmin(tree.root)

function findmin(node::AbstractNode)
    while !isnull(node.left)
        node = node.left
    end
    return node
end

findmin(node::NullNode) = node

"""
    findmax(tree::AbstractTree)
    findmax(node::AbstractNode)

Find maximum value for a tree or descendants of a certain node.
"""
findmax(tree::AbstractTree) = findmax(tree.root)

function findmax(node::AbstractNode)
    while !isnull(node.right)
        node = node.right
    end
    return node
end

findmax(node::NullNode) = node

"""
    findrightmin(node::AbstractNode)

Find minimum value for right descendants of a node.
"""
function findrightmin(node::AbstractNode)
    node = node.right
    while !isnull(node.left)
        node = node.left
    end
    return node
end

"""
    findleftmax(node::AbstractNode)

Find maximum value for left descendants of a node.
"""
function findleftmax(node::AbstractNode)
    node = node.left
    while !isnull(node.right)
        node = node.right
    end
    return node
end

"""
    findchild(grandparent::AbstractNode, dir::Symbol)

Find children of the given direction and its two children.
"""
function findchild(grandparent::AbstractNode, dir::Symbol)
    parent = getproperty(grandparent, dir)
    child1 = getproperty(parent, dir)
    child2 = getproperty(parent, opposite(dir))
    return parent, child1, child2
end
