import { LightningElement, wire, api } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";

export default class GetPicklistValuesByRecordType extends LightningElement {
  @api nam;
  @api rid;
  @wire(getPicklistValuesByRecordType, { objectApiName: "$nam", recordTypeId: "$rid" })
  wiredValues({ error, data }) {
    if (data) {
      const ev = new CustomEvent("picklistvaluesretrieved", {
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