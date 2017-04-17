//
//  TweetCell.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit


protocol RetweetProtocol  {
    func onRetweet(tweet:Tweet)
}


class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetedIconHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetedHeight: NSLayoutConstraint! //15
    @IBOutlet weak var favHeart: UIButton!
    
    @IBOutlet weak var userProfileImageUrl: UIImageView!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var reTweetCount: UILabel!
    @IBOutlet weak var tweetText: ActiveLabel!
    @IBOutlet weak var tweetedAgo: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRetweeted: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetStack: UIStackView!
    @IBOutlet weak var favStack: UIStackView!
    var delegate:RetweetProtocol?
    var fromAction:Bool = false
    var tweet:Tweet!  {
        didSet {
            if(tweet != nil) {
                layoutTweetText()
                layoutUserDetails()
                layoutFavAndRetweets()
                tweetedAgo.text = "•\(tweet?.timeAgo ?? "")"
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .none
        userName.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func onReply(_ sender: Any) {
        if(delegate != nil ) {
            delegate?.onRetweet( tweet: tweet)
        }
    }
    
    @IBAction func onFav(_ sender: Any) {
        if(!tweet.favorited!) {
           fav()
        }else{
           unfav()
        }
            
    }
    
    
    @IBAction func onRetweet(_ sender: Any) {
        
        if(!tweet.retweeted!) {
            retweet()
        }else{
            unretweet()
        }
    }
    
 
    
    override func prepareForReuse() {
        tweet = nil
        self.favoriteCount.text = ""
        self.reTweetCount.text = ""
        self.favHeart.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        self.reTweetCount.textColor = UIColor.gray
        self.favoriteCount.textColor = UIColor.gray
    }

}
//Rendering and Layout of Cell

extension TweetCell {
    
    func layoutFavAndRetweets(){
        if let retweeteduser = tweet?.retweetUserName {
            userRetweeted.text = retweeteduser + " retweeted"
            retweetedIconHeight.constant = 17
            retweetedHeight.constant = 15
        }else{
            retweetedIconHeight.constant = 0
            retweetedHeight.constant = 0
        }
        
        var retweetedCount = 0
        if( tweet.retweetCount != 0) {
            retweetedCount = tweet.retweetCount
        }
        var favCount = 0
        if( tweet.favouritesCount != 0) {
            favCount = tweet.favouritesCount
        }
        
        favoriteCount.text = favCount != 0 ? "\(favCount)" :""
        reTweetCount.text = retweetedCount != 0 ? "\(retweetedCount)" :""
        makeFavorite(count: favCount, fav: tweet.favorited!)
        makeRetweet(count: retweetedCount, retweeting: tweet.retweeted!)
    }
    
    func layoutUserDetails(){
        userName.text = tweet?.userScreenName
        userId.text = tweet?.userName
        userProfileImageUrl.setImageWith((tweet?.userProfileImage)!)
        userProfileImageUrl.layer.cornerRadius = 5
        userProfileImageUrl.clipsToBounds = true
    }
    
    func layoutTweetText() {
        tweetText.customize { (label) in
            label.text = tweet.text
            if let replyuser = tweet.replyUser?.name  {
                label.text = "Replying to @\(replyuser)" + tweet.text!
            }
            Style.styleTwitterAttributedLabelForCell(label: label)
            
        }
    }
    
    
}



//Retweet Actions

extension TweetCell {
    
    
    func retweet() {
        tweet.reTweet(success: { (tweetArg) in
            let tweetArgToAssign  = tweetArg
            tweetArgToAssign.retweetCount = tweetArgToAssign.retweetCount + 1
            self.tweet  = tweetArgToAssign
            self.tweet.retweeted = true
            self.makeRetweet(count: self.tweet.retweetCount + 1,retweeting: true)
        }, failure: { (error) in
            print("failed to retweet")
        })
        
    }
    
    
    func unretweet() {
        if( self.tweet.retweetCount != 0) {
            tweet.unReTweet(success: { (tweetArg) in
                    let tweetArgToAssign  = tweetArg
                    tweetArgToAssign.retweetCount = tweetArgToAssign.retweetCount - 1
                    self.tweet = tweetArgToAssign
                    self.tweet.retweeted = false
                    self.makeRetweet(count: self.tweet.retweetCount ,retweeting: false)
                
            }, failure: { (error) in
                print("failed to retweet")
            })
        }
    }
    
    func fav() {
        tweet.favorite(success: { (tweetArg) in
            let tweetArgToAssign  = tweetArg
            tweetArgToAssign.favouritesCount = tweetArgToAssign.favouritesCount + 1

            self.tweet = tweetArgToAssign
            self.makeFavorite(count: self.tweet.favouritesCount ,fav: true)
            self.tweet.favorited = true
            
        }, failure: { (error) in
            print("Error in favorite \(error.localizedDescription)")
        })
        
    }
    
    
    func unfav() {
        if( self.tweet.favouritesCount != 0) {
            tweet.unfavorite(success: { (tweetArg) in
                    let tweetArgToAssign  = tweetArg
                    tweetArgToAssign.favouritesCount = tweetArgToAssign.favouritesCount - 1
                    self.tweet = tweetArgToAssign
                    self.makeFavorite(count: self.tweet.favouritesCount,fav: false)
                    self.tweet.favorited = false
                
            }, failure: { (error) in
                print("Error in favorite \(error.localizedDescription)")
            })
        }
    }
    
    
    
    
    
    func makeFavorite(count:Int ,fav:Bool) {
        let countToLabel = count
        let color = fav ? UIColor.red : UIColor.gray
        self.favoriteCount.textColor = color
        let image = fav ? #imageLiteral(resourceName: "favred") : #imageLiteral(resourceName: "favorite")
        self.favoriteCount.text = "\(countToLabel)"
        self.favHeart.setImage(image, for: .normal)
        if(countToLabel == 0) {
            self.favoriteCount.text = ""
        }
        
    }
    
    
    func makeRetweet(count:Int,retweeting:Bool) {
        
        let countToLabel = count
        let color = retweeting ? UIColor.green : UIColor.gray
        self.reTweetCount.textColor = color
        let image = retweeting ? #imageLiteral(resourceName: "retweetgreen") : #imageLiteral(resourceName: "retweet")
        self.reTweetCount.text = "\(countToLabel)"
        self.retweetButton.setImage(image, for: .normal)
        if(countToLabel == 0) {
            self.reTweetCount.text = ""
        }
        
    }


    
}
