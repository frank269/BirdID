//
//  BirdInformation.swift
//  BirdID
//
//  Created by Tien Doan on 8/26/19.
//  Copyright © 2019 TienDoan. All rights reserved.
//
import UIKit
import CoreData

struct BirdInfor : Codable {
    let scientific_name : String
    let html_content : String
}

func saveBirdInfo(birds: [BirdInfor]){
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "BirdInformation", in: managedContext)!
    
    for b in birds{
        let bird = NSManagedObject(entity: entity, insertInto: managedContext)
        bird.setValue(b.scientific_name, forKey: "scientific_name")
        bird.setValue(b.html_content, forKey: "html_content")
    }
    
    do{
        try managedContext.save()
    }catch let error as NSError{
        print("Could not save. \(error), \(error.userInfo)")
    }
}

func getDataFromDatabase(){
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BirdInformation")
    
    do{
        
        let datas = try managedContext.fetch(fetchRequest)
        var birds : [BirdInfor] = []
        for d in datas{
            birds
                .append(
                    BirdInfor(
                        scientific_name: d.value(forKey: "scientific_name") as! String,
                        html_content: d.value(forKey: "html_content") as! String)
            )
        }
        listBirdsInfo = birds
    }catch let error as NSError{
        print("Could not fetch. \(error), \(error.userInfo)")
    }
}


func getDataFromApi() {
    guard let url = URL(string: getWoodApi()) else {
        return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        do{
            guard let listbirds = data else {return}
            let birds = try JSONDecoder().decode([BirdInfor].self, from: listbirds)
            saveBirdInfo(birds: birds)
            listBirdsInfo = birds
            IsNotFirstTimeUse = true
        } catch {
            print("Error when download database: \(error)")
        }
    }.resume()
}
