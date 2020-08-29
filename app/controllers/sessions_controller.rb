class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      flash[:success] = 'Welcome to sample app'
      redirect_to users_show_path(user)
    else
      flash[:danger] = 'Invalid credentials, please try again!'
      render 'new'
    end
  end
end
