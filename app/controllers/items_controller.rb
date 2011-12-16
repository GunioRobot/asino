# Manages items (which you should think of transactions on a bank account). Each transaction creates a new item within an account
class ItemsController < ApplicationController

  before_filter :load_item, :only => [:show, :edit, :update, :destroy, :add_category, :toggle_fix, :new_note, :create_note]
  before_filter :load_accounts, :only => [:new, :edit, :create]

  def index
    @items = Item.all
  end


  def show

  end


  def new
    if params[:account_id]
      @account = Account.find(params[:account_id])
      @item = Item.new({:account_id => params[:account_id]})
    else
      @item = Item.new()
    end
  end


  def edit

  end


  def create
    @account = Account.find(params[:item][:account_id])
    params[:item][:amount] = params[:item][:amount].gsub(',','.')
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(@account, :notice => 'Die Zahlung wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
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



  def destroy
    @item.destroy

    render :update do |page|
      page.visual_effect :blind_up, "item_#{@item.id}", :duration => 0.5
    end
  end


  # change category assignment for an item. Called via ajax.
  def add_category
    @account = Account.find(params[:current_account]) if params[:current_account]
    category = Category.find(params[:item][:category_id].to_i)
    @item.category_id = category.id
    @item.update_attribute(:category_id, params[:item][:category_id])
    @item.update_attribute(:transfer, (category.transfer ? true : false))
    @item.reload
    render :update do |page|
      page.replace_html "item_#{item.id}", :partial => 'items/item_row_cells', :locals => {:item => @item,
                                                                                           :account => @account}
    end
  end


  # Toggle the fix property of an item, indicating that it is a monthly recurring payment. Called via ajax.
  def toggle_fix
    @item.update_attribute(:fix, (@item.fix ? false : true))
    render :update do |page|
      page.replace_html "item_#{@item.id}", :partial => 'items/item_row_cells', :locals => {:item => @item,
                                                                                            :account => @account}
    end
  end


  def get_from_rss
    msg = "Zahlungen wurden aktualisiert."
    failure = false
    accounts = Account.find(:all)
    accounts.each do |account|
      next unless account.feed
      if account.import_from_feed

      else
        msg = "#{account.title} konnte nicht aktualisiert werden, der RSS Feed ist nicht g&uuml;ltig!"
        failure = true
        next
      end
    end
    redirect_to accounts_path, :notice => msg and return unless failure
    redirect_to accounts_path, :alert => msg and return if failure
  end

  private

  def load_item
    @item = Item.find(params[:id]) if params[:id]
  end
end
