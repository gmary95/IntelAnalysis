class RHelper {
    static func R_ycp(data: [[SeriesClass]], t_ij: Double, Y_c: Double, Y_cp: Double) -> Double {
        if Y_cp <= data.last!.last!.dY.max {
            let f1 = F1(data: data, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
            
            let f2 = F2(data: data, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
            return f1 / f2
        } else {
            return 1.0
        }
    }
    
    static func F1(data: [[SeriesClass]], t_ij: Double, Y_c: Double, Y_cp: Double) -> Double {
        if Y_cp >= Y_c{
            let newData = croppedData(data: data, Tmin: t_ij, Ymin: Y_c, Ymax: Y_cp)
            return calcIntegral(data: newData, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
        } else {
            let newData = croppedData(data: data, Tmin: t_ij, Ymin: Y_cp, Ymax: Y_c)
            return calcIntegral(data: newData, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
        }
    }
    
    static func F2(data: [[SeriesClass]], t_ij: Double, Y_c: Double, Y_cp: Double) -> Double {
        if Y_cp >= Y_c{
            let newData = croppedData(data: data, Tmin: t_ij, Ymin: Y_c, Ymax: data.last!.last!.dY.max)
            return calcIntegral(data: newData, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
        } else {
           let newData = croppedData(data: data, Tmin: t_ij, Ymin:data.first!.first!.dY.min, Ymax: Y_c)
            return calcIntegral(data: newData, t_ij: t_ij, Y_c: Y_c, Y_cp: Y_cp)
        }
    }
    
    static func calcIntegral(data: [[SeriesClass]], t_ij: Double, Y_c: Double, Y_cp: Double) -> Double {
        var result = 0.0
        for i in 0 ..< data.count {
            for j in 0 ..< data[i].count {
                result += data[i][j].frequency * (data[i][j].dY.max - data[i][j].dY.min) * (data[i][j].dT.max - data[i][j].dT.min)
            }
        }
        return result
    }
    
    static func croppedData(data: [[SeriesClass]], Tmin: Double, Ymin: Double, Ymax: Double) -> [[SeriesClass]] {
        var result: [[SeriesClass]] = []
        let t_index = findIndexT(t: Tmin, data: data)
        let ymin_index = findIndexY(y: Ymin, data: data)
        let ymax_index = findIndexY(y: Ymax, data: data)
        for i in t_index ..< data.count {
            var tmp: [SeriesClass] = []
            for j in ymin_index ... ymax_index {
                tmp.append(data[i][j])
            }
            result.append(tmp)
        }
        return result
    }
    
    static func findIndexT(t: Double, data: [[SeriesClass]]) -> Int {
        let result = 0
        for i in 0 ..< data.count {
            if data[i][0].dT.max >= t {
                return i
            }
        }
        return result
    }
    
    static func findIndexY(y: Double, data: [[SeriesClass]]) -> Int {
        let result = 0
        for i in 0 ..< data[0].count {
            if data[0][i].dY.max >= y {
                return i
            }
        }
        return result
    }
}
