require "application_system_test_case"

class AcmeAccountsTest < ApplicationSystemTestCase
  setup do
    @com_panel_acme_account = com_panel_acme_accounts(:one)
  end

  test "visiting the index" do
    visit com_panel_acme_accounts_url
    assert_selector "h1", text: "Acme Accounts"
  end

  test "creating a Acme account" do
    visit com_panel_acme_accounts_url
    click_on "New Acme Account"

    fill_in "Email", with: @com_panel_acme_account.email
    fill_in "Kid", with: @com_panel_acme_account.kid
    fill_in "Private pem", with: @com_panel_acme_account.private_pem
    click_on "Create Acme account"

    assert_text "Acme account was successfully created"
    click_on "Back"
  end

  test "updating a Acme account" do
    visit com_panel_acme_accounts_url
    click_on "Edit", match: :first

    fill_in "Email", with: @com_panel_acme_account.email
    fill_in "Kid", with: @com_panel_acme_account.kid
    fill_in "Private pem", with: @com_panel_acme_account.private_pem
    click_on "Update Acme account"

    assert_text "Acme account was successfully updated"
    click_on "Back"
  end

  test "destroying a Acme account" do
    visit com_panel_acme_accounts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Acme account was successfully destroyed"
  end
end
