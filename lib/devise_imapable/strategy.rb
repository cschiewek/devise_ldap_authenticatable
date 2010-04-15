require 'devise/strategies/base'

module Devise
  module Strategies
    # Strategy for signing in a user based on his email and password using imap.
    # Redirects to sign_in page if it's not authenticated
    class Imapable < Base
      def valid?
        valid_controller? && valid_params? && mapping.to.respond_to?(:authenticate_with_imap)
      end

      # Authenticate a user based on email and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if resource = mapping.to.authenticate_with_imap(params[scope])
          success!(resource)
        else
          fail(:invalid)
        end
      end

      protected

        def valid_controller?
          params[:controller] == 'sessions'
        end

        def valid_params?
          params[scope] && params[scope][:password].present?
        end
    end
  end
end

Warden::Strategies.add(:imapable, Devise::Strategies::Imapable)
