require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test 'invalid login' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: '', password: '' } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'valid login' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: 'foo@bar.com', password: '123456' } }
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', user_path
    assert_select 'a[href=?]', logout_path
  end
end
