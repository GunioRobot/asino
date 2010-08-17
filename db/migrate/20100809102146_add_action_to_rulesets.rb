class AddActionToRulesets < ActiveRecord::Migration
  def self.up
    add_column :rulesets, :action, :string
    add_column :rulesets, :action_parameter, :string
  end

  def self.down
    remove_column :rulesets, :action_parameter
    remove_column :rulesets, :action
  end
end
