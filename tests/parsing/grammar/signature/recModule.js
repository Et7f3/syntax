module type Signature = {
  module rec A: {
    type t = Leaf(string) | Node(ASet.t)
    let compare: (t, t) => int
  }
  // notice the need for the parens on the module_type
  // otherwise `and` signals the start another with-constraint
  and ASet: (Set.S with type elt = A.t)
  and BTree: (Btree.S with type elt = A.t)

  @onFirstAttr
  module rec A: {
    type t = Leaf(string) | Node(ASet.t)
    let compare: (t, t) => int
  }
  @onSecondAttr
  and ASet: Set.S with type elt = A.t

  @parsableOnNext
  module rec A: Btree and ASet: BSet
}
