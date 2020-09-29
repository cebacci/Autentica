# Autentica

Al fine di facilitare la comprensione e l’utilizzo delle chiamate ad Autentica, abbiamo sviluppato due componenti pronti all’uso, che permettono al programmatore di inglobare nel proprio applicativo le chiamate ad Autentica in modo semplice e sintetico. I sorgenti dei due componenti sono a vostra disposizione e possono essere analizzati e riutilizzati liberamente (licenza LGPL GNU) oppure possono essere consultati come esempio delle chiamate ad Autentica.

## Login Widget (HTML / javascript)
Permette di includere in una pagina html tutte le funzionalità di login, cambio password e password dimenticata all’interno di un contenitore. Per poterlo utilizzare, è necessario includere nella pagina html lo script necessario con la seguente istruzione:

```<script src="http://ws-a.geninfo.it/rest/api/loginWidget"></script>```

Dopodiché è sufficiente includere il custom-tag "autentica-login", avendo cura di passare la propria apiKey e gli altri eventuali parametri:

```<autentica-login apikey="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"></autentica-login>```

Per ricevere la risposta della chiamata di autenticazione è necessario aggiungere un evento di tipo "onLoginSuccess" al custom-tag:

```
function load() {
  ...
  document.querySelector('autentica-login').addEventListener('onLoginSuccess',loginSuccess,false);
  ...
}
...
function loginSuccess(e) {
  console.log(e.detail.token);
}
...
```

Per ricevere eventuali errori della chiamata di autenticazione è necessario aggiungere un evento di tipo "onError" al custom-tag:

```
function load() {
  ...
  document.querySelector('autentica-login').addEventListener('onError',error,false);
  ...
}
...
function error(e) {
  console.log(e.status);
  console.log(e.description);
}
...
```

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
Il token risultante sarà disponibile nella variabile Token. Per vostra comodità la funzione estrae anche il valore di IdUser dal token e lo inserisce nella variabile corrispondente.

Trovate l’esempio completo in <a href="https://github.com/cebacci/Autentica/tree/main/Delphi">Delphi</a>
