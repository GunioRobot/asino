# Belonging to a ruleset, these rules are applied when a new item is created
class Rule < ActiveRecord::Base
  belongs_to :ruleset
end
