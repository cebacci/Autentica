var url = "https://ws-a.geninfo.it/rest/api/Autenticazione";

var httpRequest = (HttpWebRequest)WebRequest.Create(url);
httpRequest.Method = "POST";

httpRequest.ContentType = "application/json";

var data = @"{""apiKey"": ""apikey00-del0-mio0-0000-progetto0000"",
          ""nonce"": ""123456"",
          ""userName"": ""il-mio-username"",
          ""improntaPwd"": ""la-mia-impronta-sha256"",
          ""idDispositivo"": ""il-mio-dispositivo""}";

using (var streamWriter = new StreamWriter(httpRequest.GetRequestStream()))
{
   streamWriter.Write(data);
}

var httpResponse = (HttpWebResponse)httpRequest.GetResponse();
using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
{
   var result = streamReader.ReadToEnd();
}

Console.WriteLine(httpResponse.StatusCode);