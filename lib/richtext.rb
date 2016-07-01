require 'richtext/version'
require 'richtext/node'
require 'richtext/text_node'
require 'richtext/format'

class RichText  
  # Initialize
  #
  # Create a new RichText object, either from a string or from an existing 
  # object. That feature is particularly useful when converting between formats.
  #
  # When given a string or a RichText object of the same class no parsing is 
  # performed. Only when given a RichText object of a different class will that 
  # object need to be parsed. Note that it allready may be. See #base for more 
  # details.
  
  def initialize arg = ''
    @base, @raw = if self.class == arg.class
      arg.parsed? ?
        [arg.base, nil] :
        [nil, arg.raw]
    elsif RichText === arg
      # For any other RichText object we take the base node
      [arg.base, nil]
    elsif TextNode === arg
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
  
  def to_s
    parsed? ? self.class::Format.generate(@base) : @raw
  end
  
  
  # Add (+)
  #
  # Add this RichText to another.
  
  def + other
    # Same class
    if other.class == self.class
      # If neither of the two classes have been parsed yet
      # the raw strings can safely be added
      if @raw && other.raw
        return self.class.new (@raw + other.raw)
      end
    end
    
    # Same root class
    if RichText === other
      return self.class.new (base + other.base)
    end
    
    raise TypeError,
        "cannot add #{other.class.name} to #{self.class.name}"
  end
  
  
  # Base
  #
  # Protected getter for the base node. If the raw input has not yet been parsed 
  # that will happen first, before the base node is returned.
  
  protected def base
    unless @base
      @base = self.class::Format.parse @raw
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
    not @raw.nil?
  end
  
  
  def each_node &block
    base.each(&block)
  end
  
  
  # From
  #
  # Convenience method for instansiating one RichText object from another. The 
  # methods only purpose is to make that intent more clear, and to make the 
  # creation from another RichText object explicit.
  
  def self.from rt
    unless RichText === rt
      raise TypeError, 
          "Can only create a #{self.name} from other RichText objects"
    end
        
    self.new rt
  end
end


# RichText
#
# Convenience method for creating RichText objects. Calling RichText(obj) is 
# equivalent to RichText.new(obj).

def RichText string
  RichText.new string
end
