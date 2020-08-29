require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'something' do
    get signup_path
    assert_select 'input[id=?]', 'user_name', count: 1
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'foo@bar.com', password: 'foo', password_confirmation: 'bar' } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation', count: 1
    assert_select 'div.alert.alert-danger', count: 1, value: 'The form contains 6 errors'
  end
end
