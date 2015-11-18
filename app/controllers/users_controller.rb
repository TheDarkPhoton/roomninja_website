class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if params[:commit] == 'Create'
      if @user.save
        institution = Institution.find_by(domain: @user.domain)
        institution.users << @user

        log_in @user
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  def show
    @user = current_user
  end

  def delete
  end

  private

  def user_params
    params.require(:user).permit(:id, :email, :domain, :password, :password_confirmation)
  end
end
