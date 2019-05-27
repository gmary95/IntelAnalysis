class RHelper {
    static func R_ycp(t_ij: Double, Y_c: Double, dy:Double, Y_cp: Double) -> Double {
        let f1 = F1(t_ij: t_ij, Y_c: Y_c, dy: dy, Y_cp: Y_cp)
        let f2 = F2(t_ij: t_ij, Y_c: Y_c, dy: dy, Y_cp: Y_cp)
        return f1 / f2
    }
    
    static func F1(t_ij: Double, Y_c: Double, dy:Double, Y_cp: Double) -> Double {
        if Y_cp >= Y_c{
            return calcIntegral(left1:t_ij, right1: 0.0, left2: Y_c, right2: Y_cp)
        } else {
            return calcIntegral(left1:t_ij, right1: 0.0, left2: Y_cp, right2: Y_c)
        }
    }
    
    static func F2(t_ij: Double, Y_c: Double, dy:Double, Y_cp: Double) -> Double {
        if Y_cp >= Y_c{
            return calcIntegral(left1:t_ij, right1: 0.0, left2: 0.0, right2: Y_c)
        } else {
            return calcIntegral(left1:t_ij, right1: 0.0, left2: Y_c, right2: 0.0)
        }
    }
    
    static func calcIntegral(left1: Double, right1: Double, left2: Double, right2: Double) -> Double {
        return 0.0
    }
}
