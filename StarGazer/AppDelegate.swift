//
//  AppDelegate.swift
//  StarGazer
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        let config = UISceneConfiguration(name: "Application Window", sessionRole: .windowApplication)
        config.sceneClass = UIWindowScene.self
        config.delegateClass = SceneDelegate.self

        return config
    }


}



class SceneDelegate: NSObject, UISceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions)
    {
        if let wscene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: wscene)
            HMEService.windowScene = wscene
            window.rootViewController = HMEViewController()
            window.makeKeyAndVisible()

            self.window = window
        }
    }

    private var window: UIWindow?
}
