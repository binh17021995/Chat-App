//
//  NewConversationViewController.swift
//  Chat App
//
//  Created by Duy Bình on 16/05/2023.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var hasFetched = false
    
    private var user = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users ..."
        return searchBar
        
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultLabel : UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height - 200), width: view.width/2, height: 100)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
}

extension NewConversationViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar : UISearchBar){
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        self.searchUser(query: text)
        
    }
    func searchUser(query: String){
        //filter user Firebase Storage
        //check
        
        if hasFetched {
            // if it does : filter
            
            filterUser(with: query)
            
        }else{
            //if not fetch all user
            
            DatabaseManager.shared.getAllUser(completion: {[weak self] result in
                switch result {
                case .success(let value):
                    self?.hasFetched = true
                    self?.user = value
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("Failed get user: \(error)")
                }
            })
        }
        
        // update UI: show result or show label no result
        
        
    }
    
    func filterUser(with term : String){
        guard hasFetched else {
            return
        }
        self.spinner.dismiss()
        let results : [[String : String]] = self.user.filter({
            guard let name = $0["name"]?.lowercased() as? String else {
                return false
            }
            return name.hasPrefix(term.lowercased())
            
        })
        self.results = results
        print(results)
        updateUI()
        
    }
    
    func updateUI() {
        
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        
    }
    
}
