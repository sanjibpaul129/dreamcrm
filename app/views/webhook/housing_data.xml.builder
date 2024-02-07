xml.instruct!
xml.xml do
  @data.each do |data|
    xml.QryResp do
      # xml.tag!("query yo='done'")
      xml.QryId 'mmm_response-1611359'
      xml.status 'Y'
      # xml.LEDGERENTRIES {
      # xml.LEDGERNAME data
      # }
    end
  end  
end