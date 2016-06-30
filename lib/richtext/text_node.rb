class RichText
  class TextNode < Node
    def initialize text = nil, **attributes
      super attributes
      self[:text] = text if text
    end
    
    
    # Text
    #
    # Read the text of the node. This will return nil unless the node is a leaf 
    # node.
    
    def text
      if leaf?
        self[:text] || ''
      else
        nil
      end
    end
    
    
    # Add child
    #
    # A child is either another node or any object that respond to #to_s.
    
    def add *new_children
      if leaf?
        # Remove the text entry from the node and put it in a new leaf node 
        # among the children
        t = @attributes.delete(:text)
        new_children.unshift self.class.new(t) unless t.nil? || t.empty?
      end
      
      super
    end
    
    alias_method :<<, :add
    
    
    # To String
    #
    # Combine the text from all the leaf nodes in the tree, from left to right. 
    # If a block is given the node, along with its text will be passed as 
    # arguments. The block will be called recursivly, starting at the leaf nodes
    # and propagating up until the entire tree has been "rendered" int this way.
    
    def to_s &block
      string = leaf? ? 
        text : 
        @children.reduce('') {|str, child| str + child.to_s(&block) }
        
      block_given? ? yield(self, string) : string
    end
  end
end
    