# Home Tailscale Topology

Date: 2026-03-25

## Goal

Keep remote access to the home LAN stable without creating route loops inside the same `192.168.178.0/24` network.

## Final Roles

- `glkvm` (`192.168.178.60`): primary home subnet router for `192.168.178.0/24`
- `glkvm`: only home exit node
- `nuc` (`192.168.178.141`): regular Tailscale host for services, no imported subnet routes
- `archlinux` laptop: roaming client, keeps `accept-routes=true`
- `OTX-709KJX3` Windows laptop: regular client, no advertised routes

## Why The Old Setup Broke

The failure mode was:

- `nuc` had `accept-routes=true`
- another peer advertised `192.168.178.0/24`
- `nuc` accepted that route into Tailscale policy routing table `52`
- replies to local LAN clients went out via `tailscale0` instead of `eno1`

Symptoms:

- DNS on `192.168.178.141` timed out from LAN clients
- `ssh nuc` timed out from the local network
- services were listening locally, but unreachable from the LAN

## Best-Practice Rules For This Home Network

- Only one device should advertise the home subnet `192.168.178.0/24`
- Only one device should advertise `0.0.0.0/0` and `::/0` unless there is a real reason to keep multiple exit nodes
- Stable infrastructure devices can be subnet routers or exit nodes
- Mobile laptops should stay normal clients unless they are intentionally acting as routers
- Servers like `nuc` should usually keep `accept-routes=false`
- Roaming client laptops can keep `accept-routes=true` if they need access to home-LAN addresses while away

## Current Intended Commands

`glkvm`:

```bash
tailscale set --advertise-routes=192.168.178.0/24,0.0.0.0/0,::/0
```

`nuc`:

```bash
sudo tailscale set --accept-routes=false
sudo tailscale set --advertise-exit-node=false --advertise-routes=''
```

## Quick Verification

From any Tailscale client:

```bash
tailscale status --json | jq -r '.Peer | to_entries[] | select((.value.AllowedIPs // []) | any(. == "192.168.178.0/24" or . == "0.0.0.0/0" or . == "::/0")) | [.value.HostName, (.value.PrimaryRoutes // [] | join(",")), (.value.AllowedIPs | join(","))] | @tsv'
```

Expected outcome:

- `glkvm` shows `192.168.178.0/24`
- `glkvm` is the only intended home exit node
- `nuc` does not advertise the home subnet or exit-node routes
