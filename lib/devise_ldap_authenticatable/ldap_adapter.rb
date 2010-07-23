require "net/ldap"

module Devise

  module LdapAdapter
    
    def self.valid_credentials?(login, password_plaintext)
      resource = LdapConnect.new(:login => login, :password => password_plaintext)
      resource.authorized?
    end
    
    def self.update_password(login, new_password)
      resource = LdapConnect.new(:login => login, :new_password => new_password)
      resource.change_password! if new_password.present? 
    end
    
    def self.get_groups(login)
      ldap = LdapConnect.new(:login => login)
      ldap.user_groups
    end

    class LdapConnect

      attr_reader :ldap, :login #, :base, :attribute, :required_groups, :login, :password, :new_password

      def initialize(params = {})
        ldap_config = YAML.load_file(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")[Rails.env]
        ldap_options[:encryption] = :simple_tls if ldap_config["ssl"]

        @ldap = Net::LDAP.new # (ldap_options)
        @ldap.host = ldap_config["host"]
        @ldap.port = ldap_config["port"]
        @ldap.base = ldap_config["base"]
        @attribute = ldap_config["attribute"]
        
        @group_base = ldap_config["group_base"]
        @required_groups = ldap_config["required_groups"]        
        @required_attributes = ldap_config["require_attribute"]
        
        @ldap.auth ldap_config["admin_user"], ldap_config["admin_password"] if params[:admin] 
        
        @login = params[:login]
        @password = params[:password]
        @new_password = params[:new_password]
      end

      def dn
        DeviseLdapAuthenticatable::Logger.send("LDAP search: #{@attribute}=#{@login}")
        filter = Net::LDAP::Filter.eq(@attribute.to_s, @login.to_s)
        ldap_entry = nil
        @ldap.search(:filter => filter) {|entry| ldap_entry = entry}
        if ldap_entry.nil?
          "#{@attribute}=#{@login},#{@ldap.base}"
        else
          ldap_entry.dn
        end
      end

      def authenticate!
        @ldap.auth(dn, @password)
        @ldap.bind
      end

      def authenticated?
        authenticate!
      end
      
      def authorized?
        DeviseLdapAuthenticatable::Logger.send("Authorizing user #{dn}")
        authenticated? && in_required_groups? && has_required_attribute?
      end
      
      def change_password!
        update_ldap(:userpassword => Net::LDAP::Password.generate(:sha, @new_password))
      end

      def in_required_groups?     
        return true unless ::Devise.ldap_check_group_membership
        
        ## FIXME set errors here, the ldap.yml isn't set properly.
        return false if @required_groups.nil?   
           
        admin_ldap = LdapConnect.admin
                
        for group in @required_groups
          admin_ldap.search(:base => group, :scope => Net::LDAP::SearchScope_BaseObject) do |entry|
            unless entry.uniqueMember.include? dn
              DeviseLdapAuthenticatable::Logger.send("User #{dn} is not in group: #{group}")
              return false
            end
          end
        end
        
        return true
      end
      
      def has_required_attribute?
        return true unless ::Devise.ldap_check_attributes
        
        admin_ldap = LdapConnect.admin
        
        user = find_ldap_user(admin_ldap)
                
        @required_attributes.each do |key,val|
          unless user[key].include? val
            DeviseLdapAuthenticatable::Logger.send("User #{dn} did not match attribute #{key}:#{val}")
            return false 
          end
        end
        
        return true
      end
      
      def user_groups
        admin_ldap = LdapConnect.admin
        
        DeviseLdapAuthenticatable::Logger.send("Getting groups for #{dn}")
        filter = Net::LDAP::Filter.eq("uniqueMember", dn)
        admin_ldap.search(:filter => filter, :base => @group_base).collect(&:dn)
      end
      
      private
      
      def self.admin
        ldap = LdapConnect.new(:admin => true).ldap
        
        unless ldap.bind
          DeviseLdapAuthenticatable::Logger.send("Cannot bind to admin LDAP user")
          raise DeviseLdapAuthenticatable::LdapException, "Cannot connect to admin LDAP user"
        end
        
        return ldap
      end
      
      def find_ldap_user(ldap)
        DeviseLdapAuthenticatable::Logger.send("Finding user: #{dn}")
        ldap.search(:base => dn, :scope => Net::LDAP::SearchScope_BaseObject).try(:first)
      end
      
      def update_ldap(ops)
        operations = []
        if ops.is_a? Hash
          ops.each do |key,value|
            operations << [:replace,key,value]
          end
        elsif ops.is_a? Array
          operations = ops
        end

        admin_ldap = LdapConnect.admin
        
        DeviseLdapAuthenticatable::Logger.send("Modifying user #{dn}")
        admin_ldap.modify(:dn => dn, :operations => operations)
      end

    end

  end

end
