

import 'package:smart_reload_system/src/core/constants/app_strings.dart';

class EncoderFunctions {

  ///Decode------------------------------------------------------------------------------->

  ///Link Decode
  static String decodeLink({required String value}){
    if (value.startsWith('https://')) {
      return value.replaceFirst('https://', '');
    } else if (value.startsWith('http://')) {
      return value.replaceFirst('http://', '');
    }
    return value;
  }

  ///Wifi Decode
  static Map<String, String> decodeWifi({required String value}){
    Map<String, String> result = {
      'SSID': '',
      'Type': 'No Encryption',
      'Password': '',
      'Hidden': 'false',
    };

    // Regular expressions to extract values
    RegExp ssidRegex = RegExp(r'S:(.*?);');
    RegExp typeRegex = RegExp(r'T:(.*?);');
    RegExp passwordRegex = RegExp(r'P:(.*?);');
    RegExp hiddenRegex = RegExp(r'H:(.*?);');

    String? networkType = typeRegex.firstMatch(value)?.group(1);
    if(networkType == 'WPA'){
      networkType = 'WPA/WPA2';
    }else if(networkType == 'WEP'){
      networkType = networkType;
    }else{
      networkType = 'No Encryption';
    }

    // Extracting values if they exist
    result['SSID'] = ssidRegex.firstMatch(value)?.group(1) ?? '';
    result['Type'] = networkType ?? 'No Encryption';
    result['Password'] = passwordRegex.firstMatch(value)?.group(1) ?? '';
    result['Hidden'] = hiddenRegex.firstMatch(value)?.group(1) ?? 'false';

    return result;
  }

  ///Email Decode
  static Map<String, String> decodeEmail({required String value}){
    Map<String, String> result = {'SendTo': '', 'Subject': '', 'Body': ''};

    // Remove "mailto:"
    if (!value.startsWith('mailto:')) return result;
    String emailData = value.replaceFirst('mailto:', '');

    // Split the parameters
    List<String> parts = emailData.split('?subject=');
    String recipient = parts[0]; // Email Address
    String subject = '';
    String body = '';

    if (parts.length > 1) {
      List<String> subjectAndBody = parts[1].split('&body=');
      subject = subjectAndBody[0];
      if (subjectAndBody.length > 1) {
        body = subjectAndBody[1];
      }
    }

    // Decode URL-encoded characters (%20 → space)
    subject = Uri.decodeComponent(subject);
    body = Uri.decodeComponent(body);
    result['Body'] = body;
    result['Subject'] = subject;
    result['SendTo'] = recipient;
    return result;
  }

  ///Phone Decode
  static Map<String, String> decodePhone({required String phone}){
    String value = phone;
    Map<String, String> result = {'CountryLabel': '', 'CountryCode': '', 'PhoneNumber': ''};

    //assign and remove label
    String countryLabel = value.split('-')[0];
    value = value.replaceFirst('$countryLabel-', '');

    // Remove "tel:+"
    if (!value.startsWith('tel:+')) return result;
    String phoneData = value.replaceFirst('tel:+', '');

    // Split the parameters
    List<String> parts = phoneData.split('-');
    if (parts.length > 1){
      result['CountryLabel'] = countryLabel;
      result['CountryCode'] = parts[0]; // Country Code
      result['PhoneNumber'] = parts[1]; // Phone Number
    }
    return result;
  }

  ///Sms Decode
  static Map<String, String> decodeSms({required String smsValue}){
    String value = smsValue;
    Map<String, String> result = {'CountryLabel': '', 'CountryCode': '', 'PhoneNumber': '', 'Message': ''};

    //assign and remove label
    String countryLabel = value.split('-')[0];
    value = value.replaceFirst('$countryLabel-', '');

    // Remove "SMSTO:+"
    if (!value.startsWith('SMSTO:+')) return result;
    String smsData = value.replaceFirst('SMSTO:+', '');

    // Split the parameters
    String countryCode = smsData.split('-')[0];
    smsData = smsData.replaceFirst('$countryCode-', '');

    String phoneNumber = smsData.split(':')[0];
    String message = smsData.replaceFirst('$phoneNumber:', '');

    result['CountryLabel'] = countryLabel;
    result['CountryCode'] = countryCode; // Country Code
    result['PhoneNumber'] = phoneNumber; // Phone Number
    result['Message'] = message; // Message

    return result;
  }

