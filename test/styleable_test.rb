require 'test_helper'

class StyleableObject
  include RichText::Styleable

  def initialize
    @hash = {}
  end

  def [](key)
    @hash[key]
  end

  def []=(key, value)
    @hash[key] = value
  end

  def fetch(key)
    @hash.fetch key
  end
end

describe RichText::Styleable do
  subject { StyleableObject.new }

  describe 'bold' do
    it 'inserts :bold => true/false' do
      subject.bold = true
      assert subject.fetch(:bold)
      subject.bold = false
      refute subject.fetch(:bold)
    end

    it 'is bold' do
      refute subject.bold?
      subject[:bold] = true
      assert subject.bold?
    end
  end

  describe 'italic' do
    it 'inserts :italic => true/false' do
      subject.italic = true
      assert subject.fetch(:italic)
      subject.italic = false
      refute subject.fetch(:italic)
    end

    it 'is italic' do
      refute subject.italic?
      subject[:italic] = true
      assert subject.italic?
    end
  end

  describe 'underlined' do
    it 'inserts :underlined => true/false' do
      subject.underlined = true
      assert subject.fetch(:underlined)
      subject.underlined = false
      refute subject.fetch(:underlined)
    end

    it 'is underlined' do
      refute subject.underlined?
      subject[:underlined] = true
      assert subject.underlined?
    end

    it 'has the alias underline' do
      assert_equal subject.method(:underlined?), subject.method(:underline?)
      assert_equal subject.method(:underlined=), subject.method(:underline=)
    end
  end

  describe 'color' do
    it 'inserts :color => value' do
      subject.color = :value
      assert_equal :value, subject.fetch(:color)
    end

    it 'returns the color' do
      subject[:color] = :value
      assert_equal :value, subject.color
    end
  end

  describe 'font' do
    it 'inserts :font => value' do
      subject.font = :value
      assert_equal :value, subject.fetch(:font)
    end

    it 'returns the font' do
      subject[:font] = :value
      assert_equal :value, subject.font
    end
  end
end
