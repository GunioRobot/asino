Given /^there are some default categories$/ do
  Factory.create(:category, :name => 'Miete')
  Factory.create(:category, :name => 'Gehalt')
  Factory.create(:category, :name => 'Transfer')
  Factory.create(:category, :name => 'Lebensmittel')
end

Given /^there is a category "([^\"]*)"$/ do |name|
  Factory.create(:category, :name => name)
end

