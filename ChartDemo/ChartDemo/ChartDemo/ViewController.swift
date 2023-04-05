//
//  ViewController.swift
//  ChartDemo
//
//  Created by Vignesh Kumar Subramaniam on 28/04/22.
//

import UIKit
import ChartLib
class NamedArray<T>
{
    var Title:String = ""
    var Items:[T] = []
    init(title:String,items:[T]) {
        self.Title = title
        self.Items = items
    }
}
class DataSource
{
    static var pieChartArray:Array<StudentMarks> = [
        StudentMarks(total: 3,name: "Apr",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 50),
                        SubjectMark(name: "Che", mark: 20),
                        SubjectMark(name: "Math", mark: 40),
                        SubjectMark(name: "Biology", mark: 90),
                        SubjectMark(name: "Englis", mark: 30),
                     ]),
        StudentMarks(total: 8,name: "May",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 35),
                        SubjectMark(name: "Che", mark: 50),
                        SubjectMark(name: "Math", mark: 44),
                        SubjectMark(name: "Biology", mark: 43),
                        SubjectMark(name: "Englis", mark: 89),
                     ]),
        StudentMarks(total: 4,name: "Jun",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 34),
                        SubjectMark(name: "Che", mark: 56),
                        SubjectMark(name: "Math", mark: 77),
                        SubjectMark(name: "Biology", mark: 88),
                        SubjectMark(name: "Englis", mark: 10),
                     ]),
        StudentMarks(total: 7,name: "Jul",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 20),
                        SubjectMark(name: "Che", mark: 22),
                        SubjectMark(name: "Math", mark: 43),
                        SubjectMark(name: "Biology", mark: 56),
                        SubjectMark(name: "Englis", mark: 77),
                     ]),
        StudentMarks(total: 1,name: "Aug",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 66),
                        SubjectMark(name: "Che", mark: 78),
                        SubjectMark(name: "Math", mark: 50),
                        SubjectMark(name: "Biology", mark: 83),
                        SubjectMark(name: "Englis", mark: 47),
                     ]),
        StudentMarks(total:8,name:"Sep",
                     subjects: [
                        SubjectMark(name: "Phys", mark: 70),
                        SubjectMark(name: "Che", mark: 44),
                        SubjectMark(name: "Math", mark: 22),
                        SubjectMark(name: "Biology", mark: 33),
                        SubjectMark(name: "Englis", mark: 91),
                     ])
    ]
    static var firstUnOrderedArray:Array<NamedArray<StockStatus>> = [
        NamedArray<StockStatus>(title: "Company_Google", items: [
            StockStatus(price: 4,pricemonth: "Apr"),
            StockStatus(price: 9,pricemonth: "May"),
            StockStatus(price: 2,pricemonth: "Jun"),
            StockStatus(price: 7,pricemonth: "Jul"),
            StockStatus(price: 5,pricemonth: "Aug"),
            StockStatus(price:1,pricemonth:"Sep")
        ]),
        NamedArray<StockStatus>(title: "Apple", items: [
            StockStatus(price: 10,pricemonth: "Apr"),
            StockStatus(price: 3,pricemonth: "May"),
            StockStatus(price: 9,pricemonth: "Jun"),
            StockStatus(price: 3,pricemonth: "Jul"),
            StockStatus(price: 8,pricemonth: "Aug"),
            StockStatus(price:5,pricemonth:"Sep"),
            StockStatus(price:7,pricemonth:"Oct")
        ])
    ]
    static var secondUnOrderedArray:Array<NamedArray<StockStatus>> = [
        NamedArray<StockStatus>(title: "Google", items: [
            StockStatus(price: 10,pricemonth: "Apr"),
            StockStatus(price: 2,pricemonth: "May"),
            StockStatus(price: 9,pricemonth: "Jun"),
            StockStatus(price: 3,pricemonth: "Jul"),
            StockStatus(price: 8,pricemonth: "Aug"),
            StockStatus(price:5,pricemonth:"Sep"),
            StockStatus(price:7,pricemonth:"Oct")
        ]),
        NamedArray<StockStatus>(title: "Apple", items: [
            StockStatus(price: 5,pricemonth: "Apr"),
            StockStatus(price: 9,pricemonth: "May"),
            StockStatus(price: 2,pricemonth: "Jun"),
            StockStatus(price: 7,pricemonth: "Jul"),
            StockStatus(price: 5,pricemonth: "Aug"),
            StockStatus(price:1,pricemonth:"Sep")
        ])
    ]
    static var firstArray:Array<NamedArray<StockStatus>> = [
        NamedArray<StockStatus>(title: "Google", items: [
            StockStatus(price: 12,pricemonth: "Apr"),
            StockStatus(price: 38,pricemonth: "May"),
            StockStatus(price: -41,pricemonth: "Jun"),
            StockStatus(price: 72,pricemonth: "Jul"),
            StockStatus(price: 11,pricemonth: "Aug"),
            StockStatus(price:82,pricemonth:"Sep")
        ]),
        NamedArray<StockStatus>(title: "Apple", items: [
            StockStatus(price: 22,pricemonth: "Apr"),
            StockStatus(price: 39,pricemonth: "May"),
            StockStatus(price: -24,pricemonth: "Jun"),
            StockStatus(price: 29,pricemonth: "Jul"),
            StockStatus(price: 31,pricemonth: "Aug"),
            StockStatus(price:42,pricemonth:"Sep")
        ]),
        NamedArray<StockStatus>(title: "Microsoft", items: [
            StockStatus(price: -70,pricemonth: "Apr"),
            StockStatus(price: 56,pricemonth: "May"),
            StockStatus(price: 77,pricemonth: "Jun"),
            StockStatus(price: 66,pricemonth: "Jul"),
            StockStatus(price: 10,pricemonth: "Aug"),
            StockStatus(price:33,pricemonth:"Sep")
        ])
    ]
    static var secondArray:Array<NamedArray<StockStatus>> = [
        NamedArray<StockStatus>(title: "Google", items: [
            StockStatus(price: 121,pricemonth: "Apr"),
            StockStatus(price: 626,pricemonth: "May"),
            StockStatus(price: 415,pricemonth: "Jun"),
            StockStatus(price: 296,pricemonth: "Jul"),
            StockStatus(price: 334,pricemonth: "Aug"),
            StockStatus(price:42,pricemonth:"Sep")
        ]),
        NamedArray<StockStatus>(title: "Apple", items: [
            StockStatus(price: 842,pricemonth: "Apr"),
            StockStatus(price: 282,pricemonth: "May"),
            StockStatus(price: 441,pricemonth: "Jun"),
            StockStatus(price: 71,pricemonth: "Jul"),
            StockStatus(price: 512,pricemonth: "Aug"),
            StockStatus(price:282,pricemonth:"Sep")
        ]),
        NamedArray<StockStatus>(title: "Microsoft", items: [
            StockStatus(price: 203,pricemonth: "Apr"),
            StockStatus(price: 101,pricemonth: "May"),
            StockStatus(price: 143,pricemonth: "Jun"),
            StockStatus(price: 435,pricemonth: "Jul"),
            StockStatus(price: 91,pricemonth: "Aug"),
            StockStatus(price:128,pricemonth:"Sep")
        ])
    ]
}
class StockStatus
{
    public let month:String
    public let sharePrice:Float
    init(price:Float,pricemonth:String) {
        self.sharePrice = price
        self.month = pricemonth
    }
}
class StudentMarks
{
    public let name:String
    public let total:Int
    public var subjectMarks:[SubjectMark] = []
    init(total:Int,name:String,subjects:[SubjectMark]) {
        self.total = total
        self.name = name
        self.subjectMarks = subjects
    }
}
class SubjectMark
{
    public let name:String
    public let mark:Int
    init(name:String,mark:Int) {
        self.mark = mark
        self.name = name
    }
}
class ViewController: UIViewController,ChartDataSource,BarChartDataSource,LineChartDataSource,LegendDataSource {
    func legendOfElementAt(group: Int) -> LegendInfo {
        let red = CGFloat(125 + ((group+10)*211) % 230)/CGFloat(255)
        let blue = CGFloat(125 + ((group+5)*173) % 230)/CGFloat(255)
        let gree = CGFloat(125 + ((group+7)*127) % 230)/CGFloat(255)
        let clr = UIColor(red: red, green: blue, blue: gree, alpha: 1)
        return LegendInfo(_color: clr, _title: "\(currentArray?[group].Title ?? "\(group)")")
    }
    
