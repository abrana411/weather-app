import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbManage {
  static Future<sql.Database> getDatabase() async {
    //static means cant use this method even in this file if outside this class
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath,
          "user_FavCities.db"), //creating user_places.db data base inside the path and first searching for existing one if not there then creating that and adding an empty table
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE Places(city TEXT, temp TEXT)"); //will create the table Places here too kyunki usi se insert ki request bhej rahe h to vo he banayenge ya empty bhi agar nhi h to....taki insert jab Places me ho to vo isse match kre jo empty banayenge varna empty kisi or naam se ban jayega or Places naam ka koi table hoga he nhi ...to yaha naam daal deneg Places he
      },
      version: 1,
    );
  }

  //below creating a static method so that we can use that withot instantiating the class ...ie can do like DbManage.Insert()
  static Future<void> insertInDataBase(
      String
          table, //taking table name as table which we will create in the data base (always be same in our case as we want to deal with a single table only in this app)
      Map<String,
              dynamic> //and data of table as map in which keys of this map will have same name as of fields we have given when creating a new db
          dataItem) async //this will return a future as we will insert something in the data base in future only
  {
    final sqlDb = await DbManage
        .getDatabase(); //cant use getDatabse here simply even if we are in same class ..because thats the property of static functions
    await sqlDb.insert(
      //awaiting the final insertion
      table,
      dataItem,
      // conflictAlgorithm: sql.ConflictAlgorithm
      //     .replace, //say if we alreday have an entry for pre defined primary key and we have another one we want to store for same primary key here id ..then we are telling here to replace the old entry with new one
    );
  }

  static Future<List<Map<String, dynamic>>> fetchDataFromDb(
      //future will return a list of map and map can be either of String,dynamic or String,object
      String
          table) async //will receive table name from which we want to fetch the data
  {
    final db = await DbManage.getDatabase();
    return db.query(
        table); //this will return list of map...that we have inserted in this table...so returning this from here so that can use that in place where we are calling it
  }

  static Future<void> removeFromdb(String city, String table) async {
    final db = await DbManage.getDatabase();
    db.delete(table, where: "city=?", whereArgs: [city]);
  }
}
