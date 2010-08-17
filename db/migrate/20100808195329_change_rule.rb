class ChangeRule < ActiveRecord::Migration
  def self.up
    drop_table :rules
    create_table :rules do |t|
      t.integer :ruleset_id
      t.string  :affected_attribute
      t.string  :matching_string

      t.timestamps
    end
  end

  def self.down
  end
end
