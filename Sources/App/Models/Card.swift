import Vapor
import FluentProvider
import HTTP

final class Card: Model {
    let storage = Storage()
    // MARK: Properties and database keys
    
    /// The front side of the card
    var front: String
    /// The back side of the card
    var back: String

    /// The ID of its parent
    let card_set_id: Identifier

    var belongTo: Parent<Card, CardSet> {
        return parent(id: card_set_id)
    }

    
    /// The column names for `id`, `front` and `back` in the database
    struct Keys {
        static let id = "id"
        static let card_set_id = "card_set_id"
        static let front = "front"
        static let back = "back"
    }

    /// Creates a new Card
    init(front: String, back: String, card_set_id: Identifier) {
        self.front = front
        self.back = back
        self.card_set_id = card_set_id
    }

    // MARK: Fluent Serialization

    /// Initializes the Card from the
    /// database row
    init(row: Row) throws {
        front = try row.get(Card.Keys.front)
        back = try row.get(Card.Keys.back)
        card_set_id = try row.get(Card.Keys.card_set_id)
    }

    // Serializes the Card to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Card.Keys.front, front)
        try row.set(Card.Keys.back, back)
        try row.set(Card.Keys.card_set_id, card_set_id)
        return row
    }
}

// MARK: Fluent Preparation

extension Card: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Cards
	
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(CardSet.self)
            builder.string(Card.Keys.front)
            builder.string(Card.Keys.back)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Card (POST /cards)
//     - Fetching a card (GET /cards, GET /cards/:id)
//
extension Card: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            front: try json.get(Card.Keys.front),
            back: try json.get(Card.Keys.back),
            card_set_id: try json.get(Card.Keys.card_set_id)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Card.Keys.id, id)
        try json.set(Card.Keys.front, front)
        try json.set(Card.Keys.back, back)
        try json.set(Card.Keys.card_set_id, card_set_id)
        return json
    }
}

// MARK: HTTP

// This allows Card models to be returned
// directly in route closures
extension Card: ResponseRepresentable { }

// MARK: Update

// This allows the Card model to be updated
// dynamically by the request.
extension Card: Updateable {
    // Updateable keys are called when `card.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Card>] {
        return [
            // If the request contains a String at key "front"
            // the setter callback will be called.
            UpdateableKey(Card.Keys.front, String.self) { card, front in
                card.front = front
            },
            UpdateableKey(Card.Keys.back, String.self) { card, back in
                card.back = back
            },

        ]
    }
}
