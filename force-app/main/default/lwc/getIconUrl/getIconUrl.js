import { LightningElement, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class GetIconUrl extends LightningElement {
  @api objectname;
  @wire(getObjectInfo, { objectApiName: "$objectname" })
  wiredValues({ error, data }) {
    if (data) {
      const ev = new CustomEvent("objectinforetrieved", {
        detail: { data }
      });
      // Fire the custom event
      this.dispatchEvent(ev);
    } else if (error) {
      console.log("error");
      console.log(error);
    }
  }
}