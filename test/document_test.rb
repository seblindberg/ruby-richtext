require 'test_helper'

describe RichText::Document do
  subject { ::RichText::Document }
  let(:subclass) { Class.new subject }

  it 'only parses the format when it needs to' do
    initial_node_count = node_count

    rt = subject.new 'test'
    assert_equal initial_node_count, node_count

    subject.new rt
    assert_equal initial_node_count, node_count

    subclass.new rt
    refute_equal initial_node_count, node_count
  end

  describe '#initialize' do
    it 'accepts a string' do
      rt = subject.new 'test'
      assert_equal 'test', rt.to_s
    end

    it 'accepts another RichText object' do
      orig = subject.new 'test'
      copy = subject.new orig

      refute_same orig, copy
      assert_equal orig.to_s, copy.to_s
    end

    it 'accepts a RichText object that has parsed its content' do
      orig = subject.new 'test'

      # Force a call to .parse
      orig.base
      assert orig.parsed?

      copy = subject.new orig

      assert_equal orig.to_s, copy.to_s
    end

    it 'accepts subclasses' do
      orig = subclass.new 'test'
      copy = subject.new orig

      assert copy.parsed?
      assert_equal orig.to_s, copy.to_s
    end

    it 'accepts superclasses' do
      orig = subject.new 'test'
      copy = subclass.new orig

      assert copy.parsed?
      assert_equal orig.to_s, copy.to_s
    end

    it 'accepts a tree of entries' do
      root = subject::Entry.new('a')
      root << subject::Entry.new('b')
      root << subject::Entry.new('c')

      rt = subject.new root
      assert_equal 'abc', rt.to_s
    end
  end

  describe '#parsed?' do
    it 'returns false when the object is not parsed' do
      text = subject.new 'a'
      refute text.parsed?
    end

    it 'returns true when the object is parsed' do
      root = subject::Entry.new 'a'
      text = subject.new root

      assert text.parsed?
    end
  end

  describe '#to_s' do
    # TODO
  end

  describe '#+' do
    it 'combines two objects into a new one' do
      initial_node_count = text_node_count

      text_a = subject.new 'a'
      text_b = subject.new 'b'

      text_ab = text_a + text_b

      assert_equal initial_node_count, text_node_count,
                   'No Entries should have been created'
      assert_equal 'ab', text_ab.to_s
    end

    it 'combines dissimilar classes' do
      text_a = subject.new  'a'
      text_b = subclass.new 'b'

      initial_node_count = text_node_count

      assert_equal 'ab', (text_a + text_b).to_s
      assert_operator initial_node_count, :<, text_node_count,
                      'Some new Entries should have been created'

      assert_instance_of subject,  (text_a + text_b)
      assert_instance_of subclass, (text_b + text_a)
    end

    it 'accepts a string' do
      text_a = subject.new 'a'
      text_ab = text_a + 'b'

      assert_equal 'ab', text_ab.to_s
    end
  end

  describe '#each_node' do
    it 'returns an enumerator' do
      rt = subject.new 'test'
      assert_kind_of Enumerator, rt.each_node
    end

    it 'iterates over the nodes' do
      rt = subject.new 'test'
      count = 0

      rt.each_node do
        count += 1
      end

      assert_equal 1, count
    end
  end

  describe '.from' do
    it 'creates a new object from an existing one' do
      rt = subject.new 'test'
      rt_sub = subclass.from rt

      refute_kind_of subclass, rt
      assert_kind_of subclass, rt_sub

      assert_equal rt.to_s, rt_sub.to_s
    end
  end
end
