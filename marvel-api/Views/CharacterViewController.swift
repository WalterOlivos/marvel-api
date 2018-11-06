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
    
    private var state: State = .loading {
        didSet {
            switch state {
            case .ready:
                viewMessage.isHidden = true
                tblCharacters.isHidden = false
                tblCharacters.reloadData()
            case .loading:
                tblCharacters.isHidden = true
                viewMessage.isHidden = false
                lblMessage.text = "Getting characters..."
            case .error:
                tblCharacters.isHidden = true
                viewMessage.isHidden = false
                lblMessage.text =   """
                                    Something went wrong!
                                    Try again later.
                                    """
            }
        }
    }
    
    
    @IBOutlet weak var tblCharacters: UITableView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        state = .error
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
        
        cell.configureWith(items[indexPath.item])
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard case .ready(let items) = state else { return }
        
        let characterVC = InfoViewController.instantiate(character: items[indexPath.item])
        navigationController?.pushViewController(characterVC, animated: true)
    }
}
