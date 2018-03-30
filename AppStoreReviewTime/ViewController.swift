//
//  ViewController.swift
//  AppStoreReviewTime
//
//  Created by Arbel Israeli on 20/08/2016.
//  Copyright © 2016 arbel03. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController {
    
    @IBOutlet var macOSReviewTimeContainer: UIView!
    @IBOutlet var iOSReviewTimeContainer: UIView!
    @IBOutlet weak var reviewTimeContainer: UIView!
    
    @IBOutlet weak var macOSLabel: UILabel!
    @IBOutlet weak var macOSDaysLabel: UILabel!
    @IBOutlet weak var iOSLabel: UILabel!
    @IBOutlet weak var iOSDaysLabel: UILabel!
    @IBOutlet weak var contributeButton: UIButton!
    
    var activityIndicator = UIActivityIndicatorView()
    
    var showingIOS = true {
        didSet {
			UIView.animate(withDuration: 0.5, animations: {
                self.contributeButton.center.y += 50
                }) { (_) in
					self.contributeButton.setTitle(self.showingIOS ? "Contribute iOS" : "Contribute MacOS", for: .normal)
            }
			UIView.animate(withDuration: 0.5, delay: 0.6, options: [], animations: {
                self.contributeButton.center.y -= 50
                }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Adding a gesture recognizer so we can transition between the views nicely
        reviewTimeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchView)))
        
        //Setting the activity indicator
        activityIndicator.frame = self.view.frame
        activityIndicator.hidesWhenStopped = true
		activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		activityIndicator.color = UIColor.white
        reviewTimeContainer.addSubview(activityIndicator)
		reviewTimeContainer.bringSubview(toFront: activityIndicator)
        
        //Fetching review times
        let timeFetcher = ReviewTimesFetcher(delegate: self)
        timeFetcher.getTime()
        activityIndicator.startAnimating()
        
        //Starting the network spinner
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    @IBAction func contributeReviewTime() {
		let alert = UIAlertController(title: contributeButton.titleLabel!.text, message: "Enter the amout of days it took your app to get approved", preferredStyle: .alert)
		alert.addTextField { (textField) in
            textField.placeholder = "eg. 3"
        }
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != nil {
                if let days = Int(textField.text!) {
					self.dismiss(animated: true, completion: nil)
					self.contribute(days: days)
                }
            }
        }))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
    }
    
    func contribute(days: Int) {
        let tweetVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		tweetVC?.setInitialText((showingIOS ? "#iosreviewtime" : "#macreviewtime") + " \(days) days")
		self.present(tweetVC!, animated: true, completion: nil)
    }
    
    func switchView() {
		UIView.transition(from: showingIOS ? iOSReviewTimeContainer : macOSReviewTimeContainer, to: showingIOS ? macOSReviewTimeContainer : iOSReviewTimeContainer, duration: 0.5, options: [ showingIOS ? .transitionFlipFromRight : .transitionFlipFromLeft, .showHideTransitionViews]){ (finished) in
            print(self.showingIOS)
        }
        self.showingIOS = !self.showingIOS
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reviewTimeContainer.layer.cornerRadius = reviewTimeContainer.bounds.height/2
        macOSReviewTimeContainer.layer.cornerRadius = reviewTimeContainer.layer.cornerRadius
        iOSReviewTimeContainer.layer.cornerRadius = reviewTimeContainer.layer.cornerRadius
    }
}

extension ViewController: ReviewTimeDelegate {
    func updateReviewTime(reviewTime: ReviewTime) {
        switch reviewTime.type {
        case .iOS:
            //Setting the average days
            iOSLabel.text = "\(reviewTime.averageTime)"
            if reviewTime.averageTime > 1 {
                //Setting the label to days if the average review time is more than 1 day
                iOSDaysLabel.text = "Days"
            }
        case .macOS:
            macOSLabel.text = "\(reviewTime.averageTime)"
            if reviewTime.averageTime > 1 {
                macOSDaysLabel.text = "Days"
            }
        }
        
        activityIndicator.stopAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func error(message: String) {
		contributeButton.isEnabled = false
        activityIndicator.stopAnimating()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
		let alertController = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
    }
}


