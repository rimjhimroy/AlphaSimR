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
