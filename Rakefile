require File.expand_path('spec/rails_app/config/environment', File.dirname(__FILE__))
require 'rdoc/task'

desc 'Default: run test suite.'
task :default => :spec

desc 'Generate documentation for the devise_ldap_authenticatable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DeviseLDAPAuthenticatable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RailsApp::Application.load_tasks
