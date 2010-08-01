class Monthreport < ActiveRecord::Base
  belongs_to :account
  
  def self.find_or_create(account, date)
    monthreport = find(:first, :conditions => ["account_id = ? and date = ?", account.id, date.at_end_of_month.to_date.to_s(:db)])
    if monthreport.blank?
      monthreport = Monthreport.new({:account_id => account.id, :date => date.at_end_of_month.to_date.to_s(:db)})
      monthreport.save
    end
    monthreport
  end
end
