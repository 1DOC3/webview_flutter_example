import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class WebView1doc3 extends StatefulWidget {
  final String initialUrl;
  final double? width;
  final double? height;

  const WebView1doc3(
      {Key? key, this.width, this.height, required this.initialUrl})
      : super(key: key);

  @override
  _WebView1doc3State createState() => _WebView1doc3State();
}

class _WebView1doc3State extends State<WebView1doc3> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;

  // Lista de extensiones consideradas descargables
  final List<String> downloadableExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  bool isDownloadable(String url) {
    print('1 downloadable: =========================> $url');
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final ext = uri.path.split('.').last.toLowerCase();
    print('2 downloadable: =========================> $ext');
    return downloadableExtensions.contains(ext);
  }

  void openFileBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri);
    } catch (e) {
      print('Error al abrir el navegador: $e');
      // Aquí podrías mostrar un diálogo o snackbar con el error
    }
  }

  Future<void> handlePrescriptionPdfDownload(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Obtener las cookies usando InAppWebViewController
      final List<Cookie> cookies =
          await CookieManager.instance().getCookies(url: WebUri.uri(uri));
      final String cookieString = (cookies ?? [])
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .join('; ');

      print('Cookies obtenidas: $cookieString'); // Para debug

      // Crear headers con las cookies y otros headers necesarios
      final Map<String, String> headers = {
        if (cookieString.isNotEmpty) 'Cookie': cookieString,
        'Accept': 'application/pdf',
        'X-Requested-With': 'XMLHttpRequest',
      };

      // Descargar el archivo
      final http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Obtener el directorio de documentos
        late final Directory directory;
        if (Platform.isIOS) {
          directory = await getTemporaryDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
        final String fileName =
            'prescripcion_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final String filePath = '${directory.path}/$fileName';

        // Guardar el archivo
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Mostrar mensaje de éxito
        print('Archivo guardado en: $filePath');

        // Abrir el archivo
        await OpenFile.open(filePath);
      } else {
        throw 'Error al descargar el archivo: ${response.statusCode}';
      }
    } catch (e) {
      print('Error durante la descarga: $e');
      // Aquí podrías mostrar un diálogo o snackbar con el error
    }
  }

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      // initialOptions: InAppWebViewGroupOptions(
      //   crossPlatform: InAppWebViewOptions(
      //     useShouldOverrideUrlLoading: true,
      //     javaScriptEnabled: true,
      //   ),
      // ),
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsPictureInPictureMediaPlayback: false,
        allowsInlineMediaPlayback: true,
      ),
      onPermissionRequest: (controller, permissionRequest) async {
        return PermissionResponse(
            resources: permissionRequest.resources,
            action: PermissionResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';

        if (isDownloadable(url)) {
          openFileBrowser(url);
          return NavigationActionPolicy.CANCEL;
        }

        if (url.contains('/api/prescription-pdf')) {
          handlePrescriptionPdfDownload(url);
          return NavigationActionPolicy.CANCEL;
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
