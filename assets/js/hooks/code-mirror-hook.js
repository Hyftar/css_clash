import { basicSetup } from "codemirror";
import { Compartment, EditorState } from "@codemirror/state";
import { EditorView, keymap } from "@codemirror/view";
import { indentWithTab } from "@codemirror/commands";
import { css } from "@codemirror/lang-css";
import { html } from "@codemirror/lang-html";
import { oneDark } from "@codemirror/theme-one-dark";

export const CodeMirrorHook = {
  mounted() {
    this.editorFor = this.el.dataset.editorFor;
    this.language = this.el.dataset.lang;

    const initialContent = this.el.dataset.initialContent || "";

    const themeCompartment = new Compartment();
    const isDark = this.isDarkMode();

    const onUpdate = EditorView.updateListener.of(
      (update) => {
        if (!update.docChanged) {
          return;
        }

        window.dispatchEvent(
          new CustomEvent(
            `${this.editorFor}:document-change`,
            { detail: { value: update.state.doc.toString(), type: this.language } }
          )
        );
      }
    );

    const state = EditorState.create(
      {
        doc: initialContent,
        extensions: [
          basicSetup,
          keymap.of([indentWithTab]),
          this.getLanguage(),
          onUpdate,
          themeCompartment.of(isDark ? oneDark : EditorView.theme({}, { dark: false }))
        ]
      }
    );

    this.darkThemeMutationObserver = new MutationObserver(() => { this.updateTheme(themeCompartment) })

    this.darkThemeMutationObserver.observe(
      document.documentElement,
      { attributes: true, attributeFilter: ['data-theme'] }
    );

    this.el.editor = new EditorView(
      {
        state,
        parent: this.el
      }
    );
  },

  destroyed() {
    this.darkThemeMutationObserver.disconnect();
  },

  getLanguage() {
    switch (this.el.getAttribute('data-lang')) {
      case 'html':
        return html();
      case 'css':
        return css();
      default:
        throw new Error('Unsupported language');
    }
  },

  updateTheme(themeCompartment) {
    const isDark = this.isDarkMode();

    this.el.editor.dispatch(
      {
        effects:
          themeCompartment.reconfigure(
            [
              isDark ? oneDark : EditorView.theme({}, { dark: false })
            ]
          )
      }
    )
  },

  isDarkMode() {
    if (document.documentElement.getAttribute('data-theme')) {
      return document.documentElement.getAttribute('data-theme').includes('dark');
    }

    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }
};
