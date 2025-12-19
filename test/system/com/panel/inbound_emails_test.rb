require "application_system_test_case"

class InboundEmailsTest < ApplicationSystemTestCase
  setup do
    @com_panel_inbound_email = com_panel_inbound_emails(:one)
  end

  test "visiting the index" do
    visit com_panel_inbound_emails_url
    assert_selector "h1", text: "Inbound Emails"
  end

  test "creating a Inbound email" do
    visit com_panel_inbound_emails_url
    click_on "New Inbound Email"

    click_on "Create Inbound email"

    assert_text "Inbound email was successfully created"
    click_on "Back"
  end

  test "updating a Inbound email" do
    visit com_panel_inbound_emails_url
    click_on "Edit", match: :first

    click_on "Update Inbound email"

    assert_text "Inbound email was successfully updated"
    click_on "Back"
  end

  test "destroying a Inbound email" do
    visit com_panel_inbound_emails_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Inbound email was successfully destroyed"
  end
end
