class MutateUsersController < ApplicationController
  def send_activation
    @user = User.find(params[:id])
    UserMailer.delay.welcome(@user)
    flash[:success] = 'Activation email was sent successfully. You should receive it shortly.'
    redirect_to @user
  end

  def activate
    @user = User.find_by(activation_token: params[:id])

    if @user.verified?
      flash[:success] = 'Account is already verified... Activation not required.'
    else
      @user.is_verified = true
      @user.save
      flash[:success] = 'Account was successfully activated!'
    end

    redirect_to root_path
  end

  def new_reset
    @reset = UserReset.new
  end

  def create_reset
    @reset = UserReset.new(reset_params)

    if params[:commit] == 'Reset'
      if @reset.valid?
        @reset.user.new_reset_token
        flash[:success] = 'Reset email was successfully sent. Check your email for further instructions.'
        UserMailer.delay.reset_password(@reset.user)
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  def new_password
    @user = User.find_by(reset_token: params[:id])

    respond_to { |f|
      f.html {
        if reset_expired
          redirect_to root_url
        else
          redirect_to root_url(reset_token: params[:id])
        end
      }
      f.js{
        @user.password = ''
      }
    }
  end

  def update_password
    @user = User.find_by(reset_token: params[:id])

    if params[:commit] == 'Update'
      if reset_expired
        render js: "window.location = '#{root_url}'"
      elsif @user.update_attributes(password_params)
        @user.nil_reset_token
        flash[:success] = 'Password was changed successfully.'
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  private

  def reset_params
    params.require(:user_reset).permit(:email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def reset_expired
    if @user.nil?
      flash[:danger] = 'No user with this reset id was found, create a new reset and try again.'
      return true
    elsif @user.reset_expire < Time.zone.now
      @user.nil_reset_token
      flash[:danger] = 'This reset session has expired, create a new reset and try again.'
      redirect_to root_url
      return true
    end

    false
  end
end
