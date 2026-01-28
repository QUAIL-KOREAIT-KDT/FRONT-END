// flutter_inappwebview 웹 지원을 위한 stub 파일
// 실제 InAppWebView 기능은 웹에서 사용하지 않지만,
// 플러그인 등록 에러를 방지하기 위해 필요한 객체들을 정의합니다.

window.flutter_inappwebview = {
  nativeCommunication: function () {},
  callHandler: function () {
    return Promise.resolve();
  },
  _callHandler: function () {
    return Promise.resolve();
  },
};

// WebView 관련 stub
window.InAppWebView = {
  setSettings: function () {},
  getSettings: function () {
    return {};
  },
};
