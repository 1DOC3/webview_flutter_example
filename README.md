# Webview Flutter example
## _Bienvenidos_

Este proyecto contiene un ejemplo básico de la integración de **1DOC3** mediante un webview en **Flutter**
## Configuración de permisos para Android
en tu archivo **AndroidManifest.xml** asegurate de tener los siguientes permisos:
```
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

## Configuración de permisos en Ios
en tu archivo **Info.plist** asegurate de tener los siguientes permisos:
```
<key>NSCameraUsageDescription</key>
// Mensaje personalizado que se le muestra al usuario
<string>Estás usando tu cámara para la videconferencia con uno de nuestros doctores</string>

<key>NSMicrophoneUsageDescription</key>
// Mensaje personalizado que se le muestra al usuario
<string>Estás usando tu micrófono para la videconferencia con uno de nuestros doctores</string>
```

Estos permisos son necesarios para el uso correcto de videollamada y envío de audios.


## Configuración del Webview

 Reemplaza la **URL** de ejemplo por la de tu proyecto
```
WebView1doc3(initialUrl: 'https://www.example.com');
```
Asegúrate de configurar correctamente los permisos. En el **Main.dart**  y  **web_view_1doc3.dart** vas a ver un ejemplo de cómo puedes hacerlo.