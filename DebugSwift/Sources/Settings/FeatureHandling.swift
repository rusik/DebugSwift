//
//  FeatureHandling.swift
//  DebugSwift
//
//  Created by Mochamad Rakha Luthfi Fahsya on 24/01/24.
//

import CoreLocation
import UIKit

enum FeatureHandling {

    static func setup(
        hide features: [DebugSwiftFeature],
        disable methods: [DebugSwiftSwizzleFeature],
        options: [DebugSwiftOption]
    ) {
        setupControllers(
            featuresToHide: features,
            options: options
        )
        setupMethods(methods)

        let delay: TimeInterval = DebugSwift.App.options.contains(.hideFloatingButton) ? 0 : 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            FloatViewManager.setup(TabBarController())
        }
    }

    private static func setupControllers(
        featuresToHide: [DebugSwiftFeature],
        options: [DebugSwiftOption]
    ) {
        DebugSwift.App.options = options
        DebugSwift.App.defaultControllers.removeAll(where: { featuresToHide.contains($0.controllerType) })
    }

    private static func setupMethods(_ methodsToDisable: [DebugSwiftSwizzleFeature]) {
        DebugSwift.App.disableMethods = methodsToDisable

        if !methodsToDisable.contains(.network) {
            enableNetwork()
        }

        if !methodsToDisable.contains(.location) {
            enableLocation()
        }

        if !methodsToDisable.contains(.views) {
            enableUIView()
        }

        if !methodsToDisable.contains(.crashManager) {
            enableCrashManager()
        }

        if !methodsToDisable.contains(.leaksDetector) {
            enableLeaksDetector()
        }

        if !methodsToDisable.contains(.console) {
            enableConsole()
        }
    }

    private static  func enableNetwork() {
        URLSessionConfiguration.swizzleMethods()
        NetworkHelper.shared.enable()
    }

    private static func enableCrashManager() {
        StderrCapture.startCapturing()
        StderrCapture.syncData()

        CrashManager.register()
    }

    private static func enableUIView() {
        UIView.swizzleMethods()
        UIWindow.db_swizzleMethods()
    }

    private static func enableLocation() {
        CLLocationManager.swizzleMethods()
    }

    private static func enableLeaksDetector() {
        UIViewController.lvcdSwizzleLifecycleMethods()
    }

    private static func enableConsole() {
        StdoutCapture.startCapturing()
    }
}
