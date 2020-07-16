//
//  HomeCollectionViewCell.swift
//  theMovieDB
//
//  Created by Alejandro Parra on 16/07/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        // Initialization code
    }
    
    func configure(with movie: MoviePlaceholder) {
        self.titleLabel.text = movie.title
        self.ratingLabel.text = movie.rating
        self.releaseDateLabel.text = movie.date
        setImage(with: movie)

    }
    
    static func nib() -> UINib {
        return UINib(nibName: "HomeCollectionViewCell", bundle: nil)
    }
    
    
    
    func setImage(with movie: MoviePlaceholder){
        //initialize documents directory to see if the image is already downloaded
        let docsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagePath = docsDirectory.appendingPathComponent(movie.title+movie.date)
        
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
            let url = URL(string: movie.img)
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
