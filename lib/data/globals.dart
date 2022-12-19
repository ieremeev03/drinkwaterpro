library drinkwater.globals;
bool isLoggedIn = false;
int service = 0;
String userPhone = '';
String userToken = '';
String? fmcAccept = '';
String? fmcToken = '';
int userId = 0;
int currentDeviceId = 0;
int currentDevicePrice = 0;
int currentDeviceTemp = 0;
int currentDevicePpm = 0;
String currentDeviceUuid = '';
double? liters = 0.0;
double? summ = 0.0;
int? order = 0;
String? currentPaymentMethod = '';
double? userLat = 0.0;
double? userLon = 0.0;
int currentDeviceMap = 0;
String payStatus = '';
bool debug = true;
int currentPouringId = 0;


//settings
int bonus = 0;
int waitPouring = 5;
int blockApp = 0;
String blockMessage = "Неизвестная ошибка";