export const GameDisplayHook = {
  mounted() {
    this.gameRenderElement = this.el.querySelector(`[data-render-for=${this.el.id}]`);

    this.documentState = {
      html: '',
      css: ''
    };

    this.savedDocument = { ...this.documentState };

    window.addEventListener(`${this.el.id}:document-change`, this.onDocumentChange.bind(this));
    window.addEventListener('css_clash:submit', this.onSubmit.bind(this));

    window.setInterval(this.saveProgress.bind(this), 3000);
  },

  destroyed() {
    window.removeEventListener(`${this.el.id}:document-change`, this.onDocumentChange.bind(this));
    window.removeEventListener('css_clash:submit', this.onSubmit.bind(this));
  },

  onDocumentChange(e) {
    switch (e.detail.type) {
      case 'html':
        this.documentState.html = e.detail.value;
        break;
      case 'css':
        this.documentState.css = e.detail.value;
        break;
    }

    this.updateRender(this.documentState);
  },

  onSubmit(e) {
    this.pushEventTo(
      this.el,
      'submit',
      { html: this.documentState.html, css: this.documentState.css }
    );
  },

  saveProgress() {
    if (this.documentState.html === this.savedDocument.html
      && this.documentState.css === this.savedDocument.css) {
      return;
    }

    this.savedDocument = { ...this.documentState };

    this.pushEventTo(
      this.el,
      'save_progress',
      { html: this.documentState.html, css: this.documentState.css }
    );
  },

  updateRender(state) {
    this.gameRenderElement.srcdoc = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=500, initial-scale=1.0">
          <title>Game Display</title>
        </head>
        <body>
          ${state.html}
          <style>
            ${state.css}
          </style>
        </body>
      </html>
    `;
  },
}
