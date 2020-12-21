//
//  UIViewController.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/19.
//

import UIKit

extension UIViewController{
    
    func getDirectoryPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // save data
    func saveData(fileName: String, Object: Any) -> Bool {
        let filePath = self.getDirectoryPath().appendingPathComponent(fileName)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: Object, requiringSecureCoding: true)
            try data.write(to: filePath)
            
            return true
        } catch {
            print("error occured when saving data: \(error.localizedDescription)")
            print(error)
        }
        return false
    }
    
    // load data
    func getData(fileName: String) -> Any? {
        let filePath = self.getDirectoryPath().appendingPathComponent(fileName)
        print(filePath)
        do {
            let data = try Data(contentsOf: filePath)
            let object = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            return object
        } catch  {
            print("error occured when loading data: \(error.localizedDescription)")
        }
        return nil
    }
}
