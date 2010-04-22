require 'net/ldap'

module Devise

  # simple adapter for ldap credential checking
  # ::Devise.ldap_host
  module LdapAdapter

    def self.valid_credentials?(login, password)
      debugger
      #ldap = Net::LDAP.new( :host => ::Devise.ldap_host, :port => ::Devise.ldap_port )
      #if ldap.bind( :method => :simple, :username => login, :password => password )
      #  true
      #else
      #  false
      #end
      ldap = Net::LDAP.new
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