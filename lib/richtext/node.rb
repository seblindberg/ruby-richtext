class RichText
  class Node
    attr_reader :children, :name
    
    def initialize name = :base
      @name       = name
      @children   = []
      @attributes = {}
    end
    
    
    # Add child
    #
    # A child is any object that respond to #to_s.
    
    def << *children
      @children += children
    end
    
    def to_s
      @children.reduce('') {|str, child| str + child.to_s }
    end
    
    def inspect
      "#<Node %{name}:%<id>#x>\n%{children}" % { 
        id: self.object_id, 
        children: @children.map{|c| 
            c.inspect.gsub(/(^)/) { $1 + '  ' }}.join("\n"),
        name: @name
      }
    end
  end
end