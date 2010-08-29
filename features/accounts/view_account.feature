@account
Feature: View a account
  In order to see all transactions within an account
  I want to be able to view a account

  Background:
  Given an account exists with title: "Giro"

  Scenario: Visiting the account page
    When I go to the "Giro" account page
    Then I should see "Konto bearbeiten"