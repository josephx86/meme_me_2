//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Joseph on 5/12/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    static let storyboardId = "DetailViewController"
    
    @IBOutlet weak var memeImageView: UIImageView!
    var memeImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        memeImageView.image = memeImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
}
