class RichText
  class Node
    attr_reader :children, :attributes
    
    def initialize text = nil, **attributes
      @children   = text ? [text.to_s] : []
      @attributes = attributes
    end
    
    
    # Leaf?
    #
    # Is this node a leaf node?
    
    def leaf?
      String === @children[0]
    end
    
    
    # Add child
    #
    # A child is any object that respond to #to_s.
    
    def << *children
      if leaf?
        puts "=========== Leaf ==========="
        p @children
        @children << self.class.new(@children.pop)
        p @children
        puts "=========== End Leaf ==========="
      end
      
      children.each do |c|
        @children << ((Node === c) ? c : self.class.new(c))
      end

      @children
    end
    
    
    # Each child
    #
    # Iterate over each child recursivly. This method will yield the leaf nodes 
    # of the graph from left to right.
    
    def each_child &block
      return to_enum(__callee__) unless block_given?
      
      return if leaf?
      
      @children.each do |child|
        if child.leaf?
          yield child
        else
          child.each_child(&block)
        end
      end
    end
    
    
    def each &block
      return to_enum(__callee__) unless block_given?
      
      yield self
      each_child(&block)
    end
    
    
    # To String
    #
    # Combine the text from all the leaf nodes in the graph, from left to right. 
    
    def to_s
      @children.reduce('') {|str, child| str + child.to_s }
    end
    
    
    # Attribute accessor
    #
    # Read an attribute of the node. Attributes are simply key-value pairs 
    # stored internally in a hash.
    
    def [] attribute
      @attributes[attribute]
    end
    
    
    # Count
    #
    # Returns the child count of this node.
    
    def count
      @children.size
    end
    
    
    # Size
    #
    # Returns the size of the graph where this node is the root.
    
    def size
      @children.reduce(1) {|total, child| total + child.size }
    end
    
    
    # Optimize!
    #
    # Go through each child and merge any node that a) is not a lead node and b) 
    # only has one child with its child.
    
    def optimize!
      each_child.map do |child|
        if Leaf == child || child.count > 1
          child
        else
          # Also merge the attributes, with the child
          # attributes overriding those of the parent
          child.children.first
        end
      end
    end
    
    
    def inspect
      "#<Node %<attributes>p:%<id>#x>\n%{children}" % { 
        id: self.object_id, 
        children: @children.map{|c| 
            c.inspect.gsub(/(^)/) { $1 + '  ' }}.join("\n"),
        attributes: @attributes
      }
    end
  end
end