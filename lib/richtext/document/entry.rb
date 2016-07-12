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
    class Entry < Node
      # Initialize
      #
      # Extend the default Node initializer by also accepting a string. It will,
      # if given, be stored as a text attribute.
      def initialize(text = nil, **attributes)
        super attributes
        self[:text] = text if text
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
      def <<(child)
        if leaf?
          # Remove the text entry from the node and put it in a new leaf node
          # among the children, unless it is empty
          if (t = @attributes.delete :text)
            create_child(t) unless t.empty?
          end
        end

        super
      end

      def create_child(text = '', **attributes)
        super attributes.merge(text: text)
      end

      # Optimize!
      #
      # See RichText::Node#optimize! for a description of the fundemental
      # behavior. Entries differ from regular Nodes in that leaf children with
      # no text in them will be removed.
      def optimize!
        super { |child| !child.leaf? || !child.text.empty? }
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
            @children.reduce('') { |a, e| a + e.to_s(&block) }
          end

        block_given? ? yield(self, string) : string
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
