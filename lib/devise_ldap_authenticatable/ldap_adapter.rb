require 'net/ldap'

module Devise

  # simple adapter for ldap credential checking
  # ::Devise.ldap_host
  module LdapAdapter
    
    def self.valid_credentials?(login, password_plaintext)
      resource = LdapConnect.new
      ldap = resource.ldap
      
      user_dn = "#{resource.attribute}=#{login},#{ldap.base}"
      
      ## Check login
      ldap.auth user_dn, password_plaintext
      
      if ::Devise.ldap_check_group_membership
        return (ldap.bind && resource.in_required_groups?(user_dn)) 
      else
        return ldap.bind
      end
      
    end
    
    def self.update_password(login, plaintext_password)
      resource = LdapConnect.new
      resource.update_ldap(login, :userpassword => Net::LDAP::Password.generate(:sha, plaintext_password)) if plaintext_password.present? 
    end

    class LdapConnect

      attr_reader :ldap, :base, :attribute, :required_groups

      def initialize(params = {})
        ldap_config = YAML.load_file(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")[Rails.env]
        ldap_options = params
        ldap_options[:encryption] = :simple_tls if ldap_config["ssl"]

        @ldap = Net::LDAP.new(ldap_options)
        @ldap.host = ldap_config["host"]
        @ldap.port = ldap_config["port"]
        @ldap.base = ldap_config["user_base"]
        @attribute = ldap_config["attribute"]
        @required_groups = ldap_config["required_groups"]
        @group_base = ldap_config["group_base"]
        @ldap.auth ldap_config["admin_user"], ldap_config["admin_password"] if params[:admin] 
      end

      def dn(login)
        "#{@attribute}=#{login},#{@ldap.base}"
      end

      def in_required_groups?(user_dn)
        ## login as admin to check for groups
        ldap = LdapConnect.new(:admin => true).ldap
        
        if ldap.bind
          for group in @required_groups
            ldap.search(:filter => group, :base => @group_base) do |entry|
              return true if entry.uniqueMember.include? user_dn
            end
          end
        end
        
        return false
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
        
        ## FIXME exception checking
        ldap.bind
        
        ldap.modify(:dn => dn(login), :operations => operations)
      end
      
      # ## This is for testing, It will clear all users out of the LDAP database. Useful to put in before hooks in rspec, cucumber, etc..
      # def clear_users!(base = @ldap.base)
      #   raise "You should ONLY do this on the test enviornment! It will clear out all of the users in the LDAP server" if Rails.env != "test"
      #   if @ldap.bind
      #     @ldap.search(:filter => "#{@attribute}=*", :base => base) do |entry|
      #       @ldap.delete(:dn => entry.dn)
      #     end
      #   end
      # end

    end

  end

end