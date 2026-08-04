import ProjectDescription

public enum ModulePath {
    case feature(Feature)
    case core(Core)
    case shared(Shared)
    case domain(Domain)
    case data(Data)
}
