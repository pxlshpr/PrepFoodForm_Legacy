import SwiftUI
import MFPScraper

extension MFPSearch {
    class ViewModel: ObservableObject {

        @Published var searchText = ""
        @Published var items = [MFPSearchResultFood]()
        @Published var isLoadingPage = false
        private var currentPage = 1
        private var canLoadMorePages = true
        
        var task: Task<(), Error>? = nil
        
        init(searchText: String = "Banana") {
            self.searchText = searchText
        }
    }
}

extension MFPSearch.ViewModel {
    func startSearching() {
        currentPage = 1
        items = []
        startLoadContentTask()
    }
    
    var loadContentTask: Task<(), Error> {
        Task(priority: .userInitiated) {
            let foods = try await MFPScraper().getFoods(for: searchText, page: currentPage)
            try Task.checkCancellation()
            
            print("Got back: \(foods.count) foods")
            
            await MainActor.run {
                self.items = self.items + foods
                self.isLoadingPage = false
                self.currentPage += 1
            }
        }
    }
    private func startLoadContentTask() {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        isLoadingPage = true
        
        task = loadContentTask
        
        Task {
            let _ = try await task!.value
        }
    }

    func loadMoreContentIfNeeded(currentItem item: MFPSearchResultFood?) {
        guard let item = item else {
            startLoadContentTask()
            return
        }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.hashValue == item.hashValue }) == thresholdIndex {
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
