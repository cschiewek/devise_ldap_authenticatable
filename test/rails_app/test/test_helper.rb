ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  
  def ldap_connect_string
    if ENV["LDAP_SSL"]
      "-x -H ldaps://localhost:3389 -D 'cn=admin,dc=test,dc=com' -w secret"
    else
      "-x -h localhost -p 3389 -D 'cn=admin,dc=test,dc=com' -w secret"
    end
  end
  
  def reset_ldap_server!
    if ENV["LDAP_SSL"]
      `ldapmodify #{ldap_connect_string} -f ../ldap/clear.ldif`
      `ldapadd #{ldap_connect_string} -f ../ldap/base.ldif`
    else
      `ldapmodify #{ldap_connect_string} -f ../ldap/clear.ldif`
      `ldapadd #{ldap_connect_string} -f ../ldap/base.ldif`
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
  
end
