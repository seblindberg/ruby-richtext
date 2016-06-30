# Node
#
# A Node can have  children, which themselvs can have children. A tree like 
# structure can thus be formed by composing multiple Nodes. An example of such a 
# tree structure can be seen below.
#
# The Node class implements some convenience methods for iterating, left to 
# right, over either all
#  - nodes in the tree
#  - leafs in the tree
#  - direct decendant of a node
#
# In addition to having children a Node can also have attributes, represented by # simple key => value pairs.
#
#                Example Tree
#                                        +--------------------------+
#                     A <- Root Node     | Left to right order: ABC |
#                    / \                 +--------------------------+
#      Leaf Node -> B   C <- Child to A
#    (no children)     /|\
#                      ...
# 

class RichText
  class Node
    include Enumerable
    
    attr_reader :attributes
    
    def initialize **attributes
      @children   = []
      @attributes = attributes
      #@attributes[:text] = text if text
    end
    
    
    def initialize_copy original
      @children   = original.children.map(&:dup)
      @attributes = original.attributes.dup
    end
    
    
    # Leaf?
    #
    # Is this node a leaf node?
    
    def leaf?
      @children.empty?
    end
    
    
    # Children
    #
    # Protected accessor for the children array. This array should never be 
    # mutated from the outside and is only protected rather than private to be
    # accessable to ther Nodes.
    
    protected def children
      @children
    end
    
    
    # Add child
    #
    # A child is either another node or any object that respond to #to_s.
    
    def add *new_children
      new_children.each do |c|
        @children << ((Node === c) ? c : self.class.new(c))
      end

      @children
    end
    
    alias_method :<<, :add
    
    
    # Each
    #
    # Iterate over each node in the tree, including self.
    
    def each &block
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
    
    def each_leaf &block
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
    
    def each_child &block
      return to_enum(__callee__) unless block_given?
      @children.each(&block)
    end

    
    # To String
    #
    # Combine the text from all the leaf nodes in the tree, from left to right. 
    
    # def to_s &block
    #   string = leaf? ? 
    #     @attributes[:text] : 
    #     @children.reduce('') {|str, child| str + child.to_s(&block) }
    #     
    #   block_given? ? yield(self, string) : string
    # end
    
    
    # Attribute accessor
    #
    # Read and write an attribute of the node. Attributes are simply key-value 
    # pairs stored internally in a hash.
    
    def [] attribute
      @attributes[attribute]
    end
    
    def []= attribute, value
      @attributes[attribute] = value
    end
    
    
    # Count
    #
    # Returns the child count of this node.
    
    def count
      #leaf? ? 0 : @children.size
      @children.size
    end
    
    
    # Size
    #
    # Returns the size of the tree where this node is the root.
    
    def size
      #leaf? ? 1 : @children.reduce(1) {|total, child| total + child.size }
      @children.reduce(1) {|total, child| total + child.size }
    end
    
    
    # Minimal?
    #
    # Test if the tree under this node is minimal or not. A non minimal tree 
    # contains children which themselvs only have one child.
    
    def minimal?
      not any? {|node| node.count == 1 }
    end
    
    
    # Optimize!
    #
    # Go through each child and merge any node that a) is not a lead node and b) 
    # only has one child with its child.
    
    def optimize!
      # If the node is a leaf it cannot be optimized further
      return if leaf?
      
      # First optimize each of the children
      @children.map(&:optimize!)
      
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
    end
    
    
    def inspect
      children = @children.map{|c| 
          c.inspect.gsub(/(^)/) { $1 + '  ' }}.join("\n")
          
      "#<%{name} %<a>p:%<id>#x>\n%{children}" % {
          name: self.class.name, id: self.object_id, a: @attributes, children: children}
    end
  end
end