//
//  ViewController.swift
//  IntelAnalysis
//
//  Created by Mary Gerina on 2/7/19.
//  Copyright © 2019 Mary Gerina. All rights reserved.
//

import Cocoa
import Charts

class ViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var timeSeriesRepresentationChart: LineChartView!
    @IBOutlet weak var dText: NSTextFieldCell!
    
    var filename_field: String!
    let path = "/Users⁩/gmary⁩/Documents⁩/term-1-master⁩/dynamic_series_analysis⁩/"
    var arrayOfTimeSeries = Array<Double>()
    var arrayOfName = Array<String>()
    var selection = Selection(order: 1, capacity: 0)
    var arrayOfSmooth = Array<Double>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeSeriesRepresentationChart.noDataTextColor = .white
    }
    
    @IBAction func openFile(_ sender: NSMenuItem) {
        let dialog = NSOpenPanel()
        
        dialog.directoryURL = NSURL.fileURL(withPath: path, isDirectory: true)
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["dat", "csv"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                filename_field = path
                arrayOfTimeSeries = []
                arrayOfName = []
                arrayOfSmooth = []
                openAndRead(filePath: result!)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func openAndRead(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            var elements = content.components(separatedBy: "\n")
            elements.remove(at: 0)
            elements.forEach {
                let elem = $0.components(separatedBy: ",")
                
                if let value = Double(elem.last ?? ""), let key = elem.first  {
                    arrayOfTimeSeries.append(value)
                    arrayOfName.append("\(key)")
                }
            }
            
            selection = Selection(order: 1, capacity: 0)
            for item in arrayOfTimeSeries {
                selection.append(item: item)
            }
            
            timeSeriesTabel.reloadData()
            
        representChart(timeSeries: arrayOfTimeSeries, regresion: nil, chart: timeSeriesRepresentationChart)
            
        } catch {
            _ = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    func representChart(timeSeries: Array<Double>, regresion: Array<Double>?, chart: LineChartView){
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        if let reg = regresion {
            let regresionSet = reg.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
            
            let dataSetRegresion = LineChartDataSet(values: regresionSet, label: "b-spline")
            dataSetRegresion.colors = [NSUIColor.red]
            dataSetRegresion.valueColors = [NSUIColor.clear]
            dataSetRegresion.drawCirclesEnabled = false
            dataSetRegresion.mode = .cubicBezier
            data.addDataSet(dataSetRegresion)
        }
        
        chart.data = data
        
        chart.gridBackgroundColor = .red
        chart.legend.textColor = .white
        chart.xAxis.labelTextColor = .white
        chart.leftAxis.labelTextColor = .white
        chart.rightAxis.labelTextColor = .white
    }
    
    func dictionaryToArray(dictionary: Dictionary<String, Double>) -> Array<Double> {
        let array = Array(dictionary.values)
        return array
    }
    
    @IBAction func startProccess(_ sender: Any) {
        let tmp: Int = Int(dText.title) ?? 6
        var pArr:[Double] = []
        let d = tmp
        let count: Int = arrayOfTimeSeries.count / tmp
        for i in 0 ..< count {
            pArr.append(arrayOfTimeSeries[tmp * i])
        }
        for _ in 0 ..< tmp - 1 {
//        if tmp * count < arrayOfTimeSeries.count {
            pArr.append(arrayOfTimeSeries.last!)
        }
        let split = SplineHelper(P: pArr, n: arrayOfTimeSeries.count, d: d)
        var tArray: [Double] = []
        let step = 1.0 / Double(tmp)
        for i in 0 ..< arrayOfTimeSeries.count {
            tArray.append(Double(i + 1) * step)
        }
        arrayOfSmooth = []
        for i in 0 ..< tArray.count {
            arrayOfSmooth.append(split.calcZ(t: tArray[i]))
        }
        timeSeriesTabel.reloadData()
        
        representChart(timeSeries: arrayOfTimeSeries, regresion: arrayOfSmooth, chart: timeSeriesRepresentationChart)
    }
    
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == timeSeriesTabel {
            let numberOfRows:Int = arrayOfTimeSeries.count
            return numberOfRows
        }
        return 0
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersSelectionTable {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
        static let RegressionCell = "RegressionID"
        static let NewTCell = "NewTID"
        static let NewValueCell = "NewValueID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == timeSeriesTabel {
            return loadSelection(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    func loadSelection(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfTimeSeries.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(arrayOfName[row])"
                cellIdentifier = CellIdentifiersSelectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(arrayOfTimeSeries[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                if arrayOfSmooth.count > 0 {
                    text = "\(arrayOfSmooth[row].rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.RegressionCell
                }
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
}


