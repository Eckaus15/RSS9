//
//  FeedTableViewCell.swift
//  RSS
//
//  Created by Austin Eckman on 2/13/15.
//  Copyright (c) 2015 Austin Eckman. All rights reserved.
//

import UIKit

var logItems = NSManagedObject()


class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel! //date of article
    @IBOutlet weak var link: UILabel! //Link hidden on cell
    @IBOutlet weak var subtext: UILabel! //description of article
    @IBOutlet weak var title: UILabel! //title of article
    @IBOutlet weak var favorite: UIButton! //favorite button
    @IBAction func favoriteButton(sender: AnyObject) { //favoritebutton action
        let favorite: UIButton = sender as UIButton
        let selectedFavorite = UIImage(named: "GoldStar") as UIImage!
        let notFavorite = UIImage(named: "FavoriteStar") as UIImage!
        //sets up variables with the cell information
        var myFav = title.text!
        var myDesc = subtext.text!
        var myLink = link.text!
        var myDate = date.text!
        //begin core data
        let moc = SwiftCoreDataHelper.managedObjectContext()
        var favNames: [String] = []
        let fetchRequestM = NSFetchRequest(entityName:"Favorite") //Fetch core data
        let fetchRequest = NSFetchRequest(entityName:"Favorite") //Fetch core data
        let sortDescriptor = NSSortDescriptor(key: "favoriteLinks", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicateOnTitle = NSPredicate(format: "favoriteTitle = %@", myFav)
        fetchRequest.predicate = predicateOnTitle //predicate to show only myLink in core data [Array of 1]

        if let favs = moc.executeFetchRequest(fetchRequestM, error: nil) as? [Favorite] {
            // get an array of the 'title' attributes
            favNames = favs.map { $0.favoriteTitle }
        }
        if contains(favNames, myFav){ //already favorited
            favorite.setImage(notFavorite, forState: .Normal)
            if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Favorite] {
            var logItems = fetchResults
            let logItemToDelete = logItems[0] as NSManagedObject
            moc.deleteObject(logItemToDelete)
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
                
            }
            
        }else{//Not yet favorited
            favorite.setImage(selectedFavorite, forState: .Normal)
            //save to core data
            let fav = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Favorite), managedObjectConect: moc) as Favorite
            fav.favoriteLinks = myLink as String
            fav.favoriteDesc = myDesc as String
            fav.favoriteTitle = myFav as String
            fav.favoriteDate = myDate as String
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

