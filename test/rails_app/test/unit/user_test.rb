require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def should_be_validated(user, password, message = "Password is invalid")
    assert(user.valid_ldap_authentication?(password), message)
  end
  
  def should_not_be_validated(user, password, message = "Password is not properly set")
     assert(!user.valid_ldap_authentication?(password), message)
  end

  context "With default settings" do
    setup do
      default_devise_settings!
      reset_ldap_server!
    end

    context "look up and ldap user" do
      should "return true for a user that does exist in LDAP" do
        assert_equal true, ::Devise::LdapAdapter.valid_login?('example.user@test.com')
      end

      should "return false for a user that doesn't exist in LDAP" do
        assert_equal false, ::Devise::LdapAdapter.valid_login?('barneystinson')
      end
    end
  
    context "create a basic user" do
      setup do
        @user = Factory(:user)
      end
  
      should "check for password validation" do
        assert_equal(@user.email, "example.user@test.com")
        should_be_validated @user, "secret"
        should_not_be_validated @user, "wrong_secret"
        should_not_be_validated @user, "Secret"
      end
    end
  
    context "change a LDAP password" do
      setup do
        @user = Factory(:user)
      end
  
      should "change password" do
        should_be_validated @user, "secret"
        @user.reset_password!("changed","changed")
        should_be_validated @user, "changed", "password was not changed properly on the LDAP sevrer"
      end
    
      should "not allow to change password if setting is false" do
        should_be_validated @user, "secret"
        ::Devise.ldap_update_password = false
        @user.reset_password!("wrong_secret", "wrong_secret")
        should_not_be_validated @user, "wrong_secret"
        should_be_validated @user, "secret"
      end
    end
  
    context "create new local user if user is in LDAP" do
    
      setup do
        assert(User.all.blank?, "There shouldn't be any users in the database")
      end
    
      should "don't create user in the database" do
        @user = User.authenticate_with_ldap(:email => "example.user@test.com", :password => "secret")
        assert(User.all.blank?)
      end
    
      context "creating users is enabled" do
        setup do
          ::Devise.ldap_create_user = true
        end
      
        should "create a user in the database" do
          @user = User.authenticate_with_ldap(:email => "example.user@test.com", :password => "secret")
          assert_equal(User.all.size, 1)
          assert_contains(User.all.collect(&:email), "example.user@test.com", "user not in database")
        end
  
        should "not create a user in the database if the password is wrong_secret" do
          @user = User.authenticate_with_ldap(:email => "example.user", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end
      
        should "create a user if the user is not in LDAP" do
          @user = User.authenticate_with_ldap(:email => "wrong_secret.user@test.com", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end
      end
    
    end
  
    context "use groups for authorization" do
      setup do
        @admin = Factory(:admin)
        @user = Factory(:user)
        ::Devise.authentication_keys = [:email]
        ::Devise.ldap_check_group_membership = true
      end
  
      should "admin should be allowed in" do
        should_be_validated @admin, "admin_secret"
      end
    
      should "admin should have the proper groups set" do
        assert_contains(@admin.ldap_groups, /cn=admins/, "groups attribute not being set properly")
      end
    
      should "user should not be allowed in" do
        should_not_be_validated @user, "secret"
      end
      
      should "not be validated if group with different attribute is removed" do
        `ldapmodify #{ldap_connect_string} -f ../ldap/delete_authorization_role.ldif`
        should_not_be_validated @admin, "admin_secret"
      end
    end
  
    context "use role attribute for authorization" do
      setup do
        @admin = Factory(:admin)
        @user = Factory(:user)
        ::Devise.ldap_check_attributes = true
      end
  
      should "admin should be allowed in" do
        should_be_validated @admin, "admin_secret"
      end
    
      should "user should not be allowed in" do
        should_not_be_validated @user, "secret"
      end
    end
    
    context "use admin setting to bind" do
      setup do
        @admin = Factory(:admin)
        @user = Factory(:user)
        ::Devise.ldap_use_admin_to_bind = true
      end
  
      should "description" do
        should_be_validated @admin, "admin_secret"
      end
    end
  
  end
  
  context "use uid for login" do
    setup do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = "#{Rails.root}/config/#{"ssl_" if ENV["LDAP_SSL"]}ldap_with_uid.yml"
      ::Devise.authentication_keys = [:uid]
    end
  
    context "description" do
      setup do
        @admin = Factory(:admin)
        @user = Factory(:user, :uid => "example_user")
      end
  
      should "be able to authenticate using uid" do
        should_be_validated @user, "secret"
        should_not_be_validated @admin, "admin_secret"
      end
    end
    
    context "create user" do
      setup do
        ::Devise.ldap_create_user = true
      end
  
      should "create a user in the database" do
        @user = User.authenticate_with_ldap(:uid => "example_user", :password => "secret")
        assert_equal(User.all.size, 1)
        assert_contains(User.all.collect(&:uid), "example_user", "user not in database")
      end

      should "call ldap_before_save hooks" do
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

      should "not call ldap_before_save hook if not defined" do
        assert_nothing_raised do
          should_be_validated Factory(:user, :uid => "example_user"), "secret"
        end
      end
    end    
  end
  
  context "using ERB in the config file" do
    setup do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = "#{Rails.root}/config/#{"ssl_" if ENV["LDAP_SSL"]}ldap_with_erb.yml"
    end
  
    context "authenticate" do
      setup do
        @admin = Factory(:admin)
        @user = Factory(:user)
      end
  
      should "be able to authenticate" do
        should_be_validated @user, "secret"
        should_be_validated @admin, "admin_secret"
      end
    end
  end

  context "using variants in the config file" do
    setup do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = Rails.root.join 'config', 'ldap_with_boolean_ssl.yml'
    end

    should "not fail if config file has ssl: true" do
      assert_nothing_raised do
        Devise::LdapAdapter::LdapConnect.new
      end
    end
  end
  
  context "use username builder" do
    setup do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_auth_username_builder = Proc.new() do |attribute, login, ldap|
        "#{attribute}=#{login},ou=others,dc=test,dc=com"
      end
      @other = Factory(:other)
    end

    should "be able to authenticate" do
      should_be_validated @other, "other_secret"
    end
  end
  
end
