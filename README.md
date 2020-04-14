# Bring up K8S master node based on Vagrantfile

```bash
vagrant up
vagrant ssh
```

If you bring up a box based on this Vagrantfile, you should have a node with Kubernetes up and running!
But there are a couple of final steps required before your Kubernetes node will be ready to run demo.

# Provisioning the rest

```bash
vagrant@vagrant:~$ /vagrant/provisioning.sh
```

## Access to both prometheus-node-exporter and kube-state-metrics

```bash
vagrant@vagrant:~$ curl 127.0.0.1:30091
vagrant@vagrant:~$ curl 127.0.0.1:30080
```

The output looks below

```bash
<html>
<head><title>Node Exporter</title></head>
<body>
<h1>Node Exporter</h1>
<p><a href="/metrics">Metrics</a></p>
</body>
</html>
```

# Setup PushProx

Revise `--proxy-url=http://192.168.1.109/` to pushprox-proxy IP

```bash
vagrant@vagrant:~$ cd /vagrant/pushprox-client
vagrant@vagrant:~$ nano deployment.yaml
vagrant@vagrant:~$ kubectl apply -f deployment.yaml
vagrant@vagrant:~$ exit
```

# Setup Prometheus

```bash
cd prometheus
docker-compose up
```

Open browser to visit http://127.0.0.1:9090

# Workaround to fix K8S stop running after restarting Vagrant

```bash
vagrant@vagrant:~$ sudo -i
vagrant@vagrant:~$ swapoff -a
vagrant@vagrant:~$ exit
vagrant@vagrant:~$ strace -eopenat kubectl version
```