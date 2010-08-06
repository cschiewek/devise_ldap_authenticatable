Feature: Manage logins
  In order to login with Devise LDAP Authenticatable
  As a user
  I want to login with LDAP

  Background:
    Given I check for SSL
    Given the following logins:
      | email                 | password |
      | example.user@test.com | secret  |
  
  Scenario: Login with valid user
    Given I am on the login page
    When I fill in "Email" with "example.user@test.com"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should see "posts#index"
    
  Scenario: Login with invalid user
    Given I am on the login page
    When I fill in "Email" with "example.user@test.com"
    And I fill in "Password" with "wrong"
    And I press "Sign in"
    Then I should see "Invalid email or password"
  
  Scenario: Get redirected to the login page and then login
    When I go to the new post page
    Then I should be on the login page
    When I fill in "Email" with "example.user@test.com"
    And I fill in "Password" with "secret"
    And I press "Sign in"
    Then I should be on the new post page
  
  
  