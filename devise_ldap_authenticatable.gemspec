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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('devise', '>= 2.0.0')
  s.add_dependency('net-ldap', '~> 0.2.2')
end