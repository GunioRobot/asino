class AddFixToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :fix, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :items, :fix
  end
end
