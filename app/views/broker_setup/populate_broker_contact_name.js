$("<%= '#populate_broker_contact_'+@broker_contact_id.to_s %>").empty()
$("<%= '#populate_broker_contact_'+@broker_contact_id.to_s %>").append('<%= j render("populate_broker_contact") %>')