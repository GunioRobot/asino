Given /^I am logged in$/ do
  user = Factory(:user)
  #user.register!
  visit "/users/sign_in" 
  fill_in("user_username", :with => user.username)
  fill_in("user_password", :with => user.password)
  click_button("Anmelden")
end
