require 'devise_ldap_authenticatable/strategy'

module Devise
  module Models
    # LDAP Module, responsible for validating the user credentials via LDAP.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module LdapAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :current_password, :password
        attr_accessor :password_confirmation
      end

      def login_with
        @login_with ||= Devise.mappings[self.class.to_s.downcase.to_sym].to.authentication_keys.first
        self[@login_with]
      end
      
      def reset_password!(new_password, new_password_confirmation)
        if new_password == new_password_confirmation && ::Devise.ldap_update_password
          Devise::LdapAdapter.update_password(login_with, new_password)
        end
        clear_reset_password_token if valid?
        save
      end

      def password=(new_password)
        @password = new_password
      end

      # Checks if a resource is valid upon authentication.
      def valid_ldap_authentication?(password)
        if Devise::LdapAdapter.valid_credentials?(login_with, password)
          return true
        else
          return false
        end
      end
      
      def ldap_groups
        Devise::LdapAdapter.get_groups(login_with)
      end
      
      def ldap_dn
        Devise::LdapAdapter.get_dn(login_with)
      end

      def ldap_get_param(login_with, param)
        Devise::LdapAdapter.get_ldap_param(login_with,param)
      end


      module ClassMethods
        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_ldap(attributes={}) 
          auth_key = self.authentication_keys.first
          return nil unless attributes[auth_key].present? 

          # resource = find_for_ldap_authentication(conditions)
          resource = where(auth_key => attributes[auth_key]).first
                    
          if (resource.blank? and ::Devise.ldap_create_user)
            resource = new
            resource[auth_key] = attributes[auth_key]
            resource.password = attributes[:password]
          end
                    
          if resource.try(:valid_ldap_authentication?, attributes[:password])
            resource.save if resource.new_record?
            return resource
          else
            return nil
          end
        end
        
        def update_with_password(resource)
          puts "UPDATE_WITH_PASSWORD: #{resource.inspect}"
        end
        
      end
    end
  end
end
