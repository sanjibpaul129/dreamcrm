require 'test_helper'

class FlatsControllerTest < ActionController::TestCase
  setup do
    @flat = flats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flat" do
    assert_difference('Flat.count') do
      post :create, flat: { OTA: @flat.OTA, SBA: @flat.SBA, balconies: @flat.balconies, bathrooms: @flat.bathrooms, block_id: @flat.block_id, flat_bua: @flat.flat_bua, flat_bua_markup: @flat.flat_bua_markup, floor: @flat.floor, name: @flat.name, ot_bua: @flat.ot_bua, ot_bua_markdown: @flat.ot_bua_markdown, status: @flat.status }
    end

    assert_redirected_to flat_path(assigns(:flat))
  end

  test "should show flat" do
    get :show, id: @flat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flat
    assert_response :success
  end

  test "should update flat" do
    patch :update, id: @flat, flat: { OTA: @flat.OTA, SBA: @flat.SBA, balconies: @flat.balconies, bathrooms: @flat.bathrooms, block_id: @flat.block_id, flat_bua: @flat.flat_bua, flat_bua_markup: @flat.flat_bua_markup, floor: @flat.floor, name: @flat.name, ot_bua: @flat.ot_bua, ot_bua_markdown: @flat.ot_bua_markdown, status: @flat.status }
    assert_redirected_to flat_path(assigns(:flat))
  end

  test "should destroy flat" do
    assert_difference('Flat.count', -1) do
      delete :destroy, id: @flat
    end

    assert_redirected_to flats_path
  end
end
