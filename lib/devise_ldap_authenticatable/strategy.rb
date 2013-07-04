require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        resource = valid_password? && mapping.to.authenticate_with_ldap(authentication_hash.merge(password: password))
        return fail(:invalid) unless resource

        if validate(resource)
          success!(resource)
        end
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)