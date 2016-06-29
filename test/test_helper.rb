$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'richtext'

require 'minitest/autorun'

def node_count
  ObjectSpace.each_object(RichText::Node).count
end