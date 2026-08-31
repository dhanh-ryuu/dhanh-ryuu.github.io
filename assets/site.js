document.querySelectorAll('[data-copy]').forEach((button) => {
  button.addEventListener('click', async () => {
    const target = document.querySelector(button.dataset.copy);
    if (!target) return;
    await navigator.clipboard.writeText(target.textContent.trim());
    const original = button.textContent;
    button.textContent = '✓';
    window.setTimeout(() => { button.textContent = original; }, 1400);
  });
});
document.querySelectorAll('[data-year]').forEach((node) => { node.textContent = new Date().getFullYear(); });
