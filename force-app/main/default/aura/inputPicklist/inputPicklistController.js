({
  init: function(c, e, h) {
    c.set("v.previousValue", c.get("v.value"));
  },
  setValues: function(c, e, h) {
    if (c.get("v.options").length > 0) return;
    const fieldName = c.get("v.fieldName");
    const obj = e.getParam("data")["picklistFieldValues"][fieldName];
    let values = obj.values;
    if (obj.defaultValue == null) {
      values = [{ attributes: null, label: null, validFor: Array(0), value: null }].concat(values);
    }
    c.set("v.options", values);
  },
  valueChange: function(c, e, h) {
    if (c.get("v.previousValue") == c.get("v.value")) return;
    c.set("v.previousValue", c.get("v.value"));
    c.getEvent("inputChangeEvent").fire();
  }
});