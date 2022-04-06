//
//  ShowTableViewController.swift
//  TVShowApp
//
//  Created by Jastin on 3/4/22.
//

import UIKit
import PresentationLayer
import DomainLayer

class ShowTableViewController : UIViewController {
    
   
    private var showViewModel: ShowViewModel!
    private var showEpisodeViewModel: ShowEpisodeViewModel!
    private var showSearchController: UISearchController!
    private lazy var fetchingActivityIndicator = UIActivityIndicatorView.buildActivityIndicator()
    private lazy var showTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = false
        tableView.isMultipleTouchEnabled = false
        tableView.backgroundColor = UIColor(named: ColorHelper.white.rawValue)!
        tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: NameHelper.cell.rawValue)
        return tableView
    }()
    
    init(showViewModel: ShowViewModel,showEpisodeViewModel: ShowEpisodeViewModel) {
        self.showViewModel = showViewModel
        self.showEpisodeViewModel = showEpisodeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewConfiguration()
        self.setOutletToSubView()
        self.setShowTableView()
        self.setShowSearchController()
        self.setActivityIndicatorConstraint()
    }
    
    fileprivate func setOutletToSubView() {
        self.view.addSubview(self.showTableView)
        self.view.addSubview(self.fetchingActivityIndicator)
    }
    
    fileprivate func setViewConfiguration() {
        self.view.backgroundColor = UIColor(named: ColorHelper.blue.rawValue)!
    }
    
    fileprivate func setShowTableView() {
        self.showTableView.dataSource = self
        self.showTableView.prefetchDataSource = self
        self.showTableView.delegate = self
        self.showTableView.layer.cornerRadius = 30
        self.showTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        NSLayoutConstraint.on([self.showTableView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
                               self.showTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                               self.showTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                               self.showTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)])
    }
    
    fileprivate func showTableViewFooterActivityIndicatorView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        lazy var activityIndicatorView = UIActivityIndicatorView.buildActivityIndicator()
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = footerView.center
        footerView.addSubview(activityIndicatorView)
        return footerView
    }
    
    fileprivate func setShowSearchController() {
        self.showViewModel.didSetShowEntityList = self
        self.showSearchController = UISearchController(searchResultsController: ShowSearchResultTableViewController(showViewModel: showViewModel))
        self.showSearchController.searchResultsUpdater = self
        self.navigationItem.searchController = showSearchController
    }
    
    fileprivate func setActivityIndicatorConstraint() {
        NSLayoutConstraint.on([self.fetchingActivityIndicator.centerXAnchor.constraint(equalTo: self.showTableView.centerXAnchor),
                               self.fetchingActivityIndicator.centerYAnchor.constraint(equalTo: self.showTableView.centerYAnchor)])
    }
}

extension ShowTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showViewModel.showEntityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let showTableViewCell = tableView.dequeueReusableCell(withIdentifier: NameHelper.cell.rawValue) as? ShowTableViewCell
        showTableViewCell?.accessoryType = .detailDisclosureButton
        showTableViewCell?.selectionStyle = .none
        self.showViewModel.setShowEntityByIndex(index: indexPath.row) { showEntity in
            showTableViewCell?.setShowEntity(showEntity)
        }
        return showTableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.fetchingActivityIndicator.startAnimating()
        self.showViewModel.showEntity = self.showViewModel.showEntityList[indexPath.row]
        self.showEpisodeViewModel.fetchShowEpisodeListById(showId: self.showViewModel.showEntityList[indexPath.row].id)
        self.showEpisodeViewModel.didSetShowEpisodeEntityList = self
    }
}

extension ShowTableViewController : UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.showViewModel.setShowEntityByIndex(index: indexPath.row,handler: nil)
        }
    }
}

extension ShowTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension ShowTableViewController : DidSetShowEntityList {
    func DidSetShowEntityListNotification() {
        DispatchQueue.main.async {
            self.showTableView.reloadData()
        }
    }
}

extension ShowTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let tvShowName = searchController.searchBar.text else {
            return
        }
        (searchController.searchResultsController as? ShowSearchResultTableViewController)?.searchFor(text: tvShowName)
    }
}

extension ShowTableViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showScrollPosition = scrollView.contentOffset.y
        if showScrollPosition > (self.showTableView.contentSize.height-100-scrollView.frame.size.height) {
            guard !self.showViewModel.isFetchingNextShowEntityList else {
                return
            }
            self.showTableView.tableFooterView = showTableViewFooterActivityIndicatorView()
            self.showViewModel.fetchNextShowList {
                self.showTableView.tableFooterView = nil
            }
        }
    }
}

extension ShowTableViewController : DidSetShowEpisodeEntityList {
    func DidSetShowEpisodeEntityListNotification() {
        self.fetchingActivityIndicator.stopAnimating()
        guard let showEntity = self.showViewModel.showEntity else {
            return
        }
        let showDetaiViewController = ShowDetailViewController(showEntity: showEntity, showEpisodeViewModel: self.showEpisodeViewModel)
        self.present(showDetaiViewController, animated: true)
    }
}
