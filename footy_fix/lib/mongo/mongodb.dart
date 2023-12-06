import 'dart:developer';

import 'constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabse {
  static connect() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    var collection = db.collection(COLLECTION_NAME);
    /*
    await collection.insertOne({
      "name": "admin2",
      "email": "thireshannaidoo2@gmail.com",
      "password": "wagwanLad2"
    });
    */

    //yozza
    print(await collection.find().toList());
  }
}
