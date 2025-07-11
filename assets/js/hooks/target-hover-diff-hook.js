export const TargetHoverDiffHook = {
  mounted() {
    this.el.style.setProperty("--image-path", `url(${this.el.dataset.imagePath})`)
    this.el.style.setProperty("--hover-x-position", `50cqw`)

    this.el.querySelectorAll(".position-label").forEach(el => el.innerText = '--')

    this.bindEvents()

    this.handleEvent("css_clash:toggle_hover_mode", ({ active }) => {
      this.el.classList.toggle("hidden", !active)

      if (active) {
        this.bindEvents()
      } else {
        this.unbindEvents()
      }
    })
  },

  beforeUnmount() {
    this.unbindEvents()
  },

  onMouseMove({ offsetX }) {
    this.el.style.setProperty("--hover-x-position", `${offsetX}px`)
    this.el.querySelectorAll(".position-label").forEach(el => el.innerText = `${offsetX}px`)
  },

  bindEvents() {
    this.el.addEventListener("mousemove", this.onMouseMove.bind(this))
  },

  unbindEvents() {
    this.el.removeEventListener("mousemove", this.onMouseMove.bind(this))
  }
}
