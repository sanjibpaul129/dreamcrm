class BrokerContact < ApplicationRecord
	belongs_to :broker
	belongs_to :personnel
	has_many :follow_ups
	has_many :whatsapp_followups
	has_many :broker_lead_intimations

	def self.broker_contact_list
		broker_contacts = []
		BrokerContact.all.each do |broker_contact|
			if broker_contact.broker.name == "Individual Broker"
			else
				if BrokerSourceCategoryTag.find_by_broker_contact_id(broker_contact.id) == nil
					broker_contacts += [[broker_contact.broker.name+":- "+broker_contact.name, broker_contact.id]]
				end
			end
		end
		return broker_contacts
	end

	def call_the_broker
		cli_number = "+918035469961"
		urlstring = "https://kpi.knowlarity.com/Basic/v1/account/call/makecall"
		if self.mobile_one == nil || self.mobile_one == ""
		else
		    result = HTTParty.post(urlstring,
		    :body => {
		                :k_number => "+919681411411",
		                :agent_number => "+91"+self.personnel.mobile.to_s,
		                :customer_number => "+91"+self.mobile_one.to_s,
		                :caller_id => cli_number
		            }.to_json,
		    :headers => { 'Content-Type' => 'application/json','Accept' => 'application/json','Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef','x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'} )
		end
	end

	def call_broker_other_number
		cli_number = "+918035469961"
		urlstring = "https://kpi.knowlarity.com/Basic/v1/account/call/makecall"
		if self.mobile_two == nil || self.mobile_two == ""
		else
			result = HTTParty.post(urlstring,
		    :body => {
		                :k_number => "+919681411411",
		                :agent_number => "+91"+self.personnel.mobile.to_s,
		                :customer_number => "+91"+self.mobile_two.to_s,
		                :caller_id => cli_number
		            }.to_json,
		    :headers => { 'Content-Type' => 'application/json','Accept' => 'application/json','Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef','x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'} )
		end
	end

	def brochure_visits
		require 'httparty'
		urlstring =  "https://www.googleapis.com/oauth2/v3/token"
		    result = HTTParty.post(urlstring,
		    :body => {"grant_type" => "refresh_token", "client_id"=>"601855471905-kob5pbks040lo5qce2ia4i149ulke1v1.apps.googleusercontent.com", "client_secret" => "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", "refresh_token" => "1//04h43Du3NDCUwCgYIARAAGAQSNwF-L9Ir0f2oWKuRYGZLNnGYsXV4TKamkV3lxJ_VW83hy2405_rxuEHN9yy2ERBUt9KunpHCI0I"}.to_json,
		    :headers => {'Content-Type' => 'application/json'} )
		    access_token = result["access_token"]
		url = 'https://analyticsdata.googleapis.com/v1beta/properties/406880066:runReport'
		headers = {
			'Authorization' => "Bearer #{access_token}",
			'Content-Type' => 'application/json'
		}
		body = {
			dateRanges: [
				{
					startDate: '2023-11-18',
					endDate: '2023-12-14'
				}
			],
			dimensions: [{name: 'pagePathPlusQueryString'}],
			dimensionFilter: {filter: { fieldName: 'pagePathPlusQueryString', stringFilter: { matchType: 'CONTAINS', value: "broker_contact_id="+(self.id.to_s) } } },
			metrics: [
				{
					name: 'totalUsers',
				},
				{
					name: 'eventCount',
				}
			]

		}
		response = HTTParty.post(url, headers: headers, body: body.to_json)
		if response["rows"]==nil
			return 0
		else
			return response["rows"][0]["metricValues"][0]["value"]
		end
	end

	def site_visits
		site_visits = BrokerLeadIntimation.where.not(lead_id: nil).where(broker_contact_id: self.id).count
		return site_visits  
	end
  

	def sales
		source_category_id = BrokerSourceCategoryTag.find_by(broker_contact_id: self.id).try(:source_category_id)
		if source_category_id != nil
			return Lead.where(source_category_id: source_category_id, lost_reason_id: nil).where.not(booked_on: nil).count
		else
			return 0
		end
	end

	def lead_intimations
		lead_intimations = BrokerLeadIntimation.where(broker_contact_id: self.id).count
		return lead_intimations
	end
   
	def current_status
		broker_project_status = BrokerProjectStatus.find_by_broker_id(self.broker_id)
		if broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == true && broker_project_status.contract_signed == true
			status = "Contract Signed"
		elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == true && broker_project_status.contract_signed == nil
			status = "Site Visited"
		elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == true && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
			status = "Hardcopy Sent"
		elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == true && broker_project_status.hardcopy_collaterals_sent == nil && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
			status = "Softcopy Sent"
		elsif broker_project_status.contacted == true && broker_project_status.softcopy_collaterals_sent == nil && broker_project_status.hardcopy_collaterals_sent == nil && broker_project_status.site_visited == nil && broker_project_status.contract_signed == nil
			status = "Contacted"
		else
			status = "In follow up"
		end
		return status
	end

	
end
