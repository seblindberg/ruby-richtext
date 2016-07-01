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
    html = rt.to_s do |entry, string|
      # Access the attributes from the entry and format the
      # string accordingly
      string += entry[:my_attribute] if entry[:my_attribute]
      string = "<b>#{string}</b>" if entry.bold?
      
      # Return the formatted string at the end of the block
      string
    end
    
    # puts html # => 'hello <b>world!</b>'
    assert_equal 'hello <b>world!</b>', html
  end
end