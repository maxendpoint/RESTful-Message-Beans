require 'test_helper'

class ListenersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:listeners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create listener" do
    assert_difference('Listener.count') do
      post :create, :listener => { }
    end

    assert_redirected_to listener_path(assigns(:listener))
  end

  test "should show listener" do
    get :show, :id => listeners(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => listeners(:one).to_param
    assert_response :success
  end

  test "should update listener" do
    put :update, :id => listeners(:one).to_param, :listener => { }
    assert_redirected_to listener_path(assigns(:listener))
  end

  test "should destroy listener" do
    assert_difference('Listener.count', -1) do
      delete :destroy, :id => listeners(:one).to_param
    end

    assert_redirected_to listeners_path
  end
end
