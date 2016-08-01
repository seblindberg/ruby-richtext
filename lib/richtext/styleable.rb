# Styleable
#
# Mixin for any object that respond to #[] and #[]= that includes methods for
# expressing text style. Both boolean properties such as boldness and arbitrary
# attributes such as font are supported.
#
# Attributes are stored as key-value pairs, where the key is a symbol and the
# value is some arbitrary object.

module RichText
  module Styleable
    
    # Returns true if bold formatting is applied.
    
    def bold?
      self[:bold]
    end
    
    # Sets bold to either true or false, depending on the given argument.
  
    def bold=(b)
      self[:bold] = b ? true : false
    end
  
    # Returns true if italic formatting is applied.
    
    def italic?
      self[:italic]
    end
    
    # Sets italic to either true or false, depending on the given argument.
  
    def italic=(i)
      self[:italic] = i ? true : false
    end
  
    # Returns true if underlined formatting is applied.
    
    def underlined?
      self[:underlined]
    end
    
    alias underline? underlined?
    
    # Sets underlined to either true or false, depending on the given argument.
  
    def underlined=(u)
      self[:underlined] = u ? true : false
    end
    
    alias underline= underlined=
  
    # Returns the color value if it is set, otherwise nil.
    
    def color
      self[:color]
    end
    
    # Sets the color value.
  
    def color=(c)
      self[:color] = c
    end
  
    # Returns the font value if it is set, otherwise nil.
    
    def font
      self[:font]
    end
    
    # Sets the font value.
  
    def font=(f)
      self[:font] = f
    end
  end
end
