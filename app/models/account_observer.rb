class AccountObserver < ActiveRecord::Observer
  
  def after_save(account)
    Monthreport.find_or_create(account, account.created_at)
  end
  
end