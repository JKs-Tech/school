import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CustomController extends GetxController {
  var isLoading = false.obs;
  var errorMsg = "".obs;
  var connected = false.obs;

  Future loadData() async {
    try {
      isLoading(true);

      // Check connectivity first
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection, but still allow app to work
        connected.value = true;
        isLoading(false);
        return connected.value;
      }

      // For now, just set connected to true
      // You can add actual API call here later
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate network delay

      connected.value = true;
      isLoading(false);
      return connected.value;
    } catch (e) {
      print('Error in loadData: $e');
      isLoading(false);
      errorMsg.value = e.toString();

      // Even if there's an error, allow the app to continue
      connected.value = true;
      return connected.value;
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }
}
