export const isEmpty = (o) => {
  console.log("object");
  console.log(o);
  if (o) {
    console.log("keys");
    console.log(Object.keys(o));
    console.log("prototype");
    console.log(Object.getPrototypeOf(o));
  }
  return o != null && Object.keys(o).length === 0 && Object.getPrototypeOf(o) === Object.prototype;
};
