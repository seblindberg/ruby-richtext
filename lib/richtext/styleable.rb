module RichText
  module Styleable
    
    # Returns true if the Entry has bold formatting.
    
    def bold?
      self[:bold]
    end
  
    def bold=(b)
      self[:bold] = b ? true : false
    end
  
    # Returns true if the Entry has italic formatting.
    
    def italic?
      self[:italic]
    end
  
    def italic=(i)
      self[:italic] = i ? true : false
    end
  
    # Returns true if the Entry has underlined formatting.
    
    def underlined?
      self[:underlined]
    end
    
    alias underline? underlined?
  
    def underlined=(u)
      self[:underlined] = u ? true : false
    end
    
    alias underline= underlined=
  
    # Color
    
    def color
      self[:color]
    end
  
    def color=(c)
      self[:color] = c
    end
  
    # Font
    
    def font
      self[:font]
    end
  
    def font=(f)
      self[:font] = f
    end
  end
end
