export const GameDisplayHook = {
  mounted() {
    this.gameRenderElement = this.el.querySelector(`[data-render-for=${this.el.id}]`)
    this.documentState = {
      html: '',
      css: ''
    }

    window.addEventListener(`${this.el.id}:document-change`, this.onDocumentChange.bind(this))
    window.addEventListener('css_clash:submit', this.onSubmit.bind(this))
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
