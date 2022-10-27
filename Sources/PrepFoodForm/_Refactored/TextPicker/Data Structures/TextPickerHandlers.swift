import Foundation

typealias SingleSelectionHandler = ((ImageText) -> ())
typealias MultiSelectionHandler = (([ImageText]) -> ())
typealias ColumnSelectionHandler = ((Int) -> (Bool))
typealias DeleteImageHandler = ((Int) -> ())
typealias DismissHandler = (() -> ())
