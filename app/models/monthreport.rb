class Monthreport < ActiveRecord::Base
  belongs_to :account
  
  def self.find_or_create(account, date)
    monthreport = find(:first, :conditions => ["account_id = ? and date = ?", account.id, date.at_end_of_month.to_date.to_s(:db)])
    if monthreport.blank?
      
      sum = Item.sum(:amount, :conditions => ["created_at < ? and account_id = ?", date.at_beginning_of_month.to_date.to_s(:db), account.id])
      puts "Setting init value for #{date} to #{sum}"
      monthreport = Monthreport.new({:account_id => account.id, :date => date.at_end_of_month.to_date.to_s(:db), :saldo => sum})
      monthreport.save
      puts "Stored value is #{monthreport.saldo}"
    end
    monthreport
  end

end
