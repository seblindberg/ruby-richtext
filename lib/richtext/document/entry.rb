# frozen_string_literal: true

module RichText
  class Document
    # Entry
    #
    # The Entry class extends the basic Node class and adds methods that make
    # handling text a little nicer. Essentially the :text attribute is given
    # special status by allowing it to a) be set during initialization, b) only
    # visible in leaf nodes and c) copied over when adding children to leaf
    # nodes.
    #
    # Some attributes are also supported explicitly by the inclusion of special
    # accesser methods. The attributes are are bold, italic, underline, color
    # and font.
    #
    class Entry < RootedTree::Node
      protected :prepend_child, :prepend_sibling, :value
      
      # Initialize
      #
      # Extend the default Node initializer by also accepting a string. It will,
      # if given, be stored as a text attribute.
      def initialize(text = nil, **attributes)
        attributes[:text] = text if text
        super attributes
      end
      
      alias attributes value
      
      def [](key)
        attributes[key]
      end
      
      def []=(key, v)
        attributes[key] = v
      end

      # Text
      #
      # Read the text of the node. This will return nil unless the node is a
      # leaf node. Note that nodes that are not leafs can have the text entry,
      # but it is discouraged by dissalowing access using this method.
      def text
        self[:text] || '' if leaf?
      end

      # Append
      #
      # Since the text attribute is treated differently, and only leaf nodes can
      # expose it, it must be pushed to a new child if a) this node was a leaf
      # prior to this method call and b) its text attribute is not empty.
      # def <<(child)
      #   if leaf?
      #     # Remove the text entry from the node and put it in a new leaf node
      #     # among the children, unless it is empty
      #     if (t = value.delete :text)
      #       create_child(t) unless t.empty?
      #     end
      #   end
      #
      #   super
      # end

      # Create Child
      #
      # Create and append a new child, initialized with the given text and
      # attributes.
      def append_child(text = nil, **attributes)
        if leaf? && (t = value.delete :text)
          append_child self.class.new(t)
        end
          
        if text.is_a? self.class
          super text
        else
          super self.class.new(text, attributes)
        end
      end
      
      alias << append_child
      
      # Optimize!
      #
      # Go through each child and merge any node that a) is not a lead node and b)
      # only has one child, with its child. The attributes of the child will
      # override those of the parent.
      def optimize!
        # If the node is a leaf it cannot be optimized further
        return self if leaf?
      
        # First optimize each of the children. If a block was
        # given each child will be yielded to it, and children
        # for which the block returns false will be removed
        if block_given?
          children.each { |child| child.delete unless yield child.optimize! }
        else
          children.each do |child|
            child.optimize!
            child.delete if child.leaf? && child.text.empty?
          end
        end
      
        # If we only have one child it is superfluous and
        # should be merged. That means this node will inherrit
        # the children of the single child as well as its
        # attributes
        if degree == 1
          # Move the attributes over
          attributes.merge! child.attributes
          # Get the children of the child and add them to self
          first_child.delete.each { |child| append_child child }
        end
      
        self
      end
      
      def optimize
        dup.optimize!
      end

      # To String
      #
      # Combine the text from all the leaf nodes in the tree, from left to
      # right. If a block is given the node, along with its text will be passed
      # as arguments. The block will be called recursivly, starting at the leaf
      # nodes and propagating up until the entire tree has been "rendered" in
      # this way.
      def to_s(&block)
        string =
          if leaf?
            text
          else
            children.reduce('') { |a, e| a + e.to_s(&block) }
          end

        block_given? ? yield(self, string) : string
      end
      
      def inspect *args, &block
        unless block_given?
          block = proc do |entry|
            entry.leaf? ? entry.text : 'Entry'
          end
        end
        
        super(*args, &block)
      end

      # Supported Text Attributes

      # Bold
      #
      def bold?
        self[:bold]
      end

      def bold=(b)
        self[:bold] = b ? true : false
      end

      # Italic
      #
      def italic?
        self[:italic]
      end

      def italic=(i)
        self[:italic] = i ? true : false
      end

      # Underline
      #
      def underline?
        self[:underline]
      end

      def underline=(u)
        self[:underline] = u ? true : false
      end

      # Color
      #
      def color
        self[:color]
      end

      def color=(c)
        self[:color] = c
      end

      # Font
      #
      def font
        self[:font]
      end

      def font=(f)
        self[:font] = f
      end
    end
  end
end
