class Ruleset < ActiveRecord::Base
  belongs_to :account
  has_many :rules, :dependent => :destroy
  
  cattr_accessor :result
end
