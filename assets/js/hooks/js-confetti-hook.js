import JSConfetti from 'js-confetti';

export const ConfettiHook = {
  mounted() {
    if (this.prefersReducedMotion() || window.confetti) {
      return;
    }

    window.confetti = new JSConfetti();

    window.addEventListener('css_clash:confetti', this.handleConfetti);
  },

  async handleConfetti() {
    const confettiConfig = {
      confettiRadius: 5,
      confettiNumber: 500,
      confettiColors: [
        '#a864fd', '#29cdff', '#78ff44', '#ff718d', '#fdff6a'
      ]
    }

    for (let i = 0; i < 3; i++) {
      window.confetti.addConfetti(confettiConfig)
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  },

  prefersReducedMotion() {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  },

  destroyed() {
    window.removeEventListener('css_clash:confetti', this.handleConfetti);
  }
}
