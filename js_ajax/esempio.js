var url = "https://ws-a.geninfo.it/rest/api/Autenticazione";

var xhr = new XMLHttpRequest();
xhr.open("POST", url);

xhr.setRequestHeader("Content-Type", "application/json");

xhr.onreadystatechange = function () {
   if (xhr.readyState === 4) {
      console.log(xhr.status);
      console.log(xhr.responseText);
   }};

var data = `{"apiKey": "apikey00-del0-mio0-0000-progetto0000",
          "nonce": "123456",
          "userName": "il-mio-username",
          "improntaPwd": "la-mia-impronta-sha256",
          "idDispositivo": "il-mio-dispositivo"}`;

xhr.send(data);
