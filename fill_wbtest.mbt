///|
test "fill preserves hole and rejects crossing rings" {
  let outer = [
    { x: 0, y: 0, },
    { x: 100, y: 0, },
    { x: 100, y: 100, },
    { x: 0, y: 100, },
  ]
  let hole = [
    { x: 30, y: 30, },
    { x: 70, y: 30, },
    { x: 70, y: 70, },
    { x: 30, y: 70, },
  ]
  let spans = fill([outer, hole], 10, 25).unwrap()
  assert_eq(spans.length(), 14)
  for span in spans {
    for p in span {
      assert_true(!(p.x > 30 && p.x < 70 && p.y > 30 && p.y < 70))
    }
  }
  assert_true(fill([outer, outer], 10, 25) is Err(_))
  assert_true(
    fill(
      [
        [
          { x: 0, y: 0, },
          { x: 100, y: 100, },
          { x: 0, y: 100, },
          { x: 100, y: 0, },
        ],
      ],
      10,
      25,
    )
    is Err(_),
  )
}
