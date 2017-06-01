import Vapor
import VaporPostgreSQL
import HTTP


//let config = try Config()
//try config.setup()

//let drop = try  Droplet(config)
let drop = Droplet()
drop.preparations.append(Friend.self)
//try drop.setup()

do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}

drop.get { req in
  let lang = req.headers["Accept-Language"]?.string ?? "en"
  return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
    ])
    //return try drop.view.make("welcome", "title")
}

drop.get("helloworld") { req in
  //return try drop.view.make("hello")
  return try drop.view.make("hello", ["greeting": "World"])
}

drop.get("friends") { req in
    let friends = try Friend.all().makeNode()
    let friendsDictionary = ["friends": friends]
    return try JSON(node: friendsDictionary)
}

drop.get("friends", Int.self) { req, userID in
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

drop.delete("friends", Int.self) { req, userID in
  guard let friend = try Friend.find(userID) else {
      throw Abort.notFound
  }

  try friend.delete()
  return Response(status: .ok,
    headers: ["Content-Type": "text/plain"], body: "Delete successful.")

}

drop.resource("posts", PostController())

 drop.run()
