# Autentica

Al fine di facilitare la comprensione e l’utilizzo delle chiamate ad Autentica, abbiamo sviluppato due componenti pronti all’uso, che permettono al programmatore di inglobare nel proprio applicativo le chiamate ad Autentica in modo semplice e sintetico. I sorgenti dei due componenti sono a vostra disposizione e possono essere analizzati e riutilizzati liberamente (licenza LGPL GNU) oppure possono essere consultati come esempio delle chiamate ad Autentica.

Login Widget
Permette di includere in una pagina html tutte le funzionalità di login, cambio password e password dimenticata all’interno di un <div>. Per poterlo utilizzare, è necessario includere nella pagina html lo script necessario con la seguente istruzione:
<script src="https://ws-a.geninfo.it/rest/api/loginWidget"></script>
Dopodiché è sufficiente inserire in un <div> la chiamata alla funzione vera e propria, avendo cura di passare la propria apiKey e gli altri eventuali parametri:
<div style="width: 250px; height: fit-content; margin: 25px auto 0 auto;">
  <autentica-login apikey="565D4ADF-3975-454C-9F63-1755C2C49BAF" <!--logoSrc=""-->></autentica-login>
  <p id="benvenuto" hidden="true">Benvenuto</p>
</div>

Il token risultante sarà disponibile nella variabile xxx_token_xxx

Entrate nella cartella "Login Widget"[https://github.com/cebacci/Autentica/tree/main/Login%20Widget] per scaricare l’esempio completo

"unitAutentica.pas"

Se siete programmatori Delphi o Lazarus, potete scaricare qui [https://github.com/cebacci/Autentica/blob/main/Delphi/UnitAutentica.pas] una unit da includere nel vostro progetto ed accedere a tutte le funzionalità di login, cambio password e password dimenticata. Per poterla utilizzare è necessario includerla nel vostro progetto o form con la seguente istruzione:

uses UnitAutentica;

Dopodiché è sufficiente chiamare una singola funzione passando la propria apiKey e gli altri parametri richiesti:

if not UnitAutentica.Autenticazione(‘565D4ADF-3975-454C-9F63-1755C2C49BAF’,'123456',’Titolo’,IdUser,Token,MsgErrore,CodErrore) then begin
  MessageDlg('Autenticazione non riuscita a causa del seguente errore:"'#13#10#13#10 +
               MsgErrore+#13#10#13#10+
               'Cod. Errore: '+CodErrore.ToString,
             mtError,[mbOk],0);
  Exit;
end;

Il token risultante sarà disponibile nella variabile Token. Per vostra comodità la funzione estrae anche il valore di IdUser dal token e lo inserisce nella variabile corrispondente.

Entrate nella cartella "Delphi" [https://github.com/cebacci/Autentica/tree/main/Delphi] per scaricare l’esempio completo
