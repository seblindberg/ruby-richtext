require 'rooted_tree'

require 'richtext/version'
require 'richtext/styleable'
require 'richtext/document/entry'
require 'richtext/document'

module RichText
end

# RichText
#
# Convenience method for creating RichText objects. Calling RichText(obj) is
# equivalent to RichText::Document.new(obj).
def RichText(string)
  RichText::Document.new string
end
