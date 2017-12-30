import Vapor

extension Droplet {
    func setupRoutes() throws {
        let cc = CardController()
        let pc = PostController()
        let csc = CardSetController()

        resource("cards", cc)
        resource("posts", pc)
        resource("cardsets", csc)

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
