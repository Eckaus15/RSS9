//
//  FeedTableViewCell.swift
//  RSS
//
//  Created by Austin Eckman on 2/13/15.
//  Copyright (c) 2015 Austin Eckman. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var subtext: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var favorite: UIButton!
    @IBAction func favoriteButton(sender: AnyObject) {
       let favorite: UIButton = sender as UIButton
        let selectedFavorite = UIImage(named: "GoldStar") as UIImage!
        let notFavorite = UIImage(named: "FavoriteStar") as UIImage!
        //sets up core data into array
        var myFav = title.text!
        println(myFav)
        let moc = SwiftCoreDataHelper.managedObjectContext()
            //print out core data
        let fetchRequest = NSFetchRequest(entityName:"Favorite")
        var favNames: [String] = []
        if let favs = moc.executeFetchRequest(fetchRequest, error: nil) as? [Favorite] {
            // get an array of the 'title' attributes
            favNames = favs.map { $0.favoriteLinks }
        }
        if contains(favNames, myFav){
            println("true")
            favorite.setImage(notFavorite, forState: .Normal)
            //delete from core data
            
        }else{
            println("False")
            favorite.setImage(selectedFavorite, forState: .Normal)
            //save to core data
            let fav = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Favorite), managedObjectConect: moc) as Favorite
            fav.favoriteLinks = myFav as String
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
