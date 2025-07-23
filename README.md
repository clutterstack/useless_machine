# UselessMachine

Pairs with https://github.com/clutterstack/where_machines.

The Useless Machine portion of https://where.fly.dev, a toy web application that exercises some standout features of the Fly.io platform: the Machines API for on-demand VMs, private networking, Anycast routing, and quasi-programmable request routing with fly-proxy and the `fly-replay` header.

A visitor to https://where.fly.dev pushes a button, which spawns a Fly Machine VM running this little Phoenix/LiveView server, which plays a short animation before shutting itself down. The Machine is configured such that the platform destroys it on shutdown.

![Screenshot: Title "You started a Useless Machine", message "This is Fly Machine 7811eedf292108 in Toronto", then a text-based image of a hand emerging from a trap door, about to push a button](./doc/images/almost.png)

I wrote about how this app uses `fly-replay` to enforce the one-to-one mapping between visitors and their very own ephemeral VMs: [Machine Affinity with LiveView and fly-replay](https://clutterstack.com/posts/2025-06-01-liveview-machine-affinity).

## Junk drawer

(More in the README for https://github.com/clutterstack/where_machines)

* sticky sessions (distinct from auth, because it's not a matter of providing the info appropriate to a user who has a particular cookie, but of potentially redirecting every connection)
* animation is a bunch of text files that originated as hand-drawn art, just because
* local health check endpoint and API client to tell `where_machines` that the Machine is ready to serve requests
* disconnects WebSocket and heads to a regular Phoenix view before shutting down, so local LiveView JS doesn't keep trying to reconnect