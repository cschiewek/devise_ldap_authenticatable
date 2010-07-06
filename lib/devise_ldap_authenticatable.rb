# encoding: utf-8
require 'devise'

require 'devise_ldap_authenticatable/schema'
require 'devise_ldap_authenticatable/ldap_adapter'
require 'devise_ldap_authenticatable/routes'

# Get ldap information from config/ldap.yml now
module Devise
  # Add valid users to database
  mattr_accessor :ldap_create_user
  @@ldap_create_user = false
  
  mattr_accessor :ldap_config
  # @@ldap_config = "#{Rails.root}/config/ldap.yml"
  
  mattr_accessor :ldap_update_password
  @@ldap_update_password = true
end

# Add ldap_authenticatable strategy to defaults.
#
Devise.add_module(:ldap_authenticatable,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_ldap_authenticatable/model')