  ///Whatsapp Decode
  static Map<String, String> decodeWhatsapp({required String whatsAppValue}){
    String value = whatsAppValue;
    Map<String, String> result = {'CountryLabel': '', 'CountryCode': '', 'PhoneNumber': '', 'Message': ''};

    //assign and remove label
    String countryLabel = value.split('-')[0];
    value = value.replaceFirst('$countryLabel-', '');

    // Remove "https://wa.me/"
    if (!value.startsWith('https://wa.me/')) return result;
    String waData = value.replaceFirst('https://wa.me/', '');

    // Split the parameters
    String countryCode = waData.split('-')[0];

    result['CountryLabel'] = countryLabel;
    result['CountryCode'] = countryCode; // Country Code
    waData = waData.replaceFirst('$countryCode-', '');

    String phoneNumber = waData.split(':')[0];
    String message = waData.replaceFirst('$phoneNumber:?text=', '');

    result['PhoneNumber'] = phoneNumber; // Phone Number
    result['Message'] = message.replaceAll('+', ' '); // Message

    return result;
  }

  ///validate Phone
  static String validatePhone({required String type, required String value}){
    String result = value;
    if((type == AppStrings.phoneData) || (type == AppStrings.smsData) || (type == AppStrings.whatsAppData)){
      String code = value.split('-')[0];
      result = value.replaceFirst('$code-', '');
      result = result.replaceFirst('-', '');
    }
    return result;
  }



  ///Encode------------------------------------------------------------------------------->

  ///Link Encode
  static String encodeLink({required String value}){
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    } else {
      return 'https://$value';
    }
  }

  ///Wifi Encode
  static String encodeWifi({required String netWorkName, required String selectedNetworkType, required String password, required bool checkedValue}){

    String netWorkType = '';
    if(selectedNetworkType == 'No Encryption'){
      netWorkType = '';
    }else if(selectedNetworkType == 'WPA/WPA2'){
      netWorkType = 'T:WPA;';
    }else{
      netWorkType = 'T:$selectedNetworkType;';
    }

    /// WIFI:S:Dialog;T:WEP;P:1234;H:true;;
    /// WIFI:S:Dialog;T:WPA;P:1234;H:true;;
    /// WIFI:S:Dialog;P:1234;H:true;;

    String result = 'WIFI:S:$netWorkName;${netWorkType}P:$password;H:';
    String hidden = 'H:true;;';
    hidden = checkedValue ? 'true;;' : 'false;;';
    result += hidden;
    return result;
  }

  ///Email Encode
  static String encodeEmail({required String bodyValue, required String sentTo, required String sub}){
    String newLetter='%20';
    String letter=' ';

    String subject = '?subject=';
    String body = '&body=';
    String to = 'mailto:';

    String bdy = bodyValue.replaceAll(letter, newLetter);
    return '$to$sentTo$subject$sub$body$bdy';
  }

  ///Phone Encode
  static String encodePhone({required String countryLabel, required String countryCode, required String phoneNumber}){
    return '$countryLabel-tel:+$countryCode-$phoneNumber';
  }

  ///Sms Encode
  static String encodeSms({required String countryLabel, required String countryCode, required String phoneNumber, required String message}){
    return '$countryLabel-SMSTO:+$countryCode-${phoneNumber.trim()}:$message';
  }

  ///Whatsapp Encode
  static String encodeWhatsapp({required String countryLabel, required String countryCode, required String phoneNumber, required String message}){
    String encodedMessage = message.replaceAll(' ', '+');
    return '$countryLabel-https://wa.me/$countryCode-${phoneNumber.trim()}:?text=$encodedMessage';
  }

}
