require 'test_helper'

describe RichText do
  subject { ::RichText }
  
  it 'has a version number' do
    refute_nil subject::VERSION
  end
  
  it 'creates a RichText object' do
    rt = subject.new 'test'
    assert_equal 'test', rt.to_s
  end
  
  it 'only parses the format when it needs to' do
    initial_node_count = node_count 
    
    rt = subject.new 'test'
    assert_equal initial_node_count, node_count
    
    subject.new rt
    assert_equal initial_node_count, node_count
    
    rt_subclass = Class.new subject
    rt_subclass.new rt
    refute_equal initial_node_count, node_count
  end
  
  describe '#RichText' do
    it 'also create a RichText object' do
      assert_kind_of subject, RichText('test')
    end
  end
  
  describe '.from' do  
    it 'creates a new object from an existing one' do
      rt = subject.new 'test'
      rt_subclass = Class.new subject
      
      rt_sub = rt_subclass.from rt
      
      refute_kind_of rt_subclass, rt
      assert_kind_of rt_subclass, rt_sub
      assert_equal rt.to_s, rt_sub.to_s
    end
  end
end
