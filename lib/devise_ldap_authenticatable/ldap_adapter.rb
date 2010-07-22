require 'net/ldap'

module Devise

  # simple adapter for ldap credential checking
  # ::Devise.ldap_host
  module LdapAdapter

    def self.valid_credentials?(login, attributes, password)
      debugger
      login = [::Devise.ldap_login_attribute+'='+login, attributes,::Devise.ldap_base_dn].join(',')      
      @encryption = ::Devise.ldap_ssl ? :simple_tls : nil
      ldap = Net::LDAP.new(:encryption => @encryption)
      ldap.host = ::Devise.ldap_host
      ldap.port = ::Devise.ldap_port
      ldap.auth login, password
      if ldap.bind
        true
      else
        errors.add_to_base(ldap.get_operation_result.message)
        false
      end
    end

  end

end