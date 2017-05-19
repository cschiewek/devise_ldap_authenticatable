require "net/ldap"

module Devise
  module LDAP
    DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY = 'uniqueMember'
    DEFAULT_MAIL_GROUP_UNIQUE_MEMBER_LIST_KEY = 'mailLocalAddress'
    DEFAULT_USER_UNIQUE_LIST_KEY = 'uid'
    DEFAULT_GROUP_UNIQUE_LIST_KEY = 'cn'

    module Adapter
      def self.valid_credentials?(login, password_plaintext)
        options = {:login => login,
                   :password => password_plaintext,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)

        if !resource.customer_auth? && resource.login_is_mail?
          return false unless login.include?("@#{resource.email_auth_domain}")
        end
        resource.authorized?
      end

      def self.ldap_connection?(login)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        if !resource.customer_auth? && resource.login_is_mail?
          return false unless login.include?("@#{resource.email_auth_domain}")
        end
        true
      end

      def self.create_user(login, user, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, user, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr[:objectclass] = object_classes
        resource.create_user(attr.symbolize_keys!, attribute_list_key)
      end

      def self.delete_user(login, username, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_user(username, attribute_list_key)
      end

      def self.update_attributes(login, user, attribute_mappings = nil)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        mapper = Devise::LDAP::AttributeMapper.new(:only_changed, user, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          resource.set_param(mapper.get_ldap_attribute(key.to_sym), value) unless key.nil?
        end
      end

      def self.update_password(login, new_password)
        options = {:login => login,
                   :new_password => new_password,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}

        resource = Devise::LDAP::Connection.new(options)
        resource.change_password! if new_password.present?
      end

      def self.create_group(login, group, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, group, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr.symbolize_keys!
        grp = attr[attribute_list_key.to_sym]
        attr.delete attribute_list_key.to_sym
        attr[:objectclass] = object_classes
        resource.create_group(grp, attr, attribute_list_key)
      end

      def self.delete_group(login, group, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_group(group, attribute_list_key)
      end

      def self.create_app_group(login, group, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, group, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr.symbolize_keys!
        grp = attr[attribute_list_key.to_sym]
        attr.delete attribute_list_key.to_sym
        attr[:objectclass] = object_classes
        resource.create_app_group(grp, attr, attribute_list_key)
      end

      def self.delete_app_group(login, group, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_app_group(group, attribute_list_key)
      end

      def self.create_mailbox(login, mailbox, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, mailbox, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr.symbolize_keys!
        mail = attr[attribute_list_key.to_sym]
        attr.delete attribute_list_key.to_sym
        attr[:objectclass] = object_classes
        resource.create_mailbox(mail, attr, attribute_list_key)
      end

      def self.delete_mailbox(login, mail, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_mailbox(mail, attribute_list_key)
      end

      def self.create_mail_alias(login, local_address, routing_address, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, local_address, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr.symbolize_keys!
        mail = attr[attribute_list_key.to_sym]
        attr.delete attribute_list_key.to_sym
        attr[:mailroutingaddress] = routing_address
        attr[:objectclass] = object_classes
        resource.create_mail_alias(mail, attr, attribute_list_key)
      end

      def self.delete_mail_alias(login, mail_alias, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_mail_alias(mail_alias, attribute_list_key)
      end

      def self.update_mail_alias(login, local_address, routing_address, attr = nil)
        self.ldap_connect(login).update_mail_alias(local_address, routing_address, attr)
      end

      def self.get_mail_aliases(login)
        self.ldap_connect(login).all_mail_aliases
      end

      def self.create_mail_domain(login, domain, object_classes, attribute_mappings, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        attr = Hash.new
        mapper = Devise::LDAP::AttributeMapper.new(:new, domain, attribute_mappings)
        attributes = mapper.get_attributes
        attributes.each do |key, value|
          attr[mapper.get_ldap_attribute(key.to_sym)] = value.to_s unless key.nil? || !value.present?
        end
        attr.symbolize_keys!
        domain_key = attr[attribute_list_key.to_sym]
        attr.delete attribute_list_key.to_sym
        attr[:objectclass] = object_classes
        resource.create_mail_domain(domain_key, attr, attribute_list_key)
      end

      def self.delete_mail_domain(login, domain_name, attribute_list_key)
        options = {login: login,
                   ldap_auth_username_builder: ::Devise.ldap_auth_username_builder,
                   admin: ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.delete_mail_domain(domain_name, attribute_list_key)
      end

      def self.get_mail_domains(login)
        self.ldap_connect(login).all_mail_domains
      end

      def self.update_mailbox_password(login, email, new_password, mailbox_attribute = nil)
        self.ldap_connect(login).update_personal_mailbox_password(email, new_password, mailbox_attribute)
      end

      def self.update_own_password(login, new_password, current_password)
        set_ldap_param(login, :userPassword, ::Devise.ldap_auth_password_builder.call(new_password), current_password)
      end

      def self.upload_photo(login, photo_attribute, file)
        return unless File.exist? file
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(photo_attribute, IO.binread(file))
      end

      def self.ldap_connect(login)
        options = {:login => login,
                   :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                   :admin => ::Devise.ldap_use_admin_to_bind}
        Devise::LDAP::Connection.new(options)
      end

      def self.valid_login?(login)
        self.ldap_connect(login).valid_login?
      end

      def self.get_groups(login, group_attribute = nil)
        self.ldap_connect(login).user_groups(group_attribute)
      end

      def self.app_groups_for_user(login, user_value, group_attribute)
        self.ldap_connect(login).app_groups_for_user(user_value, group_attribute)
      end

      def self.groups_for_user(login, user_value, group_attribute)
        self.ldap_connect(login).groups_for_user(user_value, group_attribute)
      end

      def self.get_all_app_groups(login)
        self.ldap_connect(login).all_app_groups
      end

      def self.get_all_groups(login)
        self.ldap_connect(login).all_groups
      end

      def self.add_user_to_group(login, group_name, group_attr, user_attr)
        self.ldap_connect(login).user_group_action(:add, login, group_name, group_attr, user_attr)
      end

      def self.remove_user_from_group(login, group_name, group_attr, user_attr)
        self.ldap_connect(login).user_group_action(:delete, login, group_name, group_attr, user_attr)
      end

      def self.add_user_to_app_group(login, group_name, group_attr, user_attr)
        self.ldap_connect(login).user_app_group_action(:add, login, group_name, group_attr, user_attr)
      end

      def self.remove_user_from_app_group(login, group_name, group_attr, user_attr)
        self.ldap_connect(login).user_app_group_action(:delete, login, group_name, group_attr, user_attr)
      end

      def self.get_personal_mailbox(login, email, mailbox_attribute = nil )
        self.ldap_connect(login).personal_mailbox(email, mailbox_attribute)
      end

      def self.get_user(login, user_value, find_attribute = nil)
        self.ldap_connect(login).user(user_value, find_attribute)
      end

      def self.get_users(login)
        self.ldap_connect(login).users
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
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.set_param(param, new_value)
      end

      def self.delete_ldap_param(login, param, password = nil)
        options = { :login => login,
                    :ldap_auth_username_builder => ::Devise.ldap_auth_username_builder,
                    :password => password }

        resource = Devise::LDAP::Connection.new(options)
        resource.delete_param(param)
      end

      def self.get_ldap_param(login,param)
        resource = self.ldap_connect(login)
        resource.ldap_param_value(param)
      end

      def self.get_ldap_extended_property(login,attribute)
        resource = self.ldap_connect(login)
        resource.get_extended_propertie attribute
      end

      def self.get_ldap_entry(login)
        self.ldap_connect(login).search_for_login
      end

    end

  end

end
