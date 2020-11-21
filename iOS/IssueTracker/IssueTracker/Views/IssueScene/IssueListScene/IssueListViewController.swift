//
//  IssueListViewController.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/01.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//
import Combine
import UIKit

class IssueListViewController: UIViewController {
    enum Section {
        case issues
    }

    typealias DataSource = UICollectionViewDiffableDataSource<Section, IssueItemViewModel>
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, IssueItemViewModel>

    enum ViewingMode {
        case general
        case edit
    }

    @IBOutlet var rightNavButton: UIBarButtonItem!
    @IBOutlet var leftNavButton: UIBarButtonItem!
    @IBOutlet var floatingButton: UIButton!

    @IBOutlet var collectionView: UICollectionView!
    private lazy var dataSource = makeDataSource()

    lazy var floatingButtonAspectRatioConstraint: NSLayoutConstraint = {
        self.floatingButton.widthAnchor.constraint(equalTo: self.floatingButton.heightAnchor)
    }()

    private var viewingMode: ViewingMode = .general

    var issueListViewModel: IssueListViewModelTypes?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureCollectionView()
        bindViewModel()

        floatingButtonAspectRatioConstraint.isActive = true
    }

    private func bindViewModel() {
        guard let viewModel = issueListViewModel else { return }

        viewModel.outputs.issuePublisher
            .receive(on: DispatchQueue.main)
            .sink { issueViewModels in
                var snapShot = SnapShot()
                snapShot.appendSections([.issues])
                snapShot.appendItems(issueViewModels, toSection: .issues)
                self.dataSource.apply(snapShot, animatingDifferences: true)
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &cancellables)

        viewModel.outputs.checkedNumPublisher
            .receive(on: DispatchQueue.main)
            .sink { numChecked in
                guard self.viewingMode == .edit else { return }
                self.title = "\(numChecked) 개 선택"
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .automatic
        collectionView.visibleCells.forEach {
            guard let cell = $0 as? IssueCellView else { return }
            cell.resetScrollOffset()
        }
        issueListViewModel?.inputs.needFetchItems()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.layer.cornerRadius = floatingButton.bounds.height / 2 * 1
    }

    private func configureSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    private func configureCollectionView() {
        setupCollectionViewLayout()
        collectionView.registerCell(type: IssueCellView.self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectCell(_:)))
        collectionView.addGestureRecognizer(tap)
    }

    private func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        let cellHeight = view.bounds.height / 10
        layout.estimatedItemSize = CGSize(width: view.bounds.width, height: cellHeight)
        layout.minimumLineSpacing = 3
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView,
                                    cellProvider: { (collectionView, indexPath, issueItem) -> UICollectionViewCell? in
                                        guard let cell: IssueCellView = collectionView.dequeueCell(at: indexPath) else { return nil }
                                        cell.configure(issueItemViewModel: issueItem)
                                        cell.showCheckBox(show: self.viewingMode == .edit, animation: false)
                                        cell.delegate = self
                                        return cell
                                    })
        return dataSource
    }
}

// MARK: - Actions

extension IssueListViewController {
    @objc func didSelectCell(_ sender: UITapGestureRecognizer) {
        guard let indexPath = collectionView?.indexPathForItem(at: sender.location(in: collectionView)) else { return }
        switch viewingMode {
        case .general:
            presentIssueDetailViewController(indexPath: indexPath)
        case .edit:
            issueListViewModel?.inputs.selectCell(at: indexPath)
        }
    }

    @IBAction func rightNavButtonTapped(_: Any) {
        switch viewingMode {
        case .general:
            toEditMode()
        case .edit:
            toGeneralMode()
        }
    }

    @IBAction func leftNavButtonTapped(_: Any) {
        switch viewingMode {
        case .general:
            presentFilterViewController()
        case .edit:
            issueListViewModel?.inputs.selectAllCells()
        }
    }

