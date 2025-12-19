require "application_system_test_case"

class AcmeOrdersTest < ApplicationSystemTestCase
  setup do
    @com_panel_acme_order = com_panel_acme_orders(:one)
  end

  test "visiting the index" do
    visit com_panel_acme_orders_url
    assert_selector "h1", text: "Acme Orders"
  end

  test "creating a Acme order" do
    visit com_panel_acme_orders_url
    click_on "New Acme Order"

    fill_in "File content", with: @com_panel_acme_order.file_content
    fill_in "File name", with: @com_panel_acme_order.file_name
    fill_in "Identifiers", with: @com_panel_acme_order.identifiers
    fill_in "Record content", with: @com_panel_acme_order.record_content
    fill_in "Record name", with: @com_panel_acme_order.record_name
    click_on "Create Acme order"

    assert_text "Acme order was successfully created"
    click_on "Back"
  end

  test "updating a Acme order" do
    visit com_panel_acme_orders_url
    click_on "Edit", match: :first

    fill_in "File content", with: @com_panel_acme_order.file_content
    fill_in "File name", with: @com_panel_acme_order.file_name
    fill_in "Identifiers", with: @com_panel_acme_order.identifiers
    fill_in "Record content", with: @com_panel_acme_order.record_content
    fill_in "Record name", with: @com_panel_acme_order.record_name
    click_on "Update Acme order"

    assert_text "Acme order was successfully updated"
    click_on "Back"
  end

  test "destroying a Acme order" do
    visit com_panel_acme_orders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Acme order was successfully destroyed"
  end
end
