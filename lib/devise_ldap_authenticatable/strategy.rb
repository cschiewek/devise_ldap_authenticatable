require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        resource = mapping.to.find_for_ldap_authentication(authentication_hash.merge(password: password))

        # resource exists in database
        if resource.persisted?
          if validate(resource) { resource.valid_ldap_authentication?(password) }
            remember_me(resource)
            resource.after_ldap_authentication
            success!(resource)
          else
            return fail(:invalid) # Invalid credentials
          end
        end

        # resource does not exist in database
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
