var app = window.app = {};

app.Search = function() {
  this._input = $('#search-txt');
  this._initAutocomplete();
};

app.Search.prototype = {

	_initAutocomplete: function() {
  this._input
    .autocomplete({
      max:20,
      minLength:3,
      delay: 300,
      source: '/dashboard',
      appendTo: '#search-results',
      select: $.proxy(this._select, this)
    })
    .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

	_select: function(e, ui) {
  this._input.val(ui.item.name + ' - ' + ui.item.city);
  return false;
},

_render: function(ul, item) {
  var markup = [
    // '<span class="img">',
    //   '<img src="' + item.image_url + '" />',
    // '</span>',
    '<span class="name">' + item.name + ':</span>',
    '<span class="city">' + item.city + ',</span>',
    '<span class="state">' + item.state + '</span>'
  ];
  return $('<li>')
    .append(markup.join(''))
    .appendTo(ul);
}
};