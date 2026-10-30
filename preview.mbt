///|
/// Proof of needle/travel geometry only; it does not simulate fabric or thread.
pub fn Plan::svg(self : Plan) -> String {
  let palette = [
    "#b91c1c", "#1d4ed8", "#15803d", "#a16207", "#7e22ce", "#0f766e", "#be185d",
    "#111827",
  ]
  let out : Array[String] = [
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"900\" height=\"700\" viewBox=\"\{-self.width/2-20} \{-self.height/2-20} \{self.width+40} \{self.height+40}\">",
    "<rect x=\"\{-self.width/2} \" y=\"\{-self.height/2}\" width=\"\{self.width}\" height=\"\{self.height}\" fill=\"#fff\" stroke=\"#aaa\"/>",
  ]
  let mut prev : Point = { x: 0, y: 0, }
  for c in self.moves {
    if c.kind == Stitch && c.position != prev {
      out.push(
        "<path d=\"M \{prev.x} \{prev.y} L \{c.position.x} \{c.position.y}\" fill=\"none\" stroke=\"\{palette[c.thread%8]}\" stroke-width=\"2\"/>",
      )
    } else if c.kind == Jump {
      out.push(
        "<path d=\"M \{prev.x} \{prev.y} L \{c.position.x} \{c.position.y}\" fill=\"none\" stroke=\"#94a3b8\" stroke-width=\"1\" stroke-dasharray=\"4 4\"/>",
      )
    }
    prev = c.position
  }
  out.push("</svg>")
  out.join("")
}

///|
/// Stable machine-independent JSON command list; positions remain in 0.1 mm.
pub fn Plan::report(self : Plan) -> Json {
  let commands = self.moves.map(fn(c) {
    (
      {
        "x": Json(c.position.x),
        "y": Json(c.position.y),
        "kind": Json(kind_name(c.kind)),
        "thread": Json(c.thread),
      } : Json)
  })
  {
    "unit": "0.1mm",
    "hoop_width": Json(self.width),
    "hoop_height": Json(self.height),
    "max_step": Json(self.max_step),
    "stitches": Json(self.moves.filter(fn(c) { c.kind == Stitch }).length()),
    "jumps": Json(self.moves.filter(fn(c) { c.kind == Jump }).length()),
    "color_changes": Json(self.moves.filter(fn(c) { c.kind == Color }).length()),
    "commands": Json(commands),
  }
}
