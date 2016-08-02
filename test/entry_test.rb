require 'test_helper'

# TODO:
# - #dup duplicates text + attributes
# - #freeze freezes text + attributes

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

  describe '#freeze' do
    it 'freezes the attribute hash' do
      node.freeze
      assert node.attributes.frozen?
    end

    it 'freezes the text entry' do
      node.freeze
      assert_raises(RuntimeError) { node.text = 'text' }
    end
  end
  
  describe '#dup' do
    it 'dupes the attributes' do
      node_dup = node.dup
      
      refute_same node.attributes, node_dup.attributes
    end
    
    it 'dupes the text' do
      node.text = 'text'
      node_dup = node.dup
      
      refute_same node.text, node_dup.text
    end
  end

  describe '#[]' do
    it 'reads attributes' do
      node.attributes[:key] = :value
      assert_equal :value, node[:key]
    end

    it 'writes attributes' do
      node[:key] = :value
      assert_equal :value, node.attributes[:key]
    end
  end

  describe '#text' do
    it 'sets the text' do
      node.text = 'text'
      assert_equal 'text', node.text
    end

    it 'only allows setting the value of leafs' do
      node << child
      assert_raises(RuntimeError) { node.text = 'text' }
    end
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

  describe '#optimize!' do
    it 'removes leaf children with blank text entries' do
      base = subject.new 'text'
      base << subject.new
      assert_equal 3, base.size
      base.optimize!
      assert_equal 1, base.size
    end

    it 'accepts a block for how to optimize' do
      minimal_tree.optimize! do |entry|
        entry.text == 'b'
      end

      assert_equal 'ac', minimal_tree.to_s
    end
  end

  describe '#optimize' do
    it 'optimizes a copy of the original' do
      root = non_minimal_tree.optimize
      refute_same non_minimal_tree, root
    end

    it 'accepts a block for how to optimize' do
      root = minimal_tree.optimize do |entry|
        entry.text == 'b'
      end

      assert_equal 'ac', root.to_s
    end
  end

  describe '#to_s' do
    it 'flattens the tree' do
      assert_equal 'abc', minimal_tree.to_s
      assert_equal 'a',   non_minimal_tree.to_s
    end
  end

  describe '#inspect' do
    it 'outputs the text for leafs' do
      node.text = 'a'
      assert_equal '"a"', node.inspect
    end

    it 'lists the attributes' do
      node.text = 'a'
      node[:b] = 'b'
      node[:c] = 'c'

      assert_equal '"a" b="b" c="c"', node.inspect
    end

    it 'outputs a circle for internal nodes and indents children' do
      node << child
      node[:a] = 'a'
      child.text = 'b'

      lines = node.inspect.split "\n"
      assert_equal '◯ a="a"', lines.first
      assert_equal '└─╴"b"', lines.last
    end

    it 'accepts a block for formatting the nodes' do
      node << child
      res = node.inspect { 'test' }

      assert_equal "test\n└─╴test", res
    end
    
    it 'escapes newlines in the text entry' do
      node.text = "line 1\nline 2"
      
      assert_equal '"line 1\nline 2"', node.inspect
    end
  end
end
