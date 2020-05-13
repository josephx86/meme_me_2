//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Joseph on 5/12/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var memeCollectionView: UICollectionView!
    @IBOutlet weak var newMemeButton: UIButton!
    let cellId = "MemeCollectionCell"
    
    var memes: [Meme]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addIcon = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(createNewMeme))
        
        navigationItem.title = "Sent memes" 
        
        memeCollectionView.delegate = self
        memeCollectionView.dataSource = self
               
        setupFlowLayout(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // If there are memes saved, show table
        // Otherwise show new meme button
        let memeCount = memes.count
        if (memeCount > 0) {
            memeCollectionView.reloadData()
            memeCollectionView.isHidden = false
            newMemeButton.isHidden = true
        } else {
            memeCollectionView.isHidden = true
            newMemeButton.isHidden = false
        }
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupFlowLayout(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MemeCollectionViewCell
        let index = indexPath.row
        let cellMeme = memes![index]
        cell.imageView.image = cellMeme.memedImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMeme = memes[indexPath.row]
        let detailController = storyboard?.instantiateViewController(identifier: DetailViewController.storyboardId) as! DetailViewController
        detailController.memeImage = selectedMeme.memedImage
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @IBAction func newMemeButtonTapped(_ sender: Any) {
        createNewMeme()
    }
    
    @objc func createNewMeme() {
        if let editorController = storyboard?.instantiateViewController(withIdentifier: MemeEditorViewController.storyboardId) {
            editorController.modalPresentationStyle = .fullScreen
            
            navigationController?
                .pushViewController(editorController, animated: true)
            
        }
    }
    
    func setupFlowLayout(_ willTransition: Bool) {
        let newWidth = willTransition ? view.frame.size.height : view.frame.size.width
        let space = CGFloat(16.0)
        let dimension = (newWidth - (4.0 * space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        memeCollectionView.frame.size.width = newWidth
        memeCollectionView.collectionViewLayout = flowLayout
        memeCollectionView.reloadData()
    }
}
