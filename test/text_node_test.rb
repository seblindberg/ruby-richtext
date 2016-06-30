require 'test_helper'

describe RichText::TextNode do
  subject { ::RichText::TextNode }
  let(:node) { subject.new }
  
  # Minimal Tree:  0
  # Size: 5       / \
  #              1  'c'
  #             / \
  #           'a' 'b'

  let(:minimal_tree) {
    child = subject.new 'a'
    child << 'b'

    base = subject.new
    base << child
    base << 'c'

    base
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

    base
  }

  describe '#to_s' do
    it 'flattens the tree' do
      assert_equal 'abc',     minimal_tree.to_s
      assert_equal 'a', non_minimal_tree.to_s
    end
  end
end