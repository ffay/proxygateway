function api_invoke(uri, params, callback) {
    $.ajax({
        url: uri,
        data: params,
        type: 'POST',
        cache: false,
        dataType: 'json',
        success: function (data) {
            if (40100 == data.errno) {
                location.href = "/login.html";
                return;
            }
            callback(data);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            if ("undefined" == typeof(XMLHttpRequest.responseJSON)) {
                alert("System error, please try again later.");
                return;
            }
            alert(XMLHttpRequest.responseJSON.msg);
        }
    });
}

function load_page(pageUrl) {
    $(".content-wrapper").load(pageUrl);
}

function get_query_string(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
    var r = window.location.search.substr(1).match(reg);
    if (r != null)return unescape(r[2]);
    return null;
}

function is_ip(ip) {
    var re = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
    return re.test(ip);
}

function check_port(port) {
    if (port > 65535) {
        return false;
    }
    var re = /^[1-9]+[0-9]*]*$/
    return re.test(port);
}

function check_weight(weight) {
    var re = /^[1-9]+[0-9]*]*$/
    return re.test(weight);
}

