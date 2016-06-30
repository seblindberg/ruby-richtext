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
    child = subject.new name: '0'
    child << {name: 'a'}
    child << {name: 'b'}
    
    base = subject.new name: '0'
    base << child
    base << {name: 'c'}
    
    [base, 5]
  }
  
  
  # Non-minimal Tree:  0
  # Size: 3            |
  #                    1
  #                    |
  #                   'a'
  
  let(:non_minimal_tree) {
    child = subject.new name: '1'
    child << {name: 'a'}
    
    base = subject.new name: '0'
    base << child
    
    [base, 3]
  }
  
  
  describe '#+' do
    it 'joins two nodes under a new root as siblings' do
      node_a = subject.new name: 'a'
      node_b = subject.new name: 'b'
      
      node_c = node_a + node_b
      assert_equal 3, node_c.size
      
      children = node_c.each_child.to_a
      
      assert_equal node_a, children[0]
      assert_equal node_b, children[1]
    end
  end
  
  
  describe '#add' do
    it 'accepts children' do
      assert_equal 0, node.count
      assert node.leaf?
      
      node << subject.new
      assert_equal 1, node.count
      refute node.leaf?
    end
    
    it 'converts a leaf node to a regular node' do
      leaf = subject.new
      assert leaf.leaf?
      
      leaf << subject.new
      refute leaf.leaf?
      
      assert_equal 1, leaf.count
      assert_equal 2, leaf.size
    end
  end
  
    
  describe '#count' do
    it 'returns zero for empty nodes' do
      assert_equal 0, node.count
    end
    
    it 'returns zero for leafs' do
      leaf = subject.new
      
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
      leaf = subject.new
      
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
      
      node.add(*children.map{|n| {name: n} })
      
      child_enum = children.each
      
      # Make sure all of the children match
      node.each_leaf do |child|
        count += 1
        assert       child.leaf?
        assert_equal child_enum.next, child[:name]
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
      child_enum = children.map{|n| {name: n} }.each
      count      = 0
      
      lvl_1 = subject.new
      lvl_1 << child_enum.next
      
      lvl_0 = subject.new
      lvl_0 << lvl_1
      lvl_0 << child_enum.next
      lvl_0 << child_enum.next
      
      child_enum = children.each
      
      lvl_0.each_leaf do |child|
        count += 1
        assert_equal child_enum.next, child[:name]
      end
      
      assert_equal children.count, count
    end
  end
  
  
  describe '#minimal?' do
    it 'returns true for leaf nodes' do
      leaf = subject.new
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
