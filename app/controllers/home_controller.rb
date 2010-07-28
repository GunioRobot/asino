class HomeController < ApplicationController
  
  def index
    @accounts = Account.all
  end

end
