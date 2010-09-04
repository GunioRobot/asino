Then /^the "([^\"]*)" monthreport should be expenses: "([^\"]*)" and income: "([^\"]*)" and saldo: "([^\"]*)"$/ do |title, expenses, income, saldo|
  account = Account.find_by_title(title)
  report = Monthreport.find(:first,:conditions => "account_id = #{account.id} and date = '#{Time.now.at_end_of_month.to_date.to_s(:db)}'")
  report.expenses == expenses.to_i and report.income == income.to_i and report.saldo == saldo.to_i
end
