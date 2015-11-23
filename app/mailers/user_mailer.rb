class UserMailer < ApplicationMailer
  default from: 'user-support@roomninja.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Room Ninja').deliver
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation.subject
  #
  def activation(user)
    @user = user
    mail(to: @user.email, subject: 'Activation Instructions').deliver
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password.subject
  #
  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: 'Reset Instruction').deliver
  end
end
