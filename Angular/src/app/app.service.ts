import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { sha256 } from "js-sha256";

@Injectable()
export class AppService {
  constructor(private http: HttpClient) {}

  private getCommonHeaders() {
    return new HttpHeaders({
      Accept: "application/json",
      "Content-Type": "application/json; charset=utf-8"
    });
  }

  public login(aUserName: string, aPassword: string, resultFn?) {
    this.http
      .post(
        "https://ws-a.geninfo.it/rest/api/Autenticazione",
        JSON.stringify({
          apiKey: "apikey00-del0-mio0-0000-progetto0000",
          nonce: "123456",
          userName: aUserName,
          improntaPwd: sha256(aPassword),
          idDispositivo: "il-mio-dispositivo"
        }),
        { headers: this.getCommonHeaders() }
      )
      .subscribe(
        (data: any) => {
          if (resultFn) {
            resultFn(JSON.stringify(data));
          } else {
            console.log(JSON.stringify(data));
          }
        },
        e => {
          if (resultFn) {
            resultFn(JSON.stringify(e.error));
          } else {
            console.log(JSON.stringify(e.error));
          }
        }
      );
  }
}
