class UsersController < ApplicationController
  before_action :user_is_logged_in, only: [:show, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if params[:commit] == 'Create'
      if @user.save
        institution = Institution.find_by(domain: @user.domain)
        institution.users << @user

        UserMailer.delay.welcome(@user)
        flash[:success] = "Welcome to the user's panel, this page will allow you to search and make bookings"
        log_in @user
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  def show
    @user = @current_user
    @find_rooms = FindRoom.new
  end

  def destroy

  end

  private

  def user_params
    params.require(:user).permit(:id, :email, :domain, :password, :password_confirmation)
  end

  def user_is_logged_in
    unless logged_in? && @current_user.id != params[:id]
      flash[:danger] = "You don't have permission to access this page"
      redirect_to root_url
    end
  end
end
