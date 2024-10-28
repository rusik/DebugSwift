//
//  Resources.UserDefaults.ViewModel.swift
//  DebugSwift
//
//  Created by Matheus Gois on 15/12/23.
//  Copyright © 2023 apple. All rights reserved.
//

import Foundation

final class ResourcesUserDefaultsViewModel: NSObject, ResourcesGenericListViewModel {

    private let userDefaults: UserDefaults
    private let suiteName: String?
    private var keys = [String]()

    // MARK: - Initialization

    init(
        userDefaults: UserDefaults,
        suiteName: String?
    ) {
        self.userDefaults = userDefaults
        self.suiteName = suiteName
        super.init()
        setupKeys()
    }

    private func setupKeys() {
        keys = userDefaults.dictionaryRepresentation().keys.sorted()
        if let latitudeIndex = keys.firstIndex(
            of: LocationToolkit.Constants.simulatedLatitude
        ) {
            keys.remove(at: latitudeIndex)
        }
        if let longitudeIndex = keys.firstIndex(
            of: LocationToolkit.Constants.simulatedLongitude
        ) {
            keys.remove(at: longitudeIndex)
        }
        if userDefaults != UserDefaults.standard {
            let standardKeys = UserDefaults.standard.dictionaryRepresentation().keys
            keys = keys.filter {
                !standardKeys.contains($0)
            }
        }
    }

    // MARK: - ViewModel

    var isSearchActived = false

    var reloadData: (() -> Void)?

    func viewTitle() -> String {
        "User defaults"
        + (suiteName == nil ? "" : " (\(suiteName!))")
    }

    func numberOfItems() -> Int {
        isSearchActived ? filteredKeys.count : keys.count
    }

    func dataSourceForItem(atIndex index: Int) -> ViewData {
        let key = isSearchActived ? filteredKeys[index] : keys[index]
        let value = userDefaults.object(forKey: key)
        let string: String
        if let data = value as? Data {
            string = data.prettyPrinted()
        } else {
            string = "\(value ?? "")"
        }

        return .init(title: key, value: string)
    }

    func handleClearAction() {
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        keys.removeAll()
        filteredKeys.removeAll()
    }

    func handleDeleteItemAction(atIndex index: Int) {
        let key = isSearchActived ? filteredKeys.remove(at: index) : keys.remove(at: index)
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()

        if isSearchActived {
            keys.removeAll(where: { $0 == key })
        }
    }

    func emptyListDescriptionString() -> String {
        "empty-data".localized() 
        + "User Defaults"
        + (suiteName == nil ? "" : " (\(suiteName!))")
    }

    // MARK: - Search Functionality

    private var filteredKeys = [String]()

    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredKeys = keys
        } else {
            filteredKeys = keys.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
