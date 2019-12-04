// RUN: %swift -target %module-target-future -parse-stdlib -emit-ir -prespecialize-generic-metadata %s | %FileCheck %s

precedencegroup AssignmentPrecedence {}

class Namespace<T> {}

class Zang {
}

extension Namespace where T == Zang {
  class ExtensionNonGeneric {}
}

@inline(never)
func consume<T>(_ t: T) {
  Builtin.fixLifetime(t)
}

// CHECK: define hidden swiftcc void @"$s4main4doityyF"() #{{[0-9]+}} {
// CHECK: entry:
// CHECK:   [[METADATA_RESPONSE:%[0-9]+]] = call swiftcc %swift.metadata_response @"$s4main9NamespaceCA2A4ZangCRszlE19ExtensionNonGenericCyAE_GMa"(i64 0) #{{[0-9]+}}
// CHECK:   [[METADATA:%[0-9]+]] = extractvalue %swift.metadata_response [[METADATA_RESPONSE]], 0
// CHECK:   call swiftcc void @"$s4main7consumeyyxlF"(%swift.opaque* noalias nocapture %5, %swift.type* [[METADATA]])
// CHECK: }
func doit() {
  consume( Namespace<Zang>.ExtensionNonGeneric() )
}

doit()
