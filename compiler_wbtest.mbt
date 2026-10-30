///|
test "compiler splits travel and enforces hoop, color and terminal command" {
  let objects : Array[Object] = [
    { shape: Running([{ x: -400, y: 0, }, { x: -300, y: 0, }]), thread: 0, },
    { shape: Running([{ x: 300, y: 0, }, { x: 400, y: 0, }]), thread: 1, },
  ]
  let plan = compile(objects, 1000, 1000, 25).unwrap()
  let commands = plan.commands()
  assert_true(commands.filter(fn(c) { c.kind == Jump }).length() > 4)
  assert_eq(commands.filter(fn(c) { c.kind == Color }).length(), 1)
  assert_true(commands[commands.length() - 1].kind == End)
  let mut prev : Point = { x: 0, y: 0, }
  for c in commands {
    if c.kind == Jump {
      assert_true(distance(prev, c.position) <= 121.0)
    }
    if c.kind == Stitch {
      assert_true(distance(prev, c.position) <= 25.0)
    }
    prev = c.position
  }
  assert_true(compile(objects, 500, 500, 25) is Err(_))
  commands.clear()
  assert_true(!plan.commands().is_empty())
}
