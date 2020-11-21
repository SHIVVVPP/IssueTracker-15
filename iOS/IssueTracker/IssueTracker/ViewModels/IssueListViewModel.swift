//
//  IssueListViewModel.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/11/04.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//
import Foundation

enum SelectionMode {
    case opened
    case closed
}

protocol IssueListViewModelTypes {
    var inputs: IssueListViewModelInputs { get }
    var outputs: IssueListViewModelOutputs { get }

    // TODO: filter 처리
    var filter: IssueFilterable? { get set }
}

protocol IssueListViewModelInputs {
    // For Events
    func needFetchItems()

    func selectCell(at path: IndexPath)
    func clearSelectedCells()
    func selectAllCells()

    func closeIssue(of id: Int)
    func closeSelectedIssue()
    func deleteIssue(of id: Int)

    func addNewIssue(title: String, description: String)

    // For Search
    func onSearch(text: String?)
}

protocol IssueListViewModelOutputs {
    var checkedNumPublisher: Published<Int>.Publisher { get }
    var issuePublisher: Published<[IssueItemViewModel]>.Publisher { get }

    func createFilterViewModel() -> IssueFilterViewModelProtocol?
    func createIssueDetailViewModel(path: IndexPath) -> IssueDetailViewModel?
}

protocol IssueListViewModelProtocol: AnyObject {
    // For Presentation
    var didItemChanged: (([IssueItemViewModel]) -> Void)? { get set }
    var didCellChecked: ((IndexPath, Bool) -> Void)? { get set }
    var showTitleWithCheckNum: ((Int) -> Void)? { get set }
    var filter: IssueFilterable? { get set }
    var issues: [IssueItemViewModel] { get }

    // For Events
    func needFetchItems()

    func selectCell(at path: IndexPath)
    func clearSelectedCells()
    func selectAllCells()

    func closeIssue(of id: Int)
    func closeSelectedIssue()
    func deleteIssue(of id: Int)

    func addNewIssue(title: String, description: String)

    // For Search
    func onSearch(text: String?)

    // For SubViewModels
    func createFilterViewModel() -> IssueFilterViewModelProtocol?
    func createIssueDetailViewModel(path: IndexPath) -> IssueDetailViewModel?
}

class IssueListViewModel {
    private weak var labelProvider: LabelProvidable?
    private weak var milestoneProvider: MilestoneProvidable?
    private weak var issueProvider: IssueProvidable?

    @Published private(set) var issues = [IssueItemViewModel]()
    @Published private(set) var numChecked = 0
    var filter: IssueFilterable? {
        didSet {
            needFetchItems()
        }
    }

    init(
        labelProvider: LabelProvidable = LabelProvider.shared,
        milestoneProvider: MilestoneProvidable = MilestoneProvider.shared,
        issueProvider: IssueProvidable = IssueProvider.shared,
        issueFilter: IssueFilterable? = IssueFilter()
    ) {
        self.labelProvider = labelProvider
        self.milestoneProvider = milestoneProvider
        self.issueProvider = issueProvider
        filter = issueFilter
    }
}

// MARK: - IssueListViewModelInputs Implementation

extension IssueListViewModel: IssueListViewModelInputs {
    func needFetchItems() {
        requestFetchIssues()
    }

    func selectCell(at path: IndexPath) {
        issues[path.row].checked.toggle()
        numChecked = issues.filter { $0.checked }.count
    }

    func clearSelectedCells() {
        issues.forEach { $0.checked = false }
        numChecked = 0
    }

    func selectAllCells() {
        issues.forEach { $0.checked = true }
        numChecked = issues.count
    }

    func addNewIssue(title: String, description: String) {
        requestAddIssue(title: title, description: description)
    }

    func closeIssue(of id: Int) {
        guard let item = issues.first(where: { $0.id == id }) else { return }
        requestChangeIssueState(of: [item], open: !item.isOpened)
    }

    func closeSelectedIssue() {
        let issueItems = issues.filter { $0.checked }
        requestChangeIssueState(of: issueItems, open: false)
    }

    func deleteIssue(of id: Int) {
        requestDeleteIssue(of: id)
    }

