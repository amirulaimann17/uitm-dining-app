import 'package:fypfinal/Models/cafe.dart';
import 'package:fypfinal/Models/menu.dart';
import 'package:fypfinal/Models/order.dart';
import 'package:fypfinal/Models/orderItem.dart';
import 'package:fypfinal/Models/student.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "cafe.db";

  String cafe = '''CREATE TABLE cafes (
    cafeId INTEGER PRIMARY KEY AUTOINCREMENT,
    cafeName TEXT NOT NULL,
    cafeLocation TEXT NOT NULL,
    cafeUsername TEXT NOT NULL,
    cafePassword TEXT NOT NULL,
    cafeImage TEXT NOT NULL,
    operationHours TEXT NOT NULL,
    isOpen INTEGER NOT NULL
)''';

  String student = '''
CREATE TABLE students (
  studentId INTEGER PRIMARY KEY AUTOINCREMENT,
  studentName TEXT NOT NULL,
  studentEmail TEXT NOT NULL,
  studentPassword TEXT NOT NULL,
  favoriteCafes TEXT, 
  FOREIGN KEY (favoriteCafes) REFERENCES cafes(cafeId) 
)
''';

  String menuTable = '''CREATE TABLE menu (
        menuId INTEGER PRIMARY KEY AUTOINCREMENT, 
        menuName TEXT NOT NULL,
        menuPrice REAL NOT NULL, 
        menuCategory TEXT NOT NULL,
        menuDescription TEXT NOT NULL,
        menuImage TEXT NOT NULL, 
        cafeId INTEGER NOT NULL,
        isAvailable BOOLEAN NOT NULL DEFAULT 1,
        FOREIGN KEY (cafeId) REFERENCES cafe(cafeId)
        )
        ''';

  String ratingTable = '''CREATE TABLE rating (
    ratingId INTEGER PRIMARY KEY AUTOINCREMENT, 
    cafeId INTEGER NOT NULL,
    studentId INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (cafeId) REFERENCES cafes(cafeId),
    FOREIGN KEY (studentId) REFERENCES students(studentId)
    )
    ''';

  String favoriteCafesTable = '''
CREATE TABLE favoriteCafes (
  studentId INTEGER NOT NULL,
  cafeId INTEGER NOT NULL,
  PRIMARY KEY (studentId, cafeId),
  FOREIGN KEY (studentId) REFERENCES students(studentId),
  FOREIGN KEY (cafeId) REFERENCES cafes(cafeId)
)
''';

  String admin = '''
CREATE TABLE admins (
  adminId INTEGER PRIMARY KEY AUTOINCREMENT,
  adminUsername TEXT NOT NULL,
  adminPassword TEXT NOT NULL
)
''';
  String cartTable = '''
CREATE TABLE cart (
    cartId INTEGER PRIMARY KEY AUTOINCREMENT,
    studentId INTEGER NOT NULL,
    menuId INTEGER NOT NULL,
    cafeId INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    dateAdded TEXT NOT NULL,
    FOREIGN KEY (studentId) REFERENCES students(studentId),
    FOREIGN KEY (menuId) REFERENCES menu(menuId),
     FOREIGN KEY (cafeId) REFERENCES cafes(cafeId)
)''';

  String orderTable = '''
  CREATE TABLE orders(
    orderId INTEGER PRIMARY KEY AUTOINCREMENT,
    studentId INTEGER NOT NULL,
    cafeId INTEGER NOT NULL,
    orderDate TEXT NOT NULL,
    totalPrice REAL NOT NULL,
    orderStatus TEXT NOT NULL,
    items TEXT,  
    FOREIGN KEY(studentId) REFERENCES students(studentId),
    FOREIGN KEY(cafeId) REFERENCES cafes(cafeId)
  )
''';

  String orderItemsTable = '''
    CREATE TABLE order_items(
      orderItemId INTEGER PRIMARY KEY AUTOINCREMENT,
      menuId INTEGER NOT NULL,
      orderId INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      menuPrice REAL NOT NULL,
      FOREIGN KEY(orderId) REFERENCES orders(orderId),
      FOREIGN KEY(menuId) REFERENCES menu(menuId)
    )
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(cafe);
      await db.execute(student);
      await db.execute(menuTable);
      await db.execute(ratingTable);
      await db.execute(favoriteCafesTable);
      await db.execute(admin);
      await db.insert('admins', {
        'adminUsername': 'admin',
        'adminPassword': '123456',
      });
      await db.execute(cartTable);
      await db.execute(orderTable);
      await db.execute(orderItemsTable);
    });
  }

  Future<int?> adminLogin(String adminUsername, String adminPassword) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
        "SELECT adminId FROM admins WHERE adminUsername = ? AND adminPassword = ?",
        [adminUsername, adminPassword]);
    if (result.isNotEmpty) {
      return result.first['adminId'] as int?;
    }
    return null;
  }

//Cafe
  Future<int> cafeSignup(Cafes cafe) async {
    final Database db = await initDB();
    int cafeId = await db.insert('cafes', cafe.toMap());
    await db.insert('rating', {
      'cafeId': cafeId,
      'studentId': null, // Set to null for default rating
      'rating': 5, // Default rating value
      'comment': 'Default rating', // Comment for default rating
      'timestamp': DateTime.now().toString(),
    });
    return cafeId;
  }

  Future<int?> cafeLogin(String cafeUsername, String cafePassword) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
        "select cafeId FROM cafes where cafeUsername = ? AND cafePassword = ?",
        [cafeUsername, cafePassword]);
    if (result.isNotEmpty) {
      return result.first['cafeId'] as int;
    }
    return null;
  }

  Future<List<Cafes>> getAllCafes() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM cafes');

    return maps.map((map) => Cafes.fromMap(map)).toList();
  }

  Future<int?> getCafeId(String cafeUsername) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
      "SELECT cafeId FROM cafes WHERE cafeUsername = ?",
      [cafeUsername],
    );
    if (result.isNotEmpty) {
      return result.first['cafeId'] as int?;
    }
    return null;
  }

  Future<String?> getCafeNameById(int cafeId) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
      "SELECT cafeName FROM cafes WHERE cafeId = ?",
      [cafeId],
    );
    if (result.isNotEmpty) {
      return result.first['cafeName'] as String;
    }
    return null;
  }

  Future<Cafes?> getCafeDetails(int cafeId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'cafes',
      where: 'cafeId = ?',
      whereArgs: [cafeId],
    );

    if (maps.isNotEmpty) {
      return Cafes.fromMap(maps.first);
    }

    return null;
  }

  Future<bool> checkUsernameExists(String cafeUsername) async {
    final db = await initDB();
    final result = await db
        .rawQuery('SELECT * FROM cafes WHERE cafeUsername = ?', [cafeUsername]);
    return result.isNotEmpty;
  }

  Future<int> updateCafeStatus(int? cafeId, bool isOpen) async {
    final Database db = await initDB();
    return db.rawUpdate(
      'UPDATE cafes SET isOpen = ? WHERE cafeId = ?',
      [isOpen ? 1 : 0, cafeId],
    );
  }

  Future<int> updateCafe(Cafes cafe) async {
    final db = await initDB();
    return await db.update(
      'cafes',
      cafe.toMap(),
      where: 'cafeId = ?',
      whereArgs: [cafe.cafeId],
    );
  }

  Future<int> deleteCafe(int cafeId) async {
    final db = await initDB();
    return await db.delete(
      'cafes',
      where: 'cafeId = ?',
      whereArgs: [cafeId],
    );
  }

//Student
  Future<int> studentSignup(Student student) async {
    final Database db = await initDB();
    return db.insert('students', student.toMap());
  }

  Future<int?> studentLogin(String studentEmail, String studentPassword) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
        "select studentId FROM students where studentEmail = ? AND studentPassword = ?",
        [studentEmail, studentPassword]);
    if (result.isNotEmpty) {
      return result.first['studentId'] as int;
    }
    return null;
  }

  Future<List<Student>> getAllStudents() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<bool> checkIfEmailExists(String email) async {
    final Database db = await initDB();
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM students WHERE studentEmail = ?",
      [email],
    );

    // If count is greater than 0, email exists
    return result.isNotEmpty && (result.first['count'] as int) > 0;
  }

  Future<Student?> getStudentDetails(int studentId) async {
    final Database db = await initDB();
    final result = await db
        .query('students', where: 'studentId = ?', whereArgs: [studentId]);

    if (result.isNotEmpty) {
      return Student.fromMap(result.first);
    }

    return null;
  }

  Future<int> updateStudent(
      studentName, studentEmail, studentPassword, studentId) async {
    final Database db = await initDB();
    final rowsAffected = await db.rawUpdate(
      'UPDATE students SET studentName = ?, studentEmail = ?, studentPassword = ? WHERE studentId = ?',
      [studentName, studentEmail, studentPassword, studentId],
    );
    return rowsAffected;
  }

  Future<int> deleteStudent(int studentId) async {
    final Database db = await initDB();
    final rowsDeleted = await db.delete(
      'students',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return rowsDeleted;
  }

//Menu
  Future<int> createMenu(MenuModel menuTable) async {
    final Database db = await initDB();
    return db.insert('menu', menuTable.toMap());
  }

  Future<List<MenuModel>> getAllMenus() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM menu');
    return maps.map((map) => MenuModel.fromMap(map)).toList();
  }

  Future<List<MenuModel>> getAllMenusByCafeId(int cafeId) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM menu WHERE cafeId = ?', [cafeId]);
    return maps.map((map) => MenuModel.fromMap(map)).toList();
  }

  Future<MenuModel?> getMenuById(int menuId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'menu',
      where: 'menuId = ?',
      whereArgs: [menuId],
    );
    if (maps.isEmpty) {
      return null; // Menu not found
    }
    return MenuModel.fromMap(maps.first);
  }

  Future<int> deleteMenu(int menuId) async {
    final Database db = await initDB();
    return db.delete('menu', where: 'menuId = ?', whereArgs: [menuId]);
  }

  Future<int> updateMenu(menuName, menuPrice, menuDescription, menuCategory,
      menuImage, menuId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update menu set menuName = ?, menuPrice = ?, menuDescription = ?, menuCategory = ?, menuImage = ? where menuId = ?',
        [
          menuName,
          menuPrice,
          menuDescription,
          menuCategory,
          menuImage,
          menuId
        ]);
  }

  Future<List<MenuModel>> searchMenus(String query) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM menu WHERE menuName LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => MenuModel.fromMap(map)).toList();
  }

  Future<List<String>> fetchMenuCategories() async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> categoryMaps =
        await db.rawQuery('SELECT DISTINCT menuCategory FROM menu');
    final List<String> uniqueCategories =
        categoryMaps.map((map) => map['menuCategory'] as String).toList();

    return uniqueCategories;
  }

  Future<int> updateMenuAvailability(int menuId, bool isAvailable) async {
    final Database db = await initDB();
    return db.rawUpdate(
      'UPDATE menu SET isAvailable = ? WHERE menuId = ?',
      [isAvailable ? 1 : 0, menuId],
    );
  }

  //Rating
  Future<int> addRating(
      int cafeId, int studentId, int rating, String comment) async {
    final Database db = await initDB();
    return db.insert('rating', {
      'cafeId': cafeId,
      'studentId': studentId,
      'rating': rating,
      'comment': comment,
      'timestamp': DateTime.now().toString(),
    });
  }

  Future<double?> calculateAverageRating(int cafeId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> ratingMaps = await db.query(
      'rating',
      columns: ['AVG(rating) as averageRating'],
      where: 'cafeId = ?',
      whereArgs: [cafeId],
    );
    double? averageRating =
        ratingMaps.isNotEmpty ? ratingMaps.first['averageRating'] : null;
    return averageRating;
  }

  //Rating
  Future<List<Map<String, dynamic>>> getAllRatingsByCafeId(int cafeId) async {
    final Database db = await initDB();
    return db.rawQuery('''
    SELECT students.studentName, rating.rating, rating.comment, rating.timestamp
    FROM rating
    INNER JOIN students ON rating.studentId = students.studentId
    WHERE rating.cafeId = ?
  ''', [cafeId]);
  }

  //fav cafe
  // Method to add cafe to favorites for a student
  Future<void> addCafeToFavorites(int studentId, int cafeId) async {
    final Database db = await initDB();
    await db.insert(
      'favoriteCafes',
      {'studentId': studentId, 'cafeId': cafeId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Method to remove cafe from favorites for a student
  Future<void> removeCafeFromFavorites(int studentId, int cafeId) async {
    final Database db = await initDB();
    await db.delete(
      'favoriteCafes',
      where: 'studentId = ? AND cafeId = ?',
      whereArgs: [studentId, cafeId],
    );
  }

  // Method to get list of favorite cafes for a student
  Future<List<Cafes>> getFavoriteCafes(int studentId) async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT cafes.*
      FROM cafes
      INNER JOIN favoriteCafes ON cafes.cafeId = favoriteCafes.cafeId
      WHERE favoriteCafes.studentId = ?
    ''', [studentId]);

    return maps.map((map) => Cafes.fromMap(map)).toList();
  }

  Future<bool> isCafeFavorite(int studentId, int cafeId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> result = await db.query(
      'favoriteCafes',
      where: 'studentId = ? AND cafeId = ?',
      whereArgs: [studentId, cafeId],
    );
    return result.isNotEmpty;
  }

  //cart
  Future<int> addToCart(
      int studentId, int menuId, int cafeId, int quantity) async {
    final Database db = await initDB();
    // Check if item already exists in the cart
    final List<Map<String, dynamic>> existingItems = await db.query(
      'cart',
      where: 'studentId = ? AND menuId = ? AND cafeId = ?',
      whereArgs: [studentId, menuId, cafeId],
    );

    if (existingItems.isNotEmpty) {
      // If item exists, update the quantity
      final existingItem = existingItems.first;
      final newQuantity = (existingItem['quantity'] as int) + quantity;
      return db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'studentId = ? AND menuId = ? AND cafeId = ?',
        whereArgs: [studentId, menuId, cafeId],
      );
    } else {
      // If item does not exist, insert a new record
      return db.insert(
        'cart',
        {
          'studentId': studentId,
          'menuId': menuId,
          'cafeId': cafeId,
          'quantity': quantity,
          'dateAdded': DateTime.now().toString(),
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getMenuInCartByCafe(
      int studentId, int cafeId) async {
    final Database db = await initDB();
    return db.rawQuery('''
    SELECT menu.*, cart.quantity
    FROM menu
    INNER JOIN cart ON menu.menuId = cart.menuId
    WHERE cart.studentId = ? AND cart.cafeId = ?
  ''', [studentId, cafeId]);
  }

  Future<int> clearCart(int studentId) async {
    final Database db = await initDB();
    return await db.delete(
      'cart',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> clearCartByCafe(int studentId, int cafeId) async {
    final Database db = await initDB();
    return await db.delete(
      'cart',
      where: 'studentId = ? AND cafeId = ?',
      whereArgs: [studentId, cafeId],
    );
  }

  Future<List<Map<String, dynamic>>> getCafeIdsInCart(int studentId) async {
    final Database db = await initDB();
    return db.rawQuery('''
    SELECT cafeId, COUNT(*) as itemCount
    FROM cart
    WHERE studentId = ?
    GROUP BY cafeId
  ''', [studentId]);
  }

  Future<void> updateCartItemQuantity(
      int studentId, int menuId, int cafeId, int newQuantity) async {
    final Database db = await initDB();
    await db.update(
      'cart',
      {'quantity': newQuantity},
      where: 'studentId = ? AND menuId = ? AND cafeId = ?',
      whereArgs: [studentId, menuId, cafeId],
    );
  }

  Future<void> removeCartItem(int studentId, int menuId, int cafeId) async {
    final Database db = await initDB();
    await db.delete(
      'cart',
      where: 'studentId = ? AND menuId = ? AND cafeId = ?',
      whereArgs: [studentId, menuId, cafeId],
    );
  }

  //order
  Future<int> insertOrder(Order order) async {
    final Database db = await initDB();
    print('Order to insert: $order');
    int orderId = await db.insert('orders', order.toMap());
    print('Inserted order with ID: $orderId');

    // Insert order items
    for (OrderItem item in order.items) {
      await db.insert('order_items', {
        'orderId': orderId,
        'menuId': item.menuId,
        'quantity': item.quantity,
        'menuPrice': item.menuPrice,
      });
      print('Inserted order item: $item');
    }
    return orderId;
  }

  Future<void> deleteCartByCafe(int studentId, int cafeId) async {
    final Database db = await initDB();
    await db.delete(
      'cart',
      where: 'studentId = ? AND cafeId = ?',
      whereArgs: [studentId, cafeId],
    );
  }

  Future<List<Order>> getOrdersByStudentId(int studentId) async {
    try {
      final Database db = await initDB();
      final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
      SELECT orders.*, GROUP_CONCAT(order_items.menuId) AS itemMenuIds,
             GROUP_CONCAT(order_items.quantity) AS itemQuantities,
             GROUP_CONCAT(order_items.menuPrice) AS itemPrices
      FROM orders
      LEFT JOIN order_items ON orders.orderId = order_items.orderId
      WHERE orders.studentId = ?
      GROUP BY orders.orderId
    ''', [studentId]);

      return orderMaps.map((map) => Order.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Order>> getCompletedOrdersByStudentId(int studentId) async {
    try {
      final Database db = await initDB();
      final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
      SELECT orders.*, GROUP_CONCAT(order_items.menuId) AS itemMenuIds,
             GROUP_CONCAT(order_items.quantity) AS itemQuantities,
             GROUP_CONCAT(order_items.menuPrice) AS itemPrices
      FROM orders
      LEFT JOIN order_items ON orders.orderId = order_items.orderId
      WHERE orders.studentId = ? AND orders.orderStatus = 'Completed'
      GROUP BY orders.orderId
    ''', [studentId]);

      return orderMaps.map((map) => Order.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching completed orders: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersByCafeId(int cafeId) async {
    try {
      final Database db = await initDB();
      final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
      SELECT orders.*, GROUP_CONCAT(order_items.menuId) AS itemMenuIds,
             GROUP_CONCAT(order_items.quantity) AS itemQuantities,
             GROUP_CONCAT(order_items.menuPrice) AS itemPrices
      FROM orders
      LEFT JOIN order_items ON orders.orderId = order_items.orderId
      WHERE orders.cafeId = ?
      GROUP BY orders.orderId
    ''', [cafeId]);

      return orderMaps.map((map) => Order.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Order>> getCompletedOrdersByCafeId(int cafeId) async {
    try {
      final Database db = await initDB();
      final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
        SELECT orders.*, GROUP_CONCAT(order_items.menuId) AS itemMenuIds,
               GROUP_CONCAT(order_items.quantity) AS itemQuantities,
               GROUP_CONCAT(order_items.menuPrice) AS itemPrices
        FROM orders
        LEFT JOIN order_items ON orders.orderId = order_items.orderId
        WHERE orders.cafeId = ? AND orders.orderStatus = 'Completed'
        GROUP BY orders.orderId
      ''', [cafeId]);

      return orderMaps.map((map) => Order.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching completed orders: $e');
      return [];
    }
  }

  Future<int> updateOrderStatus(int orderId, String newStatus) async {
    final db = await initDB();
    return await db.update(
      'orders',
      {'orderStatus': newStatus},
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Order>> getAllOrders() async {
  final Database db = await initDB();
  final List<Map<String, dynamic>> orderMaps = await db.rawQuery('''
    SELECT orders.*, GROUP_CONCAT(order_items.menuId) AS itemMenuIds,
           GROUP_CONCAT(order_items.quantity) AS itemQuantities,
           GROUP_CONCAT(order_items.menuPrice) AS itemPrices
    FROM orders
    LEFT JOIN order_items ON orders.orderId = order_items.orderId
    GROUP BY orders.orderId
  ''');

  return orderMaps.map((map) => Order.fromMap(map)).toList();
}

}
