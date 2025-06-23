export const TargetDisplayHook = {
  mounted() {
    this.gameRenderElement = this.el.querySelector('[data-component-name="document-render"]')

    this.documentState = {
      html: this.el.querySelector('[data-initial-content][data-lang="html"]').dataset.initialContent || "",
      css: this.el.querySelector('[data-initial-content][data-lang="css"]').dataset.initialContent || ""
    }

    this.savedDocument = { ...this.documentState }

    window.addEventListener(`${this.el.id}:document-change`, this.onDocumentChange.bind(this))
    window.addEventListener("css_clash:submit", this.onSubmit.bind(this))

    window.setInterval(this.saveProgress.bind(this), 5000)

    this.updateRender(this.documentState)
  },

  destroyed() {
    window.removeEventListener(`${this.el.id}:document-change`, this.onDocumentChange.bind(this))
    window.removeEventListener("css_clash:submit", this.onSubmit.bind(this))
  },

  onDocumentChange(e) {
    switch (e.detail.type) {
      case "html":
        this.documentState.html = e.detail.value
        break
      case "css":
        this.documentState.css = e.detail.value
        break
      default:
        throw new Error(`Unhandled document type: ${e.detail.type}`)
    }

    this.updateRender(this.documentState)
  },

  onSubmit(_event) {
    this.pushEventTo(
      this.el,
      "submit",
      { ...this.documentState }
    )
  },

  saveProgress() {
    if (this.documentState.html === this.savedDocument.html &&
      this.documentState.css === this.savedDocument.css) {
      return
    }

    this.savedDocument = { ...this.documentState }

    this.pushEventTo(
      this.el,
      "save_progress",
      { html: this.documentState.html, css: this.documentState.css }
    )
  },

  updateRender(state) {
    this.gameRenderElement.srcdoc = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=500, initial-scale=1.0">
          <title>Target Display</title>
          <style>
            body { overflow: hidden; }
            ${state.css}
          </style>
        </head>
        <body>
          ${state.html}
        </body>
      </html>
    `
  },
}
