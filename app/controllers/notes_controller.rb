# Notes on items are not really an own model, they are attributes of items
class NotesController < ApplicationController
  
  layout false
  
  before_filter :load_item
  
  def create
   @item.update_attributes(params[:item]) 
   render :update do |page|
     page.call 'fb.close'
     page.replace_html "note_#{@item.id}", "<img src='/images/icons/note.png'>"
   end
  end
  
  def destroy
    @item.update_attribute(:note, '') 

    render :update do |page|
      page.call 'fb.close'
      page.replace_html "note_#{@item.id}", ""
    end
  end
  
  private
  
  def load_item
    @item = Item.find(params[:item_id])
  end
  
end