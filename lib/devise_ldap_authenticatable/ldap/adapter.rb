require "net/ldap"

module Devise
  module LDAP
    DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY = 'uniqueMember'
    
    module Adapter
      def self.valid_credentials?(login, password_plaintext)
        options = {:login => login,
                   :password => password_plaintext,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :bind_user => ::Devise.ldap_user_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.authorized?
      end

      def self.update_password(login, new_password)
        options = {:login => login,
                   :new_password => new_password,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :bind_user => ::Devise.ldap_user_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.change_password! if new_password.present?
      end

      def self.update_own_password(login, new_password, current_password)
        set_ldap_param(login, :userpassword, Net::LDAP::Password.generate(:sha, new_password), current_password)
      end

      def self.ldap_connect(login, password = nil)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :password => password,
                   :bind_user => ::Devise.ldap_user_to_bind}

        resource = Devise::LDAP::Connection.new(options)
      end

      def self.valid_login?(login)
        self.ldap_connect(login).valid_login?
      end

      def self.get_groups(login)
        self.ldap_connect(login).user_groups
      end

      def self.in_ldap_group?(login, group_name, group_attribute = nil)
        self.ldap_connect(login).in_group?(group_name, group_attribute)
      end

      def self.get_dn(login)
        self.ldap_connect(login).dn
      end

      def self.set_ldap_param(login, param, new_value, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password,
                    :bind_user => ::Devise.ldap_user_to_bind }

        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(param, new_value)
      end

      def self.delete_ldap_param(login, param, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password,
                    :bind_user => ::Devise.ldap_user_to_bind }

        resource = Devise::LDAP::Connection.new(options)
        resource.delete_param(param)
      end

      def self.get_ldap_param(login,param, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password,
                    :bind_user => ::Devise.ldap_user_to_bind }

        resource = Devise::LDAP::Connection.new(options)
        resource.ldap_param_value(param)
      end

      def self.get_ldap_entry(login)
        self.ldap_connect(login).search_for_login
      end

    end

  end

end
