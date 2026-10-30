///|
pub(all) enum Shape {
  Running(Array[Point])
  Satin(Array[Point], Array[Point], Int32)
  Fill(Array[Array[Point]], Int32)
}

///|
pub(all) struct Object {
  shape : Shape
  thread : Int32
}

///|
pub(all) enum Kind {
  Stitch
  Jump
  Color
  End
} derive(Eq)

///|
pub struct Command {
  position : Point
  kind : Kind
  thread : Int32
}

///|
pub struct Plan {
  priv moves : Array[Command]
  priv width : Int32
  priv height : Int32
  priv max_step : Int32
}

///|
pub fn Plan::commands(self : Plan) -> Array[Command] {
  self.moves.copy()
}

///|
pub fn kind_name(k : Kind) -> String {
  match k {
    Stitch => "stitch"
    Jump => "jump"
    Color => "color"
    End => "end"
  }
}

///|
/// Compiles independent objects in caller order; no automatic thread sorting.
pub fn compile(
  objects : Array[Object],
  width : Int32,
  height : Int32,
  max_step : Int32,
) -> Result[Plan, String] {
  if width < 100 ||
    height < 100 ||
    width > 10000 ||
    height > 10000 ||
    max_step < 3 ||
    max_step > 121 ||
    objects.is_empty() ||
    objects.length() > 256 {
    return Err("invalid hoop, step, or object count")
  }
  let moves : Array[Command] = []
  let mut current : Point = { x: 0, y: 0, }
  let mut thread = objects[0].thread
  for obj in objects {
    if obj.thread < 0 || obj.thread > 63 {
      return Err("thread id must be 0..63")
    }
    let spans = match obj.shape {
      Running(p) =>
        match running(p, max_step) {
          Err(e) => return Err(e)
          Ok(v) => [v]
        }
      Satin(l, r, s) =>
        match satin(l, r, s, max_step) {
          Err(e) => return Err(e)
          Ok(v) => [v]
        }
      Fill(r, s) =>
        match fill(r, s, max_step) {
          Err(e) => return Err(e)
          Ok(v) => v
        }
    }
    if obj.thread != thread {
      moves.push({ position: current, kind: Color, thread: obj.thread, })
      thread = obj.thread
    }
    for span in spans {
      for p in span {
        if p.x.abs() * 2 > width || p.y.abs() * 2 > height {
          return Err("needle position outside centered hoop")
        }
      }
      let start = span[0]
      if start != current {
        let path = match running([current, start], 121) {
          Err(e) => return Err(e)
          Ok(v) => v
        }
        for i = 1; i < path.length(); i = i + 1 {
          moves.push({ position: path[i], kind: Jump, thread, })
        }
      }
      moves.push({ position: start, kind: Stitch, thread, })
      for i = 1; i < span.length(); i = i + 1 {
        moves.push({ position: span[i], kind: Stitch, thread, })
      }
      current = span[span.length() - 1]
      if moves.length() >= 200000 {
        return Err("command limit: 200000")
      }
    }
  }
  moves.push({ position: current, kind: End, thread, })
  Ok({ moves, width, height, max_step, })
}

///|
pub fn Plan::settings(self : Plan) -> (Int32, Int32, Int32) {
  (self.width, self.height, self.max_step)
}
