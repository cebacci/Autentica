<?php

$url = "https://ws-a.geninfo.it/rest/api/Autenticazione";

$curl = curl_init($url);
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);

$headers = array(
   "Content-Type: application/json",
);
curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);

$data = <<<DATA
{"apiKey": "apikey00-del0-mio0-0000-progetto0000",
          "nonce": "123456",
          "userName": "il-mio-username",
          "improntaPwd": "la-mia-impronta-sha256",
          "idDispositivo": "il-mio-dispositivo"}
DATA;

curl_setopt($curl, CURLOPT_POSTFIELDS, $data);

//for debug only!
curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);

$resp = curl_exec($curl);
curl_close($curl);
var_dump($resp);

?>

