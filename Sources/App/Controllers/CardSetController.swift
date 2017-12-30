import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our CardSets table
final class CardSetController: ResourceRepresentable {
    /// When users call 'GET' on '/cardsets'
    /// it should return an index of all available cardsets
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try CardSet.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/cardsets' with valid JSON
    /// construct and save the cardset
    func store(_ req: Request) throws -> ResponseRepresentable {
        let cardset = try req.cardset()
        try cardset.save()
        return cardset
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/cardsets/13rd88' we should show that specific cardset
    func show(_ req: Request, cardset: CardSet) throws -> ResponseRepresentable {
        return cardset
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'cardsetsets/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, cardset: CardSet) throws -> ResponseRepresentable {
        try cardset.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/cardsets' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try CardSet.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, cardset: CardSet) throws -> ResponseRepresentable {
        // See `extension CardSet: Updateable`
        try cardset.update(for: req)
        
        // Save an return the updated cardset.
        try cardset.save()
        return cardset
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new CardSet with the same ID.
    func replace(_ req: Request, cardset: CardSet) throws -> ResponseRepresentable {
        // First attempt to create a new CardSet from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.cardset()
        
        // Update the cardset with all of the properties from
        // the new cardset
        cardset.description = new.description
        try cardset.save()
        
        // Return the updated cardset
        return cardset
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<CardSet> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a cardset from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func cardset() throws -> CardSet {
        guard let json = json else { throw Abort.badRequest }
        return try CardSet(json: json)
    }
}

/// Since CardSetController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension CardSetController: EmptyInitializable { }

