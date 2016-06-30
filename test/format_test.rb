require 'test_helper'

describe RichText::Format do
  subject { ::RichText::Format }
  let(:node) { ::RichText::Node.new }
  
  describe '.parse' do
    it 'wraps the string in a Node object' do
      node = subject.parse 'test'
      
      assert_kind_of ::RichText::Node, node
      # Check the text of the first leaf
      assert_equal 'test', node.first.to_s
    end
  end
  
  describe '.generate' do
    it 'generates a bare string from a Node object' do
      node << 'test'
      string = subject.generate node

      assert_equal 'test', string
    end
    
    it 'recursivly combines the nodes' do
      lvl_1 = ::RichText::Node.new
      lvl_1 << 'hello'
      lvl_1 << ' '
      
      lvl_0 = ::RichText::Node.new
      lvl_0 << lvl_1
      lvl_0 << 'world'
      
      assert_equal 'hello world', subject.generate(lvl_0)
    end
    
    it 'passes the parent node to #generate' do
      mock = Class.new subject do
        def generate parent_node, string
          (parent_node[:name] || '') + string
        end
      end
      
      node_a = ::RichText::Node.new name: 'a' 
      node_b = ::RichText::Node.new name: 'b'
      node_c = ::RichText::Node.new name: 'c'
      
      node_c << 'd'
      node_b << node_c
      node_a << node_b
      
      assert_equal 'abcd', mock.generate(node_a)
    end
  end
end
