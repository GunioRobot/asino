class AddNoteToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :note, :string
  end

  def self.down
    remove_column :items, :note
  end
end
