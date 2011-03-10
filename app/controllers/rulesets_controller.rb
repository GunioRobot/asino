# Rulesets have one to n rules that apply to new items
class RulesetsController < ApplicationController

  before_filter :load_ruleset, :only => [:show, :edit, :update, :destroy]
  before_filter :load_accounts, :only => [:index, :new, :edit]

  def index
    @rulesets = params[:account_id] ? Ruleset.where('account_id = ?', params[:account_id]) : Ruleset.all
  end

  def new
    @ruleset = Ruleset.new({:account_id => params[:account_id]})
  end
  
  def create
    @ruleset = Ruleset.new(params[:ruleset])

    respond_to do |format|
      if @ruleset.save
        format.html { redirect_to(edit_ruleset_path(@ruleset), :notice => 'Neue Regel wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @ruleset, :status => :created, :location => @ruleset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ruleset.errors, :status => :unprocessable_entity }
      end
    end
  end


  def edit
    @ruleset.action_parameter = @ruleset.action_parameter.to_i
  end
  

  def update
    respond_to do |format|
      if @ruleset.update_attributes(params[:ruleset])
        format.html { redirect_to(rulesets_path, :notice => 'Die Regel wurde erfolgreich aktualisiert.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ruleset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @ruleset.destroy

    render :update do |page|
      page.visual_effect :blind_up, "ruleset_#{@ruleset.id}", :duration => 0.5
    end
  end

  private

  def load_ruleset
    @ruleset = Ruleset.find(params[:id]) if params[:id]
  end
  
  def load_accounts
    @accounts = Account.all
    @account = Account.find(params[:account_id]) unless params[:account_id].blank?
  end
  
end
