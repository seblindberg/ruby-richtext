require 'test_helper'

describe RichText do
  subject { ::RichText }
  let(:subclass) { Class.new subject }
  
  it 'has a version number' do
    refute_nil subject::VERSION
  end
  
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
      orig.each_node # Force the child to call .parse
      copy = subject.new orig
      
      assert_equal orig.to_s, copy.to_s
    end
    
    it 'accepts subclasses of RichText' do
      orig = subclass.new 'test'
      copy = subject.new orig
      
      assert_equal orig.to_s, copy.to_s
    end
    
    it 'accepts a TextNode tree' do
      root   = subject::TextNode.new 'a'
      root.add subject::TextNode.new 'b'
      root.add subject::TextNode.new 'c'
      
      rt = subject.new root
      assert_equal 'abc', rt.to_s
    end
  end
  
  
  describe '#+' do
    it 'combines two objects into a new one' do
      initial_node_count = text_node_count 
      
      text_a = subject.new 'a'
      text_b = subject.new 'b'
      
      text_ab = text_a + text_b
      
      assert_equal initial_node_count, text_node_count,
          'No TextNodes should have been created'
      assert_equal 'ab', text_ab.to_s
    end
    
    it 'combines dissimilar classes' do      
      text_a = subject.new  'a'
      text_b = subclass.new 'b'
      
      initial_node_count = text_node_count 
      
      assert_equal 'ab', (text_a + text_b).to_s
      assert_operator initial_node_count, :<, text_node_count,
          'Some new TextNodes should have been created'
      
      assert_instance_of subject,  (text_a + text_b)
      assert_instance_of subclass, (text_b + text_a)
    end
  end
  
  
  describe '#each_node' do
    it 'returns an enumerator' do
      rt    = subject.new 'test'
      assert_kind_of Enumerator, rt.each_node
    end
      
    it 'iterates over the nodes' do
      rt    = subject.new 'test'
      count = 0
      
      rt.each_node do |node|
        count += 1
      end
      
      assert_equal 1, count
    end
  end
  
  
  describe '#RichText' do
    it 'also create a RichText object' do
      assert_kind_of subject, RichText('test')
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
