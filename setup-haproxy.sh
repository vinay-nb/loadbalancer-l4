#!/bin/bash

set -e

echo "📁 Creating demo HTTP servers with unique responses..."

mkdir -p /tmp/server1 /tmp/server2
echo "Hello from Server 1" > /tmp/server1/index.html
echo "Hello from Server 2" > /tmp/server2/index.html

echo "🚀 Starting Python servers on ports 9001 and 9002..."

cd /tmp/server1 && python3 -m http.server 9001 > /dev/null 2>&1 &
PID1=$!
cd /tmp/server2 && python3 -m http.server 9002 > /dev/null 2>&1 &
PID2=$!

sleep 1

echo "📝 Writing HAProxy config with TCP health checks..."

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg > /dev/null
global
    daemon
    maxconn 256
    log /dev/log local0

defaults
    mode tcp
    timeout connect 5s
    timeout client 50s
    timeout server 50s

frontend http_l4_frontend
    bind *:8080
    default_backend http_l4_backends

backend http_l4_backends
    balance roundrobin
    option tcp-check
    server s1 127.0.0.1:9001 check inter 3s fall 2 rise 3
    server s2 127.0.0.1:9002 check inter 3s fall 2 rise 3

listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /
    stats refresh 10s
    stats show-node
    stats auth admin:admin
EOF

echo "🔍 Verifying HAProxy config..."
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

echo "🔁 Restarting HAProxy service..."
sudo systemctl restart haproxy

echo ""
echo "✅ HAProxy is now load balancing HTTP servers via L4 (TCP mode)"
echo "   - Try: curl http://localhost:8080 → round-robin output"
echo "   - Stats page: http://localhost:8404 (user: admin, pass: admin)"
echo ""
echo "💣 To simulate failure:"
echo "   kill $PID2     # Simulates server 2 going down"
echo "♻️  To restore:"
echo "   cd /tmp/server2 && python3 -m http.server 9002 &"
echo ""
echo "🛑 To stop everything:"
echo "   sudo systemctl stop haproxy && kill $PID1 $PID2"
