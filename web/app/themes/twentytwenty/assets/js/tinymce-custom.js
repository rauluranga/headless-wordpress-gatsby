jQuery(document).on("tinymce-editor-init", function (event, editor) {
  // register the formats
  tinymce.activeEditor.formatter.register("footer-text", {
    block: "span",
    classes: "footer-text",
  })
})
