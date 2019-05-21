import Foundation

class FrequencyCalculator {
    
    static public func getFrequency(selection: Selection, M: Int) -> Array<Double> {
        let selection = selection.data.sorted()
        let h = (selection.last! - selection.first!) / Double(M)
        var n = Array<Double>(repeating: 0.0, count: M)
        var r = Array<Double>()
        var xmin = selection.first!
        for i in 0 ... M {
            xmin = xmin + Double(i) * h
        }
        
        
        return r
    }
}
