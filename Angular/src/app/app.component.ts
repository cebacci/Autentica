import { Component, VERSION } from "@angular/core";
import { AppService } from "./app.service";

@Component({
  selector: "my-app",
  templateUrl: "./app.component.html",
  styleUrls: ["./app.component.css"]
})
export class AppComponent {
  public userName: string = "";
  public password: string = "";
  public resultData: string = "risultato del login";

  constructor(private appService: AppService) {}

  login() {
    this.appService.login(this.userName, this.password, (data: string) => {
      this.resultData = data;
    });
  }
}
