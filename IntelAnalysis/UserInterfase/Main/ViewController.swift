import Cocoa
import Charts
import Foundation

class ViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var cusumTabel: NSTableView!
    @IBOutlet weak var grshTabel: NSTableView!
    @IBOutlet weak var timeSeriesRepresentationChart: LineChartView!
    @IBOutlet weak var dText: NSTextFieldCell!
    @IBOutlet weak var HText: NSTextFieldCell!
    @IBOutlet weak var GRShButton: NSButton!
    @IBOutlet weak var CusumButton: NSButton!
    
    var filename_field: String!
    var eps = 6.0
    let path = "/Users⁩/gmary⁩/Documents⁩/term-1-master⁩/dynamic_series_analysis⁩/"
    var arrayOfTimeSeries = Array<Double>()
    var arrayOfName = Array<String>()
    var selection = Selection(order: 1, capacity: 0)
    var arrayOfSmooth = Array<Double>()
    var arrayOfCusum = Array<Double>()
    var arrayOfGRSh = Array<Double>()
    var tmp = 1
    let arrayCount = 3
    var kArray:[Double] = []
    
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
    
    func representTransformChart(timeSeries: Array<Double>, points: Array<ChartDataEntry>?, regresion: Array<Double>?, chart: LineChartView){
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        data.addDataSet(dataSet)
        
        if let pointsSet = points {
            let dataPointsSet = LineChartDataSet(values: pointsSet, label: "Points")
            dataPointsSet.colors = [NSUIColor.clear]
            dataPointsSet.valueColors = [NSUIColor.red]
            dataPointsSet.circleColors = [NSUIColor.red]
            data.addDataSet(dataPointsSet)
        }
        
        if let reg = regresion {
            let regresionSet = reg.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
            
            let dataSetRegresion = LineChartDataSet(values: regresionSet, label: "b-spline")
            dataSetRegresion.colors = [NSUIColor.red]
            dataSetRegresion.valueColors = [NSUIColor.clear]
            dataSetRegresion.drawCirclesEnabled = false
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
        tmp = Int(dText.title) ?? 6
        var pArr:[Double] = []
        let d = tmp
        tmp = tmp - 1
        let count: Int = arrayOfTimeSeries.count / tmp

        for i in 0 ..< count {
            pArr.append(arrayOfTimeSeries[tmp * i])
        }
        for _ in 0 ..< tmp {
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
        arrayOfSmooth.append(arrayOfTimeSeries.first!)
        for i in 1 ..< tArray.count - 1 {
            arrayOfSmooth.append(split.calcZ(t: tArray[i]))
        }
        arrayOfSmooth.append(arrayOfTimeSeries.last!)
        
        timeSeriesTabel.reloadData()
        
        representChart(timeSeries: arrayOfTimeSeries, regresion: arrayOfSmooth, chart: timeSeriesRepresentationChart)
    }
    
    @IBAction func startDetection(_ sender: Any) {
        eps = Double(HText.title) ?? 6.0
        if arrayOfSmooth.count > 0 {
            arrayOfCusum = []
            arrayOfGRSh = []
            kArray = createKArray()
            calcCUSUM(array: kArray)
            calcGRSh(array: kArray)
            CusumButton.isHidden = false
            GRShButton.isHidden = false
            representTransformChart(timeSeries: arrayOfSmooth, points: nil, regresion: kArray, chart: timeSeriesRepresentationChart)
        } else {
            _ = AlertHelper().dialogCancel(question: "Error", text: "You need to start with smoothing")
        }
    }
    
    @IBAction func represent(_ sender: NSButton) {
        if sender == CusumButton {
            let points = createPointsCusum()
            representTransformChart(timeSeries: arrayOfSmooth, points: points, regresion: kArray, chart: timeSeriesRepresentationChart)
        }
        if sender == GRShButton {
            let points = createPointsGRSh()
            representTransformChart(timeSeries: arrayOfSmooth, points: points, regresion: kArray, chart: timeSeriesRepresentationChart)
        }
    }
    
    func createKArray() -> [Double] {
        var kArray: [Double] = []
        for _ in 0 ..< arrayCount {
            kArray.append(0)
        }
        for i in arrayCount ..< arrayOfSmooth.count {
            let y = Array(arrayOfSmooth[i - arrayCount ... i])
            let linearReg = LinearRegresion(selection: y)
            let a = linearReg.CalculateB()
            kArray.append(atan(a))
        }
        return kArray
    }
    
    func calcCUSUM(array: [Double]) {
        for i in 0 ..< arrayCount {
            arrayOfCusum.append(0)
        }
        var y = Array(array[0...arrayCount])
        for i in arrayCount ..< array.count {
            let m = calcM(y: y)
            let cusumManager = CUSUM(y: y, m1: m)
            let elem = cusumManager.calcS(t: i - arrayCount)
            arrayOfCusum.append(elem)
            y.append(array[i])
        }
        cusumTabel.reloadData()
    }
    
    func calcM(y: [Double]) -> Double {
        var result = 0.0
        for i in 0 ..< y.count {
            result += y[i]
        }
        result /= Double(y.count)
        return result
    }
    
    func calcGRSh(array: [Double]) {
        for i in 0 ..< arrayCount {
            arrayOfGRSh.append(0)
        }
        var y = Array(array[0...arrayCount])
        for i in arrayCount ..< array.count {
            let grshManager = GRSh(y: y)
            let elem = grshManager.calcW(t: i - arrayCount)
            arrayOfGRSh.append(elem)
            y.append(array[i])
        }
        grshTabel.reloadData()
    }
    
    func createPointsCusum() -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for i in 1 ..< arrayOfCusum.count {
            if CUSUM.getResult(result: arrayOfCusum[i], eps: eps) != CUSUM.getResult(result: arrayOfCusum[i - 1], eps: eps) {
                result.append(ChartDataEntry(x: Double(i), y: arrayOfSmooth[i]))
            }
        }
        return result
    }
    
    func createPointsGRSh() -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for i in 1 ..< arrayOfGRSh.count {
            if CUSUM.getResult(result: arrayOfGRSh[i], eps: eps) != CUSUM.getResult(result: arrayOfGRSh[i - 1], eps: eps) {
                result.append(ChartDataEntry(x: Double(i), y: arrayOfSmooth[i]))
            }
        }
        return result
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == timeSeriesTabel {
            let numberOfRows:Int = arrayOfTimeSeries.count
            return numberOfRows
        }
        if tableView == cusumTabel {
            let numberOfRows:Int = arrayOfCusum.count
            return numberOfRows
        }
        if tableView == grshTabel {
            let numberOfRows:Int = arrayOfGRSh.count
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
    
    fileprivate enum CellIdentifiersDetectionTable {
        static let IndexCell = "IndexID"
        static let ValueCell = "ValueID"
        static let ResultCell = "ResultID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == timeSeriesTabel {
            return loadSelection(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == cusumTabel {
            return loadCusum(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == grshTabel {
            return loadGRSh(tableView, viewFor: tableColumn, row: row)
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
    
    func loadCusum(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfTimeSeries.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(row + 1)"
                cellIdentifier = CellIdentifiersDetectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(arrayOfCusum[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                if arrayOfSmooth.count > 0 {
                    text = "\(CUSUM.getResult(result: arrayOfCusum[row], eps: eps))"
                    cellIdentifier = CellIdentifiersDetectionTable.ResultCell
                }
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadGRSh(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if arrayOfTimeSeries.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(row + 1)"
                cellIdentifier = CellIdentifiersDetectionTable.IndexCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(arrayOfGRSh[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                if arrayOfSmooth.count > 0 {
                    text = "\(GRSh.getResult(result: arrayOfGRSh[row], eps: eps))"
                    cellIdentifier = CellIdentifiersDetectionTable.ResultCell
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


