export function clickOutside(node, callback) {
  const handle = (e) => {
    if (!node.contains(e.target)) callback();
  };
  document.addEventListener('mousedown', handle, true);
  return {
    destroy() {
      document.removeEventListener('mousedown', handle, true);
    }
  };
}

