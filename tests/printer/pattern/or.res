let Foo | Bar = 1
let (Red | Blue) | Green = 1
let Red | (Blue | Green) = 1
let exception Foo | exception Bar = 1

let Red | Blue | Green = x

let Red | (Blue | Green) = x
let (Red | Blue) | Green = x
let (Red | Blue) | (Green | Purple) | Black = x
let (Red | Blue) | ((Green | Purple) | Rosa) | (Black | White) = x
let (Red | Blue) | ((Green | Purple) | Rosa) | (Black | White) | AnotherColoooooour = x
