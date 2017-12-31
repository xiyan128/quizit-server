import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Users table
final class UserController: ResourceRepresentable {
    /// When users call 'GET' on '/users'
    /// it should return an index of all available users
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }


    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/users/13rd88' we should show that specific user
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }


    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this 
    /// implementation
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            show: show
        )
    }
}


/// Since UserController doesn't require anything to 
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension UserController: EmptyInitializable { }
