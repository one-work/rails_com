require "application_system_test_case"

class AcmeIdentifiersTest < ApplicationSystemTestCase
  setup do
    @com_panel_acme_identifier = com_panel_acme_identifiers(:one)
  end

  test "visiting the index" do
    visit com_panel_acme_identifiers_url
    assert_selector "h1", text: "Acme Identifiers"
  end

  test "creating a Acme identifier" do
    visit com_panel_acme_identifiers_url
    click_on "New Acme Identifier"

    fill_in "Domain", with: @com_panel_acme_identifier.domain
    fill_in "File content", with: @com_panel_acme_identifier.file_content
    fill_in "File name", with: @com_panel_acme_identifier.file_name
    fill_in "Identifier", with: @com_panel_acme_identifier.identifier
    fill_in "Record content", with: @com_panel_acme_identifier.record_content
    fill_in "Record name", with: @com_panel_acme_identifier.record_name
    click_on "Create Acme identifier"

    assert_text "Acme identifier was successfully created"
    click_on "Back"
  end

  test "updating a Acme identifier" do
    visit com_panel_acme_identifiers_url
    click_on "Edit", match: :first

    fill_in "Domain", with: @com_panel_acme_identifier.domain
    fill_in "File content", with: @com_panel_acme_identifier.file_content
    fill_in "File name", with: @com_panel_acme_identifier.file_name
    fill_in "Identifier", with: @com_panel_acme_identifier.identifier
    fill_in "Record content", with: @com_panel_acme_identifier.record_content
    fill_in "Record name", with: @com_panel_acme_identifier.record_name
    click_on "Update Acme identifier"

    assert_text "Acme identifier was successfully updated"
    click_on "Back"
  end

  test "destroying a Acme identifier" do
    visit com_panel_acme_identifiers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Acme identifier was successfully destroyed"
  end
end
