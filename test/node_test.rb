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
  
  describe '#each_child' do
    it 'returns an enumerator' do
      assert_kind_of Enumerator, node.each_child
    end
    
    it 'iterates over the children' do
      children = ['a', 'b', 'c']
      count    = 0
      
      node.<<(*children)
      child_enum = children.each
      
      # Make sure all of the children match
      node.each_child do |child|
        count += 1
        assert_equal child_enum.next, child
      end
      
      assert_equal children.count, count
    end
    
    it 'iterates recursivly' do
      children   = ['a', 'b', 'c']
      child_enum = children.each
      count      = 0
      
      lvl_1 = subject.new :lvl_1
      lvl_1 << child_enum.next
      
      lvl_0 = subject.new
      lvl_0 << lvl_1
      lvl_0 << child_enum.next
      lvl_0 << child_enum.next
      
      child_enum.rewind
      
      lvl_0.each_child do |child|
        count += 1
        assert_equal child_enum.next, child
      end
      
      assert_equal children.count, count
    end
  end
end
