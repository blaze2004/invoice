import 'package:supabase_flutter/supabase_flutter.dart';

class InvoiceService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getInvoiceDetails() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null; // User not logged in
    }

    final userId = user.id;

    // Query the invoice table using the user ID
    final response = await supabase
        .from('invoice')
        .select('*') // Fetch all fields from the invoice table
        .eq('id', userId)
        .single(); // Ensure we get only one result

    // if (response.error != null) {
    //   print('Error fetching invoice details: ${response.error!.message}');
    //   return null;
    // }

    // Check if response contains data
    final data = response.entries;
    
    // if (data == null) {
    //   print('No invoice data found for the user');
    //   return null;
    // }

    // Return the entire invoice data as a Map
    return data as Map<String, dynamic>?;
  }
}
