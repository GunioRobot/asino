# A ruleset consists of several rules that are applied to new items
class Ruleset < ActiveRecord::Base
  belongs_to :account
  has_many :rules, :dependent => :destroy
  
  cattr_accessor :result
end
