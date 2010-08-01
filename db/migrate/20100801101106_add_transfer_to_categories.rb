class AddTransferToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :transfer, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :categories, :transfer
  end
end
