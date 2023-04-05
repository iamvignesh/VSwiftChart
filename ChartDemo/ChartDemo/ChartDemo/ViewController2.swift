//
//  ViewController2.swift
//  ChartDemo
//
//  Created by Vignesh Kumar Subramaniam on 16/10/22.
//

import Foundation
import UIKit
import ChartLib
public protocol Keyable
{
    associatedtype Anyname:PichartDataSource
    func Sample()
}
class Man:Keyable
{
    typealias Anyname = ViewController2
    
    func Sample() {
        
    }
    typealias Mark = Int;
    
    var bluw:Mark?
    var yellow:Mark?
}
class ViewController2:UIViewController,PichartDataSource,BubbleDataSource
{
    func getCount() -> Int {
        return 10;
    }
    
    func getData(index: Int) -> BubbleData {
        var data = BubbleData()
        data.X = CGFloat(Int.random(in: 0...10))
        data.Y = CGFloat(Int.random(in: 0...10))
        data.V = CGFloat(Int.random(in: 1...20))
        return data;
    }
    
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var isOrderedSwitch: UISwitch!
    
    @IBOutlet weak var optionSwitch: UISwitch!
    @IBOutlet weak var bubbleChart: BubbleChart!
    @IBAction func isOrdererdSwitched(_ sender: UISwitch) {
        currentArray = optionSwitch.isOn ? (isOrderedSwitch.isOn ? DataSource.firstArray:DataSource.firstUnOrderedArray) : (isOrderedSwitch.isOn ?  DataSource.secondArray:DataSource.secondUnOrderedArray);
        pieChart?.reloadData()
        bubbleChart.reloadData()
    }
    @IBAction func onoptionswitched(_ sender: UISwitch) {
        currentArray = optionSwitch.isOn ? (isOrderedSwitch.isOn ? DataSource.firstArray:DataSource.firstUnOrderedArray) : (isOrderedSwitch.isOn ?  DataSource.secondArray:DataSource.secondUnOrderedArray);
        pieChart?.reloadData()
        
        bubbleChart.reloadData()
    }
    
    
    
//    func numberOfItemsFor(selectionList:[Int],index:Int) -> Int
//    func valueAt(selectionList:[Int],selection:Int, of index:Int)->Double
//    func shouldSelectValeAt(selectionList:[Int],index:Int)->Bool
    
   
    
    var currentArray:Array<NamedArray<StockStatus>>?
    
    
    
    
    func numberOfItems() -> Int {
        return currentArray?.count ?? 0;
    }
    
    
    func valueOfElementAt(group:Int, index: Int) -> Float {
        return currentArray?[group].Items[index].sharePrice ?? 0;
    }
    func numberOfGroups() -> Int {
        return currentArray?.count ?? 0;
    }
    
    func numberOfItemsFor(group: Int) -> Int {
        return currentArray?[group].Items.count ?? 0;
    }
    
    func StringAt(index: Int) -> String {
        return currentArray?.sorted(by: {$0.Items.count>=$1.Items.count}).first?.Items[index].month ?? String(index)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChart?.dataSource = self
        bubbleChart.bubbleDataSource = self;
        bubbleChart?.reloadData()
        // Do any additional setup after loading the view.
    }
    func numberOfItemsFor(selectionList:[Int],selectionIndex:Int) -> Int {
        if(selectionList.count == 0)
        {
            return DataSource.pieChartArray.count
        }
        else
        {
            if(selectionList.count==1)
            {
                let marks = selectionList[selectionIndex];
                return DataSource.pieChartArray[marks].subjectMarks.count
            }
            else
            {
                return 5
            }
        }
    }
    func valueAt(selectionList:[Int],selectionIndex:Int, of index:Int)->Double {
        if(selectionList.count == 0)
        {
            return Double(DataSource.pieChartArray[index].total)
        }
        else
        {
            if(selectionList.count==1)
            {
                let marks = selectionList[selectionIndex];
                return Double(DataSource.pieChartArray[marks].subjectMarks[index].mark);
            }
            else
            {
                return Double(Int.random(in: 40...80))
            }
        }
    }
    
    func hasChildren(selectionList:[Int],index:Int)->Bool {
        if(selectionList.count == 0)
        {
            return true;
        }
        else
        {
            if(index < 7)
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
}
