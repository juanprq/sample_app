require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:foo)
    @other_user = users(:archer)
  end

  test 'should get new' do
    get signup_path
    assert_response :success
  end

  test 'should get show' do
    get user_path @user.id
    assert_response :success
  end

  test 'should redirect edit when not logger in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: {
      user: { name: @user.name, email: @user.email }
    }

    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)

    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)

    patch user_path(@user), params: {
      user: { name: 'new name', email: 'new@email.com' }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should not update admin column' do
    log_in_as(@other_user)
    assert_not @other_user.admin?

    patch user_path(@other_user), params: {
      user: { name: 'new name', email: 'new@email.com', admin: true }
    }
    assert_redirected_to user_path(@other_user)
    assert_not flash.empty?

    @other_user.reload
    assert_not @other_user.admin?
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_redirected_to login_path
  end

  test 'should redirect destroy when logged-in as a non-admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_path
  end
end
