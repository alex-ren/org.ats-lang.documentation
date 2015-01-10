
Towards Concurrent Program
=====================================

The type system of ATS consists of both dependent types and linear types. Please refer
to ATS' documentation for its application in constructing verifiably correct sequential
progarm. Linear types are of help to certain extent in ensuring safety properties about
mutual exclusion. However, in general, the type system of ATS has difficulty in
specifying properties of concurrent programs, e.g. invariants of objects across threads, 
absence of deadlock, liveness properties, and etc. Such incapability triggers our
research in corporating model checking techniques into the verification process of ATS
program.

But first of all, programmers have to be able to write concurrent programs in ATS.
Currently, we provide a set of primitives ma
