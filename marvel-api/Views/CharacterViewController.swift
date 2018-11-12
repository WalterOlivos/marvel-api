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
    
    var characters: [Character] = []
    
    fileprivate var loading: Bool = false
    fileprivate var currentOffset: Int = 0
    
    private var state: State = .loading {
        didSet {
            stateSwitch()
        }
    }
    
    private func stateSwitch() {
        switch state {
        case .ready(let characters):
            viewMessage.isHidden = true
            tableCharacters.isHidden = false
            self.characters.append(contentsOf: characters)
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
        
        loadMoreCharacters()
        
    }
    
    func loadMoreCharacters() {
        if loading == false{
            
            provider.request(.characters(offset: currentOffset)) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    do {
                        self.state = .ready(characters: try response.map(MarvelResponse<Character>.self).data.results)
                        self.currentOffset += 50
                    } catch {
                        self.state = .error
                    }
                case .failure:
                    self.state = .error
                }
            }
        }
    }
}

extension CharacterViewController {
    enum State {
        case loading
        case ready(characters: [Character])
        case error
    }
}

extension CharacterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.reuseIdentifier, for: indexPath) as? CharacterCell ?? CharacterCell()
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableCharacters.frame.width, height: 44)
        self.tableCharacters.tableFooterView = spinner

        cell.configure(with: characters[indexPath.row])
        
        if (indexPath.row == self.characters.count - 1) {
            loadMoreCharacters()
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let characterVC = InfoViewController.instantiate(character: characters[indexPath.row])
        navigationController?.pushViewController(characterVC, animated: true)
    }
}
