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
    var rControl: UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: collectionView Setup
        collectionView.register(HomeCollectionViewCell.nib(), forCellWithReuseIdentifier: "HomeCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //MARK: refreshControl Setup
        let refString = "Arrastra para actualizar"
        let myAttrString = NSAttributedString(string: refString)
        rControl.attributedTitle = myAttrString
        rControl.addTarget(self, action: #selector(searchUpdates), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = rControl
        } else {
            collectionView.addSubview(rControl)
        }
        if(self.collectionView.contentOffset.y == 0){
            self.collectionView.contentOffset = CGPoint(x:0, y:-rControl.frame.size.height)
        }
        searchUpdates()
        
        
        //layout setup
        let layout = UICollectionViewFlowLayout()
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMovieDetailsSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toMovieDetailsSegue" else {return}
        let destinationVC = segue.destination as! MovieDetailsViewController
        let indexPath = sender as! IndexPath
        destinationVC.loadViewIfNeeded()
        destinationVC.movieID = movies[indexPath.item].id
        
    }
    
    @objc func searchUpdates() {
        let pops = self.movies.count //variable to know how many posts to delete
        self.rControl.beginRefreshing()
        self.rControl.attributedTitle = NSAttributedString(string: "Cargando", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        print("entered function")
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=634b49e294bd1ff87914e7b9d014daed&language=es&page=1")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error.debugDescription)
            }
            else if let data = data {
                do {
                    var decodedData: NSDictionary = [:]
                    try decodedData = JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    if let results = decodedData["results"] as? NSArray {
                        for object in results{
                            if let dictionary = object as? NSDictionary {
                                
                                //Initialize variables that will be joined in a MoviePlaceholder Object
                                var dictId = 0
                                var dictImgURL = "https://image.tmdb.org/t/p/w500"
                                var dictTitle = ""
                                var dictReleaseDate = ""
                                var dictRating = 0.0
                                //search for each parameter in the dictionary
                                if let tmpId = dictionary["id"] as? Int {
                                    dictId = tmpId
                                }
                                if let tmpImg = dictionary["poster_path"] as? String{
                
                                    dictImgURL += tmpImg
                                }
                                if let tmpRating = dictionary["vote_average"] as? Double{
                                    dictRating = tmpRating
                                }
                                if let tmpTitle = dictionary["title"] as? String {
                                    dictTitle = tmpTitle
                                }
                                if let tmpReleaseDate = dictionary["release_date"] as? String {
                                    let dateFGet = DateFormatter()
                                    dateFGet.dateFormat = "YYYY-mm-dd"
                                    let date = dateFGet.date(from: tmpReleaseDate)
                                    let dateFPost = DateFormatter()
                                    dateFPost.dateFormat = "DD-mm-yyyy"
                                    dictReleaseDate = dateFPost.string(from: date!)
                                }
                                
                                self.movies.append(MoviePlaceholder(id: dictId, img: dictImgURL, title: dictTitle, date: dictReleaseDate, rating: dictRating))
                                
                                
                            } else {
                                print("Cannot decode object into dictionary")
                            }
                        }
                    } else {
                        print("Cannot decode result to Array")
                    }
                } catch {
                    print("Error:", error)
                }
                
            }
            DispatchQueue.main.async {
                for _ in 0..<pops {
                    self.movies.remove(at: 0)
                }
               // update or reload table in here
                self.collectionView.reloadData()
                self.rControl.endRefreshing()
                self.rControl.attributedTitle = NSAttributedString(string: "Arrastra para actualizar")
            }
            
            
        }
        task.resume()
    }
}

