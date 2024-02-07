require 'test_helper'

class LeadsControllerTest < ActionController::TestCase
  setup do
    @lead = leads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lead" do
    assert_difference('Lead.count') do
      post :create, lead: { address: @lead.address, area: @lead.area, budget: @lead.budget, business_unit_id: @lead.business_unit_id, channel_id: @lead.channel_id, community_id: @lead.community_id, company: @lead.company, customer_remarks: @lead.customer_remarks, designation: @lead.designation, dob: @lead.dob, email: @lead.email, first_applicant: @lead.first_applicant, lost_reason_id: @lead.lost_reason_id, magazine_id: @lead.magazine_id, marketing_instance_id: @lead.marketing_instance_id, mobile: @lead.mobile, name: @lead.name, nationality_id: @lead.nationality_id, newspaper_id: @lead.newspaper_id, occupation_id: @lead.occupation_id, pan: @lead.pan, personnel_remarks: @lead.personnel_remarks, personnels_id: @lead.personnels_id, preferred_location_id: @lead.preferred_location_id, requirement: @lead.requirement, second_applicant: @lead.second_applicant, source_category_id: @lead.source_category_id, station_id: @lead.station_id, status: @lead.status }
    end

    assert_redirected_to lead_path(assigns(:lead))
  end

  test "should show lead" do
    get :show, id: @lead
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lead
    assert_response :success
  end

  test "should update lead" do
    patch :update, id: @lead, lead: { address: @lead.address, area: @lead.area, budget: @lead.budget, business_unit_id: @lead.business_unit_id, channel_id: @lead.channel_id, community_id: @lead.community_id, company: @lead.company, customer_remarks: @lead.customer_remarks, designation: @lead.designation, dob: @lead.dob, email: @lead.email, first_applicant: @lead.first_applicant, lost_reason_id: @lead.lost_reason_id, magazine_id: @lead.magazine_id, marketing_instance_id: @lead.marketing_instance_id, mobile: @lead.mobile, name: @lead.name, nationality_id: @lead.nationality_id, newspaper_id: @lead.newspaper_id, occupation_id: @lead.occupation_id, pan: @lead.pan, personnel_remarks: @lead.personnel_remarks, personnels_id: @lead.personnels_id, preferred_location_id: @lead.preferred_location_id, requirement: @lead.requirement, second_applicant: @lead.second_applicant, source_category_id: @lead.source_category_id, station_id: @lead.station_id, status: @lead.status }
    assert_redirected_to lead_path(assigns(:lead))
  end

  test "should destroy lead" do
    assert_difference('Lead.count', -1) do
      delete :destroy, id: @lead
    end

    assert_redirected_to leads_path
  end
end
