class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.xml
  
  before_filter :get_accounts
  
  def index
    render :action => 'no_accounts' and return if @accounts.empty?
    
    @enddate = Time.now.at_end_of_month
    @enddate = (Time.now + params[:month].to_i.months).at_end_of_month if params[:month]
    @startdate = @enddate.at_beginning_of_month
    
    @month = params[:month].to_i || 0
    
    @items = Item.find(:all, :conditions => ["created_at > ? and created_at < ?",  @startdate, @enddate ], :order => 'created_at desc')
    #@sum = @items.sum(&:amount)
    @sum = Item.sum(:amount, :conditions => ["transfer = 0"])
    @income = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and amount > 0',
                                      @startdate, @enddate])
    @expenses = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and amount < 0',
                                      @startdate, @enddate])

    respond_to do |format|
      format.html { render :action => 'show'}
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])
    
    @enddate = Time.now.at_end_of_month
    @enddate = (Time.now + params[:month].to_i.months).at_end_of_month if params[:month]
    @startdate = @enddate.at_beginning_of_month
    
    @month = params[:month].to_i || 0
    
    @items = Item.find(:all, :conditions => ["account_id = ? and created_at > ? and created_at < ?", @account.id, @startdate, @enddate ], :order => 'created_at desc')
    @sum = @account.items.sum(:amount)
    @income = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and account_id = ? and amount > 0',
                                      @startdate, @enddate, @account.id])
    @expenses = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and account_id = ? and amount < 0',
                                      @startdate, @enddate, @account.id])
    
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
    
    @enddate = Time.now.at_end_of_month
    @enddate = (Time.now + params[:month].to_i.months).at_end_of_month if params[:month]
    @startdate = @enddate.at_beginning_of_month
    
    @month = params[:month].to_i || 0
    
    @categories_sum = 0
    #@categories_expenses = 0
    
    if @account 
      @items = Item.find(:all, :conditions => ["account_id = ? and created_at > ? and created_at < ? and transfer = 0", @account.id, @startdate, @enddate ])
      @income = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and account_id = ? and amount > 0',
                                        @startdate, @enddate, @account.id])
      @expenses = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and transfer = 0 and account_id = ? and amount < 0',
                                        @startdate, @enddate, @account.id])
    else
      @items = Item.find(:all, :conditions => ["(account_id = ? or account_id = ?) and created_at > ? and created_at < ? and transfer = 0", 1, 2, @startdate, @enddate ])
      @income = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and amount > 0 and transfer = 0',
                                        @startdate, @enddate])
      @expenses = Item.sum(:amount, :conditions => ['created_at >= ? and created_at <= ? and amount < 0 and transfer = 0',
                                        @startdate, @enddate])
    end
    @items_by_category = @items.group_by { |i| i.category }
    @items_by_category.each do |category, items|
      next unless category
      category.sum = 0
      items.each do |item|
        category.sum += item.amount
      end
      @categories_sum += category.sum
    end 
    
    pc = GoogleChart::PieChart.new('600x350', "Ausgaben nach Kategorien",false)
    @items_by_category.each do |category, items|
      next unless category
      pc.data category.name, category.sum * -1 if category.sum < 0
    end
    @piechart = pc.to_url
  end
  
  
  def course
    @account = Account.find(params[:id]) if params[:id]
    
    monthreports = Monthreport.find(:all, :conditions => ["account_id = ? and date > ?", params[:id], '1980-01-01'], :order => 'date')

    bc = GoogleChart::BarChart.new('600x400', "Verlauf", :vertical, false)
    bc.data "Ausgaben", monthreports.collect {|m| m.expenses * -1}, 'ff9900' 
    bc.data "Einnahmen", monthreports.collect {|m| m.income}, 'ffd799'   
    bc.data "Kontostand", monthreports.collect {|m| m.saldo},'ffebcc'
    bc.data "", monthreports.collect {|m| 0}, 'ffffff'
    bc.axis :x, :labels => monthreports.collect {|m| m.date.strftime("%B %y")}, 
                :color => '000000'
    @barchart = bc.to_url

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
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  # retrieve all accounts, they are needed for the sidebar display
  def get_accounts
    @accounts = Account.all
  end
end
