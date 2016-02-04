# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    @user = User.first
    UserMailer.welcome(@user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/activation
  def activation
    @user = User.first
    UserMailer.activation(@user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/reset_password
  def reset_password
    @user = User.first
    UserMailer.reset_password(@user)
  end

end
