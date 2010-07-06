require 'net/ldap'

module Devise

  # simple adapter for ldap credential checking
  # ::Devise.ldap_host
  module LdapAdapter
    
    def self.valid_credentials?(login, password_plaintext)
      resource = LdapConnect.new
      ldap = resource.ldap
      ldap.auth "#{resource.attribute}=#{login},#{ldap.base}", password_plaintext
      ldap.bind # will return false if authentication is NOT successful
    end
    
    def self.update_password(login, plaintext_password)
      resource = LdapConnect.new
      resource.update_ldap(login, :userpassword => Net::LDAP::Password.generate(:sha, plaintext_password)) if plaintext_password.present? 
    end

    class LdapConnect

      attr_reader :ldap, :base, :attribute

      def initialize(params = {})
        ldap_config = YAML.load_file(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")[Rails.env]
        ldap_options = params
        ldap_options[:encryption] = :simple_tls if ldap_config["ssl"]

        @ldap = Net::LDAP.new(ldap_options)
        @ldap.host = ldap_config["host"]
        @ldap.port = ldap_config["port"]
        @ldap.base = ldap_config["base"]
        @attribute = ldap_config["attribute"]
        @ldap.auth ldap_config["admin_user"], ldap_config["admin_password"] if params[:admin] 
      end

      def dn(login)
        "#{@attribute}=#{login},#{@ldap.base}"
      end

      def update_ldap(login,ops)
        operations = []
        if ops.is_a? Hash
          ops.each do |key,value|
            operations << [:replace,key,value]
          end
        elsif ops.is_a? Array
          operations = ops
        end

        ldap = LdapConnect.new(:admin => true).ldap
        ldap.bind
        
        ldap.modify(:dn => dn(login), :operations => operations)
      end
      
      ## This is for testing, It will clear all users out of the LDAP database. Useful to put in before hooks in rspec, cucumber, etc..
      def clear_users!(base = @ldap.base)
        raise "You should ONLY do this on the test enviornment! It will clear out all of the users in the LDAP server" if Rails.env != "test"
        if @ldap.bind
          @ldap.search(:filter => "#{@attribute}=*", :base => base) do |entry|
            @ldap.delete(:dn => entry.dn)
          end
        end
      end

    end

  end

end