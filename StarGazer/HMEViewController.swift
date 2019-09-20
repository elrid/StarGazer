//
//  HMEViewController.swift
//  StarGazer
//

import Foundation
import UIKit
import SceneKit
import ARKit

fileprivate func swizzleClassMethod(oldClass: AnyClass, old: Selector, newClass: AnyClass, new: Selector) {
    let oldMethod = class_getClassMethod(oldClass, old)!
    let newMethod = class_getClassMethod(newClass, new)!

    let classClass = object_getClass(oldClass)!

    if(class_addMethod(classClass, old, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(classClass, new, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod))
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

fileprivate func swizzleInstanceMethod(oldClass: AnyClass, old: Selector, newClass: AnyClass, new: Selector) {
    let oldMethod = class_getInstanceMethod(oldClass, old)!
    let newMethod = class_getInstanceMethod(newClass, new)!

    if(class_addMethod(oldClass, old, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(oldClass, new, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod))
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

fileprivate extension NSObject {
    @objc class func swizzledIsWornModeSupported() -> Bool { return true }
    @objc class func swizzledIsCompositorEnabled() -> Bool { return true }
    @objc class func swizzledSupportsStereoAR() -> Bool { return true }
    @objc class func swizzledCompositorPlistKeysEnabled() -> Bool { return true }
    @objc class func swizzledSupportsPresentationMode(_ mode: Int64) -> Bool { return true }
    @objc func swizzledInstanceSupportsPresentationMode(_ mode: Int64) -> Bool { return true }

    @objc func swizzledInitWithView(_ view: UIView) -> Any? {
        perform(Selector("_commonInitWithView:"), with: view)
        setValue(true, forKey: "_heldModeSupported")
        setValue(true, forKey: "_wornModeSupported")
        return self
    }
}

fileprivate extension ARSession {

    static let swizzlePresentationInit: Void = {
        swizzleInstanceMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("initWithView:"),
                              newClass: NSObject.self, new: Selector("swizzledInitWithView:"))
    }()

    static let swizzleWornModeSupported: Void = {
        swizzleClassMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("isWornModeSupported"),
                           newClass: NSObject.self, new: Selector("swizzledIsWornModeSupported"))
    }()

    static let swizzleCompositorEnabled: Void = {
        swizzleClassMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("isCompositorEnabled"),
            newClass: NSObject.self, new: Selector("swizzledIsCompositorEnabled"))
    }()

    static let swizzleStereoARSupported: Void = {
        swizzleClassMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("supportsStereoAR"),
            newClass: NSObject.self, new: Selector("swizzledSupportsStereoAR"))
    }()

    static let swizzleCompositorPlistKeys: Void = {
        swizzleClassMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("compositorPlistKeysEnabled"),
            newClass: NSObject.self, new: Selector("swizzledCompositorPlistKeysEnabled"))
    }()

    static let swizzleClassSupportPresentationMode: Void = {
        swizzleClassMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("supportsPresentationMode:"),
            newClass: NSObject.self, new: Selector("swizzledSupportsPresentationMode:"))
    }()

    static let swizzleInstanceSupportPresentationMode: Void = {
        swizzleInstanceMethod(oldClass: NSClassFromString("ARPresentation")!, old: Selector("_supportsPresentationMode:"),
            newClass: NSObject.self, new: Selector("swizzledInstanceSupportsPresentationMode:"))
    }()
}

class HMEViewController: UIViewController {

    override func viewDidLoad() {
        ARSession.swizzlePresentationInit
        ARSession.swizzleWornModeSupported
        ARSession.swizzleCompositorEnabled
        ARSession.swizzleStereoARSupported
        ARSession.swizzleClassSupportPresentationMode
        ARSession.swizzleCompositorPlistKeys
        ARSession.swizzleInstanceSupportPresentationMode

        super.viewDidLoad()

        let scene = try! SCNScene(url: URL(fileURLWithPath: Bundle.main.path(forResource: "StarGazer", ofType: "scn")!), options: nil)

        arview.scene = scene

        self.view.addSubview(arview)

        arview.translatesAutoresizingMaskIntoConstraints = false;
        arview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        arview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        arview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true


        self.view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        button.setTitle("StarGaze", for: .normal)
        button.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        arview.session.run(configuration, options: [])
    }

    let configuration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = false
        config.environmentTexturing = .automatic
        config.wantsHDREnvironmentTextures = true
        return config
    }()

    let arview = ARSCNView()

    let button = UIButton()

    @objc func pressed(sender: UIButton!) {
        HMEService.runSupportingCode(for: arview)
    }
}
