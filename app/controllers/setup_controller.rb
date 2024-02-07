class SetupController < ApplicationController
  def stream
    loop do
      streaming_service = IncomingCall.new
      loop_status = streaming_service.start_streaming
      if loop_status == 1
        loop_status = 0 
        next    
      end
      current_time = Time.now
      break if current_time.hour >= 20
    end
  end

  def incoming_testing
    require 'faraday'
    connection = Faraday.new do |conn|
      conn.request :url_encoded
      conn.response :logger
      conn.adapter Faraday.default_adapter
    end
    connection.get do |req|
      req.url('https://konnectprodstream4.knowlarity.com:8200/update-stream/dff4b494-13d3-4c18-b907-9a830de783ef/konnect?source=router')
      req.options.on_data = Proc.new { |chunk_size, chunk|
        puts chunk
        p "========================"
      }
    end
  end

  def index
  end

  def escalation_duration
  end

  def update_escalation_duration
  end
	
  def area_index
  	@areas = Area.where(organisation_id: current_personnel.organisation_id)
  end

  def area_new
  end

  def area_create
  	area = Area.new
  	area.name = params[:name]
  	area.organisation_id = current_personnel.organisation_id
  	area.save

  	flash[:success]='Area Generated successfully.'
  	redirect_to setup_area_index_url
  end

  def area_edit
  	@area = Area.find(params[:format])
  end

  def area_update
  	area = Area.find(params[:area_id].to_i)
  	area.update(name: params[:name])

  	flash[:success]='Area Updated successfully.'
  	redirect_to setup_area_index_url
  end

  def area_destroy
  	area = Area.find(params[:format])
  	area.destroy

  	flash[:success]='Area Deleted successfully.'
  	redirect_to setup_area_index_url
  end

  def city_index
  	@cities = City.all
  end

  def city_new
  end

  def city_create
  	city = City.new
  	city.name = params[:name]
  	city.save

  	flash[:success]='City Generated successfully.'
  	redirect_to setup_city_index_url
  end

  def city_edit
  	@city = City.find(params[:format])
  end

  def city_update
  	city = City.find(params[:city_id].to_i)
  	city.update(name: params[:name])

  	flash[:success]='City Updated successfully.'
  	redirect_to setup_city_index_url
  end

  def city_destroy
  	city = City.find(params[:format])
  	city.destroy

  	flash[:success]='City Deleted successfully.'
  	redirect_to setup_city_index_url
  end

  def project_rate_index
    @project_rates = ProjectRate.includes(:business_unit).where(:business_units => {organisation_id: current_personnel.organisation_id})
  end

  def project_rate_new
    @business_units = selections(BusinessUnit, :name)
  end

  def project_rate_create
    project_rate = ProjectRate.new
    project_rate.business_unit_id = params[:business_unit_id]
    project_rate.date = params[:date]
    project_rate.base_rate = params[:base_rate]
    project_rate.save

    flash[:success]='Project Rate Generated successfully.'
    redirect_to setup_project_rate_index_url
  end

  def project_rate_edit
    @project_rate = ProjectRate.find(params[:format])
    @business_units = selections(BusinessUnit, :name)
  end

  def project_rate_update
    project_rate = ProjectRate.find(params[:project_rate_id].to_i)
    project_rate.update(date: params[:date], business_unit_id: params[:business_unit_id], base_rate: params[:base_rate])

    flash[:success]='Project Rate updated successfully.'
    redirect_to setup_project_rate_index_url
  end

  def project_rate_destroy
    @project_rate = ProjectRate.find(params[:format])
    @project_rate.destroy

    flash[:success]='Project Rate deleted successfully.'
    redirect_to setup_project_rate_index_url
  end

    def whatsapp_qr_code
        urlstring =  "https://api.maytapi.com/api/3e633113-75cd-4bc6-9e5e-be24fcdd003e/20283/qrCode"
       
        @result = HTTParty.post(urlstring, :headers => {'Content-Type' => 'application/json', 'x-maytapi-key'=>'e4845729-81e0-46cc-a393-a41d7ebbe172' } )

       p @result

        response.headers['Cache-Control'] = "public"                                                    
        response.headers['Content-Type'] = "image/png"                                 
        response.headers['Content-Disposition'] = "inline"                                              
        render :body => @result     
    end


end
