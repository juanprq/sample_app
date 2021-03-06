require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: 'foo',
      email: 'foo-1@bar.com',
      password: '123456',
      password_confirmation: '123456'
    )
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '   '
    assert_not @user.valid?
    assert_includes @user.errors.messages[:name], 'can\'t be blank'
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
    assert_includes @user.errors.messages[:email], 'can\'t be blank'
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
    assert_includes @user.errors.messages[:name], 'is too long (maximum is 50 characters)'
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
    assert_includes @user.errors.messages[:email], 'is too long (maximum is 255 characters)'
  end

  test 'email validation should accept valid emails' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address} should be valid"
    end
  end

  test 'email validation should reject invalid emails' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address} should be invalid"
    end
  end

  test 'user email should be unique' do
    duplicated_user = @user.dup
    duplicated_user.email = duplicated_user.email.upcase
    @user.save

    assert_not duplicated_user.valid?
  end

  test 'email should be downcased' do
    @user.email = 'eXamPle@BaR.CoM'
    @user.save

    assert_equal @user.email, 'example@bar.com'
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimun length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil diggest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'should follow and unfollow a user' do
    foo = users(:foo)
    archer = users(:archer)
    assert_not foo.following?(archer)
    foo.follow(archer)
    assert foo.following?(archer)
    assert archer.followers.include?(foo)
    foo.unfollow(archer)
    assert_not foo.following?(archer)
  end

  test 'feed should have the right posts' do
    foo = users(:foo)
    archer = users(:archer)
    lana = users(:lana)

    lana.microposts.each do |post_following|
      assert foo.feed.include?(post_following)
    end
    foo.microposts.each do |post_self|
      assert foo.feed.include?(post_self)
    end
    archer.microposts.each do |post_unfollowed|
      assert_not foo.feed.include?(post_unfollowed)
    end
  end
end
