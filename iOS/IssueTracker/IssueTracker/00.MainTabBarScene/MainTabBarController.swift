//
//  MainTabBarController.swift
//  IssueTracker
//
//  Created by 김신우 on 2020/10/29.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import NetworkFramework
import UIKit

class MainTabBarController: UITabBarController {
    func setupSubViewControllers() {
        let commonAppearance = UINavigationBarAppearance()
        commonAppearance.backgroundColor = .white
        commonAppearance.shadowColor = .gray

        // controllers[0] = UINavigationController -> root: IssueListViewController
        if
            let navigationController = viewControllers?[safe: 0] as? UINavigationController,
            let issueListViewController = navigationController.topViewController as? IssueListViewController
        {
            navigationController.navigationBar.scrollEdgeAppearance = commonAppearance

            let issueListViewModel = IssueListViewModel()
            issueListViewController.issueListViewModel = issueListViewModel
        }
        // controllers[1] = LabelListViewController
        if
            let navigationController = viewControllers?[safe: 1] as? UINavigationController,
            let labelListViewController = navigationController.topViewController as? LabelListViewController
        {
            navigationController.navigationBar.scrollEdgeAppearance = commonAppearance

            labelListViewController.labelListViewModel = LabelListViewModel()
        }
        // controllers[2] = MilestoneListViewConroller
        if
            let navigationController = viewControllers?[safe: 2] as? UINavigationController,
            let milestoneListViewController = navigationController.topViewController as? MilestoneListViewController
        {
            navigationController.navigationBar.scrollEdgeAppearance = commonAppearance
            milestoneListViewController.milestoneListViewModel = MilestoneListViewModel()
        }
        // controllers[3] = SettingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainTabBarController {
    static let storyBoardName = "Main"

    static func createViewController() -> UIViewController? {
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: Bundle.main)
        let mainTabBarController = storyBoard.instantiateInitialViewController() as? MainTabBarController
        mainTabBarController?.setupSubViewControllers()
        return mainTabBarController
    }
}
