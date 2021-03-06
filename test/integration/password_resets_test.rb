require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:foo)
  end

  test 'password resets' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'

    post password_resets_path(params: { password_reset: { email: 'wrong@mail.com' } })
    assert_not flash.empty?
    assert_template 'password_resets/new'


    post password_resets_path(params: { password_reset: { email: @user.email } })
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path

    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_path

    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_path

    user.toggle!(:activated)
    get edit_password_reset_path('wrong', email: user.email)
    assert_redirected_to root_path

    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[type=hidden][value=?]', user.email

    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: '',
        password_confirmation: ''
      }
    }
    assert_select 'div#error_explanation'

    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: '123456',
        password_confirmation: '123456'
      }
    }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test 'expired link' do
    post password_resets_path(params: { password_reset: { email: @user.email } })
    assert_not_equal @user.reset_digest, @user.reload.reset_digest

    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_not flash[:empty]
    assert_redirected_to new_password_reset_path
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
