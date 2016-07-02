module RichText
  class Document
    # Initialize
    #
    # Create a new RichText Document, either from a string or from an existing 
    # ducument. That feature is particularly useful when converting between 
    # formats.
    #
    # When given a string or a RichText Document of the same class no parsing is 
    # performed. Only when given a document of a different subclass will the 
    # parser need to be run parsed. Note that the document(s) may already be in  
    # parsed form, in which case no further parsing is performed. See #base for 
    # more details.
    
    def initialize arg = ''
      @base, @raw = 
        if arg.class == self.class
          arg.parsed? ?
            [arg.base, nil] :
            [nil, arg.raw]
        elsif arg.is_a? Document
          # For any other RichText object we take the base node
          [arg.base, nil]
        elsif arg.is_a? Entry
          # Also accept an Entry which will be used as the
          # document base
          [arg, nil]
        else
          [nil, arg.to_s]
        end
    end
    
    
    # To String
    #
    # Use the static implementation of .render to convert the document back into
    # a string. If the document was never parsed (and is unchanged) the 
    # origninal string is just returned.
    #
    # If a block is given it will be used in place of .render to format the node 
    # tree.
    
    def to_s &block
      if block_given?
        base.to_s(&block)
      elsif parsed? || should_parse?
        self.class.render base
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
        return self.class.new(@raw + other.raw)
      end
      
      # Same root class
      if other.is_a? Document
        return self.class.new(base + other.base)
      end
      
      unless other.respond_to? :to_s
        raise TypeError,
          "Cannot add #{other.class.name} to #{self.class.name}"
      end
      
      # Assume that the input is a raw string of the same
      # class as the current RichText object and wrap it
      # before adding it
      self + self.class.new(other)
    end
    
    
    # Append
    #
    #
    
    def append string, **attributes
      base.create_child string, **attributes
    end
    
    
    # Base
    #
    # Getter for the base node. If the raw input has not yet been 
    # parsed that will happen first, before the base node is returned.
    
    def base
      unless @base
        @base = Entry.new
        self.class.parse @base, @raw
        @raw  = nil
      end
      
      @base
    end
    
    alias_method :root, :base
    
    
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
    
    
    protected def should_parse?
      false
    end
    
    
    # Each Node
    #
    # Iterate over all Entry nodes in the document tree.
    
    def each_node &block
      base.each(&block)
    end
    
    alias_method :each_entry, :each_node
    
    
    # Parse
    #
    # Document type specific method for parsing a string and turning it into a 
    # tree of entry nodes. This method is intended to be overridden when the 
    # Document is subclassed. The default implementation just creates a top 
    # level Entry containing the given string.
    
    def self.parse base, string
      base[:text] = string
    end
    
    
    # Render
    #
    # Document type specific method for rendering a tree of entry nodes. This 
    # method is intended to be overridden when the Document is subclassed. The 
    # default implementation just concatenates the text entries into.
    
    def self.render base
      base.to_s
    end
    
    
    # From
    #
    # Convenience method for instansiating one RichText object from another. The 
    # methods only purpose is to make that intent more clear, and to make the 
    # creation from another RichText object explicit.
    
    def self.from doc
      unless doc.is_a? Document
        raise TypeError, 
          "Can only create a #{self.name} from other RichText Documents"
      end
          
      self.new doc
    end
  end
end
