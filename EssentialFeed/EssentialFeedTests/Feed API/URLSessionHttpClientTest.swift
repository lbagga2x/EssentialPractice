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
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
        }
    }
}

class URLSessionHttpClientTest: XCTestCase {
    
    func test_load_Url() {
        let url = URL(string: "https://www.yahoo.com")!
        
        let session = UrlSessionSpy()
        let client = URLSessionHttpClent(session: session)
        client.get(from: url)
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    
    /// Mark :  Helper
    private class UrlSessionSpy:URLSession {
        var receivedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            receivedUrls.append(url)
            return URLSPYSessionDataTask()
        }
    }
    
    private class URLSPYSessionDataTask: URLSessionDataTask {}
}

