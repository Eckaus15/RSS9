//
//  Favorite.swift
//  RSS
//
//  Created by Austin Eckman on 2/13/15.
//  Copyright (c) 2015 Austin Eckman. All rights reserved.
//

import Foundation
import CoreData
import UIKit
@objc(Favorite)
class Favorite: NSManagedObject {

    @NSManaged var favoriteLinks: String

}
