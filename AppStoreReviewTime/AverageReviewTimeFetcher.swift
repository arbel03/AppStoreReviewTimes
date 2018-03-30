//
//  AverageReviewTimeFetcher.swift
//  AppStoreReviewTime
//
//  Created by Arbel Israeli on 21/08/2016.
//  Copyright © 2016 arbel03. All rights reserved.
//

import Foundation

enum PlatformType: String {
    case iOS
    case macOS
}

struct ReviewTime {
    var type: PlatformType
    var averageTime: Int
}

protocol ReviewTimeDelegate {
    func updateReviewTime(reviewTime: ReviewTime)
    func error(message: String)
}

class ReviewTimesFetcher {
    var delegate: ReviewTimeDelegate!
    init(delegate: ReviewTimeDelegate) {
        self.delegate = delegate
    }
    
    //Downloading web content and fetching the review times
    func getTime() {
        let url = NSURL(string: "http://www.appreviewtimes.com/")
		let dataTask = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
            if error == nil {
				let htmlString = String(data: data!, encoding: String.Encoding.utf8)
				self.parseHTMLToReviewTimes(html: htmlString!, platform: .iOS)
				self.parseHTMLToReviewTimes(html: htmlString!, platform: .macOS)
            } else {
				DispatchQueue.main.async {
					self.delegate.error(message: error!.localizedDescription)
				}
            }
        }
        dataTask.resume()
    }
    
    func parseHTMLToReviewTimes(html: String, platform: PlatformType) {
        //Splitting the html by the relevant string per each platform, splitting by day and not days since if the average time is more than 1 day the site adds an 's'
        let platformStringToSplit = [
            PlatformType.iOS.rawValue : "<h4 class=\"ios\" data-target=\".review.ios\"><strong>iOS App Store</strong> ",
            PlatformType.macOS.rawValue : "<h4 class=\"mac\" data-target=\".review.mac\"><strong>Mac App Store</strong> "
        ]
    
        //Doing some html splitting, no need to worry about that...
		let htmlAverage = html.components(separatedBy: platformStringToSplit[platform.rawValue]!)
        if htmlAverage.count > 1 {
			let htmlAverageTrimmed = htmlAverage[1].components(separatedBy: " day")
            if htmlAverageTrimmed.count >= 1 {
                guard let htmlInt = Int(htmlAverageTrimmed[0]) else {
					DispatchQueue.main.async {
						self.delegate.error(message: "Wasn't able to fetch review time")
					}
                    return
                }
				DispatchQueue.main.async {
					self.delegate.updateReviewTime(reviewTime: ReviewTime(type: platform, averageTime: htmlInt))
				}
                return
            }
        }
		DispatchQueue.main.async {
			self.delegate.error(message: "An unknown error occurred")
		}
    }
}
