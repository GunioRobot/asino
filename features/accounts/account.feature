@account
Feature: View a account
  In order to see all transactions within an account
  I want to be able to create and view an account

  Background:
  Given I am logged in

  Scenario: Create a new account
    When I go to the new account page
    Then I should see "RSS Feed einrichten" within "#note"
    When I fill in "account_title" with "Giro"
    And I press "Speichern"
    Then I should be on the "Giro" account page
    And I should see "Konto wurde erfolgreich angelegt." within "#flash"
    And I should see "Giro:" within "#pagetitle"
    And I should see "Für dieses Konto wurden noch keine Zahlungen eingegeben."
    And I should see "Neue Zahlung" within "#sidebar"
    And I should see "Neue Zahlung eingeben"
    And I should see "Einnahmen: +0,00 €"
    And I should see "Ausgaben: 0,00 €"
    And I should see "Gesamt 0,00 €"

  Scenario: Try to create a new account without title
    When I go to the new account page
    And I press "Speichern"
    Then I should see "Konto wurde nicht angelegt!" within "#flash"
    And I should see "Bitte geben Sie dem Konto einen Namen!"

  Scenario: Try to create a new account without title that already exists
    Given an account exists with title "Giro"
    When I go to the new account page
    When I fill in "account_title" with "Giro"
    And I press "Speichern"
    Then I should see "Konto wurde nicht angelegt!" within "#flash"
    And I should see "Dieser Kontoname wird bereits verwendet!"