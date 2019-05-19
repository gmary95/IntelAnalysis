import Cocoa
import Charts
import Foundation

class ViewController: NSViewController {
    @IBOutlet weak var timeSeriesTabel: NSTableView!
    @IBOutlet weak var cusumTabel: NSTableView!
    @IBOutlet weak var grshTabel: NSTableView!
    @IBOutlet weak var timeSeriesRepresentationChart: LineChartView!
    @IBOutlet weak var gistogramRepresentationChart: BarChartView!
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
    var arrayOfCusum1 = Array<Double>()
    var arrayOfCusum2 = Array<Double>()
    var arrayOfGRSh = Array<Double>()
    var tmp = 1
    let arrayCount = 3
    var kArray:[Double] = []
    var result:[Point] = []
    var intervals:[GistogramModel] = []
    
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
        dataSet.drawCirclesEnabled = false
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
    
    func representTransformChart(timeSeries: Array<Double>, points: Array<ChartDataEntry>?, regresion: Array<ChartDataEntry>?, chart: LineChartView){
        let series = timeSeries.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let dataSet = LineChartDataSet(values: series, label: "Current time series")
        dataSet.colors = [NSUIColor.yellow]
        dataSet.valueColors = [NSUIColor.white]
        dataSet.drawCirclesEnabled = false
        data.addDataSet(dataSet)
        
        if let pointsSet = points {
            let dataPointsSet = LineChartDataSet(values: pointsSet, label: "Points")
            dataPointsSet.colors = [NSUIColor.clear]
            dataPointsSet.valueColors = [NSUIColor.red]
            dataPointsSet.circleColors = [NSUIColor.red]
            data.addDataSet(dataPointsSet)
        }
        
        if let reg = regresion {
            let dataSetRegresion = LineChartDataSet(values: reg, label: "")
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
    
    @IBAction func buildGistogram(_ sender: Any) {
        if result.count > 0 {
            let arrayOfPoints = createArrayGist()
            let points = createPointsGraph(array: result)
            representTransformChart(timeSeries: arrayOfSmooth, points: points, regresion: arrayOfPoints, chart: timeSeriesRepresentationChart)
            createInterval()
            for i in 0 ..< intervals.count {
                var n = 0
                for j in 0 ..< arrayOfSmooth.count {
                    if arrayOfSmooth[j] >= intervals[i].ymin && arrayOfSmooth[j] <= intervals[i].ymax {
                        if j + 1 >= Int(intervals[i].tmin) && j + 1 <= Int(intervals[i].tmax) {
                            n += 1
                        }
                    }
                }
                intervals[i].n = n
            }
            let months = intervals.map { e in return "[\(e.tmin); \(e.tmax)]"}
            let unitsSold = intervals.map {
                e in return Double(e.n)
            }
            
            let data = gistogramRepresentationChart.setBarChartData(xValues: months, yValues: unitsSold, label: "Monthly Sales")
            self.gistogramRepresentationChart.data = data
            self.gistogramRepresentationChart.gridBackgroundColor = NSUIColor.white
            self.gistogramRepresentationChart.xAxis.labelTextColor = .white
            self.gistogramRepresentationChart.leftAxis.labelTextColor = .white
            self.gistogramRepresentationChart.rightAxis.labelTextColor = .white
            print("")
        } else {
             _ = AlertHelper().dialogCancel(question: "Error", text: "You need to start with detection")
        }
    }
    
    func createArrayGist() -> [ChartDataEntry] {
        var tmp: [ChartDataEntry] = []
//        tmp.append(ChartDataEntry(x: 0.0, y: 0.0))
//        tmp.append(ChartDataEntry(x: 0.0, y: 3.0))
//        tmp.append(ChartDataEntry(x: result[0].x, y: 3.0))
//        tmp.append(ChartDataEntry(x: result[0].x, y: 0.0))
        for i in 0 ..< result.count - 1 {
            tmp.append(ChartDataEntry(x: result[i].x - 1.0, y: 0.0))
            tmp.append(ChartDataEntry(x: result[i].x - 1.0, y: result[i].y))
            tmp.append(ChartDataEntry(x: result[i + 1].x - 1.0, y: result[i].y))
            tmp.append(ChartDataEntry(x: result[i + 1].x - 1.0, y: 0.0))
        }
        
        tmp.append(ChartDataEntry(x: result[result.count - 1].x - 1.0, y: 0.0))
        tmp.append(ChartDataEntry(x: result[result.count - 1].x - 1.0, y: result[result.count - 1].y))
        tmp.append(ChartDataEntry(x: Double(arrayOfTimeSeries.count) - 1.0, y: result[result.count - 1].y))
        tmp.append(ChartDataEntry(x: Double(arrayOfTimeSeries.count) - 1.0, y: 0.0))
        return tmp
    }
    
    func createInterval() {
        for i in 1 ..< result.count {
            let ymin = result[i].y < result[i - 1].y ? result[i].y : result[i - 1].y
            let ymax = result[i].y < result[i - 1].y ? result[i - 1].y : result[i].y
            let tmin = result[i].x < result[i - 1].x ? result[i].x : result[i - 1].x
            let tmax = result[i].x < result[i - 1].x ? result[i - 1].x : result[i].x
            intervals.append(GistogramModel(ymin: ymin, ymax: ymax, tmin: tmin, tmax: tmax))
        }
    }
    
    @IBAction func startProccess(_ sender: Any) {
        if arrayOfTimeSeries.count != 0 {
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
            representChart(timeSeries: arrayOfTimeSeries, regresion: arrayOfSmooth, chart: timeSeriesRepresentationChart)
        } else {
            arrayOfTimeSeries = createRandomSeries()
            arrayOfSmooth = arrayOfTimeSeries
            arrayOfName = []
            for i in 0 ..< arrayOfTimeSeries.count {
                arrayOfName.append("\(i)")
            }
            representChart(timeSeries: arrayOfTimeSeries, regresion: nil, chart: timeSeriesRepresentationChart)
        }
        
        timeSeriesTabel.reloadData()
    }
    
    @IBAction func startDetection(_ sender: Any) {
        eps = Double(HText.title) ?? 6.0
        if arrayOfSmooth.count > 0 {
            arrayOfCusum1 = []
            arrayOfCusum2 = []
            arrayOfGRSh = []
            kArray = createKArray()
            calcCUSUM(array: kArray)
            
//            kArray = createZArray()
            calcGraph(array: arrayOfSmooth)
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
            let points = createPointsGraph(array: result)
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
    
    func createZArray() -> [Double] {
        var kArray: [Double] = []
        for _ in 0 ..< arrayCount {
            kArray.append(0)
        }
        for i in arrayCount ..< arrayOfSmooth.count {
            let y = Array(arrayOfSmooth[i - arrayCount ... i])
            let y_av = calcM(y: y)
            let varience = calcVar(y: y)
            let z = (y.last! - y_av) / varience
            kArray.append(z)
        }
        return kArray
    }
    
    func calcCUSUM(array: [Double]) {
        for _ in 0...arrayCount {
            arrayOfCusum1.append(0.0)
            arrayOfCusum2.append(0.0)
        }

        var S1 = 0.0
        var S2 = 0.0
        for i in arrayCount ..< array.count - 1 {
            let y = Array(array[i - arrayCount ... i])
            let m = calcM(y: y)
            let cusumManager = CUSUM(y: array, m1: m)
            let elem1 = cusumManager.calcS1(t: i + 1, SPrev: S1)
            S1 = elem1
            
            let elem2 = cusumManager.calcS2(t: i + 1, SPrev: S2)
            S2 = elem2
            
            if elem1 > eps || elem2 > eps{
                S1 = 0.0
                S2 = 0.0
            }
            
            arrayOfCusum1.append(elem1)
            arrayOfCusum2.append(elem2)
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
    
    func calcVar(y: [Double]) -> Double {
        var result: Double
        var sum: Double
        var arithMeam: Double
        
        arithMeam = calcM(y: y)
        
        sum = 0
        for item in y {
            sum += pow((item - arithMeam), 2)
        }
        
        result = sum / Double((y.count - 1))
        
        return result
    }
    
    func calcGRSh(array: [Double]) {
        var W = 0.0
        
        for i in 0 ..< array.count - 1 {
            let grshManager = GRSh(y: array)
            let elem = grshManager.calcW(t: i, WPrev: W)
            
            W = elem
            
            if elem >= eps {
                W = 0.0
            }
            
            arrayOfGRSh.append(elem)
        }
        grshTabel.reloadData()
    }
    
    func calcChangeZero(array: [Double]) {
        var W = 0.0
        
        for i in 0 ..< array.count - 1 {
            let elem = array[i]
            
            arrayOfGRSh.append(elem)
        }
        grshTabel.reloadData()
    }
    
    func calcGraph(array: [Double]) {
        result = []
        let graphManager = GraphManager()
        let points = graphManager.createPoints(y: array)
        
        graphManager.calcD(points: points, bar: eps, result: &result)
        
        grshTabel.reloadData()
    }
    
    func createPointsCusum() -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for i in 0 ..< arrayOfCusum1.count {
            if arrayOfCusum1[i] > eps || arrayOfCusum2[i] > eps{
                if let elem = result.last {
                    if (i - Int(elem.x) - 1) > 10 {
                        result.append(ChartDataEntry(x: Double(i + 1), y: arrayOfSmooth[i]))
                    }
                } else {
                    result.append(ChartDataEntry(x: Double(i + 1), y: arrayOfSmooth[i]))
                }
            }
        }
        return result
    }
    
    func createPointsGRSh() -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for i in 0 ..< arrayOfGRSh.count {
            if arrayOfGRSh[i] >= eps {
                result.append(ChartDataEntry(x: Double(i + 1), y: arrayOfSmooth[i]))
            }
        }
        return result
    }
    
    func createPointsZero() -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for i in 1 ..< arrayOfGRSh.count {
            if arrayOfGRSh[i].sign != arrayOfGRSh[i - 1].sign {
                result.append(ChartDataEntry(x: Double(i + 1), y: arrayOfSmooth[i]))
            }
        }
        return result
    }
    
    func createPointsGraph(array: [Point]) -> [ChartDataEntry] {
        var result: [ChartDataEntry] = []
        for elem in array {
                result.append(ChartDataEntry(x: Double(elem.x - 1.0), y: elem.y))
        }
        return result
    }
    
    func createRandomSeries() -> [Double] {
        var result: [Double] = []
        let count = 50
        var m = 3.0
            for _ in 0...count {
                result.append(m + Double.random(in: 0...1))
            }
        
        m = 25.0
        for _ in 0...count {
            result.append(m + Double.random(in: 0...1))
        }
        
        m = 7.0
        for _ in 0...count {
            result.append(m + Double.random(in: 0...1))
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
            let numberOfRows:Int = arrayOfCusum1.count
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
                text = "\(arrayOfCusum1[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.ValueCell
            } else if tableColumn == tableView.tableColumns[2] {
                if arrayOfSmooth.count > 0 {
                    text = "\(arrayOfCusum2[row].rounded(toPlaces: 6))"
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
                    if row != 0 {
                    if arrayOfGRSh[row].sign != arrayOfGRSh[row - 1].sign {
                        text = "Has decomposition"
                        }
                    }
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


extension BarChartView {
    
    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setBarChartData(xValues: [String], yValues: [Double], label: String) -> BarChartData{
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = [NSUIColor.red]
//        self.xAxis.valueFormatter = xAxis.valueFormatter
        
        return chartData
    }
}
