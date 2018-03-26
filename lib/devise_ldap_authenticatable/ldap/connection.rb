module Devise
  module LDAP
    class Connection
      attr_reader :ldap, :login

      def initialize(params = {})
        if ::Devise.ldap_config.is_a?(Proc)
          ldap_config = ::Devise.ldap_config.call
        else
          ldap_config = YAML.load(ERB.new(File.read(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")).result)[Rails.env]
        end
        ldap_options = params
        ldap_config['ssl'] = :simple_tls if ldap_config['ssl'] === true
        ldap_options[:encryption] = ldap_config['ssl'].to_sym if ldap_config['ssl']

        @ldap = Net::LDAP.new(ldap_options)
        @ldap.host = ldap_config['host']
        @ldap.port = ldap_config['port']
        @ldap.base = ldap_config['base']
        @attribute = ldap_config['attribute']
        @allow_unauthenticated_bind = ldap_config['allow_unauthenticated_bind']

        @ldap_auth_username_builder = params[:ldap_auth_username_builder]

        @group_base = ldap_config['group_base']
        @group_app_base = ldap_config['group_app_base']
        @mailbox_base = ldap_config['mailbox_base']
        @mail_alias_base = ldap_config['mail_alias_base']
        @mail_domain_base = ldap_config['mail_domain_base']
        @dns_domain_base = ldap_config['dns_domain_base']
        @check_group_membership = ldap_config.has_key?('check_group_membership') ? ldap_config['check_group_membership'] : ::Devise.ldap_check_group_membership
        @required_groups = ldap_config['required_groups']
        @required_attributes = ldap_config['require_attribute']
        @customer_auth = ldap_config['no_customer_auth']
        @email_auth_domain = ldap_config['email_auth_domain']
        @samba_domain = ldap_config['samba_domain']

        @ldap.auth ldap_config['admin_user'], ldap_config['admin_password'] if params[:admin]
        @ldap.auth params[:login], params[:password] if ldap_config['admin_as_user']

        @login = params[:login]
        @password = params[:password]
        @new_password = params[:new_password]
      end

      def customer_auth?
        @customer_auth == 'true'
      end

      def login_is_mail?
        @login.include?('@')
      end

      def email_auth_domain
        @email_auth_domain
      end

      def delete_param(param)
        update_ldap [[:delete, param.to_sym, nil]]
      end

      def set_param(param, new_value)
        puts "Update ldap atrribute #{param}"
        update_ldap( { param.to_sym => new_value } )
      end

      def create_user(param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{param[attr.to_sym]},#{@ldap.base}"
        DeviseLdapAuthenticatable::Logger.send("Adding user #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_user(username, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{username},#{@ldap.base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting user #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def create_group(group, param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{group},#{@group_base}"
        DeviseLdapAuthenticatable::Logger.send("Adding Group #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_group(group, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{group},#{@group_base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting Group #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def create_app_group(group, param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{group},#{@group_app_base}"
        DeviseLdapAuthenticatable::Logger.send("Adding Application Group #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_app_group(group, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{group},#{@group_app_base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting Application Group #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def create_mailbox(mail, param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{mail},#{@mailbox_base}"
        DeviseLdapAuthenticatable::Logger.send("Adding Mailbox #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_mailbox(mail, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{mail},#{@mailbox_base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting Mailbox #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def create_mail_alias(mail_alias, param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{mail_alias},#{@mail_alias_base}"
        DeviseLdapAuthenticatable::Logger.send("Adding Mail Alias #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_mail_alias(mail_alias, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{mail_alias},#{@mail_alias_base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting Mail Alias #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def update_mail_alias(mail_alias, routing_address, attr)
        admin_ldap = Connection.admin
        filter = Net::LDAP::Filter.eq(attr, mail_alias)
        resource = admin_ldap.search(filter: filter, base: @mail_alias_base).collect(&:dn)
        if resource.present?
          DeviseLdapAuthenticatable::Logger.send("Modifying Mail Alias routing addresses for #{resource.first}")
          admin_ldap.replace_attribute resource.first, :mailroutingaddress, routing_address
        end
      end

      def create_mail_domain(domain, param, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{domain},#{@mail_domain_base}"
        DeviseLdapAuthenticatable::Logger.send("Adding Mail Domain #{new_dn}")
        ldap.add(dn: new_dn, attributes: param)
      end

      def delete_mail_domain(domain, attr)
        ldap = Connection.admin
        new_dn = "#{attr}=#{domain},#{@mail_domain_base}"
        DeviseLdapAuthenticatable::Logger.send("Deleting Mail Domain #{new_dn}")
        ldap.delete(dn: new_dn)
      end

      def dn
        @dn ||= begin
          DeviseLdapAuthenticatable::Logger.send("LDAP dn lookup: #{@attribute}=#{@login}")
          ldap_entry = search_for_login
          if ldap_entry.nil?
            @ldap_auth_username_builder.call(@attribute,@login,@ldap)
          else
            ldap_entry.dn
          end
        end
      end

      def ldap_param_value(param)
        ldap_entry = search_for_login

        if ldap_entry
          unless ldap_entry[param].empty?
            value = ldap_entry.send(param)
            DeviseLdapAuthenticatable::Logger.send("Requested param #{param} has value #{value}")
            value
          else
            DeviseLdapAuthenticatable::Logger.send("Requested param #{param} does not exist")
            value = nil
          end
        else
          DeviseLdapAuthenticatable::Logger.send("Requested ldap entry does not exist")
          value = nil
        end
      end

      def get_extended_propertie(attribute)
        ldap_entry = search_for_login('+')

        if ldap_entry
          unless ldap_entry[attribute].empty?
            value = ldap_entry.send(attribute)
            DeviseLdapAuthenticatable::Logger.send("Requested extend propertie #{attribute} has value #{value}")
            value
          else
            DeviseLdapAuthenticatable::Logger.send("Requested extend propertie #{attribute} does not exist")
            value = nil
          end
        else
          DeviseLdapAuthenticatable::Logger.send("Requested ldap entry does not exist")
          value = nil
        end
      end

      def authenticate!
        return false unless (@password.present? || @allow_unauthenticated_bind)
        @ldap.auth(dn, @password)
        @ldap.bind
      end

      def authenticated?
        authenticate!
      end

      def authorized?
        DeviseLdapAuthenticatable::Logger.send("Authorizing user #{dn}")
        if !authenticated?
          DeviseLdapAuthenticatable::Logger.send("Not authorized because not authenticated.")
          false
        elsif !in_required_groups?
          DeviseLdapAuthenticatable::Logger.send("Not authorized because not in required groups.")
          false
        elsif !has_required_attribute?
          DeviseLdapAuthenticatable::Logger.send("Not authorized because does not have required attribute.")
          false
        else
          true
        end
      end

      def change_password!
        binding.pry
        update_ldap(:userpassword => Net::LDAP::Password.generate(:ssha, @new_password))
      end

      def in_required_groups?
        return true unless @check_group_membership

        ## FIXME set errors here, the ldap.yml isn't set properly.
        return false if @required_groups.nil?

        for group in @required_groups
          if group.is_a?(Array)
            return false unless in_group?(group[1], group[0])
          else
            return false unless in_group?(group)
          end
        end
        true
      end

      def in_group?(group_name, group_attribute = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
        in_group = false

        admin_ldap = Connection.admin

        unless ::Devise.ldap_ad_group_check
          admin_ldap.search(:base => group_name, :scope => Net::LDAP::SearchScope_BaseObject) do |entry|
            if entry[group_attribute].include? dn
              in_group = true
            end
          end
        else
          # AD optimization - extension will recursively check sub-groups with one query
          # "(memberof:1.2.840.113556.1.4.1941:=group_name)"
          search_result = admin_ldap.search(:base => dn,
                            :filter => Net::LDAP::Filter.ex("memberof:1.2.840.113556.1.4.1941", group_name),
                            :scope => Net::LDAP::SearchScope_BaseObject)
          # Will return  the user entry if belongs to group otherwise nothing
          if search_result.length == 1 && search_result[0].dn.eql?(dn)
            in_group = true
          end
        end

        unless in_group
          DeviseLdapAuthenticatable::Logger.send("User #{dn} is not in group: #{group_name}")
        end

        in_group
      end

      def has_required_attribute?
        return true unless ::Devise.ldap_check_attributes

        admin_ldap = Connection.admin

        user = find_ldap_user(admin_ldap)

        @required_attributes.each do |key,val|
          unless user[key].include? val
            DeviseLdapAuthenticatable::Logger.send("User #{dn} did not match attribute #{key}:#{val}")
            return false
          end
        end
        true
      end

      def user_groups(group_attribute = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting groups for #{dn}")
        dn_hash = Hash[dn.split(',').collect { |x| x.split('=') }]
        filter = Net::LDAP::Filter.eq(group_attribute, dn_hash['uid'])
        admin_ldap.search(:filter => filter, :base => @group_base).collect(&:dn)
      end

      def all_app_groups
        all_groups(@group_app_base)
      end

      def all_groups(base = @group_base)
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting all groups")
        admin_ldap.search(base: base)
      end

      def all_mail_aliases
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting all mail aliases")
        admin_ldap.search(base: @mail_alias_base)
      end

      def all_mail_domains
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting all mail domains")
        admin_ldap.search(base: @mail_domain_base)
      end

      def user_app_group_action(action, user_dn, group_name, group_attribute, user_attribute)
        user_group_action(action, user_dn, group_name, group_attribute, user_attribute, @group_app_base)
      end

      def user_group_action(action, user_dn, group_name, group_attribute, user_attribute, base = @group_base)
        ldap = Connection.admin
        new_dn = "#{group_attribute}=#{group_name},#{base}"
        DeviseLdapAuthenticatable::Logger.send("#{action.to_s} user #{user_dn} to #{new_dn}")
        ops = [
            [action.to_sym, user_attribute.to_sym, user_dn]
        ]
        ldap.modify(dn: new_dn, operations: ops)
      end

      def personal_mailbox(email, mailbox_attribute = LDAP::DEFAULT_MAIL_GROUP_UNIQUE_MEMBER_LIST_KEY)
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting personal mailbox for #{dn}")
        filter = Net::LDAP::Filter.eq(mailbox_attribute, email)
        admin_ldap.search(:filter => filter, :base => @mailbox_base)
      end

      def update_personal_mailbox_password(email, new_password, mailbox_attribute)
        admin_ldap = Connection.admin
        filter = Net::LDAP::Filter.eq(mailbox_attribute, email)
        resource = admin_ldap.search(:filter => filter, :base => @mailbox_base).collect(&:dn)
        if resource.present?
          DeviseLdapAuthenticatable::Logger.send("Modifying Mailbox password for #{resource.first}")
          admin_ldap.replace_attribute resource.first, :userpassword, new_password
        end
      end

      def app_groups_for_user(user_value, group_attribute = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
        search_for_user(user_value, group_attribute, @group_app_base)
      end

      def groups_for_user(user_value, group_attribute = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY)
        search_for_user(user_value, group_attribute)
      end

      def search_for_user(user_value, group_attribute, base = @group_base)
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting groups for #{dn}")
        filter = Net::LDAP::Filter.eq(group_attribute, user_value)
        admin_ldap.search(filter: filter, base: base).collect(&:dn)
      end

      def users
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting all user")
        admin_ldap.search()
      end

      def user
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting user info")
        admin_ldap.search(base: dn)
      end

      def user_value(user_value, find_attribute = LDAP::DEFAULT_USER_UNIQUE_LIST_KEY)
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting user info")
        filter = Net::LDAP::Filter.eq(find_attribute, user_value)
        admin_ldap.search(:filter => filter, :base => dn)
      end

      def valid_login?
        !search_for_login.nil?
      end

      # Searches the LDAP for the login
      #
      # @return [Object] the LDAP entry found; nil if not found
      def search_for_login(attribute='')
        @login_ldap_entry ||= begin
          DeviseLdapAuthenticatable::Logger.send("LDAP search for login: #{@attribute}=#{@login}")
          filter = Net::LDAP::Filter.eq(@attribute.to_s, @login.to_s)
          ldap_entry = nil
          match_count = 0
          if attribute.empty?
            @ldap.search(:filter => filter ) {|entry| ldap_entry = entry; match_count+=1}
          else
            @ldap.search(:filter => filter, :attributes => attribute ) {|entry| ldap_entry = entry; match_count+=1}
          end
          DeviseLdapAuthenticatable::Logger.send("LDAP search yielded #{match_count} matches")
          ldap_entry
        end
      end

      def get_samba_sid
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting SAMBA SID for #{@samba_domain}")
        filter = Net::LDAP::Filter.pres('sambaSID')
        result = admin_ldap.search(filter: filter, base: @samba_domain)
        result.first[:sambasid].first unless result.nil?
      end

      def set_samba_user_password(sid, password)
        new_pasword = OpenSSL::Digest::MD4.hexdigest(Iconv.iconv('UCS-2', 'UTF-8', password).join).upcase
        DeviseLdapAuthenticatable::Logger.send("Setting SambaNTPassword for #{dn}")
        update_ldap( { sambasid: sid,
                       sambaactflags: '[U]',
                       sambantntpassword: new_pasword,
                       sambapwdlastset: DateTime.now.to_time.to_i } )
      end

      def all_dns_records
        admin_ldap = Connection.admin
        DeviseLdapAuthenticatable::Logger.send("Getting all mail domains")
        admin_ldap.search(base: @dns_domain_base)
      end

      private

      def self.admin
        ldap = Connection.new(:admin => true).ldap

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

        if ::Devise.ldap_use_admin_to_bind
          privileged_ldap = Connection.admin
        else
          authenticate!
          privileged_ldap = self.ldap
        end

        DeviseLdapAuthenticatable::Logger.send("Modifying user #{dn}")
        privileged_ldap.modify(:dn => dn, :operations => operations)
      end

    end
  end
end
