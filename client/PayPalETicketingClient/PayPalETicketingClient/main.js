var eticketing = function() {
  var server = 'http://localhost:8088/api',
    db,
    attendees = [];

  function set_status(msg) {
    $('#status').html(msg);
  }

  function load_response(data) {
    if ( data['status'] == 'ok' ) {
      db = data['result'];
      set_status( db.length + ' ticket(s) downloaded' );
    }
    else {
      set_status( 'An error occurred: ' + data['status'] );
    }
  }

  function load_error( xhr, stat, text ) {
    set_status( 'Error: ' + stat + ' Detail: ' + text );
  }

  function load() {
    var title = $('#title').val();
    set_status( 'Contacting server for "' + title + '"...' );
    $.ajax({
      type: 'POST',
      url: server,
      data: 'json=' + JSON.stringify( { 'command': 'load', 'title': title } ),
      success: load_response,
      error: load_error,
      dataType: 'json'
    });
  }

  function validate() {
    var candidate = $('#code').val();
    set_status( "hi: " + db );
    for ( attendee in db ) {
      set_status( "testing: " + attendee );
      if ( db[attendee].code == candidate ) {
        if ( db[attendee].attending == 'yes' ) {
          set_status( "This attendee has already been validated." );
          return;
        }
        else {
          set_status( "Code successfully validated." );
          db[attendee].attending = 'yes';
          attendees.append( candidate );
          return;
        }
      }
    }
    set_status( "Code '" + candidate + "' not found." );
  }

  return {
    init: function() {
      $('#download').on('click', load);
      $('#validate').on('click', validate);
      set_status( 'Enter a title to download ticket details' );
    },

    set_code: function(code) {
      $('#code').val( code );
    }
  }
}();
