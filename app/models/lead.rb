class Lead < ApplicationRecord
    after_update :telecaller_feedback_message
    # after_save :whatsapp_greeting_message
require 'csv'
belongs_to :business_unit
belongs_to :source_category
belongs_to :lost_reason
has_many :maintainance_bills
has_many :follow_ups
has_many :call_records
has_many :sms_followups
has_many :whatsapp_followups
has_many :email_followups
has_many :template_sends
has_many :whatsapps
belongs_to :personnel
has_many :flats
has_many :sent_cost_sheets
has_many :maintainence_ledger_entries
has_many :preferred_location_tags
has_many :multiple_children
belongs_to :occupation
belongs_to :designation
belongs_to :nationality
attr_accessor :followup_time

# has_attached_file :first_sign, 
#                   :storage => :s3, 
#                   :bucket => ENV['S3_BUCKET_NAME'], 
#                   :s3_region => ENV['AWS_REGION'], 
#                   :path => "first_signs/:id", 
#                   :url => ":s3_domain_url"
                  
# validates_attachment_presence :first_sign
# validates_attachment_size :first_sign, :in => 0.megabytes..10.megabytes
# do_not_validate_attachment_file_type :first_sign

def telecaller_feedback_message
    if self.business_unit.organisation_id == 1
        if qualified_on_changed?
            telecaller_message = "Greetings from "+self.business_unit.name+"!"+"\n"+"\n"+"You just spoke to "+self.personnel.name+"."+"\n"+"\n"+"We hope you had a wonderful experience with us, kindly rate our Property Advisor to help us serve you better."
            urlstring = "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
            result = HTTParty.post(urlstring,
              :body => { :to_number => '+91'+self.mobile.to_s,
                        :message => telecaller_message,
                        :type => "buttons",
                    :buttons => [{:id => "happy", :text => "😀"}, {:id => "flat", :text => "😑"}, {:id => "sad", :text => "😞"}]
                }.to_json,
              :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
        end
    end
end

def whatsapp_greeting_message
    if self.business_unit_id == 70
        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
        if self.name.include?("+") == true
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": self.mobile.to_s, "type": "template", "template": {"name": "gurukul_text_greeting_message","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " Sir/Madam,"} ] } ]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            p result
            p "==================new lead created==================="
            whatsapp_followup = WhatsappFollowup.new
            whatsapp_followup.lead_id = self.id
            whatsapp_followup.bot_message = "Greeting message sent in whatsapp"
            message_data = result.parsed_response
            message_id = message_data["messages"]
            message_id = message_id[0]["id"]
            whatsapp_followup.message_id = message_id
            whatsapp_followup.save
        else
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": self.mobile.to_s, "type": "template", "template": {"name": "gurukul_text_greeting_message","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " "+self.name.to_s} ] } ]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            p result
            p "==================new lead created==================="
            whatsapp_followup = WhatsappFollowup.new
            whatsapp_followup.lead_id = self.id
            whatsapp_followup.remarks = "Greeting message sent in whatsapp"
            message_data = result.parsed_response
            message_id = message_data["messages"]
            message_id = message_id[0]["id"]
            whatsapp_followup.message_id = message_id
            whatsapp_followup.save
        end
        UserMailer.new_lead_notification(self).deliver
        p "=====================Email notification Sent========================="
    end
end

def call_the_customer(call_btn)
    urlstring = "https://kpi.knowlarity.com/Basic/v1/account/call/makecall"
    call_btn = call_btn
    if self.business_unit.name=='Dream One' || self.business_unit.name=='Dream One Hotel Apartment'
        if call_btn == "first"
            cli_number = "+918035466989"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918068323253"
        end
    elsif self.business_unit.name=='Dream Eco City'
        if call_btn == "first"
            cli_number = "+918035469961"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918068323254"
        end
    elsif self.business_unit.name=='Dream Valley'
        if call_btn == "first"
            cli_number = "+918035469962"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918035469965"
        end
    elsif self.business_unit.name=='Ecocity Bungalows'
        if call_btn == "first"
            cli_number = "+918035469966"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918068323256"
        end
    elsif self.business_unit.name=='Dream Gurukul'
        if call_btn == "first"
            cli_number = "+918048591129"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918048591130"
        end
    else
        if call_btn == "first"
            cli_number = "+918068323258"
        elsif call_btn == "second" || call_btn == "third"
            cli_number = "+918068323257"
        end
    end
    
    if call_btn == "third"
        result = HTTParty.post(urlstring,
        :body => { 
                    :k_number => "+919681411411",
                    :agent_number => "+91"+self.personnel.mobile.to_s,
                    :customer_number => "+91"+self.other_number.to_s,
                    :caller_id => cli_number
                }.to_json,
        :headers => { 'Content-Type' => 'application/json','Accept' => 'application/json','Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef','x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'} )
    else
        result = HTTParty.post(urlstring,
        :body => { 
                    :k_number => "+919681411411",
                    :agent_number => "+91"+self.personnel.mobile.to_s,
                    :customer_number => "+91"+self.mobile.to_s,
                    :caller_id => cli_number
                }.to_json,
       :headers => { 'Content-Type' => 'application/json','Accept' => 'application/json','Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef','x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'} )
    end
end

def auto_allocate
    available_site_executives=Personnel.where(business_unit_id: self.business_unit_id, access_right: nil, absent: nil)
    picked_site_executive=26
    minimum_fresh_lead_count=1000
    if BusinessUnit.find(self.business_unit_id).name=='Dream World City'
    available_site_executives+=Personnel.where(email: 'shashank@thejaingroup.com')
    end
    available_site_executives.each do |site_executive|
        fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id } ).count
        if fresh_lead_count < minimum_fresh_lead_count
        picked_site_executive=site_executive.id
        minimum_fresh_lead_count=fresh_lead_count
        end    
    end
    self.personnel_id=picked_site_executive
end

