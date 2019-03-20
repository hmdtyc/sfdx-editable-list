({
  init: function(c, e, h) {
    c.set("v.previousId", c.get("v.id"));
  },
  delete: function(c, e, h) {
    c.set("v.name", "");
    c.set("v.id", "");
    window.setTimeout(
      $A.getCallback(function() {
        c.find("input").focus();
      }),
      300
    );
  },
  inputChange: function(c, e, h) {
    const searchWord = e.getSource().get("v.value");
    c.set("v.searchWord", searchWord);
    if (!searchWord || searchWord.length < 2) return;
    window.clearTimeout(c.get("v.timer"));
    c.set(
      "v.timer",
      window.setTimeout(
        $A.getCallback(function() {
          h.search(c, e.getSource().get("v.value"))
            .then(
              $A.getCallback(function(result) {
                const ret = result[0];
                let searchResult = [];
                ret.forEach(function(elm) {
                  searchResult.push({
                    id: elm["Id"],
                    name: elm[c.get("v.referenceNameField")]
                  });
                });
                c.set("v.searchResult", searchResult);
              })
            )
            .catch(function(reason) {
              h.showError(c, h, "controller.initColumns : " + reason);
            });
        }),
        500
      )
    );
  },
  addIconDefinition: function(c, e) {
    const data = e.getParam("data");
    const iconDefinition = c.set("v.iconDefinition", data.themeInfo);
  },
  blur: function(c, e) {
    window.setTimeout(
      $A.getCallback(function() {
        c.set("v.hasFocus", false);
      }),
      300
    );
  },
  focus: function(c, e) {
    c.set("v.hasFocus", true);
  },
  select: function(c, e) {
    c.set("v.name", e.currentTarget.dataset.name);
    c.set("v.id", e.currentTarget.dataset.id);
    c.set("v.searchWord", "");
    c.set("v.searchResult", []);
  },
  idChange: function(c, e, h) {
    if (c.get("v.previousId") == c.get("v.id")) return;
    c.set("v.previousId", c.get("v.id"));
    c.getEvent("inputChangeEvent").fire();
  }
});
