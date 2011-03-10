# Observes account instances and makes sure there is a monthreport for each account
class AccountObserver < ActiveRecord::Observer
  
  def after_save(account)
    Monthreport.find_or_create(account, account.created_at)
  end
  
end