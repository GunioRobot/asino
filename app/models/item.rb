# Represents a single real transaction on a real bank account
class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  
  before_create :check_for_fixed
  after_create :apply_rulesets
  before_save :remove_from_monthreport
  after_save :add_to_monthreport
  after_destroy :remove_from_monthreport
  
  validates_presence_of :amount, :message => "Bitte geben Sie einen Betrag an!"
  
  
  scope :expenses, where("amount < 0 and transfer = 0")
  scope :income, where("amount > 0 and transfer = 0")
  scope :without_transfers, where("transfer = 0")
  scope :for_account, lambda {|account_id| where("account_id = ?", account_id).order("created_at desc")}
  scope :for_category, lambda {|category_id| where("category_id = ?", category_id).order("created_at desc")}
  scope :for_date, lambda { |date| 
    where("created_at between ? and ?", date.at_beginning_of_month, date.at_end_of_month).order("created_at desc")
  }
  scope :for_current_date, lambda { |date| 
    where("created_at between ? and ?", date.at_beginning_of_month, date.end_of_day).order("created_at desc")
  }

  
  def apply_rulesets
    return if self.account.blank?

    rulesets = Ruleset.where('(account_id is NULL or account_id = ?) and active = 1', self.account_id)
    rulesets.each do |ruleset|      
      ruleset.result = false
      ruleset.rules.each do |rule|
        ruleset.result = self.attributes[rule.affected_attribute].downcase == rule.matching_string.downcase if rule.matchtype == 'exact'
        ruleset.result = self.attributes[rule.affected_attribute].downcase.include? rule.matching_string.downcase if rule.matchtype == 'contains'
      end
      next unless ruleset.result 
      
      case ruleset.action
        when 'set_category'
          apply_set_category_rule(ruleset.action_parameter.to_i)
        else
          next
      end   
    end
  end
  
  
  # apply set_category rule
  def apply_set_category_rule(category_id)
    category = Category.find(category_id)
    self.update_attribute(:category_id, category.id)
    self.update_attribute(:transfer, true) if category.transfer
  end
  
  # more rule methods to follow here...
  
  
  # check if the new payment is a recurring one and set its state to fixed if so.
  def check_for_fixed
    date = Time.now - 1.month
    past_items = Item.where('created_at between ? and ? and payee = ? and amount = ?',
      date.at_beginning_of_month,
      date.at_end_of_month,
      self.payee.strip,
      self.amount)
     
     self.fix = (past_items.empty?) ? 0 : 1
  end
  
  
  
  def add_to_monthreport
    monthreport = Monthreport.find_or_create(self.account, self.created_at)
    if self.amount < 0 # is an expense
      monthreport.expenses += self.amount unless self.transfer?
    else # is an income
      monthreport.income += self.amount unless self.transfer?
    end
    monthreport.saldo += self.amount
    monthreport.save
  end
  
  
  
  def remove_from_monthreport
    return if self.transfer or self.new_record?
    
    begin 
      olditem = Item.find(self.id)
    rescue 
      olditem = self
    end

    time = self.created_at.blank? ? Time.now : self.created_at
    
    monthreport = Monthreport.find_or_create(self.account, time)
    if self.amount < 0 # is an expense
      monthreport.expenses = monthreport.expenses - olditem.amount
    else #is an income
      monthreport.income = monthreport.income - olditem.amount
    end
    monthreport.saldo -= olditem.amount
    monthreport.save
  end
  
end
