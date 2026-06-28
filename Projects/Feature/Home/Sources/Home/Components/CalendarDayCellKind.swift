enum CalendarDayCellKind {
    case empty
    case future(Int)
    case studied(Int, CalendarDayIntensity)
    case notStudied(Int)
    case today(Int, CalendarDayIntensity?)
}
