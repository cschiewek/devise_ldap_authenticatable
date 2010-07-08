require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def should_have_password(user, password, message = "Password is invalid")
    assert(user.valid_ldap_authentication?(password), message)
  end
  
  def should_not_have_password(user, password, message = "Password is not properly set")
     assert(!user.valid_ldap_authentication?(password), message)
  end

  context "create a basic user" do
    setup do
      @user = Factory(:user)
    end

    should "description" do
      assert_equal(@user.email, "example.user@test.com")
      should_have_password @user, "secret"
      should_not_have_password @user, "wrong_secret", "binds when using the wrong_secret password"
    end
  end
  
  context "change a LDAP password" do
    setup do
      @user = Factory(:user)
    end

    should "change password" do
      should_have_password @user, "secret"
      @user.update_attributes(:password => "changed")
      should_have_password @user, "changed", "password was not changed properly on the LDAP sevrer"
    end
    
    should "not allow to change password if setting is false" do
      should_have_password @user, "secret"
      ::Devise.ldap_update_password = false
      @user.update_attributes(:password => "wrong_secret")
      should_not_have_password @user, "wrong_secret"
      should_have_password @user, "secret"
    end
  end
  
  context "create new local user if user is in LDAP" do
    
    setup do
      assert(User.all.blank?, "There shouldn't be any users in the database")
    end
    
    should "don't create user in the database" do
      ::Devise.ldap_create_user = false
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
  

end
