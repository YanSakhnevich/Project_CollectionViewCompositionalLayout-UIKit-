import UIKit

final class ItemsViewControllerCoordinator: Coordinator {

    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = ItemsViewControllerViewModel()
        let viewController = ItemsViewController(viewModel: viewModel)
        
        navigationController?.setViewControllers([viewController], animated: false)
    }
}

