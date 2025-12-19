require "application_system_test_case"

class MetaColumnsTest < ApplicationSystemTestCase
  setup do
    @com_panel_meta_column = com_panel_meta_columns(:one)
  end

  test "visiting the index" do
    visit com_panel_meta_columns_url
    assert_selector "h1", text: "Meta Columns"
  end

  test "creating a Meta column" do
    visit com_panel_meta_columns_url
    click_on "New Meta Column"

    fill_in "Column limit", with: @com_panel_meta_column.column_limit
    fill_in "Column name", with: @com_panel_meta_column.column_name
    fill_in "Column type", with: @com_panel_meta_column.column_type
    fill_in "Model name", with: @com_panel_meta_column.model_name
    fill_in "Sql type", with: @com_panel_meta_column.sql_type
    click_on "Create Meta column"

    assert_text "Meta column was successfully created"
    click_on "Back"
  end

  test "updating a Meta column" do
    visit com_panel_meta_columns_url
    click_on "Edit", match: :first

    fill_in "Column limit", with: @com_panel_meta_column.column_limit
    fill_in "Column name", with: @com_panel_meta_column.column_name
    fill_in "Column type", with: @com_panel_meta_column.column_type
    fill_in "Model name", with: @com_panel_meta_column.model_name
    fill_in "Sql type", with: @com_panel_meta_column.sql_type
    click_on "Update Meta column"

    assert_text "Meta column was successfully updated"
    click_on "Back"
  end

  test "destroying a Meta column" do
    visit com_panel_meta_columns_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Meta column was successfully destroyed"
  end
end
