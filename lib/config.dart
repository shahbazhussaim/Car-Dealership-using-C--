const String kEmailFunctionUrl =
    String.fromEnvironment('EMAIL_FUNCTION_URL', defaultValue: '');

// Optional: Allow-list of admin emails if you do not manage roles in Firestore.
// In production, prefer Firestore roles per the prompt.
const List<String> kAdminEmails = <String>[];
