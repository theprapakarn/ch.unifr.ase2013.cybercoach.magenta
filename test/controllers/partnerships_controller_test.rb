require 'test_helper'

class PartnershipsControllerTest < ActionController::TestCase
  setup do
    @partnership = partnerships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:partnerships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create partnership" do
    assert_difference('Partnership.count') do
      post :create, partnership: { datecreated: @partnership.datecreated, first_user_confirmed: @partnership.first_user_confirmed, first_user_id: @partnership.first_user_id, public_visible: @partnership.public_visible, reference: @partnership.reference, second_user_confirmed: @partnership.second_user_confirmed, second_user_id: @partnership.second_user_id }
    end

    assert_redirected_to partnership_path(assigns(:partnership))
  end

  test "should show partnership" do
    get :show, id: @partnership
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @partnership
    assert_response :success
  end

  test "should update partnership" do
    patch :update, id: @partnership, partnership: { datecreated: @partnership.datecreated, first_user_confirmed: @partnership.first_user_confirmed, first_user_id: @partnership.first_user_id, public_visible: @partnership.public_visible, reference: @partnership.reference, second_user_confirmed: @partnership.second_user_confirmed, second_user_id: @partnership.second_user_id }
    assert_redirected_to partnership_path(assigns(:partnership))
  end

  test "should destroy partnership" do
    assert_difference('Partnership.count', -1) do
      delete :destroy, id: @partnership
    end

    assert_redirected_to partnerships_path
  end
end
