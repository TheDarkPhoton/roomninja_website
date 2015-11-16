class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to root_url
    end
  end

  def create
    if params[:commit] == 'Login'
      @user = User.find_by(email: params[:session][:email].downcase)
      if @user && @user.authenticate(params[:session][:password])
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  def destroy
    log_out if logged_in?
  end
end
