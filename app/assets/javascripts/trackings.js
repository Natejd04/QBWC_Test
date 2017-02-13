// This is shorthand for $( document ).ready(function() { })
$(function(){
  $(".checkbox-event").click(function(event){
    event.preventDefault();

    var id = $(this).attr('id');
    var checked;
    if ($(this).is(':checked')) {
    	checked = true;
	} else {
		checked = false;
	}

    $.ajax({
      method: "put",
      url: "/trackings/" + id,
      data: {emailed: checked},
      success: function(data){
      	if (data.emailed == true) {
      		console.log("Checkbox is marked as true");
      		$('#' + data.id).prop('checked', true); }
      	else {
      		console.log("Checkbox is marked as false");
      		$('#' + data.id).prop('checked', false);
      		}
      },
      error: function(data){
      	console.log('there seems to be an error.')
      	},
      dataType: 'JSON'
    });
  });
  $(".button-me").click(function(event){
    $('#loader').show();
    $(".button-me").hide();
  });
});