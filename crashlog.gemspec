# -*- encoding: utf-8 -*-
require File.expand_path('../lib/crash_log/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ivan Vanderbyl"]
  gem.email         = ["support@crashlog.io"]
  gem.description   = %q{CrashLog Exception reporter}
  gem.summary       = %q{CrashLog is an exception handler for ambitious applications}
  gem.homepage      = "http://crashlog.io"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "crashlog"
  gem.require_paths = ["lib"]
  gem.version       = CrashLog::VERSION

  gem.add_dependency("faraday",       '~> 0.8.4')
  gem.add_dependency("multi_json",    '>= 1.1.0')
  gem.add_dependency("crashlog-auth-hmac", '>= 1.1.7')
  gem.add_dependency("rabl",          '>= 0.6.13')
  gem.add_dependency("uuid")
  gem.add_dependency("hashr")
  gem.add_dependency("json")
end
