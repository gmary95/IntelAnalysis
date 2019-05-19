import Foundation

class GraphManager {
    
    func calcD(points: [Point], bar: Double, result: inout [Point]) {
        var selection:[Double] = []
        for elem in points {
            selection.append(elem.y)
        }
        let linear = LinearRegresion(selection: selection)
        linear.initAllParam()
        let k = linear.b
        let b = linear.a
        
        var dArray:[PointWithD] = []
        for point in points {
            let d = fabs(k! * point.x - point.y + b!) / sqrt(pow(k!, 2.0) + 1.0)
            if d > bar {
                dArray.append(PointWithD(point: point, d: d))
            }
        }
        
        if dArray.count != 0 {
            let max = findMax(dArr: dArray).point
            result.append(max)
            let i = findIndex(dArr: points, x: max.x)
            if i != 0 {
                let points1 = createNewSelection(selection: points, start: 0, end: i - 1)
                calcD(points: points1, bar: bar, result: &result)
            }
            
            if i != points.count - 1 {
                let points2 = createNewSelection(selection: points, start: i + 1, end: points.count - 1)
                calcD(points: points2, bar: bar, result: &result)
            }
        }
    }
    
    private func findMax(dArr: [PointWithD]) -> PointWithD {
        var result = dArr.first!
        
        for d in dArr {
            if d.d > result.d {
                result = d
            }
        }
        return result
    }
    
    private func findIndex(dArr: [Point], x: Double) -> Int {
        var result = 0
        
        for i in 0 ..< dArr.count {
            if dArr[i].x == x {
                result = i
            }
        }
        return result
    }
    
    private func createNewSelection(selection: [Point], start: Int, end: Int) -> [Point]{
        let result = Array(selection[start ... end])
        return result
    }
    
    func createPoints(y: [Double]) -> [Point] {
        var result: [Point] = []
        for i in 0 ..< y.count {
            result.append(Point(x: Double(i + 1), y: y[i]))
        }
        return result
    }
}
