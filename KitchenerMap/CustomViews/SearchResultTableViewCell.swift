//
//  SearchResultTableViewCell.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 01/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with data: Feature?) {
        let isGreek = LocaleHelper.shared.language == .greek
        titleLabel.text = isGreek ? data?.properties?.values?.nameEL : data?.properties?.values?.nameEN
        subtitleLabel.text = isGreek ? data?.properties?.values?.categoryEL : data?.properties?.values?.categoryEN
    }
}
