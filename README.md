# RichText 

[![Gem Version](https://badge.fury.io/rb/richtext.png)](http://badge.fury.io/rb/richtext)
[![Build Status](https://travis-ci.org/seblindberg/ruby-richtext.svg?branch=master)](https://travis-ci.org/seblindberg/ruby-richtext) 
[![Coverage Status](https://coveralls.io/repos/github/seblindberg/ruby-richtext/badge.svg?branch=master)](https://coveralls.io/github/seblindberg/ruby-richtext?branch=master)
[![Inline docs](http://inch-ci.org/github/seblindberg/ruby-richtext.svg?branch=master)](http://inch-ci.org/github/seblindberg/ruby-richtext)

This gem is intended to simplify the handling of formatted text. Out of the box there is no support for any actual format, but that is intentional. The RichText::Document class is primarily ment to be subclassed and extended, and only includes functionality that is (potentially) useful to any format.

See _Usage_ below for more details on how to work with and extend the gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'richtext'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install richtext

## Usage

```ruby
# Create a new RichText document
rt = RichText::Document.new 'hello '

# Or use the more convenient method
rt = RichText 'hello '

# Format the text using attributes
entry = rt.append('world', bold: true, my_attribute: '.')

# Some common styling attributes are supported directly
# This line is equivalent to entry[:italic] = true
entry.italic = true
# Under the covers the attributes are stored as
# key-value pairs, so any attribute is valid
entry[:my_attribute] = '!'

# Render the text without any formatting
puts rt.to_s # => 'hello world'

# Or style the text yourself
html = rt.to_s do |e, string|
  # Access the attributes from the entry and format the
  # string accordingly
  string += e[:my_attribute] if e[:my_attribute]
  string = "<b>#{string}</b>" if e.bold?

  # Return the formatted string at the end of the block
  string
end

puts html # => 'hello <b>world!</b>'
```

Implementing new formats is easy. Just extend the `RichText::Document` class and implement the class methods `.parse` and `.render`. The following snippet describes a document type that only renders words with more than 6 letters.

```ruby
class MyFormat < RichText::Document
  def should_parse?
    true
  end

  def self.parse(base, string)
    # Format specific implementation to parse a string. Here
    # each word is represented by its own entry. Entries are
    # given a random visibility attribute.
    string.split(' ').each do |word|
      base.create_child word, visible: (word.length > 6)
    end
  end

  def self.render(base)
    # Format specific implementation to render the document
    str = base.to_s do |entry, string|
      next string unless entry.leaf?
      entry[:visible] ? string + ' ' : ''
    end

    str.rstrip
  end
end

doc = MyFormat.new 'Format specific implementation to parse a string'
puts doc.to_s # => 'specific implementation'

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seblindberg/richtext.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

