class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.integer :account_id
      t.string :title
      t.integer :executionorder

      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end
