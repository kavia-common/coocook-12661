import React, {useCallback, useEffect, useState} from "../../_snowpack/pkg/react.js";
import * as List from "../util/List.js";
import Ingredient, {significantChanges} from "./Ingredient.js";
import IngredientListLimit from "./IngredientListLimit.js";
import {Card} from "../../_snowpack/pkg/react-bootstrap.js";
import {DndProvider} from "../../_snowpack/pkg/react-dnd.js";
import {HTML5Backend} from "../../_snowpack/pkg/react-dnd-html5-backend.js";
import "./IngredientsEditor.css.proxy.js";
import "../util/layout.css.proxy.js";
import * as IO from "../util/io.js";
const IngredientsEditor = ({project}) => {
  const [nPIngredients, setNPIngredients] = useState([]);
  const [pIngredients, setPIngredients] = useState([]);
  const fetchIngredients = async () => {
    const allIngrs = await IO.getAllIngredients(project) || [];
    const normalIngrs = allIngrs.filter((i) => i.prepare === false);
    const preparedIngrs = allIngrs.filter((i) => i.prepare === true);
    setNPIngredients(normalIngrs);
    setPIngredients(preparedIngrs);
  };
  useEffect(() => {
    fetchIngredients();
  }, []);
  const removeIngredient = useCallback((id) => {
    setNPIngredients((prevState) => prevState.filter((elem) => elem.id !== id));
    setPIngredients((prevState) => prevState.filter((elem) => elem.id !== id));
  }, [nPIngredients, pIngredients]);
  const updateIngredient = useCallback(async (id, newData) => {
    setNPIngredients((prevState) => prevState.map((elem) => elem.id === id ? {...elem, ...newData} : elem));
    setPIngredients((prevState) => prevState.map((elem) => elem.id === id ? {...elem, ...newData} : elem));
    if (significantChanges(newData))
      await IO.updateIngredient(project, id, newData);
  }, [nPIngredients, pIngredients]);
  var IngredientMoveDirection;
  (function(IngredientMoveDirection2) {
    IngredientMoveDirection2[IngredientMoveDirection2["PreparedToPrepared"] = 0] = "PreparedToPrepared";
    IngredientMoveDirection2[IngredientMoveDirection2["PreparedToNotPrepared"] = 1] = "PreparedToNotPrepared";
    IngredientMoveDirection2[IngredientMoveDirection2["NotPreparedToPrepared"] = 2] = "NotPreparedToPrepared";
    IngredientMoveDirection2[IngredientMoveDirection2["NotPreparedToNotPrepared"] = 3] = "NotPreparedToNotPrepared";
    IngredientMoveDirection2[IngredientMoveDirection2["NoMovement"] = 4] = "NoMovement";
  })(IngredientMoveDirection || (IngredientMoveDirection = {}));
  const calculateMoveDirection = (source, target) => {
    const nPContainsSource = List.contains(nPIngredients)(equalsById(source));
    const nPContainsTarget = List.contains(nPIngredients)(equalsById(target));
    const pContainsSource = List.contains(pIngredients)(equalsById(source));
    const pContainsTarget = List.contains(pIngredients)(equalsById(target));
    if (nPContainsSource && nPContainsTarget) {
      return 3;
    } else if (pContainsSource && pContainsTarget) {
      return 0;
    } else if (nPContainsSource && pContainsTarget) {
      return 2;
    } else if (pContainsSource && nPContainsTarget) {
      return 1;
    } else {
      return 4;
    }
  };
  const moveInList = (set, source, target, transform) => {
    set((prevState) => prevState.map((elem) => {
      if (elem.position === source.position) {
        return transform(elem, target);
      } else if (elem.position === target.position) {
        return transform(elem, source);
      } else {
        return elem;
      }
    }).sort(sortByPosition));
  };
  const insertIntoList = (list, position, elem) => list.concat([{...elem, ...{position}}]);
  const increasePositionWithPredicate = (list, predicate) => list.map((ingr) => predicate(ingr) ? {...ingr, ...{position: ingr.position + 1}} : ingr);
  const moveIngredient = useCallback((source, target) => {
    const direction = calculateMoveDirection(source, target);
    switch (direction) {
      case 4:
        return;
      case 3:
        moveInList(setNPIngredients, source, target, (elem, otherElem) => ({
          ...elem,
          ...{
            position: otherElem.position,
            prepare: false
          }
        }));
        break;
      case 0:
        moveInList(setPIngredients, source, target, (elem, otherElem) => ({
          ...elem,
          ...{
            position: otherElem.position,
            prepare: true
          }
        }));
        break;
      case 1:
        source.prepare = false;
        removeIngredient(source.id);
        setNPIngredients((prevState) => {
          let result = increasePositionWithPredicate(prevState, (elem) => elem.position >= target.position);
          result = insertIntoList(result, target.position, source);
          return result.sort(sortByPosition);
        });
        break;
      case 2:
        source.prepare = true;
        removeIngredient(source.id);
        setPIngredients((prevState) => {
          let result = increasePositionWithPredicate(prevState, (elem) => elem.position >= target.position);
          result = insertIntoList(result, target.position, source);
          return result.sort(sortByPosition);
        });
        break;
    }
  }, [nPIngredients, pIngredients]);
  const appendIngredientPrepared = (droppedIngredient) => {
    removeIngredient(droppedIngredient.id);
    setPIngredients((prevState) => prevState.concat([
      {
        ...droppedIngredient,
        ...{position: prevState.length + 1, prepare: true}
      }
    ]));
  };
  const prependIngredientPrepared = (droppedIngredient) => {
    removeIngredient(droppedIngredient.id);
    setPIngredients((prevState) => {
      let newState = prevState.map((elem) => ({...elem, ...{position: elem.position + 1}}));
      return [
        {
          ...droppedIngredient,
          ...{position: prevState.length, prepare: true}
        }
      ].concat(newState);
    });
  };
  const appendIngredientNotPrepared = (droppedIngredient) => {
    removeIngredient(droppedIngredient.id);
    setNPIngredients((prevState) => prevState.concat([
      {
        ...droppedIngredient,
        ...{position: prevState.length + 1, prepare: false}
      }
    ]));
  };
  const prependIngredientNotPrepared = (droppedIngredient) => {
    removeIngredient(droppedIngredient.id);
    setNPIngredients((prevState) => {
      let newState = prevState.map((elem) => ({...elem, ...{position: elem.position + 1}}));
      return [
        {
          ...droppedIngredient,
          ...{position: prevState.length, prepare: true}
        }
      ].concat(newState);
    });
  };
  return /* @__PURE__ */ React.createElement(Card, null, /* @__PURE__ */ React.createElement(Card.Header, null, /* @__PURE__ */ React.createElement("h3", null, "Ingredients")), /* @__PURE__ */ React.createElement(Card.Body, null, /* @__PURE__ */ React.createElement(DndProvider, {
    backend: HTML5Backend
  }, /* @__PURE__ */ React.createElement("div", {
    className: "flex flex-column align-start",
    id: "ingredients-editor"
  }, /* @__PURE__ */ React.createElement("div", {
    className: "list-header"
  }, "Normal Ingredients"), /* @__PURE__ */ React.createElement("div", {
    style: {width: "100%"},
    className: "flex flex-column align-start",
    id: "not-prepared-items"
  }, /* @__PURE__ */ React.createElement(IngredientListLimit, {
    appendIngredient: prependIngredientNotPrepared,
    size: {height: "1.5rem", width: "100%"},
    text: ""
  }), nPIngredients.map((ingr_def) => /* @__PURE__ */ React.createElement(Ingredient, {
    key: ingr_def.id,
    onDelete: removeIngredient,
    onChange: updateIngredient,
    moveIngredient,
    ingredient: ingr_def
  })), /* @__PURE__ */ React.createElement(IngredientListLimit, {
    appendIngredient: appendIngredientNotPrepared,
    size: {height: "3rem", width: "100%"},
    text: nPIngredients.length === 0 ? "There are no normal ingredients yet. Drag some ingredients here!" : ""
  })), /* @__PURE__ */ React.createElement("div", {
    className: "list-header"
  }, "Prepared Ingredients"), /* @__PURE__ */ React.createElement("div", {
    style: {width: "100%"},
    className: "flex flex-column align-start",
    id: "prepared-items"
  }, /* @__PURE__ */ React.createElement(IngredientListLimit, {
    appendIngredient: prependIngredientPrepared,
    size: {height: "1.5rem", width: "100%"},
    text: ""
  }), pIngredients.map((ingr_def) => /* @__PURE__ */ React.createElement(Ingredient, {
    key: ingr_def.id,
    onDelete: removeIngredient,
    onChange: updateIngredient,
    moveIngredient,
    ingredient: ingr_def
  })), /* @__PURE__ */ React.createElement(IngredientListLimit, {
    appendIngredient: appendIngredientPrepared,
    size: {height: "3rem", width: "100%"},
    text: pIngredients.length === 0 ? "There are no prepared ingredients yet. Drag some ingredients here to make them prepared!" : ""
  }))))));
};
const sortByPosition = (a, b) => a.position - b.position;
const equalsById = (ingr1) => (ingr2) => ingr1.id === ingr2.id;
export default IngredientsEditor;
