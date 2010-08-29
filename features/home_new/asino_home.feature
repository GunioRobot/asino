@home
Feature: Home page
  In order to see the home page
  As a new user
  I want to be able to create a new account

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

  Scenario: Create a new account
    When I go to the new account page
    Then I should see "RSS Feed einrichten" within "#note"
    When I fill in "account_title" with "Giro"
    And I press "Speichern"
    Then I should be on the "Giro" account page
    And I should see "Konto wurde erfolgreich angelegt." within "#flash"
    And I should see "Übersicht Giro"
    And I should see "Für dieses Konto wurden noch keine Zahlungen eingegeben."
    And I should see "Neue Zahlung" within "#sidebar"
    And I should see "Neue Zahlung eingeben"
    And I should see "Einnahmen: +0,00 €"
    And I should see "Ausgaben: 0,00 €"
    And I should see "Gesamt 0,00 €"