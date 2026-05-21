import ProjectDescription

public extension Target {
    // Interface — Client struct, DependencyKey, Model
    static func domain(interface factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DomainInterface"
        f.sources = .interface
        return make(factory: f)
    }

    // Implements — liveValue, DTO, Mapping
    static func domain(implements factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Domain.name
        f.sources = .sources
        return make(factory: f)
    }
}
