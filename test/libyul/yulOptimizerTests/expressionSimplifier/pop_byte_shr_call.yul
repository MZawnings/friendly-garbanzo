{
  pop(byte(0, shr(0x8, call(0, 0, 0, 0, 0, 0, 0))))
}
// ====
// EVMVersion: >=constantinople
// ----
// step: expressionSimplifier
//
// {
//     pop(byte(0, shr(0x8, call(0, 0, 0, 0, 0, 0, 0))))
// }
