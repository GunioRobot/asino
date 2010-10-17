Given /^I am logged in$/ do
  user = Factory(:user)
  #user.register!
  visit "/login" 
  fill_in("login", :with => user.login)
  fill_in("password", :with => user.password)
  click_button("Anmelden")
end
