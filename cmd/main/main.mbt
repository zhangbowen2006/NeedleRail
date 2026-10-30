///|
/// Entry point for the CLI or runnable program in this template.
/// Keep main focused; move logic into the library package.
/// Run with `moon run cmd/main` from the project root.
fn main {
  let plan = @lib.compile(
    [
      {
        shape: @lib.Running([
          { x: 0, y: 0, },
          { x: 100, y: 100, },
          { x: 200, y: 0, },
        ]),
        thread: 0,
      },
    ],
    1000,
    1000,
    25,
  ).unwrap()
  println(plan.report().stringify())
  println("DST bytes: \{plan.dst().length()}")
}
