class PasswordResetsController < ApplicationController
  def new

  	end
  	def create
  user = Personnel.find_by_email(params[:email])
  user.send_password_reset if user
  redirect_to root_url, :notice => "Email sent with password reset instructions."
end
  
  def edit
  @user = Personnel.find_by_password_reset_token!(params[:id])
end

def update
  @user = Personnel.find_by_password_reset_token!(params[:id])
  if @user.password_reset_sent_at < 2.hours.ago
    redirect_to new_password_reset_path, :alert => "Password &crarr; 
      reset has expired."
  elsif @user.update_attributes(params[:personnel].permit(:password, :password_confirmation))
  	@user.update(password_reset_token: nil, password_reset_sent_at: nil)
    redirect_to root_url, :notice => "Password has been reset."
  else
    render :edit
  end
end

end
