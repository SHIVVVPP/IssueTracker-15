//
//  SceneDelegate.swift
//  IssueTracker
//
//  Created by sihyung you on 2020/10/26.
//  Copyright © 2020 IssueTracker-15. All rights reserved.
//

import NetworkFramework
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    var dataLoader: DataLoader?
    var userProvider: UserProvidable?

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
            userProvider?.requestAccessToken(code: code, completion: { result in
                guard let window = self.window,
                      let dataLodaer = self.dataLoader,
                      let userProvider = self.userProvider
                else { return }
                switch result {
                case .success:
                    UIView.transition(with: window, duration: 1, options: .transitionFlipFromTop, animations: {
                        window.rootViewController = MainTabBarController.createViewController(dataLoader: dataLodaer, userProvider: userProvider)
                        window.makeKeyAndVisible()
                    }, completion: nil)
                case .failure:
                    return
                }
            })
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }

        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        dataLoader = DataLoader(session: session)

        let rootViewController: UIViewController?
        if
            let data = UserDefaults.standard.object(forKey: "AccessToken") as? Data,
            let accessToken = JSONDecoder.decode(TokenResponse.self, from: data)
        {
            userProvider = UserProvider(dataLoader: dataLoader!, tokenData: accessToken)
            rootViewController = MainTabBarController.createViewController(dataLoader: dataLoader!, userProvider: userProvider!)
        } else {
            userProvider = UserProvider(dataLoader: dataLoader!)
            rootViewController = LoginViewController.createViewController()
        }

        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
