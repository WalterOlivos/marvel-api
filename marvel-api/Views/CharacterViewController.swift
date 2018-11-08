//
//  CharacterViewController.swift
//  marvel-api
//
//  Created by Walter Oliveira on 05/11/18.
//  Copyright © 2018 Walter Oliveira. All rights reserved.
//

import Foundation
import UIKit
import Moya

class CharacterViewController: UIViewController {
    
    let provider = MoyaProvider<Marvel>(plugins: [NetworkLoggerPlugin(verbose: true)])
    
    private var state: State = .loading {
        didSet {
            stateSwitch()
        }
    }
    
    private func stateSwitch() {
        switch state {
        case .ready:
            viewMessage.isHidden = true
            tableCharacters.isHidden = false
            tableCharacters.reloadData()
        case .loading:
            tableCharacters.isHidden = true
            viewMessage.isHidden = false
            labelStatusMessage.text = "Getting characters..."
        case .error:
            tableCharacters.isHidden = true
            viewMessage.isHidden = false
            labelStatusMessage.text =   """
            Something went wrong!
            Try again later.
            """
        }
    }

    @IBOutlet weak var tableCharacters: UITableView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var labelStatusMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableCharacters.delegate = self
        tableCharacters.dataSource = self
        state = .loading
        
        provider.request(.characters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    self.state = .ready(try response.map(MarvelResponse<Character>.self).data.results)
                } catch {
                    self.state = .error
                }
            case .failure:
                self.state = .error
            }
        }
    }
}

extension CharacterViewController {
    enum State {
        case loading
        case ready([Character])
        case error
    }
}

extension CharacterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .ready(let items) = state else { return 0 }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.reuseIdentifier, for: indexPath) as? CharacterCell ?? CharacterCell()
        
        guard case .ready(let items) = state else { return cell }
        
        cell.configure(with: items[indexPath.row])
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
       
        guard case .ready(let items) = state else { return }
        
        let characterVC = InfoViewController.instantiate(character: items[indexPath.row])
        navigationController?.pushViewController(characterVC, animated: true)
    }
}
