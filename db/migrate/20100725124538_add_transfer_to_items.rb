class AddTransferToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :transfer, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :items, :transfer
  end
end
