import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let messageController = MessageController()
    messageController.routes(router)

    let userController = UserController()
    userController.routes(router)

    let userMessageController = UserMessageController()
    userMessageController.routes(router)
}
