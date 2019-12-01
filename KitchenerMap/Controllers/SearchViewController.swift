//
//  SearchViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 01/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResult: SearchResult?
    var onFeatureSelected: ((Feature) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews() {
        setUpSearchBar()
        setUpTable()
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    private func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func refreshSearch(searchResult: SearchResult) {
        let resultText = LocaleHelper.shared.language == .greek ? "αποτελέσματα βρέθηκαν" : "results found"
        subtitle.text = searchResult.features.count.string + " " + resultText
        self.searchResult = searchResult
        tableView.reloadData()
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, text.count > 2 else { return }
        Interactor.shared.textSearch(text) { [weak self] (result) in
            self?.refreshSearch(searchResult: result)
            debugPrint(result)
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let feature = searchResult?.features[indexPath.row] else { return }
        onFeatureSelected?(feature)
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult?.features.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SearchResultTableViewCell.self, for: indexPath)
        cell.configure(with: searchResult?.features[indexPath.row])
        return cell
    }
}
