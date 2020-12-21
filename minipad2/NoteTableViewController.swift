//
//  NoteTableViewController.swift
//  minipad2
//
//  Created by 灼雪 on 2020/12/9.
//

import UIKit
import os.log


class NoteTableViewController: UITableViewController {
    
    // MARK: - Proporties
    // data
    var allItems = [NoteItem]()
    // path to store data
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let object = self.getData(fileName: "allItems") as? [NoteItem]{
            allItems = object
            print("load data successfully")
        }else {
            print("load data failed")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItemCell", for: indexPath)

        // Configure the cell...
        let cellContent = self.allItems[indexPath.row]
        cell.textLabel?.text = cellContent.createDate
        cell.detailTextLabel?.text = cellContent.noteTitle
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // you should first delete your data and then delete rows from the tableView
            allItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if self.saveData(fileName: "allItems", Object: allItems) {
                print("saved data successfully after deleted data")
            } else{
                print("save failed after deleted data")
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
            
        // segue => view the detail of the noteItem
        let vc = segue.destination as? NewNoteViewController
        switch segue.identifier ?? "" {
        case "Edit":
            os_log("Editing a note.", log:OSLog.default, type: .debug)
            // 设置待会需要显示的界面
            // 当为编辑模式时，未选中表的一个单元，nowIndex是不存在的
            let nowIndex = (self.tableView.indexPathForSelectedRow?.row)!
            vc?.itemViewTitle = self.allItems[nowIndex].noteTitle
            vc?.itemViewCreatedTime = self.allItems[nowIndex].createDate
            vc?.itemViewDetail = self.allItems[nowIndex].noteDetail
            // 把在model中存储的录音名字数据传过去
            vc?.recordNameList = self.allItems[nowIndex].recordNameList ?? [String]()
            // 编辑模式，待会返回的时候不需要更新创建日期
            vc?.nowMode = "Edit"
            vc?.noteID = nowIndex

        case "Add":
            os_log("Adding a new note.", log:OSLog.default, type: .debug)
            // 新建模式，返回的时候要加一个创建日期
            vc?.nowMode = "Add"
            vc?.noteID = self.allItems.count
            vc?.recordNameList = [String]()
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: - Navigation: from any other view to the TableView
    @IBAction func unwindToNoteTableView(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? NewNoteViewController, let newNote = sourceViewController.newNoteItem{
            switch sourceViewController.nowMode {
            case "Edit":
                // update an existing note and reload the tableView
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // update the item(which the created date was not updated)
                    allItems[selectedIndexPath.row] = newNote
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
            case "Add":
                // the location to be inserted in
                let newIndexPath = IndexPath(row: allItems.count, section: 0)
                // add the new note to the data
                allItems.append(newNote)
                // add new note to tableview
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            default:
                fatalError("Unexpected mode: \(String(describing: sourceViewController.nowMode))")
            }
        }
        
        if self.saveData(fileName: "allItems", Object: allItems) {
            print("saved data successfully after added or edited data")
        } else{
            print("save failed after added or edited data")
        }
    }

}
