function changeTimes() {
    var new_tz = $('select#timezone').val();

    $('.datetime').each(function(){
        var t = $(this);
        var tz = t.attr('timezone') || 'Etc/UTC';
        var dt = new timezoneJS.Date(t.text(), tz);
        dt.setTimezone(new_tz);
        t.attr('timezone',new_tz);
        t.text(dt.toString());
    });
}

 $(function(){
    timezoneJS.timezone.zoneFileBasePath = '/static/tz';
    timezoneJS.timezone.init();

    $('select#timezone').val(jstz.determine().name()).change( changeTimes );

    changeTimes();
});