    func onSearch(text: String?) {
        filterToSearch(text: text)
    }
}

// MARK: - IssueListViewModelOutputs Implementation

extension IssueListViewModel: IssueListViewModelOutputs {
    var checkedNumPublisher: Published<Int>.Publisher { $numChecked }
    var issuePublisher: Published<[IssueItemViewModel]>.Publisher { $issues }

    func createFilterViewModel() -> IssueFilterViewModelProtocol? {
        let generalConditions = filter?.generalConditions ?? [Bool](repeating: false, count: Condition.allCases.count)
        let detailConditions = filter?.detailConditions ?? [Int](repeating: -1, count: DetailSelectionType.allCases.count)
        let viewModel = IssueFilterViewModel(labelProvider: labelProvider,
                                             milestoneProvider: milestoneProvider,
                                             issueProvider: issueProvider,
                                             generalConditions: generalConditions,
                                             detailConditions: detailConditions)

        return viewModel
    }

    func createIssueDetailViewModel(path: IndexPath) -> IssueDetailViewModel? {
        let cellViewModel = issues[path.row]
        return IssueDetailViewModel(id: cellViewModel.id,
                                    issueProvider: issueProvider,
                                    labelProvier: labelProvider,
                                    milestoneProvider: milestoneProvider)
    }
}

// MARK: - IssueListViewModelTypes Implementation

extension IssueListViewModel: IssueListViewModelTypes {
    var inputs: IssueListViewModelInputs { self }
    var outputs: IssueListViewModelOutputs { self }
}

// MARK: - Private Functions

extension IssueListViewModel {
    private func requestFetchIssues() {
        let group = DispatchGroup()
        group.enter()

        var newIssues = [IssueItemViewModel]()

        issueProvider?.fetchIssues(with: filter, completion: { [weak self] issues in
            guard let `self` = self,
                  let issues = issues
            else { return }

            issues.forEach {
                let itemViewModel = IssueItemViewModel(issue: $0)
                newIssues.append(itemViewModel)
                self.requestFetchLabels(of: $0, to: itemViewModel, group: group)
                self.requestFetchMilestones(of: $0, to: itemViewModel, group: group)
            }

            group.leave()
        })

        group.notify(queue: .main) { [weak self] in
            guard let `self` = self else { return }
            self.issues.removeAll()
            self.issues = newIssues
        }
    }

    private func requestFetchLabels(of issue: Issue, to issueItem: IssueItemViewModel, group: DispatchGroup? = nil) {
        guard let provider = labelProvider else { return }

        group?.enter()
        provider.getLabels(of: issue.labels, completion: { [weak issueItem] labels in
            issueItem?.setLabels(labels: labels)
            group?.leave()
        })
    }

    private func requestFetchMilestones(of issue: Issue, to issueItem: IssueItemViewModel, group: DispatchGroup? = nil) {
        guard let milestoneID = issue.milestone,
              let provider = milestoneProvider
        else { return }
        group?.enter()

        provider.getMilestone(at: milestoneID, completion: { [weak issueItem] milestone in
            issueItem?.setMilestone(milestone: milestone)
            group?.leave()
        })
    }

    private func requestChangeIssueState(of issueItems: [IssueItemViewModel], open: Bool) {
        guard let provider = issueProvider else { return }
        let group = DispatchGroup()

        issueItems.forEach {
            group.enter()
            provider.changeIssueState(id: $0.id, open: open) { _ in
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.needFetchItems()
        }
    }

    private func requestDeleteIssue(of id: Int) {
        issueProvider?.deleteIssue(id: id, completion: { [weak self] _ in
            self?.needFetchItems()
        })
    }

    private func filterToSearch(text: String?) {
        filter?.searchText = (text ?? "").isEmpty ? nil : text!
        issueProvider?.fetchIssues(with: filter, completion: { [weak self] _ in
            self?.needFetchItems()
        })
    }

    private func requestAddIssue(title: String, description: String) {
        issueProvider?.addIssue(title: title, description: description, milestoneID: nil) { [weak self] createdIssue in
            guard createdIssue != nil else { return }
            self?.needFetchItems()
        }
    }
}

// MARK: - SubViewModels

extension IssueListViewModel {}
