ENV["RAILS_ENV"] = "test"

require File.expand_path("rails_app/config/environment.rb",  File.dirname(__FILE__))
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl' # not sure why this is not already required

# Rails 4.1 and RSpec are a bit on different pages on who should run migrations
# on the test db and when.
#
# https://github.com/rspec/rspec-rails/issues/936
if defined?(ActiveRecord::Migration) && ActiveRecord::Migration.respond_to?(:maintain_test_schema!)
  ActiveRecord::Migration.maintain_test_schema!
end

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
end

def ldap_root
  File.expand_path('ldap', File.dirname(__FILE__))
end

def ldap_connect_string
  if ENV["LDAP_SSL"]
    "-x -H ldaps://localhost:3389 -D 'cn=admin,dc=test,dc=com' -w secret"
  else
    "-x -h localhost -p 3389 -D 'cn=admin,dc=test,dc=com' -w secret"
  end
end

def reset_ldap_server!
  if ENV["LDAP_SSL"]
    `ldapmodify #{ldap_connect_string} -f #{File.join(ldap_root, 'clear.ldif')}`
    `ldapadd #{ldap_connect_string} -f #{File.join(ldap_root, 'base.ldif')}`
  else
    `ldapmodify #{ldap_connect_string} -f #{File.join(ldap_root, 'clear.ldif')}`
    `ldapadd #{ldap_connect_string} -f #{File.join(ldap_root, 'base.ldif')}`
  end
end

def default_devise_settings!
  ::Devise.ldap_logger = true
  ::Devise.ldap_create_user = false
  ::Devise.ldap_update_password = true
  ::Devise.ldap_config = "#{Rails.root}/config/#{"ssl_" if ENV["LDAP_SSL"]}ldap.yml"
  ::Devise.ldap_check_group_membership = false
  ::Devise.ldap_check_attributes = false
  ::Devise.ldap_auth_username_builder = Proc.new() {|attribute, login, ldap| "#{attribute}=#{login},#{ldap.base}" }
  ::Devise.authentication_keys = [:email]
end
