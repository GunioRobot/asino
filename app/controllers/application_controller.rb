# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem

  before_filter :set_locale, :set_month
  
  def set_locale
    I18n.locale = 'de'
  end
  
  def set_month
    if params[:month]
      session[:month] = params[:month].to_i
      @month = params[:month].to_i
      return
    end
    if session[:month]
      @month = session[:month].to_i
      return
    end
    @month = 0
  end
  
  def check_login
    return if logged_in?
    
    redirect_to login_path, :alert => 'Bitte melden Sie sich an.' if User.count > 0;
    redirect_to signup_path, :notice => 'Bitte legen Sie zuerst einen Benutzer an.' if User.count == 0;
  end

end
