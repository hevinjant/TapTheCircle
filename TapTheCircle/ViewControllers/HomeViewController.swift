//
//  ViewController.swift
//  TapTheCircle
//
//  Created by Hevin Jant on 9/11/21.
//  Copyright © 2021 Hevin Jant. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var leaderBoard: [UserLog] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(LeaderBoardTableViewCell.self, forCellReuseIdentifier: LeaderBoardTableViewCell.identifier)
        table.tableFooterView = UIView()
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Best Players"
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play", style: .done, target: self, action: #selector(didTapPlay))
        
        // add subviews
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupTableHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAllUserLogs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // assign frame
        tableView.frame = view.bounds
    }
    
    private func setupTableHeader() {
        let headerView = LeaderBoardHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: 30))
        //headerView.clipsToBounds = true
        
        tableView.tableHeaderView = headerView
    }
    
    @objc private func didTapPlay() {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func fetchAllUserLogs() {
        DatabaseManager.shared.getAllUserLogs(completion: { [weak self] allUserLogs in
            guard let distinctUserLogs = self?.getDistinctUserLog(allUserLogs: allUserLogs) else {
                print("Failed to get distinct user log.")
                return
            }
            self?.leaderBoard = distinctUserLogs
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
    
    private func getDistinctUserLog(allUserLogs: [UserLog]) -> [UserLog] {
        var distinctUserLog: [UserLog] = []
        var distinctUserName: [String] = []
        let sortedByHighestScore = allUserLogs.sorted(by: { ($0.score > $1.score) && ($0.name < $1.name) })
        
        for userLog in sortedByHighestScore {
            if !distinctUserName.contains(userLog.name) {
                distinctUserLog.append(userLog)
                distinctUserName.append(userLog.name)
            }
        }
        
        return distinctUserLog
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderBoard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = leaderBoard[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderBoardTableViewCell.identifier, for: indexPath) as? LeaderBoardTableViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
