importScripts('https://www.gstatic.com/firebasejs/9.0.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.2/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyBliv3875udBp2EARP3CTs0iR2t4eIZSU8",
    authDomain: "flutter-app-gastos.firebaseapp.com",
    projectId: "flutter-app-gastos",
    storageBucket: "flutter-app-gastos.appspot.com",
    messagingSenderId: "991144222743",
    appId: "1:991144222743:web:42594cfc7086965f6b3c52",
    measurementId: "G-7DBWEPP817"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log('Background message received:', message);
});
