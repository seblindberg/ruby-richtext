# frozen_string_literal: true

module RichText
  # Node
  #
  # A Node can have  children, which themselvs can have children. A tree like
  # structure can thus be formed by composing multiple Nodes. An example of such
  # a tree structure can be seen below.
  #
  # The Node class implements some convenience methods for iterating, left to
  # right, over either all
  #  - nodes in the tree
  #  - leafs in the tree
  #  - direct decendant of a node
  #
  # In addition to having children a Node can also have attributes, represented
  # by simple key => value pairs.
  #
  #                Example Tree
  #                                        +--------------------------+
  #                     A <- Root Node     | Left to right order: ABC |
  #                    / \                 +--------------------------+
  #      Leaf Node -> B   C <- Child to A
  #    (no children)     /|\
  #                      ...
  #
  class Node
    include Enumerable

    attr_reader :attributes, :children
    protected :children

    def initialize(**attributes)
      @children   = []
      @attributes = attributes
    end

    def initialize_copy(original)
      @children   = original.children.map(&:dup)
      @attributes = original.attributes.dup
    end

    # Leaf?
    #
    # Returns true if this node a leaf (childless) node.
    def leaf?
      @children.empty?
    end
    
    # Child
    #
    # Access the individual children of the node. If the method is called
    # without argument and the node has only one child it will be returned.
    # Otherwise an exception will be raised.
    def child n = nil
      if n
        @children[n]
      else
        raise 'Node does not have one child' unless count == 1
        @children[0]
      end
    end

    # Append
    #
    # Add a child to the end of the node child list. The child must be of this
    # class to be accepted. Note that subclasses of Node will not accept regular
    # Nodes. The method returns self so that multiple children can be added via
    # chaining:
    #   root << child_a << child_b
    def <<(child)
      unless child.is_a? self.class
        raise TypeError,
              "Only objects of class #{self.class.name} can be appended"
      end

      @children << child
      self
    end

    # Create Child
    #
    # Create and append a new child, initialized with the given attributes.
    def create_child(**attributes)
      child = self.class.new(**attributes)
      self << child
      child
    end

    # Add (+)
    #
    # Combines two nodes by creating a new root and adding the two as children.
    def +(other)
      self.class.new.tap { |root| root << self << other }
    end

    # Each
    #
    # Iterate over each node in the tree, including self.
    def each(&block)
      return to_enum(__callee__) unless block_given?

      yield self

      @children.each do |child|
        yield child
        child.each(&block) unless child.leaf?
      end
    end

    # Each Leaf
    #
    # Iterate over each leaf in the tree. This method will yield the leaf nodes
    # of the tree from left to right.
    def each_leaf(&block)
      return to_enum(__callee__) unless block_given?
      return yield self if leaf?

      @children.each do |child|
        if child.leaf?
          yield child
        else
          child.each_leaf(&block)
        end
      end
    end

    # Each child
    #
    # Iterate over the children of this node.
    def each_child(&block)
      @children.each(&block)
    end

    # Attribute accessor
    #
    # Read and write an attribute of the node. Attributes are simply key-value
    # pairs stored internally in a hash.
    def [](attribute)
      @attributes[attribute]
    end

    def []=(attribute, value)
      @attributes[attribute] = value
    end

    # Count
    #
    # Returns the child count of this node.
    def count
      @children.size
    end

    # Size
    #
    # Returns the size of the tree where this node is the root.
    def size
      @children.reduce(1) { |a, e| a + e.size }
    end

    # Minimal?
    #
    # Test if the tree under this node is minimal or not. A non minimal tree
    # contains children which themselvs only have one child.
    def minimal?
      all? { |node| node.count != 1 }
    end

    # Optimize!
    #
    # Go through each child and merge any node that a) is not a lead node and b)
    # only has one child, with its child. The attributes of the child will
    # override those of the parent.
    def optimize!
      # If the node is a leaf it cannot be optimized further
      return self if leaf?

      # First optimize each of the children. If a block was
      # given each child will be yielded to it, and children
      # for which the block returns false will be removed
      if block_given?
        @children.select! { |child| yield child.optimize! }
      else
        @children.map(&:optimize!)
      end

      # If we only have one child it is superfluous and
      # should be merged. That means this node will inherrit
      # the children of the single child as well as its
      # attributes
      if count == 1
        child = @children[0]
        # Move the children over
        @children = child.children
        @attributes.merge! child.attributes
      end

      self
    end

    def optimize
      dup.optimize!
    end

    # Shallow equality (exclude children)
    #
    # Returns true if the other node has the exact same attributes.
    def equal?(other)
      count == other.count && @attributes == other.attributes
    end

    # Deep equality (include children)
    #
    # Returns true if the other node has the same attributes and its children
    # are also identical.
    def ==(other)
      # First make sure the nodes child count matches
      return false unless equal? other

      # Lastly make sure all of the children are equal
      each_child.zip(other.each_child).all? { |c| c[0] == c[1] }
    end

    def inspect
      children = @children.reduce('') do |s, c|
        s + "\n" + c.inspect.gsub(/(^)/) { |m| m + '  ' }
      end

      format '#<%{name} %<attrs>p:%<id>#x>%{children}',
             name: self.class.name,
             id: object_id,
             attrs: @attributes,
             children: children
    end
  end
end
