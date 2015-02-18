//
//  TableTableViewController.swift
//  RSS
//
//  Created by Austin Eckman on 11/27/14.
//  Copyright (c) 2014 Austin Eckman. All rights reserved.
//
/*
      Notes:

         1 Actuallly delete unwanted feeds
         2 Add Fav option
         3 Add All feeds option
         4 Add number of how many unread articles are there


      Notes2:
          So I plan on getting the Fav option done by just giving core data the list of links
        and those links can just go into the load(selectedFURL) individually

        For the All Feeds option its going to yeah idk yet

        Actually deleting unwanted feeds is getting moved down to LAST priority


        number of unread articles should be interesting... Take (feeds.count - readFeeds.count) 
        readfeeds.count needs to be an element of the array feeds and should just be a number that
        increases everytime a new check mark is made. Actually nvm you need to use core data so make
        core data for feeds.count to update everytime a feed is loaded and just have another one to be
        the variable for that feed


        Do I actually want it to open to a blank feed first instead of simply offering them one? Maybe a
        picture on the screen that is moving that says slide left to add a new feed or open feeds sidebar
        that would be cool, I just need some way to show that the sidebar is there even some sidebars include a small
        "handle" to pull them out. Other ways would just be an interactive thing telling them to when they are not moving
        into new cells or reading a feed.. How does one do a timer in swift? 


*/
import UIKit
import CoreData

class FeedTableViewController: UITableViewController, NSXMLParserDelegate, SideBarDelegate {
    
