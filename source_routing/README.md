# Implementing Source Routing

The objective of this exercise is to implement source routing.  With
source routing, the source host guides each switch in the network to
send the packet to a specific port. The host puts a stack of output
ports in the packet. In this example, we just put the stack after
Ethernet header and select a special etherType to indicate that.  Each
switch pops an item from the stack and forwards the packet according
to the specified port number.

Your switch must parse the source routing stack. Each item has a bos
(bottom of stack) bit and a port number. The bos bit is 1 only for the
last entry of stack.  Then at ingress, it should pop an entry from the
stack and set the egress port accordingly. The last hop may also
revert back the etherType to `TYPE_IPV4`.


## Implement source routing

1. Header type definitions for Ethernet (`ethernet_t`) and IPv4
   (`ipv4_t`) and Source Route (`srcRoute_t`).
2. Parsers for Ethernet and Source Route that populate
   `ethernet` and `srcRoutes` fields.
3. An action to drop a packet, using `mark_to_drop()`.
4. An action (called `srcRoute_nhop`), which will:
	1. Set the egress port for the next hop. 
	2. remove the first entry of srcRoutes
5. A control with an `apply` block that:
    1. checks the existence of source routes.
    2. if statement to change etherent.etherType if it is the last hop
    3. call srcRoute_nhop action
6. A deparser that selects the order in which fields inserted into the outgoing
   packet.
7. A `package` instantiation supplied with the parser, control, and deparser.
    > In general, a package also requires instances of checksum verification
    > and recomputation controls.  These are not necessary for this tutorial
    > and are replaced with instantiations of empty controls.

