///|
test "running paths preserve vertices and bounded Euclidean steps" {
  let p = running(
    [
      { x: 0, y: 0, },
      { x: 100, y: 100, },
      { x: 100, y: 100, },
      { x: -50, y: 20, },
    ],
    25,
  ).unwrap()
  assert_true(p[0] == { x: 0, y: 0, })
  assert_true(p[p.length() - 1] == { x: -50, y: 20, })
  assert_true(p.contains({ x: 100, y: 100, }))
  for i = 1; i < p.length(); i = i + 1 {
    assert_true(distance(p[i - 1], p[i]) <= 25.0)
  }
  assert_true(running([{ x: 0, y: 0, }, { x: 0, y: 0, }], 25) is Err(_))
  assert_true(running([{ x: 0, y: 0, }, { x: 10001, y: 0, }], 25) is Err(_))
}
