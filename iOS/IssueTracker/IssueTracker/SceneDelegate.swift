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

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            let code = url.absoluteString.components(separatedBy: "code=").last ?? ""
            UserProvider.shared.requestAccessToken(code: code, completion: { result in
                guard let window = self.window else { return }
                switch result {
                case .success:
                    UIView.transition(with: window, duration: 1, options: .transitionFlipFromTop, animations: {
                        window.rootViewController = MainTabBarController.createViewController()
                        window.makeKeyAndVisible()
                    }, completion: nil)
                case .failure:
                    return
                }
            })
        }
    }

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }

        let rootViewController: UIViewController?
        if
            let data = UserDefaults.standard.object(forKey: "AccessToken") as? Data,
            let accessToken = JSONDecoder.decode(TokenResponse.self, from: data)
        {
            UserProvider.shared.currentUser = accessToken.user
            UserProvider.shared.token = accessToken.accessToken
            rootViewController = MainTabBarController.createViewController()
        } else {
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
