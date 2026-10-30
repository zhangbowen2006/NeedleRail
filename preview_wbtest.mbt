///|
test "proof and report contain geometry with fixed color metadata" {
  let plan = compile(
    [{ shape: Running([{ x: 0, y: 0, }, { x: 10, y: 10, }]), thread: 1, }],
    1000,
    1000,
    25,
  ).unwrap()
  assert_true(plan.svg().has_prefix("<svg"))
  assert_true(plan.svg().contains("#1d4ed8"))
  assert_true(plan.report().stringify().contains("0.1mm"))
}
