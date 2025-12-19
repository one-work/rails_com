require "application_system_test_case"

class MetaModelsTest < ApplicationSystemTestCase
  setup do
    @com_panel_meta_model = com_panel_meta_models(:one)
  end

  test "visiting the index" do
    visit com_panel_meta_models_url
    assert_selector "h1", text: "Meta Models"
  end

  test "creating a Meta model" do
    visit com_panel_meta_models_url
    click_on "New Meta Model"

    fill_in "Description", with: @com_panel_meta_model.description
    fill_in "Model name", with: @com_panel_meta_model.model_name
    fill_in "Name", with: @com_panel_meta_model.name
    click_on "Create Meta model"

    assert_text "Meta model was successfully created"
    click_on "Back"
  end

  test "updating a Meta model" do
    visit com_panel_meta_models_url
    click_on "Edit", match: :first

    fill_in "Description", with: @com_panel_meta_model.description
    fill_in "Model name", with: @com_panel_meta_model.model_name
    fill_in "Name", with: @com_panel_meta_model.name
    click_on "Update Meta model"

    assert_text "Meta model was successfully updated"
    click_on "Back"
  end

  test "destroying a Meta model" do
    visit com_panel_meta_models_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Meta model was successfully destroyed"
  end
end
