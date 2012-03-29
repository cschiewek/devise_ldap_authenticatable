require 'spec_helper'

describe 'Users' do

  def should_be_validated(user, password, message = "Password is invalid")
    assert(user.valid_ldap_authentication?(password), message)
  end

  def should_not_be_validated(user, password, message = "Password is not properly set")
     assert(!user.valid_ldap_authentication?(password), message)
  end

  describe "With default settings" do
    before do
      default_devise_settings!
      reset_ldap_server!
    end

    describe "look up and ldap user" do
      it "should return true for a user that does exist in LDAP" do
        assert_equal true, ::Devise::LdapAdapter.valid_login?('example.user@test.com')
      end

      it "should return false for a user that doesn't exist in LDAP" do
        assert_equal false, ::Devise::LdapAdapter.valid_login?('barneystinson')
      end
    end

    describe "create a basic user" do
      before do
        @user = Factory.create(:user)
      end

      it "should check for password validation" do
        assert_equal(@user.email, "example.user@test.com")
        should_be_validated @user, "secret"
        should_not_be_validated @user, "wrong_secret"
        should_not_be_validated @user, "Secret"
      end
    end

    describe "change a LDAP password" do
      before do
        @user = Factory.create(:user)
      end

      it "should change password" do
        should_be_validated @user, "secret"
        @user.reset_password!("changed","changed")
        should_be_validated @user, "changed", "password was not changed properly on the LDAP sevrer"
      end

      it "should not allow to change password if setting is false" do
        should_be_validated @user, "secret"
        ::Devise.ldap_update_password = false
        @user.reset_password!("wrong_secret", "wrong_secret")
        should_not_be_validated @user, "wrong_secret"
        should_be_validated @user, "secret"
      end
    end

    describe "create new local user if user is in LDAP" do

      before do
        assert(User.all.blank?, "There shouldn't be any users in the database")
      end

      it "should don't create user in the database" do
        @user = User.authenticate_with_ldap(:email => "example.user@test.com", :password => "secret")
        assert(User.all.blank?)
      end

      describe "creating users is enabled" do
        before do
          ::Devise.ldap_create_user = true
        end

        it "should create a user in the database" do
          @user = User.authenticate_with_ldap(:email => "example.user@test.com", :password => "secret")
          assert_equal(User.all.size, 1)
          assert_contains(User.all.collect(&:email), "example.user@test.com", "user not in database")
        end

        it "should not create a user in the database if the password is wrong_secret" do
          @user = User.authenticate_with_ldap(:email => "example.user", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should create a user if the user is not in LDAP" do
          @user = User.authenticate_with_ldap(:email => "wrong_secret.user@test.com", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should create a user in the database if case insensitivity does not matter" do
          ::Devise.case_insensitive_keys = false
          @user = Factory.create(:user)

          assert_difference "User.count", +1 do
            User.authenticate_with_ldap(:email => "EXAMPLE.user@test.com", :password => "secret")
          end
        end

        it "should not create a user in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]
          @user = Factory.create(:user)

          assert_no_difference "User.count" do
            User.authenticate_with_ldap(:email => "EXAMPLE.user@test.com", :password => "secret")
          end
        end

        it "should create a user with downcased email in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]

          @user = User.authenticate_with_ldap(:email => "EXAMPLE.user@test.com", :password => "secret")
          assert_contains(User.all.collect(&:email), "example.user@test.com", "user not in database")
        end
      end

    end

    describe "use groups for authorization" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
        ::Devise.authentication_keys = [:email]
        ::Devise.ldap_check_group_membership = true
      end

      it "should admin should be allowed in" do
        should_be_validated @admin, "admin_secret"
      end

      it "should admin should have the proper groups set" do
        assert_contains(@admin.ldap_groups, /cn=admins/, "groups attribute not being set properly")
      end

      it "should user should not be allowed in" do
        should_not_be_validated @user, "secret"
      end

      it "should not be validated if group with different attribute is removed" do
        `ldapmodify #{ldap_connect_string} -f ../ldap/delete_authorization_role.ldif`
        should_not_be_validated @admin, "admin_secret"
      end
    end

    describe "use role attribute for authorization" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
        ::Devise.ldap_check_attributes = true
      end

      it "should admin should be allowed in" do
        should_be_validated @admin, "admin_secret"
      end

      it "should user should not be allowed in" do
        should_not_be_validated @user, "secret"
      end
    end

    describe "use admin setting to bind" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
        ::Devise.ldap_use_admin_to_bind = true
      end

      it "should description" do
        should_be_validated @admin, "admin_secret"
      end
    end

  end

  describe "use uid for login" do
    before do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = "#{Rails.root}/config/#{"ssl_" if ENV["LDAP_SSL"]}ldap_with_uid.yml"
      ::Devise.authentication_keys = [:uid]
    end

    describe "description" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user, :uid => "example_user")
      end

      it "should be able to authenticate using uid" do
        should_be_validated @user, "secret"
        should_not_be_validated @admin, "admin_secret"
      end
    end

    describe "create user" do
      before do
        ::Devise.ldap_create_user = true
      end

      it "should create a user in the database" do
        @user = User.authenticate_with_ldap(:uid => "example_user", :password => "secret")
        assert_equal(User.all.size, 1)
        assert_contains(User.all.collect(&:uid), "example_user", "user not in database")
      end

      it "should call ldap_before_save hooks" do
        User.class_eval do
          def ldap_before_save
            @foobar = 'foobar'
          end
        end
        user = User.authenticate_with_ldap(:uid => "example_user", :password => "secret")
        assert_equal 'foobar', user.instance_variable_get(:"@foobar")
        User.class_eval do
          undef ldap_before_save
        end
      end

      it "should not call ldap_before_save hook if not defined" do
        assert_nothing_raised do
          should_be_validated Factory.create(:user, :uid => "example_user"), "secret"
        end
      end
    end
  end

  describe "using ERB in the config file" do
    before do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = "#{Rails.root}/config/#{"ssl_" if ENV["LDAP_SSL"]}ldap_with_erb.yml"
    end

    describe "authenticate" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
      end

      it "should be able to authenticate" do
        should_be_validated @user, "secret"
        should_be_validated @admin, "admin_secret"
      end
    end
  end

  describe "using variants in the config file" do
    before do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = Rails.root.join 'config', 'ldap_with_boolean_ssl.yml'
    end

    it "should not fail if config file has ssl: true" do
      assert_nothing_raised do
        Devise::LdapAdapter::LdapConnect.new
      end
    end
  end

  describe "use username builder" do
    before do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_auth_username_builder = Proc.new() do |attribute, login, ldap|
        "#{attribute}=#{login},ou=others,dc=test,dc=com"
      end
      @other = Factory.create(:other)
    end

    it "should be able to authenticate" do
      should_be_validated @other, "other_secret"
    end
  end

end
