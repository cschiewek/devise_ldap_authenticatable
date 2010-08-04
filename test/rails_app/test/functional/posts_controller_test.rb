require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers

  context "not logged in" do
    should "should get INDEX" do
      get :index
      assert_response :success
      assert_equal(response.body, "posts#index")
    end
    
    context "go to NEW page" do
      setup do
        get :new
      end

      should "not get NEW" do
        assert_response :redirect
      end      
    end
  end
  
  context "logged in" do
    setup do
      @user = Factory(:user)
      sign_in(@user)
    end

    context "get NEW action" do
      setup do
        get :new
      end

      should "get the NEW action" do
        assert_response :success
        assert_equal(response.body, "posts#new")
      end
    end
    
    context "log out user" do
      setup do
        sign_out(@user)
        get :new
      end

      should "get redirected to the login page" do
        assert_response :redirect
      end
    end
    

  end
  


end
