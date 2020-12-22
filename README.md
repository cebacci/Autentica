# Autentica

Al fine di facilitare la comprensione e l’utilizzo delle chiamate ad Autentica, abbiamo sviluppato dei componenti pronti all’uso, che permettono al programmatore di inglobare nel proprio applicativo le chiamate ad Autentica in modo semplice e sintetico. I sorgenti dei componenti sono a vostra disposizione e possono essere analizzati e riutilizzati liberamente (licenza LGPL) oppure possono essere consultati come esempio delle chiamate ad Autentica.

## Passwordless Experience
Una delle grandi novità di Autentica è quella di consentire agli utenti di effettuare un accesso senza l'uso della password, utilizzando la nostra app, disponibile sia per <a href="https://play.google.com/store/apps/details?id=com.geninfo.autenticapasswordless">Android</a> che per <a href="https://apps.apple.com/it/app/autentica-passwordless/id1541663793">iOS</a>.

L'utente deve, dopo aver scaricato la app, registrare il progetto e il suo nome utente, inquadrando il QR Code corrispondente che può essere scaricato con la funzione "QRCode/api-key/username". La app richiederà la password all'utente, per verificarne l'identità, e poi l'impronta biometrica (impronta digitale o face-id) per associare l'identità in modo sicuro.

Per ottenere il token mediante utilizzo della app, si dovrà passare il nome utente alla funzione "AutenticazioneBio" che effettuerà automaticamente la connessione con la app dell'utente (avvisata con notifica push) e lo scambio delle credenziali in tutta sicurezza (dopo riconoscimento biometrico).

La cosa più semplice da fare per iniziare, è utilizzare i nostri widget.

## Login Widget (HTML / javascript)
Permette di includere in una pagina html tutte le funzionalità di login, anche con funzioni biometriche e supporto alla registrazione dell'utente, cambio password e password dimenticata all’interno di un contenitore. Per poterlo utilizzare, è necessario includere nella pagina html lo script necessario con la seguente istruzione:

```<script src="http://ws-a.geninfo.it/rest/api/loginWidget"></script>```

Dopodiché è sufficiente includere il custom-tag "autentica-login", avendo cura di passare la propria apiKey e gli altri eventuali parametri:

```<autentica-login apikey="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"></autentica-login>```

| Parametro | Descrizione | Obbligatorio |
| --- | --- | --- |
| apiKey | Chiave relativa all'applicazione | Si |
| logoSrc | link al logo dell'applicazione (non indicare questo parametro per visualizzare il logo standard di Autentica) | No |
| nonce | stringa generata randomicamente | No |

Il parametro “nonce”, che si consiglia generato random e sempre diverso, deve essere contenuto nel token ricevuto in modo da sventare attacchi di tipo “replay-attack” e “a dizionario”.

Per ricevere la risposta della chiamata di autenticazione è necessario aggiungere un evento di tipo "onLoginSuccess" al custom-tag; il token è contenuto nel parametro event.detail.token.

Per ricevere eventuali errori della chiamata di autenticazione è necessario aggiungere un evento di tipo "onError" al custom-tag; il codice di errore e la descrizione sono contenuti rispettivamente in event.detail.error ed event.detail.description.

Trovate l’esempio completo in <a href="https://github.com/cebacci/Autentica/tree/main/Login%20Widget">Login Widget</a>

## Login Form (Delphi)

Se siete programmatori Delphi o Lazarus, potete scaricare <a href="https://github.com/cebacci/Autentica/blob/main/Delphi/UnitAutentica.pas">qui</a> una unit da includere nel vostro progetto ed accedere a tutte le funzionalità di login, cambio password e password dimenticata. Per poterla utilizzare è necessario includerla nel vostro progetto o form con la seguente istruzione:

```uses UnitAutentica;```

Dopodiché è sufficiente chiamare una singola funzione passando la propria apiKey e gli altri parametri richiesti:
```
if not UnitAutentica.Autenticazione('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx','123456','Titolo',IdUser,Token,MsgErrore,CodErrore) then begin
    MessageDlg('Autenticazione non riuscita a causa del seguente errore:"'#13#10#13#10 +
                MsgErrore+#13#10#13#10+
                'Cod. Errore: '+CodErrore.ToString,
                mtError,[mbOk],0);
    Exit;
end;
```
Il token risultante sarà disponibile nella variabile Token. Per vostra comodità la funzione estrae anche il valore di IdUser dal token e lo inserisce nella variabile corrispondente. ATTENZIONE! Si consiglia di effettuare sempre una validazione del token ricevuto con la propria chiave prima di utilizzarne il contenuto.

Trovate l’esempio completo in <a href="https://github.com/cebacci/Autentica/tree/main/Delphi">Delphi</a>

## Altri Esempi
Trovate in questa repository anche degli esempi in:
* <a href="https://github.com/cebacci/Autentica/tree/main/Angular">Angular</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/csharp-dotnet">C# / .net</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/js_ajax">JS / Ajax</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/php">Php</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/python">Python</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/Delphi-FMX">Delphi-FMX</a>
* <a href="https://github.com/cebacci/Autentica/tree/main/Delphi-IW">Delphi-Intraweb</a>
