#!/bin/bash -xe

# Ensure system is up to date
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx

NGINX_PATH="/var/www/html"

# Write the landing page
cat <<'HTML' > "$NGINX_PATH/index.html"
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Welcome to AlbertDevOps</title>
<style>
body{margin:0;display:grid;place-items:center;height:100vh;
background:linear-gradient(135deg,#071026,#00121a);
font-family:Inter,system-ui,Arial;color:#fff}
h1{font-size:42px;margin:0}
p{opacity:0.85}
</style>
</head>
<body>
<main>
<h1>Welcome to "AlbertDevOps"</h1>
<p>Autoscaling-ready landing page served by nginx.</p>
</main>
</body>
</html>
HTML

chmod 644 "$NGINX_PATH/index.html"

# Start nginx
systemctl enable nginx
systemctl restart nginx
