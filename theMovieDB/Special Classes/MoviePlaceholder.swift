//
//  Movie.swift
//  theMovieDB
//
//  Created by Alejandro Parra on 16/07/20.
//  Copyright © 2020 Alejandro Parra. All rights reserved.
//

import Foundation

public class MoviePlaceholder {
    
    let img: String
    let title: String
    let date: String
    let rating: String
    
    init(img: String, title: String, date: String, rating: String) {
        self.img = img
        self.title = title
        self.date = date
        self.rating = rating
    }
    
}
