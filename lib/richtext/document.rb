module RichText
  class Document
    # Initialize
    #
    # Create a new RichText object, either from a string or from an existing 
    # object. That feature is particularly useful when converting between 
    # formats.
    #
    # When given a string or a RichText object of the same class no parsing is 
    # performed. Only when given a RichText object of a different class will 
    # that object need to be parsed. Note that it allready may be. See #base for 
    # more details.
    
    def initialize arg = ''
      @base, @raw = if self.class == arg.class
        arg.parsed? ?
          [arg.base, nil] :
          [nil, arg.raw]
      elsif Document === arg
        # For any other RichText object we take the base node
        [arg.base, nil]
      elsif Entry === arg
        # Also accept TextNodes
        [arg, nil]
      else
        [nil, arg.to_s]
      end
    end
    
    
    # To String
    #
    # Use the formats implementation of #generate to convert the RichText object 
    # back into a string. If no base node exist yet the original input is 
    # returned.
    #
    # If a block is given it will be used in place of Format#generate to format 
    # the node tree.
    
    def to_s &block
      if block_given? || parsed?
        base.to_s(&block)
      else
        @raw
      end
    end
    
    
    # Add (+)
    #
    # Add this RichText to another.
    
    def + other
      # If the other object is of the same class, and neither
      # one of the texts have been parsed, we can concatenate
      # the raw inputs together
      if other.class == self.class && !parsed? && !other.parsed?
        return self.class.new (@raw + other.raw)
      end
      
      # Same root class
      if Document === other
        return self.class.new (base + other.base)
      end
      
      unless other.respond_to?(:to_s)
        raise TypeError,
          "cannot add #{other.class.name} to #{self.class.name}"
      end
      
      # Assume that the input is a raw string of the same
      # class as the current RichText object and wrap it
      # before adding it
      self + self.class.new(other)
    end
    
    
    def append string, **attributes
      node = Entry.new(string, **attributes)
      base.add node
      node
    end
    
    
    # Base
    #
    # Protected getter for the base node. If the raw input has not yet been 
    # parsed that will happen first, before the base node is returned.
    
    protected def base
      unless @base
        @base = self.class.parse @raw
        @raw  = nil # Free the cached string
      end
      
      @base
    end
    
    
    # Raw
    #
    # Protected getter for the raw input.
    
    protected def raw
      @raw
    end
    
    
    # Parsed?
    #
    # Returns true if the raw input has been parsed and the internal 
    # representation is now a tree of nodes.
    
    def parsed?
      @raw.nil?
    end
    
    
    def each_node &block
      base.each(&block)
    end
    
    
    def self.parse string
      Entry.new string
    end
    
    
    # From
    #
    # Convenience method for instansiating one RichText object from another. The 
    # methods only purpose is to make that intent more clear, and to make the 
    # creation from another RichText object explicit.
    
    def self.from doc
      unless Document === doc
        raise TypeError, 
            "Can only create a #{self.name} from other RichText objects"
      end
          
      self.new doc
    end
  end
end