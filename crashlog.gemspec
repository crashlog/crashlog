# -*- encoding: utf-8 -*-
require File.expand_path('../lib/crash_log/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ivan Vanderbyl"]
  gem.email         = ["ivanvanderbyl@me.com"]
  gem.description   = %q{CrashLog Exception reporter}
  gem.summary       = %q{CrashLog is an exception handler for production applications}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "crashlog"
  gem.require_paths = ["lib"]
  gem.version       = CrashLog::VERSION
end
