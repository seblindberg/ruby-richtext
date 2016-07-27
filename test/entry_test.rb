require 'test_helper'

describe RichText::Document::Entry do
  subject { ::RichText::Document::Entry }
  
  let(:node) { subject.new }
  let(:child) { subject.new }

  # Minimal Tree:  0
  # Size: 5       / \
  #              1  'c'
  #             / \
  #           'a' 'b'
  #
  let(:minimal_tree) do
    ab = subject.new 'a'
    ab.append_child 'b'
    
    base = subject.new
    base << ab
    base << 'c'

    base
  end

  # Non-minimal Tree:  0
  # Size: 3            |
  #                    1
  #                    |
  #                   'a'
  #
  let(:non_minimal_tree) do
    child = subject.new
    child << 'a'

    base = subject.new
    base << child

    base
  end

  describe '#append_child' do
    it 'appends children' do
      node.append_child child
      assert_same node.child, child
    end
    
    it 'moves the text from a leaf node to a new child' do
      # Create a leaf node and a child
      leaf  = subject.new 'text'
      child = subject.new

      # Add the child to the leaf node
      leaf.append_child child

      # The old leaf should no longer have any text
      assert_nil leaf[:text]

      # The text that was previously in the old leaf should
      # now be in the first of the two children of the leaf
      assert_equal 2, leaf.degree
      assert_equal 'text', leaf.child(0).text
    end
    
    it 'accepts strings' do
      # Add a string as a child. This should be interpreted
      # as a blank Entry with the text 'test'
      node.append_child 'test', bold: true
      assert_equal 'test', node.child.text
      assert node.child.bold?
    end
    
    it 'is also available as the alias #<<' do
      assert_equal node.method(:append_child), node.method(:<<)
    end
  end
  
  describe '#prepend_child' do
    it 'is protected' do
      assert_raises(NoMethodError) { node.prepend_child }
    end
  end
  
  describe '#prepend_sibling' do
    it 'is protected' do
      assert_raises(NoMethodError) { node.prepend_sibling }
    end
  end

  describe '#to_s' do
    it 'flattens the tree' do
      assert_equal 'abc', minimal_tree.to_s
      assert_equal 'a',   non_minimal_tree.to_s
    end
  end

  describe '#optimize!' do
    it 'removes leaf children with blank text entries' do
      base = subject.new 'text'
      base << subject.new
      assert_equal 3, base.size
      base.optimize!
      assert_equal 1, base.size
    end
  end
end
