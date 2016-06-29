# Format
#
# The format extension of the RichText class describes how a specific format is # converted to and from a RichText object.

require 'singleton'

class RichText
  class Format
    include Singleton
    
    # Default implementation of parse
    #
    # This method is clearly ment to be overridden by the specific format 
    # implementation. However, instead of raising an error the default action is
    # to wrap the given string in a base node.
    
    def parse string
      Node.new.tap {|n| n << string }
    end
    
    
    # Default implementation of generate
    #
    # Like #parse this method is ment to be overridden by the specific format 
    # implementation
    
    def generate parent_node, string
      string
    end
    
    
    # Parse
    #
    # Delegate the parsing to the format instance.

    def self.parse *args
      instance.parse(*args)
    end
    
    
    # Generate
    #
    # Delegate the generating to the format instance.
    
    def self.generate node
      # Collect the combined string from the children
      string = node.children.inject('') do |str, child|
        str + (Node === child ? self.generate(child) : child)
      end
      
      instance.generate node, string
    end
  end
end