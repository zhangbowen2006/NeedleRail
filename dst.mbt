///|
/// Tajima DST balanced signed displacement records. Y is inverted for DST.
fn dst_record(dx : Int32, dy : Int32, kind : Kind) -> Array[Byte] {
  if kind == End {
    return [0, 0, 243].map(fn(x) { x.to_byte() })
  }
  if kind == Color {
    return [0, 0, 195].map(fn(x) { x.to_byte() })
  }
  let out = [0, 0, if kind == Jump { 131 } else { 3 }]
  fn axis(
    value : Int32,
    layout : Array[(Int32, Int32, Int32, Int32)],
    out : Array[Int32],
  ) -> Unit {
    let mut remaining = value
    for entry in layout {
      let (weight, index, positive, negative) = entry
      if remaining > weight / 2 {
        out[index] = out[index] | (1 << positive)
        remaining = remaining - weight
      } else if remaining < -weight / 2 {
        out[index] = out[index] | (1 << negative)
        remaining = remaining + weight
      }
    }
  }
  axis(
    dx,
    [(81, 2, 2, 3), (27, 1, 2, 3), (9, 0, 2, 3), (3, 1, 0, 1), (1, 0, 0, 1)],
    out,
  )
  axis(
    -dy,
    [(81, 2, 5, 4), (27, 1, 5, 4), (9, 0, 5, 4), (3, 1, 7, 6), (1, 0, 7, 6)],
    out,
  )
  out.map(fn(x) { x.to_byte() })
}

///|
fn pad(value : Int32, width : Int32) -> String {
  let s = value.to_string()
  " ".repeat(if width > s.length() { width - s.length() } else { 0 }) + s
}

///|
/// 512-byte ASCII header plus three-byte records, including one end record.
/// The file carries color-change commands, not thread RGB values or trim codes.
pub fn Plan::dst(self : Plan) -> Bytes {
  let mut xmin = 0
  let mut xmax = 0
  let mut ymin = 0
  let mut ymax = 0
  let mut colors = 0
  for c in self.moves {
    let p = c.position
    xmin = if p.x < xmin { p.x } else { xmin }
    xmax = if p.x > xmax { p.x } else { xmax }
    ymin = if p.y < ymin { p.y } else { ymin }
    ymax = if p.y > ymax { p.y } else { ymax }
    if c.kind == Color {
      colors = colors + 1
    }
  }
  let last = self.moves[self.moves.length() - 1].position
  let ax = if last.x >= 0 { "+" } else { "-" }
  let ay = if last.y <= 0 { "+" } else { "-" }
  let header = "LA:NEEDLERAIL      \rST:" +
    pad(self.moves.length(), 7) +
    "\rCO:" +
    pad(colors, 3) +
    "\r+X:" +
    pad(xmax, 5) +
    "\r-X:" +
    pad(-xmin, 5) +
    "\r+Y:" +
    pad(ymax, 5) +
    "\r-Y:" +
    pad(-ymin, 5) +
    "\rAX:" +
    ax +
    pad(last.x.abs(), 5) +
    "\rAY:" +
    ay +
    pad(last.y.abs(), 5) +
    "\rMX:+    0\rMY:+    0\rPD:******\r"
  let bytes : Array[Byte] = []
  for c in header.iter() {
    bytes.push(c.to_int().to_byte())
  }
  bytes.push(26)
  while bytes.length() < 512 {
    bytes.push(32)
  }
  let mut previous : Point = { x: 0, y: 0, }
  for c in self.moves {
    for
      b in dst_record(
        c.position.x - previous.x,
        c.position.y - previous.y,
        c.kind,
      ) {
      bytes.push(b)
    }
    previous = c.position
  }
  Bytes::from_array(bytes)
}
