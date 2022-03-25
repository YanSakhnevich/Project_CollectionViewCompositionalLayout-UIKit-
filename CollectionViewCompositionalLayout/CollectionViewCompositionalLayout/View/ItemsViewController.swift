import UIKit
import SnapKit

class ItemsViewController: UIViewController {
    
    private let viewModel: ItemsViewControllerViewModel
    private let spinnerView = UIActivityIndicatorView(style: .large)
    private lazy var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<String, Item>?
    
    init(viewModel: ItemsViewControllerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupViewModel()
        setupDataSource()
        viewModel.send(.viewDidLoad)
    }
    
    // MARK: - Setup ViewModel
    private func setupViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .initial:
                self.hideContent()
                self.spinnerView.startAnimating()
                
            case .loading:
                self.hideContent()
                self.spinnerView.startAnimating()
                
            case .loaded:
                self.spinnerView.stopAnimating()
                self.showContent()
                self.reloadData()
                
            case let .error(error):
                print(error)
            }
        }
    }
    
    private func hideContent() {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.alpha = 0
        }
    }
    
    private func showContent() {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.alpha = 1
        }
    }
    
    // MARK: - Setup CollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .rgbColor(red: 238, green: 238, blue: 238)
        view.addSubview(collectionView)
        collectionView.register(
            ItemCell.self,
            forCellWithReuseIdentifier: ItemCell.reuseIdentifier
        )
        collectionView.register(
            SectionHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier
        )
        reloadData()
    }
    
    // MARK: - Setup view
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(spinnerView)
        
        spinnerView.snp.makeConstraints { spiner in
            spiner.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            spiner.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
        }
    }
    
    // MARK: - Setup Layout
    private func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let sections = self.viewModel.resultsArray
            
            return self.layoutDetails(for: sections[sectionIndex])
        }
        return layout
    }
    
    // MARK: - Layout details
    private func layoutDetails(for: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.5),
                                              heightDimension: .fractionalHeight(2))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets.init(
            top: 0,
            leading: 8,
            bottom: 0,
            trailing: 8
        )
        let layoutGroupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(120),
            heightDimension: .estimated(105)
        )
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: layoutGroupSize,
            subitems: [layoutItem]
        )
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        layoutSection.contentInsets = NSDirectionalEdgeInsets.init(
            top: 10,
            leading: 10,
            bottom: 20,
            trailing: 12
        )
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(20)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        layoutSection.boundarySupplementaryItems = [sectionHeader]
        return layoutSection
    }
    
    // MARK: - Manage the data in CollectionView
    private func setupDataSource(){
        dataSource = UICollectionViewDiffableDataSource<String, Item>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, movie) -> UICollectionViewCell? in
            
            let sections = self.viewModel.resultsArray
            
            guard indexPath.section <= sections.count else {
                fatalError("Wrong number of sections")
            }
            
            guard indexPath.row <= sections[indexPath.section].items.count else {
                fatalError("Wrong number of items")
            }
            
            let item = sections[indexPath.section].items[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ItemCell.reuseIdentifier,
                for: indexPath) as? ItemCell
            if let imageURL = URL(string: item.image.the2X) {
                cell?.configureCell(title: item.title, imageURL: imageURL)
            }
            return cell
            
        })
        
        dataSource?.supplementaryViewProvider = {
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
                for: indexPath) as? SectionHeaderReusableView else { fatalError("Cannot create header view") }
            
            let sections = self.viewModel.resultsArray
            
            supplementaryView.titleLabel.text = sections[indexPath.section].header
            
            return supplementaryView
        }
    }
    
    // MARK: - Snapshot generating
    private func generateSnapshot() -> NSDiffableDataSourceSnapshot<String, Item> {
        
        var snapshot = NSDiffableDataSourceSnapshot<String, Item>()
        let sections = viewModel.resultsArray
        
        for section in sections {
            snapshot.appendSections([section.id])
            snapshot.appendItems(section.items, toSection: section.id)
        }
        
        return snapshot
    }
    
    private func reloadData() {
        dataSource?.apply(generateSnapshot(), animatingDifferences: false)
    }
}
