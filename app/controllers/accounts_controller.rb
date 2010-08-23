class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  
  before_filter :get_accounts
  
  def index
    render :action => 'no_accounts' and return if @accounts.empty?
    
    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    @lastmonth = (Time.now.at_end_of_month == @enddate) ? Time.now - 1.month :  @enddate - 1.month
    
    @sum = Item.sum(:amount)
                           
    @items = Item.for_date(@enddate)
    @income = Item.income.for_date(@enddate).sum(:amount)
    @expenses = Item.expenses.for_date(@enddate).sum(:amount)
    
    @last_month_income = Item.income.for_current_date(@lastmonth).sum(:amount)    
    @last_month_expenses = Item.expenses.for_current_date(@lastmonth).sum(:amount)

    respond_to do |format|
      format.html { render :action => 'show'}
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])
    
    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    @lastmonth = Time.now.at_end_of_month == @enddate ? Time.now :  @enddate - 1.month
    
    @items = Item.for_account(@account.id).for_date(@enddate)
    @sum = Item.for_account(@account.id).sum(:amount) if @account
    @sum = Item.sum(:amount) unless @account
    @income = Item.income.for_account(@account.id).for_date(@enddate).sum(:amount)
    @expenses = Item.expenses.for_account(@account.id).for_date(@enddate).sum(:amount)
    
    @last_month_income = Item.income.for_account(@account.id).for_current_date(@lastmonth).sum(:amount)    
    @last_month_expenses = Item.expenses.for_account(@account.id).for_current_date(@lastmonth).sum(:amount)
    
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  def overview
    @account = Account.find(params[:id]) if params[:id]
    
    @enddate = (Time.now + @month.to_i.months).at_end_of_month
    @startdate = @enddate.at_beginning_of_month
    
    #@month = params[:month].to_i || 0
    
    @categories_sum = 0
    
    if @account 
      @items = Item.for_account(@account.id).without_transfers.for_date(@enddate)
      @sum = Item.for_account(@account.id).sum(:amount)
      @income = Item.income.for_account(@account.id).for_date(@enddate).without_transfers.sum(:amount)
      @expenses = Item.expenses.for_account(@account.id).for_date(@enddate).without_transfers.sum(:amount)
    else
      @items = Item.for_date(@enddate).without_transfers
      @sum = Item.sum(:amount)
      @income = Item.income.for_date(@enddate).without_transfers.sum(:amount)
      @expenses = Item.expenses.for_date(@enddate).without_transfers.sum(:amount)
    end
    
    @items_by_category = @items.group_by { |i| i.category }
    @categories = []
    @items_by_category.each do |category, items|
      next unless category
      category.sum = 0
      items.each do |item|
        category.sum += item.amount if item.amount < 0
        category.items << item
      end
      @categories << category
      @categories_sum += category.sum
    end 
    
    @categories = @categories.sort{|l,m| l.sum <=> m.sum}
  end
  
  
  def course
    @account = Account.find(params[:id]) if params[:id]
    
    if !@account
      @expenses = Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("expenses", :conditions => "date='#{m.date}'")] }
      @income =   Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("income",   :conditions => "date='#{m.date}'")] }
      @saldo =    Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("saldo",    :conditions => "date='#{m.date}'")] }
    else
      @expenses = Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("expenses", :conditions => "date='#{m.date}' and account_id = #{@account.id}")] }
      @income =   Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("income",   :conditions => "date='#{m.date}' and account_id = #{@account.id}")] }
      @saldo =    Monthreport.all(:group => "date").collect{|m| [m.date, Monthreport.sum("saldo",    :conditions => "date='#{m.date}' and account_id = #{@account.id}")] }
    end

    
    monthreports = Monthreport.find(:all, :conditions => ["account_id = ? and date > ?", params[:id], '1980-01-01'], :order => 'date')

  end
  
  
  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(@account, :notice => 'Konto wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to(@account, :notice => 'Account was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to '/', :notice => 'Das Konto wurde gelöscht.' }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  # retrieve all accounts, they are needed for the sidebar display
  def get_accounts
    @accounts = Account.all
  end
end
