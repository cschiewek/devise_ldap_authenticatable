require 'net/ldap'

module Devise

  # simple adapter for ldap credential checking
  # ::Devise.ldap_host
  module LdapAdapter

    def self.valid_credentials?(login, password)
      debugger
      ldap = Net::LDAP.new( :host => ::Devise.ldap_host, :port => ::Devise.ldap_port )
      if ldap.bind( :method => :simple, :username => login, :password => password )
        true
      else
        false
      end
    end

  end
  
end