import {backend} from "../constants.js";
const baseUrl = (project) => {
  switch (project.type) {
    case "dish":
      return `${backend}/project/${project.id}/${project.name}/dish/${project.specificId}`;
    case "recipe":
      return `${backend}/project/${project.id}/${project.name}/recipe/${project.specificId}`;
  }
};
const fromBackendFormat = (ingredient) => ({
  id: ingredient.id,
  article: ingredient.article,
  comment: ingredient.comment,
  position: ingredient.position,
  prepare: !!ingredient.prepare,
  value: ingredient.value,
  current_unit: ingredient.current_unit,
  units: ingredient.units,
  beingDragged: false
});
const toBackendFormat = (ingredient) => {
  let result = {
    id: ingredient.id,
    article: ingredient.article,
    comment: ingredient.comment,
    position: ingredient.position,
    prepare: ingredient.prepare,
    value: ingredient.value,
    current_unit: ingredient.current_unit,
    units: ingredient.units
  };
  return result;
};
const getAllIngredients = async (project) => {
  try {
    const response = await (await fetch(`${baseUrl(project)}/ingredients`)).json();
    const final = response.map(fromBackendFormat);
    console.log("final");
    console.log(final);
    return final;
  } catch (err) {
    console.error(err);
    return null;
  }
};
const updateIngredients = async (project, ingredients) => {
  try {
    const response = await fetch(`${baseUrl(project)}/ingredients/updateAll`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ingredients: ingredients.map(toBackendFormat)})
    });
    return (await response.json()).map(fromBackendFormat);
  } catch (err) {
    return null;
  }
};
const updateIngredient = async (project, id, changes) => {
  try {
    const response = await fetch(`${baseUrl(project)}/ingredients/update`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({id, changes: toBackendFormat(changes)})
    });
    return fromBackendFormat(await response.json());
  } catch (err) {
    return null;
  }
};
export {
  getAllIngredients,
  updateIngredients,
  updateIngredient
};
