//
//  Extensions.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 03/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        //check ada cachenya atau gak - dilakukan saat first launch
        if let chachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = chachedImage
            return
        }
        
        // buat download imagenya klo cachenya ga ada
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error while downloading profile image")
            }
                
            else if error == nil {
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                    
                    
                }
            }
            }.resume()
    }
    
}