    @IBAction func floatingButtonTapped(_: Any) {
        switch viewingMode {
        case .edit:
            issueListViewModel?.inputs.closeSelectedIssue()
            toGeneralMode()
        case .general:
            AddNewIssueViewController.present(at: self, addType: .newIssue, previousData: nil, onDismiss: { [weak self] content in
                self?.issueListViewModel?.inputs.addNewIssue(title: content[0], description: content[1])
            })
        }
    }

    private func toEditMode() {
        viewingMode = .edit
        title = "0 개 선택"
        rightNavButton.title = "Cancel"
        leftNavButton.title = "Select All"
        changeButtonTo(mode: .edit)
        collectionView.visibleCells.forEach {
            guard let cell = $0 as? IssueCellView else { return }
            cell.showCheckBox(show: true, animation: true)
        }
    }

    private func toGeneralMode() {
        viewingMode = .general
        title = "이슈"
        rightNavButton.title = "Edit"
        leftNavButton.title = "Filter"
        changeButtonTo(mode: .general)
        issueListViewModel?.inputs.clearSelectedCells()
        collectionView.visibleCells.forEach {
            guard let cell = $0 as? IssueCellView else { return }
            cell.showCheckBox(show: false, animation: true)
        }
    }

    private func changeButtonTo(mode: ViewingMode) {
        switch mode {
        case .edit:
            floatingButtonAspectRatioConstraint.isActive = false
            floatingButton.setTitle("선택 이슈 닫기", for: .normal)
            floatingButton.layoutSubviews()
            floatingButton.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
            floatingButton.backgroundColor = .red
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.floatingButton.contentEdgeInsets.left = 10
                self.floatingButton.contentEdgeInsets.right = 10
                self.floatingButton.imageEdgeInsets.left = -5
            }
        case .general:
            floatingButtonAspectRatioConstraint.isActive = true
            floatingButton.setTitle("", for: .normal)
            floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
            floatingButton.backgroundColor = UIColor(displayP3Red: 72 / 255, green: 133 / 255, blue: 195 / 255, alpha: 1)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.floatingButton.contentEdgeInsets.right = 0
                self.floatingButton.contentEdgeInsets.left = 0
                self.floatingButton.imageEdgeInsets.left = 0
            }
        }
    }
}

// MARK: - Present

extension IssueListViewController {
    private func presentFilterViewController() {
        guard viewingMode == .general,
              var issueListViewModel = issueListViewModel
        else { return }
        let onDismiss = { (generalCondition: [Bool], detailCondition: [Int]) in
            issueListViewModel.filter = IssueFilter(generalCondition: generalCondition, detailCondition: detailCondition)
            self.collectionView.scrollsToTop = true
        }
        IssueFilterViewController.present(at: self, filterViewModel: issueListViewModel.outputs.createFilterViewModel(), onDismiss: onDismiss)
    }

    private func presentIssueDetailViewController(indexPath: IndexPath) {
        guard let issueListViewModel = issueListViewModel,
              let issueDetailViewModel = issueListViewModel.outputs.createIssueDetailViewModel(path: indexPath)
        else { return }
        let issueDetailVC = IssueDetailViewController.createViewController(issueDetailViewModel: issueDetailViewModel)
        navigationController?.pushViewController(issueDetailVC, animated: true)
    }
}

// MARK: - IssucCellViewDelegate Implementation

extension IssueListViewController: IssucCellViewDelegate {
    func closeIssueButtonTapped(_: IssueCellView, at id: Int) {
        issueListViewModel?.inputs.closeIssue(of: id)
    }

    func deleteIssueButtonTapped(_: IssueCellView, at id: Int) {
        issueListViewModel?.inputs.deleteIssue(of: id)
    }

    func issueCellViewBeginDragging(_ issueCellView: IssueCellView, at _: Int) {
        collectionView.visibleCells.forEach {
            guard let cell = $0 as? IssueCellView, cell != issueCellView else { return }
            UIView.animate(withDuration: 0.5) {
                cell.cellHorizontalScrollView.contentOffset = CGPoint.zero
            }
        }
    }
}

// MARK: - UISearchController Implementation

extension IssueListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        issueListViewModel?.inputs.onSearch(text: searchController.searchBar.searchTextField.text)
    }
}
