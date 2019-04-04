// ==UserScript==
// @name           instatweets
// @namespace      http://babyl.ca/instatweets
// @include        http://search.cpan.org/*
// @require        http://localhost:3000/javascripts/jquery.js
// @require        http://localhost:3000/javascripts/autoresize.jquery.min.js
// ==/UserScript==

gm_xhr_bridge();

var insta_root = 'http://localhost:3000';

function submitTweet () {
    $("#sending_tweet").show();
    $.post(
        insta_root + '/tweet', 
        {
            'update': $('#twitter_status').get(0).value,
        },
        function ( data, textStatus ) {
            $("#sending_tweet").hide(); 
            $("#twitter_status").get(0).value = "";
            update_counter();
            $('#twitter_term').slideToggle();
        }
    );
};

function update_counter () {
    var l = $('#twitter_status').get(0).value.length;
    $('#twitter_counter')
        .html(l)
        .css('color', l > 140 ? 'red' : 'black' );
}

$(function(){
    $("<div id='twit' />" )
        .css({
            position:   "absolute",
            top:        "0px",
            right:      "5px"
        })
        .appendTo('body');

    $( '<img id="twitter_logo" src="' + insta_root + '/twitter_logo.png" />' )
        .appendTo( '#twit' )
        .click( function(){
                $('#twitter_term').slideToggle();
            });

$('body').append( '<div id="twitter_term" style="padding: 5px; z-index: 20000; display: none; background-color: lightgrey; position: absolute; top: 0px; right: 120px;";>'
+ '<form method="POST" id="tweet_form">'
+ '    <textarea id="twitter_status" name="status" style="width: 50em"></textarea>'
+ '    <input id="submit_tweet" type="button" value="tweet" />'
+ '</form>'
+ '<p>characters: <span id="twitter_counter"></span></p>'
+ '<div id="sending_tweet" style="display: none">sending...</div>'
+ ''
+ '<div id="twitter_warnings">'
+ '</div>'
+ ''
+ '<p align="right"><a href="#hide" onclick="$(\'#twitter_term\').slideToggle();return false;">hide</a></p>'
+ '</div>');

    $('#twitter_status').autoResize();

    $('<span/>').attr('class','not_auth').html( 
        "you must <a href='" + insta_root + "/authenticate?origin=" + document.location +"'>"
        + "authenticate</a> yourself " + "on Twitter before you can tweet" 
    ).prependTo('#twitter_warnings');

    $.get( insta_root + '/authenticated', 
        function(data) { $('.not_auth').hide(); } );

    $('#submit_tweet').click(submitTweet);

    $('#twitter_status').keyup(update_counter);
    update_counter();

});
