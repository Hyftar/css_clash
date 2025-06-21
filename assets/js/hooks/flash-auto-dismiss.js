export const FlashAutoDismiss = {
  mounted() {
    setTimeout(
      async() => {
        const kind = this.el.dataset.flashKind

        this.el.classList.add("transition", "ease-in", "duration-200", "opacity-0")

        await new Promise((resolve) => setTimeout(resolve, 200))

        this.pushEvent("lv:clear-flash", { key: kind })
      },
      Number(this.el.dataset.autoDismissDelay)
    )
  }
}
