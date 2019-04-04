$ http post :5000/player name=yenzie alliance="Nefarious Coallition of Space Monkeys"
HTTP/1.0 200 OK
Content-Length: 110
Content-Type: application/json
Date: Sun, 16 Apr 2017 20:06:45 GMT
Server: HTTP::Server::PSGI
Server: Perl Dancer2 0.204004

{
    "__CLASS__": "Proto::Store::Model::Player",
    "alliance": "Nefarious Coallition of Space Monkeys",
    "name": "yenzie"
}
