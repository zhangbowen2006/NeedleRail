///|
/// Integer units: 10 units = 1 mm. Screen coordinates: x right, y down.
pub(all) struct Point {
  x : Int32
  y : Int32
} derive(Eq, ToJson)

///|
fn valid_point(p : Point) -> Bool {
  p.x >= -10000 && p.x <= 10000 && p.y >= -10000 && p.y <= 10000
}

///|
fn distance(a : Point, b : Point) -> Double {
  let x = (a.x - b.x).to_double()
  let y = (a.y - b.y).to_double()
  (x * x + y * y).sqrt()
}

///|
fn interpolate(a : Point, b : Point, t : Double) -> Point {
  {
    x: @math.round(a.x.to_double() + (b.x - a.x).to_double() * t).to_int(),
    y: @math.round(a.y.to_double() + (b.y - a.y).to_double() * t).to_int(),
  }
}

///|
/// Subdivision retains each vertex, removes consecutive duplicate positions,
/// and leaves headroom for integer rounding so Euclidean length stays bounded.
pub fn running(
  path : Array[Point],
  max_step : Int32,
) -> Result[Array[Point], String] {
  if path.length() < 2 ||
    path.length() > 10000 ||
    max_step < 3 ||
    max_step > 121 {
    return Err("path requires 2..10000 points and max_step 3..121")
  }
  for p in path {
    if !valid_point(p) {
      return Err("coordinate exceeds 10000 units")
    }
  }
  let result = [path[0]]
  for i = 1; i < path.length(); i = i + 1 {
    let a = path[i - 1]
    let b = path[i]
    let parts = @math.ceil(distance(a, b) / (max_step - 2).to_double()).to_int()
    if result.length() + parts > 200000 {
      return Err("needle point limit: 200000")
    }
    for j = 1; j <= parts; j = j + 1 {
      let p = interpolate(a, b, j.to_double() / parts.to_double())
      if p != result[result.length() - 1] {
        result.push(p)
      }
    }
  }
  if result.length() < 2 {
    Err("degenerate path")
  } else {
    Ok(result)
  }
}
