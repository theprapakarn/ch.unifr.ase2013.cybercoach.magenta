require 'test_helper'

class SoccerEntriesControllerTest < ActionController::TestCase
  setup do
    @soccer_entry = soccer_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:soccer_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create soccer_entry" do
    assert_difference('SoccerEntry.count') do
      post :create, soccer_entry: {  }
    end

    assert_redirected_to soccer_entry_path(assigns(:soccer_entry))
  end

  test "should show soccer_entry" do
    get :show, id: @soccer_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @soccer_entry
    assert_response :success
  end

  test "should update soccer_entry" do
    patch :update, id: @soccer_entry, soccer_entry: {  }
    assert_redirected_to soccer_entry_path(assigns(:soccer_entry))
  end

  test "should destroy soccer_entry" do
    assert_difference('SoccerEntry.count', -1) do
      delete :destroy, id: @soccer_entry
    end

    assert_redirected_to soccer_entries_path
  end
end
