# frozen_string_literal: true

module RichText
  # Document
  #
  class Document
    attr_reader :raw
    protected :raw

    # Create a new RichText Document, either from a string or from an existing
    # document. That feature is particularly useful when converting between
    # formats.
    #
    # When given a string or a RichText Document of the same class no parsing is
    # performed. Only when given a document of a different subclass will the
    # parser need to be run parsed. Note that the document(s) may already be in
    # parsed form, in which case no further parsing is performed. See #root for
    # more details.

    def initialize(arg = '')
      @root, @raw =
        if arg.instance_of? self.class
          arg.parsed? ? [arg.root, nil] : [nil, arg.raw]
        elsif arg.is_a? Document
          # For any other RichText object we take the root node
          [arg.root, nil]
        elsif arg.is_a? Entry
          # Also accept an Entry which will be used as the
          # document root
          [arg.root, nil]
        else
          [nil, arg.to_s]
        end
    end

    # Uses the static implementation of .render to convert the document back
    # into a string. If the document was never parsed (and is unchanged) the
    # origninal string is just returned.
    #
    # If a block is given it will be used in place of .render to format the node
    # tree.
    #
    # Returns a string formatted according to the rules outlined by the Document
    # format.

    def to_s(&block)
      if block_given?
        root.to_s(&block)
      elsif parsed? || should_parse?
        self.class.render root
      else
        @raw
      end
    end

    # Uses Entry#to_s to reduce the node structure down to a string.
    #
    # Returns the strings from all of the leaf nodes without any formatting
    # applied.

    def to_plain
      root.to_s
    end

    # Add another Document to this one. If the two are of (exactly) the same
    # class and neither one has been parsed, the two raw strings will be
    # concatenated. If the other is a Document the two root nodes will be merged
    # and the new root added to a new Document.
    #
    # Lastly, if other is a string it will first be wraped in a new Document and
    # then added to this one.

    def +(other)
      # If the other object is of the same class, and neither
      # one of the texts have been parsed, we can concatenate
      # the raw inputs together
      if other.class == self.class && !parsed? && !other.parsed?
        return self.class.new(@raw + other.raw)
      end

      # Same root class
      return self.class.new(root + other.root) if other.is_a? Document

      unless other.respond_to? :to_s
        raise TypeError,
              "Cannot add #{other.class.name} to #{self.class.name}"
      end

      # Assume that the input is a raw string of the same
      # class as the current RichText object and wrap it
      # before adding it
      self + self.class.new(other)
    end

    # Append a string to the document. The string will not be parsed but
    # inserted into a new entry, directly under the document root.
    #
    # string - the string that will be wrapped in an Entry object.
    # attributes - a hash of attributes that will be applied to the Entry.
    #
    # Returns the newly created child.

    def append(string, **attributes)
      root.append_child string, **attributes
      root.child(-1)
    end

    # Getter for the root node. If the raw input has not yet been
    # parsed that will happen first, before the root node is returned.
    #
    # Returns the root Entry.

    def root
      unless @root
        @root = Entry.new
        self.class.parse @root, @raw
        @raw = nil
      end

      @root
    end

    alias base root

    # Returns true if the raw input has been parsed and the internal
    # representation is now a tree of nodes.

    def parsed?
      @raw.nil?
    end

    protected def should_parse?
      false
    end

    # Iterate over all Entry nodes in the document tree.

    def each_node(&block)
      root.each(&block)
    end

    alias each_entry each_node

    # Document type specific method for parsing a string and turning it into a
    # tree of entry nodes. This method is intended to be overridden when the
    # Document is subclassed. The default implementation just creates a top
    # level Entry containing the given string.

    def self.parse(root, string)
      root.text = string
    end

    # Document type specific method for rendering a tree of entry nodes. This
    # method is intended to be overridden when the Document is subclassed. The
    # default implementation just concatenates the text entries into.

    def self.render(root)
      root.to_s
    end

    # Convenience method for instansiating one RichText object from another. The
    # methods only purpose is to make that intent more clear, and to make the
    # creation from another RichText object explicit.

    def self.from(doc)
      unless doc.is_a? Document
        raise TypeError,
              "Can only create a #{name} from other RichText Documents"
      end

      new doc
    end
  end
end
