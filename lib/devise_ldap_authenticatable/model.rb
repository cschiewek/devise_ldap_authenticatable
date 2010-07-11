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
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      def password=(new_password)
        @password = new_password
        
        if @password.present?
          Devise::LdapAdapter.update_password(self.email, password) if ::Devise.ldap_update_password
        end
      end

      def clean_up_passwords
       # self.password = nil
      end

      # Checks if a resource is valid upon authentication.
      def valid_ldap_authentication?(password)
        if Devise::LdapAdapter.valid_credentials?(self.email, password)
          ## TODO set the groups from ldap
          # self.ldap_groups = 
          ## TODO set the authorization roles from ldap
          # self.authorizations =
          return true
        else
          return false
        end
      end
      
      def ldap_groups
         Devise::LdapAdapter.get_groups(self.email)
      end

      module ClassMethods
        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_ldap(attributes={})
          return unless attributes[:email].present? 
          conditions = attributes.slice(:email)

          unless conditions[:email]
            conditions[:email] = "#{conditions[:email]}"
          end

          resource = find_for_ldap_authentication(conditions)
          
          if (resource.blank? and ::Devise.ldap_create_user)
            resource = new(conditions.merge({:password => attributes[:password]}))
          end
           
          if resource.try(:valid_ldap_authentication?, attributes[:password])
            resource.new_record? ? resource.save : resource
          else
            nil
          end

        end

        protected

        def find_for_ldap_authentication(conditions)
          scoped.where(conditions).first
        end
        
      end
    end
  end
end
