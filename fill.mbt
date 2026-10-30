///|
fn orient(a : Point, b : Point, c : Point) -> Double {
  (b.x - a.x).to_double() * (c.y - a.y).to_double() -
  (b.y - a.y).to_double() * (c.x - a.x).to_double()
}

///|
fn between(a : Int32, b : Int32, x : Int32) -> Bool {
  (x >= a && x <= b) || (x >= b && x <= a)
}

///|
fn on_segment(a : Point, b : Point, p : Point) -> Bool {
  orient(a, b, p) == 0.0 && between(a.x, b.x, p.x) && between(a.y, b.y, p.y)
}

///|
fn intersects(a : Point, b : Point, c : Point, d : Point) -> Bool {
  let x = orient(a, b, c)
  let y = orient(a, b, d)
  let z = orient(c, d, a)
  let w = orient(c, d, b)
  (
    ((x < 0.0 && y > 0.0) || (x > 0.0 && y < 0.0)) &&
    ((z < 0.0 && w > 0.0) || (z > 0.0 && w < 0.0))
  ) ||
  on_segment(a, b, c) ||
  on_segment(a, b, d) ||
  on_segment(c, d, a) ||
  on_segment(c, d, b)
}

///|
/// Simple, non-touching rings, interpreted with the even-odd fill rule.
/// Returns separate sewing spans: callers must jump between these spans.
pub fn fill(
  rings : Array[Array[Point]],
  spacing : Int32,
  max_step : Int32,
) -> Result[Array[Array[Point]], String] {
  if rings.is_empty() || rings.length() > 16 || spacing < 2 || spacing > 1000 {
    return Err("fill requires 1..16 rings, spacing 2..1000")
  }
  let edges : Array[(Point, Point, Int32, Int32, Int32)] = []
  let mut min_y = 10000
  let mut max_y = -10000
  for r = 0; r < rings.length(); r = r + 1 {
    let ring = rings[r]
    if ring.length() < 3 || ring.length() > 512 {
      return Err("each ring requires 3..512 vertices without repeated endpoint")
    }
    let mut area = 0.0
    for i = 0; i < ring.length(); i = i + 1 {
      let a = ring[i]
      let b = ring[(i + 1) % ring.length()]
      let c = ring[(i + 2) % ring.length()]
      if orient(a, b, c) == 0.0 &&
        (b.x - a.x).to_double() * (c.x - b.x).to_double() +
        (b.y - a.y).to_double() * (c.y - b.y).to_double() <
        0.0 {
        return Err("ring edge backtracks")
      }
      if !valid_point(a) || a == b {
        return Err("invalid ring vertex or zero edge")
      }
      area = area +
        a.x.to_double() * b.y.to_double() -
        a.y.to_double() * b.x.to_double()
      min_y = if a.y < min_y { a.y } else { min_y }
      max_y = if a.y > max_y { a.y } else { max_y }
      edges.push((a, b, r, i, ring.length()))
    }
    if area == 0.0 {
      return Err("zero-area ring")
    }
  }
  if edges.length() > 2048 {
    return Err("fill edge limit: 2048")
  }
  for i = 0; i < edges.length(); i = i + 1 {
    for j = i + 1; j < edges.length(); j = j + 1 {
      let (a, b, r, k, n) = edges[i]
      let (c, d, s, l, _) = edges[j]
      if r == s && (l == k + 1 || (k == 0 && l == n - 1)) {
        continue
      }
      if intersects(a, b, c, d) {
        return Err("rings intersect or touch")
      }
    }
  }
  let spans : Array[Array[Point]] = []
  let mut count = 0
  let mut reverse = false
  for y = min_y + spacing / 2; y < max_y; y = y + spacing {
    let xs : Array[Double] = []
    for edge in edges {
      let (a, b, _, _, _) = edge
      if (a.y <= y && y < b.y) || (b.y <= y && y < a.y) {
        xs.push(
          a.x.to_double() +
          (y - a.y).to_double() *
          (b.x - a.x).to_double() /
          (b.y - a.y).to_double(),
        )
      }
    }
    xs.sort()
    if xs.length() % 2 != 0 {
      return Err("odd scanline intersection count")
    }
    let row : Array[Array[Point]] = []
    for i = 0; i < xs.length(); i = i + 2 {
      let x0 = @math.ceil(xs[i]).to_int()
      let x1 = @math.floor(xs[i + 1]).to_int()
      if x0 >= x1 {
        continue
      }
      let path = if reverse {
        [{ x: x1, y, }, { x: x0, y, }]
      } else {
        [{ x: x0, y, }, { x: x1, y, }]
      }
      let span = match running(path, max_step) {
        Err(e) => return Err(e)
        Ok(v) => v
      }
      count = count + span.length()
      if count > 200000 {
        return Err("fill point limit: 200000")
      }
      row.push(span)
    }
    for i = 0; i < row.length(); i = i + 1 {
      spans.push(row[if reverse { row.length() - 1 - i } else { i }])
    }
    reverse = !reverse
  }
  if spans.is_empty() {
    Err("fill spacing produces no sewing spans")
  } else {
    Ok(spans)
  }
}
