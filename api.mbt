///|
priv struct InputObject {
  kind : String
  thread : Double
  path : Array[Array[Double]]?
  left : Array[Array[Double]]?
  right : Array[Array[Double]]?
  rings : Array[Array[Array[Double]]]?
  spacing : Double?
} derive(FromJson)

///|
priv struct Input {
  width : Double
  height : Double
  max_step : Double
  objects : Array[InputObject]
} derive(FromJson)

///|
fn int_valid(x : Double, low : Int32, high : Int32) -> Bool {
  x >= low.to_double() && x <= high.to_double() && x.to_int().to_double() == x
}

///|
/// Check lexical integers before Double decoding can round a fractional token.
fn integer_tokens(value : Json) -> Bool {
  match value {
    Number(_, repr~) => {
      let s = match repr {
        None => return false
        Some(s) => s
      }
      let mut first = true
      let mut digits = 0
      for c in s.iter() {
        if first && c == '-' {
          first = false
          continue
        }
        if c < '0' || c > '9' {
          return false
        }
        first = false
        digits = digits + 1
      }
      digits > 0
    }
    Array(items) => items.all(integer_tokens)
    Object(fields) => {
      for _, v in fields {
        if !integer_tokens(v) {
          return false
        }
      }
      true
    }
    _ => true
  }
}

///|
fn points(raw : Array[Array[Double]]) -> Result[Array[Point], String] {
  if raw.length() > 10000 {
    return Err("too many points")
  }
  let out : Array[Point] = []
  for p in raw {
    if p.length() != 2 ||
      !int_valid(p[0], -10000, 10000) ||
      !int_valid(p[1], -10000, 10000) {
      return Err("points require two integer coordinates in -10000..10000")
    }
    out.push({ x: p[0].to_int(), y: p[1].to_int(), })
  }
  Ok(out)
}

///|
pub fn parse_job(text : String) -> Result[Plan, String] {
  if text.length() > 4000000 {
    return Err("job text limit: 4000000")
  }
  let raw = @json.parse(
    text,
    reject_duplicate_keys=true,
    max_nesting_depth=16,
    preserve_number_repr=true,
  ) catch {
    _ => return Err("invalid JSON")
  }
  if !integer_tokens(raw) {
    return Err(
      "job numbers must use integer literals (no decimals or exponents)",
    )
  }
  let input : Input = @json.from_json(raw) catch {
    _ => return Err("invalid job schema")
  }
  match raw {
    Object(fields) => {
      for key, _ in fields {
        if !["width", "height", "max_step", "objects"].contains(key) {
          return Err("unknown job field: " + key)
        }
      }
      if fields.get("objects") is Some(Array(items)) {
        for item in items {
          if item is Object(obj_fields) {
            for key, _ in obj_fields {
              if ![
                  "kind", "thread", "path", "left", "right", "rings", "spacing",
                ].contains(key) {
                return Err("unknown object field: " + key)
              }
            }
          }
        }
      }
    }
    _ => return Err("job must be an object")
  }
  if !int_valid(input.width, 100, 10000) ||
    !int_valid(input.height, 100, 10000) ||
    !int_valid(input.max_step, 3, 121) {
    return Err("hoop and step must be bounded integers")
  }
  if input.objects.is_empty() || input.objects.length() > 256 {
    return Err("object count must be 1..256")
  }
  let objects : Array[Object] = []
  for obj in input.objects {
    if !int_valid(obj.thread, 0, 63) {
      return Err("invalid thread id")
    }
    let shape = match obj.kind {
      "running" => {
        if obj.left is Some(_) ||
          obj.right is Some(_) ||
          obj.rings is Some(_) ||
          obj.spacing is Some(_) {
          return Err("irrelevant running parameters")
        }
        let raw = match obj.path {
          None => return Err("running requires path")
          Some(v) => v
        }
        Running(
          match points(raw) {
            Err(e) => return Err(e)
            Ok(v) => v
          },
        )
      }
      "satin" => {
        if obj.path is Some(_) || obj.rings is Some(_) {
          return Err("irrelevant satin parameters")
        }
        let l = match obj.left {
          None => return Err("satin requires left rail")
          Some(v) => v
        }
        let r = match obj.right {
          None => return Err("satin requires right rail")
          Some(v) => v
        }
        let s = match obj.spacing {
          None => return Err("satin requires spacing")
          Some(v) => v
        }
        if !int_valid(s, 3, 1000) {
          return Err("invalid satin spacing")
        }
        Satin(
          match points(l) {
            Err(e) => return Err(e)
            Ok(v) => v
          },
          match points(r) {
            Err(e) => return Err(e)
            Ok(v) => v
          },
          s.to_int(),
        )
      }
      "fill" => {
        if obj.path is Some(_) || obj.left is Some(_) || obj.right is Some(_) {
          return Err("irrelevant fill parameters")
        }
        let raw = match obj.rings {
          None => return Err("fill requires rings")
          Some(v) => v
        }
        if raw.length() > 16 {
          return Err("too many rings")
        }
        let s = match obj.spacing {
          None => return Err("fill requires spacing")
          Some(v) => v
        }
        if !int_valid(s, 2, 1000) {
          return Err("invalid fill spacing")
        }
        let rings : Array[Array[Point]] = []
        for r in raw {
          rings.push(
            match points(r) {
              Err(e) => return Err(e)
              Ok(v) => v
            },
          )
        }
        Fill(rings, s.to_int())
      }
      _ => return Err("unknown stitch kind")
    }
    objects.push({ shape, thread: obj.thread.to_int(), })
  }
  compile(
    objects,
    input.width.to_int(),
    input.height.to_int(),
    input.max_step.to_int(),
  )
}

///|
/// Pure compilation: host writes the returned bytes, SVG and report.
pub fn compile_json(text : String) -> String {
  let p = match parse_job(text) {
    Err(e) => return ({ "error": Json(e) } : Json).stringify()
    Ok(p) => p
  }
  let bytes = p.dst()
  let out : Json = {
    "dst_bytes": Json(Array::makei(bytes.length(), fn(i) { bytes[i].to_int() })),
    "svg": Json(p.svg()),
    "report": p.report(),
  }
  out.stringify()
}
