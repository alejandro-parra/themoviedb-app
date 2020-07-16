//
//  MovieDetailsViewController.swift
//  theMovieDB
//
//  Created by Alejandro Parra on 16/07/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var durationStaticLabel: UILabel!
    @IBOutlet weak var releaseDateStaticLabel: UILabel!
    @IBOutlet weak var ratingStaticLabel: UILabel!
    @IBOutlet weak var genresStaticLabel: UILabel!
    @IBOutlet weak var descriptionStaticLabel: UILabel!
    
    
    var movieID: Int = 0
    var duration = 0
    var releaseDate = ""
    var rating = 0.0
    var genre = ""
    var desc = ""
    var imgURL = ""
    var movieTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        hideEverything(bool: true)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
       
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
         searchUpdates()
    }

    func hideEverything(bool: Bool) {
        self.imageView.isHidden = bool
        self.titleLabel.isHidden = bool
        self.durationLabel.isHidden = bool
        self.releaseDateLabel.isHidden = bool
        self.ratingLabel.isHidden = bool
        self.genreLabel.isHidden = bool
        self.descriptionLabel.isHidden = bool
        self.genresStaticLabel.isHidden = bool
        self.ratingStaticLabel.isHidden = bool
        self.durationStaticLabel.isHidden = bool
        self.releaseDateStaticLabel.isHidden = bool
        self.descriptionStaticLabel.isHidden = bool
    }
    
    func searchUpdates(){
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)?api_key=634b49e294bd1ff87914e7b9d014daed&language=es")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error.debugDescription)
                }
                else if let data = data {
                    do {
                        var decodedData: NSDictionary = [:]
                        try decodedData = JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        //search for each parameter in the dictionary
                        if let tmpRuntime = decodedData["runtime"] as? Int {
                            self.duration = tmpRuntime
                        }
                                    
                        if let tmpRating = decodedData["vote_average"] as? Double{
                            self.rating = tmpRating
                            
                        }
                        if let tmpTitle = decodedData["title"] as? String {
                            self.movieTitle = tmpTitle
                            
                        }
                        if let tmpReleaseDate = decodedData["release_date"] as? String {
                            let dateFGet = DateFormatter()
                            dateFGet.dateFormat = "YYYY-mm-dd"
                            let date = dateFGet.date(from: tmpReleaseDate)
                            let dateFPost = DateFormatter()
                            dateFPost.dateFormat = "DD-mm-yyyy"
                            self.releaseDate = dateFPost.string(from: date!)
                            
                        }
                        if let tmpGenre = decodedData["genres"] as? NSArray {
                            for genre in tmpGenre {
                                if let genreDict = genre as? NSDictionary{
                                    if self.genre != "" {
                                        self.genre += ", " + (genreDict["name"] as! String)
                                    } else {
                                        self.genre += genreDict["name"] as! String
                                    }
                                    
                                }
                            }
                            
                        }
                        if let tmpDescription = decodedData["overview"] as? String {
                            self.desc = tmpDescription
                            
                        }
                        if let tmpImg = decodedData["backdrop_path"] as? String{
                            self.imgURL = "https://image.tmdb.org/t/p/w500"+tmpImg

                        }
                        DispatchQueue.main.async() {
                            self.updateUI()
                        }
                                    
                    } catch {
                        print("Error",error)
                    }
                     
                }
                
            }
        task.resume()
    }
    
    func updateUI(){
        self.titleLabel.text = self.movieTitle
        self.durationLabel.text = String(self.duration)
        self.releaseDateLabel.text = self.releaseDate
        self.ratingLabel.text = String(self.rating)
        self.genreLabel.text = self.genre
        self.descriptionLabel.text = self.desc
        self.setImage(with: imgURL)
        
        
        self.activityIndicator.stopAnimating()
        self.hideEverything(bool: false)
    }
    
    func setImage(with url: String){
        //initialize documents directory to see if the image is already downloaded
        let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = docsDirectory.appendingPathComponent(self.movieTitle+self.releaseDate+"_backdrop")
        
        //If file exists, retrieve it, else download and cache it.
        if  FileManager.default.fileExists(atPath: imagePath.path) {
            print("Found file, retrieving")
            if let imageData = try? Data(contentsOf: imagePath){
                let image = UIImage(data: imageData)
                imageView.image = image
            } else {
                print("retrieve file error")
                imageView.image = UIImage(named: "alien-img-tmp")
            }
            
        } else {
            print("Will download images")
            print(url)
            let url = URL(string: url)
            let data = try? Data(contentsOf: url!)
            
            //if there was nothing to download
            if data != nil {
                let tmpImage = UIImage(data: data!)
                if let imageData = tmpImage?.jpegData(compressionQuality: 1) {
                    do {
                        // writes the image data to disk
                        try imageData.write(to: imagePath)
                        print("File saved")
                        imageView.image = tmpImage
                    } catch {
                        print("error saving file:", error)
                    }
                } else {
                    print("Image is not JPG")
                    imageView.image = UIImage(named: "alien-img-tmp")
                }
            } else  {
                print("Returned empty image")
                imageView.image = UIImage(named: "alien-img-tmp")
            }
            
        }
    }
    
}
