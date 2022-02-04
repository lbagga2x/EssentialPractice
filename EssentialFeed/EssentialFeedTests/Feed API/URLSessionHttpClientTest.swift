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
    init(session: URLSession) {
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
    
    func test_load_Resume() {
        let url = URL(string: "https://www.yahoo.com")!
        
        let session = UrlSessionSpy()
        let fakeUrlSession = FakeUrlSessionDataTask()
        session.stub(url: url, task: fakeUrlSession)
        
        let client = URLSessionHttpClent(session: session)
        client.get(from: url) { _ in
        }
        
        XCTAssertEqual(fakeUrlSession.resumeCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let url = URL(string: "https://www.yahoo.com")!
        let error = NSError(domain: "Any Error", code: 1)
        let session = UrlSessionSpy()
        session.stub(url: url, error: error)
        
        let client = URLSessionHttpClent(session: session)
        
        let exp = expectation(description: "Wait for completion")
        
        client.get(from: url) { result in
            switch result {
            case let .failure(failureError as NSError):
                XCTAssertEqual(failureError, error)
            default:
                XCTFail("This shouldn't fail")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    /// Mark :  Helper
    private class UrlSessionSpy: URLSession {
        var stubs = [URL: Stub]()
        
        struct Stub {
            let dataTask: URLSessionDataTask
            let error: Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("couldn't finsd stub")
            }
            completionHandler(nil, nil, stub.error)
            return stub.dataTask
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeUrlSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(dataTask: task, error: error)
        }
    }
    
    private class URLSPYSessionDataTask: URLSessionDataTask {
        override func resume() {
            
        }
    }
    
    private class FakeUrlSessionDataTask: URLSessionDataTask {
        var resumeCount = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
}

