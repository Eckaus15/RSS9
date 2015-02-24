//
//  Favorite.swift
//  The Paradox
//
//  Created by Austin Eckman on 2/22/15.
//  Copyright (c) 2015 Austin Eckman. All rights reserved.
//

import Foundation
import CoreData
import UIKit
@objc(Favorite)
class Favorite: NSManagedObject {

    @NSManaged var favoriteDesc: String
    @NSManaged var favoriteLinks: String
    @NSManaged var favoriteTitle: String
    @NSManaged var favoriteDate: String

}
