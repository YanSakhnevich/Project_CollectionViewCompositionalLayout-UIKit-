import Foundation

protocol ServiceProtocol {
    func fetchData(urlString: String, response: @escaping ([Section]?) -> Void)
}

class NetworkDataFetcher: ServiceProtocol {
    
    private func request(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
        }.resume()
    }
    
    func fetchData(urlString: String, response: @escaping ([Section]?) -> Void) {
        DispatchQueue.global().async {
            self.request(urlString: urlString) { (result) in
                switch result {
                case .success(let data):
                    do {
                        var resultsArray = [Section]()
                        let data = try JSONDecoder().decode(DataFromServer.self, from: data)
                        resultsArray = data.sections
                        response(resultsArray)
                    } catch let jsonError {
                        print("Failed to decode JSON", jsonError)
                        response(nil)
                    }
                case .failure(let error):
                    print("Error received requesting data: \(error.localizedDescription)")
                    response(nil)
                }
            }
        }
    }
}
