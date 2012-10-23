# CrashLog

[![Build Status](https://secure.travis-ci.org/crashlog/crashlog.png)](http://travis-ci.org/crashlog/crashlog)

CrashLog is a exception tracking and notification service that gives you unparalleled
insight into issues occurring within your production applications, in realtime.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crashlog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crashlog

## Configuration

### Basic:

```ruby
CrashLog.configuration do |config|
  config.api_key  = "Your API Key"
  config.secret   = "Project Project ID"
end
```

### Advanced

See [configuration.rb](/crashlog/crashlog/blob/master/lib/crash_log/configuration.rb)
for available options.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

- Ivan Vanderbyl
- Mark Wolfe