    var parser = NSXMLParser()
    var feeds = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var ftitle = NSMutableString()
    var link = NSMutableString()
    var fdescription = NSMutableString()
    var sidebar = SideBar()
    var savedFeeds = [Feed]()
    var feedNames = [String]()
    var currentFeedTitle = String()
    var currentFeedLink = String()
    var holdinglink = String()

    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        request(nil)
        loadSavedFeeds()
        

    }
    
    func favoriteButton() {
    
    }
    
    func request(urlString:String?){
        
        //Go to given url (Use this for feeds in favorite)
        
        
        if urlString == nil{
            
            let url = NSURL(string: "http://feeds.nytimes.com/nyt/rss/Technology")
            self.title = "New York Times Technology"
            feeds = []
            parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = self
            parser.shouldProcessNamespaces = true
            parser.shouldReportNamespacePrefixes = true
            parser.shouldResolveExternalEntities = true
            parser.parse()
        }else{
            var errorlink = holdinglink
            let url = NSURL(string: urlString!)
            self.title = currentFeedTitle
            feeds = []
            parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = self
            parser.shouldProcessNamespaces = true
            parser.shouldReportNamespacePrefixes = true
            parser.shouldResolveExternalEntities = true
            parser.parse()
            
            
            if feeds == []{
                println("error")
                let alertTwo = UIAlertController(title: "Alert!", message: "The feed you clicked on presented zero feeds. Please check your internet connectivity or try another feed.", preferredStyle: UIAlertControllerStyle.Alert)
                alertTwo.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertTwo, animated: true, completion: nil)
                self.request(nil)

            }
            
        }
        
        
    }


    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        element = elementName
        
        // feed properties
        if (element as NSString).isEqualToString("item"){
            elements = NSMutableDictionary.alloc()
            elements = [:]
            ftitle = NSMutableString.alloc()
            ftitle = ""
            link = NSMutableString.alloc()
            link = ""
            fdescription = NSMutableString.alloc()
            fdescription = ""


            


        }
        
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        
        if (elementName as NSString).isEqualToString("item") {
            if ftitle != ""{
                elements.setObject(ftitle, forKey: "title")
            
        }
            if link != ""{
                elements.setObject(link, forKey: "link")
            
        }
            if fdescription != ""{
                elements.setObject(fdescription, forKey: "description")
            
        }

           
        feeds.addObject(elements)

    }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
        
        if element.isEqualToString("title"){
            ftitle.appendString(string)
        } else if element.isEqualToString("link"){
            link.appendString(string)
        } else if element.isEqualToString("description"){
            fdescription.appendString(string)
        }
        
    
    }
    
    func parserDidEndDocument(parser: NSXMLParser!) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSavedFeeds (){
        savedFeeds = [Feed]()
        feedNames = [String]()
        
        //add "Add Feed" into feednames because its obviously not in there
        feedNames.append("Add Feed")
        feedNames.append("Favorites")
        feedNames.append("All Feeds")
        
        //contacts core data for feeds list
        let moc = SwiftCoreDataHelper.managedObjectContext()
        let results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Feed), withPredicate: nil, managedObjectContext: moc)
        if results.count > 0 {
            for feed in results{
                let f = feed as Feed
                savedFeeds.append(f)
                feedNames.append(f.name)
                
            }
        }
        
        //fill menu items with feedNames
        sidebar = SideBar(sourceView: self.navigationController!.view, menuItems: feedNames)
        sidebar.delegate = self
        
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        
        //checks to see if it was the add feed button pressed
        if index == 0{ //Add feed button
            let alert = UIAlertController(title: "Create A New Feed", message: "Enter the name and URL of the feed", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed Name"
            })
            alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
                textField.placeholder = "Feed URL"
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (alertAction:UIAlertAction!) -> Void in
                let textFields = alert.textFields
                let feedNameTextField = textFields?.first as UITextField
                let feedURLTextField = textFields?.last as UITextField
                
                //if feed name is filled out create into core data
                if feedNameTextField.text != "" && feedURLTextField.text != "" {
                    let moc = SwiftCoreDataHelper.managedObjectContext()
                    
                    let feed = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feed), managedObjectConect: moc) as Feed
                    feed.name = feedNameTextField.text
                    feed.url = feedURLTextField.text
                    
                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                    self.loadSavedFeeds()
                    self.title = feed.name
                    self.request(feedURLTextField.text)
                    
                    
                }
                
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else if index == 1{
            println("Favorites")
        }else if index == 2{
            println("All Feeds")

        }else if index >= 3{
            
            //Clearly was a feed pressed

            //call new MOC
            let moc = SwiftCoreDataHelper.managedObjectContext()
            var selectedFeed = moc.existingObjectWithID(savedFeeds[index - 3].objectID, error: nil) as Feed
            
            //Set title
            currentFeedTitle = selectedFeed.name
            currentFeedLink = selectedFeed.url

            
            //set new url

            request(selectedFeed.url)
        }
        

        
    }
    
   
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return feeds.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as FeedTableViewCell
        
        //Cell layout
        cell.detailTextLabel?.numberOfLines = 3
        cell.title.text = feeds.objectAtIndex(indexPath.row).objectForKey("title") as? String
        cell.subtext.text = feeds.objectAtIndex(indexPath.row).objectForKey("description") as? String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        cell.favorite.tag = indexPath.row
        
        ////////////////////////////////////////////////////////////////////////////////////

        //sets up core data into array
        var myTitle = feeds.objectAtIndex(indexPath.row).objectForKey("title") as String
        let moc = SwiftCoreDataHelper.managedObjectContext()
        let fetchRequest = NSFetchRequest(entityName:"Read")
        var titleNames: [String] = []
        //Checks to see if current feed is in array if it is return a check mark for Read
        if let reads = moc.executeFetchRequest(fetchRequest, error: nil) as? [Read] {
            // get an array of the 'title' attributes
            titleNames = reads.map { $0.readName }
        }
        if (contains(titleNames, myTitle)){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            //Already contained (Already Read)
        }else{/*Not viewed yet*/}
        
        ////////////////////////////////////////////////////////////////////////////////////
        let selectedFavorite = UIImage(named: "GoldStar") as UIImage!
        let notFavorite = UIImage(named: "FavoriteStar") as UIImage!
        
        var myFav = myTitle
        let fetchRequestTwo = NSFetchRequest(entityName:"Favorite")
        var favNames: [String] = []
        if let favs = moc.executeFetchRequest(fetchRequestTwo, error: nil) as? [Favorite] {
            favNames = favs.map { $0.favoriteLinks }
        }
        if contains(favNames, myFav){
            println("true")
            cell.favorite.setImage(selectedFavorite, forState: .Normal)
        }else{
            println("False")
            cell.favorite.setImage(notFavorite, forState: .Normal)
        }

        
        ////////////////////////////////////////////////////////////////////////////////////
        
        return cell
    }
    
    
        
      override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var accessoryType: UITableViewCellAccessoryType;()

        ///Gets url from feed
        let selectedFURL: String = feeds[indexPath.row].objectForKey("link") as String
        let selectedTitle: String = feeds[indexPath.row].objectForKey("title") as String
        var con = KINWebBrowserViewController()
        
        //Cleans URL
        var dirty = selectedFURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var clean = dirty!.stringByReplacingOccurrencesOfString(
            "%0A",
            withString: "",
            options: .RegularExpressionSearch)
        
        //Creates usuable url
        var URL = NSURL(string: clean)
        con.loadURL(URL!)
        
        self.navigationController?.pushViewController(con, animated: true)

        //coredata
        let moc = SwiftCoreDataHelper.managedObjectContext()
        let read = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Read), managedObjectConect: moc) as Read
        read.readName = selectedTitle
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
        
        //reload table to show check mark (Refresh core data)
        let thisfeed = currentFeedLink
        if thisfeed == ""{
            request(nil)
        }else{
            request(thisfeed)
        }

}

}

