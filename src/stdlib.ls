require! fs

fns =
  add: (x) -> x.0 + x.1
  sub: (x) -> x.0 - x.1
  times: (x) -> x.0 * x.1
  div: (x) -> x.0 / x.1
  mod: (x) -> x.0 % x.1
  print: (x) ->
    console.log x.0
    x.0
  prints: (x) ->
    process.stdout.write x.0
    x.0
  at: (x) -> x.1[x.0]
  either: (x) -> if x.0 then x.0 else x.1
  both: (x) -> if x.0 then x.1 else x.0
  equal: (x) -> x.0 is x.1
  not: (x) -> not x.1
  append: (x) -> x.1.concat x.0
  length: (x) -> x.0.length
  greater: (x) -> x.0 > x.1
  lesser: (x) -> x.0 < x.1
  range: (x) -> [x.0 to x.1]

library =
  argv: process.argv
  true: true
  false: false
  yes: true
  no: false
  head: (a) -> a.0.0
  map: (a) -> a.1.map (x) -> a.0 x
  add:     fns.add
  sub:     fns.sub
  mult:    fns.mult
  div:     fns.div
  mod:     fns.mod
  print:   fns.print
  prints:  fns.prints
  at:      fns.at
  if:      fns.if
  either:  fns.either
  both:    fns.both
  equal:   fns.equal
  not:     fns.not
  append:  fns.append
  length:  fns.length
  greater: fns.greater
  lesser:  fns.lesser
  range:   fns.range
  '+':  fns.add
  '-':  fns.sub
  '*':  fns.mult
  '/':  fns.div
  '%':  fns.mod

  '.':  fns.print
  '._': fns.prints
  '@':  fns.at
  '?':  fns.if
  '^':  fns.either
  '&':  fns.both
  '=':  fns.equal
  '!':  fns.not
  '<<': fns.append
  '_':  fns.length
  '>':  fns.greater
  '<':  fns.lesser
  '..': fns.range

module.exports = library