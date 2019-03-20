({
  onInit: function(c, e, h) {
    const fieldNames = [];
    try {
      c.get("v.fieldNames")
        .split(",")
        .forEach(function(elm) {
          let fieldName = elm.trim();
          if (fieldName.toLowerCase() == "recordtypeid") {
            throw new Error("controller.initColumns : RecordTypeId is Not Supported");
          } else if (fieldName.indexOf(".") > -1 || fieldName.indexOf(":") > -1) {
            throw new Error(`controller.initColumns : Invalid Field Name '${fieldName}' (':' and '.' are Not Supported)`);
          } else {
            fieldNames.push(fieldName);
          }
        });
    } catch (e) {
      h.showError(c, h, e.message);
      return;
    }
    if (fieldNames.length === 1 && !fieldNames[0]) fieldNames.shift();
    const p_getFields = fieldNames.length ? h.getFields(c, h, c.get("v.objectName"), fieldNames.join(",")) : Promise.resolve([]);
    p_getFields
      .then(
        $A.getCallback(function(fields) {
          const columnWidths = c
            .get("v.columnWidths")
            .split(",")
            .map(function(width) {
              if (width.trim().isNaN) return null;
              else return width.trim();
            });
          fields = fields.filter(function(field, index) {
            if (!field || !field.isUpdateable) return false;
            else if (
              field.type === "ADDRESS" ||
              field.type === "ANYTYPE" ||
              field.type === "CALCULATED" ||
              field.type === "COMBOBOX" ||
              field.type === "LOCATION" ||
              field.type === "MULTIPICKLIST" ||
              field.type === "BASE64" ||
              field.type === "DATACATEGORYGROUPREFERENCE" ||
              field.type === "ENCRYPTEDSTRING"
            ) {
              columnWidths.splice(index, 1);
              h.showError(c, h, `The type '${field.type}' for '${field.name}' of '${field.objectName}' is unsupported.`);
              return false;
            } else {
              return true;
            }
          });
          fields.forEach(function(field, idx) {
            field.width = columnWidths[idx] || "auto";
          });
          c.set("v.fields", fields);
        })
      )
      .catch(function(reason) {
        h.showError(c, h, "controller.initColumns : " + reason);
      });
  },
  onSearchBoxEvent: function(c, e, h) {
    if (c.get("v.order") - 1 != e.getParam("origin") || c.get("v.fields").length == 0) return;
    c.set("v.isLoading", true);
    c.set("v.recordIds", e.getParam("recordIds"));
    c.set("v.data", []);
    h.loadData(c, h);
  },
  create: function(c, e, h) {
    $A.get("e.force:createRecord")
      .setParams({
        entityApiName: c.get("v.objectName")
      })
      .fire();
  },
  save: function(c, e, h) {
    c.set("v.isLoading", true);
    const displayData = c.get("v.displayData");
    const data = c.get("v.data");
    let successNumber = 0;
    let errorNumber = 0;
    h.reflectChangedFields(c, h);
    const targetsToSave = h.getTargetsToSave(c, h, data, displayData);
    const recordsToSave = targetsToSave.recordsToSave;
    const indexesToSave = targetsToSave.indexesToSave;
    c.set("v.indexesToSave", indexesToSave);
    c.set("v.recordsToSave", recordsToSave);
    if (recordsToSave.length == 0) {
      console.log("No Records to Save");
      c.set("v.isLoading", false);
      return;
    }
    h.saveRecords(c, h, recordsToSave)
      .then(function(saveResults) {
        saveResults.forEach(function(result, idx) {
          const inputRecordData = displayData[indexesToSave[idx]];
          if (result.success) {
            inputRecordData.forEach(function(field) {
              field.changed = false;
              data[indexesToSave[idx]][field.name.toLowerCase()] = recordsToSave[idx][field.name];
            });
            successNumber++;
          } else {
            const errorsByFieldName = {};
            result.errors.forEach(function(err) {
              if (err.fields.length == 0 && !!err.message) h.showError(c, h, `${data[indexesToSave[idx]].id}: ${err.message}`);
              err.fields.forEach(function(errFieldName) {
                if (typeof errorsByFieldName[errFieldName] != "Array") errorsByFieldName[errFieldName] = [err.message];
                else errorsByFieldName[errFieldName].push(err.message);
              });
            });
            inputRecordData.forEach(function(field) {
              let targetFieldName = errorsByFieldName[field.name] || errorsByFieldName[field.label] || [];
              field.errors = targetFieldName.join(",");
            });
            errorNumber++;
          }
          displayData.splice(indexesToSave[idx], 1, inputRecordData);
        });
        if (successNumber) {
          h.showSuccess(c, h, `${successNumber} record${successNumber == 1 ? " was" : "s were"} successfully updated!`);
        }
        if (errorNumber) {
          h.showError(c, h, `Faild to update ${errorNumber} record${successNumber > 1 ? "s" : ""}!`);
        }
        c.set("v.displayData", displayData);
        c.set("v.data", data);
        c.set("v.isLoading", false);
      })
      .catch(function(reject) {
        console.error(reject);
      })
      .then(
        $A.getCallback(function() {
          c.set("v.isLoading", false);
        })
      );
  },
  resetRecord: function(c, e, h) {
    const displayData = c.get("v.displayData");
    const index = Number(e.getSource().get("v.name"));
    const data = c.get("v.data");
    const recordData = displayData[index];
    const originalData = data[index];
    recordData.forEach(function(field) {
      if (!field.changed) return;
      if (field.type == "time") field.value = h.toISOTimeString(c, h, originalData[field.name.toLowerCase()]);
      else field.value = originalData[field.name.toLowerCase()];
      if (field.type == "reference") {
        try {
          if (
            originalData[field.referenceRelationshipName.toLowerCase()] &&
            originalData[field.referenceRelationshipName.toLowerCase()][field.referenceNameField]
          ) {
            field.referenceDispalyValue = originalData[field.referenceRelationshipName.toLowerCase()][field.referenceNameField];
            field.value = originalData[field.referenceRelationshipName.toLowerCase()]["Id"];
          } else {
            field.referenceDispalyValue = undefined;
            field.value = undefined;
          }
        } catch (e) {
          console.error(e);
        }
      }
      field.errors = "";
      field.changed = false;
    });
    displayData.splice(index, 1, recordData);
    c.set("v.displayData", displayData);
  },
  viewRecord: function(c, e, h) {
    const index = Number(e.getSource().get("v.name"));
    const data = c.get("v.data");
    const originalData = data[index];
    window.open(`/${originalData.id}`, "_blank");
  },
  inputChange: function(c, e, h) {
    let index = undefined;
    if (typeof e.getSource == "function") {
      const source = e.getSource();
      if (source.get("v.type") == "checkbox") {
        source.set("v.value", source.get("v.checked"));
      }
      index = source.get("v.name");
      if ((isNaN(index) || index == "") && typeof source.getElement == "function") {
        index = source.getElement().closest("tr").dataset.index;
      }
    }
    window.clearTimeout(c.get("v.timer"));
    c.set(
      "v.timer",
      window.setTimeout(
        $A.getCallback(function() {
          h.reflectChangedFields(c, h, index);
        }),
        300
      )
    );
  }
});
