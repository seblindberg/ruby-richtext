require 'test_helper'

describe 'README.md' do
  it 'gives the correct output' do
    # Create a new RichText document
    rt = RichText::Document.new 'hello '

    # Or use the more convenient method
    rt = RichText 'hello '

    # Format the text using attributes
    entry = rt.append('world', bold: true, my_attribute: '.')

    # Some common styling attributes are supported directly
    # This line is equivalent to entry[:italic] = true
    entry.italic = true
    # Under the covers the attributes are stored as
    # key-value pairs, so any attribute is valid
    entry[:my_attribute] = '!'

    # Render the text without any formatting
    # puts rt.to_s # => 'hello world'
    assert_equal 'hello world', rt.to_s

    # Or style the text yourself
    html = rt.to_s do |e, string|
      # Access the attributes from the entry and format the
      # string accordingly
      string += e[:my_attribute] if e[:my_attribute]
      string = "<b>#{string}</b>" if e.bold?

      # Return the formatted string at the end of the block
      string
    end

    # puts html # => 'hello <b>world!</b>'
    assert_equal 'hello <b>world!</b>', html
  end

  it 'subclasses' do
    class MyFormat < RichText::Document
      def should_parse?
        true
      end

      def self.parse(base, string)
        # Format specific implementation to parse a string. Here
        # each word is represented by its own entry. Entries are
        # given a random visibility attribute.
        string.split(' ').each do |word|
          base.create_child word, visible: (word.length > 6)
        end
      end

      def self.render(base)
        # Format specific implementation to render the document
        str = base.to_s do |entry, string|
          next string unless entry.leaf?
          entry[:visible] ? string + ' ' : ''
        end

        str.rstrip
      end
    end

    doc = MyFormat.new 'Format specific implementation to parse a string'
    # puts doc.to_s # => 'specific implementation'
    assert_equal 'specific implementation', doc.to_s
  end
end
