require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:foo)
    @other = users(:archer)
    log_in_as(@user)
  end

  test 'following_page' do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select 'a[href=?]', user_path(user)
    end
  end

  test 'should follow a user the standar way' do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  test 'should follow a user with Ajax' do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  test 'should unfollow a user the standar way' do
    @user.follow(@other)
    relantionship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relantionship)
    end
  end

  test 'should unfollow a user with Ajax' do
    @user.follow(@other)
    relantionship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relantionship), xhr: true
    end
  end

end
