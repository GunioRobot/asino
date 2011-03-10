# Manages rules that are part of rulesets
class RulesController < ApplicationController

  before_filter :load_rule, :only => [:show, :edit, :update, :destroy]


  # GET /rules/new
  # GET /rules/new.xml
  def new
    @rule = Rule.new
  end

  # GET /rules/1/edit
  def edit

  end

  # POST /rules
  # POST /rules.xml
  def create
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        format.html { redirect_to(edit_ruleset_path(@rule.ruleset), :notice => 'Die neue Bedingung wurde angelegt.') }
        format.xml  { render :xml => @rule, :status => :created, :location => @rule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rules/1
  # PUT /rules/1.xml
  def update
    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        format.js   
        format.html { redirect_to(@rule, :notice => 'Rule was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /rules/1
  # DELETE /rules/1.xml
  def destroy
    @rule.destroy
    render :update do |page|
      page.hide("rule_#{@rule.id}")
    end
  end

  private

  def load_rule
    @rule = Rule.find(params[:id]) if params[:id]
  end
end
