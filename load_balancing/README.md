In this exercise, it is implemented a form of load balancing based on a simple version of Equal-Cost Multipath Forwarding. The switch will use two tables to forward packets to one of two destination hosts at random. The first table will use a hash function (applied to a 5-tuple consisting of the source and destination IP addresses, IP protocol, and source and destination TCP ports) to select one of two hosts. The second table will use the computed hash value to forward the packet to the selected host.

A complete load_balance will contain the following components:

1. Header type definitions for Ethernet (`ethernet_t`) and IPv4 (`ipv4_t`).
2. Parsers for Ethernet and IPv4 that populate `ethernet_t` and `ipv4_t` fields.
3. An action to drop a packet, using `mark_to_drop()`.
4. An action (called `set_ecmp_select`), which will:
	1. Hashes the 5-tuple specified above using the `hash` extern
	2. Stores the result in the `meta.ecmp_select` field
5. A control that:
    1. Applies the `ecmp_group` table.
    2. Applies the `ecmp_nhop` table.
6. A deparser that selects the order in which fields inserted into the outgoing
   packet.
7. A `package` instantiation supplied with the parser, control, and deparser.
    > In general, a package also requires instances of checksum verification
    > and recomputation controls.  These are not necessary for this tutorial
    > and are replaced with instantiations of empty controls.

