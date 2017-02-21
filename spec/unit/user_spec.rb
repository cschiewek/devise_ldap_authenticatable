require File.expand_path('../spec_helper', File.dirname(__FILE__))

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
        assert_equal true, ::Devise::LDAP::Adapter.valid_login?('example.user@test.com')
      end

      it "should return false for a user that doesn't exist in LDAP" do
        assert_equal false, ::Devise::LDAP::Adapter.valid_login?('barneystinson')
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
        @user.password = "changed"
        @user.change_password!("secret")
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

      it "should not create user in the database" do
        @user = User.find_for_ldap_authentication(:email => "example.user@test.com", :password => "secret")
        assert(User.all.blank?)
        assert(@user.new_record?)
      end

      describe "creating users is enabled" do
        before do
          ::Devise.ldap_create_user = true
        end

        it "should create a user in the database" do
          @user = User.find_for_ldap_authentication(:email => "example.user@test.com", :password => "secret")
          assert_equal(User.all.size, 1)
          User.all.collect(&:email).should include("example.user@test.com")
          assert(@user.persisted?)
        end

        it "should not create a user in the database if the password is wrong_secret" do
          @user = User.find_for_ldap_authentication(:email => "example.user", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should not create a user if the user is not in LDAP" do
          @user = User.find_for_ldap_authentication(:email => "wrong_secret.user@test.com", :password => "wrong_secret")
          assert(User.all.blank?, "There's users in the database")
        end

        it "should create a user in the database if case insensitivity does not matter" do
          ::Devise.case_insensitive_keys = []
          @user = Factory.create(:user)

          expect do
            User.find_for_ldap_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          end.to change { User.count }.by(1)
        end

        it "should not create a user in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]
          @user = Factory.create(:user)

          expect do
            User.find_for_ldap_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          end.to_not change { User.count }
        end

        it "should create a user with downcased email in the database if case insensitivity matters" do
          ::Devise.case_insensitive_keys = [:email]

          @user = User.find_for_ldap_authentication(:email => "EXAMPLE.user@test.com", :password => "secret")
          User.all.collect(&:email).should include("example.user@test.com")
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
        @admin.ldap_groups.should include('cn=admins,ou=groups,dc=test,dc=com')
      end

      it "should user should not be allowed in" do
        should_not_be_validated @user, "secret"
      end
    end
    
    describe "check group membership" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
      end
      
      it "should return true for admin being in the admins group" do
        assert_equal true, @admin.in_ldap_group?('cn=admins,ou=groups,dc=test,dc=com')
      end
      
      it "should return false for admin being in the admins group using the 'foobar' group attribute" do
        assert_equal false, @admin.in_ldap_group?('cn=admins,ou=groups,dc=test,dc=com', 'foobar')
      end
      
      it "should return true for user being in the users group" do
        assert_equal true, @user.in_ldap_group?('cn=users,ou=groups,dc=test,dc=com')
      end   
      
      it "should return false for user being in the admins group" do
        assert_equal false, @user.in_ldap_group?('cn=admins,ou=groups,dc=test,dc=com')
      end

      it "should return false for a user being in a nonexistent group" do
        assert_equal false, @user.in_ldap_group?('cn=thisgroupdoesnotexist,ou=groups,dc=test,dc=com')
      end
    end

    describe "check group membership w/out admin bind" do
      before do
        @user = Factory.create(:user)
        ::Devise.ldap_check_group_membership_without_admin = true
      end

      after do
        ::Devise.ldap_check_group_membership_without_admin = false
      end

      it "should return true for user being in the users group" do
        assert_equal true, @user.in_ldap_group?('cn=users,ou=groups,dc=test,dc=com')
      end

      it "should return false for user being in the admins group" do
        assert_equal false, @user.in_ldap_group?('cn=admins,ou=groups,dc=test,dc=com')
      end

      it "should return false for a user being in a nonexistent group" do
        assert_equal false, @user.in_ldap_group?('cn=thisgroupdoesnotexist,ou=groups,dc=test,dc=com')
      end

      # TODO: add a test that confirms the user's own binding is used rather
      # than the admin binding by creating an LDAP user who can't do group
      # lookups perhaps?

      # TODO: add a test to demonstrate this function won't work on a user
      # after the initial login request if the password isn't available. This
      # might have to be more of a full stack test.
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
        @user = User.find_for_ldap_authentication(:uid => "example_user", :password => "secret")
        assert_equal(User.all.size, 1)
        User.all.collect(&:uid).should include("example_user")
      end

      it "should call ldap_before_save hooks" do
        User.class_eval do
          def ldap_before_save
            @foobar = 'foobar'
          end
        end
        user = User.find_for_ldap_authentication(:uid => "example_user", :password => "secret")
        assert_equal 'foobar', user.instance_variable_get(:"@foobar")
        User.class_eval do
          undef ldap_before_save
        end
      end

      it "should not call ldap_before_save hook if not defined" do
        should_be_validated Factory.create(:user, :uid => "example_user"), "secret"
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
      Devise::LDAP::Connection.new
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
