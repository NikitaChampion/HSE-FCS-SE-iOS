//
//  TripCollectionViewCell.swift
//  TripCard
//
//  Created by Никита Игумнов on 31.01.2021.
//

import UIKit

protocol TripCollectionCellDelegate {
    func didLikeButtonPressed(cell: TripCollectionViewCell)
}

class TripCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var totalDaysLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    var delegate: TripCollectionCellDelegate?
    
    var isLiked: Bool = false {
        didSet {
            if isLiked {
                likeButton.setImage(UIImage(named: "heartfull"), for: .normal)
            } else {
                likeButton.setImage(UIImage(named: "heart"), for: .normal)
            }
        }
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        delegate?.didLikeButtonPressed(cell: self)
    }
}
