import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Cards table
final class CardController: ResourceRepresentable {
    /// When users call 'GET' on '/cards'
    /// it should return an index of all available cards
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Card.all().makeJSON()
    }

    /// When consumers call 'POST' on '/cards' with valid JSON
    /// construct and save the card
    func store(_ req: Request) throws -> ResponseRepresentable {
        let card = try req.card()
        try card.save()
        return card
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/cards/13rd88' we should show that specific card
    func show(_ req: Request, card: Card) throws -> ResponseRepresentable {
        return card
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'cards/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, card: Card) throws -> ResponseRepresentable {
        try card.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/cards' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Card.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, card: Card) throws -> ResponseRepresentable {
        // See `extension Card: Updateable`
        try card.update(for: req)

        // Save an return the updated card.
        try card.save()
        return card
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Card with the same ID.
    func replace(_ req: Request, card: Card) throws -> ResponseRepresentable {
        // First attempt to create a new Card from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.card()

        // Update the card with all of the properties from
        // the new card
        card.front = new.front
        card.back = new.back
        try card.save()

        // Return the updated card
        return card
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this 
    /// implementation
    func makeResource() -> Resource<Card> {
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
    /// Create a card from the JSON body
    /// return BadRequest error if invalid 
    /// or no JSON
    func card() throws -> Card {
        guard let json = json else { throw Abort.badRequest }
        return try Card(json: json)
    }
}

/// Since CardController doesn't require anything to 
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension CardController: EmptyInitializable { }
