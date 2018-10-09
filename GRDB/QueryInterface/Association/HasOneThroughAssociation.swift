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
    
    private var middleQuery: (AssociationJoinOperator) -> AssociationQuery
    private var middleJoinCondition: JoinCondition
    private var middleKey: String
    private var targetQuery: (AssociationJoinOperator) -> AssociationQuery
    private var targetJoinCondition: JoinCondition
    private var targetKey: String

    init(
        middleQuery: @escaping (AssociationJoinOperator) -> AssociationQuery,
        middleJoinCondition: JoinCondition,
        middleKey: String,
        targetQuery: @escaping (AssociationJoinOperator) -> AssociationQuery,
        targetJoinCondition: JoinCondition,
        targetKey: String)
    {
        self.middleQuery = middleQuery
        self.middleJoinCondition = middleJoinCondition
        self.targetQuery = targetQuery
        self.targetJoinCondition = targetJoinCondition
        self.middleKey = middleKey
        self.targetKey = targetKey
    }

    public var key: String {
        return targetKey
    }
    
    /// :nodoc:
    public var joinCondition: JoinCondition {
        return middleJoinCondition
    }
    
    /// :nodoc:
    public func query(_ joinOperator: AssociationJoinOperator) -> AssociationQuery {
        let join = AssociationJoin(
            joinOperator: AssociationJoinOperator.optional, // FIXME
            joinCondition: targetJoinCondition,
            query: targetQuery(joinOperator))
        return middleQuery(joinOperator).joining(join, forKey: key)
    }
    
    public func forKey(_ key: String) -> HasOneThroughAssociation<Origin, Destination> {
        var association = self
        association.targetKey = key
        return association
    }
    
    /// :nodoc:
    public func mapQuery(_ transform: @escaping (AssociationQuery) -> AssociationQuery) -> HasOneThroughAssociation<Origin, Destination> {
        var association = self
        association.targetQuery = { transform(self.targetQuery($0)) }
        return association
    }
}

extension TableRecord {
    public static func hasOne<MiddleAssociation, TargetAssociation>(
        _ target: TargetAssociation,
        through middle: MiddleAssociation,
        key: String? = nil)
        -> HasOneThroughAssociation<Self, TargetAssociation.RowDecoder>
        where MiddleAssociation: ToOneAssociation,
        TargetAssociation: ToOneAssociation,
        MiddleAssociation.OriginRowDecoder == Self,
        MiddleAssociation.RowDecoder == TargetAssociation.OriginRowDecoder
    {
        return HasOneThroughAssociation(
            middleQuery: { middle.query($0).select([]) },
            middleJoinCondition: middle.joinCondition,
            middleKey: middle.key,
            targetQuery: target.query,
            targetJoinCondition: target.joinCondition,
            targetKey: key ?? target.key)
    }
}

