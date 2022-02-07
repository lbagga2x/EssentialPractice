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

struct UnexpectedError: Error {}
class URLSessionHttpClent {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedError()))
            }
            
            
        }.resume()
    }
}

class URLSessionHttpClientTest: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        UrlProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        UrlProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromUrl_PerformGetRequestWithUrl() {
        let url = anyUrl()
        
        let exp = expectation(description: "Wait for completion")
        
        UrlProtocolStub.requestOberver = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSut().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let requestError = NSError(domain: "Any Error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
    }
    
    func test_getFromAllUrl_failsOnAllNilValue() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_getFromURL_successOnHttpResponseWithData() {
        
        let data = Data(bytes: "anyData".utf8)
        let response = HTTPURLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
        UrlProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "Wait for completion")
        makeSut().get(from: anyUrl()) { result in
            switch result {
            case .success(let receivedData, let receivedResponse):
                XCTAssertEqual(data, receivedData)
                XCTAssertEqual(response.url, receivedResponse.url)
            default:
                XCTFail("Thus shouldn't fail. Needed result")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    /// Mark :  Helper
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        UrlProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        makeSut(file: file, line: line).get(from: anyUrl()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("This shouldn't fail", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func makeSut(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClent {
        let client = URLSessionHttpClent()
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
    func anyUrl() -> URL {
        return URL(string: "https://www.yahoo.com")!
    }
    
    private class UrlProtocolStub: URLProtocol {
        static var stub: Stub?
        static var requestOberver: ((URLRequest) -> Void)?
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func obersverRequest(requestOberver: @escaping ((URLRequest) -> Void)) {
            self.requestOberver = requestOberver
        }
        
        static func startInterceptingRequest() {
            UrlProtocolStub.registerClass(UrlProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            UrlProtocolStub.unregisterClass(UrlProtocolStub.self)
            stub = nil
            requestOberver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestOberver?(request)
            return request
        }
        
        override func startLoading() {
            guard let stub = UrlProtocolStub.stub else {
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
