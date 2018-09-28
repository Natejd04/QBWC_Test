// This is shorthand for $( document ).ready(function() { })
$(function(){
  $('.qb-alert').hide();
  $(".checkbox-qbwc").click(function(event){
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
      url: "/qbwc_enabled/",
      data: {qbwc_enabled: checked, id: id},
      success: function(data){
        $('.qb-alert').show().delay(3000).fadeOut();
      	if (data.qbwc_enabled == true) {
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

//This is for the initial loader
$(".checkbox-qb-initial").click(function(event){
    event.preventDefault();
    var start_time =     $('#qb_helper_start_1i').val() + "-" + $('#qb_helper_start_2i').val() + "-" + $('#qb_helper_start_3i').val();
    var end_time = $('#qb_helper_end_1i').val() + "-" + $('#qb_helper_end_2i').val() + "-" + $('#qb_helper_end_3i').val();
    var checked;
    if ($('#qb_helper_initial_load').is(':checked')) {
      checked = true;
  } else {
    checked = false;
  }
    
    $.ajax({
      method: "put",
      url: "/qb_helper/",
      data: {start: start_time, end: end_time, initial_load: checked},
      success: function(data){
          $('.qb-alert').show().delay(3000).fadeOut();
              },
      error: function(data){
        console.log('there seems to be an error.')
        },
      dataType: 'JSON'
    });
  });
});