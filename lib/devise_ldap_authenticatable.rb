# encoding: utf-8
require 'devise'

require 'devise_ldap_authenticatable/schema'
require 'devise_ldap_authenticatable/ldap_adapter'
require 'devise_ldap_authenticatable/routes'

module Devise
  # host
  mattr_accessor :ldap_host
  @@ldap_host = nil

  # port
  mattr_accessor :ldap_port
  @@ldap_port = nil
  
  # Use SSL
  mattr_accessor :ldap_ssl
  @@ldap_ssl = false
  
  # Add valid users to database
  mattr_accessor :ldap_create_user
  @ldap_create_user = false
end

# Add ldap_authenticatable strategy to defaults.
#
Devise.add_module(:ldap_authenticatable,
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_ldap_authenticatable/model')
