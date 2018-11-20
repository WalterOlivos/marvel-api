//
//  ComicsViewController.swift
//  marvel-api
//
//  Created by Walter Oliveira on 13/11/18.
//  Copyright © 2018 Walter Oliveira. All rights reserved.
//

import Foundation
import UIKit
import Moya

class ComicsViewController: UIViewController {
    
    let provider = MoyaProvider<Marvel>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    var id: Int = 0
    var comics: [Comic] = []
    
    fileprivate var loading: Bool = false
    fileprivate var currentOffset: Int = 0
    
    private var state: State = .loading {
        didSet {
            stateSwitch()
        }
    }
    
    private func stateSwitch() {
        switch state {
        case .ready(let comics):
            viewMessage.isHidden = true
            tableComics.isHidden = false
            self.comics.append(contentsOf: comics)
            tableComics.reloadData()
        case .loading:
            tableComics.isHidden = true
            viewMessage.isHidden = false
            labelStatusMessage.text = "Getting comics..."
        case .error:
            tableComics.isHidden = true
            viewMessage.isHidden = false
            labelStatusMessage.text = """
            Something went wrong!
            Try again later.
            """
        }
    }
    
    @IBOutlet weak var tableComics: UITableView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var labelStatusMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableComics.delegate = self
        tableComics.dataSource = self
        state = .loading
        
        loadMoreComics()
        
    }
    

    
    func loadMoreComics() {
        
        
        
        provider.request(.comics(offset: currentOffset, id: id)) {
            [weak self] result in guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    self.state = .ready(comics: try response.map(MarvelResponse<Comic>.self).data.results)
                    self.currentOffset += 20
                } catch {
                    self.state = .error
                }
            case .failure:
                self.state = .error
            }
        }
    }
}

extension ComicsViewController {
    enum State{
        case loading
        case ready(comics: [Comic])
        case error
    }
}


extension ComicsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ComicCell.reuseIdentifier, for: indexPath) as? ComicCell ?? ComicCell()
        
        cell.configure(with: comics[indexPath.row])

        if (indexPath.row > 5) {
            
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: self.tableComics.frame.width, height: 44)
            self.tableComics.tableFooterView = spinner
        
        }
        
            if (indexPath.row == self.comics.count - 1) {
                loadMoreComics()
            }
        
        
        return cell
    }
}
