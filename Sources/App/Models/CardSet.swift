import Vapor
import FluentProvider
import HTTP

final class CardSet: Model {
    let storage = Storage()
    // MARK: Properties and database keys
    
    /// The description of the card set
    var description: String
    /// The children of the card set
    var cards: Children<CardSet, Card> {
        return children()
    }
    
    
    /// The column names for `id`, `description`` in the database
    struct Keys {
        static let id = "id"
        static let description = "description"
    }
    
    /// Creates a new CardSet
    init(description: String) {
        self.description = description
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the CardSet from the
    /// database row
    init(row: Row) throws {
        description = try row.get(CardSet.Keys.description)
    }
    
    // Serializes the CardSet to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(CardSet.Keys.description, description)
        return row
    }
}

// MARK: Fluent Preparation

extension CardSet: Preparation {
    /// Prepares a table/collection in the database
    /// for storing CardSets
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(CardSet.Keys.description)
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
//     - Creating a new cardSet (POST /cardsetss)
//     - Fetching a cardset (GET /cardsets, GET /cardsets/:id)
//
extension CardSet: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            description: try json.get(CardSet.Keys.description)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(CardSet.Keys.id, id)
        try json.set(CardSet.Keys.description, description)
        try json.set("cards", cards.all())
        return json
    }
}

// MARK: HTTP

// This allows CardSet models to be returned
// directly in route closures
extension CardSet: ResponseRepresentable { }

// MARK: Update

// This allows the Card model to be updated
// dynamically by the request.
extension CardSet: Updateable {
    // Updateable keys are called when `card.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<CardSet>] {
        return [
            // If the request contains a String at key "description"
            // the setter callback will be called.
            UpdateableKey(CardSet.Keys.description, String.self) { cardset, description in
                cardset.description = description
            },
            
        ]
    }
}
