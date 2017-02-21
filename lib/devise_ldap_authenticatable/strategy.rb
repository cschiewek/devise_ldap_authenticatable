require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      # Tests whether the returned resource exists in the database and the
      # credentials are valid.  If the resource is in the database and the credentials
      # are valid, the user is authenticated.  Otherwise failure messages are returned
      # indicating whether the resource is not found in the database or the credentials
      # are invalid.
      def authenticate!
        resource = mapping.to.find_for_ldap_authentication(authentication_hash.merge(password: password))

        return fail(:invalid) unless resource

        if resource.persisted?
          if validate(resource) { resource.valid_ldap_authentication?(password) }
            remember_me(resource)
            resource.after_ldap_authentication
            success!(resource)
          else
            return fail(:invalid) # Invalid credentials
          end
        end

        if resource.new_record?
          if validate(resource) { resource.valid_ldap_authentication?(password) }
            return fail(:not_found_in_database) # Valid credentials
          else
            return fail(:invalid) # Invalid credentials
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
