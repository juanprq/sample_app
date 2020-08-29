require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid sign up' do
    get signup_path
    assert_select 'input[id=?]', 'user_name', count: 1
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'foo@bar.com', password: 'foo', password_confirmation: 'bar' } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation', count: 1
    assert_select 'div.alert.alert-danger', count: 1, value: 'The form contains 6 errors'
  end

  test 'valid sign up' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'foo', email: 'foo@bar.com', password: '1' * 6, password_confirmation: '1' * 6 } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
