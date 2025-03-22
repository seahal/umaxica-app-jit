class UserMailer < ApplicationMailer
  default from: "sample@email.umaxica.app"

  def welcome_email
    @user = params[:user]
    @url  = "http://example.com/login"
    mail(to: 'm.shiihara@email.umaxica.app', subject: "私の素敵なサイトへようこそ")
  end
end
