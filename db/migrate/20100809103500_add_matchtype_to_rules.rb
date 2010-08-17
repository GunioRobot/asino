class AddMatchtypeToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :matchtype, :string
  end

  def self.down
    remove_column :rules, :matchtype
  end
end
