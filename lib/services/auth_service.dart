import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  // Instance FirebaseAuth, utilisée pour toutes les opérations de login/register/logout

  // Créer un compte avec email et mot de passe
  Future<String?> register({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Cette ligne envoie les infos à Firebase et crée un utilisateur
      return null; // null = pas d’erreur
    } on FirebaseAuthException catch (e) {
      // Si Firebase renvoie une erreur (ex : email déjà utilisé, mot de passe trop court)
      return e.message; // Retourne le message d’erreur
    }
  }

  // Connexion avec email et mot de passe
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Firebase va vérifier si cet email et mot de passe existent
      // Si oui, il connecte l’utilisateur et met à jour le stream authStateChanges()
      return null; // Pas d’erreur
    } on FirebaseAuthException catch (e) {
      return e.message; // Retourne le message d’erreur si l’email/mdp est incorrect
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut(); 
    // Déconnecte l’utilisateur et le stream authStateChanges() va notifier Root
  }
}
