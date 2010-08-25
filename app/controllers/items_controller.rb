class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @items = Item.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @accounts = Account.all
    @account = Account.find(params[:account_id])
    @item = Item.new({:account_id => params[:account_id]})

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @accounts = Account.all
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    account = Account.find(params[:item][:account_id])
    params[:item][:amount] = params[:item][:amount].gsub(',','.')
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(account, :notice => 'Die Zahlung wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])
    params[:item][:amount] = params[:item][:amount].gsub(',','.')

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(@item.account, :notice => 'Die Zahlung wurde erfolgreich aktualisiert.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    render :update do |page|
      page.visual_effect :blind_up, "item_#{@item.id}", :duration => 0.5
    end
  end
  
  def add_category
    item = Item.find(params[:id])
    category = Category.find(params[:item][:category_id].to_i)
    item.category_id = category.id
    item.update_attribute(:category_id, params[:item][:category_id])
    item.update_attribute(:transfer, (category.transfer ? true : false))
    item.reload
    render :update do |page|
      page.replace_html "item_#{item.id}", :partial => 'items/item_row_cells', :locals => {:item => item}
    end
  end
  
  
  def get_from_rss
    msg = "Zahlungen wurden aktualisiert."
    failure = false
    accounts = Account.find(:all)
    accounts.each do |account|
      next if account.feed.blank?
      if account.import_from_feed
      
      else
        msg = "#{account.title} konnte nicht aktualisiert werden, der RSS Feed ist nicht gültig!"
        failure = true 
        next
      end
    end
    redirect_to accounts_path, :notice => msg and return unless failure
    redirect_to accounts_path, :alert => msg and return if failure
  end
end
