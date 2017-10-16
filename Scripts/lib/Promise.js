let p = Promise;

p.reduce = (items, iterator) => {
  return Array.from(items).reduce((chain, item, i, array) => {
    return chain
      .then(() => iterator.call(iterator, item, i, array))
      .catch(err => console.error(err) && process.exit(1))
  }, Promise.resolve());
};

module.exports = p;
