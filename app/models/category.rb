# A category is used to collect and order items
class Category < ActiveRecord::Base
  has_many :items, :order => 'created_at desc'
  has_many :categories, :order => 'name', :dependent => :destroy
  belongs_to :category
  
  attr_accessor :account_id, :sum, :lastmonth_sum, :percent
end
