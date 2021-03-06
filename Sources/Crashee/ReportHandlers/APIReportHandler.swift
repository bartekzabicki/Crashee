//
//  File.swift
//  
//
//  Created by Bartłomiej Zabicki on 14/05/2020.
//

import Foundation

protocol ReportHandler {
    func handle(reports: [CrashReport], completion: @escaping ReportsCompletion)
}

final class APIReportHandler: ReportHandler {
    
    struct Configuration {
        let headers: [String: String]
        let method: Networking.NetworkMethod
        let session: URLSession
    }
    
    private(set) var url: URL
    private(set) var configuration: Configuration
    private lazy var networking: Networking = {
        let networking = Networking(session: configuration.session)
        return networking
    }()
    private var encoder: JSONEncoder
    
    // MARK: - Initialization
    
    init(url: URL, configuration: Configuration, encoder: JSONEncoder = .init()) {
        self.url = url
        self.configuration = configuration
        self.encoder = encoder
    }
    
    // MARK: - Functions
    
    public func handle(reports: [CrashReport], completion: @escaping ReportsCompletion) {
        let reportsData = reports.compactMap({ try? encoder.encode($0) })
        networking.request(with: url,
                           method: configuration.method,
                           parameters: nil,
                           reports: (key: "reports[]", reportsData: reportsData),
                           headers: configuration.headers,
                           encoding: .json,
                           onSuccess: { data in
                            completion(.success(reports))
        }, onError: { error in
            completion(.failure(.underlying(error)))
        })
    }
    
    
}
