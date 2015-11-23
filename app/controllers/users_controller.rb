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

        flash[:success] = "Welcome to the user's panel, this page will allow you to search and make bookings"
        flash[:warning] = 'Warning! You have to activate your account before you can make any bookings'
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

  def activate
    @user = User.find_by(activation_token: params[:id])

    if @user.verified
      flash[:success] = 'Account is already verified... Activation not required.'
    else
      @user.verified = true
      @user.save
      flash[:success] = 'Account was successfully activated!'
    end

    redirect_to root_path
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
