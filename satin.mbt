///|
fn rail_length(rail : Array[Point]) -> Double {
  let mut length = 0.0
  for i = 1; i < rail.length(); i = i + 1 {
    length = length + distance(rail[i - 1], rail[i])
  }
  length
}

///|
fn along(rail : Array[Point], fraction : Double, total : Double) -> Point {
  let target = fraction * total
  let mut walked = 0.0
  for i = 1; i < rail.length(); i = i + 1 {
    let length = distance(rail[i - 1], rail[i])
    if length > 0.0 && walked + length >= target {
      return interpolate(rail[i - 1], rail[i], (target - walked) / length)
    }
    walked = walked + length
  }
  rail[rail.length() - 1]
}

///|
fn satin_cell(value : Int32) -> Int32 {
  if value >= 0 {
    value / 128
  } else {
    (value - 127) / 128
  }
}

///|
/// Rails must have matching direction. Samples each by normalized arc length.
/// Oversize cross-rail stitches fail instead of silently changing stitch type.
pub fn satin(
  left : Array[Point],
  right : Array[Point],
  spacing : Int32,
  max_step : Int32,
) -> Result[Array[Point], String] {
  if left.length() > 512 || right.length() > 512 {
    return Err("satin rail vertex limit: 512")
  }
  if spacing < 3 || spacing > 1000 {
    return Err("satin spacing must be 3..1000")
  }
  match running(left, max_step) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  match running(right, max_step) {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  for rail in [left, right] {
    for i = 1; i < rail.length(); i = i + 1 {
      if rail[i] == rail[i - 1] {
        return Err("satin rail has a duplicate vertex")
      }
      if i + 1 < rail.length() {
        let a = rail[i - 1]
        let b = rail[i]
        let c = rail[i + 1]
        if orient(a, b, c) == 0.0 &&
          (b.x - a.x).to_double() * (c.x - b.x).to_double() +
          (b.y - a.y).to_double() * (c.y - b.y).to_double() <
          0.0 {
          return Err("satin rail edge backtracks")
        }
      }
      for j = i + 2; j < rail.length(); j = j + 1 {
        if intersects(rail[i - 1], rail[i], rail[j - 1], rail[j]) {
          return Err("satin rail self-intersects")
        }
      }
    }
  }
  for i = 1; i < left.length(); i = i + 1 {
    for j = 1; j < right.length(); j = j + 1 {
      if intersects(left[i - 1], left[i], right[j - 1], right[j]) {
        return Err("satin rails intersect or touch")
      }
    }
  }
  let ll = rail_length(left)
  let rl = rail_length(right)
  let length = if ll > rl { ll } else { rl }
  let steps = @math.ceil(length / spacing.to_double()).to_int()
  if steps > 99999 {
    return Err("satin point limit")
  }
  let result : Array[Point] = []
  // Each crossbar is at most 121 units long. Its bounding box therefore
  // occupies at most four 128-unit cells. Compare only spatial candidates,
  // deduplicating bars that occupy multiple cells. The budget is a work limit,
  // not a proof that rejected jobs are geometrically impossible.
  let buckets : Map[(Int32, Int32), Array[Int32]] = Map([])
  let seen = Array::make(steps + 1, -1)
  let mut comparisons = 0
  for i = 0; i <= steps; i = i + 1 {
    let t = i.to_double() / steps.to_double()
    let a = along(left, t, ll)
    let b = along(right, t, rl)
    if a == b {
      return Err("satin rails touch at a sampled station")
    }
    if distance(a, b) > max_step.to_double() {
      return Err("satin crossbar exceeds max_step; narrow rails")
    }
    if i > 0 && (a == result[2 * i - 2] || b == result[2 * i - 1]) {
      return Err(
        "satin station repeats a rounded rail endpoint; increase spacing",
      )
    }
    let x0 = satin_cell(if a.x < b.x { a.x } else { b.x })
    let x1 = satin_cell(if a.x > b.x { a.x } else { b.x })
    let y0 = satin_cell(if a.y < b.y { a.y } else { b.y })
    let y1 = satin_cell(if a.y > b.y { a.y } else { b.y })
    for x = x0; x <= x1; x = x + 1 {
      for y = y0; y <= y1; y = y + 1 {
        if buckets.get((x, y)) is Some(candidates) {
          for previous in candidates {
            if seen[previous] == i {
              continue
            }
            seen[previous] = i
            comparisons = comparisons + 1
            if comparisons > 1000000 {
              return Err("satin crossbar comparison budget exceeded: 1000000")
            }
            if intersects(a, b, result[2 * previous], result[2 * previous + 1]) {
              return Err(
                "satin crossbars intersect or touch; check rail direction and correspondence",
              )
            }
          }
        }
      }
    }
    for x = x0; x <= x1; x = x + 1 {
      for y = y0; y <= y1; y = y + 1 {
        buckets.get_or_init((x, y), fn() { [] }).push(i)
      }
    }
    result.push(a)
    result.push(b)
  }
  for i = 1; i < result.length(); i = i + 1 {
    if distance(result[i - 1], result[i]) > max_step.to_double() {
      return Err(
        "satin stitch exceeds max_step; narrow rails or reduce spacing",
      )
    }
  }
  Ok(result)
}
