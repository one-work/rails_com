require "application_system_test_case"

class AcmeAuthorizationsTest < ApplicationSystemTestCase
  setup do
    @com_panel_acme_authorization = com_panel_acme_authorizations(:one)
  end

  test "visiting the index" do
    visit com_panel_acme_authorizations_url
    assert_selector "h1", text: "Acme Authorizations"
  end

  test "creating a Acme authorization" do
    visit com_panel_acme_authorizations_url
    click_on "New Acme Authorization"

    fill_in "Domain", with: @com_panel_acme_authorization.domain
    fill_in "File content", with: @com_panel_acme_authorization.file_content
    fill_in "File name", with: @com_panel_acme_authorization.file_name
    fill_in "Identifier", with: @com_panel_acme_authorization.identifier
    fill_in "Record content", with: @com_panel_acme_authorization.record_content
    fill_in "Record name", with: @com_panel_acme_authorization.record_name
    click_on "Create Acme authorization"

    assert_text "Acme authorization was successfully created"
    click_on "Back"
  end

  test "updating a Acme authorization" do
    visit com_panel_acme_authorizations_url
    click_on "Edit", match: :first

    fill_in "Domain", with: @com_panel_acme_authorization.domain
    fill_in "File content", with: @com_panel_acme_authorization.file_content
    fill_in "File name", with: @com_panel_acme_authorization.file_name
    fill_in "Identifier", with: @com_panel_acme_authorization.identifier
    fill_in "Record content", with: @com_panel_acme_authorization.record_content
    fill_in "Record name", with: @com_panel_acme_authorization.record_name
    click_on "Update Acme authorization"

    assert_text "Acme authorization was successfully updated"
    click_on "Back"
  end

  test "destroying a Acme authorization" do
    visit com_panel_acme_authorizations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Acme authorization was successfully destroyed"
  end
end
