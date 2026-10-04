import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.login.rawValue,
    targets: [
        .feature(implements: .login, factory: .init(
            dependencies: [
                .domainInterface,
                .dependencies,
                .designSystem,
                .sdk(name: "AuthenticationServices", type: .framework, status: .required),
                .core,
            ]
        )),
        .feature(tests: .login, factory: .init(
            dependencies: [
                .feature(implements: .login),
            ]
        )),
    ]
)
