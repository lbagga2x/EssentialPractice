//
//  URLSessionHttpClientTest.swift
//  EssentialFeedTests
//
//  Created by Lalit Bagga on 2022-02-04.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHttpClent {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {
    
    func test_getFromUrl_failsOnRequestError() {
        UrlProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "https://www.yahoo.com")!
        let error = NSError(domain: "Any Error", code: 1)
        UrlProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let sut = URLSessionHttpClent()
        let exp = expectation(description: "Wait for completion")
        
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(failureError as NSError):
                XCTAssertEqual(failureError.domain, error.domain)
            default:
                XCTFail("This shouldn't fail")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        UrlProtocolStub.stopInterceptingRequest()
    }
    
    /// Mark :  Helper
    private class UrlProtocolStub: URLProtocol {
        static var stubs = [URL: Stub]()
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: NSError? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequest() {
            UrlProtocolStub.registerClass(UrlProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            UrlProtocolStub.unregisterClass(UrlProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            return UrlProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = UrlProtocolStub.stubs[url] else {
                return
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}

