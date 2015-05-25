# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise_ldap_authenticatable/version"

Gem::Specification.new do |s|
  s.name     = 'devise_ldap_authenticatable'
  s.version  = DeviseLdapAuthenticatable::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary  = 'Devise extension to allow authentication via LDAP'
  s.email = 'curtis.schiewek@gmail.com'
  s.homepage = 'https://github.com/cschiewek/devise_ldap_authenticatable'
  s.description = s.summary
  s.authors = ['Curtis Schiewek', 'Daniel McNevin', 'Steven Xu']
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('devise', '>= 3.4.1')
  s.add_dependency('net-ldap', '>= 0.6.0', '<= 0.11')

  s.add_development_dependency('rake', '>= 0.9')
  s.add_development_dependency('rdoc', '>= 3')
  s.add_development_dependency('rails', '>= 4.0')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('factory_girl_rails', '~> 1.0')
  s.add_development_dependency('factory_girl', '~> 2.0')
  s.add_development_dependency('rspec-rails')

  %w{database_cleaner capybara launchy}.each do |dep|
    s.add_development_dependency(dep)
  end
end
