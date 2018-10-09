import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

/// Test SQL generation

// case 1: A -> B -> C
// case 2: A -> B <- D
// case 3: B <- A -> E
// case 4: C <- B <- A
// case 5: A -> (B -> C) -> F
// case 6: A -> B -> (C -> F)
// case 7: F <- (C <- B) <- A
// case 8: F <- C <- (B <- A)
private struct A: TableRecord {
    static let b = belongsTo(B.self)
    static let c = hasOne(B.c, through: b) // case 1: A -> B -> C
    static let d = hasOne(B.d, through: b) // case 2: A -> B <- D
    static let e = belongsTo(E.self)
    static let f1 = hasOne(C.f, through: c) // case 5: A -> (B -> C) -> F
    static let f2 = hasOne(B.f, through: b) // case 6: A -> B -> (C -> F)
}

private struct B: TableRecord {
    static let a = hasOne(A.self)
    static let c = belongsTo(C.self)
    static let d = hasOne(D.self)
    static let e = hasOne(A.e, through: a) // case 3: B <- A -> E
    static let f = hasOne(C.f, through: c)
}

private struct C: TableRecord {
    static let a = hasOne(B.a, through: b) // case 4: C <- B <- A
    static let b = hasOne(B.self)
    static let f = belongsTo(F.self)
}

private struct D: TableRecord {
}

private struct E: TableRecord {
}

private struct F: TableRecord {
    static let c = hasOne(C.self)
    static let b = hasOne(C.b, through: c)
    static let a1 = hasOne(C.a, through: c) // case 7: F <- (C <- B) <- A
    static let a2 = hasOne(B.a, through: b) // case 8: F <- C <- (B <- A)
}

class AssociationHasOneThroughSQLTests: GRDBTestCase {
}
