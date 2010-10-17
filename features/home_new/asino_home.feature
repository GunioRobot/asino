@home
Feature: Home page
  In order to see the home page
  As a new user
  I want to be able to create a new account

  Background:
  Given I am logged in

  Scenario: Visiting the home page without having an account
    When I go to the home page
    Then I should see "Sie haben noch keine Konten angelegt."
    And I should see "Neues Konto anlegen"
    And I should see "Willkommen" within "#note"
    But I should not see "Neue Zahlung" within "#sidebar"

  Scenario: Visiting the homepage without an account I should be able to create an account
    When I go to the home page
    And I follow "Neues Konto anlegen"
    Then I should be on the new account page