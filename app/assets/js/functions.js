jQuery( function () {

    $( '.action-log' ).on( 'click', function () {

        document.location.href = $( this ).attr( 'href' ) + '&log-length=' + window.parseInt( $( '#log-length' ).val() );
        return false;

    });


});