//
//  ViewController.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/10/26.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import UIKit
import Combine

class LabelListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var labelListViewModel: LabelListViewModelType?
    private var dataSource = LabelListDataSource()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        bindViewModel()
        labelListViewModel?.inputs.viewDidLoad()
    }
    
    private func bindViewModel() {
        guard let viewModel = labelListViewModel?.outputs
        else { return }
        
        viewModel.labelPublisher
            .receive(on: RunLoop.main)
            .sink { labels in
                self.dataSource.load(labels: labels)
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func configureCollectionView() {
        setupCollectionViewLayout()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.registerCell(type: LabelCellView.self)
    }
    
    private func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height / 10)
        layout.minimumLineSpacing = 1
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
}

// MARK: - Action

extension LabelListViewController {
    
    @IBAction func plusButtonTapped(_ sender: Any) {
        showSubmitFormView(type: .add)
    }
    
    private func showSubmitFormView(type: LabelSubmitFieldsView.SubmitFieldType) {
        guard let labelSubmitFieldsView = LabelSubmitFieldsView.createView(),
            let formView = SubmitFormViewController.createViewController(with: labelSubmitFieldsView)
            else { return }
        
        switch type {
        case .add:
            labelSubmitFieldsView.onSaveButtonTapped = labelListViewModel?.inputs.addNewLabel
        case .edit(let indexPath):
            labelSubmitFieldsView.configure(labelViewModel: dataSource.datas[indexPath.row])
            labelSubmitFieldsView.onSaveButtonTapped = { (title, desc, colorCode) in
                self.labelListViewModel?.inputs.editLabel(at: indexPath, title: title, desc: desc, hexColor: colorCode)
            }
        }
        present(formView, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate Implementation

extension LabelListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSubmitFormView(type: .edit(indexPath))
    }
    
}
