console.log("inserting into the js file");
$("<%= '#interest_type' %>").empty()
$("<%= '#interest_type' %>").append('<%= j render("interest_type") %>')