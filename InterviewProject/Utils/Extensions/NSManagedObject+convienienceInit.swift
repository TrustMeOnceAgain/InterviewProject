//
//  NSManagedObject+convienienceInit.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 15/08/2022.
//

import CoreData

// Fixes warnings during unit tests
// https://stackoverflow.com/questions/52377909/coredata-warning-multiple-nsentitydescriptions-claim-the-nsmanagedobject-subcla/72161126#72161126
extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
