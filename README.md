# Whenner [![Build Status](https://secure.travis-ci.org/avdgaag/whenner.png?branch=master)](http://travis-ci.org/avdgaag/whenner)

## Introduction

A promise represents the eventual result of an asynchronous operation. The
primary way of interacting with a promise is through its `done` and `fail`
methods, which registers callbacks to receive either a promise’s eventual value
or the reason why the promise cannot be fulfilled.

## Installation

Whenner is distributed as a Ruby gem, which should be installed on most Macs and
Linux systems. Once you have ensured you have a working installation of Ruby
and Ruby gems, install the gem as follows from the command line:

    $ gem install whenner

## Usage

Whenner provides two basic methods to use deferreds:

* `Whenner.defer` to create a new deferred object and return its promise. In the
  block to the method you can fulfill or reject the deferred.
* `Whenner.when` to convert one or more arguments into promises, combining them
  into a single new promise that you can attach callbacks to.

Deferred objects can give you a promise that, at some point in the future, will
resolve to either a fulfilled or rejected state. When that happens, appropriate
callbacks are called. You can attach such callbacks on a deferred or promise
using three methods:

* `done` to register blocks to be called when the promise is fulfilled;
* `fail` to register blocks to be called when the promise is rejected;
* `always` to register blocks to be called when the promise is resolved (either
  fulfilled or rejected);

Here's an example of making three asynchronous HTTP requests, waiting for them
all to finish and acting on their results:

```ruby
$:.unshift File.expand_path('../lib', __FILE__)
require 'whenner'
require 'uri'
require 'net/http'

include Whenner

def async_get(uri)
  defer do |f|
    thread = Thread.new do
      response = Net::HTTP.get_response(URI(uri))
      if response.code =~ /^2/
        f.fulfill response.body
      else
        f.reject response.message
      end
    end
    at_exit { thread.join }
  end
end

cnn     = async_get('http://edition.cnn.com')
nytimes = async_get('http://www.nytimes.com')
google  = async_get('http://www.google.nl')

Whenner.when(cnn, google, nytimes).done do |results|
  results.map { |str| str[/<title>(.+)<\/title>/, 1] }
end.done do |titles|
  puts "Success: #{titles.inspect}"
end
```

As methods in Ruby can only take a single block, Whenner has a special block
syntax for setting both `done` and `fail` callbacks:

```ruby
defer { async_get('http://google.com') }.then do |on|
  on.done { puts 'Success!' }
  on.fail { puts 'Success!' }
end
```

The result of `Deferred#then` is a new promise for the value of the callback
that will be run.

### Documentation

See the inline [API
docs](http://rubydoc.info/github/avdgaag/whenner/master/frames) for more
information.

## Other

### Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version
   unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have
   your own version, that is fine but bump version in a commit by itself I can
   ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

### Issues

Please report any issues, defects or suggestions in the [Github issue
tracker](https://github.com/avdgaag/whenner/issues).

### What has changed?

See the [HISTORY](https://github.com/avdgaag/whenner/blob/master/HISTORY.md) file
for a detailed changelog.

### Credits

Created by: Arjan van der Gaag  
URL: [http://arjanvandergaag.nl](http://arjanvandergaag.nl)  
Project homepage: [http://avdgaag.github.com/whenner](http://avdgaag.github.com/whenner)  
Date: april 2012  
License: [MIT-license](https://github.com/avdgaag/whenner/blob/master/LICENSE) (same as Ruby)
