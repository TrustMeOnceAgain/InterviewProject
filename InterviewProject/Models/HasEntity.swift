//
//  HasEntity.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 15/08/2022.
//

import CoreData

protocol HasEntity {
    func addEntity(to context: NSManagedObjectContext)
}

extension Post: HasEntity {
    func addEntity(to context: NSManagedObjectContext) {
        let postCD = PostCD(context: context)
        postCD.id = Int32(id)
        postCD.userId = Int32(userId)
        postCD.title = title
        postCD.body = body
    }
}
