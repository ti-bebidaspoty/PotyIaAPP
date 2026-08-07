import 'dart:js_interop';

@JS('startSuriChat')
external JSPromise<JSAny?> _startSuriChat(JSString chatbotId);

@JS('hideSuriChat')
external void _hideSuriChat();

class ChatbotSuriService {
  static const String _chatbotId = 'cb18945079';

  bool _iniciado = false;

  Future<void> carregar() async {
    if (_iniciado) {
      return;
    }

    try {
      await _startSuriChat(_chatbotId.toJS).toDart;

      _iniciado = true;

      print('Chat da Suri iniciado com sucesso');
    } catch (erro, stackTrace) {
      _iniciado = false;

      print('Erro ao iniciar o chat da Suri: $erro');
      print(stackTrace);
    }
  }

  void remover() {
    try {
      _hideSuriChat();
      _iniciado = false;
    } catch (erro) {
      print('Erro ao remover o chat da Suri: $erro');
    }
  }
}