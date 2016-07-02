require 'richtext/version'
require 'richtext/node'
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
