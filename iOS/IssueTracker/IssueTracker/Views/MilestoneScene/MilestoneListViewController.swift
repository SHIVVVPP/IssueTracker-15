//
//  MilestoneListViewController.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/10/29.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import Combine
import UIKit

class MilestoneListViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    private var dataSource = MilestoneListDataSource()
    var milestoneListViewModel: MilestoneListViewModelTypes?

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        bindViewModel()
        milestoneListViewModel?.inputs.viewDidLoad()
    }

    private func bindViewModel() {
        guard let viewModel = milestoneListViewModel else { return }

        viewModel.outputs.milestonePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { milestones in
                self.dataSource.load(milestones: milestones)
                self.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }

    private func configureCollectionView() {
        setupCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.registerCell(type: MilestoneCellView.self)
    }

    private func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: view.bounds.width, height: view.bounds.height / 8)
        layout.minimumLineSpacing = 1
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

// MARK: - Action

extension MilestoneListViewController {
    @IBAction func plusButtonTapped(_: Any) {
        showSubmitFormView(type: .add)
    }

    private func showSubmitFormView(type: MilestoneSubmitFieldsView.SubmitFieldType) {
        guard let milestoneSubmitFieldsView = MilestoneSubmitFieldsView.createView(),
              let formView = SubmitFormViewController.createViewController(with: milestoneSubmitFieldsView)
        else { return }

        switch type {
        case .add:
            milestoneSubmitFieldsView.onSaveButtonTapped = milestoneListViewModel?.inputs.addNewMileStone
        case let .edit(indexPath):
            milestoneSubmitFieldsView.configure(milestoneItemViewModel: dataSource.datas[indexPath.row])
            milestoneSubmitFieldsView.onSaveButtonTapped = { title, dueDate, desc in
                self.milestoneListViewModel?.inputs.editMileStone(at: indexPath, title: title, description: desc, dueDate: dueDate)
            }
        }

        present(formView, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate Implementation

extension MilestoneListViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSubmitFormView(type: .edit(indexPath))
    }
}
