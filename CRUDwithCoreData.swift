//
//  pinModels.swift
//  PinFinFood
//
//  Created by chaloemphong on 6/29/2560 BE.
//  Copyright © 2560 chaloemphong. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol PinFinFood {
    func insert(name:String, location:String, detail:String, image:UIImage) -> Bool
    func findAll() -> [foods]
    func findOne(key:String) -> foods
    func delete(key:String) -> Bool
    func update(key:String, name:String, location:String, detial:String, image:UIImage) -> Bool
}

struct foods {
    var name = ""
    var location = ""
    var detail = ""
    var image:UIImage!
}



class PinFood: PinFinFood {
    
    private func getContext() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    private func resizeImage(max:CGFloat, image:UIImage) -> UIImage {
        let originalSize = image.size
        let newSize:CGSize!
        
        // Agol (1200 / 1600) * newWidht = newHight
        let new = (originalSize.height / originalSize.width) * max
        newSize = CGSize(width: max, height: new)
        
        let ract = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: ract)
        let newImages = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImages!
    }
    
    func insert(name: String, location: String, detail: String, image: UIImage) -> Bool {
        let context = getContext()
        let inserts = NSEntityDescription.insertNewObject(forEntityName: "PinFin", into: context)
        
        let resize = resizeImage(max: 1000.0, image: image)
        let convertToData = UIImageJPEGRepresentation(resize, 0.8)
        
        if name != "" {
            inserts.setValue(name, forKey: "name")
            inserts.setValue(location, forKey: "location")
            inserts.setValue(detail, forKey: "detail")
            inserts.setValue(convertToData, forKey: "image")
            
            do {
                try context.save()
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    func findAll() -> [foods] {
        let context = getContext()
        var food:[foods] = []
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinFin")
        fetch.returnsObjectsAsFaults = false
        
        let result = try! context.fetch(fetch)
        if result.count > 0 {
            for results in result as! [NSManagedObject] {
                let name = results.value(forKey: "name")
                let detail = results.value(forKey: "detail")
                let location = results.value(forKey: "location")
                let img = results.value(forKey: "image")
                let image = UIImage(data: img as! Data)
                
                let all = foods.init(name: name as! String, location: location as! String , detail: detail as! String, image: image!)
                food.append(all)
            }
        }
        
        
        return food
    }
    
    func findOne(key:String) -> foods {
        let context = getContext()
        var food:foods!
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinFin")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate.init(format: "name = %@", key)
        
        let result = try! context.fetch(fetch)
        if result.count > 0 {
            for results in result as! [NSManagedObject] {
                let img = results.value(forKey: "image")
                food.name = results.value(forKey: "name") as! String
                food.location = results.value(forKey: "location") as! String
                food.detail = results.value(forKey: "detail") as! String
                food.image = UIImage(data: img as! Data)
            }
        }
        
        return food
    }
    
    
    func delete(key: String) -> Bool {
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PinFin")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate.init(format: "name = %@", key)
        
        let result = try! context.fetch(fetch)
        do {
            if result.count > 0 {
                for results in result as! [NSManagedObject] {
                    if results.value(forKey: "name") != nil {
                        context.delete(results)
                        do {
                            try context.save()
                            return true
                        } catch {
                            return false
                        }
                    }
                }
            }
        }
        return false
    }
    
    func update(key: String, name:String, location:String, detial:String, image:UIImage) -> Bool {
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinFin")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate(format: "name = %@", key)
        
        let resize = self.resizeImage(max: 1000.0, image: image)
        let convert = UIImageJPEGRepresentation(resize, 1.0)
        
        let result = try! context.fetch(fetch)
        if result.count > 0 {
            for results in result as! [NSManagedObject] {
                if results.value(forKey: "name") != nil {
                    results.setValue(name, forKey: "name")
                    results.setValue(location, forKey: "location")
                    results.setValue(detial, forKey: "detail")
                    results.setValue(convert, forKey: "image")
                    
                    do {
                        try context.save()
                        return true
                    } catch {
                        return false
                    }
                }
            }
        }
        
        return false
    }
}




















