#!/usr/bin/bash

state_dir=/tmp/socksdtest
rm -rf $state_dir
mkdir -p $state_dir/{dirlist,log}
touch $state_dir/dirlist/{foo,bar}

socksd=/home/balki/projects/curl/tests/server/socksd

cd $state_dir/dirlist
python3 -m http.server 8088 &> ../py.log &
sleep 2

cd $state_dir
$socksd --portfile socksdport &

runcurl() {
  curl -s -x "socks5h://127.0.0.1:$(cat socksdport)" "http://127.0.0.1:8088"
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
