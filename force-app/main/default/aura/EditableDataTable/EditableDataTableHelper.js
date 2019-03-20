({
  loadData: function(c, h) {
    const recordIds = c.get("v.recordIds");
    let rows = c.get("v.rows");
    if (!rows || rows > 200 || rows < 1) rows = 20;
    h.getRecords(c, h, c.get("v.objectName"), JSON.stringify(c.get("v.fields")), JSON.stringify(recordIds), String(rows))
      .then(
        $A.getCallback(function(records) {
          records.forEach(function(record, index) {
            records[index] = h.setKeysToLowerCase(c, h, record);
          });
          c.set("v.data", records);
          const displayData = h.createDisplayData(c, h, c.get("v.fields"), records);
          c.set("v.displayData", displayData);
          const totalLength = c.get("v.recordIds").length;
          if (totalLength > rows) {
            h.showWarning(c, h, `Only ${rows} Results are Showing [Total: ${totalLength}]`);
          }
        })
      )
      .catch(function(reason) {
        h.showError(c, h, reason);
      })
      .then(
        $A.getCallback(function() {
          c.set("v.isLoading", false);
        })
      );
  },
  createDisplayData: function(c, h, fields, data) {
    const displayData = [];
    data.forEach(function(record) {
      const row = [];
      fields.forEach(function(field) {
        let recordInfo = {
          name: field.name,
          value: record[field.name.toLowerCase()],
          label: field.label,
          changed: false,
          errors: "",
          recordtypeid: record.recordtypeid || "012000000000000AAA"
        };
        switch (field.type) {
          case "PICKLIST":
            recordInfo.type = "picklist";
            break;
          case "REFERENCE":
            recordInfo.type = "reference";
            recordInfo.referenceObjectName = field.referenceObjectName;
            recordInfo.referenceRelationshipName = field.referenceRelationshipName;
            recordInfo.referenceNameField = field.referenceNameField;
            recordInfo.referenceDispalyValue = record[field.referenceRelationshipName.toLowerCase()]
              ? record[field.referenceRelationshipName.toLowerCase()][field.referenceNameField]
              : null;
            break;
          case "TEXTAREA":
            recordInfo.type = "textarea";
            break;
          case "CURRENCY":
            recordInfo.type = "number";
            recordInfo.formatter = "currency";
            break;
          case "PERCENT":
            recordInfo.type = "number";
            recordInfo.formatter = "percent-fixed";
            break;
          case "DATE":
            recordInfo.type = "date";
            break;
          case "DATETIME":
            recordInfo.type = "datetime";
            break;
          case "TIME":
            recordInfo.type = "time";
            recordInfo.value = h.toISOTimeString(c, h, recordInfo.value);
            break;
          case "PHONE":
            recordInfo.type = "phone";
            break;
          case "EMAIL":
            recordInfo.type = "email";
            break;
          case "URL":
            recordInfo.type = "url";
            break;
          case "BOOLEAN":
            recordInfo.type = "checkbox";
            break;
          default:
            recordInfo.type = "text";
            break;
        }
        row.push(recordInfo);
      });
      displayData.push(row);
    });
    return displayData;
  },
  navigateToSObject: function(c, h, recordId) {
    $A.get("e.force:navigateToSObject")
      .setParams({
        recordId: recordId
      })
      .fire();
  },
  setKeysToLowerCase: function(c, h, obj) {
    var key,
      keys = Object.keys(obj);
    var n = keys.length;
    var result = {};
    while (n--) {
      key = keys[n];
      result[key.toLowerCase()] = obj[key];
    }
    return result;
  },
  getFields: function(c, h, objectName, fieldNames) {
    const action = c.get("c.getFields");
    action.setParams({
      objectName: objectName,
      fieldNames: fieldNames
    });
    return new Promise(function(resolve, reject) {
      action.setCallback(this, function(response) {
        const ret = response.getReturnValue();
        if (response.getState() === "SUCCESS") ret.hasError ? reject(ret.message) : resolve(ret);
        else if (response.getState() === "ERROR") reject(response.getError());
      });
      $A.enqueueAction(action);
    });
  },
  getRecords: function(c, h, objectName, fieldsJson, recordIdsJson, rows) {
    const action = c.get("c.getRecords");
    action.setParams({
      objectName: objectName,
      fieldsJson: fieldsJson,
      recordIdsJson: recordIdsJson,
      rowsLimit: rows
    });
    return new Promise(function(resolve, reject) {
      action.setCallback(this, function(response) {
        const ret = response.getReturnValue();
        if (response.getState() === "SUCCESS") resolve(ret);
        else if (response.getState() === "ERROR") reject("errorr");
      });
      $A.enqueueAction(action);
    });
  },
  getTargetsToSave: function(c, h, data, displayData) {
    const indexesToSave = [];
    const recordsToSave = [];
    displayData.forEach(function(record, index) {
      let saveFlg = false;
      let recordObj = {
        Id: data[index].id,
        attributes: {
          type: c.get("v.objectName")
        }
      };
      record.forEach(function(field) {
        if (field.changed) saveFlg = true;
        if (field.type == "time") recordObj[field.name] = h.toMillisecTime(c, h, field.value) || null;
        else recordObj[field.name] = field.value;
      });
      if (!saveFlg) return;
      indexesToSave.push(index);
      recordsToSave.push(recordObj);
    });
    return { recordsToSave: recordsToSave, indexesToSave: indexesToSave };
  },
  saveRecords: function(c, h, recordsToSave) {
    const action = c.get("c.saveRecords");
    action.setParams({
      recordsJson: JSON.stringify(recordsToSave),
      sObjectName: c.get("v.objectName")
    });
    return new Promise(function(resolve, reject) {
      action.setCallback(this, function(response) {
        const ret = JSON.parse(response.getReturnValue());
        // console.log("=====RETURN VALUE======");
        // console.log(ret);
        if (response.getState() === "SUCCESS") ret.hasError ? reject(ret.message) : resolve(ret);
        else if (response.getState() === "ERROR") reject(response.getError());
      });
      $A.enqueueAction(action);
    });
  },
  toISOTimeString: function(c, h, millisecTime) {
    if (!millisecTime) return undefined;
    const i = new Date(millisecTime).toISOString();
    return i.substring(i.indexOf("T") + 1, i.indexOf("Z"));
  },
  toMillisecTime: function(c, h, isoTimeString) {
    if (!isoTimeString) return undefined;
    return Date.parse(`1970-01-01T${isoTimeString}Z`);
  },
  reflectChangedFields: function(c, h, index) {
    const displayData = c.get("v.displayData");
    const data = c.get("v.data");
    if (index != undefined) {
      const record = h.checkChangedFields(c, h, displayData[index], data[index]);
      displayData.splice(index, 1, record);
    } else {
      displayData.forEach(function(record, idx) {
        record = h.checkChangedFields(c, h, record, data[idx]);
      });
    }
    c.set("v.displayData", displayData);
  },
  checkChangedFields: function(c, h, record, originalRecord) {
    record.forEach(function(field) {
      if (
        originalRecord[field.name.toLowerCase()] == field.value ||
        (field.type == "time" && h.toMillisecTime(c, h, field.value) == originalRecord[field.name.toLowerCase()]) ||
        (field.type == "reference" && originalRecord[field.name.toLowerCase()] == undefined && field.value == "")
      ) {
        field.changed = false;
      } else {
        field.changed = true;
        field.errors = "";
      }
    });
    return record;
  },
  showSuccess: function(c, h, message) {
    h.showToast(c, h, "success", "pester", message);
  },
  showError: function(c, h, message) {
    h.showToast(c, h, "error", "pester", message);
  },
  showWarning: function(c, h, message) {
    h.showToast(c, h, "warning", "pester", message);
  },
  showToast: function(c, h, type, mode, message) {
    const isOnAppBuilder = document.location.href.toLowerCase().indexOf("flexipageeditor") >= 0;
    if (isOnAppBuilder && type != "success") {
      console.error(message);
      c.set("v.errorMessage", message);
    } else {
      const toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: type,
        mode: mode,
        message: message,
        duration: 5000
      });
      toastEvent.fire();
    }
  }
});
