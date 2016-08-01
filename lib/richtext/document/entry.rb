# frozen_string_literal: true

# The Entry class extends the basic Node class and adds methods that make
# handling text a little nicer. Essentially the :text attribute is given
# special status by allowing it to a) be set during initialization, b) only
# visible in leaf nodes and c) copied over when adding children to leaf nodes.
#
# Some attributes are also supported explicitly by the inclusion of special
# accesser methods. The attributes are are bold, italic, underline, color and
# font.

module RichText
  class Document
    class Entry < RootedTree::Node
      include Styleable

      attr_reader :attributes
      protected :prepend_child, :prepend_sibling, :value, :value=

      # Extend the default Node initializer by also accepting a string. It will,
      # if given, be stored as a text attribute.

      def initialize(text = nil, **attributes)
        @attributes = attributes
        super text
      end

      # Freeze the attributes hash, as well as the node structure.
      #
      # Returns self.

      def freeze
        @attributes.freeze
        super
      end

      # Accessor for single attributes.
      #
      # key - the attribute key
      #
      # Returns the attribute value if it is set and nil otherwise.

      def [](key)
        attributes[key]
      end

      # Write a single attribute.
      #
      # key - the attribute key
      # v - the new value

      def []=(key, v)
        attributes[key] = v
      end

      # Read the text of the node.
      #
      # Returns the string stored in the node, if it is a leaf. Otherwise nil.

      def text
        value || '' if leaf?
      end

      # Write the text of the node. The method will raise a RuntimeException if
      # the node is not a leaf.

      def text=(new_text)
        raise 'Only leafs can have a text entry' unless leaf?
        self.value = new_text
      end

      # Create and append a new child, initialized with the given text and
      # attributes.
      #
      # child_text - the text of the child or an Entry object.
      # attributes - a hash of attributes to apply to the child if child_text is
      #              not an Entry object.
      #
      # Returns self to allow chaining.

      def append_child(child_text = nil, **attributes)
        super self.class.new(value) if leaf? && !text.empty?

        if child_text.is_a? self.class
          super child_text
        else
          super self.class.new(child_text, attributes)
        end
      end

      alias << append_child

      # Go through each child and merge any node that a) is not a lead node and
      # b) only has one child, with its child. The attributes of the child will
      # override those of the parent.
      #
      # Returns self.

      def optimize!(&block)
        # If the node is a leaf it cannot be optimized further
        return self if leaf?

        block = proc { |e| e.leaf? && e.text.empty? } unless block_given?

        children.each do |child|
          child.delete if block.call child.optimize!(&block)
        end

        # If we only have one child it is superfluous and
        # should be merged. That means this node will inherrit
        # the children of the single child as well as its
        # attributes
        if degree == 1
          # Move the attributes over
          attributes.merge! child.attributes
          self.value = child.text
          # Get the children of the child and add them to self
          first_child.delete.each { |child| append_child child }
        end

        self
      end

      # Optimize a copy of the node tree based on the rules outlined for
      # #optimize!.
      #
      # Returns the root of the new optimized node structure.

      def optimize(&block)
        dup.optimize!(&block)
      end

      # Combine the text from all the leaf nodes in the tree, from left to
      # right. If a block is given the node, along with its text will be passed
      # as arguments. The block will be called recursivly, starting at the leaf
      # nodes and propagating up until the entire tree has been "rendered" in
      # this way.
      #
      # block - a block that will be used to generate strings for each node.
      #
      # Returns a string representation of the node structure.

      def to_s(&block)
        string =
          if leaf?
            text
          else
            children.reduce('') { |a, e| a + e.to_s(&block) }
          end

        block_given? ? yield(self, string) : string
      end

      # Represents the Entry structure as a hierarchy, showing the attributes of
      # each node as well as the text entries in the leafs.
      #
      # If a block is given, it will be called once for each entry, and the
      # returned string will be used to represent the object in the output
      # graph.
      #
      # Returns a string. Note that it will contain newline characters if the
      # node has children.

      def inspect(*args, &block)
        unless block_given?
          block = proc do |entry|
            base_name = entry.leaf? ? %("#{entry.text}") : '◯'
            base_name + entry.attributes.reduce('') do |a, (k, v)|
              a + " #{k}=#{v.inspect}"
            end
          end
        end

        super(*args, &block)
      end
    end
  end
end
