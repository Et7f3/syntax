let #shape = x
let #Shape = x
let #\"type" = x
let #\"test 🏚" = x
let #\"Shape✅" = x

let #Shape(\"module", \"ExoticIdent") = x

let #\"type"(\"module", \"ExoticIdent") = x
let #\"Shape🎡"(\"module", \"ExoticIdent") = x

let cmp = (selectedChoice, value) =>
  switch (selectedChoice, value) {
  | (#...a, #...a) => true
  | [#...b, #...b] => true
  | list{#...b, #...b} => true
  | {x: #...c, y: #...c} => true
  | Constructor(#...a, #...a) => true
  | #Constuctor(#...a, #...a) => true
  | #...a as x => true
  | #...a | #...b => true
  | (#...a : typ) => true
  | lazy #...a => true
  | exception #...a => true
  | _ => false
  }
