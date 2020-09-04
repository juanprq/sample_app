require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup' do
    get signup_path
    assert_select 'input[id=?]', 'user_name', count: 1
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'foo@bar.com', password: 'foo', password_confirmation: 'bar' } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation', count: 1
    assert_select 'div.alert.alert-danger', count: 1, value: 'The form contains 6 errors'
  end

  test 'valid signup with account activation' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'foo', email: 'foo-1@bar.com', password: '1' * 6, password_confirmation: '1' * 6 } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # get the instance variable
    user = assigns(:user)
    assert_not user.activated?

    log_in_as(user)
    assert_not is_logged_in?

    get edit_accounts_activation_path('invalid token', email: user.email)
    assert_not is_logged_in?

    get edit_accounts_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    get edit_accounts_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    follow_redirect!
    assert is_logged_in?
  end
end
