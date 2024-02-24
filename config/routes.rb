Rails.application.routes.draw do

  

  # mount Ckeditor::Engine => '/ckeditor'
  get 'transaction/index'
  get 'setup/index'

  get 'report/index'

  get 'report/connected_calls'
  post 'report/connected_calls'

  get 'report/progress_bar'
  post 'report/progress_bar'

  get 'windows/google_lead_details'
  post 'windows/google_lead_details'

  get 'windows/daily_calling_report'
  post 'windows/daily_calling_report'

  get 'windows/site_visit_form'
  post 'windows/site_visit_form'
  post 'windows/site_visit_form_submit'
  post 'windows/walk_in_site_visit_form_submit'


  get 'report/monthly_target_index'
  get 'report/monthly_target_new'
  post'report/monthly_target_create'
  get 'report/monthly_target_edit'
  post 'report/monthly_target_update'

  get 'windows/all_live_leads_index'
  post 'windows/all_live_leads_index'
  get  'windows/whatsapp_responsiveness_report'
  post 'windows/whatsapp_responsiveness_report'

  get 'demand/booking_form'
  post 'demand/booking_form'
  get 'demand/booking_preview'
  post 'demand/booking_preview'
  get 'demand/booking_form_download_and_mail'
  post 'demand/booking_form_download_and_mail'

  get 'demand/oriental'
  post 'demand/oriental'

  post 'demand/booking_form_submit'
  get 'demand/Allotment_letter_preview'
  post 'demand/Allotment_letter_preview'
  get 'demand/allotment_letter_download_mail'
  post 'demand/allotment_letter_download_mail'

  get 'demand/send_welcome_letter'
  post 'demand/send_welcome_letter'

  get 'windows/customer_report'
  post 'windows/customer_report'

  get 'source_categories/source_tag_with_facebook_index'
  post 'source_categories/source_tag_with_facebook_index'
  get 'source_categories/source_tag_with_facebook_new'
  post 'source_categories/source_tag_with_facebook_create'
  get 'source_categories/source_tag_with_facebook_edit'
  patch 'source_categories/source_tag_with_facebook_update'
  get 'source_categories/source_tag_with_facebook_destroy'

  post 'marketing_automation/referred_lead_create'
  get 'marketing_automation/referred_lead_form'
  get 'marketing_automation/wish_to_customer_index'
  post 'marketing_automation/wish_to_customer_index'
  get 'marketing_automation/wish_to_customer_upload_form'
  post 'marketing_automation/wish_to_customer_upload'
  get 'marketing_automation/wish_to_customer_destroy'
  post 'marketing_automation/wish_to_customer_destroy'
  get 'marketing_automation/wish_to_customer_submit'
  post 'marketing_automation/wish_to_customer_submit'
  get 'marketing_automation/wish_to_customer_clear'
  post 'marketing_automation/wish_to_customer_clear'
  get 'marketing_automation/wish_to_customer_edit'
  patch 'marketing_automation/wish_to_customer_update'

  get 'marketing_automation/referred_leads_index'
  post 'marketing_automation/referred_leads_index'

  get 'marketing_automation/referral_scheme_opt'
  post 'marketing_automation/referral_scheme_opt'

  get 'setup/area_index'
  post 'setup/area_index'
  get 'setup/area_new'
  post 'setup/area_create'
  get 'setup/area_edit'
  post 'setup/area_update'
  get 'setup/area_destroy'

  get 'setup/city_index'
  post 'setup/city_index'
  get 'setup/city_new'
  post 'setup/city_create'
  get 'setup/city_edit'
  post 'setup/city_update'
  get 'setup/city_destroy'



  # get 'preferred_locations/preferred_location_tag_index'
  # post 'preferred_locations/preferred_location_tag_index'
  # get 'preferred_locations/preferred_location_tag_new'
  # post 'preferred_locations/preferred_location_tag_create'
  # get 'preferred_locations/preferred_location_tag_edit'
  # post 'preferred_locations/preferred_location_tag_update'
  # get 'preferred_locations/preferred_location_tag_destroy'

  get 'other_project/other_project_index'
  post 'other_project/other_project_index'
  get 'other_project/other_project_new'
  post 'other_project/other_project_create'
  get 'other_project/other_project_edit'
  patch 'other_project/other_project_update'
  get 'other_project/other_project_destroy'

  get 'access_point/access_point_index'
  post 'access_point/access_point_index'
  get 'access_point/access_point_new'
  post 'access_point/access_point_create'
  get 'access_point/access_point_edit'
  patch 'access_point/access_point_update'
  get 'access_point/access_point_destroy'
  get 'access_point/access_point_with_personnel'
  post 'access_point/access_point_with_personnel'
  get 'access_point/personnel_tagging_with_access_point'
  post 'access_point/personnel_tagging_with_access_point'
  post 'access_point/access_point_submit'

  get 'windows/fresh_lead_submit'
  post 'windows/fresh_lead_submit'


  get 'adhoc_charge/adhoc_charge_index'
  post 'adhoc_charge/adhoc_charge_index'
  get 'adhoc_charge/adhoc_charge_new'
  post 'adhoc_charge/adhoc_charge_create'
  get 'adhoc_charge/adhoc_charge_edit'
  patch 'adhoc_charge/adhoc_charge_update'
  get 'adhoc_charge/adhoc_charge_destroy'

  get 'credit_note_head/credit_note_head_index'
  post 'credit_note_head/credit_note_head_index'
  get 'credit_note_head/credit_note_head_new'
  post 'credit_note_head/credit_note_head_create'
  get 'credit_note_head/credit_note_head_edit'
  patch 'credit_note_head/credit_note_head_update'
  get 'credit_note_head/credit_note_head_destroy'


  get 'flats/opening_balance_index'
  post 'flats/opening_balance_index'
  get 'flats/opening_balance_edit'
  post 'flats/opening_balance_update'
  get 'marketing_automation/email_template_index'
  post 'marketing_automation/email_template_index'
  get 'marketing_automation/email_template_new'
  post 'marketing_automation/email_template_create'
  get 'marketing_automation/email_template_edit'
  patch 'marketing_automation/email_template_update'
  post 'marketing_automation/email_template_update'
  get 'marketing_automation/email_template_destroy'
  get 'marketing_automation/testing_email_template_send'
  post 'marketing_automation/testing_email_template_send'

  get 'marketing_automation/email_template_preview_index'
  post 'marketing_automation/email_template_preview_index'

  get 'marketing_automation/email_image_index'
  post 'marketing_automation/email_image_index'

  get 'marketing_automation/email_image_upload_form'
  post 'marketing_automation/email_image_upload_form'

  get 'marketing_automation/email_image_upload'
  post 'marketing_automation/email_image_upload'

  get 'marketing_automation/email_attachment_upload_form'
  post 'marketing_automation/email_attachment_upload_form'

  get 'marketing_automation/email_attachment_upload'
  post 'marketing_automation/email_attachment_upload'

  get 'marketing_automation/whatsapp_image_upload_form'
  post 'marketing_automation/whatsapp_image_upload_form'

  get 'marketing_automation/whatsapp_image_upload'
  post 'marketing_automation/whatsapp_image_upload'

  get 'marketing_automation/bulk_recipient_index'
  post 'marketing_automation/bulk_recipient_index'
  get 'marketing_automation/bulk_recipient_upload_form'
  post 'marketing_automation/bulk_recipient_upload'
  get 'marketing_automation/bulk_recipient_destroy'
  post 'marketing_automation/bulk_recipient_destroy'
  get 'marketing_automation/bulk_recipient_submit'
  post 'marketing_automation/bulk_recipient_submit'
  get 'marketing_automation/bulk_recipient_clear'
  post 'marketing_automation/bulk_recipient_clear'
  get 'marketing_automation/whatsapp_template_index'
  post 'marketing_automation/whatsapp_template_index'
  get 'marketing_automation/whatsapp_template_new'
  post 'marketing_automation/whatsapp_template_create'
  get 'marketing_automation/whatsapp_template_edit'
  patch 'marketing_automation/whatsapp_template_update'
  post 'marketing_automation/whatsapp_template_update'
  get 'marketing_automation/whatsapp_template_destroy'

  get 'marketing_automation/whatsapp_image_index'
  post 'marketing_automation/whatsapp_image_index'

  get 'marketing_automation/whatsapp_image_upload_form'
  post 'marketing_automation/whatsapp_image_upload_form'

  get 'marketing_automation/whatsapp_image_upload'
  post 'marketing_automation/whatsapp_image_upload'




  get 'marketing_automation/whatsapp_template_preview_index'
  post 'marketing_automation/whatsapp_template_preview_index'

  get 'marketing_automation/testing_whatsapp_template_send'
  post 'marketing_automation/testing_whatsapp_template_send'

  get 'marketing_automation/sms_template_index'
  post 'marketing_automation/sms_template_index'
  get 'marketing_automation/sms_template_new'
  post 'marketing_automation/sms_template_create'
  get 'marketing_automation/sms_template_edit'
  patch 'marketing_automation/sms_template_update'
  post 'marketing_automation/sms_template_update'
  get 'marketing_automation/sms_template_destroy'
  get 'marketing_automation/sms_template_preview_index'
  post 'marketing_automation/testing_sms_template_send'


  get 'windows/template_send'

  get 'demand/e_signature'
  post 'demand/e_signature'

  get 'demand_report/future_demand_index'
  post 'demand_report/future_demand_index'
  get 'demand_report/demand_accrued_interest'
  post 'demand_report/demand_accrued_interest'

  get 'demand_report/area_unit_wise_demand_index'
  post 'demand_report/area_unit_wise_demand_index'

  get 'demand_report/ledger_entry_header_index'
  post 'demand_report/ledger_entry_header_index'

  get 'demand_report/demand_notice_index'
  post 'demand_report/demand_notice_index'

  get 'demand_report/demand_notice_download_mail'
  post 'demand_report/demand_notice_download_mail'

  get 'demand_report/ignore_demand_index'
  post 'demand_report/ignore_demand_index'

  get 'demand_report/restore_demands'
  post 'demand_report/restore_demands'

  get 'demand_report/multi_demand_destroy'
  post 'demand_report/multi_demand_destroy'

  get 'demand/booking_submit_for_action'
  post 'demand/booking_submit_for_action'

  get 'demand/unconfirmed_booking'
  post 'demand/unconfirmed_booking'

  get 'demand/mortgage_noc_preview'
  post 'demand/mortgage_noc_preview'
  get 'demand/mortgage_noc_send'
  post 'demand/mortgage_noc_send'


  get 'demand/aggrement_preview'
  post 'demand/aggrement_preview'

  get 'demand/aggrement_download_mail'
  post 'demand/aggrement_download_mail'

  get 'demand/builder_noc_preview'
  post 'demand/builder_noc_preview'

  get 'demand/second_welcome_letter_send'
  post 'demand/second_welcome_letter_send'

  get 'report/money_receipt_submit'
  post 'report/money_receipt_submit'

  get 'report/maintenance_collection_graph'
  post 'report/maintenance_collection_graph'


  get 'demand_report/demand_money_receipt_submit'
  post 'demand_report/demand_money_receipt_submit'

  get 'demand_report/demand_money_receipt_destroy'
  post 'demand_report/demand_money_receipt_destroy'
  get 'demand_report/multi_demand_money_receipt_destroy'
  post 'demand_report/multi_demand_money_receipt_destroy'

  get 'demand_report/demand_collection_graph'
  post 'demand_report/demand_collection_graph'

  get 'demand_report/milestone_invoice_preview'
  post 'demand_report/milestone_invoice_preview'
  get 'demand_report/ledger_entry_header_date_edit'
  post 'demand_report/ledger_entry_header_date_edit'
  get 'demand_report/ledger_entry_header_date_update'
  post 'demand_report/ledger_entry_header_date_update'
  get 'demand_report/demand_destroy'

  get 'demand_report/particular_demand_bill_register'
  post 'demand_report/particular_demand_bill_register'

  get 'demand_report/demand_money_receipt_preview_index'
  post 'demand_report/demand_money_receipt_preview_index'
  get 'demand_report/demand_money_receipt_download'
  post 'demand_report/demand_money_receipt_download'

  get 'demand_report/particular_demand_money_receipt_register'
  post 'demand_report/particular_demand_money_receipt_register'

  get 'demand_report/demand_bill_register'
  post 'demand_report/demand_bill_register'

  get 'demand_report/demand_money_receipt_register'
  post 'demand_report/demand_money_receipt_register'

  get 'demand_report/multi_money_receipt_delete'
  post 'demand_report/multi_money_receipt_delete'

  get 'demand_report/demand_outstanding_report'
  post 'demand_report/demand_outstanding_report'

  get 'demand_report/individual_customer_demand_ledger'
  post 'demand_report/individual_customer_demand_ledger'

  get 'demand_report/demand_letter_with_breakup'
  post 'demand_report/demand_letter_with_breakup'

  get 'demand_report/breakup_demand_letter_download_and_mail'
  post 'demand_report/breakup_demand_letter_download_and_mail'

  get 'demand_report/breakup_demand_ledger_download_and_mail'
  post 'demand_report/breakup_demand_ledger_download_and_mail'

  get 'demand_report/individual_customer_demand_ledger_detailed'
  post 'demand_report/individual_customer_demand_ledger_detailed'

  get 'demand_report/outstanding_submit'
  post 'demand_report/outstanding_submit'

  get 'demand_report/demand_outstanding_reminder'
  post 'demand_report/demand_outstanding_reminder'

  get 'demand_report/demand_whatsapp_reminder'
  post 'demand_report/demand_whatsapp_reminder'

  get 'demand_report/demand_outstanding_ignore'
  post 'demand_report/demand_outstanding_ignore'

  get 'demand_report/demand_reminder_log_index'
  post 'demand_report/demand_reminder_log_index'

  get 'demand_report/demand_ledger_download_and_mail'
  post 'demand_report/demand_ledger_download_and_mail'

  get 'report/maintainance_bill_report_index'
  post 'report/maintainance_bill_report_index'

  get "report/export_maintenance_outstanding_report"
  post "report/export_maintenance_outstanding_report"

  get "windows/export_all_live_leads"
  post "windows/export_all_live_leads"

  get "windows/export_daily_calling_report"
  post "windows/export_daily_calling_report"

  get 'report/maintenance_bill_register'
  post 'report/maintenance_bill_register'

  get 'report/particular_maintenance_bill_destroy'
  post 'report/particular_maintenance_bill_destroy'

  get 'report/bulk_maintenance_bill_delete'
  post 'report/bulk_maintenance_bill_delete'

  get 'electrical_report/bulk_electrical_bill_delete'
  post 'electrical_report/bulk_electrical_bill_delete'

  get 'electrical_report/bulk_electrical_money_receipt_delete'
  post 'electrical_report/bulk_electrical_money_receipt_delete'

  get 'report/particular_money_receipt_destroy'
  post 'report/particular_money_receipt_destroy'

  get 'report/money_receipt_bulk_deletion'
  post 'report/money_receipt_bulk_deletion'

  get 'report/money_receipt_register'
  post 'report/money_receipt_register'

  get 'maintainance/sample_testing'

  get 'report/outstanding_report_index'
  post 'report/outstanding_report_index'

  get 'report/outstanding_reminder'
  post 'report/outstanding_reminder'

  get 'report/reminder_log_index'
  post 'report/reminder_log_index'

  get 'setup/escalation_duration'
  post 'setup/escalation_duration'

  get 'electrical_report/outstanding_electric_bill_index'
  post 'electrical_report/outstanding_electric_bill_index'

  get 'electrical_report/electrical_reminder_log_index'
  post 'electrical_report/electrical_reminder_log_index'

  get 'electrical_report/individual_customer_electric_ledger'
  post 'electrical_report/individual_customer_electric_ledger'

  get 'electrical_report/outstanding_electrical_reminder'
  post 'electrical_report/outstanding_electrical_reminder'

  get 'electrical_report/electrical_bill_register'
  post 'electrical_report/electrical_bill_register'

  get 'electrical_report/electrical_money_receipt_register'
  post 'electrical_report/electrical_money_receipt_register'

  get 'maintainance_bill/flat_transfer'
  post 'maintainance_bill/transfer_to_new_lead'

  get 'maintainance_bill/flat_tag_with_lead'
  post 'maintainance_bill/flat_tag_with_lead'

  get 'maintainance_bill/credit_note_entry'
  post 'maintainance_bill/credit_note_entry'
  get 'maintainance_bill/credit_note_preview_index'
  get 'maintainance_bill/credit_note_entry_in_bulk'
  post 'maintainance_bill/credit_note_in_bulk'

  get 'maintainance_bill/credit_note_download'
  post 'maintainance_bill/credit_note_download'

  get 'maintainance_bill/credit_note'
  post 'maintainance_bill/credit_note'
  get 'report/credit_note_register'
  post 'report/credit_note_register'
  get 'maintainance_bill/credit_note_edit'
  post 'maintainance_bill/credit_note_update'
  get 'maintainance_bill/credit_note_destroy'

  post 'maintainance_bill/flat_tagging'

  resources :escalations

  resources :work_order_items

  resources :bills

  resources :bill_items

  resources :work_orders

  resources :marketing_instances

  resources :vendors

  resources :source_categories

  resources :follow_ups

  resources :nationalities

  resources :communities

  resources :magazines

  resources :stations

  resources :channels

  resources :newspapers

  resources :preferred_locations

  resources :occupations

  resources :designations

  resources :lost_reasons

  resources :leads

  resources :calls

  resources :marketing_numbers

  resources :milestones

  post 'milestone_index/milestone_index' => 'milestones#milestone_index'
  get 'milestone_index/milestone_index' => 'milestones#milestone_index'

  resources :payment_plans

  resources :posession_charges

  resources :block_extra_charges

  resources :extra_charges

  resources :flc_charges

  resources :flat_plcs

  resources :plc_charges

  resources :plcs

  resources :flats

  post 'flat_index/flat_index' => 'flats#flat_index'
  get 'flat_index/flat_index' => 'flats#flat_index'

  resources :car_parks

  resources :car_park_natures

  resources :blocks

  resources :project_rates

  resources :project_documents

  resources :documents

  resources :emails

  resources :companies

  resources :business_units

  resources :organisations

  resources :personnels


  get "password_resets/new"
  get 'current_user' => "personnels#current_user"
  get "sessions/new"

  get "log_out" => 'sessions#destroy', :as => "log_out"
  get "log_in" => 'sessions#new', :as => "log_in"
  get "sign_up" => 'personnels#new', :as => "sign_up"
  root :to => 'personnels#new'
  resources :sessions
  resources :password_resets

  post 'personnels/request_for_demo' => 'personnels#request_for_demo'
  get 'personnels/request_for_demo' => 'personnels#request_for_demo'

  get 'windows/call_record/:id', to: 'windows#call_record_follow_up_entry_form'
  post 'windows/call_record/:id', to: 'windows#call_record_follow_up_entry_form'

  get 'windows/direct_lead_follow_up/:id', to: 'windows#direct_follow_up_entry_form'
  post 'windows/direct_lead_follow_up/:id', to: 'windows#direct_follow_up_entry_form'

  get 'windows/site_visit/:id', to: 'windows#site_visit_entry_form'
  post 'windows/site_visit/:id', to: 'windows#site_visit_entry_form'

  post 'windows/site_visit_entry' => 'windows#site_visit_entry'
  get 'windows/site_visit_entry' => 'windows#site_visit_entry'
  patch 'windows/site_visit_entry' => 'windows#site_visit_entry'

  post 'windows/call_record_follow_up_entry' => 'windows#call_record_follow_up_entry'
  get 'windows/call_record_follow_up_entry' => 'windows#call_record_follow_up_entry'

  post 'windows/download_site_visit_qr_code' => 'windows#download_site_visit_qr_code'
  get 'windows/download_site_visit_qr_code' => 'windows#download_site_visit_qr_code'

  post 'windows/field_visit_register' => 'windows#field_visit_register'
  get 'windows/field_visit_register' => 'windows#field_visit_register'

  post 'windows/repeat_site_visit_register' => 'windows#repeat_site_visit_register'
  get 'windows/repeat_site_visit_register' => 'windows#repeat_site_visit_register'

  get 'windows/unallocated_leads' => 'windows#unallocated_leads'
  get 'windows/fresh_leads' => 'windows#fresh_leads'
  post 'windows/fresh_leads' => 'windows#fresh_leads'
  post 'windows/allocate' => 'windows#allocate'
  post 'windows/outbound' => 'windows#outbound'
  get 'windows/outbound' => 'windows#outbound'
  post 'windows/outbound_call' => 'windows#outbound_call'
  get 'windows/outbound_call' => 'windows#outbound_call'
  post 'windows/inbound_call' => 'windows#inbound_call'
  get 'windows/inbound_call' => 'windows#inbound_call'
  post 'windows/call_details' => 'windows#call_details'
  get 'windows/call_details' => 'windows#call_details'
  post 'windows/round_robin' => 'windows#round_robin'
  get 'windows/round_robin' => 'windows#round_robin'
  post 'windows/call' => 'windows#call'
  get 'windows/call' => 'windows#call'

  post 'windows/leads_import' => 'windows#leads_import'
  get 'windows/leads_import' => 'windows#leads_import'

  post 'windows/flat_rate_update' => 'windows#flat_rate_update'
  get 'windows/flat_rate_update' => 'windows#flat_rate_update'

  post 'windows/import_leads' => 'windows#import_leads'
  get 'windows/import_leads' => 'windows#import_leads'

  post 'windows/mobile_number_search' => 'windows#mobile_number_search'
  get 'windows/mobile_number_search' => 'windows#mobile_number_search'

  post 'windows/daily_entries' => 'windows#daily_entries'
  get 'windows/daily_entries' => 'windows#daily_entries'

  post 'windows/daily_entries_in_a_month' => 'windows#daily_entries_in_a_month'
  get 'windows/daily_entries_in_a_month' => 'windows#daily_entries_in_a_month'

  post 'windows/source_wise_leads' => 'windows#source_wise_leads'
  get 'windows/source_wise_leads' => 'windows#source_wise_leads'

  post 'windows/facebook_leads_expandable' => 'windows#facebook_leads_expandable'
  get 'windows/facebook_leads_expandable' => 'windows#facebook_leads_expandable'

  post 'report/facebook_expandable' => 'report#facebook_expandable'
  get 'report/facebook_expandable' => 'report#facebook_expandable'

  post 'report/digital_report' => 'report#digital_report'
  get 'report/digital_report' => 'report#digital_report'

  post 'windows/source_wise_leads_expandable' => 'windows#source_wise_leads_expandable'
  get 'windows/source_wise_leads_expandable' => 'windows#source_wise_leads_expandable'

  post 'windows/source_wise_leads_expandable_pure' => 'windows#source_wise_leads_expandable_pure'
  get 'windows/source_wise_leads_expandable_pure' => 'windows#source_wise_leads_expandable_pure'

  post 'windows/weekly_source_wise_leads' => 'windows#weekly_source_wise_leads'
  get 'windows/weekly_source_wise_leads' => 'windows#weekly_source_wise_leads'

  post 'windows/weekly_source_wise_leads_with_opening' => 'windows#weekly_source_wise_leads_with_opening'
  get 'windows/weekly_source_wise_leads_with_opening' => 'windows#weekly_source_wise_leads_with_opening'

  post 'windows/monthly_source_wise_leads' => 'windows#monthly_source_wise_leads'
  get 'windows/monthly_source_wise_leads' => 'windows#monthly_source_wise_leads'

  post 'windows/monthly_chart_last_year' => 'windows#monthly_chart_last_year'
  get 'windows/monthly_chart_last_year' => 'windows#monthly_chart_last_year'

  post 'windows/monthly_source_wise_leads_with_opening' => 'windows#monthly_source_wise_leads_with_opening'
  get 'windows/monthly_source_wise_leads_with_opening' => 'windows#monthly_source_wise_leads_with_opening'

  post 'windows/personnel_wise_leads' => 'windows#personnel_wise_leads'
  get 'windows/personnel_wise_leads' => 'windows#personnel_wise_leads'

  post 'windows/personnel_wise_leads_genie' => 'windows#personnel_wise_leads_genie'
  get 'windows/personnel_wise_leads_genie' => 'windows#personnel_wise_leads_genie'

  post 'windows/lost_reason_wise_leads' => 'windows#lost_reason_wise_leads'
  get 'windows/lost_reason_wise_leads' => 'windows#lost_reason_wise_leads'

  post 'windows/all_leads' => 'windows#all_leads'
  get 'windows/all_leads' => 'windows#all_leads'

  post 'windows/all_followups' => 'windows#all_followups'
  get 'windows/all_followups' => 'windows#all_followups'

  post 'leads/home/home' => 'leads#home'
  get 'leads/home/home' => 'leads#home'

  get 'windows/pending_followups' => 'windows#pending_followups'
  post 'windows/pending_followups' => 'windows#pending_followups'

  get 'windows/followup_due' => 'windows#followup_due'
  post 'windows/followup_due' => 'windows#followup_due'

  get 'windows/booked_leads' => 'windows#booked_leads'
  post 'windows/booked_leads' => 'windows#booked_leads'

  get 'windows/site_visited_leads' => 'windows#site_visited_leads'
  post 'windows/site_visited_leads' => 'windows#site_visited_leads'

  get 'windows/lost_leads' => 'windows#lost_leads'
  post 'windows/lost_leads' => 'windows#lost_leads'

  get 'windows/followup_history' => 'windows#followup_history'
  post 'windows/followup_history' => 'windows#followup_history'

  get 'windows/followup_entry' => 'windows#followup_entry'
  post 'windows/followup_entry' => 'windows#followup_entry'


  get 'windows/drilldown_followup_entry' => 'windows#drilldown_followup_entry'
  post 'windows/drilldown_followup_entry' => 'windows#drilldown_followup_entry'

  get 'windows/project_wise_source_wise_bar_chart' => 'windows#project_wise_source_wise_bar_chart'
  post 'windows/project_wise_source_wise_bar_chart' => 'windows#project_wise_source_wise_bar_chart'

  get 'windows/project_wise_executive_wise_bar_chart' => 'windows#project_wise_executive_wise_bar_chart'
  post 'windows/project_wise_executive_wise_bar_chart' => 'windows#project_wise_executive_wise_bar_chart'

  get 'windows/project_wise_open_leads_pie_chart' => 'windows#project_wise_open_leads_pie_chart'
  post 'windows/project_wise_open_leads_pie_chart' => 'windows#project_wise_open_leads_pie_chart'

  get 'windows/executive_wise_open_leads_pie_chart' => 'windows#executive_wise_open_leads_pie_chart'
  post 'windows/executive_wise_open_leads_pie_chart' => 'windows#executive_wise_open_leads_pie_chart'

  get 'windows/snapshot' => 'windows#snapshot'
  post 'windows/snapshot' => 'windows#snapshot'

  get 'windows/expenditure_entry_form' => 'windows#expenditure_entry_form'
  post 'windows/expenditure_entry_form' => 'windows#expenditure_entry_form'

  get 'windows/expenditure_entry' => 'windows#expenditure_entry'
  post 'windows/expenditure_entry' => 'windows#expenditure_entry'

  get 'windows/expenditure_edit_form' => 'windows#expenditure_edit_form'
  post 'windows/expenditure_edit_form' => 'windows#expenditure_edit_form'

  get 'windows/expenditure_edit_entry' => 'windows#expenditure_edit_entry'
  post 'windows/expenditure_edit_entry' => 'windows#expenditure_edit_entry'

  get "windows/call_made" => 'windows#call_made'
  post "windows/call_made" => 'windows#call_made'

  get "windows/call_missed" => 'windows#call_missed'
  post "windows/call_missed" => 'windows#call_missed'

  get "windows/call_received" => 'windows#call_received'
  post "windows/call_received" => 'windows#call_received'

  get "windows/month_picker" => 'windows#month_picker'
  post "windows/month_picker" => 'windows#month_picker'

  get "windows/call_report" => 'windows#call_report'
  post "windows/call_report" => 'windows#call_report'

  get "windows/call_record_list" => 'windows#call_record_list'
  post "windows/call_record_list" => 'windows#call_record_list'

  get "windows/absolute_lost" => 'windows#absolute_lost'
  post "windows/absolute_lost" => 'windows#absolute_lost'

  get "windows/alive_again" => 'windows#alive_again'
  post "windows/alive_again" => 'windows#alive_again'

  get "webhook/livserve_data" => 'webhook#livserve_data'
  post "webhook/livserve_data" => 'webhook#livserve_data'

  get "webhook/upload_transcript" => 'webhook#upload_transcript'
  post "webhook/upload_transcript" => 'webhook#upload_transcript'

  get "webhook/google_drive_call_record" => 'webhook#google_drive_call_record'
  post "webhook/google_drive_call_record" => 'webhook#google_drive_call_record'

  get "webhook/jsb_chat" => 'webhook#jsb_chat'
  post "webhook/jsb_chat" => 'webhook#jsb_chat'

  get "webhook/webhook_chat" => 'webhook#webhook_chat'
  post "webhook/webhook_chat" => 'webhook#webhook_chat'

  get "webhook/check_lead_existence" => 'webhook#check_lead_existence'
  post "webhook/check_lead_existence" => 'webhook#check_lead_existence'

  get "webhook/create_whatsapp" => 'webhook#create_whatsapp'
  post "webhook/create_whatsapp" => 'webhook#create_whatsapp'

  get "webhook/mobile_check" => 'webhook#mobile_check'
  post "webhook/mobile_check" => 'webhook#mobile_check'

  get "webhook/kiswok" => 'webhook#kiswok'
  post "webhook/kiswok" => 'webhook#kiswok'

  get "webhook/qualify_lead" => 'webhook#qualify_lead'
  post "webhook/qualify_lead" => 'webhook#qualify_lead'

  get "webhook/isv_lead" => 'webhook#isv_lead'
  post "webhook/isv_lead" => 'webhook#isv_lead'

  get "webhook/mark_lead_hot" => 'webhook#mark_lead_hot'
  post "webhook/mark_lead_hot" => 'webhook#mark_lead_hot'

  get "webhook/lead_reengaged" => 'webhook#lead_reengaged'
  post "webhook/lead_reengaged" => 'webhook#lead_reengaged'

  get "webhook/kiswok_incoming_message" => 'webhook#kiswok_incoming_message'
  post "webhook/kiswok_incoming_message" => 'webhook#kiswok_incoming_message'

  get "webhook/chat_id_check" => 'webhook#chat_id_check'
  post "webhook/chat_id_check" => 'webhook#chat_id_check'

  get "webhook/fb_whatsapp_lead_create" => 'webhook#fb_whatsapp_lead_create'
  post "webhook/fb_whatsapp_lead_create" => 'webhook#fb_whatsapp_lead_create'

  get "webhook/microsite_whatsapp_lead_create" => 'webhook#microsite_whatsapp_lead_create'
  post "webhook/microsite_whatsapp_lead_create" => 'webhook#microsite_whatsapp_lead_create'

  get "windows/flat_availability" => 'windows#flat_availability'
  post "windows/flat_availability" => 'windows#flat_availability'

  get "windows/costing" => 'windows#costing'
  post "windows/costing" => 'windows#costing'

  get "windows/cost_sheet" => 'windows#cost_sheet'
  post "windows/cost_sheet" => 'windows#cost_sheet'

  get "windows/populate_flats" => 'windows#populate_flats'
  post "windows/populate_flats" => 'windows#populate_flats'

  get "windows/populate_project_rate" => 'windows#populate_project_rate'
  post "windows/populate_project_rate" => 'windows#populate_project_rate'

  get "windows/populate_payment_plans" => 'windows#populate_payment_plans'
  post "windows/populate_payment_plans" => 'windows#populate_payment_plans'

  get "demand_report/populate_blocks" => 'demand_report#populate_blocks'
  post "demand_report/populate_blocks" => 'demand_report#populate_blocks'

  get "windows/populate_car_parks" => 'windows#populate_car_parks'
  post "windows/populate_car_parks" => 'windows#populate_car_parks'

  get "windows/cost_sheet_send" => 'windows#cost_sheet_send'
  post "windows/cost_sheet_send" => 'windows#cost_sheet_send'

  get "windows/cost_sheet_send_edit"
  post "windows/cost_sheet_send_edit"
  post 'windows/cost_sheet_send_update'

  get "windows/cost_sheet_download_or_mail" => 'windows#cost_sheet_download_or_mail'
  post "windows/cost_sheet_download_or_mail" => 'windows#cost_sheet_download_or_mail'

  post 'windows/payment_milestone_index' => 'windows#payment_milestone_index'
  get 'windows/payment_milestone_index' => 'windows#payment_milestone_index'
  get 'windows/payment_milestone_new' => 'windows#payment_milestone_new'
  post 'windows/payment_milestone_create' => 'windows#payment_milestone_create'
  get 'windows/payment_milestone_edit' => 'windows#payment_milestone_edit'
  patch 'windows/payment_milestone_update' => 'windows#payment_milestone_update'
  get 'windows/payment_milestone_destroy' => 'windows#payment_milestone_destroy'

  post 'extra_development_charges/extra_development_charges_index' => 'extra_developmwnt_charges#extra_development_charges_index'
  get 'extra_development_charges/extra_development_charges_index' => 'extra_development_charges#extra_development_charges_index'
  get 'extra_development_charges/extra_development_charges_new' => 'extra_development_charges#extra_development_charges_new'
  post 'extra_development_charges/extra_development_charges_create' => 'extra_development_charges#extra_development_charges_create'
  get 'extra_development_charges/extra_development_charges_edit' => 'extra_development_charges#extra_development_charges_edit'
  patch 'extra_development_charges/extra_development_charges_update' => 'extra_development_charges#extra_development_charges_update'
  get 'extra_development_charges/extra_development_charges_destroy' => 'extra_development_charges#extra_development_charges_destroy'

  post 'servant_quarter/index' => 'servant_quarter#index'
  get 'servant_quarter/index' => 'servant_quarter#index'
  get 'servant_quarter/new' => 'servant_quarter#new'
  post 'servant_quarter/create' => 'servant_quarter#create'
  get 'servant_quarter/edit' => 'servant_quarter#edit'
  patch 'servant_quarter/update' => 'servant_quarter#update'
  get 'servant_quarter/destroy' => 'servant_quarter#destroy'


  post 'tax/index' => 'tax#index'
  get 'tax/index' => 'tax#index'
  get 'tax/new' => 'tax#new'
  post 'tax/create' => 'tax#create'
  get 'tax/edit' => 'tax#edit'
  patch 'tax/update' => 'tax#update'
  get 'tax/destroy' => 'tax#destroy'

  get 'maintainance/maintainance_index'
  post 'maintainance/maintainance_index'
  get 'maintainance/maintainance_new'
  post 'maintainance/maintainance_create'
  get 'maintainance/maintainance_edit'
  patch 'maintainance/maintainance_update'
  get 'maintainance/maintainance_destroy'
  post 'maintainance/maintainance_destroy'


  get 'maintainance_ledger/maintainance_ledger_index'
  post 'maintainance_ledger/maintainance_ledger_index'
  get 'maintainance_ledger/maintainance_ledger_new'
  post 'maintainance_ledger/maintainance_ledger_create'
  get 'maintainance_ledger/maintainance_ledger_edit'
  patch 'maintainance_ledger/maintainance_ledger_update'
  get 'maintainance_ledger/maintainance_ledger_destroy'
  post 'maintainance_ledger/maintainance_ledger_destroy'

  get 'maintainance_bill/customer_with_flat_submit'
  post 'maintainance_bill/customer_with_flat_submit'

  get 'maintainance_bill/maintainance_bill_index'
  post 'maintainance_bill/maintainance_bill_index'
  get 'maintainance_bill/maintainance_bill_new'
  post 'maintainance_bill/maintainance_bill_create'
  get 'maintainance_bill/maintainance_bill_edit'
  patch 'maintainance_bill/maintainance_bill_update'
  get 'maintainance_bill/maintainance_bill_destroy'
  post 'maintainance_bill/maintainance_bill_destroy'

  get 'maintainance_bill/individual_maintainance_bill_index'
  post 'maintainance_bill/individual_maintainance_bill_index'
  get 'maintainance_bill/individual_maintainance_bill_new'
  post 'maintainance_bill/individual_maintainance_bill_create'
  get 'maintainance_bill/individual_maintainance_bill_edit'
  patch 'maintainance_bill/individual_maintainance_bill_update'
  get 'maintainance_bill/individual_maintainance_bill_destroy'
  post 'maintainance_bill/individual_maintainance_bill_destroy'

  get 'maintainance_bill/particualr_project_customer'
  post 'maintainance_bill/particualr_project_customer'

  get 'maintainance_bill/maintainance_bill_preview_index'
  post 'maintainance_bill/maintainance_bill_preview_index'
  get 'maintainance_bill/maintainance_bill_pdf_converter'
  post 'maintainance_bill/maintainance_bill_pdf_converter'
  get 'maintainance_bill/maintainance_bill_download'
  post 'maintainance_bill/maintainance_bill_download'
  get 'maintainance_bill/money_receipt_download'
  post 'maintainance_bill/money_receipt_download'

  get 'maintainance_bill/maintainance_bill_tax_invoice_index'
  post 'maintainance_bill/maintainance_bill_tax_invoice_index'
  get 'maintainance_bill/maintainance_bill_tax_invoice_download'
  post 'maintainance_bill/maintainance_bill_tax_invoice_download'

  get 'maintainance_bill/money_receipt_preview_index'
  post 'maintainance_bill/money_receipt_preview_index'
  get 'maintainance_bill/money_receipt_pdf_converter'
  post 'maintainance_bill/money_receipt_pdf_converter'


  get 'maintainance_bill/customer_with_flat_index'
  post 'maintainance_bill/customer_with_flat_index'

  get 'maintainance_bill/manual_maintainance_bill_send_index'
  post 'maintainance_bill/manual_maintainance_bill_send_index'

  get 'maintainance_bill/manual_money_receipt_send_index'
  post 'maintainance_bill/manual_money_receipt_send_index'

  get 'maintainance_bill/manual_bill_send'
  post 'maintainance_bill/manual_bill_send'

  get 'maintainance_bill/manual_receipt_send'
  post 'maintainance_bill/manual_receipt_send'

  get 'maintainance_bill/individual_marking'
  post 'maintainance_bill/individual_marking'

  get 'maintainance_bill/individual_remarks'
  post 'maintainance_bill/individual_remarks'

  get 'maintainance_bill/flat_remarks'
  post 'maintainance_bill/flat_remarks'

  get 'maintainance_bill/populate_rate'
  post 'maintainance_bill/populate_rate'

  get 'maintainance_bill/populate_individual_rate'
  post 'maintainance_bill/populate_individual_rate'

  get 'report/individual_remarks_edit'
  post 'report/individual_flat_remarks_edit'

  get 'report/populate_bill_report'
  post 'report/populate_bill_report'

  get 'report/individual_customer_ledger'
  post 'report/individual_customer_ledger'

  get 'report/individual_customer_ledger_with_interest'
  post 'report/individual_customer_ledger_with_interest'

  get 'maintainance_bill/money_receipt_index'
  post 'maintainance_bill/money_receipt_index'
  get 'maintainance_bill/money_receipt_new'
  post 'maintainance_bill/money_receipt_create'
  get 'maintainance_bill/money_receipt_edit'
  patch 'maintainance_bill/money_receipt_update'
  get 'maintainance_bill/money_receipt_destroy'
  post 'maintainance_bill/money_receipt_destroy'
  get 'maintainance_bill/maintenance_outstanding_feed'
  post 'maintainance_bill/maintenance_outstanding_feed'

  get 'electrical/electrical_index'
  post 'electrical/electrical_index'
  get 'electrical/electrical_new'
  post 'electrical/electrical_create'
  get 'electrical/electrical_edit'
  patch 'electrical/electrical_update'
  get 'electrical/electrical_destroy'
  post 'electrical/electrical_destroy'
  get 'electrical/electrical_outstanding_feed'
  post 'electrical/electrical_outstanding_feed'

  get 'electrical_bill/electrical_bill_index'
  post 'electrical_bill/electrical_bill_index'
  get 'electrical_bill/electrical_bill_new'
  post 'electrical_bill/electrical_bill_create'
  get 'electrical_bill/electrical_bill_edit'
  patch 'electrical_bill/electrical_bill_update'
  get 'electrical_bill/electrical_bill_destroy'
  post 'electrical_bill/electrical_bill_destroy'

  get 'windows/populate_lost_reason'
  post 'windows/populate_lost_reason'

  get 'leads/leads/populate_area_other' => 'leads#populate_area_other'
  post 'leads/leads/populate_area_other' => 'leads#populate_area_other'
  get 'leads/leads/populate_work_area_other' => 'leads#populate_work_area_other'
  post 'leads/leads/populate_work_area_other' => 'leads#populate_work_area_other'

  get 'leads/leads/populate_city_other' => 'leads#populate_city_other'
  post 'leads/leads/populate_city_other' => 'leads#populate_city_other'

  get 'demand/populate_bank_other' => 'demand#populate_bank_other'
  post 'demand/populate_bank_other' => 'demand#populate_bank_other'

  get 'demand/populate_second_applicant_form' => 'demand#populate_second_applicant_form'
  post 'demand/populate_second_applicant_form' => 'demand#populate_second_applicant_form'
  get 'demand/populate_second_applicant_signature' => 'demand#populate_second_applicant_signature'
  post 'demand/populate_second_applicant_signature' => 'demand#populate_second_applicant_signature'

  get 'demand/populate_occupation_other' => 'demand#populate_occupation_other'
  post 'demand/populate_occupation_other' => 'demand#populate_occupation_other'

  get 'demand/populate_designation_other' => 'demand#populate_designation_other'
  post 'demand/populate_designation_other' => 'demand#populate_designation_other'

  get 'leads/leads/populate_occupation_other' => 'leads#populate_occupation_other'
  post 'leads/leads/populate_occupation_other' => 'leads#populate_occupation_other'

  get 'leads/leads/populate_designation_other' => 'leads#populate_designation_other'
  post 'leads/leads/populate_designation_other' => 'leads#populate_designation_other'

  get 'leads/leads/populate_newspaper_other' => 'leads#populate_newspaper_other'
  post 'leads/leads/populate_newspaper_other' => 'leads#populate_newspaper_other'

  get 'leads/leads/populate_channel_other' => 'leads#populate_channel_other'
  post 'leads/leads/populate_channel_other' => 'leads#populate_channel_other'

  get 'leads/leads/populate_station_other' => 'leads#populate_station_other'
  post 'leads/leads/populate_station_other' => 'leads#populate_station_other'

  get 'leads/leads/populate_magazine_other' => 'leads#populate_magazine_other'
  post 'leads/leads/populate_magazine_other' => 'leads#populate_magazine_other'

  get 'leads/leads/populate_community_other' => 'leads#populate_community_other'
  post 'leads/leads/populate_community_other' => 'leads#populate_community_other'

  get 'leads/leads/populate_nationality_other' => 'leads#populate_nationality_other'
  post 'leads/leads/populate_nationality_other' => 'leads#populate_nationality_other'

  get 'electrical_bill/populate_electric_rate'
  post 'electrical_bill/populate_electric_rate'

  get 'electrical_bill/electrical_bill_preview_index'
  post 'electrical_bill/electrical_bill_preview_index'
  get 'electrical_bill/electrical_bill_download'
  post 'electrical_bill/electrical_bill_download'
  get 'electrical_bill/electrical_bill_pdf_converter'
  post 'electrical_bill/electrical_bill_pdf_converter'

  get 'electrical_bill/manual_electrical_bill_send_index'
  post 'electrical_bill/manual_electrical_bill_send_index'

  get 'electrical_bill/manual_electrical_bill_send'
  post 'electrical_bill/manual_electrical_bill_send'

  get 'electrical_bill/electrical_money_receipt_index'
  post 'electrical_bill/electrical_money_receipt_index'
  get 'electrical_bill/electrical_money_receipt_new'
  post 'electrical_bill/electrical_money_receipt_create'
  get 'electrical_bill/electrical_money_receipt_edit'
  patch 'electrical_bill/electrical_money_receipt_update'
  get 'electrical_bill/electrical_money_receipt_destroy'
  post 'electrical_bill/electrical_money_receipt_destroy'

  get 'electrical_bill/manual_electrical_receipt_send_index'
  post 'electrical_bill/manual_electrical_receipt_send_index'

  get 'electrical_bill/manual_electrical_receipt_send'
  post 'electrical_bill/manual_electrical_receipt_send'


  get 'electrical_bill/electrical_money_receipt_preview_index'
  post 'electrical_bill/electrical_money_receipt_preview_index'
  get 'electrical_bill/electrical_money_receipt_pdf_converter'
  post 'electrical_bill/electrical_money_receipt_pdf_converter'
  get 'electrical_bill/electrical_money_receipt_download'
  post 'electrical_bill/electrical_money_receipt_download'

  post 'windows/cost_sheet_review' => 'windows#cost_sheet_review'
  get 'windows/cost_sheet_review' => 'windows#cost_sheet_review'

  post 'windows/sales_funnel' => 'windows#sales_funnel'
  get 'windows/sales_funnel' => 'windows#sales_funnel'

  post 'windows/mis' => 'windows#mis'
  get 'windows/mis' => 'windows#mis'

  post 'windows/whatsapp_snippet' => 'windows#whatsapp_snippet'
  get 'windows/whatsapp_snippet' => 'windows#whatsapp_snippet'

  post 'windows/cost_sheet_convert'
  get 'windows/cost_sheet_convert'

  post 'windows/payment_sheet_convert'
  get 'windows/payment_sheet_convert'

  post 'windows/mis_genie' => 'windows#mis_genie'
  get 'windows/mis_genie' => 'windows#mis_genie'

  post 'windows/executive_wise_mis_genie' => 'windows#executive_wise_mis_genie'
  get 'windows/executive_wise_mis_genie' => 'windows#executive_wise_mis_genie'

  post 'post_sales/booked_flats_to_confirm' => 'post_sales#booked_flats_to_confirm'
  get 'post_sales/booked_flats_to_confirm' => 'post_sales#booked_flats_to_confirm'

  post 'post_sales/booking_entry' => 'post_sales#booking_entry'
  get 'post_sales/booking_entry' => 'post_sales#booking_entry'

  post 'source_categories/drilldown' => 'source_categories#drilldown'

  get 'personnels/new'

  scope '/webhook', :controller => :webhook do
  post :calls
  get :calls
  end

  scope '/webhook', :controller => :webhook do
  post :rajat_calls
  get :rajat_calls
  end

  scope '/webhook', :controller => :webhook do
  post :jsb_calls
  get :jsb_calls
  end

  scope '/webhook', :controller => :webhook do
  post :highrise_alcove_status_update
  get :highrise_alcove_status_update
  end

  scope '/webhook', :controller => :webhook do
  post :highrise_alcove_transfer_update
  get :highrise_alcove_transfer_update
  end

  scope '/webhook', :controller => :webhook do
  post :whatsapp_text_message
  get :whatsapp_text_message
  end
  scope '/webhook', :controller => :webhook do
  post :whatsapp_media_message
  get :whatsapp_media_message
  end
  scope '/webhook', :controller => :webhook do
  post :whatsapp_map_message
  get :whatsapp_map_message
  end

  scope '/webhook', :controller => :webhook do
  post :credai_data
  get :credai_data
  end

  scope '/webhook', :controller => :webhook do
    post :magic_bricks_data
    get :magic_bricks_data
  end

  scope '/webhook', :controller => :webhook do
    post :highrise_alcove_data
    get :highrise_alcove_data
  end

  scope '/webhook', :controller => :webhook do
    post :acres_data
    get :acres_data
  end

  scope '/webhook', :controller => :webhook do
    post :housing_data
    get :housing_data
  end


  scope '/webhook', :controller => :webhook do
    post :facebook_data
    get :facebook_data
  end

  scope '/webhook', :controller => :webhook do
    post :linkedin_data
    get :linkedin_data
  end

  scope '/webhook', :controller => :webhook do
    post :website_form_data
    get :website_form_data
  end

  scope '/webhook', :controller => :webhook do
    post :jaingroup_website_form_data
    get :jaingroup_website_form_data
  end

  scope '/webhook', :controller => :webhook do
  post :website_chat_data
  get :website_chat_data
  end

  scope '/webhook', :controller => :webhook do
  post :alcove_chat
  get :alcove_chat
  end

  scope '/webhook', :controller => :webhook do
  post :rajat_chat
  get :rajat_chat
  end

  get 'demand/booking_confirmation_form'
  post 'demand/booking_confirmation_form'

  get 'demand/confirm_booking_submit'
  post 'demand/confirm_booking_submit'
  get 'demand/cost_sheet_useless_mark'
  post 'demand/cost_sheet_useless_mark'

  get 'demand/booking_date_edit'
  post 'demand/booking_date_edit'
  get 'demand/booking_date_update'
  post 'demand/booking_date_update'

  get 'demand/bookings'
  post 'demand/bookings'

  get 'demand/adhoc_demand_form'
  post 'demand/adhoc_demand_form'

  get 'demand/generate_adhoc_demand'
  post 'demand/generate_adhoc_demand'

  get 'demand/demand_preview_index'
  post 'demand/demand_preview_index'

  get 'demand/demand_money_receipt_preview_index'
  post 'demand/demand_money_receipt_preview_index'

  get 'demand/demand_money_receipt_with_gst_preview_index'
  post 'demand/demand_money_receipt_with_gst_preview_index'

  get 'demand/demand_gst_money_receipt_download_mail'
  post 'demand/demand_gst_money_receipt_download_mail'

  get 'demand/confirm_booking'
  post 'demand/confirm_booking'

  get 'demand/construction_linked_demand_generation_form'
  post 'demand/construction_linked_demand_generation_form'

  get 'demand/generate_construction_linked_demand'
  post 'demand/generate_construction_linked_demand'

  get 'demand/demand_money_receipt_index'
  post 'demand/demand_money_receipt_index'
  get 'demand/money_receipt_entry_form'
  post 'demand/money_receipt_entry'
  get 'demand/demand_money_receipt_edit'
  post 'demand/demand_money_receipt_update'
  get 'demand/demand_money_receipt_destroy'
  post 'demand/demand_money_receipt_download_mail'
  get 'demand/demand_money_receipt_download_mail'
  post 'demand/demand_download_mail'
  get 'demand/demand_download_mail'

  post 'demand/parallel_outstanding_feed'
  get 'demand/parallel_outstanding_feed'

  post 'demand/parallel_collection_feed'
  get 'demand/parallel_collection_feed'

  post 'demand/dwc_parallel_outstanding_feed'
  get 'demand/dwc_parallel_outstanding_feed'

  post 'demand/dwc_parallel_collection_feed'
  get 'demand/dwc_parallel_collection_feed'

  post 'maintainance/collection_feed'
  get 'maintainance/collection_feed'

  post 'electrical_report/collection_feed'
  get 'electrical_report/collection_feed'

  post 'demand/cancellation_form'
  get 'demand/cancellation_form'

  post 'demand/cancel'
  get 'demand/cancel'

  post 'demand/adhoc_charge_entry'
  get 'demand/adhoc_charge_entry'

  post 'demand/credit_note_entry'
  get 'demand/credit_note_entry'

  post 'demand/adhoc_charge'
  get 'demand/adhoc_charge'
  post 'demand/credit_note'
  get 'demand/credit_note'

  get 'adhoc_charge/adhoc_charge_register'
  post 'adhoc_charge/adhoc_charge_register'
  get'demand/adhoc_charge_edit'
  post 'demand/adhoc_charge_update'
  get 'demand/adhoc_charge_destroy'

  get 'credit_note_head/credit_note_register'
  post 'credit_note_head/credit_note_register'
  get'demand/credit_note_edit'
  post 'demand/credit_note_update'
  get 'demand/credit_note_destroy'
  get 'credit_note_head/credit_note_register'
  post 'credit_note_head/credit_note_register'

  get 'setup/project_rate_index'
  post 'setup/project_rate_index'
  get 'setup/whatsapp_qr_code'
  post 'setup/whatsapp_qr_code'
  get 'setup/project_rate_new'
  post 'setup/project_rate_create'
  get 'setup/project_rate_edit'
  post 'setup/project_rate_update'
  get 'setup/project_rate_destroy'

  get 'windows/reengaged_lead_index'
  post 'windows/reengaged_lead_index'

  get 'demand/credit_note_preview_index'
  post 'demand/credit_note_preview_index'
  post 'demand/demand_credit_note_download_mail'

  post "webhook/ifttt_call_capture" => 'webhook#ifttt_call_capture'
  get 'webhook/phone_call_report'
  post 'webhook/phone_call_report'

  get 'windows/import_costing_report'
  post 'windows/costing_report_import'

  post "transaction/personnel_notes"

  get 'windows/facebook_costing_report'
  post 'windows/facebook_costing_report'

  get 'report/import_call_logs'
  post 'report/call_logs_import'
  get 'report/call_audit_report'
  post 'report/call_audit_report'

  get 'report/detailed_audit_report'
  post 'report/detailed_audit_report'

  post 'leads/create'

  get 'windows/populate_area_other' => 'windows#populate_area_other'
  post 'windows/populate_area_other' => 'windows#populate_area_other'
  get 'windows/populate_work_area_other' => 'windows#populate_work_area_other'
  post 'windows/populate_work_area_other' => 'windows#populate_work_area_other'
  get 'windows/populate_occupation_other' => 'windows#populate_occupation_other'
  post 'windows/populate_occupation_other' => 'windows#populate_occupation_other'

  get 'report/em_report_index'
  post 'report/em_report_index'

  get 'report/daily_report'
  post 'report/daily_report'

  get "report/export_detailed_audit_report"
  post "report/export_detailed_audit_report"

  get "webhook/super_receptionist" => 'webhook#super_receptionist'
  post "webhook/super_receptionist" => 'webhook#super_receptionist'

  get 'transaction/call_testing'
  post 'transaction/customer_followup_entry'
  post 'windows/customer_followup_entry'

  get 'transaction/sr_fresh_leads'
  post 'transaction/sr_fresh_lead_entry'
  get 'transaction/sr_live_leads'

  get 'report/em_report_testing_index'
  post 'report/em_report_testing_index'

  post 'demand/milestone_wise_report'
  get 'demand/milestone_wise_report'

  get 'report/call_report'
  post 'report/call_report'

  get 'transaction/telecaller_lead_auditing'
  post 'transaction/telecaller_lead_auditing'

  get 'report/google_report'
  post 'report/google_report'

  get 'report/keyword_wise_google_report'
  post 'report/keyword_wise_google_report'

  get 'report/device_wise_google_report'
  post 'report/device_wise_google_report'

  get 'report/placement_wise_google_report'
  post 'report/placement_wise_google_report'

  get 'report/network_wise_google_report'
  post 'report/network_wise_google_report'

  get 'report/extention_wise_google_report'
  post 'report/extention_wise_google_report'

  get 'report/target_wise_google_report'
  post 'report/target_wise_google_report'

  get 'report/fb_insta_lead_report'
  post 'report/fb_insta_lead_report'

  get 'report/location_wise_google_report'
  post 'report/location_wise_google_report'

  get 'report/organic_lead_report'
  post 'report/organic_lead_report'

  get 'report/facebook_graphical_report'
  post 'report/facebook_graphical_report'

  get 'report/budget_status'
  post 'report/budget_status'

  get 'report/tat_report'
  post 'report/tat_report'

  get 'report/target_id_wise_google_report'
  post 'report/target_id_wise_google_report'

  get 'report/device_model_wise_google_report'
  post 'report/device_model_wise_google_report'

  get 'report/communicated_through_wise_google_report'
  post 'report/communicated_through_wise_google_report'

  get 'report/fb_audience_explorer'
  post 'report/fb_audience_explorer'

  get 'windows/qualified_leads_register'
  post 'windows/qualified_leads_register'

  get 'setup/stream'
  get 'report/detail_tat_report'
  post 'report/detail_tat_report'

  get 'report/populate_interest_type' => 'report#populate_interest_type'
  post 'report/populate_interest_type' => 'report#populate_interest_type'

  get 'report/google_expandable_report'
  post 'report/google_expandable_report'

  get 'setup/incoming_testing'
  post 'setup/incoming_testing'

  get 'report/fb_costing_report'
  post 'report/fb_costing_report'

  get 'report/google_costing_report'
  post 'report/google_costing_report'

  get 'windows/import_qualified_leads'
  post 'windows/qualified_leads_import'

  get 'windows/import_site_visited_leads'
  post 'windows/site_visited_leads_import'

  get 'windows/booking_date_edit'
  post 'windows/booking_date_edit'
  post 'windows/booking_date_update'

  get 'webhook/customer_whatsapp_reply_capture'
  post 'webhook/customer_whatsapp_reply_capture'

  get 'report/fb_google_costing_report'
  post 'report/fb_google_costing_report'
  get 'report/populate_sources'
  post 'report/populate_sources'

  get 'windows/sv_form_index'
  post 'windows/sv_form_index'

  get 'windows/walk_in_sv_form'

  get 'windows/populate_other_broker'
  post 'windows/populate_other_broker'

  get 'report/sr_call_report'
  post 'report/sr_call_report'

  get 'windows/sv_personnel_detail_form'
  post 'windows/sv_personnel_details_submit'
  get 'windows/sv_office_details_form'
  post 'windows/sv_office_details_submit'
  get 'windows/sv_requirement_form'
  post 'windows/sv_requirement_form_submit'

  post 'webhook/site_visit_feedback'
  get 'windows/customer_feedback_form'
  post 'windows/customer_feedback_entry'
  get 'windows/populate_rating_reason'
  post 'windows/populate_rating_reason'

  get 'windows/customer_feedback_report'
  post 'windows/customer_feedback_report'

  get 'windows/fb_google_expenditure_entry_form' => 'windows#fb_google_expenditure_entry_form'
  post 'windows/fb_google_expenditure_entry_form' => 'windows#fb_google_expenditure_entry_form'

  get 'windows/fb_google_expenditure_entry' => 'windows#fb_google_expenditure_entry'
  post 'windows/fb_google_expenditure_entry' => 'windows#fb_google_expenditure_entry'

  get 'broker_setup/index'
  get 'broker_setup/broker_index'
  get 'broker_setup/broker_new'
  post 'broker_setup/broker_create'
  get 'broker_setup/broker_edit'
  post 'broker_setup/broker_update'
  get 'broker_setup/broker_destroy'

  post 'broker_setup/broker_contracts_signed'
  get 'broker_setup/broker_contracts_signed'

  get 'broker_setup/broker_contact_index'
  get 'broker_setup/broker_contact_new'
  post 'broker_setup/broker_contact_create'
  get 'broker_setup/broker_contact_edit'
  post 'broker_setup/broker_contact_update'
  get 'broker_setup/broker_contact_destroy'

  get 'broker_setup/broker_project_status_index'
  post 'broker_setup/broker_project_status_index'
  get 'broker_setup/broker_project_status_new'
  post 'broker_setup/broker_project_status_create'
  get 'broker_setup/broker_project_status_edit'
  post 'broker_setup/broker_project_status_update'
  get 'broker_setup/broker_project_status_destroy'

  get "broker_setup/contract_signed_update" => 'broker_setup#contract_signed_update'
  post "broker_setup/contract_signed_update" => 'broker_setup#contract_signed_update'

  get "broker_setup/sv_update" => 'broker_setup#sv_update'
  post "broker_setup/sv_update" => 'broker_setup#sv_update'

  get "broker_setup/hrd_cpy_sent_update" => 'broker_setup#hrd_cpy_sent_update'
  post "broker_setup/hrd_cpy_sent_update" => 'broker_setup#hrd_cpy_sent_update'

  get "broker_setup/sft_cpy_sent_update" => 'broker_setup#sft_cpy_sent_update'
  post "broker_setup/sft_cpy_sent_update" => 'broker_setup#sft_cpy_sent_update'

  get "broker_setup/contacted_update" => 'broker_setup#contacted_update'
  post "broker_setup/contacted_update" => 'broker_setup#contacted_update'

  get "broker_setup/contacted_uncheck" => 'broker_setup#contacted_uncheck'
  post "broker_setup/contacted_uncheck" => 'broker_setup#contacted_uncheck'

  get "broker_setup/sft_cpy_sent_uncheck" => 'broker_setup#sft_cpy_sent_uncheck'
  post "broker_setup/sft_cpy_sent_uncheck" => 'broker_setup#sft_cpy_sent_uncheck'

  get "broker_setup/hrd_cpy_sent_uncheck" => 'broker_setup#hrd_cpy_sent_uncheck'
  post "broker_setup/hrd_cpy_sent_uncheck" => 'broker_setup#hrd_cpy_sent_uncheck'

  get "broker_setup/sv_uncheck" => 'broker_setup#sv_uncheck'
  post "broker_setup/sv_uncheck" => 'broker_setup#sv_uncheck'

  get "broker_setup/contract_signed_uncheck" => 'broker_setup#contract_signed_uncheck'
  post "broker_setup/contract_signed_uncheck" => 'broker_setup#contract_signed_uncheck'

  get "broker_setup/populate_broker_name" => 'broker_setup#populate_broker_name'
  post "broker_setup/populate_broker_name" => 'broker_setup#populate_broker_name'

  get "broker_setup/populate_broker_contact_name" => 'broker_setup#populate_broker_contact_name'
  post "broker_setup/populate_broker_contact_name" => 'broker_setup#populate_broker_contact_name'

  get "broker_setup/broker_name_update" => 'broker_setup#broker_name_update'
  post "broker_setup/broker_name_update" => 'broker_setup#broker_name_update'

  get "broker_setup/broker_contact_name_update" => 'broker_setup#broker_contact_name_update'
  post "broker_setup/broker_contact_name_update" => 'broker_setup#broker_contact_name_update'

  get "broker_setup/broker_leaderboard"
  
  get "broker_setup/status_pie_chart"
  post "broker_setup/status_pie_chart"

  get 'broker_setup/populate_other_broker'
  post 'broker_setup/populate_other_broker'

  get 'broker_setup/other_broker_name_update'
  post 'broker_setup/other_broker_name_update'

  get "broker_setup/status_funnel_chart"
  post "broker_setup/status_funnel_chart"

  get 'webhook/click_to_call'
  post 'webhook/click_to_call'
  post 'webhook/followup_update'

  get 'broker_setup/broker_agreement_index'
  post 'broker_setup/broker_agreement_index'
  post 'broker_setup/agreement_submit'

  get 'broker_setup/broker_agreement_contract'
  post 'broker_setup/broker_agreement_contract'
  get 'broker_setup/thank_you'

  get 'broker_setup/broker_agreement_link_send'
  get 'broker_setup/broker_source_category_tag_index'
  get 'broker_setup/broker_source_category_tag_new'
  post 'broker_setup/broker_source_category_tag_create'
  get 'broker_setup/broker_source_category_tag_edit'
  post 'broker_setup/broker_source_category_tag_update'
  get 'broker_setup/broker_source_category_tag_destroy'

  get 'broker_setup/fresh_broker'
  post 'broker_setup/fresh_broker'
  post 'broker_setup/fresh_broker_followup_entry'
  post 'broker_setup/broker_followup_entry'
  
  get 'broker_setup/followup_broker'
  post 'broker_setup/followup_broker'
  get 'broker_setup/broker_followup_history'
  post 'broker_setup/broker_followup_history'
  
  get 'broker_setup/future_followup_broker'
  post 'broker_setup/future_followup_broker'
  post 'broker_setup/broker_future_followup_reschedule'
  
  get 'broker_setup/broker_contact_search'
  post 'broker_setup/broker_contact_search'

  get 'windows/reply_to_customer_over_whatsapp'
  post 'windows/reply_to_customer_over_whatsapp'

  get 'broker_setup/broker_logo_upload'
  post 'broker_setup/broker_logo_upload'
  get 'broker_setup/broker_logo_upload_index'

  get 'broker_setup/broker_contact_whatsapp'
  post 'broker_setup/broker_contact_whatsapp'

  get 'broker_setup/broker_contact_whatsapp_massage'
  post 'broker_setup/broker_contact_whatsapp_massage'

  post 'broker_setup/broker_contact_whatsapp_massages'

  get 'broker_setup/broker_contact_whatsapp_index'
  post 'broker_setup/broker_contact_whatsapp_index'

  get 'broker_setup/broker_lead_intimation_link_send'
  get 'broker_setup/broker_lead_intimation_form'
  get 'broker_setup/broker_lead_intimation'
  post 'broker_setup/broker_lead_intimation'
  
  get 'broker_setup/broker_lead_intimation_remarks'
  post 'broker_setup/broker_lead_intimation_remarks'
  
  get 'report/telecaller_calling_report'
  post 'report/telecaller_calling_report'

  get 'broker_setup/brochure_link_send'
  post 'broker_setup/brochure_link_send'
  
  get 'broker_setup/broker_lead_intimation_destroy'

  get "broker_setup/update_lead_id" => 'broker_setup#update_lead_id'
  post "broker_setup/update_lead_id" => 'broker_setup#update_lead_id'
  
  get 'windows/conversation_history'
  get 'windows/followup_update'
  post 'windows/followup_update'

  get 'report/not_connected_calling_gap'
  post 'report/not_connected_calling_gap'

  get 'broker_setup/broker_dashboard'
  post 'broker_setup/broker_dashboard'


  get "broker_setup/site_visited_update" => 'broker_setup#site_visited_update'
  post "broker_setup/site_visited_update" => 'broker_setup#site_visited_update'

  get 'broker_setup/fresh_broker_and_broker_contact'
  post 'broker_setup/fresh_broker_and_broker_contact'

  get 'broker_setup/fresh_broker_and_broker_contact_create'
  post 'broker_setup/fresh_broker_and_broker_contact_create'

  get 'broker_setup/project_details'
  
  get 'broker_setup/site_visited_broker_index'
  post 'broker_setup/site_visited_broker_index'

  get 'broker_setup/site_visited_brokers_all'
  post 'broker_setup/site_visited_brokers_all'

  get 'broker_setup/indipendent_agreement_index'
  post 'broker_setup/indipendent_agreement_index'

  get '/broker_names', to: 'broker_setup#broker_names'

  get 'report/organic_and_paid_lead_report'
  post 'report/organic_and_paid_lead_report'

  get 'report/organic_and_paid_lead_report_web_conversion'
  post 'report/organic_and_paid_lead_report_web_conversion'

  get 'report/sales_em'
  post 'report/sales_em'

  get 'report/site_visit_form_register'
  post 'report/site_visit_form_register'

  get 'transaction/live_lead_whatsapp'
  post 'transaction/live_lead_whatsapp'
  post 'transaction/whatsapp_to_lead'

  get 'report/call_recording_index'
  post 'report/call_recording_index'

  get 'report/lead_wise_recording'
  post 'report/lead_wise_recording'
  get 'windows/sv_feedback_link_send'
end