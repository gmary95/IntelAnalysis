class RHelper {
    static func R_ycp(x: [Double], y_cp: [Double], y: [Double], Y_c: Double, Y_cp: Double, f: [[Double]]) -> Double {
        let f1 = F1(Y_c: Y_c, Y_cp: Y_cp, x: x, y: y_cp, f: f)
        let f2 = F2(Y_c: Y_c, Y_cp: Y_cp, x: x, y: y, f: f)
        return f1 / f2
    }
    
    static func F1(Y_c: Double, Y_cp: Double, x: [Double], y: [Double], f: [[Double]]) -> Double {
        if Y_cp >= Y_c{
            return calcIntegral(x: x, y: y, f: f)
        } else {
            return calcIntegral(x: x, y: y.reversed(), f: f)
        }
    }
    
    static func F2(Y_c: Double, Y_cp: Double, x: [Double], y: [Double], f: [[Double]]) -> Double {
        if Y_cp >= Y_c{
            return calcIntegral(x: x, y: y, f: f)
        } else {
            return calcIntegral(x: x, y: y.reversed(), f: f)
        }
    }
    
    static func calcIntegral(x: [Double], y: [Double], f: [[Double]]) -> Double {
        var result = 0.0
        for i in 0 ..< x.count {
            for j in 0 ..< y.count {
                result += f[i][j] * (x[i] - x[i - 1]) * (y[i] - y[i - 1])
            }
        }
        return result
    }
}
