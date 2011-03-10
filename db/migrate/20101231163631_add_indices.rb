class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :categories,          :category_id
    add_index :items,               :account_id
    add_index :items,               :category_id
    add_index :monthreports,        :account_id
    add_index :rules,               :ruleset_id
    add_index :rulesets,            :account_id
  end

  def self.down
  end
end
