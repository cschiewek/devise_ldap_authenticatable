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
          # self.password_salt = self.class.encryptor_class.salt
          # self.encrypted_password = password_digest(@password)
          Devise::LdapAdapter.update_password(self.email, password) if ::Devise.ldap_update_password
          # self.encrypted_password = @password
        end
      end

      # Set password to nil
      def clean_up_passwords
       # self.password = nil
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
