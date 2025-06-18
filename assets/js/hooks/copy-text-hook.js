export const CopyTextHook = {
  mounted() {
    this.el.addEventListener('click', () => {
      if (!navigator.clipboard) {
        return;
      }

      const textToCopy = this.el.getAttribute('data-copy-text');

      navigator.clipboard.writeText(textToCopy);
    });
  }
}
