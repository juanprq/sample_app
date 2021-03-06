class ApplicationController < ActionController::Base
  include SessionsHelper

  def logged_in_user
    unless logged_in?
      flash[:danger] = 'Please log in.'
      store_location
      redirect_to login_url
    end
  end

end
