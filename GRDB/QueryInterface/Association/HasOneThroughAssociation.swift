//
//  HasOneThroughAssociation.swift
//  GRDBCustom
//
//  Created by Gwendal Roué on 09/10/2018.
//  Copyright © 2018 Gwendal Roué. All rights reserved.
//

import Foundation

public struct HasOneThroughAssociation<Origin, Destination>: ToOneAssociation {
    /// :nodoc:
    public typealias OriginRowDecoder = Origin

    /// :nodoc:
    public typealias RowDecoder = Destination
    
    private let pivot: AssociationBase
    private let target: AssociationBase

    init(
        pivot: AssociationBase,
        target: AssociationBase)
    {
        self.pivot = pivot
        self.target = target
    }

    public func forKey(_ key: String) -> HasOneThroughAssociation<Origin, Destination> {
        fatalError("Not implemented")
//        return HasOneThroughAssociation(pivot: pivot, target: target.forKey(key))
    }
    
    public var query: AssociationQuery {
        fatalError("Not implemented")
    }

    public var joinCondition: JoinCondition {
        return pivot.joinCondition
    }
    
    public func mapQuery(_ transform: @escaping (AssociationQuery) -> AssociationQuery) -> HasOneThroughAssociation<Origin, Destination> {
        return HasOneThroughAssociation(pivot: pivot, target: target.mapQuery(transform))
    }
    
    public func joinedQuery(_ query: AssociationQuery, with joinOperator: AssociationJoinOperator) -> AssociationQuery {
        var query = pivot.joinedQuery(query, with: joinOperator)
        query = target.joinedQuery(query, with: joinOperator)
        return query
    }
    
    public func joinedQuery(_ query: QueryInterfaceQuery, with joinOperator: AssociationJoinOperator) -> QueryInterfaceQuery {
        var query = pivot.joinedQuery(query, with: joinOperator)
        query = target.joinedQuery(query, with: joinOperator)
        return query
    }
    

//    public var key: String {
//        return targetKey
//    }
//
//    /// :nodoc:
//    public var leftKey: String {
//        return middleKey
//    }
//
//    /// :nodoc:
//    public var joinCondition: JoinCondition {
//        return middleJoinCondition
//    }
//
////    /// :nodoc:
////    public func query(_ joinOperator: AssociationJoinOperator) -> AssociationQuery {
////        let join = AssociationJoin(
////            joinOperator: joinOperator,
////            joinCondition: targetJoinCondition,
////            query: targetQuery(joinOperator))
////        return middleQuery(joinOperator).joining(join, forKey: key)
////    }
//
//    public func forKey(_ key: String) -> HasOneThroughAssociation<Origin, Destination> {
//        var association = self
//        association.targetKey = key
//        return association
//    }
//
//    /// :nodoc:
//    public func mapQuery(_ transform: @escaping (AssociationQuery) -> AssociationQuery) -> HasOneThroughAssociation<Origin, Destination> {
//        var association = self
//        association.targetQuery = { transform(self.targetQuery($0)) }
//        return association
//    }
}

extension TableRecord {
    public static func hasOne<MiddleAssociation, TargetAssociation>(
        _ target: TargetAssociation,
        through pivot: MiddleAssociation,
        key: String? = nil)
        -> HasOneThroughAssociation<Self, TargetAssociation.RowDecoder>
        where MiddleAssociation: ToOneAssociation,
        TargetAssociation: ToOneAssociation,
        MiddleAssociation.OriginRowDecoder == Self,
        MiddleAssociation.RowDecoder == TargetAssociation.OriginRowDecoder
    {
        if let key = key {
            return HasOneThroughAssociation(pivot: pivot.select([]), target: target.forKey(key))
        } else {
            return HasOneThroughAssociation(pivot: pivot.select([]), target: target)
        }
    }
}

