require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers

  context "not logged in" do
    should "should get index" do
      get :index
      assert_response :success
      assert_equal(response.body, "posts#index")
    end
    
    context "go to show page" do
      setup do
        get :show, :id => 1
      end

      should "not get show" do
        assert_response :redirect
      end      
    end
  end
  
  context "logged in" do
    setup do
      @user = Factory(:user)
      sign_in(@user)
    end

    context "get show action" do
      setup do
        get :show, :id => 1
      end

      should "get the show action" do
        assert_response :success
      end
    end
    
    context "log out user" do
      setup do
        sign_out(@user)
        get :show, :id => 1
      end

      should "get redirected to the login page" do
        assert_response :redirect
      end
    end
    

  end
  


end
