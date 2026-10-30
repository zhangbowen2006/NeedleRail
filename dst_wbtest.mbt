///|
test "all 59049 legal displacement pairs decode independently" {
  fn decode(b : Array[Byte]) -> (Int32, Int32) {
    fn bit(b : Byte, i : Int32) -> Int32 {
      (b.to_int() >> i) & 1
    }
    let x = bit(b[0], 0) -
      bit(b[0], 1) +
      3 * (bit(b[1], 0) - bit(b[1], 1)) +
      9 * (bit(b[0], 2) - bit(b[0], 3)) +
      27 * (bit(b[1], 2) - bit(b[1], 3)) +
      81 * (bit(b[2], 2) - bit(b[2], 3))
    let y = bit(b[0], 7) -
      bit(b[0], 6) +
      3 * (bit(b[1], 7) - bit(b[1], 6)) +
      9 * (bit(b[0], 5) - bit(b[0], 4)) +
      27 * (bit(b[1], 5) - bit(b[1], 4)) +
      81 * (bit(b[2], 5) - bit(b[2], 4))
    (x, -y)
  }
  for x = -121; x <= 121; x = x + 1 {
    for y = -121; y <= 121; y = y + 1 {
      assert_eq(decode(dst_record(x, y, Stitch)), (x, y))
      assert_eq(decode(dst_record(x, y, Jump)), (x, y))
    }
  }
  let plan = compile(
    [{ shape: Running([{ x: 0, y: 0, }, { x: 100, y: 0, }]), thread: 0, }],
    1000,
    1000,
    25,
  ).unwrap()
  let bytes = plan.dst()
  assert_eq(bytes.length(), 512 + 3 * plan.moves.length())
  assert_eq(bytes[bytes.length() - 1].to_int(), 243)
}
