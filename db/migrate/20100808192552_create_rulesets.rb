class CreateRulesets < ActiveRecord::Migration
  def self.up
    create_table :rulesets do |t|
      t.string :name
      t.integer :account_id
      t.boolean :active, :null => false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :rulesets
  end
end
