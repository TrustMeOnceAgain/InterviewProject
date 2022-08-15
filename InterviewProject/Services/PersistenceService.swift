//
//  PersistenceService.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 12/08/2022.
//

import CoreData
import Combine

struct PersistenceService {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "InterviewProject")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceService = {
        let result = PersistenceService(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<10 {
            let newPost = PostCD(context: viewContext)
            newPost.id = Int32(index)
            newPost.userId = Int32(index * 10)
            newPost.title = "Title: \(index)"
            newPost.body = "Body for index: \(index)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    func fetchData<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { [weak container] promise in
            do {
                try container?.viewContext.performAndWait {
                    let result = try fetchRequest.execute()
                    promise(.success(result))
                }
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func storeData() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak container] promise in
            do {
                try container?.viewContext.save()
                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteAllData(for entity: Entity) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak container] promise in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try container?.viewContext.execute(deleteRequest)
                promise(.success(()))
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    enum Entity {
        case post
        
        var name: String {
            switch self {
            case .post:
                return "PostCD"
            }
        }
    }
}
