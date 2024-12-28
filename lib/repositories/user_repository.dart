import '../models/user_model.dart';
import '../constants/firebase_constants.dart';

class UserRepository {

  Future<void> addUser(UserModel user) async {
    await usersCollection.doc(user.uid).set(user.toJson());
  }

  Future<List<UserModel>> getAllUsers() async {
    var snapshot = await usersCollection.get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
}