class HomeController < ApplicationController
  
  def index
    @accounts = Account.all
  end
  
  def help
    @accounts = Account.all
  end

end
