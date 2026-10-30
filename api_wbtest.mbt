///|
test "job schema refuses fractional geometry and invalid modes" {
  let good = "{\"width\":1000,\"height\":1000,\"max_step\":25,\"objects\":[{\"kind\":\"running\",\"thread\":0,\"path\":[[0,0],[100,100]]}]}"
  assert_true(parse_job(good) is Ok(_))
  assert_true(parse_job(good.replace(old="100,100", new="100.1,100")) is Err(_))
  assert_true(parse_job(good.replace(old="running", new="unknown")) is Err(_))
  assert_true(compile_json("{}").contains("error"))
}
