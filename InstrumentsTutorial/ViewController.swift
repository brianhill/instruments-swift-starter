//
//  ViewController.swift
//  InstrumentsTutorial
//
//  Created by James Frost on 26/02/2015.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let flickr = Flickr()
    private var searches = [FlickrSearchResults]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: nil, action: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? SearchResultsViewController {
            if let indexPath = tableView.indexPathsForSelectedRows!.first {
                destination.searchResults = searches[indexPath.row]
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
}

extension ViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchBar.hidden = true
        activityIndicator.startAnimating()
        
        flickr.searchFlickrForTerm(searchBar.text!) { results, error in
            self.searchBar.hidden = false
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                let alert = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            if let results = results {
                self.searches.append(results)
                self.tableView.insertRowsAtIndexPaths([ NSIndexPath(forRow: self.searches.count-1, inSection: 0) ], withRowAnimation: .Top)
            }
        }
    }
}

extension ViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let searchResult = searches[indexPath.row]
        
        cell.textLabel?.text = searchResult.searchTerm
        cell.detailTextLabel?.text = "(\(searchResult.searchResults.count))"
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            searches.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([ indexPath ], withRowAnimation: .Fade)
        }
    }
}

