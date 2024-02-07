$("<%= '#second_applicant_signature' %>").empty()
$("<%= '#second_applicant_signature' %>").append('<%= j render("second_applicant_signature") %>')

$(document).ready(function() {
  var canvas2 = document.getElementById("signature_2");
  var signaturePad2 = new SignaturePad(canvas2);
  
  $('#clear-signature_2').on('click', function(){
      signaturePad2.clear();
  });
});