    func colorOfElementAt(group: Int) -> CGColor {
        let red = CGFloat(125 + ((group+10)*211) % 230)/CGFloat(255)
        let blue = CGFloat(125 + ((group+5)*173) % 230)/CGFloat(255)
        let gree = CGFloat(125 + ((group+7)*127) % 230)/CGFloat(255)
        return UIColor(red: red, green: blue, blue: gree, alpha: 1).cgColor
    }
    
    func colorOfElementAt(group: Int, index: Int) -> CGColor {
        let red = CGFloat(125 + ((group+10)*211) % 230)/CGFloat(255)
        let blue = CGFloat(125 + ((group+5)*173) % 230)/CGFloat(255)
        let gree = CGFloat(125 + ((group+7)*127) % 230)/CGFloat(255)
        return UIColor(red: red, green: blue, blue: gree, alpha: 1).cgColor
    }
    
//    func numberOfItemsFor(selectionList:[Int],index:Int) -> Int
//    func valueAt(selectionList:[Int],selection:Int, of index:Int)->Double
//    func shouldSelectValeAt(selectionList:[Int],index:Int)->Bool
    
    @IBOutlet weak var barChart: BarChart!
    @IBOutlet weak var lineChart: LineChart!
    @IBOutlet weak var isOrderedSwitch: UISwitch!
    
    @IBOutlet weak var stackedBarChart: StackedBarChart!
    @IBOutlet weak var optionSwitch: UISwitch!
    
    var currentArray:Array<NamedArray<StockStatus>>?
    
    
    
    
    func numberOfItems() -> Int {
        return currentArray?.count ?? 0;
    }
    
    @IBAction func isOrdererdSwitched(_ sender: UISwitch) {
        currentArray = optionSwitch.isOn ? (isOrderedSwitch.isOn ? DataSource.firstArray:DataSource.firstUnOrderedArray) : (isOrderedSwitch.isOn ?  DataSource.secondArray:DataSource.secondUnOrderedArray);
        barChart?.reloadData()
        lineChart?.reloadData()
        stackedBarChart.reloadData()
    }
    @IBAction func onoptionswitched(_ sender: UISwitch) {
        currentArray = optionSwitch.isOn ? (isOrderedSwitch.isOn ? DataSource.firstArray:DataSource.firstUnOrderedArray) : (isOrderedSwitch.isOn ?  DataSource.secondArray:DataSource.secondUnOrderedArray);
        barChart?.reloadData()
        lineChart?.reloadData()
        stackedBarChart.reloadData()
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
        barChart?.barChartSource = self
        lineChart?.lineChartSource = self
        stackedBarChart.barChartSource = self;
        lineChart.legendDataSource = self
        barChart.legendDataSource = self
        stackedBarChart.legendDataSource = self;
        // Do any additional setup after loading the view.
    }
    
}

