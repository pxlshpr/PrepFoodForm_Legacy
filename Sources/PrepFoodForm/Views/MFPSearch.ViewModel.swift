import SwiftUI
import MFPScraper

extension MFPSearch {
    class ViewModel: ObservableObject {

        @Published var searchText = ""
        @Published var results: [MFPSearchResultFood] = []
        @Published var latestResults: [MFPSearchResultFood] = [] {
            didSet {
                Task(priority: .low) {
                    fetchFoodsTask = try await fetchFoods(results)
                }
            }
        }
        @Published var foods: [String: MFPProcessedFood] = [:]

        @Published var path: [Route] = []
        
        @Published var isLoadingPage = false
        private var currentPage = 1
        private var canLoadMorePages = true
        
        var searchTask: Task<(), Error>? = nil
        var fetchFoodsTask: Task<Void, Error>? = nil

        init(searchText: String = "Kelloggs Chocos") {
            self.searchText = searchText
        }
    }
}

extension MFPSearch.ViewModel {
    func startSearching() {
        currentPage = 1
        results = []
        startLoadContentTask()
    }
    
    func cancelSearching() {
        searchTask?.cancel()
    }
    
    var loadContentTask: Task<(), Error> {
        Task(priority: .high) {
            do {
                print("⬆️ Sending request for page \(currentPage) of \(searchText)")
                let results = try await MFPScraper().getFoods(for: searchText, page: currentPage)
                try Task.checkCancellation()
                
                print("⬇️ Got back: \(results.count) foods")

                self.currentPage += 1
                
                await MainActor.run {
                    self.latestResults = results
                    self.results = self.results + results
                    self.isLoadingPage = false
                }
                
                //TODO: NEXT - Including this task blocks the next page's load until all tasks have been downloaded.
                // - Find out why
                // - Possibly spawn this task elsewhere and keep queuing up new tasks as new pages are loaded
                
            } catch {
                fetchFoodsTask?.cancel()
            }
        }
    }
    
    func fetchFoods(_ results: [MFPSearchResultFood]) async throws -> Task<Void, Error> {
        Task(priority: .low) {
            try Task.checkCancellation()
            await withThrowingTaskGroup(of: Void.self) { group in
                for result in results {
                    let _ = group.addTaskUnlessCancelled {
                        try Task.checkCancellation()
                        let food = try await MFPScraper().getFood(for: FoodIdentifier(result.url))
                        try Task.checkCancellation()
                        await MainActor.run {
                            print("Got food: \(food.name)")
                            self.foods[result.url] = food
                        }
                    }
                }
            }
        }
    }
    
    func food(for result: MFPSearchResultFood) -> MFPProcessedFood? {
        foods[result.url]
    }
    
    private func startLoadContentTask() {
        
        /// Cancel previous `searchTask`
        searchTask?.cancel()
        
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
        
        searchTask = loadContentTask
        
        Task(priority: .high) {
            do {
                let _ = try await searchTask!.value
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func loadMoreContentIfNeeded(currentResult result: MFPSearchResultFood?) {
        guard let result = result else {
            startLoadContentTask()
            return
        }
        
        let thresholdIndex = results.index(results.endIndex, offsetBy: -5)
        if results.firstIndex(where: { $0.hashValue == result.hashValue }) == thresholdIndex {
            startLoadContentTask()
        }
    }
    

    //    private func loadMoreContent() {
    //        guard !isLoadingPage && canLoadMorePages else {
    //            return
    //        }
    //
    //        isLoadingPage = true
    //
    //        let url = URL(string: "https://s3.eu-west-2.amazonaws.com/com.donnywals.misc/feed-\(currentPage).json")!
    //        URLSession.shared.dataTaskPublisher(for: url)
    //            .map(\.data)
    //            .decode(type: ListResponse.self, decoder: JSONDecoder())
    //            .receive(on: DispatchQueue.main)
    //            .handleEvents(receiveOutput: { response in
    //                self.canLoadMorePages = response.hasMorePages
    //                self.isLoadingPage = false
    //                self.currentPage += 1
    //            })
    //            .map({ response in
    //                return self.items + response.items
    //            })
    //            .catch({ _ in Just(self.items) })
    //                .assign(to: $items)
    //    }
}
