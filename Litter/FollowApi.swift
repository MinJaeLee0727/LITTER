//
//  FollowApi.swift
//  Litter
//
//  Created by X3non0727 on 01/15/18.
//  Copyright © 2018 X3non0727. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FollowApi {
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    func followUserAction(withUser id: String) {
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    if let value = dict[key] as? [String: Any] {
                        let timestampPost = value["timestamp"] as! Int
                        Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).setValue(["timestamp": timestampPost])
                    }
                    
                }
            }
        })
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(true)
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child("\(id)-\(Api.User.CURRENT_USER!.uid)")
        newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "objectId": Api.User.CURRENT_USER!.uid, "type": "follow", "timestamp": timestamp])

    }
    
//    func followHashAction(withUser )
    
    func unFollowAction(withUser id: String) {
        
        Api.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        })
        
        REF_FOLLOWERS.child(id).child(Api.User.CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(Api.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
        
        let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(id).child("\(id)-\(Api.User.CURRENT_USER!.uid)")
        newNotificationReference.setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        })
    }
    
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })

    }
    
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
        
    }
    
}
