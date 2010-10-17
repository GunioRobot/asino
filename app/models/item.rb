class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  
  before_create :check_for_fixed
  after_create :apply_rulesets
  before_save :remove_from_monthreport
  after_save :add_to_monthreport
  after_destroy :remove_from_monthreport
  
  validates_presence_of :amount, :message => "Bitte geben Sie einen Betrag an!"
  
  
  named_scope :expenses, :conditions => ['amount < 0 and transfer = 0']
  named_scope :income, :conditions => ['amount > 0 and transfer = 0']
  named_scope :without_transfers, :conditions => ['transfer = 0']
  
  named_scope :for_account, 
              (lambda do |account_id| 
                      {:conditions => ['account_id = ?', account_id],
                        :order => 'created_at desc'}
                end)

  # returns all items within a month indicated by date
  named_scope :for_date, 
              (lambda do |date| 
                      {:conditions => ['created_at between ? and ?',
                                        date.at_beginning_of_month.to_s(:db),
                                        date.at_end_of_month.to_s(:db)],
                        :order => 'created_at desc'}
                end)  
                
named_scope :for_current_date, 
            (lambda do |date| 
                    {:conditions => ['created_at between ? and ?',
                                      date.at_beginning_of_month.to_s(:db),
                                      date.end_of_day.to_s(:db)],
                      :order => 'created_at desc'}
              end)
  
  
  def apply_rulesets
    return if self.account.blank?
    
    rulesets = Ruleset.find(:all, :conditions => ["account_id is NULL or account_id = ?", self.account_id])
    
    rulesets.each do |ruleset|
      next unless ruleset.active
      
      ruleset.result = false
      ruleset.rules.each do |rule|
        ruleset.result = self.attributes[rule.affected_attribute].downcase == rule.matching_string.downcase if rule.matchtype == 'exact'
        ruleset.result = self.attributes[rule.affected_attribute].downcase.include? rule.matching_string.downcase if rule.matchtype == 'contains'
      end
      next unless ruleset.result 
      
      case ruleset.action
        when 'set_category'
          category = Category.find(ruleset.action_parameter.to_i)
          self.update_attribute(:category_id, category.id)
          self.update_attribute(:transfer, true) if category.transfer
      end
      
    end
    
  end
  
  
  # check if the new payment is a recurring one and set its state to fixed if so.
  def check_for_fixed
    date = Time.now - 1.month
    past_items = Item.find(:all, :conditions => ["created_at between ? and ? and payee = ? and amount = ?",
     date.at_beginning_of_month.to_s(:db),
     date.at_end_of_month.to_s(:db),
     self.payee.strip,
     self.amount * -1])
     self.fix = ((past_items.empty?) ? 0 : 1)
  end
  
  
  
  def add_to_monthreport
    return if self.transfer
    
    RAILS_DEFAULT_LOGGER.debug "add to monthreport: #{self.amount}"
    
    monthreport = Monthreport.find_or_create(self.account, self.created_at)
    if self.amount < 0 # is an expense
      monthreport.expenses += self.amount
    else # is an income
      monthreport.income += self.amount
    end
    monthreport.saldo += self.amount
    monthreport.save
  end
  
  
  
  def remove_from_monthreport
    return if self.transfer
    return if self.new_record?
    
    begin 
      olditem = Item.find(self.id)
    rescue 
      olditem = self
    end
    
    RAILS_DEFAULT_LOGGER.debug "removing from monthreport: #{self.amount}"
    
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
