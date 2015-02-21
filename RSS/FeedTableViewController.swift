//
//  TableTableViewController.swift
//  RSS
//
//  Created by Austin Eckman on 11/27/14.
//  Copyright (c) 2014 Austin Eckman. All rights reserved.
//
/*
      Notes:

         4 Add number of how many unread articles are there

*/
import UIKit
import CoreData

class FeedTableViewController: UITableViewController, NSXMLParserDelegate, SideBarDelegate {
    
    var parser = NSXMLParser() //Parser
    var feeds = NSMutableArray() //Feed list
    var elements = NSMutableDictionary() //feed elements
    var element = NSString() //feed elements1
    var ftitle = NSMutableString() //feed title
    var link = NSMutableString() //feed link
    var fdescription = NSMutableString() //feed description
    var sidebar = SideBar() //sidebar
    var savedFeeds = [Feed]() //sidebar saved feeds (core)
    var feedNames = [String]() //sidebar feed names
    var currentFeedTitle = String() //current feed title
    var currentFeedLink = String() //current feed link
    var holdinglink = String() //error reverse title
    var sidebarindex = Int() //index 0 add feeds; 1 favs ; 2 all feeds



    
 
    func refresh(sender:AnyObject)
    {
        // Updating your data here...
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        
        //Refreshing enabled
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
        request(nil)
        loadSavedFeeds()
        
        

    }
    
    
    func request(urlString:String?){
        
        
        if urlString == nil{

            
            //DEFAULT LINK
            let url = NSURL(string: "http://feeds.nytimes.com/nyt/rss/Technology")
            self.title = "New York Times Technology"
            currentFeedLink = "http://feeds.nytimes.com/nyt/rss/Technology"
            feeds = []
            parser = NSXMLParser(contentsOfURL: url)!
            parser.delegate = self
            parser.shouldProcessNamespaces = true
            parser.shouldReportNamespacePrefixes = true
            parser.shouldResolveExternalEntities = true
            parser.parse()
            tableView.reloadData()
            
        }else{
            
            
            //USER LINK
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
            
            if feeds == [] && self.currentFeedLink != "http://feeds.nytimes.com/nyt/rss/Technology"{
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
        
        //add "Add Feed" into feednames because its not in there
        feedNames.append("Add Feed")
        feedNames.append("Favorites")
      //  feedNames.append("All Feeds")
        
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
        
        //checks to see what side bar button was pressed
        
        if index == 0{ //Add feed button was pressed
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
                   // self.title = feed.name
                    self.request(feedURLTextField.text)
                    
                    
                }
                
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else if index == 1{ //Favorites was selected on side bar
            self.title = "Favorites"
            sidebarindex = 1
            
            var favFeeds = [] as NSArray
            let moc = SwiftCoreDataHelper.managedObjectContext()
            let favFetch = NSFetchRequest(entityName: "Favorite")
            if let favS = moc.executeFetchRequest(favFetch, error: nil) as? [Favorite]{
                favFeeds = favS.map{ $0.favoriteTitle}
            }
            self.tableView.reloadData()


        }else if index >= 2{
            sidebarindex = 2
            //Clearly was a feed pressed

            //call new MOC
            let moc = SwiftCoreDataHelper.managedObjectContext()
            var selectedFeed = moc.existingObjectWithID(savedFeeds[index - 2].objectID, error: nil) as Feed
            
            //Set title
            currentFeedTitle = selectedFeed.name
            currentFeedLink = selectedFeed.url

            
            //set new url

            request(selectedFeed.url)
            self.tableView.reloadData()

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
        if sidebarindex == 3{
        return feeds.count
        } else if sidebarindex == 2{
        return feeds.count
        } else if sidebarindex == 1{
        
            let moc = SwiftCoreDataHelper.managedObjectContext()
            var favNames: [String] = []
            let fetchRequestM = NSFetchRequest(entityName:"Favorite")
            if let favs = moc.executeFetchRequest(fetchRequestM, error: nil) as? [Favorite] {
                favNames = favs.map { $0.favoriteTitle }}
            
            if favNames.count != 0{
                return favNames.count
            }else{
                return 0
            }
            
        } else{
        return feeds.count
        }
        
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as FeedTableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        if sidebarindex != 1{
            
            ////////////////// Marked for sidebar index that is not favorites //////////////////
            
        cell.detailTextLabel?.numberOfLines = 3
        cell.title.text = feeds.objectAtIndex(indexPath.row).objectForKey("title") as? String
        cell.subtext.text = feeds.objectAtIndex(indexPath.row).objectForKey("description") as? String
        cell.link.text = feeds.objectAtIndex(indexPath.row).objectForKey("link") as? String
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        cell.favorite.tag = indexPath.row
            
            
            ////////////////// Returns checkmark if read //////////////////
            
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
            
            ////////////////// Returns goldstar if favorited //////////////////
            let selectedFavorite = UIImage(named: "GoldStar") as UIImage!
            let notFavorite = UIImage(named: "FavoriteStar") as UIImage!
            let favURL: String = feeds[indexPath.row].objectForKey("link") as String
            var myFav = myTitle
            let fetchRequestTwo = NSFetchRequest(entityName:"Favorite")
            var favNames: [String] = []
            if let favs = moc.executeFetchRequest(fetchRequestTwo, error: nil) as? [Favorite] {
                favNames = favs.map { $0.favoriteTitle }
            }
            if contains(favNames, myFav){
                cell.favorite.setImage(selectedFavorite, forState: .Normal)
            }else{
                cell.favorite.setImage(notFavorite, forState: .Normal)
            }
            
            
            ////////////////// End (Return cell) //////////////////
            
        } else{
            
            ////////////////// Marked for sidebar index that is favorites //////////////////

            
        var favoriteNames: [String] = []
        var favoriteLink: [String] = []
        var favoriteDesc: [String] = []

        let moc = SwiftCoreDataHelper.managedObjectContext()
        let fetchRequestFav = NSFetchRequest(entityName: "Favorite")
        let sortDescriptor = NSSortDescriptor(key: "favoriteTitle", ascending: true)
        fetchRequestFav.sortDescriptors = [sortDescriptor]
        if let favsLoad = moc.executeFetchRequest(fetchRequestFav, error: nil) as? [Favorite]{
            favoriteNames = favsLoad.map { $0.favoriteTitle}}
        if let favsLoad = moc.executeFetchRequest(fetchRequestFav, error: nil) as? [Favorite]{
            favoriteLink = favsLoad.map { $0.favoriteLinks}}
        if let favsLoad = moc.executeFetchRequest(fetchRequestFav, error: nil) as? [Favorite]{
            favoriteDesc = favsLoad.map { $0.favoriteDesc}}
            
            if favoriteNames.count > 0{
            
            cell.detailTextLabel?.numberOfLines = 3
            cell.title.text = favoriteNames[indexPath.row]
            cell.link.text = favoriteLink[indexPath.row]
            cell.subtext.text = favoriteDesc[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.Blue
            cell.favorite.tag = indexPath.row
            
            ////////////////// Returns checkmark if read //////////////////
            
            //sets up core data into array
            var myTitle = favoriteNames[indexPath.row]
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
            
                ////////////////// Returns goldstar if favorited //////////////////
            let selectedFavorite = UIImage(named: "GoldStar") as UIImage!
            let notFavorite = UIImage(named: "FavoriteStar") as UIImage!
            let favURL = favoriteLink[indexPath.row]
            var myFav = myTitle
            let fetchRequestTwo = NSFetchRequest(entityName:"Favorite")
            var favNames: [String] = []
            if let favs = moc.executeFetchRequest(fetchRequestTwo, error: nil) as? [Favorite] {
                favNames = favs.map { $0.favoriteTitle }
            }
            if contains(favNames, myFav){
                cell.favorite.setImage(selectedFavorite, forState: .Normal)
            }else{
                cell.favorite.setImage(notFavorite, forState: .Normal)
            }
            
            }else{
                //Blank because 0 articles are favorited!
            }
            
            ////////////////// End (Return cell) //////////////////
            

        }

        return cell
    }
    
    
        
      override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var accessoryType: UITableViewCellAccessoryType;()

        ///Gets url from feed
        var fNames: [String] = []
        var fLink: [String] = []
        var fDesc: [String] = []
        var clean: String
        var mTitle: String
        
        
        if sidebarindex != 1{
            
        let selectedFURL: String = feeds[indexPath.row].objectForKey("link") as String
        let selectedTitle: String = feeds[indexPath.row].objectForKey("title") as String
            //Cleans URL
        var dirty = selectedFURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        clean = dirty!.stringByReplacingOccurrencesOfString(
            "%0A",
            withString: "",
            options: .RegularExpressionSearch)
            
        } else {
            
            let moc = SwiftCoreDataHelper.managedObjectContext()
            let fetchRequestFav = NSFetchRequest(entityName: "Favorite")
            let sortDescriptor = NSSortDescriptor(key: "favoriteTitle", ascending: true)
            fetchRequestFav.sortDescriptors = [sortDescriptor]
            if let favsLoad = moc.executeFetchRequest(fetchRequestFav, error: nil) as? [Favorite]{
                fNames = favsLoad.map { $0.favoriteTitle}}
            if let favsLoad = moc.executeFetchRequest(fetchRequestFav, error: nil) as? [Favorite]{
                fLink = favsLoad.map { $0.favoriteLinks}}
            //Cleans URL
            var mTitle = fNames[indexPath.row]
            var dirty = fLink[indexPath.row].stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            clean = dirty!.stringByReplacingOccurrencesOfString(
                "%0A",
                withString: "",
                options: .RegularExpressionSearch)
            
        }
        var con = KINWebBrowserViewController()
        

        
        //Creates usuable url
        var URL = NSURL(string: clean)
        con.loadURL(URL!)
        
        self.navigationController?.pushViewController(con, animated: true)

        //coredata
        let moc = SwiftCoreDataHelper.managedObjectContext()
        let read = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Read), managedObjectConect: moc) as Read
        if sidebarindex != 1{

        read.readName = feeds[indexPath.row].objectForKey("title") as String
        } else{
        read.readName = fNames[indexPath.row]
        }
        SwiftCoreDataHelper.saveManagedObjectContext(moc)
        
        //reload table to show check mark (Refresh core data)
        self.tableView.reloadData()

}

}

