require 'test_helper'

describe RichText::Node do
  subject { ::RichText::Node }
  let(:node) { subject.new }
  
  # Minimal Tree:  0
  # Size: 5       / \
  #              1  'c'
  #             / \
  #           'a' 'b'
  
  let(:minimal_tree) {
    child = subject.new
    child << 'a'
    child << 'b'
    
    base = subject.new
    base << child
    base << 'c'
    
    [base, 5]
  }
  
  
  # Non-minimal Tree:  0
  # Size: 3            |
  #                    1
  #                    |
  #                   'a'
  
  let(:non_minimal_tree) {
    child = subject.new
    child << 'a'
    
    base = subject.new
    base << child
    
    [base, 3]
  }
  
  
  it 'accepts children' do
    assert_empty node.children
    node << 'String'
    refute_empty node.children
  end
  
  
  describe '#to_s' do
    it 'flattens the tree' do
      lvl_1 = subject.new
      lvl_1 << 'Hello'
      
      lvl_0 = subject.new
      lvl_0 << lvl_1
      lvl_0 << ' '
      lvl_0 << 'world'
      
      assert_equal 'Hello',       lvl_1.to_s
      assert_equal 'Hello world', lvl_0.to_s
    end
  end
  
  
  describe '#count' do
    it 'returns zero for empty nodes' do
      assert_equal 0, node.count
    end
    
    it 'returns zero for leafs' do
      leaf = subject.new 'leaf'
      
      assert leaf.leaf?
      assert_equal 0, leaf.count
    end
    
    it 'returns the number of immediate children' do
      child = subject.new
      child << subject.new
      node << child
      assert_equal 1, node.count
    end
  end
  
  
  describe '#size' do
    it 'returns 1 for nodes with no children' do
      assert_equal 1, node.size
    end
    
    it 'returns 1 for leaf nodes' do
      leaf = subject.new 'leaf'
      
      assert leaf.leaf?
      assert_equal 1, leaf.size
    end
    
    it 'returns the total number of descending nodes, including the root' do
      child = subject.new
      child << subject.new
      node << child
      assert_equal 3, node.size
    end
  end
  
  
  describe '#each_leaf' do
    it 'returns an enumerator' do
      assert_kind_of Enumerator, node.each_leaf
    end
    
    it 'iterates over the leafs' do
      children = ['a', 'b', 'c']
      count    = 0
      
      node.<<(*children)
      
      child_enum = children.each
      
      # Make sure all of the children match
      node.each_leaf do |child|
        count += 1
        assert_equal child_enum.next, child.to_s
      end
      
      assert_equal children.count, count
    end
    
    
    # Tree:  0
    #      / | \
    #     1 'b''c'
    #     |
    #    'a'
    
    it 'iterates recursivly' do
      children   = ['a', 'b', 'c']
      child_enum = children.each
      count      = 0
      
      lvl_1 = subject.new
      lvl_1 << child_enum.next
      
      lvl_0 = subject.new
      lvl_0 << lvl_1
      lvl_0 << child_enum.next
      lvl_0 << child_enum.next
      
      child_enum.rewind
      
      lvl_0.each_leaf do |child|
        count += 1
        assert_equal child_enum.next, child.to_s
      end
      
      assert_equal children.count, count
    end
  end
  
  
  describe '#minimal?' do
    it 'returns true for leaf nodes' do
      leaf = subject.new 'leaf'
      assert leaf.minimal?
    end
    
    it 'returns true for minimal trees' do
      base, _ = minimal_tree
      assert base.minimal?
    end
    
    it 'returns false for non-minimal trees' do
      base, _ = non_minimal_tree
      refute base.minimal?
    end
  end
  
  
  describe '#optimize!' do
    it 'deos nothing to an already minimal tree' do
      base, size = minimal_tree
      assert_equal size, base.size
      base.optimize!
      assert_equal size, base.size
    end

    it 'transforms a non-minimal tree to its minimal form' do
      base, size = non_minimal_tree
      
      assert_equal size, base.size
      base.optimize!
      
      assert base.leaf?
      assert_equal 1, base.size
    end
  end
end
