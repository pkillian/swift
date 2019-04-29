// RUN: %target-run-simple-swift | %FileCheck %s
// REQUIRES: executable_test

@_functionBuilder
struct TupleBuilder {
  static func buildBlock<T1, T2>(_ t1: T1, _ t2: T2) -> (T1, T2) {
    return (t1, t2)
  }
  
  static func buildBlock<T1, T2, T3>(_ t1: T1, _ t2: T2, _ t3: T3)
      -> (T1, T2, T3) {
    return (t1, t2, t3)
  }

  static func buildBlock<T1, T2, T3, T4>(_ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4)
      -> (T1, T2, T3, T4) {
    return (t1, t2, t3, t4)
  }

  static func buildBlock<T1, T2, T3, T4, T5>(
    _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5
  ) -> (T1, T2, T3, T4, T5) {
    return (t1, t2, t3, t4, t5)
  }

  static func buildDo<T>(_ value: T) -> T { return value }
  static func buildIf<T>(_ value: T?) -> T? { return value }
}

func tuplify<T>(_ cond: Bool, @TupleBuilder body: (Bool) -> T) {
  print(body(cond))
}

// CHECK: (17, 3.14159, "Hello, DSL", (["nested", "do"], 6), Optional((2.71828, ["if", "stmt"])))
let name = "dsl"
tuplify(true) {
  17
  3.14159
  "Hello, \(name.map { $0.uppercased() }.joined())"
  do {
    ["nested", "do"]
    1 + 2 + 3
  }
  if $0 {
    2.71828
    ["if", "stmt"]
  }
}

// CHECK: ("Empty optional", nil)
tuplify(false) {
  "Empty optional"
  if $0 {
    2.71828
    ["if", "stmt"]
  }
}

struct Tagged<Tag, Entity> {
  let tag: Tag
  let entity: Entity
}

protocol Taggable {
}

extension Taggable {
  func tag<Tag>(_ tag: Tag) -> Tagged<Tag, Self> {
    return Tagged(tag: tag, entity: self)
  }
}

extension Int: Taggable { }
extension String: Taggable { }
extension Double: Taggable { }

@_functionBuilder
struct TaggedBuilder<Tag> {
  static func buildBlock() -> () { }

  static func buildBlock<T1>(_ t1: Tagged<Tag, T1>) -> Tagged<Tag, T1> {
    return t1
  }

  static func buildBlock<T1, T2>(_ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>) -> (Tagged<Tag, T1>, Tagged<Tag, T2>) {
    return (t1, t2)
  }

  static func buildBlock<T1, T2, T3>(_ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>, _ t3: Tagged<Tag, T3>)
      -> (Tagged<Tag, T1>, Tagged<Tag, T2>, Tagged<Tag, T3>) {
    return (t1, t2, t3)
  }

  static func buildBlock<T1, T2, T3, T4>(_ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>, _ t3: Tagged<Tag, T3>, _ t4: Tagged<Tag, T4>)
      -> (Tagged<Tag, T1>, Tagged<Tag, T2>, Tagged<Tag, T3>, Tagged<Tag, T4>) {
    return (t1, t2, t3, t4)
  }

  static func buildBlock<T1, T2, T3, T4, T5>(
    _ t1: Tagged<Tag, T1>, _ t2: Tagged<Tag, T2>, _ t3: Tagged<Tag, T3>, _ t4: Tagged<Tag, T4>, _ t5: Tagged<Tag, T5>
  ) -> (Tagged<Tag, T1>, Tagged<Tag, T2>, Tagged<Tag, T3>, Tagged<Tag, T4>, Tagged<Tag, T5>) {
    return (t1, t2, t3, t4, t5)
  }

  static func buildIf<T>(_ value: Tagged<Tag, T>?) -> Tagged<Tag, T>? { return value }
}

enum Color {
  case red, green, blue
}

func acceptColorTagged<Result>(@TaggedBuilder<Color> body: () -> Result) {
  print(body())
}

struct TagAccepter<Tag> {
  static func acceptTagged<Result>(@TaggedBuilder<Tag> body: () -> Result) {
    print(body())
  }
}

func testAcceptColorTagged(b: Bool, i: Int, s: String, d: Double) {
  // CHECK: Tagged<
  acceptColorTagged {
    i.tag(.red)
    s.tag(.green)
    d.tag(.blue)
  }

  // CHECK: Tagged<
  TagAccepter<Color>.acceptTagged {
    i.tag(.red)
    s.tag(.green)
    d.tag(.blue)
  }

  // CHECK: Tagged<
  TagAccepter<Color>.acceptTagged { () -> Tagged<Color, Int> in 
    if b {
      return i.tag(Color.green)
    } else {
      return i.tag(Color.blue)
    }
  }
}

testAcceptColorTagged(b: true, i: 17, s: "Hello", d: 3.14159)
