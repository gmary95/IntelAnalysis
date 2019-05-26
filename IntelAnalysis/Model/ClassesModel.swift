class ClassesModel {
    public var series: [Point]
    
    public init() {
        series = []
    }
    
    public func add(point: Point){
        series.append(point)
    }

    public func getCount(dT: (Double, Double), dY: (Double, Double)) -> Int {
        var result = 0
        for p in series {
            if (p.x >= dT.0 && p.x < dT.1) && (p.y >= dY.0 && p.y < dY.1) {
                result += 1
            }
        }
        return result
    }
    
    public func getClasses(dT: (Double, Double), dY: (Double, Double)) -> SeriesClass {
        let fr = getCount(dT: dT, dY: dY)
        return SeriesClass(dT: DiffClass(min: dT.0, max: dT.1), dY: DiffClass(min: dY.0, max: dY.1), fr: fr)
    }
}


public class DiffClass {
    public var min: Double
    public var max: Double
    
    
    public init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }
}

public class SeriesClass {
    public var dT: DiffClass
    public var dY: DiffClass
    public var frequency: Int
    
    
    public init(dT: DiffClass, dY: DiffClass, fr: Int) {
        self.dT = dT
        self.dY = dY
        self.frequency = fr
    }
}

