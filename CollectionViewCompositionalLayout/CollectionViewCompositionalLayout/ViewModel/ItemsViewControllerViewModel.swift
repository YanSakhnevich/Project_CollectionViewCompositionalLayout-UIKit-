import UIKit

final class ItemsViewControllerViewModel {
    
    var onStateChanged: ((State) -> Void)?
    
    private(set) var state: State = .initial {
        didSet {
            onStateChanged?(state)
        }
    }
    
    func send(_ action: Action) {
        switch action {
        case .viewDidLoad:
            state = .loading
            fetchData()
        }
    }
    
    lazy var resultsArray = [Section]()
    private let responseSearch: ServiceProtocol = NetworkDataFetcher()
    
    private func fetchData() {
        let urlString = Constants.urlForCollectionViewData
        
        responseSearch.fetchData(urlString: urlString) { [weak self] section in
            guard let sectionsArray = section else { return }
            self?.resultsArray = sectionsArray
            
            DispatchQueue.main.async {
                self?.state = .loaded
            }
        }
    }
}

// MARK: - Actions/State for View/ViewModel
extension ItemsViewControllerViewModel {
    
    enum Action {
        case viewDidLoad
    }
    
    enum State {
        case initial
        case loading
        case loaded
        case error(String)
    }
}
