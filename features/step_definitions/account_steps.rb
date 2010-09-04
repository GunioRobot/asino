Given /^an account exists with title "([^\"]*)"$/ do |title|
  account = Factory.create(:account, :title => title)
end
