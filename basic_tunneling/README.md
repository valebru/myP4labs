# Implementing Basic Tunneling

The basic switch forwards based on the destination IP address.  Your jobs is to define a new
header type to encapsulate the IP packet and modify the switch code, so that it
instead decides the destination port using a new tunnel header.

The new header type will contain a protocol ID, which indicates the type of
packet being encapsulated, along with a destination ID to be used for routing.


## Implement Basic Tunneling

1. A new header type has been added called `myTunnel_t` that contains
two 16-bit fields: `proto_id` and `dst_id`.
2. The `myTunnel_t` header has been added to the `headers` struct.
2. Update the parser to extract either the `myTunnel` header or
`ipv4` header based on the `etherType` field in the Ethernet header. The
etherType corresponding to the myTunnel header is `0x1212`. The parser should
also extract the `ipv4` header after the `myTunnel` header if `proto_id` ==
`TYPE_IPV4` (i.e.  0x0800).
3. Define a new action called `myTunnel_forward` that simply sets the
egress port (i.e. `egress_spec` field of the `standard_metadata` bus) to the
port number provided by the control plane.
4. Define a new table called `myTunnel_exact` that perfoms an exact
match on the `dst_id` field of the `myTunnel` header. This table should invoke
either the `myTunnel_forward` action if the there is a match in the table and
it should invoke the `drop` action otherwise.
5. Update the `apply` statement in the `MyIngress` control block to
apply your newly defined `myTunnel_exact` table if the `myTunnel` header is
valid. Otherwise, invoke the `ipv4_lpm` table if the `ipv4` header is valid.
6. Update the deparser to emit the `ethernet`, then `myTunnel`, then
`ipv4` headers. Remember that the deparser will only emit a header if it is
valid. A header's implicit validity bit is set by the parser upon extraction.
So there is no need to check header validity here.
7. Add static rules for your newly defined table so that the switches
will forward correctly for each possible value of `dst_id`. 
