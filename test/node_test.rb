require 'test_helper'

describe RichText::Node do
  subject { ::RichText::Node }
  let(:node) { subject.new }
  
  it 'accepts children' do
    assert_empty node.children
    node << 'String'
    refute_empty node.children
  end
  
  it 'accepts a name' do
    n = subject.new :name
    assert_equal :name, n.name
  end
  
  describe '#to_s' do
    it 'flattens the tree' do
      lvl_1 = subject.new :lvl_1
      lvl_1 << 'Hello'
      
      lvl_0 = subject.new
      lvl_0 << lvl_1
      lvl_0 << ' '
      lvl_0 << 'world'
      
      assert_equal 'Hello',       lvl_1.to_s
      assert_equal 'Hello world', lvl_0.to_s
    end
  end
end
