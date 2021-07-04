import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.routes.defaultMaxBodySize = "50mb"
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateParty())
    app.migrations.add(CreateChat())
    try app.autoMigrate().wait()
    // register routes
    try routes(app)
}
