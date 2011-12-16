# Manages categories that apply to items
class CategoriesController < ApplicationController

  before_filter :load_category, :only => [:show, :edit, :update, :destroy]
  before_filter :load_accounts, :only => [:index, :new, :edit]

  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.where('category_id is NULL').order('name').includes(:categories, :items)
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show

  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new({:account_id => params[:account_id]})
  end

  # GET /categories/1/edit
  def edit

  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(categories_path, :notice => 'Neue Kategorie wurde erfolgreich angelegt.') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(categories_path, :notice => 'Die &Auml;nderungen an der Kategorie wurden gespeichert.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end

  private

  def load_category
    @category = Category.find(params[:id]) if params[:id]
  end

end
