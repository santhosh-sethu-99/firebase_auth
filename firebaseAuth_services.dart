import 'package:firebase_auth/firebase_auth.dart';
import 'firebaseAuth_exception_handler.dart';

class FirebaseAuthServices {
  bool userChange() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        return false;
      } else {
        print('User is signed in!');
        return true;
      }
    });
    return true;
  }

  Future<String> sendEmailVeification() async {
    User user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      var actionCodeSettings = ActionCodeSettings(
        url: 'Link',
        androidInstallApp: true,
        androidPackageName: "appname",
        androidMinimumVersion: '1',
        handleCodeInApp: true,
      );

      await user.sendEmailVerification(actionCodeSettings);
      print(actionCodeSettings.dynamicLinkDomain.toString());
      return 'Verification mail sent.';
    }
    return 'Try again';
  }

  Future<AuthResultStatus> createUserWithEmailAndPassword(
      String email, String userName) async {
    AuthResultStatus resultStatus;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: userName);
      resultStatus = AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      // 'weak-password'
      // 'email-already-in-use'
      resultStatus = AuthExceptionHandler.handleException(e);
    } catch (e) {
      print(e);
      resultStatus = AuthExceptionHandler.handleException(e);
    }
    return resultStatus;
  }

  Future<AuthResultStatus> signInWithEmailAndPassword(
      String email, String password) async {
    AuthResultStatus resultStatus;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      resultStatus = AuthResultStatus.successful;
    } on FirebaseAuthException catch (e) {
      // 'user-not-found'
      // 'wrong-password'
      resultStatus = AuthExceptionHandler.handleException(e);
    }
    return resultStatus;
  }

  void deleteTheRegisteredUser() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  Future<bool> isUserEmailVerified() async {
    User user = FirebaseAuth.instance.currentUser;
    await user.reload();
    if (user.emailVerified) {
      return true;
    }
    return false;
  }

  void signOutCurrentUser() {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
      print('User Signed out activated');
    }
  }

  String userDetails(String param) {
    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      switch (param) {
        case 'email':
          return user.email;
      }
    }
    return null;
  }
}
