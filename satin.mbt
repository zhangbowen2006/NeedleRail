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
/// Rails must have matching direction. Samples each by normalized arc length.
/// Oversize cross-rail stitches fail instead of silently changing stitch type.
pub fn satin(
  left : Array[Point],
  right : Array[Point],
  spacing : Int32,
  max_step : Int32,
) -> Result[Array[Point], String] {
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
  let ll = rail_length(left)
  let rl = rail_length(right)
  let length = if ll > rl { ll } else { rl }
  let steps = @math.ceil(length / spacing.to_double()).to_int()
  if steps > 99999 {
    return Err("satin point limit")
  }
  let result : Array[Point] = []
  for i = 0; i <= steps; i = i + 1 {
    let t = i.to_double() / steps.to_double()
    let a = along(left, t, ll)
    let b = along(right, t, rl)
    if a == b {
      return Err("satin rails touch at a sampled station")
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
