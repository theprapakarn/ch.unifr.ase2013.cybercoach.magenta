require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get controller" do
    get :controller
    assert_response :success
  end

  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get car" do
    get :car
    assert_response :success
  end

end
