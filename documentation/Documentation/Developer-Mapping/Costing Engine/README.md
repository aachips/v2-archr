# ARCHR costing contracts

This folder defines the Project-KEY-centered reporting contract shared by the
Project Costing Database, Funding Sources Database, Task Library, Document
Builder, and Reporting Database.

- `costingObject.json` is a populated example of a resolved project snapshot.
- `schemas/costing-input.schema.json` validates sparse automation input.
- `schemas/costing-snapshot.schema.json` validates resolved snapshots.
- `schemas/costing-common.schema.json` contains the shared object definitions.
- `costing-flow.md` illustrates the operational and data flow.

The Costing Database is not the AAHH Finance accounting ledger. `act` represents
an attributed reporting actual and must retain its derivation and evidence
references. Funding selection precedes draw approval and payment.

## Sparse-write rules

1. Every write carries a unique `eventId`, an operation, and `projectKey`.
2. Omitted properties do not erase stored data.
3. Array members are upserted by their stable object IDs.
4. Earlier `robo` and `est` entries remain available after a better entry is
   added.
5. Deletion is never inferred from omission; records are explicitly voided.
6. The resolver normally uses `act > est > robo` per task when calculating the
   current reporting summary.

