xml.instruct!
xml.xml do
  @leads_captured.each do |lead_captured|
    xml.QryResp do
      xml.QryId lead_captured
      xml.status 'Y'
    end
  end  
end