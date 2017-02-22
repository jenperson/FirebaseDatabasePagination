//
//  ViewController.swift
//  TestingFirebaseQuery
//
//  Created by Jennifer Person on 2/19/17.
//  Copyright © 2017 Jennifer Person. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var data : [String] = []
    var ref: FIRDatabaseReference!
    var _refHandle: FIRDatabaseHandle!
    //var query: FIRDatabaseQuery!
    var startKey : String?
    var count = 3
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableViewFirst()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isLoading = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureTableViewFirst() {
        isLoading = true
        ref = FIRDatabase.database().reference()
        var query = ref.child("values").queryOrderedByKey()
        
       /* if startKey != nil {
            print("startKey: \(startKey)")
            data.removeLast()
            print("last data: \(data.last)")
            query = query.queryStarting(atValue: startKey)
           // count += 1
            
        }*/
        query.queryLimited(toFirst: UInt(count-1)).observe(.childAdded, with: { (snapshot) -> Void in
            guard var children = snapshot.children.allObjects as? [FIRDataSnapshot] else {
                // Handle error
                return
            }
            
            // with each child found, the start key changes to that child's  value
            self.startKey = snapshot.key
            print("startkey \(self.startKey)")
            
            if self.startKey != nil && !children.isEmpty {
                children.removeFirst()
            }
            self.data.append(snapshot.value as! String)
            self.tableView.insertRows(at: [IndexPath(row: self.data.count-1, section: 0)], with: .automatic)
                           // self.tableView.reloadData()
        })

        

    }
    
    func configureTableView() {
        isLoading = true
        ref = FIRDatabase.database().reference()
        var query = ref.child("values").queryOrderedByKey()
        
        if startKey != nil {
            print("startKey: \(startKey)")
            data.removeLast()
            tableView.reloadData()
            print("last data: \(data.last)")
            query = query.queryStarting(atValue: startKey)
        }
        query.queryLimited(toFirst: UInt(count)).observe(.childAdded, with: { (snapshot) -> Void in
            guard var children = snapshot.children.allObjects as? [FIRDataSnapshot] else {
                // Handle error
                return
            }
            
            self.startKey = snapshot.key
            print("startkey \(self.startKey)")
            
            if self.startKey != nil && !children.isEmpty {
                children.removeFirst()
                
            }
            self.data.append(snapshot.value as! String)
            self.tableView.insertRows(at: [IndexPath(row: self.data.count-1, section: 0)], with: .automatic)
        })

        isLoading = false

    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //configureTableView()
        cell.textLabel?.text = data[indexPath.item]
        
        /*
 // See if we need to load more species
 let rowsToLoadFromBottom = 5;
 let rowsLoaded = species.count
 if (!self.isLoadingSpecies && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
 let totalRows = self.speciesWrapper?.count ?? 0
 let remainingSpeciesToLoad = totalRows - rowsLoaded;
 if (remainingSpeciesToLoad > 0) {
 self.loadMoreSpecies()
 }
 }*/
        
        /*let rowsToLoadFromBottom = 5
        let rowsLoaded = data.count
        if (!isLoading && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
            configureTableView()
        }*/
 
        return cell
    }
 
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height)) {
            //user has scrolled to the bottom
            if (!isLoading) {
                print("bottom")
            }
        }
    }*/
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView == tableView) {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if !isLoading {
                    isLoading = true
                    configureTableView()
                }
            }
        }
    }

}
