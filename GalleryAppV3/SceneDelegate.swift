//
//  SceneDelegate.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let container = DependencyContainer()
        let rootVC: UIViewController
        if let gallery = container.makeGalleryViewController() as? ViewController {
            gallery.openFavorites = { store in container.makeFavoritesViewController(favoritesStore: store) }
            rootVC = gallery
        } else {
            rootVC = makeConfigErrorViewController()
        }
        let navigation = UINavigationController(rootViewController: rootVC)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
    }

    private func makeConfigErrorViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = NSLocalizedString("alert.error_title", comment: "")
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("config.missing_key", comment: "")
        label.numberOfLines = 0
        label.textAlignment = .center
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }
}

