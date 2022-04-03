//
//  ShowInteractor.swift
//  domain
//
//  Created by Jastin on 1/4/22.
//

import Foundation

public protocol ShowInteractorProtocol {
    func fetchShowList(handler: @escaping ((Result<[ShowEntity],DomainError>) -> Void))
}

public class ShowInteractor : ShowInteractorProtocol {
    
    private let showDomainRepositoryProtocol: ShowDomainRepositoryProtocol
    
    public init(showDomainRepositoryProtocol: ShowDomainRepositoryProtocol) {
        self.showDomainRepositoryProtocol = showDomainRepositoryProtocol
    }
    
    public func fetchShowList(handler: @escaping ((Result<[ShowEntity],DomainError>) -> Void)) {
        self.showDomainRepositoryProtocol.fetchShowList(handler: handler)
    }
}
