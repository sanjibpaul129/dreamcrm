class SessionsController < ApplicationController
	 def new
    @original_url=params[:original_url]
   end

  def create
  personnel = Personnel.authenticate(params[:email], params[:password])
  if personnel
   
    if params[:remember_me]
      cookies.permanent[:auth_token] = personnel.auth_token
    else
      cookies[:auth_token] = personnel.auth_token  
    end
  if personnel.access_right==0
     if params[:original_url]==nil   
     redirect_to windows_mis_url
     else
     redirect_to params[:original_url], method: :post 
     end
  elsif personnel.access_right==-1
  redirect_to report_outstanding_report_index_url  
  else
  redirect_to windows_fresh_leads_url  
  end
  else
    flash.now.alert = "Invalid email or password"
    render "new"
  end
end

def destroy
 cookies.delete(:auth_token)
  redirect_to personnels_new_url
end
  
end
