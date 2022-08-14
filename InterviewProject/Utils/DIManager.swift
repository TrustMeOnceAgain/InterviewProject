//
//  DIManager.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import Foundation

class DIManager {
    static var shared: DIManager = DIManager()
    
    let appEnvironment: AppEnv
    let networkService: NetworkingService
    let persistentService: PersistenceService
    
    let jsonPlaceholderDBRepository: JsonPlaceholderDBRepository
    let jsonPlaceholderWebRepository: JsonPlaceholderWebRepository
    
    private init() {
        let appEnv: AppEnv = .realData // change to use mocked data, could be extended to use e.g. defaults
        
        self.appEnvironment = appEnv
        self.networkService = DIManager.createNetworkingService(appEnv: appEnv)
        self.persistentService = PersistenceService(inMemory: appEnv != .realData)
        
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
