require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "create a basic user" do
    setup do
      @user = Factory.build(:user)
    end

    should "description" do
      assert_equal(@user.email, "example.user@test.com")
      assert(@user.valid_ldap_authentication?("secret"), "Cannot bind to LDAP server")
      assert(!@user.valid_ldap_authentication?("wrong"), "binds when using the wrong password")
    end
  end
  

end
