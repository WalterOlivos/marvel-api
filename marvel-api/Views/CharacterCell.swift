//
//  CharacterCell.swift
//  marvel-api
//
//  Created by Walter Oliveira on 05/11/18.
//  Copyright © 2018 Walter Oliveira. All rights reserved.
//

import UIKit
import Kingfisher

class CharacterCell: UITableViewCell {
    public static let reuseIdentifier = "CharacterCell"

    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    public func configureWith(_ character: Character) {
        lblName.text = character.name
        
        imgThumb.kf.setImage(with: character.thumbnail.url,
                             options: [.transition(.fade(0.3))])
    }
}
