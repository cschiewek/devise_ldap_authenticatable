require File.expand_path("../lib/devise_ldap_authenticatable/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "devise_ldap_authenticatable"
  s.version     = DeviseLdapAuthenticatable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel McNevin", "Curtis Schiewek" ]
  s.email       = ["dpmcnevin@gmail.com"]
  s.homepage    = "http://github.com/cschiewek/devise_ldap_authenticatable/tree/rails3"
  s.summary     = "LDAP Authentication for Devise"
  s.description = "LDAP Authentication for Devise"

  s.required_rubygems_version = ">= 1.3.6"

  s.rubyforge_project         = "devise_ldap_authenticatable"

  # If you have other dependencies, add them here
  s.add_dependency "devise", "~> 1.1.rc2"
  s.add_dependency "ruby-net-ldap", "~> 0.0.4"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

end
