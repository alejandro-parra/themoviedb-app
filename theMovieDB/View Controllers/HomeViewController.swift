//
//  ViewController.swift
//  theMovieDB
//
//  Created by Alejandro Parra on 15/07/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [MoviePlaceholder] = []
    var numberItems: CGFloat = 0
    var lineSpacing: CGFloat = 0
    var interlineSpace: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(HomeCollectionViewCell.nib(), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
        numberItems = 2
        lineSpacing = 5
        interlineSpace = 5
        
        let width = (collectionView.frame.width - (numberItems - 1) * interlineSpace) / numberItems
        let height = width * 1.5185 //the aspect ratio of a movie poster is 27:41
        layout.itemSize = CGSize(width: width, height: height)
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = interlineSpace
        collectionView.setCollectionViewLayout(layout, animated: true)
        

        
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.configure(with: movies[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (numberItems - 1) * interlineSpace) / numberItems
        let height = width * 1.5185 //the aspect ratio of a movie poster is 27:41
        
        return CGSize(width: width, height: height)
    }

}

