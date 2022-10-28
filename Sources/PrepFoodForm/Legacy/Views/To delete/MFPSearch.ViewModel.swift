//import SwiftUI
//import MFPScraper
//import SwiftHaptics
//import SwiftSugar
//
//extension MFPSearch.ViewModel {
//    
//    func updateLoadingStatus() {
//        if case .failed = loadingStatus {
//            Haptics.errorFeedback()
//            loadingFailed = true
//        } else {
//            Haptics.warningFeedback()
//            loadingFailed = false
//        }
//        if case .firstAttempt = loadingStatus {
//            isFirstAttempt = true
//        } else {
//            isFirstAttempt = false
//        }
//        
//        errorMessage = loadingStatus.errorMessage
//        retryMessage = loadingStatus.retryMessage
//    }
//    
//    func startSearching() {
//        
//        isFirstAttempt = true
//        loadingFailed = false
//        loadingStatus = .firstAttempt
//        retryMessage = nil
//        errorMessage = nil
//        
//        currentPage = 1
//        results = []
//        
//        /// Cancel previous `searchTask`
//        searchTask?.cancel()
//        isLoadingPage = false
//        
//        startLoadContentTask()
////        simulateLoadingTask()
//    }
//    
//    func cancelSearching() {
//        fetchFoodsTask?.cancel()
//        searchTask?.cancel()
//        self.isLoadingPage = false
//    }
//    
//    var loadContentTask: Task<(), Error> {
//        Task(priority: .medium) {
//            do {
//                print("⬆️ Sending request for page \(currentPage) of \(searchText)")
//                let results = try await MFPScraper().getFoods(for: searchText, page: currentPage)
//                try Task.checkCancellation()
//                
//                print("⬇️ Got back: \(results.count) foods")
//
//                self.currentPage += 1
//                
//                await MainActor.run {
//                    self.latestResults = results
//                    self.results = self.results + results
//                    self.isLoadingPage = false
//                }
//                
//                //TODO: NEXT - Including this task blocks the next page's load until all tasks have been downloaded.
//                // - Find out why
//                // - Possibly spawn this task elsewhere and keep queuing up new tasks as new pages are loaded
//                
//            } catch {
//                print("🛑 Page Fetch Task was cancelled!")
//            }
//        }
//    }
//    
//    func fetchFoods(_ results: [MFPSearchResultFood]) async throws -> Task<Void, Error> {
//        Task(priority: .low) {
//            do {
//                try Task.checkCancellation()
//                await withThrowingTaskGroup(of: Void.self) { group in
//                    for result in results {
//                        let _ = group.addTaskUnlessCancelled {
//                            try Task.checkCancellation()
//                            let food = try await MFPScraper().getFood(for: FoodIdentifier(result.url))
//                            try Task.checkCancellation()
//                            await MainActor.run {
//                                print("Got food: \(food.name)")
//                                self.foods[result.url] = food
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print("🛑 Foods Fetch Task was cancelled!")
//            }
//        }
//    }
//    
//    func food(for result: MFPSearchResultFood) -> MFPProcessedFood? {
//        foods[result.url]
//    }
//    
//    func simulateLoadingTask() {
//        isLoadingPage = true
//        Task {
//            try await sleepTask(2)
//            await MainActor.run {
//                loadingStatus = .retry(attemptNumber: 1, maxAttempts: 3, reason: .timeout)
//            }
//            try await sleepTask(2)
//            await MainActor.run {
//                loadingStatus = .retry(attemptNumber: 2, maxAttempts: 3, reason: .timeout)
//            }
//            try await sleepTask(2)
//            await MainActor.run {
//                loadingStatus = .retry(attemptNumber: 3, maxAttempts: 3, reason: .timeout)
//            }
//            try await sleepTask(2)
//            await MainActor.run {
//                loadingStatus = .failed(reason: .timeout)
//            }
//        }
//    }
//    
//    private func startLoadContentTask() {
//        
//        guard !isLoadingPage && canLoadMorePages else {
//            return
//        }
//        
//        isLoadingPage = true
//        
//        searchTask = loadContentTask
//        
//        Task(priority: .medium) {
//            do {
//                let _ = try await searchTask!.value
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//    
//    func loadNextPage() {
//        startLoadContentTask()
//    }
//
//    func loadMoreContentIfNeeded(currentResult result: MFPSearchResultFood?) {
//        guard currentPage <= maximumNumberOfAutoloadingPages else {
//            return
//        }
//        
//        guard let result = result else {
//            startLoadContentTask()
//            return
//        }
//        
//        let thresholdIndex = results.index(results.endIndex, offsetBy: -5)
//        if results.firstIndex(where: { $0.hashValue == result.hashValue }) == thresholdIndex {
//            startLoadContentTask()
//        }
//    }
//    
//
//    //    private func loadMoreContent() {
//    //        guard !isLoadingPage && canLoadMorePages else {
//    //            return
//    //        }
//    //
//    //        isLoadingPage = true
//    //
//    //        let url = URL(string: "https://s3.eu-west-2.amazonaws.com/com.donnywals.misc/feed-\(currentPage).json")!
//    //        URLSession.shared.dataTaskPublisher(for: url)
//    //            .map(\.data)
//    //            .decode(type: ListResponse.self, decoder: JSONDecoder())
//    //            .receive(on: DispatchQueue.main)
//    //            .handleEvents(receiveScanResult: { response in
//    //                self.canLoadMorePages = response.hasMorePages
//    //                self.isLoadingPage = false
//    //                self.currentPage += 1
//    //            })
//    //            .map({ response in
//    //                return self.items + response.items
//    //            })
//    //            .catch({ _ in Just(self.items) })
//    //                .assign(to: $items)
//    //    }
//}
