require 'devise_imapable/strategy'

module Devise
  module Models
    # Imapable Module, responsible for validating the user credentials via an imap server.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module Imapable
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
      def valid_imap_authentication?(password)
        Devise::ImapAdapter.valid_credentials?(self.email, password)
      end

      module ClassMethods
        # Authenticate a user based on configured attribute keys. Returns the
        # authenticated user if it's valid or nil.
        def authenticate_with_imap(attributes={})
          return unless attributes[:email].present?
          conditions = attributes.slice(:email)

          unless conditions[:email] && conditions[:email].include?('@') && Devise.default_email_suffix
            conditions[:email] = "#{conditions[:email]}@#{Devise.default_email_suffix}"
          end

          resource = find_for_imap_authentication(conditions) || new(conditions)

          if resource.try(:valid_imap_authentication?, attributes[:password])
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
        def find_for_imap_authentication(conditions)
          find(:first, :conditions => conditions)
        end
      end
    end
  end
end
