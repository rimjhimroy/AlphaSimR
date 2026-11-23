# Local fixes to AlphaSimR's bundled MaCS implementation

This fork retains the upstream AlphaSimR license, authorship and attribution.
It starts from upstream commit `0a60280b8c9c65aaf8afcaee031e3498decd3b21`
(AlphaSimR 2.1.0). These changes support reproducible founder generation in a
separate tetraploid simulation project. They are general software corrections,
not a new model of ancestral quadrivalent meiosis or double reduction.

## Return valid empty founder populations

MaCS can legitimately generate zero SNPs, including when the mutation rate is
positive. Previously `src/simulator.cpp` accessed the first site before checking
whether that site existed, potentially crashing R. It now returns an empty
locus dimension with the requested number of individuals and chromosome copies.
The requested haplotype count is read from the existing MaCS command.

`R/founderPop.R` now handles the resulting empty genetic map without assigning
invalid marker names or calculating a nonfinite centromere. Zero is used as a
finite centromere placeholder for the empty map. Nonempty maps keep their
previous handling. No empty examples are resampled or replaced.

Run `Rscript tests/macs-zero-sites.R` against the installed package. It covers
diploids/tetraploids, inbred/outbred founders, two chromosomes, and zero/positive
mutation rates that produce empty outcomes. It checks dimensions, counts and
finite metadata.

## Make seeded MaCS founders independent of memory layout

The bundled MaCS implementation used `byNodePtr` to order ancestral nodes by
pointer address. Identical commands and random seeds could therefore traverse
nodes in a different order when allocation history changed. The same random
draws could then select different nodes and produce different founders.

The correction is limited to three dependency source files:

- `src/simulator.h`: compare node creation-order IDs rather than addresses.
- `src/datastructures.cpp`: assign each new node its ID.
- `src/simulator.cpp`: reset the counter at the start of each MaCS simulation.

The counter is thread-local so independent chromosome simulations do not share
it. This changes the implementation's traversal order and hence old seeded
realizations. It does not add a demographic or meiotic mechanism. Existing
simulations from the old implementation should remain separately versioned.

Run `Rscript tests/macs-reproducibility.R` against the installed package. It
compares fresh R processes, reversed seed batches, allocation perturbations,
and one/two-thread chromosome generation; distinct seeds must remain distinct.
The replay guarantee is scoped to the tested environment, not arbitrary
compiler, R or platform versions.

## Validation in the originating project

The corrected 2.1.0 dependency was built before promotion to the application.
Across 20 configurations, matching repeat comparisons increased from 6/60 to
60/60; all 54 nonempty repeats matched after the correction, versus zero before.
Nine distinct-seed contrasts remained distinct. Fourteen controlled inheritance
checks and three bridge integration cases passed. Both zero-rate and
positive-rate empty outcomes passed the complete genotype export path.

A replacement ancestry diagnostic completed 256 endpoints. All 32 intended
founder groups had identical founder hashes across the eight generation/pairing
treatments. Endpoints still represent separate forward mutation trajectories.
These are software and controlled inheritance checks, not evidence of accurate
recombination inference or an explicit ancestral quadrivalent model.

No generated datasets, compiled packages, credentials or local environments are
included in this repository. The original upstream license and attribution are
preserved.
