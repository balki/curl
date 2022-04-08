#!/usr/bin/bash

state_dir=/tmp/socksdtest
rm -rf $state_dir
mkdir -p $state_dir/{dirlist,log}
touch $state_dir/dirlist/{foo,bar}

socksd=/home/balki/projects/curl/tests/server/socksd
curlbin=/home/balki/projects/curl/w.tmp/root/bin/curl

cd $state_dir/dirlist
python3 -m http.server 8088 &> ../py.log &
sleep 2

cd $state_dir
# $socksd --portfile socksdport &

$socksd --unix-socket socksd.sock &

runcurl() {
  # $curlbin -s -x "socks5h://127.0.0.1:$(cat socksdport)" "http://127.0.0.1:8088"
  $curlbin -s -x "socks5h://unix$state_dir/socksd.sock" "http://127.0.0.1:8088"
}

diff <(runcurl) - << EOR && echo "test passed"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bar">bar</a></li>
<li><a href="foo">foo</a></li>
</ul>
<hr>
</body>
</html>
EOR

pkill -P $$
