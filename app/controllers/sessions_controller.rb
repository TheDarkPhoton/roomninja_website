class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to root_url
    end
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      flash[:success] = 'Login was successful'
    else
      @error = true
    end
  end

  def destroy
    log_out if logged_in?
    flash[:warning] = 'Logout was successful'
    redirect_to root_url
  end
end
