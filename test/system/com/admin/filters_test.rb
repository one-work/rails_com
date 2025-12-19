require "application_system_test_case"

class FiltersTest < ApplicationSystemTestCase
  setup do
    @com_admin_filter = com_admin_filters(:one)
  end

  test "visiting the index" do
    visit com_admin_filters_url
    assert_selector "h1", text: "Filters"
  end

  test "should create filter" do
    visit com_admin_filters_url
    click_on "New filter"

    fill_in "Name", with: @com_admin_filter.name
    click_on "Create Filter"

    assert_text "Filter was successfully created"
    click_on "Back"
  end

  test "should update Filter" do
    visit com_admin_filter_url(@com_admin_filter)
    click_on "Edit this filter", match: :first

    fill_in "Name", with: @com_admin_filter.name
    click_on "Update Filter"

    assert_text "Filter was successfully updated"
    click_on "Back"
  end

  test "should destroy Filter" do
    visit com_admin_filter_url(@com_admin_filter)
    click_on "Destroy this filter", match: :first

    assert_text "Filter was successfully destroyed"
  end
end
