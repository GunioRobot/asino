class ApplicationController < ActionController::Base
  protect_from_forgery

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
    return if user_signed_in?
    
    redirect_to new_user_session_path, :alert => 'Bitte melden Sie sich an.' if User.count > 0;
    redirect_to new_user_registration_path, :notice => 'Bitte legen Sie zuerst einen Benutzer an.' if User.count == 0;
  end
  
  
  # returns an array of categories that contain all according category items
  def categorized_items(items = [], itemtype = 'expenses' , basevalue = 0, date)
    categories = []
    categories_sum = 0
    no_category = Category.new({:name => 'Ohne Kategorie'})
 
    items.group_by { |i| i.category }.each do |c, items|
      c = no_category unless c
      # note we have to work with a copy here to avoid overwriting values when we get both expenses and income on one page!
      category = c.clone 
      category.sum = 0
      category.category_id = c.id
      items.each do |item|
        next if (itemtype == 'expenses' and item.amount >= 0) or (itemtype == 'income' and item.amount < 0)
        category.sum += item.amount
        category.lastmonth_sum = c.items.for_date(date).sum(:amount)
        category.percent = (category.sum  / basevalue * 100).round(1)
        category.items << item
      end
      categories << category unless category.sum == 0
      categories_sum += category.sum
    end 
    
    categories = categories.sort{|l,m| l.sum <=> m.sum}
    return categories
  end
  
  def load_accounts
    @accounts = Account.all
  end
  
end
