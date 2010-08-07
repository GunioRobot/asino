class Item < ActiveRecord::Base
  belongs_to :category
  belongs_to :account
  
  after_create :apply_rules
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
  
  
  def apply_rules
    return if self.account.blank?
    
    account.rules.each do |rule|
      RAILS_DEFAULT_LOGGER.debug "applying rule: #{rule.title}"
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
