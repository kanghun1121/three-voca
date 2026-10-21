import ProjectDescription

public enum ModulePath {
    case feature(Feature)
    case core(Core)
    case domain(Domain)
    case data(Data)
    case networking(Networking)
}
