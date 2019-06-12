//
//  ParseNewsTableViewController.swift
//  Module-2
//
//  Created by Jan Rombout on 10/06/2019.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Alamofire


class ParseNewsTableViewController: PFQueryTableViewController
{
    
    var segmentedControl:UISegmentedControl?

    override init(style: UITableView.Style, className: String!)
    {
        super.init(style: style, className: className)
        
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 25
        
        self.parseClassName = className
        self.tableView.allowsSelection = true
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        segmentedControl = UISegmentedControl(items: ["All", "Guides", "Interviews"])
        segmentedControl!.addTarget(self, action: #selector(onSegmentedControlValueChanged(segmentedControl:)), for: UIControl.Event.valueChanged)
        segmentedControl!.selectedSegmentIndex = 0
        
        tableView.tableHeaderView = segmentedControl
        
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "cellIdentifier")
    }
    
    @objc func onSegmentedControlValueChanged(segmentedControl:UISegmentedControl)
    {
        self.loadObjects()
    }
    
    override func queryForTable() -> PFQuery<PFObject>
    {
        let query:PFQuery = PFQuery(className:self.parseClassName ?? "")
        
        if segmentedControl != nil && segmentedControl!.selectedSegmentIndex > 0
        {
            query.whereKey("category", equalTo: segmentedControl!.selectedSegmentIndex == 1 ? "Guides" : "Interviews")
        }
        
        if objects != nil && objects!.count == 0
        {
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
        }
        
        query.order(byAscending: "title")
        
        return query
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell?
    {
        var cell:NewsTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as? NewsTableViewCell
        
        if cell == nil
        {
            cell = Bundle.main.loadNibNamed("NewsTableViewCell", owner: self, options: nil)?[0] as? NewsTableViewCell
            
            cell!.thumbnailView?.image = nil
        }
        
        if  let title = object?["title"] as? String,
            let excerpt = object?["excerpt"] as? String,
            let thumbnailURL = object?["thumbnailURL"] as? String
        {
            cell!.titleLabel?.text = title
            cell!.excerptLabel?.text = excerpt
            
            Alamofire.request(thumbnailURL).responseData {
                response in
                
                if let data = response.result.value {
                    cell!.thumbnailView?.image = UIImage(data: data)
                }
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let detailVC:NewsDetailViewController = NewsDetailViewController(nibName: "NewsDetailViewController", bundle:nil)
        
        if  let object = self.object(at: indexPath),
            let title = object["title"] as? String,
            let excerpt = object["excerpt"] as? String,
            let thumbnailURL = object["thumbnailURL"] as? String,
            let articleURL = object["articleURL"] as? String
        {
            let article:Article = Article()
            article.title = title
            article.content = excerpt
            article.thumbnailURL = thumbnailURL
            article.articleURL = articleURL
            
            detailVC.article = article
            detailVC.title = title
        }
        
        navigationController?.pushViewController(detailVC, animated:true)
    }
}
