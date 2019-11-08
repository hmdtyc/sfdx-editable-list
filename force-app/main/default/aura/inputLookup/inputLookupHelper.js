({
  search: function(c, searchValue) {
    if (!searchValue || searchValue.length < 2) return;
    if (this.validate(searchValue)) {
      const action = c.get("c.search");
      action.setParams({
        objectName: c.get("v.referenceObjectName"),
        nameField: c.get("v.referenceNameField"),
        keyword: searchValue
      });
      return new Promise(function(resolve, reject) {
        action.setCallback(this, function(response) {
          const ret = JSON.parse(response.getReturnValue());
          if (response.getState() === "SUCCESS") ret.hasError ? reject(ret.message) : resolve(ret);
          else if (response.getState() === "ERROR") reject(response.getError());
        });
        $A.enqueueAction(action);
      });
    } else {
      this.showError(c, "Following letters are not supported. \n ? & | ! { } [ ] ( ) ^ ~ * : \\ \" ' + -");
    }
  },
  validate: function(searchValue) {
    if (searchValue.indexOf("'") > -1 || searchValue.indexOf('"') > -1) return false;
    return !searchValue.match(/[\?\&\|\!\{\}\[\]\(\)\^\~\*\:\\\+\-]/);
  },
  showError: function(c, message) {
    const isOnAppBuilder = document.location.href.toLowerCase().indexOf("flexipageeditor") >= 0;
    if (isOnAppBuilder) {
      console.error(message);
      c.set("v.errorMessage", message);
    } else {
      const toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "error",
        mode: "sticky",
        message: message
      });
      toastEvent.fire();
    }
  }
});