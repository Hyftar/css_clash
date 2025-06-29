import { Compartment, EditorState } from "@codemirror/state"
import { EditorView, keymap, scrollPastEnd } from "@codemirror/view"
import { basicSetup } from "codemirror"
import { abbreviationTracker, emmetConfig, expandAbbreviation } from '@emmetio/codemirror6-plugin';
import { css } from "@codemirror/lang-css"
import { html } from "@codemirror/lang-html"
import { indentWithTab } from "@codemirror/commands"
import { oneDark } from "@codemirror/theme-one-dark"

export const CodeMirrorHook = {
  mounted() {
    this.editorFor = this.el.dataset.editorFor
    this.language = this.el.dataset.lang

    this.handleEvent("css_clash:set_readonly", ({ readonly }) => this.setReadonly(readonly))
    this.handleEvent("css_clash:reset_editor", ({ fullReset }) => this.resetEditor(fullReset))

    const initialContent = this.el.dataset.initialContent || ""
    const readonly = this.el.dataset.readonly === "true"

    this.readonlyCompartment = new Compartment()

    const themeCompartment = new Compartment()
    const isDark = this.isDarkMode()

    const onUpdate = EditorView.updateListener.of(
      (update) => {
        if (!update.docChanged) {
          return
        }

        window.dispatchEvent(
          new CustomEvent(
            `${this.editorFor}:document-change`,
            { detail: { value: update.state.doc.toString(), type: this.language } }
          )
        )
      }
    )

    const extensions = [
      basicSetup,
      scrollPastEnd(),
      keymap.of(
        [
          indentWithTab,
          {
            key: 'Cmd-e',
            run: expandAbbreviation
          }
        ]
      ),
      ...this.getLanguageSpecificExtensions(),
      onUpdate,
      themeCompartment.of(isDark ? oneDark : EditorView.theme({}, { dark: false }))
    ]

    extensions.push(this.readonlyCompartment.of(EditorState.readOnly.of(readonly)))

    const state = EditorState.create(
      {
        doc: initialContent,
        extensions
      }
    )

    this.darkThemeMutationObserver = new MutationObserver(() => {
      this.updateTheme(themeCompartment)
    })

    this.darkThemeMutationObserver.observe(
      document.documentElement,
      { attributes: true, attributeFilter: ["data-theme"] }
    )

    this.el.editor = new EditorView(
      {
        state,
        parent: this.el
      }
    )
  },

  destroyed() {
    this.darkThemeMutationObserver.disconnect()
  },

  resetEditor(fullReset) {
    const content = fullReset ? "" : this.el.dataset.initialContent || ""

    const transaction = this.el.editor.state.update({
      changes: {
        from: 0,
        to: this.el.editor.state.doc.length,
        insert: content
      }
    })

    this.el.editor.dispatch(transaction)

    this.setReadonly(false)
  },

  setReadonly(readonly) {
    this.el.editor.dispatch({
      effects: this.readonlyCompartment.reconfigure(EditorState.readOnly.of(readonly))
    })
  },

  getLanguageSpecificExtensions() {
    switch (this.language) {
      case "html":
        return [html(), emmetConfig.of({syntax: "html"}), abbreviationTracker({syntax: "html"})]
      case "css":
        return [css(), emmetConfig.of({syntax: "css"}), abbreviationTracker({syntax: "css"})]
      default:
        throw new Error("Unsupported language")
    }
  },

  updateTheme(themeCompartment) {
    const isDark = this.isDarkMode()

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
    if (document.documentElement.getAttribute("data-theme")) {
      return document.documentElement.getAttribute("data-theme").includes("dark")
    }

    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
  }
}
