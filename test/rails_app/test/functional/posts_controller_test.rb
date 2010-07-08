require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  
  context "not logged in" do
    setup do
      
    end

    should "description" do
      
    end
  end
  
  
  test "should get index" do
    get :index
    assert_response :success
  end

end
