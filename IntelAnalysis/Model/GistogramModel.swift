class GistogramModel {
    var ymin: Double
    var ymax: Double
    var tmin: Double
    var tmax: Double
    var n: Int = 0
    
    init(ymin: Double, ymax: Double, tmin: Double, tmax: Double) {
        self.ymin = ymin
        self.ymax = ymax
        self.tmin = tmin
        self.tmax = tmax
    }
}
