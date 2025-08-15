///|
let table = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
]

///| create version 4 UUID conforming to RFC4122
/// ## Parameters
/// - `get_seed` : A function that returns a 32-byte seed.   
///   The seed function should:  
///   - Always return exactly 32 bytes
///   - Ensure uniqueness across rapid consecutive calls
/// ## Example
/// ```
/// test "format and Uniqueness" {
///   let set : @hashset.T[String] = @hashset.new()
///   for i in 0..<1000 {
///     let uuid = @lib.randomUUID(fn() {
///       // Generate different seed for each call
///       let bytes = Array::make(32, b'0')
///       for j in 0..<32 {
///         let val = (i * 101 + j * 79 + (i << 3) + (j << 2) + (i * j * 13)) % 256
///         bytes[j] = val.to_byte()
///       }
///       @bytes.from_array(bytes)
///     })
///     println(uuid)
///     assert_eq(uuid[14], '4')
///     let tmp = uuid[19]
///     assert_true(tmp == '8' || tmp == '9' || tmp == 'a' || tmp == 'b')
///     assert_false(set.contains(uuid))
///     set.add(uuid)
///   }
/// }
/// ```
pub fn randomUUID(get_seed : () -> Bytes) -> String {
  let seed_bytes = get_seed()
  if seed_bytes.length() != 32 {
    abort("seed must be 32 bytes long")
  }
  let uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".to_array()
  let seed_array = seed_bytes.to_array()
  let mut char_index = 0
  for i in 0..<uuid.length() {
    match uuid[i] {
      'x' => {
        // Use seed bytes with position-based variation
        let seed_index = char_index % seed_array.length()
        let randnum = (
            seed_array[seed_index].to_int() + char_index * 37 + i * 13
          ) %
          16
        uuid[i] = table[randnum]
        char_index += 1
      }
      'y' => {
        // set variant conforming to RFC4122
        let seed_index = char_index % seed_array.length()
        let mut randnum = (
            seed_array[seed_index].to_int() + char_index * 53 + i * 17
          ) %
          16
        randnum = (randnum & 0b0011) | 0b1000
        uuid[i] = table[randnum]
        char_index += 1
      }
      _ => ()
    }
  }
  String::from_array(uuid)
}
