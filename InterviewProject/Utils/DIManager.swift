//
//  DIManager.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

class DIManager {
    static var shared: DIManager = DIManager()
    
    let networkService: NetworkingService
    let persistentService: PersistenceService
    
    let jsonPlaceholderDBRepository: JsonPlaceholderDBRepository
    let jsonPlaceholderWebRepository: JsonPlaceholderWebRepository
    
    private init() {
        self.networkService = DIManager.createNetworkingService(appEnv: .realData) // change to use mocked data
        self.persistentService = PersistenceService()
        
        self.jsonPlaceholderWebRepository = JsonPlaceholderWebRepository(networkService: networkService)
        self.jsonPlaceholderDBRepository = JsonPlaceholderDBRepository(persistenceService: persistentService)
    }
    
    private static func createNetworkingService(appEnv: AppEnv) -> NetworkingService {
        switch appEnv {
        case .realData:
            return RealNetworkService()
        case .mockedData:
            return MockedNetworkService()
        }
    }
    
    enum AppEnv {
        case realData, mockedData
    }
}
