(function () {
  const scriptId = 'cbm-jssdk';
  let sdkPromise = null;
  let iniciado = false;

  function carregarSdkSuri() {
    if (
      window.CBM &&
      typeof window.CBM.StartWebChat === 'function'
    ) {
      return Promise.resolve();
    }

    if (sdkPromise) {
      return sdkPromise;
    }

    sdkPromise = new Promise((resolve, reject) => {
      window.cbAsyncInit = function () {
        resolve();
      };

      let script = document.getElementById(scriptId);

      if (script) {
        script.addEventListener(
          'load',
          function () {
            if (
              window.CBM &&
              typeof window.CBM.StartWebChat === 'function'
            ) {
              resolve();
            }
          },
          { once: true }
        );

        script.addEventListener(
          'error',
          function () {
            reject(new Error('Erro ao carregar o SDK da Suri'));
          },
          { once: true }
        );

        return;
      }

      script = document.createElement('script');
      script.id = scriptId;
      script.src = 'https://webchat.chatbotmaker.io/cbm-jssdk.js';
      script.async = true;

      script.onerror = function () {
        sdkPromise = null;
        reject(new Error('Erro ao carregar o SDK da Suri'));
      };

      document.body.appendChild(script);
    });

    return sdkPromise;
  }

  window.startSuriChat = async function (chatbotId) {
    if (iniciado) {
      return;
    }

    await carregarSdkSuri();

    if (
      !window.CBM ||
      typeof window.CBM.StartWebChat !== 'function'
    ) {
      throw new Error('O objeto CBM não está disponível');
    }

    window.CBM.ChatbotId = chatbotId;

    await window.CBM.StartWebChat();

    iniciado = true;
  };

  window.hideSuriChat = function () {
    iniciado = false;

    const elementos = document.querySelectorAll(
      'iframe[src*="chatbotmaker"], ' +
      '[id*="cbm"], ' +
      '[class*="cbm"], ' +
      '.__talkjs_popup, ' +
      '.__talkjs_launcher'
    );

    elementos.forEach(function (elemento) {
      elemento.remove();
    });
  };
})();
})();