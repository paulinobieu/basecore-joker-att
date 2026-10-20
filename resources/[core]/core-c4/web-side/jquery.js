$(document).ready(function () {
    var interval;
    window.addEventListener("message", function (event) {
        var time = event.data.time;
        if (time && time > 0) {
            $("#displayC4").fadeIn();
            var el = $("#c4Text");
            $(el).html(time);
            interval = setInterval(function () {
                if (time > 0) {
                    time--;
                    if (time < 10) {
                        $(el).html("0" + time.toString());
                    } else {
                        $(el).html(time);
                    }
                } else {
                    $("#displayC4").fadeOut();
                    clearInterval(interval);
                    interval = null;
                }
            }, 1000);
        } else {
            $("#displayC4").fadeOut();
            if (interval) {
                clearInterval(interval);
                interval = null;
            }
        }
    });
});