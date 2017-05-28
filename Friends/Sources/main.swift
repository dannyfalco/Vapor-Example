import Vapor
import VaporPostgreSQL


//let config = try Config()
//try config.setup()

//let drop = try Droplet(config)
let drop = Droplet()
drop.preparations.append(Friend.self)
//try drop.setup()

do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

drop.get { req in
    return try drop.view.make("welcome", "title")
}

drop.get("friends") { req in
    let friends = try Friend.all().makeNode()
    let friendsDictionary = ["friends": friends]
    return try JSON(node: friendsDictionary)
}

drop.get("friends", Int.self) {req, userID in
  guard let friend = try Friend.find(userID) else {
    throw Abort.notFound
  }
  return try friend.makeJSON()
}

drop.post("friend") { req in
    var friend = try Friend(node: req.json)
    try friend.save()
    return try friend.makeJSON()
}

drop.resource("posts", PostController())

 drop.run()
