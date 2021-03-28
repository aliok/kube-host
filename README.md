# Kubernetes host on Lenovo

Available at https://github.com/aliok/kube-host

To be used in conjunction with https://github.com/aliok/kube-guest

To be placed at `~/host`.

## kind

Start in guest:

```
start-kind.sh
```

Dashboard doesn't work. See https://stackoverflow.com/questions/53957413/how-to-access-kubernetes-dashboard-from-outside-network


## crc

The official guide [here](https://code-ready.github.io/crc/#setting-up-remote-server_gsg) shows how to setup crc on the host and how to connect 
to it from a Fedora guest. However, in my case, my guest is a Mac. There is [another](https://www.opensourcerers.org/2021/03/22/accessing-a-remote-codeready-containers-installation-with-macos/) guide for that.

What I did:
- Do the things in the official guide(skipped the firewall shit, only did the HA proxy part) (I actaually disabled firewall entirely)
- Do the things in the 2nd article - optimized setup: install dnsmasq on host, configure /etc/resolver on Mac to point to host. UPDATE: this didn't work. There is another dnsmasq instance on Linux host which binds to port 53 and I can't change its config. I tried starting a 2nd instance of dnsmasq at a custom port, but Mac can't connect to dns server with custom port. In the end, I just did't do the optimized setup. I installed dnsmasq on my Mac and pointed at that in Mac's dns settings. It resolves to this machine.

Start in guest:
```
start-crc.sh
```
