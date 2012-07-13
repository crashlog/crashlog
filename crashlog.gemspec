# -*- encoding: utf-8 -*-
require File.expand_path('../lib/crash_log/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["TestPilot CI"]
  gem.email         = ["support@crashlog.io"]
  gem.description   = %q{CrashLog Exception reporter}
  gem.summary       = %q{CrashLog is an exception handler for production applications}
  gem.homepage      = "http://crashlog.io"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "crashlog"
  gem.require_paths = ["lib"]
  gem.version       = CrashLog::VERSION
  gem.platform      = Gem::Platform::RUBY

  gem.add_dependency("activesupport")
  gem.add_dependency("faraday")
  gem.add_dependency("json", "> 1.6.0")
  gem.add_dependency("rabl", '>= 0.6.14')

end
