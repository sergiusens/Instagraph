function color_from_qml(qml_color)
{
    var color = {
        "r": Math.round(qml_color.r * 100),
        "g": Math.round(qml_color.g * 100),
        "b": Math.round(qml_color.b * 100),
    };
    return color;
}

function formatString(string, qml_color)
{
    //var user_reg = "/@(\w*)/g";
    var user_reg = "/@([a-zA-Z0-9._]*)/g"
    var tag_reg = "/#(\S*)/g"
    var color = color_from_qml(qml_color);

    string = string.replace(/@([a-zA-Z0-9._]*)/g,'<a href="user://$1" style="text-decoration:none;color:rgb('+color.r+','+color.g+','+color.b+');">@$1</a>');
    string = string.replace(/#(\S*)/g,'<a href="tag://$1" style="text-decoration:none;color:rgb('+color.r+','+color.g+','+color.b+');">#$1</a>');

    return string;
}

function formatUser(string, qml_color)
{
    var color = color_from_qml(qml_color);
    return '<a href="user://'+string+'" style="text-decoration:none;font-weight:500;color:rgb('+color.r+','+color.g+','+color.b+');">'+string+'</a>';
}

function makeLink(string, qml_color)
{
    var color = color_from_qml(qml_color);
    return '<a href="'+string+'" style="text-decoration:none;font-weight:500;color:rgb('+color.r+','+color.g+','+color.b+');">'+string+'</a>';
}

function getBestImage(imageObject, width) {
    var closest = typeof imageObject[0] != 'undefined' ? imageObject[0] : {"width":0, "height":0, "url":""};

    for(var i = 0; i < imageObject.length; i++){
        if(imageObject[i].width >= width && imageObject[i].width < closest.width) closest = imageObject[i];
    }

    return closest;
}

function milisecondsToString(miliseconds, short, timestamp) {
    if (timestamp) {
        miliseconds = miliseconds/1000000;
    }

    try {
        //get different date time initials.
        var myDate = new Date();
        var difference_ms = myDate.getTime() - miliseconds * 1000;
        //take out milliseconds
        difference_ms = difference_ms / 1000;
        var seconds = Math.floor(difference_ms % 60);
        difference_ms = difference_ms / 60;
        var minutes = Math.floor(difference_ms % 60);
        difference_ms = difference_ms / 60;
        var hours = Math.floor(difference_ms % 24);
        difference_ms = difference_ms / 24;
        var days = Math.floor(difference_ms % 7);
        difference_ms = difference_ms / 7;
        var weeks = Math.floor(difference_ms);

        //remove weeks if it exceeds the month limit ie. 4weeks+2days.
        var months = 0;
        if ((weeks == 4 && days >= 2) || (weeks > 4)) {
            difference_ms = difference_ms * 7;
            days = Math.floor(difference_ms % 30);
            difference_ms = difference_ms / 30;
            months = Math.floor(difference_ms);
            weeks = 0;
        }
        //check and return the largest value of date time initialized.
        if (months > 0) {
            return short ? i18n.tr("%1M").arg(months) : i18n.tr("%1 MONTH AGO", "%1 MONTHS AGO", months).arg(months);
        } else if (weeks != 0) {
            return short ? i18n.tr("%1w").arg(weeks) : i18n.tr("%1 WEEK AGO", "%1 WEEKS AGO", weeks).arg(weeks);
        } else if (days != 0) {
            return short ? i18n.tr("%1d").arg(days) : i18n.tr("%1 DAY AGO", "%1 DAYS AGO", days).arg(days);
        } else if (hours != 0) {
            return short ? i18n.tr("%1h").arg(hours) : i18n.tr("%1 HOUR AGO", "%1 HOURS AGO", hours).arg(hours);
        } else if (minutes != 0) {
            return short ? i18n.tr("%1m").arg(minutes) : i18n.tr("%1 MINUTE AGO", "%1 MINUTES AGO", minutes).arg(minutes);
        } else if (seconds != 0) {
            return short ? i18n.tr("%1s").arg(seconds) : i18n.tr("%1 SECOND AGO", "%1 SECONDS AGO", seconds).arg(seconds);
        }
    } catch (e) {
        console.log(e);
    }
}

function toObject(arr) {
    var rv = {};
    for (var i = 0; i < arr.length; ++i)
        if (arr[i] !== undefined) rv[i] = arr[i];
    return rv;
}

function objectLength(obj) {
  var result = 0;
  for(var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
      result++;
    }
  }
  return result;
}
