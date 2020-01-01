import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:okra_widget/models/Enums.dart';
import 'package:okra_widget/utils/OkraOptions.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Web extends StatefulWidget {

  final OkraOptions okraOptions;

  const Web({
    Key key,
    this.okraOptions
  })  : assert(okraOptions != null), super(key: key);

  @override
  _WebState createState() => _WebState();
}


class _WebState extends State<Web> {

  WebViewController _controller;

   Uri generateLinkInitializationUrl(OkraOptions okraOptions) {
     var queryParameters = {
       'isWebview': okraOptions.isWebview.toString(),
       'key': okraOptions.key,
       'token': okraOptions.token,
       'products': convertArrayListToString(okraOptions.products),
       'env': okraOptions.env.toString(),
       'source': 'flutter',
       'uuid': okraOptions.uuid,
       'clientName': okraOptions.clientName,
     };

     return Uri.https('demo-dev.okra.ng', '/link.html', queryParameters);
   }

   String convertArrayListToString(List<Product> productList){
     String formattedArray = "[";
     for (int index = 0; index < productList.length; index++){
       if(index == (productList.length - 1)){
         formattedArray = formattedArray + "\"${productList[index].toString().split('.').last}\"";
       }else {
         formattedArray = formattedArray + "\"${productList[index].toString().split('.').last}\",";
       }
     }

     formattedArray = formattedArray + "]";

     return formattedArray.toString();
   }

//"https://demo-dev.okra.ng/link.html?isWebview=true&key=c81f3e05-7a5c-5727-8d33-1113a3c7a5e4&token=5d8a35224d8113507c7521ac&products=[%22auth%22,%22transactions%22,%22balance%22]&env=dev&clientName=Spinach"

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl : generateLinkInitializationUrl(widget.okraOptions).toString(),
      javascriptMode : JavascriptMode.unrestricted,
      javascriptChannels: Set.from([
        JavascriptChannel(
            name: 'Mobile',
            onMessageReceived: (JavascriptMessage message) {
              Navigator.pop(context);
            })
      ]),
      onWebViewCreated: (webViewController){},
      navigationDelegate: (action){
        String url = action.url;
        Uri uri = Uri.parse(url);
        uri.queryParameters.forEach((key,value) => {
         if(key == "shouldClose" && value.toLowerCase() == 'true'){
              Navigator.pop(context)
           }
         }

        );
        return NavigationDecision.navigate;
      },
    );
  }
}
