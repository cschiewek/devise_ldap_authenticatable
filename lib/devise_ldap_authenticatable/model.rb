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
      def self.included(base)
        base.class_eval do
          extend ClassMethods

          attr_accessor :password
        end
      end

      # Set password to nil
      def clean_up_passwords
        self.password = nil
      end

      # Checks if a resource is valid upon authentication.
      def valid_ldap_authentication?(password)
        Devise::LdapAdapter.valid_credentials?(self.email, password)
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
          resource = new(conditions) if (resource.nil? and ::Devise.ldap_create_user)
           
          if resource.try(:valid_ldap_authentication?, attributes[:password])
             resource.new_record? ? create(conditions) : resource
          end
        end

      protected

        # Find first record based on conditions given (ie by the sign in form).
        # Overwrite to add customized conditions, create a join, or maybe use a
        # namedscope to filter records while authenticating.
        # Example:
        #
        #   def self.find_for_imap_authentication(conditions={})
        #     conditions[:active] = true
        #     find(:first, :conditions => conditions)
        #   end
        #
        def find_for_ldap_authentication(conditions)
          # find(:first, :conditions => conditions)
          ## Rails 3 query language since find(:first) will be deprecated
          scoped.where(conditions).first
        end
      end
    end
  end
end
