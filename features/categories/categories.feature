@category
Feature: Create a category
  In order to see all transactions within an account
  I want to be able to create and view an account

  Background:
  Given I am logged in

  Scenario: Follow home page link to categories
    When I am on the home page
    And I follow "Kategorien"
    Then I should be on the categories page

  Scenario: Follow new category ling from account page
    Given an account exists with title "Giro"
    And I am on the "Giro" account page
    Then I should see "Kategorien"
    When I follow "Kategorien"
    Then I should see "Kategorien verwalten" within "#pagetitle"
    And I should see "Neue Kategorie anlegen"
    When I follow "Neue Kategorie anlegen"
    Then I should be on the new category page

  Scenario: Create a new category
    When I am on the categories page
    And I follow "Neue Kategorie anlegen"
    Then I should be on the new category page
    When I fill in "category_name" with "Testkategorie"
    And I press "Speichern"
    Then I should be on the categories page
    And I should see "Neue Kategorie wurde erfolgreich angelegt." within "#flash"
    And I should see "Testkategorie"

  Scenario: Edit a category
    Given there is a category "Testkategorie"
    And I am on the categories page
    When I follow "Bearbeiten" within "#category_1"
    Then I should see "Kategorie bearbeiten"
    When I fill in "category_name" with "Däs is a a Töst"
    And I press "Speichern"
    Then I should be on the categories page
    And I should see "Die &Auml;nderungen an der Kategorie wurden gespeichert." within "#flash"
    And I should see "Däs is a a Töst"
