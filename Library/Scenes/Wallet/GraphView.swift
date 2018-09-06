//
//  Library
//
//  Created by Otto Suess on 06.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import ScrollableGraphView

final class GraphView: ScrollableGraphView {
    override init(frame: CGRect, dataSource: ScrollableGraphViewDataSource) {
        super.init(frame: frame, dataSource: dataSource)
        
        backgroundFillColor = UIColor.Zap.background
        shouldAdaptRange = true
        direction = .rightToLeft
        shouldRangeAlwaysStartAtZero = true
        dataPointSpacing = frame.width / 8
        
        let linePlot = LinePlot(identifier: "line")
        linePlot.lineWidth = 1
        linePlot.lineStyle = .smooth
        linePlot.lineColor = UIColor.Zap.lightningOrange
        linePlot.adaptAnimationType = .elastic
        linePlot.fillType = .gradient
        linePlot.fillGradientStartColor = UIColor.Zap.seaBlue
        linePlot.fillGradientEndColor = UIColor.Zap.deepSeaBlue
        
        let dotPlot = DotPlot(identifier: "dots")
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = .white
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let referenceLines = ReferenceLines()
        referenceLines.relativePositions = [0, 0.5, 1]
        referenceLines.referenceLineColor = UIColor.Zap.gray
        referenceLines.referenceLinePosition = .right
        referenceLines.referenceLineLabelColor = .white
        referenceLines.referenceLineUnits = Settings.shared.cryptoCurrency.value.unit.symbol
        referenceLines.dataPointLabelColor = .white
        referenceLines.dataPointLabelsSparsity = 2
        
        addPlot(plot: linePlot)
        addPlot(plot: dotPlot)
        addReferenceLines(referenceLines: referenceLines)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
