# v0.1 contract

The compiler consumes explicit geometry, never guesses stitches from a photo.
Each object starts with a jump. Empty/degenerate paths fail. All needle and jump
positions must stay inside a centered rectangular hoop. Long moves are split
deterministically. Color changes are explicit, and the stream terminates once.

Running stitches follow polylines. Satin alternates between arc-length samples
of two supplied rails. Fill uses even-odd scanlines; disconnected spans are joined
by jumps to avoid sewing across holes. Underlay, tie-in, trims, fabric distortion,
automatic lettering and vendor-specific machine settings are outside v0.1.

DST has 0.1 mm integer displacement records and no thread RGB palette. JSON and
SVG preserve color metadata separately. External decoding is required before
claiming file-format compatibility. No physical embroidery has been performed.
