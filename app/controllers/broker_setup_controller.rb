class BrokerSetupController < ApplicationController
    def broker_index
        if current_personnel.email == "ayush@thejaingroup.com"
            @brokers = Broker.all
        else
            @brokers = Broker.includes(:broker_contacts).where(:broker_contacts => {personnel_id: current_personnel.id})
        end
    end

    def broker_new
    end

    def broker_create
        broker = Broker.new
        broker.name = params[:name]
        broker.address = params[:address]
        broker.landline = params[:landline]
        broker.firm = params[:firm]
        broker.premium = params[:premium]
        broker.save

        broker_project_status = BrokerProjectStatus.new
        broker_project_status.broker_id = broker.id
        broker_project_status.business_unit_id = 70
        broker_project_status.save

        flash[:success] = "Broker Created Successfully."
        redirect_to broker_setup_broker_index_url
    end

    def broker_edit
       @broker = Broker.find(params[:format])
    end

    def broker_update
        broker = Broker.find(params[:broker_id])
        broker.update(name: params[:name], address: params[:address], firm: params[:firm], premium: params[:premium], landline: params[:landline])
        flash[:success] = "Broker Updated Successfully."
        redirect_to broker_setup_broker_index_url
    end

    def broker_destroy
        @broker = Broker.find(params[:format])
        @broker.destroy

        flash[:success] = "Broker Destroyed Successfully."
        redirect_to broker_setup_broker_index_url
    end

    def broker_contact_index
        @broker_contacts = BrokerContact.includes(:personnel).all
    end

    def broker_contact_new
        @brokers = Broker.broker_list
        @executives = []
        Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4).each do |executive|
            @executives+=[[executive.name, executive.id]]
        end
        @executives += [["Admin", 1]]
        @executives.sort!
    end

    def broker_contact_create
        broker_contact = BrokerContact.new
        broker_contact.broker_id = params[:broker_id]
        broker_contact.name = params[:name]
        broker_contact.email = params[:email]
        broker_contact.mobile_one = params[:mobile_one]
        broker_contact.mobile_two = params[:mobile_two]
        broker_contact.saved_in_phone = params[:saved_in_phone]
        broker_contact.reference = params[:reference]
        broker_contact.personnel_id = params[:personnel_id]
        broker_contact.save

        flash[:success] = "Broker Contact Created Successfully."
        redirect_to broker_setup_broker_contact_index_url
    end

    def broker_contact_edit
        @brokers = Broker.broker_list
        @executives = []
        Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4).each do |executive|
            @executives+=[[executive.name, executive.id]]
        end
        @executives += [["Admin", 1]]
        @executives.sort!
        @broker_contact = BrokerContact.find(params[:format])
    end

    def broker_contact_update
        broker_contact = BrokerContact.find(params[:broker_contact_id])
        broker_contact.update(broker_id: params[:broker_id], name: params[:name], email: params[:email], mobile_one: params[:mobile_one], mobile_two: params[:mobile_two], saved_in_phone: params[:saved_in_phone], reference: params[:reference], personnel_id: params[:personnel_id])
        flash[:success] = "Broker Contact Updated Successfully."
        redirect_to broker_setup_broker_contact_index_url
    end

    def broker_contact_destroy
        @broker_contact = BrokerContact.find(params[:format])
        @broker_contact.destroy

        flash[:success] = "Broker Contact Destroyed Successfully."
        redirect_to broker_setup_broker_contact_index_url
    end

    def broker_project_status_index
        if params[:status] == nil
            if current_personnel.email == "ayush@thejaingroup.com"
                @broker_contacts = BrokerContact.includes(:personnel).all.sort_by{|x| x.broker_id}
            else
                @broker_contacts = BrokerContact.includes(:personnel).where(personnel_id: current_personnel.id).sort_by{|x| x.broker_id}
            end
        else
            @status = params[:status]
            if @status == "All"
                @broker_contacts = BrokerContact.includes(:personnel).all.sort_by{|x| x.broker_id}
            elsif @status == "Contacted"
                @broker_contacts = BrokerContact.includes(:personnel, :broker).where(:brokers => {id: (BrokerProjectStatus.where(contacted: true).pluck(:broker_id))}).sort_by{|x| x.broker_id}
            elsif @status == "Softcopy Sent"
                @broker_contacts = BrokerContact.includes(:personnel).where(:brokers => {id: (BrokerProjectStatus.where(softcopy_collaterals_sent: true).pluck(:broker_id))}).sort_by{|x| x.broker_id}
            elsif @status == "Hardcopy Sent"
                @broker_contacts = BrokerContact.includes(:personnel).where(:brokers => {id: (BrokerProjectStatus.where(hardcopy_collaterals_sent: true).pluck(:broker_id))}).sort_by{|x| x.broker_id}
            elsif @status == "Site Visited"
                @broker_contacts = BrokerContact.includes(:personnel).where(:brokers => {id: (BrokerProjectStatus.where(site_visited: true).pluck(:broker_id))}).sort_by{|x| x.broker_id}
            elsif @status == "Contract Signed"
                @broker_contacts = BrokerContact.includes(:personnel).where(:brokers => {id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))}).sort_by{|x| x.broker_id}
            end
        end
    end

    def contract_signed_update
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(contract_signed: true)
        respond_to do |format|
            format.js { render :action => "contract_signed_update"}
        end
    end

    def sv_update
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(site_visited: true)
        respond_to do |format|
            format.js { render :action => "sv_update"}
        end
    end

    def hrd_cpy_sent_update
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(hardcopy_collaterals_sent: true)
        respond_to do |format|
            format.js { render :action => "hrd_cpy_sent_update"}
        end
    end

    def sft_cpy_sent_update
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(softcopy_collaterals_sent: true)
        respond_to do |format|
            format.js { render :action => "sft_cpy_sent_update"}
        end
    end

    def contacted_update
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(contacted: true)
        respond_to do |format|
            format.js { render :action => "contacted_update"}
        end
    end

    def sft_cpy_sent_uncheck
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(softcopy_collaterals_sent: nil)
        respond_to do |format|
            format.js { render :action => "sft_cpy_sent_uncheck"}
        end
    end

    def hrd_cpy_sent_uncheck
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(hardcopy_collaterals_sent: nil)
        respond_to do |format|
            format.js { render :action => "hrd_cpy_sent_uncheck"}
        end
    end

    def sv_uncheck
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(site_visited: nil)
        respond_to do |format|
            format.js { render :action => "sv_uncheck"}
        end
    end

    def contract_signed_uncheck
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(contract_signed: nil)
        respond_to do |format|
            format.js { render :action => "contract_signed_uncheck"}
        end
    end

    def contacted_uncheck
        broker_project_status = BrokerProjectStatus.find(params[:id].to_i)
        broker_project_status.update(contacted: nil)
        respond_to do |format|
            format.js { render :action => "contacted_uncheck"}
        end
    end

    def populate_broker_name
        @broker_contact_id = params[:id]
        @brokers = Broker.broker_list
        @brokers += [["Others", -1]]
        @broker = Broker.find(BrokerContact.find(@broker_contact_id).broker_id)
        respond_to do |format|
            format.js { render :action => "populate_broker_name"}
        end
    end

    def populate_broker_contact_name
        @broker_contact_id = params[:id]
        @broker_contact = BrokerContact.find(@broker_contact_id)
        respond_to do |format|
            format.js { render :action => "populate_broker_contact_name"}
        end
    end

    def broker_name_update
        @broker_contact_id = params[:broker_contact_id]
        @broker_id = params[:broker_id]
        BrokerContact.find(@broker_contact_id).update(broker_id: @broker_id)
        respond_to do |format|
            format.js { render :action => "broker_name_update"}
        end
    end

    def broker_contact_name_update
        @broker_contact_id = params[:broker_contact_id]
        @broker_contact_name = params[:broker_contact_name]
        BrokerContact.find(@broker_contact_id).update(name: @broker_contact_name)
        respond_to do |format|
            format.js { render :action => "broker_contact_name_update"}
        end
    end

    def broker_agreement_index
        @broker = Broker.find(params[:format])
    end

    def agreement_submit
        broker = Broker.find(params[:broker_id])
        if broker.contract_signature == nil || broker.contract_signature == ""
            broker.update(contract_signature: params[:signature_data])
            BrokerProjectStatus.find_by_broker_id(broker.id).update(contract_signed: true)
        end
        @contract_pdf = render_to_string(:partial => "broker_agreement_contract", :layout => false, :locals => {:@my_variable => broker})
        @contract_pdf = '<html><body>'+@contract_pdf+'</body></html>'
        @pdf = WickedPdf.new.pdf_from_string(@contract_pdf)
        broker.broker_contacts.each do |broker_contact|
            if broker_contact.email == nil || broker_contact.email == ""
            else
                UserMailer.broker_agreement_mail([broker, @pdf, broker_contact]).deliver
                UserMailer.signed_broker_data_mail([broker_contact]).deliver
            end
            if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "thankyou_for_registering","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21680&authkey=%21AFCg2lW0mLQwENo&width=1600&height=900"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.id.to_s}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "After Agreement Sign message sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                end
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "thankyou_for_registering","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21680&authkey=%21AFCg2lW0mLQwENo&width=1600&height=900"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.id.to_s}]}]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "After Agreement Sign message sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "thankyou_for_registering","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21680&authkey=%21AFCg2lW0mLQwENo&width=1600&height=900"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.id.to_s}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "After Agreement Sign message sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                end
            end
        end

        flash[:success] = 'Agreement Signed Successfully'
        redirect_to broker_setup_thank_you_url
    end

    def broker_leaderboard
        @broker_wise_data = {}
        BrokerContact.where(inactive: nil).each do |broker_contact|
            brochure_visit = 0
            lead_intimations = 0
            site_visits = 0
            bookings = 0
            brochure_visit = broker_contact.brochure_visit
            lead_intimations = broker_contact.lead_intimations
            site_visits = broker_contact.site_visits
            bookings = broker_contact.sales
            @broker_wise_data[broker_contact.broker.name+": "+broker_contact.name] = [brochure_visit, lead_intimations, site_visits, bookings]
        end
            @broker_wise_data = @broker_wise_data.sort_by{|_, v| v[2]}.reverse.take(25).to_h
            @broker_wise_data_keys = @broker_wise_data.keys.to_json
            @broker_wise_data_value = [{:name => 'Bookings', :data => @broker_wise_data.map { |_, v| v[3] } },{:name => 'Site Visit', :data => @broker_wise_data.map { |_, v| v[2] }},{:name => 'Lead Lintimation', :data => @broker_wise_data.map { |_, v| v[1] }},{:name => 'Brochure Visit', :data => @broker_wise_data.map { |_, v| v[0] }}].to_json.html_safe
    end

    def status_pie_chart
        total_brokers=Broker.all.count
        brokers_softcopy_collaterals_sent=BrokerProjectStatus.where(softcopy_collaterals_sent: true).count
        brokers_untouched=total_brokers-brokers_softcopy_collaterals_sent
        brokers_contacted=BrokerProjectStatus.where(contacted: true).count
        brokers_collaterals_sent_not_called=brokers_softcopy_collaterals_sent-brokers_contacted
        brokers_hardcopy_collaterals_sent=BrokerProjectStatus.where(hardcopy_collaterals_sent: true).count
        brokers_called_kit_not_sent=brokers_contacted-brokers_hardcopy_collaterals_sent
        brokers_site_visited=BrokerProjectStatus.where(site_visited: true).count
        brokers_kit_sent_not_site_visited=brokers_hardcopy_collaterals_sent-brokers_site_visited
        brokers_contract_signed=BrokerProjectStatus.where(contract_signed: true).count
        broker_site_visited_contract_not_signed=brokers_site_visited-brokers_contract_signed

        series_data=[{:name => 'Brokers Untouched', :y => brokers_untouched},{:name => 'Collateral Sent Not Called', :y => brokers_collaterals_sent_not_called},{:name => 'Called, Kit not Sent', :y => brokers_called_kit_not_sent},{:name => 'Kit Sent not Visited', :y => brokers_kit_sent_not_site_visited},{:name => 'Visited not Signed', :y => broker_site_visited_contract_not_signed},{:name => 'SignedUp', :y => brokers_contract_signed}]

        @series=[{:name => 'Broker Status', :data => series_data}].to_json.html_safe
    end


    def populate_other_broker
        @broker_contact_id = params[:broker_contact_id]
    end

    def other_broker_name_update
        @broker_contact_id = params[:broker_contact_id]
        @broker_name = params[:broker_name]
        broker = Broker.new
        broker.name = @broker_name
        broker.save
        BrokerContact.find(@broker_contact_id).update(broker_id: broker.id)
        respond_to do |format|
            format.js { render :action => "other_broker_name_update"}
        end
    end

    def status_funnel_chart
        # total_brokers=Broker.all.count
        # brokers_softcopy_collaterals_sent=BrokerProjectStatus.where(softcopy_collaterals_sent: true).count
        # brokers_untouched=total_brokers-brokers_softcopy_collaterals_sent
        # brokers_contacted=BrokerProjectStatus.where(contacted: true).count
        # brokers_collaterals_sent_not_called=brokers_softcopy_collaterals_sent-brokers_contacted
        # brokers_hardcopy_collaterals_sent=BrokerProjectStatus.where(hardcopy_collaterals_sent: true).count
        # brokers_called_kit_not_sent=brokers_contacted-brokers_hardcopy_collaterals_sent
        # brokers_site_visited=BrokerProjectStatus.where(site_visited: true).count
        # brokers_kit_sent_not_site_visited=brokers_hardcopy_collaterals_sent-brokers_site_visited
        # brokers_contract_signed=BrokerProjectStatus.where(contract_signed: true).count
        # broker_site_visited_contract_not_signed=brokers_site_visited-brokers_contract_signed

        # series_data=[['Brokers Untouched', brokers_untouched],['Collateral Sent Not Called', brokers_collaterals_sent_not_called],['Called, Kit not Sent', brokers_called_kit_not_sent],['Kit Sent not Visited', brokers_kit_sent_not_site_visited],['Visited not Signed', broker_site_visited_contract_not_signed],['SignedUp', brokers_contract_signed]]
        # @series=[{:name => 'Broker Status', :data => series_data}].to_json.html_safe
        render :layout => false

    end

    def broker_agreement_link_send
        broker_contact = BrokerContact.find(params[:format])
        if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "Push to sign agreement message sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
                # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                # result = HTTParty.post(urlstring,
                # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            end
        else
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            if result.parsed_response["messages"] == nil
            else
                message_id = result.parsed_response["messages"][0]["id"]
                whatsapp_followup = WhatsappFollowup.new
                whatsapp_followup.broker_contact_id = broker_contact.id
                whatsapp_followup.bot_message = "Push to sign agreement message sent"
                whatsapp_followup.message_id = message_id
                whatsapp_followup.save
            end
            # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            # result = HTTParty.post(urlstring,
            # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
            # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        end
        flash[:success] = "Link send successfully."
        redirect_to broker_setup_broker_index_url
    end

    def broker_source_category_tag_index
        @broker_source_category_tags = BrokerSourceCategoryTag.all
    end

    def broker_source_category_tag_new
        @source_categories = []
        SourceCategory.where(organisation_id: current_personnel.organisation_id, inactive: [nil, false]).where('heirarchy like ?', '%Agent%').each do |source_category|
            if source_category.description == "Individual Broker"
            else
                @source_categories += [[source_category.description+": ("+source_category.broker_contact_tagged.to_s+")", source_category.id]]
            end
        end
        @broker_contacts = BrokerContact.broker_contact_list
    end

    def broker_source_category_tag_create
        broker_source_category_tag = BrokerSourceCategoryTag.new
        broker_source_category_tag.source_category_id = params[:source_category_id]
        broker_source_category_tag.broker_contact_id = params[:broker_contact_id]
        broker_source_category_tag.save

        flash[:success] = "Broker Source category Created Successfully."
        redirect_to broker_setup_broker_source_category_tag_index_url
    end

    def broker_source_category_tag_edit
        @source_categories = []
        SourceCategory.where(organisation_id: current_personnel.organisation_id, inactive: [nil, false]).where('heirarchy like ?', '%Agent%').each do |source_category|
            if source_category.description == "Individual Broker"
            else 
                @source_categories += [[source_category.description+": ("+source_category.broker_contact_tagged.to_s+")", source_category.id]]
            end
        end
        @broker_contacts = BrokerContact.broker_contact_list
        @broker_source_category_tag = BrokerSourceCategoryTag.find(params[:format])
    end

    def broker_source_category_tag_update
        broker_source_category_tag = BrokerSourceCategoryTag.find(params[:broker_source_category_tag_id])
        broker_source_category_tag.update(source_category_id: params[:source_category_id], broker_contact_id: params[:broker_contact_id])

        flash[:success] = "Broker source category Updated Successfully."
        redirect_to broker_setup_broker_source_category_tag_index_url
    end

    def broker_source_category_tag_destroy
        @broker_source_category_tag = BrokerSourceCategoryTag.find(params[:format])
        @broker_source_category_tag.destroy

        flash[:success] = "Broker source category Destroyed Successfully."
        redirect_to broker_setup_broker_source_category_tag_index_url
    end


    def fresh_broker
        @executives = []
        Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4).each do |executive|
            @executives+=[[executive.name, executive.id]]
        end
        @executives.sort!
        if params[:personnel_id] == nil
            @executive = -1
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where(:follow_ups => { :broker_contact_id => nil }, personnel_id: current_personnel.id, inactive: nil)
        else
            @executive = params[:personnel_id].to_i
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where(:follow_ups => { :broker_contact_id => nil }, personnel_id: @executive, inactive: nil)
        end
    end

    def fresh_broker_followup_entry
        @gurukul_whatsapp_templates = ["gurukul_broker_invite", "gurukul_location", "gurukul_project_brief", "dream_gurukul_brochure", "60days_contract_signing", "broker_lead_intimation"]
        if params[:call] == nil
            broker_contact_id = params[:call_other_number].keys[0]
            @broker_contact = BrokerContact.find(broker_contact_id.to_i)
            if current_personnel.id == @broker_contact.personnel_id
                @broker_contact.call_broker_other_number
            end
        else
            broker_contact_id = params[:call].keys[0]
            @broker_contact = BrokerContact.find(broker_contact_id.to_i)
            if current_personnel.id == @broker_contact.personnel_id
                @broker_contact.call_the_broker
            end
        end
    end

    def broker_followup_entry
        broker_contact = BrokerContact.find(params[:broker_contact_id].to_i)
        followup = FollowUp.new
        followup.broker_contact_id = params[:broker_contact_id].to_i
        if params[:telephony_call_id] == nil || params[:telephony_call_id] == ""
            telephony_call = TelephonyCall.where(customer_number: [broker_contact.mobile_one,broker_contact.mobile_two], untagged: true).sort_by{|x| x.created_at}.last
            if telephony_call == nil
            else
                followup.telephony_call_id = telephony_call.id
                broker_contact.update(call_attempted: broker_contact.call_attempted+1)
                if followup.telephony_call.duration > 0.0 && followup.telephony_call.call_type == "Connected"
                    broker_contact.update(call_connected: broker_contact.call_connected+1)
                end
            end
        else
            followup.telephony_call_id = params[:telephony_call_id].to_i
            if broker_contact.call_attempted == nil
                broker_contact.update(call_attempted: 1)
            else
                broker_contact.update(call_attempted: broker_contact.call_attempted+1)
            end
            if broker_contact.call_connected == nil
                if followup.telephony_call.duration > 0.0 && followup.telephony_call.call_type == "Connected"
                    broker_contact.update(call_connected: 1)
                end
            else
                if followup.telephony_call.duration > 0.0 && followup.telephony_call.call_type == "Connected"
                    broker_contact.update(call_connected: broker_contact.call_connected+1)
                end
            end
        end
        followup.communication_time = DateTime.now
        followup.follow_up_time = params[:followup_date]
        followup.remarks = params[:remarks]
        followup.personnel_id = current_personnel.id
        if broker_contact.follow_ups != []
            broker_contact.follow_ups.each{|x| x.update(last: nil)}
            followup.scheduled_time = broker_contact.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
        else
            followup.first = true
        end
        followup.last = true
        followup.save
        if params[:anticipation]=='Good'
        broker_contact.update(anticipation: false)
        elsif params[:anticipation]=='Hot'    
        broker_contact.update(anticipation: true)
        end
        if params[:inactive] == true || params[:inactive] == "true"
            broker_contact.update(inactive: true)
        else
            broker_contact.update(inactive: nil)
        end
        if params[:head_count] == nil || params[:head_count] == ""
        else
            broker_contact.update(head_count: params[:head_count])
        end
        if params[:whatsapp_templates] == [] || params[:whatsapp_templates] == nil
        else
            params[:whatsapp_templates].each do |whatsapp_template_name|
                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    else
                        if whatsapp_template_name == "gurukul_broker_invite"
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+broker_contact.mobile_two.to_s,"type": "template","template": {"name": "gurukul_broker_invite","language": {"code": "en"},"components": [
                                {"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21671&authkey=%21AIjDtmPiidPvqxg&width=1600&height=1600"}}]},
                                {"type": "body","parameters": [{"type": "text","text": broker_contact.name}]},
                                {"type": "button", "sub_type": "QUICK_REPLY", "index": "0", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},
                                # call button need not be coded it appears autometically in the message.
                                {"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},
                                ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            if result.parsed_response["messages"] == nil
                            else
                                message_id = result.parsed_response["messages"][0]["id"]
                                whatsapp_followup = WhatsappFollowup.new
                                whatsapp_followup.broker_contact_id = broker_contact.id
                                whatsapp_followup.bot_message = "Invitation message sent"
                                whatsapp_followup.message_id = message_id
                                whatsapp_followup.save
                            end
                        elsif whatsapp_template_name == "dream_gurukul_brochure"
                            link_text = ""
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_two.to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_two.to_s
                            end
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        elsif whatsapp_template_name == "60days_contract_signing" 
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        elsif whatsapp_template_name == "broker_lead_intimation"
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        else
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            p result
                            p "============project details result===================="
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    end
                else
                    if whatsapp_template_name == "gurukul_broker_invite"
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+broker_contact.mobile_one.to_s,"type": "template","template": {"name": "gurukul_broker_invite","language": {"code": "en"},"components": [
                            {"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21671&authkey=%21AIjDtmPiidPvqxg&width=1600&height=1600"}}]},
                            {"type": "body","parameters": [{"type": "text","text": broker_contact.name}]},
                            {"type": "button", "sub_type": "QUICK_REPLY", "index": "0", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},
                            # call button need not be coded it appears autometically in the message.
                            {"type": "button", "sub_type": "QUICK_REPLY", "index": "1", "parameters": [{"type": "payload","payload": "PAYLOAD"}]},
                            ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Invitation message sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    elsif whatsapp_template_name == "dream_gurukul_brochure"
                        link_text = ""
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_one.to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_one.to_s
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    elsif whatsapp_template_name == "60days_contract_signing" 
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    elsif whatsapp_template_name == "broker_lead_intimation"
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    else
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        p result
                        p "============project details result===================="
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                        else 
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            p result
                            p "============project details result===================="
                            if result.parsed_response["messages"] == nil
                            else
                                whatsapp_followup = WhatsappFollowup.new
                                whatsapp_followup.broker_contact_id = broker_contact.id
                                whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                message_data = result.parsed_response
                                message_id = message_data["messages"]
                                message_id = message_id[0]["id"]
                                whatsapp_followup.message_id = message_id
                                whatsapp_followup.save
                            end
                        end
                    end
                end
            end
        end
        if followup.telephony_call_id == nil
        else
            if followup.telephony_call.duration > 10.0
                if params[:status] == "Hardcopy Sent"
                    BrokerProjectStatus.find_by_broker_id(broker_contact.broker_id).update(contacted: true, hardcopy_collaterals_sent: true)
                elsif params[:status] == "Site Visited"
                    BrokerProjectStatus.find_by_broker_id(broker_contact.broker_id).update(contacted: true, site_visited: true)
                elsif params[:status] == "Invitation accepted"
                if broker_contact.accept_invitation==true
                else
                    broker_contact.update(accept_invitation: true)
                    link_text = ""
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s
                            end
                        else
                            # location
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+broker_contact.mobile_two.to_s,"type": "template","template": {"name": "thankyou_accept_invitation","language": {"code": "en"},"components": [
                            {"type": "header","parameters": [{"type": "location","location": {"longitude": "88.4590", "latitude": "22.6773", "name": "Dream Gurukul", "address": "Ward 26, Dream Gurukul, 154, Old Jessore Rd, Ganganagar, Fortune City, Madhyamgram, Kolkata, West Bengal 700132"}}]}]
                            }}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Location Link Sent"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                            
                            # brochure
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
                            end
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Brochure Link Sent"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                            
                            # agreement
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Agreement Link Sent"
                            message_data = result.parsed_response
                            message_id = message_data["messages"]
                            message_id = message_id[0]["id"]
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    else
                        # location
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","recipient_type": "individual","to": "91"+broker_contact.mobile_one.to_s,"type": "template","template": {"name": "thankyou_accept_invitation","language": {"code": "en"},"components": [
                        {"type": "header","parameters": [{"type": "location","location": {"longitude": "88.4590", "latitude": "22.6773", "name": "Dream Gurukul", "address": "Ward 26, Dream Gurukul, 154, Old Jessore Rd, Ganganagar, Fortune City, Madhyamgram, Kolkata, West Bengal 700132"}}]}]
                        }}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Location Link Sent"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save

                        # brochure
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Brochure Link Sent"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save

                        # agreement
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Agreement Link Sent"
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                end
                elsif params[:status] == "Not Interested"
                    broker_contact.update(accept_invitation: false)
                else
                    if followup.telephony_call.call_type == "Connected"
                        BrokerProjectStatus.find_by_broker_id(broker_contact.broker_id).update(contacted: true)
                    end
                end
            else
                if params[:status] == "Hardcopy Sent"
                    BrokerProjectStatus.find_by_broker_id(broker_contact.broker_id).update(contacted: true, hardcopy_collaterals_sent: true)
                elsif params[:status] == "Site Visited"
                    BrokerProjectStatus.find_by_broker_id(broker_contact.broker_id).update(contacted: true, site_visited: true)
                elsif params[:status] == "Invitation accepted"
                    broker_contact.update(accept_invitation: true)
                elsif params[:status] == "Not Interested"
                    broker_contact.update(accept_invitation: false)
                end
            end
        end

        flash[:success] = "followup entry done successfully."
        if params["update"] == nil
            redirect_to broker_setup_followup_broker_url
        else
            redirect_to broker_setup_fresh_broker_url
        end
    end

    def followup_broker
        @executives = []
        Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4).each do |executive|
            @executives+=[[executive.name, executive.id]]
        end
        @executives.sort!
        if params[:personnel_id] == nil
            @executive = -1
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where( :follow_ups => {:last => true}, inactive: nil, personnel_id: current_personnel.id).where('follow_ups.follow_up_time < ?', Date.today+1.day)
        else
            @executive = params[:personnel_id].to_i
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where( :follow_ups => {:last => true}, personnel_id: @executive, inactive: nil).where('follow_ups.follow_up_time < ?', Date.today+1.day)
        end
    end

    def broker_followup_history
        @gurukul_whatsapp_templates = ["gurukul_broker_invite", "gurukul_location", "gurukul_project_brief", "dream_gurukul_brochure", "60days_contract_signing", "broker_lead_intimation"]
        if params[:call] == nil
            broker_contact_id = params[:call_other_number].keys[0]
            @broker_contact = BrokerContact.find(broker_contact_id.to_i)
            if current_personnel.id == @broker_contact.personnel_id
                @broker_contact.call_broker_other_number
            end
        else
            broker_contact_id = params[:call].keys[0]
            @broker_contact = BrokerContact.find(broker_contact_id.to_i)
            if current_personnel.id == @broker_contact.personnel_id
                @broker_contact.call_the_broker
            end
        end
    end

    def future_followup_broker
        @executives = []
        Personnel.where(organisation_id: current_personnel.organisation_id).where('access_right is ? OR access_right = ? OR access_right = ?', nil, 2, 4).each do |executive|
            @executives+=[[executive.name, executive.id]]
        end
        @executives.sort!
        if params[:personnel_id] == nil
            @executive = -1
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where( :follow_ups => {:last => true}, personnel_id: current_personnel.id, inactive: nil).where('follow_ups.follow_up_time >= ?', Date.today+1.day)
            @day_1_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+1.day, Date.today+2.days).count
            @day_2_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+2.day, Date.today+3.days).count
            @day_3_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+3.day, Date.today+4.days).count
            @day_4_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+4.day, Date.today+5.days).count
            @day_5_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+5.day, Date.today+6.days).count
            @day_6_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+6.day, Date.today+7.days).count
            @day_7_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+7.day, Date.today+8.days).count
        else
            @executive = params[:personnel_id].to_i
            @broker_contacts = BrokerContact.includes(:personnel, :follow_ups).where( :follow_ups => {:last => true}, personnel_id: @executive, inactive: nil).where('follow_ups.follow_up_time >= ?', Date.today+1.day)
            @day_1_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+1.day, Date.today+2.days).count
            @day_2_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+2.day, Date.today+3.days).count
            @day_3_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+3.day, Date.today+4.days).count
            @day_4_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+4.day, Date.today+5.days).count
            @day_5_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+5.day, Date.today+6.days).count
            @day_6_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+6.day, Date.today+7.days).count
            @day_7_count = @broker_contacts.where('follow_ups.follow_up_time >= ? and follow_ups.follow_up_time < ?', Date.today+7.day, Date.today+8.days).count
        end
    end

    def broker_future_followup_reschedule
        if params[:call] == nil
            params[:broker_contact_ids].each do |broker_contact_id|
                broker_contact = BrokerContact.find(broker_contact_id)
                followup = FollowUp.new
                followup.broker_contact_id = broker_contact_id
                followup.communication_time = DateTime.now
                followup.follow_up_time = params[:followup_date]
                followup.remarks = params[:remarks]
                followup.personnel_id = current_personnel.id
                if broker_contact.follow_ups != []
                    broker_contact.follow_ups.each{|x| x.update(last: nil)}
                    followup.scheduled_time = broker_contact.follow_ups.sort_by{|x| [x.created_at, x.id] }.last.follow_up_time
                else
                    followup.first = true
                end
                followup.last = true
                followup.save
            end
            flash[:success] = "followup entry done successfully."
            redirect_to broker_setup_future_followup_broker_url
        else
            redirect_to :controller => "broker_setup", :action => "broker_followup_history", params: request.request_parameters
        end
    end

    def broker_contact_search
        if request.get?
            @broker_contacts = []
        elsif params[:call] != nil
            redirect_to :controller => "broker_setup", :action => "broker_followup_history", params: request.request_parameters
        else
            if params['id_search'] == 'Search'
                @broker_contacts = BrokerContact.where(id: params[:broker_contact_id])
                if current_personnel.email == "pranabeshpratiharjgm@gmail.com" || current_personnel.email == "dibakar@thejaingroup.com" || current_personnel.email == "sales.dreamgurukul2@thejaingroup.com"
                    if @broker_contacts == []
                        redirect_to broker_setup_fresh_broker_and_broker_contact_url
                    end
                end
            elsif params['name_search'] == 'Search'
                @broker_contacts = BrokerContact.where(name: params[:broker_contact_name])
                if current_personnel.email == "pranabeshpratiharjgm@gmail.com" || current_personnel.email == "dibakar@thejaingroup.com" || current_personnel.email == "sales.dreamgurukul2@thejaingroup.com"
                    if @broker_contacts == []
                        redirect_to broker_setup_fresh_broker_and_broker_contact_url
                    end
                end
            # elsif params['email_search'] == 'Search'
            #     @broker_contacts = BrokerContact.where(id: params[:broker_contact_id])
            elsif params['mobile_search'] == 'Search'
                @broker_contacts = BrokerContact.where('mobile_one = ? OR mobile_two = ?', params[:broker_contact_mobile], params[:broker_contact_mobile])
                if current_personnel.email == "pranabeshpratiharjgm@gmail.com" || current_personnel.email == "dibakar@thejaingroup.com" || current_personnel.email == "sales.dreamgurukul2@thejaingroup.com"
                    if @broker_contacts == []
                        redirect_to broker_setup_fresh_broker_and_broker_contact_url
                    end
                end
            end
        end
    end

    def fresh_broker_and_broker_contact
        @brokers = Broker.broker_list
    end

    def fresh_broker_and_broker_contact_create
        if params[:broker_id] == ""
            if params[:broker_name] == "Individual Broker"
                params[:name].each_with_index do |name, index|
                    broker = Broker.new
                    broker.name = "Individual Broker "+params[:broker_name]
                    broker.save

                    broker_project_status = BrokerProjectStatus.new
                    broker_project_status.broker_id = broker.id
                    broker_project_status.business_unit_id = 70
                    broker_project_status.save

                    broker_contact = BrokerContact.new
                    broker_contact.broker_id = broker.id
                    broker_contact.name = params[:name]
                    broker_contact.email = params[:email][index]
                    broker_contact.mobile_one = params[:mobile_one][index]
                    broker_contact.mobile_two = params[:mobile_two][index]
                    broker_contact.personnel_id = current_personnel.id
                    broker_contact.site_visited = true
                    broker_contact.save
                    link_text = ""
                    if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s
                            end
                        else
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
                            end
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "SV thank you message sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Brochure Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                       
                        # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        # result = HTTParty.post(urlstring,
                        # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                        # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Agreement Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    else
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "SV thank you message sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Brochure Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        # result = HTTParty.post(urlstring,
                        # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                        # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Agreement Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    alert_message = "Channel Partner Arrived at site:"+"\n"+"\n"+"*Name:* "+broker_contact.name+"\n"+"*Mobile:* "+broker_contact.mobile_one.to_s+"\n"+"*Alternate No.:* "+broker_contact.mobile_two.to_s+"\n"+"\n"+"*Contract Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919831182225", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end                
            else
                broker = Broker.new
                broker.name = params[:broker_name]
                broker.save

                broker_project_status = BrokerProjectStatus.new
                broker_project_status.broker_id = broker.id
                broker_project_status.business_unit_id = 70
                broker_project_status.save

                params[:name].each_with_index do |name, index|
                    broker_contact = BrokerContact.new
                    broker_contact.broker_id = broker.id
                    broker_contact.name = params[:name][index]
                    broker_contact.email = params[:email][index]
                    broker_contact.mobile_one = params[:mobile_one][index]
                    broker_contact.mobile_two = params[:mobile_two][index]
                    broker_contact.personnel_id = current_personnel.id
                    broker_contact.site_visited = true
                    broker_contact.save
                    link_text = ""
                    if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s
                            end
                        else
                            if broker_contact.email == nil || broker_contact.email == ""
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
                            else
                                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
                            end
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "SV thank you message sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Brochure Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                       
                        # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        # result = HTTParty.post(urlstring,
                        # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                        # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Agreement Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    else
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "SV thank you message sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Brochure Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                        # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        # result = HTTParty.post(urlstring,
                        # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                        # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if result.parsed_response["messages"] == nil
                        else
                            message_id = result.parsed_response["messages"][0]["id"]
                            whatsapp_followup = WhatsappFollowup.new
                            whatsapp_followup.broker_contact_id = broker_contact.id
                            whatsapp_followup.bot_message = "Agreement Link Sent"
                            whatsapp_followup.message_id = message_id
                            whatsapp_followup.save
                        end
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    alert_message = "Channel Partner Arrived at site:"+"\n"+"\n"+"*Name:* "+broker_contact.name+"\n"+"*Mobile:* "+broker_contact.mobile_one.to_s+"\n"+"*Alternate No.:* "+broker_contact.mobile_two.to_s+"\n"+"\n"+"*Contract Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919831182225", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
            end
        else
            broker = Broker.find(params[:broker_id])
            params[:name].each_with_index do |name, index|
                broker_contact = BrokerContact.new
                broker_contact.broker_id = broker.id
                broker_contact.name = params[:name][index]
                broker_contact.email = params[:email][index]
                broker_contact.mobile_one = params[:mobile_one][index]
                broker_contact.mobile_two = params[:mobile_two][index]
                broker_contact.personnel_id = current_personnel.id
                broker_contact.site_visited = true
                broker_contact.save
                link_text = ""
                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s
                        end
                    else
                        if broker_contact.email == nil || broker_contact.email == ""
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
                        else
                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
                        end
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "SV thank you message sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Brochure Link Sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                   
                    # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    # result = HTTParty.post(urlstring,
                    # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                    # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Agreement Link Sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                else
                    if broker_contact.email == nil || broker_contact.email == ""
                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
                    else
                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "SV thank you message sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Brochure Link Sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                    # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    # result = HTTParty.post(urlstring,
                    # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                    # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if result.parsed_response["messages"] == nil
                    else
                        message_id = result.parsed_response["messages"][0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Agreement Link Sent"
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    end
                end
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                alert_message = "Channel Partner Arrived at site:"+"\n"+"\n"+"*Name:* "+broker_contact.name+"\n"+"*Mobile:* "+broker_contact.mobile_one.to_s+"\n"+"*Alternate No.:* "+broker_contact.mobile_two.to_s+"\n"+"\n"+"*Contract Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919831182225", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
            end
        end
        flash[:success] = "Broker Updated Successfully."
        redirect_to broker_setup_broker_contact_search_url
    end

    def site_visited_update
        broker_contact = BrokerContact.find(params[:id].to_i)
        broker_contact.update(site_visited: true)
        if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "SV thank you message sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
                # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                # result = HTTParty.post(urlstring,
                # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "Agreement Link sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
            end
        else
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            if result.parsed_response["messages"] == nil
            else
                message_id = result.parsed_response["messages"][0]["id"]
                whatsapp_followup = WhatsappFollowup.new
                whatsapp_followup.broker_contact_id = broker_contact.id
                whatsapp_followup.bot_message = "SV thank you message sent"
                whatsapp_followup.message_id = message_id
                whatsapp_followup.save
            end
            # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            # result = HTTParty.post(urlstring,
            # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
            # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            if result.parsed_response["messages"] == nil
            else
                message_id = result.parsed_response["messages"][0]["id"]
                whatsapp_followup = WhatsappFollowup.new
                whatsapp_followup.broker_contact_id = broker_contact.id
                whatsapp_followup.bot_message = "Agreement Link sent"
                whatsapp_followup.message_id = message_id
                whatsapp_followup.save
            end
            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
            else
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_sv_thankyou","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21756&authkey=%21AJKcta1sHaDR2kM&width=1600&height=1600"}}] } ]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "SV thank you message sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
                # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                # result = HTTParty.post(urlstring,
                # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s} ] } ]}}.to_json,
                # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_revised_agreement_link","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21679&authkey=%21AGFuHzOpWONAJoY&width=1366&height=767"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.broker.id.to_s}]}]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "Agreement Link sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end
            end
        end
        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
        alert_message = "Channel Partner Arrived at site:"+"\n"+"\n"+"*Name:* "+broker_contact.name+"\n"+"*Mobile:* "+broker_contact.mobile_one.to_s+"\n"+"*Alternate No.:* "+broker_contact.mobile_two.to_s+"\n"+"\n"+"*Contract Link:* https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker_contact.broker.id.to_s
        result = HTTParty.post(urlstring,
        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        result = HTTParty.post(urlstring,
        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919831182225", "type": "text", "text": {"preview_url": false, "body" => alert_message}}.to_json,
        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        
        respond_to do |format|
            format.js { render :action => "site_visited_update"}
        end
    end

    def broker_logo_upload_index
        @broker = Broker.find(params[:format])
    end

    def broker_logo_upload
        if params[:commit] == "Upload"
            p "==================================================="
            p params
            p "==================================================="

            # broker = Broker.find(params[:broker_id])
            # broker_logo = params[:broker_logo]


            # flash[:success] = "Logo Uploaded Successfully."
            redirect_to broker_setup_thank_you_url
        else
            broker = Broker.find(params[:format])
            message ="To Upload your company logo please click on the link given below: "+"\n"+"\n"+"https://www.realtybucket.com/broker_setup/broker_logo_upload_index."+broker.id.to_s
            broker.broker_contacts.each do |broker_contact|
                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    else
                        urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
                        result = HTTParty.post(urlstring,
                        :body => { :to_number => '+91'+broker_contact.mobile_two.to_s,
                           :message => message,
                            :type => "text"
                            }.to_json,
                            :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                    end
                else
                    urlstring =  "https://api.maytapi.com/api/89a92550-8408-44c0-ade2-d13bf1247083/21511/sendMessage"
                    result = HTTParty.post(urlstring,
                    :body => { :to_number => '+91'+broker_contact.mobile_one.to_s,
                       :message => message,
                        :type => "text"
                        }.to_json,
                        :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'9cebccdc-2f25-4576-bc9e-ba01a941c61e' } )
                end
                sleep(3)
            end
            flash[:success] = "Logo Upload Link send successfully."
            redirect_to broker_setup_broker_index_url
        end
    end

    def broker_contact_whatsapp
        @broker_contact = BrokerContact.find(params[:format])
    end

    def broker_contact_whatsapp_index
        if params[:format] == nil
            @broker_contacts = BrokerContact.includes(:personnel => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}, inactive: nil)
            # @broker_contacts = BrokerContact.all
            @selected_broker_contact = nil
        else
            @broker_contacts = BrokerContact.includes(:personnel => [:business_unit]).where(:business_units => {organisation_id: current_personnel.organisation_id}, inactive: nil)
            # @broker_contacts = BrokerContact.all
            @selected_broker_contact = BrokerContact.find(params[:format])
        end
    end
    def broker_contact_whatsapp_massages
        if params[:reply_to_customer] == nil
        else
            broker_contact = BrokerContact.find(params[:broker_contact_id])
            reply = params[:reply_to_customer]
            if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            else
                urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                p result
                p "===================="
                message_data = result.parsed_response
                message_id = message_data["messages"]
                message_id = message_id[0]["id"]
                whatsapp_followup = WhatsappFollowup.new
                whatsapp_followup.broker_contact_id = broker_contact.id
                whatsapp_followup.bot_message = reply.to_s
                whatsapp_followup.message_id = message_id
                whatsapp_followup.save
            end
            redirect_to :back
        end
    end

    def broker_contact_whatsapp_massage
        @gurukul_whatsapp_templates = ["gurukul_location", "gurukul_project_brief", "dream_gurukul_brochure", "60days_contract_signing", "broker_lead_intimation"]
        if params[:reply_to_customer] == nil && params[:other_details] == nil
        else
            customer_number = params[:customer_number]
            whatsapp_number = params[:whatsapp_number]
            broker_contact = nil
            broker_contacts = BrokerContact.where('mobile_one = ? OR mobile_two = ?', customer_number[2..customer_number.length], customer_number[2..customer_number.length])
            if broker_contacts == []
            else
                if broker_contacts.count == 1
                    broker_contact  = broker_contacts[0]
                end
            end
            if broker_contact == nil
            else
                if params[:other_details] == nil
                    reply = params[:reply_to_customer]
                    urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    p result
                    p "===================="
                    data = [customer_number, whatsapp_number, reply]
                    UserMailer.sending_whatsapp_to_customer(data).deliver
                    message_data = result.parsed_response
                    message_id = message_data["messages"]
                    message_id = message_id[0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "Agent Reply: "+reply.to_s
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                else
                    if params[:reply_to_customer] == ""
                        params[:whatsapp_templates].each do |whatsapp_template_name|
                            if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                else
                                    if whatsapp_template_name == "dream_gurukul_brochure"
                                        link_text = ""
                                        if broker_contact.email == nil || broker_contact.email == ""
                                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_two.to_s
                                        else
                                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_two.to_s
                                        end
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    elsif whatsapp_template_name == "60days_contract_signing" 
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    elsif whatsapp_template_name == "broker_lead_intimation"
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    else
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        p result
                                        p "============project details result===================="
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    end
                                end
                            else
                                if whatsapp_template_name == "dream_gurukul_brochure"
                                    link_text = ""
                                    if broker_contact.email == nil || broker_contact.email == ""
                                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_one.to_s
                                    else
                                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_one.to_s
                                    end
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                elsif whatsapp_template_name == "60days_contract_signing" 
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                elsif whatsapp_template_name == "broker_lead_intimation"
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                else
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    p result
                                    p "============project details result===================="
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                    else 
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        p result
                                        p "============project details result===================="
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    end
                                end
                            end
                        end
                    else
                        reply = params[:reply_to_customer]
                        urlstring = "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": customer_number.to_s, "type": "text", "text": {"preview_url": false, "body" => reply.to_s}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        p result
                        p "===================="
                        data = [customer_number, whatsapp_number, reply]
                        UserMailer.sending_whatsapp_to_customer(data).deliver
                        message_data = result.parsed_response
                        message_id = message_data["messages"]
                        message_id = message_id[0]["id"]
                        whatsapp_followup = WhatsappFollowup.new
                        whatsapp_followup.broker_contact_id = broker_contact.id
                        whatsapp_followup.bot_message = "Agent Reply: "+reply.to_s
                        whatsapp_followup.message_id = message_id
                        whatsapp_followup.save
                    
                        params[:whatsapp_templates].each do |whatsapp_template_name|
                            if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                else
                                    if whatsapp_template_name == "dream_gurukul_brochure"
                                        link_text = ""
                                        if broker_contact.email == nil || broker_contact.email == ""
                                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_two.to_s
                                        else
                                            link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_two.to_s
                                        end
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    elsif whatsapp_template_name == "60days_contract_signing" 
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    elsif whatsapp_template_name == "broker_lead_intimation"
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    else
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        p result
                                        p "============project details result===================="
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    end
                                end
                            else
                                if whatsapp_template_name == "dream_gurukul_brochure"
                                    link_text = ""
                                    if broker_contact.email == nil || broker_contact.email == ""
                                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.mobile_one.to_s
                                    else
                                        link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s+"&mobile="+broker_contact.mobile_one.to_s
                                    end
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                elsif whatsapp_template_name == "60days_contract_signing" 
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "60days_contract_signing","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": " https://www.realtybucket.com/broker_setup/broker_agreement_index."+broker.id.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})    
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                elsif whatsapp_template_name == "broker_lead_intimation"
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                else
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                    p result
                                    p "============project details result===================="
                                    whatsapp_followup = WhatsappFollowup.new
                                    whatsapp_followup.broker_contact_id = broker_contact.id
                                    whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                    message_data = result.parsed_response
                                    message_id = message_data["messages"]
                                    message_id = message_id[0]["id"]
                                    whatsapp_followup.message_id = message_id
                                    whatsapp_followup.save
                                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                    else 
                                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                        result = HTTParty.post(urlstring,
                                        :body => { "messaging_product": "whatsapp", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": { "name": whatsapp_template_name.to_s, "language": { "code": "en" } } }.to_json,
                                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                        p result
                                        p "============project details result===================="
                                        whatsapp_followup = WhatsappFollowup.new
                                        whatsapp_followup.broker_contact_id = broker_contact.id
                                        whatsapp_followup.bot_message = whatsapp_template_name.to_s+" sent in whatsapp"
                                        message_data = result.parsed_response
                                        message_id = message_data["messages"]
                                        message_id = message_id[0]["id"]
                                        whatsapp_followup.message_id = message_id
                                        whatsapp_followup.save
                                    end
                                end
                            end
                        end
                    end
                end
            end

            flash[:success] = "whatsapp sent successfully."
            redirect_to :back
        end
    end

    def broker_lead_intimation_form
        @business_units = []
        BusinessUnit.where(organisation_id: 1).each do |business_unit|
        @business_units += [[business_unit.name, business_unit.id]]
        end
    end

    def broker_lead_intimation_remarks
    broker_lead_intimation = BrokerLeadIntimation.find(params[:lead_selection].to_i)
    broker_lead_intimation.update(remarks: params[:remarks])
    redirect_to :back
    end



    def broker_lead_intimation
        if params[:broker_contact_id] == nil
            lost_reasons = LostReason.where(organisation_id: current_personnel.organisation_id).pluck(:id)
            lost_reasons = lost_reasons-[57,49]
            lost_reasons = lost_reasons+[nil]
            @broker_lead_intmations_without_lead_id = BrokerLeadIntimation.where(lead_id: nil).order(created_at: :desc)
            @broker_lead_intmations_with_lead_id = BrokerLeadIntimation.includes(:lead).where(:leads => {lost_reason_id: lost_reasons}).where('broker_lead_intimations.lead_id > ?', 0).order(created_at: :desc)
        else
            duplicate_entry = false
            intimation_found_with_name = []
            leads_found_with_name = []
            live_leads = []
            lost_leads = []
            mobile_data = params[:mobile].to_s+"%"
            broker_lead_intimations = BrokerLeadIntimation.where('mobile LIKE ?', params[:mobile]+"%").where.not(lead_id: 0)
            leads = Lead.where(business_unit_id: params[:business_unit_id]).where('mobile like ?', params[:mobile]+'%')
            if broker_lead_intimations == [] && leads == []
                data = [params[:broker_contact_id], params[:business_unit_id], params[:name],params[:email],params[:mobile]]
                UserMailer.fresh_lead_intimation_alert(data).deliver
                broker_contact = BrokerContact.find(params[:broker_contact_id])
                if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    else
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                else
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    else
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    end
                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    result = HTTParty.post(urlstring,
                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                end
            elsif broker_lead_intimations == []
                # leads_found_with_name = leads.where('name like ?' , "%"+params[:name].to_s+"%")
                leads_found_with_name = []
                leads.each do |lead|
                    exisiting_name = lead.name.downcase
                    intimated_name = params[:name].downcase
                    levenshtein_distance = Text::Levenshtein.distance(exisiting_name, params[:name])
                    max_length = [exisiting_name.length, params[:name].length].max
                    similarity_percentage = ((max_length - levenshtein_distance) / max_length.to_f) * 100
                    leads_found_with_name += [[lead, similarity_percentage]]
                    leads_found_with_name = leads_found_with_name.sort_by{|x| x[1]}.reverse.first(5)
                end
                if leads_found_with_name == []
                else
                    leads_found_with_name.each do |lead_data|
                        if lead_data[0].lost_reason_id == nil && lead_data[0].booked_on == nil
                            live_leads += [lead_data[0]]
                        elsif lead_data[0].lost_reason_id != nil && lead_data[0].booked_on != nil
                            lost_leads += [lead_data[0]]
                        end
                    end
                    if live_leads == []
                        if lost_leads == []
                        else
                            data = [lost_leads, "Lost Leads found", params[:broker_contact_id], params[:business_unit_id], params[:name],params[:email],params[:mobile]]
                            UserMailer.lead_intimation_found(data).deliver
                            broker_contact = BrokerContact.find(params[:broker_contact_id])
                            if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                else
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                end
                                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                result = HTTParty.post(urlstring,
                                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            else
                                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                result = HTTParty.post(urlstring,
                                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                                else
                                    urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                    result = HTTParty.post(urlstring,
                                    :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                    :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                                end
                                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                result = HTTParty.post(urlstring,
                                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            end
                        end
                    else
                        data = [live_leads, "Live Leads found", params[:broker_contact_id], params[:business_unit_id], params[:name],params[:email],params[:mobile]]
                        UserMailer.lead_intimation_found(data).deliver
                        broker_contact = BrokerContact.find(params[:broker_contact_id])
                        if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                            else
                                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                result = HTTParty.post(urlstring,
                                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            end
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        else
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                            else
                                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                                result = HTTParty.post(urlstring,
                                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                            end
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        end
                    end    
                end
            elsif leads == []
                # intimation_found_with_name = broker_lead_intimations.where('name like ?', "%"+params[:name].to_s+"%")
                intimation_found_with_name = []
                broker_lead_intimations.each do |broker_lead_intimation|
                    exisiting_name = broker_lead_intimation.name.downcase
                    intimated_name = params[:name].downcase
                    levenshtein_distance = Text::Levenshtein.distance(exisiting_name, params[:name])
                    max_length = [exisiting_name.length, params[:name].length].max
                    similarity_percentage = ((max_length - levenshtein_distance) / max_length.to_f) * 100
                    intimation_found_with_name += [[broker_lead_intimation, similarity_percentage]]
                    intimation_found_with_name = intimation_found_with_name.sort_by{|x| x[1]}.reverse.first(5)
                end
                p intimation_found_with_name
                data = []
                if intimation_found_with_name == []
                else
                    data = [intimation_found_with_name, "Intimation found", params[:broker_contact_id], params[:business_unit_id], params[:name],params[:email],params[:mobile]]
                    UserMailer.lead_intimation_found(data).deliver
                    broker_contact = BrokerContact.find(params[:broker_contact_id])
                    if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                        else
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    else
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                        else
                            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                            result = HTTParty.post(urlstring,
                            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                        end
                        urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                        result = HTTParty.post(urlstring,
                        :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                        :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    end
                end
            else
                intimation_found_with_name = []
                broker_lead_intimations.each do |broker_lead_intimation|
                    exisiting_name = broker_lead_intimation.name.downcase
                    intimated_name = params[:name].downcase
                    levenshtein_distance = Text::Levenshtein.distance(exisiting_name, params[:name])
                    max_length = [exisiting_name.length, params[:name].length].max
                    similarity_percentage = ((max_length - levenshtein_distance) / max_length.to_f) * 100
                    intimation_found_with_name += [[broker_lead_intimation, similarity_percentage]]
                    intimation_found_with_name = intimation_found_with_name.sort_by{|x| x[1]}.reverse.first(5)
                end
                data = []
                if intimation_found_with_name == []
                else
                    data = [intimation_found_with_name, "Intimation found", params[:broker_contact_id], params[:business_unit_id], params[:name],params[:email],params[:mobile]]
                    UserMailer.lead_intimation_found(data).deliver
                    # broker_contact = BrokerContact.find(params[:broker_contact_id])
                    # if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
                    #     if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    #     else
                    #         urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    #         result = HTTParty.post(urlstring,
                    #         :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    #         :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    #     end
                    #     urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    #     result = HTTParty.post(urlstring,
                    #     :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    #     :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    # else
                    #     urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    #     result = HTTParty.post(urlstring,
                    #     :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    #     :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    #     if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                    #     else
                    #         urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    #         result = HTTParty.post(urlstring,
                    #         :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    #         :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    #     end
                    #     urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                    #     result = HTTParty.post(urlstring,
                    #     :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "919903821111", "type": "template", "template": {"name": "cp_lead_intimation_acknowledgement", "language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=3F3CF1D351D4BABC%21762&authkey=%21AJA0PMIsa_wUCfg&width=940&height=788"}}]},{"type": "body","parameters": [{"type": "text","text": broker_contact.name.to_s}, {"type": "text","text": DateTime.now.to_date.strftime('%d/%m/%Y')}, {"type": "text","text": params[:name]}, {"type": "text","text": params[:mobile]}]}]}}.to_json,
                    #     :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                    # end
                end
                leads_found_with_name = []
                leads.each do |lead|
                    exisiting_name = lead.name.downcase
                    intimated_name = params[:name].downcase
                    levenshtein_distance = Text::Levenshtein.distance(exisiting_name, params[:name])
                    max_length = [exisiting_name.length, params[:name].length].max
                    similarity_percentage = ((max_length - levenshtein_distance) / max_length.to_f) * 100
                    if similarity_percentage.to_f >= 50.00
                        leads_found_with_name += [lead]
                    end
                    leads_found_with_name += [[lead, similarity_percentage]]
                    leads_found_with_name = leads_found_with_name.sort_by{|x| x[1]}.reverse.first(5)
                end
            end
            if BrokerLeadIntimation.where(business_unit_id: params[:business_unit_id], mobile: params[:mobile]).where.not(lead_id: 0) == []
                broker_lead_intimation = BrokerLeadIntimation.new
                broker_lead_intimation.broker_contact_id = params[:broker_contact_id]
                broker_lead_intimation.business_unit_id = params[:business_unit_id]
                broker_lead_intimation.name = params[:name]
                broker_lead_intimation.email = params[:email]
                broker_lead_intimation.mobile = params[:mobile]
                broker_lead_intimation.save
            else
                duplicate_entry = true
            end
            if duplicate_entry == true
                flash[:danger] = "Lead Intimation not created because the lead is already exist in our system, Please contact with Dibakar Das(9903821111) to confirm the same, and for any further query."
            else
                flash[:success] = "Lead Intimation Generated Successfully."
            end
            redirect_to broker_setup_thank_you_url
        end
    end

    def broker_lead_intimation_destroy
        BrokerLeadIntimation.find(params[:format]).destroy

        flash[:success] = "Lead Intimation Destroyed Successfully."
        redirect_to broker_setup_broker_lead_intimation_url
    end

    def update_lead_id
        broker_lead_intimation = BrokerLeadIntimation.find(params[:format])
        broker_lead_intimation.update(lead_id: 0)
        
        flash[:success] = "Lead Intimation Removed Successfully."
        redirect_to broker_setup_broker_lead_intimation_url
    end

    def broker_lead_intimation_link_send
        broker_contact = BrokerContact.find(params[:format])
        if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
            else
                
                urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
                result = HTTParty.post(urlstring,
                :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "thankyou_for_registering","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21680&authkey=%21AFCg2lW0mLQwENo&width=1600&height=900"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.id.to_s}]}]}}.to_json,
                :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
                if result.parsed_response["messages"] == nil
                else
                    message_id = result.parsed_response["messages"][0]["id"]
                    whatsapp_followup = WhatsappFollowup.new
                    whatsapp_followup.broker_contact_id = broker_contact.id
                    whatsapp_followup.bot_message = "After Agreement Sign message sent"
                    whatsapp_followup.message_id = message_id
                    whatsapp_followup.save
                end

                p result
            end
        else
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": "91"+broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "thankyou_for_registering","language": {"code": "en"}, "components": [{"type": "header","parameters": [{"type": "image","image": {"link": "https://onedrive.live.com/download?resid=55E14145A4D50C02%21680&authkey=%21AFCg2lW0mLQwENo&width=1600&height=900"}}]},{"type": "button", "sub_type": "url", "index": "0", "parameters": [{"type": "text","text": broker_contact.id.to_s}]}]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            if result.parsed_response["messages"] == nil
            else
                message_id = result.parsed_response["messages"][0]["id"]
                whatsapp_followup = WhatsappFollowup.new
                whatsapp_followup.broker_contact_id = broker_contact.id
                whatsapp_followup.bot_message = "After Agreement Sign message sent"
                whatsapp_followup.message_id = message_id
                whatsapp_followup.save
            end

            # urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            # result = HTTParty.post(urlstring,
            # :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "broker_lead_intimation","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": "https://www.realtybucket.com/broker_setup/broker_lead_intimation_form?broker_contact_id="+broker_contact.id.to_s} ] } ]}}.to_json,
            # :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
            p result
        end
        flash[:success] = "Link send successfully."
        redirect_to broker_setup_broker_contact_index_url
    end

    def brochure_link_send
        broker_contact = BrokerContact.find(params[:format])
        link_text = ""
        if broker_contact.mobile_one == nil || broker_contact.mobile_one == ""
            if broker_contact.mobile_two == nil || broker_contact.mobile_two == ""
                if broker_contact.email == nil || broker_contact.email == ""
                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s
                else
                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&email="+broker_contact.try(:email).to_s
                end
            else
                if broker_contact.email == nil || broker_contact.email == ""
                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s
                else
                    link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_two).to_s+"&email="+broker_contact.try(:email).to_s
                end
            end
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_two.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        else
            if broker_contact.email == nil || broker_contact.email == ""
                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s
            else
                link_text = "https://dreamgurukul.in/brochure.html?broker_contact_id="+broker_contact.id.to_s+"&mobile="+broker_contact.try(:mobile_one).to_s+"&email="+broker_contact.try(:email).to_s
            end
            urlstring =  "https://graph.facebook.com/v17.0/132619236591729/messages"
            result = HTTParty.post(urlstring,
            :body => {"messaging_product": "whatsapp","receipient_type": "individual", "to": broker_contact.mobile_one.to_s, "type": "template", "template": {"name": "dream_gurukul_brochure","language": {"code": "en"}, "components": [{"type": "body","parameters": [{"type": "text","text": link_text.to_s} ] } ]}}.to_json,
            :headers => {'Content-Type' => 'application/json', 'Authorization' => "Bearer EAAJOtH8G0vsBOZCrzZCBp6unBqSQCGyhPe27IWNGroadoaFpJHwzZBJZBGa1xSEmLrZCSwexBrjyFS7k6oLKdnKH7IwK7m3utAvhFdsEw8ckCtq5d8ZAyp0annlCogVW5We6X8EgJHjzySVxLtXBhCsZAdKiFI6fAPS2oHqi3knfzu3VW2qCSYpU2NigQBp62ZC3"})
        end
        flash[:success] = "Brochure Link send successfully."
        redirect_to broker_setup_broker_index_url
    end

    def broker_contracts_signed
    @brokers_signed=BrokerContact.where(inactive: nil, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id)))
    end

    def broker_dashboard
        @executives = Personnel.where(id: BrokerContact.all.pluck(:personnel_id).uniq).sort_by{|x| x.name}.map{|x| x.name}
        @telecaller_wise_data = []
        broker_allocated_to_tc = {}
        invitation_accepted = {}
        calls_attempted = {}
        calls_connected = {}
        total_sv = {}
        total_sign = {}
        total_inactive = {}
        # head_counts = {}
        # 27visit = {}
        # 28visit = {}
        total_broker_allocated_to_tc = 0
        total_invitation_accepted = 0
        total_calls_attempted = 0
        total_calls_connected = 0
        total_sv_count = 0
        total_sign_count = 0
        total_inactive_count = 0
        # total_head_counts = 0
        # total_27th_visit = 0
        # total_28th_visit = 0
        Personnel.where(id: BrokerContact.all.pluck(:personnel_id).uniq).sort_by{|x| x.name}.each do |personnel|
            if broker_allocated_to_tc["Brokers Allocation"] == nil
                broker_allocated_to_tc["Brokers Allocation"] = [BrokerContact.where(personnel_id: personnel.id).count]
                total_broker_allocated_to_tc = BrokerContact.where(personnel_id: personnel.id).count
            else
                broker_allocated_to_tc["Brokers Allocation"] += [BrokerContact.where(personnel_id: personnel.id).count]
                total_broker_allocated_to_tc += BrokerContact.where(personnel_id: personnel.id).count
            end
            if invitation_accepted["Invitation Accepted"] == nil
                invitation_accepted["Invitation Accepted"] = [BrokerContact.where(personnel_id: personnel.id, accept_invitation: true).count]
                total_invitation_accepted = BrokerContact.where(personnel_id: personnel.id, accept_invitation: true).count
            else
                invitation_accepted["Invitation Accepted"] += [BrokerContact.where(personnel_id: personnel.id, accept_invitation: true).count]
                total_invitation_accepted += BrokerContact.where(personnel_id: personnel.id, accept_invitation: true).count
            end
            # if 27visit["27th Monday"] == nil
            #     27visit["27th Monday"] = [BrokerContact.where(personnel_id: personnel.id, anticipation: true).count]
            #     total_27th_visit = BrokerContact.where(personnel_id: personnel.id, anticipation: true).count
            # else
            #     27visit["27th Monday"] += [BrokerContact.where(personnel_id: personnel.id, anticipation: true).count]
            #     total_27th_visit += BrokerContact.where(personnel_id: personnel.id, anticipation: true).count
            # end
            # if 28visit["28th Tuesday"] == nil
            #     28visit["28th Tuesday"] = [BrokerContact.where(personnel_id: personnel.id, anticipation: false).count]
            #     total_28th_visit = BrokerContact.where(personnel_id: personnel.id, anticipation: false).count
            # else
            #     28visit["28th Tuesday"] += [BrokerContact.where(personnel_id: personnel.id, anticipation: false).count]
            #     total_28th_visit += BrokerContact.where(personnel_id: personnel.id, anticipation: false).count
            # end
            # if head_counts["Head Count"] == nil
            #     head_counts["Head Count"] = [BrokerContact.where(personnel_id: personnel.id).sum(:head_count)]
            #     total_head_counts = BrokerContact.where(personnel_id: personnel.id).sum(:head_count)
            # else
            #     head_counts["Head Count"] += [BrokerContact.where(personnel_id: personnel.id).sum(:head_count)]
            #     total_head_counts += BrokerContact.where(personnel_id: personnel.id).sum(:head_count)
            # end
            if calls_attempted["Calls Attempted"] == nil
                calls_attempted["Calls Attempted"] = [BrokerContact.where(personnel_id: personnel.id).sum(:call_attempted)]
                total_calls_attempted = BrokerContact.where(personnel_id: personnel.id).sum(:call_attempted)
            else
                calls_attempted["Calls Attempted"] += [BrokerContact.where(personnel_id: personnel.id).sum(:call_attempted)]
                total_calls_attempted += BrokerContact.where(personnel_id: personnel.id).sum(:call_attempted)
            end
            if calls_connected["Calls Connected"] == nil
                calls_connected["Calls Connected"] = [BrokerContact.where(personnel_id: personnel.id).sum(:call_connected)]
                total_calls_connected = BrokerContact.where(personnel_id: personnel.id).sum(:call_connected)
            else
                calls_connected["Calls Connected"] += [BrokerContact.where(personnel_id: personnel.id).sum(:call_connected)]
                total_calls_connected += BrokerContact.where(personnel_id: personnel.id).sum(:call_connected)
            end
            if total_sv["Site Visited"] == nil
                total_sv["Site Visited"] = [BrokerContact.where(personnel_id: personnel.id, site_visited: true).count]
                total_sv_count = BrokerContact.where(personnel_id: personnel.id, site_visited: true).count
            else
                total_sv["Site Visited"] += [BrokerContact.where(personnel_id: personnel.id, site_visited: true).count]
                total_sv_count += BrokerContact.where(personnel_id: personnel.id, site_visited: true).count
            end
            if total_sign["Contract Signed"] == nil
                total_sign["Contract Signed"] = [BrokerContact.where(personnel_id: personnel.id, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))).count]
                total_sign_count = BrokerContact.where(personnel_id: personnel.id, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))).count
            else
                total_sign["Contract Signed"] += [BrokerContact.where(personnel_id: personnel.id, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))).count]
                total_sign_count += BrokerContact.where(personnel_id: personnel.id, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))).count
            end
            if total_inactive["Inactive"] == nil
                total_inactive["Inactive"] = [BrokerContact.where(personnel_id: personnel.id, inactive: true).count]
                total_inactive_count = BrokerContact.where(personnel_id: personnel.id, inactive: true).count
            else
                total_inactive["Inactive"] += [BrokerContact.where(personnel_id: personnel.id, inactive: true).count]
                total_inactive_count += BrokerContact.where(personnel_id: personnel.id, inactive: true).count
            end
        end
        broker_allocated_to_tc["Brokers Allocation"] += [total_broker_allocated_to_tc]
        invitation_accepted["Invitation Accepted"] += [total_invitation_accepted]
        calls_attempted["Calls Attempted"] += [total_calls_attempted]
        calls_connected["Calls Connected"] += [total_calls_connected]
        # head_counts["Head Count"] += [total_head_counts]
        # 27visit["27th Monday"] += [total_27th_visit]
        # 28visit["28th Tuesday"] += [total_28th_visit]
        total_sv["Site Visited"] += [total_sv_count]
        total_sign["Contract Signed"] += [total_sign_count]
        total_inactive["Inactive"] += [total_inactive_count]
        # @telecaller_wise_data = [broker_allocated_to_tc, invitation_accepted, calls_attempted, calls_connected, head_counts, 27th_visit, 28th_visit, total_sv, total_sign, total_inactive]
        @telecaller_wise_data = [broker_allocated_to_tc, invitation_accepted, calls_attempted, calls_connected, total_sv, total_sign, total_inactive]        
    end

    def project_details
          @broker_contact = BrokerContact.find(params[:format])
      end

    def site_visited_broker_index
        @site_visited_brokers = BrokerContact.where(site_visited: true, broker_id: (BrokerProjectStatus.where(contract_signed: nil).pluck(:broker_id))).where.not(id: [341,3465,3460,3461,3464,3463,3470,164,3481,3495,3488,3499,3507,790])
        @agreement_signed_brokers = BrokerContact.where(site_visited: true, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id))).where.not(id: [2436,327,2399,1285,2467,3462,3466,509,3467,3468,3469,3471,3472,3473,3474,3433,3421,3428,3435,3423,3414,3475,3419,3432,3418,3476,3477,3478,3483,3487,3479,3490,3494,128,3480,3484,3482,3486,3489,3492,3485,3493,3491,3496,3497,241,3498,3500,3501,3508,3502,3505,3506,405,3503,3504,3509,3510,501,3511,3512,3513,3514,3515,708,839,1598,1693])        
    end

    def site_visited_brokers_all
        @site_visited_brokers = BrokerContact.where(site_visited: true, broker_id: (BrokerProjectStatus.where(contract_signed: nil).pluck(:broker_id)))
        @agreement_signed_brokers = BrokerContact.where(site_visited: true, broker_id: (BrokerProjectStatus.where(contract_signed: true).pluck(:broker_id)))        
    end

    def indipendent_agreement_index
        if params[:broker_name] == "" || params[:broker_name] == nil
        else
            broker = Broker.new
            broker.name = params[:broker_name]
            broker.contract_signature = params[:signature_data]
            broker.save

            broker_project_status = BrokerProjectStatus.new
            broker_project_status.broker_id = broker.id
            broker_project_status.business_unit_id = 70
            broker_project_status.contract_signed = true
            broker_project_status.save

            broker_contact = BrokerContact.new
            broker_contact.broker_id = broker.id
            broker_contact.name = params[:name]
            broker_contact.email = params[:email]
            broker_contact.mobile_one = params[:mobile_one]
            broker_contact.mobile_two = params[:mobile_two]
            broker_contact.personnel_id = 294
            broker_contact.save

            @contract_pdf = render_to_string(:partial => "broker_agreement_contract", :layout => false, :locals => {:@my_variable => broker})
            @contract_pdf = '<html><body>'+@contract_pdf+'</body></html>'
            @pdf = WickedPdf.new.pdf_from_string(@contract_pdf)
            broker.broker_contacts.each do |broker_contact|
                if broker_contact.email == nil || broker_contact.email == ""
                else
                    UserMailer.broker_agreement_mail([broker, @pdf, broker_contact]).deliver
                    UserMailer.signed_broker_data_mail([broker_contact]).deliver
                end
            end

            flash[:success] = 'Registration Successful.'
            redirect_to broker_setup_thank_you_url
        end
    end

    def broker_names
      @broker_names = Broker.where("name LIKE ?", "%#{params[:term]}%").pluck(:name)
      render json: @broker_names
    end
end

#event whether to be created for floor plan

#name rectifications

#visited but not signed to be called

#inactive to be audited

#lead protection form through whatsapp form
