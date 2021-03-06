# time:1m55.91s
@api @disablecaptcha @datastore
Feature: Datastore
  In order to know the datastore is working
  As a website user
  I need to be able to add and remove items from the datastore

  Background:
    Given users:
      | name    | mail                | roles           |
      | Gabriel | gabriel@example.com | content creator |
      | Katie   | katie@example.com   | site manager    |
      | Daniel  | daniel@example.com  | content creator |
      | Jaz     | editor@example.com  | editor          |
    Given groups:
      | title    | author  | published |
      | Group 01 | Katie   | Yes       |
      | Group 02 | Katie   | Yes       |
    And group memberships:
      | user    | group    | role on group        | membership status |
      | Gabriel | Group 01 | member               | Active            |
      | Jaz     | Group 01 | administrator member | Active            |
      | Daniel  | Group 02 | member               | Active            |
    Given datasets:
      | title      | publisher | author  | published | description |
      | Dataset 01 | Group 01  | Gabriel | Yes       | Test        |
      | Dataset 02 | Group 02  | Daniel  | Yes       | Test        |
    And "Format" terms:
      | name    |
      | csv     |
    And resources:
      | title       | publisher | format | dataset    | author  | published | description               | link file |
      | Resource 01 | Group 01  | csv    | Dataset 01 | Gabriel | Yes       | The resource description. | https://s3.amazonaws.com/dkan-default-content-files/files/datastore-simple.csv |
      | Resource 02 | Group 02  | csv    | Dataset 02 | Daniel  | Yes       | The resource description. | https://s3.amazonaws.com/dkan-default-content-files/files/datastore-simple2.csv |

  # Don't remove! This is for avoiding issues when scenarios are skipped.
  Scenario: Dumb test
    Given I am on the homepage

  @datastore_01 @javascript
  Scenario: Adding and Removing items from the datastore
  # @resource_sm_05 captures this scenario.

  @datastore_02 @api
  Scenario: Anonymous users should not be able to manage datastores
    Given I am an anonymous user
    Then I "should not" be able to manage the "Resource 01" datastore

  @datastore_03 @api @javascript
  Scenario: Content Creators should be able to manage only datastores
  associated with the resources they own
    Given I am logged in as "Gabriel"
    Then I "should" be able to manage the "Resource 01" datastore
    Given I am logged in as "Daniel"
    Then I "should not" be able to manage the "Resource 01" datastore

  @datastore_04 @api
  Scenario: Editors should be able to manage only datastores associated with
  resources created by members of their groups
    Given I am logged in as "Jaz"
    Then I "should" be able to manage the "Resource 01" datastore
    And I "should not" be able to manage the "Resource 02" datastore

  @datastore_05 @api
  Scenario: Site Managers should be able to manage any datastore
    Given I am logged in as "Katie"
    Then I "should" be able to manage the "Resource 01" datastore
    And I "should" be able to manage the "Resource 02" datastore 

  @datastore_06 @api @noworkflow @datastore @javascript @fixme
  Scenario: Import a csv tab delimited file.
    Given endpoints:
      | name             | path                   |
      | dataset rest api | /api/dataset           |
    And I use the "dataset rest api" endpoint to login with user "admin" and pass "admin"
    And I use the "dataset rest api" endpoint to attach the file "dkan/TAB_delimiter_large_raw_number.csv" to "Resource 03"
    And I am logged in as a user with the "site manager" role
    When I am on "dataset/dataset-02"
    And I click "Resource 03"
    And I click "Edit"
    And I press "Save"
    Then I should see "Resource Resource 03 has been updated"
    And I click "Manage Datastore"
    #Then I wait for "DKAN Datastore File: Status"
    And I select "TAB" from "edit-feedscsvparser-delimiter"
    And I press "Import"
    And I wait for "5" seconds
    Then I should see "5 imported items total."
    When I click "View"
    And I wait for "5" seconds
    Then I should see exactly "30" ".slick-cell" in region "recline preview"