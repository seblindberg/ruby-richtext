require 'richtext/version'
require 'richtext/node'
require 'richtext/format'

class RichText
  FORMAT = Format
  
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
    @base, @raw = case arg
    when self.class then [nil,  arg.raw]
    when RichText   then [arg.base, nil]
    else                 [nil,      arg]
    end
  end
  
  
  # To String
  #
  # Use the formats implementation of #generate to convert the RichText object 
  # back into a string. If no base node exist yet the original input is 
  # returned.
  
  def to_s
    @base ? FORMAT.generate(@base) : @raw
  end
  
  
  # Base
  #
  # Protected getter for the base node. If the raw input has not yet been parsed 
  # that will happen first, before the base node is returned.
  
  protected def base
    unless @base
      @base = FORMAT.parse @raw
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
