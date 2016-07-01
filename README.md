# Richtext

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/richtext`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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
# Create a new RichText object
rt = RichText.new 'hello '

# Or use the more convenient method
rt = RichText 'hello '

# Format the text using attributes
entry = rt.append 'world', bold: true, my_attribute: '.'

# Some common styling attributes are supported directly
entry.italic = true
# Under the covers the attributes are stored as key-value pairs
entry[:my_attribute] = '!'

# Render the text without any formatting
puts rt.to_s # => 'hello world'

# Or style the text yourself
html = rt.to_s do |entry, string|
    # Access the attributes from the entry and format the
    # string accordingly
    string += entry[:my_attribute] if entry[:my_attribute]
    string = "<b>#{string}</b> if entry.bold?
end

puts html # => 'hello <b>world!</b>'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/richtext.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

