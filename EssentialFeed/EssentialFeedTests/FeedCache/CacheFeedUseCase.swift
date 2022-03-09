//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Lalit Bagga on 2022-03-09.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ item: [FeedItem]) {
        store.deleteCacheFeed()
    }
}

class FeedStore {
    var deletecCacheCount = 0
    
    func deleteCacheFeed() {
        deletecCacheCount += 1
    }
}

class CacheFeedUseCase: XCTestCase {
    
    func test_init_DoesnotDeleteCacheUpon() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletecCacheCount, 0)
    }
    
    func test_save_requestCacheDeleteion() {
        let store = FeedStore()
        let loader = LocalFeedLoader(store: store)
        loader.save([getUniqueItem(), getUniqueItem()])
        
        
        XCTAssertEqual(store.deletecCacheCount, 1)
    }
    
    private func getUniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: "", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "www.yahoo.com")!
    }
}
