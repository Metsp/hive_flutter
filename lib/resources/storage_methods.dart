import "dart:typed_data";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:uuid/uuid.dart";

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Adding an image to firebase storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    // This method takes in childname, in order to allow storing all types of photos of the app, such as profile pictures, posts etc.
    // Check if the image being uploaded is a post or not using isPost

    Reference ref = _storage.ref().child(childName).child(_auth.currentUser!
        .uid); // Ref is a pointer to the file in the storage, ref to a file that already exists, or not

    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(
        file); // UploadTask is used to choose how the file is being uploaded to firebase

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref
        .getDownloadURL(); // Used to get a URL to be saved into the firestore database
    return downloadUrl;
  }
}
