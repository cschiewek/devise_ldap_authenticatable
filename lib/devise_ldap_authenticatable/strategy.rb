require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user based on his login and password using LDAP.
    # Redirects to sign_in page if it's not authenticated
    class LdapAuthenticatable < Authenticatable
      def valid?
        valid_controller? && valid_params? && mapping.to.respond_to?(:authenticate_with_ldap)
      end

      # Authenticate a user based on login and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if resource = mapping.to.authenticate_with_ldap(params[scope])
          success!(resource)
        else
          fail(:invalid)
        end
      end

      protected

        def valid_controller?
          params[:controller] == 'devise/sessions'
        end

        def valid_params?
          params[scope] && params[scope][:password].present?
        end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)