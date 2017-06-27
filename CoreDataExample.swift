//
//  FoodPinModels.swift
//  FoodPin
//
//  Created by chaloemphong on 6/27/2560 BE.
//  Copyright © 2560 chaloemphong. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol FoodPin {
    func insert(foodPin:FoodPinModel) -> Bool
    func update(foodPin:FoodPinModel, key:String) -> Bool
    func findAll() -> [FoodPinModel]
    func findOne(key:String) -> FoodPinModel
    func delete(key:String) -> Bool
}

struct FoodPinModel {
    var name:String!
    var location:String
    var detail:String!
    var image:UIImage!
    
    init(name:String, location:String, detail:String, image:UIImage) {
        self.name = name
        self.location = location
        self.detail = detail
        self.image = image
    }
}

class FoodPinStore: FoodPin {
    
    private func getContext() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    private func resizeImage(MaxSize:CGFloat, image:UIImage) -> UIImage {
        
        let originSize = image.size
        let max = MaxSize
        var newSize:CGSize!
        
        // Agol (1200 / 1600) * newWidht = newHight
        let new = (originSize.height / originSize.width) * max
        newSize = CGSize(width: max, height: new)
        
        let ract = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: ract)
        let images = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return images!
    }
    
    func insert(foodPin: FoodPinModel) -> Bool {
        let context = getContext()
        let insert = NSEntityDescription.insertNewObject(forEntityName: "FoodPins", into: context)
        
        let resize = self.resizeImage(MaxSize: 1000.0, image: foodPin.image)
        let convert = UIImageJPEGRepresentation(resize, 0.8)
        
        insert.setValue(foodPin.name, forKey: "name")
        insert.setValue(foodPin.location, forKey: "location")
        insert.setValue(foodPin.detail, forKey: "detail")
        insert.setValue(convert, forKey: "image")
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func update(foodPin: FoodPinModel, key: String) -> Bool {
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodPins")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate.init(format: "name", key)
        
        let resize = self.resizeImage(MaxSize: 1000.0, image: foodPin.image)
        let convert = UIImageJPEGRepresentation(resize, 0.8)
        
        let result = try! context.fetch(fetch)
        if result.count > 0 {
            for results in result as! [NSManagedObject] {
                
                if results.value(forKey: "name") != nil {
                    results.setValue(foodPin.name, forKey: "name")
                    results.setValue(foodPin.detail, forKey: "detail")
                    results.setValue(foodPin.location, forKey: "location")
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
    
    func findAll() -> [FoodPinModel] {
        
        var models:[FoodPinModel] = []
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FoodPins")
        fetch.returnsObjectsAsFaults = false
        
        do {
            let result = try! context.fetch(fetch)
            
            if result.count > 0 {
                
                for results in result as! [NSManagedObject] {
                    let name = results.value(forKey: "name") as! String
                    let detail = results.value(forKey: "detail") as! String
                    let location = results.value(forKey: "location") as! String
                    let img = results.value(forKey: "image") as! Data
                    let image = UIImage.init(data: img)
                    
                    models.append(FoodPinModel.init(name: name, location: location, detail: detail, image: image!))
                }
            }
        }
        
        return models
    }
    
    func findOne(key:String) -> FoodPinModel {
        var models:[FoodPinModel] = []
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodPins")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate.init(format: "name = %@", key)
        
        let result = try! context.fetch(fetch)
        
        if result.count > 0 {
            for results in result as! [NSManagedObject] {
                if results.value(forKey: "name") != nil {
                    let name = results.value(forKey: "name") as! String
                    let detail = results.value(forKey: "detail") as! String
                    let location = results.value(forKey: "location") as! String
                    let img = results.value(forKey: "image") as! Data
                    let image = UIImage.init(data: img)
                    
                    models.append(FoodPinModel.init(name: name, location: location, detail: detail, image: image!))
                }
            }
            
        }
        
        return models[0]
    }
    
    func delete(key: String) -> Bool {
        let context = getContext()
        let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FoodPins")
        fetch.returnsObjectsAsFaults = false
        fetch.predicate = NSPredicate.init(format: "name", key)
        
        do {
            let result = try! context.fetch(fetch)
            
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
    
}
