import 'package:Project_Prism/global.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Using https://www.researchgate.net/profile/Shefalika-Samaddar/publication/238090125/figure/fig1/AS:298754591739909@1448240053400/Organizational-Structure-of-a-Typical-Technical-Institute.png
// For generic permission level for Account level 1 [admin].

// For Account level 2 [student],3[guest] it is undefined and need not to be taken care of.

enum db_fetch_status {
  exists,
  nodata,
  error,
  success // Meant for update,set, and delete operations
}

class db_fetch_return {
  db_fetch_status? status;
  Object? data;

  db_fetch_return(db_fetch_status s, Object? d) {
    status = s;
    data = d;
  }
}

class account_obj {
  Timestamp? createdAt, lastSeen, updatedAt;
  String? email;

  String? classBelong = "None";
  String? firstName, lastName;
  String? avatarUrl;

  String? title;

  bool isStudent = false;
  bool? isDayscholar;

  bool? collegeBus;
  int? collegeBusId;

  int? registerNum;
  String? rollNo;

  int? phoneNo;
  //int? parentPhoneNo;

  int? roomNo;
  int? hostelType;

  // Staff
  String? position; // Faculty or Bus Driver or etc.,
  String? designation; // Assisant professor or assiocate or etc
  String? positionEncoded; // BusDriver or other alias
  int? permissionLevel; // Permission level for client side verification
  // Above two attributes can be null for non working faculty
  String? departmentStaff; // Engineering / Arts and Science, etc
  List<dynamic>? handlingDepartment; // Could be null [eg : CSE]
  // Unsure about this
  int? facultyCode;

  // Student
  String? department = "-";
  String? parentDepartment;
  String? branch;
  String? branchCode;
  String? programme;
  String? year;
  String? section;

  // Both
  Map<String, dynamic> hashes =
      global.hashes; // Despite using "dynamic", it is "String"
  String? facePhoto;
  int? notificationCount = 0;

  account_obj fromJSON(Map<String, Object?> Data) {
    account_obj newObj = account_obj();

    //newObj.timeStamp = Data["loginTimeStamp"];

    newObj.createdAt = Data["createdAt"] as Timestamp?;
    newObj.updatedAt = Data["updatedAt"] as Timestamp?;
    newObj.lastSeen = Data["lastSeen"] as Timestamp?;
    newObj.classBelong = Data["class"] as String?;
    newObj.firstName = Data["firstName"] as String?;
    newObj.lastName = Data["lastName"] as String?;
    newObj.rollNo = Data["rollNo"] as String?;
    newObj.avatarUrl = Data["avatar"] as String?;

    newObj.isDayscholar = Data["isDayscholar"] as bool?;
    newObj.collegeBus = Data["collegeBus"] as bool?;
    newObj.collegeBusId = Data["collegeBusId"] as int?;
    newObj.registerNum = Data["registerNum"] as int?;
    newObj.phoneNo = Data["phoneNo"] as int?;

    newObj.isStudent = Data["isStudent"] as bool;
    newObj.notificationCount = Data["notifications"] as int?;
    newObj.department = Data["department"] as String?;
    newObj.parentDepartment = Data["parentDepartment"] as String?;
    newObj.branch = Data["branch"] as String?;
    newObj.branchCode = Data["branchCode"] as String?;
    newObj.programme = Data["programme"] as String?;
    newObj.year = Data["year"] as String?;
    dynamic hashesCheck = Data["hashes"];
    newObj.hashes =
        (hashesCheck != null) ? hashesCheck as Map<String, dynamic> : {};
    newObj.section = Data["section"] as String?;

    newObj.departmentStaff = Data["departmentStaff"] as String?;
    newObj.designation = Data["designation"] as String?;
    newObj.handlingDepartment = Data["handlingDepartment"] as List<dynamic>?;
    newObj.facultyCode = Data["facultyCode"] as int?;
    newObj.permissionLevel = Data["permissionLevel"] as int?;
    newObj.position = Data["position"] as String?;
    newObj.positionEncoded = Data["positionEncoded"] as String?;

    newObj.title = Data["title"] as String?;
    newObj.facePhoto = Data["facePhoto"] as String?;
    newObj.email = Data["email"] as String?;

    return newObj;
  }

  @override
  String toString() {
    return "$classBelong $department $year $section $hashes $isStudent $notificationCount";
  }

  Map<String, Object?> toJson() {
    return {
      //"loginTimeStamp" : timeStamp,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "lastSeen": lastSeen,
      "firstName": firstName,
      "lastName": lastName,
      "avatar": avatarUrl,

      "rollNo": rollNo,
      "registerNum": registerNum,
      "phoneNo": phoneNo,
      "isDayscholar": isDayscholar,
      "collegeBus": collegeBus,
      "collegeBusId": collegeBusId,

      "designation": designation,
      "departmentStaff": departmentStaff,
      "handlingDepartment": handlingDepartment,
      "facultyCode": facultyCode,
      "permissionLevel": permissionLevel,
      "position": position,
      "positionEncoded": positionEncoded,

      "new": true,
      "notifications": notificationCount,
      "class": classBelong,
      "isStudent": isStudent,
      "department": department,
      "parentDepartment": parentDepartment,
      "branch": branch,
      "branchCode": branchCode,
      "programme": programme,
      "year": year,
      "hashes": hashes,
      "section": section,

      "title": title,
      "facePhoto": facePhoto,
      "email": email
    };
  }
}

class db {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  db() {
    firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    debugPrint("Okay database class inited");
    //firestore.
  }

  CollectionReference<Object?> addCollection(String name, String path) {
    if (global.collectionMap.containsKey(name) == true) {
      return global.collectionMap[name]!; // Returns if exists already
    }
    global.collectionMap[name] =
        firestore.collection(path); // Adding the collection
    return global.collectionMap[name]!;
  }

  Future<db_fetch_return> get(
      CollectionReference<Object?> collection, String id) async {
    try {
      DocumentSnapshot<Object?> snapshot = await collection.doc(id).get();

      if (snapshot.exists) {
        return db_fetch_return(db_fetch_status.exists, snapshot.data());
      } else {
        return db_fetch_return(db_fetch_status.nodata, null);
      }
    } catch (e) {
      // Error occurred [network issue]
      debugPrint("Error on processing $id document ${e.toString()}");
      return db_fetch_return(db_fetch_status.error, e.toString());
    }
  }

  Future<db_fetch_return> create(CollectionReference<Object?> collection,
      String id, Object dataForUpdate) async {
    try {
      await collection.doc(id).set(dataForUpdate);
      return db_fetch_return(db_fetch_status.success, null);
    } catch (e) {
      // Error occurred [network issue]
      debugPrint("Error on processing $id document ${e.toString()}");
      return db_fetch_return(db_fetch_status.error, e.toString());
    }
  }

  Future<db_fetch_return> update(CollectionReference<Object?> collection,
      String id, Map<Object, Object?> dataForUpdate) async {
    try {
      await collection.doc(id).update(dataForUpdate);
      return db_fetch_return(db_fetch_status.success, null);
    } catch (e) {
      // Error occurred [network issue]
      debugPrint("Error on processing $id document ${e.toString()}");
      return db_fetch_return(db_fetch_status.error, e.toString());
    }
  }

  Future<db_fetch_return> remove(
      CollectionReference<Object?> collection, String id) async {
    try {
      await collection.doc(id).delete();
      return db_fetch_return(db_fetch_status.success, null);
    } catch (e) {
      // Error occurred [network issue]
      debugPrint("Error on processing $id document ${e.toString()}");
      return db_fetch_return(db_fetch_status.error, e.toString());
    }
  }
}
