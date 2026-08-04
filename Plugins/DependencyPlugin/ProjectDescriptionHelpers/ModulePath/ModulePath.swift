import ProjectDescription

public enum ModulePath {
    case feature(Feature)
    case core(Core)
    case shared(Shared)
    case useCase(UseCase)
    case data(Data)
}
