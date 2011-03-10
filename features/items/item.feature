@item
Feature: Create a transaction
  In order work with transaction a user should be able to ceate, edit and delete items

  Background:
  Given I am logged in
  And an account exists with title "Giro"
  And there are some default categories
  
  Scenario: Visit the account page, create a new item and edit it
    When I go to the "Giro" account page
    Then I should see "Neue Zahlung eingeben"
    When I follow "Neue Zahlung eingeben"
    Then I should be on the new item page for "Giro" account
    When I fill in "item_amount" with "-100"
    And I fill in "item_payee" with "Testempfänger"
    And I fill in "item_description" with "Testüberweisung -100"
    And I press "Speichern"
    Then I should be on the "Giro" account page
    And I should see "Die Zahlung wurde erfolgreich angelegt." within "#flash"
    And I should see "Testempfänger" within "#item_1"
    And I should see "-100,00 €" within "#saldo"
    And I should see "+0" within "#income"
    And I should see "-100" within "#expenses"
    When I follow "Bearbeiten" within "#item_1"
    Then I should see "Zahlung bearbeiten"
    When I fill in "item_amount" with "-50.00"
    And I fill in "item_payee" with "Bearbeiteter Empfänger"
    And I fill in "item_description" with "Bearbeitet"
    And I press "Speichern"
    Then I should be on the "Giro" account page
    And I should see "Bearbeiteter Empfänger" within "#item_1"
    And I should see "Bearbeitet" within "#item_1"
    And I should see "-50,00 €" within "#item_1"
    And I should see "-50,00 €" within "#saldo"
    And I should see "+0" within "#income"
    And I should see "-50" within "#expenses"
    #When I follow "Löschen" within "#item_1"
    #And I go to the "Giro" account page
    #Then I should not see "Testempfänger"
    


  Scenario: The user manipulates several transactions both with positive and negative values and the monthreport should sum all transactions
    # spend 100
    When  I go to the new item page for "Giro" account
    And I fill in "item_amount" with "-100"
    And I fill in "item_payee" with "Testempfänger"
    And I fill in "item_description" with "Testüberweisung -100"
    And I press "Speichern"
    Then I should see "Die Zahlung wurde erfolgreich angelegt." within "#flash"
    And I should see "Testempfänger"
    And I should see "-100,00 €" within "#saldo"
    And I should see "+0" within "#income"
    And I should see "-100" within "#expenses"
    And the "Giro" monthreport should be expenses: "-100" and income: "0" and saldo: "-100"
    # add 50
    When  I go to the new item page for "Giro" account
    And I fill in "item_amount" with "50"
    And I fill in "item_payee" with "Testempfänger"
    And I fill in "item_description" with "Testüberweisung 50"
    And I press "Speichern"
    Then I should see "Die Zahlung wurde erfolgreich angelegt." within "#flash"
    And I should see "Testempfänger"
    And I should see "-50,00 €" within "#saldo"
    And I should see "+50" within "#income"
    And I should see "-100" within "#expenses"
    And the "Giro" monthreport should be expenses: "-100" and income: "50" and saldo: "-50"
    # spend 7,24
    When  I go to the new item page for "Giro" account
    And I fill in "item_amount" with "-7,24"
    And I fill in "item_payee" with "Testempfänger"
    And I fill in "item_description" with "Testüberweisung -7,24"
    And I press "Speichern"
    Then I should see "Die Zahlung wurde erfolgreich angelegt." within "#flash"
    And the "Giro" monthreport should be expenses: "-107.24" and income: "50" and saldo: "-57.24"
    # edit 7,24 to 205,75
    When I follow "Bearbeiten" within "#item_3"
    When I fill in "item_amount" with "-205.75"
    And I fill in "item_payee" with "Bearbeiteter Empfänger"
    And I fill in "item_description" with "Bearbeitet"
    And I press "Speichern"
    Then I should see "Die Zahlung wurde erfolgreich aktualisiert." within "#flash"
    And the "Giro" monthreport should be expenses: "-205.75" and income: "50" and saldo: "-155.75"
    # edit 50 to 123.87
    When I follow "Bearbeiten" within "#item_2"
    When I fill in "item_amount" with "123.87"
    And I fill in "item_payee" with "Bearbeiteter Empfänger"
    And I fill in "item_description" with "Bearbeitet"
    And I press "Speichern"
    Then I should see "Die Zahlung wurde erfolgreich aktualisiert." within "#flash"
    And the "Giro" monthreport should be expenses: "-205.75" and income: "123.87" and saldo: "-81.88"
    