class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  
  after_create :apply_rulesets
  after_save :add_to_monthreport
  after_destroy :remove_from_monthreport
  
  
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
  
  def add_to_monthreport
    return if self.transfer
    
    monthreport = Monthreport.find_or_create(self.account, self.created_at)
    if self.amount <= 0
      monthreport.expenses += self.amount
    else
      monthreport.income += self.amount
    end
    monthreport.saldo = self.account.items.sum(:amount, :conditions => ["created_at <= ?", self.created_at.at_end_of_month.to_date.to_s(:db)])
    monthreport.save
  end
  
  def remove_from_monthreport
    return if self.transfer
    
    monthreport = Monthreport.find_or_create(self.account, self.created_at)
    if self.amount < 0
      monthreport.expenses = monthreport.expenses - self.amount
    else
      monthreport.income = monthreport.expenses - self.amount
    end
    monthreport.saldo = self.account.items.sum(:amount, :conditions => ["created_at <= ?", self.created_at.at_end_of_month.to_date.to_s(:db)])
    monthreport.save
  end
  
end
