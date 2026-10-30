///|
test "satin rails preserve endpoints and alternate sides" {
  assert_true(
    satin(
      [
        { x: 0, y: 0, },
        { x: 100, y: 100, },
        { x: 0, y: 100, },
        { x: 100, y: 0, },
      ],
      [{ x: 200, y: 0, }, { x: 200, y: 100, }],
      10,
      121,
    )
    is Err(_),
  )
  assert_true(
    satin(
      [{ x: 0, y: 0, }, { x: 100, y: 100, }],
      [{ x: 100, y: 0, }, { x: 0, y: 100, }],
      10,
      121,
    )
    is Err(_),
  )
  let p = satin(
    [{ x: 0, y: 0, }, { x: 0, y: 100, }],
    [{ x: 40, y: 0, }, { x: 40, y: 100, }],
    10,
    60,
  ).unwrap()
  assert_eq(p.length(), 22)
  for i = 0; i < p.length(); i = i + 1 {
    assert_eq(p[i].x, if i % 2 == 0 { 0 } else { 40 })
  }
  assert_eq(p[p.length() - 1].y, 100)
  assert_true(
    satin(
      [{ x: 0, y: 0, }, { x: 0, y: 100, }],
      [{ x: 80, y: 0, }, { x: 80, y: 100, }],
      10,
      60,
    )
    is Err(_),
  )
}
