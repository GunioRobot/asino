# Mangages account specific actions. An account actually refers to a bank account.
class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  
  before_filter :get_accounts, :check_login
  before_filter :load_account, :only => [:show, :edit, :update, :destroy, :overview, :course]
  
  
  def index
    render :action => 'no_accounts' and return if @accounts.empty?
    
    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    @lastmonth = (Time.now.at_end_of_month == @enddate) ? Time.now - 1.month :  @enddate - 1.month

    @sum = Item.until_date(@enddate).sum(:amount)
                           
    @items = Item.for_date(@enddate)
    @income = Item.income.for_date(@enddate).sum(:amount)
    @expenses = Item.expenses.for_date(@enddate).sum(:amount)
    
    sort_items #sort items according to order param
    
    @last_month_income = Item.income.for_current_date(@lastmonth).sum(:amount)    
    @last_month_expenses = Item.expenses.for_current_date(@lastmonth).sum(:amount)

    render :action => 'show'
  end



  def show
    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    @lastmonth = (Time.now.at_end_of_month == @enddate) ? Time.now - 1.month :  @enddate - 1.month
    
    @items = Item.for_account(@account.id).for_date(@enddate)
    if @account
       @sum = Item.for_account(@account.id).until_date(@enddate).sum(:amount) 
    else
      @sum = Item.until_date(@enddate).sum(:amount)
    end
    @income = Item.income.for_account(@account.id).for_date(@enddate).sum(:amount)
    @expenses = Item.expenses.for_account(@account.id).for_date(@enddate).sum(:amount)
    
    @last_month_income = Item.income.for_account(@account.id).for_current_date(@lastmonth).sum(:amount)    
    @last_month_expenses = Item.expenses.for_account(@account.id).for_current_date(@lastmonth).sum(:amount)
    
    sort_items #sort items according to order param
  end
  
  
  # show graph of monthly saldo, expenses, income development
  def course
    @include_graph_scripts = true
    Account.all.each do |account|
      Monthreport.find_or_create(account, Time.now)
    end
    
    if !@account
      @items = Item.without_transfers
      @expenses = Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_date(m.date).sum(:expenses)] }
      @income =   Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_date(m.date).sum(:income  )] }
      @saldo =    Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_date(m.date).sum(:saldo   )] }
    else
      @items = Item.for_account(@account.id).without_transfers
      @expenses = Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_account(@account.id).for_date(m.date).sum(:expenses)] }
      @income =   Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_account(@account.id).for_date(m.date).sum(:income )] }
      @saldo =    Monthreport.grouped_by_date.collect{|m| [m.date, Monthreport.for_account(@account.id).for_date(m.date).sum(:saldo  )] }
    end
  end
  
  
  def overview
    @include_graph_scripts = true

    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    @lastmonth = (Time.now.at_end_of_month == @enddate) ? Time.now - 1.month :  @enddate - 1.month

    if @account 
      @items = Item.for_account(@account.id).for_date(@enddate).without_transfers
      @sum = Item.for_account(@account.id).sum(:amount)
      @income = Item.income.for_account(@account.id).for_date(@enddate).without_transfers.sum(:amount)
      @expenses = Item.expenses.for_account(@account.id).for_date(@enddate).without_transfers.sum(:amount)
    else
      @items = Item.for_date(@enddate).without_transfers
      @sum = Item.sum(:amount)
      @income = Item.income.for_date(@enddate).without_transfers.sum(:amount)
      @expenses = Item.expenses.for_date(@enddate).without_transfers.sum(:amount)
    end

    @expense_categories = categorized_items(@items, 'expenses', @expenses, @lastmonth)
    @income_categories  = categorized_items(@items, 'income', @income, @lastmonth)
  end 
  
  def search
    @sum = Item.sum(:amount)
    
    unless params[:account_id].blank?
      @items = Item.for_account(params[:account_id]).find(:all, 
                  :conditions => ["description LIKE ? or payee LIKE ?", "%#{params[:term]}%","%#{params[:term]}%"], 
                  :order => 'created_at desc')
      @result_saldo = Item.for_account(params[:account_id]).find(:all, 
                  :conditions => ["description LIKE ? or payee LIKE ?", "%#{params[:term]}%","%#{params[:term]}%"]).sum(&:amount) #todo not nice!
    else
      @items = Item.find(:all, 
                  :conditions => ["description LIKE ? or payee LIKE ?", "%#{params[:term]}%","%#{params[:term]}%"], 
                  :order => 'created_at desc')
      @result_saldo = Item.find(:all, 
                  :conditions => ["description LIKE ? or payee LIKE ?", "%#{params[:term]}%","%#{params[:term]}%"]).sum(&:amount) #todo not nice!
    end
    
    render :template => 'accounts/show'
  end
  
  
  def new
    @account = Account.new
  end


  def edit

  end


  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(@account, :notice => 'Konto wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { 
                      flash[:alert] = 'Konto wurde nicht angelegt!'
                      render :action => 'new'
                     }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to(@account, :notice => 'Die Kontodaten wurden erfolgreich ge&auml;ndert.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to '/', :notice => 'Das Konto wurde gel&ouml;scht.' }
      format.xml  { head :ok }
    end
  end
  
  
  protected
  
  
  # retrieve all accounts, they are needed for the sidebar display
  def get_accounts
    @accounts = Account.all
  end
  
  
  # sort items according to sort params in url
  def sort_items
    @items = @items.sort_by(&:created_at) if params[:order] == 'date'
    @items = @items.sort_by(&:created_at).reverse if params[:order] == 'date desc'
    @items = @items.sort_by(&:payee) if params[:order] == 'payee'
    @items = @items.sort_by(&:payee).reverse if params[:order] == 'payee desc'
    @items = @items.sort_by(&:description) if params[:order] == 'descr'
    @items = @items.sort_by(&:description).reverse if params[:order] == 'descr desc'
    @items = @items.sort_by(&:amount) if params[:order] == 'saldo'
    @items = @items.sort_by(&:amount).reverse if params[:order] == 'saldo desc'
    @items = @items.sort_by(&:category_id) if params[:order] == 'cat'
    @items = @items.sort_by(&:category_id).reverse if params[:order] == 'cat desc'
  end
  
  private

  def load_account
    @account = Account.find(params[:id]) if params[:id]
  end
end
