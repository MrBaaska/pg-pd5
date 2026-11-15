(function() {
  const sectionKey = window.sessionStorage.getItem('ubtz:active-section-key');
  if (!sectionKey || window.parent === window) {
    return;
  }

  const prefix = 'ubtz:section:' + sectionKey + ':';
  const storage = window.localStorage;
  const storagePrototype = Object.getPrototypeOf(storage);
  const originalGetItem = storagePrototype.getItem;
  const originalSetItem = storagePrototype.setItem;
  const originalRemoveItem = storagePrototype.removeItem;
  const originalClear = storagePrototype.clear;
  const originalKey = storagePrototype.key;

  function notifyParent(action, key, value) {
    window.parent.postMessage({
      type: 'ubtz:section-storage',
      sectionKey: sectionKey,
      action: action,
      key: key,
      value: value
    }, window.location.origin);
  }

  Object.defineProperties(storagePrototype, {
    getItem: {
      configurable: true,
      value: function(key) {
        if (this !== storage) {
          return originalGetItem.call(this, key);
        }
        return originalGetItem.call(this, prefix + String(key));
      }
    },
    setItem: {
      configurable: true,
      value: function(key, value) {
        if (this !== storage) {
          return originalSetItem.call(this, key, value);
        }
        const storageKey = String(key);
        const storageValue = String(value);
        originalSetItem.call(this, prefix + storageKey, storageValue);
        if (this === storage) {
          notifyParent('set', storageKey, storageValue);
        }
      }
    },
    removeItem: {
      configurable: true,
      value: function(key) {
        if (this !== storage) {
          return originalRemoveItem.call(this, key);
        }
        const storageKey = String(key);
        originalRemoveItem.call(this, prefix + storageKey);
        if (this === storage) {
          notifyParent('remove', storageKey);
        }
      }
    },
    clear: {
      configurable: true,
      value: function() {
        if (this !== storage) {
          return originalClear.call(this);
        }
        const keys = [];
        for (let index = 0; index < this.length; index++) {
          const key = originalKey.call(this, index);
          if (key && key.startsWith(prefix)) {
            keys.push(key.slice(prefix.length));
          }
        }
        keys.forEach(key => originalRemoveItem.call(this, prefix + key));
        if (this === storage) {
          keys.forEach(key => notifyParent('remove', key));
        }
      }
    },
    key: {
      configurable: true,
      value: function(index) {
        if (this !== storage) {
          return originalKey.call(this, index);
        }
        const keys = [];
        for (let storageIndex = 0; storageIndex < this.length; storageIndex++) {
          const key = originalKey.call(this, storageIndex);
          if (key && key.startsWith(prefix)) {
            keys.push(key.slice(prefix.length));
          }
        }
        return keys[index] ?? null;
      }
    }
  });
})();
