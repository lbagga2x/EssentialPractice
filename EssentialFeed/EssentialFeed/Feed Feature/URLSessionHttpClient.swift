//
//  URLSessionHttpClent.swift
//  EssentialFeed
//
//  Created by Lalit Bagga on 2022-02-07.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public class URLSessionHttpClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    private struct UnexpectedError: Error {}

    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedError()))
            }
            
            
        }.resume()
    }
}
