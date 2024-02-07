$("<%= '#populate_broker_'+@broker_contact_id.to_s %>").empty()
$("<%= '#populate_broker_'+@broker_contact_id.to_s %>").append('<%= j render("broker_update") %>')