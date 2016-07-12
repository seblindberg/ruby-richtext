require 'test_helper'

describe RichText::Document::Entry do
  subject { ::RichText::Document::Entry }
  let(:node) { subject.new }

  # Minimal Tree:  0
  # Size: 5       / \
  #              1  'c'
  #             / \
  #           'a' 'b'
  #
  let(:minimal_tree) do
    child = subject.new 'a'
    child.create_child 'b'

    base = subject.new
    base << child
    base.create_child 'c'

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
    child.create_child 'a'

    base = subject.new
    base << child

    base
  end

  describe '#<<' do
    it 'moves the text from a leaf node to a new child' do
      # Create a leaf node and a child
      leaf  = subject.new 'text'
      child = subject.new

      # Add the child to the leaf node
      leaf << child

      # The old leaf should no longer have any text
      assert_nil leaf.text
      assert_nil leaf[:text]

      # The text that was previously in the old leaf should
      # now be in the first of the two children of the leaf
      assert_equal 2, leaf.count
      assert_equal 'text', leaf.each_child.first.text
    end
  end

  describe '#create_child' do
    it 'accepts strings' do
      # Add a string as a child. This should be interpreted
      # as a blank Entry with the text 'test'
      node.create_child 'test'
      assert_equal 'test', node.each_child.first.text
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
