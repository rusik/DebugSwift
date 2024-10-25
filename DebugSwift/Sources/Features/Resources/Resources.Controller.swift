//
//  Resources.Controller.swift
//  DebugSwift
//
//  Created by Matheus Gois on 14/12/23.
//  Copyright © 2023 apple. All rights reserved.
//

import UIKit

final class ResourcesViewController: BaseController, MainFeatureType {

    var controllerType: DebugSwiftFeature { .resources }

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme.shared.backgroundColor
        tableView.separatorColor = .darkGray

        return tableView
    }()

    private var items: [Item] = []

    private enum Item {
        case files
        case userDefaults(UserDefaults, name: String? = nil)
        case keychain
        var title: String {
            switch self {
            case .files:
                "files-title".localized()
            case .userDefaults:
                "user-defaults".localized()
            case .keychain:
                "keychain".localized()
            }
        }
        var subtitle: String? {
            switch self {
            case .files: nil
            case .userDefaults(_, let name): name
            case .keychain: nil
            }
        }
    }

    override init() {
        super.init()
        setupTabBar()
        setupItems()
    }

    private func setupItems() {
        items = [.files]
        var userDefaultItems: [Item] = []
        for option in DebugSwift.App.options {
            if case let .userDefaults(suiteNames) = option {
                for name in suiteNames {
                    if let userDefaults = UserDefaults(suiteName: name) {
                        userDefaultItems.append(
                            .userDefaults(userDefaults, name: name)
                        )
                    }
                }
            }
        }
        if userDefaultItems.isEmpty {
            items += [.userDefaults(.standard)]
        } else {
            items += [.userDefaults(.standard, name: "standard")]
            items += userDefaultItems
        }
        items += [.keychain]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: .cell
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupTabBar() {
        title = "resources-title".localized()
        tabBarItem = UITabBarItem(
            title: title,
            image: .named("filemenu.and.selection"),
            tag: 2
        )
    }
}

extension ResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: .cell,
            for: indexPath
        )
        let item = items[indexPath.row]
        cell.setup(
            title: item.title,
            subtitle: item.subtitle
        )
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80.0
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller: UIViewController?
        switch items[indexPath.row] {
        case .files:
            // Handle "File" selection
            controller = ResourcesFilesViewController()
        case .userDefaults(let userDefaults, let name):
            let viewModel = ResourcesUserDefaultsViewModel(
                userDefaults: userDefaults,
                suiteName: name
            )
            controller = ResourcesGenericController(viewModel: viewModel)
        case .keychain:
            let viewModel = ResourcesKeychainViewModel()
            controller = ResourcesGenericController(viewModel: viewModel)
        }
        if let controller {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
