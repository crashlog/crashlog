#!/usr/bin/env rake
require 'rubygems'
require 'bundler/setup'
require "bundler/gem_tasks"

require File.expand_path("../lib/crash_log", __FILE__)

require 'rake'
require "rspec/core/rake_task"

require 'appraisal'

desc "Run all examples"
RSpec::Core::RakeTask.new

task :default => :spec
