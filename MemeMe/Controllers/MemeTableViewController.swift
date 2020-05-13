//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Joseph on 5/12/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource,  UITableViewDelegate {
    
    @IBOutlet weak var newMemeButton: UIButton!
    @IBOutlet weak var memeTableView: UITableView!
    let tableCellReuseId = "MemeTableCell"
    
    var memes: [Meme]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addIcon = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addIcon, style: .plain, target: self, action: #selector(createNewMeme))
        
        navigationItem.title = "Sent memes"
        
        memeTableView.delegate = self
        memeTableView.dataSource = self
        memeTableView.rowHeight = 120.0
    } 
    
    override func viewWillAppear(_ animated: Bool) {
        // If there are memes saved, show table
        // Otherwise show new meme button
        let memeCount = memes.count
        if (memeCount > 0) {
            memeTableView.reloadData()
            memeTableView.isHidden = false
            newMemeButton.isHidden = true
        } else {
            memeTableView.isHidden = true
            newMemeButton.isHidden = false
        }
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func newMemeButtonTapped(_ sender: Any) {
        createNewMeme()
    }
    
    @objc func createNewMeme() {
        if let editorController = storyboard?.instantiateViewController(withIdentifier: MemeEditorViewController.storyboardId) {
            editorController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(editorController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellMeme = memes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellReuseId)!
        cell.imageView?.image = cellMeme.memedImage
        let memeText = "\(cellMeme.topText) \(cellMeme.bottomText)"
        cell.textLabel?.text = memeText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeme = memes[indexPath.row]
        let detailController = storyboard?.instantiateViewController(identifier: DetailViewController.storyboardId) as! DetailViewController
        detailController.memeImage = selectedMeme.memedImage
        navigationController?.pushViewController(detailController, animated: true)
    }
}
