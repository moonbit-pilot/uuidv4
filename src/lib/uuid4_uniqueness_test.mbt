///|
test "Uniqueness" {
  let set : @hashset.T[String] = @hashset.new()
  for i in 0..<10000 {
    let uuid = @lib.randomUUID(fn() {
      // Generate different seed for each iteration using multiple factors
      let bytes = Array::make(32, b'0')
      for j in 0..<32 {
        // Use more variation to ensure unique seeds with better distribution
        let val = (i * 101 + j * 79 + (i << 3) + (j << 2) + i * j * 13) % 256
        bytes[j] = val.to_byte()
      }
      @bytes.from_array(bytes)
    })
    assert_false(set.contains(uuid))
    set.add(uuid)
  }
  assert_eq(set.size(), 10000)
}
