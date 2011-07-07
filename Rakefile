require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the devise_imapable plugin.'
Rake::TestTask.new(:test) do |t|
  # t.libs << 'lib'
  # t.libs << 'test'
  # t.pattern = 'test/**/*_test.rb'
  # t.verbose = true
  puts <<-eof

*** NOTICE ***

All tests are done in the sample Rails app. 

Please go to test/rails_app and run the tests there. 

Make sure to bundle install and rake db:migrate

  eof
end

desc 'Generate documentation for the devise_ldap_authenticatable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DeviseLDAPAuthenticatable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "devise_ldap_authenticatable"
    gemspec.summary = "LDAP authentication module for Devise"
    gemspec.description = "LDAP authentication module for Devise"
    gemspec.email = "curtis.schiewek@gmail.com"
    gemspec.homepage = "http://github.com/cschiewek/devise_ldap_authenticatable"
    gemspec.authors = ["Curtis Schiewek", "Daniel McNevin"]
    gemspec.add_runtime_dependency "devise", "~> 1.4.0"
    gemspec.add_runtime_dependency "net-ldap", "~> 0.2.2"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
