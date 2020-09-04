require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:foo)
    @non_admin = users(:archer)
  end

  test 'redirect with non active user' do
    @non_admin.update_attribute(:activated, false)

    log_in_as(@user)
    get user_path(@non_admin)
    assert_redirected_to users_path
  end
end
