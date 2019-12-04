// RUN: %swift -target %module-target-future -emit-ir -prespecialize-generic-metadata %s | %FileCheck %s

// CHECK: @"$s4main5ValueVySiGMf" = internal constant <{ i8**, i64, %swift.type_descriptor*, %swift.type*, i32, [4 x i8], i64 }> <{ i8** getelementptr inbounds (%swift.vwtable, %swift.vwtable* @"$s4main5ValueVWV", i32 0, i32 0), i64 512, %swift.type_descriptor* bitcast (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8 }>* @"$s4main5ValueVMn" to %swift.type_descriptor*), %swift.type* @"$sSiN", i32 0, [4 x i8] zeroinitializer, i64 3 }>, align 8
struct Value<First> {
  let first: First
}

@inline(never)
func consume<T>(_ t: T) {
  withExtendedLifetime(t) { t in
  }
}

// CHECK: define hidden swiftcc void @"$s4main4doityyF"() #{{[0-9]+}} {
// CHECK:   call swiftcc void @"$s4main7consumeyyxlF"(%swift.opaque* noalias nocapture %{{[0-9]+}}, %swift.type* bitcast (i64* getelementptr inbounds (<{ i8**, i64, %swift.type_descriptor*, %swift.type*, i32, [4 x i8], i64 }>, <{ i8**, i64, %swift.type_descriptor*, %swift.type*, i32, [4 x i8], i64 }>* @"$s4main5ValueVySiGMf", i32 0, i32 1) to %swift.type*))
// CHECK: }
func doit() {
  consume( Value(first: 13) )
}
doit()

// CHECK: ; Function Attrs: noinline nounwind readnone
// CHECK: define hidden swiftcc %swift.metadata_response @"$s4main5ValueVMa"(i64, %swift.type*) #{{[0-9]+}} {
// CHECK: entry:
// CHECK:   [[ERASED_TYPE:%[0-9]+]] = bitcast %swift.type* %1 to i8*
// CHECK:   br label %[[TYPE_COMPARISON_LABEL:[0-9]+]]
// CHECK: [[TYPE_COMPARISON_LABEL]]:
// CHECK:   [[EQUAL_TYPE:%[0-9]+]] = icmp eq i8* bitcast (%swift.type* @"$sSiN" to i8*), [[ERASED_TYPE]]
// CHECK:   [[EQUAL_TYPES:%[0-9]+]] = and i1 true, [[EQUAL_TYPE]]
// CHECK:   br i1 [[EQUAL_TYPES]], label %[[EXIT_PRESPECIALIZED:[0-9]+]], label %[[EXIT_NORMAL:[0-9]+]]
// CHECK: [[EXIT_PRESPECIALIZED]]:
// CHECK:   ret %swift.metadata_response { %swift.type* bitcast (i64* getelementptr inbounds (<{ i8**, i64, %swift.type_descriptor*, %swift.type*, i32, [4 x i8], i64 }>, <{ i8**, i64, %swift.type_descriptor*, %swift.type*, i32, [4 x i8], i64 }>* @"$s4main5ValueVySiGMf", i32 0, i32 1) to %swift.type*), i64 0 }
// CHECK: [[EXIT_NORMAL]]:
// CHECK:   {{%[0-9]+}} = call swiftcc %swift.metadata_response @__swift_instantiateGenericMetadata(i64 %0, i8* [[ERASED_TYPE]], i8* undef, i8* undef, %swift.type_descriptor* bitcast (<{ i32, i32, i32, i32, i32, i32, i32, i32, i32, i16, i16, i16, i16, i8, i8, i8, i8 }>* @"$s4main5ValueVMn" to %swift.type_descriptor*)) #{{[0-9]+}}
// CHECK:   ret %swift.metadata_response {{%[0-9]+}}
// CHECK: }
