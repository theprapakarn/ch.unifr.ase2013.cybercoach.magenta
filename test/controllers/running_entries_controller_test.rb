require 'test_helper'

class RunningEntriesControllerTest < ActionController::TestCase
  setup do
    @running_entry = running_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:running_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create running_entry" do
    assert_difference('RunningEntry.count') do
      post :create, running_entry: { course_length: @running_entry.course_length, course_type: @running_entry.course_type, number_of_round: @running_entry.number_of_round, track: @running_entry.track }
    end

    assert_redirected_to running_entry_path(assigns(:running_entry))
  end

  test "should show running_entry" do
    get :show, id: @running_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @running_entry
    assert_response :success
  end

  test "should update running_entry" do
    patch :update, id: @running_entry, running_entry: { course_length: @running_entry.course_length, course_type: @running_entry.course_type, number_of_round: @running_entry.number_of_round, track: @running_entry.track }
    assert_redirected_to running_entry_path(assigns(:running_entry))
  end

  test "should destroy running_entry" do
    assert_difference('RunningEntry.count', -1) do
      delete :destroy, id: @running_entry
    end

    assert_redirected_to running_entries_path
  end
end
