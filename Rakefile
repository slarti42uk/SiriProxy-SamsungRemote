# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "SiriProxy-SamsungRemote"
  gem.homepage = "http://github.com/slarti42uk/SiriProxy-SamsungRemote"
  gem.license = "MIT"
  gem.summary = %Q{Port of the Perl version of the Samsung iPhone Protocol wrapped as a SiriProxy plugin}
  gem.description = %Q{Bringing together the work of plamoni on the SiriProxy and pjnewman's iPhone Protocol Decoded (SamyGo forum), this plugin is intended to allow the use of Siri to control my Samsung LE40C650 and hopefully other Samsung smart TV's}
  gem.email = "steve@codebed.com"
  gem.authors = ["Steve Kingsley"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "SiriProxy-SamsungRemote #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
