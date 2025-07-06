# 🚀 L4 Load Balancer Prototype using HAProxy

This project sets up a simple **Layer 4 (TCP) load balancer** using **HAProxy**, balancing traffic between two local **Python HTTP servers** with **active health checks**.

Useful for:
- Prototyping load balancers
- Understanding L4 vs L7 routing
- Observing HAProxy health checks in action

---

## 📦 Features

- HAProxy in **TCP mode** (Layer 4)
- Load balances between two backend servers on ports `9001` and `9002`
- Uses `roundrobin` load balancing
- TCP-level **health checks**:
  - `fall 2`: Mark backend as DOWN after 2 failed checks
  - `rise 3`: Mark backend as UP after 3 successful checks
- Stats dashboard on `localhost:8404`

---

## 🛠️ How to Use

### 1. Clone the Repository
git clone https://github.com/your-username/l4-haproxy-prototype.git
cd l4-haproxy-prototype


## Run the Setup Script
`chmod +x setup-haproxy.sh`

## This will:
- Start two Python HTTP servers on ports 9001 and 9002
- Create an HAProxy config with health checks
- Start HAProxy on port 8080
- Enable HAProxy stats dashboard on port 8404

## Testing the Load Balancer
`curl http://localhost:8080`

Each request will round-robin between:
- Hello from Server 1
- Hello from Server 2

## View the Stats Dashboard
`http://localhost:8404`

## Simulating Server Failure
`kill $(lsof -t -i:9002)`
- Watch it go DOWN on the stats page
- To bring it back:
`cd /tmp/server2 && python3 -m http.server 9002`
- After 3 successful TCP checks, HAProxy will mark it UP again.

## Stopping Everything
`sudo systemctl stop haproxy`
`kill $(lsof -t -i:9001)`
`kill $(lsof -t -i:9002)`