def transfer_to_back_office
    project_name = BusinessUnit.find(self.business_unit_id).name
    if project_name=='Dream World City'
        self.personnel_id = 129
        # # UserMailer.api_testing(['pre_dwc_capture','pre_dwc_capture', self.email, self.mobile, self.source_category.description]).deliver
        # available_executives = Personnel.where(email: ['sudiptadeb@thejaingroup.com'])
        # picked_executive = available_executives[0].id
        # minimum_fresh_lead_count = 1000
        # available_executives.each do |site_executive|
        #     fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil} ).count
        #     if fresh_lead_count < minimum_fresh_lead_count
        #         picked_executive = site_executive.id
        #         minimum_fresh_lead_count = fresh_lead_count
        #     end    
        # end
        # self.personnel_id = picked_executive
        # self.mobile = "" if self.mobile==nil
        # self.email = "" if self.email==nil
        # self.name = "" if self.name==nil
        # reference = self.source_category.heirarchy
        # reference = 'Facebook' if self.source_category.heirarchy.include? 'ACEBOOK'
        # urlstring =  "https://ceptessoftwarepvtltd3.secure.force.com/webhook/services/apexrest/website"
        #     result = HTTParty.post(urlstring,
        #        :body => {
        #             "Leads": [
        #                         {
        #                             "FirstName": self.name,
        #                             "LastName": "",
        #                             "Phone": self.mobile,
        #                             "Email": self.email,
        #                             "Project": "Dream World City",
        #                             "Budget": "",
        #                             "AreaFrom": "",
        #                             "AreaTo": "",
        #                             "ProjectStatus": "",
        #                             "BHK": "",
        #                             "Description": "",
        #                             "BankLoan": "",
        #                             "CarPark": "",
        #                             "Location": "",
        #                             "EnquiryNo": "123",
        #                             "AccessKey": "8f5766ed87365760b73adbd8d88da658",
        #                             "Keyword": "",
        #                             "TxtAd": "",
        #                             "Reference": reference,
        #                             "SubReference": reference,
        #                             "SubSubReference": reference
        #                         }
        #                     ]
        #                 }.to_json,
        #                 :headers => {'Content-Type' => 'application/json'} )
        # if result[0..6]=='success' 
        # else       
        #     UserMailer.api_testing(['dwc_salesforce_not_capture','dwc_salesforce_not_capture', self.mobile, result]).deliver
        # end
        # self.booked_on = Time.now
        # self.lost_reason_id = 56
        # self.status = true
    elsif project_name == 'Dream One' || project_name == 'Dream One Hotel Apartment' || project_name == 'Dream Exotica' || project_name == 'Dream Residency Manor' || project_name == 'Dream Palazzo'
        available_executives = Personnel.where(business_unit_id: 2, access_right: 2, absent: nil)
        picked_executive = available_executives[0].id
        minimum_fresh_lead_count = 1000
        if available_executives.count == 1
            self.personnel_id = available_executives[0].id
        else
            available_executives.each do |site_executive|
                fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
                if fresh_lead_count < minimum_fresh_lead_count
                    picked_executive = site_executive.id
                    minimum_fresh_lead_count = fresh_lead_count
                end    
            end
            self.personnel_id = picked_executive
        end
    elsif project_name == "Dream Gurukul"
        available_executives = Personnel.where(business_unit_id: self.business_unit_id, access_right: nil, absent: nil)
        available_executives += Personnel.where(business_unit_id: self.business_unit_id, access_right: 2, absent: nil)
        picked_executive = available_executives[0].id
        minimum_fresh_lead_count = 1000
        available_executives.each do |site_executive|
            fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
            if fresh_lead_count < minimum_fresh_lead_count
                picked_executive = site_executive.id
                minimum_fresh_lead_count = fresh_lead_count
            end    
        end
        self.personnel_id = picked_executive
    elsif project_name == 'Ecocity Bungalows' || project_name == 'Dream Eco City' || project_name == 'Dream Valley'
        if project_name == 'Dream Valley'
            available_executives = Personnel.where(business_unit_id: 6, access_right: nil, absent: nil)
            available_executives += Personnel.where(business_unit_id: 5, access_right: 2, absent: nil)
            if available_executives.count == 1
                self.personnel_id = available_executives[0].id
            else
                picked_executive = available_executives[0].id
                minimum_fresh_lead_count = 1000
                available_executives.each do |site_executive|
                    fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
                    if fresh_lead_count < minimum_fresh_lead_count
                        picked_executive = site_executive.id
                        minimum_fresh_lead_count = fresh_lead_count
                    end    
                end
                self.personnel_id = picked_executive
            end
        else
            available_executives = Personnel.where(business_unit_id: 5, access_right: nil, absent: nil)
            available_executives += Personnel.where(business_unit_id: 5, access_right: 2, absent: nil)
            picked_executive = available_executives[0].id
            minimum_fresh_lead_count = 1000
            available_executives.each do |site_executive|
                fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
                if fresh_lead_count < minimum_fresh_lead_count
                    picked_executive = site_executive.id
                    minimum_fresh_lead_count = fresh_lead_count
                end    
            end
            self.personnel_id = picked_executive
        end
        # elsif project_name == 'Dream Exotica'
        #     available_executives = Personnel.where(business_unit_id: 4, access_right: nil, absent: nil)
        #     self.personnel_id = available_executives[0].id
        # elsif project_name == 'Dream Residency Manor' || project_name == 'Dream Palazzo'
        #     available_executives = Personnel.where(business_unit_id: 7, access_right: nil, absent: nil)
        #     self.personnel_id = available_executives[0].id
        # available_executives += Personnel.where(business_unit_id: 7, access_right: 2, absent: nil)
        # if available_executives.count == 1
        #     self.personnel_id = available_executives[0].id
        # elsif available_executives.count == 2
        #     if available_executives[0].last_robin == nil && available_executives[1].last_robin == nil
        #         self.personnel_id = available_executives[0].id
        #         available_executives[0].update(last_robin: true)
        #         available_executives[1].update(last_robin: nil)
        #     else
        #         if available_executives[0].last_robin == nil
        #             self.personnel_id = available_executives[0].id
        #             available_executives[0].update(last_robin: true)
        #             available_executives[1].update(last_robin: nil)
        #         elsif available_executives[1].last_robin == nil
        #             self.personnel_id = available_executives[1].id
        #             available_executives[1].update(last_robin: true)
        #             available_executives[0].update(last_robin: nil)
        #         end 
        #     end
        # end
    elsif project_name=='Southern Vista'
        available_executives = Personnel.where(email: ['medwina@rajathomes.com'])
        picked_executive = Personnel.find_by_email('medwina@rajathomes.com').id
        minimum_fresh_lead_count = 1000
        available_executives.each do |site_executive|
            fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
            if fresh_lead_count < minimum_fresh_lead_count
                picked_executive = site_executive.id
                minimum_fresh_lead_count = fresh_lead_count
            end    
        end
        self.personnel_id = picked_executive
    elsif project_name=='Aagaman'
        available_executives = Personnel.where(email: 'medwina@rajathomes.com')
        picked_executive = Personnel.find_by_email('medwina@rajathomes.com').id
        minimum_fresh_lead_count = 1000
        available_executives.each do |site_executive|
            fresh_lead_count = Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
            if fresh_lead_count < minimum_fresh_lead_count
                picked_executive = site_executive.id
                minimum_fresh_lead_count = fresh_lead_count
            end    
        end
        self.personnel_id = picked_executive
    elsif project_name=='JSB Serene Tower' || project_name=='JSB Jyoti Residency'
        available_executives=Personnel.where(email: ['namrata@jsb.in.net','priyanka@jsb.in.net'])
        picked_executive=available_executives[0].id
        minimum_fresh_lead_count=1000
            available_executives.each do |site_executive|
                fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
                if fresh_lead_count < minimum_fresh_lead_count
                picked_executive=site_executive.id
                minimum_fresh_lead_count=fresh_lead_count
                end    
            end
        self.personnel_id=picked_executive
    elsif project_name=='JSB Springfield' || project_name=='JSB Lake Front'
        available_executives=Personnel.where(email: ['namrata@jsb.in.net','priyanka@jsb.in.net'])
        picked_executive=available_executives[0].id
        minimum_fresh_lead_count=1000
            available_executives.each do |site_executive|
                fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
                if fresh_lead_count < minimum_fresh_lead_count
                picked_executive=site_executive.id
                minimum_fresh_lead_count=fresh_lead_count
                end    
            end
        self.personnel_id=picked_executive    
    else
        self.personnel_id=Personnel.find_by_email('ayush@erpbuddy.com').id
    end
    if self.name[0..2]=='+91'
        customer_name=''
    elsif self.name[0..1]=='FB'
        customer_name=''
    elsif self.name[0..8]=='Microsite'
        customer_name=''
    elsif self.name[0..8]=='Newspaper'
        customer_name=''
    elsif self.name[0..6]=='Website'
        customer_name=''
    elsif self.name[0..2]=='IVR'
        customer_name=''
    elsif self.name.include? 'Missed'
        customer_name=''
    elsif self.name.include? 'Connected'
        customer_name=''
    elsif self.name.include? 'None'
        customer_name=''
    else    
        customer_name=' '+self.name
    end
    if self.mobile==nil || self.mobile=='' || self.mobile.length != 10
    else
        if 'exist' == 'not exists'
        else
            if project_name == 'Dream One'
                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+self.mobile,
                         :message => "https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21469&authkey=ADQzYYBEkTZ6_rk",    
                          :text => "Welcome to Dream One",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    
                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+self.mobile,
                         :message => "https://dsm01pap001files.storage.live.com/y4mTFKUj7EFWW4iw1YCYecweWfW5WoEViiq9py3MQY7E2J1iDdOTQHo8exjaGsUJQvBjTursQYeb-YBapD0FpZB-walLKDr7yFGLwt7l7W3jLwsbIaf7ARtU6Ias6mFONM5NMeKzPFJGCRhZTkdJK5klS90StkOqzs3tWZp9hnQhrknkhv9xwhwYCM0wmFUTZRC?width=960&height=1200&cropmode=none",    
                          :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    
            elsif project_name=='Dream World City'
            elsif project_name=='Dream One Hotel Apartment'
                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                @result = HTTParty.post(urlstring,
                   :body => { :to_number => '+91'+self.mobile,
                     :message => "https://bl6pap003files.storage.live.com/y4m2tjcMKwXpedCuggcI8s8pFGLTUe3k9N-9FUnBk_ymWrX7bapgQqVavFHa59GjhivX57xzaB2__9G6WtP4SxnP6V6yCS6vBY1VyuIkSrk7DL4KH1ArN7NRjy5hGDV9MVGrdl296M9eDjFFLcZSaqCTm_DhcuSCzjolsflK3o-acNBwKXse_FAs8YdgToKFfTd?width=4500&height=4500&cropmode=none",    
                      :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One Studios"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert xp\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                      :type => "media"
                      }.to_json,
                      :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    
            elsif project_name=='Dream Valley'
                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                @result = HTTParty.post(urlstring,
                   :body => { :to_number => '+91'+self.mobile,
                     :message => "https://bnz07pap001files.storage.live.com/y4ma4ixSPFFua7hlRDKYM4dCfqGwGOvmVpAgiFXZl7b3guDatWouocEUwwuxFfAwmhlCFTXCyca8VG1XNpyDt35REn8tCSbA9_2TLRhE4iJEKLn4smGxkOcdu7uUs4GqGqL-mli3wCvAugLL2pAavNa6Iyl1crvZBROJf9vftXI3LaQsm4s8h_Ox2gV9HgvIzP4?width=4500&height=4500&cropmode=none",    
                      :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream Valley"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                      :type => "media"
                      }.to_json,
                      :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )     
            elsif project_name=='Dream Eco City'
                urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
                @result = HTTParty.post(urlstring,
                   :body => { :to_number => '+91'+self.mobile,
                     :message => "https://bnz07pap001files.storage.live.com/y4mZxfTpXAjsRuC42COQJg7f8M_OWKJZnaCZSt5XDNc_KxTYJsug8AyRgVeXGh0ETL2gEHEYfIeB9qX6K0urZtgfA16x1YoiKCt12bVMfV82OJE3HvQV8ueGpVp3ccMeBbpEwSt4DFV8n5rvSuBuk1KbThkG-M-xhvY4Qk8ViXG5XzWj_8sxJW-eWLC0vRfuliq?width=250&height=360&cropmode=none",    
                      :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream Eco City"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                      :type => "media"
                      }.to_json,
                      :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
            elsif project_name=='Southern Vista'
                urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+self.mobile,
                         :message => "https://drive.google.com/uc?id=1Jke_nyq4j7VfW-BB05gJojCet7khCTyK&export=download",    
                          :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Southern Vista"+".\n\nI can help you with the following 👇\n\n1. Brochure & Floor Plans\n2. BHK/Size/Price Grid\n3. Location\n4. Photo Gallery\n5. Walkthrough Video\n6. Possession Date\n7. Payment Schedule\n8. Book Virtual/Site Visit\n9. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
            elsif project_name=='Aagaman'
                # https://rajathomes.com/aagaman/#location
                # https://rajathomes.com/aagaman/#plans
                # https://rajathomes.com/aagaman/#gallery
                # https://goo.gl/maps/fNyrQHN97LQRoGGV8
                # https://youtu.be/VdlDHPzgRrU
                urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
                    @result = HTTParty.post(urlstring,
                       :body => { :to_number => '+91'+self.mobile,
                         :message => "https://dsm01pap001files.storage.live.com/y4mLm_UQkXnsqzO5wBxrxHhYLVcyUyuLFZSKxF-cT9QRcBVJY-qnlK-x7cAUCqlvt1WKQ7OCM9NsBgH3--78PZyM2Sz5SiobcqnNXwEBfhNCA0alTJdnd81wKct2SfC457bfSAugX9c0m86EiFsTNKqyExnQoQQCKsYAaSp5-gtU3WMrTeEnO90oRzi4s-hUbxu?width=1080&height=1080&cropmode=none",    
                          :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Rajat Aagaman"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. BHK/Size/Price Grid\n3. Location\n4. Photo Gallery\n5. Walkthrough Video\n6. Book a Site Visit\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                          :type => "media"
                          }.to_json,
                          :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )
            elsif project_name=='JSB Serene Tower'
                 urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
                     result = HTTParty.get(urlstring,
                        :body => { :phone => '91'+(self.mobile),
                           :body => 'https://imageclassify.s3.amazonaws.com/serene+tower+creative.jpg',
                           :caption => "Hi "+customer_name+",\n\nThank you for your interest in "+"JSB Serene Tower"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                           :filename => 'offer.jpg'  
                           }.to_json,
                :headers => { 'Content-Type' => 'application/json' } )
            elsif project_name=='JSB Jyoti Residency'         
              urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
                  result = HTTParty.get(urlstring,
              :body => { :phone => '91'+(self.mobile),
                        :body => 'https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg',
                        :caption => "Hi "+customer_name+",\n\nThank you for your interest in "+"JSB Jyoti Residency"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
                        :filename => 'offer.jpg'  
                        }.to_json,
             :headers => { 'Content-Type' => 'application/json' } )         
            elsif project_name == "Dream Gurukul"
                whatsapp_templates = WhatsappTemplate.where(business_unit_id: 70, fresh: true, send_after_days: 0)
                whatsapp_name = ""
                if self.name.include?('Missed') || self.name.include?('Connected') || self.name.include?('None') || self.name.length >= 20
                    whatsapp_name = "Sir/Madam"
                else
                    whatsapp_name = self.name
                end
                whatsapp_templates.each do |whatsapp_template|
                    if whatsapp_template.name_required == true
                        if whatsapp_template.template_type == "pdf"
                        elsif whatsapp_template.template_type == "video"
                        elsif whatsapp_template.template_type == "text"
                        elsif whatsapp_template.template_type == "image with text"
                        elsif whatsapp_template.template_type == "image with text and quickreply button"
                        elsif whatsapp_template.template_type == "video with text and quickreply button"
                        elsif whatsapp_template.template_type == "pdf with text and quickreply button"
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+self.mobile.to_s,"type": "template","template": {"name": whatsapp_template.title,"language": {"code": "en"},"components": [{"type": "header","parameters": [{"type": "document","document": {"link": whatsapp_template.file_url.to_s, "filename": whatsapp_template.file_name.to_s}}]},{"type": "body","parameters": [{"type": "text","text": whatsapp_name}]},{"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            p result
                            p "==================welcome message======================"
                        elsif whatsapp_template.template_type == "pdf with text"
                        elsif whatsapp_template.template_type == "video with text"
                        end
                    else
                        if whatsapp_template.template_type == "pdf"
                        elsif whatsapp_template.template_type == "video"
                        elsif whatsapp_template.template_type == "text"
                        elsif whatsapp_template.template_type == "image with text"
                        elsif whatsapp_template.template_type == "image with text and quickreply button"
                        elsif whatsapp_template.template_type == "video with text and quickreply button"
                        elsif whatsapp_template.template_type == "pdf with text and quickreply button"
                        elsif whatsapp_template.template_type == "pdf with text"
                        elsif whatsapp_template.template_type == "video with text"
                        end
                    end
                end
            else
            end
        end
    end    
end

# def transfer_to_back_office
#     project_name=BusinessUnit.find(self.business_unit_id).name
#     if project_name=='Dream World City'
#         # available_executives=Personnel.where(business_unit_id: self.business_unit_id, access_right: nil, absent: nil)
#         # available_executives+=Personnel.where(business_unit_id: self.business_unit_id, access_right: 2, absent: nil)
#         UserMailer.api_testing(['pre_dwc_capture','pre_dwc_capture', self.email, self.mobile, self.source_category.description]).deliver
#         available_executives=Personnel.where(email: ['sudiptadeb@thejaingroup.com'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil} ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#             picked_executive=site_executive.id
#             minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#         self.mobile="" if self.mobile==nil
#         self.email="" if self.email==nil
#         self.name="" if self.name==nil
#         reference=self.source_category.heirarchy
#         reference='Facebook' if self.source_category.heirarchy.include? 'ACEBOOK'
#           # query = { :access_key => '8f5766ed87365760b73adbd8d88da658',
#           #                       :action => 'save_lead',    
#           #                       :contenqname => self.name,
#           #                       :contenqlname => "",
#           #                       :mobile_phone => self.mobile,
#           #                       :primary_email => self.email,
#           #                       "Project_Name" => self.business_unit.name,
#           #                       :enq_no => "123456",
#           #                       :reference => reference,
#           #                       :subreference => reference,
#           #                       :subsubreference => reference,
#           #                       :city_name => "Kolkata" 
#           #                       }

#           # urlstring =  "http://nkcrm.nkrealtors.com/nkcrm_v2/api.php"
#           #                 result = HTTParty.post(urlstring, :query => query )
#         urlstring =  "https://ceptessoftwarepvtltd3.secure.force.com/webhook/services/apexrest/website"
#             result = HTTParty.post(urlstring,
#                :body => {
#                     "Leads": [
#                                 {
#                                     "FirstName": self.name,
#                                     "LastName": "",
#                                     "Phone": self.mobile,
#                                     "Email": self.email
#                                     "Project": "Dream World City",
#                                     "Budget": "",
#                                     "AreaFrom": "",
#                                     "AreaTo": "",
#                                     "ProjectStatus": "",
#                                     "BHK": "",
#                                     "Description": "",
#                                     "BankLoan": "",
#                                     "CarPark": "",
#                                     "Location": "",
#                                     "EnquiryNo": "123",
#                                     "AccessKey": "8f5766ed87365760b73adbd8d88da658",
#                                     "Keyword": "",
#                                     "TxtAd": "",
#                                     "Reference": reference,
#                                     "SubReference": reference,
#                                     "SubSubReference": reference
#                                 }
#                             ]
#                         }.to_json,
#                         :headers => {'Content-Type' => 'application/json'} )
#         if result[0..6]=='success' 
#         else       
#             UserMailer.api_testing(['dwc_salesforce_not_capture','dwc_salesforce_not_capture', self.mobile]).deliver
#         end
#         self.booked_on=Time.now
#         self.lost_reason_id=56
#         self.status=true               
#     elsif project_name=='Dream One'
#         available_executives=Personnel.where(email: ['varsha@thejaingroup.com'])
#         # available_executives=Personnel.where(email: ['moumitamitra@thejaingroup.com'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#     elsif project_name=='Dream One Hotel Apartment'
#         available_executives=Personnel.where(email: ['lily@thejaingroup.com'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#     elsif project_name=='Dream Eco City' 
#         available_executives=Personnel.where(business_unit_id: self.business_unit_id, access_right: nil, absent: nil)
#         available_executives+=Personnel.where(business_unit_id: self.business_unit_id, access_right: 2, absent: nil)
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#     elsif project_name=='Southern Vista' 
#         available_executives=Personnel.where(email: ['medwina@rajathomes.com'])
#         picked_executive=Personnel.find_by_email('medwina@rajathomes.com').id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#     elsif project_name=='Dream Valley'
#         available_executives=Personnel.where(email: ['tahseen@thejaingroup.com'])
#         # available_executives=Personnel.where(email: ['benejuela@thejaingroup.com'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#         available_executives.each do |site_executive|
#             fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#             if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#             end    
#         end
#         self.personnel_id=picked_executive
#     elsif project_name=='Dream Residency Manor' || project_name=='Dream Palazzo' || project_name=='Dream Exotica'
#         self.personnel_id=Personnel.find_by_email('jenifer@thejaingroup.com').id
#         # self.personnel_id=Personnel.find_by_email('sudiptadeb@thejaingroup.com').id
#         # elsif project_name=='Dream Exotica'
#         # available_executives=Personnel.where(business_unit_id: self.business_unit_id, access_right: nil, absent: nil)
#         # available_executives+=Personnel.where(business_unit_id: self.business_unit_id, access_right: 2, absent: nil)
#         # picked_executive=available_executives[0].id
#         # minimum_fresh_lead_count=1000
#         #     available_executives.each do |site_executive|
#         #         fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil} ).count
#         #         if fresh_lead_count < minimum_fresh_lead_count
#         #         picked_executive=site_executive.id
#         #         minimum_fresh_lead_count=fresh_lead_count
#         #         end    
#         #     end
#         # self.personnel_id=Personnel.find_by_email('sudiptadeb@thejaingroup.com').id
#     elsif project_name=='JSB Serene Tower' || project_name=='JSB Jyoti Residency'
#         available_executives=Personnel.where(email: ['namrata@jsb.in.net','priyanka@jsb.in.net'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#             available_executives.each do |site_executive|
#                 fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#                 if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#                 end    
#             end
#         self.personnel_id=picked_executive
#     elsif project_name=='JSB Springfield' || project_name=='JSB Lake Front'
#         available_executives=Personnel.where(email: ['namrata@jsb.in.net','priyanka@jsb.in.net'])
#         picked_executive=available_executives[0].id
#         minimum_fresh_lead_count=1000
#             available_executives.each do |site_executive|
#                 fresh_lead_count=Lead.includes(:follow_ups).where( :follow_ups => { :lead_id => nil }, :leads => { :personnel_id => site_executive.id, status: nil } ).count
#                 if fresh_lead_count < minimum_fresh_lead_count
#                 picked_executive=site_executive.id
#                 minimum_fresh_lead_count=fresh_lead_count
#                 end    
#             end
#         self.personnel_id=picked_executive    
#     else
#         self.personnel_id=Personnel.find_by_email('ayush@erpbuddy.com').id
#     end

#     if self.name[0..2]=='+91'
#     customer_name=''
#     elsif self.name[0..1]=='FB'
#     customer_name=''
#     elsif self.name[0..8]=='Microsite'
#     customer_name=''
#     elsif self.name[0..8]=='Newspaper'
#     customer_name=''
#     elsif self.name[0..6]=='Website'
#     customer_name=''
#     elsif self.name[0..2]=='IVR'
#     customer_name=''
#     else    
#     customer_name=' '+self.name
#     end

#     if self.mobile==nil || self.mobile=='' || self.mobile.length != 10
#     else
#         # urlstring =  "https://eu71.chat-api.com/instance124988/checkPhone?token=awjkvkwi2sdzv65j&phone="+('91'+(self.mobile))
#         # result = HTTParty.get(urlstring)
#         if 'exist' == 'not exists'
#             # message="Hi"+customer_name+",%0a%0a"+"Thanks for showing interest in "+self.business_unit.name+". We will get back to you shorty. Otherwise you may please call us instantly at "+self.personnel.mobile+"%0aThanks"     
#             # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+(self.business_unit.organisation.sender_id)+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + (self.mobile) + "&text=" + message + "&route=03"
#             # response=HTTParty.get(urlstring)
#         else
#             if project_name=='Dream One'
            
#             urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
#                     @result = HTTParty.post(urlstring,
#                        :body => { :to_number => '+91'+self.mobile,
#                          :message => "https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21469&authkey=ADQzYYBEkTZ6_rk",    
#                           :text => "Welcome to Dream One",
#                           :type => "media"
#                           }.to_json,
#                           :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    

#             # urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
#             #                 result = HTTParty.get(urlstring,
#             #             :body => { :phone => '91'+self.mobile,
#             #                       :body => "https://onedrive.live.com/download?cid=55E14145A4D50C02&resid=55E14145A4D50C02%21469&authkey=ADQzYYBEkTZ6_rk",
#             #                       :caption => "Welcome to Dream One",
#             #                       :filename => 'video.mp4'  
#             #                       }.to_json,
#             #            :headers => { 'Content-Type' => 'application/json' } )

            
#             urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
#                     @result = HTTParty.post(urlstring,
#                        :body => { :to_number => '+91'+self.mobile,
#                          :message => "https://bl6pap003files.storage.live.com/y4mcCQiCAt151rB402wTNV3ti5otYoMLm28MN7aRXWDcZGAdZCNwCcSBitaDdeAA4a6orwGdzrN8c8SS3qqt4MGXB-RRfmcCKLwImftHGzsdXntLJgNZF9W3xXdqxD1qgL9MXszSLWwOzXkVPZX_3LnD9MYi-D86xhZxU5b5IWoHsP1Jo-hkoVMWYwZt5ypN9C7?width=1156&height=1160&cropmode=none",    
#                           :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                           :type => "media"
#                           }.to_json,
#                           :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    


#            #  urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
#            #      result = HTTParty.get(urlstring,
#            #  :body => { :phone => '91'+self.mobile,
#            #            :body => 'https://bl6pap003files.storage.live.com/y4mcCQiCAt151rB402wTNV3ti5otYoMLm28MN7aRXWDcZGAdZCNwCcSBitaDdeAA4a6orwGdzrN8c8SS3qqt4MGXB-RRfmcCKLwImftHGzsdXntLJgNZF9W3xXdqxD1qgL9MXszSLWwOzXkVPZX_3LnD9MYi-D86xhZxU5b5IWoHsP1Jo-hkoVMWYwZt5ypN9C7?width=1156&height=1160&cropmode=none',
#            #            :caption => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#            #            :filename => 'offer.jpg'  
#            #            }.to_json,
#            # :headers => { 'Content-Type' => 'application/json' } )

#             # sleep(1)
            
#             # urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
#             # result = HTTParty.get(urlstring,
#             #         :body => { :phone => '91'+self.mobile,
#             #                   # :previewBase64 => 'data:image/jpeg;base64,'+(Base64.encode64(open('https://bl6pap003files.storage.live.com/y4mdkQBviTMMdi2CJiXc4ONrfTqXSn-2SDjnWFbYHnDSpCLKk6rzuZnhK-TucqONhF46HB5twkCbjgG03GLgGh006RUsnrNxV16HvhUNK7Wj0Q-jX6_wTwLvwFUYg0zYWxD8qwTdU48wI2hAxqfxWy4n9nI3pKsyzKXB0WPnlEtjKdUaOqVwRdw5ytdNMGHDtpB?width=400&height=240&cropmode=none'){ |io| io.read })),  
#             #                   # :previewBase64 => preview_string,
#             #                   :body => "Luxury Apartments\n\n*2BHK* - 71 lacs to 90 lacs\n\n*3BHK* - 1 to 1.6 Cr\n",
#             #                   :title => 'Please help us with you Home Preference',
#             #                   :footer => 'Kindly choose to help us assist you!',
#             #                   # :description => 'Customer Testimonials of the Project',
#             #                   # :text => 'To view honest feedback of customer watch https://youtu.be/vawNPopXSK4'  
#             #                   :buttons => ['2BHK','3BHK','Not Interested']
#             #                   }.to_json,
#             #        :headers => { 'Content-Type' => 'application/json' } )
#             # urlstring =  "https://eu71.chat-api.com/instance124988/sendButtons?token=awjkvkwi2sdzv65j"
#             # result = HTTParty.get(urlstring,
#             #         :body => { :phone => '91'+self.mobile,
#             #                   # :previewBase64 => 'data:image/jpeg;base64,'+(Base64.encode64(open('https://bl6pap003files.storage.live.com/y4mdkQBviTMMdi2CJiXc4ONrfTqXSn-2SDjnWFbYHnDSpCLKk6rzuZnhK-TucqONhF46HB5twkCbjgG03GLgGh006RUsnrNxV16HvhUNK7Wj0Q-jX6_wTwLvwFUYg0zYWxD8qwTdU48wI2hAxqfxWy4n9nI3pKsyzKXB0WPnlEtjKdUaOqVwRdw5ytdNMGHDtpB?width=400&height=240&cropmode=none'){ |io| io.read })),  
#             #                   # :previewBase64 => preview_string,
#             #                   :body => "Ultra Luxury Apartments \n\n*4BHK* - 1.82 to 1.97 Cr\n\n*Penthouse* - 2.65 to 3.05 Cr\n",
#             #                   :title => 'Please help us with you Home Preference',
#             #                   :footer => 'Kindly choose to help us assist you!',
#             #                   # :description => 'Customer Testimonials of the Project',
#             #                   # :text => 'To view honest feedback of customer watch https://youtu.be/vawNPopXSK4'  
#             #                   :buttons => ['4BHK','Penthouse','Not Interested']
#             #                   }.to_json,
#             #        :headers => { 'Content-Type' => 'application/json' } )    

#             elsif project_name=='Dream World City'

#            #  urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
#            #      result = HTTParty.get(urlstring,
#            #  :body => { :phone => '91'+self.mobile,
#            #            :body => 'https://bl6pap003files.storage.live.com/y4mdHOuU3cypHv3jDrl6SnjHkzUyPg5ZVuD8btzv1hi7b0bowsjFul7Oi7o3DaZcTfhysCvkj-Ny0c52KbRtUgJsKPsMa1M1dD86lgM6rCoFQQBi71hbrdUA5mKnz-1ZYAYM34ZvC0b8jAGQpLMgTs-nrZThBKSP8ALz6vW4-KVMfC0FzJjegjaa8OTz89PRaJS?width=1024&height=1024&cropmode=none',
#            #            :caption => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream World City, Kolkata's first iconic City themed township"+".\n\nI can help you with the following 👇\n\n1. Project Summary\n2. Ongoing rate per sft\n3. Possession Date\n4. Google Map Location\n5. Brochure\n6. Photo Gallery\n7. Book Appointment\n8. Walkthrough\n9. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)"+"\n\nOur sales expert will soon get in touch with you or you can connect with us at 9681911911.\n\nNote: We expect a surge in incoming calls, please bear with us in case your call does not get through in the 1st attempt. However our team will get in touch with you in due course.",
#            #            :filename => 'offer.jpeg'  
#            #            }.to_json,
#            # :headers => { 'Content-Type' => 'application/json' } )    
#             elsif project_name=='Dream One Hotel Apartment'

#             urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
#             @result = HTTParty.post(urlstring,
#                :body => { :to_number => '+91'+self.mobile,
#                  :message => "https://bl6pap003files.storage.live.com/y4m2tjcMKwXpedCuggcI8s8pFGLTUe3k9N-9FUnBk_ymWrX7bapgQqVavFHa59GjhivX57xzaB2__9G6WtP4SxnP6V6yCS6vBY1VyuIkSrk7DL4KH1ArN7NRjy5hGDV9MVGrdl296M9eDjFFLcZSaqCTm_DhcuSCzjolsflK3o-acNBwKXse_FAs8YdgToKFfTd?width=4500&height=4500&cropmode=none",    
#                   :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One Studios"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                   :type => "media"
#                   }.to_json,
#                   :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )    


#            #  urlstring =  "https://eu71.chat-api.com/instance124988/sendFile?token=awjkvkwi2sdzv65j"
#            #      result = HTTParty.get(urlstring,
#            #  :body => { :phone => '91'+self.mobile,
#            #            :body => 'https://bl6pap003files.storage.live.com/y4m2tjcMKwXpedCuggcI8s8pFGLTUe3k9N-9FUnBk_ymWrX7bapgQqVavFHa59GjhivX57xzaB2__9G6WtP4SxnP6V6yCS6vBY1VyuIkSrk7DL4KH1ArN7NRjy5hGDV9MVGrdl296M9eDjFFLcZSaqCTm_DhcuSCzjolsflK3o-acNBwKXse_FAs8YdgToKFfTd?width=4500&height=4500&cropmode=none',
#            #            :caption => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream One Studios"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#            #            :filename => 'offer.jpeg'  
#            #            }.to_json,
#            # :headers => { 'Content-Type' => 'application/json' } )
#             elsif project_name=='Dream Valley'

#             urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
#             @result = HTTParty.post(urlstring,
#                :body => { :to_number => '+91'+self.mobile,
#                  :message => "https://bnz07pap001files.storage.live.com/y4ma4ixSPFFua7hlRDKYM4dCfqGwGOvmVpAgiFXZl7b3guDatWouocEUwwuxFfAwmhlCFTXCyca8VG1XNpyDt35REn8tCSbA9_2TLRhE4iJEKLn4smGxkOcdu7uUs4GqGqL-mli3wCvAugLL2pAavNa6Iyl1crvZBROJf9vftXI3LaQsm4s8h_Ox2gV9HgvIzP4?width=4500&height=4500&cropmode=none",    
#                   :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream Valley"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                   :type => "media"
#                   }.to_json,
#                   :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )     

#         elsif project_name=='Dream Eco City'

#             urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21763/sendMessage"
#             @result = HTTParty.post(urlstring,
#                :body => { :to_number => '+91'+self.mobile,
#                  :message => "https://bnz07pap001files.storage.live.com/y4mZxfTpXAjsRuC42COQJg7f8M_OWKJZnaCZSt5XDNc_KxTYJsug8AyRgVeXGh0ETL2gEHEYfIeB9qX6K0urZtgfA16x1YoiKCt12bVMfV82OJE3HvQV8ueGpVp3ccMeBbpEwSt4DFV8n5rvSuBuk1KbThkG-M-xhvY4Qk8ViXG5XzWj_8sxJW-eWLC0vRfuliq?width=250&height=360&cropmode=none",    
#                   :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Dream Eco City"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Book Appointment\n5. Company Profile\n6. Expert Chat\n7. Walkthrough\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                   :type => "media"
#                   }.to_json,
#                   :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )     


#             elsif project_name=='Southern Vista'

#             urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/21010/sendMessage"
#                     @result = HTTParty.post(urlstring,
#                        :body => { :to_number => '+91'+self.mobile,
#                          :message => "https://drive.google.com/uc?id=1Jke_nyq4j7VfW-BB05gJojCet7khCTyK&export=download",    
#                           :text => "Hi"+customer_name+",\n\nThank you for your interest in "+"Southern Vista"+".\n\nI can help you with the following 👇\n\n1. Brochure & Floor Plans\n2. BHK/Size/Price Grid\n3. Location\n4. Photo Gallery\n5. Walkthrough Video\n6. Possession Date\n7. Payment Schedule\n8. Book Virtual/Site Visit\n9. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                           :type => "media"
#                           }.to_json,
#                           :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )    

#            #  urlstring =  "https://eu71.chat-api.com/instance226994/sendFile?token=gfzvtsw22h4eps80"
#            #      result = HTTParty.get(urlstring,
#            #  :body => { :phone => '91'+self.mobile,
#            #            :body => 'https://drive.google.com/uc?id=1Jke_nyq4j7VfW-BB05gJojCet7khCTyK&export=download',
#            #            :caption => "Hi"+customer_name+",\n\nThank you for your interest in "+"Southern Vista"+".\n\nI can help you with the following 👇\n\n1. Brochure & Floor Plans\n2. BHK/Size/Price Grid\n3. Location\n4. Photo Gallery\n5. Walkthrough Video\n6. Possession Date\n7. Payment Schedule\n8. Book Virtual/Site Visit\n9. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#            #            :filename => 'creative.jpeg'  
#            #            }.to_json,
#            # :headers => { 'Content-Type' => 'application/json' } )
#             elsif project_name=='JSB Serene Tower'
#                  urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
#                      result = HTTParty.get(urlstring,
#                  :body => { :phone => '91'+(self.mobile),
#                            :body => 'https://imageclassify.s3.amazonaws.com/serene+tower+creative.jpg',
#                            :caption => "Hi "+customer_name+",\n\nThank you for your interest in "+"JSB Serene Tower"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                            :filename => 'offer.jpg'  
#                            }.to_json,
#                 :headers => { 'Content-Type' => 'application/json' } )
#             elsif project_name=='JSB Jyoti Residency'         
#               urlstring =  "https://eu71.chat-api.com/instance187812/sendFile?token=r88dlb58pg4tjvg7"
#                   result = HTTParty.get(urlstring,
#               :body => { :phone => '91'+(self.mobile),
#                         :body => 'https://imageclassify.s3.amazonaws.com/Jyoti+Residency+Creative.jpg',
#                         :caption => "Hi "+customer_name+",\n\nThank you for your interest in "+"JSB Jyoti Residency"+".\n\nI can help you with the following 👇\n\n1. Brochure\n2. Location\n3. Photo Gallery\n4. Posession Date\n5. Book Appointment\n6. Company Profile\n7. Expert Chat\n\n💡 *Tip:* To make a selection, you can also type the number adjacent to the option (e.g: 1 or 2)",
#                         :filename => 'offer.jpg'  
#                         }.to_json,
#              :headers => { 'Content-Type' => 'application/json' } )         
#             else
#             # message="Hi"+customer_name+",%0a%0a"+"Thanks for showing interest in "+self.business_unit.name+". We will get back to you shorty. Otherwise you may please call us instantly at "+self.personnel.mobile+"%0aThanks"     
#             # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+self.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + (self.mobile) + "&text=" + message + "&route=03"
#             #      if urlstring.ascii_only?
#             #        response=HTTParty.get(urlstring)
#             #      end   
#             end
#         end
#     end    
# end

def duplicate_capture(original_lead)
    if self.source_category_id==original_lead.source_category_id
        same_source_lost_reason=LostReason.find_by(organisation_id: original_lead.source_category.organisation_id, description: 'Duplicate lead (existing with same source)')
        if same_source_lost_reason != nil
            self.status=true
            self.booked_on=Time.now
            self.lost_reason_id=same_source_lost_reason.id
            self.personnel_id=original_lead.personnel_id
            self.save

            reengaged=Whatsapp.new
            reengaged.by_lead=false
            reengaged.lead_id=original_lead.id
            reengaged.message='Lead showed interest again vide '+(original_lead.source_category.heirarchy)
            reengaged.save

            original_lead.update(reengaged_on: Time.now)


                executive_number='91'+self.personnel.mobile
                if self.mobile != nil && self.email != nil
                message="Lead showing interest again, "+ self.name+", "+self.mobile+", "+self.email
                elsif self.mobile != nil
                message="Lead showing interest again, "+ self.name+", "+self.mobile
                elsif self.email != nil
                message="Lead showing interest again, "+ self.name+", "+self.email
                end 
                if self.business_unit.organisation.whatsapp_instance==nil
                # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+self.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
                # response=HTTParty.get(urlstring)
                else
                # urlstring =  "https://eu71.chat-api.com/instance"+self.business_unit.organisation.whatsapp_instance+"/sendMessage?token="+self.business_unit.organisation.whatsapp_key
                #             result = HTTParty.get(urlstring,
                #                :body => { :phone => "91"+(self.personnel.mobile),
                #                           :body => message 
                #                           }.to_json,
                #                :headers => { 'Content-Type' => 'application/json' } )
                end
        end        
    else
        shared_source_lost_reason=LostReason.find_by(organisation_id: original_lead.source_category.organisation_id, description: 'Shared lead (existing with other source)')
        if shared_source_lost_reason != nil
            self.status=true
            self.booked_on=Time.now
            self.lost_reason_id=shared_source_lost_reason.id
            self.personnel_id=original_lead.personnel_id
            self.save

            reengaged=Whatsapp.new
            reengaged.by_lead=false
            reengaged.lead_id=original_lead.id
            reengaged.message='Lead showed interest again vide '+(original_lead.source_category.heirarchy)
            reengaged.save

            original_lead.update(reengaged_on: Time.now)

            executive_number='91'+self.personnel.mobile
            if self.mobile != nil && self.email != nil
            message="Lead showing interest again, "+ self.name+", "+self.mobile+", "+self.email
            elsif self.mobile != nil
            message="Lead showing interest again, "+ self.name+", "+self.mobile
            elsif self.email != nil
            message="Lead showing interest again, "+ self.name+", "+self.email
            end 
            if self.business_unit.organisation.whatsapp_instance==nil
            # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+self.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
            # response=HTTParty.get(urlstring)
            else
            # urlstring =  "https://eu71.chat-api.com/instance"+self.business_unit.organisation.whatsapp_instance+"/sendMessage?token="+self.business_unit.organisation.whatsapp_key
            #             result = HTTParty.get(urlstring,
            #                :body => { :phone => "91"+(self.personnel.mobile),
            #                           :body => message 
            #                           }.to_json,
            #                :headers => { 'Content-Type' => 'application/json' } )
            end
        end
    end
    
end

def self.import(file)
  leads_imported=0
  errors=[]	
  spreadsheet= Lead.open_spreadsheet(file)
  header=spreadsheet.row(1)
  lead=nil
  (2..spreadsheet.last_row).each do |i|
    row=Hash[[header,spreadsheet.row(i)].transpose]
    if row['Name']==nil && row['Mobile_No']==nil && row['Email_ID']==nil && row['Project_Name']==nil && row['Source_Reference']==nil && row['Sales_Person']==nil
        break
    end
    # name should always be present
    # if mobile is present it should always be 10 digits
    # either mobile, other number or email should be present
    
    
    if row['Name']==nil
    errors=errors+[['No Name', row]]
    name_validation=false	
	end
	if row['Mobile_No']!=nil
    	if row['Mobile_No'].to_s.scan(/\D/).empty?
    		if row['Mobile_No'].to_s.length!=10
    		errors=errors+[['mobile not 10 digits', row]]
    		mobile_validation=false
    		end		
    	else
    	errors=errors+[['Non number in mobile', row]]	
    	mobile_validation=false
    	end
    else
	    if row['Email_ID']==nil
	    errors=errors+[['Email & Mobile not present', row]]	
	    email_validation=false	
	    end	
    end
    
    if row['Project_Name']==nil
        project_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
            project_validation=false
            errors=errors+[['Project not found', row]]
        else
            business_unit_id=BusinessUnit.find_by_name(row['Project_Name']).id
        end
    end

    if row['Project_Name']==nil
        source_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
                errors=errors+[['Project not found', row]]   
                source_validation=false
        else
            if SourceCategory.find_by(description: row['Source_Reference'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id)==nil
            errors=errors+[['Source error', row]]	
        	source_validation=false	
            end	
        end
    end    
    
    if row['Project_Name']==nil
        source_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
                errors=errors+[['Project not found', row]]   
                sales_person_validation=false
        else
        
            if row['Sales_Person']==nil
            	sales_person_validation=false
            	errors=errors+[['Sales Person not present', row]]
            elsif Personnel.find_by(name: row['Sales_Person'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id)==nil
            	sales_person_validation=false
            	errors=errors+[['Sales Person not found', row]]
            end
        end    
    end    

	if row['Mobile_No']!=nil
		if Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false) != []
    	project_mobile_validation=false
    	errors=errors+[['Duplicate Mobile', row, Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false)[0]]]
    	elsif Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days) != []
        errors=errors+[['Duplicate Mobile marked lost in the last 7 days', row, Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days)[0]]]
        end
    end

    if row['Email_ID']!=nil
       if Lead.where(email: row['Email_ID'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false) != []
        project_email_validation=false
        errors=errors+[['Duplicate Email', row, Lead.where(email: row['Email_ID'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false)[0]]]
        elsif Lead.where(mobile: row['Email_ID'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days) != []
        errors=errors+[['Duplicate Email marked lost in the last 7 days', row, Lead.where(mobile: row['Email_ID'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days)[0]]]
       end
    end

    if name_validation==false || mobile_validation==false || email_validation==false || source_validation==false || sales_person_validation==false || project_validation==false || project_mobile_validation==false || project_email_validation==false 
    else
	    lead=new
	    if row['Source_Date']==nil || row['Source_Date']==''
	    lead.generated_on=Time.now
	    else
	    lead.generated_on=row['Source_Date']	
	    end
	    lead.name=row['Name']
	    lead.mobile=row['Mobile_No'].to_s
	    lead.email=row['Email_ID']
	    lead.source_category_id=SourceCategory.find_by(description: row['Source_Reference'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id).id
	    lead.business_unit_id=business_unit_id
	    lead.personnel_id=Personnel.find_by(name: row['Sales_Person'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id).id
        lead.customer_remarks=row['Remarks']
        # lead.site_visited_on=row['Source_Date']
        lead.save!
        leads_imported+=1
        # UserMailer.new_lead_notification(lead).deliver
        
        # executive_number='91'+lead.personnel.mobile
        # if lead.mobile != nil && lead.email != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.mobile+", "+lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # elsif lead.mobile != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # elsif lead.email != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # end 
        # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
        

        # begin
        #    response=HTTParty.get(urlstring)
        #  rescue HTTParty::Error
        # end
        
        # # importing leads transferred to agents
        # if Personnel.find_by_name(row['Sales_Person']).agent==true
        #     lead.update(status: true)
        #     lead.update(booked_on: Time.now)
        #     lead.update(lost_reason_id: 6)
        #     follow_up=FollowUp.new
        #     follow_up.personnel_id=lead.personnel_id
        #     follow_up.lead_id=lead.id
        #     follow_up.communication_time=Time.now
        #     follow_up.follow_up_time=Time.now
        #     follow_up.remarks=''
        #     follow_up.status=true
        #     follow_up.first=true
        #     follow_up.last=true
        #     follow_up.save!
        # end
  	end
  end
  errors=errors.uniq { |s| s.second }
  UserMailer.lead_import_errors([errors, leads_imported, lead]).deliver
  return errors
end


def self.import_with_first_follow_up(file)
  leads_imported=0
  errors=[] 
  spreadsheet= Lead.open_spreadsheet(file)
  header=spreadsheet.row(1)
  lead=nil
  (2..spreadsheet.last_row).each do |i|
    row=Hash[[header,spreadsheet.row(i)].transpose]
    if row['Name']==nil && row['Mobile_No']==nil && row['Email_ID']==nil && row['Project_Name']==nil && row['Source_Reference']==nil && row['Sales_Person']==nil && row['Lost_Reason']==nil && row['Remarks']==nil && row['Follow_up_time']==nil && row['Status']==nil
        break
    end
    # name should always be present
    # if mobile is present it should always be 10 digits
    # either mobile, other number or email should be present
    
    
    if row['Name']==nil
    errors=errors+[['No Name', row]]
    name_validation=false   
    end
    if row['Mobile_No']!=nil
        if row['Mobile_No'].to_s.scan(/\D/).empty?
            if row['Mobile_No'].to_s.length!=10
            errors=errors+[['mobile not 10 digits', row]]
            mobile_validation=false
            end     
        else
        errors=errors+[['Non number in mobile', row]]   
        mobile_validation=false
        end
    else
        if row['Email_ID']==nil
        errors=errors+[['Email & Mobile not present', row]] 
        email_validation=false  
        end 
    end
    
    if row['Project_Name']==nil
        project_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
            project_validation=false
            errors=errors+[['Project not found', row]]
        else
            business_unit_id=BusinessUnit.find_by_name(row['Project_Name']).id
        end
    end

    if row['Project_Name']==nil
        source_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
                errors=errors+[['Project not found', row]]   
                source_validation=false
        else
            if SourceCategory.find_by(description: row['Source_Reference'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id)==nil
            errors=errors+[['Source error', row]]   
            source_validation=false 
            end 
        end
    end    
    
    if row['Project_Name']==nil
        source_validation=false
        errors=errors+[['Project not mentioned', row]]
    else
        if BusinessUnit.find_by_name(row['Project_Name'])==nil
                errors=errors+[['Project not found', row]]   
                sales_person_validation=false
        else
        
            if row['Sales_Person']==nil
                sales_person_validation=false
                errors=errors+[['Sales Person not present', row]]
            elsif Personnel.find_by(name: row['Sales_Person'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id)==nil
                sales_person_validation=false
                errors=errors+[['Sales Person not found', row]]
            end
        end    
    end    

    if row['Mobile_No']!=nil
        if Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false) != []
        project_mobile_validation=false
        errors=errors+[['Duplicate Mobile', row, Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false)[0]]]
        elsif Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days) != []
        errors=errors+[['Duplicate Mobile marked lost in the last 7 days', row, Lead.where(mobile: row['Mobile_No'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days)[0]]]
        end
    end

    if row['Email_ID']!=nil
       if Lead.where(email: row['Email_ID'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false) != []
        project_email_validation=false
        errors=errors+[['Duplicate Email', row, Lead.where(email: row['Email_ID'].to_s, business_unit_id: business_unit_id).where('status is ? or status = ?', nil, false)[0]]]
        elsif Lead.where(mobile: row['Email_ID'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days) != []
        errors=errors+[['Duplicate Email marked lost in the last 7 days', row, Lead.where(mobile: row['Email_ID'].to_s, business_unit_id: business_unit_id, status: true).where('created_at > ?', Date.today-7.days)[0]]]
       end
    end

    if name_validation==false || mobile_validation==false || email_validation==false || source_validation==false || sales_person_validation==false || project_validation==false || project_mobile_validation==false || project_email_validation==false 
    else
        lead=new
        if row['Source_Date']==nil
        lead.generated_on=Time.now
        else
        lead.generated_on=row['Source_Date']    
        end
        lead.name=row['Name']
        lead.mobile=row['Mobile_No'].to_s
        lead.email=row['Email_ID']
        lead.source_category_id=SourceCategory.find_by(description: row['Source_Reference'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id).id
        lead.business_unit_id=business_unit_id
        lead.personnel_id=Personnel.find_by(name: row['Sales_Person'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id).id
        lead.customer_remarks=row['Remarks']
        lead.save!
        leads_imported+=1
        # UserMailer.new_lead_notification(lead).deliver
        
        # executive_number='91'+lead.personnel.mobile
        # if lead.mobile != nil && lead.email != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.mobile+", "+lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # elsif lead.mobile != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.mobile+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # elsif lead.email != nil
        # message="Source: "+row['Source_Reference']+", "+ lead.name+", "+lead.email+", "+ Bitly.client.shorten('http://www.realtybucket.com/windows/direct_lead_follow_up/'+lead.id.to_s).short_url
        # end 
        # urlstring = 'http://panel.smsmessenger.in/api/mt/SendSMS?APIKey=kG6vgYgUqEmnHUtHX15pNQ&senderid='+lead.business_unit.organisation.sender_id+'&channel=Trans&DCS=0&flashsms=0' + "&number=" + executive_number + "&text=" + message + "&route=03"
        

        # begin
        #    response=HTTParty.get(urlstring)
        #  rescue HTTParty::Error
        # end
        
        # importing leads transferred to agents
        if row['Lost_Reason']==nil && row['Follow_up_time']==nil
        else
            if row['Lost_Reason']=='' || row['Lost_Reason']==nil
                follow_up=FollowUp.new
                if row['Status']=='OV'
                lead.update(osv: true)
                follow_up.osv=true
                end
                follow_up.personnel_id=lead.personnel_id
                follow_up.lead_id=lead.id
                follow_up.communication_time=Time.now
                follow_up.follow_up_time=row['Follow_up_time']
                follow_up.remarks=row['Remarks']
                follow_up.first=true
                follow_up.last=true
                follow_up.save!
            elsif LostReason.find_by(description: row['Lost_Reason'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id)==nil
            else
                lead.update(status: true)
                lead.update(booked_on: Time.now)
                lead.update(lost_reason_id: LostReason.find_by(description: row['Lost_Reason'], organisation_id: BusinessUnit.find_by_name(row['Project_Name']).organisation_id).id)
                follow_up=FollowUp.new
                follow_up.personnel_id=lead.personnel_id
                follow_up.lead_id=lead.id
                follow_up.communication_time=Time.now
                follow_up.follow_up_time=Time.now
                follow_up.remarks=row['Remarks']
                follow_up.status=true
                follow_up.first=true
                follow_up.last=true
                follow_up.save!
            end
        end
    end
  end
  errors=errors.uniq { |s| s.second }
  UserMailer.lead_import_errors([errors, leads_imported, lead]).deliver
  return errors
end

  def self.open_spreadsheet(file)

    tmp = file.tempfile
    okfile = File.join("public", file.original_filename)
    FileUtils.cp tmp.path, okfile


    case File.extname(file.original_filename)
    #when ".csv" then Roo::Csv.new (file.path nil, :ignore)

    when ".xlsx" then Roo::Excelx.new (okfile)
    # when ".xls" then Roo::Excel.new (file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def anticipation=(value)
    if value=='Hot'
    write_attribute(:anticipation, true)
    elsif value=='Good'
    write_attribute(:anticipation, false)
    else
    write_attribute(:anticipation, nil)    
    end    
  end

  def anticipation
    if self[:anticipation]==true
    result='Hot'
    elsif self[:anticipation]==false
    result='Good'
    else
    result=''    
    end
    return result
  end

  def cross
    self.follow_ups.uniq{|x| x.personnel_id}.pluck[:personnel_id]
  end

  def alpha_id
    mapping=['a','b','c','d','e','f','g','h','i','j']
    alpha_id=''
    numeric_id=self.id
    numeric_ids=numeric_id.to_s.split("")
    numeric_ids.each do |lead_id|
        alpha_id+=mapping[lead_id.to_i]
    end
    return alpha_id
  end

  def self.qualified_lead_import(file)
    leads_imported = 0
    errors = 0
    spreadsheet = Lead.open_spreadsheet(file)
    header = spreadsheet.row(1)
    lead = nil
    found = false
    not_found_leads = []
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header,spreadsheet.row(i)].transpose]    
        if row['Name'] == nil && row['Mobile_No'] == nil && row['Email_ID'] == nil && row['Project_Name'] == nil && row['Created_at'] == nil && row['qualified_on'] == nil
            break
        end
        qualified_on = row['qualified_on']
        created_at = row['Created_at']    
        business_unit_id = BusinessUnit.find_by_name(row['Project_Name']).id
        if row['Mobile_No'] == nil || row['Mobile_No'] == ""
            if row['Email_ID'] == nil || row['Email_ID'] == nil
                not_found_leads += [row]
                errors += 1
            else
                leads = Lead.where(email: row['Email_ID'], business_unit_id: business_unit_id)
                if leads == []
                    not_found_leads += [row]
                    errors += 1
                else
                    leads.each do |lead|
                        if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                        else
                            # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                            if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-45.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+46.days).to_date
                                lead.update(qualified_on: qualified_on.to_datetime)
                                leads_imported += 1
                                found = true
                                break
                            else
                                found = false
                            end
                        end
                    end
                    if found == false
                        not_found_leads += [row]
                        errors += 1
                    end
                end
            end
        else
            leads = Lead.where(mobile: row['Mobile_No'], business_unit_id: business_unit_id)
            if leads == []
                if row['Email_ID'] == nil || row['Email_ID'] == ""
                    not_found_leads += [row]
                    errors += 1
                else
                    leads = Lead.where(email: row['Email_ID'], business_unit_id: business_unit_id)
                    if leads == []
                        not_found_leads += [row]
                        errors += 1
                    else
                        leads.each do |lead|
                            if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                            else
                                # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                                if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-30.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+31.days).to_date
                                    lead.update(qualified_on: qualified_on.to_datetime)
                                    leads_imported += 1
                                    found = true
                                    break
                                else
                                    found = false
                                end
                            end
                        end
                        if found == false
                            not_found_leads += [row]
                            errors += 1
                        end
                    end
                end
            else
                leads.each do |lead|
                    if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                    else
                        # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                        if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-30.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+31.days).to_date
                            lead.update(qualified_on: qualified_on.to_datetime)
                            leads_imported += 1
                            found = true
                            break
                        else
                            found = false
                        end
                    end
                end
                if found == false
                    not_found_leads += [row]
                    errors += 1
                end
            end
        end
    end
    UserMailer.qualified_lead_import_errors([not_found_leads]).deliver
    return errors
  end

  def self.site_visited_lead_import(file)
    leads_imported = 0
    errors = 0
    spreadsheet = Lead.open_spreadsheet(file)
    header = spreadsheet.row(1)
    lead = nil
    found = false
    not_found_leads = []
    (2..spreadsheet.last_row).each do |i|
        row = Hash[[header,spreadsheet.row(i)].transpose]    
        if row['Name'] == nil && row['Mobile_No'] == nil && row['Email_ID'] == nil && row['Project_Name'] == nil && row['Created_at'] == nil && row['site_visited_on'] == nil
            break
        end
        site_visited_on = row['site_visited_on']
        created_at = row['Created_at']    
        business_unit_id = BusinessUnit.find_by_name(row['Project_Name']).id
        if row['Mobile_No'] == nil || row['Mobile_No'] == ""
            if row['Email_ID'] == nil || row['Email_ID'] == ""
                not_found_leads += [row]
                errors += 1
            else
                leads = Lead.where(email: row['Email_ID'], business_unit_id: business_unit_id)
                if leads == []
                    not_found_leads += [row]
                    errors += 1
                else
                    leads.each do |lead|
                        if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                        else
                            # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                            if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-30.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+31.days).to_date
                                lead.update(site_visited_on: site_visited_on.to_datetime)
                                leads_imported += 1
                                found = true
                                break
                            else
                                found = false
                            end
                        end
                    end
                    if found == false
                        not_found_leads += [row]
                        errors += 1
                    end
                end
            end
        else
            leads = Lead.where(mobile: row['Mobile_No'], business_unit_id: business_unit_id)
            if leads == []
                if row['Email_ID'] == nil || row['Email_ID'] == ""
                    not_found_leads += [row]
                    errors += 1
                else
                    leads = Lead.where(email: row['Email_ID'], business_unit_id: business_unit_id)
                    if leads == []
                        not_found_leads += [row]
                        errors += 1
                    else
                        leads.each do |lead|
                            if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                            else
                                # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                                if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-30.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+31.days).to_date
                                    lead.update(site_visited_on: site_visited_on.to_datetime)
                                    leads_imported += 1
                                    found = true
                                    break
                                else
                                    found = false
                                end
                            end
                        end
                        if found == false
                            not_found_leads += [row]
                            errors += 1
                        end
                    end
                end
            else
                leads.each do |lead|
                    if lead.lost_reason_id == 49 || lead.lost_reason_id == 54
                    else
                        # if (lead.generated_on+5.hours+30.minutes).to_date == created_at.to_date
                        if created_at.to_date >= (lead.generated_on+5.hours+30.minutes-30.days).to_date && created_at.to_date < (lead.generated_on+5.hours+30.minutes+31.days).to_date
                            lead.update(site_visited_on: site_visited_on.to_datetime)
                            leads_imported += 1
                            found = true
                            break
                        else
                            found = false
                        end
                    end
                end
                if found == false
                    not_found_leads += [row]
                    errors += 1
                end
            end
        end
    end
    UserMailer.site_visited_lead_import_errors([not_found_leads]).deliver
    return errors
  end

  def unseen_messages
    counter = 0
    self.whatsapp_followups.each do |whatsapp_followup|
        if whatsapp_followup.seen == true
        else
            if whatsapp_followup.template_message == nil
                if whatsapp_followup.remarks == nil || whatsapp_followup.remarks == ""
                    if whatsapp_followup.bot_message == nil || whatsapp_followup.bot_message == ""
                    else
                        counter += 1
                    end
                else
                    counter += 1
                end
            end
        end
    end
    return counter
  end

  def whatsapp_message_seen
    self.whatsapp_followups.each do |whatsapp_followup|
        if whatsapp_followup.seen == nil
            whatsapp_followup.update(seen: true)
        end
    end
  end
end       