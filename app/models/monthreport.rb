# Monthreport instances collect monthly data for an account. They are basically data caches to speed up account statistics
class Monthreport < ActiveRecord::Base
  
  belongs_to :account

  scope :for_account, lambda {|account_id| where("account_id = ?", account_id)}
  scope :for_date,    lambda {|date| where("date = ?", date)}            
  scope :grouped_by_date, :group => :date
  
  def self.find_or_create(account, date)
    monthreport = Monthreport.where('account_id = ? and date = ?', account.id, date.at_end_of_month.to_date.to_s(:db)).first
    if monthreport.blank?
      sum = Item.where('created_at < ? and account_id = ?', date.at_beginning_of_month.to_date.to_s(:db), account.id).sum('amount')
      monthreport = Monthreport.new({:account_id => account.id, :date => date.at_end_of_month, :saldo => sum})
      monthreport.save
    end
    monthreport
  end

end
