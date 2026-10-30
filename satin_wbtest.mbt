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

///|
test "satin rejects adjacent backtracking and reversed correspondence" {
  match
    satin(
      [{ x: 0, y: 0, }, { x: 0, y: 100, }, { x: 0, y: 50, }],
      [{ x: 40, y: 0, }, { x: 40, y: 100, }, { x: 40, y: 50, }],
      10,
      121,
    ) {
    Ok(_) => fail("backtracking rail accepted")
    Err(e) => assert_true(e.contains("backtracks"))
  }
  match
    satin(
      [{ x: 0, y: 0, }, { x: 0, y: 40, }],
      [{ x: 20, y: 40, }, { x: 20, y: 0, }],
      10,
      121,
    ) {
    Ok(_) => fail("reversed correspondence accepted")
    Err(e) => assert_true(e.contains("crossbars"))
  }
}

///|
test "nonadjacent crossbars cannot overlap after turning a corner" {
  // Both rails are simple, disjoint and x-monotone. Crossbars rise and then
  // descend, so nonadjacent horizontal bars overlap although neighbors differ.
  match
    satin(
      [{ x: -40, y: -30, }, { x: -30, y: 30, }, { x: -20, y: -30, }],
      [{ x: 20, y: -30, }, { x: 30, y: 30, }, { x: 40, y: -30, }],
      7,
      121,
    ) {
    Ok(_) => fail("nonadjacent overlapping crossbars accepted")
    Err(e) => assert_true(e.contains("crossbars"))
  }
}

///|
test "large normal satin uses bounded spatial candidate checks" {
  assert_eq(satin_cell(-129), -2)
  assert_eq(satin_cell(-128), -1)
  assert_eq(satin_cell(-1), -1)
  assert_eq(satin_cell(0), 0)
  assert_eq(satin_cell(127), 0)
  assert_eq(satin_cell(128), 1)
  let result = satin(
    [{ x: -20, y: -9000, }, { x: -20, y: 9000, }],
    [{ x: 20, y: -9000, }, { x: 20, y: 9000, }],
    3,
    60,
  ).unwrap()
  assert_eq(result.length(), 12002)
  assert_eq(result[0].y, -9000)
  assert_eq(result[result.length() - 1].y, 9000)
  for i = 1; i < result.length(); i = i + 1 {
    assert_true(distance(result[i - 1], result[i]) <= 60.0)
  }
}

///|
test "rounded repeated stations fail explicitly" {
  match
    satin(
      [{ x: 0, y: 0, }, { x: 0, y: 10, }],
      [{ x: 40, y: 0, }, { x: 40, y: 10000, }],
      3,
      121,
    ) {
    Ok(_) => fail("rounded repeated rail endpoint accepted")
    Err(e) => assert_true(e.contains("repeats a rounded rail endpoint"))
  }
}
