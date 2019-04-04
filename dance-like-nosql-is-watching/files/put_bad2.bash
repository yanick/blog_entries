$ http put :5000/player/yenzie power=maximal
HTTP/1.0 500 Internal Server Error
Content-Length: 289
Content-Type: application/json
Date: Sun, 16 Apr 2017 20:13:36 GMT
Server: HTTP::Server::PSGI
Server: Perl Dancer2 0.204004

{
    "exception": "Can't locate object method \"power\" via package \"Proto::Store::Model::Player\" at /home/yanick/work/perl-modules/Dancer2-Plugin-StoreManager/proto/bin/../lib/Dancer2/Plugin/StoreManager.pm line 71.\n",
    "message": "",
    "status": "500",
    "title": "Error 500 - Internal Server Error"
}

